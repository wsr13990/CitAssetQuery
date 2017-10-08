DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `fill_categoryId_byTableName`$$

CREATE PROCEDURE `fill_categoryId_byTableName`(IN tableName VARCHAR(50))
	MODIFIES SQL DATA
    BEGIN
    	DROP TABLE IF EXISTS control;
    	
	#check whether category_id exist, if not add column
	SET @count = 	(SELECT COUNT(*) FROM `information_schema`.`COLUMNS`
			WHERE 	`TABLE_SCHEMA` = 'cit_asset' AND
				`TABLE_NAME` = tableName AND
				(`COLUMN_NAME` = 'category_id'));
	IF @count = 0 THEN
		SET @addColumn = CONCAT('alter table ', tableName,' add column category_id varchar(25) default null');
		PREPARE addColumn FROM @addColumn;
		EXECUTE addColumn;
		DEALLOCATE PREPARE addColumn;
	END IF;
	
	SET @stmt = CONCAT(
		'update ',tableName,' inner join asset_category on asset_category.category_name = ',tableName,'.category
		set ',tableName,'.category_id = asset_category.category_id where ',tableName,'.category_id is null or ',tableName,'.category_id = "";'
	);
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	#Check if all category_id successfully filled
	CREATE TEMPORARY TABLE control(`status` VARCHAR(100));
	SET @stmt = CONCAT('set @control = (select count(asset_id) from ',tableName,' where category_id is null or category_id = "");');
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	IF @control = 0 THEN
		INSERT INTO control VALUES("OK : All category_id filled");
	ELSE
		INSERT INTO control VALUES("WARNING : Several category_id is missing");
	END IF;
	SELECT * FROM control;
	
    END$$

DELIMITER ;