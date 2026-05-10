# Spreadsheet Answers

## Q1
### Query
What data quality issues were found in `transactions_raw.csv`, and how was each field standardised?

### Result Summary
Seven fields required cleaning before analysis could begin.

**merchant_name** had inconsistent casing and extra whitespace (e.g. `" alpha mart "`, `"Alpha  Mart"`, `"ALPHA MART"`). Fix: `strip()` → collapse consecutive spaces → `title()` → map to a canonical name list from `merchant_master.csv`.

**status** contained mixed case, trailing spaces, and embedded error codes (e.g. `"Captured "`, `" CAPTURED"`, `"failed E05 timeout"`, `" chargeback "`). Fix: `strip()` → `lower()` → keyword match: any value containing `chargeback` → `"chargeback"`, containing `fail` → `"failed"`, containing `capture` → `"captured"`.

**risk_score** used two different prefix formats (`"score:62"`, `"risk-83"`) and trailing spaces (`"55 "`). Two rows (T011, T002 gateway blank) were fully blank. Fix: regex to strip all non-digit characters → cast to integer; blanks kept as `NaN`.

**gateway_region** had 11 blank rows and mixed casing (`"apac"`, `" APAC "`, `"EU "`, `"us"`). Fix: `strip()` → `upper()`; blank values back-filled from `merchant_master.default_region` via merchant name join.

**transaction_date** was formatted consistently as `YYYY-MM-DD` but had occasional leading/trailing whitespace. Fix: parse with `pd.to_datetime()` → reformat as `YYYY-MM-DD` string.

**currency** had trailing whitespace in some rows. Fix: `strip()`.

**raw_amount** was clean; no issues found.

---

## Q2
### Query
How was `amount_usd` calculated, and what exchange rates were applied?

### Result Summary
Each transaction was converted to USD using a **date-matched rate** from `exchange_rates.csv`. The join key was `(transaction_date, currency)`, so each transaction used the exact spot rate for its settlement date rather than a single average rate.

| Currency | Rate Range Used | Logic |
|----------|----------------|-------|
| INR | 0.0118 – 0.0121 | Varied by date (Mar 1–6) |
| EUR | 1.07 – 1.09 | Varied by date |
| USD | 1.0 | No conversion needed |

Formula applied: `amount_usd = raw_amount × usd_rate` (rounded to 2 decimal places).

Example: T001 — ₹420,000 × 0.0119 (Mar 1 rate) = **$4,998.00 USD**.

---

## Q3
### Query
How were `high_value_flag` and `high_risk_flag` defined and applied?

### Result Summary
Both flags are binary (1 = condition met, 0 = not met), computed after `amount_usd` and `status` were finalised.

**high_value_flag = 1 when:**
- `gateway_region = APAC` and `amount_usd > 5,000`
- `gateway_region = EU` and `amount_usd > 6,000`
- `gateway_region = US` and `amount_usd > 7,000`
- Otherwise `0`

**high_risk_flag = 1 when:**
- `risk_score >= 70` (covers T003, T007, T010, T013–T014, T017–T018, T020)
- OR `status = 'chargeback'` (covers T007, T018, T024, T029)
- Otherwise `0`

Across 30 transactions: **8 triggered high_value_flag**, **9 triggered high_risk_flag**. T007 (Alpha Mart chargeback, risk=83) and T018 (Beta Stores chargeback, risk=86) triggered both.

---

## Q4
### Query
How were blank `gateway_region` values handled?

### Result Summary
11 of 30 transactions had a blank or missing `gateway_region`. These were filled using the `default_region` column from `merchant_master.csv`, joined on the cleaned `merchant_name`.

Since Alpha Mart and Beta Stores both default to `APAC`, all 11 blanks resolved to `APAC`. No rows remained without a region after the join, so no transactions were excluded from flag logic.

---

## Q5
### Query
What does the Merchant Risk Summary reveal about relative merchant risk?

### Result Summary
Computed by grouping `cleaned_transactions.csv` on `merchant_id` / `merchant_name`.

