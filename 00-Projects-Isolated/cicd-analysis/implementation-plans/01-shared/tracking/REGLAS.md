# Reglas de Ejecución de Sprints

**Proyecto:** edugo-shared  
**Fecha:** 20 de Noviembre, 2025  
**Propósito:** Reglas y procedimientos para ejecutar sprints de manera consistente y controlada

---

## 🎯 Principios Fundamentales

### 1. Tarea Completada = Tarea Marcada
- ✅ **SIEMPRE** marcar una tarea como completada inmediatamente después de terminarla
- ✅ Actualizar `SPRINT-STATUS.md` en tiempo real
- ✅ No agrupar múltiples tareas antes de marcar

### 2. Código que Compila
- ✅ Después de cada tarea que toca código: `go build ./...`
- ✅ Después de cada tarea que toca código: `go test ./...`
- ✅ Si falla compilación o tests: **DETENER** y resolver antes de continuar

### 3. Branch Strategy
- ✅ **SIEMPRE** trabajar desde rama `dev`
- ✅ Crear feature branch: `sprint-X-YYYY-MM-DD` desde `dev`
- ✅ PR siempre a `dev`, nunca directo a `main`

### 4. Bloqueos por Dependencias Externas
- ✅ Si una tarea requiere Docker/BD/RabbitMQ y no está disponible:
  - Implementar con **stub** o **mock**
  - Documentar en `decisions/TASK-XX-BLOCKED.md`
  - Marcar tarea como "✅ (con stub)" en SPRINT-STATUS.md
- ✅ En Fase 2 se resuelven todos los stubs

### 5. Documentación de Errores
- ✅ Cada error que toma >10 min resolver se documenta en `errors/ERROR-YYYY-MM-DD-HH-MM.md`
- ✅ Incluir: síntoma, causa raíz, intentos de solución, solución final

---

## 📋 Estructura de 3 Fases

### FASE 1: Implementación con Stubs
**Objetivo:** Completar todas las tareas del sprint, usando stubs/mocks cuando sea necesario

#### Paso 1.1: Análisis Pre-Sprint
```bash
# Leer y entender el sprint
cat ../sprints/SPRINT-X-TASKS.md

# Leer documentación del proyecto
cat ../README.md
cat ../docs/QUICK-START.md
cat ../INDEX.md
```

#### Paso 1.2: Preparación de Rama
```bash
# Asegurar que dev está actualizado
git checkout dev
git pull origin dev

# Crear feature branch
git checkout -b sprint-X-$(date +%Y-%m-%d)

# Registrar inicio
echo "Sprint X iniciado: $(date)" >> logs/SPRINT-X-LOG.md
```

#### Paso 1.3: Ejecución Tarea por Tarea
**Por cada tarea:**

1. Leer la tarea en `../sprints/SPRINT-X-TASKS.md`
2. Marcar como "🔄 En progreso" en `SPRINT-STATUS.md`
3. Ejecutar la tarea
4. **SI** requiere dependencia externa (Docker, BD, etc.):
   - Implementar con stub/mock
   - Crear archivo `decisions/TASK-XX-BLOCKED.md`
   - Marcar como "✅ (stub)" en SPRINT-STATUS.md
5. **SI** NO requiere dependencia externa:
   - Implementar completamente
   - Marcar como "✅" en SPRINT-STATUS.md
6. **SIEMPRE** después de modificar código:
   ```bash
   go build ./...
   go test ./...
   ```
7. **SI** compilación o tests fallan:
   - Resolver inmediatamente
   - Documentar si toma >10 min
8. Commit de la tarea:
   ```bash
   git add .
   git commit -m "feat(sprint-X): completar tarea XX - [nombre tarea]"
   ```

#### Paso 1.4: Revisión de Código (Fase 1)
```bash
# Delegar a subagente para revisión de código
# El subagente debe:
# - Buscar mejoras obvias
# - Identificar code smells
# - Sugerir optimizaciones
# - Documentar en reviews/FASE-1-REVIEW.md
```

#### Paso 1.5: Cierre de Fase 1
```markdown
# Crear archivo ./FASE-1-COMPLETE.md
- Lista de tareas completadas
- Lista de tareas con stubs (para Fase 2)
- Comentarios para Fase 2
- Código compilando: [SÍ/NO]
- Tests pasando: [SÍ/NO]
```

---

### FASE 2: Resolución de Stubs/Mocks
**Objetivo:** Reemplazar todos los stubs/mocks con implementaciones reales

#### Paso 2.1: Análisis de Stubs
```bash
# Leer documentación de Fase 1
cat ./FASE-1-COMPLETE.md

# Listar todos los stubs
grep -r "✅ (stub)" ./SPRINT-STATUS.md

# Leer cada decisión de bloqueo
ls ./decisions/TASK-*-BLOCKED.md
```

