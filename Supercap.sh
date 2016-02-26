#/bin/bash
#Version 2.2 4/23/13
#Modified script to output PASSED or FAILED w/ failing controller number. Added in system SN to file output

#Initialize numberic variables

count=0
c=0
d=0
File_Path=/root/Supercap_learn_`uname -n`
Time_Out=40  # 15 second loops x 40 is 10 minute timeout
Controller0_complete=0 # Initial Learn Complete Controller 0
Controller1_complete=0 # Initial Learn Complete Controller 1
Controller0_Pass=controller0
Controller1_Pass=controller1

#Determine if CmdTool2 is installed and the path

Ipmitool_SN(){
	if [ -f /usr/bin/ipmitool ]
		then
		SN=$(/usr/bin/ipmitool fru | grep -m 1 "Product Serial" | awk '{print $4}')
		echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - System SN is $SN" >> $File_Path
	fi
}

CmdTool2_path(){
	if [ -f /opt/MegaRAID/CmdTool2/CmdTool264 ]
  		then
    		Path="/opt/MegaRAID/CmdTool2/CmdTool264"
	elif [ -f /opt/MegaRAID/CmdTool2/CmdTool2 ]
		then
		Path="/opt/MegaRAID/CmdTool2/CmdTool2"
	else
		echo "`uname -n` - CmdTool2 not installed" | tee -a $File_Path
		exit
	fi
}

#Get controller info
Controller_count(){
	Controller0=$($Path -adpallinfo -a0 | grep "Adapter #0")
	Controller1=$($Path -adpallinfo -a1 | grep "Adapter #1")
}

#Execute learn command on Controller
Learn(){
        Execute=$($Path -adpbbucmd -bbulearn -a$1 | grep "Adapter")
        Success=$(echo $Execute | awk '{print $5}')

	if [ $Success != "Succeeded." ]; then
		echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - Learn Command not successful on Controller $1" | tee -a $File_Path
	fi
}

failedcheck(){
	if [[ "$Requested0" == "No" && "$Active0" == "No" && "$c" == "1" ]]; then
                Controller0_complete=1
        fi

        if [[ "$Requested1" == "No" && "$Active1" == "No" && "$d" == "1" ]]; then
                Controller1_complete=1
        fi
}

#Single Controller monitoring for learn cycle completion
SingleController_learn_monitor(){
                while [ $count -le $Time_Out ]; do

                learn=$($Path -adpbbucmd -a0 | egrep 'Learn Cycle Requested|Learn Cycle Active')

                Requested=$(echo $learn | awk '{print $5}')
                Active=$(echo $learn | awk '{print $10}')

                #Once the Learn Cycle is active on Controller 0, set flag
                if [[ "$Requested" == "Yes" && "$Active" == "Yes" ]]; then
                        c=1
                fi

                #If flag is set and learn cycle is no longer active
                if [[ "$Requested" == "No" && "$Active" == "No" && "$c" == "1" ]]; then
                        Controller0_complete=1
                	break
		fi

                sleep 15
                count=`expr $count + 1`
                done

	if [[ $count -ge $Time_Out ]]; then
		echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - Supercap learn cycle timeout" | tee -a $File_Path
	fi
}

#Dual Controller monitoring for learn cycle completion
DualController_learn_monitor(){
                while [ $count -le $Time_Out ]; do
                learn0=$($Path -adpbbucmd -a0 | egrep 'Learn Cycle Requested|Learn Cycle Active')
                learn1=$($Path -adpbbucmd -a1 | egrep 'Learn Cycle Requested|Learn Cycle Active')

                Requested0=$(echo $learn0 | awk '{print $5}')
                Active0=$(echo $learn0 | awk '{print $10}')

                Requested1=$(echo $learn1 | awk '{print $5}')
                Active1=$(echo $learn1 | awk '{print $10}')

                #Once the Learn Cycle is active on Controller 0, set flag
                if [[ "$Requested0" == "Yes" && "$Active0" == "Yes" ]]; then
                        c=1
                fi

                #Once the Learn Cycle is active on Controller 1, set flag
                if [[ "$Requested1" == "Yes" && "$Active1" == "Yes" ]]; then
                        d=1
                fi

                #If flags are set on both controllers and both learn cycles are no longer active
                if [[ "$Requested0" == "No" && "$Active0" == "No" && "$c" == "1" && "$Requested1" == "No" && "$Active1" == "No" && "$d" == "1" ]]; then
			Controller0_complete=1
			Controller1_complete=1
			break
                fi

                #If learn cycle is not complete, sleep for 15 seconds and recheck.
                sleep 15
                count=`expr $count + 1`
                done
                
	if [[ $count -ge $Time_Out ]]; then
                echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - Supercap learn cycle timeout" | tee -a $File_Path
		failedcheck        
 	fi
}

SingleWB(){
        WB=$($Path -ldinfo -l0 -a0 | grep "Current Cache Policy:" | awk '{print $4}')
        if [[ "$WB" == "WriteBack," && "$Controller0_Pass" == "1" ]]; then
                echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - PASSED" | tee -a $File_Path
        elif [[ "$WB" == "WriteThrough," && "$Controller0_Pass" == "1" ]] ; then
                echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - FAILED Controller 0 Virtual Disk 0 is in WriteThrough mode" | tee -a $File_Path
        else
		echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - FAILED" | tee -a $File_Path
	fi
}

