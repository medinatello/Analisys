#!/bin/bash

# Script de inicialización para EduGo API
# Instala dependencias y genera documentación Swagger

set -e

echo "🚀 Inicializando EduGo API..."
echo ""

# Verificar que Go está instalado
if ! command -v go &> /dev/null; then
    echo "❌ Go no está instalado. Por favor instala Go 1.21 o superior."
    echo "   https://golang.org/dl/"
    exit 1
fi

echo "✅ Go instalado: $(go version)"
echo ""

# Instalar dependencias
echo "📦 Instalando dependencias de Go..."
go mod download
go mod tidy
echo "✅ Dependencias instaladas"
echo ""

# Instalar swag si no está instalado
if ! command -v swag &> /dev/null; then
    echo "📝 Instalando Swag (generador de Swagger)..."
    go install github.com/swaggo/swag/cmd/swag@latest
    echo "✅ Swag instalado"
else
    echo "✅ Swag ya está instalado: $(swag --version)"
fi
echo ""

# Generar documentación Swagger
echo "📝 Generando documentación Swagger..."
swag init -g cmd/server/main.go -o docs
echo "✅ Documentación Swagger generada en ./docs"
echo ""

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo "📄 Creando archivo .env desde .env.example..."
    cp .env.example .env
    echo "✅ Archivo .env creado. Edítalo según tus necesidades."
else
    echo "ℹ️  Archivo .env ya existe"
fi
echo ""

echo "✅ Inicialización completada!"
echo ""
echo "Para ejecutar el servidor:"
echo "  make run"
echo "  o"
echo "  go run cmd/server/main.go"
echo ""
echo "Documentación Swagger estará disponible en:"
echo "  http://localhost:8080/swagger/index.html"
echo ""
echo "Health check:"
echo "  http://localhost:8080/health"
echo ""
