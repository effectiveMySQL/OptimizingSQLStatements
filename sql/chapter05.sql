# Effective MySQL: Optimizing SQL Statements by Ronald Bradford
# http://effectivemysql.com/book/optimizing-sql-statements
#

#
# chapter02.sql
#
CREATE SCHEMA IF NOT EXISTS book;
USE book;

#Covering Index
SELECT artist_id,name,founded FROM   artist WHERE  founded=1969;
ALTER TABLE artist ADD INDEX (founded);
EXPLAIN SELECT artist_id,name,founded FROM   artist WHERE  founded=1969\G
ALTER TABLE artist  DROP INDEX founded, ADD INDEX founded_name (founded,name);
EXPLAIN SELECT artist_id,name,founded FROM   artist WHERE  founded=1969\G
EXPLAIN SELECT artist_id,name,founded  FROM artist> WHERE founded=1969  AND type='Person'\G
ALTER TABLE artist  DROP INDEX founded_name,  ADD INDEX founded_type_name(founded,type,name);
EXPLAIN SELECT artist_id,name,founded  FROM artist> WHERE founded=1969  AND type='Person'\G

# Storage Engine Implications
ALTER TABLE artist ENGINE=MyISAM;
EXPLAIN SELECT artist_id,name,founded  FROM artist> WHERE founded=1969  AND type='Person'\G
ALTER TABLE artist  DROP INDEX founded_type_name,  ADD INDEX founded_myisam (founded,type,name,artist_id);
EXPLAIN SELECT artist_id,name,founded  FROM artist> WHERE founded=1969  AND type='Person'\G
ALTER TABLE artist DROP INDEX founded_myisam, ENGINE=InnoDB;

# Partial Index
SET @schema = IFNULL(@schema,DATABASE());
SELECT @schema as table_schema, CURDATE() AS today;
SELECT   table_name,
         engine,row_format as format, table_rows, 
         avg_row_length as avg_row,
         round((data_length+index_length)/1024/1024,2) as total_mb,
         round((data_length)/1024/1024,2) as data_mb,
         round((index_length)/1024/1024,2) as index_mb
FROM     information_schema.tables
WHERE    table_schema=@schema
AND      table_name = @table
\G
ALTER TABLE album DROP INDEX artist_id;
SHOW CREATE TABLE album\G
SET @table='album';
SOURCE tablesize.sql
ALTER TABLE album ADD INDEX (name);
SOURCE tablesize.sql
ALTER TABLE album  DROP INDEX name,  ADD INDEX (name(20));
SOURCE tablesize.sql

ALTER TABLE artist  DROP INDEX name,  ADD INDEX name_part (name(20));
EXPLAIN SELECT artist_id,name,founded  FROM artist  WHERE name LIKE 'Queen%'\G

# END
