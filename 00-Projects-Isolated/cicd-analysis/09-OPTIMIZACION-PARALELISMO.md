# Optimización con Paralelismo en GitHub Actions

**Fecha:** 19 de Noviembre, 2025  
**Objetivo:** Implementar ejecución paralela para reducir tiempos de CI/CD  
**Estado:** Preparación para escalabilidad futura

---

## 🎯 Motivación

Aunque estamos en fase de desarrollo con código limitado, **establecer la estructura ahora** nos permite:

1. ✅ Escalabilidad lista cuando el código crezca
2. ✅ Tiempos de CI/CD optimizados desde el inicio
3. ✅ Mejor experiencia de desarrollo (feedback rápido)
4. ✅ Aprovechar runners concurrentes de GitHub

---

## 📊 Análisis de Tiempos Actuales

### Estado Actual (Secuencial)

**api-mobile - PR to Main:**
```
Job 1: Unit Tests         → 2 min
Job 2: Integration Tests  → 3 min (espera a Job 1)
Job 3: Lint               → 1 min (espera a Job 1)
Job 4: Security Scan      → 1 min (espera a Job 1)
Job 5: Summary            → 5s (espera a todos)

Tiempo total: ~7 minutos (secuencial con algunas paralelizaciones)
```

### Con Paralelismo Optimizado

```
                    ┌─ Unit Tests (2 min)
                    │
Checkout (10s) ────┼─ Integration Tests (3 min)
                    │
                    ├─ Lint (1 min)
                    │
                    └─ Security Scan (1 min)
                            ↓
                    Summary (5s)

Tiempo total: ~3.5 minutos (50% más rápido)
```

---

## 🚀 Estrategias de Paralelismo

### 1. Jobs Paralelos (Nivel Básico)

**Sin dependencias entre jobs:**

```yaml
jobs:
  # Estos 4 jobs se ejecutan EN PARALELO
  unit-tests:
    runs-on: ubuntu-latest
    # NO tiene "needs:", se ejecuta inmediatamente
    steps:
      - uses: actions/checkout@v4
      - run: make test-unit

  integration-tests:
    runs-on: ubuntu-latest
    # NO tiene "needs:", se ejecuta en paralelo con unit-tests
    steps:
      - uses: actions/checkout@v4
      - run: make test-integration

  lint:
    runs-on: ubuntu-latest
    # NO tiene "needs:", paralelo
    steps:
      - uses: actions/checkout@v4
      - run: golangci-lint run

  security:
    runs-on: ubuntu-latest
    # NO tiene "needs:", paralelo
    steps:
      - uses: actions/checkout@v4
      - run: gosec ./...

  # Este job ESPERA a que todos terminen
  summary:
    runs-on: ubuntu-latest
    needs: [unit-tests, integration-tests, lint, security]
    if: always()
    steps:
      - run: echo "Resumen de resultados"
```

**Ventaja:** Máximo paralelismo, tiempo = job más lento (no suma de todos)

---

### 2. Matrix Strategy (Paralelismo por Datos)

**Para tests modulares:**

```yaml
jobs:
  test-modules:
    runs-on: ubuntu-latest
    strategy:
      # fail-fast: false permite que otros módulos continúen si uno falla
      fail-fast: false
      # matrix define N jobs paralelos
      matrix:
        module:
          - handlers
          - services
          - repositories
          - domain
          - infrastructure
      # max-parallel: 5  # Opcional: limitar concurrencia
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Test ${{ matrix.module }}
        run: go test -v ./internal/${{ matrix.module }}/...
```

**Resultado:**
- 5 jobs corren en paralelo (uno por módulo)
- Tiempo = módulo más lento (no suma de todos)
- Si un módulo falla, otros continúan (con fail-fast: false)

---

### 3. Paralelismo por Tipo de Test

**Separar unit, integration, e2e:**

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        test-type:
          - unit
          - integration
          - e2e
        include:
          - test-type: unit
            command: make test-unit
            timeout: 5
          - test-type: integration
            command: make test-integration
            timeout: 10
          - test-type: e2e
            command: make test-e2e
            timeout: 15
    
    timeout-minutes: ${{ matrix.timeout }}
    
    steps:
      - uses: actions/checkout@v4
      - name: Run ${{ matrix.test-type }} tests
        run: ${{ matrix.command }}
