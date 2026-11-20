select * from data_mart.weekly_sales;
use data_mart;

#pre-clean data 
SELECT 
    week_dates AS original_string_date,
    STR_TO_DATE(week_dates, '%d/%c/%y') AS converted_date
FROM weekly_sales;

create table pre_clean_data as 
select 	week_dates, region, platform, segment, customer_type, transactions, sales,
		STR_TO_DATE(week_dates, '%d/%c/%y') AS dates,
		week(week_dates) as week_number,
        month(week_dates) as month_number,
        year(week_dates) as calendar_year, 
        case 
			when segment = 'C1' then 'Young Adults'
            when segment = 'C2' then 'Middle Aged'
            when segment = 'C3' or segment = 'C4' then 'Retirees'
            when segment = 'F1' then 'Young Adults'
            when segment = 'F2' then 'Middle Aged'
            when segment = 'F3' or segment = 'F4' then 'Retirees'
            else "unknown"
		end as age_band,
        case 
			when segment like 'C%' then 'Couples'
            when segment like 'F%' then 'Family'
            else "unknown"
		end as demographic,
        round(sales /  transactions, 2) avg_sales 
FROM weekly_sales;


#cleandata
create view clean_data as 
select 	STR_TO_DATE(week_dates, '%d/%c/%y') AS dates,
		week(week_dates) as week_number,
        month(week_dates) as month_number,
        year(week_dates) as calendar_year, 
        case 
			when segment = 'C1' then 'Young Adults'
            when segment = 'C2' then 'Middle Aged'
            when segment = 'C3' or segment = 'C4' then 'Retirees'
            when segment = 'F1' then 'Young Adults'
            when segment = 'F2' then 'Middle Aged'
            when segment = 'F3' or segment = 'F4' then 'Retirees'
            else "unknown"
		end as age_band,
        case 
			when segment like 'C%' then 'Couples'
            when segment like 'F%' then 'Family'
            else "unknown"
		end as demographic,
        round(sales /  transactions, 2) avg_sales 
FROM weekly_sales;

#2. Data Exploration

select * 
from clean_weekly_data;

#What day of the week is used for each week_date value?

select DISTINCT dayname(dates) day_of_week
from clean_data;

#What range of week numbers are missing from the dataset?
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

#How many total transactions were there for each year in the dataset?
select extract(year from dates) year,
		count(transactions) transactions_per_year,
        sum(transactions) transactions_total_per_year 
from Pre_clean_data
group by extract(year from dates);

#What is the total sales for each region for each month?
select region, month_number, sum(sales) sales 
from pre_clean_data
group by region, month_number
order by month_number asc, calendar_year asc, sales desc;

#What is the total count of transactions for each platform
select platform, sum(transactions) total_transactions
from pre_clean_data
group by platform;

#What is the percentage of sales for Retail vs Shopify for each month?
select 	round((sum(case when platform = 'Retail' then sales else 0 end)/ sum(sales)) * 100,2) as retails,
		round((sum(case when platform = 'Shopify' then sales else 0 end) / sum(sales)) * 100,2) as Shopify
from pre_clean_data;

SELECT 
    platform,
    SUM(sales) AS platform_sales,
    SUM(sales) / SUM(SUM(sales)) OVER () AS percentage_share
FROM pre_clean_data
GROUP BY platform;


#What is the percentage of sales by demographic for each year in the dataset?
select 	demographic, calendar_year,
		SUM(sales) AS demographic_sales,
		(SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY calendar_year)) * 100 AS percentage_share
from pre_clean_data
group by demographic, calendar_year
order by calendar_year;


#Which age_band and demographic values contribute the most to Retail sales?
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


#Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
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
        
#3. Before & After Analysis
#*This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
#aking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
#We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before
#Using this analysis approach - answer the following questions:

with cte as (
select 
	sum(case
			when dates >= date_sub('2020-06-15', interval 4 week) and dates < '2020-06-15' then sales 
            else 0
            end ) as before_4_weeks_sales,
	sum(case
			when dates < date_add('2020-06-15', interval 4 week) and dates >= '2020-06-15' then sales 
            else 0
            end ) as after_4_weeks_sales
from pre_clean_data)
select 	before_4_weeks_sales, 
		after_4_weeks_sales,
		(before_4_weeks_sales - after_4_weeks_sales) as sales_change_actual, 
        round((before_4_weeks_sales - after_4_weeks_sales)   / after_4_weeks_sales * 100 , 2) as sales_change_pct
