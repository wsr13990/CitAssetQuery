USE `history`;
DELIMITER $$

DROP PROCEDURE IF EXISTS `update_claim_proceed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_claim_proceed`(IN `month` INT(2), IN `year` INT(4))
MODIFIES SQL DATA
BEGIN	
	SET @filedate = CONCAT(RIGHT(CONCAT('0',`month`),2),RIGHT(`year`,2));
	DROP TABLE IF EXISTS update_proceed;

	SET @stmt = CONCAT("
	create temporary table update_proceed as(
	SELECT	`id`,`source`,`group`,`paid`,temp1.`je_id_description`,`je_id`,`site_id`,
		temp2.`dpis`,temp2.`asset_number`,`desc`,`asset_category`,temp2.`dol`,`period_wo`,`cost`,
		`accum_depre`,`nbv`,`ar_claim`,`period_record`,`period_report`,
		`percentage`,`qty_paid`,`other_income`,`gain_loss`
	FROM (SELECT * FROM `claim_proceed_",@filedate,"` WHERE `asset_number` = '')temp1 
	left join
	(SELECT `je_id_description`,`asset_number`,`dpis`,`dol` FROM `claim_proceed_",@filedate,"` GROUP BY `je_id_description`)temp2
	on temp2.`je_id_description`=temp1.`je_id_description`);
	");
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	SET @stmt = CONCAT("
	update `claim_proceed_",@filedate,"`, update_proceed
	set	`claim_proceed_",@filedate,"`.`dpis` = update_proceed.`dpis`,
		`claim_proceed_",@filedate,"`.`asset_number` = update_proceed.`asset_number`,
		`claim_proceed_",@filedate,"`.`dol` = update_proceed.`dol`
	where (`claim_proceed_",@filedate,"`.`asset_number`='' or `claim_proceed_",@filedate,"`.`asset_number` is null)
	and `claim_proceed_",@filedate,"`.`je_id_description` = update_proceed.`je_id_description`;
	");
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	SET @stmt = CONCAT("
	set @control = (SELECT count(*) FROM `claim_proceed_",@filedate,"` WHERE `asset_number` = '');
	");
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	IF @control = 0 THEN
		SELECT "Ok: All claim proceed asset_number already filled" AS control;
	ELSE
		SET @stmt = CONCAT("
		SELECT * FROM `claim_proceed_",@filedate,"` WHERE `asset_number` = '';
		");
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END IF;
END$$

DELIMITER ;