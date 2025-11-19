# Informe Detallado de Duplicidades - CI/CD EduGo

**Fecha:** 19 de Noviembre, 2025  
**Propósito:** Identificar código duplicado exacto en workflows

---

## 📊 Resumen de Duplicación

| Categoría | Líneas Totales | Líneas Duplicadas | % Duplicación |
|-----------|----------------|-------------------|---------------|
| Setup Go | ~120 | ~120 | 100% |
| Acceso repos privados | ~60 | ~60 | 100% |
| Sync main-to-dev | ~600 | ~576 | 96% |
| Docker build steps | ~300 | ~270 | 90% |
| Coverage checks | ~150 | ~120 | 80% |
| PR comments | ~200 | ~160 | 80% |
| **TOTAL** | **~1,430** | **~1,306** | **~91%** |

---

## 🔄 Bloque 1: Setup Go + GOPRIVATE (100% duplicado)

### Ocurrencias: 23 veces en 6 repositorios

**Código exacto repetido:**

```yaml
- name: 🔧 Setup Go
  uses: actions/setup-go@v5
  with:
    go-version: ${{ env.GO_VERSION }}
    cache: true

- name: 🔐 Configurar acceso a repos privados
  run: |
    git config --global url."https://${{ secrets.GITHUB_TOKEN }}@github.com/".insteadOf "https://github.com/"
  env:
    GOPRIVATE: github.com/EduGoGroup/*
```

**Encontrado en:**

| Proyecto | Workflow | Líneas |
|----------|----------|--------|
| api-mobile | pr-to-dev.yml | 18-27 |
| api-mobile | pr-to-main.yml | 18-27 |
| api-mobile | test.yml | 24-33 |
| api-mobile | manual-release.yml | N/A (no usa) |
| api-administracion | pr-to-dev.yml | 18-27 |
| api-administracion | test.yml | 24-33 |
| api-administracion | build-and-push.yml | 23-32 |
| api-administracion | release.yml | 23-32 |
| worker | ci.yml | 18-27 |
| worker | build-and-push.yml | N/A |
| worker | release.yml | 23-32 |
| shared | ci.yml | 23-32 (×7 en matriz) |
| shared | test.yml | 18-27 (×7 en matriz) |
| shared | release.yml | 23-32 (×7 en matriz) |
| infrastructure | ci.yml | 14-23 |

**Estimación:** ~23 ocurrencias × 10 líneas = **230 líneas duplicadas**

**Solución propuesta:**

```yaml
# Composite action: setup-edugo-go
- uses: EduGoGroup/edugo-infrastructure/.github/actions/setup-edugo-go@v1
```

**Ahorro:** 230 líneas → 23 líneas = **207 líneas eliminadas (90%)**

---

## 🔄 Bloque 2: Sync Main to Dev (96% duplicado)

### Ocurrencias: 6 workflows idénticos

**Código duplicado (versión completa - 100 líneas):**

