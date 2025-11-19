# Actualización: Releases por Módulo - Aclaraciones

**Fecha:** 19 de Noviembre, 2025

---

## 🔄 Corrección: Opción "all" en Releases por Módulo

### ❌ INCORRECTO (versión anterior)
```
all → Crea UN tag global v0.7.0 para todos los módulos
```

### ✅ CORRECTO
```
all → Crea MÚLTIPLES tags, uno por cada módulo con su PROPIA versión:
  - common/v0.7.1
  - logger/v0.8.2
  - auth/v0.6.5
  - middleware/gin/v0.7.0
  - messaging/rabbit/v0.9.1
  - database/postgres/v0.8.3
  - database/mongodb/v0.7.7
```

**Razón:** Cada módulo evoluciona independientemente.

---

## 📋 Implementación Correcta

### Opción 1: Release de UN Módulo

```yaml
on:
  workflow_dispatch:
    inputs:
      module:
        description: 'Módulo a liberar'
        type: choice
        options:
          - common
          - logger
          - auth
          - middleware/gin
          - messaging/rabbit
          - database/postgres
          - database/mongodb
          - all  # ← Libera TODOS con sus propias versiones
      
      version:
        description: 'Versión (solo si módulo != all)'
        required: false
        type: string
```

**Uso Módulo Individual:**
```
Module: logger
Version: 0.8.2
→ Crea tag: logger/v0.8.2
```

---

### Opción 2: Release de TODOS (all)

**Cuando se selecciona "all":**
1. Lee el archivo `versions.json` con la versión actual de cada módulo
2. Auto-incrementa la versión de cada módulo (patch)
3. Crea un tag por cada módulo
4. Actualiza `versions.json`

**Archivo de versiones:**
```json
// .github/versions.json
{
  "common": "0.7.1",
  "logger": "0.8.2",
  "auth": "0.6.5",
  "middleware/gin": "0.7.0",
  "messaging/rabbit": "0.9.1",
  "database/postgres": "0.8.3",
  "database/mongodb": "0.7.7"
}
```

**Workflow implementación:**

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Determinar qué liberar
        id: determine
        run: |
          MODULE="${{ inputs.module }}"
          
          if [ "$MODULE" = "all" ]; then
            echo "mode=all" >> $GITHUB_OUTPUT
            echo "✅ Modo: Liberar TODOS los módulos"
          else
            echo "mode=single" >> $GITHUB_OUTPUT
            echo "module=$MODULE" >> $GITHUB_OUTPUT
            echo "version=${{ inputs.version }}" >> $GITHUB_OUTPUT
            echo "✅ Modo: Liberar $MODULE v${{ inputs.version }}"
          fi
      
      # === MODO SINGLE ===
      - name: Release módulo individual
        if: steps.determine.outputs.mode == 'single'
        run: |
          MODULE="${{ steps.determine.outputs.module }}"
          VERSION="${{ steps.determine.outputs.version }}"
          
          # Tests
          cd $MODULE
          go test -v ./...
          cd ..
          
          # Tag
          TAG="$MODULE/v$VERSION"
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git tag -a "$TAG" -m "Release $MODULE v$VERSION"
          git push origin "$TAG"
          
          echo "✅ Tag creado: $TAG"
      
      # === MODO ALL ===
      - name: Leer versiones actuales
        if: steps.determine.outputs.mode == 'all'
        id: read_versions
        run: |
          # Leer versions.json
          if [ ! -f .github/versions.json ]; then
            echo "❌ .github/versions.json no existe"
            exit 1
          fi
          
          cat .github/versions.json
      
      - name: Auto-incrementar versiones (patch)
        if: steps.determine.outputs.mode == 'all'
        id: increment
        run: |
          # Script para incrementar patch de cada módulo
          python3 << 'PYTHON'
import json
import re

# Leer versiones actuales
with open('.github/versions.json', 'r') as f:
    versions = json.load(f)

# Incrementar patch de cada módulo
new_versions = {}
for module, version in versions.items():
    # Parsear semver
    match = re.match(r'^(\d+)\.(\d+)\.(\d+)$', version)
    if not match:
        print(f"❌ Versión inválida para {module}: {version}")
        exit(1)
    
    major, minor, patch = match.groups()
    new_patch = int(patch) + 1
    new_version = f"{major}.{minor}.{new_patch}"
    new_versions[module] = new_version
    print(f"  {module}: {version} → {new_version}")

# Guardar nuevas versiones
with open('.github/versions.json', 'w') as f:
    json.dump(new_versions, f, indent=2)

