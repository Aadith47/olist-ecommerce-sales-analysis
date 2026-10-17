# Olist E-Commerce: Late Deliveries and Bad Reviews

**Question:** Are late deliveries linked to bad reviews, and how much sales value sits in late, unhappy orders?

## Summary

I used SQL on about 99K orders from a Brazilian online marketplace. Late deliveries are rare (6.8% of delivered orders), but they are strongly linked to bad reviews. Orders that arrive more than 7 days late average 1.70 stars, against 4.29 stars for on-time orders. About 4.7% of delivered sales value (R$ 720K of R$ 15.4M) is tied to late orders that got a 1 or 2 star review.

## Key findings

1. **Late deliveries are rare.** 6,534 of 96,470 delivered orders (6.8%) arrived after the promised date.
2. **Reviews drop as the delay grows.**

   | Delivery | Orders | Average review score |
   |---|---|---|
   | On time or early | 89,443 | 4.29 |
   | 1-3 days late | 1,852 | 3.29 |
   | 4-7 days late | 1,748 | 2.11 |
   | More than 7 days late | 2,781 | 1.70 |

3. **Late orders are often very late.** Of the 6,381 late orders that have a review, 2,781 (44%) arrived more than 7 days late.
4. **Money at risk.** 3,979 late orders got a 1 or 2 star review. Their value (price plus freight) is about R$ 720K, which is 4.7% of the R$ 15.4M of delivered sales.
5. **Late delivery is not the only cause.** About 11K reviews gave 1 star, but only 6,534 orders were late. Lateness explains part of the bad reviews, not all of them.

Money values are in Brazilian reais (R$). "Money at risk" is the value of the orders, not proven lost revenue.

## Approach

1. Load the CSV files into a SQLite database with Python.
2. Check the data: order statuses, orders per month, missing dates, duplicate reviews.
3. Measure how late each order was (delivered date minus promised date).
4. Compare review scores for on-time and late orders.
5. Estimate the money at risk and its share of delivered sales.

## Method and data checks

- **Late** means the delivery date is later than the promised date. I compare calendar days, not exact times, because the promised date has no time of day.
- **One score per order.** Some orders have more than one review row, so I average the scores for each order first.
- **Orders used.** Lateness is measured only for delivered orders that have a delivery date. 646 delivered orders have no review, so they are left out of the review comparison.
- **No double counting.** Price plus freight is added up per order before joining to reviews.
- **Speed.** I added indexes on `order_id`, because the joins were very slow without them.

## Recommendations

These are ideas based on the findings so far. They are not proven fixes.

- **Focus on the longest delays first.** Orders more than 7 days late score the lowest (1.70) and make up 44% of late orders.
- **Make delivery promises more realistic.** Even 1-3 days late costs about 1 star, so a safer estimate may protect reviews.
- **Warn customers early** when an order is going to be late, and follow up with them.
- **Find where the lateness happens** (state, seller, product category) before choosing fixes. This is the next analysis.

## Limitations

- This is a public dataset. It may not match the full business.
- A link is not proof of cause. A late order and a bad review can both come from another problem, such as a product issue.
- Review scores are averaged per order, and orders with no review are excluded from the score comparison.
- Money at risk is an estimate. Some customers may have been refunded or may have bought again.

## Next steps

- [x] Load the data and run the first checks
- [x] Late rate, review scores by delay, money at risk
- [ ] Late rate by customer state, product category, and seller
- [ ] Charts in Python (pandas, matplotlib)
- [ ] Dashboard in Tableau Public
- [ ] Optional: a basic model to predict bad reviews

## How to run

1. Download the **Brazilian E-Commerce Public Dataset by Olist** from Kaggle and put the CSV files in a folder called `data/`.
2. Install pandas (`pip install pandas`) and run `python load_data.py`. This creates `olist.db`.
3. Open `olist.db` in DB Browser for SQLite and go to the Execute SQL tab.
4. Run the index block at the top of `queries.sql` once, press Write Changes, then run the queries one at a time.

The raw CSV files are not in this repo. Download them from Kaggle.

## Repo structure

```
load_data.py     loads the CSV files into olist.db
queries.sql      indexes and SQL queries 1-6
README.md        this file
data/            raw CSVs (not committed, see .gitignore)
```

## Skills used

SQL (joins, CTEs, CASE WHEN, aggregation, indexes), Python (pandas), data cleaning, defining business metrics.

## Disclaimer

Unofficial analysis of a public dataset. Not affiliated with Olist.