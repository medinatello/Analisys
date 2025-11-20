# Plan de Implementación CI/CD - Análisis UltraThink

**Fecha:** 19 de Noviembre, 2025  
**Metodología:** UltraThink - Análisis de dependencias y orden óptimo  
**Objetivo:** Plan atómico por proyecto con carpetas independientes

---

## 🧠 Análisis UltraThink: Dependencias

### Grafo de Dependencias del Ecosistema

**IMPORTANTE:** Este diagrama muestra dependencias **de código Go (go get)** Y **de infraestructura/runtime**.

```
FUNDAMENTOS (SECUENCIAL - OBLIGATORIO)
═══════════════════════════════════════

┌─────────────────────┐
│  edugo-shared       │ ← Código compartido (logger, db, auth, etc.)
│  (Tipo B)           │
└──────────┬──────────┘
           │ go get
           │
           ▼
┌─────────────────────┐
│ edugo-infrastructure│ ← Esquema BD, migraciones, contratos RabbitMQ
│ (Tipo B)            │   + Helpers de testing
└──────────┬──────────┘
           │
           │ TODAS las aplicaciones dependen de infrastructure:
           │ • Migraciones PostgreSQL (esquema BD)
           │ • Migraciones MongoDB
           │ • Contratos de eventos RabbitMQ
           │ • Helpers de testing (postgres/testing)
           │
           ├─────────────┬─────────────┬─────────────┐
           │             │             │             │
           ▼             ▼             ▼             ▼
    ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
    │api-mobile│  │api-admin │  │  worker  │  │ dev-env  │
    │ (Tipo A) │  │ (Tipo A) │  │ (Tipo A) │  │ (Tipo C) │
    └──────────┘  └──────────┘  └──────────┘  └──────────┘

    ↑ ESTOS 4 PUEDEN IR EN PARALELO (no dependen entre sí)
```

### ⚠️ Clarificación Crítica sobre infrastructure

**edugo-infrastructure NO es solo código Go**, contiene:

