# 📋 PLAN: Tooling Profesional y Docker Mejorado

**Fecha**: 2025-10-29
**Objetivo**: Convertir el proyecto en setup profesional enterprise-ready

---

## 🎯 OBJETIVOS

1. ✅ **Makefiles profesionales** por proyecto (build, test, coverage, lint, swagger, docker)
2. ✅ **VSCode debugging** configurado por proyecto (.vscode/launch.json)
3. ✅ **Docker structure** mejorado (compose por proyecto + orquestador raíz)
4. ✅ **Desarrollo local** optimizado
5. ✅ **CI/CD ready** (estructura preparada para GitHub Actions)

---

## 📁 ESTRUCTURA FINAL PROPUESTA

```
EduGo/Analisys/
├── source/
│   ├── api-mobile/
│   │   ├── .vscode/
│   │   │   ├── launch.json           ✨ NUEVO (debugging)
│   │   │   └── settings.json         ✨ NUEVO (Go settings)
│   │   ├── Makefile                  ✨ MEJORADO (profesional)
│   │   ├── docker-compose.yml        ✨ NUEVO (standalone)
│   │   └── Dockerfile                ✨ MOVIDO (desde raíz)
│   │
│   ├── api-administracion/
│   │   ├── .vscode/                  ✨ NUEVO
│   │   ├── Makefile                  ✨ MEJORADO
│   │   ├── docker-compose.yml        ✨ NUEVO
│   │   └── Dockerfile                ✨ MOVIDO
│   │
│   ├── worker/
│   │   ├── .vscode/                  ✨ NUEVO
│   │   ├── Makefile                  ✨ MEJORADO
│   │   ├── docker-compose.yml        ✨ NUEVO
│   │   └── Dockerfile                ✨ MOVIDO
│   │
│   └── scripts/                      ✅ Ya existe
│
├── docker-compose.yml                ✨ ORQUESTADOR (llama a sub-composes)
├── Makefile                          ✨ ORQUESTADOR (ejecuta en 3 proyectos)
└── .vscode/
    └── launch.json                   ✨ WORKSPACE (todos los proyectos)
```

---

## 🔧 MAKEFILES PROFESIONALES

### Targets Estándar (Cada Proyecto)

```makefile
.PHONY: help build test test-coverage lint fmt vet swagger clean run docker-build docker-run dev

help:                ## Mostrar ayuda
build:               ## Compilar binario
test:                ## Ejecutar tests
test-coverage:       ## Tests con cobertura (genera coverage.html)
test-integration:    ## Tests de integración
lint:                ## Ejecutar golangci-lint
fmt:                 ## Formatear código (gofmt)
vet:                 ## Análisis estático (go vet)
swagger:             ## Regenerar Swagger
clean:               ## Limpiar binarios y caché
run:                 ## Ejecutar en modo desarrollo
docker-build:        ## Construir imagen Docker
docker-run:          ## Ejecutar con docker-compose local
dev:                 ## Modo desarrollo completo (deps + run)
audit:               ## Auditoría de calidad (tidy + vet + test + lint)
deps:                ## Instalar/actualizar dependencias
tools:               ## Instalar herramientas (swag, golangci-lint, etc.)
```

### Ejemplo Makefile Profesional (api-mobile)

