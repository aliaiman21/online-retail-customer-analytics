WITH basket AS (
    SELECT DISTINCT invoice_no, stock_code FROM sales
),
product_orders AS (
    SELECT stock_code, COUNT(*) AS orders_with_product
    FROM basket GROUP BY stock_code
),
names AS (
    SELECT stock_code, ANY_VALUE(description) AS product
    FROM sales GROUP BY stock_code
),
pairs AS (
    SELECT a.stock_code AS code_a, b.stock_code AS code_b, COUNT(*) AS orders_together
    FROM basket a
    JOIN basket b
      ON a.invoice_no = b.invoice_no            -- same order
     AND a.stock_code < b.stock_code            -- each pair once, no product paired with itself
    GROUP BY a.stock_code, b.stock_code
    HAVING COUNT(*) >= 200                      -- only pairs seen in 200+ orders
),
total AS (SELECT COUNT(DISTINCT invoice_no) AS n_orders FROM basket)
SELECT
    na.product                                                              AS product_a,
    nb.product                                                              AS product_b,
    p.orders_together,
    ROUND(100.0 * p.orders_together / t.n_orders, 2)                        AS support_pct,
    ROUND(100.0 * p.orders_together / pa.orders_with_product, 1)            AS confidence_a_to_b_pct,
    ROUND(p.orders_together * t.n_orders
          / (pa.orders_with_product * pb.orders_with_product * 1.0), 1)     AS lift
FROM pairs p
CROSS JOIN total t
JOIN product_orders pa ON pa.stock_code = p.code_a
JOIN product_orders pb ON pb.stock_code = p.code_b
JOIN names na          ON na.stock_code = p.code_a
JOIN names nb          ON nb.stock_code = p.code_b
ORDER BY lift DESC
LIMIT 15;
