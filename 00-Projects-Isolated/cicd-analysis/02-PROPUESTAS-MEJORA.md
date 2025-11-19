# Propuestas de Mejora y Estandarización - CI/CD EduGo

**Fecha:** 19 de Noviembre, 2025  
**Versión:** 1.0  
**Estado:** Propuesta para Revisión

---

## 🎯 Objetivos de la Estandarización

1. **Reducir duplicación** de código en workflows (~70% actual → <20% objetivo)
2. **Estandarizar herramientas** y versiones en todo el ecosistema
3. **Unificar estrategias** de Docker builds y versionado
4. **Resolver fallos recurrentes** en workflows
5. **Centralizar configuración** común usando edugo-infrastructure

---

## 📋 Plan de Implementación por Fases

### Fase 1: CRÍTICO - Resolver Fallos Actuales (Inmediato)
**Duración estimada:** 1-2 días  
**Impacto:** Alto  
**Prioridad:** 🔴 Máxima

### Fase 2: Estandarización Base (Corto plazo)
**Duración estimada:** 3-5 días  
**Impacto:** Alto  
**Prioridad:** 🟡 Alta

### Fase 3: Centralización y Reusabilidad (Mediano plazo)
**Duración estimada:** 1-2 semanas  
**Impacto:** Medio-Alto  
**Prioridad:** 🟢 Media

### Fase 4: Optimización Avanzada (Largo plazo)
**Duración estimada:** 2-3 semanas  
**Impacto:** Medio  
**Prioridad:** 🔵 Baja

---

## 🔴 FASE 1: Resolver Fallos Críticos

### 1.1 Investigar y Resolver Fallos en infrastructure

**Problema:**
```
Tasa de fallo: 80% (8/10 últimos runs)
Último fallo: 2025-11-18T22:55:53Z
```

**Acción:**
```bash
# 1. Obtener logs del último fallo
gh api repos/EduGoGroup/edugo-infrastructure/actions/runs/19483248827/jobs \
  --jq '.jobs[] | select(.conclusion == "failure") | {name, steps}'

# 2. Identificar el step exacto que falla
# 3. Reproducir localmente
cd /path/to/edugo-infrastructure
make test  # o equivalente

# 4. Corregir el problema
# 5. Crear PR con fix
```

**Posibles causas y soluciones:**

**Causa 1:** Compilación de CLIs fallando
```yaml
# Solución: Actualizar dependencias
- name: Actualizar go.mod
  run: |
    cd postgres && go mod tidy
    cd ../mongodb && go mod tidy
```

**Causa 2:** Tests fallando por timeout
```yaml
# Solución: Aumentar timeout
- name: Run tests
  run: go test -v -timeout=5m ./...
```

**Causa 3:** Dependencias privadas no accesibles
```yaml
# Solución: Verificar GOPRIVATE
- name: Configurar acceso
  run: |
    git config --global url."https://${{ secrets.GITHUB_TOKEN }}@github.com/".insteadOf "https://github.com/"
  env:
    GOPRIVATE: github.com/EduGoGroup/*
```

**Entregable:** PR que corrija los fallos con tests pasando.

---

### 1.2 Resolver Fallos en release.yml (api-administracion, worker)

**Problema:**
```
api-administracion: Run 19485500426 - failure
worker: Run 19485700108 - failure
```

**Acción:**
```bash
# 1. Ver logs detallados
gh run view 19485500426 --repo EduGoGroup/edugo-api-administracion --log-failed

# 2. Identificar step fallido
# 3. Reproducir localmente si es posible
```

**Posibles causas:**

**Causa 1:** Docker build fallando
```yaml
# Verificar Dockerfile
# Verificar build-args
# Verificar permisos de registry
```

**Causa 2:** Tests fallando en release
```yaml
# Solución: Asegurar que tests pasen antes de release
# Agregar validación previa
```

**Causa 3:** Changelog o version.txt faltantes
```yaml
# Solución: Crear archivos si no existen
- name: Crear archivos si faltan
  run: |
    [ ! -f ".github/version.txt" ] && echo "0.1.0" > .github/version.txt
    [ ! -f "CHANGELOG.md" ] && cp templates/CHANGELOG.template.md CHANGELOG.md
```

