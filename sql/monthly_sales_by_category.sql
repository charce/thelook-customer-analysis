-- output: merch-funnel.sales_analysis.monthly_sales_by_category
-- grain: month × category
-- sources: bigquery-public-data.thelook_ecommerce.order_items, bigquery-public-data.thelook_ecommerce.products
-- notes: Excludes Cancelled/Returned; units_sold = count of order_items rows; AOV computed at (month, category)

CREATE OR REPLACE TABLE `merch-funnel.sales_analysis.monthly_sales_by_category` AS
SELECT
  DATE_TRUNC(DATE(oi.created_at), MONTH) AS month,
  p.category,
  SUM(oi.sale_price) AS revenue,
  COUNT(DISTINCT oi.order_id) AS orders,
  COUNT(*) AS units_sold,
  SAFE_DIVIDE(SUM(oi.sale_price), COUNT(DISTINCT oi.order_id)) AS avg_order_value
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY month, category
ORDER BY month, category;
