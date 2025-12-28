{{ config(
    materialized='table',
    tags=['oncology', 'dimension']
) }}

with cohort as (
    select
        person_id,
        cohort_name,
        primary_cancer_type,
        cancer_claim_count,
        most_recent_diagnosis_date,
        all_cancer_codes,
        all_cancer_descriptions
    from {{ ref('int_oncology_cohort') }}
)

select
    person_id,
    cohort_name,
    primary_cancer_type,
    cancer_claim_count,
    most_recent_diagnosis_date,
    all_cancer_codes,
    all_cancer_descriptions
from cohort
