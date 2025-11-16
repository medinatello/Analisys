# 🎯 Dudas Restantes para Trabajo Vertical por Proyecto

**Fecha:** 15 de Noviembre, 2025  
**Después de:** edugo-shared v0.7.0 resuelto  
**Estado:** 4/5 problemas críticos cross-proyecto pendientes

---

## 📊 Resumen Ejecutivo

### Situación Actual

**✅ RESUELTO:**
- P0-1: edugo-shared v0.7.0 completamente especificado y congelado

**⬜ PENDIENTE (Cross-Proyecto):**
- P0-2: Ownership de tablas compartidas
- P0-3: Contratos de eventos RabbitMQ
- P0-4: docker-compose.yml y scripts
- P1-1: Sincronización PostgreSQL ↔ MongoDB

**Estrategia:**
1. Resolver dudas cross-proyecto restantes (P0-2, P0-3, P0-4, P1-1)
2. Luego trabajar verticalmente proyecto por proyecto sin bloqueos

---

## 🚧 Dudas Cross-Proyecto (Bloquean Múltiples Proyectos)

### P0-2: Ownership de Tablas Compartidas

**Proyectos afectados:** api-admin, api-mobile  
**Severidad:** 🔴 CRÍTICA - BLOQUEANTE DE MIGRACIONES  
**Tiempo estimado:** 3-4 horas

**Ambigüedad:**
- ¿Quién crea `users`? (api-admin menciona pero api-mobile la usa)
- ¿Quién crea `materials`? (api-mobile menciona pero no especifica si asume existe)
- ¿Quién crea `schools`, `academic_units`?

**Impacto:**
- Riesgo de migraciones duplicadas
- Conflictos "table already exists"
- CI/CD no tiene orden garantizado

**Solución requerida:**
- Crear `TABLE_OWNERSHIP.md` con owner claro de cada tabla
- Documentar orden de ejecución: api-admin → api-mobile
- Implementar validación en Makefile

**Hasta que se resuelva:**
- ❌ NO se puede ejecutar migraciones de manera desatendida
- ❌ CI/CD de migraciones está bloqueado

---

### P0-3: Contratos de Eventos RabbitMQ

**Proyectos afectados:** api-mobile, worker  
**Severidad:** 🔴 CRÍTICA - BLOQUEANTE DE INTEGRACIÓN  
**Tiempo estimado:** 4-5 horas

**Ambigüedad:**
- ¿Estructura JSON exacta de `material.uploaded`?
- ¿Estructura JSON exacta de `assessment.generated`?
- ¿Versionamiento de eventos? (¿Qué pasa con breaking changes?)
- ¿Configuración de exchanges, queues, bindings?

**Impacto:**
- api-mobile y worker pueden usar formatos incompatibles
- Breaking changes rompen integración sin aviso
- Debugging de eventos imposible

**Solución requerida:**
- Crear `EVENT_CONTRACTS.md` con estructura JSON completa
- Especificar estrategia de versionamiento (v1.0, v1.1, v2.0)
- Documentar configuración RabbitMQ (exchanges, queues, routing keys)

**Hasta que se resuelva:**
- ❌ worker NO puede consumir eventos correctamente
- ❌ Integración api-mobile ↔ worker bloqueada

---

### P0-4: docker-compose.yml No Existe

**Proyectos afectados:** TODOS (5/5)  
**Severidad:** 🔴 CRÍTICA - BLOQUEANTE DE DESARROLLO LOCAL  
**Tiempo estimado:** 4-5 horas

**Problema:**
- Archivo docker-compose.yml NO EXISTE
- Scripts (setup.sh, seed-data.sh) NO EXISTEN
- Seeds de datos NO EXISTEN
- Desarrollo local imposible

**Impacto:**
- Ningún desarrollador puede levantar infraestructura local
- Tests de integración no se pueden ejecutar
- Setup manual propenso a errores

**Solución requerida:**
- Crear dev-environment/docker-compose.yml (PostgreSQL, MongoDB, RabbitMQ)
- Crear scripts/setup.sh automatizado
- Crear scripts/seed-data.sh con datos de prueba
- Crear .env.example con variables necesarias

**Hasta que se resuelva:**
- ❌ Desarrollo local bloqueado
- ❌ Tests de integración no se pueden ejecutar

---

### P1-1: Sincronización PostgreSQL ↔ MongoDB

**Proyectos afectados:** api-mobile, worker  
**Severidad:** 🟡 ALTA - DECISIÓN ARQUITECTÓNICA  
**Tiempo estimado:** 3-4 horas

