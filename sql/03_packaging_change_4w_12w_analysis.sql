3. Before & After Analysis
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
		(after_4_weeks_sales - before_4_weeks_sales) as sales_change_actual, 
        round((after_4_weeks_sales - before_4_weeks_sales)   / before_4_weeks_sales* 100 , 2) as sales_change_pct
from cte;

Question - What about the entire 12 weeks before and after?

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


Question - How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
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
 

Question - How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

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



Question - Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

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

Question - FOR PLATFORM

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

Question - for Age Band

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


Question - For demographic

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

Question - For customer_type

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
