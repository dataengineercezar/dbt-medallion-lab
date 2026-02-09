with orders as (
    select * from {{ ref('silver__orders_enriched') }}
    where is_valid_order = true
),

clv as (
    select
        customer_id,
        customer_name,
        email,
        city,
        state,
        customer_segment,
        count(distinct order_id) as total_orders,
        cast(sum(total_amount) as decimal(12,2)) as lifetime_value,
        cast(avg(total_amount) as decimal(10,2)) as avg_order_value,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        date_diff('day', min(order_date), max(order_date)) as days_as_customer,
        -- Classificação por valor
        case
            when sum(total_amount) >= 5000 then 'platinum'
            when sum(total_amount) >= 2000 then 'gold'
            when sum(total_amount) >= 500 then 'silver'
            else 'bronze'
        end as value_tier,
        current_date as updated_at
    from orders
    group by
        customer_id, customer_name, email,
        city, state, customer_segment
)

select * from clv
order by lifetime_value desc