```makefile
# Variables
APP_NAME=api-mobile
VERSION=$(shell git describe --tags --always --dirty)
BUILD_DIR=bin
COVERAGE_DIR=coverage

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=gofmt
GOVET=$(GOCMD) vet

# Build flags
LDFLAGS=-ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(shell date -u +%Y-%m-%dT%H:%M:%SZ)"

# Colors
YELLOW=\033[1;33m
GREEN=\033[1;32m
RESET=\033[0m

.DEFAULT_GOAL := help

help: ## Mostrar esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'

build: ## Compilar binario
	@echo "$(YELLOW)Compilando $(APP_NAME)...$(RESET)"
	@mkdir -p $(BUILD_DIR)
	@$(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(APP_NAME) ./cmd/main.go
	@echo "$(GREEN)✓ Binario creado: $(BUILD_DIR)/$(APP_NAME)$(RESET)"

test: ## Ejecutar tests
	@echo "$(YELLOW)Ejecutando tests...$(RESET)"
	@$(GOTEST) -v -race ./...
	@echo "$(GREEN)✓ Tests completados$(RESET)"

test-coverage: ## Tests con cobertura
	@echo "$(YELLOW)Ejecutando tests con cobertura...$(RESET)"
	@mkdir -p $(COVERAGE_DIR)
	@$(GOTEST) -v -race -coverprofile=$(COVERAGE_DIR)/coverage.out ./...
	@$(GOCMD) tool cover -html=$(COVERAGE_DIR)/coverage.out -o $(COVERAGE_DIR)/coverage.html
	@$(GOCMD) tool cover -func=$(COVERAGE_DIR)/coverage.out
	@echo "$(GREEN)✓ Reporte: $(COVERAGE_DIR)/coverage.html$(RESET)"

test-integration: ## Tests de integración
	@echo "$(YELLOW)Ejecutando tests de integración...$(RESET)"
	@$(GOTEST) -v -tags=integration ./...

lint: ## Linter (golangci-lint)
	@echo "$(YELLOW)Ejecutando linter...$(RESET)"
	@golangci-lint run --config=../../.golangci.yml
	@echo "$(GREEN)✓ Linter completado$(RESET)"

fmt: ## Formatear código
	@echo "$(YELLOW)Formateando código...$(RESET)"
	@$(GOFMT) -w .
	@echo "$(GREEN)✓ Código formateado$(RESET)"

vet: ## Análisis estático
	@echo "$(YELLOW)Ejecutando go vet...$(RESET)"
	@$(GOVET) ./...
	@echo "$(GREEN)✓ go vet completado$(RESET)"

swagger: ## Regenerar Swagger
	@echo "$(YELLOW)Regenerando Swagger...$(RESET)"
	@swag init -g cmd/main.go -o docs
	@echo "$(GREEN)✓ Swagger regenerado$(RESET)"

clean: ## Limpiar binarios y caché
	@echo "$(YELLOW)Limpiando...$(RESET)"
	@rm -rf $(BUILD_DIR) $(COVERAGE_DIR)
	@$(GOCMD) clean -cache -testcache
	@echo "$(GREEN)✓ Limpieza completa$(RESET)"

run: ## Ejecutar en desarrollo
	@echo "$(YELLOW)Ejecutando $(APP_NAME)...$(RESET)"
	@APP_ENV=local \
	 POSTGRES_PASSWORD=edugo_pass \
	 MONGODB_URI=mongodb://edugo_admin:edugo_pass@localhost:27017/edugo?authSource=admin \
	 RABBITMQ_URL=amqp://edugo_user:edugo_pass@localhost:5672/ \
	 $(GOCMD) run cmd/main.go

dev: deps swagger run ## Desarrollo completo

docker-build: ## Construir imagen Docker
	@echo "$(YELLOW)Construyendo imagen Docker...$(RESET)"
	@docker-compose build
	@echo "$(GREEN)✓ Imagen construida$(RESET)"

docker-run: ## Ejecutar con docker-compose
	@echo "$(YELLOW)Levantando servicio...$(RESET)"
	@docker-compose up -d
	@echo "$(GREEN)✓ Servicio corriendo$(RESET)"

docker-stop: ## Detener docker-compose
	@docker-compose down

docker-logs: ## Ver logs de Docker
	@docker-compose logs -f

audit: ## Auditoría completa de calidad
	@echo "$(YELLOW)=== AUDITORÍA DE CALIDAD ===$(RESET)"
	@echo "1. Verificando go.mod..."
	@$(GOMOD) tidy -diff
	@$(GOMOD) verify
	@echo "2. Verificando formato..."
	@test -z "$$($(GOFMT) -l .)" || (echo "Archivos sin formatear:" && $(GOFMT) -l . && exit 1)
	@echo "3. Análisis estático..."
	@$(GOVET) ./...
	@echo "4. Tests..."
	@$(GOTEST) -race -vet=off ./...
	@echo "$(GREEN)✓ Auditoría completada$(RESET)"

deps: ## Actualizar dependencias
	@echo "$(YELLOW)Actualizando dependencias...$(RESET)"
	@$(GOMOD) download
	@$(GOMOD) tidy
	@echo "$(GREEN)✓ Dependencias actualizadas$(RESET)"

tools: ## Instalar herramientas de desarrollo
	@echo "$(YELLOW)Instalando herramientas...$(RESET)"
	@go install github.com/swaggo/swag/cmd/swag@latest
	@go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "$(GREEN)✓ Herramientas instaladas$(RESET)"

ci: audit test-coverage ## Pipeline CI (audit + coverage)
	@echo "$(GREEN)✓ CI pipeline completado$(RESET)"

.PHONY: all
all: clean deps fmt vet swagger test build ## Compilación completa
```