```

---

### 4. Paralelismo Multi-Platform

**Para builds de producción:**

```yaml
jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        go: ['1.25']
        arch: [amd64, arm64]
    
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go }}
      
      - name: Build
        env:
          GOOS: ${{ matrix.os == 'ubuntu-latest' && 'linux' || 'darwin' }}
          GOARCH: ${{ matrix.arch }}
        run: go build -o bin/app-${{ matrix.os }}-${{ matrix.arch }} ./cmd/main.go
```

**Resultado:** 4 builds paralelos (2 OS × 2 arch)

---

## 🎯 Implementación para EduGo

### Propuesta 1: api-mobile - PR to Dev (Paralelo)

**Antes (actual):**
```yaml
jobs:
  unit-tests:
    # ...
  
  lint:
    # ...
  
  summary:
    needs: [unit-tests, lint]
```

**Después (optimizado):**
```yaml
jobs:
  # PARALELO: Estos 3 jobs corren simultáneamente
  unit-tests:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
        with:
          go-version: '1.25'
      - run: make test-unit

  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: golangci-lint run

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: gosec ./...

  # SECUENCIAL: Este espera a los 3 anteriores
  summary:
    needs: [unit-tests, lint, security]
    if: always()
    steps:
      - name: Generate summary
        # ...
```

**Mejora:** De ~3 min secuencial a ~2 min paralelo (33% más rápido)

---

### Propuesta 2: api-mobile - PR to Main (Paralelo + Matrix)

```yaml
jobs:
  # PARALELO NIVEL 1: Tests por módulo
  test-by-module:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      max-parallel: 5
      matrix:
        module:
          - handlers
          - services
          - repositories
          - domain
    
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - name: Test ${{ matrix.module }}
        run: go test -v -race ./internal/${{ matrix.module }}/...

  # PARALELO NIVEL 1: Tests de integración
  integration-tests:
    runs-on: ubuntu-latest
    if: |
      vars.ENABLE_AUTO_INTEGRATION == 'true' ||
      contains(github.event.pull_request.labels.*.name, 'run-integration')
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: make test-integration

  # PARALELO NIVEL 1: Lint
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: golangci-lint run

  # PARALELO NIVEL 1: Security
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: gosec ./...

  # PARALELO NIVEL 1: Coverage
  coverage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: make coverage-report
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  # NIVEL 2: Espera a todos
  summary:
    needs: [test-by-module, integration-tests, lint, security, coverage]
    if: always()
    steps:
      # ...
```

**Mejora:** De ~7 min a ~3 min (57% más rápido)

---

### Propuesta 3: shared - Tests Modulares Paralelos

**Actual (ya usa matrix):**
```yaml
jobs:
  test-modules:
    strategy:
      matrix:
        module: [common, logger, auth, middleware/gin, ...]
    # 7 jobs paralelos ✅ Ya optimizado
```

**Mejora adicional: Tests multi-versión Go:**

```yaml
jobs:
  test-compatibility:
    strategy:
      fail-fast: false
      matrix:
        go-version: ['1.24', '1.25']
        module: [common, logger, auth]
    
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
      - name: Test ${{ matrix.module }} with Go ${{ matrix.go-version }}
        working-directory: ${{ matrix.module }}
        run: go test -v ./...
```

**Resultado:** 6 jobs paralelos (2 versiones × 3 módulos core)  
**Beneficio:** Validación de compatibilidad multi-versión

---

### Propuesta 4: Docker Build Multi-Platform Paralelo

**Actual:**
```yaml
- uses: docker/build-push-action@v5
  with:
    platforms: linux/amd64,linux/arm64
    # Esto YA es paralelo internamente ✅
