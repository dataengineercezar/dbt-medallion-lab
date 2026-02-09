with items as (
    select * from {{ ref('silver__order_items') }}
),

product_metrics as (
    select
        product_id,
        product_name,
        category,
        count(distinct order_id) as times_ordered,
        sum(quantity) as total_quantity_sold,
        cast(sum(line_total) as decimal(12,2)) as total_revenue,
        cast(avg(unit_price) as decimal(10,2)) as avg_selling_price,
        -- Ranking por receita
        row_number() over (order by sum(line_total) desc) as revenue_rank,
        -- Ranking por quantidade
        row_number() over (order by sum(quantity) desc) as quantity_rank,
        current_date as updated_at
    from items
    group by product_id, product_name, category
)

select * from product_metrics
order by total_revenue desc