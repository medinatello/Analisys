# Cronograma General - Implementación CI/CD Ecosistema EduGo

**Fecha:** 19 de Noviembre, 2025  
**Duración Total:** 4 semanas (20 días laborables)  
**Esfuerzo Total:** 120-150 horas  
**Proyectos:** 6 repositorios

---

## 🎯 Visión General

### Estrategia de Implementación

**Por Sprints:** 4 sprints de 1 semana cada uno  
**Por Prioridad:** Críticos primero, optimizaciones después  
**Por Dependencias:** Base → Consumidores  
**Paralelismo:** Algunos proyectos pueden trabajarse en paralelo

---

## 📅 Sprint 1: Fundamentos y Base (Semana 1)

**Fechas:** 20-24 Noviembre, 2025  
**Objetivo:** Estabilizar librerías base del ecosistema  
**Proyectos:** shared, infrastructure  
**Prioridad:** 🔴 CRÍTICA

### Día 1 (Lunes) - Análisis y Preparación

**infrastructure (Mañana - 4h):**
- [ ] 🔴 Analizar logs de 8 fallos consecutivos (2h)
- [ ] 🔴 Reproducir fallos localmente (2h)

**shared (Tarde - 4h):**
- [ ] 🟡 Backup completo del proyecto (30m)
- [ ] 🟡 Migrar a Go 1.25 (2h)
- [ ] 🟡 Validación local completa (1.5h)

**Total Día 1:** 8h

---

### Día 2 (Martes) - Resolver Fallos Críticos

**infrastructure (Mañana - 4h):**
- [ ] 🔴 Aplicar corrección según causa identificada (2h)
- [ ] 🔴 Validar fix localmente (1h)
- [ ] 🔴 Crear PR de corrección (1h)

**shared (Tarde - 3h):**
- [ ] 🟡 Crear PR de migración Go 1.25 (30m)
- [ ] 🟡 Corregir "fallos fantasma" en test.yml (1h)
- [ ] 🟡 Validar CI/CD pasa (1.5h)

**Total Día 2:** 7h

---

### Día 3 (Miércoles) - Estandarización

**infrastructure (Mañana - 3h):**
- [ ] 🟡 Validar CI/CD pasa (1h)
- [ ] 🟡 Migrar a Go 1.25 (1h)
- [ ] 🟡 Merge de correcciones (1h)

**shared (Tarde - 4h):**
- [ ] 🟡 Pre-commit hooks (2h)
- [ ] 🟡 Coverage thresholds por módulo (1.5h)
- [ ] 🟡 Documentación (30m)

**Total Día 3:** 7h

---

### Día 4 (Jueves) - Releases por Módulo

**shared (Todo el día - 6h):**
- [ ] 🟡 Crear workflow release-module.yml (3h)
- [ ] 🟡 Crear archivo versions.json (30m)
- [ ] 🟡 Crear workflow auto-release-modules.yml (2h)
- [ ] 🟡 Probar release manual de un módulo (30m)

**infrastructure (paralelo si hay tiempo - 2h):**
- [ ] 🟢 Pre-commit hooks (1h)
- [ ] 🟢 Documentación de workflows (1h)

**Total Día 4:** 6-8h

---

### Día 5 (Viernes) - Validación y Cierre Sprint 1

**shared (Mañana - 3h):**
- [ ] 🟢 Testing final completo (1.5h)
- [ ] 🟢 Documentación final (1h)
- [ ] 🟢 Merge a dev (30m)

**infrastructure (Tarde - 2h):**
- [ ] 🟢 Validación final (1h)
- [ ] 🟢 Merge a dev (1h)

**Retrospectiva Sprint 1 (1h):**
- [ ] Revisar métricas de éxito
- [ ] Documentar aprendizajes
- [ ] Preparar Sprint 2

**Total Día 5:** 6h

---

**TOTAL SPRINT 1:** 34-36 horas

**Resultado Esperado:**
- ✅ infrastructure: 20% → 95%+ success rate
- ✅ shared: Go 1.25 estandarizado, releases por módulo
- ✅ Ambos: Pre-commit hooks, documentación

---

## 📅 Sprint 2: APIs Principales (Semana 2)

