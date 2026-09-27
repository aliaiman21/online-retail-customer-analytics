SELECT
    country,
    COUNT(DISTINCT customer_id)                                        AS customers,
    COUNT(*)                                                           AS orders,
    ROUND(SUM(order_value))                                            AS revenue,
    ROUND(100.0 * SUM(order_value) / SUM(SUM(order_value)) OVER (), 1) AS pct_revenue,
    ROUND(AVG(order_value))                                            AS avg_order_value,
    ROUND(SUM(order_value) / COUNT(DISTINCT customer_id))              AS revenue_per_customer
FROM orders
GROUP BY country
HAVING COUNT(DISTINCT customer_id) >= 10
ORDER BY revenue DESC
LIMIT 12;