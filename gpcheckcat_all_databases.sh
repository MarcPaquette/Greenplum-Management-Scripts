#!/bin/bash
#runs a gpcheckcat on all databses.
nohup $GPHOME/bin/lib/gpcheckcat -A 2>&1 > gpcheckcat.`date +%F_%s`.log &
