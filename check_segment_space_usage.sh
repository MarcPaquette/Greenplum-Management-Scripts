#!/bin/bash
gpssh -f host.all "df -h | grep data"| sed 's/\[\ /\[/g'| sed 's/\[\ /\[/g'|sort -k6 -g| column -t

