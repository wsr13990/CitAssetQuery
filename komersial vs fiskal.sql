SELECT * FROM `far_commercial_upto_2016` WHERE asset_id < 1000;

SELECT DISTINCT `cost_account` , SUM(cost), SUM(`n_2018`), SUM(d_2018), SUM(akum_upto_prev_Year) FROM `far_commercial_upto_2016`
WHERE YEAR(addition_period) <= 2015
GROUP BY `cost_account`;
SELECT DISTINCT `cost_account` , SUM(cost), SUM(`n_2016`), SUM(d_2016), SUM(akum_upto_prev_Year) FROM `far_commercial_upto_2016`
WHERE YEAR(addition_period) <= 2015
GROUP BY `cost_account`;

SELECT DISTINCT `source` , SUM(cost), SUM(`n_2014`),SUM(d_2014),SUM(`n_2015`),SUM(d_2015), SUM(akum_upto_prev_Year)
FROM `uso`
GROUP BY `source`;

SELECT SUM(cost) FROM `far_commercial_upto_2016_compiled`;

CALL `recalculate_akum_upto`(2018, "uso");

SELECT DISTINCT `category` , SUM(cost), SUM(`n_2018`), SUM(d_2018),SUM(`n_2019`),SUM(d_2019), SUM(akum_upto_prev_Year)
FROM `compiled_far_fiscal_upto_2016` WHERE kelompok_aset != "FA Upto 2005 (Bulk)"
GROUP BY `category`;


SELECT DISTINCT `kelompok_aset` , SUM(cost), SUM(`n_2018`), SUM(d_2018),SUM(`n_2019`),SUM(d_2019), SUM(akum_upto_prev_Year)
FROM `compiled_far_fiscal_bulk`
GROUP BY `kelompok_aset`;


CALL `recalculate_akum_upto`(2018, "tower_fiscal_upto_2016_exclude_bulk");

SELECT DISTINCT `source_detail` , SUM(cost), SUM(`n_2018`),SUM(d_2018),SUM(`n_2019`),SUM(d_2019), SUM(akum_upto_prev_Year) FROM `far_commercial_upto_2016`
GROUP BY `source_detail`;

SELECT * FROM reverse_manual2005;
SELECT * FROM `tower_depre`;

CALL `calculate_depre_from_1996_to_parameterYear`(2019, "wo_manual");
CALL `recalculate_akum_upto`(2018, "wo_manual");

CALL `calculate_depre_from_1996_to_parameterYear`(2019,"reverse_manual2005");
CALL `recalculate_akum_upto`(2018, "reverse_manual2005");

CALL `fill_dpis_monthAndyear_by_tableName`("tower_upto2016_sebenarnya");
CALL `calculate_depre_tower_upto`(2018, "tower_upto2016_sebenarnya");
UPDATE `tower_upto2016_sebenarnya` SET tower_year_as_building = 20 -(2010 - dpis_year) WHERE dpis_year < 2011 AND dpis_month > 1;
UPDATE `tower_upto2016_sebenarnya` SET tower_year_as_building = 20 -(2010 - dpis_year)-1 WHERE dpis_year < 2011 AND dpis_month = 1;


SELECT * FROM `tower_upto2016_sebenarnya`;
CALL `recalculate_akum_upto`(2017, "tower_upto2016_sebenarnya");
CALL `calculate_depre_from_a_to_b`(2017, 2018, "`reclass_eti_bulk`");
CALL `recalculate_akum_upto`(2017,'`reclass_eti_bulk`' );

SELECT * FROM ``far_commercial_upto_2016`` WHERE source_detail = "FAR2016";
CALL `calculate_depre_from_a_to_b`(2017,2018,"`far_commercial_upto_2016_copy`");

SELECT DISTINCT `addition_period` , SUM(cost), SUM(`n_2018`) FROM `far_commercial_upto_2016`
GROUP BY `addition_period`;
SELECT `source_detail` , SUM(cost), SUM(`n_2018`) FROM `far_fiscal_upto_2016`
GROUP BY `source_detail`;

UPDATE `comparefiscalvscommercial` SET `cost_difference` = `fiscal_cost`-`commercial_cost`, `d_2018_difference`=`fiscal_d_2018`-`commercial_d_2018`, `n_2018_difference`=`fiscal_n_2018`-`commercial_n_2018`;
DELETE FROM `far_commercial_upto_2016` WHERE YEAR(addition_period) = 2016;

DROP TABLE IF EXISTS sumByFiscal;
CREATE TABLE sumByFiscal
AS SELECT asset_number, SUM(cost), SUM(d_2018),SUM(n_2018) FROM `far_fiscal_upto_2016` GROUP BY asset_number;

DROP TABLE IF EXISTS sumByCommercial;
CREATE TABLE sumByCommercial
AS SELECT asset_number, SUM(cost),SUM(d_2018), SUM(n_2018) FROM `far_commercial_upto_2016` GROUP BY asset_number;

