# Proceso de Homologación: dev → main

**Propósito:** Sincronizar cambios acumulados en `dev` con `main` y crear releases estables.  
**Frecuencia:** Periódica (cuando se acumulen cambios significativos en dev)  
**Duración estimada:** 2-3 horas  
**Última actualización:** 12 de Noviembre, 2025

---

## 📋 Contexto

Este proceso **SOLO se ejecuta en sesiones dedicadas de homologación**. Es el único momento en que:
- Se actualizan las ramas `main` con cambios de `dev`
- Se crean releases oficiales
- Se generan nuevas imágenes Docker

**⚠️ IMPORTANTE:** Durante el desarrollo normal (FASES 1-7), NUNCA se toca `main` ni se crean releases.

---

## 🎯 Objetivos

1. ✅ Sincronizar `shared/dev` → `shared/main` con releases unificados
2. ✅ Actualizar dependencias de shared en todos los proyectos
3. ✅ Sincronizar cambios acumulados: `dev` → `main` en cada proyecto
4. ✅ Crear releases oficiales con nuevas versiones
5. ✅ Generar imágenes Docker actualizadas

---

## 📑 Pre-requisitos

### Antes de Iniciar

- [ ] Todas las tareas pendientes en dev están completas
- [ ] No hay PRs abiertos en ningún repo
- [ ] No hay errores de compilación en dev
- [ ] Todos los tests en dev están pasando
- [ ] Revisar RULES.md para recordar criterios

### Herramientas Necesarias

```bash
# GitHub CLI
gh --version  # Debe estar instalado y autenticado

# Git configurado
git config --global user.name
git config --global user.email

# Go instalado
go version  # 1.21+
```

---

## 📖 Proceso Completo

### FASE 1: Preparación y Organización (30 min)

#### 1.1 Organizar Documentación

```bash
cd /Users/jhoanmedina/source/EduGo/Analisys/specs/api-admin-jerarquia

# Crear carpeta archived/ si no existe
mkdir -p archived

# Mover documentos de fases completadas
mv FASE_*.md archived/
mv *.bak archived/ 2>/dev/null
mv *.backup archived/ 2>/dev/null

# Actualizar README.md con progreso actual
# Actualizar LOGS.md con estado de sesión
```

#### 1.2 Verificar Estado de Repositorios

```bash
# Revisar estado local de todos los repos
for repo in edugo-shared edugo-api-mobile edugo-api-administracion edugo-worker edugo-dev-environment; do
  cd /Users/jhoanmedina/source/EduGo/repos-separados/$repo
  echo "📁 $repo"
  echo "  Rama: $(git branch --show-current)"
  echo "  Estado: $(git status --short | wc -l | tr -d ' ') cambios"
  echo "  Últimos commits:"
  git log --oneline -2 | sed 's/^/    /'
done
```

#### 1.3 Actualizar Todas las Ramas dev

```bash
# Para cada repo: actualizar dev local
for repo in edugo-shared edugo-api-mobile edugo-api-administracion edugo-worker; do
  cd /Users/jhoanmedina/source/EduGo/repos-separados/$repo
  git checkout dev
  git pull origin dev
done
```

#### 1.4 Limpiar Ramas Remotas Obsoletas

```bash
# Ver ramas remotas
cd /Users/jhoanmedina/source/EduGo/repos-separados/[REPO]
git branch -r | grep -v HEAD | grep -v main | grep -v dev

# Eliminar ramas feature/* ya mergeadas
git push origin --delete feature/[NOMBRE-RAMA]
```

---

### FASE 2: Homologación de shared (1 hora)

#### 2.1 Crear PR dev → main en shared

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared

# Verificar commits pendientes
git log --oneline dev ^main | wc -l

# Crear PR
gh pr create --base main --head dev \
  --title "feat: Homologación - cambios acumulados en dev" \
  --body "## 📋 Resumen

Merge de dev a main con todos los cambios acumulados desde último release.

