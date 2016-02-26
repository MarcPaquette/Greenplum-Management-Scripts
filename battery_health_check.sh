#!/bin/bash
omconfig storage controller action=exportlog controller=0; cat /var/log/lsi_`date +%m%d`.log | grep -A 8 'BATTERY MONITORED INFORMATION' |tail -8| cut -c 6- | grep "Full";
cat /var/log/lsi_`date +%m%d`.log | grep 'Manufacturer Name' | head -n 1
