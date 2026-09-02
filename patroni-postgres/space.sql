select nspname || '.' || relname as "relation",
   pg_size_pretty(pg_total_relation_size(c.oid)) as "total_size"
 from pg_class c
 left join pg_namespace n on (n.oid = c.relnamespace)
 where nspname not in ('pg_catalog', 'information_schema')
   and c.relkind <> 'i'
   and nspname !~ '^pg_toast'
 order by pg_total_relation_size(c.oid) desc;