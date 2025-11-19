# Quick Wins - Mejoras Rápidas de CI/CD

**Objetivo:** Mejoras que se pueden implementar en 1-2 días con alto impacto

---

## 🎯 Quick Win #1: Resolver Fallos Críticos en infrastructure

**Impacto:** 🔴 CRÍTICO  
**Esfuerzo:** 2-4 horas  
**ROI:** Inmediato

### Problema
```
Success Rate: 20% (8 fallos consecutivos)
Último fallo: 2025-11-18 22:55:53
```

### Solución

```bash
# Paso 1: Obtener logs del último fallo
gh run view 19483248827 --repo EduGoGroup/edugo-infrastructure --log-failed > fallo.log

# Paso 2: Identificar step fallido
cat fallo.log | grep -A 10 "Error:"

# Paso 3: Reproducir localmente
cd /path/to/edugo-infrastructure
go test ./...

# Paso 4: Corregir y crear PR
# (según el error específico encontrado)
```

**Tiempo estimado:** 2-4 horas  
**Beneficio:** infrastructure vuelve a estar operativo

---

## 🎯 Quick Win #2: Eliminar Workflow Docker Duplicado en worker

**Impacto:** 🔴 ALTO  
**Esfuerzo:** 1 hora  
**ROI:** Reduce confusión y duplicación

### Problema
Worker tiene 3 workflows construyendo Docker:
1. `build-and-push.yml` (manual + push main)
2. `docker-only.yml` (trigger desconocido)
3. `release.yml` (tag push)

### Solución

**Decisión:** Mantener SOLO `manual-release.yml` (como api-mobile)

```bash
# Paso 1: Eliminar workflows duplicados
cd edugo-worker
git rm .github/workflows/docker-only.yml
git rm .github/workflows/build-and-push.yml

# Paso 2: Renombrar release.yml a manual-release.yml
git mv .github/workflows/release.yml .github/workflows/manual-release.yml

# Paso 3: Modificar manual-release.yml
# Cambiar trigger a SOLO workflow_dispatch con control por variable
```

**PR Example:**
```yaml
# .github/workflows/manual-release.yml
name: Release - Manual

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Versión a crear (sin v, ej: 0.1.0)'
        required: true
      build_docker:
        description: 'Construir imagen Docker'
        type: boolean
        default: true

  # Auto-trigger (deshabilitado por defecto)
  push:
    branches: [main]
    # Solo se activa si ENABLE_AUTO_RELEASE=true en repo settings

jobs:
  check-trigger:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - name: Verificar auto-release habilitado
        run: |
          if [ "${{ vars.ENABLE_AUTO_RELEASE }}" != "true" ]; then
            echo "⏭️  Auto-release deshabilitado - saliendo"
            exit 78  # Neutral exit
          fi
```

**Tiempo estimado:** 1 hora  
**Beneficio:** De 3 workflows a 1, claridad total

---

## 🎯 Quick Win #3: Congelar Go en 1.24.10

**Impacto:** 🟡 MEDIO-ALTO  
**Esfuerzo:** 30 minutos  
**ROI:** Elimina problemas con 1.25

### Problema
```
Go 1.25 causó problemas en GitHub Actions
Necesidad de congelar en versión estable
```

### Solución

