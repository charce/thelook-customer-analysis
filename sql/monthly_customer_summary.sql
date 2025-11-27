-- monthly_customer_summary.sql

-- aggregate customer data and perform rolling monthly calculations
  -- group data by user_id to calculate total_orders
  -- add flags for customer status
    -- is_new_customer = TRUE if customer signed up within last 30 days
    -- customer status inactive = after 12 months

-- source:
  -- merch-funnel.customer_analysis.complete_customer_data

CREATE OR REPLACE TABLE
  `merch-funnel.customer_analysis.monthly_customer_summary` AS
WITH month_calendar AS (
  SELECT
    month_start
  FROM UNNEST(
    GENERATE_DATE_ARRAY(
      (
        SELECT MIN(DATE_TRUNC(DATE(signup_date), MONTH)) 
        FROM `merch-funnel.customer_analysis.complete_customer_data`
      ),
      DATE_TRUNC(CURRENT_DATE(), MONTH),
      INTERVAL 1 MONTH
      )
    ) AS month_start
),

customers AS (
  -- one row per customer
  SELECT
    user_id,
    ANY_VALUE(first_name) AS first_name,
    ANY_VALUE(last_name) AS last_name,
    ANY_VALUE(email) AS email,
    ANY_VALUE(age) AS age,
    ANY_VALUE(gender) AS gender,
    ANY_VALUE(state) AS state,
    ANY_VALUE(city) AS city,
    ANY_VALUE(country) AS country,
    ANY_VALUE(traffic_source) AS traffic_source,
    MIN(DATE(signup_date)) AS signup_date,
    DATE_TRUNC(MIN(DATE(signup_date)), MONTH) AS signup_month
  FROM `merch-funnel.customer_analysis.complete_customer_data`
  GROUP BY user_id
),

orders_by_month AS (
  -- for each month and customer:
    -- compute cumulative total_orders up to snapshot_month
    -- compute most recent order date up to snapshot_month
  SELECT
    m.month_start AS snapshot_month,
    c.user_id,
    -- rolling total orders as of this month
    COUNT(DISTINCT CASE
      WHEN DATE_TRUNC(DATE(o.order_date), MONTH) <= m.month_start
      THEN o.order_id
    END) AS total_orders_to_date,
    -- most recent order as of this month
    MAX(CASE
      WHEN DATE_TRUNC(DATE(o.order_date), MONTH) <= m.month_start
      THEN o.order_date
    END) AS most_recent_order_date_to_date
  FROM month_calendar AS m
  JOIN customers AS c
    ON c.signup_month <= m.month_start -- only months on/after signup
  LEFT JOIN `merch-funnel.customer_analysis.complete_customer_data` AS o
    ON o.user_id = c.user_id
  GROUP BY snapshot_month, c.user_id
),

monthly_customer_summary AS (
  -- attach customer attributes and status flags to each customer-month pairing
  SELECT
    o.snapshot_month,
    c.user_id,
    c.first_name,
    c.last_name,
    c.email,
    c.age,
    c.gender,
    c.state,
    c.city,
    c.country,
    c.traffic_source,
    c.signup_date,
    c.signup_month,
    o.total_orders_to_date AS total_orders,
    o.most_recent_order_date_to_date AS most_recent_order_date,
    -- new customer if signup_month = snapshot_month
    (c.signup_month = o.snapshot_month) AS is_new_customer,
    -- status as of snapshot_month, using only orders up to that month
    CASE
      WHEN c.signup_month = o.snapshot_month THEN 'new'
      WHEN o.most_recent_order_date_to_date IS NULL THEN 'inactive'
      WHEN DATE_DIFF(
             o.snapshot_month,
             DATE_TRUNC(DATE(o.most_recent_order_date_to_date), MONTH),
             MONTH
           ) <= 12
        THEN 'active' -- last order within 12 months
      ELSE 'inactive' -- last order more than 12 months ago
    END AS status
  FROM orders_by_month AS o
  JOIN customers AS c
    ON c.user_id = o.user_id
)

SELECT
  *
FROM monthly_customer_summary
ORDER BY snapshot_month, user_id;