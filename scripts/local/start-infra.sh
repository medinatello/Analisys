#!/bin/bash

# ============================================
# Iniciar Infraestructura Local Compartida
# ============================================

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RESET='\033[0m'

echo -e "${BLUE}🐳 Infraestructura Local EduGo${RESET}"
echo ""

# Verificar si contenedores ya existen y están corriendo
if docker ps --format '{{.Names}}' | grep -q "edugo-postgres-local"; then
    echo -e "${GREEN}✓ Contenedores ya están corriendo${RESET}"
    echo -e "${BLUE}💡 Verificando salud...${RESET}"
    docker-compose -f docker/docker-compose.local.yml ps
else
    # Verificar si existen pero están detenidos
    if docker ps -a --format '{{.Names}}' | grep -q "edugo-postgres-local"; then
        echo -e "${YELLOW}📦 Contenedores existentes detectados (detenidos)${RESET}"
        echo -e "${BLUE}🔄 Iniciando contenedores existentes...${RESET}"
        docker-compose -f docker/docker-compose.local.yml start
        sleep 5
        echo -e "${GREEN}✅ Contenedores iniciados (datos preservados)${RESET}"
    else
        echo -e "${YELLOW}🆕 Primera vez - Creando contenedores...${RESET}"
        docker-compose -f docker/docker-compose.local.yml up -d
        sleep 15
        echo -e "${GREEN}✅ Contenedores creados y datos iniciales cargados${RESET}"
    fi
fi

echo ""
echo -e "${BLUE}📊 Estado de servicios:${RESET}"
docker-compose -f docker/docker-compose.local.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo -e "${GREEN}✅ Infraestructura ready${RESET}"
echo -e "${BLUE}🌐 Red:${RESET} edugo-local-network"
echo -e "${BLUE}📄 RabbitMQ:${RESET} http://localhost:15672 (edugo_user/edugo_pass)"
