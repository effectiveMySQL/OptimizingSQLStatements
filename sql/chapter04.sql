# Effective MySQL: Optimizing SQL Statements by Ronald Bradford
# http://effectivemysql.com/book/optimizing-sql-statements
#

#
# chapter04.sql
#
CREATE SCHEMA IF NOT EXISTS book;
USE book;

#Existing Indexes
SELECT artist_id, type, founded FROM   artist WHERE  name = 'Coldplay';
EXPLAIN SELECT artist_id, type, founded FROM   artist WHERE  name = 'Coldplay'\G
SHOW CREATE TABLE artist\G

# Restricting rows with an index
EXPLAIN SELECT artist_id, type, founded FROM   artist WHERE founded=1942\G
ALTER TABLE artist ADD INDEX (founded);
EXPLAIN SELECT artist_id, type, founded FROM   artist WHERE founded=1942\G
ALTER TABLE artist ADD INDEX (founded);
EXPLAIN SELECT artist_id, type, founded FROM   artist WHERE founded=1942\G

# Joing tables with an index
EXPLAIN SELECT ar.name, ar.founded, al.name, al.first_released FROM  artist ar  INNER JOIN album al USING (artist_id) WHERE  ar.name = 'Queen'\G
ALTER TABLE album ADD INDEX (artist_id);
EXPLAIN SELECT ar.name, ar.founded, al.name, al.first_released FROM  artist ar  INNER JOIN album al USING (artist_id) WHERE  ar.name = 'Queen'\G

# Understanding index cardinality
ALTER TABLE artist ADD INDEX (type);
SET @@session.optimizer_switch='index_merge_intersection=off';
EXPLAIN SELECT artist_id, name, country_id FROM   artist WHERE founded = 1980 AND type='Band'\G
SHOW INDEXES FROM artist\G
EXPLAIN SELECT artist_id, name, country_id FROM   artist WHERE founded BETWEEN 1980 AND 1989 AND type='Band'\G
EXPLAIN SELECT artist_id, name, country_id FROM   artist WHERE founded BETWEEN 1980 AND 1989 AND type='Combination'\G

#Using indexes for pattern matching
EXPLAIN SELECT artist_id, type, founded FROM   artist WHERE  name LIKE 'Queen%'\G
EXPLAIN SELECT artist_id, type, founded FROM   artist WHERE  name LIKE '%Queen%'\G
EXPLAIN SELECT artist_id, type, founded FROM   artist WHERE  UPPER(name) = UPPER('Billy Joel')\G

# Selecting a unique row
FLUSH STATUS;
SHOW SESSION STATUS  LIKE 'Handler_read_next';
SELECT name FROM artist WHERE name ='Enya';
SHOW SESSION STATUS  LIKE 'Handler_read_next';

ALTER TABLE artist DROP INDEX name,ADD UNIQUE INDEX(name);

FLUSH STATUS;
SHOW SESSION STATUS  LIKE 'Handler_read_next';
SELECT name FROM artist WHERE name ='Enya';
SHOW SESSION STATUS  LIKE 'Handler_read_next';


# Ordering Results
EXPLAIN SELECT name,founded FROM artist  WHERE name like 'AUSTRALIA%' ORDER BY founded\G
FLUSH STATUS;
SELECT name,founded FROM artist  WHERE name like 'AUSTRALIA%' ORDER BY founded\G
SHOW SESSION STATUS LIKE '%sort%';
EXPLAIN SELECT name,founded FROM artist  WHERE name like 'AUSTRALIA%' ORDER BY name\G
FLUSH STATUS;
SELECT name,founded FROM artist  WHERE name like 'AUSTRALIA%' ORDER BY name\G
SHOW SESSION STATUS LIKE '%sort%';

