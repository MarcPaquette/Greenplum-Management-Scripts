#!/bin/bash
ssh mdw  #get on the master
su - gpadmin  #Make sure you are gpadmin
gpstart -a #make sure the database is up
psql -t -c "select distinct hostname from gp_segment_configuration where hostname not like 'mdw%'" template1 > ~/host_shutdown #generate host file
gpstop -af # stop database before system shutdown
su - #log in as root
source /usr/local/greenplum-db/greenplum_path.sh # source the greenplum environment
gpssh -f ~gpadmin/host_shutdown -e "shutdown -h now" # shutdown all segment servers except for mdw
shutdown -h now # shutdown mdw