**Entregable:** Release exitoso o workflow deshabilitado si no se usa.

---

### 1.3 Corregir "Fallos Fantasma" en shared

**Problema:**
```yaml
# test.yml se ejecuta en push aunque no debería
on:
  workflow_dispatch:
  pull_request:
    branches: [ main, dev ]
# GitHub intenta ejecutarlo en push de todas formas
```

**Solución:**
```yaml
jobs:
  test-coverage:
    name: Coverage ${{ matrix.module }}
    runs-on: ubuntu-latest
    # Agregar condición explícita
    if: github.event_name != 'push'
    strategy:
      ...
```

**Entregable:** PR en edugo-shared eliminando fallos fantasma.

---

## 🟡 FASE 2: Estandarización Base

### 2.1 Unificar Versiones de Go

**Estado actual:**
```
api-mobile: 1.24
api-administracion: 1.24
worker: 1.25 ⚠️
shared: 1.25
infrastructure: 1.24
```

**Decisión requerida:**

**Opción A: Estandarizar en Go 1.24**
- ✅ Más conservador
- ✅ Ya usado en mayoría
- ❌ No aprovecha mejoras de 1.25

**Opción B: Migrar todos a Go 1.25**
- ✅ Versión más reciente
- ✅ Ya usado en worker y shared
- ⚠️ Requiere testing de compatibilidad

**Recomendación:** **Opción B - Go 1.25**

**Implementación:**
```yaml
# Crear variable central en edugo-infrastructure
# /.github/workflows/config/versions.json
{
  "go_version": "1.25",
  "golangci_lint_version": "v1.64.7",
  "docker_buildx_version": "v3"
}
```

**Migración:**
1. Actualizar `GO_VERSION: "1.25"` en todos los workflows
2. Probar build y tests en cada proyecto
3. Crear PRs individuales
4. Merge coordinado

**Entregable:** Todos los proyectos en Go 1.25.

---

### 2.2 Estandarizar Versiones de GitHub Actions

**Estado actual:**
```
actions/checkout: v4 (mayoría), v5 (infrastructure)
actions/setup-go: v5 (mayoría), v6 (infrastructure)
```

**Decisión:** Migrar todos a las versiones más recientes estables.

**Estándar propuesto:**
```yaml
actions/checkout@v4
actions/setup-go@v5
docker/setup-buildx-action@v3
docker/login-action@v3
docker/build-push-action@v5
docker/metadata-action@v5
actions/upload-artifact@v4
actions/github-script@v7
golangci/golangci-lint-action@v6
```

**Nota:** Usar v4/v5/v6 en lugar de v4.1.2 para recibir patches automáticos.

**Entregable:** Documento de versiones estándar + PRs de actualización.

---

### 2.3 Unificar Umbrales de Cobertura

**Estado actual:**
```
api-mobile: 33%
api-administracion: 33%
worker: No definido
shared: No definido
```

**Propuesta:**

**Para Tipo A (APIs y Worker):**
```yaml
env:
  COVERAGE_THRESHOLD: 33
  ENABLE_COVERAGE_CHECK: true
```

**Para Tipo B (Shared):**
```yaml
# Por módulo individual
env:
  COVERAGE_THRESHOLD_COMMON: 50
  COVERAGE_THRESHOLD_LOGGER: 60
  COVERAGE_THRESHOLD_AUTH: 40
  # ... resto de módulos
```

**Implementación:**
1. Agregar threshold a worker
2. Agregar thresholds por módulo a shared
3. Implementar script `check-coverage.sh` común

**Entregable:** Todos los proyectos con umbral de cobertura definido y validado.

---

### 2.4 Estandarizar Nombres de Workflows

**Convención propuesta:**

| Propósito | Nombre Estándar |
|-----------|----------------|
| CI en PR a dev | `CI - PR to Dev` |
| CI en PR a main | `CI - PR to Main` |
| CI genérico | `CI Pipeline` |
| Tests manuales | `Tests - Manual` |
| Release manual | `Release - Manual` |
| Release automático | `Release - Automated` |
| Sincronización | `Sync - Main to Dev` |
| Docker build manual | `Docker - Build and Push` |

**Implementación:**
```yaml
# En cada workflow
name: CI - PR to Dev  # ← Estandarizar aquí
```

