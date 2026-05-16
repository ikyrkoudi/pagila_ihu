create table if not exists capstone-project-495705.reporting_db.rep_revenue_per_period as

with revenue as (
select
   p.payment_date
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
, reporting_dates as (
select * 
from capstone-project-495705.reporting_db.reporting_periods_table
where reporting_period in ('Day','Month','Year')
And reporting_date >= '2015-01-01'
)
, revenue_per_period as (
select
  'Day' as reporting_period
  , date_trunc(revenue.payment_date,day) as reporting_date
  , sum(payment_amount) as total_revenue
from revenue
group by 1,2
 union all
select
  'Month' as reporting_period
  , date_trunc(revenue.payment_date,month) as reporting_date
  , sum(payment_amount) as total_revenue
from revenue
group by 1,2
 union all
select
  'Year' as reporting_period
  , date_trunc(revenue.payment_date,year) as reporting_date
  , sum(payment_amount) as total_revenue
from revenue
group by 1,2
)
, final as (
select
  reporting_dates.reporting_period
  , reporting_dates.reporting_date
  , coalesce(revenue_per_period.total_revenue,0) as total_revenue
from
    reporting_dates
left join revenue_per_period
on reporting_dates.reporting_period = revenue_per_period.reporting_period
and reporting_dates.reporting_date = revenue_per_period.reporting_date
where reporting_dates.reporting_period = 'Day'
 union all
select
  reporting_dates.reporting_period
  , reporting_dates.reporting_date
  , coalesce(revenue_per_period.total_revenue,0) as total_revenue
from
    reporting_dates
left join revenue_per_period
on reporting_dates.reporting_period = revenue_per_period.reporting_period
and reporting_dates.reporting_date = revenue_per_period.reporting_date
where reporting_dates.reporting_period = 'Month'
 union all
select
  reporting_dates.reporting_period
  , reporting_dates.reporting_date
  , coalesce(revenue_per_period.total_revenue,0) as total_revenue
from
    reporting_dates
left join revenue_per_period
on reporting_dates.reporting_period = revenue_per_period.reporting_period
and reporting_dates.reporting_date = revenue_per_period.reporting_date
where reporting_dates.reporting_period = 'Year'
)

select * from final