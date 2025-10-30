#!/bin/bash

# ============================================
# Script para Detener Todos los Servicios
# ============================================

# Colors
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
RESET='\033[0m'

# PID file
PID_FILE=".running_services.pid"

echo -e "${BLUE}╔════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║     ⏹️  Deteniendo Servicios EduGo    ║${RESET}"
echo -e "${BLUE}╔════════════════════════════════════════╗${RESET}"
echo ""

# Verificar que exista el archivo de PIDs
if [ ! -f "$PID_FILE" ]; then
    echo -e "${RED}⚠️  No hay servicios corriendo${RESET}"
    echo -e "${YELLOW}💡 O el archivo $PID_FILE no existe${RESET}"
    exit 0
fi

# Leer PIDs y detener procesos
while IFS=: read -r service pid; do
    echo -e "${YELLOW}Deteniendo $service (PID: $pid)...${RESET}"
    
    if ps -p $pid > /dev/null 2>&1; then
        kill $pid 2>/dev/null
        
        # Esperar a que termine (máximo 5 segundos)
        for i in {1..5}; do
            if ! ps -p $pid > /dev/null 2>&1; then
                echo -e "${GREEN}✓ $service detenido${RESET}"
                break
            fi
            sleep 1
        done
        
        # Force kill si no terminó
        if ps -p $pid > /dev/null 2>&1; then
            echo -e "${YELLOW}  Force killing $service...${RESET}"
            kill -9 $pid 2>/dev/null
            echo -e "${GREEN}✓ $service terminado (force)${RESET}"
        fi
    else
        echo -e "${YELLOW}  $service ya no está corriendo${RESET}"
    fi
done < "$PID_FILE"

# Eliminar archivo de PIDs
rm -f "$PID_FILE"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║     ✅ Todos los Servicios Detenidos  ║${RESET}"
echo -e "${GREEN}╔════════════════════════════════════════╗${RESET}"
echo ""
echo -e "${BLUE}📊 Logs guardados en:${RESET}"
echo -e "  ${YELLOW}logs/api-mobile.log${RESET}"
echo -e "  ${YELLOW}logs/api-admin.log${RESET}"
echo -e "  ${YELLOW}logs/worker.log${RESET}"
echo ""
echo -e "${BLUE}🚀 Para iniciar nuevamente:${RESET}"
echo -e "  ${YELLOW}./start-all.sh${RESET}"
echo ""
