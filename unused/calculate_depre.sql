DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `calculate_depre`$$

CREATE PROCEDURE `calculate_depre`(IN parameter_year INTEGER)
    READS SQL DATA
BEGIN
	DROP TABLE IF EXISTS far_depre;
	SET @createTable = 'CREATE TABLE far_depre AS SELECT * FROM far;';
	PREPARE createTable FROM @createTable;
	EXECUTE createTable;
	DEALLOCATE PREPARE createTable;
	
	SET @akum = NULL;
	SET @period = 1996;
	ALTER TABLE far_depre ADD COLUMN akum_upto_prev_Year DECIMAL(20,2) DEFAULT 0;
	WHILE @period <= parameter_year DO
		SET @addColumn = CONCAT('alter table far_depre add column d_', @period, ' decimal(20,2) default 0, add column n_', @period, ' decimal(20,2) default 0');
		PREPARE addColumn FROM @addColumn;
		EXECUTE addColumn;
		DEALLOCATE PREPARE addColumn;
	      
		IF @period < 2001 THEN
			SET @sqlstmt = CONCAT('update far_depre set d_', @period,'= cost * get_dpis_rate(category_id, ', @period, '), n_', @period,'= cost - d_', @period,' where dpis_year = ', @period);
			PREPARE stmt FROM @sqlstmt;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		ELSE
			SET @sqlstmt = CONCAT('update far_depre set d_', @period,'= cost * get_dpis_rate(category_id, ', @period, ') * ((13-dpis_month)/12), n_', @period,'= cost - d_', @period,' where dpis_year = ', @period);
			PREPARE stmt FROM @sqlstmt;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		END IF;
	      
		IF @period > 1996 THEN
			SET @sqlstmt = CONCAT('update far_depre set d_', @period,'= if(dpis_year_end=', @period, ', n_', @period-1,', n_', @period-1,' * get_dpis_rate(category_id, ', @period, ')), n_', @period,'= n_', @period-1,' - d_', @period,' where dpis_year_end>=', @period,' and dpis_year <', @period, ' and (category_id not in (''BLD TS'',''Building'') or (category_id in (''CME NW SHL'',''infraCME_bangunan'',''infraCME_bangunan_2'') and ', @period,'<2004))');       
			PREPARE stmt FROM @sqlstmt;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			
			SET @sqlstmt = CONCAT('update far_depre set d_', @period,'= if(dpis_year_end=', @period, ', n_', @period-1,', cost * get_dpis_rate(category_id, ', @period, ')), n_', @period,'= n_', @period-1,' - d_', @period,' where dpis_year_end>=', @period,' and  dpis_year <', @period,' and category_id in (''BLD TS'',''Building'')');
			PREPARE stmt FROM @sqlstmt;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		IF @period > 2003 THEN
			SET @sqlstmt = CONCAT('update far_depre set d_', @period,'= if(dpis_year_end=', @period, ', n_', @period-1,', cost * get_dpis_rate(category_id, ', @period, ')), n_', @period,'= n_', @period-1,' - d_', @period,' where dpis_year_end>=', @period,' and dpis_year < ', @period,' and dpis_year >= 2004 and category_id in (''CME NW SHL'',''infraCME_bangunan'',''infraCME_bangunan_2'')');
			PREPARE stmt FROM @sqlstmt;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		  
			SET @sqlstmt = CONCAT('update far_depre set d_', @period,'= if(dpis_year_end=', @period, ', n_', @period-1,',  n_2003 * get_dpis_rate(category_id, ', @period, ')), n_', @period,'= n_', @period-1,' - d_', @period,' where dpis_year_end>=', @period,' and dpis_year < ', @period,' and dpis_year < 2004 and category_id in (''CME NW SHL'',''infraCME_bangunan'',''infraCME_bangunan_2'')');
			PREPARE stmt FROM @sqlstmt;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		END IF;
		ELSE
		
			SET @sqlstmt = CONCAT('update far_depre set d_', @period,'= cost * get_dpis_rate(category_id, ', @period, '), n_', @period,'= cost - d_', @period,' where dpis_year < ', @period);
			PREPARE stmt FROM @sqlstmt;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		END IF;
		
		SET @akum = CONCAT_WS('+', @akum, CONCAT(' far_depre.d_',@period,' '));
		IF @period = (parameter_year - 1) THEN
			SET @akum = CONCAT('update far_depre set akum_upto_prev_Year = (', @akum,');');
			PREPARE akum FROM @akum;
			EXECUTE akum;
			DEALLOCATE PREPARE akum;
		END IF;
		
		IF @period = 2017 THEN
			SET @monthperiod = 1;
			WHILE @monthperiod <= 12 DO
				SET @addColumn = CONCAT('alter table far_depre add column dm', @monthperiod, '_', @period, ' decimal(20,2) default 0, add column nm', @monthperiod,'_',@period, ' decimal(20,2) default 0');
				PREPARE addColumn FROM @addColumn;
				EXECUTE addColumn;
				DEALLOCATE PREPARE addColumn;
				
				SET @sqlstmt = CONCAT('update far_depre set dm',@monthperiod, '_', @period ,'= d_',@period ,'/(13-dpis_month) * if(dpis_month>',@monthperiod,',0,',@monthperiod+1,'-dpis_month), nm',@monthperiod,'_', @period ,'= cost - dm',@monthperiod,'_', @period , 
									' where dpis_year = ', @period );
				PREPARE stmt FROM @sqlstmt;
				EXECUTE stmt;

				SET @sqlstmt = CONCAT('update far_depre set dm',@monthperiod,'_', @period ,'= ',@monthperiod,'/12 * d_',@period ,', nm',@monthperiod,'_', @period ,'= n_',@period -1,' - dm',@monthperiod,'_', @period ,
									' where dpis_year < ', @period ,' and dpis_year_end>', @period );
				PREPARE stmt FROM @sqlstmt;
				EXECUTE stmt;

				SET @sqlstmt = CONCAT('update far_depre set dm',@monthperiod,'_', @period,'= (d_',@period,'/dpis_month_end) * if(dpis_month_end>',@monthperiod,',',@monthperiod,',dpis_month_end), nm',@monthperiod,'_', @period ,'= n_',@period -1,' - dm',@monthperiod,'_', @period ,
									' where dpis_year_end = ', @period );
				PREPARE stmt FROM @sqlstmt;
				EXECUTE stmt;
				
				SET @monthperiod = @monthperiod + 1;
			END WHILE;
		END IF;
		SET @period = @period + 1;
	END WHILE;
END; $$

DELIMITER ;