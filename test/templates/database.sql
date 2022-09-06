---> databases:

SELECT * FROM pg_database;

---> schemata:

SELECT *
FROM   information_schema.schemata
WHERE  catalog_name = '%{name}';
