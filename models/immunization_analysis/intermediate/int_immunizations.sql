{{ config(
    materialized='table',
    tags=['immunization_analysis', 'intermediate']
) }}

with immunizations as (
    select
        immunization_id,
        person_id,
        patient_id,
        encounter_id,
        practitioner_id,
        source_code,
        source_code_type,
        source_description,
        normalized_code,
        normalized_code_type,
        normalized_description,
        status,
        status_reason,
        occurrence_date,
        source_dose,
        normalized_dose,
        location_id,
        data_source
    from {{ ref('stg_immunizations') }}
),

claims as (
    select
        person_id,
        claim_start_date,
        sum(coalesce(paid_amount, 0)) as paid_amount,
        sum(coalesce(allowed_amount, 0)) as allowed_amount,
        sum(coalesce(total_cost_amount, 0)) as total_cost_amount,
        count(distinct claim_id) as claim_count
    from {{ ref('stg_immunization_claims') }}
    group by person_id, claim_start_date
)

select
    i.immunization_id,
    i.person_id,
    i.patient_id,
    i.encounter_id,
    i.practitioner_id,
    i.source_code,
    i.source_code_type,
    i.source_description,
    i.normalized_code,
    i.normalized_code_type,
    i.normalized_description,
    i.status,
    i.status_reason,
    i.occurrence_date,
    i.source_dose,
    i.normalized_dose,
    i.location_id,
    i.data_source,
    coalesce(c.paid_amount, 0) as paid_amount,
    coalesce(c.allowed_amount, 0) as allowed_amount,
    coalesce(c.total_cost_amount, 0) as total_cost_amount,
    coalesce(c.claim_count, 0) as claim_count
from immunizations i
left join claims c
    on i.person_id = c.person_id
    and i.occurrence_date = c.claim_start_date