#### Paso 2.2: Verificar Disponibilidad de Recursos
```bash
# Verificar Docker
docker ps

# Verificar PostgreSQL (si aplica)
docker-compose ps postgres

# Verificar RabbitMQ (si aplica)
docker-compose ps rabbitmq
```

#### Paso 2.3: Reemplazar Stubs
**Por cada stub:**

1. Leer `decisions/TASK-XX-BLOCKED.md`
2. Verificar que el recurso externo está disponible
3. **SI** disponible:
   - Eliminar stub/mock
   - Implementar código real
   - Ejecutar tests de integración
   - Actualizar SPRINT-STATUS.md: "✅ (stub)" → "✅ (real)"
4. **SI** NO disponible:
   - Documentar razón en FASE-2-COMPLETE.md
   - Mantener stub (marcarlo como "⚠️ stub permanente")
5. Commit:
   ```bash
   git add .
   git commit -m "refactor(sprint-X): reemplazar stub tarea XX con implementación real"
   ```

#### Paso 2.4: Revisión de Código (Fase 2)
```bash
# Delegar a subagente para revisión
# Enfocarse en:
# - Manejo correcto de recursos externos
# - Error handling robusto
# - Tests de integración completos
# - Documentar en reviews/FASE-2-REVIEW.md
```

#### Paso 2.5: Manejo de Errores en Fase 2
**SI encuentras errores:**

1. Crear archivo: `errors/ERROR-YYYY-MM-DD-HH-MM.md`
2. Contenido:
   ```markdown
   # Error: [Descripción breve]
   
   **Fecha:** YYYY-MM-DD HH:MM
   **Tarea:** XX
   **Fase:** 2
   
   ## Síntoma
   [Qué falló]
   
   ## Causa Raíz
   [Por qué falló]
   
   ## Intentos de Solución
   1. Intento 1: [descripción] → [resultado]
   2. Intento 2: [descripción] → [resultado]
   ...
   
   ## Solución Final
   [Qué funcionó]
   
   ## Aprendizaje
   [Qué aprendimos]
   ```
3. **SI** se intenta >3 veces sin éxito:
   - Documentar estado actual
   - **DETENER**
   - Informar al usuario con resumen completo

#### Paso 2.6: Cierre de Fase 2
```markdown
# Crear archivo ./FASE-2-COMPLETE.md
- Stubs resueltos: [X/Y]
- Stubs permanentes: [lista con razón]
- Errores encontrados: [X]
- Errores resueltos: [X]
- Código compilando: [SÍ/NO]
- Tests pasando: [SÍ/NO]
- Tests de integración pasando: [SÍ/NO]
```

---

### FASE 3: Validación, CI/CD y Merge
**Objetivo:** Validar todo, crear PR, pasar CI/CD, mergear a dev

#### Paso 3.1: Validación Local Completa
```bash
# Compilación
go build ./...
echo "Build status: $?" >> ./FASE-3-VALIDATION.md

# Tests unitarios
go test ./... -v
echo "Unit tests status: $?" >> ./FASE-3-VALIDATION.md

# Tests de integración (si existen)
go test ./... -tags=integration -v
echo "Integration tests status: $?" >> ./FASE-3-VALIDATION.md

# Linter
golangci-lint run ./...
echo "Lint status: $?" >> ./FASE-3-VALIDATION.md

# Coverage
go test ./... -coverprofile=coverage.out
go tool cover -func=coverage.out
echo "Coverage: $(go tool cover -func=coverage.out | grep total | awk '{print $3}')" >> ./FASE-3-VALIDATION.md
```

**SI algo falla:**
- ❌ **DETENER**
- Resolver antes de continuar
- Documentar en `errors/` si es necesario

#### Paso 3.2: Push y Crear PR
```bash
# Push de la feature branch
git push origin sprint-X-$(date +%Y-%m-%d)

# Crear PR usando gh CLI
gh pr create \
  --base dev \
  --head sprint-X-$(date +%Y-%m-%d) \
  --title "Sprint X: [Título del sprint]" \
  --body "$(cat ./PR-DESCRIPTION.md)"
```

#### Paso 3.3: Monitorear CI/CD (Máximo 5 minutos)
```bash
# Esperar y monitorear
for i in {1..5}; do
  echo "Minuto $i de 5..."
  
  # Obtener estado del PR
  gh pr status
  
  # Verificar checks
  gh pr checks
  
  # Si todos pasaron, salir del loop
  if gh pr checks | grep -q "All checks have passed"; then
    echo "✅ Todos los checks pasaron en minuto $i"
    break
  fi
  
  # Si aún hay checks corriendo
  if [ $i -eq 5 ]; then
    echo "⚠️ Checks aún corriendo después de 5 minutos"
    echo "DETENER e informar al usuario"
    exit 1
  fi
  
  sleep 60
done
```

