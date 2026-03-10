-- MRR Distribution by Subscription Plan
-- Calculates total MRR and customers per plan

SELECT
    plan,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(mrr_usd) AS total_mrr,
    ROUND(AVG(mrr_usd), 2) AS avg_mrr_per_subscription,
    ROUND(SUM(mrr_usd) * 100.0 / SUM(SUM(mrr_usd)) OVER (), 1) AS mrr_share_pct
FROM subscriptions
GROUP BY plan
ORDER BY total_mrr DESC;
