.PHONY: help install swag run dev test clean

# Variables
BINARY_NAME=edugo-api
MAIN_PATH=./cmd/server
DOCS_PATH=./docs

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Instalar dependencias
	@echo "📦 Instalando dependencias..."
	go mod download
	go mod tidy
	@echo "✅ Dependencias instaladas"

swag: ## Generar documentación Swagger
	@echo "📝 Generando documentación Swagger..."
	@if ! command -v swag &> /dev/null; then \
		echo "⚠️  swag no está instalado. Instalando..."; \
		go install github.com/swaggo/swag/cmd/swag@latest; \
	fi
	swag init -g cmd/server/main.go -o $(DOCS_PATH)
	@echo "✅ Documentación Swagger generada en $(DOCS_PATH)"

run: swag ## Ejecutar el servidor
	@echo "🚀 Iniciando servidor..."
	go run $(MAIN_PATH)/main.go

dev: swag ## Ejecutar en modo desarrollo con hot reload
	@echo "🔥 Modo desarrollo (hot reload)..."
	@if ! command -v air &> /dev/null; then \
		echo "⚠️  air no está instalado. Instalando..."; \
		go install github.com/cosmtrek/air@latest; \
	fi
	air

build: swag ## Compilar el binario
	@echo "🔨 Compilando..."
	go build -o bin/$(BINARY_NAME) $(MAIN_PATH)/main.go
	@echo "✅ Binario compilado en bin/$(BINARY_NAME)"

test: ## Ejecutar tests
	@echo "🧪 Ejecutando tests..."
	go test -v ./...

clean: ## Limpiar archivos generados
	@echo "🧹 Limpiando..."
	rm -rf bin/
	rm -rf $(DOCS_PATH)
	@echo "✅ Limpieza completada"

docker-build: ## Construir imagen Docker
	@echo "🐳 Construyendo imagen Docker..."
	docker build -t edugo-api:latest .

docker-run: ## Ejecutar en Docker
	@echo "🐳 Ejecutando en Docker..."
	docker run -p 8080:8080 --env-file .env edugo-api:latest