**Ambigüedad:**
- ¿Orden de creación? (¿MongoDB primero o PostgreSQL primero?)
- ¿Patrón de consistencia? (2PC, Saga, Eventual Consistency)
- ¿Qué hacer con inconsistencias? (orphan records, referencias rotas)
- ¿Transacciones distribuidas necesarias?

**Impacto:**
- Riesgo de race conditions
- Datos inconsistentes entre bases de datos
- Debugging complejo de problemas de sincronización

**Solución requerida:**
- Especificar patrón de sincronización (recomendado: Eventual Consistency)
- Documentar flujo exacto de creación en assessment
- Definir manejo de fallos y reintentos
- Crear cronjob de validación de integridad

**Hasta que se resuelva:**
- ⚠️ Desarrollo puede proceder con suposiciones
- ⚠️ Riesgo de implementar patrón incorrecto

---

## 📦 Dudas Específicas por Proyecto

### api-mobile (✅ Listo para trabajo vertical DESPUÉS de resolver cross-proyecto)

**Dependencias externas:**
- ⬜ P0-2: Ownership de tablas (¿crea materials o asume existe?)
- ⬜ P0-3: Contratos de eventos (estructura JSON de material.uploaded)
- ⬜ P0-4: docker-compose.yml (para levantar infra)
- ⬜ P1-1: Sincronización PG ↔ Mongo (orden en assessment)
- ✅ edugo-shared v0.7.0 (RESUELTO)

**Dudas internas (pueden resolverse durante desarrollo):**

1. **Validación de archivos soportados**
   - Severidad: 🟢 Baja
   - ¿Qué formatos exactamente? (PDF, DOCX, PPTX, ¿otros?)
   - ¿Tamaño máximo de archivo?
   - ¿Validación de contenido?

2. **Formato de respuestas de API**
   - Severidad: 🟡 Media
   - ¿Estructura exacta de respuestas de error?
   - ¿Paginación estándar?

3. **Permisos por endpoint**
   - Severidad: 🟡 Media
   - Matriz de permisos (qué rol puede hacer qué)

**Estrategia:**
- Esperar resolución de P0-2, P0-3, P0-4, P1-1
- Luego desarrollo vertical autónomo (Sprints 01-03)

---

### api-administracion (✅ Listo para trabajo vertical DESPUÉS de resolver cross-proyecto)

**Dependencias externas:**
- ⬜ P0-2: Ownership de tablas (confirmar que crea users, schools)
- ⬜ P0-4: docker-compose.yml (para levantar infra)
- ✅ edugo-shared v0.7.0 (RESUELTO)

**Dudas internas (pueden resolverse durante desarrollo):**

1. **Seeds de datos iniciales**
   - Severidad: 🟡 Media
   - ¿Qué datos crear al inicializar?
   - ¿Roles por defecto? (admin, super-admin)

2. **Permisos granulares**
   - Severidad: 🟡 Media
   - Matriz completa de permisos por rol
   - ¿Permisos por escuela o globales?

3. **Workflow de aprobación de escuelas**
   - Severidad: 🟢 Baja
   - ¿Escuelas se aprueban manualmente?
   - ¿Quién puede aprobar?

**Estrategia:**
- Esperar resolución de P0-2, P0-4
- Luego desarrollo vertical autónomo (Sprints 01-02)
- P0-2 es crítico (api-admin crea tablas base)

---

### worker (✅ Listo para trabajo vertical DESPUÉS de resolver cross-proyecto)

**Dependencias externas:**
- ⬜ P0-3: Contratos de eventos (estructura JSON de material.uploaded)
- ⬜ P0-4: docker-compose.yml (para levantar infra)
- ⬜ P1-1: Sincronización PG ↔ Mongo (orden en assessment)
- ✅ edugo-shared v0.7.0 (RESUELTO - incluye DLQ y evaluation)

**Dudas internas (pueden resolverse durante desarrollo):**

1. **SLA de OpenAI**
   - Severidad: 🟡 Media
   - ¿Qué hacer si excede 60 segundos?
   - ¿UX asíncrono? (notificar después)
   - ¿Retry strategy?

2. **Costos de OpenAI**
   - Severidad: 🟡 Media
   - ¿Límites por escuela?
   - ¿Qué hacer si se excede presupuesto?
   - ¿Degradación graceful?

