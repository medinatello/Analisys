# 🔄 Flujo Correcto del Sistema de Tracking de Sprints

**Versión:** 2.0  
**Fecha:** 20 de Noviembre, 2025  
**Estado:** Propuesto (basado en análisis de fallas)

---

## 📊 Comparación de Flujos

### ❌ Flujo Actual (Fallido)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. DISEÑO EN ANALISYS                                       │
│    • Crear REGLAS.md                                        │
│    • Crear SPRINT-X-TASKS.md                                │
│    • Crear .sprint-tracking/                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ ⚠️ PROBLEMA: No hay sincronización
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. "INICIAR SPRINT 1"                                       │
│    ❌ Archivos NO existen en repo objetivo                  │
│    ❌ Claude debe crearlos desde cero                        │
│    ❌ 30 minutos perdidos                                    │
│    ❌ Ambigüedad total                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. FASE 1 (con problemas)                                   │
│    • Calificación: 6.7/10                                   │
│    • 7 problemas críticos                                   │
└─────────────────────────────────────────────────────────────┘
```

---

### ✅ Flujo Propuesto (Correcto)

```
┌─────────────────────────────────────────────────────────────┐
│ FASE 0: BOOTSTRAP (NUEVA)                                   │
│ ════════════════════════════════════════════════════════════│
│                                                              │
│ Paso 0.1: Validar Diseño en Analisys                       │
│ ┌──────────────────────────────────────┐                   │
│ │ ✅ REGLAS.md existe                   │                   │
│ │ ✅ SPRINT-X-TASKS.md completo         │                   │
│ │ ✅ Scripts de validación creados      │                   │
│ │ ✅ Patrón de nombres definido         │                   │
│ └──────────────────────────────────────┘                   │
│                                                              │
│ Paso 0.2: Sincronizar a Repo Objetivo                      │
│ ┌──────────────────────────────────────┐                   │
│ │ $ ./scripts/sync-tracking-system.sh  │                   │
│ │     edugo-shared 1                   │                   │
│ │                                       │                   │
│ │ • Copia REGLAS.md                    │                   │
│ │ • Copia SPRINT-1-TASKS.md            │                   │
│ │ • Crea .sprint-tracking/             │                   │
│ │ • Inicializa SPRINT-STATUS.md        │                   │
│ └──────────────────────────────────────┘                   │
│                                                              │
│ Paso 0.3: Detectar Estado del Código                       │
│ ┌──────────────────────────────────────┐                   │
│ │ $ ./scripts/detect-existing-code.sh  │                   │
│ │                                       │                   │
│ │ 📦 logger: EXISTE (95.8% coverage)   │                   │
│ │ 📦 auth: EXISTE (78% coverage)       │                   │
│ │ 📦 common: NO EXISTE                  │                   │
│ │                                       │                   │
│ │ → Guardar en CODE-STATUS.md          │                   │
│ └──────────────────────────────────────┘                   │
│                                                              │
│ Paso 0.4: Pre-flight Check                                 │
│ ┌──────────────────────────────────────┐                   │
│ │ $ ./scripts/pre-flight-check.sh      │                   │
│ │                                       │                   │
│ │ ✅ REGLAS.md en docs/cicd/            │                   │
│ │ ✅ SPRINT-1-TASKS.md en docs/cicd/    │                   │
│ │ ✅ Rama correcta creada               │                   │
│ │ ✅ dev actualizado                    │                   │
│ └──────────────────────────────────────┘                   │
│                                                              │
│ Paso 0.5: Commit de Bootstrap                              │
│ ┌──────────────────────────────────────┐                   │
│ │ $ git add docs/cicd/                 │                   │
│ │ $ git commit -m "chore: bootstrap"   │                   │
│ └──────────────────────────────────────┘                   │
│                                                              │
│ ✅ SOLO SI TODO PASA → Continuar a Fase 1                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ ✅ Sistema listo
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ FASE 1: IMPLEMENTACIÓN                                      │
│ ════════════════════════════════════════════════════════════│
│                                                              │
│ Por cada Tarea:                                             │
│                                                              │
│ ┌─────────────────────────────────────┐                    │
│ │ 1. Leer SPRINT-X-TASKS.md           │                    │
│ │    ✅ Archivo existe (desde Fase 0)  │                    │
│ └─────────────────┬───────────────────┘                    │
│                   │                                          │
│                   ▼                                          │
│ ┌─────────────────────────────────────┐                    │
│ │ 2. Detectar si código existe        │                    │
│ │    (usar CODE-STATUS.md)            │                    │
│ └─────────────────┬───────────────────┘                    │
│                   │                                          │
│           ┌───────┴───────┐                                 │
│           │               │                                 │
│      EXISTE            NO EXISTE                            │
│           │               │                                 │
│           ▼               ▼                                 │
│   ┌───────────┐   ┌──────────────┐                        │
│   │ Validar   │   │ Implementar  │                        │
│   │ cumple    │   │ desde cero   │                        │
│   │ requisitos│   │              │                        │
│   └─────┬─────┘   └──────┬───────┘                        │
│         │                │                                  │
│         │                ▼                                  │
│         │         ┌──────────────┐                         │
│         │         │ Escribir     │                         │
│         │         │ tests        │                         │
│         │         └──────┬───────┘                         │
│         │                │                                  │
│         └────────┬───────┘                                  │
│                  │                                          │
│                  ▼                                          │
│         ┌──────────────────┐                               │
│         │ Validar tarea    │                               │
│         │ (script auto)    │                               │
│         └────────┬─────────┘                               │
│                  │                                          │
│           ┌──────┴──────┐                                  │
│           │             │                                   │
│        PASA          FALLA                                  │
│           │             │                                   │
│           ▼             ▼                                   │
│   ┌──────────┐   ┌──────────┐                             │
│   │ Marcar   │   │ Reintentar│                             │
│   │ ✅ OK     │   │ (max 3x)  │                             │
│   └──────┬───┘   └─────┬────┘                             │
│          │             │                                    │
│          │             └────► DETENER si falla 3x          │
│          │                                                  │
│          ▼                                                  │
│   ┌──────────────┐                                         │
│   │ Commit       │                                         │
│   │ atomico      │                                         │
│   └──────────────┘                                         │
│                                                              │
│ ✅ Todas las tareas completadas → FASE-1-COMPLETE.md       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ FASE 2: RESOLUCIÓN DE STUBS                                 │
│ ════════════════════════════════════════════════════════════│
│                                                              │
│ 1. Leer FASE-1-COMPLETE.md                                  │
│    ✅ Archivo existe (creado en Fase 1)                     │
│                                                              │
│ 2. Listar stubs: grep "✅ (stub)" SPRINT-STATUS.md          │
│                                                              │
│ 3. Por cada stub:                                           │
│    • Verificar servicio disponible                          │
│    • Reemplazar con implementación real                     │
│    • Tests de integración                                   │
│    • Validar con script                                     │
│                                                              │
│ ✅ Todos los stubs resueltos → FASE-2-COMPLETE.md          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ FASE 3: VALIDACIÓN Y CI/CD                                  │
│ ════════════════════════════════════════════════════════════│
│                                                              │
│ 1. Validación local completa                                │
│    • go build ./...                                         │
│    • go test ./...                                          │
│    • golangci-lint run                                      │
│    • coverage >= threshold                                  │
│                                                              │
│ 2. Crear PR                                                 │
│    • Push a rama                                            │
│    • gh pr create                                           │
│                                                              │
│ 3. Monitorear CI/CD (max 5 min)                            │
│    • GitHub Actions                                         │
│    • Si falla → corregir                                    │
│    • Si pasa → merge                                        │
│                                                              │
│ 4. Merge y post-merge validation                           │
│                                                              │
│ ✅ Sprint completado → SPRINT-X-COMPLETE.md                │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Puntos Clave del Nuevo Flujo

