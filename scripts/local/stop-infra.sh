#!/bin/bash

# ============================================
# Detener Infraestructura (Mantiene Datos)
# ============================================

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RESET='\033[0m'

echo -e "${YELLOW}⏹️  Deteniendo infraestructura (datos preservados)...${RESET}"
docker-compose -f docker/docker-compose.local.yml stop
echo -e "${GREEN}✅ Infraestructura detenida (volúmenes intactos)${RESET}"
echo ""
echo -e "${YELLOW}💡 Para iniciar nuevamente:${RESET} ./scripts/local/start-infra.sh"
echo -e "${YELLOW}💡 Para destruir datos:${RESET} ./scripts/local/clean-infra.sh"