---

## 🐛 VSCODE DEBUGGING

### .vscode/launch.json (por proyecto)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug API Mobile",
      "type": "go",
      "request": "launch",
      "mode": "debug",
      "program": "${workspaceFolder}/cmd/main.go",
      "env": {
        "APP_ENV": "local",
        "POSTGRES_PASSWORD": "edugo_pass",
        "MONGODB_URI": "mongodb://edugo_admin:edugo_pass@localhost:27017/edugo?authSource=admin",
        "RABBITMQ_URL": "amqp://edugo_user:edugo_pass@localhost:5672/"
      },
      "args": [],
      "showLog": true,
      "trace": "verbose"
    },
    {
      "name": "Debug API Mobile (Dev Environment)",
      "type": "go",
      "request": "launch",
      "mode": "debug",
      "program": "${workspaceFolder}/cmd/main.go",
      "env": {
        "APP_ENV": "dev",
        "POSTGRES_PASSWORD": "${input:postgresPassword}",
        "MONGODB_URI": "${input:mongodbUri}",
        "RABBITMQ_URL": "${input:rabbitmqUrl}"
      },
      "showLog": true
    },
    {
      "name": "Debug Specific Test",
      "type": "go",
      "request": "launch",
      "mode": "test",
      "program": "${workspaceFolder}",
      "args": [
        "-test.v",
        "-test.run",
        "^${input:testName}$"
      ],
      "showLog": true
    },
    {
      "name": "Attach to Process",
      "type": "go",
      "request": "attach",
      "mode": "local",
      "processId": "${command:pickProcess}"
    }
  ],
  "inputs": [
    {
      "id": "testName",
      "type": "promptString",
      "description": "Nombre del test a ejecutar",
      "default": "TestMaterialSummaryResponse_JSON"
    },
    {
      "id": "postgresPassword",
      "type": "promptString",
      "description": "PostgreSQL Password",
      "default": "dev_password"
    },
    {
      "id": "mongodbUri",
      "type": "promptString",
      "description": "MongoDB URI",
      "default": "mongodb://dev-host:27017/edugo"
    },
    {
      "id": "rabbitmqUrl",
      "type": "promptString",
      "description": "RabbitMQ URL",
      "default": "amqp://dev-host:5672/"
    }
  ]
}
```

### .vscode/settings.json (por proyecto)

```json
{
  "go.testFlags": ["-v", "-race"],
  "go.buildFlags": ["-v"],
  "go.lintTool": "golangci-lint",
  "go.lintOnSave": "package",
  "go.formatTool": "goimports",
  "go.useLanguageServer": true,
  "go.toolsManagement.autoUpdate": true,
  "go.coverOnSave": true,
  "go.coverageDecorator": {
    "type": "gutter",
    "coveredHighlightColor": "rgba(64,128,64,0.5)",
    "uncoveredHighlightColor": "rgba(128,64,64,0.25)"
  },
  "files.exclude": {
    "**/.git": true,
    "**/bin": true,
    "**/coverage": true
  }
}
```

---

## 🐳 ESTRUCTURA DOCKER MEJORADA

### Concepto

**Actual** (centralizado):
```
/ (raíz)
├── Dockerfile.api-mobile
├── Dockerfile.api-administracion
├── Dockerfile.worker
└── docker-compose.yml (monolítico)
```

**Propuesto** (distribuido + orquestador):
```
/source/api-mobile/
├── Dockerfile                    # Docker para este servicio
└── docker-compose.yml            # Compose standalone