**Entregable:** Todos los workflows con nombres consistentes.

---

## 🟢 FASE 3: Centralización y Reusabilidad

### 3.1 Crear Repositorio de Workflows Reusables

**Estructura propuesta en edugo-infrastructure:**

```
edugo-infrastructure/
├── .github/
│   ├── workflows/
│   │   ├── reusable/
│   │   │   ├── go-test.yml          # Workflow reusable para tests Go
│   │   │   ├── go-lint.yml          # Workflow reusable para lint
│   │   │   ├── docker-build.yml     # Workflow reusable para Docker
│   │   │   ├── sync-branches.yml    # Workflow reusable para sync
│   │   │   └── release.yml          # Workflow reusable para releases
│   │   └── actions/
│   │       ├── setup-edugo-go/      # Composite action
│   │       │   └── action.yml
│   │       ├── docker-build-edugo/  # Composite action
│   │       │   └── action.yml
│   │       └── coverage-check/      # Composite action
│   │           └── action.yml
│   └── config/
│       └── versions.json            # Versiones centralizadas
```

---

### 3.2 Composite Action: setup-edugo-go

**Propósito:** Centralizar setup de Go + configuración de repos privados.

**Archivo:** `.github/actions/setup-edugo-go/action.yml`

```yaml
name: 'Setup EduGo Go Environment'
description: 'Configura Go con versión estándar y acceso a repos privados'

inputs:
  go-version:
    description: 'Versión de Go (default: 1.25)'
    required: false
    default: '1.25'
  
  cache:
    description: 'Habilitar cache de Go'
    required: false
    default: 'true'

runs:
  using: 'composite'
  steps:
    - name: Setup Go
      uses: actions/setup-go@v5
      with:
        go-version: ${{ inputs.go-version }}
        cache: ${{ inputs.cache }}
    
    - name: Configurar acceso a repos privados
      shell: bash
      run: |
        git config --global url."https://${{ github.token }}@github.com/".insteadOf "https://github.com/"
      env:
        GOPRIVATE: github.com/EduGoGroup/*
    
    - name: Verificar configuración
      shell: bash
      run: |
        echo "✓ Go version: $(go version)"
        echo "✓ GOPRIVATE: $GOPRIVATE"
```

**Uso en workflows:**
```yaml
steps:
  - uses: actions/checkout@v4
  
  - name: Setup Go
    uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@main
    # O con versión específica:
    # uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
```

**Beneficio:** Reemplaza ~15 líneas de código repetido en cada workflow.

---

### 3.3 Composite Action: docker-build-edugo

**Propósito:** Estandarizar builds de Docker con configuración común.

**Archivo:** `.github/actions/docker-build-edugo/action.yml`

```yaml
name: 'Build and Push EduGo Docker Image'
description: 'Build Docker con configuración estándar EduGo'

inputs:
  image-name:
    description: 'Nombre de la imagen (ej: edugogroup/edugo-api-mobile)'
    required: true
  
  tag-strategy:
    description: 'Estrategia de tags: semver, branch, manual'
    required: true
    default: 'semver'
  
  version:
    description: 'Versión (para semver)'
    required: false
  
  platforms:
    description: 'Plataformas (ej: linux/amd64,linux/arm64)'
    required: false
    default: 'linux/amd64'
  
  push:
    description: 'Push a registry'
    required: false
    default: 'true'

runs:
  using: 'composite'
  steps:
    - name: Setup Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Login a GHCR
      uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ github.token }}
    
    - name: Generate tags (semver)
      if: inputs.tag-strategy == 'semver'
      id: meta-semver
      uses: docker/metadata-action@v5
      with:
        images: ghcr.io/${{ inputs.image-name }}
        tags: |
          type=semver,pattern={{version}},value=${{ inputs.version }}
          type=semver,pattern={{major}}.{{minor}},value=${{ inputs.version }}
          type=raw,value=latest
    
    - name: Generate tags (branch)
      if: inputs.tag-strategy == 'branch'
      id: meta-branch
      uses: docker/metadata-action@v5
      with:
        images: ghcr.io/${{ inputs.image-name }}
        tags: |
          type=ref,event=branch
          type=sha,prefix={{branch}}-
    
    - name: Build and Push
      uses: docker/build-push-action@v5
      with:
        context: .
        platforms: ${{ inputs.platforms }}
        push: ${{ inputs.push }}
        tags: ${{ steps.meta-semver.outputs.tags || steps.meta-branch.outputs.tags }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

**Uso:**
```yaml
- name: Build Docker
  uses: EduGoGroup/edugo-infrastructure/.github/actions/docker-build-edugo@main
  with:
    image-name: edugogroup/edugo-api-mobile
    tag-strategy: semver
    version: ${{ steps.version.outputs.version }}
    platforms: linux/amd64,linux/arm64
