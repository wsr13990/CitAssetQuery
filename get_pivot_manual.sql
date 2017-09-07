DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `get_pivot_manual`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_pivot_manual`(paramMonth INTEGER(2), paramYear INTEGER(4), IN tableName VARCHAR(25))
    READS SQL DATA
BEGIN
	SET @pivot = 	CONCAT('CREATE TABLE ',tableName,' AS 
				SELECT `category_id`, SUM(cost) AS cost, SUM(`akum_upto_prev_Year`) AS `akum_upto_prev_Year`, SUM(`dm',paramMonth,'_',paramYear,'`) AS `dm',paramMonth,'_',paramYear,'`
				from manual GROUP BY `category_id`;');
	PREPARE pivot FROM @pivot;
	EXECUTE pivot;
	DEALLOCATE PREPARE pivot;
	
	
END$$

DELIMITER ;