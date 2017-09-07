DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `get_pivot_intangible_asset`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_pivot_intangible_asset`(paramMonth INTEGER(2), paramYear INTEGER(4), IN tableName VARCHAR(25))
    READS SQL DATA
BEGIN
	SET @pivot = 	CONCAT('CREATE TABLE ',tableName,' AS 
				SELECT `source`, SUM(cost) AS cost, SUM(`akum_upto_prev_Year`) AS `akum_upto_prev_Year`, SUM(`dm',paramMonth,'_',paramYear,'`) AS `dm',paramMonth,'_',paramYear,'`
				from intangible_asset GROUP BY `source`;');
	PREPARE pivot FROM @pivot;
	EXECUTE pivot;
	DEALLOCATE PREPARE pivot;
	
	
END$$

DELIMITER ;