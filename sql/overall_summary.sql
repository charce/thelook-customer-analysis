-- output: merch-funnel.sales_analysis.overall_summary
-- grain: month (one row per month)
-- sources: merch-funnel.sales_analysis.monthly_sales_overview, merch-funnel.customer_analysis.monthly_customer_kpis
-- notes: Combines monthly sales KPIs + customer KPIs for the Summary page; active_share = (active + new) / total_customers

CREATE OR REPLACE TABLE `merch-funnel.sales_analysis.overall_summary` AS
SELECT
  s.month,
  s.revenue,
  s.orders,
  s.avg_order_value,
  c.active_customers,
  c.new_customers,
  SAFE_DIVIDE(c.active_customers + c.new_customers, c.total_customers) AS active_share
FROM `merch-funnel.sales_analysis.monthly_sales_overview` AS s
JOIN `merch-funnel.customer_analysis.monthly_customer_kpis` AS c
  ON s.month = c.snapshot_month;
