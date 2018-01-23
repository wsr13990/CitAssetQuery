CALL `update_claim_proceed`(6,2017);


USE history;
SET @month = 6;
SET @year = 2017;
#######################################################################################################################################
########################################CREATE UPLOAD FILE TO CIT SYSTEM FOR WRITE OFF FISCAL##########################################
#######################################################################################################################################
SET @filedate = CONCAT(RIGHT(CONCAT('0',@month),2),RIGHT(@year,2));
SET @claim_proceed = CONCAT('claim_proceed_',@filedate);
SET @upload_wo_fiscal = CONCAT('upload_wo_fiscal_',@filedate);
SET @wo_date = LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1"));

SET @stmt = CONCAT("DROP TABLE IF EXISTS ",@upload_wo_fiscal,";");
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @stmt = CONCAT("
CREATE TABLE ",@upload_wo_fiscal," AS
SELECT 	",@claim_proceed,".`je_id_description` AS batch_name,
	DATE_FORMAT(",@claim_proceed,".`period_wo`,'%m/%d/%Y') AS given_up_date,
	",@claim_proceed,".`asset_number` AS asset_number,
	DATE_FORMAT(",@claim_proceed,".`dpis`,'%m/%d/%Y') AS date_placed_in_service,
	",@claim_proceed,".`asset_category` AS Kategori,
	",@claim_proceed,".`cost` AS Cost,
	0 AS deprn_amount,
	wo_depre.`akum_upto_prev_Year` + wo_depre.`d_2017_sd_date_event` AS deprn_reserve,
	'FISCAL' AS book_type_code,
	sum(",@claim_proceed,".`ar_claim`) AS Ar_claim,
	sum(",@claim_proceed,".`other_income`) AS proceed,
	wo_depre.type_wo,
	'' AS `group`,
	DATE_FORMAT(@wo_date,'%m/%d/%Y') AS period_name
FROM ",@claim_proceed,"
LEFT JOIN (select * from cit_asset.write_off_depre where month(give_up_date) = @month and year(give_up_date) = @year) wo_depre
ON wo_depre.`asset_number_wo` = ",@claim_proceed,".`asset_number`
WHERE month(period_wo) = @month and year(period_wo) = @year group by asset_number
");
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;



UNION
SELECT 	cit_asset.`write_off_depre`.`batch` AS batch_name,
	cit_asset.`write_off_depre`.`give_up_date` AS given_up_date,
	cit_asset.`write_off_depre`.`asset_number_wo` AS asset_number,
	cit_asset.`write_off_depre`.`dpis` AS date_placed_in_service,
	cit_asset.`write_off_depre`.`category` AS Kategori,
	0 AS Cost,
	0 AS deprn_amount,
	0 AS deprn_reserve,
	'FISCAL' AS book_type_code,
	",@claim_proceed,".`ar_claim` AS Ar_claim,
	",@claim_proceed,".`other_income` AS proceed,
	cit_asset.`write_off_depre`.type_wo,
	'' AS `group`,
	@wo_date AS period_name
FROM cit_asset.`write_off_depre`
RIGHT JOIN ",@claim_proceed,"
ON cit_asset.`write_off_depre`.`asset_number_wo` = ",@claim_proceed,".`asset_number`
WHERE cit_asset.`write_off_depre`.give_up_date < @wo_date AND MONTH(",@claim_proceed,".`period_wo`) = @month AND YEAR(",@claim_proceed,".`period_wo`) =@year
UNION
SELECT * FROM cit_asset.`manual_write_off_fiscal` WHERE MONTH(`period_name`)=@month AND YEAR(`period_name`)=@year;


#######################################################################################################################################
####################################CREATE UPLOAD FILE TO CIT SYSTEM FOR WRITE OFF COMMERCIAL##########################################
#######################################################################################################################################

DROP TABLE IF EXISTS upload_wo_commercial_temp;
CREATE TEMPORARY TABLE upload_wo_commercial_temp AS
SELECT * FROM (
SELECT 	`claim_proceed`.`je_id_description` AS batch_name,
	`write_off_depre`.`give_up_date` AS given_up_date,
	`write_off_depre`.`asset_number_wo` AS asset_number,
	`write_off_depre`.`dpis` AS date_placed_in_service,
	`write_off_depre`.`category` AS Kategori,
	`write_off_depre`.`cost` AS Cost,
	0 AS deprn_amount,
	`claim_proceed`.`accum_depre` AS deprn_reserve,
	'COMMERCIAL' AS book_type_code,
	0 AS Ar_claim,
	0 AS proceed,
	`write_off_depre`.type_wo,
	'' AS `group`,
	@wo_date AS period_name
FROM `write_off_depre`
LEFT JOIN claim_proceed
ON `write_off_depre`.`asset_number_wo` = `claim_proceed`.`asset_number`
WHERE `write_off_depre`.give_up_date = @wo_date
GROUP BY asset_number,`period_wo`)temp;

UPDATE upload_wo_commercial_temp
INNER JOIN 
(SELECT * FROM claim_proceed WHERE MONTH(`period_report`)=@month AND YEAR(`period_report`)=@year)b SET upload_wo_commercial_temp.Ar_claim = b.ar_claim, proceed=b.`other_income` WHERE upload_wo_commercial_temp.asset_number = b.`asset_number`;

-- UPDATE upload_wo_commercial_temp
-- INNER JOIN
-- `claim_proceed` SET upload_wo_commercial_temp.Ar_claim = claim_proceed.ar_claim, proceed=claim_proceed.`other_income` WHERE upload_wo_commercial_temp.asset_number = claim_proceed.`asset_number`;

DROP TABLE IF EXISTS upload_wo_commercial;
CREATE TABLE upload_wo_commercial AS
SELECT * FROM upload_wo_commercial_temp
UNION
SELECT 	`claim_proceed`.`je_id_description` AS batch_name,
	`write_off_depre`.`give_up_date` AS given_up_date,
	`write_off_depre`.`asset_number_wo` AS asset_number,
	`write_off_depre`.`dpis` AS date_placed_in_service,
	`write_off_depre`.`category` AS Kategori,
	0 AS Cost,
	0 AS deprn_amount,
	0 AS deprn_reserve,
	'COMMERCIAL' AS book_type_code,
	SUM(`claim_proceed`.`ar_claim`) AS Ar_claim,
	SUM(`claim_proceed`.`other_income`) AS proceed,
	`write_off_depre`.type_wo,
	'' AS `group`,
	@wo_date AS period_name
FROM `write_off_depre`
RIGHT JOIN `claim_proceed`
ON `write_off_depre`.`asset_number_wo` = `claim_proceed`.`asset_number`
WHERE MONTH(`write_off_depre`.give_up_date) < @month AND MONTH(`claim_proceed`.`period_report`) = @month AND YEAR(`claim_proceed`.`period_report`) =@year
GROUP BY asset_number,`period_wo`
UNION
SELECT * FROM `manual_write_off_commercial` WHERE MONTH(`period_name`)=@month AND YEAR(`period_name`)=@year;

SELECT * FROM `upload_wo_commercial`;

SELECT	SUM(`Cost`) - 29476690178 AS cost_diff,
	SUM(`deprn_amount`) - 0 AS deprn_diff,
	SUM(`deprn_reserve`)-22385343082 AS deprn_reserve_diff,
	SUM(`Ar_claim`)-2317786331 AS ar_claim_diff,
	SUM(`proceed`)-0 AS proceed_reserve
 FROM `upload_wo_commercial`;
