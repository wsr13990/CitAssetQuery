DELIMITER $$

USE`cit_asset`$$

DROP PROCEDURE IF EXISTS update_write_off_date$$

CREATE PROCEDURE update_write_off_date()
MODIFIES SQL DATA
BEGIN$$
	DROP TABLE IF EXISTS bulk_2005_wo_update;
	CREATE TEMPORARY TABLE bulk_2005_wo_update
	AS(
		SELECT 	"write off " AS entry_type,
			CAST(@wo_date AS DATE) AS bulk_2005_write_off_date,
			far.asset_number,
			far.addition_period,
			far.source,
			far.source_detail,
			far.dpis,
			far.dpis_month,
			far.dpis_month_end,
			far.dpis_year,
			far.dpis_year_end,
			far.category,
			far.category_id,
			-temp.bulk_2005 AS cost
		FROM (SELECT * FROM far WHERE source_detail = "bulk_2005") far
		INNER JOIN (SELECT asset_number, bulk_2005 FROM mapping_write_off WHERE bulk_2005 != 0) temp
		ON far.asset_number = temp.asset_number
		GROUP BY far.asset_number
	);

	#TODO: 	add if statement to check if it already updated before	
	INSERT INTO far 	(entry_type,
				bulk_2005_write_off_date,
				asset_number,
				addition_period,
				source,
				source_detail,
				dpis,
				dpis_month,
				dpis_month_end,
				dpis_year,
				dpis_year_end,
				category,
				category_id,
				cost)
	SELECT * FROM bulk_2005_wo_update;

	SELECT *, temp.far_cost - temp.wo_cost AS difference
	FROM
		(SELECT SUM(far_not_written_off.cost) AS far_cost,
			SUM(far_inner_join_write_off.cost) AS wo_cost
			FROM far_not_written_off,far_inner_join_write_off
		WHERE write_off_date IS NULL AND far_not_written_off.asset_id = far_inner_join_write_off.asset_id) temp;

	UPDATE far, (SELECT * FROM far_inner_join_write_off WHERE source_detail != "bulk_2005") inner_join
	SET far.write_off_date = @wo_date
	WHERE far.write_off_date IS NULL AND far.asset_id = inner_join.asset_id;
END$$