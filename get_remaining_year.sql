DELIMITER $$

USE `cit_asset`$$

DROP FUNCTION IF EXISTS `get_remaining_year`$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_remaining_year`(month_end INTEGER, year_end INTEGER, current_year INTEGER) RETURNS DECIMAL(15,4)
    READS SQL DATA
BEGIN
	DECLARE remaining_year DECIMAL(15,4);
	IF year_end < current_year THEN SET remaining_year = 0;
	ELSEIF year_end = current_year THEN SET remaining_year = 1;
	ELSE SET remaining_year = year_end - current_year + (month_end/12);
	END IF;
	RETURN remaining_year;
END$$