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
), ranked AS (
    SELECT
        customer_id,
        customer_revenue,
        RANK() OVER (ORDER BY customer_revenue DESC) AS revenue_rank,
        SUM(customer_revenue) OVER () AS total_revenue,
        SUM(customer_revenue) OVER (
            ORDER BY customer_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM revenue
)

SELECT
	customer_id,
	customer_revenue,
	revenue_rank,
	ROUND(customer_revenue *100.0 /total_revenue, 1) AS revenue_share,
	ROUND(cumulative_revenue * 100.0 / total_revenue, 1) AS cumulative_share_pct
FROM ranked
ORDER BY revenue_rank DESC
LIMIT 5;

