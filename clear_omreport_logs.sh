#!/bin/bash
omreport system alertlog >> ~/alertlog.`date +%Y%m%d`.log; omconfig system alertlog action=clear
omreport system esmlog >> ~/esmlog.`date +%Y%m%d`.log; omconfig system esmlog action=clear
echo "esm log and alert log have been cleared, in root's home directory"
