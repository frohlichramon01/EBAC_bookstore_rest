# `python-base` sets up all our shared environment variables
FROM python:3.10-slim as python-base

# Definir variáveis de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.2.0 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Instalar dependências do sistema
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar o Poetry
RUN curl -sSL https://install.python-poetry.org | python

# Instalar dependências do Postgres
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho para o projeto
WORKDIR $PYSETUP_PATH

# Copiar arquivos do projeto para o diretório de trabalho
COPY pyproject.toml poetry.lock ./

# Verificar se os arquivos estão presentes no diretório
RUN ls -la /opt/pysetup

# Copiar o restante dos arquivos da aplicação para o contêiner
COPY . /opt/pysetup/

# Verificar o conteúdo após copiar tudo
RUN ls -la /opt/pysetup

# Instalar dependências de runtime
RUN poetry install --only main

# Instalar pytest e factory-boy
RUN pip install factory-boy==3.3.1 pytest==8.3.3

# Definir diretório de trabalho para a aplicação
WORKDIR /app
COPY . /app/

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
