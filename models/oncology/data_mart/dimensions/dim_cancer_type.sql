{{ config(
    materialized='table',
    tags=['oncology', 'dimension']
) }}

with cancer_types as (
    select * from (values
        (1, 'Lip, Oral Cavity & Pharynx', 'C00', 'C15', 'Malignant', 1),
        (2, 'Digestive Organs', 'C15', 'C27', 'Malignant', 2),
        (3, 'Respiratory & Intrathoracic', 'C30', 'C40', 'Malignant', 3),
        (4, 'Bone & Articular Cartilage', 'C40', 'C42', 'Malignant', 4),
        (5, 'Melanoma & Skin', 'C43', 'C45', 'Malignant', 5),
        (6, 'Mesothelial & Soft Tissue', 'C45', 'C50', 'Malignant', 6),
        (7, 'Breast', 'C50', 'C51', 'Malignant', 7),
        (8, 'Female Genital Organs', 'C51', 'C59', 'Malignant', 8),
        (9, 'Male Genital Organs', 'C60', 'C64', 'Malignant', 9),
        (10, 'Urinary Tract', 'C64', 'C69', 'Malignant', 10),
        (11, 'Eye, Brain & CNS', 'C69', 'C73', 'Malignant', 11),
        (12, 'Thyroid & Endocrine Glands', 'C73', 'C76', 'Malignant', 12),
        (13, 'Ill-defined & Secondary Sites', 'C76', 'C7A', 'Malignant', 13),
        (14, 'Neuroendocrine Tumors', 'C7A', 'C7B', 'Malignant', 14),
        (15, 'Secondary Neuroendocrine', 'C7B', 'C81', 'Malignant', 15),
        (16, 'Hematologic', 'C81', 'C97', 'Malignant', 16),
        (17, 'In Situ Neoplasms', 'D00', 'D10', 'In Situ', 17),
        (18, 'Benign Neoplasms', 'D10', 'D37', 'Benign', 18),
        (19, 'Uncertain Behavior', 'D37', 'D49', 'Uncertain', 19),
        (20, 'Benign Neuroendocrine', 'D3A', 'D3B', 'Benign', 20),
        (21, 'Unspecified Behavior', 'D49', 'D50', 'Unspecified', 21),
        (99, 'Other Neoplasm', null, null, 'Other', 99)
    ) as t(cancer_type_key, cancer_type_name, icd10_range_start, icd10_range_end, category, sort_order)
)

select
    cancer_type_key,
    cancer_type_name,
    icd10_range_start,
    icd10_range_end,
    category,
    sort_order
from cancer_types
