SET @wo_month = 5;

CREATE
TEMPORARY TABLE far_not_written_off
(INDEX (asset_number), UNIQUE (asset_id))
AS (
	SELECT * FROM far
	WHERE write_off_date IS NULL
);

CREATE
TEMPORARY TABLE current_write_off
(INDEX (asset_number), UNIQUE (write_off_id))
AS (
	SELECT * FROM write_off
	WHERE MONTH(give_up_date) = @wo_month
	GROUP BY asset_number);

CREATE TEMPORARY TABLE far_inner_join_write_off
(INDEX (asset_number), UNIQUE(asset_id))
AS (
	SELECT	far.asset_id AS asset_id,
		far.asset_number AS asset_number,
		far.addition_period AS addition_period,
		far.source AS source,
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
				'sum( if (source = '
				,'"'
				, source
				,'"'
				,' , cost,0) ) AS '
				, source,
				' '
			))
	FROM far_not_written_off
);
SET @pivot_table_name = "pivot_far_inner_join_write_off";
SET @sql = CONCAT(
		'CREATE TEMPORARY TABLE ',
		@pivot_table_name,
		' AS ',
		'SELECT asset_number, ',
		@dynamic_sql,
		'FROM far_inner_join_write_off
		GROUP BY asset_number'
		);
PREPARE pivot FROM @sql;
EXECUTE pivot;
DEALLOCATE PREPARE pivot;


SET @sourceSum = (SELECT GROUP_CONCAT( DISTINCT CONCAT('far.',source) SEPARATOR ' + ') FROM far_not_written_off);
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
		far.*,
		(', @sourceSum, ') AS total
	FROM current_write_off wo
	LEFT JOIN pivot_far_inner_join_write_off far ON wo.asset_number = far.asset_number) temp'
 ,' ');
 
PREPARE mapping FROM @mapping_write_off;
EXECUTE mapping;
DEALLOCATE PREPARE mapping;

SELECT @mapping_write_off;
DROP TABLE mapping_write_off;
SELECT * FROM mapping_write_off;


SHOW INDEX FROM far_inner_join_write_off;
SHOW STATUS LIKE '%tmp%';
SELECT * FROM pivot_far_inner_join_write_off;	