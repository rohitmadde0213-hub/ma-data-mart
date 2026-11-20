# ma-data-mart
SQL (MySQL) data cleaning, 4-week and 12-week packaging impact analysis around 2020-06-15, and 2-slide Tableau Public dashboard for Danny Ma's Data Mart challenge.
# Data Mart — MySQL & Tableau Analytics

[![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Tableau](https://img.shields.io/badge/Visualization-Tableau-E97627?style=flat-square&logo=tableau&logoColor=white)](https://public.tableau.com/app/profile/rohit.madde/vizzes)
[![Status](https://img.shields.io/badge/Status-Completed-2E7D32?style=flat-square)](#)

> **Case Study Focus:** End-to-end SQL data cleaning, calendar validation, channel/regional/demographic analysis, and pre/post-**`2020-06-15`** sales impact evaluation on **Danny Ma's Data Mart** dataset, paired with interactive **Tableau** dashboards.

---

## Project Overview

Data Mart introduced sustainable packaging across operations around **June 15, 2020**. This project investigates how sales and transaction patterns behaved before and after that rollout—separating true packaging impact from baseline seasonality (2018–2020) and breaking down performance across channels (`Retail` vs. `Shopify`), regions, and customer segments (`Demographic` & `Age Band`).

---

## Repository Structure

```text
data-mart-sql-analysis/
├── README.md
└── sql/
    ├── 01_data_cleaning_and_calendar_checks.sql
    ├── 02_sales_platform_and_demographics.sql
    └── 03_packaging_change_4w_12w_analysis.sql