#### Paso 3.4: Revisar Comentarios de Copilot
```bash
# Obtener comentarios del PR
gh pr view --comments > ./reviews/COPILOT-COMMENTS.md

# Analizar comentarios
# Clasificar en:
# 1. CRÍTICOS (errores, bugs, vulnerabilidades)
# 2. MEJORAS (refactoring, optimizaciones)
# 3. TRADUCCIONES (español → inglés)
# 4. NO PROCEDE (falsos positivos, mala interpretación)
```

**Reglas para comentarios:**

1. **CRÍTICOS:**
   - ✅ Resolver inmediatamente
   - ✅ Push de fix
   - ✅ Reiniciar monitoreo (5 min máx)

2. **TRADUCCIONES (español → inglés):**
   - ❌ **DESCARTAR** (no resolver)
   - Documentar en `./reviews/DISCARDED-COMMENTS.md`

3. **MEJORAS:**
   - Estimar puntos Fibonacci (1, 2, 3, 5, 8, 13...)
   - **SI** <= 3 puntos: Resolver inmediatamente
   - **SI** > 3 puntos:
     - Documentar en `./decisions/MEJORA-FUTURA.md`
     - **DETENER**
     - Informar al usuario con opciones:
       - a) Resolver ahora (ampliar sprint)
       - b) Crear issue para futuro
       - c) Ignorar

4. **NO PROCEDE:**
   - Documentar en `./reviews/DISCARDED-COMMENTS.md`
   - **SI** consideras relevante: Informar al usuario y DETENER
   - **SI** NO es relevante: Informar al usuario pero CONTINUAR

#### Paso 3.5: Merge a Dev
```bash
# SI todos los checks pasaron
# Y comentarios críticos resueltos
# Y comentarios de mejora <= 3 puntos resueltos

gh pr merge --merge --delete-branch
```

#### Paso 3.6: Monitorear CI/CD Post-Merge (Máximo 5 minutos)
```bash
# Cambiar a dev
git checkout dev
git pull origin dev

# Monitorear últimos workflows
gh run list --branch dev --limit 5

# Esperar hasta 5 minutos
for i in {1..5}; do
  echo "Post-merge minuto $i de 5..."
  
  # Ver estado del último run
  gh run view --log-failed
  
  # Si completó exitosamente
  if gh run list --branch dev --limit 1 | grep -q "completed.*success"; then
    echo "✅ CI/CD post-merge exitoso en minuto $i"
    break
  fi
  
  # Si falla
  if gh run list --branch dev --limit 1 | grep -q "completed.*failure"; then
    echo "❌ CI/CD post-merge falló"
    echo "DETENER e informar al usuario"
    exit 1
  fi
  
  # Si aún corriendo después de 5 min
  if [ $i -eq 5 ]; then
    echo "⚠️ CI/CD aún corriendo después de 5 minutos post-merge"
    echo "DETENER e informar al usuario"
    exit 1
  fi
  
  sleep 60
done
```

#### Paso 3.7: PR a Main (Solo si usuario lo pide)
**SI el usuario solicita PR a main:**

```bash
# Crear PR de dev a main
gh pr create \
  --base main \
  --head dev \
  --title "Release: Sprint X - [Título]" \
  --body "$(cat ./RELEASE-NOTES.md)"

# Repetir proceso de monitoreo (Paso 3.3)
# Repetir revisión de comentarios (Paso 3.4)
# Merge si todo pasa
gh pr merge --merge

# Monitorear post-merge en main (Paso 3.6)
```

#### Paso 3.8: Release Manual (Solo si usuario lo pide)
**SI el usuario solicita release:**

```bash
# Obtener última versión
LAST_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Incrementar versión (ejemplo: v0.1.0 → v0.1.1)
NEW_VERSION=$(echo $LAST_VERSION | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')

# Crear tag
git tag -a $NEW_VERSION -m "Release $NEW_VERSION - Sprint X"
git push origin $NEW_VERSION

# Crear release en GitHub
gh release create $NEW_VERSION \
  --title "Release $NEW_VERSION" \
  --notes "$(cat ./RELEASE-NOTES.md)"
```

#### Paso 3.9: Sincronización Final
```bash
# Verificar que main y dev están iguales
git checkout main
git pull origin main
MAIN_SHA=$(git rev-parse HEAD)

git checkout dev
git pull origin dev
DEV_SHA=$(git rev-parse HEAD)

if [ "$MAIN_SHA" == "$DEV_SHA" ]; then
  echo "✅ main y dev sincronizados"
else
  echo "⚠️ main y dev NO están sincronizados"
  echo "main: $MAIN_SHA"
  echo "dev: $DEV_SHA"
  
  # Fast-forward dev a main
  git merge main --ff-only
  git push origin dev
fi

# Actualizar dev local
git checkout dev
git pull origin dev

echo "✅ Sprint X completado exitosamente"
```

