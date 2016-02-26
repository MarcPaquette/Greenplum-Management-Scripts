#!/bin/bash

# you can point switchlist to /etc/hosts and it will search for the following patterns and try to run over them:
# i-sw- aggr-sw e-sw vdx-sw
switchlist=/etc/hosts
#switchlist=/root/switchlist
switchuser=admin
switchpass=changeme

check_ssh ()
{
        switchip=`echo $ipaddress|tr -d '\r'`
        switchnm=`echo $switchname|tr -d '\r'`
expect <<EOD 2>&1 > /dev/null
        set timeout 600
        spawn ssh -l "$switchuser" "$switchip" -oStrictHostKeyChecking=no -oNumberOfPasswordPrompts=1
        expect "*?password:"
        send "$switchpass\r" 
        expect "*?> "
        send ":\r"
        expect "*?> "
        send "exit\r"
EOD
sshtest=$?
}

get_switch_temp ()
{
        switchip=`echo $ipaddress|tr -d '\r'`
        switchnm=`echo $switchname|tr -d '\r'`
	switch_config_backup=/usr/local/switch_config/$switchnm-running_config-`date +%m%d%Y-%H%M%S`.cfg
        check_ssh 2>&1 > /dev/null
        [ ! "$sshtest" = "0" ] && echo "`date +%m/%d/%Y-%H:%M:%S` : Failed login to $switchnm, will not  temperature" && return 1 || echo "`date +%m/%d/%Y-%H:%M:%S` : Password verified for switch $switchnm. Continue with config backup..." 
	if [ "$switchnm" = vdx* ]; then
	expect <<EOD | sed -n '/show/,$p'|grep -v show 2>&1 > $switch_config_backup
        set timeout 600
        spawn ssh -l "$switchuser" "$switchip" -oStrictHostKeyChecking=no
        expect "*?password:"
        send "$switchpass\r" 
        expect "*?> "
        send "show running-config\r"
        expect "*?> "
        send "exit\r"
EOD
	else
	expect <<EOD | tail -n +6 | head -n -2 2>&1 > $switch_config_backup
        set timeout 600
        spawn ssh -l "$switchuser" "$switchip" -oStrictHostKeyChecking=no
        expect "*?password:"
        send "$switchpass\r" 
        expect "*?> "
        send "cmsh --eval 'show run' \r"
        expect "*?> "
        send "exit\r"
EOD
	fi
}

main ()
{
	# you can point switchlist to /etc/hosts and it will search for the following patterns and try to run over them:
	# i-sw- aggr-sw e-sw vdx-sw
	# or create your own file in the format of IP Name
	switchlist=/etc/hosts
	#switchlist=/root/switchlist
	switchuser=admin
	switchpass=changeme
	switch_temp_log=/root/switch_temp.log

	# loop over all switches from input file, check that ssh is available and if so get temp.
	runtime=`date +%m/%d/%Y-%H:%M:%S`
	grep "i-sw-\|aggr-sw\|e-sw\|vdx-sw" $switchlist |sed '/^#/d'|awk '{print $1" "$2}' | while read ipaddress switchname
	do
		nmap $ipaddress -p 22 |grep ssh > /dev/null 2>&1 && get_switch_temp $switchuser $switchpass $ipaddress $switchname|| echo "`date +%m/%d/%Y-%H:%M:%S` : Skipping switch $switchname" >> $switch_temp_log
	done
}

main

