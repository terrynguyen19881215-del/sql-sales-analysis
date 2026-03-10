-- =========================================
-- 05 CUSTOMER LTV ANALYSIS
-- Evaluates customer lifetime value across customers,
-- acquisition channels, and subscription plans
-- =========================================


-- =========================================
-- 1. Customer Lifetime Value
-- Calculates total lifetime revenue per customer
-- =========================================

SELECT
    customer_id,
    SUM(amount_usd) AS lifetime_value,
    COUNT(*) AS payment_count,
    MIN(payment_date) AS first_payment_date,
    MAX(payment_date) AS last_payment_date
FROM payments
WHERE status = 'paid'
GROUP BY customer_id
ORDER BY lifetime_value DESC;



-- =========================================
-- 2. Average LTV by Acquisition Channel
-- Measures which channels bring higher-value customers
-- =========================================

WITH customer_ltv AS (
    SELECT
        customer_id,
        SUM(amount_usd) AS lifetime_value
    FROM payments
    WHERE status = 'paid'
    GROUP BY customer_id
)

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(AVG(cl.lifetime_value), 2) AS avg_ltv,
    SUM(cl.lifetime_value) AS total_ltv
FROM customers c
JOIN customer_ltv cl
    ON c.customer_id = cl.customer_id
GROUP BY c.acquisition_channel
ORDER BY avg_ltv DESC;



-- =========================================
-- 3. Average LTV by Subscription Plan
-- Measures customer value across pricing tiers
-- =========================================

WITH customer_ltv AS (
    SELECT
        customer_id,
        SUM(amount_usd) AS lifetime_value
    FROM payments
    WHERE status = 'paid'
    GROUP BY customer_id
)

SELECT
    s.plan,
    COUNT(DISTINCT s.customer_id) AS customers,
    ROUND(AVG(cl.lifetime_value), 2) AS avg_ltv,
    SUM(cl.lifetime_value) AS total_ltv
FROM subscriptions s
JOIN customer_ltv cl
    ON s.customer_id = cl.customer_id
GROUP BY s.plan
ORDER BY avg_ltv DESC;
