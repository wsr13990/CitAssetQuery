DELIMITER $$


USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `recalculate_akum_upto`$$

CREATE PROCEDURE `recalculate_akum_upto`(IN paramYear INT(4), IN tableName VARCHAR(50))
	MODIFIES SQL DATA
BEGIN
	SET @count = 	(SELECT COUNT(*) FROM `information_schema`.`COLUMNS`
			WHERE 	`TABLE_SCHEMA` = 'cit_asset' AND
			`TABLE_NAME` = tableName AND
			`COLUMN_NAME` = "akum_upto_prev_Year");
	IF @count = 0 THEN
		SET @addColumn = CONCAT('alter table ', tableName,' add column akum_upto_prev_Year decimal(20,2) default 0');
		PREPARE addColumn FROM @addColumn;
		EXECUTE addColumn;
		DEALLOCATE PREPARE addColumn;
	END IF;
	
	SET @akum = NULL;
	SET @period = 1996;
	WHILE @period <= paramYear DO
		SET @akum = CONCAT_WS(' + ', @akum, CONCAT('d_', @period));
		SET @period = @period + 1;
	END WHILE;
	SET @stmt  = CONCAT('update ',tableName,' set `akum_upto_prev_Year` = (',@akum,')');
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;