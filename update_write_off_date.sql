SELECT far.*
FROM (SELECT * FROM far WHERE source_detail = "bulk_2005") far
INNER JOIN (SELECT asset_number, bulk_2005 FROM mapping_write_off WHERE bulk_2005 != 0) temp
ON far.asset_number = temp.asset_number
GROUP BY far.asset_number;



SELECT * FROM mapping_write_off WHERE bulk_2005 != 0;

SELECT *, temp.far_cost - temp.wo_cost AS difference
FROM
	(SELECT SUM(far.cost) AS far_cost,
		SUM(far_inner_join_write_off.cost) AS wo_cost
		FROM far,far_inner_join_write_off
	WHERE write_off_date IS NULL AND far.asset_id = far_inner_join_write_off.asset_id) temp;

UPDATE far, far_inner_join_write_off
SET write_off_date = @wo_date
WHERE write_off_date IS NULL AND far.asset_id = far_inner_join_write_off.asset_id;

