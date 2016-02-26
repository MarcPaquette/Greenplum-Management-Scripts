
create or replace function gp_reredistribute(t oid) returns text as
$$
DECLARE
   distr_clause text;
   table_name text;
   cmd text;
   attr_num int;
   attr_name text;
BEGIN
   -- USAGE:
   --
   -- SELECT gp_reredistribute(74740395);
   --
   select n.nspname || '.' || c.relname into table_name from pg_class c join pg_namespace n on c.relnamespace = n.oid where c.oid = $1 and relkind = 'r';
   IF NOT FOUND THEN
       raise notice 'Cannot find (%)', $1;
       return '';
   END IF;
 
   -- GET DISTRIB CLAUSE IN PROPER ORDER
   distr_clause := '';
   for attr_num in (select unnest(attrnums) x from gp_distribution_policy where localoid = $1) loop
       select attname into attr_name from pg_attribute where attrelid = $1 and attnum = attr_num;
       if (distr_clause != '') then
          distr_clause := distr_clause || ',';
       end if;
       distr_clause := distr_clause || attr_name;
   end loop;
 
   -- select string_agg(a.attname, ',') into distr_clause from (select * from pg_attribute where attrelid=$1) a join (select unnest(attrnums) x from gp_distribution_policy where localoid = $1) d on a.attnum = d.x;
   -- raise notice '%', distr_clause;
   if (distr_clause IS NULL OR distr_clause = '') then
      raise notice 'NULL distribution';
      return '';
   end if;
 
   cmd := '';
   cmd := cmd || 'ALTER TABLE ' || table_name || ' SET with (reorganize = false) DISTRIBUTED RANDOMLY;';
   cmd := cmd || E'\nALTER TABLE ' || table_name || ' SET with (reorganize = true) DISTRIBUTED BY (' || distr_clause || ');';
 
   return cmd;
END
$$ language plpgsql;

