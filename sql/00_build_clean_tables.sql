-- Step 0: fix data types + remove exact duplicate rows
CREATE OR REPLACE TABLE raw_typed AS
SELECT DISTINCT
    InvoiceNo                                 AS invoice_no,
    StockCode                                 AS stock_code,
    TRIM(Description)                         AS description,
    Quantity                                  AS quantity,
    STRPTIME(InvoiceDate, '%m/%d/%Y %H:%M')   AS invoice_ts,
    UnitPrice                                 AS unit_price,
    CustomerID                                AS customer_id,
    Country                                   AS country
FROM raw_retail;

-- Clean product lines
CREATE OR REPLACE TABLE sales AS
SELECT
    *,
    CAST(invoice_ts AS DATE)                  AS invoice_date,
    DATE_TRUNC('month', invoice_ts)::DATE     AS invoice_month,
    ROUND(quantity * unit_price, 2)           AS revenue
FROM raw_typed
WHERE invoice_no NOT LIKE 'C%'                -- rule 1: no cancellations
  AND customer_id IS NOT NULL                 -- rule 2: must have a customer
  AND quantity > 0 AND unit_price > 0         -- rule 3: no returns / zero price
  AND REGEXP_MATCHES(stock_code, '^[0-9]{5}');-- rule 4: real products only

-- One row per order
CREATE OR REPLACE TABLE orders AS
SELECT
    invoice_no,
    customer_id,
    ANY_VALUE(country)        AS country,
    MIN(invoice_ts)           AS order_ts,
    MIN(invoice_month)        AS order_month,
    COUNT(*)                  AS lines,
    SUM(quantity)             AS units,
    SUM(revenue)              AS order_value
FROM sales
GROUP BY invoice_no, customer_id;