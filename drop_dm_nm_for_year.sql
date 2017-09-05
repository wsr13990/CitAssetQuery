DELIMITER $$

USE `cit_asset`$$
DROP PROCEDURE IF EXISTS `drop_dm_nm_for_year`$$

CREATE PROCEDURE `drop_dm_nm_for_year`(IN `year` INT(4), IN tableName VARCHAR(50))
	MODIFIES SQL DATA
	BEGIN
		SET @m = 1;
		SET @drop_stmt = NULL;
		WHILE @m <= 12 DO
			SET @drop_stmt = CONCAT_WS(",",@drop_stmt, CONCAT('drop dm',@m,'_',`year`,', drop nm',@m,'_',`year`));
			SET @m = @m + 1;
		END WHILE;
		SET @stmt = CONCAT('alter table ',tableName ,' ',@drop_stmt);
		SELECT @stmt;
		
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END$$

DELIMITER ;