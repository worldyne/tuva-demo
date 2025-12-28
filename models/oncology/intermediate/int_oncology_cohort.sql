{{ config(
    materialized='table',
    tags=['oncology', 'intermediate']
) }}

with cancer_conditions as (
    select
        person_id,
        condition_id,
        claim_id,
        recorded_date,
        normalized_code,
        normalized_description,
        cancer_type
    from {{ ref('stg_oncology_conditions') }}
),

patient_claim_counts as (
    select
        person_id,
        count(distinct claim_id) as cancer_claim_count
    from cancer_conditions
    group by 1
    having count(distinct claim_id) >= 2
),

patient_cancer_types as (
    select
        c.person_id,
        c.cancer_type,
        count(*) as type_count,
        max(c.recorded_date) as latest_recorded_date
    from cancer_conditions c
    inner join patient_claim_counts p
        on c.person_id = p.person_id
    group by 1, 2
),

primary_cancer_type as (
    select
        person_id,
        cancer_type as primary_cancer_type,
        latest_recorded_date
    from patient_cancer_types
    qualify row_number() over (
        partition by person_id
        order by type_count desc, latest_recorded_date desc
    ) = 1
),

distinct_codes as (
    select distinct
        c.person_id,
        c.normalized_code,
        c.normalized_description
    from cancer_conditions c
    inner join patient_claim_counts p
        on c.person_id = p.person_id
),

patient_codes as (
    select
        person_id,
        list(normalized_code order by normalized_code) as all_cancer_codes,
        list(normalized_description order by normalized_code) as all_cancer_descriptions
    from distinct_codes
    group by 1
),

cohort as (
    select
        p.person_id,
        p.cancer_claim_count,
        pct.primary_cancer_type,
        pct.latest_recorded_date as most_recent_diagnosis_date,
        pc.all_cancer_codes,
        pc.all_cancer_descriptions,
        'Active Oncology' as cohort_name
    from patient_claim_counts p
    inner join primary_cancer_type pct
        on p.person_id = pct.person_id
    inner join patient_codes pc
        on p.person_id = pc.person_id
)

select * from cohort
