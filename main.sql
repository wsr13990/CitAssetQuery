#Closing month and year, change it to the intended closing month and year
SET @month = 11;
SET @year = 2017;
SET @depreBulkBangunan =   22322714512;#November

############################################################################################################################################
####################################################### Monthly Closing ####################################################################
############################################################################################################################################
SET @faryear = CONCAT("FAR",@year);
SET @addition_period = LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1"));


TRUNCATE TABLE far_addition_monthly;
#Import the addition far to far_addition_monthly
UPDATE `far_addition_monthly` SET `addition_period` = @addition_period, source = @faryear, source_detail = @faryear;
CALL `fill_categoryId_byTableName`("far_addition_monthly");
CALL `fill_dpis_monthAndyear_by_tableName`("far_addition_monthly");
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"far_addition_monthly");
CALL `calculate_depre_monthly_for_a_year`(@year, "far_addition_monthly");
CALL `recalculate_akum_upto`(@year-1, "far_addition_monthly");
CALL `insert_table_from_to`("far_addition_monthly", "far_depre");
UPDATE far_depre SET source_detail2=source WHERE source_detail2 ='' ;
UPDATE `far_depre` SET kelompok_aset = get_kelompok_aset(category_id) WHERE kelompok_aset IS NULL;


TRUNCATE TABLE manual;
#Import the manual to manual table
UPDATE `manual` SET `addition_period` = @addition_period, source = "Manual", source_detail = "Manual";
CALL `fill_categoryId_byTableName`("manual");
CALL `fill_dpis_monthAndyear_by_tableName`("manual");
UPDATE manual SET category_id = "ARO" WHERE 	asset_id = 217189 OR
						asset_id = 217190 OR
						asset_id = 216977 OR
						asset_id = 216978 OR
						asset_id = 216979 OR
						asset_id = 216288;
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"manual");
CALL `calculate_depre_monthly_for_a_year`(@year, "manual");
CALL `recalculate_akum_upto`(@year-1, "manual");


TRUNCATE TABLE intangible_asset;
#Import the intangible asset to intangible_asset table
UPDATE `intangible_asset` SET `addition_period` = @addition_period, source_detail = source;
CALL `fill_categoryId_byTableName`("intangible_asset");
CALL `fill_dpis_monthAndyear_by_tableName`("intangible_asset");
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"intangible_asset");
CALL `calculate_depre_monthly_for_a_year`(@year, "intangible_asset");
CALL `recalculate_akum_upto`(@year-1, "intangible_asset");



TRUNCATE TABLE `write_off`;
#Import the write off to write_off table
UPDATE write_off SET give_up_date = @addition_period;
CALL `write_off_mapping`(@month,@year);
SELECT * FROM control_bulk_2005;
SELECT * FROM mapping_write_off;
CALL `update_write_off_date`(@month,@year);
CALL `fill_categoryId_byTableName`("mapping_write_off");
CALL `fill_dpis_monthAndyear_by_tableName`("mapping_write_off");
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"mapping_write_off");
CALL `calculate_depre_by_month_year_tableName`(@month-1,@year,"mapping_write_off");
CALL `update_depre_nbv_wo_by_month_year`(@month-1,@year);
CALL `recalculate_akum_upto`(@year-1, "mapping_write_off");
CALL `insert_table_from_to`("mapping_write_off", "write_off_depre");
CALL `calculateChargingDepre`(@year);


#Create pivot table for each category_id
CALL `get_pivot_all`(@month,@year);
DROP TABLE IF EXISTS pivotManual;
CALL `get_pivot_manual`(@month, @year, "pivotManual");
DROP TABLE IF EXISTS pivotIntangibleAsset;
CALL `get_pivot_intangible_asset`(@month, @year, "pivotIntangibleAsset");

#Display SL0608 pivot by year
SET @stmt = CONCAT("select source_detail, sum(cost) as cost,sum(akum_upto_prev_year) as akum_upto_prev_year, sum(dm",@month,"_",@year,") as dm",@month,"_",@year," from far_depre where source = 'SL0608' and write_off_date is null group by source_detail;");
PREPARE stmt FROM @smt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


#Pivot bulk 2005
DROP TABLE IF EXISTS pivotBulk2005;
#This amount is used as parameter in prepare_file_upload @akum_bulk
SET @stmt = CONCAT('set @depreTowerBulk = (select sum(dm',@month,'_',@year,') from far_depre where source_detail = "Tower 2005");');
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
SET @bulk2005 = 4358183121883;
SET @stmt = CONCAT('create table pivotBulk2005 as SELECT SUM(cost)+ @bulk2005 AS cost_2005, @depreBulkBangunan + @depreTowerBulk as dm',@month,'_',@year,' FROM far_depre WHERE source="bulk_2005";');
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

############################################################################################################################################
##################################################### New Year Calculation #################################################################
############################################################################################################################################
CALL `calculate_depre_monthly_for_a_year`(@year, "far_depre");
CALL `calculate_depreTower_year`(@year, "far_depre");
CALL `calculate_depre_monthly_for_a_year`(@year, "far_depre");
CALL `calculate_depre_monthly_for_a_year`(@year, "far_depre");
CALL `recalculate_akum_upto`(@year-1, "far_depre");
CALL `drop_dm_nm_for_year`(@year-1, "far_depre");