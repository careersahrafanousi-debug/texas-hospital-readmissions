-- sqlite3 readmissions.db < sql/01_load.sql
.mode csv
DROP TABLE IF EXISTS raw_hrrp;
DROP TABLE IF EXISTS raw_hospital;
.import data/cms_hrrp_fy2026.csv raw_hrrp
.import data/cms_hospital_info.csv raw_hospital
