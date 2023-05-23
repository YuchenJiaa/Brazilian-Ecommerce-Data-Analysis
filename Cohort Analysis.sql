select customer_id, count(*)
from olist_orders_dataset
group by customer_id
order by count(*) desc

select customer_unique_id, count(*)
from olist_customers_dataset
group by customer_unique_id
order by count(*) desc

--Retention and repurchase
--get Repurchase Rate
with cte_countCustomer as (
  select 
    count(*) [Total Customers] 
  from 
    (
      select 
        c.customer_unique_id, 
        count(*) countCustomer 
      from 
        olist_customers_dataset c 
        join olist_orders_dataset o on c.customer_id = o.customer_id 
      group by 
        c.customer_unique_id
    ) countCustomer
), 
cte_countRepurchased as (
  select 
    count(*) [Total Repurchased Customers] 
  from 
    (
      select 
        c.customer_unique_id, 
        count(*) orderTimes 
      from 
        olist_customers_dataset c 
        join olist_orders_dataset o on c.customer_id = o.customer_id 
      group by 
        c.customer_unique_id 
      having 
        count(*) > 1
    ) countRepurchased
) 
select 
  cast(
    round(
      (
        cte_countRepurchased.[Total Repurchased Customers] * 1.0
      ) / (
        cte_countCustomer.[Total Customers] * 1.0
      ) * 100, 
      2
    ) as decimal(10, 2)
  ) [Repurchase Rate] 
from 
  cte_countRepurchased, 
  cte_countCustomer;

  --get each customer_unique_id information
  with cte_customerOrder as (
  select 
    customer_unique_id, 
    o.* 
  from 
    olist_customers_dataset c 
    right join olist_orders_dataset o on c.customer_id = o.customer_id
), 
--get the first purchase month of each customer_unique_id
cte_cohorMonth as (
  select 
    customer_unique_id, 
    min(order_purchase_timestamp) as cohorDate 
  from 
    cte_customerOrder 
  group by 
    customer_unique_id
), 
--extract order and cohorDate's year and month 
cte_cohorYearMonth as (
  select 
    o.order_id, 
    c.customer_unique_id, 
    o.order_purchase_timestamp, 
    cte_cohorMonth.cohorDate, 
    DATEPART(
      year, o.order_purchase_timestamp
    ) as orderYear, 
    DATEPART(
      month, o.order_purchase_timestamp
    ) as orderMonth, 
    DATEPART(year, cte_cohorMonth.cohorDate) as cohorYear, 
    DATEPART(month, cte_cohorMonth.cohorDate) as cohorMonth 
  from 
    olist_orders_dataset o 
    join olist_customers_dataset c on o.customer_id = c.customer_id 
    join cte_cohorMonth on c.customer_unique_id = cte_cohorMonth.customer_unique_id 
  where 
    order_status != 'unavailable' 
    and order_status != 'canceled'
) 
select 
  order_id, 
  customer_unique_id, 
  (orderYear - cohorYear) * 12 + (orderMonth - cohorMonth) as cohorIndex 
from 
  cte_cohorYearMonth;