### 1. Fase 0 es OBLIGATORIA

```
⚠️ NUNCA iniciar Fase 1 sin completar Fase 0
```

**Razón:** Fase 0 asegura que todos los archivos existan antes de empezar.

### 2. Validación en Cada Paso

```
Cada fase tiene un archivo *-COMPLETE.md que valida completitud
```

**Archivos generados:**
- `FASE-0-COMPLETE.md` → Bootstrap exitoso
- `FASE-1-COMPLETE.md` → Implementación completa
- `FASE-2-COMPLETE.md` → Stubs resueltos
- `FASE-3-VALIDATION.md` → Validación completa
- `SPRINT-X-COMPLETE.md` → Sprint terminado

### 3. Detección Automática de Código

```bash
# Fase 0 genera CODE-STATUS.md
# Fase 1 lo consulta antes de cada tarea

if module_exists && tests_pass && coverage_ok; then
  mark_as_completed_preexisting
else
  implement_from_scratch
fi
```

### 4. Scripts de Validación Automática

```
Cada tarea tiene scripts/validate-task-X.X.sh

Solo se marca como completada si script retorna exit 0
```

### 5. Pre-flight Checks

```bash
# Antes de CADA fase
./scripts/pre-flight-check.sh

# Si falla → DETENER
# Si pasa → CONTINUAR
```

