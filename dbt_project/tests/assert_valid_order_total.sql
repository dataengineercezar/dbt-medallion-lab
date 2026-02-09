-- Valida que o total do pedido é maior que zero para pedidos válidos
select
    order_id,
    total_amount,
    is_valid_order
from {{ ref('silver__orders') }}
where is_valid_order = true
    and total_amount <= 0