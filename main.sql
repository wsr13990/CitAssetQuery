CALL `fill_categoryId_byTableName`("manual");
CALL `fill_dpis_monthAndyear_by_tableName`("manual");
CALL `calculate_depre_from_1996_to_parameterYear`(2017,"manual");
CALL `calculate_depre_monthly_for_a_year`(2017, "manual");
CALL `recalculate_akum_upto`(2016, "manual");


CALL `fill_categoryId_byTableName`("intangible_asset");
CALL `fill_dpis_monthAndyear_by_tableName`("intangible_asset");
CALL `calculate_depre_from_1996_to_parameterYear`(2017,"intangible_asset");
CALL `calculate_depre_monthly_for_a_year`(2017, "intangible_asset");
CALL `recalculate_akum_upto`(2016, "intangible_asset");


CALL `fill_categoryId_byTableName`("tower_depre");
CALL `fill_dpis_monthAndyear_by_tableName`("tower_depre");
CALL `calculate_depre_from_1996_to_parameterYear`(2017,"tower_depre");

CALL`calculate_depre_from_a_to_b`(2011, 2017, "tower_depre");
CALL `calculate_depreTower_from2011_to`(2017, "tower_depre");
CALL `calculate_depre_monthly_for_a_year`(2017, "tower_depre");
CALL `recalculate_akum_upto`(2016, "tower_depre");
CALL `get_pivot_by_month_year_source_table`(5,2017, "FAR2011", "tower_depre");


CALL `write_off_mapping`(5,2017);
SELECT * FROM control_bulk_2005;
SELECT * FROM mapping_write_off;
CALL `update_write_off_date`(5,2017);
CALL `fill_categoryId_byTableName`("mapping_write_off");
CALL `fill_dpis_monthAndyear_by_tableName`("mapping_write_off");
CALL `calculate_depre_from_1996_to_parameterYear`(2017,"mapping_write_off");
CALL `calculate_depre_by_month_year_tableName`(4,2017,"mapping_write_off");
CALL `update_depre_nbv_wo_by_month_year`(4,2017);
CALL `recalculate_akum_upto`(2016, "mapping_write_off");
CALL `insert_table_from_to`("mapping_write_off", "write_off_depre");


CALL `get_pivot_by_month_year_source_table`(5,2017, "FAR2011", "tower_depre");
CALL `drop_dm_nm_for_year`(2017, "tower_depre");
