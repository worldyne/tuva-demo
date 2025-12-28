{{ config(
    materialized='table',
    tags=['oncology', 'fact']
) }}

with financials as (
    select
        person_id,
        primary_cancer_type,
        care_setting,
        care_setting_detail,
        total_paid,
        total_allowed,
        total_cost,
        claim_count,
        patient_total_paid
    from {{ ref('int_oncology_financials') }}
),

cancer_type_dim as (
    select
        cancer_type_key,
        cancer_type_name
    from {{ ref('dim_cancer_type') }}
),

care_setting_dim as (
    select
        care_setting_key,
        care_setting_code,
        care_setting_detail_code
    from {{ ref('dim_care_setting') }}
),

spend_bucket_dim as (
    select
        spend_bucket_key,
        min_threshold,
        max_threshold
    from {{ ref('dim_spend_bucket') }}
)

select
    f.person_id,
    coalesce(ct.cancer_type_key, 99) as cancer_type_key,
    cs.care_setting_key,
    sb.spend_bucket_key,
    f.total_paid as paid_amount,
    f.total_allowed as allowed_amount,
    f.total_cost as total_cost_amount,
    f.claim_count
from financials f
left join cancer_type_dim ct
    on f.primary_cancer_type = ct.cancer_type_name
left join care_setting_dim cs
    on coalesce(f.care_setting, 'Unknown') = coalesce(cs.care_setting_code, 'Unknown')
    and coalesce(f.care_setting_detail, 'Unknown') = coalesce(cs.care_setting_detail_code, 'Unknown')
left join spend_bucket_dim sb
    on f.patient_total_paid >= sb.min_threshold
    and (f.patient_total_paid <= sb.max_threshold or sb.max_threshold is null)
