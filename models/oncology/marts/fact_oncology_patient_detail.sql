{{ config(
    materialized='table',
    tags=['oncology', 'marts']
) }}

with cohort as (
    select
        person_id,
        cancer_claim_count,
        primary_cancer_type,
        most_recent_diagnosis_date,
        all_cancer_codes,
        all_cancer_descriptions,
        cohort_name
    from {{ ref('int_oncology_cohort') }}
),

patient_financials as (
    select
        person_id,
        sum(total_paid) as total_paid,
        sum(total_allowed) as total_allowed,
        sum(total_cost) as total_cost,
        sum(claim_count) as total_claims,
        max(spend_bucket) as spend_bucket,
        max(spend_quartile) as spend_quartile
    from {{ ref('int_oncology_financials') }}
    group by 1
),

care_setting_breakdown as (
    select
        person_id,
        list(distinct care_setting) as care_settings_used,
        sum(case when care_setting = 'inpatient' then total_paid else 0 end) as inpatient_paid,
        sum(case when care_setting = 'outpatient' then total_paid else 0 end) as outpatient_paid,
        sum(case when care_setting = 'emergency' then total_paid else 0 end) as emergency_paid,
        sum(case when care_setting = 'office-based' then total_paid else 0 end) as office_paid,
        sum(case when care_setting = 'ancillary' then total_paid else 0 end) as ancillary_paid
    from {{ ref('int_oncology_financials') }}
    group by 1
)

select
    c.person_id,
    c.cohort_name,
    c.primary_cancer_type,
    c.all_cancer_codes,
    c.all_cancer_descriptions,
    c.cancer_claim_count,
    c.most_recent_diagnosis_date,
    pf.total_paid,
    pf.total_allowed,
    pf.total_cost,
    pf.total_claims,
    pf.spend_bucket,
    pf.spend_quartile,
    csb.care_settings_used,
    csb.inpatient_paid,
    csb.outpatient_paid,
    csb.emergency_paid,
    csb.office_paid,
    csb.ancillary_paid
from cohort c
left join patient_financials pf
    on c.person_id = pf.person_id
left join care_setting_breakdown csb
    on c.person_id = csb.person_id
order by pf.total_paid desc nulls last
