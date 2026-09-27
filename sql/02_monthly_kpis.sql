WITH monthly AS (
    SELECT
        order_month,
        ROUND(SUM(order_value), 0)          AS revenue,
        COUNT(*)                            AS orders,
        COUNT(DISTINCT customer_id)         AS active_customers,
        ROUND(AVG(order_value), 2)          AS avg_order_value
    FROM orders
    GROUP BY order_month
)
SELECT
    *,
    ROUND(100.0 * (revenue / LAG(revenue) OVER (ORDER BY order_month) - 1), 1)  AS revenue_mom_pct,
    order_month = (SELECT MAX(order_month) FROM orders)                         AS is_partial_month
FROM monthly
ORDER BY order_month;