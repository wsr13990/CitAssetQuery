SET @limit1 = 850000*1;
SET @limit2 = 850000*2;
SET @limit3 = 850000*3;
SET @limit4 = 850000*4;
SET @limit5 = 850000*5;

SELECT `asset_number`,`category_name`,`dpis`,`cost`,`ytd_deprn`,`deprn_reserve`,`book_type_code`,`desc`,`source`,`period_name`
FROM upload_juli WHERE id <= @limit1;

SELECT `asset_number`,`category_name`,`dpis`,`cost`,`ytd_deprn`,`deprn_reserve`,`book_type_code`,`desc`,`source`,`period_name`
FROM upload_juli WHERE id > @limit1 AND id <= @limit2;

SELECT `asset_number`,`category_name`,`dpis`,`cost`,`ytd_deprn`,`deprn_reserve`,`book_type_code`,`desc`,`source`,`period_name`
FROM upload_juli WHERE id > @limit2 AND id <= @limit3;

SELECT `asset_number`,`category_name`,`dpis`,`cost`,`ytd_deprn`,`deprn_reserve`,`book_type_code`,`desc`,`source`,`period_name`
FROM upload_juli WHERE id > @limit3 AND id <= @limit4;