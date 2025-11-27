-- complete_customer_data.sql

-- combine user attribtes with order history for each user
-- add user's signup month and most recent order (order id & order date)

-- source:
  -- bigquery-public-data.thelook_ecommerce.users
  -- bigquery-public-data.thelook_ecommerce.orders
  
CREATE OR REPLACE TABLE
  `merch-funnel.customer_analysis.complete_customer_data` AS
WITH user_orders AS (
  SELECT 
    u.id AS user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.age,
    u.gender,
    u.state,
    u.city,
    u.country,
    u.traffic_source,
    u.created_at AS signup_date,
    DATE_TRUNC(DATE(u.created_at), MONTH) AS signup_month,
    o.order_id,
    o.created_at AS order_date,
    o.num_of_item AS order_quantity,
  FROM `bigquery-public-data.thelook_ecommerce.users` AS u
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
  ON u.id = o.user_id
  ORDER BY user_id, signup_date ASC
),

-- get customers' most recent orders
latest_orders AS (
  SELECT 
    user_id, 
    order_id AS most_recent_order_id, 
    order_date AS most_recent_order_date
  FROM (
    SELECT 
        user_id, 
        order_id, 
        order_date, 
        ROW_NUMBER() OVER (
          PARTITION BY user_id 
          ORDER BY order_date DESC
          ) as rn
    FROM user_orders) AS order_rankings
  WHERE rn = 1
  ORDER BY user_id
)

SELECT 
  uo.*,
  lo.most_recent_order_id,
  lo.most_recent_order_date
FROM user_orders AS uo
LEFT JOIN latest_orders AS lo
ON uo.user_id = lo.user_id;