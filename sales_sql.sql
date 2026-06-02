Create database Mobile_sales;
use Mobile_sales;
RENAME TABLE `mobile sales data (2)`
TO mobile_sales_data;
select * from mobile_sales_data;


-- Q1  Core KPIs: Revenue, Units & Transactions --

select round(sum(units_sold * Price_Per_Unit)/1e7,2) as Toatal_Revenue_cr,
count(Transaction_id) as total_no_of_transaction,
sum(units_sold) as Total_unit_sold,
round(avg(Price_Per_Unit),2) as Avg_price_per_unit
from mobile_sales_data;

-- Insights --
-- 76.9 Cr total | 19,150 units | 3,835 transactions | 40,114 avg price --


-- Q2 Brand Revenue Ranking with Market Share --

-- select brand,round(sum(units_sold * Price_Per_Unit),2) as Total_Revenue,
-- dense_rank() over(order by sum(units_sold * Price_Per_Unit) desc) as ranking
-- from mobile_sales_data
-- group by brand;

with brand_rev as (
select brand,round(sum(units_sold * Price_Per_Unit),2) as revenue
from mobile_sales_data
group by brand
)

select *,
round(revenue * 100/ sum(revenue) over() ,2) as market_share_pct,
dense_rank() over (order by revenue desc ) as market_share_rank
from brand_rev;

-- Insights --
-- Apple 21.0% > Samsung 20.8% > OnePlus 20.0% > Vivo 19.5% > Xiaomi 18.7%


-- Q3 Top Cities by Revenue & Geographic Concentration --

select city,round(sum(units_sold * Price_Per_Unit),2) as revenue,
round(sum(units_sold * Price_Per_Unit)*100/sum(sum((units_sold * Price_Per_Unit))) over (),2) as market_share
from mobile_sales_data
group by city
order by market_share desc
limit 5;

-- Insights --
-- Delhi 26.5% | Mumbai 16.5% | Ranchi 4.0% | Chennai 4.0% | Rajkot 3.6%


-- Q4 Year-on-Year Growth using LAG Window Function --

select year, round(sum(units_sold * Price_Per_Unit),2) as revenue,
lag(sum(units_sold * Price_Per_Unit)) over(order by year) as Prev_year_rev,
(sum(units_sold * Price_Per_Unit) - lag(sum(units_sold * Price_Per_Unit)) over(order by year))  * 100 /
lag(sum(units_sold * Price_Per_Unit)) over(order by year) as yoy_growth
from mobile_sales_data
group by year;

with yearly_revenue as (
select year,sum(units_sold * Price_Per_Unit) as revenue
from mobile_sales_data
group by year
)

select year,
revenue, lag(revenue) over (order by year) as prev_revenue,
       ROUND(
           (revenue - LAG(revenue) OVER(ORDER BY year))
           * 100.0
           / LAG(revenue) OVER(ORDER BY year),
           2
       ) AS yoy_growth_pct

FROM yearly_revenue;

-- insights -- 
--  2022: +345.4% | 2023: −3.3% | 2024: −23.0%