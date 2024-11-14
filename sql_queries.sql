use walmart_db;
select * from walmart;
-- Find different payment method and number of transactions, number of quantity sold

select payment_method, count(*) as no_payments,
sum(quantity) as no_qty_sold
from walmart
group by payment_method; 

-- Identify the highest-rated category in each branch, displaying the branch, category
-- avg_rating

select * from(
	select branch, category, avg(rating) as avg_rating,
	rank() over(partition by branch order by avg(rating) desc) as rnk
	from walmart
	group by branch, category
	order by branch, avg_rating desc
) as ranked_data
where rnk =1;

-- Identify the busiest day for each branch baesd on the number of transactions

select * from (
select 
	branch,
    date_format(str_to_date(date, '%d/%m/%y'),'%W') as day_name,
    count(*) as no_transactions,
    rank() over(partition by branch order by count(*) desc) as rnk
from walmart
group by branch, day_name
) as ranked
where rnk=1;

-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity

select payment_method,
sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Determine the average, minimum and maximum rating of category for each city. List the city, average_rating, min_rating, and max_rating.

select  city, category,
	min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart
group by city, category;

-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity *profit_margin). List category and total_profit, ordered from highest to lowest profit.

 select category,
	sum(total) as total_revenue,
	sum(total *profit_margin) as profit
from walmart
group by category;

-- Determine the most common payment method for each branch. Display branch and the preferred_payment_method.

with cte as(
select branch, payment_method,
	count(*) as total_trans,
    rank() over(partition by branch order by count(*) desc) as rnk
from walmart
group by branch, payment_method)
select * from cte
where rnk =1;

-- Categorize sales into 3groups Morning, Afternoon, Evening.
-- Find out which of the shift and number of invoices.

select branch,
	case
		when hour(time(time))<12 then 'Morning'
        when hour(time(time)) between 12 and 17 then 'Afternoon' 
        else 'Evening'
	end as shift,
    count(*) as num_invoices
from walmart
group by branch, shift
order by branch, num_invoices desc;

--  Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
-- revedecre = lastyear_reve - curryear_reve / lastyear_reve * 100

with revenue_2022 as(
	select branch,sum(total) as revenue
	from walmart
    where year(str_to_date(date, '%d/%m/%y')) =2022
    group by branch
),
revenue_2023 as(
	select branch,
	sum(total) as revenue
	from walmart
    where year(str_to_date(date, '%d/%m/%y'))=2023
	group by branch
)
select r2022.branch,
	r2022.revenue as last_year_revenue,
    r2023.revenue as current_year_revenue,
    round(((r2022.revenue - r2023.revenue) / r2022.revenue) *100,2) as revenue_decrease_ratio
from revenue_2022 as r2022
join revenue_2023 as r2023 on r2022.branch = r2023.branch
where r2022.revenue > r2023.revenue
order by revenue_decrease_ratio desc
limit 5;