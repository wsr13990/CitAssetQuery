#Closing month and year, change it to the intended closing month and year
SET @month = 7;
SET @year = 2017;


############################################################################################################################################
####################################################### Monthly Closing ####################################################################
############################################################################################################################################

TRUNCATE TABLE far_addition_monthly;
#Import the addition far to far_addition_monthly
CALL `fill_categoryId_byTableName`("far_addition_monthly");
CALL `fill_dpis_monthAndyear_by_tableName`("far_addition_monthly");
UPDATE SET `addition_period` = LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1"));
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"far_addition_monthly");
CALL `recalculate_akum_upto`(@year-1, "far_addition_monthly");
CALL `insert_table_from_to`("far_addition_monthly", "far_depre");


TRUNCATE TABLE manual;
#Import the manual to manual table
CALL `fill_categoryId_byTableName`("manual");
CALL `fill_dpis_monthAndyear_by_tableName`("manual");
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"manual");
CALL `calculate_depre_monthly_for_a_year`(@year, "manual");
CALL `recalculate_akum_upto`(@year-1, "manual");


TRUNCATE TABLE intangible_asset;
#Import the intangible asset to intangible_asset table
CALL `fill_categoryId_byTableName`("intangible_asset");
CALL `fill_dpis_monthAndyear_by_tableName`("intangible_asset");
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"intangible_asset");
CALL `calculate_depre_monthly_for_a_year`(@year, "intangible_asset");
CALL `recalculate_akum_upto`(@year-1, "intangible_asset");


TRUNCATE TABLE intangible_asset;
#Import the write off to write_off table
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
#TODO: Make procedure for the query below to calculate chargin depre
UPDATE `write_off_depre` SET `akum_addition_retire_tahun_yang_sama` = IF(`FAR2017` = 0, 0, (FAR2017/cost)*akum_upto_prev_Year);
UPDATE `write_off_depre` SET `charging_depre` = `akum_addition_retire_tahun_yang_sama` + `d_2017_sd_date_event`;
SELECT SUM(`charging_depre`) FROM `write_off_depre`;

#Create pivot table for each category_id
CALL `get_pivot_all`(@month,@year);


############################################################################################################################################
##################################################### New Year Calculation #################################################################
############################################################################################################################################
CALL `calculate_depre_monthly_for_a_year`(2018, "far_depre");
CALL `calculate_depreTower_year`(2018, "far_depre");
CALL `calculate_depre_monthly_for_a_year`(2018, "far_depre");
CALL `calculate_depre_monthly_for_a_year`(2018, "far_depre");
CALL `recalculate_akum_upto`(2017, "far_depre");
CALL `drop_dm_nm_for_year`(2017, "far_depre");