```yaml
name: Sync Main to Dev

on:
  push:
    branches: [main]
    tags:
      - 'v*'

permissions:
  contents: write
  pull-requests: write

jobs:
  sync:
    name: Create PR to sync main → dev
    runs-on: ubuntu-latest
    if: "!contains(github.event.head_commit.message, 'chore: sync')"

    steps:
      - name: Checkout código
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          ref: main

      - name: Obtener versión actual
        id: version
        run: |
          if [ -f ".github/version.txt" ]; then
            VERSION=$(cat .github/version.txt)
            echo "version=$VERSION" >> $GITHUB_OUTPUT
            echo "📌 Versión actual: v$VERSION"
          else
            echo "version=unknown" >> $GITHUB_OUTPUT
          fi

      - name: Verificar si dev existe
        id: check_dev
        run: |
          if git ls-remote --heads origin dev | grep -q dev; then
            echo "exists=true" >> $GITHUB_OUTPUT
            echo "✓ Rama dev existe"
          else
            echo "exists=false" >> $GITHUB_OUTPUT
            echo "⚠️  Rama dev no existe, se creará"
          fi

      - name: Crear rama dev si no existe
        if: steps.check_dev.outputs.exists == 'false'
        run: |
          git checkout -b dev
          git push -u origin dev
          echo "✓ Rama dev creada"

      - name: Verificar si hay commits en main que dev no tiene
        id: check_diff
        run: |
          git fetch origin dev

          # Contar commits en main que dev NO tiene
          COMMITS_AHEAD=$(git rev-list --count origin/dev..origin/main)

          if [ "$COMMITS_AHEAD" -eq 0 ]; then
            echo "has_diff=false" >> $GITHUB_OUTPUT
            echo "✓ main y dev están sincronizados ($COMMITS_AHEAD commits)"
          else
            echo "has_diff=true" >> $GITHUB_OUTPUT
            echo "⚠️  main tiene $COMMITS_AHEAD commits que dev no tiene"
            echo "Commits a sincronizar:"
            git log --oneline origin/dev..origin/main
          fi

      - name: Merge main to dev con manejo de conflictos
        if: steps.check_diff.outputs.has_diff == 'true'
        run: |
          VERSION="${{ steps.version.outputs.version }}"

          # Configurar git
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          # Checkout dev y actualizar primero (minimizar conflictos)
          git checkout dev
          git pull origin dev

          echo "🔄 Intentando merge de main a dev..."

          # Intentar merge
          if git merge origin/main --no-ff -m "chore: sync main v$VERSION to dev

          Sincronización automática de main a dev después de cambios en main.

          🤖 Generated with [Claude Code](https://claude.com/claude-code)

          Co-Authored-By: Claude <noreply@anthropic.com>"; then
            # Merge exitoso
            git push origin dev
            echo "✅ Sincronización exitosa: main → dev"
          else
            # Merge falló (conflictos)
            echo "❌ ERROR: Conflictos detectados en merge main → dev"
            echo "::error::Conflictos requieren resolución manual"
            echo "::error::Archivos en conflicto:"
            git status --short
            git merge --abort
            exit 1
          fi

      - name: Resumen
        run: |
          echo "# 🔄 Sincronización Main → Dev" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "| Aspecto | Estado |" >> $GITHUB_STEP_SUMMARY
          echo "|---------|--------|" >> $GITHUB_STEP_SUMMARY
          echo "| Versión | v${{ steps.version.outputs.version }} |" >> $GITHUB_STEP_SUMMARY
          echo "| Rama dev existe | ${{ steps.check_dev.outputs.exists }} |" >> $GITHUB_STEP_SUMMARY
          echo "| Diferencias | ${{ steps.check_diff.outputs.has_diff }} |" >> $GITHUB_STEP_SUMMARY

          if [ "${{ steps.check_diff.outputs.has_diff }}" == "true" ]; then
            echo "" >> $GITHUB_STEP_SUMMARY
            echo "✅ Merge automático completado" >> $GITHUB_STEP_SUMMARY
            echo "📍 dev se sincronizó con main correctamente" >> $GITHUB_STEP_SUMMARY
          else
            echo "" >> $GITHUB_STEP_SUMMARY
            echo "✅ main y dev ya están sincronizados" >> $GITHUB_STEP_SUMMARY
          fi
```

**Diferencias mínimas entre repos:**

| Repo | Diferencia |
|------|------------|
| api-mobile | Versión base |
| api-administracion | Idéntico 100% |
| worker | Idéntico 100% |
| shared | Idéntico 100% |
| infrastructure | Nombre: "Sync main to dev" (lowercase) |

**Estimación:** 6 workflows × 100 líneas = **600 líneas duplicadas**

**Solución propuesta:**

```yaml
# En cada repo: .github/workflows/sync-main-to-dev.yml
name: Sync Main to Dev

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  sync:
    uses: EduGoGroup/edugo-infrastructure/.github/workflows/reusable/sync-branches.yml@v1
```

**Ahorro:** 600 líneas → 30 líneas = **570 líneas eliminadas (95%)**

---

## 🔄 Bloque 3: Docker Build Steps (90% duplicado)

