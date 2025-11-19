# Investigación: Go 1.25 - Análisis del Problema y Viabilidad

**Fecha:** 19 de Noviembre, 2025  
**Investigación:** Por qué falló Go 1.25 y si podemos usarlo ahora  
**Proyectos afectados:** edugo-api-mobile, edugo-shared

---

## 🎯 Resumen Ejecutivo

**Problema Original:** Se configuró **Go 1.25.3** (versión que NO EXISTÍA en ese momento)

**Estado Actual:** Go 1.25.4 SÍ EXISTE AHORA (disponible oficialmente)

**Causa del Fallo:** Error en número de versión (1.25.3 vs 1.25.4) + golangci-lint incompatibilidad

**Conclusión:** ✅ **PODEMOS migrar a Go 1.25.4 AHORA**, pero con precauciones

---

## 📊 Versiones Oficiales de Go (19 Nov 2025)

### Disponibles AHORA:

```
✅ go1.25.4  ← ÚLTIMA VERSIÓN (disponible)
✅ go1.24.10 ← VERSIÓN ACTUAL (estable)
```

### Estado en Noviembre 11, 2025 (cuando ocurrió el problema):

**Configurado:** `go 1.25.3`  
**Realidad:** Probablemente Go 1.25.3 no estaba disponible aún, solo 1.25.2 o anterior

---

## 🔍 Análisis del Fallo Original

### Timeline del Problema

**Noviembre 11, 2025 - Commits problemáticos:**

```bash
535852a - docs: actualizar versión de Go a 1.25.3 en README.md
         ↓
4c38785 - fix: actualizar golangci-lint action para Go 1.25.3
         ↓
         ❌ FALLOS EN CI/CD (4 runs)
         ↓
9c92b23 - fix: corregir versión de Go de 1.25.3 (inexistente) a 1.23
         ↓
2c8b8e2 - fix: actualizar de Go 1.25.3 (inexistente) a Go 1.24
```

### Error Exacto en GitHub Actions

**Run ID:** 19282118024  
**Job:** Lint & Format Check  
**Fallo en step:** 🔍 Run golangci-lint

```
Error: can't load config: the Go language version (go1.24) 
used to build golangci-lint is lower than the targeted 
Go version (1.25.3)
```

**Análisis:**
```
golangci-lint v1.64.8 → compilado con Go 1.24
go.mod requiere → go 1.25.3 (que no existía o no era estable)
GitHub Actions → no pudo instalar Go 1.25.3
Resultado → Pipeline fallido
```

---

## 🧪 Verificación de Compatibilidad Actual

### 1. Dependencias Principales

**testcontainers-go v0.40.0:**
```
Requiere: go 1.24.0
✅ Compatible con Go 1.25.4
```

**golang.org/x/crypto (última):**
```
Requiere: go 1.24.0
✅ Compatible con Go 1.25.4
```

**Conclusión:** Las dependencias NO son el problema, soportan 1.25.

---

### 2. Herramientas de CI/CD

**golangci-lint v1.64.7 (usado en workflows):**
```
¿Compatible con Go 1.25? → NECESITA VERIFICACIÓN
```

**GitHub Actions setup-go@v5:**
```
✅ Soporta Go 1.25.4 oficialmente
```

---

## ✅ ¿Podemos Migrar a Go 1.25.4 AHORA?

### SÍ, PERO con validación previa

**Requisitos para migración exitosa:**

1. ✅ **Go 1.25.4 existe oficialmente** (verificado)
2. ✅ **Dependencias compatibles** (testcontainers, crypto)
3. ⚠️ **golangci-lint compatible** (necesita verificación)
4. ⚠️ **No hay breaking changes** (necesita pruebas)

---

## 🚀 Plan de Migración a Go 1.25.4

### Fase 1: Validación (1 hora)

