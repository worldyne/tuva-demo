{{ config(
    materialized='table',
    tags=['immunization_analysis', 'dimension']
) }}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2010-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
)

select
    {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_sk,
    date_day as full_date,
    extract(year from date_day) as year,
    extract(quarter from date_day) as quarter,
    extract(month from date_day) as month,
    extract(week from date_day) as week_of_year,
    extract(day from date_day) as day_of_month,
    extract(dayofweek from date_day) as day_of_week,
    case extract(dayofweek from date_day)
        when 0 then 'Sunday'
        when 1 then 'Monday'
        when 2 then 'Tuesday'
        when 3 then 'Wednesday'
        when 4 then 'Thursday'
        when 5 then 'Friday'
        when 6 then 'Saturday'
    end as day_name,
    case 
        when extract(month from date_day) in (1, 2, 3) then 'Q1'
        when extract(month from date_day) in (4, 5, 6) then 'Q2'
        when extract(month from date_day) in (7, 8, 9) then 'Q3'
        else 'Q4'
    end as quarter_name,
    case extract(month from date_day)
        when 1 then 'January'
        when 2 then 'February'
        when 3 then 'March'
        when 4 then 'April'
        when 5 then 'May'
        when 6 then 'June'
        when 7 then 'July'
        when 8 then 'August'
        when 9 then 'September'
        when 10 then 'October'
        when 11 then 'November'
        when 12 then 'December'
    end as month_name,
    case 
        when extract(dayofweek from date_day) in (0, 6) then true 
        else false 
    end as is_weekend,
    case
        when extract(month from date_day) between 9 and 12 
             or extract(month from date_day) between 1 and 3
        then true
        else false
    end as is_flu_season
from date_spine
