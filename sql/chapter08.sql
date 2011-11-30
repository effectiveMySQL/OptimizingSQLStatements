# Effective MySQL: Optimizing SQL Statements by Ronald Bradford
# http://effectivemysql.com/book/optimizing-sql-statements
#

#
# chapter08.sql
#
CREATE SCHEMA IF NOT EXISTS book;
USE book;

# Combining your DDL
ALTER TABLE test ADD INDEX (username);
ALTER TABLE test DROP INDEX name, ADD INDEX name (last_name,first_name);
ALTER TABLE test ADD COLUMN last_visit DATE NULL;
ALTER TABLE test 
ADD INDEX (username),
DROP INDEX name, 
ADD INDEX name (last_name,first_name),
ADD COLUMN last_visit DATE NULL;

#Removing Duplicate Indexes
DROP TABLE IF EXISTS test;
CREATE TABLE test(
   id INT UNSIGNED NOT NULL,
   first_name VARCHAR(30) NOT NULL,
   last_name  VARCHAR(30) NOT NULL,
   joined     DATE NOT NULL,
   PRIMARY KEY(id),
   INDEX (id)
 );

DROP TABLE IF EXISTS test;
CREATE TABLE test(
   id INT UNSIGNED NOT NULL,
   first_name VARCHAR(30) NOT NULL,
   last_name  VARCHAR(30) NOT NULL,
   joined     DATE NOT NULL,
   PRIMARY KEY(id),
   INDEX name1 (last_name),
   INDEX name2 (last_name, first_name)
 );

# Column Types
SET @ip='123.100.0.16';
SELECT @ip, INET_ATON(@ip) AS str_to_i, INET_NTOA(INET_ATON(@ip)) as i_to_str;

# MD5
SET @str='somevalue';
SELECT MD5(@str), LENGTH(MD5(@str)) AS len_md5, LENGTH(UNHEX(MD5(@str))) as len_unhex;

# Other SQL Optimizations
SHOW PROFILE SOURCE FOR QUERY 7;

# Removing Repeating SQL Statements
SELECT name FROM firms WHERE id=727;
SELECT name FROM firms WHERE id=758;
SELECT name FROM firms WHERE id=857;
SELECT name FROM firms WHERE id=740;
SELECT name FROM firms WHERE id=849;
SELECT name FROM firms WHERE id=839;
SELECT name FROM firms WHERE id=847;
SELECT name FROM firms WHERE id=867;
SELECT name FROM firms WHERE id=829;
SELECT name FROM firms WHERE id=812;
SELECT name FROM firms WHERE id=868;
SELECT name FROM firms WHERE id=723;
SELECT id, name
FROM firms 
WHERE id IN (723, 727, 740, 758, 812, 829, 839, 847, 849, 857, 867, 868);

SET PROFILING=1;
SELECT ...;
SHOW PROFILES;

SELECT 'Sum Individual Queries' AS txt,SUM(DURATION) AS total_time FROM INFORMATION_SCHEMA.PROFILING WHERE QUERY_ID BETWEEN 1 AND 12 
UNION
SELECT 'Combined Query',SUM(DURATION) FROM INFORMATION_SCHEMA.PROFILING WHERE QUERY_ID = 13;


SELECT a.id, a.firm_id, a.title 
FROM   article a 
WHERE  a.type=2 
AND    a.created > '2011-06-01';
#  For loop for all records 
SELECT id, name 
FROM   firm
WHERE  id = :firm_id;
SELECT a.id, a.firm_id, f.name, a.title 
FROM article a
INNER JOIN firm f ON a.firm_id = f.id
WHERE a.type=2 
AND a.created > '2011-06-01';

# MySQL Caching
SET GLOBAL query_cache_size=1024*1024*16;
SET GLOBAL query_cache_type=1;
SET PROFILING=1;
SELECT name FROM firms WHERE id=727;
SELECT name FROM firms WHERE id=727;
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
SHOW PROFILE FOR QUERY 2;

# Column Improvement
SELECT fid, val, val
FROM table1
WHERE fid = X;

SELECT val
FROM table1
WHERE fid = X;

# Join Improvement
SELECT /* Query 1 */ id FROM table1
WHERE col1 = X
AND   col2 = Y;
SELECT /* Query 2 */ table2.val1, table2.val2, table2.val3
FROM table2  INNER JOIN table1 USING (id)
WHERE table2.id = 9
AND   table1.col1 = X
AND   table1.col2 = Y
AND   table2.col1 = Z;
SELECT /* Query 2 */ val1, val2, val3
FROM table2
WHERE table2.id = 9
AND   table2.col1 = Z;

# Rewritin Subqueries
SELECT id, label
FROM   code_opts 
WHERE  code_id = (SELECT id FROM codes WHERE typ='CATEGORIES') 
ORDER BY seq;
SELECT  o.id, o.label
FROM    code_opts o INNER JOIN codes c ON o.code_id = c.id
WHERE   c.typ='CATEGORIES'
ORDER BY o.seq;

# END
