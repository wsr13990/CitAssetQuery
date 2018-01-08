DELIMITER $$

USE `cit_asset`$$

DROP FUNCTION IF EXISTS `get_kelompok_aset`$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_kelompok_aset`(category_id VARCHAR(30)) RETURNS VARCHAR(10)
    READS SQL DATA
BEGIN
      DECLARE result VARCHAR(10);
      SET result = NULL;
      SELECT kelompok_aset INTO result FROM(
      SELECT kelompok_aset FROM kelompok_aset 
      WHERE category_id = category_id LIMIT 1)temp;
      RETURN result;
    END$$

DELIMITER ;