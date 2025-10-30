#!/bin/bash

# ============================================
# Desencriptar archivo .env.enc con SOPS
# ============================================

if [ -z "$1" ]; then
    echo "Uso: ./decrypt.sh <ambiente>"
    echo "Ejemplo: ./decrypt.sh dev"
    exit 1
fi

ENV=$1
SOURCE_FILE=".env.$ENV.enc"
OUTPUT_FILE=".env.$ENV"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "❌ Archivo $SOURCE_FILE no existe"
    exit 1
fi

echo "🔓 Desencriptando $SOURCE_FILE → $OUTPUT_FILE"
sops -d "$SOURCE_FILE" > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Desencriptado exitosamente"
    echo "⚠️  $OUTPUT_FILE está en .gitignore (NO commitear)"
else
    echo "❌ Error al desencriptar (¿tienes la clave correcta?)"
    exit 1
fi
