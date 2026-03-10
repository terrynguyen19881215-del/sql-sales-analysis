-- =========================================
-- 01 REVENUE ANALYSIS
-- Core revenue metrics and customer contribution
-- =========================================


-- =========================================
-- 1. Monthly Revenue Trend
-- Calculates total paid revenue per month
-- Useful for tracking business growth over time
-- =========================================

SELECT
    DATE_TRUNC('month', payment_date) AS month,
    SUM(amount_usd) AS revenue
FROM payments
WHERE status = 'paid'
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY month;



-- =========================================
-- 2. MRR Distribution by Subscription Plan
-- Calculates total MRR and number of customers per plan
-- Helps evaluate pricing tier performance
-- =========================================

SELECT
    plan,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(mrr_usd) AS total_mrr,
    ROUND(AVG(mrr_usd), 2) AS avg_mrr_per_subscription,
    ROUND(
        SUM(mrr_usd) * 100.0 /
        SUM(SUM(mrr_usd)) OVER (),
        1
    ) AS mrr_share_pct
FROM subscriptions
GROUP BY plan
ORDER BY total_mrr DESC;



-- =========================================
-- 3. Top Customer Revenue Contribution
-- Measures how much revenue is generated
-- by the highest value customers
-- =========================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(amount_usd) AS customer_revenue
    FROM payments
    WHERE status = 'paid'
    GROUP BY customer_id
),

ranked_customers AS (
    SELECT
        customer_id,
        customer_revenue,
        RANK() OVER (ORDER BY customer_revenue DESC) AS revenue_rank,
        SUM(customer_revenue) OVER () AS total_revenue,
        SUM(customer_revenue) OVER (
            ORDER BY customer_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM customer_revenue
)

SELECT
    customer_id,
    customer_revenue,
    revenue_rank,
    ROUND(customer_revenue * 100.0 / total_revenue, 1) AS revenue_share_pct,
    ROUND(cumulative_revenue * 100.0 / total_revenue, 1) AS cumulative_share_pct
FROM ranked_customers
ORDER BY revenue_rank
LIMIT 5;
