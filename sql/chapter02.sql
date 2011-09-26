# Effective MySQL: Optimizing SQL Statements by Ronald Bradford
# http://effectivemysql.com/book/optimizing-sql-statements
#

#
# chapter02.sql
#
CREATE SCHEMA IF NOT EXISTS book;
USE book;

#
# EXPLAIN
#
EXPLAIN SELECT host,user,password FROM mysql.user WHERE user like 'r%'\G
EXPLAIN SELECT host,user,password FROM mysql.user WHERE host='localhost' AND user like 'r%'\G

#
# EXPLAIN PARTITIONS
#
DROP TABLE IF EXISTS audit_log;
CREATE TABLE audit_log (
  yr    YEAR NOT NULL,
  msg   VARCHAR(100) NOT NULL)
ENGINE=InnoDB
PARTITION BY RANGE (yr) (
  PARTITION p0 VALUES LESS THAN (2010),
  PARTITION p1 VALUES LESS THAN (2011),
  PARTITION p2 VALUES LESS THAN (2012),
  PARTITION p3 VALUES LESS THAN MAXVALUE);
INSERT INTO audit_log(yr,msg) VALUES (2005,'2005'),(2006,'2006'),(2011,'2011'),(2020,'2020');
EXPLAIN PARTITIONS SELECT * from audit_log WHERE yr in (2011,2012)\G

# 
# EXPLAIN EXTENDED
#
DROP TABLE IF EXISTS test1;
DROP TABLE IF EXISTS test2;
CREATE TABLE test1(
  uid  VARCHAR(32) NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY(uid)
) ENGINE=InnoDB DEFAULT CHARSET latin1;
CREATE TABLE test2(
  uid  VARCHAR(32) NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY(uid)
) ENGINE=InnoDB DEFAULT CHARSET utf8;
EXPLAIN EXTENDED select t1.name from test1 t1 INNER JOIN test2 t2 USING(uid)\G
SHOW WARNINGS\G


# 
# SHOW CREATE TABLE
#
DROP TABLE IF EXISTS wp_options;
CREATE TABLE `wp_options` (
  `option_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `blog_id` int(11) NOT NULL DEFAULT '0',
  `option_name` varchar(64) NOT NULL DEFAULT '',
  `option_value` longtext NOT NULL,
  `autoload` varchar(20) NOT NULL DEFAULT 'yes',
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `option_name` (`option_name`)
) ENGINE=MyISAM AUTO_INCREMENT=4138 DEFAULT CHARSET=utf8;
SHOW CREATE TABLE wp_options\G

# 
# SHOW INDEXES
#
DROP TABLE IF EXISTS wp_posts;
CREATE TABLE `wp_posts` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `post_author` bigint(20) unsigned NOT NULL DEFAULT '0',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content` longtext NOT NULL,
  `post_title` text NOT NULL,
  `post_excerpt` text NOT NULL,
  `post_status` varchar(20) NOT NULL DEFAULT 'publish',
  `comment_status` varchar(20) NOT NULL DEFAULT 'open',
  `ping_status` varchar(20) NOT NULL DEFAULT 'open',
  `post_password` varchar(20) NOT NULL DEFAULT '',
  `post_name` varchar(200) NOT NULL DEFAULT '',
  `to_ping` text NOT NULL,
  `pinged` text NOT NULL,
  `post_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_modified_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content_filtered` text NOT NULL,
  `post_parent` bigint(20) unsigned NOT NULL DEFAULT '0',
  `guid` varchar(255) NOT NULL DEFAULT '',
  `menu_order` int(11) NOT NULL DEFAULT '0',
  `post_type` varchar(20) NOT NULL DEFAULT 'post',
  `post_mime_type` varchar(100) NOT NULL DEFAULT '',
  `comment_count` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `post_name` (`post_name`),
  KEY `type_status_date` (`post_type`,`post_status`,`post_date`,`ID`),
  KEY `post_parent` (`post_parent`),
  KEY `post_author` (`post_author`)
) ENGINE=MyISAM AUTO_INCREMENT=3761 DEFAULT CHARSET=utf8;
SHOW INDEXES FROM wp_posts;
SHOW INDEXES FROM wp_posts\G

#
# SHOW TABLE STATUS
#
SHOW TABLE STATUS LIKE 'wp_posts'\G
ALTER TABLE wp_posts ENGINE=InnoDB;
SELECT COUNT(*) FROM wp_posts;
SHOW TABLE STATUS LIKE 'wp_posts'\G
SHOW TABLE STATUS LIKE 'wp_posts'\G
SHOW TABLE STATUS LIKE 'wp_posts'\G
SELECT COUNT(*) FROM wp_posts;
SET @schema = IFNULL(@schema,DATABASE());
SET @table='inventory';
SELECT @schema as table_schema, CURDATE() AS today;
SELECT   table_name,
         engine,row_format as format, table_rows, avg_row_length as avg_row,
         round((data_length+index_length)/1024/1024,2) as total_mb,
         round((data_length)/1024/1024,2) as data_mb,
         round((index_length)/1024/1024,2) as index_mb
FROM     information_schema.tables
WHERE    table_schema=@schema
AND      table_name = @table
\G

#
# SHOW STATUS
#
SHOW GLOBAL STATUS LIKE 'Created_tmp_%tables';
SHOW SESSION STATUS LIKE 'Created_tmp_%tables';
FLUSH STATUS;
SELECT * FROM mysql.user;
SHOW SESSION STATUS LIKE 'handler_read%';

#
# SHOW VARIABLES
#
SHOW SESSION VARIABLES LIKE 'tmp_table_size';
SELECT 'SESSION' AS scope,variable_name,variable_value
FROM INFORMATION_SCHEMA.SESSION_VARIABLES
WHERE variable_name IN ('tmp_table_size','max_heap_table_size')
UNION 
SELECT 'GLOBAL',variable_name,variable_value 
FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES 
WHERE variable_name IN ('tmp_table_size','max_heap_table_size');

# END
