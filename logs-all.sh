#!/bin/bash

# ============================================
# Ver Logs de Todos los Servicios
# ============================================

# Colors
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RESET='\033[0m'

echo -e "${BLUE}📊 Logs de Todos los Servicios (Ctrl+C para salir)${RESET}"
echo ""

# Verificar que existan los logs
mkdir -p logs

# Mostrar logs con colores
tail -f logs/api-mobile.log logs/api-admin.log logs/worker.log 2>/dev/null | while read line; do
    case "$line" in
        *api-mobile*)
            echo -e "${GREEN}[API Mobile]${RESET} $line"
            ;;
        *api-admin*)
            echo -e "${YELLOW}[API Admin]${RESET} $line"
            ;;
        *worker*)
            echo -e "${BLUE}[Worker]${RESET} $line"
            ;;
        *)
            echo "$line"
            ;;
    esac
done