1. **🐘 postgres/** - Migraciones de PostgreSQL (esquema completo de BD)
2. **🍃 mongodb/** - Migraciones de MongoDB
3. **📨 messaging/** - Schemas y validación de eventos RabbitMQ
4. **🧪 postgres/testing** - Helpers para tests de integración
5. **🐳 docker/** - Docker Compose con perfiles
6. **🛠️ scripts/** - Scripts de automatización

**¿Por qué las APIs dependen de infrastructure?**

- ✅ **Esquema de BD sincronizado** - Todos usan las mismas migraciones
- ✅ **Contratos de eventos validados** - RabbitMQ con schemas consistentes
- ✅ **Tests de integración funcionales** - Imports de `postgres/testing`
- ✅ **Sin discrepancias** - Todo el ecosistema con misma estructura

**Implementar APIs ANTES de infrastructure causaría:**
- ❌ Migraciones desactualizadas
- ❌ Tests de integración rotos
- ❌ Contratos de eventos inconsistentes
- ❌ **DISCREPANCIA entre proyectos**

### Orden de Implementación Óptimo

**⚠️ CRÍTICO: Respetar este orden para evitar discrepancias**

**Fase 1 - FUNDAMENTOS (SECUENCIAL):**
1. **edugo-shared** → Código compartido (logger, db, auth)
2. **edugo-infrastructure** → Esquema BD + contratos + testing
   
   ✅ **Validación obligatoria antes de continuar:**
   - Migraciones PostgreSQL aplicadas correctamente
   - Migraciones MongoDB aplicadas correctamente
   - Schemas de RabbitMQ validados
   - Tests de `postgres/testing` pasando

**Fase 2 - APLICACIONES (PARALELO - 4 proyectos simultáneos):**
3. **edugo-api-mobile** (consume shared + infrastructure)
4. **edugo-api-administracion** (consume shared + infrastructure)
5. **edugo-worker** (consume shared + infrastructure)
6. **edugo-dev-environment** (independiente pero útil tenerlo actualizado)

---

## 📅 División por Sprints

### Sprint 1: Fundamentos y Base (Semana 1) - SECUENCIAL
**Objetivo:** Estabilizar y preparar librerías base e infraestructura  
**Proyectos:** shared, infrastructure  
**Duración:** 5 días  
**Modo:** **SECUENCIAL** (uno después del otro)

**Orden de ejecución:**
1. **Día 1-2:** edugo-shared (Sprint 1)
2. **Día 3-5:** edugo-infrastructure (Sprint 1)

**✅ Criterios de validación antes de continuar:**
- [ ] edugo-shared: Tests pasando + release creado
- [ ] edugo-infrastructure: Migraciones PostgreSQL/MongoDB aplicadas
- [ ] edugo-infrastructure: Schemas RabbitMQ validados
- [ ] edugo-infrastructure: Tests de `postgres/testing` pasando

---

### Sprint 2: APIs Principales (Semana 2) - PARALELO
**Objetivo:** Migrar APIs con workflows optimizados  
**Proyectos:** api-mobile, api-administracion  
**Duración:** 5 días  
**Modo:** **PARALELO** (ambos proyectos simultáneamente)

**Pre-requisito:** ✅ Sprint 1 completado y validado

---

### Sprint 3: Worker y Utilidades (Semana 3) - PARALELO
**Objetivo:** Completar ecosistema  
**Proyectos:** worker, dev-environment  
**Duración:** 3 días  
**Modo:** **PARALELO** (ambos proyectos simultáneamente)

**Pre-requisito:** ✅ Sprint 1 completado y validado

**Nota:** Este sprint puede ejecutarse en paralelo con Sprint 2 si se desea máxima velocidad.

---

### Sprint 4: Cross-Project - Workflows Reusables (Semana 4)
**Objetivo:** Centralizar y eliminar duplicación usando workflows reusables  
**Proyectos:** TODOS (usando infrastructure como base para workflows compartidos)  
**Duración:** 5 días

**Pre-requisito:** ✅ Sprints 1, 2 y 3 completados

---

## 🚀 Estrategia de Implementación Recomendada

### Opción 1: Máxima Velocidad (3-4 días)

```
DÍA 1-2: FASE 1 - Fundamentos (Secuencial)
├─ shared (Sprint 1)
└─ infrastructure (Sprint 1)
   └─ ✅ Validar: Migraciones + Schemas + Tests

DÍA 3-4: FASE 2 - Aplicaciones (4 en PARALELO)
├─ api-mobile (Sprint 2)
├─ api-administracion (Sprint 2)
├─ worker (Sprint 3)
└─ dev-environment (Sprint 3)
   └─ ✅ Todos arrancan simultáneamente (máximo paralelismo)

SEMANA 4: FASE 3 - Workflows Reusables
└─ Todos los proyectos (Sprint 4)
```

### Opción 2: Controlada (5-6 días)

```
DÍA 1-2: FASE 1 - Fundamentos (Secuencial)
├─ shared (Sprint 1)
└─ infrastructure (Sprint 1)

DÍA 3-4: FASE 2 - APIs (2 en PARALELO)
├─ api-mobile (Sprint 2)
└─ api-administracion (Sprint 2)

DÍA 5-6: FASE 3 - Worker y Utilidades (2 en PARALELO)
├─ worker (Sprint 3)
└─ dev-environment (Sprint 3)

SEMANA 4: FASE 4 - Workflows Reusables
└─ Todos los proyectos (Sprint 4)
```

**Recomendación:** Usar **Opción 1** para máxima eficiencia, ya que todos los proyectos de aplicación son independientes entre sí (solo dependen de shared + infrastructure).

---

## 🎯 Identificación de Tareas Cross-Project

### Tareas que DEBEN hacerse en TODOS los proyectos

**Cross-1:** Migrar a Go 1.25  
**Cross-2:** Configurar pre-commit hooks  
**Cross-3:** Implementar control de releases con variables  
**Cross-4:** Estandarizar nombres de workflows  
**Cross-5:** Implementar concurrency control  
**Cross-6:** Agregar coverage thresholds  
**Cross-7:** Migrar a workflows reusables (Sprint 4)  

### Tareas Específicas por Tipo

**Solo Tipo A (APIs, Worker):**
- Consolidar workflows Docker
- Implementar paralelismo en tests
- Tests de integración con control

**Solo Tipo B (Shared, Infrastructure):**
- Releases por módulo independiente
- Auto-release con detección de cambios
- Tests de compatibilidad multi-versión Go

---

## 📁 Estructura de Carpetas del Plan

```
00-Projects-Isolated/cicd-analysis/
├── implementation-plans/
│   ├── 01-shared/
│   │   ├── README.md
│   │   ├── SPRINT-1-TASKS.md
│   │   ├── SPRINT-4-TASKS.md
│   │   ├── WORKFLOWS/
│   │   └── SCRIPTS/
│   │
│   ├── 02-infrastructure/
│   │   ├── README.md
│   │   ├── SPRINT-1-TASKS.md
│   │   ├── SPRINT-4-TASKS.md
│   │   ├── WORKFLOWS/
│   │   └── SCRIPTS/
│   │
│   ├── 03-api-mobile/
│   │   ├── README.md
│   │   ├── SPRINT-2-TASKS.md
│   │   ├── SPRINT-4-TASKS.md
│   │   ├── WORKFLOWS/
│   │   └── SCRIPTS/
│   │
│   ├── 04-api-administracion/
│   │   ├── README.md
│   │   ├── SPRINT-2-TASKS.md
│   │   ├── SPRINT-4-TASKS.md
│   │   ├── WORKFLOWS/
│   │   └── SCRIPTS/
│   │
│   ├── 05-worker/
│   │   ├── README.md
│   │   ├── SPRINT-3-TASKS.md
│   │   ├── SPRINT-4-TASKS.md
│   │   ├── WORKFLOWS/
│   │   └── SCRIPTS/
│   │
│   └── 06-dev-environment/
│       ├── README.md
│       └── SPRINT-3-TASKS.md
│
└── CRONOGRAMA-GENERAL.md
```

**Principio:** Cada carpeta es **autosuficiente** con toda la info necesaria para ese proyecto.

---

## 🎯 Siguiente Paso

Voy a generar los planes detallados por proyecto usando UltraThink para analizar:
- Dependencias entre tareas
- Orden óptimo de ejecución
- Puntos de validación
- Criterios de éxito
- Scripts listos para copiar/pegar

¿Procedo a generar la estructura completa?

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025
