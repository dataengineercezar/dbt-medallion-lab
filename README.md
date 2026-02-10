# 🥇 dbt Medallion Architecture Lab

Repositório hands-on demonstrando **dbt (Data Build Tool)** com **Medallion Architecture** (Bronze → Silver → Gold) sobre **AWS Athena + S3 + Iceberg**.

Projeto completo com **seeds, models, data contracts, testes de qualidade e snapshots SCD Tipo 2**.

---

## 📦 Stack Tecnológica

| Tecnologia | Versão | Papel |
|---|---|---|
| dbt-core | 1.8.9 | Transformação de dados (ELT) |
| dbt-athena-community | 1.8.4 | Adapter AWS Athena |
| AWS Athena | v3 | Engine SQL serverless |
| AWS S3 | - | Storage do Data Lake |
| AWS Glue Catalog | - | Metastore |
| Apache Iceberg | - | Table format (ACID, time travel) |
| Docker | - | Ambiente reprodutível |
| Python | 3.10 | Runtime do dbt |
| Git | - | Versionamento semântico |

---

## 🏗️ Arquitetura

```
Seeds (CSV)  ──▶  Bronze (Views)  ──▶  Silver (Tabelas Iceberg)  ──▶  Gold (Tabelas Iceberg)
                                                │
                                                ▼
                                        Snapshots (SCD Tipo 2)
```

| Camada | Materialização | Propósito | Modelos |
|--------|---------------|-----------|---------|
| **Bronze** | view | Dados brutos com tipagem | 4 modelos |
| **Silver** | table (Iceberg) | Limpeza e enriquecimento | 5 modelos |
| **Gold** | table (Iceberg) | Agregações de negócio | 4 modelos |
| **Snapshots** | table (Iceberg) | Rastreamento histórico (SCD Tipo 2) | 1 snapshot |

---

## 📁 Estrutura do Projeto

```
dbt-medallion-lab/
├── docker/
│   ├── Dockerfile              # Imagem Python 3.10 + dbt
│   └── docker-compose.yml      # Serviço dbt-athena
├── dbt_project/
│   ├── dbt_project.yml         # Configuração do projeto
│   ├── profiles.yml            # Conexão Athena/S3
│   ├── seeds/                  # Dados brutos (CSV)
│   │   ├── raw_customers.csv
│   │   ├── raw_orders.csv
│   │   ├── raw_products.csv
│   │   └── raw_order_items.csv
│   ├── models/
│   │   ├── bronze/             # Camada bruta (views)
│   │   ├── silver/             # Camada limpa (tabelas)
│   │   └── gold/               # Camada de negócio (tabelas)
│   ├── snapshots/              # SCD Tipo 2
│   │   └── snapshot_customers.sql
│   └── tests/                  # Testes singulares
│       ├── assert_positive_revenue.sql
│       ├── assert_valid_order_total.sql
│       └── assert_customer_has_orders.sql
├── docs/
│   ├── medallion-architecture.md
│   ├── dbt-concepts.md
│   └── data-contracts.md
└── README.md
```

---

## 🧱 Modelos por Camada

### Bronze (Dados Brutos)
| Modelo | Origem | Descrição |
|--------|--------|-----------|
| `bronze__customers` | raw_customers | Clientes com casting de tipos |
| `bronze__orders` | raw_orders | Pedidos com casting de tipos |
| `bronze__products` | raw_products | Produtos com casting de tipos |
| `bronze__order_items` | raw_order_items | Itens de pedido com casting de tipos |

### Silver (Limpo e Enriquecido)
| Modelo | Transformações |
|--------|---------------|
| `silver__customers` | Normalização de email, segmentação de clientes |
| `silver__orders` | Flags de validade, campos temporais |
| `silver__products` | Classificação de faixa de preço |
| `silver__order_items` | Cálculo de total por linha, join com produtos |
| `silver__orders_enriched` | Visão 360° desnormalizada |

### Gold (Agregações de Negócio)
| Modelo | KPI |
|--------|-----|
| `gold__revenue_per_month` | Receita bruta/líquida mensal |
| `gold__customer_lifetime_value` | Valor do tempo de vida do cliente |
| `gold__top_products` | Ranking de produtos por receita |
| `gold__customer_summary` | Resumo completo por cliente |

---

## ✅ Qualidade de Dados

**39 testes** cobrindo 7 dimensões de qualidade:

| Tipo | Quantidade | Cobertura |
|------|-----------|-----------|
| `unique` | 13 | Unicidade de chaves primárias |
| `not_null` | 19 | Completude de campos críticos |
| `accepted_values` | 3 | Validade de campos categóricos |
| `relationships` | 1 | Integridade referencial |
| Testes singulares | 3 | Regras de negócio customizadas |

**Data Contracts** ativos em todas as camadas Silver e Gold com `enforced: true`.

---

## 🔄 Snapshots (SCD Tipo 2)

Snapshot `snapshot_customers` rastreia mudanças históricas usando estratégia `check`:

```
| customer_id | city           | dbt_valid_from | dbt_valid_to | Status   |
|-------------|----------------|----------------|--------------|----------|
| 1           | Sao Paulo      | 2026-02-09     | 2026-02-10   | Expirado |
| 1           | Rio de Janeiro | 2026-02-10     | NULL         | Ativo    |
```

---

## 🚀 Como Executar

### Pré-requisitos
- Docker e Docker Compose
- Conta AWS com Athena, S3 e Glue configurados
- Credenciais AWS em `~/.aws/credentials`

### Subir o ambiente
```bash
cd docker
docker compose up -d
```

### Executar o pipeline completo
```bash
# Validar conexão
docker exec -it dbt-athena dbt debug

# Carregar dados brutos
docker exec -it dbt-athena dbt seed

# Executar modelos (Bronze → Silver → Gold)
docker exec -it dbt-athena dbt run

# Executar snapshots
docker exec -it dbt-athena dbt snapshot

# Executar testes de qualidade
docker exec -it dbt-athena dbt test
```

### Pipeline completo em um comando
```bash
docker exec -it dbt-athena bash -c "dbt seed && dbt run && dbt snapshot && dbt test"
```

---

## 📚 Documentação

| Documento | Conteúdo |
|-----------|----------|
| [Arquitetura Medallion](docs/medallion-architecture.md) | Detalhamento das camadas Bronze, Silver e Gold |
| [Conceitos do dbt](docs/dbt-concepts.md) | Seeds, models, testes, snapshots e comandos |
| [Contratos de Dados](docs/data-contracts.md) | Estratégia de qualidade e matriz de testes |

---

## 📊 Resultado dos Testes

```
Done. PASS=39 WARN=0 ERROR=0 SKIP=0 TOTAL=39
```

---

## 🛠️ Decisões Técnicas

| Decisão | Justificativa |
|---------|--------------|
| `view` na Bronze | Evita duplicação de dados; sempre reflete a origem |
| `table` (Iceberg) na Silver/Gold | Performance de leitura, suporte a ACID e time travel |
| Estratégia `check` no snapshot | Não depende de coluna `updated_at` na origem |
| `timestamp(3)` no snapshot | Compatibilidade com precisão padrão do Athena/Iceberg |
| `data_tests` ao invés de `tests` | Conformidade com dbt 1.8+ (sintaxe não-deprecada) |
| `initcap()` substituído | Função não suportada pelo Athena; usado `concat(upper(substr()),lower(substr()))` |

---

## 👤 Autor

**Cezar Carmo** — [GitHub](https://github.com/dataengineercezar)
