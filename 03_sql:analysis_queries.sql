-- ============================================================
-- TWJ Labs – Transaction Analysis Queries
-- Source table : cleaned_transactions
-- Generated   : 2026-05-09
-- ============================================================


-- ============================================================
-- Q1  Count transactions by status
-- ============================================================
SELECT
    status,
    COUNT(*)                                        AS transaction_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_total
FROM cleaned_transactions
GROUP BY status
ORDER BY transaction_count DESC;


-- ============================================================
-- Q2  Total captured GMV by merchant
-- ============================================================
SELECT
    merchant_id,
    merchant_name,
    merchant_category,
    ROUND(SUM(amount_usd), 2)                       AS captured_gmv_usd,
    COUNT(*)                                        AS captured_txn_count
FROM cleaned_transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name, merchant_category
ORDER BY captured_gmv_usd DESC;


-- ============================================================
-- Q3  Top 10 merchants by captured GMV
-- ============================================================
SELECT
    merchant_id,
    merchant_name,
    merchant_category,
    account_manager,
    ROUND(SUM(amount_usd), 2)                       AS captured_gmv_usd,
    COUNT(*)                                        AS captured_txn_count,
    ROUND(AVG(amount_usd), 2)                       AS avg_txn_value_usd
FROM cleaned_transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name, merchant_category, account_manager
ORDER BY captured_gmv_usd DESC
LIMIT 10;


-- ============================================================
-- Q4  Daily GMV and successful transaction count
-- ============================================================
SELECT
    transaction_date,
    ROUND(SUM(amount_usd), 2)                       AS total_gmv_usd,
    SUM(CASE WHEN status = 'captured' THEN 1 ELSE 0 END) AS successful_txn_count,
    COUNT(*)                                        AS total_txn_count,
    ROUND(
        SUM(CASE WHEN status = 'captured' THEN amount_usd ELSE 0 END), 2
    )                                               AS captured_gmv_usd
FROM cleaned_transactions
GROUP BY transaction_date
ORDER BY transaction_date;


-- ============================================================
-- Q5  Merchants with chargeback ratio above 1%
-- ============================================================
SELECT
    merchant_id,
    merchant_name,
    COUNT(*)                                                AS total_transactions,
    SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) AS chargeback_count,
    ROUND(
        SUM(CASE WHEN status = 'chargeback' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2
    )                                                       AS chargeback_ratio_pct,
    ROUND(
        SUM(CASE WHEN status = 'chargeback' THEN amount_usd ELSE 0 END), 2
    )                                                       AS chargeback_amount_usd
FROM cleaned_transactions
GROUP BY merchant_id, merchant_name
HAVING
    SUM(CASE WHEN status = 'chargeback' THEN 1.0 ELSE 0 END)
    / COUNT(*) * 100 > 1
ORDER BY chargeback_ratio_pct DESC;


-- ============================================================
-- Q6  Regions with average risk score above 50
--     AND more than 20 transactions
-- ============================================================
SELECT
    gateway_region,
    COUNT(*)                                        AS total_transactions,
    ROUND(AVG(risk_score), 2)                       AS avg_risk_score,
    MAX(risk_score)                                 AS max_risk_score,
    SUM(CASE WHEN high_risk_flag = 1 THEN 1 ELSE 0 END) AS high_risk_txn_count
FROM cleaned_transactions
WHERE risk_score IS NOT NULL
GROUP BY gateway_region
HAVING
    AVG(risk_score) > 50
    AND COUNT(*) > 20
ORDER BY avg_risk_score DESC;


-- ============================================================
-- Q7  Users with 3 or more failed or chargeback transactions
--     on the same day
-- ============================================================
SELECT
    user_id,
    transaction_date,
    COUNT(*)                                        AS bad_txn_count,
    SUM(CASE WHEN status = 'failed'     THEN 1 ELSE 0 END) AS failed_count,
    SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) AS chargeback_count,
    ROUND(SUM(amount_usd), 2)                       AS total_amount_usd,
    GROUP_CONCAT(transaction_id ORDER BY transaction_id) AS transaction_ids
FROM cleaned_transactions
WHERE status IN ('failed', 'chargeback')
GROUP BY user_id, transaction_date
HAVING COUNT(*) >= 3
ORDER BY bad_txn_count DESC, transaction_date;


-- ============================================================
-- Q8  Chargeback count, unique affected users, and chargeback
--     amount by merchant
-- ============================================================
SELECT
    ct.merchant_id,
    ct.merchant_name,
    ct.merchant_category,
    ct.account_manager,
    COUNT(*)                                        AS chargeback_count,
    COUNT(DISTINCT ct.user_id)                      AS unique_affected_users,
    ROUND(SUM(ct.amount_usd), 2)                    AS total_chargeback_amount_usd,
    ROUND(AVG(ct.amount_usd), 2)                    AS avg_chargeback_amount_usd,
    ROUND(
        COUNT(*) * 100.0 / merchant_totals.total_txns, 2
    )                                               AS chargeback_rate_pct
FROM cleaned_transactions ct
JOIN (
    SELECT merchant_id, COUNT(*) AS total_txns
    FROM cleaned_transactions
    GROUP BY merchant_id
) merchant_totals USING (merchant_id)
WHERE ct.status = 'chargeback'
GROUP BY
    ct.merchant_id, ct.merchant_name,
    ct.merchant_category, ct.account_manager,
    merchant_totals.total_txns
ORDER BY total_chargeback_amount_usd DESC;
