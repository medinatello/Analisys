#!/bin/bash

# ============================================
# Script para Iniciar Todos los Servicios
# ============================================

# Colors
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
RESET='\033[0m'

# PID file
PID_FILE=".running_services.pid"

# Variables de ambiente por defecto
export APP_ENV="${APP_ENV:-local}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-edugo_pass}"
export MONGODB_URI="${MONGODB_URI:-mongodb://edugo_admin:edugo_pass@localhost:27017/edugo?authSource=admin}"
export RABBITMQ_URL="${RABBITMQ_URL:-amqp://edugo_user:edugo_pass@localhost:5672/}"
export OPENAI_API_KEY="${OPENAI_API_KEY:-sk-test-key}"

echo -e "${BLUE}╔════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║     🚀 Iniciando Servicios EduGo      ║${RESET}"
echo -e "${BLUE}╔════════════════════════════════════════╗${RESET}"
echo ""
echo -e "${YELLOW}Ambiente: ${APP_ENV}${RESET}"
echo ""

# Verificar que no haya servicios corriendo
if [ -f "$PID_FILE" ]; then
    echo -e "${RED}⚠️  Servicios ya están corriendo${RESET}"
    echo -e "${YELLOW}💡 Ejecuta ./stop-all.sh primero${RESET}"
    exit 1
fi

# Limpiar PID file
> "$PID_FILE"

# ============================================
# Iniciar API Mobile
# ============================================
echo -e "${YELLOW}[1/3] Iniciando API Mobile...${RESET}"
cd source/api-mobile
go run cmd/main.go > ../../logs/api-mobile.log 2>&1 &
API_MOBILE_PID=$!
echo "api-mobile:$API_MOBILE_PID" >> ../../"$PID_FILE"
cd ../..
sleep 2

# Verificar que inició
if ps -p $API_MOBILE_PID > /dev/null; then
    echo -e "${GREEN}✓ API Mobile corriendo (PID: $API_MOBILE_PID)${RESET}"
    echo -e "  ${BLUE}Swagger: http://localhost:8080/swagger/index.html${RESET}"
else
    echo -e "${RED}✗ API Mobile falló al iniciar${RESET}"
    cat logs/api-mobile.log | tail -20
fi

# ============================================
# Iniciar API Administración
# ============================================
echo -e "${YELLOW}[2/3] Iniciando API Administración...${RESET}"
cd source/api-administracion
go run cmd/main.go > ../../logs/api-admin.log 2>&1 &
API_ADMIN_PID=$!
echo "api-admin:$API_ADMIN_PID" >> ../../"$PID_FILE"
cd ../..
sleep 2

# Verificar que inició
if ps -p $API_ADMIN_PID > /dev/null; then
    echo -e "${GREEN}✓ API Admin corriendo (PID: $API_ADMIN_PID)${RESET}"
    echo -e "  ${BLUE}Swagger: http://localhost:8081/swagger/index.html${RESET}"
else
    echo -e "${RED}✗ API Admin falló al iniciar${RESET}"
    cat logs/api-admin.log | tail -20
fi

# ============================================
# Iniciar Worker
# ============================================
echo -e "${YELLOW}[3/3] Iniciando Worker...${RESET}"
cd source/worker
go run cmd/main.go > ../../logs/worker.log 2>&1 &
WORKER_PID=$!
echo "worker:$WORKER_PID" >> ../../"$PID_FILE"
cd ../..
sleep 2

# Verificar que inició
if ps -p $WORKER_PID > /dev/null; then
    echo -e "${GREEN}✓ Worker corriendo (PID: $WORKER_PID)${RESET}"
else
    echo -e "${RED}✗ Worker falló al iniciar${RESET}"
    cat logs/worker.log | tail -20
fi

# ============================================
# Resumen
# ============================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║      ✅ Todos los Servicios OK        ║${RESET}"
echo -e "${GREEN}╔════════════════════════════════════════╗${RESET}"
echo ""
echo -e "${BLUE}📋 Servicios corriendo:${RESET}"
echo -e "  ${GREEN}API Mobile:${RESET}        http://localhost:8080/swagger/index.html"
echo -e "  ${GREEN}API Admin:${RESET}         http://localhost:8081/swagger/index.html"
echo -e "  ${GREEN}Worker:${RESET}            Procesando en background"
echo ""
echo -e "${BLUE}📊 Logs:${RESET}"
echo -e "  ${YELLOW}API Mobile:${RESET}        tail -f logs/api-mobile.log"
echo -e "  ${YELLOW}API Admin:${RESET}         tail -f logs/api-admin.log"
echo -e "  ${YELLOW}Worker:${RESET}            tail -f logs/worker.log"
echo ""
echo -e "${BLUE}⏹️  Para detener:${RESET}"
echo -e "  ${YELLOW}./stop-all.sh${RESET}"
echo ""
