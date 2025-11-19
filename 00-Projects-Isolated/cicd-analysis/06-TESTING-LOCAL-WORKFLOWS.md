# Testing Local de GitHub Actions Workflows

**Fecha:** 19 de Noviembre, 2025  
**Objetivo:** Ejecutar y probar workflows de GitHub Actions localmente antes de push

---

## 🎯 Opciones para Testing Local

### Opción 1: nektos/act (⭐ Recomendado)

**Lo más popular y completo para ejecutar GitHub Actions localmente.**

#### Instalación

```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Verificar instalación
act --version
```

#### Uso Básico

```bash
# En el proyecto
cd ~/source/EduGo/repos-separados/edugo-api-mobile

# Listar workflows disponibles
act -l

# Ejecutar workflow específico
act -W .github/workflows/pr-to-dev.yml

# Ejecutar solo un job específico
act -j unit-tests

# Simular un evento pull_request
act pull_request

# Dry-run (ver qué haría sin ejecutar)
act -n

# Ver logs detallados
act -v
```

#### Configuración

Crear archivo `.actrc` en el proyecto:

```bash
cat > .actrc << 'EOF'
# Usar imagen medium (más completa)
-P ubuntu-latest=catthehacker/ubuntu:act-latest

# Variables de entorno
--env GO_VERSION=1.24.10
--env COVERAGE_THRESHOLD=33
EOF
```

#### Ejecutar Workflows de EduGo

```bash
# PR to Dev (tests unitarios)
act pull_request \
  -W .github/workflows/pr-to-dev.yml \
  -j unit-tests \
  --env GO_VERSION=1.24.10

# PR to Main (suite completa)
act pull_request \
  -W .github/workflows/pr-to-main.yml \
  --env GO_VERSION=1.24.10

# Manual Release (workflow_dispatch)
act workflow_dispatch \
  -W .github/workflows/manual-release.yml \
  --input version=0.1.0
```

---

### Opción 2: Makefile Targets (⭐ Más Simple)

**Replicar los pasos del workflow en Makefile.**

```makefile
# Makefile en cada proyecto

.PHONY: ci-unit-tests
ci-unit-tests:
	@echo "🧪 Ejecutando tests unitarios (como CI)..."
	@export GO_VERSION=1.24.10 && \
	export COVERAGE_THRESHOLD=33 && \
	go fmt ./... && \
	go vet ./... && \
	go test -v -race -coverprofile=coverage.out ./... && \
	go tool cover -func=coverage.out

.PHONY: ci-lint
ci-lint:
	@echo "🔍 Ejecutando lint (como CI)..."
	@golangci-lint run --timeout=5m

.PHONY: ci-pr-to-dev
ci-pr-to-dev: ci-lint ci-unit-tests
	@echo "✅ Simulación de PR to Dev completada"

.PHONY: act-pr-dev
act-pr-dev:
	@echo "🎬 Ejecutando workflow PR to Dev localmente con act..."
	@act pull_request -W .github/workflows/pr-to-dev.yml
```

**Uso:**
```bash
# Opción rápida (sin Docker)
make ci-pr-to-dev

# Opción completa (con act)
make act-pr-dev
```

---

### Opción 3: Docker Compose para Tests de Integración

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  test-runner:
    image: golang:1.24.10-alpine
    working_dir: /app
    volumes:
      - .:/app
    environment:
      - GO_VERSION=1.24.10
      - RUN_INTEGRATION_TESTS=true
      - POSTGRES_HOST=postgres
    depends_on:
      - postgres
      - mongodb
    command: go test -v -race ./...

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
      POSTGRES_DB: edugo_test

  mongodb:
    image: mongo:7.0
```

**Uso:**
```bash
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

---

## 🎯 Recomendación por Caso de Uso

### Tests Rápidos Diarios
```bash
# Makefile targets (sin Docker)
make ci-pr-to-dev
```

### Validación Pre-Push
```bash
# act (con Docker)
act pull_request -W .github/workflows/pr-to-dev.yml
```

### Tests de Integración
```bash
# Docker Compose
docker-compose -f docker-compose.test.yml up
```

---

## 📋 Setup Recomendado

### 1. Instalar Herramientas

```bash
brew install act
brew install --cask docker
```

### 2. Configurar act Globalmente

```bash
cat > ~/.actrc << 'EOF'
-P ubuntu-latest=catthehacker/ubuntu:act-latest
--container-architecture linux/amd64
EOF
```

### 3. Agregar Makefile Targets

```makefile
.PHONY: act-list
act-list:
	@echo "📋 Workflows disponibles:"
	@act -l

.PHONY: act-pr-dev
act-pr-dev:
	@act pull_request -W .github/workflows/pr-to-dev.yml

.PHONY: act-dry
act-dry:
	@act -n
```

---

## 🔧 Troubleshooting

### act falla con "permission denied"
```bash
act -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

### Docker-in-Docker no funciona
```bash
act --bind
```

### Secrets no disponibles
```bash
# Crear .secrets (NO COMMITEAR)
cat > .secrets << 'EOF'
GITHUB_TOKEN=ghp_xxx
EOF

act --secret-file .secrets
echo ".secrets" >> .gitignore
```

---

## 📊 Comparación de Opciones

| Opción | Velocidad | Fidelidad | Complejidad |
|--------|-----------|-----------|-------------|
| Makefile | ⚡⚡⚡ | ⭐⭐ | Baja |
| act | ⚡⚡ | ⭐⭐⭐⭐ | Media |
| Docker Compose | ⚡ | ⭐⭐⭐⭐⭐ | Media |

---

## 🚀 Quick Start

```bash
# Instalación
brew install act

# Test rápido
cd ~/source/EduGo/repos-separados/edugo-api-mobile
act -l

# Ejecutar workflow
act pull_request -W .github/workflows/pr-to-dev.yml -j unit-tests

# Agregar a Makefile
cat >> Makefile << 'EOF'

.PHONY: test-ci
test-ci:
	act pull_request -W .github/workflows/pr-to-dev.yml
EOF

# Usar
make test-ci
```

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025
