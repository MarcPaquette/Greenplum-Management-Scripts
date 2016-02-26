#!/bin/bash
#collects the failed segments logs for a given time period.
psql -t -c "
select distinct command
from (
  select
  'ssh ' || SC.hostname || ' tar czf ' || SC.hostname || '_gpseg'||SC.content||'_' || SC.preferred_role|| '_'||  substring(CH.time, 0, 11) || '.tar.gz '|| FS.fselocation || '/pg_log/' || 'gpdb-' || substring(CH.time, 0, 11) || '*.csv; ' ||
  'scp ' || SC.hostname || ':' || SC.hostname || '_gpseg'||SC.content||'_' || SC.preferred_role|| '_'||  substring(CH.time, 0, 11) || '.tar.gz .; ' ||
  'ssh ' || SC.hostname || ' rm ' || SC.hostname || '_gpseg'||SC.content||'_' || SC.preferred_role|| '_'||  substring(CH.time, 0, 11) || '.tar.gz ;'
  as command
  From gp_configuration_history CH
  join gp_segment_configuration SC
  on CH.dbid = SC.dbid
  join pg_filespace_entry FS
  on SC.dbid = FS.fsedbid
  WHERE
  CH.time between '8/10/2012' and now()
) a;" |tr '\n' ' ' | /bin/bash

