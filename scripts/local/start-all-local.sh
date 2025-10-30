#!/bin/bash

# ============================================
# Iniciar TODO: Infraestructura + 3 Apps
# ============================================

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
RESET='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║  🚀 Iniciando Stack Completo EduGo (Local)   ║${RESET}"
echo -e "${BLUE}╔════════════════════════════════════════════════╗${RESET}"
echo ""

# Paso 1: Iniciar infraestructura
echo -e "${YELLOW}[Paso 1/4] Iniciando infraestructura compartida...${RESET}"
./scripts/local/start-infra.sh
echo ""

# Paso 2: Verificar datos
echo -e "${YELLOW}[Paso 2/4] Verificando datos en BD...${RESET}"
./scripts/local/check-db-data.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ BD lista con datos${RESET}"
else
    echo -e "${YELLOW}⚠️  BD sin datos, se cargarán en primer arranque${RESET}"
fi
echo ""

# Paso 3: Iniciar las 3 aplicaciones
echo -e "${YELLOW}[Paso 3/4] Iniciando aplicaciones...${RESET}"
echo ""

# Usar los scripts existentes
./start-all.sh

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║         ✅ Stack Completo Iniciado            ║${RESET}"
echo -e "${BLUE}╔════════════════════════════════════════════════╗${RESET}"
echo ""
echo -e "${GREEN}🌐 Servicios disponibles:${RESET}"
echo -e "  ${BLUE}API Mobile:${RESET}   http://localhost:8080/swagger/index.html"
echo -e "  ${BLUE}API Admin:${RESET}    http://localhost:8081/swagger/index.html"
echo -e "  ${BLUE}RabbitMQ:${RESET}     http://localhost:15672 (edugo_user/edugo_pass)"
echo -e "  ${BLUE}PostgreSQL:${RESET}   localhost:5432 (edugo_user/edugo_pass)"
echo -e "  ${BLUE}MongoDB:${RESET}      localhost:27017 (edugo_admin/edugo_pass)"
echo ""
echo -e "${YELLOW}📊 Ver estado:${RESET} ./status.sh"
echo -e "${YELLOW}📄 Ver logs:${RESET}  ./logs-all.sh"
echo -e "${YELLOW}⏹️  Detener:${RESET}   ./scripts/local/stop-all-local.sh"
echo ""
