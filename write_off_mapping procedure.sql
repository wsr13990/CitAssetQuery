DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `write_off_mapping`$$

CREATE PROCEDURE `write_off_mapping`(IN paramMonth INTEGER(2), IN paramYear INTEGER(4))
    MODIFIES SQL DATA
    BEGIN


		SET @wo_date = LAST_DAY(CONCAT(CAST(paramYear AS CHAR(4)),"-", CAST(paramMonth AS CHAR(2)),"-", "1"));
		DROP TABLE IF EXISTS not_written_off;
		DROP TABLE IF EXISTS current_write_off;
		DROP TABLE IF EXISTS inner_join_write_off;
		DROP TABLE IF EXISTS pivot_inner_join_write_off;
		DROP TABLE IF EXISTS mapping_write_off;
		DROP TABLE IF EXISTS control_bulk_2005;
		DROP TABLE IF EXISTS control;
		
		CREATE TEMPORARY TABLE control(`status` VARCHAR(100));
		CREATE TEMPORARY TABLE not_written_off
		(INDEX (asset_number), INDEX(source_detail), INDEX(write_off_date), UNIQUE (asset_id) )
		AS (
			SELECT	`asset_id`,`entry_type`,`bulk_2005_write_off_date`,`write_off_date`,`asset_number`,
				`addition_period`,`source`,`source_detail`,`dpis`,`dpis_month`,`dpis_month_end`,
				`dpis_year`,`dpis_year_end`,`category`,`category_id`,`cost`
			FROM `far_depre`
			WHERE (write_off_date >= @wo_date OR write_off_date IS NULL) AND
			source != "ReverseManual2005" AND source != "WO_Manual2011" AND source != "WO_Manual2012" AND source != "WO_Manual2013" AND source != "WO_Manual2014" AND source != "WO_Manual2016"
		);

		UPDATE not_written_off
		SET cost = 0
		WHERE source_detail = "bulk_2005";

		CREATE TEMPORARY TABLE current_write_off
		(INDEX (asset_number), INDEX(give_up_date),UNIQUE (write_off_id))
		AS (
			SELECT write_off.write_off_id AS asset_id, write_off.* FROM write_off
			WHERE MONTH(give_up_date) = paramMonth AND YEAR(give_up_date) = paramYear
			GROUP BY asset_number);
			
		CREATE TEMPORARY TABLE inner_join_write_off
		(INDEX (asset_number), UNIQUE(asset_id))
		AS (
			SELECT	not_written_off.asset_id AS asset_id,
				not_written_off.asset_number AS asset_number,
				not_written_off.addition_period AS addition_period,
				not_written_off.source AS source,
				not_written_off.source_detail AS source_detail,
				not_written_off.category AS category,
				not_written_off.category_id AS category_id,
				not_written_off.cost AS cost
			FROM not_written_off
			INNER JOIN current_write_off wo ON wo.asset_number = not_written_off.asset_number
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
			FROM not_written_off
		);
		SET @sql = CONCAT(
				'CREATE TEMPORARY TABLE
				pivot_inner_join_write_off
				AS
				SELECT 	asset_number,
					category AS category,
					category_id,',
					@dynamic_sql,
				' FROM inner_join_write_off
				GROUP BY asset_number;'
				);
		PREPARE pivot FROM @sql;
		EXECUTE pivot;
		DEALLOCATE PREPARE pivot;
		
		
		SET @sourceSum = (SELECT GROUP_CONCAT(DISTINCT CONCAT('pivot.',source_detail) SEPARATOR ' + ') FROM not_written_off);
		SET @mapping_write_off = CONCAT(
		'CREATE TABLE mapping_write_off 
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
				pivot.*,
				(', @sourceSum, ') AS total
			FROM current_write_off wo
			LEFT JOIN pivot_inner_join_write_off pivot ON wo.asset_number = pivot.asset_number) temp'
		 ,' ');
		PREPARE mapping FROM @mapping_write_off;
		EXECUTE mapping;
		DEALLOCATE PREPARE mapping;

		UPDATE mapping_write_off
		SET	bulk_2005 = difference
		WHERE difference != 0;

		SET @update_sum = (SELECT GROUP_CONCAT(DISTINCT source_detail SEPARATOR ' + ') FROM not_written_off);
		SET @update_mapping = CONCAT('
		UPDATE mapping_write_off
		SET 	total = (',@update_sum,'),
			difference = cost - total
		WHERE difference != 0;
		');
		PREPARE update_mapping FROM @update_mapping;
		EXECUTE update_mapping;
		DEALLOCATE PREPARE update_mapping;
		
		UPDATE mapping_write_off SET category_id = NULL;
		
		
		#Checking that all write of found on far
		SET @wo_not_found = (SELECT COUNT(category) FROM mapping_write_off WHERE category IS NULL OR category = "");
		IF @wo_not_found = 0 THEN
			INSERT INTO control VALUES("OK : All wo found in far");
		ELSE
			INSERT INTO control VALUES("WARNING : Several wo not found in far");
		END IF;
		
		#Checking that the mapping cost of bulk_2005 is valid and if there any partial write off in 2005
		CREATE TEMPORARY TABLE control_bulk_2005
		AS
		SELECT *, calculated_bulk_2005 - actual_bulk_2005 AS difference
		FROM(
			SELECT wo.asset_number, wo.bulk_2005 AS calculated_bulk_2005, temp.cost AS actual_bulk_2005 FROM mapping_write_off wo
			INNER JOIN(
				SELECT far.* FROM
					(SELECT * FROM far_depre WHERE source_detail = "bulk_2005") far
				INNER JOIN current_write_off
				ON far.asset_number = current_write_off.asset_number) temp
			ON wo.asset_number = temp.asset_number
			GROUP BY wo.asset_number
		) temp;
		SET @partial_wo_control = (SELECT SUM(ABS(difference)) FROM control_bulk_2005);
		IF @partial_wo_control = 0 THEN
			INSERT INTO control VALUES("OK : Bulk 2005 valid & No partial write off");
		ELSE
			INSERT INTO control VALUES("WARNING : Partial write off");
		END IF;
		
		#Print out mapping control
		SELECT * FROM control;

    END$$

DELIMITER ;
	