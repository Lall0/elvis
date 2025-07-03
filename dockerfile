# Usa uma imagem oficial do Python com base no Alpine Linux.
# Alpine é extremamente leve, mas pode exigir a compilação de algumas dependências.
FROM python:3.13.5-alpine3.22

# Define as variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Define o diretório de trabalho no contêiner
WORKDIR /app

# Copia o arquivo de dependências e as instala.
# Isso é feito em um passo separado para aproveitar o cache de camadas do Docker.
# As dependências só serão reinstaladas se o requirements.txt for alterado.
COPY requirements.txt .
# Instala as dependências do Python.
# Instala temporariamente as ferramentas de compilação (gcc, musl-dev), usa-as para o pip, e depois as remove na mesma camada para otimizar o tamanho da imagem.
RUN apk add --no-cache --virtual .build-deps gcc musl-dev && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apk del .build-deps

# Copia o restante do código da aplicação para o diretório de trabalho
COPY . .

# Expõe a porta 8000 para indicar em qual porta a aplicação está rodando.
EXPOSE 8000

# Executa o servidor uvicorn. Use 0.0.0.0 para torná-lo acessível de fora do contêiner.
# A flag --reload é removida, pois não é recomendada para produção.
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]