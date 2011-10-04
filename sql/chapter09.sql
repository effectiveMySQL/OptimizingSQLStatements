# Effective MySQL: Optimizing SQL Statements by Ronald Bradford
# http://effectivemysql.com/book/optimizing-sql-statements
#

#
# chapter09.sql
#
CREATE SCHEMA IF NOT EXISTS book;
USE book;

DROP TABLE IF EXISTS customer;

DROP TABLE IF EXISTS parent;
DROP TABLE IF EXISTS child;
CREATE TABLE parent (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY(id)
) ENGINE=InnoDB;

CREATE TABLE child (
  child_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  parent_id INT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY(child_id),
  KEY (parent_id)
) ENGINE=InnoDB;

INSERT INTO parent(id,name) VALUES(NULL,REPEAT(HEX(LAST_INSERT_ID()),10));
INSERT INTO parent(id,name) VALUES(NULL,REPEAT(HEX(LAST_INSERT_ID()),10));
INSERT INTO parent(id,name) VALUES(NULL,REPEAT(HEX(LAST_INSERT_ID()),10));
INSERT INTO parent(id,name) VALUES(NULL,REPEAT(HEX(LAST_INSERT_ID()),10));
INSERT INTO parent(id,name) VALUES(NULL,REPEAT(HEX(LAST_INSERT_ID()),10));
INSERT INTO parent(id,name) SELECT NULL,REPEAT(HEX(id),10) FROM parent;
INSERT INTO parent(id,name) SELECT NULL,REPEAT(HEX(id),10) FROM parent;
INSERT INTO parent(id,name) SELECT NULL,REPEAT(HEX(id),10) FROM parent;
INSERT INTO parent(id,name) SELECT NULL,REPEAT(HEX(id),10) FROM parent;
INSERT INTO parent(id,name) SELECT NULL,REPEAT(HEX(id),10) FROM parent;

INSERT INTO child(child_id,parent_id,name) SELECT NULL,id,name FROM parent WHERE MOD(id,2) = 0 OR MOD(id,3) = 0;


EXPLAIN SELECT p.*
FROM parent p
WHERE p.id NOT IN (SELECT c.parent_id FROM child c)\G

EXPLAIN SELECT p.*
FROM parent p
LEFT JOIN child c ON p.id = c.parent_id
WHERE c.child_id IS NULL\G

EXPLAIN SELECT p.* 
FROM parent p 
WHERE  NOT EXISTS (SELECT parent_id FROM child c WHERE c.parent_id = p.id)\G



ALTER TABLE parent ADD parent_id INT UNSIGNED NULL;
UPDATE parent SET parent_id=id;

SELECT p.*
FROM   parent p,
       child c 
WHERE  p.parent_id = c.parent_id
AND    c.child_id < 10;

# END
