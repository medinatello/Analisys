#!/bin/bash

# ============================================
# Destruir TODO (Apps + Infraestructura + Datos)
# ============================================

RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RESET='\033[0m'

echo -e "${RED}╔════════════════════════════════════════════════╗${RESET}"
echo -e "${RED}║    ⚠️  DESTRUCCIÓN COMPLETA - CONFIRMACIÓN    ║${RESET}"
echo -e "${RED}╔════════════════════════════════════════════════╗${RESET}"
echo ""
echo -e "${YELLOW}Esto eliminará:${RESET}"
echo -e "  ${RED}✗${RESET} Contenedores Docker (postgres, mongo, rabbitmq)"
echo -e "  ${RED}✗${RESET} Volúmenes con TODOS los datos"
echo -e "  ${RED}✗${RESET} Red virtual (edugo-local-network)"
echo -e "  ${RED}✗${RESET} Logs de aplicaciones"
echo ""
echo -e "${YELLOW}NO se puede deshacer esta acción.${RESET}"
echo ""
read -p "¿Estás ABSOLUTAMENTE seguro? Escribe 'DELETE' para confirmar: " confirm

if [ "$confirm" = "DELETE" ]; then
    echo ""
    echo -e "${YELLOW}🧹 Deteniendo aplicaciones...${RESET}"
    ./stop-all.sh 2>/dev/null
    
    echo -e "${YELLOW}🧹 Destruyendo infraestructura...${RESET}"
    docker-compose -f docker/docker-compose.local.yml down -v
    
    echo -e "${YELLOW}🧹 Limpiando logs...${RESET}"
    rm -rf logs/*.log
    rm -f .running_services.pid
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║        ✅ Limpieza Completa Exitosa           ║${RESET}"
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${RESET}"
    echo ""
    echo -e "${BLUE}🚀 Para iniciar desde cero:${RESET} ./scripts/local/start-all-local.sh"
else
    echo ""
    echo -e "${GREEN}❌ Cancelado - Nada fue eliminado${RESET}"
fi
