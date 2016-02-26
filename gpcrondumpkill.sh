#!/bin/bash
#Author: Marc Paquette
#Date 2013-04-05

#kill dump in master
echo 'kill on master'
ps -ef | grep gpcrondump | grep -v grep | grep -v gpcrondumpkill | awk '{print $2}'| xargs \kill 2> /dev/null 
echo 'sleeping' 
sleep 10

#kill -11 dump in master
echo 'kill -11 on master'
ps -ef | grep gpcrondump | grep -v grep | grep -v gpcrondumpkill |awk '{print $2}'| xargs \kill -11 2> /dev/null

#kill dump in segment
echo 'kill on segements'
gpssh `psql -R' ' -A -t -c "select distinct '-h ' || hostname from gp_segment_configuration"` -e "ps -ef|grep gpadmin|grep gp_dump|grep -v grep|awk '{print \$2}' | xargs \kill " | egrep -v 'ps|usage|kill'

echo 'sleeping'
sleep 10
#kill dump in segment
echo 'kill -11 on segments'
gpssh `psql -R' ' -A -t -c "select distinct '-h ' || hostname from gp_segment_configuration"` -e "ps -ef|grep gpadmin|grep gp_dump|grep -v grep|awk '{print \$2}' | xargs \kill -11 " | egrep -v 'ps|usage|kill'