```

---

### 3.4 Workflow Reusable: sync-branches.yml

**Propósito:** Centralizar lógica de sincronización main → dev.

**Archivo:** `.github/workflows/reusable/sync-branches.yml`

```yaml
name: Sync Branches (Reusable)

on:
  workflow_call:
    inputs:
      source-branch:
        description: 'Rama origen'
        required: false
        type: string
        default: 'main'
      
      target-branch:
        description: 'Rama destino'
        required: false
        type: string
        default: 'dev'
      
      version-file:
        description: 'Archivo de versión (opcional)'
        required: false
        type: string
        default: '.github/version.txt'

permissions:
  contents: write

jobs:
  sync:
    name: Sync ${{ inputs.source-branch }} → ${{ inputs.target-branch }}
    runs-on: ubuntu-latest
    if: "!contains(github.event.head_commit.message, 'chore: sync')"
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          ref: ${{ inputs.source-branch }}
      
      - name: Obtener versión
        id: version
        run: |
          if [ -f "${{ inputs.version-file }}" ]; then
            VERSION=$(cat ${{ inputs.version-file }})
            echo "version=$VERSION" >> $GITHUB_OUTPUT
          else
            echo "version=unknown" >> $GITHUB_OUTPUT
          fi
      
      - name: Verificar si target existe
        id: check_target
        run: |
          if git ls-remote --heads origin ${{ inputs.target-branch }} | grep -q ${{ inputs.target-branch }}; then
            echo "exists=true" >> $GITHUB_OUTPUT
          else
            echo "exists=false" >> $GITHUB_OUTPUT
          fi
      
      - name: Crear target si no existe
        if: steps.check_target.outputs.exists == 'false'
        run: |
          git checkout -b ${{ inputs.target-branch }}
          git push -u origin ${{ inputs.target-branch }}
      
      - name: Verificar diferencias
        id: check_diff
        run: |
          git fetch origin ${{ inputs.target-branch }}
          COMMITS_AHEAD=$(git rev-list --count origin/${{ inputs.target-branch }}..origin/${{ inputs.source-branch }})
          if [ "$COMMITS_AHEAD" -eq 0 ]; then
            echo "has_diff=false" >> $GITHUB_OUTPUT
          else
            echo "has_diff=true" >> $GITHUB_OUTPUT
            echo "commits=$COMMITS_AHEAD" >> $GITHUB_OUTPUT
          fi
      
      - name: Merge
        if: steps.check_diff.outputs.has_diff == 'true'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          
          git checkout ${{ inputs.target-branch }}
          git pull origin ${{ inputs.target-branch }}
          
          if git merge origin/${{ inputs.source-branch }} --no-ff -m "chore: sync ${{ inputs.source-branch }} to ${{ inputs.target-branch }}

          Sincronización automática.

          🤖 Generated with Claude Code"; then
            git push origin ${{ inputs.target-branch }}
            echo "✅ Merge exitoso"
          else
            echo "❌ Conflictos detectados"
            git merge --abort
            exit 1
          fi
```

**Uso en cada proyecto:**
```yaml
# .github/workflows/sync-main-to-dev.yml
name: Sync Main to Dev

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  sync:
    uses: EduGoGroup/edugo-infrastructure/.github/workflows/reusable/sync-branches.yml@main
    # Opcional: con parámetros custom
    # with:
    #   source-branch: main
    #   target-branch: develop
```

**Beneficio:** Elimina ~100 líneas de código duplicado en 6 repos.

---

### 3.5 Workflow Reusable: go-test.yml

**Archivo:** `.github/workflows/reusable/go-test.yml`

```yaml
name: Go Tests (Reusable)