### Ocurrencias: 8 workflows

**Patrón duplicado:**

```yaml
- name: Setup Docker Buildx
  uses: docker/setup-buildx-action@v3

- name: Login a GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ${{ env.REGISTRY }}
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

- name: Extraer metadata para Docker
  id: meta
  uses: docker/metadata-action@v5
  with:
    images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
    tags: |
      type=semver,pattern={{version}}
      type=semver,pattern={{major}}.{{minor}}
      type=semver,pattern={{major}}
      type=raw,value=latest

- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    platforms: linux/amd64,linux/arm64
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

**Encontrado en:**

| Proyecto | Workflow | Variación en tags |
|----------|----------|-------------------|
| api-mobile | manual-release.yml | ✅ Similar |
| api-administracion | build-and-push.yml | ⚠️ Diferente (environment) |
| api-administracion | release.yml | ✅ Similar + production tag |
| worker | build-and-push.yml | ⚠️ Diferente (branch, sha) |
| worker | release.yml | ✅ Similar |
| worker | docker-only.yml | ⚠️ Simple (solo latest) |

**Estimación:** 8 workflows × 35 líneas = **280 líneas duplicadas**

**Problema:** Las estrategias de tags difieren significativamente.

**Solución propuesta:**

```yaml
- name: Build Docker
  uses: EduGoGroup/edugo-infrastructure/.github/actions/docker-build-edugo@v1
  with:
    image-name: edugogroup/edugo-api-mobile
    tag-strategy: semver  # o 'branch', 'environment'
    version: ${{ steps.version.outputs.version }}
```

**Ahorro:** 280 líneas → 40 líneas = **240 líneas eliminadas (86%)**

---

## 🔄 Bloque 4: Coverage Check (80% duplicado)

### Ocurrencias: 5 workflows

**Código duplicado:**

```yaml
- name: ✅ Verificar umbral de cobertura
  if: |
    !contains(github.event.pull_request.labels.*.name, 'skip-coverage')
  run: |
    ./scripts/check-coverage.sh coverage/coverage-filtered.out ${{ env.COVERAGE_THRESHOLD }} || {
      echo "::warning::Cobertura por debajo del umbral de ${COVERAGE_THRESHOLD}%"
      echo "💡 Tip: Agrega label 'skip-coverage' al PR si es temporal"
      exit 1
    }
  continue-on-error: false
```

**Encontrado en:**

| Proyecto | Workflow | Threshold |
|----------|----------|-----------|
| api-mobile | pr-to-dev.yml | 33% |
| api-mobile | pr-to-main.yml | 33% |
| api-administracion | pr-to-dev.yml | 33% |
| api-administracion | pr-to-main.yml | 33% (no existe workflow) |

**Variaciones:**
- Algunos usan `::warning::`, otros `::error::`
- Path del script: `./scripts/check-coverage.sh` (estándar)
- Path de coverage: `coverage/coverage-filtered.out` vs `coverage.out`

**Estimación:** 5 workflows × 12 líneas = **60 líneas duplicadas**

**Problema adicional:** El script `check-coverage.sh` está duplicado en cada repo.

**Solución propuesta:**

```yaml
- name: Check Coverage
  uses: EduGoGroup/edugo-infrastructure/.github/actions/coverage-check@v1
  with:
    coverage-file: coverage/coverage-filtered.out
    threshold: ${{ env.COVERAGE_THRESHOLD }}
    allow-skip-label: true
