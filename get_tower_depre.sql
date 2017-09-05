DELIMITER $$

USE `cit_asset`$$

DROP FUNCTION IF EXISTS `get_tower_depre`$$

CREATE FUNCTION `get_tower_depre`(month_end INTEGER, year_end INTEGER, current_year INTEGER, nbv DECIMAL(20,2))
	RETURNS DECIMAL(20,2)
	READS SQL DATA
BEGIN
	DECLARE tower_depre DECIMAL(20,2);
	IF year_end < current_year THEN SET tower_depre = 0;
	ELSEIF year_end = current_year THEN SET tower_depre = nbv;
	ELSE SET tower_depre = nbv / (year_end - current_year + (month_end/12));
	END IF;
	RETURN tower_depre;
END$$

DELIMITER ;