DELIMITER $$

USE `tax`$$

DROP PROCEDURE IF EXISTS `calculate_depre`$$

CREATE DEFINER=`root`@`%` PROCEDURE `calculate_depre`(IN period INTEGER)
    READS SQL DATA
BEGIN
      
      IF period < 2001 THEN
        SET @sqlstmt = CONCAT('update asset set d_', period,'= cost * get_dpis_rate(category_id, ', period, '), n_', period,'= cost - d_', period,' where dpis_year = ', period);
        PREPARE stmt FROM @sqlstmt;
        EXECUTE stmt;
      ELSE
        SET @sqlstmt = CONCAT('update asset set d_', period,'= cost * get_dpis_rate(category_id, ', period, ') * ((13-dpis_month)/12), n_', period,'= cost - d_', period,' where dpis_year = ', period);
        PREPARE stmt FROM @sqlstmt;
        EXECUTE stmt;
      END IF;
      
      IF period > 1996 THEN
        
        
        
        SET @sqlstmt = CONCAT('update asset set d_', period,'= if(dpis_year_end=', period, ', n_', period-1,', n_', period-1,' * get_dpis_rate(category_id, ', period, ')), n_', period,'= n_', period-1,' - d_', period,' where dpis_year_end>=', period,' and dpis_year <', period, ' and (category_id not in (''BLD TS'',''Building'') or (category_id in (''CME NW SHL'',''infraCME_bangunan'',''infraCME_bangunan_2'') and ', period,'<2004))');       
        PREPARE stmt FROM @sqlstmt;
        EXECUTE stmt;
        
        
        
        SET @sqlstmt = CONCAT('update asset set d_', period,'= if(dpis_year_end=', period, ', n_', period-1,', cost * get_dpis_rate(category_id, ', period, ')), n_', period,'= n_', period-1,' - d_', period,' where dpis_year_end>=', period,' and  dpis_year <', period,' and category_id in (''BLD TS'',''Building'')');
        PREPARE stmt FROM @sqlstmt;
        EXECUTE stmt;
        IF period > 2003 THEN
          
          
          SET @sqlstmt = CONCAT('update asset set d_', period,'= if(dpis_year_end=', period, ', n_', period-1,', cost * get_dpis_rate(category_id, ', period, ')), n_', period,'= n_', period-1,' - d_', period,' where dpis_year_end>=', period,' and dpis_year < ', period,' and dpis_year >= 2004 and category_id in (''CME NW SHL'',''infraCME_bangunan'',''infraCME_bangunan_2'')');
          PREPARE stmt FROM @sqlstmt;
          EXECUTE stmt;
          
          SET @sqlstmt = CONCAT('update asset set d_', period,'= if(dpis_year_end=', period, ', n_', period-1,',  n_2003 * get_dpis_rate(category_id, ', period, ')), n_', period,'= n_', period-1,' - d_', period,' where dpis_year_end>=', period,' and dpis_year < ', period,' and dpis_year < 2004 and category_id in (''CME NW SHL'',''infraCME_bangunan'',''infraCME_bangunan_2'')');
          PREPARE stmt FROM @sqlstmt;
          EXECUTE stmt;
        END IF;
      ELSE
        
        SET @sqlstmt = CONCAT('update asset set d_', period,'= cost * get_dpis_rate(category_id, ', period, '), n_', period,'= cost - d_', period,' where dpis_year < ', period);
        PREPARE stmt FROM @sqlstmt;
        EXECUTE stmt;
      END IF;
    END$$

DELIMITER ;