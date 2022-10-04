---> info:

SELECT * FROM pg_database WHERE datname = '%<name>s'

---> schema_names:

SELECT schema_name
FROM information_schema.schemata
WHERE catalog_name = '%<name>s'
