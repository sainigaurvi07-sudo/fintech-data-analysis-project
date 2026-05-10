# SQL Answers

## Q1
### Query
Count transactions by status — how many transactions fall into each outcome category, and what share of total volume does each represent?

### Result Summary
| status | transaction_count | pct_of_total |
|---|---|---|
| captured | 19 | 63.3% |
| failed | 7 | 23.3% |
| chargeback | 4 | 13.3% |

**30 transactions total.** Nearly two-thirds completed successfully. The combined failure rate (failed + chargeback) of 36.7% is high for a payments dataset and warrants investigation — particularly the 13.3% chargeback rate, which far exceeds the typical industry threshold of 1%.

---

## Q2
### Query
Calculate total captured GMV by merchant — how much revenue (in USD) did each merchant successfully collect?

### Result Summary
| merchant_name | captured_gmv_usd | captured_txn_count |
|---|---|---|
| Beta Stores | $33,431.00 | 6 |
| Alpha Mart | $29,984.50 | 8 |
| Delta Travels | $10,300.00 | 2 |
| City Pharma | $8,640.00 | 2 |
| Eco Home | $0.00 | 0 |

**Eco Home generated zero captured GMV** — both its transactions ended in chargeback or failure. Beta Stores leads in captured revenue despite a high risk profile, largely driven by T010 ($7,381 at risk_score 77). City Pharma and Delta Travels are low volume but clean performers.

---

## Q3
### Query
Show top 10 merchants by captured GMV — ranked leaderboard of merchants by successfully collected revenue.

### Result Summary
Only 4 of 5 merchants produced captured transactions. Full ranked list:

| Rank | merchant_name | category | account_manager | captured_gmv_usd | captured_txns | avg_txn_usd |
|---|---|---|---|---|---|---|
| 1 | Beta Stores | Electronics | Rohan Mehta | $33,431.00 | 6 | $5,571.83 |
| 2 | Alpha Mart | Grocery | Aisha Khan | $29,984.50 | 8 | $3,748.06 |
| 3 | Delta Travels | Travel | Marcus Lee | $10,300.00 | 2 | $5,150.00 |
| 4 | City Pharma | Healthcare | Elena Rossi | $8,640.00 | 2 | $4,320.00 |
| 5 | Eco Home | Home | Nina Weber | $0.00 | 0 | — |

Beta Stores has the highest average transaction value among high-volume merchants ($5,571), reflecting its Electronics category. The dataset has fewer than 10 merchants, so the `LIMIT 10` returns all 5.

---

## Q4
### Query
Show daily GMV and successful transaction count — how did volume and conversion trend across the 6-day window?

### Result Summary
| date | total_gmv_usd | captured_gmv_usd | successful_txns | total_txns |
|---|---|---|---|---|
| 2026-03-01 | $26,382.00 | $26,382.00 | 5 | 5 |
| 2026-03-02 | $25,049.00 | $19,049.00 | 3 | 5 |
| 2026-03-03 | $18,391.00 | $13,766.50 | 4 | 5 |
| 2026-03-04 | $16,420.00 | $13,420.00 | 4 | 5 |
| 2026-03-05 | $19,232.00 | $6,136.00 | 1 | 6 |
| 2026-03-06 | $10,606.00 | $10,606.00 | 2 | 4 |

**Mar 1 was the strongest day** — 100% capture rate, $26k GMV. **Mar 5 was the worst** — only 1 of 6 transactions captured ($6,136 of $19,232 total volume), with U008 generating 4 failed/chargeback transactions alone. Overall GMV trended down across the week, with a partial recovery on Mar 5–6 driven by volume rather than conversion quality.

---

## Q5
### Query
Find merchants with chargeback ratio above 1% — identify merchants whose dispute rate exceeds the standard industry alert threshold.

