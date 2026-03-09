SELECT
  c.customer_id,
  SUM(p.amount_usd) AS total_revenue
FROM payments p
JOIN customers c
  ON p.customer_id = c.customer_id
WHERE p.status = 'paid'
GROUP BY c.customer_id
ORDER BY total_revenue DESC
LIMIT 1;
