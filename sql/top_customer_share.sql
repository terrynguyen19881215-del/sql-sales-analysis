-- Top Customer Revenue Contribution
-- Top Revenue Contribution
-- Calculates revenue share of top 5 value customers

WITH revenue AS (
	SELECT
		customer_id,
		SUM(amount_usd) AS customer_revenue
	FROM payments
	WHERE status = 'paid'
	GROUP BY customer_id
), total_revenue_table AS (
	SELECT
		customer_id,
		customer_revenue,
		SUM(r.customer_revenue) OVER () AS total_revenue
	FROM revenue r
)

SELECT
	customer_id,
	customer_revenue,
	ROUND(customer_revenue *100.0 /total_revenue, 1) AS revenue_share
FROM total_revenue_table
ORDER BY customer_revenue DESC
LIMIT 5;

