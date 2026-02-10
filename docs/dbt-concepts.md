# Conceitos do dbt Aplicados Neste Projeto

## Seeds (Sementes de Dados)

Seeds são arquivos CSV carregados diretamente no data warehouse. Neste projeto, simulam dados brutos de um sistema de e-commerce.

```
seeds/
├── raw_customers.csv    (10 registros)
├── raw_orders.csv       (20 registros)
├── raw_products.csv     (8 registros)
└── raw_order_items.csv  (25 registros)
```

**Configuração em `dbt_project.yml`:**
```yaml
seeds:
  medallion_lab:
    schema: medallion_db
    +column_types:
      price: double
      total_amount: double
      unit_price: double
```

---

## Models (Modelos)

Modelos são instruções SQL `SELECT` que definem transformações. Cada modelo produz uma tabela ou view.

### Materializações Utilizadas
- **view** — Camada Bronze; leve, sempre reflete os dados atuais da origem
- **table** — Camadas Silver/Gold; materializadas como tabelas Iceberg no S3

### Referenciamento
- `{{ source('raw', 'raw_customers') }}` — Referencia um seed/source
- `{{ ref('silver__customers') }}` — Referencia outro modelo

---

## Testes de Dados

### Testes Genéricos (definidos em YAML)
Aplicados via arquivos YAML de schema:
- `unique` — Garante que não há valores duplicados
- `not_null` — Garante que não há valores NULL
- `accepted_values` — Valida contra uma lista permitida
- `relationships` — Valida integridade referencial (chaves estrangeiras)

### Testes Singulares (arquivos SQL)
Queries SQL customizadas no diretório `tests/` que retornam linhas que violam uma condição:
- `assert_positive_revenue.sql` — Valida que todos os valores de receita são > 0
- `assert_valid_order_total.sql` — Valida cruzamento de totais de pedidos
- `assert_customer_has_orders.sql` — Garante que clientes na Gold possuem pedidos

---

## Snapshots (SCD Tipo 2)

Snapshots rastreiam mudanças nos dados de origem ao longo do tempo usando Slowly Changing Dimensions (Dimensões de Mudança Lenta).

**Estratégia: `check`**
Compara colunas especificadas entre execuções para detectar mudanças.

```sql
{% snapshot snapshot_customers %}
{{
    config(
        strategy='check',
        check_cols=['customer_name', 'email', 'city', 'state', 'customer_segment'],
        unique_key='customer_id',
        invalidate_hard_deletes=True
    )
}}
-- ...
{% endsnapshot %}
```

**Colunas Geradas Automaticamente:**

| Coluna | Finalidade |
|--------|-----------|
| `dbt_scd_id` | Hash único para cada versão do registro |
| `dbt_valid_from` | Timestamp de quando esta versão se tornou ativa |
| `dbt_valid_to` | Timestamp de quando esta versão foi substituída (NULL = atual) |
| `dbt_updated_at` | Timestamp da execução do snapshot |

**Exemplo de SCD Tipo 2 validado neste projeto:**

| customer_id | city | state | dbt_valid_from | dbt_valid_to | Status |
|-------------|------|-------|----------------|--------------|--------|
| 1 | Sao Paulo | SP | 2026-02-09 | 2026-02-10 | Expirado |
| 1 | Rio de Janeiro | RJ | 2026-02-10 | NULL | Ativo |

---

## Data Contracts (Contratos de Dados)

Garantem a estrutura dos modelos via schemas YAML nas camadas Silver e Gold:

```yaml
models:
  - name: silver__customers
    config:
      contract:
        enforced: true
    columns:
      - name: customer_id
        data_type: integer
        data_tests:
          - unique
          - not_null
```

Quando o contrato está ativo (`enforced: true`):
- Nomes das colunas devem corresponder exatamente
- Tipos de dados são validados
- Qualquer desvio de schema causa falha no build

---

## Estrutura do Projeto

```
dbt_project/
├── dbt_project.yml          # Configuração do projeto
├── profiles.yml             # Perfis de conexão (Athena)
├── seeds/                   # Dados brutos em CSV
├── models/
│   ├── bronze/              # Camada bruta (views)
│   ├── silver/              # Camada limpa (tabelas Iceberg)
│   └── gold/                # Camada de negócio (tabelas Iceberg)
├── snapshots/               # Rastreamento SCD Tipo 2
└── tests/                   # Testes singulares customizados
```

---

## Comandos Essenciais

```bash
# Carregar seeds no warehouse
dbt seed

# Executar todos os modelos
dbt run

# Executar testes de qualidade
dbt test

# Executar snapshots
dbt snapshot

# Pipeline completo
dbt seed && dbt run && dbt snapshot && dbt test

# Executar modelo específico
dbt run --select silver__customers

# Executar testes de um modelo
dbt test --select silver__customers

# Executar apenas testes singulares
dbt test --select test_type:singular

# Validar conexão
dbt debug
```
