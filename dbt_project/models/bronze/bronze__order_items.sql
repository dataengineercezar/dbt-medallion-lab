with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

staged as (
    select
        item_id,
        order_id,
        product_id,
        quantity,
        cast(unit_price as decimal(10,2)) as unit_price
    from source
)

select * from staged
