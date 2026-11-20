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
