.PHONY: help build up down logs clean restart db-init test

# Colores para output
YELLOW := \033[1;33m
GREEN := \033[1;32m
RESET := \033[0m

help: ## Mostrar esta ayuda
	@echo "$(YELLOW)EduGo - Comandos disponibles:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'

build: ## Construir todas las imágenes Docker
	@echo "$(YELLOW)Construyendo imágenes Docker...$(RESET)"
	docker-compose build

up: ## Levantar todos los servicios
	@echo "$(YELLOW)Levantando servicios...$(RESET)"
	docker-compose up -d
	@echo "$(GREEN)✓ Servicios levantados$(RESET)"
	@echo "  - API Mobile: http://localhost:8080/swagger/index.html"
	@echo "  - API Admin:  http://localhost:8081/swagger/index.html"
	@echo "  - RabbitMQ:   http://localhost:15672 (user: edugo_user, pass: edugo_pass)"

down: ## Detener todos los servicios
	@echo "$(YELLOW)Deteniendo servicios...$(RESET)"
	docker-compose down

logs: ## Ver logs de todos los servicios
	docker-compose logs -f

logs-api-mobile: ## Ver logs de API Mobile
	docker-compose logs -f api-mobile

logs-api-admin: ## Ver logs de API Administración
	docker-compose logs -f api-administracion

logs-worker: ## Ver logs del Worker
	docker-compose logs -f worker

clean: ## Limpiar contenedores, volúmenes e imágenes
	@echo "$(YELLOW)Limpiando Docker...$(RESET)"
	docker-compose down -v --rmi all
	@echo "$(GREEN)✓ Limpieza completa$(RESET)"

restart: down up ## Reiniciar todos los servicios

db-init: ## Ejecutar scripts de inicialización de bases de datos
	@echo "$(YELLOW)Inicializando bases de datos...$(RESET)"
	@echo "PostgreSQL se inicializa automáticamente desde source/scripts/postgresql/"
	@echo "MongoDB se inicializa automáticamente desde source/scripts/mongodb/"
	@echo "$(GREEN)✓ Scripts configurados$(RESET)"

test: ## Ejecutar tests de las APIs
	@echo "$(YELLOW)Ejecutando tests...$(RESET)"
	cd source/api-mobile && go test ./...
	cd source/api-administracion && go test ./...
	@echo "$(GREEN)✓ Tests completados$(RESET)"

swagger: ## Regenerar documentación Swagger
	@echo "$(YELLOW)Regenerando Swagger...$(RESET)"
	cd source/api-mobile && swag init -g cmd/main.go -o docs
	cd source/api-administracion && swag init -g cmd/main.go -o docs
	@echo "$(GREEN)✓ Swagger regenerado$(RESET)"

dev-api-mobile: ## Ejecutar API Mobile en modo desarrollo (local)
	cd source/api-mobile && go run cmd/main.go

dev-api-admin: ## Ejecutar API Admin en modo desarrollo (local)
	cd source/api-administracion && go run cmd/main.go

dev-worker: ## Ejecutar Worker en modo desarrollo (local)
	cd source/worker && go run cmd/main.go

status: ## Ver estado de los servicios
	@docker-compose ps
