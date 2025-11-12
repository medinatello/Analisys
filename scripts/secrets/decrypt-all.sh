#!/bin/bash

# ============================================
# Desencriptar TODOS los .env.enc files
# ============================================

echo "🔓 Desencriptando archivos de secretos..."
echo ""

for env in dev qa prod; do
    if [ -f ".env.$env.enc" ]; then
        echo "Desencriptando .env.$env.enc..."
        ./scripts/secrets/decrypt.sh $env
    else
        echo "⚠️  .env.$env.enc no existe (saltando)"
    fi
done

echo ""
echo "✅ Desencriptación completada"
echo "⚠️  Archivos .env.{dev,qa,prod} están en .gitignore"