# Determining which index to use
ALTER TABLE album ADD INDEX (country_id), ADD INDEX (album_type_id);
SET @@session.optimizer_switch='index_merge_intersection=off';
EXPLAIN SELECT al.name, al.first_released, al.album_type_id FROM   album al WHERE al.country_id=221 AND album_type_id=1\G
EXPLAIN SELECT al.name, al.first_released, al.album_type_id FROM   album al WHERE al.country_id=221 AND album_type_id=4\G
SHOW INDEXES FROM album\G
SELECT COUNT(*) FROM album where country_id=221;
SELECT COUNT(*) FROM album where album_type_id=4;
SELECT COUNT(*) FROM album where album_type_id=1;

# Providing a Better Index
ALTER TABLE album ADD INDEX m1 (country_id, album_type_id);
EXPLAIN SELECT al.name, al.first_released, al.album_type_id FROM   album al WHERE al.country_id=221 AND album_type_id=4\G
ALTER TABLE album ADD INDEX m2 (album_type_id,country_id);
EXPLAIN SELECT al.name, al.first_released, al.album_type_id FROM   album al WHERE al.country_id=221 AND album_type_id=4\G
SHOW INDEXES FROM album\G

# Many column indexes
ALTER TABLE artist ADD index (type,gender,country_id);
EXPLAIN SELECT name FROM artist WHERE type= 'Person' AND     gender='Male' AND     country_id = 13\G
EXPLAIN SELECT name FROM artist WHERE type= 'Person' AND     gender='Male'\G

# Combining WHERE and ORDER BY
ALTER TABLE album ADD INDEX (name);
EXPLAIN SELECT a.name, ar.name, a.first_released FROM album a INNER JOIN artist ar USING (artist_id) WHERE a.name = 'Greatest Hits' ORDER BY a.first_released\G
ALTER TABLE album ADD INDEX name_release (name,first_released);
EXPLAIN SELECT a.name, ar.name, a.first_released FROM album a INNER JOIN artist ar USING (artist_id) WHERE a.name = 'Greatest Hits' ORDER BY a.first_released\G

# MySQL optimizer features
SET @@session.optimizer_switch='index_merge_intersection=on';
EXPLAIN SELECT artist_id, name FROM   artist WHERE  name = 'Queen' OR founded = 1942\G
EXPLAIN SELECT artist_id, name FROM   artist WHERE  type = 'Band' AND founded = 1942\G
EXPLAIN SELECT artist_id, name FROM   artist WHERE  name = 'Queen' OR (founded  BETWEEN 1942 AND 1950)\G
EXPLAIN SELECT artist_id, name FROM   artist WHERE  name = 'Queen' OR (type = 'Band' AND    founded = 1942)\G

# Query Hints
EXPLAIN SELECT album.name, artist.name, album.first_released FROM artist INNER JOIN album USING (artist_id) WHERE album.name = 'Greatest Hits'\G
EXPLAIN SELECT STRAIGHT_JOIN album.name, artist.name, album.first_released FROM artist INNER JOIN album USING (artist_id) WHERE album.name = 'Greatest Hits'\G
EXPLAIN SELECT artist_id, name, country_id FROM   artist WHERE founded = 1980 AND type='Band'\G
EXPLAIN SELECT artist_id, name, country_id FROM   artist USE INDEX (type) WHERE founded = 1980 AND type='Band'\G
EXPLAIN SELECT artist_id, name, country_id FROM   artist IGNORE INDEX (founded)  WHERE founded = 1980 AND type='Band'\G
EXPLAIN SELECT artist_id, name, country_id FROM   artist IGNORE INDEX (founded,founded_2) USE INDEX (type_2) WHERE founded = 1980 AND type='Band'\G

# DML Impact
DROP TABLE IF EXISTS t1;
CREATE TABLE t1 LIKE album;
INSERT INTO t1 SELECT * FROM album;
DROP TABLE t1;
CREATE TABLE t1 LIKE album;
#ALTER TABLE t1 DROP INDEX first_released, DROP INDEX album_type_id, DROP INDEX name, DROP INDEX country_id, DROP INDEX m1, DROP INDEX m2;
ALTER TABLE t1  DROP INDEX album_type_id, DROP INDEX country_id, DROP INDEX m1, DROP INDEX m2;
INSERT INTO t1 SELECT * FROM album;
DROP TABLE t1;



# END