**Fechas:** 27-1 Diciembre, 2025  
**Objetivo:** Migrar y optimizar APIs  
**Proyectos:** api-mobile (piloto), api-administracion  
**Prioridad:** 🟡 ALTA

### Día 1 (Lunes) - api-mobile Piloto

**api-mobile (Todo el día - 6-7h):**
- [ ] 🟡 Preparación y backup (30m)
- [ ] 🟡 Migrar a Go 1.25 (PILOTO) (1h)
- [ ] 🟡 Validación local exhaustiva (1h)
- [ ] 🟡 Crear PR y validar CI/CD (1.5h)
- [ ] 🟡 Implementar paralelismo en pr-to-dev.yml (2h)

**Total Día 1:** 6-7h

---

### Día 2 (Martes) - api-mobile Optimización

**api-mobile (Todo el día - 6-7h):**
- [ ] 🟡 Paralelismo en pr-to-main.yml (2.5h)
- [ ] 🟡 Pre-commit hooks (1.5h)
- [ ] 🟡 Corregir 23 errores de lint (1.5h)
- [ ] 🟡 Control releases por variable (1h)

**Total Día 2:** 6-7h

---

### Día 3 (Miércoles) - api-administracion Críticos

**api-administracion (Todo el día - 7-8h):**
- [ ] 🔴 Investigar fallos en release.yml (2h)
- [ ] 🔴 Aplicar fix según causa (2h)
- [ ] 🔴 Eliminar workflow Docker duplicado (1h)
- [ ] 🔴 Crear pr-to-main.yml (2h)
- [ ] 🔴 Validar CI/CD (1h)

**Total Día 3:** 7-8h

---

### Día 4 (Jueves) - api-administracion Migración

**api-administracion (Todo el día - 5-6h):**
- [ ] 🟡 Migrar a Go 1.25 (basado en api-mobile) (1h)
- [ ] 🟡 Pre-commit hooks (1h)
- [ ] 🟡 GitHub App token (1h)
- [ ] 🟡 Control releases por variable (1h)
- [ ] 🟡 Validación completa (1-2h)

**Total Día 4:** 5-6h

---

### Día 5 (Viernes) - Validación y Cierre Sprint 2

**Ambas APIs (3h cada una - 6h total):**
- [ ] 🟢 Testing exhaustivo (1.5h cada una)
- [ ] 🟢 Documentación (1h cada una)
- [ ] 🟢 Merge a dev (30m cada una)

**Retrospectiva Sprint 2 (1h):**
- [ ] Comparar api-mobile vs api-administracion
- [ ] Validar que Go 1.25 funcionó bien
- [ ] Preparar Sprint 3

**Total Día 5:** 7h

---

**TOTAL SPRINT 2:** 31-35 horas

**Resultado Esperado:**
- ✅ api-mobile: Paralelismo, Go 1.25, 0 errores lint
- ✅ api-administracion: 40% → 90%+ success, Docker consolidado
- ✅ Ambas: Pre-commit hooks, releases controladas

---

## 📅 Sprint 3: Worker y Utilidades (Semana 3)

**Fechas:** 4-8 Diciembre, 2025  
**Objetivo:** Completar migración del ecosistema  
**Proyectos:** worker, dev-environment  
**Prioridad:** 🟡 MEDIA

### Día 1 (Lunes) - worker Consolidación Docker

**worker (Todo el día - 7-8h):**
- [ ] 🔴 Análisis completo de 3 workflows Docker (2h)
- [ ] 🔴 Backup de workflows a eliminar (30m)
- [ ] 🔴 Consolidar en manual-release.yml (2h)
- [ ] 🔴 Eliminar build-and-push.yml y docker-only.yml (1h)
- [ ] 🔴 Validar consolidación (1.5h)
- [ ] 🔴 Crear PR (30m)

**Total Día 1:** 7-8h

---

### Día 2 (Martes) - worker Migración Go

**worker (Todo el día - 5-6h):**
- [ ] 🟡 Migrar a Go 1.25 (consistencia) (1h)
- [ ] 🟡 Agregar coverage threshold 33% (1h)
- [ ] 🟡 Pre-commit hooks (1.5h)
- [ ] 🟡 Validar CI/CD pasa (1.5h)
- [ ] 🟡 Merge a dev (30m)

**Total Día 2:** 5-6h

---

