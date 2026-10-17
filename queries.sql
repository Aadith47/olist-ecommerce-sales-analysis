-- Olist project: SQL queries
-- run one query at a time (select it, then press Execute)


-- 0. speed-up indexes (run once, before query 5, then press Write Changes)
-- without these, the joins in queries 5 and 6 can take a very long time
create index if not exists idx_reviews_order on order_reviews(order_id);
create index if not exists idx_items_order on order_items(order_id);
create index if not exists idx_orders_order on orders(order_id);


-- 1. how many orders for each status?
select order_status, count(*) as total_orders
from orders
group by order_status
order by total_orders desc;


-- 2. orders per month (shows the date range and the trend)
select
    strftime('%Y-%m', order_purchase_timestamp) as month,
    count(*) as total_orders
from orders
group by month
order by month;


-- 3. how many delivered orders came late?
-- late = delivered after the date we promised the customer (we compare days, not times)
select
    count(*) as delivered_orders,
    sum(case when date(order_delivered_customer_date) > date(order_estimated_delivery_date) then 1 else 0 end) as late_orders,
    round(100.0 * sum(case when date(order_delivered_customer_date) > date(order_estimated_delivery_date) then 1 else 0 end) / count(*), 1) as late_percent
from orders
where order_status = 'delivered'
  and order_delivered_customer_date is not null;


-- 4. do late deliveries get worse reviews? (the main question)
-- an order can have more than one review row, so first we take one score per order
with review_per_order as (
    select order_id, avg(review_score) as review_score
    from order_reviews
    group by order_id
),
delivery as (
    select
        order_id,
        julianday(date(order_delivered_customer_date)) - julianday(date(order_estimated_delivery_date)) as days_late
    from orders
    where order_status = 'delivered'
      and order_delivered_customer_date is not null
)
select
    case
        when d.days_late <= 0 then '1. on time or early'
        when d.days_late <= 3 then '2. 1-3 days late'
        when d.days_late <= 7 then '3. 4-7 days late'
        else '4. more than 7 days late'
    end as delivery_group,
    count(*) as total_orders,
    round(avg(r.review_score), 2) as avg_review_score
from delivery d
join review_per_order r on d.order_id = r.order_id
group by delivery_group
order by delivery_group;


-- 5. money at risk = money from orders that came late AND got a bad review (1 or 2 stars)
-- we add up price + freight for each order first, so no order is counted twice
with review_per_order as (
    select order_id, avg(review_score) as review_score
    from order_reviews
    group by order_id
),
order_value as (
    select order_id, sum(price + freight_value) as order_total
    from order_items
    group by order_id
)
select
    count(*) as late_and_unhappy_orders,
    round(sum(v.order_total), 2) as money_at_risk
from orders o
join review_per_order r on o.order_id = r.order_id
join order_value v on o.order_id = v.order_id
where o.order_status = 'delivered'
  and o.order_delivered_customer_date is not null
  and date(o.order_delivered_customer_date) > date(o.order_estimated_delivery_date)
  and r.review_score <= 2;


-- 6. what share of delivered sales is the money at risk?
-- same as query 5, divided by the total sales of delivered orders
with review_per_order as (
    select order_id, avg(review_score) as review_score
    from order_reviews
    group by order_id
),
order_value as (
    select order_id, sum(price + freight_value) as order_total
    from order_items
    group by order_id
),
total_delivered as (
    select sum(v.order_total) as delivered_sales
    from orders o
    join order_value v on o.order_id = v.order_id
    where o.order_status = 'delivered'
),
at_risk as (
    select sum(v.order_total) as money_at_risk
    from orders o
    join review_per_order r on o.order_id = r.order_id
    join order_value v on o.order_id = v.order_id
    where o.order_status = 'delivered'
      and o.order_delivered_customer_date is not null
      and date(o.order_delivered_customer_date) > date(o.order_estimated_delivery_date)
      and r.review_score <= 2
)
select
    round(a.money_at_risk, 2) as money_at_risk,
    round(t.delivered_sales, 2) as delivered_sales,
    round(100.0 * a.money_at_risk / t.delivered_sales, 1) as percent_at_risk
from at_risk a, total_delivered t;


-- 7. late percent by customer state
-- we skip states with fewer than 100 delivered orders, because their percent is not reliable
select
    customer_state,
    count(*) as delivered_orders,
    sum(case when date(order_delivered_customer_date) > date(order_estimated_delivery_date) then 1 else 0 end) as late_orders,
    round(100.0 * sum(case when date(order_delivered_customer_date) > date(order_estimated_delivery_date) then 1 else 0 end) / count(*), 1) as late_percent
from orders o
join customers c on o.customer_id = c.customer_id
where order_status = 'delivered'
  and order_delivered_customer_date is not null
group by customer_state
having count(*) >= 100
order by late_percent desc;


-- 8. late percent by product category
-- count(distinct order_id) counts each order once per category
-- left join keeps products whose category has no English name (coalesce falls back to another name)
select
    coalesce(t.product_category_name_english, p.product_category_name, 'unknown') as category,
    count(distinct o.order_id) as delivered_orders,
    count(distinct case when date(o.order_delivered_customer_date) > date(o.order_estimated_delivery_date) then o.order_id end) as late_orders,
    round(100.0 * count(distinct case when date(o.order_delivered_customer_date) > date(o.order_estimated_delivery_date) then o.order_id end) / count(distinct o.order_id), 1) as late_percent
from orders o
join order_items i on o.order_id = i.order_id
join products p on i.product_id = p.product_id
left join category_translation t on p.product_category_name = t.product_category_name
where o.order_status = 'delivered'
  and o.order_delivered_customer_date is not null
group by category
having count(distinct o.order_id) >= 100
order by late_percent desc;


-- optional next: which sellers have the most late orders? (orders -> order_items -> sellers)