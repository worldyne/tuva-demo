{{ config(
    materialized='table',
    tags=['immunization_analysis', 'intermediate']
) }}

with cohort as (
    select
        person_id
    from
        {{ ref('int_immunizations_cohort') }}
),

claims as (
    select
        person_id,
        claim_id,
        claim_start_date,
        service_category_1,
        service_category_2,
        paid_amount,
        allowed_amount,
        total_cost_amount
    from {{ ref('stg_immunization_claims') }}
),
cohort_claims as (
    select
        ch.person_id,
        ch.immunization_id,
        cl.claim_id,
        cl.claim_start_date,
        cl.service_category_1 as care_setting,
        cl.service_category_2 as care_setting_detail,
        coalesce(cl.paid_amount, 0) as paid_amount,
        coalesce(cl.allowed_amount, 0) as allowed_amount,
        coalesce(cl.total_cost_amount, 0) as total_cost_amount
    from cohort ch
    inner join claims cl
        on ch.person_id = cl.person_id
),
patient_care_setting_spend as (
    select
        person_id,
        immunization_id,
        care_setting,
        care_setting_detail,
        sum(paid_amount) as total_paid,
        sum(allowed_amount) as total_allowed,
        sum(total_cost_amount) as total_cost,
        count(distinct claim_id) as claim_count
    from claims_with_cohort
    group by person_id, immunization_id, care_setting, care_setting_detail
),

patient_total_spend as (
    select
        person_id,
        sum(total_paid) as patient_total_paid
    from patient_care_setting_spend
),

with_spend_bucket as (
    -- TODO: Join patient_care_setting_spend to patient_total_spend
    -- Add: spend_quartile using NTILE(4) over patient_total_paid
    -- Add: spend_bucket CASE statement (use oncology thresholds or adjust for immunization context)
    -- Consider: Should thresholds be lower since immunization patients may have lower overall costs?
    select
        pcs.person_id,
        pcs.immunization_id,
        pcs.care_setting,
        pcs.care_setting_detail,
        pcs.total_paid,
        pcs.total_allowed,
        pcs.total_cost,
        pcs.claim_count,
        pts.patient_total_paid,
        ntile(4) over (order by pts.patient_total_paid) as spend_quartile,
        -- case
        --     when pts.patient_total_paid >= 100000 then 'High Cost (>$100k)'
        --     when pts.patient_total_paid >= 25000 then 'Medium Cost ($25k-$100k)'
        --     when pts.patient_total_paid >= 5000 then 'Low Cost ($5k-$25k)'
        --     else 'Minimal Cost (<$5k)'
        -- end as spend_bucket
    from patient_care_setting_spend pcs
    inner join patient_total_spend pts
        on pcs.person_id, = pts.person_id
)

select * from with_spend_bucket

