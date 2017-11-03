# Greenplum-Management-Scripts
  Using these commands can *DESTROY* your database if you don't know what your doing. I bear no responsiblities for your actions with these scripts. Use at your own risk.
  
## Script documentation

### allow_system_table_mods.sql
  Allows you to modify the data in system tables.


### catalog_bloat_fixer.sh
  Cleans out catalog bloat from creating and deleting multiple objects. Run only during maintenence windows as it holds exclusive locks on many important system tables.  Written with Lubomir Petrov


### check_segment_space_usage.sh
  Print out disk space usage on DCA's.  Can be helpful in identifying skew.

### collect_failed_segment_logs.sh
  Collect the logs from a failed segment. Script needs to be updated with date of failure.

### filemapping.sql
  Shows where the segement's data directories are mapped to.  Useful for identifying database data directories

### gdb_core_bt_query.sh
  Get the backtrace and query from a Greenplum core dump.  Answers the question "what query caused the database to panic?"

### get_BT_from_cores.sh
  Get the backtrace of all the core files that were generated on a DCA. 

### gpcheckcat_all_databases.sh
  Run gpecheckcat on all databases and log it to a file.  Run on a system with NO activity

### gpcrondumpkill.sh
  gpcrondump used to hang.  This script will cancel the gpcrondump in the right order using the right escalation of kill signals.


### gpexplorer_extract.sh
  Extract the data from a gpexplorer output.  Archaic.

### max_fsm_setter.sh
  Answers the question "What should I set my max_fsm to?"

### monitor_stat_activity.sh
  Monitor active queries

### nohostfile_gpssh.sh
  gpssh without having to use a hostfile 

### orphan_proccess_finder.sh
  GPDB used to have an issue where processes would get orphaned.  It's been fixed, but this script will identify process that are no longer being tracked by GPDB (orphaned)

### postgres.gdb
  gdb scripts to work with gpdb cores. Written by Dan Lynch

### postgres.gdb.txt
   postgres.gdb usage written by Dan Lynch

### pre_4.1_gpcheckcat_all_databases.sh
  run gpcheckcat on all database, versions 4.1 and lower.

### querytext.sh
  Get the backtrace and query from a Greenplum core dump.  Answers the question "what query caused the database to panic?"

### redistribute.sql
  Redistribute a table based off of the OID.  run this command offline. Written by Lubomir Petrov

### segment_file_mapping.sql
  Map data files to database id's. 

### vacuum_old_tables.sh
  Finds tables with OLD transcaction id's.  Prevents Transaction ID wraparound (data loss) This corrects lack of maintenance.


## DCA Directory:
  Scripts specific to DCA hardware (mostly v1)

### Supercap.sh
  Does stuff with DCA v2 Super caps. Checks health, etc.. I didn't write this.

### battery_health_check.sh
  Check the health of the RAID controller batteries on a DCA v1.

### clear_omreport_logs.sh
  Clear out the omreport logs when they fill up. 

### dca_shutdown_script.sh
  Cleanly shutdown a DCA.

### force_write_back.sh
  DCA V1's could have performance issues with batteries on the RAID controllers, this forced this.  Risk of dataloss for performance improvments...

### switch_config_backup.sh
  Backup the switch config.  Writen by Sagy Volkov