---

## 📋 Checklist de Migración

### Para Migrar del Flujo Antiguo al Nuevo

- [ ] **Crear Fase 0 en todos los planes**
  - [ ] `01-shared/FASE-0-BOOTSTRAP.md`
  - [ ] `02-infrastructure/FASE-0-BOOTSTRAP.md`
  - [ ] `03-api-mobile/FASE-0-BOOTSTRAP.md`
  - [ ] `04-api-administracion/FASE-0-BOOTSTRAP.md`
  - [ ] `05-worker/FASE-0-BOOTSTRAP.md`
  - [ ] `06-dev-environment/FASE-0-BOOTSTRAP.md`

- [ ] **Crear scripts de sincronización**
  - [ ] `scripts/sync-tracking-system.sh`
  - [ ] `scripts/detect-existing-code.sh`
  - [ ] `scripts/pre-flight-check.sh`

- [ ] **Actualizar REGLAS.md**
  - [ ] Agregar sección de pre-requisitos
  - [ ] Agregar manejo de código existente
  - [ ] Especificar rutas absolutas
  - [ ] Documentar fuente de verdad

- [ ] **Completar SPRINT-X-TASKS.md**
  - [ ] Todas las tareas listadas (no solo 1)
  - [ ] Scripts de validación por tarea
  - [ ] Qué hacer si código existe

- [ ] **Crear templates de validación**
  - [ ] `scripts/validate-task-template.sh`
  - [ ] Ejemplos de validación por tipo de tarea

- [ ] **Documentar fuente de verdad**
  - [ ] `docs/cicd/README.md` en template
  - [ ] Explicar diferencia con `docs/isolated/`

---

## 🚀 Ejemplo de Ejecución Completa

### Escenario: Sprint 1 en edugo-shared