from cte;

#What about the entire 12 weeks before and after?

with cte as (
select 
	sum(case
			when dates >= date_sub('2020-06-15', interval 12 week) and dates < '2020-06-15' then sales 
            else 0
            end ) as before_12_weeks_sales,
	sum(case
			when dates < date_add('2020-06-15', interval 12 week) and dates >= '2020-06-15' then sales 
            else 0
            end ) as after_12_weeks_sales
from pre_clean_data)
select 	before_12_weeks_sales, 
		after_12_weeks_sales,
		(before_12_weeks_sales - after_12_weeks_sales) as sales_change_actual, 
        round((before_12_weeks_sales - after_12_weeks_sales)   / after_12_weeks_sales * 100 , 2) as sales_change_pct
from cte; 


#How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
with cte as (
select 
	sum(case
			when dates >= date_sub('2020-06-15', interval 12 week) and dates < '2020-06-15' then sales 
            else 0
            end ) as before_12_weeks_sales,
	sum(case
			when dates < date_add('2020-06-15', interval 12 week) and dates >= '2020-06-15' then sales 
            else 0
            end ) as after_12_weeks_sales
from pre_clean_data)
select 	before_12_weeks_sales, 
		after_12_weeks_sales,
		(before_12_weeks_sales - after_12_weeks_sales) as sales_change_actual, 
        round((before_12_weeks_sales - after_12_weeks_sales)   / after_12_weeks_sales * 100 , 2) as sales_change_pct
from cte; 
 

#How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

with yearly_window as 
(select calendar_year,
	sum(case
			when dates >= date_sub(str_to_date(concat(calendar_year, '-06-15'), '%Y-%m-%d'), interval 12 week) 
            and dates < str_to_date(concat(calendar_year, '-06-15'), '%Y-%m-%d') then sales 
            else 0
            end ) as before_12_weeks_sales,
	sum(case
			WHEN dates >= STR_TO_DATE(CONCAT(calendar_year, '-06-15'), '%Y-%m-%d')
             AND dates <  DATE_ADD(STR_TO_DATE(CONCAT(calendar_year, '-06-15'), '%Y-%m-%d'), INTERVAL 4 WEEK)
            THEN sales ELSE 0
            end ) as after_12_weeks_sales
from pre_clean_data
where calendar_year in (2018,2019,2020)
group by calendar_year
)
select calendar_year, 
		before_12_weeks_sales,
        after_12_weeks_sales,
        (before_12_weeks_sales - after_12_weeks_sales) as sales_change_actual,
        ROUND(
        ((before_12_weeks_sales - after_12_weeks_sales) / after_12_weeks_sales) * 100,
        2
    ) AS sales_change_pct
from yearly_window
order by calendar_year;



#Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

with cte_of_12_week as
(select region, 
			sum(case
			when dates >= date_sub('2020-06-15', interval 12 week) and dates < '2020-06-15' then sales 
            else 0
            end ) as before_12_weeks_sales,
	sum(case
			when dates < date_add('2020-06-15', interval 12 week) and dates >= '2020-06-15' then sales 
            else 0
            end ) as after_12_weeks_sales
from pre_clean_data
group by region)
select region,
		before_12_weeks_sales,
        after_12_weeks_sales,
        (after_12_weeks_sales - before_12_weeks_sales) change_in_12_weeks,
        round((after_12_weeks_sales - before_12_weeks_sales)/ NULLIF(before_12_weeks_sales, 0) * 100.0, 2) pct_change
from cte_of_12_week
order by pct_change; 

#FOR PLATFORM

with cte_of_12_week as
(select platform, 
			sum(case
			when dates >= date_sub('2020-06-15', interval 12 week) and dates < '2020-06-15' then sales 
            else 0
            end ) as before_12_weeks_sales,
	sum(case
			when dates < date_add('2020-06-15', interval 12 week) and dates >= '2020-06-15' then sales 
            else 0
            end ) as after_12_weeks_sales
from pre_clean_data
group by platform)
select 	platform,
		before_12_weeks_sales,
        after_12_weeks_sales,
        (after_12_weeks_sales - before_12_weeks_sales) change_in_12_weeks,
        round((after_12_weeks_sales - before_12_weeks_sales)/ NULLIF(before_12_weeks_sales, 0) * 100.0, 2) pct_change
