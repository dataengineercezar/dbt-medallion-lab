-- Valida que todos os clientes no Gold summary existem na Silver
select
    g.customer_id
from {{ ref('gold__customer_summary') }} g
left join {{ ref('silver__customers') }} s
    on g.customer_id = s.customer_id
where s.customer_id is null