with orders as (
    select * from {{ ref('silver__orders_enriched') }}
    where is_valid_order = true
),

monthly_revenue as (
    select
        order_year,
        order_month,
        count(distinct order_id) as total_orders,
        count(distinct customer_id) as unique_customers,
        cast(sum(total_amount) as decimal(12,2)) as gross_revenue,
        cast(avg(total_amount) as decimal(10,2)) as avg_ticket,
        sum(total_items) as total_items_sold,
        current_date as updated_at
    from orders
    group by order_year, order_month
)

select * from monthly_revenue
order by order_year, order_month