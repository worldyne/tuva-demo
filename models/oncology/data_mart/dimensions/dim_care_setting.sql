{{ config(
    materialized='table',
    tags=['oncology', 'dimension']
) }}

with care_setting_details as (
    select distinct
        care_setting,
        care_setting_detail
    from {{ ref('int_oncology_financials') }}
    where care_setting is not null or care_setting_detail is not null
),

care_settings_with_keys as (
    select
        row_number() over (order by 
            case care_setting
                when 'inpatient' then 1
                when 'outpatient' then 2
                when 'office-based' then 3
                when 'ancillary' then 4
                else 5
            end,
            care_setting_detail
        ) as care_setting_key,
        care_setting as care_setting_code,
        case care_setting
            when 'inpatient' then 'Inpatient'
            when 'outpatient' then 'Outpatient'
            when 'office-based' then 'Office Based'
            when 'ancillary' then 'Ancillary'
            else 'Unknown'
        end as care_setting_name,
        care_setting_detail as care_setting_detail_code,
        coalesce(replace(replace(care_setting_detail, '_', ' '), '-', ' '), 'Unknown') as care_setting_detail_name,
        case care_setting
            when 'inpatient' then 1
            when 'outpatient' then 2
            when 'office-based' then 3
            when 'ancillary' then 4
            else 99
        end as sort_order
    from care_setting_details
)

select
    care_setting_key,
    care_setting_code,
    care_setting_name,
    care_setting_detail_code,
    care_setting_detail_name,
    sort_order
from care_settings_with_keys
