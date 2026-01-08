{{ config(
    materialized='view',
    tags=['medication_analysis', 'staging']
)}}

with practitioners as (
    select
        *
    from {{ref('core__practitioner')}}
)
select * from practitioners