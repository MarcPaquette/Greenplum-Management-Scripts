#!/bin/bash
gdb postgres  -batch -ex 'set width 400' -ex 'bt' -ex 'set print elements 0' -ex 'p debug_query_string' -c 
