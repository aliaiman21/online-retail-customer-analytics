SELECT
    segment,
    COUNT(*)                                                         AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)               AS pct_customers,
    ROUND(SUM(monetary))                                             AS revenue,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1)     AS pct_revenue,
    ROUND(AVG(recency_days))                                         AS avg_recency_days,
    ROUND(AVG(frequency), 1)                                         AS avg_orders,
    ROUND(AVG(monetary))                                             AS avg_spend
FROM rfm_segments
GROUP BY segment
ORDER BY revenue DESC;