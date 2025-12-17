-- output: merch-funnel.sales_analysis.top_products_overall
-- grain: product_id (one row per product)
-- sources: bigquery-public-data.thelook_ecommerce.order_items, bigquery-public-data.thelook_ecommerce.products
-- notes: Excludes Cancelled/Returned; share_of_total_revenue computed across all products (window sum)

CREATE OR REPLACE TABLE `merch-funnel.sales_analysis.top_products_overall` AS
SELECT
  p.id AS product_id,
  p.name AS product_name,
  p.category,
  SUM(oi.sale_price) AS revenue,
  COUNT(*) AS units_sold,
  COUNT(DISTINCT oi.order_id) AS orders,
  SAFE_DIVIDE(SUM(oi.sale_price), SUM(SUM(oi.sale_price)) OVER ()) AS share_of_total_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY product_id, product_name, category
ORDER BY revenue DESC;