on:
  workflow_call:
    inputs:
      go-version:
        description: 'Versión de Go'
        required: false
        type: string
        default: '1.25'
      
      test-type:
        description: 'Tipo de test: unit, integration, all'
        required: false
        type: string
        default: 'unit'
      
      coverage-threshold:
        description: 'Umbral de cobertura (%)'
        required: false
        type: number
        default: 33
      
      enable-coverage-check:
        description: 'Validar umbral de cobertura'
        required: false
        type: boolean
        default: true
      
      working-directory:
        description: 'Directorio de trabajo'
        required: false
        type: string
        default: '.'

jobs:
  test:
    name: Tests
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Go
        uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@main
        with:
          go-version: ${{ inputs.go-version }}
      
      - name: Download dependencies
        working-directory: ${{ inputs.working-directory }}
        run: go mod download
      
      - name: Run unit tests
        if: inputs.test-type == 'unit' || inputs.test-type == 'all'
        working-directory: ${{ inputs.working-directory }}
        run: go test -v -race -coverprofile=coverage.out ./...
      
      - name: Check coverage
        if: inputs.enable-coverage-check
        working-directory: ${{ inputs.working-directory }}
        run: |
          COVERAGE=$(go tool cover -func=coverage.out | tail -1 | awk '{print $NF}' | sed 's/%//')
          echo "Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < ${{ inputs.coverage-threshold }}" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% is below threshold ${{ inputs.coverage-threshold }}%"
            exit 1
          fi
      
      - name: Upload coverage
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: ${{ inputs.working-directory }}/coverage.out
```

**Uso:**
```yaml
jobs:
  test:
    uses: EduGoGroup/edugo-infrastructure/.github/workflows/reusable/go-test.yml@main
    with:
      go-version: '1.25'
      test-type: 'all'
      coverage-threshold: 33
```

---

### 3.6 Eliminar Workflows Duplicados

**Problema identificado:**

**worker tiene 3 workflows construyendo Docker:**
1. `build-and-push.yml`
2. `docker-only.yml`
3. `release.yml`

**api-administracion tiene 2:**
1. `build-and-push.yml`
2. `release.yml`

**Propuesta de consolidación:**

**Para TODOS los proyectos Tipo A:**

```
Mantener SOLO:
1. release.yml (automático en tag) - Usa workflow reusable
2. manual-release.yml (manual desde UI) - Usa composite action

Eliminar:
- build-and-push.yml
- docker-only.yml
```

**Estrategia unificada:**

| Escenario | Workflow | Trigger | Tags Generados |
|-----------|----------|---------|----------------|
| Release production | `release.yml` | Push tag v* | semver (1.0.0, 1.0, 1), latest |
| Release manual (dev/staging) | `manual-release.yml` | Workflow dispatch | environment, sha |
| PR testing | NO build Docker | N/A | N/A |

**Implementación:**
1. Crear PR eliminando workflows duplicados
2. Probar release manual
3. Probar release automático
4. Merge

**Entregable:** Cada proyecto con máximo 2 workflows de Docker.

---

## 🔵 FASE 4: Optimización Avanzada

### 4.1 Implementar GitHub App en Todos los Proyectos

**Estado actual:**
- ✅ api-mobile: Usa GitHub App
- ❌ Resto: Usa GITHUB_TOKEN

**Problema con GITHUB_TOKEN:**
No dispara workflows subsecuentes (sync-main-to-dev no se ejecuta automáticamente después de release).

**Solución:**

1. **Crear GitHub App a nivel organización** (si no existe)
2. **Configurar secrets a nivel organización:**
   - `APP_ID`
   - `APP_PRIVATE_KEY`
3. **Actualizar todos los workflows de release:**

```yaml
jobs:
  create-release:
    steps:
      - name: Generar token desde GitHub App
        id: generate_token
        uses: actions/create-github-app-token@v2.1.4
        with:
          app-id: ${{ secrets.APP_ID }}
          private-key: ${{ secrets.APP_PRIVATE_KEY }}
      
      - name: Checkout
        uses: actions/checkout@v4
        with:
          token: ${{ steps.generate_token.outputs.token }}
      
      # Resto del workflow usa el token de la app
