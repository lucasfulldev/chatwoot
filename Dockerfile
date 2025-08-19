FROM ruby:3.2.3

ENV RAILS_ENV=production \
    BUNDLE_PATH=/gems \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
# Adiciona esta linha para aumentar o limite de memória do Node.js
ENV NODE_OPTIONS=--max-old-space-size=4096

# Instala pacotes essenciais
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  curl \
  git \
  imagemagick \
  ffmpeg \
  vim

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm

# Configura git safe directory
RUN git config --global --add safe.directory /app

WORKDIR /app

# COPIAR SOMENTE DEPENDÊNCIAS PRIMEIRO
COPY package.json pnpm-lock.yaml* ./

# Instala dependências JS antes de copiar o restante do código
RUN pnpm install
RUN npx update-browserslist-db@latest # Adiciona este comando para atualizar o browserslist

# Instala bundler e gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --without development test

# Copia o restante do código
COPY . .

# Corepack
RUN npm install -g corepack && corepack enable && corepack prepare pnpm@latest --activate

# AGORA O CÓDIGO E AS DEPENDÊNCIAS ESTÃO PRESENTES, ENTÃO PODE RODAR O BUILD
# A linha abaixo foi removida pois NODE_OPTIONS já define o limite de memória para todos os comandos Node.js
# RUN node --max-old-space-size=4096 ./node_modules/vite/bin/vite.js build --mode production

RUN pnpm build # Este comando agora usará o limite de memória definido por NODE_OPTIONS


EXPOSE 9021
CMD ["./entrypoints/web.sh"]
