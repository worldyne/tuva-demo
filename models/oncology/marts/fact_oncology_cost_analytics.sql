{{ config(
    materialized='table',
    tags=['oncology', 'marts']
) }}

with financials as (
    select * from {{ ref('int_oncology_financials') }}
),

by_care_setting as (
    select
        care_setting,
        primary_cancer_type,
        spend_bucket,
        spend_quartile,
        count(distinct person_id) as patient_count,
        sum(total_paid) as total_paid_amount,
        sum(total_allowed) as total_allowed_amount,
        sum(total_cost) as total_cost_amount,
        sum(claim_count) as total_claims,
        avg(patient_total_paid) as avg_patient_total_spend
    from financials
    group by 1, 2, 3, 4
),

summary_stats as (
    select
        care_setting,
        primary_cancer_type,
        spend_bucket,
        spend_quartile,
        patient_count,
        total_paid_amount,
        total_allowed_amount,
        total_cost_amount,
        total_claims,
        avg_patient_total_spend,
        round(total_paid_amount * 100.0 / nullif(sum(total_paid_amount) over (), 0), 2) as pct_of_total_paid,
        round(total_paid_amount / nullif(patient_count, 0), 2) as paid_per_patient,
        round(total_claims * 1.0 / nullif(patient_count, 0), 2) as claims_per_patient
    from by_care_setting
)

select
    care_setting,
    primary_cancer_type,
    spend_bucket,
    spend_quartile,
    patient_count,
    total_paid_amount,
    total_allowed_amount,
    total_cost_amount,
    total_claims,
    avg_patient_total_spend,
    pct_of_total_paid,
    paid_per_patient,
    claims_per_patient
from summary_stats
order by total_paid_amount desc
