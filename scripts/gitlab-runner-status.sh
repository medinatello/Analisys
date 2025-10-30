#!/bin/bash

# Script para verificar el estado de GitLab Runner
# Uso: ./scripts/gitlab-runner-status.sh

echo "🔍 Estado de GitLab Runner"
echo "================================"
echo ""

# Verificar instalación
if ! command -v gitlab-runner &> /dev/null; then
    echo "❌ gitlab-runner no está instalado"
    echo "   Instalar con: brew install gitlab-runner"
    exit 1
fi

echo "✅ gitlab-runner instalado (versión $(gitlab-runner --version | head -1))"
echo ""

# Ver runners registrados
echo "📋 Runners registrados:"
gitlab-runner list
echo ""

# Ver si el servicio está corriendo
echo "🏃 Estado del servicio:"
if pgrep -f "gitlab-runner" > /dev/null; then
    echo "✅ GitLab Runner está corriendo"
    echo ""
    echo "Procesos:"
    ps aux | grep gitlab-runner | grep -v grep
else
    echo "⏸️  GitLab Runner NO está corriendo"
    echo ""
    echo "Para iniciar:"
    echo "  ./scripts/gitlab-runner-start.sh"
fi

echo ""
echo "Ver configuración en: ~/.gitlab-runner/config.toml"
echo "Ver pipelines en: https://gitlab.com/groups/edugogroup/-/pipelines"
