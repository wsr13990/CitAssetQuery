DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `get_pivot_by_month_year_source_detail_table`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_pivot_by_month_year_source_detail_table`(paramMonth INTEGER(2), paramYear INTEGER(4), paramSource VARCHAR(25), IN tableName VARCHAR(25))
    READS SQL DATA
BEGIN
	SET @wo_date = LAST_DAY(CONCAT(CAST(paramYear AS CHAR(4)),"-", CAST(paramMonth AS CHAR(2)),"-", "1"));
	#TODO: change source_detail to source when tower is already imported and calculated
	SET @pivot = 	CONCAT('create table ',tableName,' as
				SELECT	source, SUM(cost) as cost,
					SUM(akum_upto_prev_Year) as akum_upto_prev_Year,
					SUM(dm', paramMonth,'_',paramYear,') as dm', paramMonth,'_',paramYear,'
				FROM far_depre  WHERE `source_detail` = "',paramSource,'" AND 
					(write_off_date IS NULL OR write_off_date > "',@wo_date,'") GROUP BY source;');
	PREPARE pivot FROM @pivot;
	EXECUTE pivot;
	DEALLOCATE PREPARE pivot;
END$$

DELIMITER ;