```

**Mejora: Cache entre jobs paralelos:**

```yaml
jobs:
  # PARALELO: Build por plataforma
  build-docker:
    strategy:
      matrix:
        platform: [linux/amd64, linux/arm64]
    steps:
      - uses: docker/setup-buildx-action@v3
      
      - uses: docker/build-push-action@v5
        with:
          platforms: ${{ matrix.platform }}
          # Cache compartido entre ambos jobs
          cache-from: type=gha,scope=build-${{ matrix.platform }}
          cache-to: type=gha,mode=max,scope=build-${{ matrix.platform }}
          # No push aún, solo build
          push: false
          tags: temp-${{ matrix.platform }}
  
  # SECUENCIAL: Merge manifests
  push-manifest:
    needs: build-docker
    steps:
      - name: Create and push manifest
        # Combinar las 2 imágenes en un manifest multi-arch
```

**Nota:** Para nuestro caso actual, buildx ya lo hace bien. Esta optimización es para cuando tengamos builds muy pesados (>10 min).

---

## 🎓 Conceptos de Paralelismo en GitHub Actions

### Nivel 1: Jobs Independientes (Más Simple)

```yaml
jobs:
  job-a:  # ←┐
  job-b:  # ├─ Estos 3 corren EN PARALELO
  job-c:  # ←┘
  
  job-d:
    needs: [job-a, job-b, job-c]  # Este espera a los 3
```

**Tiempo:** max(job-a, job-b, job-c) + job-d

---

### Nivel 2: Matrix Strategy (Paralelismo por Datos)

```yaml
jobs:
  test:
    strategy:
      matrix:
        module: [a, b, c, d, e]
    # GitHub crea 5 jobs paralelos automáticamente
```

**Límite:** GitHub permite hasta 256 jobs en matriz (pero 20 concurrentes en plan free)

---

### Nivel 3: Composite con Reutilización

```yaml
jobs:
  test-suite:
    strategy:
      matrix:
        suite: [unit, integration, e2e]
    steps:
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/run-tests@v1
        with:
          test-type: ${{ matrix.suite }}
```

---

### Nivel 4: Workflows Reusables Anidados

```yaml
jobs:
  tests:
    uses: ./.github/workflows/reusable/go-test.yml
    with:
      parallel: true  # El workflow reusable maneja paralelismo interno
  
  docker:
    uses: ./.github/workflows/reusable/docker-build.yml
    # Corre en paralelo con tests
```

---

## 📋 Implementación Práctica para EduGo

### Estructura Recomendada: PR to Dev

```yaml
name: CI - PR to Dev

on:
  pull_request:
    branches: [dev]

env:
  GO_VERSION: "1.25"

jobs:
  # ═══════════════════════════════════════════════
  # NIVEL 1: Jobs paralelos independientes
  # ═══════════════════════════════════════════════
  
  unit-tests:
    name: Unit Tests
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: go test -short -race ./...

  lint:
    name: Lint
    runs-on: ubuntu-latest
    timeout-minutes: 3
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: golangci-lint run --timeout=2m

  format-check:
    name: Format Check
    runs-on: ubuntu-latest
    timeout-minutes: 1
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ env.GO_VERSION }}
      - run: |
          if [ -n "$(gofmt -l .)" ]; then
            echo "❌ Código sin formatear"
            exit 1
          fi

  mod-check:
    name: Go Mod Tidy Check
    runs-on: ubuntu-latest
    timeout-minutes: 2
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: |
          go mod tidy
          git diff --exit-code go.mod go.sum

  # ═══════════════════════════════════════════════
  # NIVEL 2: Summary (espera a todos)
  # ═══════════════════════════════════════════════
  
  summary:
    name: Summary
    runs-on: ubuntu-latest
    needs: [unit-tests, lint, format-check, mod-check]
    if: always()
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            const results = {
              'Unit Tests': '${{ needs.unit-tests.result }}',
              'Lint': '${{ needs.lint.result }}',
              'Format': '${{ needs.format-check.result }}',
              'Go Mod': '${{ needs.mod-check.result }}'
            };
            
            let summary = '## 📊 Resultados CI\n\n';
            for (const [name, result] of Object.entries(results)) {
              const emoji = result === 'success' ? '✅' : '❌';
              summary += `${emoji} **${name}**: ${result}\n`;
            }
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: summary
            });
