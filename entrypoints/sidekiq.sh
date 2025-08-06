#!/bin/bash
set -e

echo "🚀 Iniciando Sidekiq..."
bundle exec sidekiq -C config/sidekiq.yml
