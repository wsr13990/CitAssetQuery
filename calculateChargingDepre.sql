DELIMITER $$
USE `cit_asset`$$
DROP PROCEDURE IF EXISTS `calculateChargingDepre`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `calculateChargingDepre`(IN paramYear INTEGER(4))
    MODIFIES SQL DATA
    BEGIN
	SET @stmt = CONCAT("UPDATE `write_off_depre` SET `akum_addition_retire_tahun_yang_sama` = IF(",paramYear," = 0, 0, (",paramYear,"/cost)*akum_upto_prev_Year);");
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	SET @stmt = CONCAT("UPDATE `write_off_depre` SET `charging_depre` = `akum_addition_retire_tahun_yang_sama` + `d_",paramYear,"_sd_date_event`;");
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	SELECT SUM(`charging_depre`) FROM `write_off_depre`;
    END$$

DELIMITER ;