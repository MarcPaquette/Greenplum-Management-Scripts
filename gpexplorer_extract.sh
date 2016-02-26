#!/bin/bash
open_gpexplorer()
{
gpexplorer_file=$1
if [ $# -ne 0 ]; then
         gpexp_dir=`echo $1|awk -F. '{print $1}'`
         mkdir $gpexp_dir
         mv $gpexplorer_file $gpexp_dir
         cd $gpexp_dir
         tar_location=`awk '/^__GPEXPLORER_LOG_ABOVE__/ {print NR + 1; exit 0; }' $gpexplorer_file`
         if [ -z "$tar_location" ]; then
                 tar jxvf $gpexplorer_file
         else
                 (( log_section=tar_location-2 ))
                 # extracting the gpexplorer run log we might get old compression format
                 if echo $gpexplorer_file | grep tgz; then
                         head -n $log_section $gpexplorer_file > `echo $gpexplorer_file|sed 's/tgz/log/'`
                         # extracting the gpexplorer data
                         tail -n+$tar_location $gpexplorer_file | tar xvmz -C ./
                 else
                         head -n $log_section $gpexplorer_file > `echo $gpexplorer_file|sed 's/bz2/log/'`
                         # extracting the gpexplorer data
                         tail -n+$tar_location $gpexplorer_file | tar xvmj -C ./
                 fi
         fi
         for x in `ls gphealthcheck_*`
         do
                tar jxvf $x
         done
         for x in `ls gposhwcheck*`
         do
          hostdir=`echo $x|awk -F- '{print $2}'`
          mkdir $hostdir
          mv $x $hostdir/
          cd $hostdir
          tar jxvf $x
          cd ..
         done
fi
}