DROP TABLE IF EXISTS compareFiscalVsCommercial;
CREATE TABLE compareFiscalVsCommercial
AS SELECT f.asset_number AS f_AN, c.asset_number AS c_AN, f.cost AS fiscal_cost, c.cost AS commercial_cost, f.cost - c.cost AS cost_difference, f.d_2018 AS fiscal_d_2018, c.d_2018 AS commercial_d_2018, f.d_2018 - c.d_2018 AS d_2018_difference, f.n_2018 AS fiscal_n_2018, c.n_2018 AS commercial_n_2018, f.n_2018 - c.n_2018 AS n_2018_difference
FROM `sumbyfiscal` f
LEFT JOIN `sumbycommercial` c
ON f.asset_number = c.asset_number
UNION
SELECT f.asset_number AS f_AN, c.asset_number AS c_AN, f.cost AS fiscal_cost, c.cost AS commercial_cost, f.cost - c.cost AS cost_difference, f.d_2018 AS fiscal_d_2018, c.d_2018 AS commercial_d_2018, f.d_2018 - c.d_2018 AS d_2018_difference, f.n_2018 AS fiscal_n_2018, c.n_2018 AS commercial_n_2018, f.n_2018 - c.n_2018 AS n_2018_difference
FROM `sumbyfiscal` f
RIGHT JOIN `sumbycommercial` c
ON f.asset_number = c.asset_number;

CREATE TABLE far_addition_2017 AS
SELECT * FROM `far_depre` WHERE source = "FAR2017";

SELECT SUM(fiscal_cost), SUM(commercial_cost),SUM(cost_difference), SUM(`fiscal_d_2018`), SUM(`commercial_d_2018`),SUM(d_2018_difference), SUM(`fiscal_n_2018`), SUM(`commercial_n_2018`),SUM(n_2018_difference) FROM`comparefiscalvscommercial`;



INSERT INTO `far_fiscal_upto_2016`(`entry_type`,`bulk_2005_write_off_date`,`tower_year_as_building`,`write_off_date`,`source`,`asset_number`,`addition_period`,`source_detail`,`dpis`,`dpis_month`,`dpis_month_end`,`dpis_year`,`dpis_year_end`,`category`,`category_id`,`cost_account`,`cost`,`akum_upto_prev_Year`,`d_1996`,`n_1996`,`d_1997`,`n_1997`,`d_1998`,`n_1998`,`d_1999`,`n_1999`,`d_2000`,`n_2000`,`d_2001`,`n_2001`,`d_2002`,`n_2002`,`d_2003`,`n_2003`,`d_2004`,`n_2004`,`d_2005`,`n_2005`,`d_2006`,`n_2006`,`d_2007`,`n_2007`,`d_2008`,`n_2008`,`d_2009`,`n_2009`,`d_2010`,`n_2010`,`d_2011`,`n_2011`,`d_2012`,`n_2012`,`d_2013`,`n_2013`,`d_2014`,`n_2014`,`d_2015`,`n_2015`,`d_2016`,`n_2016`,`d_2017`,`n_2017`,`d_2018`,`n_2018`)
SELECT `entry_type`,`bulk_2005_write_off_date`,`tower_year_as_building`,`write_off_date`,`source`,`asset_number`,`addition_period`,`source_detail`,`dpis`,`dpis_month`,`dpis_month_end`,`dpis_year`,`dpis_year_end`,`category`,`category_id`,`cost_account`,`cost`,`akum_upto_prev_Year`,`d_1996`,`n_1996`,`d_1997`,`n_1997`,`d_1998`,`n_1998`,`d_1999`,`n_1999`,`d_2000`,`n_2000`,`d_2001`,`n_2001`,`d_2002`,`n_2002`,`d_2003`,`n_2003`,`d_2004`,`n_2004`,`d_2005`,`n_2005`,`d_2006`,`n_2006`,`d_2007`,`n_2007`,`d_2008`,`n_2008`,`d_2009`,`n_2009`,`d_2010`,`n_2010`,`d_2011`,`n_2011`,`d_2012`,`n_2012`,`d_2013`,`n_2013`,`d_2014`,`n_2014`,`d_2015`,`n_2015`,`d_2016`,`n_2016`,`d_2017`,`n_2017`,`d_2018`,`n_2018`
FROM `wo_manual`;

SELECT COUNT(asset_id) FROM `far_fiscal_upto_2016` WHERE source_detail != "bulk_2005";
SELECT COUNT(asset_id) FROM `far_commercial_upto_2016` WHERE source_detail != "bulk_2005";

SELECT SUM(cost) FROM `far_fiscal_upto_2016` WHERE source_detail != "bulk_2005";
SELECT SUM(cost) FROM `far_commercial_upto_2016` WHERE source_detail != "bulk_2005";

SELECT * FROM `far_commercial_upto_2016` WHERE asset_id <= 1000;