#!/bin/bash
ORPHAN="ps auwxx | grep postgres |grep con[0-9]  |`psql -R'|' -A  -t -c "select ' grep -v con'|| sess_id::text from pg_stat_activity;" `"
gpssh `psql -R' ' -A  -t -c " select distinct '-h ' || hostname from gp_segment_configuration ;"` -e $ORPHAN

