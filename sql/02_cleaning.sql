CREATE TABLE retail_db.retail AS
SELECT DISTINCT
       invoice, stock_code, description, quantity,
       invoice_date, price, customer_id, country,
       quantity * price AS revenue
FROM retail_db.retail_raw
WHERE customer_id IS NOT NULL
  AND invoice NOT LIKE 'C%'
  AND quantity > 0
  AND price > 0;
  
  CREATE INDEX idx_cust ON retail_db.retail(customer_id);
  
  SELECT COUNT(*)                    AS clean_rows,
       COUNT(DISTINCT customer_id) AS customers,
       ROUND(SUM(revenue), 2)      AS total_revenue
FROM retail_db.retail;