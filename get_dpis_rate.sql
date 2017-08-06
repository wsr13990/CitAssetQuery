DELIMITER $$

USE `cit_asset`$$

DROP FUNCTION IF EXISTS `get_dpis_rate`$$

CREATE FUNCTION `get_dpis_rate`(category VARCHAR(30), period INTEGER) RETURNS DECIMAL(15,4)
    READS SQL DATA
BEGIN
      DECLARE rate DECIMAL(15,4);
      SET rate = 0;
      SELECT dpis_rate INTO rate FROM dpis_rate 
      WHERE category_id = category AND period >= period_from AND period <= period_to;
      RETURN rate;
    END$$

DELIMITER ;