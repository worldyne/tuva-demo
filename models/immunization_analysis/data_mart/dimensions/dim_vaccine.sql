{{ config(
    materialized='table',
    tags=['immunization_analysis', 'dimension']
) }}

with immunizations as (
    select * from {{ ref('int_immunizations') }}
),

vaccines as (
    select distinct
        normalized_code,
        normalized_code_type,
        normalized_description
    from immunizations
    where normalized_code is not null
)

select
    {{ dbt_utils.generate_surrogate_key(['normalized_code']) }} as vaccine_sk,
    normalized_code as cvx_code,
    normalized_code_type as code_type,
    normalized_description as vaccine_name,
    case
        when normalized_description ilike '%influenza%' or normalized_description ilike '%flu%' then 'Influenza'
        when normalized_description ilike '%covid%' or normalized_description ilike '%sars%' then 'COVID-19'
        when normalized_description ilike '%dtap%' or normalized_description ilike '%tdap%' then 'DTaP/Tdap'
        when normalized_description ilike '%mmr%' or normalized_description ilike '%measles%' then 'MMR'
        when normalized_description ilike '%polio%' or normalized_description ilike '%ipv%' then 'Polio'
        when normalized_description ilike '%hepatitis%' or normalized_description ilike '%hep%' then 'Hepatitis'
        when normalized_description ilike '%hpv%' or normalized_description ilike '%papilloma%' then 'HPV'
        when normalized_description ilike '%pneumo%' or normalized_description ilike '%pcv%' then 'Pneumococcal'
        when normalized_description ilike '%zoster%' or normalized_description ilike '%shingles%' then 'Shingles'
        when normalized_description ilike '%varicella%' or normalized_description ilike '%chickenpox%' then 'Varicella'
        when normalized_description ilike '%meningococcal%' or normalized_description ilike '%mening%' then 'Meningococcal'
        when normalized_description ilike '%rotavirus%' then 'Rotavirus'
        when normalized_description ilike '%hib%' or normalized_description ilike '%haemophilus%' then 'Hib'
        else 'Other'
    end as vaccine_category,
    case
        when normalized_description ilike '%dtap%' 
            or normalized_description ilike '%mmr%' 
            or normalized_description ilike '%polio%' 
            or normalized_description ilike '%hep b%' 
            or normalized_description ilike '%rotavirus%' 
            or normalized_description ilike '%hib%' 
            or normalized_description ilike '%varicella%' 
            or normalized_description ilike '%pcv%'
            then 'Childhood'
        when normalized_description ilike '%zoster%' 
            or normalized_description ilike '%shingles%' 
            or normalized_description ilike '%pneumo%'
            then 'Adult'
        else 'All Ages'
    end as age_group_target
from vaccines
