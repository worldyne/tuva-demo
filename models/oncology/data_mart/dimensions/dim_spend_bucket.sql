{{ config(
    materialized='table',
    tags=['oncology', 'dimension']
) }}

with spend_buckets as (
    select * from (values
        (1, 'High Cost (>$100k)', 100000.00, null, 1),
        (2, 'Medium Cost ($25k-$100k)', 25000.00, 99999.99, 2),
        (3, 'Low Cost ($5k-$25k)', 5000.00, 24999.99, 3),
        (4, 'Minimal Cost (<$5k)', 0.00, 4999.99, 4)
    ) as t(spend_bucket_key, spend_bucket_name, min_threshold, max_threshold, sort_order)
)

select
    spend_bucket_key,
    spend_bucket_name,
    min_threshold,
    max_threshold,
    sort_order
from spend_buckets
