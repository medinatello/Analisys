.PHONY: help run deps tidy test send-test-message

# Variables
GO := go

help: ## Mostrar ayuda
	@echo "Comandos disponibles:"
	@echo "  make run              - Ejecutar el worker"
	@echo "  make deps             - Instalar dependencias"
	@echo "  make tidy             - Limpiar dependencias"
	@echo "  make send-test-message - Enviar mensaje de prueba a RabbitMQ"

run: ## Ejecutar el worker
	@echo "🔄 Ejecutando Worker..."
	@echo "   Asegúrate de que RabbitMQ esté corriendo en localhost:5672"
	@$(GO) run cmd/main.go

deps: ## Instalar dependencias
	@echo "📦 Instalando dependencias..."
	@$(GO) mod download
	@echo "✅ Dependencias instaladas"

tidy: ## Limpiar dependencias
	@echo "🧹 Limpiando dependencias..."
	@$(GO) mod tidy
	@echo "✅ Dependencias limpiadas"

send-test-message: ## Enviar mensaje de prueba a RabbitMQ
	@echo "📨 Enviando mensaje de prueba..."
	@$(GO) run scripts/send_test_message.go
