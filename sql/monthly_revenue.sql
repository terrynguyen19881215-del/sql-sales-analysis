SELECT
  DATE_TRUNC('month', payment_date) AS month,
  SUM(amount_usd) AS revenue
FROM payments
WHERE status = 'paid'
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY month;