## ✨ Cambios Principales

[LISTAR CAMBIOS IMPORTANTES]

## 📦 Módulos Afectados

[LISTAR MÓDULOS CON CAMBIOS]

---
**Tipo:** Homologación periódica
**Generado con:** Claude Code"
```

#### 2.2 Esperar CI/CD (máx 5 minutos)

```bash
# Esperar 2-3 minutos
sleep 120

# Verificar estado
gh pr view [PR_NUMBER] --json statusCheckRollup,mergeable --jq \
  '{mergeable: .mergeable, total: (.statusCheckRollup | length), success: ([.statusCheckRollup[] | select(.conclusion == "SUCCESS")] | length)}'

# Si no pasa todos: aplicar RULES.md
# - Documentar en CICD_ISSUES/
# - Máximo 3 intentos por error
# - Si no resuelve: detener y notificar
```

#### 2.3 Merge a main

```bash
# Si todos los checks pasan
gh pr merge [PR_NUMBER] --squash --delete-branch=false

# Actualizar local
git checkout main
git pull origin main
```

#### 2.4 Crear Releases Unificados

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared

# Determinar nueva versión (incrementar según cambios)
# Ejemplo: v0.4.0 → v0.5.0 (minor) o v0.4.1 (patch)
NEW_VERSION="v0.5.0"

# Listar módulos
MODULES=(
  "auth"
  "bootstrap"
  "common"
  "config"
  "database/mongodb"
  "database/postgres"
  "lifecycle"
  "logger"
  "messaging/rabbit"
  "middleware/gin"
)

# Crear tags para todos los módulos
for module in "${MODULES[@]}"; do
  tag="${module}/${NEW_VERSION}"
  echo "📦 Creando tag ${tag}..."
  git tag -a "${tag}" -m "Release ${module} ${NEW_VERSION}

Homologación periódica desde dev
[DESCRIBIR CAMBIOS PRINCIPALES]

Generado con: Claude Code"
done

# Push tags
git push origin --tags

# Crear releases en GitHub
for module in "${MODULES[@]}"; do
  tag="${module}/${NEW_VERSION}"
  echo "🚀 Creando release ${tag}..."
  
  gh release create "${tag}" \
    --title "Release ${module} ${NEW_VERSION}" \
    --notes "## 📦 ${module} ${NEW_VERSION}

### ✨ Cambios

[LISTAR CAMBIOS DEL MÓDULO]

### 📊 Estado

- ✅ Tests pasando
- ✅ Linting completado

### 🔗 Uso

\`\`\`bash
go get github.com/EduGoGroup/edugo-shared/${module}@${NEW_VERSION}
\`\`\`

---
**Tipo:** Homologación periódica"
  
  sleep 2
done
```

#### 2.5 Sincronizar dev con main

```bash
git checkout dev
git pull origin dev
git merge main -m "chore: sync main ${NEW_VERSION} to dev"
git push origin dev
```

---

### FASE 3: Actualizar Proyectos (1-1.5 horas)

**Repetir para:** `api-mobile`, `api-administracion`, `worker`

#### 3.1 Actualizar Dependencias de shared

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/[PROYECTO]

# Asegurar estar en dev
git checkout dev
git pull origin dev

# Actualizar shared a nueva versión
NEW_VERSION="v0.5.0"  # Usar la versión creada en FASE 2
go get github.com/EduGoGroup/edugo-shared/bootstrap@${NEW_VERSION}
go get github.com/EduGoGroup/edugo-shared/config@${NEW_VERSION}
go get github.com/EduGoGroup/edugo-shared/lifecycle@${NEW_VERSION}
go get github.com/EduGoGroup/edugo-shared/logger@${NEW_VERSION}
go mod tidy

# Compilar para verificar
go build ./...
# Debe compilar sin errores
```

#### 3.2 Commit y Push

```bash
git add go.mod go.sum
git commit -m "chore: actualizar shared a ${NEW_VERSION}

