# Plan Maestro: Centralización de Entities en Infrastructure

**Fecha:** 20 de Noviembre, 2025  
**Objetivo:** Migrar entities de todos los proyectos a infrastructure como single source of truth  
**Proyectos afectados:** 4 (infrastructure, api-mobile, api-administracion, worker)

---

## 🎯 Visión General

### Problema Actual
- **Entities duplicadas** en api-mobile, api-administracion y worker
- Cambios en schema de BD requieren **actualizar múltiples proyectos**
- **Riesgo de discrepancias** entre proyectos
- **Lógica de negocio mezclada** con estructura de datos

### Solución
- **Centralizar entities** en `infrastructure/postgres/entities/` y `infrastructure/mongodb/entities/`
- Entities = **Reflejo exacto de BD** (sin lógica)
- Cada proyecto **importa desde infrastructure**
- Lógica de negocio → **Domain Services** en cada proyecto

---

## 📊 Resumen de Análisis

### Inventario Global de Entities

#### PostgreSQL (14 entities totales)

| Entity | Tabla | Proyectos que la usan |
|--------|-------|----------------------|
| User | users | api-mobile, api-administracion |
| School | schools | api-administracion |
| AcademicUnit | academic_units | api-administracion |
| Membership | memberships | api-administracion |
| Material | materials | api-mobile, api-administracion |
| MaterialVersion | material_versions | api-mobile |
| Subject | subjects | api-administracion |
| Unit | units | api-administracion |
| GuardianRelation | guardian_relations | api-administracion |
| Assessment | assessments | api-mobile |
| AssessmentQuestion | assessment_questions | api-mobile |
| AssessmentAnswer | assessment_answers | api-mobile |
| AssessmentAttempt | assessment_attempts | api-mobile |
| Progress | progress | api-mobile |

#### MongoDB (3 entities totales)

| Entity | Collection | Proyectos que la usan |
|--------|------------|----------------------|
| MaterialAssessment | material_assessment | worker |
| MaterialSummary | material_summary | worker |
| MaterialEvent | material_event | worker |

---

## 📈 Métricas Globales

| Métrica | api-mobile | api-administracion | worker | TOTAL |
|---------|------------|-------------------|--------|-------|
| **Entities locales** | 7 | 7 | 3 | **17** |
| **LOC en entities** | 874 | 1,556 | 421 | **2,851** |
| **Archivos afectados** | 31 | 38 | 6 | **75** |
| **Domain Services a crear** | 4 | 6 | 3 | **13** |
| **Tiempo estimado** | 12-15h | 16-20h | 5-7h | **33-42h** |

**Impacto total:**
- ✅ Eliminar **2,851 líneas** de código duplicado
- ✅ Actualizar **75 archivos**
- ✅ Crear **13 domain services** nuevos
- ✅ Crear **17 entities** en infrastructure

---

## 🗺️ Orden de Ejecución (CRÍTICO)

### ⚠️ REGLA DE ORO: Secuencial → Paralelo

```
FASE 1: INFRASTRUCTURE (OBLIGATORIO PRIMERO)
└─ Sprint ENTITIES en infrastructure
   └─ ✅ Validar que compila y tests pasan
   └─ ✅ Crear tags de release
   └─ ✅ Disponible en GitHub

          ↓
          
FASE 2: PROYECTOS (PARALELO - Después de Fase 1)
├─ Sprint ENTITIES-ADAPTATION en api-mobile
├─ Sprint ENTITIES-ADAPTATION en api-administracion
└─ Sprint ENTITIES-ADAPTATION en worker
   └─ ✅ Los 3 pueden ejecutarse simultáneamente
```

---

## 📋 Sprints Creados

### Sprint 1: Infrastructure (Fundamento)
**Archivo:** `02-infrastructure/SPRINT-ENTITIES.md`  
**Duración:** 6-8 horas  
**Prioridad:** BLOQUEANTE - Debe completarse antes de los demás

**Tareas principales:**
1. Crear `postgres/entities/` (14 entities)
2. Crear `mongodb/entities/` (3 entities)
3. Tests básicos
4. Release tags

**Criterios de éxito:**
- [ ] 17 entities creados y compilando
- [ ] Tests básicos pasando
- [ ] Tags `postgres/entities/v0.1.0` y `mongodb/entities/v0.1.0` publicados
- [ ] Disponible para `go get`

