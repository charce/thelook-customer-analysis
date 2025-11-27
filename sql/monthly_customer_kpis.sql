-- monthly_customer_kpis.sql

-- monthly rollup of customer KPIs for dashboard cards + trend charts:
  -- total_customers
  -- active / new / inactive customers
  -- active_share
  -- cumulative total_orders_to_date
  -- avg_orders_per_customer (cumulative)

-- source:
  -- merch-funnel.customer_analysis.monthly_customer_summary

CREATE OR REPLACE TABLE `merch-funnel.customer_analysis.monthly_customer_kpis` AS
SELECT
  snapshot_month,
  COUNT(DISTINCT user_id) AS total_customers,
  COUNT(DISTINCT CASE WHEN status = 'active' THEN user_id END) AS active_customers,
  COUNT(DISTINCT CASE WHEN status = 'new' THEN user_id END) AS new_customers,
  COUNT(DISTINCT CASE WHEN status = 'inactive' THEN user_id END) AS inactive_customers,
  -- compute percentage of active customers 
  SAFE_DIVIDE(COUNT(DISTINCT CASE WHEN status IN ('active', 'new') THEN user_id END), COUNT(DISTINCT user_id)) AS active_share,
  SUM(total_orders) AS total_orders_to_date,
  SAFE_DIVIDE(SUM(total_orders), COUNT(DISTINCT user_id)) AS avg_orders_per_customer
FROM `merch-funnel.customer_analysis.monthly_customer_summary`
GROUP BY snapshot_month
ORDER BY snapshot_month DESC;