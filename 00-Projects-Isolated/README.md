# 📦 Proyectos Aislados - Ecosistema EduGo

**Fecha:** 16 de Noviembre, 2025  
**Versión:** 2.0.0  
**Propósito:** Documentación autocontenida por proyecto

---

## 🎯 Filosofía de Esta Carpeta

Cada subcarpeta contiene **TODA** la documentación necesaria para implementar ese proyecto de forma **100% autónoma**, sin depender de archivos externos.

**Principio:** "Todo lo que necesitas está dentro de la carpeta del proyecto"

---

## 📂 Proyectos Disponibles

### ✅ COMPLETADOS

#### 1. shared/ (v0.7.0 FROZEN)

**Estado:** 🔒 COMPLETADO Y CONGELADO  
**Fecha:** 15 de Noviembre, 2025  
**Versión:** v0.7.0

**Contenido:**
- 12 módulos Go publicados
- Coverage global: ~75%
- Política: Solo bug fixes hasta post-MVP
- Documentación completa y autocontenida

**Para copiar a repo:**
```bash
cp -r 00-Projects-Isolated/shared/ /path/to/edugo-shared/docs/isolated/
```

---

#### 2. api-administracion/ (v0.2.0)

**Estado:** ✅ COMPLETADO  
**Fecha:** 12 de Noviembre, 2025  
**Versión:** v0.2.0

**Contenido:**
- Sistema de jerarquía académica completo
- 15+ endpoints REST
- >80% test coverage
- Documentación oficial en: `/Analisys/docs/specs/api-admin-jerarquia/`

**Nota:** Esta carpeta sirve como **referencia histórica**. Documentación oficial está en ubicación indicada.

---

#### 3. dev-environment/ (v1.0.0)

**Estado:** ✅ COMPLETADO  
**Fecha:** 13 de Noviembre, 2025  
**Versión:** v1.0.0

**Contenido:**
- 6 perfiles Docker
- Scripts automatizados
- Seeds completos
- Documentación de uso

**Para copiar a repo:**
```bash
cp -r 00-Projects-Isolated/dev-environment/ /path/to/edugo-dev-environment/docs/isolated/
```

---

#### 4. infrastructure/ (v0.1.1)

**Estado:** ✅ 96% COMPLETADO  
**Fecha:** 16 de Noviembre, 2025  
**Versión:** v0.1.1

**Contenido:**
- Migraciones PostgreSQL (8 tablas)
- JSON Schemas de eventos (4 eventos)
- Docker Compose con profiles
- Scripts de automatización
- Documentación completa

**Pendiente:**
- database/migrate.go (1-2h)
- schemas/validator.go (2-3h)

**Para copiar a repo:**
```bash
cp -r 00-Projects-Isolated/infrastructure/ /path/to/edugo-infrastructure/docs/isolated/
```

---

### 🔄 EN PROGRESO

#### 5. api-mobile/ (Evaluaciones)

**Estado:** 🔄 EN PROGRESO (40%)  
**Prioridad:** P0 (Crítica)

**Contenido:**
- Sistema de evaluaciones especificado
- Dependencias actualizadas (shared v0.7.0, infrastructure v0.1.1)
- 6 sprints documentados
- Listo para implementación

**Para copiar a repo:**
```bash
cp -r 00-Projects-Isolated/api-mobile/ /path/to/edugo-api-mobile/docs/isolated/
```

---

### ⬜ PENDIENTES

#### 6. worker/ (Procesamiento IA)

**Estado:** ⬜ PENDIENTE (0%)  
**Prioridad:** P1 (Alta)

**Contenido:**
- Procesamiento de PDFs especificado
- **Costos de OpenAI documentados** ($0.069/material gpt-4-turbo)
- **SLA de OpenAI documentado** (18s p95, 500 RPM)
- Dependencias actualizadas (shared v0.7.0, infrastructure v0.1.1)
- DLQ configurado
- 6 sprints documentados

