# Contratos de Dados & Estratégia de Qualidade

## O Que São Contratos de Dados?

Contratos de dados são acordos formais sobre a estrutura, formato e qualidade dos dados trocados entre produtores e consumidores. No dbt, são garantidos através de arquivos YAML de schema.

Funcionam como uma **API de dados**: se o produtor alterar a estrutura sem avisar, o pipeline quebra propositalmente — evitando que dados incorretos cheguem aos consumidores.

---

## Implementação Neste Projeto

### Aplicação dos Contratos

Todos os modelos Silver e Gold possuem contratos ativos:

```yaml
config:
  contract:
    enforced: true
```

Isso garante que:
- Nomes das colunas correspondam exatamente ao declarado
- Tipos de dados sejam validados na materialização
- Qualquer desvio de schema cause falha no build (fail-fast)

---

## Matriz de Cobertura de Testes

| Camada | Tipo de Teste | Qtd | Exemplos |
|--------|--------------|-----|----------|
| Bronze (Sources) | `unique` | 4 | Todas as chaves primárias |
| Bronze (Sources) | `not_null` | 5 | PKs + chaves estrangeiras |
| Bronze (Sources) | `relationships` | 1 | orders → customers (FK) |
| Silver | `unique` | 5 | Todas as chaves primárias |
| Silver | `not_null` | 8 | PKs + campos críticos |
| Silver | `accepted_values` | 2 | customer_segment, price_tier |
| Gold | `unique` | 4 | Todas as chaves primárias |
| Gold | `not_null` | 6 | PKs + métricas-chave |
| Gold | `accepted_values` | 1 | value_tier |
| Custom | SQL Singular | 3 | Validações de regras de negócio |
| **Total** | | **39** | |

---

## Dimensões de Qualidade Cobertas

| Dimensão | Como É Testada |
|----------|----------------|
| **Unicidade** | Testes `unique` em todas as chaves primárias |
| **Completude** | Testes `not_null` em colunas críticas |
| **Validade** | Testes `accepted_values` para campos categóricos |
| **Integridade Referencial** | Testes `relationships` para chaves estrangeiras |
| **Acurácia** | Testes SQL customizados para regras de negócio |
| **Consistência** | Validação cruzada entre modelos (totais de pedidos) |
| **Temporalidade** | Rastreamento via snapshots com `dbt_valid_from/to` |

---

## Testes Singulares (Customizados)

### Receita Positiva
Garante que não existem receitas negativas ou zeradas na Gold:
```sql
-- tests/assert_positive_revenue.sql
select order_month, gross_revenue
from {{ ref('gold__revenue_per_month') }}
where gross_revenue <= 0
```

### Total de Pedido Válido
Valida que os totais de gasto por cliente são consistentes:
```sql
-- tests/assert_valid_order_total.sql
select customer_id, total_spent
from {{ ref('gold__customer_lifetime_value') }}
where total_spent < 0
```

### Cliente Possui Pedidos
Garante que todo cliente na Gold realmente possui pedidos:
```sql
-- tests/assert_customer_has_orders.sql
select customer_id, total_orders
from {{ ref('gold__customer_summary') }}
where total_orders <= 0
```

---

## Executando os Testes

```bash
# Todos os testes (39)
dbt test

# Apenas testes de sources (Bronze)
dbt test --select source:raw

# Apenas testes singulares (customizados)
dbt test --select test_type:singular

# Testes de um modelo específico
dbt test --select silver__customers

# Testes da camada Gold inteira
dbt test --select gold__revenue_per_month gold__customer_lifetime_value gold__top_products gold__customer_summary
```

---

## Resultado Esperado

```
Completed successfully

Done. PASS=39 WARN=0 ERROR=0 SKIP=0 TOTAL=39
```
