SELECT source_detail, SUM(cost), SUM(`ytd_deprn`), SUM(`deprn_reserve`) FROM `upload_asset_0717`
WHERE `asset_number` NOT IN (
SELECT `asset_number` FROM `claim_proceed_0717` WHERE MONTH(`period_wo`)=7
)
GROUP BY `source_detail`;

SELECT SUM(`Cost`),SUM(`deprn_amount`),SUM(`deprn_reserve`),SUM(`Ar_claim`),SUM(`proceed`) FROM `upload_wo_fiscal_0717`;

SELECT * FROM `upload_wo_fiscal_0717`;