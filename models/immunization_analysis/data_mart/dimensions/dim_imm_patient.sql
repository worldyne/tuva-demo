{{ config(
    materialized='table',
    tags=['immunization_analysis', 'dimension']
) }}

with immunizations as (
    select * from {{ ref('int_immunizations') }}
),

patients as (
    select distinct
        person_id,
        patient_id
    from immunizations
),

patient_immunization_stats as (
    select
        person_id,
        count(*) as total_immunizations,
        count(distinct normalized_code) as distinct_vaccines,
        min(occurrence_date) as first_immunization_date,
        max(occurrence_date) as last_immunization_date,
    from immunizations
    group by person_id
)


select
    {{ dbt_utils.generate_surrogate_key(['p.person_id']) }} as patient_sk,
    p.person_id,
    p.patient_id,
    s.total_immunizations,
    s.distinct_vaccines,
    s.first_immunization_date,
    s.last_immunization_date
from patients p
inner join patient_immunization_stats s
    on p.person_id = s.person_id
