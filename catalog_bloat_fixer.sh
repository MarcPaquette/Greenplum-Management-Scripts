#!/bin/bash

BLOAT_LEVEL_ACTION=5
ANALYZE_FNAME=/tmp/analyze_cleanup.sql
VACFULL_FNAME=/tmp/vacuum_cleanup.sql
REINDEX_FNAME=/tmp/reindex_cleanup.sql

GP_DATABASES="$( psql -t -A -c " select datname from pg_database where datname <> 'template0' ;")"

for db in $GP_DATABASES; do
    echo Generating script to ANALYZE database $db: $ANALYZE_FNAME
    psql -Atc "select 'ANALYZE ' || schemaname || '.' || tablename || ';' from pg_tables where schemaname = 'pg_catalog' order by tablename ;" $db > $ANALYZE_FNAME

    echo Analyzing database $db
    psql -af $ANALYZE_FNAME $db

    echo Generating script to VACUUM database $db: $VACFULL_FNAME
    psql -Atc "select 'VACUUM FULL ' || T.schemaname || '.' || T.tablename || ';' from pg_tables T join gp_toolkit.gp_bloat_diag B on  T.schemaname = B.bdinspname  and T.tablename  = B.bdirelname where schemaname = 'pg_catalog' and bdirelpages/case when bdiexppages = 0 then 1 else bdiexppages end  >= $BLOAT_LEVEL_ACTION order by tablename;" $db > $VACFULL_FNAME

    echo Generating script to REINDEX database $db: $REINDEX_FNAME
    psql -Atc "select 'REINDEX TABLE ' || T.schemaname || '.' || T.tablename || ';' from pg_tables T join gp_toolkit.gp_bloat_diag B on  T.schemaname = B.bdinspname  and T.tablename  = B.bdirelname where schemaname = 'pg_catalog' and bdirelpages/case when bdiexppages = 0 then 1 else bdiexppages end  >= $BLOAT_LEVEL_ACTION order by tablename;" $db > $REINDEX_FNAME

    echo Vacuuming catalog for database $db
    psql -af $VACFULL_FNAME $db
    
    echo REINDEX catalog for database $db
    psql -af $REINDEX_FNAME $db

    /bin/rm -f $ANALYZE_FNAME
    /bin/rm -f $VACFULL_FNAME
    /bin/rm -f $REINDEX_FNAME
done

