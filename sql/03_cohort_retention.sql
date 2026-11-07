-- 03_cohort_retention.sql
-- Cohort = month of first purchase. month_index = months since first purchase.

WITH first_buy AS (                       -- each customer's joining month
    SELECT customer_id,
           DATE_FORMAT(MIN(invoice_date), '%Y-%m-01') AS cohort_month
    FROM retail_db.retail
    GROUP BY customer_id
),
activity AS (                             -- every purchase, tagged with cohort + month number
    SELECT r.customer_id,
           f.cohort_month,
           TIMESTAMPDIFF(MONTH, f.cohort_month,
               DATE_FORMAT(r.invoice_date, '%Y-%m-01')) AS month_index
    FROM retail_db.retail r
    JOIN first_buy f ON r.customer_id = f.customer_id
),
cohort_counts AS (                        -- unique active customers per cohort per month
    SELECT cohort_month, month_index,
           COUNT(DISTINCT customer_id) AS active_customers
    FROM activity
    GROUP BY cohort_month, month_index
)
SELECT cohort_month,                      -- retention % = active / month-0 size
       month_index,
       active_customers,
       ROUND(active_customers * 100.0 /
             FIRST_VALUE(active_customers) OVER (
                 PARTITION BY cohort_month ORDER BY month_index), 1) AS retention_pct
FROM cohort_counts
ORDER BY cohort_month, month_index;

-- Part B: average retention for genuinely new customers
-- Excludes the left-censored Dec 2009 cohort and the partial Dec 2011 month

WITH first_buy AS (
    SELECT customer_id,
           DATE_FORMAT(MIN(invoice_date), '%Y-%m-01') AS cohort_month
    FROM retail_db.retail
    GROUP BY customer_id
),
activity AS (
    SELECT r.customer_id,
           f.cohort_month,
           TIMESTAMPDIFF(MONTH, f.cohort_month,
               DATE_FORMAT(r.invoice_date, '%Y-%m-01')) AS month_index
    FROM retail_db.retail r
    JOIN first_buy f ON r.customer_id = f.customer_id
    WHERE r.invoice_date < '2011-12-01'          -- drop partial month
),
cohort_counts AS (
    SELECT cohort_month, month_index,
           COUNT(DISTINCT customer_id) AS active_customers
    FROM activity
    GROUP BY cohort_month, month_index
),
retention AS (
    SELECT cohort_month, month_index,
           active_customers * 100.0 /
           FIRST_VALUE(active_customers) OVER (
               PARTITION BY cohort_month ORDER BY month_index) AS retention_pct
    FROM cohort_counts
)
SELECT month_index,
       ROUND(AVG(retention_pct), 1) AS avg_retention_pct,
       COUNT(*)                     AS cohorts_included
FROM retention
WHERE cohort_month <> '2009-12-01'                -- drop left-censored cohort
  AND month_index BETWEEN 0 AND 12
GROUP BY month_index
ORDER BY month_index;