```

**Tiempo estimado:**
- Antes: ~4 min (secuencial)
- Después: ~2 min (paralelo) - **50% mejora**

---

### Estructura Recomendada: PR to Main

```yaml
name: CI - PR to Main

jobs:
  # ═══════════════════════════════════════════════
  # NIVEL 1: Tests paralelos por tipo
  # ═══════════════════════════════════════════════
  
  tests:
    strategy:
      fail-fast: false
      matrix:
        test-suite:
          - name: unit
            command: make test-unit
            timeout: 5
            cache-key: unit
          
          - name: integration
            command: make test-integration
            timeout: 15
            cache-key: integration
            needs-docker: true
    
    name: Tests - ${{ matrix.test-suite.name }}
    runs-on: ubuntu-latest
    timeout-minutes: ${{ matrix.test-suite.timeout }}
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: docker/setup-buildx-action@v3
        if: matrix.test-suite.needs-docker
      
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      
      - name: Run tests
        run: ${{ matrix.test-suite.command }}
      
      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-${{ matrix.test-suite.cache-key }}
          path: coverage/

  # NIVEL 1: Quality checks paralelos
  quality-checks:
    strategy:
      fail-fast: false
      matrix:
        check: [lint, format, security, mod-tidy]
    
    name: Quality - ${{ matrix.check }}
    runs-on: ubuntu-latest
    timeout-minutes: 5
    
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      
      - name: Run ${{ matrix.check }}
        run: make check-${{ matrix.check }}

  # NIVEL 2: Summary
  summary:
    needs: [tests, quality-checks]
    if: always()
    # ...
```

**Tiempo estimado:**
- Antes: ~7 min
- Después: ~3.5 min - **50% mejora**

---

### Propuesta: shared - Paralelismo Avanzado

**Actual (ya optimizado):**
```yaml
strategy:
  matrix:
    module: [common, logger, auth, ...]
# 7 jobs paralelos ✅
```

**Mejora: Agregar dimensión de Go version:**

```yaml
jobs:
  test-modules:
    strategy:
      fail-fast: false
      matrix:
        module: [common, logger, auth]
        go-version: ['1.24', '1.25']
    
    name: Test ${{ matrix.module }} (Go ${{ matrix.go-version }})
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
      - working-directory: ${{ matrix.module }}
        run: go test -v ./...
```

**Resultado:** 6 jobs paralelos (3 módulos × 2 versiones)  
**Beneficio:** Validación de compatibilidad automática

---

## 🎯 Paralelismo en Release Workflows

### Propuesta: Manual Release Paralelo

```yaml
jobs:
  # PARALELO: Validaciones
  validate:
    strategy:
      matrix:
        check: [tests, lint, build]
    name: Validate - ${{ matrix.check }}
    steps:
      - uses: actions/checkout@v4
        with:
          ref: main
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: make ${{ matrix.check }}

  # SECUENCIAL: Esperan validaciones
  create-tag:
    needs: validate
    steps:
      - name: Create and push tag
        # ...

  # PARALELO: Build multi-arch
  build-docker:
    needs: create-tag
    strategy:
      matrix:
        platform: [linux/amd64, linux/arm64]
    steps:
      - uses: docker/build-push-action@v5
        with:
          platforms: ${{ matrix.platform }}
          push: false
          outputs: type=docker,dest=/tmp/image-${{ matrix.platform }}.tar

  # SECUENCIAL: Merge y push
  push-multiarch:
    needs: build-docker
    steps:
      # docker manifest create y push
