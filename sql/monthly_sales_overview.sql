-- output: merch-funnel.sales_analysis.monthly_sales_overview
-- grain: month (one row per month)
-- sources: bigquery-public-data.thelook_ecommerce.order_items
-- notes: Excludes Cancelled/Returned; units_sold = count of order_items rows; AOV = revenue/orders; units_per_order = units_sold/orders

CREATE OR REPLACE TABLE `merch-funnel.sales_analysis.monthly_sales_overview` AS
SELECT
  DATE_TRUNC(DATE(created_at), MONTH) AS month,
  SUM(sale_price) AS revenue,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(*) AS units_sold, -- count of order_items rows
  SAFE_DIVIDE(SUM(sale_price), COUNT(DISTINCT order_id)) AS avg_order_value,
  SAFE_DIVIDE(COUNT(*), COUNT(DISTINCT order_id)) AS units_per_order
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status NOT IN ('Cancelled', 'Returned')
GROUP BY month
ORDER BY month;
