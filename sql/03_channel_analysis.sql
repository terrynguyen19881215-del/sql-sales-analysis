-- =========================================
-- 03 CHANNEL ANALYSIS
-- Evaluates marketing channel performance
-- =========================================


-- =========================================
-- 1. Revenue by Acquisition Channel
-- Shows which channels generate the most revenue
-- =========================================

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT p.customer_id) AS paid_customers,
    SUM(p.amount_usd) AS revenue
FROM payments p
JOIN customers c
    ON p.customer_id = c.customer_id
WHERE p.status = 'paid'
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;



-- =========================================
-- 2. Revenue per Customer by Channel
-- Measures revenue efficiency of each channel
-- =========================================

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT p.customer_id) AS paid_customers,
    SUM(p.amount_usd) AS revenue,
    ROUND(
        SUM(p.amount_usd) * 1.0 /
        COUNT(DISTINCT p.customer_id),
        2
    ) AS revenue_per_customer
FROM payments p
JOIN customers c
    ON p.customer_id = c.customer_id
WHERE p.status = 'paid'
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer DESC;



-- =========================================
-- 3. Revenue Share by Channel
-- Calculates each channel's contribution to total revenue
-- =========================================

SELECT
    c.acquisition_channel,
    SUM(p.amount_usd) AS revenue,
    ROUND(
        SUM(p.amount_usd) * 100.0 /
        SUM(SUM(p.amount_usd)) OVER (),
        1
    ) AS revenue_share_pct
FROM payments p
JOIN customers c
    ON p.customer_id = c.customer_id
WHERE p.status = 'paid'
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;
