-- 04_clv.sql
-- Part A: average customer value metrics

WITH cust AS (                                   -- one row per customer
    SELECT customer_id,
           COUNT(DISTINCT invoice) AS orders,
           SUM(revenue)            AS total_revenue,
           MIN(invoice_date)       AS first_date,
           MAX(invoice_date)       AS last_date
    FROM retail_db.retail
    GROUP BY customer_id
)
SELECT COUNT(*)                                     AS customers,
       ROUND(SUM(total_revenue), 2)                 AS total_revenue,
       ROUND(SUM(total_revenue) / SUM(orders), 2)   AS aov,
       ROUND(AVG(orders), 2)                        AS avg_orders,
       ROUND(AVG(total_revenue), 2)                 AS avg_clv,
       ROUND(AVG(TIMESTAMPDIFF(MONTH, first_date, last_date)), 1) AS avg_lifespan_months,
       ROUND(AVG(orders = 1) * 100, 1)              AS one_time_buyer_pct
FROM cust;

-- 04_clv.sql
-- Part B: cumulative revenue per customer, by cohort

WITH first_buy AS (                               -- joining month
    SELECT customer_id,
           DATE_FORMAT(MIN(invoice_date), '%Y-%m-01') AS cohort_month
    FROM retail_db.retail
    GROUP BY customer_id
),
cohort_size AS (                                  -- customers per cohort
    SELECT cohort_month, COUNT(*) AS customers
    FROM first_buy
    GROUP BY cohort_month
),
monthly_rev AS (                                  -- revenue per cohort per month
    SELECT f.cohort_month,
           TIMESTAMPDIFF(MONTH, f.cohort_month,
               DATE_FORMAT(r.invoice_date, '%Y-%m-01')) AS month_index,
           SUM(r.revenue) AS revenue
    FROM retail_db.retail r
    JOIN first_buy f ON r.customer_id = f.customer_id
    GROUP BY f.cohort_month, month_index
)
SELECT m.cohort_month,
       m.month_index,
       s.customers,
       ROUND(SUM(m.revenue) OVER (PARTITION BY m.cohort_month
                                  ORDER BY m.month_index)
             / s.customers, 2) AS cum_revenue_per_customer
FROM monthly_rev m
JOIN cohort_size s ON m.cohort_month = s.cohort_month
ORDER BY m.cohort_month, m.month_index;