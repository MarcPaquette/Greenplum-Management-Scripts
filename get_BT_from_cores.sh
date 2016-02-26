#!/bin/bash
#add gpssh
#add $GPHOME
find /var/core -mmin -720 -type f | xargs -L1 -I{} gdb /usr/local/GP-4.2.2.1/bin/postgres -c {} -batch -ex 'bt' -ex 'quit'

