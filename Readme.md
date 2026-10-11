# Olist E-Commerce: Late Deliveries and Bad Reviews

**Question:** Do late deliveries lead to bad reviews, and how much sales value is in those late, unhappy orders?

> Status: in progress. Results marked **[TO FILL]** will be added after the queries are run.

## Dataset

Brazilian E-Commerce Public Dataset by Olist (Kaggle). About 99K orders from a Brazilian online marketplace, spread over linked tables: `orders`, `order_items`, `order_reviews`, `order_payments`, `customers`, `products`, `sellers`.

The raw CSV files are **not** included in this repo. Download them from Kaggle and place them in a folder called `data/`.

## Tools

- SQL (SQLite via DB Browser for SQLite): data analysis
- Python (pandas, matplotlib): exploratory analysis and charts
- Tableau Public: dashboard

## How to run

1. Download the dataset from Kaggle and put the CSV files in `data/`.
2. Run `python load_data.py`. This creates `olist.db`.
3. Open `olist.db` in DB Browser for SQLite and run the queries in `queries.sql`.

## Key steps

1. **Load and check the data:** count rows, check date columns, and confirm the table joins work.
2. **Review scores:** the score split is 1-star and 5-star heavy. Score 5: about 57K. Score 4: about 19K. Score 1: about 11K.
3. **Delivery delay:** compare the delivered date with the estimated date. An order is "late" if delivered after the estimate.
4. **Late vs review score:** average review score by how many days late. **[TO FILL]**
5. **Money at risk:** sales value of late orders with a 1- or 2-star review. **[TO FILL]**
6. **Where the problem is:** late rate by state and by product category. **[TO FILL]**
7. **Dashboard:** key numbers and charts in Tableau Public. **[TO FILL: link]**

## Findings

- **[TO FILL]** Late rate across all delivered orders.
- **[TO FILL]** Average review score for on-time vs late orders.
- **[TO FILL]** Money in late, unhappy orders, and its share of total sales.

## Recommendations

- **[TO FILL]** Three actions the company could take, based on the findings.

## Limitations

- The data is a public sample. It may not match Olist's full business.
- Delivery dates can be missing for some orders. Those rows are left out of lateness checks.
- Correlation is not cause. A late order and a bad review can both come from a third factor, such as a problem with the product.

## Repo structure

```
load_data.py     loads the CSV files into olist.db
queries.sql      SQL queries used in the analysis
data/            raw CSVs (not committed, see .gitignore)
README.md        this file
```

## Disclaimer

Unofficial analysis using a public dataset. Not affiliated with Olist.