DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `write_off_mapping`$$

CREATE PROCEDURE `write_off_mapping`(IN paramMonth INTEGER(2), IN paramYear INTEGER(4))
    MODIFIES SQL DATA
    BEGIN
		SET paramMonth = 6;
		SET paramYear = 2017;

		SET @wo_date = LAST_DAY(CONCAT(CAST(paramYear AS CHAR(4)),"-", CAST(paramMonth AS CHAR(2)),"-", "1"));
		DROP TABLE IF EXISTS far_not_written_off;
		DROP TABLE IF EXISTS current_write_off;
		DROP TABLE IF EXISTS far_inner_join_write_off;
		DROP TABLE IF EXISTS pivot_far_inner_join_write_off;
		DROP TABLE IF EXISTS mapping_write_off;
		DROP TABLE IF EXISTS control_bulk_2005;

		CREATE
		TEMPORARY TABLE far_not_written_off
		(INDEX (asset_number), UNIQUE (asset_id))
		AS (
			SELECT * FROM far
			WHERE	(write_off_date >= @wo_date OR write_off_date IS NULL)
		);

		UPDATE far_not_written_off
		SET cost = 0
		WHERE source_detail = "bulk_2005";

		CREATE
		TEMPORARY TABLE current_write_off
		(INDEX (asset_number), UNIQUE (write_off_id))
		AS (
			SELECT write_off.write_off_id AS asset_id, write_off.* FROM write_off
			WHERE MONTH(give_up_date) = paramMonth AND YEAR(give_up_date) = paramYear
			GROUP BY asset_number);
			
		CREATE TEMPORARY TABLE far_inner_join_write_off
		(INDEX (asset_number), UNIQUE(asset_id))
		AS (
			SELECT	far.asset_id AS asset_id,
				far.asset_number AS asset_number,
				far.addition_period AS addition_period,
				far.source AS source,
				far.source_detail AS source_detail,
				far.category AS category,
				far.category_id AS category_id,
				far.cost AS cost
			FROM far_not_written_off far
			INNER JOIN current_write_off wo ON wo.asset_number = far.asset_number
		);
		

		SET @dynamic_sql = (
			SELECT
				GROUP_CONCAT(DISTINCT
					CONCAT(
						'sum( if (source_detail = '
						,'"'
						, source_detail
						,'"'
						,' , cost,0) ) AS '
						, source_detail,
						' '
					))
			FROM far_not_written_off
		);
		SET @sql = CONCAT(
				'CREATE TEMPORARY TABLE
				pivot_far_inner_join_write_off
				AS
				SELECT 	asset_number,
					category AS fiscal_category,
					category_id,',
					@dynamic_sql,
				'FROM far_inner_join_write_off
				GROUP BY asset_number'
				);
		PREPARE pivot FROM @sql;
		EXECUTE pivot;
		DEALLOCATE PREPARE pivot;
		
		
		SET @sourceSum = (SELECT GROUP_CONCAT(DISTINCT CONCAT('far.',source_detail) SEPARATOR ' + ') FROM far_not_written_off);
		SET @mapping_write_off = CONCAT(
		'CREATE TEMPORARY TABLE mapping_write_off 
		AS
			SELECT temp.*, temp.COST - temp.TOTAL AS difference FROM (	
			SELECT 	wo.write_off_id AS asset_id,
				wo.site_id AS site_id,
				wo.batch AS batch,
				wo.give_up_date AS give_up_date,
				wo.dpis AS dpis,
				wo.commercial_category AS commercial_category,
				wo.cost AS cost,
				wo.asset_number AS asset_number_wo,
				far.*,
				(', @sourceSum, ') AS total
			FROM current_write_off wo
			LEFT JOIN pivot_far_inner_join_write_off far ON wo.asset_number = far.asset_number) temp'
		 ,' ');
		PREPARE mapping FROM @mapping_write_off;
		EXECUTE mapping;
		DEALLOCATE PREPARE mapping;

		UPDATE mapping_write_off
		SET	bulk_2005 = difference
		WHERE difference != 0;

		SET @update_sum = (SELECT GROUP_CONCAT(DISTINCT source_detail SEPARATOR ' + ') FROM far_not_written_off);
		SET @update_mapping = CONCAT('
		UPDATE mapping_write_off
		SET 	total = (',@update_sum,'),
			difference = cost - total
		WHERE difference != 0;
		');
		PREPARE update_mapping FROM @update_mapping;
		EXECUTE update_mapping;
		DEALLOCATE PREPARE update_mapping;
		
		CALL `fill_dpis_monthAndyear_by_tableName`("mapping_write_off");
		
		/*Print out current month wo mapping*/
		SELECT * FROM mapping_write_off;

    END$$

DELIMITER ;