**Para copiar a repo:**
```bash
cp -r 00-Projects-Isolated/worker/ /path/to/edugo-worker/docs/isolated/
```

---

## 🗺️ Mapa de Dependencias

```
infrastructure v0.1.1 (base compartida)
    ↓
    ├─→ api-administracion v0.2.0 ✅
    │       ↓
    ├─→ api-mobile (en progreso)
    │       ↓
    └─→ worker (pendiente)

shared v0.7.0 (FROZEN)
    ↓
    ├─→ api-administracion v0.2.0 ✅
    ├─→ api-mobile (en progreso)
    └─→ worker (pendiente)
```

**Orden de implementación:**
1. ✅ shared v0.7.0
2. ✅ infrastructure v0.1.1
3. ✅ api-administracion v0.2.0
4. 🔄 api-mobile
5. ⬜ worker

---

## 📊 Estado Global

### Completitud por Proyecto

| Proyecto | Estado | Progreso | Documentación |
|----------|--------|----------|---------------|
| shared | 🔒 Frozen | 100% | ✅ Completa |
| infrastructure | ✅ Activo | 96% | ✅ Completa |
| api-administracion | ✅ Completado | 100% | ✅ Completa |
| dev-environment | ✅ Completado | 100% | ✅ Completa |
| api-mobile | 🔄 En progreso | 40% | ✅ Completa |
| worker | ⬜ Pendiente | 0% | ✅ Completa |

### Métricas del Ecosistema

- **Proyectos completados:** 4/6 (67%)
- **Completitud documental:** 96%
- **Bloqueantes críticos:** 0
- **Desarrollo viable:** ✅ SÍ

---

## 📁 Estructura de Cada Proyecto

Cada carpeta sigue este patrón estándar:

```
proyecto-name/
├── START_HERE.md              ⭐ Punto de entrada - LEER PRIMERO
├── EXECUTION_PLAN.md          Plan detallado de ejecución
├── PROGRESS.json              Tracking de progreso
│
├── 01-Context/                Contexto del proyecto
│   ├── PROJECT_OVERVIEW.md    Overview completo
│   ├── ECOSYSTEM_CONTEXT.md   Cómo encaja en ecosistema
│   ├── DEPENDENCIES.md        Dependencias detalladas
│   └── TECH_STACK.md          Stack tecnológico
│
├── 02-Requirements/           Requisitos
│   ├── PRD.md
│   ├── FUNCTIONAL_SPECS.md
│   ├── TECHNICAL_SPECS.md
│   └── ACCEPTANCE_CRITERIA.md
│
├── 03-Design/                 Diseño
│   ├── ARCHITECTURE.md
│   ├── DATA_MODEL.md
│   ├── API_CONTRACTS.md
│   └── SECURITY_DESIGN.md
│
├── 04-Implementation/         Implementación (6 sprints)
│   ├── Sprint-01-.../
│   ├── Sprint-02-.../
│   └── ...
│
├── 05-Testing/                Testing
│   └── ...
│
└── 06-Deployment/             Deployment
    └── ...
```

---

## 🚀 Cómo Usar Esta Documentación

### Para Desarrolladores

**Si vas a trabajar en api-mobile:**
1. Entra a `00-Projects-Isolated/api-mobile/`
2. Lee `START_HERE.md`
3. Sigue `EXECUTION_PLAN.md`
4. Implementa sprint por sprint
5. **NO necesitas salir de esta carpeta**

**Si vas a trabajar en worker:**
1. Entra a `00-Projects-Isolated/worker/`
2. Lee `START_HERE.md`
3. Revisa costos de OpenAI documentados
4. Sigue `EXECUTION_PLAN.md`
5. **NO necesitas salir de esta carpeta**

---

### Para Copiar al Repositorio Real

Cuando completes la implementación, copia la documentación al repo:

