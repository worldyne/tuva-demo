{{ config(
    materialized='table',
    tags=['immunization_analysis', 'fact']
) }}

with immunizations as (
    select * from {{ ref('int_immunizations') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['immunization_id']) }} as immunization_sk,
    
    {{ dbt_utils.generate_surrogate_key(['person_id']) }} as patient_sk,
    {{ dbt_utils.generate_surrogate_key(['practitioner_id']) }} as provider_sk,
    {{ dbt_utils.generate_surrogate_key(['normalized_code']) }} as vaccine_sk,
    {{ dbt_utils.generate_surrogate_key(['occurrence_date']) }} as date_sk,
    
    immunization_id,
    encounter_id,
    person_id,
    patient_id,
    
    status as immunization_status,
    normalized_dose as dose_number,
    occurrence_date,
    data_source,
    
    paid_amount,
    allowed_amount,
    total_cost_amount,
    claim_count,
    
    1 as immunization_count

from immunizations
