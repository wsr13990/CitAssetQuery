DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `insert_table_from_to`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_table_from_to`(IN tableSource VARCHAR(25), IN tableDest VARCHAR(25))
    MODIFIES SQL DATA
BEGIN
	SET @stmt = CONCAT("set @column = (select group_concat(column_name separator ', ') from information_schema.COLUMNS where `TABLE_SCHEMA` = 'cit_asset' AND column_name != 'asset_id' and `TABLE_NAME` = '",tableSource,"');");
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	SET @stmt = CONCAT("insert into ",tableDest,"(",@column,") select ",@column," from  ",tableSource,";");
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;