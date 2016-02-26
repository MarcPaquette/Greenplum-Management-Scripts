#!/bin/bash
while true; do date; psql template1 -c "select usename,procpid,sess_id,waiting, datname,substring(current_query,1,95),now()-query_start as \"Query Time\" from pg_stat_activity  where current_query not like '%datname%' order by query_start"; sleep 30; done;
