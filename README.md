# TheLook eCommerce Analytics Dashboard

Multi-page analytics dashboard built on Google BigQuery’s public **TheLook eCommerce** dataset.
Includes a **Yearly Summary** page, a **Sales Analysis** page, and an interactive **Monthly Customer Analysis** experience (with a drill-through **Customer Details** explorer).

I modeled customer status over time (active / inactive / new), built a rolling **monthly customer snapshot** in BigQuery, created monthly sales aggregates, and combined them into a Looker Studio report.

---

## Live dashboard

🔗 **Interactive report:**  
[Customer Analysis – Looker Studio](https://lookerstudio.google.com/s/nk38J66QtYs)

---

## Dashboard export (PDF)

[theLook Analysis Dashboard (PDF)](thelook_analysis_dashboard.pdf)

Note: The PDF is a static export. The live Looker Studio report contains filters, drill-through navigation, and interactive tooltips.

--- 

## Pages included

1) Summary (Year view)
A high-level executive view of performance by year (year-grain KPIs and trends).

2) Sales Analysis
Sales performance trends and breakdowns using monthly aggregates:
- Revenue, Orders, Units Sold, AOV, Units/Order over time
- Breakdowns by category and geography
- Top products contribution

3) Monthly Customer Analysis (Month view)
The main customer page is **month-grain** and centered around a **Snapshot Month** selector (Nov. 2025 by default), including:
  - Total/Active/Inactive/New customers
  - Order activity context (e.g., total orders to date, avg. orders/customer)
  - Acquisition, demographic, and geography breakdowns
  - A “Full Customer Details” drill-through path for deeper exploration

4) Customer Details (Drill-through)
The Customer Details page is a drill-through destination from Monthly Customer Analysis (via "Full Customer Details"), intended for deeper segmentation and record-level exploration.

---

## Filter behavior

Different pages use different grains, so filters are intentionally page-appropriate:

- Summary page = Year grain (year selector / year-based context)
- Monthly Customer Analysis = Snapshot Month grain 
- Customer Details = Drill-through Drill-through context
  - reached from the Monthly page
  - used for segmentation and exploration

---

## Business questions

This project is designed to answer questions a retail / e-commerce team would care about:

### Customer questions
1. **How many customers do we have, and how many are active vs inactive each month?**  
2. **Is the customer base growing healthily, or are we accumulating churned customers?**  
3. **Which traffic sources drive the most customers?**  
4. **What does our customer base look like by age, gender, and geography?**  
5. **Can stakeholders drill into specific segments (e.g., “Active US customers, age 20–25, in Nov 2025”)?**

### Sales questions
6. **How are revenue, orders, and units trending over time?**
7. **What time periods, product areas, or segments are driving growth/decline?**
8. **How do sales patterns line up with customer growth, churn, and acquisition mix?**
---

## Key metrics & definitions

### Customer metrics (monthly snapshot)
- **Total Customers** - distinct users in the dataset
- **New Customers** - customers whose signup month equals the snapshot month
- **Active Customers** - customers whose most recent order is within the last 12 months (as of the snapshot month)
- **Inactive Customers** - customers who never ordered or whose last order was more than 12 months before the snapshot month
- **Active Share of Customers (%)** - Active Share = (Active Customers + New Customers) / Total Customers (snapshot month)
- **Total Orders to Date** - cumulative orders up to the snapshot month
- **Avg. Orders/Customer** - total orders to date / total customers

### Sales metrics (monthly aggregates)
- **Revenue** – sum of sale_price from order items (excluding Cancelled/Returned)
- **Orders** – distinct order_id
- **Units Sold** – count of order items (excluding Cancelled/Returned)
- **AOV** – revenue ÷ orders
- **Units/Order** – units sold ÷ orders

---

## Tech stack

- **Warehouse:** Google BigQuery  
- **Dataset:** `bigquery-public-data.thelook_ecommerce`  
- **Modeling:** StandardSQL (BigQuery)  
- **BI tool:** Looker Studio  