---

### Sprint 2: api-mobile (Adaptación)
**Archivo:** `03-api-mobile/SPRINT-ENTITIES-ADAPTATION.md`  
**Duración:** 12-15 horas  
**Dependencia:** Sprint 1 completado

**Tareas principales:**
1. Crear 4 Domain Services
2. Actualizar 31 archivos
3. Eliminar 7 entities locales
4. Migrar tests

**Complejidad:** 🔴 ALTA
- Assessment, Attempt y Material tienen mucha lógica de negocio
- 31 archivos a actualizar
- Conversión de value objects a UUIDs

**Criterios de éxito:**
- [ ] 4 domain services creados con tests
- [ ] 31 archivos actualizados
- [ ] 7 entities eliminados
- [ ] go build exitoso
- [ ] go test pass 100%
- [ ] coverage >= 80%

---

### Sprint 3: api-administracion (Adaptación)
**Archivo:** `04-api-administracion/SPRINT-ENTITIES-ADAPTATION.md`  
**Duración:** 16-20 horas  
**Dependencia:** Sprint 1 completado

**Tareas principales:**
1. Crear/actualizar 6 Domain Services
2. Actualizar 38 archivos
3. Eliminar 7 entities locales
4. Migrar tests

**Complejidad:** 🔴 ALTA
- AcademicUnit es MUY complejo (413 LOC)
- Manejo de árboles recursivos
- 38 archivos a actualizar
- Conversión de value objects

**Criterios de éxito:**
- [ ] 6 domain services creados/actualizados con tests
- [ ] 38 archivos actualizados
- [ ] 7 entities eliminados
- [ ] go build exitoso
- [ ] go test pass 100%
- [ ] coverage >= 80%

---

### Sprint 4: worker (Adaptación)
**Archivo:** `05-worker/SPRINT-ENTITIES-ADAPTATION.md`  
**Duración:** 5-7 horas  
**Dependencia:** Sprint 1 completado

**Tareas principales:**
1. Crear 3 Domain Services
2. Actualizar 6 archivos
3. Eliminar 3 entities locales
4. Validar BSON tags

**Complejidad:** 🟡 MEDIA
- Solo MongoDB (más simple que PostgreSQL)
- Menos archivos afectados
- CRÍTICO: Validar BSON tags son idénticos

**Criterios de éxito:**
- [ ] 3 domain services creados con tests
- [ ] 6 archivos actualizados
- [ ] 3 entities eliminados
- [ ] BSON tags validados (queries funcionan)
- [ ] go build exitoso
- [ ] go test pass 100%

---

## 🚀 Estrategia de Implementación

### Opción 1: Secuencial Pura (Más Segura)
```
Semana 1: Infrastructure (6-8h)
  └─ Validar y estabilizar antes de continuar

Semana 2: api-mobile (12-15h)
  └─ Validar que funciona antes de continuar

Semana 3: api-administracion (16-20h)
  └─ Validar que funciona antes de continuar

Semana 4: worker (5-7h)
  └─ Validación final
```

**Total:** 4 semanas (39-50 horas)

---

### Opción 2: Híbrida (Recomendada)
```
Semana 1:
├─ Lunes-Miércoles: Infrastructure (6-8h)
└─ Validación exhaustiva antes de continuar

Semana 2-3:
├─ api-mobile (12-15h)          } EN PARALELO
├─ api-administracion (16-20h)  } (si hay 2+ devs)
└─ worker (5-7h)                } O secuencial (1 dev)

Semana 4: Validación global y documentación
```

**Total:** 3-4 semanas (39-50 horas)

---

### Opción 3: Máxima Velocidad (Arriesgada)
```
Semana 1: Infrastructure (6-8h)

Semana 2: api-mobile + api-administracion + worker EN PARALELO (con 3 devs)

Semana 3: Integración y validación global
```

**Total:** 2-3 semanas (39-50 horas distribuidas)

---

## ⚠️ Riesgos y Mitigaciones

### Riesgo 1: Infrastructure incompleto
**Probabilidad:** MEDIA  
**Impacto:** ALTO (bloquea todo)

**Mitigación:**
- ✅ Validar EXHAUSTIVAMENTE Sprint 1 antes de continuar
- ✅ Comparar cada entity con migración SQL/MongoDB
- ✅ Tests automatizados de mapeo
- ✅ No avanzar hasta que tags estén publicados