print("\n✅ Versiones incrementadas")
PYTHON
      
      - name: Tests de todos los módulos
        if: steps.determine.outputs.mode == 'all'
        run: |
          MODULES=(common logger auth middleware/gin messaging/rabbit database/postgres database/mongodb)
          
          for module in "${MODULES[@]}"; do
            echo "🧪 Testing $module..."
            cd $module
            go test -v ./...
            cd - > /dev/null
          done
          
          echo "✅ Todos los tests pasaron"
      
      - name: Crear tags para todos los módulos
        if: steps.determine.outputs.mode == 'all'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          
          # Leer nuevas versiones
          python3 << 'PYTHON'
import json

with open('.github/versions.json', 'r') as f:
    versions = json.load(f)

# Generar comandos git tag
for module, version in versions.items():
    tag = f"{module}/v{version}"
    print(f"git tag -a '{tag}' -m 'Release {module} v{version}'")
    print(f"git push origin '{tag}'")
    print(f"echo '✅ Tag creado: {tag}'")
PYTHON
      
      - name: Commit versions.json actualizado
        if: steps.determine.outputs.mode == 'all'
        run: |
          git add .github/versions.json
          git commit -m "chore: actualizar versiones después de release

🤖 Generated with Claude Code"
          git push origin main
```

**Uso "all":**
```
Module: all
Version: (ignorado)

→ Lee versions.json
→ Incrementa patch de cada módulo
→ Crea tags:
  - common/v0.7.2 (era 0.7.1)
  - logger/v0.8.3 (era 0.8.2)
  - auth/v0.6.6 (era 0.6.5)
  - ... etc
→ Actualiza versions.json
→ Commit a main
```

---

## 🔄 Pipeline Automático con Variable

**IMPORTANTE:** El pipeline también debe invocar releases automáticamente si la variable está activa.

### Implementación

```yaml
# .github/workflows/auto-release-modules.yml
name: Auto Release Modules (Si Habilitado)

on:
  # Trigger en push a main
  push:
    branches: [main]
    # Solo si cambió código en algún módulo
    paths:
      - 'common/**'
      - 'logger/**'
      - 'auth/**'
      - 'middleware/**'
      - 'messaging/**'
      - 'database/**'

