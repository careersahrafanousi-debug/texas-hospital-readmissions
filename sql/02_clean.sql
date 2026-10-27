-- Clean HRRP rows. CMS writes "N/A" and "Too Few to Report" into numeric columns.
DROP TABLE IF EXISTS readm;
CREATE TABLE readm AS
SELECT
    r."Facility ID"   AS facility_id,
    r."Facility Name" AS facility_name,
    r.State           AS state,
    CASE r."Measure Name"
        WHEN 'READM-30-AMI-HRRP'      THEN 'Heart attack'
        WHEN 'READM-30-HF-HRRP'       THEN 'Heart failure'
        WHEN 'READM-30-PN-HRRP'       THEN 'Pneumonia'
        WHEN 'READM-30-COPD-HRRP'     THEN 'COPD'
        WHEN 'READM-30-CABG-HRRP'     THEN 'Bypass surgery'
        WHEN 'READM-30-HIP-KNEE-HRRP' THEN 'Hip/knee replacement'
    END AS condition,
    CASE WHEN r."Number of Discharges" GLOB '[0-9]*' THEN CAST(r."Number of Discharges" AS INTEGER) END AS discharges,
    CASE WHEN r."Number of Readmissions" GLOB '[0-9]*' THEN CAST(r."Number of Readmissions" AS INTEGER) END AS readmissions,
    CAST(NULLIF(r."Excess Readmission Ratio", 'N/A') AS REAL)   AS err,
    CAST(NULLIF(r."Predicted Readmission Rate", 'N/A') AS REAL) AS predicted_rate,
    CAST(NULLIF(r."Expected Readmission Rate", 'N/A') AS REAL)  AS expected_rate,
    h."City/Town" AS city,
    CASE
        WHEN h."Hospital Ownership" LIKE 'Voluntary non-profit%' THEN 'Non-profit'
        WHEN h."Hospital Ownership" = 'Proprietary'              THEN 'For-profit'
        WHEN h."Hospital Ownership" LIKE 'Government%'           THEN 'Government'
        ELSE 'Other'
    END AS ownership_group,
    CASE WHEN h."Hospital overall rating" GLOB '[1-5]' THEN CAST(h."Hospital overall rating" AS INTEGER) END AS star_rating
FROM raw_hrrp r
LEFT JOIN raw_hospital h ON h."Facility ID" = r."Facility ID";

-- Estimated excess readmissions = discharges x (predicted rate - expected rate)
-- Positive = more readmissions than CMS expects for that hospital's patient mix
ALTER TABLE readm ADD COLUMN excess_readmissions REAL;
UPDATE readm
SET excess_readmissions = discharges * (predicted_rate - expected_rate) / 100.0
WHERE discharges IS NOT NULL AND err IS NOT NULL;