---

### Riesgo 2: Pérdida de lógica de negocio
**Probabilidad:** ALTA  
**Impacto:** CRÍTICO

**Mitigación:**
- ✅ Inventario completo de métodos en entities antiguas
- ✅ Crear domain services ANTES de eliminar entities
- ✅ Tests de cobertura >= 80%
- ✅ Code review exhaustivo de domain services
- ✅ Comparación lado a lado (entity vieja vs nueva)

---

### Riesgo 3: BSON/DB tags incorrectos
**Probabilidad:** MEDIA  
**Impacto:** CRÍTICO (BD no funciona)

**Mitigación:**
- ✅ Script de validación de tags
- ✅ Tests de integración con BD real
- ✅ Comparar JSON/BSON serialization antes/después
- ✅ Tests con datos reales de producción (staging)

---

### Riesgo 4: Conversión de value objects
**Probabilidad:** ALTA  
**Impacto:** MEDIO

**Mitigación:**
- ✅ Crear funciones helpers de conversión
- ✅ Tests unitarios de conversión
- ✅ Documentar patrón en cada Sprint
- ✅ Ejemplos de código en sprints

---

### Riesgo 5: Breaking changes en APIs
**Probabilidad:** BAJA  
**Impacto:** ALTO

**Mitigación:**
- ✅ DTOs no deben cambiar (solo cambios internos)
- ✅ Tests de integración de API completos
- ✅ Tests end-to-end antes/después
- ✅ Validar contratos de API no cambian

---

## ✅ Criterios de Éxito Globales

### Por Proyecto

- [ ] **infrastructure:** 17 entities creados, tags publicados
- [ ] **api-mobile:** Compilación + tests + coverage >= 80%
- [ ] **api-administracion:** Compilación + tests + coverage >= 80%
- [ ] **worker:** Compilación + tests + BSON validado

### Integración

- [ ] **Todos los proyectos compilan** juntos
- [ ] **Tests de integración** pasan en todos
- [ ] **No hay regresiones** en funcionalidad
- [ ] **Coverage global** >= 75%

### Documentación

- [ ] **README actualizado** en cada proyecto
- [ ] **Guías de migración** completadas
- [ ] **Lecciones aprendidas** documentadas
- [ ] **Domain services** documentados

---

## 📚 Archivos Generados

```
00-Projects-Isolated/cicd-analysis/implementation-plans/
├── PLAN-MAESTRO-ENTITIES.md                        # Este archivo
│
├── 02-infrastructure/
│   └── SPRINT-ENTITIES.md                          # Sprint 1 (BLOQUEANTE)
│
├── 03-api-mobile/
│   └── SPRINT-ENTITIES-ADAPTATION.md               # Sprint 2 (1,110 líneas)
│
├── 04-api-administracion/
│   └── SPRINT-ENTITIES-ADAPTATION.md               # Sprint 3
│
└── 05-worker/
    ├── SPRINT-ENTITIES-ADAPTATION.md               # Sprint 4 (770 líneas)
    └── RESUMEN-ANALISIS.md                         # Análisis detallado
```

---

## 🎯 Recomendación Final

### Para 1 Desarrollador: Opción 1 (Secuencial)
- Más seguro
- Menor riesgo de errores
- Aprendizaje incremental
- 4 semanas

### Para 2-3 Desarrolladores: Opción 2 (Híbrida)
- Buen balance riesgo/velocidad
- Infrastructure primero (todos participan)
- Luego paralelo en proyectos
- 3 semanas

### Comenzar YA con: Sprint 1 (Infrastructure)
No se puede avanzar sin completar infrastructure primero.

---

## 📞 Próximos Pasos Inmediatos

1. **Revisar este Plan Maestro** con el equipo
2. **Asignar responsables** a cada Sprint
3. **Ejecutar Sprint 1 (Infrastructure)** - BLOQUEANTE
4. **Validar exhaustivamente** Sprint 1 antes de continuar
5. **Lanzar Sprints 2-4** (secuencial o paralelo según equipo)

---

**Generado por:** Claude Code  
**Fecha:** 20 de Noviembre, 2025  
**Basado en:** Análisis de 4 proyectos con 3 subagentes paralelos