jobs:
  check-auto-release:
    runs-on: ubuntu-latest
    outputs:
      should_release: ${{ steps.check.outputs.should_release }}
      changed_modules: ${{ steps.detect.outputs.modules }}
    
    steps:
      - name: Verificar si auto-release está habilitado
        id: check
        run: |
          if [ "${{ vars.ENABLE_AUTO_RELEASE_MODULES }}" = "true" ]; then
            echo "should_release=true" >> $GITHUB_OUTPUT
            echo "✅ Auto-release de módulos HABILITADO"
          else
            echo "should_release=false" >> $GITHUB_OUTPUT
            echo "⏭️  Auto-release de módulos DESHABILITADO"
            echo ""
            echo "💡 Para habilitar:"
            echo "   Settings → Variables → ENABLE_AUTO_RELEASE_MODULES = true"
          fi
      
      - uses: actions/checkout@v4
        if: steps.check.outputs.should_release == 'true'
        with:
          fetch-depth: 2
      
      - name: Detectar módulos modificados
        if: steps.check.outputs.should_release == 'true'
        id: detect
        run: |
          # Detectar qué módulos cambiaron en este push
          CHANGED_FILES=$(git diff --name-only HEAD^ HEAD)
          
          MODULES=()
          for file in $CHANGED_FILES; do
            # Extraer módulo del path
            if [[ $file == common/* ]]; then
              MODULES+=("common")
            elif [[ $file == logger/* ]]; then
              MODULES+=("logger")
            elif [[ $file == auth/* ]]; then
              MODULES+=("auth")
            elif [[ $file == middleware/gin/* ]]; then
              MODULES+=("middleware/gin")
            elif [[ $file == messaging/rabbit/* ]]; then
              MODULES+=("messaging/rabbit")
            elif [[ $file == database/postgres/* ]]; then
              MODULES+=("database/postgres")
            elif [[ $file == database/mongodb/* ]]; then
              MODULES+=("database/mongodb")
            fi
          done
          
          # Eliminar duplicados
          UNIQUE_MODULES=($(echo "${MODULES[@]}" | tr ' ' '\n' | sort -u))
          
          if [ ${#UNIQUE_MODULES[@]} -eq 0 ]; then
            echo "modules=none" >> $GITHUB_OUTPUT
            echo "⏭️  No hay módulos modificados"
          else
            # Convertir a JSON array
            MODULES_JSON=$(printf '%s\n' "${UNIQUE_MODULES[@]}" | jq -R . | jq -s -c .)
            echo "modules=$MODULES_JSON" >> $GITHUB_OUTPUT
            echo "✅ Módulos modificados: ${UNIQUE_MODULES[@]}"
          fi
  
  release-changed-modules:
    needs: check-auto-release
    if: |
      needs.check-auto-release.outputs.should_release == 'true' &&
      needs.check-auto-release.outputs.changed_modules != 'none'
    
    runs-on: ubuntu-latest
    strategy:
      matrix:
        module: ${{ fromJson(needs.check-auto-release.outputs.changed_modules) }}
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.24.10'
      
      - name: Leer versión actual del módulo
        id: current
        run: |
          MODULE="${{ matrix.module }}"
          CURRENT=$(jq -r ".[\"$MODULE\"]" .github/versions.json)
          echo "version=$CURRENT" >> $GITHUB_OUTPUT
          echo "📌 Versión actual de $MODULE: $CURRENT"
      
      - name: Incrementar versión (patch)
        id: new
        run: |
          CURRENT="${{ steps.current.outputs.version }}"
          
          # Parse semver
          IFS='.' read -r major minor patch <<< "$CURRENT"
          NEW_PATCH=$((patch + 1))
          NEW_VERSION="$major.$minor.$NEW_PATCH"
          
          echo "version=$NEW_VERSION" >> $GITHUB_OUTPUT
          echo "✅ Nueva versión: $CURRENT → $NEW_VERSION"
      
      - name: Tests del módulo
        run: |
          cd ${{ matrix.module }}
          go test -v ./...
      
      - name: Crear tag
        run: |
          MODULE="${{ matrix.module }}"
          VERSION="${{ steps.new.outputs.version }}"
          TAG="$MODULE/v$VERSION"
          
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          
          git tag -a "$TAG" -m "Auto-release $MODULE v$VERSION

Cambios detectados en push a main.

🤖 Generated with Claude Code"
          
          git push origin "$TAG"
          echo "✅ Tag creado: $TAG"
      
      - name: Actualizar versions.json
        run: |
          MODULE="${{ matrix.module }}"
          VERSION="${{ steps.new.outputs.version }}"
          
          # Actualizar JSON
          jq --arg module "$MODULE" --arg version "$VERSION" \
             '.[$module] = $version' \
             .github/versions.json > .github/versions.json.tmp
          
          mv .github/versions.json.tmp .github/versions.json
          
          git add .github/versions.json
          git commit -m "chore: bump $MODULE to v$VERSION [skip ci]"
          git push origin main
```

**Estado inicial:**
```
ENABLE_AUTO_RELEASE_MODULES = false (o no existe)
→ Push a main NO crea releases automáticamente
```

**Cuando estemos confiados:**
```bash
# Habilitar auto-release
gh variable set ENABLE_AUTO_RELEASE_MODULES --body "true" --repo EduGoGroup/edugo-shared

# Ahora cada push a main que modifique un módulo:
# 1. Detecta qué módulos cambiaron
# 2. Incrementa versión patch automáticamente
# 3. Crea tag para cada módulo modificado
# 4. Actualiza versions.json
```

---

## 📋 Resumen de Comportamiento

### Manual Release (Siempre Disponible)

**Opción 1: Módulo Específico**
```
Actions → Release - Por Módulo → Run workflow
Module: logger
Version: 0.8.5

→ Crea tag: logger/v0.8.5
→ NO actualiza versions.json (versión manual explícita)
```

**Opción 2: Todos los Módulos**
```
Actions → Release - Por Módulo → Run workflow
Module: all
Version: (ignorado)

→ Lee versions.json
→ Incrementa patch de CADA módulo
→ Crea UN tag POR MÓDULO con su nueva versión
→ Actualiza versions.json
→ Commit a main
```

---

### Auto Release (Si Variable Habilitada)

```
ENABLE_AUTO_RELEASE_MODULES = true

Push a main modifica:
  - common/utils.go
  - logger/logger.go

Pipeline detecta cambios:
→ common: v0.7.1 → v0.7.2 (tag common/v0.7.2)
→ logger: v0.8.2 → v0.8.3 (tag logger/v0.8.3)
→ Actualiza versions.json
→ Commit [skip ci]
```

---

## 🎯 Ventajas de Este Enfoque

1. ✅ **Cada módulo tiene su propia versión independiente**
2. ✅ **"all" libera TODOS con auto-increment**, no versión común
3. ✅ **Manual siempre disponible** (seguro)
4. ✅ **Auto-release opcional** con variable
5. ✅ **Fácil activación** cuando estemos confiados
6. ✅ **Versionado automático** basado en cambios detectados

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025
