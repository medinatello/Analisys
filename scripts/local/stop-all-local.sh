#!/bin/bash

# ============================================
# Detener Apps + Infraestructura (Mantiene Datos)
# ============================================

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RESET='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║      ⏹️  Deteniendo Stack EduGo (Local)      ║${RESET}"
echo -e "${BLUE}╔════════════════════════════════════════════════╗${RESET}"
echo ""

# Detener aplicaciones
echo -e "${YELLOW}[1/2] Deteniendo aplicaciones...${RESET}"
./stop-all.sh

# Detener infraestructura (mantiene datos)
echo -e "${YELLOW}[2/2] Deteniendo infraestructura...${RESET}"
./scripts/local/stop-infra.sh

echo ""
echo -e "${GREEN}✅ Stack detenido (datos preservados en volúmenes Docker)${RESET}"
echo ""
echo -e "${BLUE}💾 Datos preservados:${RESET}"
echo -e "  - PostgreSQL: edugo-postgres-local-data"
echo -e "  - MongoDB: edugo-mongodb-local-data"
echo -e "  - RabbitMQ: edugo-rabbitmq-local-data"
echo ""
echo -e "${YELLOW}🚀 Reiniciar:${RESET} ./scripts/local/start-all-local.sh"
echo -e "${YELLOW}🧹 Limpiar:${RESET}  ./scripts/local/clean-all-local.sh"
echo ""
