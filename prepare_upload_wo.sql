USE history;
SET @month = 6;
SET @year = 2017;

CALL `update_claim_proceed`(@month,@year);
#######################################################################################################################################
########################################CREATE UPLOAD FILE TO CIT SYSTEM FOR WRITE OFF FISCAL##########################################
#######################################################################################################################################
SET @filedate = CONCAT(RIGHT(CONCAT('0',@month),2),RIGHT(@year,2));
SET @claim_proceed = CONCAT('claim_proceed_',@filedate);
SET @upload_wo = CONCAT('upload_wo_fiscal_',@filedate);
SET @wo_date = LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1"));

SET @stmt = CONCAT("DROP TABLE IF EXISTS ",@upload_wo,";");
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @stmt = CONCAT("
CREATE TABLE ",@upload_wo," AS
SELECT 	",@claim_proceed,".`je_id_description` AS batch_name,
	DATE_FORMAT(",@claim_proceed,".`period_wo`,'%m/%d/%Y') AS given_up_date,
	",@claim_proceed,".`asset_number` AS `Asset Number`,
	DATE_FORMAT(",@claim_proceed,".`dpis`,'%m/%d/%Y') AS date_placed_in_service,
	",@claim_proceed,".`asset_category` AS Kategori,
	",@claim_proceed,".`cost` AS Cost,
	0.00 AS deprn_amount,
	wo_depre.`akum_upto_prev_Year` + wo_depre.`d_2017_sd_date_event` AS deprn_reserve,
	'FISCAL' AS book_type_code,
	sum(",@claim_proceed,".`ar_claim`) AS Ar_claim,
	sum(",@claim_proceed,".`other_income`) AS proceed,
	",@claim_proceed,".source as type_wo,
	'' AS `group`,
	DATE_FORMAT(@wo_date,'%m/%d/%Y') AS period_name
FROM ",@claim_proceed,"
LEFT JOIN (select * from cit_asset.write_off_depre where month(give_up_date) = @month and year(give_up_date) = @year) wo_depre
ON wo_depre.`asset_number_wo` = ",@claim_proceed,".`asset_number`
WHERE month(period_wo) = @month and year(period_wo) = @year group by ",@claim_proceed,".asset_number
");
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @stmt = CONCAT("
ALTER TABLE ",@upload_wo," 	MODIFY COLUMN `Cost` DECIMAL(42,2) NOT NULL DEFAULT 0,
				MODIFY COLUMN `deprn_amount` DECIMAL(42,2) NOT NULL DEFAULT 0,
				MODIFY COLUMN `deprn_reserve` DECIMAL(42,2) NOT NULL DEFAULT 0,
				MODIFY COLUMN `Ar_claim` DECIMAL(42,2) NOT NULL DEFAULT 0,
				MODIFY COLUMN `proceed` DECIMAL(42,2) NOT NULL DEFAULT 0;
");
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

#######################################################################################################################################
####################################CREATE UPLOAD FILE TO CIT SYSTEM FOR WRITE OFF COMMERCIAL##########################################
#######################################################################################################################################

SET @filedate = CONCAT(RIGHT(CONCAT('0',@month),2),RIGHT(@year,2));
SET @claim_proceed = CONCAT('claim_proceed_',@filedate);
SET @upload_wo = CONCAT('upload_wo_commercial_',@filedate);
SET @wo_date = LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1"));

SET @stmt = CONCAT("DROP TABLE IF EXISTS ",@upload_wo,";");
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @stmt = CONCAT("
CREATE TABLE ",@upload_wo," AS
SELECT 	",@claim_proceed,".`je_id_description` AS batch_name,
	DATE_FORMAT(",@claim_proceed,".`period_wo`,'%m/%d/%Y') AS given_up_date,
	",@claim_proceed,".`asset_number` AS asset_number,
	DATE_FORMAT(",@claim_proceed,".`dpis`,'%m/%d/%Y') AS date_placed_in_service,
	",@claim_proceed,".`asset_category` AS Kategori,
	",@claim_proceed,".`cost` AS Cost,
	0 AS deprn_amount,
	",@claim_proceed,".`accum_depre` AS deprn_reserve,
	'COMMERCIAL' AS book_type_code,
	sum(",@claim_proceed,".`ar_claim`) AS Ar_claim,
	sum(",@claim_proceed,".`other_income`) AS proceed,
	",@claim_proceed,".source as type_wo,
	'' AS `group`,
	DATE_FORMAT(@wo_date,'%m/%d/%Y') AS period_name
FROM ",@claim_proceed,"
WHERE month(period_wo) = @month and year(period_wo) = @year group by asset_number
");
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @stmt = CONCAT("
ALTER TABLE ",@upload_wo," 	MODIFY COLUMN `Cost` DECIMAL(42,2) NOT NULL DEFAULT 0,
				MODIFY COLUMN `deprn_amount` DECIMAL(42,2) NOT NULL DEFAULT 0,
				MODIFY COLUMN `deprn_reserve` DECIMAL(42,2) NOT NULL DEFAULT 0,
				MODIFY COLUMN `Ar_claim` DECIMAL(42,2) NOT NULL DEFAULT 0,
				MODIFY COLUMN `proceed` DECIMAL(42,2) NOT NULL DEFAULT 0;
");
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
