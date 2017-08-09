CALL `fill_categoryId_byTableName`("manual");
CALL `fill_dpis_monthAndyear_by_tableName`("manual");
CALL `calculate_depre_from_1996_to_parameterYear`(2017,"manual");
CALL `calculate_depre_monthly_for_a_year`(2017, "manual");
CALL `recalculate_akum_upto`(2016, "manual");


CALL `write_off_mapping`(5,2017);
CALL `update_write_off_date`(5,2017);
CALL `fill_categoryId_byTableName`("mapping_write_off");
CALL `fill_dpis_monthAndyear_by_tableName`("mapping_write_off");
CALL `calculate_depre_from_1996_to_parameterYear`(2017,"mapping_write_off");
CALL `recalculate_akum_upto`(2016, "mapping_write_off");
SELECT * FROM mapping_write_off;


CALL `get_pivot_by_month_year_source_table`(5,2017, "FAR2006", "tower_depre");
