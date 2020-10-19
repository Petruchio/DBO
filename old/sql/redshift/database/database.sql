---> databases

SELECT * FROM pg_catalog.pg_database

---> database_names

SELECT datname FROM pg_catalog.pg_database

---> views

SELECT * FROM pg_catalog.pg_views

---> tables

SELECT * FROM pg_catalog.pg_tables

---> select

SELECT * FROM %{schema}.%{table}

---> where

	SELECT * FROM %{schema}.%{table} WHERE %{where}

---> cursor

DECLARE %{name} CURSOR WITHOUT HOLD FOR %{query}

---> next_n

FETCH FORWARD %{step} FROM %{cursor}

---> reloid

SELECT c.oid,
	n.nspname,
	c.relname
FROM pg_catalog.pg_class c
	 LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relname OPERATOR(pg_catalog.~) '^(%{relation})$'
	AND n.nspname OPERATOR(pg_catalog.~) '^(%{schema})$'
ORDER BY 2, 3;

---> relattrs

SELECT
	relchecks,
	relkind,
	relhasindex,
	relhasrules,
	reltriggers <> 0,
	false,
	false,
	relhasoids,
	false as relispartition,
	'',
	reltablespace
FROM pg_catalog.pg_class
WHERE oid = '%{oid}';

---> colattrs

SELECT a.attname,
	pg_catalog.format_type(a.atttypid, a.atttypmod),
	(SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid, true) for 128)
	 FROM pg_catalog.pg_attrdef d
	 WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef),
	a.attnotnull,
	NULL AS attcollation,
	''::pg_catalog.char AS attidentity,
	''::pg_catalog.char AS attgenerated
FROM pg_catalog.pg_attribute a
WHERE a.attrelid = '%{relid}' AND a.attnum > 0 AND NOT a.attisdropped
ORDER BY a.attnum;

---> create_table

CREATE TABLE %{schema}.%{table} (
	%{definition}
);

---> schemata

SELECT nspname
FROM   pg_catalog.pg_namespace
WHERE  nspname NOT LIKE 'pg_%'  -- *Technically* too general.
AND    nspname != 'information_schema'

---> rows

SELECT count(*)
FROM   %{schema}.%{table}

---> view_def2

SELECT
	nspname,
	relname,
	relkind,
	pg_catalog.pg_get_viewdef(c.oid, true),
	pg_catalog.array_remove(
		pg_catalog.array_remove(
			c.reloptions,
			'check_option=local'
		),
		'check_option=cascaded'
	) AS reloptions,
	CASE
		WHEN 'check_option=local'    = ANY (c.reloptions) THEN 'LOCAL'::text
		WHEN 'check_option=cascaded' = ANY (c.reloptions) THEN 'CASCADED'::text
		ELSE NULL
	END AS checkoption
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n
ON c.relnamespace = n.oid
WHERE c.oid = %{oid}

---> view_def

SELECT definition
FROM   pg_catalog.pg_views
WHERE  (schemaname, viewname) = ('%{schema}', '%{view}')

---> column_names

SELECT column_name
FROM   information_schema.columns

---> schema_columns

SELECT column_name
FROM   information_schema.columns
WHERE  schema_name = '%{schema}'

---> table_columns

SELECT column_name
FROM   information_schema.columns
WHERE  (schema_name, table_name) = ('%{schema}', '%{table}')

---> column_data

SELECT *
FROM   information_schema.columns
WHERE  (schema_name, table_name, column_name)
     = ('%{schema}', '%{table}', '%{column}')
