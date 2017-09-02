#Closing month and year
SET @month = 7;
SET @year = 2017;


CALL `fill_categoryId_byTableName`("far_addition_monthly");
CALL `fill_dpis_monthAndyear_by_tableName`("far_addition_monthly");
UPDATE SET `addition_period` = LAST_DAY(CONCAT(CAST(@year AS CHAR(4)),"-", CAST(@month AS CHAR(2)),"-", "1"));
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"far_addition_monthly");
CALL `recalculate_akum_upto`(@year-1, "far_addition_monthly");
CALL `insert_table_from_to`("far_addition_monthly", "far_depre");


CALL `fill_categoryId_byTableName`("manual");
CALL `fill_dpis_monthAndyear_by_tableName`("manual");
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"manual");
CALL `calculate_depre_monthly_for_a_year`(@year, "manual");
CALL `recalculate_akum_upto`(@year-1, "manual");


CALL `fill_categoryId_byTableName`("intangible_asset");
CALL `fill_dpis_monthAndyear_by_tableName`("intangible_asset");
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"intangible_asset");
CALL `calculate_depre_monthly_for_a_year`(@year, "intangible_asset");
CALL `recalculate_akum_upto`(@year-1, "intangible_asset");


CALL `fill_categoryId_byTableName`("tower_depre");
CALL `fill_dpis_monthAndyear_by_tableName`("tower_depre");
CALL `calculate_depre_from_1996_to_parameterYear`(@year,"tower_depre");

CALL`calculate_depre_from_a_to_b`(2011, @year, "tower_depre");
CALL `calculate_depreTower_from2011_to`(@year, "tower_depre");
CALL `calculate_depre_monthly_for_a_year`(@year, "tower_depre");
CALL `recalculate_akum_upto`(@year-1, "tower_depre");
CALL `get_pivot_by_month_year_source_table`(@month,@year, "FAR2011", "tower_depre");


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

#Create pivot table for each category_id
CALL `get_pivot_all`(@month,@year);
