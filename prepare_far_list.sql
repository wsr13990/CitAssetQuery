DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `prepare_far_list`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prepare_far_list`(IN paramYear INTEGER(2),OUT far_list VARCHAR(255))
    MODIFIES SQL DATA
BEGIN
	SET @year = 2007;
	SET @far_list = "'FAR2006'";
	WHILE @year < paramYear DO
		SET @year = @year + 1;
		SET @far_list = CONCAT(@far_list,',',CONCAT("'FAR",@year,"'"));
	END WHILE;
	SET far_list = CONCAT('(',@far_list,')');
END$$

DELIMITER ;