3. **Validación de calidad de resúmenes**
   - Severidad: 🟢 Baja
   - ¿Cómo validar que resumen es bueno?
   - ¿Umbral mínimo de longitud?
   - ¿Validación de coherencia?

4. **Rate limiting de OpenAI**
   - Severidad: 🟡 Media
   - ¿Cómo manejar error 429?
   - ¿Backoff exponencial?
   - ¿Encolar para después?

**Estrategia:**
- Esperar resolución de P0-3, P0-4, P1-1
- Luego desarrollo vertical autónomo (Sprints 04-05)
- P0-3 es CRÍTICO (worker consume eventos)

---

### dev-environment (🚧 EN PROGRESO - P0-4)

**Dependencias externas:**
- ⬜ P0-4: docker-compose.yml (ES ESTE PROYECTO)
- ✅ edugo-shared v0.7.0 (RESUELTO)

**Tareas específicas:**

1. **docker-compose.yml**
   - Severidad: 🔴 CRÍTICA
   - PostgreSQL 15
   - MongoDB 7.0
   - RabbitMQ 3.12
   - Mongo Express (opcional)
   - PgAdmin (opcional)

2. **Scripts de setup**
   - Severidad: 🔴 CRÍTICA
   - setup.sh (levantar todo automatizado)
   - seed-data.sh (datos de prueba)
   - teardown.sh (limpiar)

