#!/bin/bash
#runns a gpcheckcat on all databases
for i in `psql -l | grep '|' | grep -v 'Access privileges' | cut -f1 -d'|'`; 
 do nohup $GPHOME/bin/lib/gpcheckcat  $i  2>&1 > gpcheckcat.$i.`date +%Y%m%d_%s`.out ; 
done
