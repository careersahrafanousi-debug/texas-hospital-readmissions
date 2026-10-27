.headers on
.mode column
-- Rows per hospital should be 6 (one per condition)
SELECT COUNT(*) rows, COUNT(DISTINCT facility_id) hospitals, COUNT(*)*1.0/COUNT(DISTINCT facility_id) rows_per_hosp FROM readm;
-- Hospitals in HRRP that do not match the hospital info file
SELECT COUNT(DISTINCT facility_id) unmatched FROM readm WHERE city IS NULL;
-- Usable rows (have a ratio and discharge count)
SELECT state='TX' is_tx, COUNT(*) rows, SUM(err IS NOT NULL) has_ratio, SUM(excess_readmissions IS NOT NULL) usable FROM readm GROUP BY 1;
-- Ratio range
SELECT MIN(err), MAX(err) FROM readm;
