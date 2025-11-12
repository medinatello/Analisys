#!/bin/bash

# ============================================
# Verificar si BD tiene datos cargados
# ============================================

CONTAINER_NAME="edugo-postgres-local"

# Verificar que PostgreSQL tenga la tabla app_user con datos
COUNT=$(docker exec $CONTAINER_NAME psql -U edugo_user -d edugo -t -c \
  "SELECT COUNT(*) FROM app_user;" 2>/dev/null | tr -d ' ')

if [ $? -eq 0 ] && [ "$COUNT" -gt 0 ]; then
    echo "✅ PostgreSQL tiene datos ($COUNT usuarios)"
    exit 0
else
    echo "❌ PostgreSQL sin datos o tabla no existe"
    exit 1
fi
