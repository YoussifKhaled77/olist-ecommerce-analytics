# Olist Power BI — DAX Measures Reference

> All measures validated against 99,441 orders (2016–2018)  
> Create a blank table called `_Measures` and add all measures there  
> Calculated columns are added directly to the relevant table

---

## Table of Contents

- [Sales Measures](#-sales-measures)
- [Delivery Measures](#-delivery-measures)
- [Customer Satisfaction Measures](#-customer-satisfaction-measures)
- [Customer Measures](#-customer-measures)
- [Location Measures](#-location-measures)
- [Time Intelligence Measures](#-time-intelligence-measures)
- [Helper / Label Measures](#-helper--label-measures)
- [Calculated Columns](#-calculated-columns)
- [RFM Analysis](#-rfm-analysis)
- [Validation Checklist](#-validation-checklist)

---

## 💰 Sales Measures

### [Total Revenue]
```dax
Total Revenue = 
SUMX(
    olist_order_items,
    olist_order_items[price]
)
```
> **Validated:** R$13,591,643.70 · product price only, excludes freight

---

### [Total Freight]
```dax
Total Freight = 
SUMX(
    olist_order_items,
    olist_order_items[freight_value]
)
```
> **Validated:** R$2,251,909.54

---

### [Gross Revenue]
```dax
Gross Revenue = 
[Total Revenue] + [Total Freight]
```
> **Validated:** R$15,843,553.24 · total billed to customers including shipping

---

### [Total Orders]
```dax
Total Orders = 
DISTINCTCOUNT(olist_orders[order_id])
```
> **Validated:** 99,441

---

### [Total Items Sold]
```dax
Total Items Sold = 
COUNTROWS(olist_order_items)
```
> **Validated:** 112,650

---

### [Avg Order Value]
```dax
Avg Order Value = 
DIVIDE(
    [Total Revenue],
    [Total Orders]
)
```
> **Validated:** R$136.75 · product price only

---

### [Avg Items Per Order]
```dax
Avg Items Per Order = 
DIVIDE(
    [Total Items Sold],
    [Total Orders]
)
```
> **Validated:** 1.142

---

### [Freight Rate %]
```dax
Freight Rate % = 
DIVIDE(
    [Total Freight],
    [Total Revenue]
)
```
> **Validated:** 16.57% · flag with conditional formatting if > 18%

---

### [Avg Freight]
```dax
Avg Freight = 
DIVIDE(
    [Total Freight],
    [Total Items Sold]
)
```
> **Validated:** R$19.98 avg freight per item

---

### [Cancelled Orders]
```dax
Cancelled Orders = 
CALCULATE(
    [Total Orders],
    olist_orders[order_status] = "canceled"
)
```
> **Note:** Spelled "canceled" (one L) in the dataset  
> **Validated:** 625

---

### [Cancellation Rate %]
```dax
Cancellation Rate % = 
DIVIDE(
    [Cancelled Orders],
    [Total Orders]
)
```
> **Validated:** 0.63%

---

### [Unique Products]
```dax
Unique Products = 
DISTINCTCOUNT(olist_order_items[product_id])
```
> **Validated:** 32,951

---

### [% of Total Revenue]
```dax
% of Total Revenue = 
DIVIDE(
    [Total Revenue],
    CALCULATE(
        [Total Revenue],
        ALL(olist_order_items)
    )
)
```
> Use in category / state bar charts to show share alongside absolute value

---

## 🚚 Delivery Measures

### [Delivered Orders]
```dax
Delivered Orders = 
CALCULATE(
    [Total Orders],
    olist_orders[order_status] = "delivered"
)
```
> **Validated:** 96,478

---

### [Delivery Rate %]
```dax
Delivery Rate % = 
DIVIDE(
    [Delivered Orders],
    [Total Orders]
)
```
> **Validated:** 97.01%

---

### [Avg Delivery Days]
```dax
Avg Delivery Days = 
AVERAGEX(
    FILTER(
        olist_orders,
        olist_orders[order_status] = "delivered"
            && NOT ISBLANK(olist_orders[order_delivered_customer_date])
    ),
    DATEDIFF(
        olist_orders[order_purchase_timestamp],
        olist_orders[order_delivered_customer_date],
        DAY
    )
)
```
> **Validated:** 12.09 days avg from purchase to customer door

---

### [On-Time Deliveries]
```dax
On-Time Deliveries = 
CALCULATE(
    COUNTROWS(olist_orders),
    olist_orders[order_status] = "delivered",
    olist_orders[order_delivered_customer_date]
        <= olist_orders[order_estimated_delivery_date]
)
```

---

### [On-Time Rate %]
```dax
On-Time Rate % = 
DIVIDE(
    [On-Time Deliveries],
    [Delivered Orders]
)
```
> **Validated:** 91.88% · TARGET ≥ 90%  
> Conditional formatting: green ≥ 90% / amber ≥ 80% / red < 80%

---

### [Late Deliveries]
```dax
Late Deliveries = 
CALCULATE(
    COUNTROWS(olist_orders),
    olist_orders[order_status] = "delivered",
    NOT ISBLANK(olist_orders[order_delivered_customer_date]),
    olist_orders[order_delivered_customer_date]
        > olist_orders[order_estimated_delivery_date]
)
```
> **Validated:** ~7,827

---

### [Late Rate %]
```dax
Late Rate % = 
DIVIDE(
    [Late Deliveries],
    [Delivered Orders]
)
```
> **Validated:** 8.12%

---

### [Avg Delay Days (Late Only)]
```dax
Avg Delay Days Late = 
AVERAGEX(
    FILTER(
        olist_orders,
        olist_orders[order_status] = "delivered"
            && NOT ISBLANK(olist_orders[order_delivered_customer_date])
            && olist_orders[order_delivered_customer_date]
                > olist_orders[order_estimated_delivery_date]
    ),
    DATEDIFF(
        olist_orders[order_estimated_delivery_date],
        olist_orders[order_delivered_customer_date],
        DAY
    )
)
```
> **Validated:** 8.87 days avg overdue for late orders only

---

## ⭐ Customer Satisfaction Measures

### [Total Reviews]
```dax
Total Reviews = 
COUNTROWS(olist_reviews)
```
> **Validated:** 99,224

---

### [Avg Review Score]
```dax
Avg Review Score = 
AVERAGE(olist_reviews[review_score])
```
> **Validated:** 4.0864

---

### [5 Star Reviews]
```dax
5 Star Reviews = 
CALCULATE(
    [Total Reviews],
    olist_reviews[review_score] = 5
)
```
> **Validated:** 57,328 · 57.78%

---

### [4 Star Reviews]
```dax
4 Star Reviews = 
CALCULATE(
    [Total Reviews],
    olist_reviews[review_score] = 4
)
```
> **Validated:** 19,142

---

### [3 Star Reviews]
```dax
3 Star Reviews = 
CALCULATE(
    [Total Reviews],
    olist_reviews[review_score] = 3
)
```
> **Validated:** 8,179

---

### [2 Star Reviews]
```dax
2 Star Reviews = 
CALCULATE(
    [Total Reviews],
    olist_reviews[review_score] = 2
)
```
> **Validated:** 3,151

---

### [1 Star Reviews]
```dax
1 Star Reviews = 
CALCULATE(
    [Total Reviews],
    olist_reviews[review_score] = 1
)
```
> **Validated:** 11,424

---

### [Positive Rate %]
```dax
Positive Rate % = 
DIVIDE(
    CALCULATE(
        [Total Reviews],
        olist_reviews[review_score] >= 4
    ),
    [Total Reviews]
)
```
> **Validated:** 76.99% · 4+5 star combined

---

### [Negative Rate %]
```dax
Negative Rate % = 
DIVIDE(
    CALCULATE(
        [Total Reviews],
        olist_reviews[review_score] <= 2
    ),
    [Total Reviews]
)
```
> **Validated:** 14.68% · 1+2 star combined

---

### [NPS Proxy]
```dax
NPS Proxy = 
VAR Promoters = CALCULATE(
    [Total Reviews],
    olist_reviews[review_score] = 5
)
VAR Detractors = CALCULATE(
    [Total Reviews],
    olist_reviews[review_score] <= 2
)
RETURN
DIVIDE(
    Promoters - Detractors,
    [Total Reviews]
) * 100
```
> **Validated:** ~43.1 · directional proxy only, not a formal NPS survey

---

### [Avg Score (On-Time Orders)]
```dax
Avg Score On-Time = 
CALCULATE(
    [Avg Review Score],
    olist_orders[Is On Time] = "On Time"
)
```
> **Validated:** 4.29 · confirms delivery drives satisfaction

---

### [Avg Score (Late Orders)]
```dax
Avg Score Late = 
CALCULATE(
    [Avg Review Score],
    olist_orders[Is On Time] = "Late"
)
```
> **Validated:** 2.35 · late delivery = strongly negative review

---

## 👥 Customer Measures

### [Total Customers]
```dax
Total Customers = 
DISTINCTCOUNT(
    olist_customers[customer_unique_id]
)
```
> ⚠️ Use `customer_unique_id` NOT `customer_id` — `customer_id` inflates to 99,441  
> **Validated:** 96,096

---

### [Repeat Customers]
```dax
Repeat Customers = 
SUMX(
    VALUES(olist_customers[customer_unique_id]),
    IF(
        CALCULATE(
            COUNTROWS(olist_orders)
        ) > 1,
        1, 0
    )
)
```
> **Validated:** 2,997

---

### [One-Time Customers]
```dax
One-Time Customers = 
[Total Customers] - [Repeat Customers]
```
> **Validated:** 93,099 · 96.9% of all customers

---

### [Repeat Purchase Rate %]
```dax
Repeat Purchase Rate % = 
DIVIDE(
    [Repeat Customers],
    [Total Customers]
)
```
> **Validated:** 3.12% · critical retention insight

---

### [Avg Customer LTV]
```dax
Avg Customer LTV = 
DIVIDE(
    [Total Revenue],
    [Total Customers]
)
```
> **Validated:** R$141.43

---

### [Total Customer Revenue]
```dax
Total Customer Revenue = 
SUM(customer_lifetime[total_revenue])
```
> Uses `customer_lifetime` pre-aggregated table

---

### [Total Customer Orders]
```dax
Total Customer Orders = 
SUM(customer_lifetime[total_orders])
```

---

### [Avg Order Value (Customer LTV)]
```dax
Avg Order Value CLV = 
AVERAGE(customer_lifetime[avg_order_value])
```

---

## 🗺️ Location Measures

### [Revenue by State]
```dax
Revenue by State = 
CALCULATE(
    [Total Revenue],
    RELATEDTABLE(olist_customers)
)
```
> Place `olist_customers[customer_state]` on axis · supports State → City drill-down

---

### [Orders by State]
```dax
Orders by State = 
CALCULATE(
    [Total Orders],
    RELATEDTABLE(olist_customers)
)
```

---

### [Revenue per Customer by State]
```dax
Revenue per Customer by State = 
DIVIDE(
    [Total Revenue],
    DISTINCTCOUNT(olist_customers[customer_unique_id])
)
```
> Highlights high-value regions with fewer but bigger customers

---

### [% of Total Revenue by Location]
```dax
% of Total Revenue by Location = 
DIVIDE(
    [Total Revenue],
    CALCULATE(
        [Total Revenue],
        ALL(olist_customers[customer_state])
    )
)
```

---

## ⏱️ Time Intelligence Measures

> ⚠️ These measures require a Date table linked to `olist_orders[order_purchase_timestamp]`

### [Revenue MoM %]
```dax
Revenue MoM % = 
VAR Current = [Total Revenue]
VAR Prev = CALCULATE(
    [Total Revenue],
    DATEADD(
        olist_orders[order_purchase_timestamp],
        -1, MONTH
    )
)
RETURN
DIVIDE(Current - Prev, Prev)
```

---

### [Revenue YoY %]
```dax
Revenue YoY % = 
VAR Current = [Total Revenue]
VAR Prev = CALCULATE(
    [Total Revenue],
    DATEADD(
        olist_orders[order_purchase_timestamp],
        -1, YEAR
    )
)
RETURN
DIVIDE(Current - Prev, Prev)
```
> **Validated:** 2017 → 2018: +20% revenue growth

---

### [Revenue PY]
```dax
Revenue PY = 
CALCULATE(
    [Total Revenue],
    DATEADD(
        olist_orders[order_purchase_timestamp],
        -1, YEAR
    )
)
```
> **Validated:** R$6,155,807 · use as comparison value in KPI cards

---

### [Orders MoM %]
```dax
Orders MoM % = 
VAR Current = [Total Orders]
VAR Prev = CALCULATE(
    [Total Orders],
    DATEADD(
        olist_orders[order_purchase_timestamp],
        -1, MONTH
    )
)
RETURN
DIVIDE(Current - Prev, Prev)
```

---

### [Cumulative Revenue YTD]
```dax
Cumulative Revenue YTD = 
CALCULATE(
    [Total Revenue],
    DATESYTD(
        olist_orders[order_purchase_timestamp]
    )
)
```

---

## 🏷️ Helper / Label Measures

### [Delivery Status Label]
```dax
Delivery Status Label = 
SWITCH(TRUE(),
    [On-Time Rate %] >= 0.95, "Excellent",
    [On-Time Rate %] >= 0.90, "Good",
    [On-Time Rate %] >= 0.80, "At Risk",
    "Critical"
)
```

---

### [Freight Risk Label]
```dax
Freight Risk Label = 
IF(
    [Freight Rate %] > 0.18,
    "⚠ High Freight",
    "✓ Within Target"
)
```

---

### [Score Color Band]
```dax
Score Color Band = 
SWITCH(TRUE(),
    [Avg Review Score] >= 4.5, "Excellent",
    [Avg Review Score] >= 4.0, "Good",
    [Avg Review Score] >= 3.5, "Fair",
    "Poor"
)
```

---

### [Customer Segment Label]
```dax
Customer Segment Label = 
SWITCH(TRUE(),
    [Repeat Purchase Rate %] >= 0.05, "High Retention",
    [Repeat Purchase Rate %] >= 0.03, "Low Retention",
    "Critical Retention"
)
```

---

## 🧮 Calculated Columns

> Add these directly to the table — **not** to `_Measures`

### olist_orders → [Delivery Days]
```dax
Delivery Days = 
IF(
    olist_orders[order_status] = "delivered"
        && NOT ISBLANK(olist_orders[order_delivered_customer_date]),
    DATEDIFF(
        olist_orders[order_purchase_timestamp],
        olist_orders[order_delivered_customer_date],
        DAY
    ),
    BLANK()
)
```

---

### olist_orders → [Is On Time]
```dax
Is On Time = 
IF(
    olist_orders[order_status] = "delivered"
        && NOT ISBLANK(olist_orders[order_delivered_customer_date]),
    IF(
        olist_orders[order_delivered_customer_date]
            <= olist_orders[order_estimated_delivery_date],
        "On Time",
        "Late"
    ),
    "N/A"
)
```

---

### olist_orders → [Delay Days]
```dax
Delay Days = 
IF(
    olist_orders[order_status] = "delivered"
        && NOT ISBLANK(olist_orders[order_delivered_customer_date]),
    DATEDIFF(
        olist_orders[order_estimated_delivery_date],
        olist_orders[order_delivered_customer_date],
        DAY
    ),
    BLANK()
)
```
> Negative = arrived early · Positive = arrived late

---

### olist_orders → [Delivery Band]
```dax
Delivery Band = 
SWITCH(TRUE(),
    olist_orders[Delivery Days] <= 5,  "1 - Express (0-5d)",
    olist_orders[Delivery Days] <= 10, "2 - Fast (6-10d)",
    olist_orders[Delivery Days] <= 15, "3 - Standard (11-15d)",
    olist_orders[Delivery Days] <= 20, "4 - Slow (16-20d)",
    olist_orders[Delivery Days] > 20,  "5 - Very Slow (20d+)",
    "N/A"
)
```
> Prefix numbers force correct sort order in visuals

---

### olist_orders → [Order Year]
```dax
Order Year = YEAR(olist_orders[order_purchase_timestamp])
```

---

### olist_orders → [Order Month]
```dax
Order Month = FORMAT(olist_orders[order_purchase_timestamp], "MMM YYYY")
```

---

### olist_orders → [Order Quarter]
```dax
Order Quarter = 
"Q" & QUARTER(olist_orders[order_purchase_timestamp])
& " " & YEAR(olist_orders[order_purchase_timestamp])
```

---

### olist_orders → [Day of Week]
```dax
Day of Week = FORMAT(olist_orders[order_purchase_timestamp], "dddd")
```

---

### olist_orders → [Month Number]
```dax
Month Number = MONTH(olist_orders[order_purchase_timestamp])
```
> Sort `Order Month` by this column to fix alphabetical month ordering

---

### olist_orders → [Month Year Sort]
```dax
Month Year Sort = 
YEAR(olist_orders[order_purchase_timestamp]) * 100 
+ MONTH(olist_orders[order_purchase_timestamp])
```
> Sort `Order Month` by this column for correct chronological order

---

### olist_reviews → [Review Level]
```dax
Review Level = 
SWITCH(
    olist_reviews[review_score],
    5, "5 - Excellent",
    4, "4 - Good",
    3, "3 - Neutral",
    2, "2 - Poor",
    1, "1 - Terrible"
)
```

---

### olist_customers → [Customer Segment]
```dax
Customer Segment = 
VAR OrdCnt = CALCULATE(
    COUNTROWS(olist_orders),
    ALLEXCEPT(
        olist_customers,
        olist_customers[customer_unique_id])
)
RETURN
SWITCH(TRUE(),
    OrdCnt >= 5, "VIP",
    OrdCnt >= 2, "Premium",
    "Standard"
)
```

---

### olist_customers → [customer_state_full]
```dax
customer_state_full = 
"Brazil, " & olist_customers[customer_state]
```
> Use on filled map visual to force Power BI to resolve Brazilian states instead of US states

---

## 📊 RFM Analysis

> Create `RFM_Table` as a new calculated table

### RFM_Table (Calculated Table)
```dax
RFM_Table = 
VAR MaxDate = MAX(olist_orders[order_purchase_timestamp])
RETURN
SUMMARIZE(
    olist_orders,
    olist_customers[customer_unique_id],
    "Recency",
    DATEDIFF(
        MAX(olist_orders[order_purchase_timestamp]),
        MaxDate,
        DAY
    ),
    "Frequency",
    DISTINCTCOUNT(olist_orders[order_id]),
    "Monetary",
    CALCULATE(SUM(olist_order_items[price]))
)
```

---

### RFM_Table → [Recency Score]
```dax
Recency Score = 
SWITCH(TRUE(),
    RFM_Table[Recency] <= 30,  5,
    RFM_Table[Recency] <= 90,  4,
    RFM_Table[Recency] <= 180, 3,
    RFM_Table[Recency] <= 365, 2,
    1
)
```

---

### RFM_Table → [Frequency Score]
```dax
Frequency Score = 
SWITCH(TRUE(),
    RFM_Table[Frequency] >= 5, 5,
    RFM_Table[Frequency] = 4,  4,
    RFM_Table[Frequency] = 3,  3,
    RFM_Table[Frequency] = 2,  2,
    1
)
```

---

### RFM_Table → [Monetary Score]
```dax
Monetary Score = 
SWITCH(TRUE(),
    RFM_Table[Monetary] >= 1000, 5,
    RFM_Table[Monetary] >= 500,  4,
    RFM_Table[Monetary] >= 200,  3,
    RFM_Table[Monetary] >= 100,  2,
    1
)
```

---

### RFM_Table → [RFM Score]
```dax
RFM Score = 
RFM_Table[Recency Score] * 100
+ RFM_Table[Frequency Score] * 10
+ RFM_Table[Monetary Score]
```

---

### RFM_Table → [RFM Segment]
```dax
RFM Segment = 
SWITCH(TRUE(),
    RFM_Table[Recency Score] >= 4
        && RFM_Table[Frequency Score] >= 4, "Champions",
    RFM_Table[Recency Score] >= 3
        && RFM_Table[Frequency Score] >= 3, "Loyal Customers",
    RFM_Table[Recency Score] >= 4
        && RFM_Table[Frequency Score] <= 2, "New Customers",
    RFM_Table[Recency Score] <= 2
        && RFM_Table[Frequency Score] >= 3, "At Risk",
    RFM_Table[Recency Score] <= 2
        && RFM_Table[Frequency Score] <= 2, "Lost",
    "Potential Loyalists"
)
```

---

### RFM_Summary (Calculated Table for visuals)
```dax
RFM_Summary = 
SUMMARIZE(
    RFM_Table,
    RFM_Table[RFM Segment],
    "Avg Frequency", AVERAGE(RFM_Table[Frequency Score]),
    "Avg Monetary",  AVERAGE(RFM_Table[Monetary]),
    "Avg Recency",   AVERAGE(RFM_Table[Recency Score]),
    "Customer Count", COUNTROWS(RFM_Table)
)
```
> Use this table on the RFM treemap / scatter visual — avoids the 96K row grouping error

---

## ✅ Validation Checklist

Paste all measures into a blank table visual to verify:

| Measure | Expected Value |
|---|---|
| [Total Orders] | 99,441 |
| [Total Revenue] | R$13,591,643.70 |
| [Total Freight] | R$2,251,909.54 |
| [Gross Revenue] | R$15,843,553.24 |
| [Avg Order Value] | R$136.75 |
| [Total Items Sold] | 112,650 |
| [Freight Rate %] | 16.57% |
| [Cancelled Orders] | 625 |
| [Delivered Orders] | 96,478 |
| [Delivery Rate %] | 97.01% |
| [Avg Delivery Days] | 12.09 |
| [On-Time Rate %] | 91.88% |
| [Late Deliveries] | ~7,827 |
| [Late Rate %] | 8.12% |
| [Avg Delay Days Late] | 8.87 days |
| [Total Reviews] | 99,224 |
| [Avg Review Score] | 4.09 |
| [5 Star Reviews] | 57,328 |
| [1 Star Reviews] | 11,424 |
| [Positive Rate %] | 76.99% |
| [Negative Rate %] | 14.68% |
| [NPS Proxy] | ~43 |
| [Avg Score On-Time] | 4.29 |
| [Avg Score Late] | 2.35 |
| [Total Customers] | 96,096 |
| [Repeat Customers] | 2,997 |
| [Repeat Purchase Rate %] | 3.12% |
| [Avg Customer LTV] | R$141.43 |
| [Unique Products] | 32,951 |

---

## 📋 Data Model Relationships

| From Table | From Column | To Table | To Column | Cardinality | Direction |
|---|---|---|---|---|---|
| olist_orders | order_id | olist_order_items | order_id | 1 : Many | Single |
| olist_order_items | product_id | olist_product | product_id | Many : 1 | Single |
| olist_orders | order_id | olist_reviews | order_id | 1 : 1 | Single |
| olist_orders | customer_id | olist_customers | customer_id | Many : 1 | Single |
| olist_customers | customer_zip_code_prefix | olist_geolocation | geolocation_zip_code_prefix | Many : 1 | Single |
| customer_lifetime | customer_id | olist_customers | customer_id | 1 : 1 | Single |
| Unique_Customers | customer_unique_id | RFM_Table | customer_unique_id | 1 : Many | Single |

---

*Olist Analytics Project · Power BI DAX Measures · 2016–2018*