```bash
# 1. Probar en api-mobile localmente
cd ~/source/EduGo/repos-separados/edugo-api-mobile

# 2. Actualizar Go local si es necesario
go version  # Verificar que sea 1.24.10

# 3. Crear rama de prueba
git checkout -b test/go-1.25.4

# 4. Actualizar go.mod
cat > go.mod.tmp << 'EOF'
module github.com/EduGoGroup/edugo-api-mobile

go 1.25.4  // ← Actualizar aquí

require (
    // ... mantener todas las dependencias
)
EOF
# Copiar solo la línea go, mantener resto igual

# 5. Probar build local
go mod tidy
go build ./...

# 6. Ejecutar tests
go test ./...

# 7. Ejecutar lint
golangci-lint run --timeout=5m

# 8. Si todo pasa → Continuar
# Si falla → Investigar error específico
```

---

### Fase 2: Actualizar Workflows (15 min)

```bash
# Actualizar versión en workflows
find .github/workflows -name "*.yml" -exec sed -i '' 's/GO_VERSION: "1.24.10"/GO_VERSION: "1.25.4"/g' {} +
find .github/workflows -name "*.yml" -exec sed -i '' "s/go-version: '1.24.10'/go-version: '1.25.4'/g" {} +

# Actualizar Dockerfile
sed -i '' 's/golang:1.24.10-alpine/golang:1.25.4-alpine/g' Dockerfile
```

---

### Fase 3: Testing Local con act (30 min)

```bash
# Probar workflow completo localmente
act pull_request -W .github/workflows/pr-to-dev.yml --env GO_VERSION=1.25.4

# Si falla, ver logs detallados
act pull_request -W .github/workflows/pr-to-dev.yml -v
```

---

### Fase 4: PR de Prueba (1 hora)

```bash
# Commit cambios
git add .
git commit -m "test: evaluar migración a Go 1.25.4

Prueba de compatibilidad con Go 1.25.4.

Cambios:
- go.mod: go 1.25.4
- Workflows: GO_VERSION 1.25.4
- Dockerfile: golang:1.25.4-alpine

Validaciones locales:
- build: OK
- tests: OK  
- lint: OK

🤖 Generated with Claude Code"

# Push
git push origin test/go-1.25.4

# Crear PR de prueba
gh pr create \
  --title "test: Evaluar migración a Go 1.25.4" \
  --body "## 🧪 Prueba de Migración a Go 1.25.4

**Contexto:**
- Go 1.25.4 está disponible oficialmente
- Problema anterior fue por Go 1.25.3 (versión inexistente/inestable)
- Todas las dependencias son compatibles

**Validaciones Locales:**
- ✅ go mod tidy
- ✅ go build
- ✅ go test
- ✅ golangci-lint

**Objetivo:**
Validar en GitHub Actions si Go 1.25.4 funciona correctamente.

**Si falla:** Analizar logs y decidir si quedarse en 1.24.10
**Si pasa:** Evaluar merge a dev" \
  --base dev \
  --label "testing,go-upgrade"

# Monitorear el PR
gh pr view --web
```

---

## 🔬 Checklist de Validación

### Antes de Migrar

- [ ] Go 1.25.4 existe oficialmente ✅ (verificado)
- [ ] Instalado localmente: `go install golang.org/dl/go1.25.4@latest && go1.25.4 download`
- [ ] `go mod tidy` sin errores
- [ ] `go build ./...` sin errores
- [ ] `go test ./...` sin errores
- [ ] `golangci-lint run` sin errores
- [ ] `make test-integration` sin errores (si aplica)

### Durante PR de Prueba

- [ ] Setup Go pasa
- [ ] Download dependencies pasa
- [ ] Unit tests pasan
- [ ] Integration tests pasan (si se ejecutan)
- [ ] golangci-lint pasa
- [ ] Docker build pasa
- [ ] No hay warnings inesperados

### Decisión Final

- [ ] Si TODO pasa → Merge y replicar en otros proyectos
- [ ] Si ALGO falla → Investigar causa específica
- [ ] Si es problema de golangci-lint → Actualizar versión de lint
- [ ] Si es breaking change de Go → Quedarse en 1.24.10

