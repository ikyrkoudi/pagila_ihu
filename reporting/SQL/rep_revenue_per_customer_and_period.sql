create table if not exists capstone-project-495705.reporting_db.rep_revenue_per_customer_and_period as

with revenue as (
select
   p.customer_id
   , p.payment_date
   , p.payment_amount
from capstone-project-495705.staging_db.stg_payment p
inner join capstone-project-495705.staging_db.stg_rental r 
on p.rental_id = r.rental_id
inner join capstone-project-495705.staging_db.stg_inventory i 
on r.inventory_id = i.inventory_id
inner join capstone-project-495705.staging_db.stg_film f 
on i.film_id = f.film_id
where f.film_title != 'GOODFELLAS SALUTE'
)

, customers as (
select *
from capstone-project-495705.staging_db.stg_customer
)

, reporting_dates as (
select * 
from capstone-project-495705.reporting_db.reporting_periods_table
where reporting_period in ('Day','Month','Year')
)

, revenue_per_period as (
select
  customers.customer_id
  , 'Day' as reporting_period
  , date_trunc(revenue.payment_date,day) as reporting_date
  , sum(payment_amount) as total_revenue
from revenue
left join customers
on revenue.customer_id = customers.customer_id
group by 1,2,3
 union all

select
  customers.customer_id
  , 'Month' as reporting_period
  , date_trunc(revenue.payment_date,month) as reporting_date
  , sum(payment_amount) as total_revenue
from revenue
left join customers
on revenue.customer_id = customers.customer_id
group by 1,2,3
 union all

select
  customers.customer_id
  , 'Year' as reporting_period
  , date_trunc(revenue.payment_date,year) as reporting_date
  , sum(payment_amount) as total_revenue
from revenue
left join customers
on revenue.customer_id = customers.customer_id
group by 1,2,3
)

, final as (
select
  revenue_per_period.customer_id
  , reporting_dates.reporting_period
  , reporting_dates.reporting_date
  , revenue_per_period.total_revenue as total_revenue
from
    reporting_dates
inner join revenue_per_period
on reporting_dates.reporting_period = revenue_per_period.reporting_period
and reporting_dates.reporting_date = revenue_per_period.reporting_date
where reporting_dates.reporting_period = 'Day'
 union all

select
  revenue_per_period.customer_id
  , reporting_dates.reporting_period
  , reporting_dates.reporting_date
  , revenue_per_period.total_revenue as total_revenue
from
    reporting_dates
inner join revenue_per_period
on reporting_dates.reporting_period = revenue_per_period.reporting_period
and reporting_dates.reporting_date = revenue_per_period.reporting_date
where reporting_dates.reporting_period = 'Month'
 union all

select
  revenue_per_period.customer_id
  , reporting_dates.reporting_period
  , reporting_dates.reporting_date
  , revenue_per_period.total_revenue as total_revenue
from
    reporting_dates
inner join revenue_per_period
on reporting_dates.reporting_period = revenue_per_period.reporting_period
and reporting_dates.reporting_date = revenue_per_period.reporting_date
where reporting_dates.reporting_period = 'Year'
)

select * from final