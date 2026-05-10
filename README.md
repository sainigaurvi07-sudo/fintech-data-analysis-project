<repo-root>/
├── README.md
# Fintech Data Analysis Project

## Student Information

- **Student Name:** Gaurvi Saini  
- **Student ID:** bitsom_ftai_2601005  

---

## Public GitHub Repository

GitHub Repository Link:  
[fintech-data-analysis-project](https://github.com/sainigaurvi07-sudo/fintech-data-analysis-project?utm_source=chatgpt.com)

---

## Project Overview

This project focuses on fintech transaction data analysis and includes:

- Data cleaning and preprocessing
- Spreadsheet-based analysis
- SQL business analysis
- Python reconciliation workflow
- JSON normalization
- Dashboard creation using Looker Studio

---

## Folder Structure

```bash
├── README.md
├── 01_data/
├── 02_spreadsheet/
├── 03_sql/
├── 04_python/
└── 05_visualization/
```

---

## Tools Used

- VS Code
- CSV Files
- MySQL
- Google Sheets
- Looker Studio
- Python
- Jupyter Notebook

---

## Short Run Instructions

1. Open the project folder in VS Code.
2. Run the SQL queries from `03_sql/analysis_queries.sql` using MySQL.
3. Open `04_python/fintech_pipeline.ipynb` in Jupyter Notebook or VS Code.
4. Execute all notebook cells to generate processed outputs.
5. Use the generated CSV files from `01_data/processed/`.
6. Import processed files into Google Sheets if needed.
7. Connect the sheets/files to Looker Studio for dashboard visualization.

---

## Key Features

- Transaction data cleaning
- Merchant performance analysis
- Payment reconciliation workflow
- API JSON normalization
- Business KPI dashboard

---
├── 01_data/
│   ├── raw/
│   │   ├── transactions_raw.csv 
│   │   ├── merchant_master.csv
│   │   ├── users.csv
│   │   ├── ledger.csv
│   │   ├── gateway.csv
│   │   ├── exchange_rates.csv
│   │   └── api_response_sample.json
│   └── processed/
│       ├── cleaned_transactions.csv
│       ├── merchant_risk_summary.csv
│       ├── missing_in_gateway.csv
│       ├── missing_in_ledger.csv
│       ├── amount_mismatches.csv
│       ├── status_mismatches.csv
│       ├── reconciliation_report.csv
│       ├── api_normalized.csv
│       ├── daily_summary.csv
│       ├── payment_method_breakdown.csv
│       ├── region_breakdown.csv
│       └── merchant_performance_summary.csv
├── 02_spreadsheet/
│   ├── spreadsheet_workbook.xlsx
│   └── spreadsheet_answers.md
├── 03_sql/
│   ├── analysis_queries.sql
│   └── sql_answers.md
├── 04_python/
│   ├── fintech_pipeline.ipynb
│   └── summary_metrics.json
└── 05_visualization/
    └── dashboard_link.txt