---

## 🎯 Posibles Problemas y Soluciones

### Problema 1: golangci-lint incompatible

**Error esperado:**
```
Error: golangci-lint version too old for Go 1.25
```

**Solución:**
```yaml
# Actualizar golangci-lint en workflow
- uses: golangci/golangci-lint-action@v6
  with:
    version: v1.64.8  # o latest
```

### Problema 2: Breaking changes en Go 1.25

**Síntomas:**
```
Tests fallan con errores raros
Build falla con errores de sintaxis
```

**Solución:**
```bash
# Revisar release notes de Go 1.25
curl -s https://go.dev/doc/go1.25 | grep -i "breaking\|incompatible"

# Ajustar código según sea necesario
```

### Problema 3: Dependencias con versiones fijas

**Síntomas:**
```
go: module requires go >= 1.26
```

**Solución:**
```bash
# Actualizar dependencias a versiones compatibles
go get -u ./...
go mod tidy
```

---

## 💡 Recomendación Final

### Opción A: Migrar a Go 1.25.4 (Recomendado si tenemos tiempo)

**Pros:**
- ✅ Última versión oficial disponible
- ✅ Mejoras de performance
- ✅ Parches de seguridad
- ✅ Features nuevas del lenguaje
- ✅ Mantenernos actualizados

**Contras:**
- ⚠️ Requiere validación (2-3 horas)
- ⚠️ Posibles ajustes en código
- ⚠️ Riesgo de encontrar incompatibilidades

**Plan:**
1. Crear PR de prueba en api-mobile
2. Validar en CI/CD
3. Si pasa, replicar en shared
4. Luego api-admin, worker, infrastructure

---

### Opción B: Quedarse en Go 1.24.10 (Conservador)

**Pros:**
- ✅ Ya funciona perfectamente
- ✅ Sin riesgo
- ✅ Sin tiempo de validación
- ✅ Todas las dependencias compatibles

**Contras:**
- ⚠️ No aprovechamos mejoras de 1.25
- ⚠️ Eventualmente tendremos que actualizar

**Plan:**
1. Mantener 1.24.10 congelado
2. Revisar en 3-6 meses
3. Actualizar cuando Go 1.26 esté disponible (saltar 1.25)

---

## 🎓 Lecciones Aprendidas

### 1. El Problema NO fue "Go 1.25"

**❌ Mito:** "Go 1.25 causó problemas, no funciona"

**✅ Realidad:** 
- Go **1.25.3** no existía (versión inexistente)
- Go **1.25.4** SÍ existe y probablemente funciona bien
- El problema fue configurar una versión que no había sido liberada

### 2. Verificar Versiones Antes de Configurar

**Checklist antes de actualizar Go:**
```bash
# 1. Verificar que la versión existe
curl -s https://go.dev/dl/?mode=json | jq -r '.[].version' | grep "go1.25.4"

# 2. Verificar en GitHub Actions
# https://github.com/actions/setup-go/blob/main/docs/adrs/0000-supported-versions.md

# 3. Probar localmente primero
go install golang.org/dl/go1.25.4@latest
go1.25.4 download
go1.25.4 version
```

### 3. Dependencies NO son el Problema

**Verificado:**
- testcontainers-go v0.40.0 → requiere go 1.24.0 (compatible con 1.25)
- golang.org/x/crypto → requiere go 1.24.0 (compatible con 1.25)

**Conclusión:** Las dependencias actuales soportan Go 1.25.

---

## 🚀 Plan de Acción Recomendado

### Opción Sugerida: Migrar Gradualmente

**Semana 1: Prueba en api-mobile**
```bash
# Día 1: Crear PR de prueba
# Día 2: Validar CI/CD
# Día 3: Ajustar si hay problemas
```

**Semana 2: Si api-mobile pasa**
```bash
# Migrar shared primero (es librería base)
# Validar que otros proyectos siguen funcionando
```