```bash
# Script para actualizar todos los repos

repos=(
  "edugo-api-mobile"
  "edugo-api-administracion"
  "edugo-worker"
  "edugo-shared"
  "edugo-infrastructure"
)

for repo in "${repos[@]}"; do
  cd ~/source/EduGo/repos-separados/$repo
  
  # Find and replace en todos los workflows
  find .github/workflows -name "*.yml" -exec sed -i '' 's/GO_VERSION: "1.24"/GO_VERSION: "1.24.10"/g' {} +
  find .github/workflows -name "*.yml" -exec sed -i '' 's/GO_VERSION: "1.25"/GO_VERSION: "1.24.10"/g' {} +
  find .github/workflows -name "*.yml" -exec sed -i '' "s/go-version: '1.24'/go-version: '1.24.10'/g" {} +
  find .github/workflows -name "*.yml" -exec sed -i '' "s/go-version: '1.25'/go-version: '1.24.10'/g" {} +
  
  # Agregar comentario de advertencia
  for file in .github/workflows/*.yml; do
    if grep -q "GO_VERSION:" "$file"; then
      sed -i '' '/^env:/a\
  # ⚠️  Go 1.24.10 CONGELADO - No actualizar sin aprobación (1.25 causó problemas)\
' "$file"
    fi
  done
  
  # Commit
  git checkout -b chore/freeze-go-1.24.10
  git add .github/workflows/
  git commit -m "chore: congelar Go en 1.24.10

Go 1.25 causó problemas en GitHub Actions.
Se congela en 1.24.10 hasta nueva evaluación.

🤖 Generated with Claude Code"
  
  # Push y crear PR
  git push origin chore/freeze-go-1.24.10
  gh pr create --title "chore: Congelar Go en 1.24.10" \
               --body "**Problema:** Go 1.25 causó errores en GitHub Actions

**Solución:** Congelar en 1.24.10 (última versión estable conocida)

**Cambios:**
- Actualizar GO_VERSION a 1.24.10 en todos los workflows
- Agregar comentario de advertencia
- No actualizar sin aprobación explícita" \
               --base main
done
```

**Tiempo estimado:** 30 minutos  
**Beneficio:** Estabilidad en todos los proyectos

---

## 🎯 Quick Win #4: Configurar Pre-commit Hooks para Lint

**Impacto:** 🟡 MEDIO-ALTO  
**Esfuerzo:** 1 hora  
**ROI:** Evita errores tontos en CI

### Problema
Errores de lint llegan a CI cuando deberían detectarse localmente.

### Solución

```bash
# Setup en cada proyecto

# 1. Crear carpeta de hooks
mkdir -p .githooks

# 2. Crear pre-commit hook
cat > .githooks/pre-commit << 'HOOK'
#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Pre-commit checks - EduGo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Verificar formato Go
echo "📝 Verificando formato Go..."
UNFORMATTED=$(gofmt -l . | grep -v vendor || true)
if [ -n "$UNFORMATTED" ]; then
  echo "❌ Archivos sin formatear encontrados:"
  echo "$UNFORMATTED"
  echo ""
  echo "💡 Solución: go fmt ./..."
  exit 1
fi
echo "✅ Formato correcto"

# 2. golangci-lint
echo ""
echo "🔍 Ejecutando golangci-lint..."
if ! command -v golangci-lint &> /dev/null; then
  echo "⚠️  golangci-lint no instalado"
  echo "📦 Instala con: brew install golangci-lint"
  echo "⏭️  Saltando lint check..."
else
  if golangci-lint run --timeout=2m; then
    echo "✅ Lint pasó"
  else
    echo "❌ Lint falló"
    echo ""
    echo "💡 Corrige los errores antes de commit"
    echo "💡 O usa --no-verify para saltar (no recomendado)"
    exit 1
  fi
fi

# 3. go mod tidy check
echo ""
echo "📦 Verificando go.mod..."
cp go.mod go.mod.bak
cp go.sum go.sum.bak
go mod tidy
if ! diff -q go.mod go.mod.bak > /dev/null || ! diff -q go.sum go.sum.bak > /dev/null; then
  mv go.mod.bak go.mod
  mv go.sum.bak go.sum
  echo "❌ go.mod o go.sum necesitan tidy"
  echo "💡 Ejecuta: go mod tidy"
  exit 1
fi
rm go.mod.bak go.sum.bak
echo "✅ go.mod actualizado"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Todos los pre-commit checks pasaron"
echo "🚀 Continuando con commit..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
HOOK

chmod +x .githooks/pre-commit

# 3. Configurar Git
git config core.hooksPath .githooks

# 4. Crear Makefile target
cat >> Makefile << 'MAKE'

.PHONY: setup-hooks
setup-hooks:
	@echo "⚙️  Configurando Git hooks..."
	@git config core.hooksPath .githooks
	@chmod +x .githooks/*
	@echo "✅ Hooks configurados en .githooks/"
	@echo ""
	@echo "Los pre-commit hooks verificarán:"
	@echo "  • Formato Go (gofmt)"
	@echo "  • Lint (golangci-lint)"
	@echo "  • go.mod actualizado"

.PHONY: test-hooks
test-hooks:
	@echo "🧪 Probando pre-commit hook..."
	@./.githooks/pre-commit
MAKE

# 5. Actualizar README.md
cat >> README.md << 'README'

## 🛠️ Setup Inicial para Desarrollo

### 1. Instalar Herramientas

```bash
# macOS
brew install golangci-lint

