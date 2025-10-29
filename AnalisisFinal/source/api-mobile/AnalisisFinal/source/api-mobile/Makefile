.PHONY: help swagger run swagger-ui deps tidy clean

# Variables
SWAG := $(shell command -v swag 2> /dev/null || echo ~/go/bin/swag)
GO := go

help: ## Mostrar ayuda
	@echo "Comandos disponibles:"
	@echo "  make swagger     - Generar documentación Swagger"
	@echo "  make run         - Ejecutar la API"
	@echo "  make swagger-ui  - Generar Swagger y ejecutar la API"
	@echo "  make deps        - Instalar dependencias"
	@echo "  make tidy        - Limpiar dependencias"
	@echo "  make clean       - Limpiar archivos generados"

swagger: ## Generar documentación Swagger
	@echo "🔨 Generando documentación Swagger..."
	@$(SWAG) init -g cmd/main.go -o docs --parseDependency --parseInternal --parseDepth 2
	@echo "✅ Documentación Swagger generada en ./docs/"

run: ## Ejecutar la API
	@echo "🚀 Ejecutando API en puerto 8080..."
	@$(GO) run cmd/main.go

swagger-ui: swagger run ## Generar Swagger y ejecutar la API

deps: ## Instalar dependencias
	@echo "📦 Instalando dependencias..."
	@$(GO) mod download
	@echo "✅ Dependencias instaladas"

tidy: ## Limpiar dependencias
	@echo "🧹 Limpiando dependencias..."
	@$(GO) mod tidy
	@echo "✅ Dependencias limpiadas"

clean: ## Limpiar archivos generados
	@echo "🧹 Limpiando archivos generados..."
	@rm -rf docs/
	@echo "✅ Archivos limpiados"