| Merchant | Txns | Total (USD) | Avg Risk | Max Risk | Chargeback Rate | High Risk Rate |
|---|---|---|---|---|---|---|
| Alpha Mart | 11 | $40,812 | 61.2 | 83 | 9.1% | 18.2% |
| Beta Stores | 11 | $41,782 | 69.4 | 86 | 9.1% | **45.5%** |
| City Pharma | 2 | $8,640 | 40.0 | 42 | 0.0% | 0.0% |
| Delta Travels | 4 | $14,600 | 48.8 | 58 | 25.0% | 25.0% |
| Eco Home | 2 | $10,246 | 54.5 | 65 | **50.0%** | **50.0%** |

**Key findings:**
- **Beta Stores** carries the highest operational risk: avg risk score 69.4 (just below the 70 threshold), max score 86, and 45.5% of its transactions flagged as high-risk.
- **Eco Home** has the worst chargeback rate (50%) but only 2 transactions — too small a sample to be conclusive; warrants monitoring.
- **Delta Travels** has a 25% chargeback rate (1 of 4 txns), elevated for a travel merchant.
- **City Pharma** is the cleanest merchant: zero chargebacks, zero high-risk flags, avg risk score 40.

---

## Q6
### Query
Were any transactions missing risk scores, and how were they treated?

### Result Summary
**Two transactions had blank risk scores** after cleaning:
- **T011** (Alpha Mart, Mar 3) — raw value was fully empty
- No others — all remaining blanks were artifacts of prefix strings that resolved to valid integers after cleaning

These two rows were retained in `cleaned_transactions.csv` with `risk_score = NaN`. For flag purposes, `NaN >= 70` evaluates to `False` in pandas, so neither row was erroneously flagged as high-risk. The `high_risk_flag` for T011 = 0 (status was `failed`, not `chargeback`).

In the merchant risk summary, `avg_risk_score` and `max_risk_score` for Alpha Mart are computed excluding NaN values (pandas default), which is the statistically correct approach.

---

## Q7
### Query
What is the distribution of payment methods and statuses across the cleaned dataset?

### Result Summary
**Status distribution (30 transactions):**

| Status | Count | % |
|---|---|---|
| captured | 18 | 60.0% |
| failed | 8 | 26.7% |
| chargeback | 4 | 13.3% |

**Payment method distribution:**

| Method | Count |
|---|---|
| Card | 13 |
| UPI | 10 |
| Wallet | 4 |
| NetBanking | 3 |

Card transactions are the most common (43%) and are also the primary carrier of chargebacks (3 of 4 chargebacks were Card). UPI transactions showed no chargebacks in this dataset.

---

## Q8
### Query
Summarise the overall data pipeline: inputs, transformations, and outputs.

### Result Summary
**Inputs:**
- `transactions_raw.csv` — 30 raw transactions across 5 merchants, 3 currencies
- `exchange_rates.csv` — 19 date-currency rate pairs (Mar 1–6, 2026)
- `merchant_master.csv` — 5 merchant records with category, manager, default region

**Transformations (in order):**
1. Parse and reformat `transaction_date`
2. Normalise `merchant_name` (case + whitespace + canonical map)
3. Classify `status` via keyword matching
4. Extract numeric `risk_score` from prefixed strings
5. Normalise `gateway_region` (case); fill 11 blanks from merchant master
6. Join merchant master fields (`merchant_id`, `account_manager`, `merchant_category`)
7. Join exchange rates on `(date, currency)` → compute `amount_usd`
8. Compute `high_value_flag` and `high_risk_flag` per defined thresholds
9. Aggregate merchant-level risk summary

**Outputs:**
- `01_data/processed/cleaned_transactions.csv` — 30 rows × 16 columns, fully standardised
- `01_data/processed/merchant_risk_summary.csv` — 5 rows × 16 columns, one row per merchant
- `02_spreadsheet/spreadsheet_workbook.xlsx` — 6-tab workbook (Raw, FX Rates, Merchant Master, Cleaned Transactions, Risk Summary, Cleaning Notes)