# Linux
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
```

### 2. Configurar Pre-commit Hooks

```bash
make setup-hooks
```

Esto configura hooks que verifican automáticamente antes de cada commit:
- ✅ Formato de código (gofmt)
- ✅ Lint (golangci-lint)
- ✅ go.mod actualizado

### 3. Verificar Setup

```bash
# Probar hooks
make test-hooks

# Verificar golangci-lint
golangci-lint --version

# Verificar git hooks
git config core.hooksPath  # Debe mostrar: .githooks
```

### 4. Bypass (Solo en Emergencias)

```bash
# Saltar pre-commit hooks (NO RECOMENDADO)
git commit --no-verify -m "mensaje"
```

README

# 6. Commit todo
git add .githooks/ Makefile README.md
git commit -m "feat: agregar pre-commit hooks para lint

Previene errores de formato y lint antes de commit.

Cambios:
- Pre-commit hook con gofmt, golangci-lint, go mod tidy
- Makefile targets para setup
- Actualizar README con instrucciones

🤖 Generated with Claude Code"
```

**Tiempo estimado:** 1 hora (20 min código + 40 min aplicar a 5 repos)  
**Beneficio:** -80% errores de lint en CI

---

## 🎯 Quick Win #5: Control de Releases con Variable

**Impacto:** 🟡 MEDIO  
**Esfuerzo:** 30 minutos  
**ROI:** Flexibilidad para futuro

### Problema
Releases automáticos son inseguros en ambiente de desarrollo.

### Solución

**Enfoque:** On-demand siempre, con opción de automatizar en futuro.

```yaml
# .github/workflows/manual-release.yml
name: Release - Manual

on:
  # 1. Siempre disponible manualmente
  workflow_dispatch:
    inputs:
      version:
        description: 'Versión a crear (sin v, ej: 0.1.0)'
        required: true
        type: string
      
      build_docker:
        description: 'Construir imagen Docker'
        type: boolean
        default: true
      
      create_github_release:
        description: 'Crear GitHub Release'
        type: boolean
        default: true

  # 2. Auto-trigger (DESHABILITADO por defecto)
  #    Solo se activa si ENABLE_AUTO_RELEASE=true
  push:
    branches: [main]

jobs:
  # Job 1: Verificar si debe ejecutarse
  check-execution:
    runs-on: ubuntu-latest
    outputs:
      should_run: ${{ steps.check.outputs.should_run }}
    steps:
      - name: Decidir si ejecutar
        id: check
        run: |
          # Si es manual, siempre ejecutar
          if [ "${{ github.event_name }}" = "workflow_dispatch" ]; then
            echo "should_run=true" >> $GITHUB_OUTPUT
            echo "✅ Ejecución manual - proceder"
            exit 0
          fi
          
          # Si es push, verificar variable
          if [ "${{ vars.ENABLE_AUTO_RELEASE }}" = "true" ]; then
            echo "should_run=true" >> $GITHUB_OUTPUT
            echo "✅ Auto-release habilitado - proceder"
          else
            echo "should_run=false" >> $GITHUB_OUTPUT
            echo "⏭️  Auto-release deshabilitado - saltar"
            echo ""
            echo "💡 Para habilitar auto-release:"
            echo "   Settings → Secrets and variables → Actions → Variables"
            echo "   Crear: ENABLE_AUTO_RELEASE = true"
          fi

  # Job 2: Ejecutar release (solo si check-execution dice que sí)
  release:
    needs: check-execution
    if: needs.check-execution.outputs.should_run == 'true'
    runs-on: ubuntu-latest
    
    steps:
      # ... resto del workflow de release
```

