# ============================================
# Makefile Orquestador - EduGo
# Ejecuta comandos en los 3 proyectos
# ============================================

# Colors
YELLOW := \033[1;33m
GREEN := \033[1;32m
BLUE := \033[1;34m
RESET := \033[0m

# Projects
PROJECTS := source/api-mobile source/api-administracion source/worker

.DEFAULT_GOAL := help

help: ## Mostrar ayuda
	@echo "$(BLUE)EduGo - Comandos Orquestador:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'

# ============================================
# Build Targets (Todos los Proyectos)
# ============================================

build-all: ## Compilar los 3 proyectos
	@echo "$(BLUE)=== 🔨 COMPILANDO TODOS LOS PROYECTOS ===$(RESET)"
	@for project in $(PROJECTS); do \
		echo "$(YELLOW)Compilando $$project...$(RESET)"; \
		cd $$project && make build && cd ../../..; \
	done
	@echo "$(GREEN)✅ Todos los proyectos compilados$(RESET)"

test-all: ## Tests en los 3 proyectos
	@echo "$(BLUE)=== 🧪 TESTS EN TODOS LOS PROYECTOS ===$(RESET)"
	@for project in $(PROJECTS); do \
		echo "$(YELLOW)Testing $$project...$(RESET)"; \
		cd $$project && make test && cd ../../..; \
	done
	@echo "$(GREEN)✅ Todos los tests completados$(RESET)"

coverage-all: ## Coverage en los 3 proyectos
	@echo "$(BLUE)=== 📊 COVERAGE EN TODOS LOS PROYECTOS ===$(RESET)"
	@for project in $(PROJECTS); do \
		echo "$(YELLOW)Coverage $$project...$(RESET)"; \
		cd $$project && make test-coverage && cd ../../..; \
	done
	@echo "$(GREEN)✅ Coverage reports generados$(RESET)"

lint-all: ## Lint en los 3 proyectos
	@echo "$(BLUE)=== 🔎 LINT EN TODOS LOS PROYECTOS ===$(RESET)"
	@for project in $(PROJECTS); do \
		echo "$(YELLOW)Linting $$project...$(RESET)"; \
		cd $$project && make lint && cd ../../..; \
	done

fmt-all: ## Formatear código de los 3 proyectos
	@echo "$(BLUE)=== ✨ FORMATEANDO TODOS LOS PROYECTOS ===$(RESET)"
	@for project in $(PROJECTS); do \
		cd $$project && make fmt && cd ../../..; \
	done
	@echo "$(GREEN)✅ Código formateado$(RESET)"

swagger-all: ## Regenerar Swagger en las 2 APIs
	@echo "$(BLUE)=== 📚 REGENERANDO SWAGGER ===$(RESET)"
	@cd source/api-mobile && make swagger && cd ../..
	@cd source/api-administracion && make swagger && cd ../..
	@echo "$(GREEN)✅ Swagger regenerado$(RESET)"

audit-all: ## Auditoría completa en los 3 proyectos
	@echo "$(BLUE)=== 🔐 AUDITORÍA COMPLETA ===$(RESET)"
	@for project in $(PROJECTS); do \
		echo "$(YELLOW)Auditando $$project...$(RESET)"; \
		cd $$project && make audit && cd ../../..; \
	done
	@echo "$(GREEN)✅ Auditoría completada$(RESET)"

tidy-all: ## go mod tidy en los 3 proyectos
	@for project in $(PROJECTS); do \
		cd $$project && make tidy && cd ../../..; \
	done

clean-all: ## Limpiar binarios de los 3 proyectos
	@echo "$(YELLOW)🧹 Limpiando todos los proyectos...$(RESET)"
	@for project in $(PROJECTS); do \
		cd $$project && make clean && cd ../../..; \
	done
	@echo "$(GREEN)✓ Limpieza completa$(RESET)"

# ============================================
# Docker (Stack Completo)
# ============================================

docker-build: ## Construir todas las imágenes Docker
	@echo "$(YELLOW)🐳 Construyendo imágenes Docker...$(RESET)"
	@docker-compose build
	@echo "$(GREEN)✓ Imágenes construidas$(RESET)"

up: ## Levantar stack completo
	@echo "$(YELLOW)🚀 Levantando servicios...$(RESET)"
	@docker-compose up -d
	@echo "$(GREEN)✓ Servicios corriendo:$(RESET)"
	@echo "  $(BLUE)API Mobile:$(RESET)  http://localhost:8080/swagger/index.html"
	@echo "  $(BLUE)API Admin:$(RESET)   http://localhost:8081/swagger/index.html"
	@echo "  $(BLUE)RabbitMQ:$(RESET)    http://localhost:15672 (edugo_user/edugo_pass)"

down: ## Detener todos los servicios
	@echo "$(YELLOW)⏹️  Deteniendo servicios...$(RESET)"
	@docker-compose down
	@echo "$(GREEN)✓ Servicios detenidos$(RESET)"

restart: down up ## Reiniciar servicios

logs: ## Ver logs de todos los servicios
	@docker-compose logs -f

logs-api-mobile: ## Logs de API Mobile
	@docker-compose logs -f api-mobile

logs-api-admin: ## Logs de API Admin
	@docker-compose logs -f api-administracion

logs-worker: ## Logs de Worker
	@docker-compose logs -f worker

status: ## Estado de los servicios
	@docker-compose ps

clean-docker: ## Limpiar Docker (contenedores + volúmenes + imágenes)
	@echo "$(YELLOW)🧹 Limpiando Docker...$(RESET)"
	@docker-compose down -v --rmi all
	@echo "$(GREEN)✓ Docker limpio$(RESET)"

# ============================================
# Development
# ============================================

dev-api-mobile: ## Ejecutar API Mobile local
	@cd source/api-mobile && make run

dev-api-admin: ## Ejecutar API Admin local
	@cd source/api-administracion && make run

dev-worker: ## Ejecutar Worker local
	@cd source/worker && make run

# ============================================
# CI/CD
# ============================================

ci: audit-all test-all swagger-all ## Pipeline CI completo
	@echo "$(GREEN)🎉 CI pipeline completado exitosamente$(RESET)"

pre-commit: fmt-all audit-all ## Validación pre-commit

# ============================================
# Tools
# ============================================

tools: ## Instalar herramientas en todos los proyectos
	@for project in $(PROJECTS); do \
		cd $$project && make tools && cd ../../..; \
	done

# ============================================
# Info
# ============================================

info: ## Información del proyecto
	@echo "$(BLUE)📋 EduGo - Información$(RESET)"
	@echo "  Proyectos: 3 (api-mobile, api-administracion, worker)"
	@echo "  Version: $$(git describe --tags --always)"
	@echo "  Branch: $$(git branch --show-current)"
	@echo "  Go: $$(go version)"
	@echo "  Commits: $$(git log --oneline | wc -l | tr -d ' ')"

.PHONY: help build-all test-all coverage-all lint-all fmt-all swagger-all audit-all tidy-all clean-all docker-build up down restart logs logs-api-mobile logs-api-admin logs-worker status clean-docker dev-api-mobile dev-api-admin dev-worker ci pre-commit tools info
