SELECT
    plan,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(mrr_usd) AS total_mrr
FROM subscriptions
GROUP BY plan
ORDER BY total_mrr DESC;
