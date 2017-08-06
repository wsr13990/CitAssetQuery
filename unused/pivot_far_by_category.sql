SET @pivot_month = 6;
SET @pivot_year = 2017;
SET @pivot_period = "FAR2006";


SET @pivot_date = LAST_DAY(CONCAT(CAST(@pivot_year AS CHAR(4)),"-", CAST(@pivot_month AS CHAR(2)),"-", "1"));
DROP TABLE IF EXISTS pivot_non_tower;
DROP TABLE IF EXISTS pivot_tower;


SELECT category_id, SUM(cost) FROM far
WHERE (write_off_date IS NULL OR write_off_date > @wo_date) AND source = @pivot_period
GROUP BY category_id;