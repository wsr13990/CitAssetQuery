SET @addition_month = 6;

DROP TABLE far_dpis;

UPDATE far_temp
SET 	dpis_month = MONTH(dpis),
	dpis_year = YEAR(dpis)
WHERE 	dpis_month = 0 OR dpis_month_end = 0 OR
	dpis_year = 0 OR dpis_year_end = 0;

CREATE TEMPORARY TABLE far_dpis
AS
SELECT 	far_temp.asset_id,
	far_temp.dpis,
	far_temp.dpis_month,
	CASE
		WHEN far_temp.dpis_month = 1 THEN 12
		ELSE (far_temp.dpis_month - 1)
	END AS dpis_month_end,
	far_temp.dpis_year,
	CASE
		WHEN far_temp.dpis_month = 1 THEN (far_temp.dpis_year + cat.umur_ekonomis - 1)
		ELSE (far_temp.dpis_year + far_temp.umur_ekonomis)
	END AS dpis_year_end,
	cat.umur_ekonomis AS umur_ekonomis	
FROM far_temp
INNER JOIN asset_category cat
ON far_temp.category_id = cat.category_id
GROUP BY asset_id;

UPDATE far_temp, far_dpis
SET 	far_temp.dpis_month_end = far_dpis.dpis_month_end,
	far_temp.dpis_year_end = far_dpis.dpis_year_end
WHERE far_temp.asset_id = far_dpis.asset_id;

SELECT * FROM far_temp
WHERE MONTH(addition_period) = @addition_month;