{{ config(
    materialized='view',
    tags=['medication_analysis', 'staging']
)}}

with immunizations as (
    select
        *
    from {{ref('core__immunization')}}
)
select * from immunizations