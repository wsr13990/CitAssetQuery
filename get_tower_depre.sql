DELIMITER $$

USE `cit_asset`$$

DROP FUNCTION IF EXISTS `get_tower_depre`$$

CREATE FUNCTION `get_tower_depre`(remaining_age INTEGER, period INTEGER, remaining_cost DECIMAL(15,4))
	RETURNS DECIMAL(15,4)
	READS SQL DATA
BEGIN
	DECLARE tower_depre DECIMAL(15,4);
	SET tower_depre = 0;
	IF (period - 2010) > remaining_age THEN
		SET tower_depre = 0;
	ELSE
		SET tower_depre = remaining_cost / remaining_age;
	END IF;
	RETURN tower_depre;
END$$

DELIMITER ;