```

**Entregable:** Todos los proyectos usando GitHub App tokens.

---

### 4.2 Implementar PR Automáticos para Releases

**Concepto:** En lugar de push directo a main en releases, crear PR automático.

**Beneficios:**
- ✅ Permite review antes de release
- ✅ CI/CD valida antes de merge
- ✅ Más seguro

**Implementación:**

```yaml
# En manual-release.yml
jobs:
  create-release-pr:
    steps:
      # ... preparar cambios (version.txt, CHANGELOG)
      
      - name: Crear rama de release
        run: |
          git checkout -b release/v${{ inputs.version }}
          git add .github/version.txt CHANGELOG.md
          git commit -m "chore: prepare release v${{ inputs.version }}"
          git push origin release/v${{ inputs.version }}
      
      - name: Crear PR
        env:
          GH_TOKEN: ${{ steps.generate_token.outputs.token }}
        run: |
          gh pr create \
            --base main \
            --head release/v${{ inputs.version }} \
            --title "Release v${{ inputs.version }}" \
            --body "$(cat /tmp/changelog.md)" \
            --label "release"
      
      # El tag se crea DESPUÉS de merge del PR
```

**Decisión requerida:** ¿Implementar para todos o solo algunos proyectos?

---

### 4.3 Monitoreo y Alertas de Salud de CI/CD

**Propuesta:** Dashboard centralizado de salud de workflows.

**Opción 1: GitHub Status Badges en README**

```markdown
# edugo-api-mobile