### Result Summary
| merchant_name | total_txns | chargeback_count | chargeback_ratio_pct | chargeback_amount_usd |
|---|---|---|---|---|
| Eco Home | 2 | 1 | 50.00% | $6,649.00 |
| Delta Travels | 4 | 1 | 25.00% | $2,500.00 |
| Alpha Mart | 11 | 1 | 9.09% | $5,400.00 |
| Beta Stores | 11 | 1 | 9.09% | $1,711.00 |

**All 4 merchants that processed chargebacks exceed the 1% threshold** — City Pharma is the only clean merchant. Eco Home's 50% rate is the most alarming, though small sample size (2 txns) limits confidence. Delta Travels at 25% is notable given it is a Travel merchant, a category already prone to disputes. Alpha Mart and Beta Stores both sit at 9.1%, well above the 1% threshold that typically triggers processor review.

---

## Q6
### Query
Find regions with average risk score above 50 and more than 20 transactions — identify geographies that are both high-risk and high-volume.

### Result Summary
| gateway_region | total_transactions | avg_risk_score | max_risk_score | high_risk_txn_count |
|---|---|---|---|---|
| APAC | 22 | 65.48 | 86 | 8 |

**Only APAC meets both criteria.** EU (4 txns, avg 47.25) and US (4 txns, avg 48.75) both fail on volume and narrowly miss on risk score. APAC's average of 65.48 is significantly above the 50 threshold, and 8 of its 22 transactions triggered the `high_risk_flag`. The max score of 86 (T018, Beta Stores chargeback) represents the riskiest individual transaction in the dataset. APAC requires the most active risk monitoring.

---

## Q7
### Query
Find users with 3 or more failed or chargeback transactions on the same day — detect anomalous behaviour patterns that may indicate fraud or account compromise.

### Result Summary
| user_id | transaction_date | bad_txn_count | failed_count | chargeback_count | total_amount_usd |
|---|---|---|---|---|---|
| U008 | 2026-03-05 | 4 | 3 | 1 | $8,499.00 |

**U008 is the only flagged user.** On March 5 they generated 4 bad transactions across two merchants: T016 (Beta Stores, failed, $2,596), T017 (Beta Stores, failed, $2,124), T018 (Beta Stores, chargeback, $1,711), and T019 (Alpha Mart, failed, $3,068). The combination of a chargeback plus repeated failures at two separate merchants on the same day is a strong signal of account abuse, card testing, or unauthorised usage. U008 should be escalated for manual review and potential suspension.

---

## Q8
### Query
Show chargeback count, unique affected users, and chargeback amount by merchant — build a full chargeback exposure profile per merchant.

### Result Summary
| merchant_name | category | account_manager | chargebacks | unique_users | total_chargeback_usd | avg_chargeback_usd | cb_rate_pct |
|---|---|---|---|---|---|---|---|
| Eco Home | Home | Nina Weber | 1 | 1 | $6,649.00 | $6,649.00 | 50.00% |
| Alpha Mart | Grocery | Aisha Khan | 1 | 1 | $5,400.00 | $5,400.00 | 9.09% |
| Delta Travels | Travel | Marcus Lee | 1 | 1 | $2,500.00 | $2,500.00 | 25.00% |
| Beta Stores | Electronics | Rohan Mehta | 1 | 1 | $1,711.00 | $1,711.00 | 9.09% |

**Total chargeback exposure: $16,259 across 4 merchants.** Each dispute involved a different user, ruling out a single bad actor hitting multiple merchants. Eco Home has the highest-value chargeback ($6,649 from U004) relative to its total volume, making it the most financially exposed merchant on a per-dispute basis. Nina Weber (Eco Home account manager) and Elena Rossi (City Pharma — zero chargebacks, a positive data point) represent the two extremes of merchant health in the portfolio. Rohan Mehta's Beta Stores has the lowest absolute chargeback amount ($1,711) despite the highest raw transaction volume, suggesting effective risk controls on individual transaction sizes.