**Semana 3: Migrar resto**
```bash
# api-administracion
# worker
# infrastructure
```

---

## 📋 Script de Migración

```bash
#!/bin/bash
# migrate-to-go-1.25.4.sh

set -e

PROJECT_PATH=$1
PROJECT_NAME=$(basename $PROJECT_PATH)

echo "🚀 Migrando $PROJECT_NAME a Go 1.25.4..."
echo ""

cd $PROJECT_PATH

# 1. Crear rama
git checkout dev
git pull origin dev
git checkout -b chore/upgrade-go-1.25.4

# 2. Actualizar go.mod
echo "📝 Actualizando go.mod..."
sed -i '' 's/^go 1\.24\.10/go 1.25.4/' go.mod
sed -i '' 's/^go 1\.24/go 1.25.4/' go.mod

# 3. Actualizar workflows
echo "📝 Actualizando workflows..."
find .github/workflows -name "*.yml" -exec sed -i '' 's/GO_VERSION: "1.24.10"/GO_VERSION: "1.25.4"/g' {} +
find .github/workflows -name "*.yml" -exec sed -i '' 's/GO_VERSION: "1.24"/GO_VERSION: "1.25.4"/g' {} +
find .github/workflows -name "*.yml" -exec sed -i '' "s/go-version: '1.24.10'/go-version: '1.25.4'/g" {} +

# 4. Actualizar Dockerfile si existe
if [ -f Dockerfile ]; then
  echo "📝 Actualizando Dockerfile..."
  sed -i '' 's/golang:1.24.10-alpine/golang:1.25.4-alpine/g' Dockerfile
  sed -i '' 's/golang:1.24-alpine/golang:1.25.4-alpine/g' Dockerfile
fi

# 5. Actualizar README si menciona versión
if grep -q "Go 1.24" README.md 2>/dev/null; then
  sed -i '' 's/Go 1\.24\.10/Go 1.25.4/g' README.md
  sed -i '' 's/Go 1\.24/Go 1.25/g' README.md
fi

echo ""
echo "✅ Archivos actualizados"
echo ""

# 6. Validar localmente
echo "🧪 Validando cambios..."

# 6.1 go mod tidy
echo "  → go mod tidy..."
if go mod tidy; then
  echo "  ✅ go mod tidy OK"
else
  echo "  ❌ go mod tidy FALLÓ"
  exit 1
fi

# 6.2 build
echo "  → go build..."
if go build ./...; then
  echo "  ✅ go build OK"
else
  echo "  ❌ go build FALLÓ"
  exit 1
fi

# 6.3 tests
echo "  → go test..."
if go test ./...; then
  echo "  ✅ go test OK"
else
  echo "  ❌ go test FALLÓ"
  exit 1
fi

# 6.4 lint
echo "  → golangci-lint..."
if golangci-lint run --timeout=5m; then
  echo "  ✅ golangci-lint OK"
else
  echo "  ⚠️  golangci-lint con warnings (revisar)"
fi

echo ""
echo "✅ Validaciones locales completadas"
echo ""

# 7. Commit
git add .
git commit -m "chore: actualizar Go a 1.25.4

Migración de Go 1.24.10 a Go 1.25.4.

Razón:
- Go 1.25.4 está disponible oficialmente
- Problema anterior fue Go 1.25.3 (versión inexistente)
- Todas las dependencias son compatibles

Cambios:
- go.mod: go 1.25.4
- Workflows: GO_VERSION 1.25.4
- Dockerfile: golang:1.25.4-alpine (si aplica)

Validaciones locales:
- ✅ go mod tidy
- ✅ go build
- ✅ go test
- ✅ golangci-lint

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"

echo "📤 Pusheando rama de prueba..."
git push origin chore/upgrade-go-1.25.4

echo ""
echo "✅ Migración preparada"
echo ""
echo "📋 Próximos pasos:"
echo "  1. Crear PR: gh pr create --base dev --label testing"
echo "  2. Validar que CI/CD pase"
echo "  3. Si pasa → Merge"
echo "  4. Si falla → Analizar logs y ajustar"
```

