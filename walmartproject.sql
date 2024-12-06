CREATE DATABASE IF NOT EXISTS walmartSales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- timeofday
select 
time,
(
	Case
		WHEN time between "00:00:00" and "12:00:00" then "Morning"
        WHEN time between "12:01:00" and "16:00:00" then "Afternoon"
        ELSE "Evening"
	END
) as time_of_date
from sales;

ALTER TABLE SALES ADD COLUMN time_of_date VARCHAR(20);

UPDATE sales
SET time_of_date = (
Case
		WHEN time between "00:00:00" and "12:00:00" then "Morning"
        WHEN time between "12:01:00" and "16:00:00" then "Afternoon"
        ELSE "Evening"
END
);

-- dayname
select date,dayname(date) from sales;

alter table sales add column day_name varchar(20);

update sales set day_name = dayname(date);

-- monthname
select date,monthname(date) from sales;
 
alter table sales add column month_name varchar(20);

update sales set month_name = monthname(date);


---------------------------------------------------------------------------


-- How many unique cities does the data have?
select distinct(city) from sales;

-- In which city is each branch?
select 
distinct branch,
city
from sales;

------------------------------------------------ product ----------------------------------------------------------------------------
-- How many unique product lines does the data have?
select
	distinct product_line
from sales;

-- What is the most selling product line
select
	count(quantity) as qty,
    product_line
from sales
group by product_line
order by qty desc;

-- What is the most common payment method?
select
	payment,
    count(payment) as cnt
from sales
group by payment
order by cnt desc;

-- What is the total revenue by month?
select
	sum(total) as total,
    month_name
from sales
group by month_name
order by total desc;

-- What month had the largest COGS?
select
	month_name,
    sum(cogs) as maxi
from sales
group by month_name
order by maxi desc;

-- What product line had the largest revenue?
select
	product_line,
    sum(total) as rev
from sales
group by product_line
order by rev desc;

-- What is the city with the largest revenue?
select
	city,
    branch,
    sum(total) as rev
from sales
group by city,branch
order by rev desc;

-- What product line had the largest VAT?
select
	product_line,
    sum(tax_pct) as rev
from sales
group by product_line
order by rev desc;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales
select
	product_line,
    (case
			when avg(quantity) > 6 then "Good"
        else "Bad"
	end) as avrg_sales
from sales
group by product_line;

-- Which branch sold more products than average product sold?
select
	branch,
    quantity as qty
from sales;

select
	sum(quantity) as qty,
    branch
from sales
group by branch
having sum(quantity)>(select avg(quantity) from sales);


-- What is the most common product line by gender
select
    gender,
    count(gender) as cnt,
    product_line
from sales
group by product_line,gender
order by cnt desc;

-- What is the average rating of each product line
select
	round(avg(rating),2) as rtg,
    product_line
from sales
group by product_line
order by rtg desc;

---------------------------------------------------- customers ---------------------------------------------------------------
-- How many unique customer types does the data have?
select
	distinct customer_type
from sales;

-- How many unique payment methods does the data have?
select
	distinct payment
from sales;

-- What is the most common customer type?
select
	count(customer_type) as typ,
    customer_type
from sales
group by customer_type
order by typ desc;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
select
	gender,
    count(gender)
from sales
group by gender;

-- What is the gender distribution per branch?
select
	count(*) as gnd,
    gender,
    branch
from sales
group by gender,branch
order by branch ;

SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.


-- Which time of the day do customers give most ratings?
select
	avg(rating) as rtg,
    time_of_date
from sales
group by time_of_date
order by rtg desc;

-- Which time of the day do customers give most ratings per branch?
select
	avg(rating) as rtg,
    time_of_date,
    branch
from sales
group by time_of_date,branch
order by branch;

-- Which day fo the week has the best avg ratings?
select
	day_name,
    avg(rating) as avrg
from sales
group by day_name
order by avrg desc;


-- Which day of the week has the best average ratings per branch?
select
	day_name,
    avg(rating) as avrg,branch
from sales
group by day_name,branch
order by branch;

-- sales
-- Number of sales made in each time of the day per weekday 
select
	sum(quantity) as aty,
    day_name,
    time_of_date
from sales
group by day_name,time_of_date
order by day_name;

-- Which of the customer types brings the most revenue?
select
	customer_type,
    sum(total) as tot
from sales
group by customer_type
ORDER BY tot;

-- Which city has the largest tax/VAT percent?
select
	city,
    round(avg(tax_pct),2) as pct
from sales
group by city
order by pct desc;

-- Which customer type pays the most in VAT?
select
	customer_type,
    avg(tax_pct) as pct
from sales
group by customer_type
order by pct;