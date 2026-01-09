{{ config(
    materialized='table',
    tags=['immunization_analysis', 'dimension']
) }}

with providers as (
    select
        practitioner_id,
        npi,
        provider_first_name,
        provider_last_name,
        practice_affiliation,
        specialty,
        sub_specialty
    from {{ ref('stg_providers') }}
    where practitioner_id is not null
)

select
    {{ dbt_utils.generate_surrogate_key(['practitioner_id']) }} as provider_sk,
    practitioner_id,
    npi,
    provider_first_name,
    provider_last_name,
    concat(provider_first_name, ' ', provider_last_name) as provider_full_name,
    practice_affiliation,
    specialty,
    sub_specialty
from providers