/source/api-administracion/
├── Dockerfile
└── docker-compose.yml

/source/worker/
├── Dockerfile
└── docker-compose.yml

/ (raíz)
├── docker-compose.yml            # Orquestador (llama a sub-composes)
└── docker-compose.dev.yml        # Override para desarrollo
```

### docker-compose.yml (Orquestador Raíz)

```yaml
version: '3.8'

# Servicios de infraestructura compartida
services:
  postgres:
    image: postgres:15-alpine
    container_name: edugo-postgres
    environment:
      POSTGRES_DB: edugo
      POSTGRES_USER: edugo_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-edugo_pass}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./source/scripts/postgresql:/docker-entrypoint-initdb.d:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U edugo_user -d edugo"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - edugo-network

  mongodb:
    image: mongo:7.0
    container_name: edugo-mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: edugo_admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGODB_PASSWORD:-edugo_pass}
      MONGO_INITDB_DATABASE: edugo
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
      - ./source/scripts/mongodb:/docker-entrypoint-initdb.d:ro
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/edugo --quiet
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - edugo-network

  rabbitmq:
    image: rabbitmq:3.12-management-alpine
    container_name: edugo-rabbitmq
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER:-edugo_user}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD:-edugo_pass}
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - edugo-network

# Incluir servicios de aplicación
include:
  - path: ./source/api-mobile/docker-compose.yml
  - path: ./source/api-administracion/docker-compose.yml
  - path: ./source/worker/docker-compose.yml

volumes:
  postgres_data:
  mongodb_data:
  rabbitmq_data:

networks:
  edugo-network:
    driver: bridge
    name: edugo-network
```

### docker-compose.yml (api-mobile)

```yaml
services:
  api-mobile:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: edugo-api-mobile
    environment:
      APP_ENV: ${APP_ENV:-local}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-edugo_pass}
      MONGODB_URI: mongodb://edugo_admin:${MONGODB_PASSWORD:-edugo_pass}@mongodb:27017/edugo?authSource=admin
      RABBITMQ_URL: amqp://${RABBITMQ_USER:-edugo_user}:${RABBITMQ_PASSWORD:-edugo_pass}@rabbitmq:5672/
    ports:
      - "8080:8080"
    volumes:
      - ./config:/app/config:ro  # Mount config files
      - ./logs:/app/logs         # Mount logs directory
    depends_on:
      postgres:
        condition: service_healthy
      mongodb:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - edugo-network

networks:
  edugo-network:
    external: true
    name: edugo-network
