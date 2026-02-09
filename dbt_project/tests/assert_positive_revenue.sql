-- Valida que nenhuma receita mensal é negativa
select
    order_year,
    order_month,
    gross_revenue
from {{ ref('gold__revenue_per_month') }}
where gross_revenue < 0