---

## Data source

This project uses Google’s public **TheLook eCommerce** dataset:

- Dataset: `bigquery-public-data.thelook_ecommerce`
- Tables used:
  - `bigquery-public-data.thelook_ecommerce.users`
  - `bigquery-public-data.thelook_ecommerce.orders`
  - `bigquery-public-data.thelook_ecommerce.order_items`
  - `bigquery-public-data.thelook_ecommerce.products`

TheLook is a **fictitious** online clothing store; the data is synthetic and intended for analytics demos and education.

---

## SQL pipeline

All transformation logic lives in the `sql/` directory.

### Customer modeling (monthly snapshot) 

1) `complete_customer_data.sql`
Joins `users` + `orders` into a customer–order base table and attaches each customer’s most recent order.
  Output: `merch-funnel.customer_analysis.complete_customer_data`

2) `monthly_customer_summary.sql`
Builds a rolling monthly snapshot (grain: `snapshot_month` × `user_id`) with:
- cumulative total orders as of the snapshot month
- most recent order date as of the snapshot month
- status $\varepsilon$ {new, active, inactive}
  Output: `merch-funnel.customer_analysis.monthly_customer_summary`

3) `monthly_customer_kpis.sql`
Aggregates snapshot data to month-level KPIs (grain: `snapshot_month`) for dashboard scorecards and trends.
  Output: `merch-funnel.customer_analysis.monthly_customer_kpis`

### Sales modeling (monthly aggregates) 

4) `monthly_sales_overview.sql`
Monthly sales performance (grain: `month`): revenue, orders, units, AOV, units/order.
  Output: `merch-funnel.sales_analysis.monthly_sales_overview`

5) `monthly_sales_by_category.sql`
Monthly sales by product category (grain: `month × category`).
  Output: `merch-funnel.sales_analysis.monthly_sales_by_category`

6) `monthly_sales_by_geo.sql`
Monthly sales by customer category (grain: `month × country`).
  Output: `merch-funnel.sales_analysis.monthly_sales_by_geo`

7) `top_products_overall.sql`
Top products overall (grain: product) with revenue share of total.
  Output: `merch-funnel.sales_analysis.top_products_overall`

8) `monthly_sales_by_customer_type.sql`
Bridge table linking sales to customer status (grain: `month × customer_type`) by joining order activity to the monthly customer snapshot.
  Output: `merch-funnel.sales_analysis.monthly_sales_by_customer_type`

9) `overall_summary.sql`
Combined monthly dataset used on the Summary page (grain: `month`) joining sales overview + customer KPIs.
  Output: `merch-funnel.sales_analysis.overall_summary`

---

## Interactivity

- Month-grain customer exploration via the Snapshot Month control
- Drill-through to Customer Details for deeper segmentation
- Page-level filtering to prevent grain mismatches (Year view vs Month view)

---

## How to reproduce

1. Create a Google Cloud project and enable **BigQuery**.  
2. Create datasets: 
  - `merch-funnel.customer_analysis` 
  - `merch-funnel.sales_analysis`  
3. Run SQL scripts in order:
  1. `complete_customer_data.sql`
  2. `monthly_customer_summary.sql`
  3. `monthly_customer_kpis.sql`
  4. `monthly_sales_overview.sql`
  5. `monthly_sales_by_category.sql`
  6. `monthly_sales_by_geo.sql`
  7. `top_products_overall.sql`
  8. `monthly_sales_by_customer_type.sql`
  9. `overall_summary.sql`
4. In Looker Studio, connect the resulting tables and recreate visuals (or copy the shared report and repoint the data sources).

---

## Next steps (future work)

- Add cohort analysis (retention by signup month).  
- Build a session-based funnel (browse → cart → purchase).  
- Add revenue-per-customer / CLV proxy metrics using the snapshot pattern
