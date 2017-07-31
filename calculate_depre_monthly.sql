DELIMITER $$

USE `tax`$$

DROP PROCEDURE IF EXISTS `calculate_depre_monthly`$$

CREATE DEFINER=`root`@`%` PROCEDURE `calculate_depre_monthly`(monthperiod INTEGER,IN period INTEGER)
    MODIFIES SQL DATA
BEGIN
      
      SET @sqlstmt = CONCAT('update asset set dm',monthperiod, '_', period,'= d_',period,'/(13-dpis_month) * if(dpis_month>',monthperiod,',0,',monthperiod+1,'-dpis_month), nm',monthperiod,'_', period,'= cost - dm',monthperiod,'_', period, 
                            ' where dpis_year = ', period);
      PREPARE stmt FROM @sqlstmt;
      EXECUTE stmt;
      
      SET @sqlstmt = CONCAT('update asset set dm',monthperiod,'_', period,'= ',monthperiod,'/12 * d_',period,', nm',monthperiod,'_', period,'= n_',period-1,' - dm',monthperiod,'_', period,
                            ' where dpis_year < ', period,' and dpis_year_end>', period);
      PREPARE stmt FROM @sqlstmt;
      EXECUTE stmt;
      
      SET @sqlstmt = CONCAT('update asset set dm',monthperiod,'_', period,'= (d_',period,'/dpis_month_end) * if(dpis_month_end>',monthperiod,',',monthperiod,',dpis_month_end), nm',monthperiod,'_', period,'= n_',period-1,' - dm',monthperiod,'_', period,
                            ' where dpis_year_end = ', period);
      PREPARE stmt FROM @sqlstmt;
      EXECUTE stmt;
END$$

DELIMITER ;