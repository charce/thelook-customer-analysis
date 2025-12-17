-- output: merch-funnel.customer_analysis.monthly_customer_kpis
-- grain: snapshot_month (one row per month)
-- sources: merch-funnel.customer_analysis.monthly_customer_summary
-- notes: active_share = (active + new) / total; total_orders_to_date and avg_orders_per_customer derived from rolling totals in monthly_customer_summary

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