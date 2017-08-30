DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `update_depre_nbv_wo_by_month_year`$$

CREATE PROCEDURE `update_depre_nbv_wo_by_month_year`(IN paramMonth INTEGER(2), IN paramYear INTEGER(4))
    MODIFIES SQL DATA
 BEGIN
	SET @stmt = CONCAT("alter table mapping_write_off change dm",paramMonth,"_",paramYear," `d_",paramYear,"_sd_date_event` decimal(20,2), change nm",paramMonth,"_",paramYear," `n_",paramYear,"_sd_date_event` DECIMAL(20,2);");PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;