**Configurar variable cuando estemos listos:**
```bash
# Opción 1: Via UI
# Settings → Secrets and variables → Actions → Variables → New repository variable
# Name: ENABLE_AUTO_RELEASE
# Value: true

# Opción 2: Via CLI
gh variable set ENABLE_AUTO_RELEASE --body "true" --repo EduGoGroup/edugo-api-mobile
```

**Tiempo estimado:** 30 minutos  
**Beneficio:** Control total, fácil migración a auto

---

## 🎯 Quick Win #6: Control de Tests de Integración

**Impacto:** 🟡 MEDIO  
**Esfuerzo:** 20 minutos  
**ROI:** Evita ejecuciones innecesarias

### Problema
Tests de integración deberían ser on-demand hasta estar confiados.

### Solución

```yaml
# En workflows de CI (pr-to-dev.yml, pr-to-main.yml)

jobs:
  unit-tests:
    # Siempre se ejecutan
    steps:
      - run: make test-unit

  integration-tests:
    # Solo si:
    # 1. Workflow manual Y usuario pidió integration
    # 2. O variable ENABLE_AUTO_INTEGRATION=true
    # 3. O PR tiene label 'run-integration'
    if: |
      (github.event_name == 'workflow_dispatch' && inputs.run_integration == 'true') ||
      (vars.ENABLE_AUTO_INTEGRATION == 'true') ||
      (contains(github.event.pull_request.labels.*.name, 'run-integration'))
    
    runs-on: ubuntu-latest
    timeout-minutes: 15
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.24.10'
      
      - name: Run integration tests
        env:
          RUN_INTEGRATION_TESTS: "true"
        run: make test-integration
```

**Agregar input manual:**
```yaml
on:
  workflow_dispatch:
    inputs:
      run_integration:
        description: 'Ejecutar tests de integración'
        type: boolean
        default: false
  
  pull_request:
    # ...
```

**Uso:**
```bash
# Opción 1: Manual desde UI
# Actions → Workflow → Run workflow → ✓ Ejecutar tests integración

# Opción 2: Label en PR
# Agregar label 'run-integration' al PR

# Opción 3: Habilitar permanentemente (cuando estemos listos)
gh variable set ENABLE_AUTO_INTEGRATION --body "true"
```

**Tiempo estimado:** 20 minutos  
**Beneficio:** Control granular de tests costosos

---

## 🎯 Quick Win #7: Releases por Módulo (shared/infrastructure)

**Impacto:** 🟡 MEDIO  
**Esfuerzo:** 45 minutos  
**ROI:** Releases independientes por módulo

### Problema
shared e infrastructure tienen múltiples módulos que necesitan releases independientes.

### Solución

