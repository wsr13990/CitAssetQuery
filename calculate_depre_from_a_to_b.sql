#Created to accomodate tower depre calculation which undergo change in depreciation method
DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `calculate_straightLine_depre_from_a_to_b`$$

CREATE PROCEDURE `calculate_straightLine_depre_from_a_to_b`(IN changeYear INTEGER(4),IN endYear INTEGER(4), IN tableName VARCHAR(50))
    MODIFIES SQL DATA
BEGIN
	SET @period = beginYear;
	WHILE @period <= endYear DO
		CALL `calculate_depre_by_year_tableName`(@period, tableName);
		SET @period = @period + 1;
	END WHILE;
END$$

DELIMITER ;