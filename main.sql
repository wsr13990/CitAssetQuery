CALL `fill_dpis_monthAndyear_by_tableName`("far_depre");

CALL `write_off_mapping`(7,2017);

CALL `get_pivot_by_month_year_source_table`(5,2017, "FAR2006", "tower_depre");

CALL `recalculate_akum_upto`(2016, "far_depre");
