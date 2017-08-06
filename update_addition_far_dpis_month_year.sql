SET	@addition_month = 6,
	@addition_year = 2017;

DROP TABLE IF EXISTS far_addition;
DROP TABLE IF EXISTS updated_far_addition;

CREATE TEMPORARY TABLE far_addition
AS SELECT * FROM far
WHERE MONTH(addition_period) = @addition_month AND YEAR(addition_period) = @addition_year;

UPDATE far_addition
SET 	dpis_month = MONTH(dpis),
	dpis_year = YEAR(dpis);

CREATE TEMPORARY TABLE updated_far_addition
AS
SELECT 	far_addition.asset_id,
	far_addition.addition_period,
	far_addition.dpis,
	far_addition.dpis_month,
	CASE
		WHEN far_addition.dpis_month = 1 THEN 12
		ELSE (far_addition.dpis_month - 1)
	END AS dpis_month_end,
	far_addition.dpis_year,
	CASE
		WHEN far_addition.dpis_month = 1 THEN (far_addition.dpis_year + cat.umur_ekonomis - 1)
		ELSE (far_addition.dpis_year + cat.umur_ekonomis)
	END AS dpis_year_end,
	far_addition.category,
	cat.category_id,
	cat.umur_ekonomis AS umur_ekonomis	
FROM far_addition
INNER JOIN asset_category cat
ON far_addition.category = cat.category_name
GROUP BY asset_id;

UPDATE far, updated_far_addition
SET 	far.dpis_month = updated_far_addition.dpis_month,
	far.dpis_month_end = updated_far_addition.dpis_month_end,
	far.dpis_year = updated_far_addition.dpis_year,
	far.dpis_year_end = updated_far_addition.dpis_year_end,
	far.category_id = updated_far_addition.category_id
WHERE far.asset_id = updated_far_addition.asset_id;

SELECT * FROM far
WHERE MONTH(addition_period) = @addition_month AND YEAR(addition_period) = @addition_year;