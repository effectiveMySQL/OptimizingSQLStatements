# Effective MySQL: Optimizing SQL Statements by Ronald Bradford
# http://effectivemysql.com/book/optimizing-sql-statements
#

#
# chapter01.sql
#
CREATE SCHEMA IF NOT EXISTS book;
USE book;

#
# Pre-requisite table for queries
#
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
id INT UNSIGNED NOT NULL AUTO_INCREMENT,
supp_id INT UNSIGNED NOT NULL,
item_id INT UNSIGNED NOT NULL,
qty INT SIGNED NOT NULL,       
created  DATETIME  NOT NULL,
PRIMARY KEY  (id),
UNIQUE KEY (supp_id, item_id),
KEY created (created)
) ENGINE=InnoDB;

#
# Finding a Slow SQL Statement
#
SHOW FULL PROCESSLIST\G

#
# run and Time Your SQL Statement
#
SELECT * FROM inventory WHERE item_id = 16102176;

# Generate a Query Execution Plan (QEP)
EXPLAIN SELECT * FROM inventory WHERE item_id = 16102176\G

#
# What You Should Not do
ALTER TABLE inventory ADD INDEX (item_id);

#
# Confirm Your Optimization
#
SELECT * FROM inventory WHERE item_id = 16102176;
EXPLAIN SELECT * FROM inventory WHERE item_id = 16102176;

#
# The Correct Approach
#
SHOW CREATE TABLE inventory\G
SHOW TABLE STATUS LIKE 'inventory'\G

# END
