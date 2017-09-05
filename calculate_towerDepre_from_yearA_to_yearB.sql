DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `calculate_towerDepre_from_yearA_to_yearB`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `calculate_towerDepre_from_yearA_to_yearB`(IN beginYear INTEGER(4),IN endYear INTEGER(4), IN tableName VARCHAR(50))
    MODIFIES SQL DATA
BEGIN
	SET @period = beginYear;
	WHILE @period <= endYear DO
		CALL `calculate_depreTower_year`(@period, tableName);
		SET @period = @period + 1;
	END WHILE;
END$$

DELIMITER ;