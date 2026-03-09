-- Cohort Retention Analysis
-- Measures customer retention by first purchase month

WITH first_paid AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(payment_date)) AS cohort_month
    FROM payments
    WHERE status = 'paid'
    GROUP BY customer_id
    ), monthly_activity AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', payment_date) AS activity_month,
        SUM(amount_usd) AS revenue
    FROM payments
    WHERE status = 'paid'
    GROUP BY customer_id, DATE_TRUNC('month', payment_date)
    ), cohort_activity AS (
    SELECT
        fp.customer_id,
        fp.cohort_month,
        ma.activity_month,
        ma.revenue,
        (
          (EXTRACT(YEAR FROM ma.activity_month) - EXTRACT(YEAR FROM fp.cohort_month)
          ) * 12
          +
          (EXTRACT(MONTH FROM ma.activity_month) - EXTRACT(MONTH FROM fp.cohort_month))
        ) AS month_index
    FROM first_paid fp
    JOIN monthly_activity ma
        ON fp.customer_id = ma.customer_id
  ), cohort_summary AS (
    SELECT
        cohort_month,
        month_index,
        COUNT(DISTINCT customer_id) AS active_customers,
        SUM(revenue) AS revenue
    FROM cohort_activity
    GROUP BY cohort_month, month_index
), retention_base AS (
    SELECT
        cohort_month,
        month_index,
        active_customers,
        revenue,
        MAX(CASE WHEN month_index = 0 THEN active_customers END)
            OVER (PARTITION BY cohort_month) AS cohort_size
    FROM cohort_summary
)
SELECT
    cohort_month,
    month_index,
    active_customers,
    cohort_size,
    revenue,
    ROUND(active_customers * 100.0 / cohort_size, 1) AS retention_pct
FROM retention_base
ORDER BY cohort_month, month_index;