```

---

## 📋 PLAN DE IMPLEMENTACIÓN

### FASE 1: Makefiles Profesionales (1 hora)

**1.1. Crear Makefile api-mobile** (20min)
- Agregar todos los targets profesionales
- Variables de configuración
- Colores y mensajes claros
- Targets: help, build, test, coverage, lint, swagger, docker, audit, ci

**1.2. Crear Makefile api-administracion** (15min)
- Copiar de api-mobile
- Ajustar variables (APP_NAME, puerto)
- Sin targets de RabbitMQ

**1.3. Crear Makefile worker** (15min)
- Copiar de api-mobile
- Sin servidor HTTP
- Agregar targets para OpenAI testing

**1.4. Mejorar Makefile raíz** (10min)
- Orquestador que ejecuta make en cada proyecto
- Targets: build-all, test-all, swagger-all, clean-all

**Commit**: `chore: add professional Makefiles to all projects`

---

### FASE 2: VSCode Debugging (45min)

**2.1. api-mobile .vscode/** (15min)
- `launch.json` con 4 configuraciones:
  1. Debug local
  2. Debug dev environment
  3. Debug specific test
  4. Attach to process
- `settings.json` con Go settings

**2.2. api-administracion .vscode/** (10min)
- Similar a api-mobile
- Ajustar variables

**2.3. worker .vscode/** (10min)
- Sin servidor HTTP
- Con OPENAI_API_KEY

**2.4. Workspace .vscode/** (10min)
- launch.json a nivel raíz con todas las configs
- Multi-root workspace settings

**Commit**: `chore: add VSCode debugging configurations`

---

### FASE 3: Docker Structure Profesional (1.5 horas)

**3.1. Mover Dockerfiles** (15min)
- Mover `Dockerfile.api-mobile` → `source/api-mobile/Dockerfile`
- Mover `Dockerfile.api-administracion` → `source/api-administracion/Dockerfile`
- Mover `Dockerfile.worker` → `source/worker/Dockerfile`
- Ajustar context en cada Dockerfile (. en lugar de ../..)

**3.2. Crear docker-compose.yml por proyecto** (30min)
- `source/api-mobile/docker-compose.yml`
- `source/api-administracion/docker-compose.yml`
- `source/worker/docker-compose.yml`
- Cada uno con su servicio + referencia a network externa

**3.3. Actualizar docker-compose.yml raíz** (30min)
- Usar `include:` para sub-composes (Docker Compose 2.20+)
- O alternativa: `docker-compose -f compose1.yml -f compose2.yml`
- Mantener solo servicios de infraestructura (postgres, mongo, rabbitmq)
- Crear docker-compose.dev.yml para overrides de desarrollo

**3.4. Actualizar Dockerfiles** (15min)
- Multi-stage builds optimizados
- Cache de dependencias
- Health checks en imágenes

**Commit 1**: `refactor: move Dockerfiles to project directories`
**Commit 2**: `feat: add docker-compose per project with orchestrator`

---

### FASE 4: Tooling Adicional (45min)

**4.1. .golangci.yml** (15min)
- Configuración compartida de golangci-lint en raíz
- Linters habilitados: gofmt, govet, errcheck, staticcheck, gosimple, etc.

**4.2. .editorconfig** (5min)
- Configuración de editor consistente

**4.3. .gitignore mejorado** (5min)
- Agregar bin/, coverage/, *.log
- Ignorar archivos temporales

**4.4. Makefile raíz orquestador** (20min)
- `make all`: Ejecuta en 3 proyectos
- `make test-all`: Tests en 3 proyectos
- `make build-all`: Build en 3 proyectos
- `make docker-up`: Levanta stack completo

**Commit**: `chore: add project-wide tooling configuration`

---

### FASE 5: Documentación (30min)

**5.1. Actualizar DOCKER.md** (10min)
- Documentar nueva estructura
- Cómo ejecutar cada proyecto standalone
- Cómo ejecutar stack completo

**5.2. Actualizar DEVELOPMENT.md** (10min)
- Documentar Makefiles
- Documentar VSCode debugging
- Workflows de desarrollo

**5.3. Crear CONTRIBUTING.md** (10min)
- Guía para contribuidores
- Setup de entorno
- Workflow de desarrollo
- Standards de código

**Commit**: `docs: update documentation for professional tooling`

---

## ⏱️ ESTIMACIÓN TOTAL

| Fase | Tiempo | Commits |
|------|--------|---------|
| 1. Makefiles | 1h | 1 |
| 2. VSCode | 45min | 1 |
| 3. Docker | 1.5h | 2 |
| 4. Tooling | 45min | 1 |
| 5. Docs | 30min | 1 |
| **TOTAL** | **4.5 horas** | **6 commits** |

---

## 📦 ARCHIVOS A CREAR/MODIFICAR

### Por Proyecto (×3)
- `Makefile` (mejorado) - ~150 líneas
- `.vscode/launch.json` - ~80 líneas
- `.vscode/settings.json` - ~20 líneas
- `docker-compose.yml` (nuevo) - ~40 líneas
- `Dockerfile` (movido y mejorado) - ~40 líneas

**Subtotal por proyecto**: 5 archivos, ~330 líneas
**Total 3 proyectos**: 15 archivos, ~990 líneas

### Raíz
- `docker-compose.yml` (reescrito) - ~80 líneas
- `docker-compose.dev.yml` (nuevo) - ~30 líneas
- `Makefile` (orquestador) - ~100 líneas
- `.vscode/launch.json` (workspace) - ~100 líneas
- `.golangci.yml` - ~60 líneas
- `.editorconfig` - ~20 líneas
- `.gitignore` (mejorado) - +10 líneas
- `CONTRIBUTING.md` - ~100 líneas

**Total raíz**: 8 archivos, ~500 líneas

**GRAN TOTAL**: ~23 archivos nuevos/modificados, ~1,500 líneas

---

## 🎯 RESULTADO ESPERADO

### Desarrollo Local Simplificado

```bash
# Por proyecto
cd source/api-mobile
make help          # Ver comandos disponibles
make dev           # Desarrollo completo (deps + swagger + run)
make test-coverage # Tests con reporte HTML
make audit         # Validación completa