### Día 3 (Miércoles) - dev-environment (Opcional)

**dev-environment (Medio día - 2-3h):**
- [ ] 🟢 Mejorar README.md (1h)
- [ ] 🟢 Script de validación docker-compose (30m)
- [ ] 🟢 Documentar por qué no tiene CI/CD (30m)
- [ ] 🟢 Crear PR (30m)

**Retrospectiva Sprint 3 (1h):**
- [ ] Validar worker estable
- [ ] Confirmar Go 1.25 en 5/6 proyectos
- [ ] Preparar Sprint 4

**Total Día 3:** 3-4h

---

**TOTAL SPRINT 3:** 15-18 horas (3 días)

**Resultado Esperado:**
- ✅ worker: 3 workflows Docker → 1, Go 1.25, coverage 33%
- ✅ dev-environment: Documentado, validación opcional
- ✅ Ecosistema: 5/6 proyectos en Go 1.25

---

## 📅 Sprint 4: Workflows Reusables (Semana 4)

**Fechas:** 11-15 Diciembre, 2025  
**Objetivo:** Centralizar y eliminar duplicación  
**Proyectos:** TODOS (usando infrastructure como base)  
**Prioridad:** 🟢 MEDIA-ALTA

### Día 1 (Lunes) - Crear Workflows Reusables Base

**infrastructure (Todo el día - 7-8h):**
- [ ] 🟢 Crear estructura .github/workflows/reusable/ (30m)
- [ ] 🟢 Crear sync-branches.yml reusable (2h)
- [ ] 🟢 Crear go-test.yml reusable (2h)
- [ ] 🟢 Crear go-lint.yml reusable (1.5h)
- [ ] 🟢 Documentación de reusables (1h)
- [ ] 🟢 Testing de workflows reusables (1h)

**Total Día 1:** 7-8h

---

### Día 2 (Martes) - Crear Composite Actions

**infrastructure (Todo el día - 7-8h):**
- [ ] 🟢 Crear setup-edugo-go composite action (2h)
- [ ] 🟢 Crear docker-build-edugo composite action (2.5h)
- [ ] 🟢 Crear coverage-check composite action (1.5h)
- [ ] 🟢 Testing de composite actions (1h)
- [ ] 🟢 Documentación completa (1h)

**Total Día 2:** 7-8h

---

### Día 3 (Miércoles) - Migrar Proyecto Piloto

**api-mobile (Todo el día - 6-7h):**
- [ ] 🟢 Migrar sync-main-to-dev.yml (1h)
- [ ] 🟢 Migrar setup Go en todos los workflows (1.5h)
- [ ] 🟢 Migrar Docker build en manual-release (1.5h)
- [ ] 🟢 Testing exhaustivo (2h)
- [ ] 🟢 Crear PR (30m)

**Total Día 3:** 6-7h

---

### Día 4 (Jueves) - Migrar Resto de Proyectos

**TODOS (en paralelo si hay múltiples personas - 8-10h):**

**shared (2-3h):**
- [ ] 🟢 Migrar a composite actions (1.5h)
- [ ] 🟢 Migrar sync workflow (1h)

**api-administracion (2-3h):**
- [ ] 🟢 Copiar patrón de api-mobile (1.5h)
- [ ] 🟢 Validar (1h)

**worker (2-3h):**
- [ ] 🟢 Migrar workflows (1.5h)
- [ ] 🟢 Validar (1h)

**infrastructure (1h):**
- [ ] 🟢 Migrar sync workflow (1h)

**Total Día 4:** 7-10h (dependiendo de paralelización)

---

### Día 5 (Viernes) - Validación Final y Cierre

**Validación Ecosistema Completo (4-5h):**
- [ ] 🟢 Ejecutar CI/CD en los 6 proyectos (2h)
- [ ] 🟢 Validar workflows reusables funcionan (1h)
- [ ] 🟢 Medir métricas de mejora (1h)
- [ ] 🟢 Documentación final (1h)

**Retrospectiva Sprint 4 (2h):**
- [ ] Calcular reducción de código duplicado
- [ ] Medir mejoras de tiempo
- [ ] Documentar patrón para futuros proyectos
- [ ] Crear guía de mantenimiento

**Total Día 5:** 6-7h

---

**TOTAL SPRINT 4:** 33-40 horas

