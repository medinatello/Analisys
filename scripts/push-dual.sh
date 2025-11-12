#!/bin/bash

# Script para pushear a GitHub Y GitLab simultáneamente
# Uso: ./scripts/push-dual.sh <directorio-del-repo> <mensaje-commit>

set -e

REPO_DIR=$1
COMMIT_MSG=$2

if [ -z "$REPO_DIR" ] || [ -z "$COMMIT_MSG" ]; then
    echo "❌ Uso: ./scripts/push-dual.sh <directorio-repo> <mensaje-commit>"
    echo ""
    echo "Ejemplo:"
    echo "  ./scripts/push-dual.sh edugo-shared 'fix: corregir bug en auth'"
    exit 1
fi

# Mapeo de directorios locales a nombres de repos
declare -A REPO_MAP
REPO_MAP["api-mobile"]="edugo-api-mobile"
REPO_MAP["api-administracion"]="edugo-api-administracion"
REPO_MAP["worker"]="edugo-worker"
REPO_MAP["dev-environment"]="edugo-dev-environment"

# Obtener nombre del repo
REPO_NAME="${REPO_MAP[$REPO_DIR]}"

if [ -z "$REPO_NAME" ]; then
    echo "❌ Repositorio no reconocido: $REPO_DIR"
    echo "Opciones válidas: api-mobile, api-administracion, worker, dev-environment"
    exit 1
fi

echo "📦 Pusheando: $REPO_NAME"
echo "💬 Mensaje: $COMMIT_MSG"
echo "================================"
echo ""

# Ir al directorio del repo extraído
REPO_PATH="/Users/jhoanmedina/source/EduGo/repos-temp/$REPO_NAME"

if [ ! -d "$REPO_PATH" ]; then
    echo "❌ Directorio no existe: $REPO_PATH"
    exit 1
fi

cd "$REPO_PATH"

# Verificar que hay cambios
if [ -z "$(git status --porcelain)" ]; then
    echo "ℹ️  No hay cambios para commitear"
else
    # Hacer commit
    git add .
    git commit -m "$COMMIT_MSG"
    echo "✅ Commit creado"
fi

# Push a GitHub (origin)
echo ""
echo "📤 Pusheando a GitHub..."
git push origin main
echo "✅ GitHub actualizado"

# Push a GitLab (gitlab remote)
echo ""
echo "📤 Pusheando a GitLab..."

# Verificar si existe el remote gitlab
if ! git remote | grep -q "^gitlab$"; then
    echo "Agregando remote gitlab..."
    git remote add gitlab "https://oauth2:${GITLAB_TOKEN}@gitlab.com/edugogroup/$REPO_NAME.git"
fi

git push gitlab main
echo "✅ GitLab actualizado"

echo ""
echo "🎉 Push dual completado!"
echo ""
echo "Ver en GitHub: https://github.com/EduGoGroup/$REPO_NAME"
echo "Ver pipeline en GitLab: https://gitlab.com/edugogroup/$REPO_NAME/-/pipelines"
