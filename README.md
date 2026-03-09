# SQL Portfolio Project #1
## SaaS Revenue & Retention Analysis

Author: Nguyen Giang  
Tools: SQL (PostgreSQL / BigQuery)

---

# Project Overview

This project analyzes a SaaS-style dataset to understand:

• Revenue sources  
• Customer contribution  
• Monthly revenue trends  
• Customer retention behavior  
• Subscription value distribution  

The analysis demonstrates core SQL skills used by data analysts in real business scenarios.

---

# Dataset Structure

### customers
| column | description |
|------|-------------|
customer_id | unique customer identifier  
signup_date | date user signed up  
acquisition_channel | marketing channel source  
segment | customer segment (SMB, Enterprise)

---

### payments
| column | description |
|------|-------------|
customer_id | customer making the payment  
payment_date | payment timestamp  
amount_usd | payment value  
status | payment status (paid / failed)

---

### subscriptions
| column | description |
|------|-------------|
customer_id | subscribed customer  
plan | subscription plan type  
mrr_usd | monthly recurring revenue  
status | subscription status

---

# SQL Analysis

## 1 Revenue by Acquisition Channel

**Goal:** Identify which marketing channels generate the most revenue.

**Key SQL Skills**

- JOIN
- Aggregation
- GROUP BY

**Query**

See:  
`sql/revenue_by_channel.sql`

---

## 2 Monthly Revenue Trend

**Goal:** Track revenue growth over time.

**Business Insight**

Revenue trends reveal:

- business growth
- seasonality
- marketing effectiveness

**Query**

See:  
`sql/monthly_revenue.sql`

---

## 3 Top Customer Contribution

**Goal:** Identify customers contributing the largest share of revenue.

**Key SQL Skills**

- CTE
- Window Functions
- Revenue share calculation

**Query**

See:  
`sql/top_customer_share.sql`

---

## 4 Cohort Retention Analysis

**Goal:** Analyze customer retention behavior over time.

Cohort analysis groups customers by their **first purchase month** and measures retention across future months.

**Key SQL Skills**

- CTE
- Cohort grouping
- Window functions
- Time indexing

**Query**

See:  
`sql/cohort_retention.sql`

---

## 5 MRR by Subscription Plan

**Goal:** Analyze Monthly Recurring Revenue distribution across subscription plans.

This is a key SaaS metric used to evaluate product pricing and plan adoption.

**Query**

See:  
`sql/mrr_per_plan.sql`

---

# Key SQL Skills Demonstrated

- JOIN
- GROUP BY
- Aggregations
- CTE
- Window Functions
- Cohort Analysis
- Revenue Metrics

---

# Repository Structure
---

# Business Value

This analysis demonstrates how SQL can be used to answer key business questions:

• Which channels bring the most valuable customers?  
• How is revenue evolving over time?  
• Who are the highest-value customers?  
• How well do customers retain over time?  
• Which subscription plans generate the most revenue?

---

# Next Improvements

Future enhancements could include:

• churn analysis  
• LTV calculation  
• funnel analysis  
• dashboard visualization (Power BI / Tableau)
