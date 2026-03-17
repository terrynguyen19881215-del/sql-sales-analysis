-- ============================================
-- 07_unit_economics.sql
-- Purpose:
--   1) LTV per customer
--   2) Average LTV by acquisition channel
--   3) CAC by channel (mock / assumed input)
--   4) LTV / CAC ratio
-- Notes:
--   - This project dataset does not include marketing spend.
--   - CAC values below are mock assumptions for unit economics analysis.
--   - Replace cac_table with real marketing cost data when available.
-- ============================================


-- ============================================
-- 1. LTV per customer
-- ============================================
WITH customer_ltv AS (
    SELECT
        p.customer_id,
        SUM(p.amount_usd) AS lifetime_revenue
    FROM payments p
    WHERE p.status = 'paid'
    GROUP BY p.customer_id
)
SELECT
    cl.customer_id,
    cl.lifetime_revenue
FROM customer_ltv cl
ORDER BY cl.lifetime_revenue DESC;


-- ============================================
-- 2. Average LTV by acquisition channel
-- ============================================
WITH customer_ltv AS (
    SELECT
        p.customer_id,
        SUM(p.amount_usd) AS lifetime_revenue
    FROM payments p
    WHERE p.status = 'paid'
    GROUP BY p.customer_id
)
SELECT
    c.acquisition_channel,
    ROUND(AVG(cl.lifetime_revenue), 2) AS avg_ltv
FROM customer_ltv cl
JOIN customers c
    ON cl.customer_id = c.customer_id
GROUP BY c.acquisition_channel
ORDER BY avg_ltv DESC;


-- ============================================
-- 3. CAC by acquisition channel (mock assumptions)
-- Replace this section with real marketing cost data if available.
-- ============================================
WITH cac_table AS (
    SELECT 'Paid' AS acquisition_channel, 1200::numeric AS cac
    UNION ALL
    SELECT 'Referral', 400::numeric
    UNION ALL
    SELECT 'Organic', 1400::numeric
    UNION ALL
    SELECT 'Outbound', 800::numeric
)
SELECT
    acquisition_channel,
    cac
FROM cac_table
ORDER BY acquisition_channel;


-- ============================================
-- 4. LTV / CAC ratio by acquisition channel
-- ============================================
WITH customer_ltv AS (
    SELECT
        p.customer_id,
        SUM(p.amount_usd) AS lifetime_revenue
    FROM payments p
    WHERE p.status = 'paid'
    GROUP BY p.customer_id
),
ltv_by_channel AS (
    SELECT
        c.acquisition_channel,
        ROUND(AVG(cl.lifetime_revenue), 2) AS avg_ltv
    FROM customer_ltv cl
    JOIN customers c
        ON cl.customer_id = c.customer_id
    GROUP BY c.acquisition_channel
),
cac_table AS (
    SELECT 'Paid' AS acquisition_channel, 1200::numeric AS cac
    UNION ALL
    SELECT 'Referral', 400::numeric
    UNION ALL
    SELECT 'Organic', 1400::numeric
    UNION ALL
    SELECT 'Outbound', 800::numeric
)
SELECT
    lbc.acquisition_channel,
    lbc.avg_ltv,
    ct.cac,
    ROUND(lbc.avg_ltv / ct.cac, 2) AS ltv_cac_ratio,
    CASE
        WHEN lbc.avg_ltv / ct.cac > 1 THEN 'Profitable'
        WHEN lbc.avg_ltv / ct.cac = 1 THEN 'Break-even'
        ELSE 'Unprofitable'
    END AS unit_economics_status
FROM ltv_by_channel lbc
JOIN cac_table ct
    ON lbc.acquisition_channel = ct.acquisition_channel
ORDER BY ltv_cac_ratio DESC;
