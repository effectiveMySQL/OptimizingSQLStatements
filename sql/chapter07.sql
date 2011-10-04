# Effective MySQL: Optimizing SQL Statements by Ronald Bradford
# http://effectivemysql.com/book/optimizing-sql-statements
#

#
# chapter07.sql
#
CREATE SCHEMA IF NOT EXISTS book;
USE book;

SET PROFILING=1;
SELECT NOW();
SELECT BENCHMARK(1+1,100000);
SELECT BENCHMARK('1'+'1',100000);
SELECT SLEEP(1);
SELECT SLEEP(2);
SHOW PROFILES;

# END
