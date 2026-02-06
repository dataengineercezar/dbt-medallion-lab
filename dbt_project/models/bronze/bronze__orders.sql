with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

staged as (
    select
        order_id,
        customer_id,
        order_status,
        cast(total_amount as decimal(10,2)) as total_amount,
        cast(order_date as date) as order_date
    from source
)

select * from staged