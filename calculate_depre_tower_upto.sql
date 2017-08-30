DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `calculate_depre_tower_upto`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `calculate_depre_tower_upto`(IN paramYear INTEGER(4), IN fileName VARCHAR(50))
    MODIFIES SQL DATA
BEGIN
	SET @stmt = CONCAT('update ',filename,' set category_id = "CME NW";');
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	CALL `calculate_depre_from_1996_to_parameterYear`(2010, fileName);
	
	SET @stmt = CONCAT('update ',filename,' set category_id = "BLD TS";');
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	CALL `calculate_depreTower_from2011_to`(paramYear,fileName);
    END$$

DELIMITER ;