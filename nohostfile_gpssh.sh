#!/bin/bash
gpssh `psql -R' ' -A  -t -c " select distinct '-h ' || hostname from gp_segment_configuration ;"` 