#### Paso 3.10: Cierre de Sprint
```markdown
# Crear archivo ./SPRINT-X-COMPLETE.md
- Fecha inicio: [YYYY-MM-DD]
- Fecha fin: [YYYY-MM-DD]
- Duración: [X horas/días]
- Tareas completadas: [X/Y]
- Stubs resueltos: [X/Y]
- Errores encontrados: [X]
- PR creado: [#XX]
- Mergeado a dev: [SÍ/NO]
- Mergeado a main: [SÍ/NO]
- Release creado: [vX.Y.Z] o [N/A]
- Comentarios Copilot: [X críticos, Y mejoras, Z descartados]
```

---

## 📁 Estructura de Archivos de Seguimiento

```
./
├── REGLAS.md                         ← Este archivo
├── SPRINT-STATUS.md                  ← Estado actual de tareas
├── FASE-1-COMPLETE.md               ← Cierre de Fase 1
├── FASE-2-COMPLETE.md               ← Cierre de Fase 2
├── FASE-3-VALIDATION.md             ← Validaciones de Fase 3
├── SPRINT-X-COMPLETE.md             ← Cierre completo del sprint
├── PR-DESCRIPTION.md                 ← Template de PR
├── RELEASE-NOTES.md                  ← Notas de release
│
├── logs/
│   └── SPRINT-X-LOG.md              ← Log detallado del sprint
│
├── errors/
│   └── ERROR-YYYY-MM-DD-HH-MM.md    ← Documentación de errores
│
├── decisions/
│   ├── TASK-XX-BLOCKED.md           ← Decisiones de stubs
│   └── MEJORA-FUTURA.md             ← Mejoras pospuestas
│
└── reviews/
    ├── FASE-1-REVIEW.md             ← Revisión de código Fase 1
    ├── FASE-2-REVIEW.md             ← Revisión de código Fase 2
    ├── COPILOT-COMMENTS.md          ← Comentarios de Copilot
    └── DISCARDED-COMMENTS.md        ← Comentarios descartados
```

---

## 🚨 Casos de Error y DETENER

### Cuándo DETENER e informar al usuario:

1. ❌ Compilación falla después de intentar resolver 3 veces
2. ❌ Tests fallan después de intentar resolver 3 veces
3. ❌ CI/CD toma más de 5 minutos
4. ❌ CI/CD falla en PR
5. ❌ CI/CD falla post-merge
6. ❌ Copilot sugiere mejora >3 puntos Fibonacci
7. ❌ Error toma >30 minutos resolver
8. ❌ No se puede acceder a recurso externo en Fase 2 y no hay alternativa

### Qué incluir al DETENER:

```markdown
# Reporte de Detención

**Fecha:** [YYYY-MM-DD HH:MM]
**Fase:** [1/2/3]
**Tarea:** [XX]
**Razón:** [Descripción]

## Estado Actual
- Tareas completadas: [X/Y]
- Última tarea exitosa: [XX]
- Tarea problemática: [XX]

## Problema Detectado
[Descripción detallada]

## Intentos de Solución
1. [Intento 1]
2. [Intento 2]
3. [Intento 3]

## Opciones para el Usuario
a) [Opción 1]
b) [Opción 2]
c) [Opción 3]

## Archivos Relevantes
- Error log: [ruta]
- Decisiones: [ruta]
- Código problemático: [ruta]
```

---

## ✅ Checklist Rápido por Fase

### Fase 1:
- [ ] Rama creada desde dev actualizado
- [ ] Cada tarea marcada al completarse
- [ ] Código compila después de cada cambio
- [ ] Tests pasan después de cada cambio
- [ ] Stubs documentados en decisions/
- [ ] Revisión de código completada
- [ ] FASE-1-COMPLETE.md creado

### Fase 2:
- [ ] Todos los stubs identificados
- [ ] Recursos externos verificados
- [ ] Stubs reemplazados o documentados como permanentes
- [ ] Tests de integración pasando
- [ ] Errores documentados en errors/
- [ ] Revisión de código completada
- [ ] FASE-2-COMPLETE.md creado

### Fase 3:
- [ ] Build exitoso
- [ ] Tests unitarios exitosos
- [ ] Tests integración exitosos (si aplica)
- [ ] Lint sin errores
- [ ] Coverage >= umbral del proyecto
- [ ] PR creado
- [ ] CI/CD pasó (<5 min)
- [ ] Comentarios Copilot resueltos
- [ ] Mergeado a dev
- [ ] CI/CD post-merge exitoso (<5 min)
- [ ] (Opcional) PR a main y release
- [ ] dev y main sincronizados
- [ ] SPRINT-X-COMPLETE.md creado

---

**Última actualización:** 20 de Noviembre, 2025  
**Generado por:** Claude Code  
**Versión:** 1.0
