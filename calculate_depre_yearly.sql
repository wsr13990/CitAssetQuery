DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `calculate_depre_by_year_tableName`$$

CREATE PROCEDURE `calculate_depre_by_year_tableName`(IN parameter_year INTEGER(4), IN tableName VARCHAR(50))
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
	
	IF parameter_year < 2001 THEN
		SET @sqlstmt = CONCAT('update ', tableName,' set d_', parameter_year,'= cost * get_dpis_rate(category_id, ', parameter_year, '), n_', parameter_year,'= cost - d_', parameter_year,' where dpis_year = ', parameter_year);
		PREPARE stmt FROM @sqlstmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SET @sqlstmt = CONCAT('update ', tableName,' set d_', parameter_year,'= cost * get_dpis_rate(category_id, ', parameter_year, ') * ((13-dpis_month)/12), n_', parameter_year,'= cost - d_', parameter_year,' where dpis_year = ', parameter_year);
		PREPARE stmt FROM @sqlstmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END IF;
	
#Calculate yearly depreciation      
	IF parameter_year > 1996 THEN
		SET @sqlstmt = CONCAT('update ', tableName,' set d_', parameter_year,'= if(dpis_year_end=', parameter_year, ', n_', parameter_year-1,', n_', parameter_year-1,' * get_dpis_rate(category_id, ', parameter_year, ')), n_', parameter_year,'= n_', parameter_year-1,' - d_', parameter_year,' where dpis_year_end>=', parameter_year,' and dpis_year <', parameter_year, ' and (category_id not in (''BLD TS'',''Building'') or (category_id in (''CME NW SHL'',''infraCME_bangunan'',''infraCME_bangunan_2'') and ', parameter_year,'<2004))');       
		PREPARE stmt FROM @sqlstmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		SET @sqlstmt = CONCAT('update ', tableName,' set d_', parameter_year,'= if(dpis_year_end=', parameter_year, ', n_', parameter_year-1,', cost * get_dpis_rate(category_id, ', parameter_year, ')), n_', parameter_year,'= n_', parameter_year-1,' - d_', parameter_year,' where dpis_year_end>=', parameter_year,' and  dpis_year <', parameter_year,' and category_id in (''BLD TS'',''Building'')');
		PREPARE stmt FROM @sqlstmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	IF parameter_year > 2003 THEN
		SET @sqlstmt = CONCAT('update ', tableName,' set d_', parameter_year,'= if(dpis_year_end=', parameter_year, ', n_', parameter_year-1,', cost * get_dpis_rate(category_id, ', parameter_year, ')), n_', parameter_year,'= n_', parameter_year-1,' - d_', parameter_year,' where dpis_year_end>=', parameter_year,' and dpis_year < ', parameter_year,' and dpis_year >= 2004 and category_id in (''CME NW SHL'',''infraCME_bangunan'',''infraCME_bangunan_2'')');
		PREPARE stmt FROM @sqlstmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	  
		SET @sqlstmt = CONCAT('update ', tableName,' set d_', parameter_year,'= if(dpis_year_end=', parameter_year, ', n_', parameter_year-1,',  n_2003 * get_dpis_rate(category_id, ', parameter_year, ')), n_', parameter_year,'= n_', parameter_year-1,' - d_', parameter_year,' where dpis_year_end>=', parameter_year,' and dpis_year < ', parameter_year,' and dpis_year < 2004 and category_id in (''CME NW SHL'',''infraCME_bangunan'',''infraCME_bangunan_2'')');
		PREPARE stmt FROM @sqlstmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END IF;
	ELSE
	
		SET @sqlstmt = CONCAT('update ', tableName,' set d_', parameter_year,'= cost * get_dpis_rate(category_id, ', parameter_year, '), n_', parameter_year,'= cost - d_', parameter_year,' where dpis_year < ', parameter_year);
		PREPARE stmt FROM @sqlstmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END IF;
	
	SET @akum = CONCAT_WS('+', @akum, CONCAT(' ', tableName,'.d_',parameter_year,' '));
	IF parameter_year = (parameter_year - 1) THEN
		SET @akum = CONCAT('update ', tableName,' set akum_upto_prev_Year = (', @akum,');');
		PREPARE akum FROM @akum;
		EXECUTE akum;
		DEALLOCATE PREPARE akum;
	END IF;	
END; $$

DELIMITER ;