CALL `fill_dpis_monthAndyear_by_tableName`("far_depre");

CALL `write_off_mapping`(6,2017);

CALL `calculate_depre_from_1996_to_parameterYear`(2017,"mapping_write_off");

CALL `calculate_depre_monthly_for_a_year`(2017, "mapping_write_off");

SELECT * FROM mapping_write_off;

CALL `get_pivot_by_month_year_source_table`(5,2017, "FAR2006", "tower_depre");

CALL `recalculate_akum_upto`(2016, "far_depre");

