{{ config(
    materialized='view',
    tags=['oncology', 'staging']
) }}

with oncology_patients as (
    select distinct person_id
    from {{ ref('int_oncology_cohort') }}
),

medical_claims as (
    select
        mc.medical_claim_id,
        mc.claim_id,
        mc.claim_line_number,
        mc.person_id,
        mc.encounter_id,
        mc.encounter_type,
        mc.claim_type,
        mc.claim_start_date,
        mc.claim_end_date,
        mc.service_category_1,
        mc.service_category_2,
        mc.place_of_service_code,
        mc.place_of_service_description,
        mc.paid_amount,
        mc.allowed_amount,
        mc.charge_amount,
        mc.total_cost_amount,
        mc.data_source
    from {{ ref('core__medical_claim') }} mc
    inner join oncology_patients op
        on mc.person_id = op.person_id
)

select * from medical_claims
