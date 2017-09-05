SET @month = 7;
SET @year = 2017;
SET @depre_bulk =  14205363780;
SET @akum_bulk =  311392990894;


SET @addition_date = LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1"));

DROP TABLE IF EXISTS upload;
#TODO: manual 2017 masih salah
#File upload exclude depre building bulk
SET @stmt = CONCAT('	CREATE TABLE upload AS
			SELECT `asset_number`,`category`,`dpis`,`cost`,`dm',@month,'_',@year,'` AS ytd_deprn,`dm',@month,'_',@year,'`+`akum_upto_prev_Year` AS deprn_reserve, "FISCAL" AS book_type, 1 AS `desc`, source, @addition_date AS period_name
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date >= @addition_date)
			AND (source = "FAR2006" OR source = "FAR2007" OR source = "FAR2008" OR source = "FAR2009" OR source = "FAR2010"
				OR source = "FAR2011" OR source = "FAR2012" OR source = "FAR2013" OR source = "FAR2014" OR source = "FAR2015"
				OR source = "FAR2016" or source = "FAR2017")
			union all
			SELECT `asset_number`,`category`,`dpis`,`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2011", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date >= @addition_date)
				AND source = "WO_Manual2011"
			union all
			SELECT `asset_number`,`category`,`dpis`,`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2012", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date >= @addition_date)
				AND source = "WO_Manual2012"
			union all
			SELECT `asset_number`,`category`,`dpis`,`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2013", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date >= @addition_date)
				AND source = "WO_Manual2013"
			union all
			SELECT `asset_number`,`category`,`dpis`,`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2014", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date >= @addition_date)
				AND source = "WO_Manual2014"
			union all
			SELECT `asset_number`,`category`,`dpis`,`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "WO-Manual2016", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL or write_off_date >= @addition_date)
				AND source = "WO_Manual2016"
			union all
			SELECT `asset_number`,`category`,`dpis`,`cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "Reverse Manual 2005", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL OR write_off_date >= @addition_date) AND source = "ReverseManual2005"
			UNION all
			SELECT 1,`category`,`dpis`,0 ,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "Bulk 2005", @addition_date
			FROM far_depre
			WHERE (write_off_date IS NULL OR write_off_date >= @addition_date) AND source = "Tower 2005"
			UNION all
			select 1,"Infra", null, 4358183121883, 0, 0, "FISCAL", 1, "Bulk 2005", @addition_date
			UNION all
			select 1,"Bangunan", null, 0, @depre_bulk,@akum_bulk, "FISCAL", 1, "Bulk 2005", @addition_date
			UNION all			
			SELECT `asset_number`, `category`, `dpis`, SUM(cost), 0, 0, "FISCAL", 1, "Bulk 2005", @addition_date
			FROM far_depre
			WHERE source_detail = "bulk_2005"  AND (bulk_2005_write_off_date IS NULL OR bulk_2005_write_off_date < @addition_date) GROUP BY asset_number
			UNION all
			select `asset_number_wo`, `category`, `dpis`, 0 , 0, `charging_depre`, "FISCAL", 1 ,"Manual 2017", @addition_date from `write_off_depre`
			union all
			SELECT `asset_number`, `category`, `dpis`, `cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, "Manual 2017", @addition_date
			FROM `manual`
			union all
			SELECT `asset_number`, `category`, `dpis`, `cost`,`dm',@month,'_',@year,'`,`dm',@month,'_',@year,'`+`akum_upto_prev_Year`, "FISCAL", 1, source, @addition_date
			FROM `intangible_asset`;');
PREPARE stmt FROM @stmt;
EXECUTE stmt;
#create index idx on upload(`asset_number`,`source`);

SELECT source, SUM(cost) AS cost, SUM(`ytd_deprn`) AS ytd_deprn, SUM(`deprn_reserve`) AS deprn_reserve FROM `upload` GROUP BY `source`;