# Tableau dashboard

Data source: `output/readmissions_by_condition.csv` and `output/tx_hospital_summary.csv`

**Sheets**
1. **Excess by condition** - Filter Region = Texas and Excess Readmissions > 0. Rows: `Condition`. Columns: `SUM(Excess Readmissions)`. Sort descending.
2. **Hospital priority list** - Summary file. Rows: `Facility Name`. Columns: `Excess Readmits`. Color: `Conditions Worse`. Top 20 filter.
3. **Heat map** - Rows: `Facility Name` (top 20). Columns: `Condition`. Color: `AVG(Err)` diverging, center 1.0.
4. **Star rating** - Columns: `Star Rating`. Rows: % worse = `SUM(IF [Result] = "Worse than expected" THEN 1 ELSE 0 END) / COUNT([Result])`.

**Dashboard:** KPI tiles (678 excess readmissions, 74% pneumonia + heart failure, 80 hospitals worse on 3+ conditions), then sheets 1 and 2, with 3 below. Filter: Ownership Group, City.

Published version: _add your Tableau Public link here_
