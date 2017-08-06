CALL `fill_dpis_monthAndyear_by_tableName`("far_depre");

CALL `get_pivot_by_month_year_source_table`(5,2017, "FAR2006", "tower_depre");

CALL `recalculate_akum_upto`(2016, "far_depre");

CALL `calculate_depre_from_a_to_b`(1996, 2011, "tower_depre");

SELECT * FROM tower_depre WHERE asset_number = 209342;

SELECT * FROM asset_category WHERE category_id = "CME NW";

SELECT * FROM dpis_rate WHERE category_id = "CME NW";


SELECT * FROM depre_test;