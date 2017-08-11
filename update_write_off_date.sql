DELIMITER $$

USE`cit_asset`$$

DROP PROCEDURE IF EXISTS update_write_off_date$$

CREATE PROCEDURE `update_write_off_date`(IN paramMonth INT(2), IN paramYear INT(4))
	MODIFIES SQL DATA
BEGIN
	DROP TABLE IF EXISTS control;
	CREATE TEMPORARY TABLE control(`status` VARCHAR(100));
	#Check if wo allocated to bulk 2005 already updated
	SET @wo_date = LAST_DAY(CONCAT(CAST(paramYear AS CHAR(4)),"-", CAST(paramMonth AS CHAR(2)),"-", "1"));
	SET @updated_current_wo_2005 = (SELECT COUNT(`bulk_2005_write_off_date`)
					FROM far_depre WHERE `bulk_2005_write_off_date` = @wo_date);
	IF @updated_current_wo_2005 = 0 THEN
		#update the table
		DROP TABLE IF EXISTS bulk_2005_wo_update;
		CREATE TEMPORARY TABLE bulk_2005_wo_update
		AS(
			SELECT 	"write off" AS entry_type,
				CAST(@wo_date AS DATE) AS bulk_2005_write_off_date,
				far_depre.asset_number,
				far_depre.addition_period,
				far_depre.source,
				far_depre.source_detail,
				far_depre.dpis,
				far_depre.dpis_month,
				far_depre.dpis_month_end,
				far_depre.dpis_year,
				far_depre.dpis_year_end,
				far_depre.category,
				far_depre.category_id,
				-temp.bulk_2005 AS cost
			FROM (SELECT * FROM far_depre WHERE source_detail = "bulk_2005") far_depre
			INNER JOIN (SELECT asset_number, bulk_2005 FROM mapping_write_off WHERE bulk_2005 != 0) temp
			ON far_depre.asset_number = temp.asset_number
			GROUP BY far_depre.asset_number
		);
		INSERT INTO far_depre (entry_type,
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
		INSERT INTO control VALUES("OK : Bulk 2005 wo updated");
	ELSE
		INSERT INTO control VALUES("WARNING : Bulk 2005 wo already updated before");
	END IF;
	
	
	#Check if the wo cost and the cost of far_depre written off is same
	SET @wo_cost_vs_far_depre_cost = 	(SELECT temp.far_depre_cost - temp.wo_cost AS difference FROM
						(SELECT SUM(not_written_off.cost) AS far_depre_cost,
							SUM(inner_join_write_off.cost) AS wo_cost
							FROM not_written_off,inner_join_write_off
						WHERE write_off_date IS NULL AND not_written_off.asset_id = inner_join_write_off.asset_id) temp
					);		
	#Check if current wo other than bulk 2005 already updated
	SET @wo_date = LAST_DAY(CONCAT(CAST(paramYear AS CHAR(4)),"-", CAST(paramMonth AS CHAR(2)),"-", "1"));
	SET @updated_current_wo = (SELECT COUNT(`write_off_date`) FROM far_depre WHERE `write_off_date` = @wo_date);
	
	#Update wo date for the far_depre other than bulk 2005	
	IF (@updated_current_wo = 0 AND @wo_cost_vs_far_depre_cost = 0)THEN		
		UPDATE far_depre, (SELECT * FROM far_depre_inner_join_write_off WHERE source_detail != "bulk_2005") inner_join
		SET far_depre.write_off_date = @wo_date
		WHERE far_depre.write_off_date IS NULL AND far_depre.asset_id = inner_join.asset_id;
		INSERT INTO control VALUES("OK : wo other than bulk 2005 updated");
	ELSE
		INSERT INTO control VALUES("WARNING : wo other than bulk 2005 already updated before");
	END IF;
	
	SELECT * FROM control;
END$$

DELIMITER ;