```

Y centralizar el script en edugo-infrastructure.

**Ahorro:** 60 líneas + 3 scripts duplicados eliminados

---

## 🔄 Bloque 5: PR Comments (80% duplicado)

### Ocurrencias: 4 workflows

**Código duplicado:**

```yaml
- name: 📈 Comentar cobertura en PR
  uses: actions/github-script@v7
  if: always()
  with:
    script: |
      const fs = require('fs');
      const coverage = fs.readFileSync('coverage/coverage-filtered.out', 'utf8');
      const lines = coverage.split('\n');
      const totalLine = lines[lines.length - 2];
      const match = totalLine.match(/(\d+\.\d+)%/);
      const coveragePercent = match ? match[1] : 'N/A';

      const comment = `## 📊 Cobertura de Tests Unitarios

      **Cobertura Total**: ${coveragePercent}%
      **Umbral Mínimo**: ${process.env.COVERAGE_THRESHOLD}%

      ${parseFloat(coveragePercent) >= parseFloat(process.env.COVERAGE_THRESHOLD) ? '✅ Cobertura cumple con el umbral' : '⚠️ Cobertura por debajo del umbral'}

      📄 [Ver reporte completo](https://github.com/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId})
      `;

      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: comment
      });
```

**Encontrado en:**

| Proyecto | Workflow |
|----------|----------|
| api-mobile | pr-to-dev.yml |
| api-administracion | pr-to-dev.yml |

**Estimación:** 2 workflows × 30 líneas = **60 líneas duplicadas**

**Problema:** Lógica JavaScript embebida en YAML.

**Solución propuesta:**

Mover a composite action o crear archivo `.js` reutilizable:

```yaml
- name: Comment Coverage
  uses: EduGoGroup/edugo-infrastructure/.github/actions/comment-coverage@v1
  with:
    coverage-file: coverage/coverage-filtered.out
    threshold: ${{ env.COVERAGE_THRESHOLD }}
```

---

## 🔄 Bloque 6: Resumen de Tests en PR (75% duplicado)

### Ocurrencias: 4 workflows

**Código duplicado:**

```yaml
summary:
  name: PR Summary
  runs-on: ubuntu-latest
  needs: [unit-tests, lint]
  if: always()

  steps:
    - name: 📋 Generar resumen
      uses: actions/github-script@v7
      with:
        script: |
          const unitTests = '${{ needs.unit-tests.result }}';
          const lint = '${{ needs.lint.result }}';

          const statusEmoji = (status) => {
            switch(status) {
              case 'success': return '✅';
              case 'failure': return '❌';
              case 'cancelled': return '⏸️';
              default: return '⚠️';
            }
          };

          const summary = `## 🔍 Resumen de Checks - PR a Dev

          | Check | Estado |
          |-------|--------|
          | Tests Unitarios | ${statusEmoji(unitTests)} ${unitTests} |
          | Lint & Format | ${statusEmoji(lint)} ${lint} |

          ${unitTests === 'success' && lint === 'success' ? '✅ **Todos los checks pasaron** - PR listo para review' : '⚠️ **Algunos checks fallaron** - Por favor revisa los errores'}
          `;

          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: summary
          });
```

**Estimación:** 4 workflows × 40 líneas = **160 líneas duplicadas**

**Variaciones:**
- pr-to-dev: checks unitTests + lint
- pr-to-main: checks unitTests + integrationTests + lint + security

**Solución:** Composite action parametrizable.

---

## 📊 Análisis de Tags Docker Duplicados

### Problema: Múltiples workflows generando tags

**Caso: worker (PEOR CASO)**

**Escenario 1: Push a main**

Workflow: `build-and-push.yml`
```yaml
tags: |
  type=ref,event=branch              # → main
  type=sha,prefix={{branch}}-        # → main-abc1234
  type=raw,value=latest              # → latest
```

**Resultado:** 3 tags para el mismo commit.

**Escenario 2: Tag v1.0.0**

Workflow: `release.yml`
```yaml
tags: |
  type=semver,pattern={{version}}    # → 1.0.0
  type=semver,pattern={{major}}.{{minor}}  # → 1.0
  type=semver,pattern={{major}}      # → 1
  type=raw,value=latest              # → latest (DUPLICADO)
  type=raw,value=${{ tag }}          # → v1.0.0
```

**Resultado:** 5 tags para el mismo commit.

**Escenario 3: Manual con environment=staging**

Workflow: `build-and-push.yml` (manual)
```yaml
tags: |
  type=raw,value=${{ inputs.environment }}  # → staging
  type=sha,prefix={{branch}}-               # → main-abc1234 (DUPLICADO si es desde main)
