WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        order_month,
        MIN(order_month) OVER (PARTITION BY customer_id)   AS cohort_month
    FROM orders
    WHERE order_month < DATE '2011-12-01'       -- Dec 2011 is partial (data ends 9 Dec)
),
cohort_activity AS (
    SELECT
        cohort_month,
        DATE_DIFF('month', cohort_month, order_month)      AS months_since_first,
        COUNT(DISTINCT customer_id)                        AS customers
    FROM customer_months
    GROUP BY cohort_month, months_since_first
)
SELECT
    cohort_month,
    months_since_first,
    customers,
    FIRST_VALUE(customers) OVER (PARTITION BY cohort_month
                                 ORDER BY months_since_first)     AS cohort_size,
    ROUND(100.0 * customers / FIRST_VALUE(customers) OVER (PARTITION BY cohort_month
                                 ORDER BY months_since_first), 1) AS retention_pct
FROM cohort_activity
ORDER BY cohort_month, months_since_first;