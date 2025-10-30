#!/bin/bash

# ============================================
# Ver Estado de los Servicios
# ============================================

# Colors
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
RESET='\033[0m'

PID_FILE=".running_services.pid"

echo -e "${BLUE}📊 Estado de los Servicios EduGo${RESET}"
echo ""

if [ ! -f "$PID_FILE" ]; then
    echo -e "${RED}⚠️  No hay servicios corriendo${RESET}"
    echo -e "${YELLOW}💡 Ejecuta ./start-all.sh para iniciar${RESET}"
    exit 0
fi

# Leer y verificar cada servicio
while IFS=: read -r service pid; do
    if ps -p $pid > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $service${RESET} (PID: $pid) - ${GREEN}RUNNING${RESET}"
        
        # Mostrar puerto si aplica
        case "$service" in
            api-mobile)
                echo -e "  ${BLUE}→ http://localhost:8080/swagger/index.html${RESET}"
                ;;
            api-admin)
                echo -e "  ${BLUE}→ http://localhost:8081/swagger/index.html${RESET}"
                ;;
        esac
    else
        echo -e "${RED}✗ $service${RESET} (PID: $pid) - ${RED}STOPPED${RESET}"
    fi
done < "$PID_FILE"

echo ""
echo -e "${BLUE}📊 Logs:${RESET} ./logs-all.sh"
echo -e "${BLUE}⏹️  Detener:${RESET} ./stop-all.sh"
echo ""
