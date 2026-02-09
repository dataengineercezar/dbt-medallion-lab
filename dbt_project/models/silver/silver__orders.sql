with bronze as (
    select * from {{ ref('bronze__orders') }}
),

cleaned as (
    select
        order_id,
        customer_id,
        order_status,
        total_amount,
        order_date,
        -- Flag para pedidos válidos (excluir cancelados/devolvidos)
        case
            when order_status in ('completed', 'pending') then true
            else false
        end as is_valid_order,
        -- Mês do pedido para análise temporal
        month(order_date) as order_month,
        year(order_date) as order_year,
        current_date as updated_at
    from bronze
)

select * from cleaned