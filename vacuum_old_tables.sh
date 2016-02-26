#!/bin/bash
# Author: Marc Paquette
# Date 2013-04-03
# Prevents tables from hitting maximum transaction age

MAX_AGE=170000000


##find databases with high transaction age
DATABASES=$( psql -t -c "SELECT  datname FROM pg_database where age(datfrozenxid) >= $MAX_AGE union SELECT datname FROM gp_dist_random('pg_database')  where age(datfrozenxid) >= $MAX_AGE" -d template1)

###goes through high age databases, finds high age databases
for DATABASE in $DATABASES
do
	TABLES=$(psql -t -c "select relname from pg_class where relkind ='r' and relstorage != 'x' and  age(relfrozenxid)>  $MAX_AGE union select  relname from gp_dist_random('pg_class') where relkind ='r' and relstorage != 'x' and  age(relfrozenxid)>  $MAX_AGE;" -d $DATABASE)
	######Begin Inner Loop for Vacuum
	for TABLE in $TABLES
	do
		###Vaccuums databses, analyze for good measure
		psql -e -t -c "VACUUM ANALYZE $TABLE" -d $DATABASE
		###Reindex as it's just good practice
		psql -e -t -c "REINDEX TABLE  $TABLE" -d $DATABASE
	done
	######End Inner Loop for Vacuum
done;

