with customers as (
    select * from {{ ref('silver__customers') }}
),

orders as (
    select * from {{ ref('silver__orders_enriched') }}
),

summary as (
    select
        c.customer_id,
        c.customer_name,
        c.city,
        c.state,
        c.customer_segment,
        count(case when o.is_valid_order = true then o.order_id end) as completed_orders,
        count(case when o.order_status = 'cancelled' then o.order_id end) as cancelled_orders,
        count(case when o.order_status = 'returned' then o.order_id end) as returned_orders,
        coalesce(cast(sum(case when o.is_valid_order = true then o.total_amount else 0 end) as decimal(12,2)), cast(0 as decimal(12,2))) as total_spent,
        coalesce(cast(avg(case when o.is_valid_order = true then o.total_amount end) as decimal(10,2)), cast(0 as decimal(10,2))) as avg_order_value,
        c.created_at as signup_date,
        max(o.order_date) as last_order_date,
        current_date as updated_at
    from customers c
    left join orders o
        on c.customer_id = o.customer_id
    group by
        c.customer_id, c.customer_name, c.city,
        c.state, c.customer_segment, c.created_at
)

select * from summary
order by total_spent desc