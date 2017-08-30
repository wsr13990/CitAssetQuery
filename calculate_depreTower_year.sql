DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `calculate_depreTower_year`$$

CREATE PROCEDURE `calculate_depreTower_year`(IN parameter_year INTEGER(4), IN tableName VARCHAR(50))
    MODIFIES SQL DATA
BEGIN
#check if column exists, if not add new yearly depreciation and NBV
	SET @count = 	(SELECT COUNT(*) FROM `information_schema`.`COLUMNS`
			WHERE 	`TABLE_SCHEMA` = 'cit_asset' AND
			`TABLE_NAME` = tableName AND
			(`COLUMN_NAME` = CONCAT('d_',parameter_year) OR `COLUMN_NAME` = CONCAT('n_',parameter_year)));
	IF @count = 0 THEN
		SET @addColumn = CONCAT('alter table ', tableName,' add column d_', parameter_year, ' decimal(20,2) default 0, add column n_', parameter_year, ' decimal(20,2) default 0');
		PREPARE addColumn FROM @addColumn;
		EXECUTE addColumn;
		DEALLOCATE PREPARE addColumn;
	END IF;
	
	SET @sqlstmt = CONCAT('update ', tableName,' set d_', parameter_year,'= if(dpis_year = 2011 and dpis_month = 1, get_tower_depre(tower_year_as_building, ',parameter_year,', cost), get_tower_depre(tower_year_as_building,',parameter_year,',n_2010)), n_', parameter_year,'= if(dpis_year = 2011 and parameter_year = 2011, cost - d_',parameter_year,', n_',parameter_year-1,' - d_', parameter_year,') where (dpis_year <= 2011) or (dpis_year = 2011 and dpis_month = 1);');
	PREPARE stmt FROM @sqlstmt;
	EXECUTE stmt;
		
	SET @akum = CONCAT_WS('+', @akum, CONCAT(' ', tableName,'.d_',parameter_year,' '));
		IF parameter_year = (parameter_year - 1) THEN
			SET @akum = CONCAT('update ', tableName,' set akum_upto_prev_Year = (', @akum,');');
			PREPARE akum FROM @akum;
			EXECUTE akum;
			DEALLOCATE PREPARE akum;
		END IF;
END; $$

DELIMITER ;