```

**Resultado:** 2 tags para el mismo commit.

**TOTAL POTENCIAL para worker:** 10+ tags diferentes apuntando al mismo o diferente código.

**Problema de caché:** GHCR tiene límites de storage, múltiples tags ocupan espacio.

---

### Caso: api-administracion

**build-and-push.yml:**
```yaml
tags: |
  type=raw,value=${{ inputs.environment }}
  type=raw,value=latest,enable=${{ inputs.push_latest }}
  type=sha,prefix=${{ inputs.environment }}-
```

**release.yml:**
```yaml
tags: |
  type=semver,pattern={{version}}
  type=semver,pattern={{major}}.{{minor}}
  type=semver,pattern={{major}}
  type=raw,value=latest
  type=raw,value=production
  type=sha,prefix=${{ tag }}-
```

**Conflicto:** Si se hace release y manual build el mismo día:
- `latest` se sobreescribe entre workflows
- Multiple SHA tags: `development-abc123`, `staging-abc123`, `v1.0.0-abc123`

---

## 🔍 Scripts Duplicados

### check-coverage.sh

**Encontrado en:**
- api-mobile/scripts/check-coverage.sh
- api-administracion/scripts/check-coverage.sh

**Código (similar 100%):**

```bash
#!/bin/bash
COVERAGE_FILE=$1
THRESHOLD=$2

# Calcular cobertura total
COVERAGE=$(go tool cover -func="$COVERAGE_FILE" | tail -1 | awk '{print $NF}' | sed 's/%//')

echo "Cobertura: $COVERAGE%"
echo "Umbral: $THRESHOLD%"

if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
  echo "❌ Cobertura por debajo del umbral"
  exit 1
fi

echo "✅ Cobertura cumple el umbral"
```

**Solución:** Mover a edugo-infrastructure y referenciar desde workflows.

---

## 📈 Impacto de Eliminar Duplicación

### Antes (Estado Actual)

```
Total de workflows: 28
Líneas totales: ~3,500
Líneas duplicadas: ~1,300 (37%)
```

### Después (Con Reusables)

```
Workflows consumidores: 28
Workflows reusables: 5
Composite actions: 4
Líneas totales: ~1,500
Líneas duplicadas: ~200 (13%)

Reducción: 57% menos código
```

---

## 🎯 Priorización de Refactoring

### Prioridad 1: Máximo impacto
1. ✅ sync-main-to-dev (600 líneas → 30)
2. ✅ Docker builds (280 líneas → 40)

### Prioridad 2: Alto impacto
3. ✅ setup-edugo-go (230 líneas → 23)
4. ✅ Eliminar workflows Docker duplicados en worker

### Prioridad 3: Medio impacto
5. ✅ PR comments y summaries (220 líneas → 40)
6. ✅ Coverage checks (60 líneas → 12)

---

## 📝 Checklist de Refactoring

### Fase 1: Crear Reusables
- [ ] Crear edugo-infrastructure/.github/workflows/reusable/sync-branches.yml
- [ ] Crear edugo-infrastructure/.github/actions/setup-edugo-go/
- [ ] Crear edugo-infrastructure/.github/actions/docker-build-edugo/
- [ ] Crear edugo-infrastructure/.github/actions/coverage-check/
- [ ] Crear edugo-infrastructure/.github/actions/pr-summary/

### Fase 2: Migrar api-mobile (Piloto)
- [ ] Migrar sync-main-to-dev.yml
- [ ] Migrar setup Go en todos los workflows
- [ ] Migrar Docker build en manual-release
- [ ] Testing completo
- [ ] Documentar experiencia

### Fase 3: Migrar Resto
- [ ] api-administracion
- [ ] worker
- [ ] shared
- [ ] infrastructure

### Fase 4: Limpiar
- [ ] Eliminar workflows duplicados
- [ ] Estandarizar estrategia de tags
- [ ] Centralizar scripts

---

**Beneficio final:** De ~1,300 líneas duplicadas a ~200 = **85% reducción**

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025
