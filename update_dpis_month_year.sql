#This procedure fill the 0 value in dpis_month, dpis_month_end, dpis_year, dpis_year_end
#by taking parameter string name of the table wanted to be filled
DELIMITER $$

USE `cit_asset`$$

DROP PROCEDURE IF EXISTS `fill_dpis_monthAndyear_by_tableName`$$

CREATE PROCEDURE `fill_dpis_monthAndyear_by_tableName`(IN tableName VARCHAR(50))
	MODIFIES SQL DATA
BEGIN
	DROP TABLE IF EXISTS control;
	
	#check whether dpis_month, dpis_month_end, dpis_year, dpis_year_end exist, if not add columns
	SET @count = 	(SELECT COUNT(*) FROM `information_schema`.`COLUMNS`
			WHERE 	`TABLE_SCHEMA` = 'cit_asset' AND
				`TABLE_NAME` = tableName AND
				(`COLUMN_NAME` = 'dpis_month' OR `COLUMN_NAME` = 'dpis_month_end' OR `COLUMN_NAME` = 'dpis_year' OR `COLUMN_NAME` = 'dpis_year_end'));
	IF @count = 0 THEN
		SET @addColumn = CONCAT('alter table ', tableName,' 	add column dpis_month int(2) default 0,
									add column dpis_month_end int(2) default 0,
									add column dpis_year int(4) default 0,
									add column dpis_year_end int(4) default 0');
		PREPARE addColumn FROM @addColumn;
		EXECUTE addColumn;
		DEALLOCATE PREPARE addColumn;
	END IF;
	
	#update the dpis_month, dpis_month_end, dpis_year, dpis_year_end
	DROP TEMPORARY TABLE IF EXISTS far_dpis;
	
	SET @stmt = CONCAT('UPDATE ',tableName,' SET dpis_month = MONTH(dpis), dpis_year = YEAR(dpis) WHERE dpis_month = 0 OR dpis_month_end = 0 OR dpis_year = 0 OR dpis_year_end = 0;');
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	SET @stmt = CONCAT('
		CREATE TEMPORARY TABLE far_dpis
		AS
		SELECT 	',tableName,'.asset_id, ',tableName,'.dpis, ',tableName,'.dpis_month,
			CASE
				WHEN ',tableName,'.dpis_month = 1 THEN 12
				ELSE (',tableName,'.dpis_month - 1)
			END AS dpis_month_end,
			',tableName,'.dpis_year,
			CASE
				WHEN ',tableName,'.dpis_month = 1 THEN (',tableName,'.dpis_year + cat.umur_ekonomis - 1)
				ELSE (',tableName,'.dpis_year + cat.umur_ekonomis)
			END AS dpis_year_end,
			cat.umur_ekonomis AS umur_ekonomis	
		FROM ',tableName,'
		INNER JOIN asset_category cat
		ON ',tableName,'.category_id = cat.category_id
		WHERE 	dpis_month = 0 OR dpis_month_end = 0 OR
			dpis_year = 0 OR dpis_year_end = 0
		GROUP BY asset_id;
	');
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	SET @stmt = CONCAT('
	UPDATE ',tableName,', far_dpis
	SET 	',tableName,'.dpis_month_end = far_dpis.dpis_month_end,
		',tableName,'.dpis_year_end = far_dpis.dpis_year_end
	WHERE ',tableName,'.asset_id = far_dpis.asset_id;
	');
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	#Honestly this is the most ugly code i've ever write(0_0)
	#If there any shortcut to write this part better??
	#This part check if all dpis_month, dpis_month_end, dpis_year, dpis_year_end are successfully filled
	(CREATE TEMPORARY TABLE control(`status` VARCHAR(100));
	SET @dpisMonthNullStatement = CONCAT('set @dpisMonthNull = (select count(dpis_month) from ',tableName,' where dpis_month is null or dpis_month = 0 or dpis_month = "");');
	SET @dpisMonthEndNullStatement = CONCAT('set @dpisMonthEndNull = (select count(dpis_month_end) from ',tableName,' where dpis_month_end is null or dpis_month_end = 0 or dpis_month_end = "");');
	SET @dpisYearNullStatement = CONCAT('set @dpisYearNull = (select count(dpis_year) from ',tableName,' where dpis_year is null or dpis_year = 0 or dpis_year = "");');
	SET @dpisYearEndNullStatement = CONCAT('set @dpisYearEndNull = (select count(dpis_year_end) from ',tableName,' where dpis_year_end is null or dpis_year_end = 0 or dpis_year_end = "");');
	PREPARE dpisMonthNullStatement FROM @dpisMonthNullStatement;
	PREPARE dpisMonthEndNullStatement FROM @dpisMonthEndNullStatement;
	PREPARE dpisYearNullStatement FROM @dpisYearNullStatement;
	PREPARE dpisYearEndNullStatement FROM @dpisYearEndNullStatement;
	EXECUTE dpisMonthNullStatement;
	EXECUTE dpisMonthEndNullStatement;
	EXECUTE dpisYearNullStatement;
	EXECUTE dpisYearEndNullStatement;)
	
	SET @control = @dpisMonthNull+@dpisMonthEndNull+@dpisYearNull+@dpisYearEndNull;
	IF @control = 0 THEN
		INSERT INTO control VALUES("OK : All dpis month year filled");
	ELSE
		INSERT INTO control VALUES("WARNING : Several dpis month year is missing");
	END IF;
	SELECT * FROM control;
	
END$$

DELIMITER ;