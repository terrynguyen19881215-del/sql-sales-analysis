-- ============================================
-- 06_churn_analysis.sql
-- Purpose:
--   1) Monthly churn
--   2) Churn by acquisition channel
--   3) Churn by cohort month
-- Notes:
--   - Churn is defined as:
--     customer active in month M but not active in month M+1
--   - The last observed month is excluded from churn calculation
--     because we do not yet know whether users will return next month.
-- ============================================


-- ============================================
-- 1. Monthly churn
-- ============================================
WITH customer_active AS (
    SELECT DISTINCT
        p.customer_id,
        DATE_TRUNC('month', p.payment_date) AS activity_month
    FROM payments p
    WHERE p.status = 'paid'
),
active_customers AS (
    SELECT
        ca.activity_month,
        COUNT(DISTINCT ca.customer_id) AS active_customers
    FROM customer_active ca
    GROUP BY ca.activity_month
),
last_month_set AS (
    SELECT
        MAX(activity_month) AS last_month
    FROM customer_active
),
churn_customers AS (
    SELECT
        ca.activity_month,
        COUNT(DISTINCT ca.customer_id) AS churn_customers
    FROM customer_active ca
    LEFT JOIN customer_active ca_next
        ON ca.customer_id = ca_next.customer_id
       AND ca.activity_month + INTERVAL '1 month' = ca_next.activity_month
    CROSS JOIN last_month_set lms
    WHERE ca_next.customer_id IS NULL
      AND ca.activity_month < lms.last_month
    GROUP BY ca.activity_month
)
SELECT
    ac.activity_month AS month,
    ac.active_customers,
    COALESCE(cc.churn_customers, 0) AS churn_customers,
    ROUND(
        COALESCE(cc.churn_customers, 0)::decimal / ac.active_customers,
        2
    ) AS churn_rate
FROM active_customers ac
LEFT JOIN churn_customers cc
    ON ac.activity_month = cc.activity_month
ORDER BY month;


-- ============================================
-- 2. Churn by acquisition channel
-- ============================================
WITH customer_active AS (
    SELECT DISTINCT
        p.customer_id,
        DATE_TRUNC('month', p.payment_date) AS activity_month,
        c.acquisition_channel
    FROM payments p
    JOIN customers c
        ON p.customer_id = c.customer_id
    WHERE p.status = 'paid'
),
active_customers AS (
    SELECT
        ca.activity_month,
        ca.acquisition_channel,
        COUNT(DISTINCT ca.customer_id) AS active_customers
    FROM customer_active ca
    GROUP BY
        ca.activity_month,
        ca.acquisition_channel
),
last_month_set AS (
    SELECT
        MAX(activity_month) AS last_month
    FROM customer_active
),
churn_customers AS (
    SELECT
        ca.activity_month,
        ca.acquisition_channel,
        COUNT(DISTINCT ca.customer_id) AS churn_customers
    FROM customer_active ca
    LEFT JOIN customer_active ca_next
        ON ca.customer_id = ca_next.customer_id
       AND ca.activity_month + INTERVAL '1 month' = ca_next.activity_month
    CROSS JOIN last_month_set lms
    WHERE ca_next.customer_id IS NULL
      AND ca.activity_month < lms.last_month
    GROUP BY
        ca.activity_month,
        ca.acquisition_channel
)
SELECT
    ac.activity_month AS month,
    ac.acquisition_channel,
    ac.active_customers,
    COALESCE(cc.churn_customers, 0) AS churn_customers,
    ROUND(
        COALESCE(cc.churn_customers, 0)::decimal / ac.active_customers,
        2
    ) AS churn_rate
FROM active_customers ac
LEFT JOIN churn_customers cc
    ON ac.activity_month = cc.activity_month
   AND ac.acquisition_channel = cc.acquisition_channel
ORDER BY
    month,
    acquisition_channel;


-- ============================================
-- 3. Churn by cohort month
-- ============================================
WITH cohort_table AS (
    SELECT
        p.customer_id,
        DATE_TRUNC('month', MIN(p.payment_date)) AS cohort_month
    FROM payments p
    WHERE p.status = 'paid'
    GROUP BY p.customer_id
),
customer_activity AS (
    SELECT DISTINCT
        p.customer_id,
        DATE_TRUNC('month', p.payment_date) AS activity_month,
        ct.cohort_month
    FROM payments p
    JOIN cohort_table ct
        ON p.customer_id = ct.customer_id
    WHERE p.status = 'paid'
),
active_customers AS (
    SELECT
        ca.activity_month,
        ca.cohort_month,
        COUNT(DISTINCT ca.customer_id) AS active_customers
    FROM customer_activity ca
    GROUP BY
        ca.activity_month,
        ca.cohort_month
),
last_month_set AS (
    SELECT
        MAX(activity_month) AS last_month
    FROM customer_activity
),
churn_customers AS (
    SELECT
        ca.activity_month,
        ca.cohort_month,
        COUNT(DISTINCT ca.customer_id) AS churn_customers
    FROM customer_activity ca
    LEFT JOIN customer_activity ca_next
        ON ca.customer_id = ca_next.customer_id
       AND ca.activity_month + INTERVAL '1 month' = ca_next.activity_month
    CROSS JOIN last_month_set lms
    WHERE ca_next.customer_id IS NULL
      AND ca.activity_month < lms.last_month
    GROUP BY
        ca.activity_month,
        ca.cohort_month
)
SELECT
    ac.activity_month AS month,
    ac.cohort_month,
    ac.active_customers,
    COALESCE(cc.churn_customers, 0) AS churn_customers,
    ROUND(
        COALESCE(cc.churn_customers, 0)::numeric / ac.active_customers,
        2
    ) AS churn_rate
FROM active_customers ac
LEFT JOIN churn_customers cc
    ON ac.activity_month = cc.activity_month
   AND ac.cohort_month = cc.cohort_month
ORDER BY
    month,
    cohort_month;