3. **Seeds de datos**
   - Severidad: 🟡 Media
   - seeds/postgres/*.sql (users, schools, materials de prueba)
   - seeds/mongodb/*.js (material_summary, material_assessment)

4. **.env.example**
   - Severidad: 🔴 CRÍTICA
   - Variables para todos los proyectos
   - Valores de ejemplo razonables

**Estrategia:**
- Ejecutar P0-4 (4-5 horas)
- Desbloquea TODOS los demás proyectos
- Prioridad MÁXIMA

---

### edugo-shared (✅ COMPLETADO - v0.7.0 FROZEN)

**Estado:** ✅ 100% completado y congelado  
**Versión:** v0.7.0 (FROZEN hasta post-MVP)  
**Dudas restantes:** NINGUNA

**Política:**
- Solo bug fixes críticos (v0.7.1, v0.7.2, etc.)
- NO nuevas features
- NO refactoring

**Ver detalles en:**
- `00-ERRORES_CRITICOS_CORREGIDOS.md`
- `/repos-separados/edugo-shared/FROZEN.md`

---

## 🎯 Orden de Ejecución Recomendado

### Fase 0: Resolver Cross-Proyecto (2-3 días)

```
Día 1:
├─ P0-4: docker-compose.yml + scripts (4-5h) ← MÁXIMA PRIORIDAD
└─ P0-2: TABLE_OWNERSHIP.md (3-4h)

Día 2:
├─ P0-3: EVENT_CONTRACTS.md (4-5h)
└─ P1-1: Sincronización PG ↔ Mongo (3-4h)

Resultado: TODOS los proyectos desbloqueados
```

### Fase 1: Trabajo Vertical Paralelo (Sprints 01-02)

```
Sprint 01-02 (Paralelo):
├─ api-administracion (crea tablas base)
│   ├─ Migraciones (users, schools, academic_units)
│   ├─ Endpoints CRUD básicos
│   └─ Tests de integración
│
└─ api-mobile (asume tablas base existen)
    ├─ Espera que api-admin complete migraciones
    ├─ Migraciones (materials, assessment)
    ├─ Endpoints CRUD + upload
    └─ Tests de integración
```

### Fase 2: Trabajo Vertical Secuencial (Sprints 03-05)

```
Sprint 03:
└─ api-mobile (continuar)
    ├─ Publicación de eventos RabbitMQ
    └─ Integración con shared

Sprint 04-05:
└─ worker
    ├─ Consumo de eventos
    ├─ Integración OpenAI
    ├─ Generación de resúmenes/quizzes
    └─ Publicación de resultados
```

### Fase 3: Integración (Sprint 06)

```
Sprint 06:
└─ Integración completa
    ├─ Tests E2E
    ├─ Deployment
    └─ Validación final
```

---

## 📊 Métricas de Bloqueo

### Antes de Resolver Cross-Proyecto

| Proyecto | Bloqueado por | Puede iniciar | Progreso posible |
|----------|---------------|---------------|------------------|
| **api-admin** | P0-2, P0-4 | ❌ NO | 0% |
| **api-mobile** | P0-2, P0-3, P0-4, P1-1 | ❌ NO | 0% |
| **worker** | P0-3, P0-4, P1-1 | ❌ NO | 0% |
| **dev-environment** | P0-4 (es él mismo) | 🟡 PARCIAL | 50% (solo docs) |
| **shared** | - | ✅ SÍ | 100% (FROZEN) |

**Proyectos bloqueados:** 3/5 (60%)

---

### Después de Resolver Cross-Proyecto

| Proyecto | Bloqueado por | Puede iniciar | Progreso posible |
|----------|---------------|---------------|------------------|
| **api-admin** | - | ✅ SÍ | 100% |
| **api-mobile** | - | ✅ SÍ | 100% |
| **worker** | - | ✅ SÍ | 100% |
| **dev-environment** | - | ✅ SÍ | 100% |
| **shared** | - | ✅ SÍ | 100% (FROZEN) |

**Proyectos bloqueados:** 0/5 (0%) 🎉

---

## ✅ Checklist de Readiness por Proyecto

### api-administracion

**Prerequisitos cross-proyecto:**
- [ ] P0-2: TABLE_OWNERSHIP.md confirmando que crea users, schools
- [ ] P0-4: docker-compose.yml para levantar PostgreSQL local

**Prerequisitos internos:**
- [x] edugo-shared v0.7.0 (auth, logger, config, database)
- [ ] Decisión: Seeds de datos iniciales
- [ ] Decisión: Permisos granulares por rol

**Estado:** ⬜ 40% listo (esperando P0-2, P0-4)

---

### api-mobile

**Prerequisitos cross-proyecto:**
- [ ] P0-2: TABLE_OWNERSHIP.md definiendo ownership de materials
- [ ] P0-3: EVENT_CONTRACTS.md con estructura de material.uploaded
- [ ] P0-4: docker-compose.yml para levantar infra local
- [ ] P1-1: Sincronización PG ↔ Mongo en assessment

**Prerequisitos internos:**
- [x] edugo-shared v0.7.0 (auth, logger, config, messaging, database)
- [ ] Decisión: Validación de archivos soportados
- [ ] Decisión: Formato de respuestas de API

**Estado:** ⬜ 30% listo (esperando P0-2, P0-3, P0-4, P1-1)

---

### worker

**Prerequisitos cross-proyecto:**
- [ ] P0-3: EVENT_CONTRACTS.md con estructura de material.uploaded
- [ ] P0-4: docker-compose.yml para levantar infra local
- [ ] P1-1: Sincronización PG ↔ Mongo en assessment

**Prerequisitos internos:**
- [x] edugo-shared v0.7.0 (logger, config, messaging, database, evaluation)
- [ ] Decisión: SLA de OpenAI y UX asíncrono
- [ ] Decisión: Costos de OpenAI y límites
- [ ] Decisión: Validación de calidad de resúmenes

**Estado:** ⬜ 35% listo (esperando P0-3, P0-4, P1-1)

---

### dev-environment

**Prerequisitos cross-proyecto:**
- [ ] P0-4: docker-compose.yml (ES ESTE PROYECTO)

**Prerequisitos internos:**
- [x] Decisión: Servicios a incluir (PostgreSQL, MongoDB, RabbitMQ)
- [ ] Implementación: Scripts de setup
- [ ] Implementación: Seeds de datos

**Estado:** ⬜ 50% listo (solo documentación, falta código)

---

## 🎊 Conclusión

### Estrategia Clara

1. **Inmediato (2-3 días):** Resolver P0-2, P0-3, P0-4, P1-1
2. **Después:** Desarrollo vertical paralelo/secuencial sin bloqueos
3. **Resultado:** 5/5 proyectos desbloqueados, desarrollo autónomo posible

### Impacto de Resolver Cross-Proyecto

| Métrica | Antes | Después | Mejora |
|---------|-------|---------|--------|
| Proyectos desbloqueados | 1/5 (20%) | 5/5 (100%) | +80% |
| Completitud global | 88% | 96% | +8% |
| Desarrollo autónomo posible | ❌ NO | ✅ SÍ | 100% |

### Próxima Acción

**Ejecutar P0-4 (docker-compose.yml) AHORA** - Desbloquea desarrollo local de TODOS.

---

**Última actualización:** 15 de Noviembre, 2025  
**Estado:** 1/5 problemas críticos resueltos (edugo-shared v0.7.0)  
**Próxima meta:** Resolver 4 problemas cross-proyecto restantes (2-3 días)

---

🚀 **Una vez resuelto cross-proyecto: Desarrollo vertical autónomo habilitado** 🚀
