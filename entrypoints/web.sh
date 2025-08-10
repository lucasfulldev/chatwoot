#!/bin/bash
set -e

# Cria os diretórios necessários para o Puma antes de iniciar o servidor
# O flag '-p' garante que os diretórios serão criados se não existirem
# e não falhará se já existirem.
mkdir -p tmp/pids
mkdir -p tmp/sockets

# Instala dependências JS se não existirem
if [ ! -d "node_modules" ]; then
  echo "Installing JS dependencies..."
  pnpm install || npm install || yarn install
fi

echo "Criando banco de dados se não existir..."
bin/rails db:create
echo "Rodando migrations..."
bin/rails db:migrate
echo "Rodando seeds (populando dados iniciais)..."
bin/rails db:seed

echo "Pré-compilando assets..."
bin/rails assets:precompile

echo "Iniciando o servidor Puma..."
bundle exec puma -C config/puma.rb