# Effective MySQL: Optimizing SQL Statements by Ronald Bradford
# http://effectivemysql.com/book/optimizing-sql-statements
#

#
# chapter06.sql
#
CREATE SCHEMA IF NOT EXISTS book;
USE book;

# Named Key Buffers
SET GLOBAL hot.key_buffer_size=1024*1024*64;
CACHE INDEX  table1, table2 IN hot;
LOAD INDEX INTO CACHE table1, table2;

# innodb_buffer_pool_size
SHOW GLOBAL STATUS LIKE 'innodb_buffer%';
SHOW ENGINE INNODB STATUS;

# query_cache_size
SET GLOBAL query_cache_type = 1;
SET GLOBAL query_cache_size =  1024 * 1024 * 16;
SET GLOBAL query_cache_type = 0;
SET GLOBAL query_cache_size =  0;
SHOW GLOBAL STATUS LIKE 'Qcache%'

# max_heap_table_size
SET SESSION max_heap_table_size=1024*1024;
CREATE TABLE t1(
i INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
c VARCHAR(1024)) ENGINE=MEMORY;
INSERT INTO t1(i) VALUES
(NULL),(NULL),(NULL),(NULL),(NULL),
(NULL),(NULL),(NULL),(NULL),(NULL);
INSERT INTO t1(i) SELECT NULL FROM t1 AS a, t1 AS b, t1 AS c;

# tmp_table_size
SHOW SESSION STATUS LIKE 'create%tables';
SELECT ...;
SHOW SESSION STATUS LIKE 'create%tables';

# END