```bash
# Ejemplo: api-mobile completado
cd /path/to/edugo-api-mobile
mkdir -p docs/isolated
cp -r /path/to/Analisys/00-Projects-Isolated/api-mobile/* docs/isolated/

# Commit en el repo del proyecto
git add docs/isolated/
git commit -m "docs: agregar documentación isolated autocontenida"
```

---

## 🔗 Relación con AnalisisEstandarizado

### Diferencias

**AnalisisEstandarizado/** (Vista HORIZONTAL):
- Documentación cross-proyecto
- Overview global del ecosistema
- Decisiones compartidas
- Matriz de dependencias

**00-Projects-Isolated/** (Vista VERTICAL):
- Documentación por proyecto
- Autocontenida y completa
- Sin referencias externas
- Lista para copiar a cada repo

### Complementariedad

Ambas carpetas coexisten:
- **Usa AnalisisEstandarizado:** Para entender el ecosistema completo
- **Usa Projects-Isolated:** Para implementar un proyecto específico

---

## 📝 Versiones Canónicas

### Dependencias del Ecosistema

**IMPORTANTE:** Estas son las ÚNICAS versiones válidas:

```go
// go.mod de cualquier proyecto
require (
    github.com/EduGoGroup/edugo-shared/auth v0.7.0          // FROZEN
    github.com/EduGoGroup/edugo-shared/logger v0.7.0        // FROZEN
    github.com/EduGoGroup/edugo-shared/evaluation v0.7.0    // FROZEN
    github.com/EduGoGroup/edugo-infrastructure/database v0.1.1
    github.com/EduGoGroup/edugo-infrastructure/schemas v0.1.1
)
```

**NO usar:**
- ❌ shared v1.3.0, v1.4.0, v1.5.0 (NO EXISTEN)
- ❌ Ninguna otra versión que no esté listada arriba

---

## ⚠️ Notas Importantes

### Para Agentes IA

1. **Cada carpeta es autónoma**
   - Entra a la carpeta del proyecto
   - Lee START_HERE.md
   - Sigue EXECUTION_PLAN.md
   - No salgas de la carpeta

2. **Versiones CORRECTAS**
   - shared: v0.7.0 (FROZEN)
   - infrastructure: v0.1.1
   - IGNORA cualquier otra versión mencionada

3. **Estados claros**
   - Completado = No tocar, solo referencia
   - Frozen = Consumir, no modificar
   - En progreso = Continuar implementación
   - Pendiente = Iniciar cuando sea prioridad

---

## 📊 Información Crítica Agregada

### Costos de OpenAI (worker/)

| Operación | Tokens | Costo (gpt-4-turbo) |
|-----------|--------|---------------------|
| Extracción PDF | ~5,000 | $0.050 |
| Resumen | ~2,000 | $0.060 |
| Quiz | ~3,000 | $0.090 |
| **Total/material** | ~10,000 | **$0.20** |

**Proyecciones mensuales:**
- 100 materiales: $20/mes
- 500 materiales: $100/mes
- 1,000 materiales: $200/mes

### Política shared v0.7.0 (shared/)

**Permitido:**
- ✅ Bug fixes críticos (v0.7.1, v0.7.2, etc.)
- ✅ Documentación
- ✅ Tests

**NO Permitido:**
- ❌ Nuevas features
- ❌ Breaking changes
- ❌ Refactoring mayor

**Razón:** Estabilidad durante desarrollo de api-mobile y worker

---

## 🎊 RESULTADO FINAL

**6 proyectos documentados de forma autocontenida:**
- ✅ infrastructure (NUEVO)
- ✅ shared (actualizado a FROZEN v0.7.0)
- ✅ api-administracion (marcado completado v0.2.0)
- ✅ dev-environment (marcado completado v1.0.0)
- ✅ api-mobile (actualizado con nuevas dependencias)
- ✅ worker (actualizado con costos/SLA OpenAI)

**Cada proyecto listo para copiar a su repositorio real.**

---

**Generado:** 16 de Noviembre, 2025  
**Por:** Claude Code  
**Metodología:** Documentación Aislada y Autocontenida