```

---

## 🚀 Implementación por Fases

### Fase 1: Paralelismo Básico (1 día)

**Implementar en api-mobile:**
- Jobs independientes en paralelo
- Separar lint, tests, security
- Sin cambios complejos

**Tiempo:** 2-3 horas  
**Mejora esperada:** 30-40%

---

### Fase 2: Matrix Strategies (2 días)

**Implementar en todos los Tipo A:**
- Tests por módulo/paquete
- Quality checks por tipo

**Tiempo:** 4-6 horas  
**Mejora esperada:** 50-60%

---

### Fase 3: Optimizaciones Avanzadas (1 semana)

**Implementar:**
- Cachés optimizados compartidos
- Workflows reusables con paralelismo
- Artifacts compartidos entre jobs
- Build multi-platform optimizado

**Tiempo:** 1 semana  
**Mejora esperada:** 70-80%

---

## 📊 Comparación de Tiempos Estimados

### api-mobile

| Workflow | Actual | Con Paralelismo | Mejora |
|----------|--------|-----------------|--------|
| PR to Dev | ~3 min | ~2 min | 33% |
| PR to Main | ~7 min | ~3.5 min | 50% |
| Manual Release | ~10 min | ~6 min | 40% |

### shared

| Workflow | Actual | Con Mejoras | Mejora |
|----------|--------|-------------|--------|
| CI | ~8 min | ~4 min | 50% |
| Tests | ~8 min | ~3 min | 62% |
| Release | ~15 min | ~8 min | 47% |

---

## 🎯 Configuración de Concurrencia

### Evitar Builds Redundantes

```yaml
# Al inicio de cada workflow
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

**Efecto:**
- Nuevo push cancela run anterior del mismo branch
- Ahorra tiempo y recursos
- Útil cuando se hacen múltiples pushes rápidos

**Ejemplo:**
```
Push 1 → CI empieza (2 min restantes)
Push 2 → CI anterior se cancela, nueva CI empieza
```

---

## 📋 Makefile Targets para Paralelismo Local

```makefile
# Ejecutar tests en paralelo localmente

.PHONY: test-parallel
test-parallel:
	@echo "🚀 Ejecutando tests en paralelo..."
	@go test -v -race -parallel=4 ./...

.PHONY: test-by-package
test-by-package:
	@echo "🚀 Tests por paquete en paralelo..."
	@go list ./... | xargs -n1 -P4 go test -v

.PHONY: lint-parallel
lint-parallel:
	@echo "🔍 Lint en paralelo..."
	@golangci-lint run --concurrency=4

.PHONY: ci-parallel
ci-parallel:
	@echo "🎯 CI completo en paralelo..."
	@$(MAKE) -j4 test-unit lint format-check mod-check
```

**Uso:**
```bash
# Tests en paralelo (4 workers)
make test-parallel

# CI completo en paralelo
make ci-parallel
```

---

## 🔧 Optimizaciones de Cache

### Cache Multinivel

```yaml
jobs:
  test:
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-go@v5
        with:
          go-version: '1.25'
          cache: true
          # Cache automático de:
          # - ~/.cache/go-build
          # - ~/go/pkg/mod
      
      - name: Cache golangci-lint
        uses: actions/cache@v4
        with:
          path: ~/.cache/golangci-lint
          key: golangci-lint-${{ hashFiles('go.sum') }}
      
      - name: Cache testcontainers
        uses: actions/cache@v4
        with:
          path: ~/.testcontainers
          key: testcontainers-${{ hashFiles('go.sum') }}
      
      - name: Download dependencies
        run: go mod download
```

**Beneficio:** De ~30s de setup a ~5s con cache hit

---

### Cache de Docker Layers

```yaml
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha,scope=${{ github.workflow }}
    cache-to: type=gha,mode=max,scope=${{ github.workflow }}
```

**Beneficio:** De ~5 min de build a ~1 min con cache

---

## 🎯 Implementación Recomendada

### Para api-mobile (Empezar aquí)

```yaml
# .github/workflows/pr-to-dev.yml
name: CI - PR to Dev

concurrency:
  group: ci-pr-dev-${{ github.ref }}
  cancel-in-progress: true

env:
  GO_VERSION: "1.25"

jobs:
  # Jobs paralelos
  unit-tests:
    # ...
  
  lint:
    # ...
  
  format:
    # ...
  
  mod-tidy:
    # ...

  # Summary
  summary:
    needs: [unit-tests, lint, format, mod-tidy]
    if: always()
    # ...
```

---

### Para shared (Mejorar actual)

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test-modules:
    strategy:
      fail-fast: false
      max-parallel: 10  # Aumentar de 7 default
      matrix:
        module: [common, logger, auth, ...]
    # ...
  
  # NUEVO: Compatibility matrix
  test-go-versions:
    strategy:
      matrix:
        go: ['1.24', '1.25']
        module: [common, logger, auth]  # Core modules
    # ...
