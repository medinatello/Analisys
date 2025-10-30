#!/bin/bash

# ============================================
# Destruir Infraestructura (Incluye Datos)
# ============================================

RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RESET='\033[0m'

echo -e "${RED}⚠️  ADVERTENCIA: Esto ELIMINARÁ TODOS LOS DATOS LOCALES${RESET}"
echo -e "${YELLOW}   - Base de datos PostgreSQL${RESET}"
echo -e "${YELLOW}   - Base de datos MongoDB${RESET}"
echo -e "${YELLOW}   - Colas y mensajes de RabbitMQ${RESET}"
echo ""
read -p "¿Estás seguro? Escribe 'yes' para confirmar: " confirm

if [ "$confirm" = "yes" ]; then
    echo -e "${YELLOW}🧹 Eliminando contenedores y volúmenes...${RESET}"
    docker-compose -f docker/docker-compose.local.yml down -v
    echo -e "${GREEN}✅ Infraestructura eliminada completamente${RESET}"
    echo ""
    echo -e "${YELLOW}💡 Para crear nuevamente:${RESET} ./scripts/local/start-infra.sh"
else
    echo -e "${GREEN}❌ Cancelado (datos preservados)${RESET}"
fi
