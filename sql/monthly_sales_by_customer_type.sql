-- output: merch-funnel.sales_analysis.monthly_sales_by_customer_type
-- grain: month × customer_status
-- sources: bigquery-public-data.thelook_ecommerce.order_items, merch-funnel.customer_analysis.monthly_customer_summary
-- notes: Excludes Cancelled/Returned; customer_status comes from snapshot-month status (new/active/inactive) joined on (user_id, month)

CREATE OR REPLACE TABLE `merch-funnel.sales_analysis.monthly_sales_by_customer_type` AS
SELECT
  DATE_TRUNC(DATE(oi.created_at), MONTH) AS month,
  cs.status AS customer_status,
  SUM(oi.sale_price) AS revenue,
  COUNT(DISTINCT oi.order_id) AS orders,
  COUNT(*) AS units_sold
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `merch-funnel.customer_analysis.monthly_customer_summary` AS cs
  ON oi.user_id = cs.user_id
 AND cs.snapshot_month = DATE_TRUNC(DATE(oi.created_at), MONTH)
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY month, customer_status
ORDER BY month, customer_status;
