DELIMITER $$

USE `cit_asset`$$
DROP PROCEDURE IF EXISTS `get_pivot_all`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_pivot_all`(paramMonth INTEGER(2), paramYear INTEGER(4))
READS SQL DATA
BEGIN
	
	DROP TABLE IF EXISTS prevPivotSL0608;
	DROP TABLE IF EXISTS prevpivotRevManual2005;
	DROP TABLE IF EXISTS prevPivotFar2006;
	DROP TABLE IF EXISTS prevPivotFar2007;
	DROP TABLE IF EXISTS prevPivotFar2008;
	DROP TABLE IF EXISTS prevPivotFar2009;
	DROP TABLE IF EXISTS prevPivotFar2010;
	DROP TABLE IF EXISTS prevPivotFar2011;
	DROP TABLE IF EXISTS prevPivotFar2012;
	DROP TABLE IF EXISTS prevPivotFar2013;
	DROP TABLE IF EXISTS prevPivotFar2014;
	DROP TABLE IF EXISTS prevPivotFar2015;
	DROP TABLE IF EXISTS prevPivotFar2016;
	DROP TABLE IF EXISTS prevPivotFar2017;
	DROP TABLE IF EXISTS prevPivotWoManual;
	
	DROP TABLE IF EXISTS pivotSL0608;
	DROP TABLE IF EXISTS pivotRevManual2005;
	DROP TABLE IF EXISTS pivotFar2006;
	DROP TABLE IF EXISTS pivotFar2007;
	DROP TABLE IF EXISTS pivotFar2008;
	DROP TABLE IF EXISTS pivotFar2009;
	DROP TABLE IF EXISTS pivotFar2010;
	DROP TABLE IF EXISTS pivotFar2011;
	DROP TABLE IF EXISTS pivotFar2012;
	DROP TABLE IF EXISTS pivotFar2013;
	DROP TABLE IF EXISTS pivotFar2014;
	DROP TABLE IF EXISTS pivotFar2015;
	DROP TABLE IF EXISTS pivotFar2016;
	DROP TABLE IF EXISTS pivotFar2017;
	DROP TABLE IF EXISTS pivotWoManual;
	
	
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "SL0608", "prevPivotSL0608");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "ReverseManual2005", "prevpivotRevManual2005");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2006", "prevPivotFar2006");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2007", "prevPivotFar2007");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2008", "prevPivotFar2008");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2009", "prevPivotFar2009");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2010", "prevPivotFar2010");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2011", "prevPivotFar2011");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2012", "prevPivotFar2012");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2013", "prevPivotFar2013");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2014", "prevPivotFar2014");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2015", "prevPivotFar2015");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2016", "prevPivotFar2016");
	CALL `get_pivot_by_month_year_source_table`(paramMonth-1,paramYear, "FAR2017", "prevPivotFar2017");
	CALL `get_pivot_by_month_year_source_detail_table`(paramMonth-1,paramYear, "WO_Manual", "prevPivotWoManual");
	
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "SL0608", "pivotSL0608");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "ReverseManual2005", "pivotRevManual2005");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2006", "pivotFar2006");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2007", "pivotFar2007");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2008", "pivotFar2008");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2009", "pivotFar2009");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2010", "pivotFar2010");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2011", "pivotFar2011");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2012", "pivotFar2012");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2013", "pivotFar2013");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2014", "pivotFar2014");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2015", "pivotFar2015");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2016", "pivotFar2016");
	CALL `get_pivot_by_month_year_source_table`(paramMonth,paramYear, "FAR2017", "pivotFar2017");
	CALL `get_pivot_by_month_year_source_detail_table`(paramMonth,paramYear, "WO_Manual", "pivotWoManual");
END$$

DELIMITER ;
