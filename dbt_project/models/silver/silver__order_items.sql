with bronze_items as (
    select * from {{ ref('bronze__order_items') }}
),

bronze_products as (
    select * from {{ ref('bronze__products') }}
),

enriched as (
    select
        i.item_id,
        i.order_id,
        i.product_id,
        p.product_name,
        p.category,
        i.quantity,
        i.unit_price,
        cast(i.quantity * i.unit_price as decimal(10,2)) as line_total,
        current_date as updated_at
    from bronze_items i
    left join bronze_products p
        on i.product_id = p.product_id
)

select * from enriched