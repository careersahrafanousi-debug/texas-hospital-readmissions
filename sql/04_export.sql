-- Export tables for Tableau
.headers on
.mode csv
.output output/readmissions_by_condition.csv
SELECT facility_id, facility_name, city, state,
       CASE WHEN state = 'TX' THEN 'Texas' ELSE 'Rest of US' END AS region,
       ownership_group, star_rating, condition, discharges, readmissions,
       err, predicted_rate, expected_rate, ROUND(excess_readmissions, 2) AS excess_readmissions,
       CASE WHEN err > 1 THEN 'Worse than expected' WHEN err IS NOT NULL THEN 'Better or as expected' END AS result
FROM readm WHERE err IS NOT NULL;
.output output/tx_hospital_summary.csv
SELECT * FROM tx_hospital_summary ORDER BY excess_readmits DESC;
.output stdout
