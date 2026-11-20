#2. Data Exploration

select * 
from clean_weekly_data;

Question - What day of the week is used for each week_date value?

select DISTINCT dayname(dates) day_of_week
from clean_data;

Question - What range of week numbers are missing from the dataset?
WITH RECURSIVE numbers AS (
    SELECT 1 AS week_number
    UNION ALL
    SELECT week_number + 1 
    FROM numbers 
    WHERE week_number < 52
)
SELECT n.week_number AS missing_weeks
FROM numbers n
LEFT JOIN clean_weekly_data c ON n.week_number = c.week_number
WHERE c.week_number IS NULL;

Question - How many total transactions were there for each year in the dataset?
select extract(year from dates) year,
		count(transactions) transactions_per_year,
        sum(transactions) transactions_total_per_year 
from Pre_clean_data
group by extract(year from dates);

Question - What is the total sales for each region for each month?
select region, month_number, sum(sales) sales 
from pre_clean_data
group by region, month_number
order by month_number asc, calendar_year asc, sales desc;

Question - What is the total count of transactions for each platform
select platform, sum(transactions) total_transactions
from pre_clean_data
group by platform;

Question - What is the percentage of sales for Retail vs Shopify for each month?
select 	round((sum(case when platform = 'Retail' then sales else 0 end)/ sum(sales)) * 100,2) as retails,
		round((sum(case when platform = 'Shopify' then sales else 0 end) / sum(sales)) * 100,2) as Shopify
from pre_clean_data;

SELECT 
    platform,
    SUM(sales) AS platform_sales,
    SUM(sales) / SUM(SUM(sales)) OVER () AS percentage_share
FROM pre_clean_data
GROUP BY platform;

Question - What is the percentage of sales by demographic for each year in the dataset?
select 	demographic, calendar_year,
		SUM(sales) AS demographic_sales,
		(SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY calendar_year)) * 100 AS percentage_share
from pre_clean_data
group by demographic, calendar_year
order by calendar_year;

Question - Which age_band and demographic values contribute the most to Retail sales?
with cte as 
(
select age_band, demographic, sum(sales) total_sales, 
			sum(sales) * 100.0 / sum(sum(sales)) over () as pct_of_retail_sales,
			dense_rank() over (order by sum(sales) desc) rn
from pre_clean_data
where lower(platform) = 'Retail'
group by age_band, demographic
)
select age_band, demographic, total_sales, round(pct_of_retail_sales, 2) pct_of_retail_sales
from cte 
where rn = 1;

Question - Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
select calendar_year, 
		platform, 
		sum(transactions) total_transactions, 
		sum(sales) total_sales, 
		round(sum(sales) / sum(transactions),2) avg_transaction_size  
from pre_clean_data
group by calendar_year, 
		platform
order by calendar_year, 
		platform;
