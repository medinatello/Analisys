#!/bin/bash

# ============================================
# Encriptar archivo .env con SOPS
# ============================================

if [ -z "$1" ]; then
    echo "Uso: ./encrypt.sh <ambiente>"
    echo "Ejemplo: ./encrypt.sh dev"
    exit 1
fi

ENV=$1
SOURCE_FILE=".env.$ENV"
OUTPUT_FILE=".env.$ENV.enc"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "❌ Archivo $SOURCE_FILE no existe"
    exit 1
fi

echo "🔐 Encriptando $SOURCE_FILE → $OUTPUT_FILE"
sops -e "$SOURCE_FILE" > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Encriptado exitosamente"
    echo "💡 Ahora puedes commitear: git add $OUTPUT_FILE"
else
    echo "❌ Error al encriptar"
    exit 1
fi