```yaml
# edugo-shared/.github/workflows/release-module.yml
name: Release - Por Módulo (Manual)

on:
  workflow_dispatch:
    inputs:
      module:
        description: 'Módulo a liberar'
        type: choice
        required: true
        options:
          - common
          - logger
          - auth
          - middleware/gin
          - messaging/rabbit
          - database/postgres
          - database/mongodb
          - all  # Liberar todos con misma versión
      
      version:
        description: 'Versión (sin v, ej: 0.7.1)'
        required: true
        type: string

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.24.10'
      
      - name: Validar módulo
        id: validate
        run: |
          MODULE="${{ inputs.module }}"
          VERSION="${{ inputs.version }}"
          
          # Validar formato semver
          if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
            echo "❌ Versión debe ser semver (ej: 0.7.1)"
            exit 1
          fi
          
          # Validar que módulo existe
          if [ "$MODULE" != "all" ] && [ ! -d "$MODULE" ]; then
            echo "❌ Módulo $MODULE no existe"
            exit 1
          fi
          
          echo "module=$MODULE" >> $GITHUB_OUTPUT
          echo "version=$VERSION" >> $GITHUB_OUTPUT
      
      - name: Tests del módulo
        run: |
          MODULE="${{ steps.validate.outputs.module }}"
          
          if [ "$MODULE" = "all" ]; then
            # Probar todos
            for mod in common logger auth middleware/gin messaging/rabbit database/postgres database/mongodb; do
              echo "Testing $mod..."
              cd $mod
              go test -v ./...
              cd -
            done
          else
            # Probar solo el módulo
            cd $MODULE
            go test -v ./...
          fi
      
      - name: Crear tags
        run: |
          MODULE="${{ steps.validate.outputs.module }}"
          VERSION="${{ steps.validate.outputs.version }}"
          
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          
          if [ "$MODULE" = "all" ]; then
            # Tag global
            TAG="v$VERSION"
            git tag -a "$TAG" -m "Release v$VERSION (todos los módulos)"
            git push origin "$TAG"
            echo "✅ Tag creado: $TAG"
          else
            # Tag por módulo: common/v0.7.1
            TAG="$MODULE/v$VERSION"
            git tag -a "$TAG" -m "Release $MODULE v$VERSION"
            git push origin "$TAG"
            echo "✅ Tag creado: $TAG"
          fi
      
      - name: Crear GitHub Release
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          MODULE="${{ steps.validate.outputs.module }}"
          VERSION="${{ steps.validate.outputs.version }}"
          
          if [ "$MODULE" = "all" ]; then
            TAG="v$VERSION"
            TITLE="Release v$VERSION (Todos los módulos)"
          else
            TAG="$MODULE/v$VERSION"
            TITLE="Release $MODULE v$VERSION"
          fi
          
          gh release create "$TAG" \
            --title "$TITLE" \
            --notes "## Instalación

\`\`\`bash
go get github.com/EduGoGroup/edugo-shared/$MODULE@$TAG
\`\`\`

## Uso

Ver documentación en [$MODULE/README.md](https://github.com/EduGoGroup/edugo-shared/tree/$TAG/$MODULE)"
```

**Uso:**
```bash
# Liberar módulo específico
# Actions → Release - Por Módulo → Run workflow
# Module: logger
# Version: 0.7.1

# Resultado: Tag logger/v0.7.1

# Instalar en otro proyecto:
go get github.com/EduGoGroup/edugo-shared/logger@logger/v0.7.1
```

**Tiempo estimado:** 45 minutos  
**Beneficio:** Releases independientes, versionado claro

---

## 📊 Resumen de Quick Wins Actualizados

| # | Quick Win | Tiempo | Impacto | Prioridad | Aclaración |
|---|-----------|--------|---------|-----------|------------|
| 1 | Resolver fallos infrastructure | 2-4h | 🔴 Crítico | P0 | - |
| 2 | Eliminar Docker worker | 1h | 🔴 Alto | P0 | Solo manual |
| 3 | Congelar Go 1.24.10 | 30m | 🟡 Medio | P1 | 1.25 causó problemas |
| 4 | Pre-commit hooks lint | 1h | 🟡 Medio | P1 | Evitar errores tontos |
| 5 | Control releases variable | 30m | 🟡 Medio | P1 | On-demand + futuro auto |
| 6 | Control tests integración | 20m | 🟡 Medio | P1 | On-demand hasta confianza |
| 7 | Releases por módulo | 45m | 🟡 Medio | P1 | shared/infrastructure |

**Total:** ~7 horas para resolver 7 problemas críticos

---

## 📅 Plan de Ejecución Actualizado

### Día 1 (Hoy)
- ⏰ 9:00-11:00: QW #1 - Resolver infrastructure (2h)
- ⏰ 11:00-12:00: QW #2 - Eliminar Docker worker (1h)
- ⏰ 14:00-15:00: QW #4 - Pre-commit hooks (1h)
- ⏰ 15:00-15:30: QW #3 - Congelar Go 1.24.10 (30m)

**Total Día 1:** 4h 30m

### Día 2 (Mañana)
- ⏰ 9:00-9:30: QW #5 - Control releases (30m)
- ⏰ 9:30-10:00: QW #6 - Control tests integración (20m)
- ⏰ 10:00-10:45: QW #7 - Releases por módulo (45m)

**Total Día 2:** 1h 35m

**TOTAL:** 6h 5m distribuidas en 2 días

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025  
**Versión:** 2.0 con aclaraciones
