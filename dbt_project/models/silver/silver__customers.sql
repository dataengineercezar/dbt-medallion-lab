with bronze as (
    select * from {{ ref('bronze__customers') }}
),

cleaned as (
    select
        customer_id,
        customer_name,
        lower(trim(email)) as email,
        concat(upper(substr(city, 1, 1)), lower(substr(city, 2))) as city,
        upper(state) as state,
        created_at,
        -- Classificação por antiguidade
        case
            when created_at < date '2025-04-01' then 'early_adopter'
            when created_at < date '2025-07-01' then 'mid_adopter'
            else 'late_adopter'
        end as customer_segment,
        current_date as updated_at
    from bronze
)

select * from cleaned