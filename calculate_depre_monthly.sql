DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `calculate_depre_by_month_year_tableName`$$

CREATE PROCEDURE `calculate_depre_by_month_year_tableName`(monthperiod INTEGER(2),IN period INTEGER(4), IN depreTable VARCHAR(25))
    MODIFIES SQL DATA
BEGIN
#Check if column exist, if not add new monthly depreciation column and monthly nbv column
	SET @count = 	(SELECT COUNT(*) FROM `information_schema`.`COLUMNS`
			WHERE 	`TABLE_SCHEMA` = 'cit_asset' AND
			`TABLE_NAME` = depreTable AND
			(`COLUMN_NAME` = CONCAT('dm',monthperiod,'_',period) OR `COLUMN_NAME` = CONCAT('nm',monthperiod,'_',period)));
	IF @count = 0 THEN
		SET @addColumn = CONCAT('alter table ', depreTable,' add column dm',monthperiod,'_', period, ' decimal(20,2) default 0, add column nm',monthperiod,'_', period, ' decimal(20,2) default 0');
		PREPARE addColumn FROM @addColumn;
		EXECUTE addColumn;
		DEALLOCATE PREPARE addColumn;
	END IF;
	
#calculate monthly depreciation	
	SET @sqlstmt = CONCAT('update ', depreTable,' set dm',monthperiod, '_', period,'= d_',period,'/(13-dpis_month) * if(dpis_month>',monthperiod,',0,',monthperiod+1,'-dpis_month), nm',monthperiod,'_', period,'= cost - dm',monthperiod,'_', period, 
			    ' where dpis_year = ', period);
	PREPARE stmt FROM @sqlstmt;
	EXECUTE stmt;

	SET @sqlstmt = CONCAT('update ', depreTable,' set dm',monthperiod,'_', period,'= ',monthperiod,'/12 * d_',period,', nm',monthperiod,'_', period,'= n_',period-1,' - dm',monthperiod,'_', period,
			    ' where dpis_year < ', period,' and dpis_year_end>', period);
	PREPARE stmt FROM @sqlstmt;
	EXECUTE stmt;

	SET @sqlstmt = CONCAT('update ', depreTable,' set dm',monthperiod,'_', period,'= (d_',period,'/dpis_month_end) * if(dpis_month_end>',monthperiod,',',monthperiod,',dpis_month_end), nm',monthperiod,'_', period,'= n_',period-1,' - dm',monthperiod,'_', period,
			    ' where dpis_year_end = ', period);
	PREPARE stmt FROM @sqlstmt;
	EXECUTE stmt;
END$$

DELIMITER ;