DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `calculate_depre_from_1996_to_parameterYear`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `calculate_depre_from_1996_to_parameterYear`(IN parameter_year INTEGER(4), IN tableName VARCHAR(50))
    MODIFIES SQL DATA
BEGIN
	SET @period = 1996;
	WHILE @period <= parameter_year DO
		CALL `calculate_depre_by_year_tableName`(@period, tableName);
		SET @period = @period + 1;
	END WHILE;
END$$

DELIMITER ;