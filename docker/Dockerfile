FROM python:3.10-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar dbt + adapter Athena
RUN pip install --no-cache-dir \
    dbt-core==1.8.* \
    dbt-athena-community==1.8.*

# Diretório de trabalho
WORKDIR /dbt

# Copiar profiles.yml para o diretório padrão do dbt
RUN mkdir -p /root/.dbt

ENTRYPOINT ["dbt"]
CMD ["--version"]