CALL calculate_depre(2017);

CALL `get_pivot_by_month_year_source`(6,2017, "FAR2006");

CREATE TABLE depre_test AS SELECT * FROM far_depre WHERE asset_id < 100;

CALL `calculate_by_year_tableName`(2018, "depre_test");

CALL `calculate_depre_from_1996_to_parameterYear`(2018, "depre_test");

CALL `calculate_depre_monthly_for_a_year`(2017, "far_depre");

SELECT * FROM depre_test;

CALL `recalculate_akum_upto`(2016, "far_depre");

SELECT category_id, SUM(cost) FROM far_depre WHERE source = "FAR2006" AND (write_off_date IS NULL OR write_off_date > "2017-06-30") GROUP BY category_id;