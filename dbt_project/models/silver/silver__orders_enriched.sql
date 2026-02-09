with orders as (
    select * from {{ ref('silver__orders') }}
),

customers as (
    select * from {{ ref('silver__customers') }}
),

order_items_agg as (
    select
        order_id,
        count(*) as total_items,
        sum(line_total) as calculated_total
    from {{ ref('silver__order_items') }}
    group by order_id
),

enriched as (
    select
        o.order_id,
        o.customer_id,
        c.customer_name,
        c.email,
        c.city,
        c.state,
        c.customer_segment,
        o.order_status,
        o.is_valid_order,
        o.total_amount,
        coalesce(oi.total_items, 0) as total_items,
        coalesce(oi.calculated_total, cast(0 as decimal(10,2))) as calculated_total,
        o.order_date,
        o.order_month,
        o.order_year,
        o.updated_at
    from orders o
    left join customers c
        on o.customer_id = c.customer_id
    left join order_items_agg oi
        on o.order_id = oi.order_id
)

select * from enriched
