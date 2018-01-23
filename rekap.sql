#######################################################################################################################################
################################################PARAMETER SETTINGS#####################################################################
#######################################################################################################################################
-- SET @month = 6;
-- SET @year = 2017;
-- SET @depre_bangunan_bulk =  12176026097;
-- SET @depre_tower_2005 =  @depreTowerBulk;


-- SET @month = 7;
-- SET @year = 2017;
-- SET @depre_bangunan_bulk = 14205363780.3347;
-- SET @depre_tower_2005 =  63093691311.1151;


-- SET @month = 8;
-- SET @year = 2017;
-- SET @depre_bangunan_bulk = 16234701463.2397;
-- SET @depre_tower_2005 =  73195352985.96;

-- SET @month = 9;
-- SET @year = 2017;
-- SET @depre_bangunan_bulk = 18264039146;
-- SET @depre_tower_2005 =  @depreTowerBulk;

-- SET @month = 10;
-- SET @year = 2017;
-- SET @depre_bangunan_bulk = 20293376829;
-- SET @depre_tower_2005 =  @depreTowerBulk;

-- SET @month = 11;
-- SET @year = 2017;
-- SET @depre_bangunan_bulk =  22322714512;
-- SET @depre_tower_2005 =  @depreTowerBulk;

SET @month = 12;
SET @year = 2017;
SET @depre_bangunan_bulk =  24352052195;
SET @depre_tower_2005 =  @depreTowerBulk;