- bootstrap: actualizado
- config: actualizado
- lifecycle: actualizado
- logger: actualizado

Compilación verificada ✅
"
git push origin dev
```

#### 3.3 Crear PR dev → main

```bash
gh pr create --base main --head dev \
  --title "chore: actualizar shared a ${NEW_VERSION} + cambios acumulados" \
  --body "## 📋 Resumen

Actualización de shared a **${NEW_VERSION}** + todos los cambios acumulados en dev.

## ✨ Cambios Principales

### Dependencias
- \`shared\`: actualizado a ${NEW_VERSION}

### Trabajos Previos en dev
[LISTAR TRABAJOS COMPLETADOS]

## 🔍 Validación

- ✅ Compilación exitosa
- ✅ Dependencias actualizadas
- ✅ Sin breaking changes

---
**Tipo:** Homologación periódica"
```

#### 3.4 Esperar CI/CD y Mergear

```bash
# Esperar 2-3 minutos
sleep 180

# Verificar checks
gh pr view [PR_NUMBER] --json statusCheckRollup,mergeable --jq \
  '{mergeable: .mergeable, total: (.statusCheckRollup | length), success: ([.statusCheckRollup[] | select(.conclusion == "SUCCESS")] | length)}'

# Si hay errores:
# - Formato: gofmt -w . && git commit && git push
# - Tests: corregir y push
# - Aplicar RULES.md (máx 5 min, máx 3 intentos)

# Mergear
gh pr merge [PR_NUMBER] --squash --delete-branch=false

# Actualizar main local
git checkout main
git pull origin main
```

#### 3.5 Ejecutar Release Manual

```bash
# Ver versión actual
cat .github/version.txt

# Incrementar versión (ejemplo: 0.1.10 → 0.1.11)
OLD_VERSION=$(cat .github/version.txt)
# Calcular nueva versión según tipo de cambio
NEW_PROJECT_VERSION="0.1.11"  # patch
# NEW_PROJECT_VERSION="0.2.0"   # minor (nueva feature)
# NEW_PROJECT_VERSION="1.0.0"   # major (breaking change)

# Ejecutar workflow
gh workflow run manual-release.yml \
  -f version=${NEW_PROJECT_VERSION} \
  -f bump_type=patch

# Verificar que inició
sleep 10
gh run list --workflow="manual-release.yml" --limit 1

# ✅ Release ejecutándose (crear imagen Docker)
# No esperar - continuar con siguiente proyecto
```

---

### FASE 4: Validar dev-environment (10 min)

#### 4.1 Verificar Configuración

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-dev-environment

# Ver configuración de imágenes
cat docker/docker-compose.yml | grep "image:" | grep edugo

