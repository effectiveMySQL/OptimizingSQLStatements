# Effective MySQL: Optimizing SQL Statements by Ronald Bradford
# http://effectivemysql.com/book/optimizing-sql-statements
#

#
# chapter03.sql
#
CREATE SCHEMA IF NOT EXISTS book;
USE book;

#
# Example Tables
#
DROP TABLE IF EXISTS source_words;
CREATE TABLE source_words (
  word VARCHAR(50) NOT NULL,
  INDEX (word)
) ENGINE=MyISAM;
LOAD DATA LOCAL INFILE '/usr/share/dict/words' 
INTO TABLE source_words(word);

CREATE TABLE million_words(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  word VARCHAR(50) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE INDEX (word)
) ENGINE=InnoDB;

INSERT INTO million_words(word) 
SELECT DISTINCT word FROM source_words;
INSERT INTO million_words(word) 
SELECT DISTINCT REVERSE(word) FROM source_words 
WHERE REVERSE(word) NOT IN (select word from source_words);
SELECT @cnt := COUNT(*) FROM million_words;
SELECT @diff := 1000000 - @cnt;
-- We need to run dynamic SQL to support a variable LIMIT
SET @sql = CONCAT("
INSERT INTO million_words(word) 
SELECT DISTINCT CONCAT(word,'X1Y') FROM source_words LIMIT ",@diff);
PREPARE cmd FROM @sql;
EXECUTE cmd;
SELECT COUNT(*) FROM million_words;

#
# Data Integrity
#
INSERT INTO million_words(id,word) VALUES(1,'xxxxxxxxx');
INSERT INTO million_words(word) VALUES('oracle');

#
# Optimizing Data Access
#
CREATE TABLE no_index_words LIKE million_words;
ALTER TABLE no_index_words DROP INDEX word;
INSERT INTO no_index_words SELECT * FROM million_words;
SELECT * FROM no_index_words WHERE word='oracle';
SELECT * FROM million_words WHERE word='oracle';

#
# MyISAM B-Tree
#
CREATE TABLE colors (
  name   VARCHAR(20) NOT NULL,
  items  VARCHAR(255) NOT NULL
) ENGINE=MyISAM;

INSERT INTO colors(name, items) VALUES
('RED','Apples,Sun,Blood,...'),
('ORANGE','Oranges,Sand,...'),
('YELLOW','...'),
('GREEN','Kermit,Grass,Leaves,Plants,Emeralds,Frogs,Seaweed,Spinach,Money,Jade,Go Traffic Light'),
('BLUE','Sky,Water,Blueberries,Earth'),
('INDIGIO','...'),
('VIOLET','...'),
('WHITE','...'),
('BLACK','Night,Coal,Blackboard,Licorice,Piano Keys,...');

ALTER TABLE colors ADD INDEX (name);

#
# InnoDB B+tree Clustered Primary Key
#
SET @table='million_words'; 
SOURCE tablesize.sql 


CREATE TABLE million_words2 ( 
 id INT UNSIGNED NOT NULL,  
 word VARCHAR(50) NOT NULL,  
 PRIMARY KEY (word),  
 UNIQUE KEY(id))  
ENGINE=InnoDB; 
SELECT word,id FROM million_words ORDER BY id  
INTO OUTFILE '/tmp/million_words.tsv'; 
LOAD DATA LOCAL INFILE '/tmp/million_words.tsv'  
INTO TABLE million_words2(word,id); 
SET @table='million_words2'; 
SOURCE tablesize.sql 

DROP TABLE IF EXISTS colors_wide;
CREATE TABLE colors_wide (
  name   VARCHAR(20) NOT NULL,
  items  VARCHAR(255) NOT NULL,
  filler1 VARCHAR(500) NULL,
  PRIMARY KEY (name)
) ENGINE=InnoDB;

INSERT INTO colors_wide(name, items) VALUES
('RED','Apples,Sun,Blood,...'),
('ORANGE','Oranges,Sand,...'),
('YELLOW','...'),
('GREEN','Kermit,Grass,Leaves,Plants,Emeralds,Frogs,Seaweed,Spinach,Money,Jade,Go Traffic Light'),
('BLUE','Sky,Water,Blueberries,Earth'),
('INDIGIO','...'),
('VIOLET','...'),
('WHITE','...'),
('BLACK','Night,Coal,Blackboard,Licorice,Piano Keys,...');

UPDATE colors_wide SET filler1=REPEAT('x',500), filler2=filler1, filler3=filler1,filler4=filler1,filler5=filler1;

#
# Memory Hash Index
#
CREATE TABLE memory_words(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  word VARCHAR(50) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY (word)
) ENGINE=MEMORY;

SET SESSION max_heap_table_size = 1024 *1024 * 100;
INSERT INTO memory_words(id,word) SELECT id,word from million_words;
SELECT COUNT(*) FROM memory_words;
SET PROFILING=1;
SELECT SQL_NO_CACHE * FROM memory_words WHERE word = 'apple';
SELECT SQL_NO_CACHE * FROM memory_words WHERE word = 'orange';
SELECT SQL_NO_CACHE * FROM memory_words WHERE word = 'lemon';
SELECT SQL_NO_CACHE * FROM memory_words WHERE word = 'wordnotfound';
SELECT SQL_NO_CACHE * FROM memory_words WHERE word LIKE 'apple%';
SHOW PROFILES;
SET @table='memory_words'; 
SOURCE tablesize.sql 

#
# MEMORY B-tree Index
#
SET SESSION max_heap_table_size = 1024 *1024 * 150;
ALTER TABLE memory_words DROP INDEX word,ADD INDEX USING BTREE (word);
SET SESSION profiling_history_size=0;
SET PROFILING=0;
SET PROFILING=1;
SET SESSION profiling_history_size=10;
SELECT SQL_NO_CACHE * FROM memory_words WHERE word = 'apple';
SELECT SQL_NO_CACHE * FROM memory_words WHERE word = 'orange';
SELECT SQL_NO_CACHE * FROM memory_words WHERE word = 'lemon';
SELECT SQL_NO_CACHE * FROM memory_words WHERE word = 'wordnotfound';
SELECT SQL_NO_CACHE * FROM memory_words WHERE word LIKE 'apple%';
SET @table='memory_words'; 
SOURCE tablesize.sql 

# END
