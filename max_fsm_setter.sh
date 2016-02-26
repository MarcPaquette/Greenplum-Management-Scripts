echo 'max_fsm_relations should be set to :'
 for i in $(psql -t -c'select datname from pg_database;'); do psql -t -c ' select count(1) from  (select '1' from pg_tables union all select '1' from pg_indexes) as a;' $i;done 2> /dev/null | grep '[0-9]' | awk '{ sum+=$1} END {print sum * 1.20}' | cut -f1 -d'.'

echo 'your current settings are: '
gpconfig -s max_fsm_relations
echo
echo 'max_fsm_pages should be set to :'
 for i in $(psql -t -c'select datname from pg_database;'); do psql -t -c ' select count(1) from  (select '1' from pg_tables union all select '1' from pg_indexes) as a;' $i;done 2> /dev/null | grep '[0-9]' | awk '{ sum+=$1} END {print sum * 1.20 * 17}' | cut -f1 -d'.'

echo 'your current settings are: '
gpconfig -s max_fsm_pages