```

---

## 📈 Benchmarks Esperados

### Pequeño (Estado Actual)

```
Código: ~10K líneas
Tests: ~100 tests
Tiempo secuencial: ~3 min
Tiempo paralelo: ~2 min
Mejora: 33%
```

### Mediano (6 meses)

```
Código: ~50K líneas
Tests: ~500 tests
Tiempo secuencial: ~10 min
Tiempo paralelo: ~4 min
Mejora: 60%
```

### Grande (1 año)

```
Código: ~100K líneas
Tests: ~1000 tests
Tiempo secuencial: ~20 min
Tiempo paralelo: ~6 min
Mejora: 70%
```

---

## 📋 Checklist de Implementación

### Fase 1: Setup (1 día)
- [ ] Implementar jobs paralelos en api-mobile
- [ ] Agregar concurrency control
- [ ] Separar lint, format, mod-check
- [ ] Probar localmente con act
- [ ] Crear PR y validar tiempos

### Fase 2: Matrix (2 días)
- [ ] Implementar matrix para tests por módulo
- [ ] Agregar compatibility matrix (Go versions)
- [ ] Optimizar shared con max-parallel
- [ ] Medir mejoras de tiempo

### Fase 3: Cache (3 días)
- [ ] Implementar cache multinivel
- [ ] Optimizar Docker cache
- [ ] Compartir artifacts entre jobs
- [ ] Benchmark final

---

## 💡 Tips de Paralelismo

### 1. fail-fast: false

```yaml
strategy:
  fail-fast: false  # No cancela otros jobs si uno falla
```

**Usar cuando:** Queremos ver TODOS los fallos, no solo el primero

---

### 2. max-parallel

```yaml
strategy:
  max-parallel: 5  # Máximo 5 jobs concurrentes
  matrix:
    item: [1,2,3,4,5,6,7,8,9,10]
```

**Usar cuando:** Limitamos recursos (ej: bases de datos compartidas)

---

### 3. timeout-minutes

```yaml
timeout-minutes: 5  # Matar job si pasa 5 min
```

**Usar siempre:** Evita jobs colgados que consumen minutos de GitHub

---

## 🎓 Ejemplo Completo: Workflow Paralelo Optimizado

```yaml
name: CI - Optimized Parallel

concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  GO_VERSION: "1.25"

jobs:
  # ═══ PARALELO NIVEL 1 ═══
  
  fast-checks:
    strategy:
      matrix:
        check:
          - {name: format, cmd: make check-format, timeout: 1}
          - {name: mod-tidy, cmd: make check-mod, timeout: 2}
          - {name: vet, cmd: go vet ./..., timeout: 2}
    
    name: ${{ matrix.check.name }}
    runs-on: ubuntu-latest
    timeout-minutes: ${{ matrix.check.timeout }}
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: ${{ matrix.check.cmd }}

  tests:
    strategy:
      fail-fast: false
      max-parallel: 3
      matrix:
        suite: [unit, integration, e2e]
    
    name: Tests - ${{ matrix.suite }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
      - run: make test-${{ matrix.suite }}

  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: golangci/golangci-lint-action@v6
        with:
          version: v1.64.7

  # ═══ PARALELO NIVEL 2 (después de tests) ═══
  
  coverage-report:
    needs: tests
    steps:
      - name: Download all coverage
        uses: actions/download-artifact@v4
      - name: Merge coverage
        # ...

  # ═══ FINAL ═══
  
  summary:
    needs: [fast-checks, tests, lint, coverage-report]
    if: always()
    # ...
```

---

## 📊 ROI de Paralelismo

### Inversión
- Tiempo setup: 1-2 días
- Complejidad: Media

### Retorno
- -50% tiempo de CI/CD
- Feedback más rápido para developers
- Mejor uso de runners concurrentes de GitHub
- Preparado para escalar

**ROI:** Alto (especialmente a largo plazo)

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025  
**Versión:** 1.0