DualWB(){
        WB0=$($Path -ldinfo -l0 -a0 | grep "Current Cache Policy:" | awk '{print $4}')
        WB1=$($Path -ldinfo -l0 -a1 | grep "Current Cache Policy:" | awk '{print $4}')
	if [[ "$WB0" == "WriteBack," && "$Controller0_Pass" == "1" && "$WB1" == "WriteBack," && "$Controller1_Pass" == "1" ]]; then
                echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - PASSED" | tee -a $File_Path
        else
                if [[ "$WB0" == "WriteThrough," && "$Controller0_Pass" == "1" ]] ; then
			echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - FAILED Controller 0 Virtual Disk 0 is in WriteThrough mode" | tee -a $File_Path
		elif [[ "$WB1" == "WriteThrough," && "$Controller1_Pass" == "1" ]] ; then
			echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - FAILED Controller 1 Virtual Disk 1 is in WriteThrough mode" | tee -a $File_Path
		else
			echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - FAILED" | tee -a $File_Path
		fi
        fi
}

GetControllerTime0(){
        Initial0=$($Path -adpgettime -a0)
        Initial_date0=$(echo $Initial0 | awk '{print $5}' | awk -F/ '{print $1$2$3}' | cut -c 1,2,3,4,7,8)
        Initial_time0=$(echo $Initial0 | awk '{print $7}' | awk -F: '{print $1$2$3}')
}

GetControllerTime1(){
        Initial1=$($Path -adpgettime -a1)
        Initial_date1=$(echo $Initial1 | awk '{print $5}' | awk -F/ '{print $1$2$3}' | cut -c 1,2,3,4,7,8)
        Initial_time1=$(echo $Initial1 | awk '{print $7}' | awk -F: '{print $1$2$3}')
}

TimeCheck(){
	#Parse the time field from the log process.  When complete, execute FinalCheck
	#Passed variables
	# $1 Completed time
	# $2 Initial Controller time
	# $3 Controller ID
	# $4 Learn cycle complete variable from learn monitor
	# $5 Controller_Pass variable

	if [ $1 -gt $2 ]
                then
        	Log_complete=1
		FinalCheck $Log_complete $4 $3 $5
	else
        	FinalCheck $Log_complete $4 $3 $5
	fi
}

DateCheck(){
	#Parse the date field from the log file process. If date is newer or older, go to FinalCheck. If date is the same go 
	#to TimeCheck process.
	#Passed variables
	# $1 Completed date
	# $2 Completed time
	# $3 Initial Controller date
	# $4 Initial Controller time
	# $5 Controller ID
	# $6 Learn cycle complete variable from learn monitor
	# $7 Controller_Pass variable
	
	Log_complete=0
        
	if [ $1 -gt $3 ]
                then
		echo "Controller $5 date is newer"
        	Log_complete=1
		FinalCheck $Log_complete $6 $5 $7
	elif [ $1 -eq $3 ]
                then
                TimeCheck $2 $4 $5 $6 $7
        else
		FinalCheck $Log_complete $6 $5 $7
        fi
}

FinalCheck(){
	#Check flag from learn cycle monitoring process and flag from log file parsing process
	#Passed variables
	# $1 Log File complete
	# $2 Learn cycle complete variable from learn monitor
	# $3 Controller ID
	# $4 Controller_Pass variable

	if [[ "$1" = "1" && "$2" = "1" ]]
		then
		if [[ "$4" == "controller0" ]]
			then
			Controller0_Pass=1		
		elif [[ "$4" == "controller1" ]]
			then
			Controller1_Pass=1
		else
			echo "Unknown Controller_Pass variable"
		fi
#		echo "`date '+%m-%d-%Y %H:%M:%S'` - Learn Cycle successful on Controller $3" | tee -a $File_Path
	else
		echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - Learn Cycle not successful on Controller $3" | tee -a $File_Path
	fi
}

Complete_check(){  
	#Parse the adpalilog and grab the last instance of "153 Battery relearn complete"
	# Passed variables
	# $1 Controller ID
	# $2 Initial Controller Date
	# $3 Initial Controller Time
	# $4 Learn cycle complete variable from learn monitor
	# $5 Controller_Pass variable


        Complete=$($Path -adpalilog -a$1 | grep "153=Battery relearn completed" | tail -1)
        Complete_date=$(echo $Complete | awk '{print $1}' | awk -F/ '{print $1$2$3}')
        Complete_time=$(echo $Complete | awk '{print $2}' | awk -F: '{print $1$2$3}')

#	if [ -z $Complete_date ]
#		then
#		Complete_date=0
#	fi
#
#        if [ -z $Complete_time ]
#                then
#                Complete_time=0
#        fi

        if [ -z "$Complete" ]
                then
                #echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - No 153=Battery relearn completed found" | tee -a $File_Path
		FinalCheck 0 $4 $1 $5
        else
		DateCheck $Complete_date $Complete_time $2 $3 $1 $4 $5
	fi
}

OneControllerProcess(){
	GetControllerTime0
	Learn 0
	SingleController_learn_monitor
	Complete_check 0 $Initial_date0 $Initial_time0 $Controller0_complete $Controller0_Pass
	SingleWB
}

TwoControllerProcess(){
	GetControllerTime0
	GetControllerTime1
	Learn 0
	Learn 1
	DualController_learn_monitor
	Complete_check 0 $Initial_date0 $Initial_time0 $Controller0_complete $Controller0_Pass
	Complete_check 1 $Initial_date1 $Initial_time1 $Controller1_complete $Controller1_Pass
	DualWB
}

#Main Process Flow

echo "`uname -n` - `date '+%m-%d-%Y %H:%M:%S'` - Supercap script executed" | tee -a $File_Path

#Discover CmdTool2 Path
CmdTool2_path

#Get system SN
Ipmitool_SN

#Discover number of controllers in system
Controller_count

#If Controller1 is discovered, execute TwoControllerProcess, otherwise execute OneControllerProcess
if [ "$Controller1" == "Adapter #1" ]; then
	TwoControllerProcess
else
	OneControllerProcess
fi
