WITH snapshot AS (
    SELECT MAX(order_ts)::DATE + 1 AS as_of FROM orders      -- "today" = 10 Dec 2011
),
customer_rfm AS (
    SELECT
        o.customer_id,
        DATE_DIFF('day', MAX(o.order_ts)::DATE, s.as_of)     AS recency_days,
        COUNT(*)                                             AS frequency,
        ROUND(SUM(o.order_value), 2)                         AS monetary
    FROM orders o CROSS JOIN snapshot s
    GROUP BY o.customer_id, s.as_of
),
scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC, customer_id) AS r_score,   -- recent = 5
        NTILE(5) OVER (ORDER BY frequency, monetary)            AS f_score,
        NTILE(5) OVER (ORDER BY monetary)                       AS m_score
    FROM customer_rfm
)
SELECT
    *,
    CASE
        WHEN r_score >= 4 AND f_score >= 4             THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3             THEN 'Loyal'
        WHEN r_score >= 4 AND f_score <= 2             THEN 'New / Promising'
        WHEN r_score <= 2 AND f_score >= 4             THEN 'At Risk (high value)'
        WHEN r_score <= 2 AND f_score BETWEEN 2 AND 3  THEN 'Needs Attention'
        WHEN r_score = 3                               THEN 'About to Sleep'
        ELSE                                                'Lost / Hibernating'
    END AS segment
FROM scored
ORDER BY monetary DESC;