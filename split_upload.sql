DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `split_upload`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `split_upload`(IN filename VARCHAR(255), IN countrow INT(6))
    MODIFIES SQL DATA
BEGIN
	SET @stmt = CONCAT("set @row = (select count(*) from history.",filename,")");
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	SET @split = CEIL(@row/countrow);
	SET @i = 0;
	SET @stmt = CONCAT("
	set @col = (SELECT REPLACE(GROUP_CONCAT('`',COLUMN_NAME,'`'),'`id`,','')
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = '",filename,"'
	ORDER BY ORDINAL_POSITION);
	");
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	DROP TABLE IF EXISTS header;
	
	SET @header = (SELECT REPLACE(GROUP_CONCAT("'",COLUMN_NAME,"'"),"'id',","")
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = filename
	ORDER BY ORDINAL_POSITION);
	WHILE @i < @split DO
		SET @timestamp = UNIX_TIMESTAMP();
		SET @limit = @i*countrow;
		
		DROP TABLE IF EXISTS content;
		SET @stmt = CONCAT("
		create temporary table content as
		select ",@col," from history.",filename," limit ",@limit,",",countrow,";
		");
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		SET @stmt = CONCAT("
		select * into outfile 'D:/Kerja/CitAsset/Upload/",filename,"_",@i,"_",@timestamp,".csv'
		FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
		from
		(SELECT ",@header,"
		union all
		select * from content)temp;
		");
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		SET @i = @i+1;
	END WHILE;
	
END$$
DELIMITER ;