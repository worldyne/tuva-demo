{{ config(
    materialized='view',
    tags=['immunization_analysis', 'staging']
) }}

with medical_claims as (
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
)

select * from medical_claims
