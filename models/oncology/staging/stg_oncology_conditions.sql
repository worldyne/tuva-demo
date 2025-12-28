{{ config(
    materialized='view',
    tags=['oncology', 'staging']
) }}

with conditions as (
    select
        condition_id,
        person_id,
        encounter_id,
        claim_id,
        recorded_date,
        condition_type,
        source_code_type,
        source_code,
        normalized_code_type,
        normalized_code,
        normalized_description,
        data_source
    from {{ ref('core__condition') }}
    where normalized_code_type = 'icd-10-cm'
),

cancer_conditions as (
    select
        *,
        case
            when normalized_code >= 'C00' and normalized_code < 'C15' then 'Lip, Oral Cavity & Pharynx'
            when normalized_code >= 'C15' and normalized_code < 'C27' then 'Digestive Organs'
            when normalized_code >= 'C30' and normalized_code < 'C40' then 'Respiratory & Intrathoracic'
            when normalized_code >= 'C40' and normalized_code < 'C42' then 'Bone & Articular Cartilage'
            when normalized_code >= 'C43' and normalized_code < 'C45' then 'Melanoma & Skin'
            when normalized_code >= 'C45' and normalized_code < 'C50' then 'Mesothelial & Soft Tissue'
            when normalized_code >= 'C50' and normalized_code < 'C51' then 'Breast'
            when normalized_code >= 'C51' and normalized_code < 'C59' then 'Female Genital Organs'
            when normalized_code >= 'C60' and normalized_code < 'C64' then 'Male Genital Organs'
            when normalized_code >= 'C64' and normalized_code < 'C69' then 'Urinary Tract'
            when normalized_code >= 'C69' and normalized_code < 'C73' then 'Eye, Brain & CNS'
            when normalized_code >= 'C73' and normalized_code < 'C76' then 'Thyroid & Endocrine Glands'
            when normalized_code >= 'C76' and normalized_code < 'C7A' then 'Ill-defined & Secondary Sites'
            when normalized_code >= 'C7A' and normalized_code < 'C7B' then 'Neuroendocrine Tumors'
            when normalized_code >= 'C7B' and normalized_code < 'C81' then 'Secondary Neuroendocrine'
            when normalized_code >= 'C81' and normalized_code < 'C97' then 'Hematologic'
            when normalized_code >= 'D00' and normalized_code < 'D10' then 'In Situ Neoplasms'
            when normalized_code >= 'D10' and normalized_code < 'D37' then 'Benign Neoplasms'
            when normalized_code >= 'D37' and normalized_code < 'D3A' then 'Uncertain Behavior'
            when normalized_code >= 'D3A' and normalized_code < 'D3B' then 'Benign Neuroendocrine'
            when normalized_code >= 'D48' and normalized_code < 'D49' then 'Uncertain Behavior'
            when normalized_code >= 'D49' and normalized_code < 'D50' then 'Unspecified Behavior'
            else 'Other Neoplasm'
        end as cancer_type
    from conditions
    where (
        (normalized_code >= 'C00' and normalized_code < 'C97')
        or (normalized_code >= 'C7A' and normalized_code < 'C7C')
        or (normalized_code >= 'D00' and normalized_code < 'D50')
        or (normalized_code >= 'D3A' and normalized_code < 'D3B')
    )
)

select * from cancer_conditions
