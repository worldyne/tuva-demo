{{ config(
    materialized='table',
    tags=['oncology', 'intermediate']
) }}

with cohort as (
    select
        person_id,
        primary_cancer_type,
        cancer_claim_count
    from {{ ref('int_oncology_cohort') }}
),

claims as (
    select
        person_id,
        claim_id,
        claim_start_date,
        service_category_1,
        paid_amount,
        allowed_amount,
        total_cost_amount
    from {{ ref('stg_oncology_claims') }}
),

claims_with_cohort as (
    select
        c.person_id,
        co.primary_cancer_type,
        cl.claim_id,
        cl.claim_start_date,
        coalesce(cl.service_category_1, 'Other') as care_setting,
        coalesce(cl.paid_amount, 0) as paid_amount,
        coalesce(cl.allowed_amount, 0) as allowed_amount,
        coalesce(cl.total_cost_amount, 0) as total_cost_amount
    from cohort c
    inner join claims cl
        on c.person_id = cl.person_id
    cross join (select 1) co_placeholder
    left join cohort co
        on c.person_id = co.person_id
),

patient_care_setting_spend as (
    select
        person_id,
        primary_cancer_type,
        care_setting,
        sum(paid_amount) as total_paid,
        sum(allowed_amount) as total_allowed,
        sum(total_cost_amount) as total_cost,
        count(distinct claim_id) as claim_count
    from claims_with_cohort
    group by 1, 2, 3
),

patient_total_spend as (
    select
        person_id,
        sum(total_paid) as patient_total_paid
    from patient_care_setting_spend
    group by 1
),

with_spend_bucket as (
    select
        pcs.person_id,
        pcs.primary_cancer_type,
        pcs.care_setting,
        pcs.total_paid,
        pcs.total_allowed,
        pcs.total_cost,
        pcs.claim_count,
        pts.patient_total_paid,
        ntile(4) over (order by pts.patient_total_paid) as spend_quartile,
        case
            when pts.patient_total_paid >= 100000 then 'High Cost (>$100k)'
            when pts.patient_total_paid >= 25000 then 'Medium Cost ($25k-$100k)'
            when pts.patient_total_paid >= 5000 then 'Low Cost ($5k-$25k)'
            else 'Minimal Cost (<$5k)'
        end as spend_bucket
    from patient_care_setting_spend pcs
    inner join patient_total_spend pts
        on pcs.person_id = pts.person_id
)

select * from with_spend_bucket