# Debugging en VSCode
# F5 → Seleccionar "Debug API Mobile" → Debugging activo
# Breakpoints, step-through, variables, todo funciona

# Docker por proyecto
cd source/api-mobile
make docker-build  # Solo este servicio
make docker-run    # Solo este servicio

# Stack completo
cd /
make up            # Levanta todo (infraestructura + 3 servicios)
make logs          # Ver todos los logs
make test-all      # Tests en 3 proyectos
```

### CI/CD Ready

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
      - run: make ci  # ¡Un solo comando!
```

---

## 🔐 MEJORAS DE SEGURIDAD

1. **Secrets en .env**: Nunca en docker-compose.yml
2. **.dockerignore mejorado**: Excluir config/*.yaml (excepto en build)
3. **Read-only mounts**: Config files como readonly
4. **Health checks**: En Dockerfiles individuales

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Fase 1: Makefiles
- [ ] api-mobile/Makefile (profesional)
- [ ] api-administracion/Makefile
- [ ] worker/Makefile
- [ ] Makefile raíz (orquestador)
- [ ] Probar: `make help`, `make test`, `make build` en cada proyecto
- [ ] Commit

### Fase 2: VSCode
- [ ] api-mobile/.vscode/ (launch.json + settings.json)
- [ ] api-administracion/.vscode/
- [ ] worker/.vscode/
- [ ] .vscode/ raíz (workspace)
- [ ] Probar debugging con F5
- [ ] Commit

### Fase 3: Docker
- [ ] Mover Dockerfiles a cada proyecto
- [ ] Crear docker-compose.yml por proyecto
- [ ] Reescribir docker-compose.yml raíz
- [ ] Crear docker-compose.dev.yml
- [ ] Probar builds individuales
- [ ] Probar stack completo
- [ ] 2 Commits

### Fase 4: Tooling
- [ ] .golangci.yml (raíz)
- [ ] .editorconfig
- [ ] .gitignore mejorado
- [ ] Makefile raíz completo
- [ ] Probar linters
- [ ] Commit

### Fase 5: Docs
- [ ] Actualizar DOCKER.md
- [ ] Actualizar DEVELOPMENT.md
- [ ] Crear CONTRIBUTING.md
- [ ] Commit

---

## 🎉 VENTAJAS

1. ✅ **Desarrollo standalone**: Cada proyecto puede trabajarse independientemente
2. ✅ **Debugging profesional**: VSCode debugging con breakpoints
3. ✅ **Makefiles estándar**: Comandos consistentes entre proyectos
4. ✅ **Docker modular**: Levantar solo lo que necesitas
5. ✅ **CI/CD ready**: Un solo comando `make ci`
6. ✅ **Code quality**: Lint + vet + format automatizado
7. ✅ **Coverage reports**: HTML reports visuales

---

**¿Apruebas este plan para implementar?**
