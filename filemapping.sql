select 
                CH.time ,
                CH.dbid , 
                CH.desc ,
                SC.content ,
                SC.role ,
                SC.preferred_role ,
                SC.mode ,
                SC.status ,
                SC.port ,
                SC.hostname ,
                SC.address ,
                SC.replication_port ,
                SC.san_mounts ,
                FS.fsefsoid ,
                FS.fselocation
From gp_configuration_history CH
join gp_segment_configuration SC
                on CH.dbid = SC.dbid
join pg_filespace_entry FS
                on SC.dbid = FS.fsedbid;