![CI Status](https://img.shields.io/github/actions/workflow/status/EduGoGroup/edugo-api-mobile/ci.yml?branch=main)
![Coverage](https://img.shields.io/codecov/c/github/EduGoGroup/edugo-api-mobile)
![Release](https://img.shields.io/github/v/release/EduGoGroup/edugo-api-mobile)
```

**Opción 2: Workflow de Monitoreo**

Crear workflow en edugo-infrastructure que:
1. Consulta estado de todos los workflows de todos los repos
2. Genera reporte
3. Envía alerta si tasa de fallo > 30%

```yaml
# .github/workflows/monitor-health.yml
name: Monitor CI/CD Health

on:
  schedule:
    - cron: '0 9 * * 1'  # Lunes 9am
  workflow_dispatch:

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - name: Check workflow health
        run: |
          # Para cada repo
          for repo in api-mobile api-administracion worker shared infrastructure; do
            gh api repos/EduGoGroup/edugo-$repo/actions/runs \
              --jq '.workflow_runs[:20] | group_by(.conclusion) | map({conclusion: .[0].conclusion, count: length})'
          done
      
      - name: Generate report
        run: # Generar markdown con estadísticas
      
      - name: Create issue if unhealthy
        if: # Tasa de fallo > umbral
        run: |
          gh issue create \
            --title "⚠️ CI/CD Health Alert" \
            --body "$(cat report.md)" \
            --label "devops,alert"
```

---

### 4.4 Caché Optimizado para Dependencias Go

**Estado actual:** Todos usan cache básico de setup-go.

**Mejora:** Caché multicapa con restore-keys.

```yaml
- name: Setup Go with Advanced Cache
  uses: actions/setup-go@v5
  with:
    go-version: '1.25'
    cache: true
    cache-dependency-path: |
      go.sum
      **/go.sum  # Para repos con múltiples módulos
```

**Beneficio:** Reducción de tiempo de setup de ~30s a ~5s.

---

### 4.5 Matrix Strategy para Tests Multiplataforma

**Propuesta:** Probar en múltiples plataformas.

```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        go: ['1.24', '1.25']
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go }}
      - run: go test ./...
```

**Decisión:** ¿Solo para shared o también para APIs?

---

## 📊 Matriz de Decisiones

| Propuesta | Impacto | Esfuerzo | Prioridad | Decisión Requerida |
|-----------|---------|----------|-----------|-------------------|
| Resolver fallos infrastructure | Alto | Bajo | Máxima | ❌ No - Acción inmediata |
| Unificar Go 1.25 | Alto | Bajo | Alta | ✅ Sí - ¿1.24 o 1.25? |
| Composite actions | Alto | Medio | Alta | ❌ No - Implementar |
| Workflows reusables | Alto | Medio | Media | ❌ No - Implementar |
| Eliminar Docker duplicados | Medio | Bajo | Alta | ✅ Sí - ¿Qué workflows mantener? |
| GitHub App en todos | Medio | Bajo | Media | ❌ No - Implementar |
| PR automáticos para release | Bajo | Alto | Baja | ✅ Sí - ¿Para todos o solo algunos? |
| Monitoreo salud CI/CD | Bajo | Medio | Baja | ✅ Sí - ¿Opción 1 o 2? |
| Matrix multiplataforma | Bajo | Bajo | Baja | ✅ Sí - ¿Para qué proyectos? |

---

## 🎯 Roadmap Sugerido

### Semana 1
- ✅ Día 1-2: FASE 1 completa (resolver fallos)
- ✅ Día 3-4: Estandarizar versiones (Go, actions)
- ✅ Día 5: Estandarizar nombres y umbrales

### Semana 2
- ✅ Día 1-2: Crear composite actions
- ✅ Día 3-4: Crear workflows reusables
- ✅ Día 5: Eliminar workflows duplicados

### Semana 3
- ✅ Día 1-2: Migrar proyectos a usar reusables
- ✅ Día 3-4: Testing y validación
- ✅ Día 5: Documentación y capacitación

### Semana 4 (Opcional)
- ✅ Implementar GitHub App en todos
- ✅ Configurar monitoreo
- ✅ Optimizaciones avanzadas

---

## 📝 Checklist de Implementación

### Fase 1: Crítico
- [ ] Investigar logs de fallos en infrastructure
- [ ] Corregir fallos en infrastructure (PR)
- [ ] Investigar fallos en release.yml (api-admin, worker)
- [ ] Corregir o deshabilitar releases fallidos
- [ ] Eliminar "fallos fantasma" en shared

### Fase 2: Estandarización
- [ ] Decidir versión Go estándar (1.24 o 1.25)
- [ ] Actualizar GO_VERSION en todos los workflows
- [ ] Estandarizar versiones de actions
- [ ] Agregar umbrales de cobertura faltantes
- [ ] Renombrar workflows con convención estándar
- [ ] Crear documento de estándares

### Fase 3: Centralización
- [ ] Crear estructura en edugo-infrastructure
- [ ] Implementar setup-edugo-go composite action
- [ ] Implementar docker-build-edugo composite action
- [ ] Implementar sync-branches workflow reusable
- [ ] Implementar go-test workflow reusable
- [ ] Eliminar workflows duplicados de Docker
- [ ] Migrar api-mobile a usar reusables
- [ ] Migrar api-administracion a usar reusables
- [ ] Migrar worker a usar reusables
- [ ] Migrar shared a usar reusables
- [ ] Testing completo de workflows

### Fase 4: Optimización (Opcional)
- [ ] Configurar GitHub App organizacional
- [ ] Migrar todos a GitHub App tokens
- [ ] Decidir sobre PR automáticos para releases
- [ ] Implementar monitoreo de salud CI/CD
- [ ] Optimizar cachés
- [ ] Configurar matrix multiplataforma

---

## 🚀 Beneficios Esperados

### Cuantitativos
- 📉 **-70% código duplicado** en workflows
- ⏱️ **-30% tiempo de setup** (con cachés optimizados)
- 📊 **+40% tasa de éxito** (resolviendo fallos actuales)
- 🔄 **-50% tiempo de mantenimiento** (reusables centralizados)

### Cualitativos
- ✅ Mantenimiento más fácil
- ✅ Onboarding más rápido para nuevos devs
- ✅ Consistencia en todo el ecosistema
- ✅ Menos errores por configuración incorrecta
- ✅ Mejor visibilidad de salud del proyecto

---

## 📚 Documentación Requerida

1. **Guía de Workflows** - Explicar cada workflow y cuándo se usa
2. **Guía de Contribución CI/CD** - Cómo modificar workflows
3. **Troubleshooting** - Problemas comunes y soluciones
4. **ADR (Architecture Decision Record)** - Decisiones tomadas y por qué

---

**Próximos pasos:** Revisar propuestas con el equipo y priorizar implementación.

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025
