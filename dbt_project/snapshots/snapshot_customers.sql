{% snapshot snapshot_customers %}

{{
    config(
        target_schema='medallion_db',
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_name', 'email', 'city', 'state', 'customer_segment'],
        invalidate_hard_deletes=True
    )
}}

select
    customer_id,
    customer_name,
    email,
    city,
    state,
    customer_segment,
    created_at,
    cast(now() as timestamp(3)) as snapshot_loaded_at
from {{ ref('silver__customers') }}

{% endsnapshot %}
