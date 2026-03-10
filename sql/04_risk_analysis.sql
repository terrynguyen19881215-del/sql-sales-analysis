-- =========================================
-- 04 BUSINESS RISK ANALYSIS
-- Evaluates revenue concentration and growth sustainability
-- =========================================


-- =========================================
-- 1. Revenue Concentration Risk
-- Measures how much revenue is concentrated among top customers
-- =========================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount_usd) AS revenue
    FROM payments
    WHERE status = 'paid'
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        revenue,
        RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
        SUM(revenue) OVER () AS total_revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM customer_revenue
)

SELECT
    customer_id,
    revenue_rank,
    revenue,
    ROUND(revenue * 100.0 / total_revenue, 1) AS revenue_share_pct,
    ROUND(cumulative_revenue * 100.0 / total_revenue, 1) AS cumulative_share_pct
FROM ranked_customers
ORDER BY revenue_rank;



-- =========================================
-- 2. Customer Dependency
-- Calculates revenue share of top 3 customers
-- =========================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount_usd) AS revenue
    FROM payments
    WHERE status = 'paid'
    GROUP BY customer_id
)

SELECT
    customer_id,
    revenue,
    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        1
    ) AS revenue_share_pct
FROM customer_revenue
ORDER BY revenue DESC
LIMIT 3;



-- =========================================
-- 3. Pareto Revenue Analysis (80/20 Rule)
-- Determines if a small percentage of customers
-- generates the majority of revenue
-- =========================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount_usd) AS revenue
    FROM payments
    WHERE status = 'paid'
    GROUP BY customer_id
),
ranked AS (
    SELECT
        customer_id,
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rank,
        SUM(revenue) OVER () AS total_revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM customer_revenue
)

SELECT
    customer_id,
    rank,
    revenue,
    ROUND(cumulative_revenue * 100.0 / total_revenue, 1) AS cumulative_revenue_pct
FROM ranked
ORDER BY rank;



-- =========================================
-- 4. Growth Sustainability
-- Compares revenue growth with customer growth
-- =========================================

SELECT
    DATE_TRUNC('month', payment_date) AS month,
    COUNT(DISTINCT customer_id) AS paid_customers,
    SUM(amount_usd) AS revenue,
    ROUND(
        SUM(amount_usd) * 1.0 /
        COUNT(DISTINCT customer_id),
        2
    ) AS revenue_per_customer
FROM payments
WHERE status = 'paid'
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY month;
