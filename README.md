# 🛒 Olist E-Commerce Analytics

> End-to-end business intelligence project analyzing 99,441 orders from Brazil's largest e-commerce marketplace (2016–2018)

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)

---

## 📌 Project Overview

This project is a complete end-to-end analytics solution built on the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). It covers the full BI workflow:

- **Data exploration & cleaning** with SQL
- **Data modeling** in Power BI (star schema)
- **45+ DAX measures** across 7 analytical domains
- **7-page interactive Power BI dashboard**
- **RFM customer segmentation** analysis
- **3-page executive PDF report** with business recommendations

---

## 📥 Download Power BI File
[Download .pbix file](https://drive.google.com/file/d/1cYFG2K-UFf8BGN4qpBgbifXksffoXE35/view?usp=sharing)

---

## 📊 Key Business Insights

| Metric | Value | Signal |
|--------|-------|--------|
| Total Revenue | R$13.59M | +143% YoY growth |
| Total Orders | 99,441 | Consistent uptrend |
| On-Time Delivery Rate | 91.88% | Above 90% target |
| Avg Review Score | 4.09 / 5.0 | NPS Proxy +43 |
| Repeat Purchase Rate | 3.12% | ⚠️ Critical retention issue |
| Late Deliveries | 7,827 | 8.12% of orders |
| Top Category | Health & Beauty | R$1.26M revenue |
| Top State | São Paulo (SP) | 38.3% of total revenue |

---

## 🗂️ Repository Structure

```
olist-ecommerce-analytics/
│
├── README.md                        ← You are here
│
├── sql/
│   └── olist_queries.sql            ← All SQL queries used in the project
│   └── Data_Loading_Script.sql            ← Loading data into the database
│
├── powerbi/
│   └── dax_measures.md              ← All 45+ DAX measures with validation values
│
├── Olist_Analytics_Report.pdf   ← 3-page executive PDF report
|
└── assets/
    ├── overview.png                 ← Dashboard screenshots
    ├── sales.png
    ├── products.png
    ├── customers.png
    ├── delivery.png
    ├── location.png
    └── satisfaction.png
```

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **SQL** | Data exploration, cleaning, and initial analysis |
| **Power BI Desktop** | Data modeling, DAX measures, dashboard |
| **DAX** | 45+ measures across sales, delivery, satisfaction, RFM |
| **Power Query (M)** | Data transformation and preparation |

---

## 📁 Dataset

The dataset is from [Kaggle — Brazilian E-Commerce by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

| Table | Rows | Description |
|-------|------|-------------|
| `olist_orders` | 99,441 | Orders with status, timestamps, customer |
| `olist_order_items` | 112,650 | Line items with price and freight |
| `olist_customers` | 99,441 | Customer location data |
| `olist_products` | 32,951 | Product metadata and category |
| `olist_reviews` | 99,224 | Customer review scores and comments |
| `olist_geolocation` | 1,000,163 | Zip code lat/lng mapping |
| `product_category_name_translation` | 71 | Portuguese → English category names |
| `customer_lifetime` | custom | Pre-aggregated customer LTV table |

---

## 🗃️ Data Model

Star schema with the following relationships:

```
olist_orders (1) ──────── (N) olist_order_items
olist_order_items (N) ─── (1) olist_product
olist_orders (1) ──────── (1) olist_reviews
olist_orders (N) ──────── (1) olist_customers
olist_customers (N) ───── (1) olist_geolocation
customer_lifetime (1) ─── (1) olist_customers
Unique_Customers (1) ──── (N) RFM_Table
```

---

## 📋 Dashboard Pages

The Power BI dashboard contains **7 pages**:

### Page 1 — Executive Overview
- 4 KPI cards: Revenue, Orders, Customers, Avg Review Score
- Revenue by Month line chart
- Orders by Month column chart
- Delivery Performance donut
- Top 5 States by Revenue bar chart
- Slicers: Year, Month, State, Delivery Performance

### Page 2 — Sales Performance
- 3 KPI cards: Revenue, Orders, Avg Order Value
- Monthly revenue area chart with **Year → Quarter → Month drill-down**
- Monthly Sales Matrix table
- Revenue by Day of Week bar chart
- Slicers: Year, Customer State

### Page 3 — Product Performance
- 3 KPI cards: Total Products, Top Product Revenue, Avg Items/Order
- Top 10 Products by Revenue horizontal bar
- Top 8 Categories by Revenue horizontal bar
- Category Matrix: Revenue / Orders / Avg Freight
- **Drill-through** to Product Details page

### Page 4 — Customers
- 3 KPI cards: Total Customers, Repeat Customers, Avg LTV
- Customer growth line chart
- Customer Segments bar chart (RFM)
- Customer Type donut (One-time vs Repeat)
- Top 10 Customers by Revenue table
- **RFM Treemap**: Champions, Loyal, New, At Risk, Lost, Potential

### Page 5 — Delivery Performance
- 4 KPI cards: Avg Delivery Days, On-Time Rate, Total Freight, Late Deliveries
- Avg Delivery Days by Month line chart with **Year → Month drill-down**
- On-Time Rate Trend line chart
- Delivery Time Distribution bar chart
- Monthly Delivery Metrics matrix

### Page 6 — Location
- 4 KPI cards: Active States, Top State, Unique Cities, SE Region Share
- **Brazil filled map** (choropleth) by state revenue
- Top 8 States by Revenue column chart
- Regional Breakdown donut
- **State → City drill-down** support

### Page 7 — Review & Satisfaction
- 4 KPI cards: Avg Score, 5-Star, 1-Star, NPS Proxy
- Top 10 Categories by Review score bar chart
- On-Time Rate vs Avg Review combo chart
- Delivery Days vs Review Score scatter plot
- Review Score Distribution donut

---

## 📐 DAX Measures Summary

All measures are in [`powerbi/dax_measures.md`](powerbi/dax_measures.md)

| Category | Count | Key Measures |
|----------|-------|-------------|
| Sales | 12 | Total Revenue, Avg Order Value, Freight Rate % |
| Delivery | 10 | On-Time Rate %, Avg Delivery Days, Late Rate % |
| Satisfaction | 12 | Avg Review Score, NPS Proxy, Score by delivery |
| Customers | 8 | Repeat Rate %, Avg LTV, RFM Segments |
| Location | 4 | Revenue by State, Revenue per Customer |
| Time Intel | 5 | Revenue MoM %, Revenue YoY %, YTD |
| Helper / Labels | 4 | Delivery Status Label, Score Color Band |
| **Total** | **45+** | |

---

## 🔍 Key Findings

### Sales
- Revenue grew **8x in 15 months** (Jan 2017 → Apr 2018)
- **Black Friday Nov 2017**: R$1.01M — 52% above any other month
- Top 3 categories (**Health & Beauty**, Watches & Gifts, Bed & Bath) = 24% of revenue

### Delivery
- **91.88% on-time rate** overall — above 90% target
- **March 2018 crisis**: on-time rate dropped to 78.6%, avg delivery spiked to 15.9 days
- Freight costs **16.6% of revenue** — margin risk if exceeds 18%

### Customers
- **96.9% of customers** buy only once — critical retention problem
- **68,051 customers** classified as "Lost" in RFM analysis
- Average customer LTV: **R$141.43**

### Satisfaction
- **57.8% are 5-star reviews** — strong positive skew
- On-time orders avg **4.29★** vs late orders avg **2.35★** — delivery drives satisfaction
- **March 2018 score dip** to 3.75★ directly correlates with delivery crisis

### Geography
- **São Paulo** = 38.3% of all revenue (R$5.2M)
- **Southeast region** (SP + RJ + MG) = 64.1% of total revenue
- Northern states (AM, PA, RO) each under 1% — growth opportunity

---

## 💡 Business Recommendations

| Priority | Action | Impact |
|----------|--------|--------|
| 🔴 CRITICAL | Launch customer loyalty program | +2% repeat rate ≈ R$270K/year |
| 🔴 CRITICAL | Win-back campaign for 68,051 Lost customers | Reactivate largest RFM segment |
| 🟡 HIGH | Investigate March 2018 delivery failure | Prevent recurrence of crisis |
| 🟡 HIGH | Reduce freight cost below 16% | Protect revenue margins |
| 🔵 MEDIUM | Expand top category SKU depth | Health & Beauty + Watches = R$2.46M |
| 🔵 MEDIUM | Expand to Northern states | Low competition, high growth potential |
| 🟢 MONITOR | Maintain delivery above 90% on-time | Set automated alerts |

---

## 🚀 How to Use

### Power BI Dashboard
1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. Load all CSV files into Power BI Desktop
3. Apply the data model relationships listed in [`powerbi/dax_measures.md`](powerbi/dax_measures.md)
4. Create the calculated columns and measures from the DAX file
5. Build the visuals following the page structure above

### SQL Queries
1. Load the CSV files into your preferred SQL database (PostgreSQL / MySQL / SQLite)
2. Run the queries in [`sql/olist_queries.sql`](sql/olist_queries.sql)

---

## 📄 Report

The executive report is available in [`report/Olist_Analytics_Report.pdf`](report/Olist_Analytics_Report.pdf)

**Contents:**
- Page 1: Executive Summary with 8 KPI cards and health check table
- Page 2: Performance deep dive (Sales, Products, Customers, Delivery, Satisfaction)
- Page 3: Regional analysis and 7 prioritized business recommendations

---

## 👤 Author

Built as a complete end-to-end BI portfolio project covering:
- SQL data analysis
- Power BI data modeling and DAX
- Dashboard design and UX
- Executive reporting

---

## 📜 License

This project is licensed under the MIT License.  
Dataset is publicly available on Kaggle under the [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.

---

*Olist E-Commerce Analytics · Brazil · 2016–2018*