```bash
# ════════════════════════════════════════════════════════════
# FASE 0: BOOTSTRAP
# ════════════════════════════════════════════════════════════

# Paso 0.1: Validar diseño
cd /Users/jhoanmedina/source/EduGo/Analisys
ls 00-Projects-Isolated/cicd-analysis/implementation-plans/01-shared/
# ✅ REGLAS.md existe
# ✅ SPRINT-1-TASKS.md existe (15 tareas)
# ✅ .sprint-tracking/ existe

# Paso 0.2: Sincronizar
./scripts/sync-tracking-system.sh edugo-shared 1
# ✅ Archivos copiados a edugo-shared/docs/cicd/

# Paso 0.3: Detectar código
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared
./scripts/detect-existing-code.sh > docs/cicd/.sprint-tracking/CODE-STATUS.md
# 📦 logger: EXISTE (95.8%)
# 📦 auth: EXISTE (78%)
# 📦 common: NO EXISTE

# Paso 0.4: Pre-flight check
./scripts/pre-flight-check.sh
# ✅ Todos los checks pasaron

# Paso 0.5: Commit
git add docs/cicd/
git commit -m "chore(sprint-1): bootstrap tracking system"

# ✅ FASE 0 COMPLETA
echo "Fase 0 completada" > docs/cicd/.sprint-tracking/FASE-0-COMPLETE.md

# ════════════════════════════════════════════════════════════
# FASE 1: IMPLEMENTACIÓN
# ════════════════════════════════════════════════════════════

# Tarea 1.1: Crear backup
git checkout dev && git pull
git checkout -b backup/pre-sprint-1
git push origin backup/pre-sprint-1
git checkout dev
git checkout -b sprint-1-2025-11-20

# Tarea 1.2: Logger (YA EXISTE)
cat docs/cicd/.sprint-tracking/CODE-STATUS.md | grep logger
# 📦 logger: EXISTE (95.8%)

# Validar que cumple requisitos
cd logger
go test -cover ./...
# ok   github.com/EduGoGroup/edugo-shared/logger  0.123s  coverage: 95.8%

# Cumple → Marcar como completada (preexistente)
echo "✅ TASK-1.2 (preexistente, validado)" >> ../docs/cicd/.sprint-tracking/SPRINT-STATUS.md

# Commit
git commit -m "chore(sprint-1): validate existing logger module"

# Tarea 1.3: Common (NO EXISTE)
cat docs/cicd/.sprint-tracking/CODE-STATUS.md | grep common
# 📦 common: NO EXISTE

# Implementar desde cero
mkdir common
# ... implementar código ...
# ... escribir tests ...

# Validar con script
./scripts/validate-task-1.3.sh
# ✅ TASK-1.3 VALIDADA EXITOSAMENTE

# Marcar como completada
echo "✅ TASK-1.3" >> docs/cicd/.sprint-tracking/SPRINT-STATUS.md

# Commit
git commit -m "feat(sprint-1): implement common module"

# ... repetir para todas las tareas ...

# ✅ FASE 1 COMPLETA
cat > docs/cicd/.sprint-tracking/FASE-1-COMPLETE.md << EOF
# Fase 1 Completada

- Tareas: 15/15 ✅
- Con stubs: 2 (RabbitMQ, PostgreSQL)
- Código preexistente validado: 3 módulos
- Código nuevo: 4 módulos

Próximo: Fase 2 (resolver stubs)
EOF

# ════════════════════════════════════════════════════════════
# FASE 2: STUBS
# ════════════════════════════════════════════════════════════

# Listar stubs
grep "(stub)" docs/cicd/.sprint-tracking/SPRINT-STATUS.md
# ✅ TASK-5 (stub) - RabbitMQ
# ✅ TASK-8 (stub) - PostgreSQL

# Resolver cada stub
docker-compose up -d rabbitmq postgres

# Implementar RabbitMQ real
cd messaging/rabbit
# ... reemplazar stub con código real ...
go test ./...  # tests de integración
# ok

# Marcar
sed -i 's/TASK-5 (stub)/TASK-5 (real)/' ../../docs/cicd/.sprint-tracking/SPRINT-STATUS.md

# ... repetir para PostgreSQL ...

# ✅ FASE 2 COMPLETA
cat > docs/cicd/.sprint-tracking/FASE-2-COMPLETE.md << EOF
# Fase 2 Completada

- Stubs resueltos: 2/2 ✅
- Tests de integración: PASAN ✅

Próximo: Fase 3 (validación y CI/CD)
EOF

# ════════════════════════════════════════════════════════════
# FASE 3: VALIDACIÓN
# ════════════════════════════════════════════════════════════

# Validación local
go build ./...        # ✅
go test ./...         # ✅
golangci-lint run     # ✅
go test -cover ./...  # ✅ 85% (>threshold 70%)

# Push y PR
git push origin sprint-1-2025-11-20
gh pr create --base dev --title "Sprint 1: Fundamentos" --body "..."

# Monitorear CI/CD
gh pr checks
# ✅ ci.yml: passing
# ✅ test.yml: passing

# Merge
gh pr merge --merge

# Post-merge validation
git checkout dev && git pull
gh run list --branch dev --limit 1
# ✅ completed, success

# ✅ SPRINT COMPLETO
cat > docs/cicd/.sprint-tracking/SPRINT-1-COMPLETE.md << EOF
# Sprint 1 Completado

- Duración: 3 días
- Tareas: 15/15 ✅
- PR: #42 ✅
- CI/CD: ✅
- Merged a dev: ✅

¡Sprint exitoso! 🎉
EOF
```

---

## 📊 Comparación de Resultados

### Antes (Sin Fase 0)

```
┌────────────────────────────────────┐
│ Fase 1: 6.7/10                     │
│ • 30 min perdidos creando sistema  │
│ • 7 problemas críticos             │
│ • Ambigüedad total                 │
└────────────────────────────────────┘
```

### Después (Con Fase 0)

```
┌────────────────────────────────────┐
│ Fase 0: 10 min                     │
│ Fase 1: 9.5/10                     │
│ • 0 min perdidos                   │
│ • 0 problemas críticos             │
│ • Claridad total                   │
└────────────────────────────────────┘
```

**ROI:** Invertir 10 min en Fase 0 ahorra 30+ min en Fase 1 y elimina ambigüedades.

---

## 🎯 Conclusión

El nuevo flujo con **Fase 0 (Bootstrap)** resuelve todos los problemas identificados:

✅ Archivos existen antes de iniciar  
✅ Estado del código detectado automáticamente  
✅ Una sola fuente de verdad documentada  
✅ Validaciones automáticas en cada paso  
✅ Scripts reutilizables entre proyectos  

**Resultado esperado:** Sistema robusto con calificación >9.5/10 en todas las fases.

---

**Generado con:** Claude Code (Sonnet 4.5)  
**Fecha:** 20 de Noviembre, 2025  
**Basado en:** Análisis de fallas del sistema actual
