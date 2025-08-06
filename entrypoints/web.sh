#!/bin/bash
set -e

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
# ATENÇÃO: Para ambientes de produção, considere a idempotência das seeds.
# Se as seeds criam dados que não devem ser duplicados, adicione lógica para verificar
# a existência antes de criar, ou use um comando de seed mais específico para deploy.
bin/rails db:seed

echo "Pré-compilando assets..."
bin/rails assets:precompile

echo "Iniciando o servidor Puma..."
bundle exec puma -C config/puma.rb