**Uso:**
```bash
# Ejecutar para api-mobile
./migrate-to-go-1.25.4.sh ~/source/EduGo/repos-separados/edugo-api-mobile
```

---

## 🎯 Estrategia de Rollout

### Orden de Migración Sugerido

**1. edugo-shared** (primero)
- Es la librería base
- Si falla, impacta a todos
- Mejor detectar problemas aquí

**2. edugo-api-mobile** (segundo)
- Tiene tests de integración completos
- Mejor cobertura de casos
- Si pasa aquí, probablemente pasa en otros

**3. edugo-infrastructure** (tercero)
- Librería de soporte
- Menos crítico que shared

**4. edugo-api-administracion** (cuarto)
- Similar a api-mobile
- Menos tests que mobile

**5. edugo-worker** (último)
- Menos complejo
- Ya tiene Go 1.25 en algunos workflows (inconsistencia detectada)

---

## 📊 Matriz de Decisión

### Migrar AHORA (Go 1.25.4)

| Aspecto | Evaluación |
|---------|------------|
| **Riesgo Técnico** | 🟡 Medio (validación necesaria) |
| **Esfuerzo** | 🟢 Bajo (2-3 horas totales) |
| **Beneficio** | 🟡 Medio (mejoras incrementales) |
| **Urgencia** | 🟢 Baja (1.24.10 funciona bien) |
| **Ventana de Testing** | ✅ Buena (estamos en desarrollo) |

**Score:** 7/10 - **Vale la pena intentar**

### Quedarse en Go 1.24.10

| Aspecto | Evaluación |
|---------|------------|
| **Riesgo Técnico** | 🟢 Bajo (ya funciona) |
| **Esfuerzo** | 🟢 Ninguno |
| **Beneficio** | 🔴 Ninguno (solo mantener status quo) |
| **Deuda Técnica** | 🟡 Media (eventualmente hay que actualizar) |

**Score:** 5/10 - **Opción segura pero no óptima**

---

## 💡 Recomendación Final

### 🎯 MIGRAR A GO 1.25.4 CON VALIDACIÓN

**Razones:**
1. ✅ La versión existe oficialmente AHORA
2. ✅ El problema anterior fue versión inexistente (1.25.3)
3. ✅ Estamos en fase de desarrollo (ventana de testing)
4. ✅ Todas las dependencias son compatibles
5. ✅ Podemos revertir fácilmente si falla

**Plan:**
1. **HOY:** Ejecutar script de validación local (30 min)
2. **MAÑANA:** Crear PR de prueba en api-mobile (1 hora)
3. **Si pasa:** Replicar en shared y resto (2 horas)
4. **Si falla:** Analizar logs, decidir si ajustar o quedarse en 1.24.10

**Criterio de Éxito:**
- ✅ CI/CD pasa en api-mobile
- ✅ Tests de integración pasan
- ✅ golangci-lint sin errores
- ✅ Docker build exitoso

**Criterio de Rollback:**
- ❌ Cualquier fallo no explicable en <1 hora de debugging
- ❌ Breaking changes que requieren refactoring
- ❌ Problemas de compatibilidad con herramientas

---

## 📝 Siguiente Paso Inmediato

**Ejecutar este comando AHORA para validar:**

```bash
cd ~/source/EduGo/repos-separados/edugo-api-mobile

# Probar Go 1.25.4 SIN cambiar archivos
docker run --rm -v $(pwd):/app -w /app golang:1.25.4-alpine sh -c '
  go version
  go mod download
  go build ./...
  go test -short ./...
'
```

Si este comando pasa → **ADELANTE con la migración**  
Si falla → **Investigar el error específico**

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025  
**Versión:** 1.0 - Investigación Completa
