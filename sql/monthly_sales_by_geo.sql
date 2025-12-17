-- output: merch-funnel.sales_analysis.monthly_sales_by_geo
-- grain: month × country
-- sources: bigquery-public-data.thelook_ecommerce.order_items, bigquery-public-data.thelook_ecommerce.users
-- notes: Excludes Cancelled/Returned; country is based on user profile; units_sold = count of order_items rows

CREATE OR REPLACE TABLE `merch-funnel.sales_analysis.monthly_sales_by_geo` AS
SELECT
  DATE_TRUNC(DATE(oi.created_at), MONTH) AS month,
  u.country,
  SUM(oi.sale_price) AS revenue,
  COUNT(DISTINCT oi.order_id) AS orders,
  COUNT(*) AS units_sold,
  SAFE_DIVIDE(SUM(oi.sale_price), COUNT(DISTINCT oi.order_id)) AS avg_order_value
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
  ON oi.user_id = u.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY month, country
ORDER BY month, country;
