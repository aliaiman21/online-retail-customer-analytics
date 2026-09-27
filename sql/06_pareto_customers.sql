WITH ranked AS (
    SELECT
        customer_id,
        monetary,
        ROW_NUMBER() OVER (ORDER BY monetary DESC)                      AS rank_no,
        COUNT(*) OVER ()                                                AS n_customers,
        SUM(monetary) OVER (ORDER BY monetary DESC
                            ROWS UNBOUNDED PRECEDING)                   AS running_revenue,
        SUM(monetary) OVER ()                                           AS total_revenue
    FROM rfm_segments
)
SELECT
    top_pct                                                              AS top_pct_of_customers,
    ROUND(100.0 * MAX(running_revenue) / MAX(total_revenue), 1)          AS pct_of_revenue
FROM ranked
CROSS JOIN (VALUES (1), (5), (10), (20), (50)) AS t(top_pct)
WHERE rank_no <= n_customers * top_pct / 100.0
GROUP BY top_pct
ORDER BY top_pct;