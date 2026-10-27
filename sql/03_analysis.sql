-- Texas hospital readmissions, CMS FY2026 Hospital Readmissions Reduction Program
-- (performance period July 2021 - June 2024)
-- Excess Readmission Ratio (ERR) > 1.0 means more 30-day readmissions than expected.
.headers on
.mode column

-- Q1. Share of hospital-condition results worse than expected: Texas vs rest of US
SELECT CASE WHEN state = 'TX' THEN 'Texas' ELSE 'Rest of US' END AS region,
       COUNT(*)                                    AS scored_results,
       SUM(err > 1)                                AS worse_than_expected,
       ROUND(100.0 * SUM(err > 1) / COUNT(*), 1)   AS pct_worse
FROM readm WHERE err IS NOT NULL
GROUP BY 1;

-- Q2. Which condition drives Texas excess readmissions?
SELECT condition,
       COUNT(*)                                   AS tx_hospitals_scored,
       SUM(err > 1)                               AS worse_than_expected,
       ROUND(100.0 * SUM(err > 1) / COUNT(*), 1)  AS pct_worse,
       ROUND(SUM(CASE WHEN excess_readmissions > 0 THEN excess_readmissions END)) AS excess_readmits_at_worse_hospitals
FROM readm
WHERE state = 'TX' AND err IS NOT NULL
GROUP BY condition
ORDER BY excess_readmits_at_worse_hospitals DESC;

-- Q3. Hospital level: how many conditions is each Texas hospital worse than expected on?
DROP TABLE IF EXISTS tx_hospital_summary;
CREATE TABLE tx_hospital_summary AS
SELECT facility_id, facility_name, city, ownership_group, star_rating,
       COUNT(err)                                  AS conditions_scored,
       SUM(err > 1)                                AS conditions_worse,
       ROUND(AVG(err), 4)                          AS avg_err,
       ROUND(MAX(err), 4)                          AS worst_err,
       ROUND(SUM(CASE WHEN excess_readmissions > 0 THEN excess_readmissions ELSE 0 END), 1) AS excess_readmits
FROM readm
WHERE state = 'TX'
GROUP BY facility_id
HAVING COUNT(err) > 0;

SELECT conditions_worse, COUNT(*) AS hospitals,
       ROUND(SUM(excess_readmits)) AS excess_readmits
FROM tx_hospital_summary
GROUP BY conditions_worse ORDER BY conditions_worse;

-- Q4. Concentration: what share of Texas excess readmissions comes from the top 20 hospitals?
WITH ranked AS (
    SELECT excess_readmits,
           ROW_NUMBER() OVER (ORDER BY excess_readmits DESC) AS rnk,
           SUM(excess_readmits) OVER ()                      AS total
    FROM tx_hospital_summary
)
SELECT SUM(CASE WHEN rnk <= 20 THEN excess_readmits END) AS top20_excess,
       MAX(total)                                       AS total_excess,
       ROUND(100.0 * SUM(CASE WHEN rnk <= 20 THEN excess_readmits END) / MAX(total), 1) AS top20_share_pct,
       (SELECT COUNT(*) FROM tx_hospital_summary WHERE excess_readmits > 0) AS hospitals_with_excess
FROM ranked;

-- Q5. By ownership (Texas)
SELECT ownership_group,
       COUNT(*)                                   AS hospitals,
       ROUND(AVG(avg_err), 3)                     AS avg_err,
       ROUND(100.0 * SUM(conditions_worse) / SUM(conditions_scored), 1) AS pct_results_worse
FROM tx_hospital_summary
GROUP BY ownership_group ORDER BY avg_err DESC;

-- Q6. Star rating vs readmission performance (Texas)
SELECT star_rating, COUNT(*) AS hospitals, ROUND(AVG(avg_err), 3) AS avg_err,
       ROUND(100.0 * SUM(conditions_worse) / SUM(conditions_scored), 1) AS pct_results_worse
FROM tx_hospital_summary WHERE star_rating IS NOT NULL
GROUP BY star_rating ORDER BY star_rating;

-- Q7. Priority list: Texas hospitals with the most excess readmissions
SELECT facility_name, city, conditions_scored, conditions_worse, avg_err, excess_readmits
FROM tx_hospital_summary
ORDER BY excess_readmits DESC
LIMIT 10;
