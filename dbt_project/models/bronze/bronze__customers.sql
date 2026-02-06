with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

staged as (
    select
        customer_id,
        customer_name,
        email,
        city,
        state,
        cast(created_at as date) as created_at
    from source
)

select * from staged