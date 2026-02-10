# Arquitetura Medallion (Bronze → Silver → Gold)

## Visão Geral

A Arquitetura Medallion é um padrão de design de dados utilizado para organizar logicamente os dados em um lakehouse. Os dados são refinados progressivamente através de três camadas, cada uma com um propósito específico.

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   BRONZE    │────▶│   SILVER    │────▶│    GOLD     │
│ Dados Brutos│     │  Limpos e   │     │  Agregações │
│  Sem Filtro │     │ Enriquecidos│     │  de Negócio │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Camada Bronze (Dados Brutos)

**Objetivo:** Ingerir dados brutos com transformação mínima (apenas tipagem).

| Aspecto | Implementação |
|---------|---------------|
| Materialização | `view` |
| Transformações | Apenas casting de tipos |
| Origem | Seeds do dbt (arquivos CSV) |
| Modelos | `bronze__customers`, `bronze__orders`, `bronze__products`, `bronze__order_items` |

**Princípios:**
- Nenhuma lógica de negócio aplicada
- Abordagem schema-on-read
- Atua como área de staging
- Origem rastreável para linhagem de dados

---

## Camada Silver (Limpo e Enriquecido)

**Objetivo:** Limpar, validar e enriquecer os dados para consumo analítico.

| Aspecto | Implementação |
|---------|---------------|
| Materialização | `table` (Iceberg) |
| Transformações | Limpeza, normalização, enriquecimento |
| Data Contracts | Garantidos via schemas YAML do dbt |
| Modelos | `silver__customers`, `silver__orders`, `silver__products`, `silver__order_items`, `silver__orders_enriched` |

**Transformações Aplicadas:**
- **Customers:** Normalização de email (lowercase/trim), segmentação de clientes por data de cadastro
- **Products:** Classificação de faixa de preço (low/medium/high/premium)
- **Orders:** Flags de validade, extração de campos temporais (ano/mês/dia)
- **Order Items:** Cálculo de total por linha, enriquecimento com dados de produto via join
- **Orders Enriched:** Visão desnormalizada completa com dados de cliente + produto

---

## Camada Gold (Agregações de Negócio)

**Objetivo:** Entregar KPIs e agregações prontas para consumo pelo negócio.

| Aspecto | Implementação |
|---------|---------------|
| Materialização | `table` (Iceberg) |
| Transformações | Agregações, rankings, KPIs |
| Consumidores | Ferramentas de BI, dashboards, relatórios |
| Modelos | `gold__revenue_per_month`, `gold__customer_lifetime_value`, `gold__top_products`, `gold__customer_summary` |

**KPIs de Negócio:**
- **Receita por Mês:** Receita bruta/líquida mensal com contagem de pedidos
- **Customer Lifetime Value:** Gasto total, frequência de compras, classificação por faixa de valor
- **Top Produtos:** Ranking de receita com análise de quantidade e margem
- **Resumo do Cliente:** Visão 360° com todas as métricas-chave

---

## Diagrama de Fluxo de Dados

```
Seeds (CSV)
  │
  ▼
Bronze (Views) ──── Testes de Source (unique, not_null, relationships)
  │
  ▼
Silver (Tabelas Iceberg) ──── Testes de Modelo + Data Contracts
  │
  ▼
Gold (Tabelas Iceberg) ──── Testes de Validação de Negócio
  │
  ▼
Snapshots (SCD Tipo 2) ──── Rastreamento de Mudanças Históricas
```
