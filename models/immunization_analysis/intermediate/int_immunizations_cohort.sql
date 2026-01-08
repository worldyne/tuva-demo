{{ config(
    materialized='table',
    tags=['immunization_analysis', 'intermediate']
) }}

with immunizations as (
    select
        immunization_id,
        person_id,
        patient_id,
        encounter_id,
        source_code_type,
        source_code,
        source_description,
        status,
        status_reason,
        occurence_date,
        source_dose,
        normalized_dose,
        location_id,
        practitioner_id
    from {{ ref('stg_immunizations')}}
),
immunization_counts as (
    select
        person_id,
        count(immunization_id) AS immunizations_count
    from
        immunizations
    group by person_id
),
encounter_counts as (
    select
        person_id,
        count(distinct encounter_id) as ecounters_count
    from immunizations
    group by person_id
),
distinct_codes as (
    select distinct
        person_id,
        normalized_code,
        normalized_code_description
    from immunizations
),
immunization_codes as (
    select
        person_id,
        list(normalized_code order by normalized_code) as all_immunization_codes,
        list(normalized_description order by normalized_code) as all_immunization_descriptions
)

cohort as (
    select 
        i.person_id,
        i.immunizations_count,
        ec.ecounters_count,
        ic.all_immunization_codes,
        ic.all_immunization_descriptions
    from immunization_counts i
    inner join encounter_counts ec
        on i.person_id = ec.person_id
    inner join immunization_codes ic
        on i.person_id = ic.person_id
)

select * from cohort