**Resultado Esperado:**
- ✅ 4 workflows reusables creados
- ✅ 3 composite actions creadas
- ✅ 6 proyectos migrados
- ✅ 70% → 20% código duplicado

---

## 📊 Resumen por Proyecto y Sprint

### Matriz de Participación

| Proyecto | Sprint 1 | Sprint 2 | Sprint 3 | Sprint 4 | Total Horas |
|----------|----------|----------|----------|----------|-------------|
| **shared** | ✅ 18-22h | - | - | ✅ 2-3h | 20-25h |
| **infrastructure** | ✅ 12-16h | - | - | ✅ 14-16h | 26-32h |
| **api-mobile** | - | ✅ 12-14h | - | ✅ 6-7h | 18-21h |
| **api-administracion** | - | ✅ 12-14h | - | ✅ 2-3h | 14-17h |
| **worker** | - | - | ✅ 12-14h | ✅ 2-3h | 14-17h |
| **dev-environment** | - | - | ✅ 2-3h | - | 2-3h |
| **TOTAL** | **30-38h** | **24-28h** | **14-17h** | **26-32h** | **94-115h** |

---

## 🎯 Tareas Cross-Project

### Estas tareas se repiten en TODOS (o casi todos) los proyectos:

**Cross-1: Migrar a Go 1.25**
- Proyectos: shared, infrastructure, api-mobile, api-administracion, worker
- Sprint: 1, 2, 3
- Tiempo total: ~6h (1-1.5h por proyecto)

**Cross-2: Pre-commit Hooks**
- Proyectos: TODOS (6)
- Sprint: 1, 2, 3
- Tiempo total: ~7h (1-1.5h por proyecto)

**Cross-3: Control Releases con Variables**
- Proyectos: api-mobile, api-administracion, worker
- Sprint: 2, 3
- Tiempo total: ~1.5h (30m por proyecto)

**Cross-4: Migrar a Workflows Reusables**
- Proyectos: TODOS excepto dev-environment (5)
- Sprint: 4
- Tiempo total: ~12h (2-3h por proyecto)

---

## 📈 Cronograma Visual

```
Semana 1 (Sprint 1):
┌─────────────┬──────────────────────────────────────┐
│ Proyecto    │ L    M    M    J    V                │
├─────────────┼──────────────────────────────────────┤
│ shared      │ ███  ███  ████ ██████ ███           │
│ infra       │ ████ ████ ███  ██     ██             │
└─────────────┴──────────────────────────────────────┘

Semana 2 (Sprint 2):
┌─────────────┬──────────────────────────────────────┐
│ Proyecto    │ L    M    M    J    V                │
├─────────────┼──────────────────────────────────────┤
│ api-mobile  │ ██████ ██████ ─    ─    ─           │
│ api-admin   │ ─      ─      ███████ █████ ███     │
└─────────────┴──────────────────────────────────────┘

Semana 3 (Sprint 3):
┌─────────────┬──────────────────────────────────────┐
│ Proyecto    │ L    M    M    J    V                │
├─────────────┼──────────────────────────────────────┤
│ worker      │ ███████ █████ ─    ─    ─           │
│ dev-env     │ ─       ─     ███  ─    ─           │
└─────────────┴──────────────────────────────────────┘

Semana 4 (Sprint 4):
┌─────────────┬──────────────────────────────────────┐
│ Proyecto    │ L    M    M    J    V                │
├─────────────┼──────────────────────────────────────┤
│ infra       │ ███████ ███████ ─    ─    ─         │
│ TODOS       │ ─       ─       ████ █████████ ███  │
└─────────────┴──────────────────────────────────────┘

Leyenda: █ = Trabajo activo, ─ = Sin actividad
```

---

## 🚦 Criterios de Progreso a Siguiente Sprint

### Antes de Sprint 2:
- ✅ infrastructure con >90% success rate
- ✅ shared con Go 1.25 y releases modulares funcionando
- ✅ Ambos con pre-commit hooks

### Antes de Sprint 3:
- ✅ api-mobile con paralelismo implementado
- ✅ api-administracion con >85% success rate
- ✅ Ambas APIs con Go 1.25

### Antes de Sprint 4:
- ✅ worker con 1 solo workflow Docker
- ✅ worker con Go 1.25 y coverage 33%
- ✅ TODOS los proyectos Tipo A y B estables

