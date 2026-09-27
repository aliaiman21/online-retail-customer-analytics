SELECT 1 AS step, 'Raw rows'                             AS stage, COUNT(*) AS rows_left FROM raw_retail
UNION ALL
SELECT 2, 'After removing exact duplicates',             COUNT(*) FROM raw_typed
UNION ALL
SELECT 3, 'After removing cancellations',                COUNT(*) FROM raw_typed
          WHERE invoice_no NOT LIKE 'C%'
UNION ALL
SELECT 4, 'After removing missing CustomerID',           COUNT(*) FROM raw_typed
          WHERE invoice_no NOT LIKE 'C%' AND customer_id IS NOT NULL
UNION ALL
SELECT 5, 'After removing zero/negative qty or price',   COUNT(*) FROM raw_typed
          WHERE invoice_no NOT LIKE 'C%' AND customer_id IS NOT NULL
            AND quantity > 0 AND unit_price > 0
UNION ALL
SELECT 6, 'After removing non-products (postage, fees)', COUNT(*) FROM sales
ORDER BY step;