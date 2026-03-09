-- Revenue by Acquisition Channel
-- Identify which marketing channels generate the most revenue

SELECT
  c.acquisition_channel,
  COUNT(DISTINCT customer_id) AS customers,
  SUM(amount_usd) AS revenue
FROM payments p
JOIN customers c
  ON p.customer_id = c.customer_id
WHERE status = 'paid'
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;
