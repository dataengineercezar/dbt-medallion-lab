with bronze as (
    select * from {{ ref('bronze__products') }}
),

enriched as (
    select
        product_id,
        product_name,
        category,
        price,
        -- Faixa de preço
        case
            when price < 300 then 'low'
            when price < 1000 then 'medium'
            when price < 3000 then 'high'
            else 'premium'
        end as price_tier,
        current_date as updated_at
    from bronze
)

select * from enriched