from cte_of_12_week
order by pct_change; 

#for Age Band

with cte_of_12_week as
(select age_band, 
			sum(case
			when dates >= date_sub('2020-06-15', interval 12 week) and dates < '2020-06-15' then sales 
            else 0
            end ) as before_12_weeks_sales,
	sum(case
			when dates < date_add('2020-06-15', interval 12 week) and dates >= '2020-06-15' then sales 
            else 0
            end ) as after_12_weeks_sales
from pre_clean_data
group by age_band)
select 	age_band,
		before_12_weeks_sales,
        after_12_weeks_sales,
        (after_12_weeks_sales - before_12_weeks_sales) change_in_12_weeks,
        round((after_12_weeks_sales - before_12_weeks_sales)/ NULLIF(before_12_weeks_sales, 0) * 100.0, 2) pct_change
from cte_of_12_week
order by pct_change; 


#demographic

with cte_of_12_week as
(select demographic, 
			sum(case
			when dates >= date_sub('2020-06-15', interval 12 week) and dates < '2020-06-15' then sales 
            else 0
            end ) as before_12_weeks_sales,
	sum(case
			when dates < date_add('2020-06-15', interval 12 week) and dates >= '2020-06-15' then sales 
            else 0
            end ) as after_12_weeks_sales
from pre_clean_data
group by demographic)
select 	demographic,
		before_12_weeks_sales,
        after_12_weeks_sales,
        (after_12_weeks_sales - before_12_weeks_sales) change_in_12_weeks,
        round((after_12_weeks_sales - before_12_weeks_sales)/ NULLIF(before_12_weeks_sales, 0) * 100.0, 2) pct_change
from cte_of_12_week
order by pct_change; 

#For customer_type

with cte_of_12_week as
(select customer_type, 
			sum(case
			when dates >= date_sub('2020-06-15', interval 12 week) and dates < '2020-06-15' then sales 
            else 0
            end ) as before_12_weeks_sales,
	sum(case
			when dates < date_add('2020-06-15', interval 12 week) and dates >= '2020-06-15' then sales 
            else 0
            end ) as after_12_weeks_sales
from pre_clean_data
group by customer_type)
select 	customer_type,
		before_12_weeks_sales,
        after_12_weeks_sales,
        (after_12_weeks_sales - before_12_weeks_sales) change_in_12_weeks,
        round((after_12_weeks_sales - before_12_weeks_sales)/ NULLIF(before_12_weeks_sales, 0) * 100.0, 2) pct_change
from cte_of_12_week
order by pct_change; 


### conclusion 

#1. Core Findings (What Happened?)

#Summarize the biggest patterns uncovered in Sections 1–3 using concrete numbers from your queries

#Packaging Change Impact (4-Week & 12-Week Windows): Highlight the immediate dip right after 2020-06-15 (4 weeks before vs. after) and whether sales recovered or continued slipping over the longer 12-week window.
#Seasonality Check (2018 & 2019 Comparison): Contrast 2020 against the exact same mid-June periods in 2018 and 2019. Point out whether the post-June 15 drop was unique to the 2020 packaging change or if mid-June normally fluctuates.
#Channel Divergence (Retail vs. Shopify): Note which channel absorbed the biggest drop (typically brick-and-mortar Retail accounts for the overwhelming majority of total revenue and saw the steepest drop, whereas Shopify online sales often grew or stayed far more resilient).
#Regional & Customer Segment Concentration: Call out which regions (such as Oceania/Asia or specific hard-hit markets) and which customer groups (Families, Retirees, Middle Aged, or unknown age bands) drove the largest revenue losses or gains.


#Root-Cause Hypotheses
#Unknown Demographics Gap: A large share of sales often sits under unknown age bands and demographics (unregistered / guest checkouts), limiting targeted retention campaigns.
#Channel Behavior: Online Shopify buyers may respond more positively to eco-friendly packaging or have higher average basket sizes than in-store Retail shoppers.


#Actionable Recommendations for Danny's Team
#Targeted Promotions in Hard-Hit Regions & Segments
#In-Store Retail Communication
#Double Down on Shopify Growth
#Fix Data Capture for unknown Customers