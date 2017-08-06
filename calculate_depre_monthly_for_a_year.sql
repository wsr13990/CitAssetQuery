DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `calculate_depre_monthly_for_a_year`$$
CREATE PROCEDURE `calculate_depre_monthly_for_a_year`(IN yearParameter INT(4), IN depreTable VARCHAR(25))
	MODIFIES SQL DATA
BEGIN
	SET @month = 1;
	WHILE @month <= 12 DO
		CALL `calculate_depre_by_month_year_tableName`(@month, yearParameter, depreTable);
		SET @month = @month + 1;
	END WHILE;
END$$

DELIMITER ;