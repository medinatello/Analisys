#!/bin/bash

# ============================================
# Encriptar TODOS los .env files
# ============================================

echo "🔐 Encriptando todos los archivos de secretos..."
echo ""

for env in dev qa prod; do
    if [ -f ".env.$env" ]; then
        echo "Encriptando .env.$env..."
        ./scripts/secrets/encrypt.sh $env
    else
        echo "⚠️  .env.$env no existe (saltando)"
    fi
done

echo ""
echo "✅ Encriptación completada"
echo "💡 Commitear: git add .env.*.enc"
