SET @schema = IFNULL(@schema,DATABASE()); 
SELECT @schema as table_schema, CURDATE() AS today; 
SELECT  table_name, 
        engine,row_format AS format, table_rows, 
        avg_row_length AS avg_row, 
        round((data_length+index_length)/1024/1024,2) AS total_mb, 
        round((data_length)/1024/1024,2) AS data_mb, 
        round((index_length)/1024/1024,2) AS index_mb 
FROM    INFORMATION_SCHEMA.tables 
WHERE   table_schema=@schema 
AND     table_name = @table 
\G 