#######################################################################################################################################
############################################CREATE GROSS FA FOR CIT UPLOAD#############################################################
#######################################################################################################################################
SET @manual2005 = 4358183121883;
SET @addition_date = DATE_FORMAT(LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1")), "%m/%d/%Y");
SET @addition_period = LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1"));
SET @wo_date = LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1"));

DROP TABLE IF EXISTS upload;
DROP TABLE IF EXISTS temp1;
DROP TABLE IF EXISTS temp2;
#File upload exclude depre building bulk
SET @far = 	CONCAT('SELECT `asset_number`,`category` as category_name,DATE_FORMAT(dpis, "%m/%d/%Y") as dpis,`cost`,`dm',@month,'_',@year,'` AS ytd_deprn,`dm',@month,'_',@year,'`+`akum_upto_prev_Year` AS deprn_reserve, "FISCAL" AS book_type_code, 1 AS `desc`, source_detail, @addition_date AS period_name
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date > @wo_date) AND addition_period <= @addition_period
			AND (source_detail = "FAR2006" OR source_detail = "FAR2007" OR source_detail = "FAR2008" OR source_detail = "FAR2009" OR source_detail = "FAR2010"
				OR source_detail = "FAR2011" OR source_detail = "FAR2012" OR source_detail = "FAR2013" OR source_detail = "FAR2014" OR source_detail = "FAR2015"
				OR source_detail = "FAR2016" or source_detail = "FAR2017")');
SET @wo_manual_2011 = CONCAT('SELECT `asset_number`,`category`,DATE_FORMAT(dpis, "%m/%d/%Y"),`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2011", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date > @wo_date)
				AND source_detail = "WO_Manual2011"');
SET @wo_manual_2012 = CONCAT('SELECT `asset_number`,`category`,DATE_FORMAT(dpis, "%m/%d/%Y"),`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2012", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date > @wo_date)
				AND source_detail = "WO_Manual2012"');
SET @wo_manual_2013 = CONCAT('SELECT `asset_number`,`category`,DATE_FORMAT(dpis, "%m/%d/%Y"),`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2013", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date > @wo_date)
				AND source_detail = "WO_Manual2013"');
SET @wo_manual_2014 = CONCAT('SELECT `asset_number`,`category`,DATE_FORMAT(dpis, "%m/%d/%Y"),`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2014", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date > @wo_date)
				AND source_detail = "WO_Manual2014"');
SET @wo_manual_2016 = CONCAT('SELECT `asset_number`,`category`,DATE_FORMAT(dpis, "%m/%d/%Y"),`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2016", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date > @wo_date)
				AND source_detail = "WO_Manual2016"');
SET @rev_manual_2005 = CONCAT('SELECT `asset_number`,`category`,DATE_FORMAT(dpis, "%m/%d/%Y"),`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "Reverse Manual 2005", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL OR write_off_date >= @wo_date) AND source_detail = "ReverseManual2005"');			
SET @manual = CONCAT('SELECT `asset_number`, `category`, DATE_FORMAT(dpis, "%m/%d/%Y"), `cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "Manual 2017", @addition_date
			FROM `manual`');
SET @intangible_asset = CONCAT('SELECT `asset_number`, `category`, DATE_FORMAT(dpis, "%m/%d/%Y"), `cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, source_detail, @addition_date
			FROM `intangible_asset`');
SET @stmt = CONCAT('create temporary table temp1 as ', CONCAT_WS(' union all ', @far, @wo_manual_2011, @wo_manual_2012, @wo_manual_2013, @wo_manual_2014, @wo_manual_2016, @rev_manual_2005, @manual, @intangible_asset), ';');
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

			
DROP TABLE IF EXISTS temp2;
SET @no_asset_number = CONCAT('	create temporary table temp2(asset_number INT AUTO_INCREMENT PRIMARY KEY) as
				SELECT `category`,DATE_FORMAT(LAST_DAY(CONCAT(CAST(dpis_year AS CHAR(4)),"-", CAST(dpis_month AS CHAR(2)),"-", "1")), "%m/%d/%Y") as dpis,0 as cost,`dm',@month,'_',@year,'` as ytd_deprn,`dm',@month,'_',@year,'`+`akum_upto_prev_Year` as deprn_reserve, "FISCAL" as book_type_code, 1 as `desc`, "Bulk 2005" as source, @addition_date as period_name
				FROM far_depre
				WHERE (write_off_date IS NULL OR write_off_date > @wo_date) AND source_detail = "Tower 2005"
				UNION all
				select "Infra", "11/30/1997", @manual2005, 0, 0, "FISCAL", 1, "Bulk 2005", @addition_date
				UNION all
				select "Bangunan", "1/28/2002", 0, @depre_bangunan_bulk,@depre_tower_2005, "FISCAL", 1, "Bulk 2005", @addition_date
				;');

PREPARE stmt FROM @no_asset_number;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE upload(id MEDIUMINT AUTO_INCREMENT PRIMARY KEY) AS
SELECT * FROM temp1
UNION ALL
SELECT * FROM temp2
UNION ALL				
SELECT `asset_number`, `category`, DATE_FORMAT(dpis, "%m/%d/%Y"), SUM(cost), 0, 0, "FISCAL", 1, "Bulk 2005", @addition_date
FROM far_depre
WHERE source_detail = "bulk_2005"  AND (bulk_2005_write_off_date IS NULL OR bulk_2005_write_off_date < @wo_date) GROUP BY asset_number
UNION ALL		
SELECT `asset_number_wo`, `category`, DATE_FORMAT(dpis, "%m/%d/%Y"), 0 , 0, `charging_depre`, "FISCAL", 1 ,"Manual 2017", @addition_date FROM `write_off_depre`
#UNION ALL
#SELECT *FROM `manual_write_off_fiscal` WHERE period_name = @wo_date
;


-- CREATE INDEX idx1 ON upload(`asset_number`);
-- CREATE INDEX idx2 ON upload(`source`);
-- CREATE INDEX idx3 ON upload(`dpis`);
-- CREATE INDEX idx4 ON upload(`category`);

SELECT source_detail, SUM(cost) AS cost, SUM(`ytd_deprn`) AS ytd_deprn, SUM(`deprn_reserve`) AS deprn_reserve FROM `upload` GROUP BY `source_detail`;

SELECT asset_number, category, dpis, cost, ytd_deprn, deprn_reserve, book_type, `desc`, source, period_name  FROM upload;