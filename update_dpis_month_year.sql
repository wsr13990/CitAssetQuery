DROP TABLE far_dpis;

UPDATE far
SET 	dpis_month = MONTH(dpis),
	dpis_year = YEAR(dpis)
WHERE 	dpis_month = 0 OR dpis_month_end = 0 OR
	dpis_year = 0 OR dpis_year_end = 0;

CREATE TEMPORARY TABLE far_dpis
AS
SELECT 	far.asset_id,
	far.dpis,
	far.dpis_month,
	CASE
		WHEN far.dpis_month = 1 THEN 12
		ELSE (far.dpis_month - 1)
	END AS dpis_month_end,
	far.dpis_year,
	CASE
		WHEN far.dpis_month = 1 THEN (far.dpis_year + cat.umur_ekonomis - 1)
		ELSE (far.dpis_year + cat.umur_ekonomis)
	END AS dpis_year_end,
	cat.umur_ekonomis AS umur_ekonomis	
FROM far
INNER JOIN asset_category cat
ON far.category_id = cat.category_id
GROUP BY asset_id;

UPDATE far, far_dpis
SET 	far.dpis_month_end = far_dpis.dpis_month_end,
	far.dpis_year_end = far_dpis.dpis_year_end
WHERE far.asset_id = far_dpis.asset_id;

SELECT * FROM far
WHERE MONTH(addition_period) = 6;

SELECT DISTINCT source_detail FROM far;

/*display category not mapped on asset category*/ 
SELECT DISTINCT category, category_id FROM far
WHERE dpis_month_end = 0 OR dpis_year_end = 0;