# Ver versiones en .env (si existe)
cat docker/.env | grep VERSION
```

#### 4.2 Decisión de Actualización

**Caso 1: Usa `latest` (recomendado)**
```yaml
image: ghcr.io/edugogroup/edugo-api-mobile:${API_MOBILE_VERSION:-latest}
```
✅ **No requiere cambios** - Tomará automáticamente las nuevas imágenes

**Caso 2: Usa versiones específicas**
```yaml
image: ghcr.io/edugogroup/edugo-api-mobile:0.1.10
```
❌ **Requiere actualización manual** - Actualizar a nuevas versiones

**Acción si requiere cambios:**
```bash
# Actualizar docker-compose.yml con nuevas versiones
# Crear PR y mergear según proceso normal
```

---

## 📊 Checklist de Validación Final

### Repositorios

- [ ] **edugo-shared**
  - [ ] PR dev → main mergeado
  - [ ] Releases v[X.Y.Z] creados para 10 módulos
  - [ ] Tags pusheados
  - [ ] dev sincronizado con main

- [ ] **edugo-api-mobile**
  - [ ] Dependencias shared actualizadas
  - [ ] PR dev → main mergeado
  - [ ] Release v[X.Y.Z] ejecutándose
  - [ ] main y dev sincronizados

- [ ] **edugo-api-administracion**
  - [ ] Dependencias shared actualizadas
  - [ ] PR dev → main mergeado
  - [ ] Release v[X.Y.Z] ejecutándose
  - [ ] main y dev sincronizados

- [ ] **edugo-worker**
  - [ ] Dependencias shared actualizadas
  - [ ] PR dev → main mergeado
  - [ ] Release v[X.Y.Z] ejecutándose
  - [ ] main y dev sincronizados

- [ ] **edugo-dev-environment**
  - [ ] Configuración validada
  - [ ] Actualizaciones realizadas (si aplica)

### Documentación

- [ ] LOGS.md actualizado con sesión de homologación
- [ ] README.md con progreso actualizado
- [ ] Documentos de fases completadas archivados
- [ ] Este documento revisado y actualizado

### Releases

- [ ] Todos los workflows de release iniciados
- [ ] Monitoreo de progreso configurado
- [ ] Imágenes Docker se crearán automáticamente

---

## 🚨 Manejo de Errores

### Error: CI/CD no pasa

**Acciones:**
1. Revisar logs: `gh run view [RUN_ID] --log-failed`
2. Documentar en `CICD_ISSUES/[FECHA]-[PROYECTO]-[PR].md`
3. Aplicar corrección
4. Push y esperar re-ejecución
5. Máximo 3 intentos (según RULES.md)
6. Si no resuelve: detener y notificar usuario

### Error: Formato de código

```bash
# Aplicar gofmt
gofmt -w .

# Commit y push
git add .
git commit -m "fix: formatear código con gofmt"
git push origin [BRANCH]
```

### Error: Conflictos en merge

```bash
# Resolver manualmente
git merge main
# Editar archivos conflictivos
git add [ARCHIVOS]
git commit -m "fix: resolver conflictos de merge"
git push origin dev
```

### Error: Release no inicia

```bash
# Verificar workflow existe
gh workflow list

# Ver detalles del workflow
cat .github/workflows/manual-release.yml

# Verificar inputs requeridos
# Ejecutar con todos los parámetros necesarios
```

---

## 📝 Notas Importantes

### Versionado

**shared:**
- Usar versionado semántico: vMAJOR.MINOR.PATCH
- MAJOR: Breaking changes
- MINOR: Nuevas features compatibles
- PATCH: Bugfixes

**Proyectos (api-mobile, api-admin, worker):**
- Mismo esquema semántico
- Incrementar según tipo de cambios acumulados

### Timing

- **RULES.md:** Máximo 5 minutos por CI/CD
- **Total esperado:** 2-3 horas para todos los repos
- **Releases Docker:** Continúan ejecutándose (10-15 min cada uno)

### Frecuencia Recomendada

- **Mínimo:** Cada 2 semanas
- **Máximo:** Cada sprint/milestone completado
- **Evitar:** Acumular más de 20-30 commits en dev sin homologar

---

## 🎯 Resultado Esperado

Al finalizar el proceso:

✅ **Sincronización completa**
- main = dev en todos los repos
- Sin PRs abiertos
- Sin ramas obsoletas

✅ **Releases creados**
- shared: 10 módulos con misma versión
- api-mobile: nueva versión + imagen Docker
- api-administracion: nueva versión + imagen Docker
- worker: nueva versión + imagen Docker

✅ **Listo para desarrollo**
- Todos pueden volver a trabajar en dev
- main tiene versión estable
- Imágenes Docker actualizadas disponibles

---

## 📚 Referencias

- **RULES.md** - Reglas del proyecto (leer SIEMPRE)
- **LOGS.md** - Registro de sesiones
- **GitHub Actions** - Para monitorear releases
- **Releases de shared** - `https://github.com/EduGoGroup/edugo-shared/releases`

---

**Última ejecución:** 12 de Noviembre, 2025  
**Próxima homologación:** [PENDIENTE]  
**Responsable:** Equipo de desarrollo  
**Generado con:** Claude Code
