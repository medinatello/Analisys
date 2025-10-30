#!/bin/bash

# Script para iniciar GitLab Runner manualmente
# Uso: ./scripts/gitlab-runner-start.sh

set -e

echo "🚀 Iniciando GitLab Runner..."
echo "================================"
echo ""

# Verificar que gitlab-runner está instalado
if ! command -v gitlab-runner &> /dev/null; then
    echo "❌ gitlab-runner no está instalado"
    echo "   Instalar con: brew install gitlab-runner"
    exit 1
fi

echo "✅ gitlab-runner está instalado"
echo ""

# Verificar que Docker está corriendo
if ! docker info &> /dev/null; then
    echo "❌ Docker no está corriendo"
    echo "   Por favor inicia Docker Desktop"
    exit 1
fi

echo "✅ Docker está corriendo"
echo ""

# Ver configuración del runner
echo "📋 Runner configurado:"
gitlab-runner list
echo ""

echo "🏃 Iniciando runner..."
echo "⚠️  NOTA: Mantén esta terminal abierta mientras el runner está activo"
echo "⚠️  Para detener: Presiona Ctrl+C"
echo ""
echo "Ver pipelines en: https://gitlab.com/groups/edugogroup/-/pipelines"
echo ""

# Ejecutar runner en foreground
gitlab-runner run