---

## 🎯 Hitos Clave

### Hito 1: infrastructure Operativo (Fin Sprint 1)
```
Fecha: 24 Nov 2025
Criterio: Success rate >90%
Impacto: Desbloquea todo el ecosistema
```

### Hito 2: Go 1.25 en Todas las APIs (Fin Sprint 2)
```
Fecha: 1 Dic 2025
Criterio: 5/6 proyectos en Go 1.25
Impacto: Consistencia total
```

### Hito 3: Consolidación Docker (Fin Sprint 3)
```
Fecha: 8 Dic 2025
Criterio: worker con 1 workflow, no 3
Impacto: Elimina desperdicio
```

### Hito 4: Workflows Reusables Activos (Fin Sprint 4)
```
Fecha: 15 Dic 2025
Criterio: 4 workflows reusables, 3 composite actions
Impacto: -70% código duplicado
```

---

## 📋 Opciones de Ejecución

### Opción A: Equipo Completo (Recomendado)

**Configuración:** 2-3 personas trabajando en paralelo

**Asignación:**
```
Persona 1: infrastructure + shared (Sprint 1)
Persona 2: api-mobile (Sprint 2)
Persona 3: api-administracion (Sprint 2)

Persona 1: worker (Sprint 3)
Persona 2+3: Apoyo en Sprint 4
```

**Tiempo real:** 4 semanas calendario, ~40h por persona

---

### Opción B: Solo Developer (Secuencial)

**Configuración:** 1 persona full-time

**Duración:** 4 semanas, 90-115h total

**Carga:**
- Sprint 1: 30-38h (muy pesado)
- Sprint 2: 24-28h (pesado)
- Sprint 3: 14-17h (moderado)
- Sprint 4: 26-32h (pesado)

---

### Opción C: Part-Time (Extendido)

**Configuración:** 1 persona medio tiempo (4h/día)

**Duración:** 6-8 semanas

**Distribución:**
- Semanas 1-2: Sprint 1
- Semanas 3-4: Sprint 2
- Semana 5: Sprint 3
- Semanas 6-7: Sprint 4
- Semana 8: Buffer

---

## 🔄 Dependencias Entre Sprints

```
Sprint 1 (shared + infrastructure)
    ↓
    ├─→ Sprint 2 (api-mobile + api-admin)
    │   └─→ Sprint 3 (worker)
    │       └─→ Sprint 4 (todos)
    │
    └─→ Sprint 4 (crear reusables en infrastructure)
```

**Regla:** No avanzar a siguiente sprint sin completar criterios de progreso.

---

## 📊 Métricas de Éxito Global

### Al Finalizar los 4 Sprints

| Métrica | Antes | Después | Mejora |
|---------|-------|---------|--------|
| **Success Rate Promedio** | 64% | 95%+ | +48% |
| **Workflows totales** | 25 | 18 + 5 reusables | -28% |
| **Líneas código workflows** | ~3,850 | ~1,100 | **-71%** |
| **Go version consistente** | 40% | 100% | +150% |
| **Proyectos con pre-commit** | 0/6 | 6/6 | +600% |
| **Coverage thresholds** | 2/6 | 6/6 | +200% |
| **Docker workflows duplicados** | 6 | 0 | -100% |
| **Tiempo promedio CI** | ~5 min | ~3 min | **-40%** |

---

## 📅 Fechas Clave

| Fecha | Evento | Entregable |
|-------|--------|-----------|
| **20 Nov** | 🚀 Inicio Sprint 1 | - |
| **24 Nov** | ✅ Fin Sprint 1 | infrastructure + shared estables |
| **27 Nov** | 🚀 Inicio Sprint 2 | - |
| **1 Dic** | ✅ Fin Sprint 2 | APIs con Go 1.25 |
| **4 Dic** | 🚀 Inicio Sprint 3 | - |
| **8 Dic** | ✅ Fin Sprint 3 | worker consolidado |
| **11 Dic** | 🚀 Inicio Sprint 4 | - |
| **15 Dic** | 🎉 Fin Sprint 4 | Workflows reusables activos |
| **16-17 Dic** | 📊 Review Final | Métricas y retrospectiva |

---

