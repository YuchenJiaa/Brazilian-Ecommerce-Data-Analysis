--get revenue by location
select o.order_id, order_purchase_timestamp, customer_unique_id, 
		customer_zip_code_prefix, customer_city, customer_state, 
		geolocation_lat, geolocation_lng, sum(price) as revenue
from olist_orders_dataset o
join olist_customers_dataset c
on o.customer_id = c.customer_id
join olist_order_items_dataset oItem
on o.order_id = oItem.order_id
join olist_geolocation_dataset g
on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
where order_status != 'canceled' and order_status != 'unavailable'
group by o.order_id, order_purchase_timestamp, customer_unique_id,
		customer_zip_code_prefix, customer_city, customer_state,
		geolocation_lat, geolocation_lng

--get popular products by state that in top 3 revenue via price
select o.order_id, order_purchase_timestamp, customer_unique_id, product_category_name,
		customer_zip_code_prefix, customer_city, customer_state, 
		geolocation_lat, geolocation_lng, sum(price) as revenue
from olist_orders_dataset o
join olist_customers_dataset c
on o.customer_id = c.customer_id
join olist_order_items_dataset oItem
on o.order_id = oItem.order_id
join olist_geolocation_dataset g
on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
join olist_products_dataset p
on oItem.product_id = p.product_id
where order_status != 'canceled' and order_status != 'unavailable' and customer_state in ('SP', 'MG', 'RJ')
group by o.order_id, order_purchase_timestamp, customer_unique_id,
		customer_zip_code_prefix, customer_city, customer_state,
		geolocation_lat, geolocation_lng, product_category_name

--get active user and average price by state
select  count(distinct customer_unique_id) as ActiveUser, customer_state, round(cast(avg(price) as decimal (10,2)), 2) as AveragePrice
from olist_orders_dataset o
join olist_customers_dataset c
on o.customer_id = c.customer_id
join olist_order_items_dataset oItem
on o.order_id = oItem.order_id
where order_status != 'canceled' and order_status != 'unavailable'
group by customer_state

