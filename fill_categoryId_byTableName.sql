DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `fill_categoryId_byTableName`$$

CREATE PROCEDURE `fill_categoryId_byTableName`(IN tableName VARCHAR(50))
	MODIFIES SQL DATA
    BEGIN
	SET @stmt = CONCAT(
		'update ',tableName,' inner join asset_category on asset_category.category_name = ',tableName,'.category
		set ',tableName,'.category_id = asset_category.category_id where ',tableName,'.category_id is null or ',tableName,'.category_id = "";'
	);
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
    END$$

DELIMITER ;