## 🎯 Puntos de Decisión

### Checkpoint 1 (Día 2 Sprint 1)
**Pregunta:** ¿infrastructure se pudo corregir?
- ✅ Sí → Continuar
- ❌ No → Escalar, investigar más profundo (2-3 días extra)

### Checkpoint 2 (Día 1 Sprint 2)
**Pregunta:** ¿Go 1.25 en api-mobile pasó CI/CD?
- ✅ Sí → Migrar resto de proyectos
- ❌ No → Investigar, posible rollback a 1.24.10

### Checkpoint 3 (Día 1 Sprint 3)
**Pregunta:** ¿Consolidación Docker en worker funciona?
- ✅ Sí → Continuar
- ❌ No → Mantener 2 workflows, documentar por qué

### Checkpoint 4 (Día 3 Sprint 4)
**Pregunta:** ¿api-mobile piloto con reusables funciona?
- ✅ Sí → Migrar todos
- ❌ No → Ajustar reusables, reintentar

---

## 📝 Checklist General de Sprints

### Sprint 1
- [ ] infrastructure: 20% → 95%+ success
- [ ] shared: Go 1.25, releases modulares
- [ ] Ambos: Pre-commit hooks

### Sprint 2
- [ ] api-mobile: Paralelismo, Go 1.25
- [ ] api-administracion: 40% → 90%+ success
- [ ] Ambas: Docker consolidado, pre-commit hooks

### Sprint 3
- [ ] worker: 3 → 1 workflow Docker
- [ ] worker: Go 1.25, coverage 33%
- [ ] dev-environment: Documentado (opcional)

### Sprint 4
- [ ] 4 workflows reusables creados
- [ ] 3 composite actions creadas
- [ ] 5 proyectos migrados a reusables
- [ ] Documentación completa

---

## 🎓 Guía de Navegación de Planes

### Para Comenzar Sprint 1:
```bash
cd implementation-plans/01-shared
open INDEX.md

cd ../02-infrastructure
open INDEX.md
```

### Para Comenzar Sprint 2:
```bash
cd implementation-plans/03-api-mobile
open INDEX.md

cd ../04-api-administracion
open INDEX.md
```

### Para Comenzar Sprint 3:
```bash
cd implementation-plans/05-worker
open INDEX.md

cd ../06-dev-environment
open INDEX.md
```

### Para Comenzar Sprint 4:
```bash
# infrastructure crea los reusables
cd implementation-plans/02-infrastructure
open SPRINT-4-TASKS.md

# Resto los consume
cd ../03-api-mobile
open SPRINT-4-TASKS.md
```

---

## 💰 ROI por Sprint

| Sprint | Inversión | Retorno Inmediato | ROI |
|--------|-----------|-------------------|-----|
| Sprint 1 | 30-38h | infrastructure estable | ∞ (crítico) |
| Sprint 2 | 24-28h | APIs optimizadas | Alto |
| Sprint 3 | 14-17h | worker consolidado | Medio |
| Sprint 4 | 26-32h | -70% duplicación | Muy Alto |
| **TOTAL** | **94-115h** | **Ecosistema optimizado** | **213%/año** |

---

## ✅ Resumen de Planes Generados

```
📁 implementation-plans/
   ├── 01-shared/              ✅ 8 archivos, 6,100 líneas
   ├── 02-infrastructure/      ✅ 7 archivos, 3,930 líneas
   ├── 03-api-mobile/          ✅ 7 archivos, 4,677 líneas
   ├── 04-api-administracion/  ✅ 6 archivos, 4,484 líneas
   ├── 05-worker/              ✅ 5 archivos, 6,009 líneas
   ├── 06-dev-environment/     ✅ 5 archivos, 2,384 líneas
   └── CRONOGRAMA-GENERAL.md   ✅ Este archivo

Total: 38 archivos markdown
Total: ~27,600 líneas
Total: ~700 KB documentación
```

---

## 🎉 Plan Completo Listo

**Cada proyecto tiene:**
- ✅ Plan autosuficiente
- ✅ Scripts ejecutables
- ✅ Checkboxes de progreso
- ✅ Validaciones
- ✅ Troubleshooting

**Puedes ir a cualquier carpeta y tener TODA la información necesaria.**

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025  
**Versión:** 1.0 Final
