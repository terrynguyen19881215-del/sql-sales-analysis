-- Revenue by Acquisition Channel
-- Identify which marketing channels generate the most revenue

SELECT
  c.acquisition_channel,
  COUNT(DISTINCT customer_id) AS customers,
  SUM(amount_usd) AS revenue,
  ROUND(SUM(amount_usd) * 100.0 / SUM(SUM(amount_usd)) OVER (), 1) AS revenue_share_pct
FROM payments p
JOIN customers c
  ON p.customer_id = c.customer_id
WHERE status = 'paid'
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;
