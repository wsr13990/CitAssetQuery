SET @wo_month = 6;
SET @wo_year = 2017;


SET @wo_date = LAST_DAY(CONCAT(CAST(@wo_year AS CHAR(4)),"-", CAST(@wo_month AS CHAR(2)),"-", "1"));
DROP TABLE far_not_written_off;
DROP TABLE current_write_off;
DROP TABLE far_inner_join_write_off;
DROP TABLE pivot_far_inner_join_write_off;
DROP TABLE mapping_write_off;
DROP TABLE control_bulk_2005;

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
	SELECT * FROM write_off
	WHERE MONTH(give_up_date) = @wo_month AND YEAR(give_up_date) = @wo_year
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
	SELECT 	wo.write_off_id AS write_off_id,
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


/*Print out current month wo mapping*/
SELECT * FROM mapping_write_off;

/*Checking that the mapping cost of bulk_2005 is valid*/
CREATE TEMPORARY TABLE control_bulk_2005
AS
SELECT *, calculated_bulk_2005 - actual_bulk_2005 AS difference
FROM(
	SELECT wo.asset_number, wo.bulk_2005 AS calculated_bulk_2005, temp.cost AS actual_bulk_2005 FROM mapping_write_off wo
	INNER JOIN(
		SELECT far.* FROM
			(SELECT * FROM far WHERE source_detail = "bulk_2005") far
		INNER JOIN current_write_off
		ON far.asset_number = current_write_off.asset_number) temp
	ON wo.asset_number = temp.asset_number
	GROUP BY wo.asset_number
) temp;
SELECT SUM(ABS(difference)) FROM control_bulk_2005;