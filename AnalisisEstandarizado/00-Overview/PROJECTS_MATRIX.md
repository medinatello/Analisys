# 📊 Matriz de Proyectos - Ecosistema EduGo

**Fecha:** 16 de Noviembre, 2025  
**Versión:** 2.0.0

---

## 🎯 Visión General

Esta matriz muestra las relaciones, dependencias y responsabilidades de cada proyecto del ecosistema EduGo.

---

## 📦 Matriz de Proyectos

| Proyecto | Versión | Estado | Prioridad | Rol | Completitud |
|----------|---------|--------|-----------|-----|-------------|
| **edugo-shared** | v0.7.0 | 🔒 FROZEN | - | Biblioteca compartida | 100% |
| **edugo-infrastructure** | v0.1.1 | ✅ Activo | P0 | Infraestructura centralizada | 96% |
| **edugo-api-administracion** | v0.2.0 | ✅ Completado | P0 | API admin académica | 100% |
| **edugo-dev-environment** | - | ✅ Completado | P1 | Entorno desarrollo | 100% |
| **edugo-api-mobile** | - | 🔄 En progreso | P0 | API mobile estudiantes | 40% |
| **edugo-worker** | - | ⬜ Pendiente | P1 | Procesamiento IA | 0% |

---

## 🔗 Matriz de Dependencias

### Consumo de shared v0.7.0

| Proyecto | Módulos Consumidos |
|----------|-------------------|
| **api-administracion** | auth, logger, config, bootstrap, lifecycle, database/postgres |
| **api-mobile** | auth, logger, config, bootstrap, lifecycle, database/postgres, database/mongodb, messaging/rabbit, evaluation |
| **worker** | logger, config, messaging/rabbit, database/mongodb, evaluation |
| **dev-environment** | testing (solo para tests) |

### Consumo de infrastructure v0.1.1

| Proyecto | Componentes Usados |
|----------|--------------------|
| **api-administracion** | database/migrations (owner), docker/, scripts/ |
| **api-mobile** | database/migrations (consumer), docker/, schemas/, scripts/ |
| **worker** | docker/, schemas/, scripts/ |
| **dev-environment** | docker/ (referencia), scripts/, seeds/ |

---

## 🗄️ Matriz de Ownership de Bases de Datos

### PostgreSQL

| Tabla | Owner | Readers | Writers | Descripción |
|-------|-------|---------|---------|-------------|
| users | api-admin | todos | api-admin | Usuarios del sistema |
| schools | api-admin | todos | api-admin | Escuelas |
| academic_units | api-admin | api-mobile, api-admin | api-admin | Unidades académicas |
| unit_membership | api-admin | api-mobile, api-admin | api-admin | Membresías |
| materials | api-mobile | todos | api-mobile | Materiales educativos |
| assessment | api-mobile | api-mobile, worker | api-mobile, worker | Evaluaciones |
| assessment_attempt | api-mobile | api-mobile | api-mobile | Intentos |
| assessment_answer | api-mobile | api-mobile | api-mobile | Respuestas |

**Orden de ejecución de migraciones:**
1. api-administracion (tablas base)
2. api-mobile (tablas con foreign keys)

### MongoDB

| Colección | Owner | Readers | Writers | Descripción |
|-----------|-------|---------|---------|-------------|
| material_summary | worker | api-mobile | worker | Resúmenes IA |
| material_assessment | worker | api-mobile, worker | worker | Quizzes IA |
| material_event | worker | worker | worker | Log de eventos |

---

## 📨 Matriz de Eventos RabbitMQ

| Evento | Publisher | Consumer(s) | Propósito |
|--------|-----------|-------------|-----------|
| material.uploaded | api-mobile | worker | Notificar nuevo material para procesar |
| assessment.generated | worker | api-mobile | Notificar quiz generado |
| material.deleted | api-mobile | worker | Notificar eliminación de material |
| student.enrolled | api-admin | api-mobile | Notificar nueva matrícula |

**Exchange:** edugo.topic (tipo: topic)  
**DLQ:** Habilitado con retry 3x

---

## 🚀 Matriz de Puertos

| Proyecto | Puerto | Protocolo | Propósito |
|----------|--------|-----------|-----------|
| api-administracion | 8081 | HTTP | API REST admin |
| api-mobile | 8080 | HTTP | API REST mobile |
| worker | - | - | Worker asíncrono |
| PostgreSQL | 5432 | TCP | Base de datos |
| MongoDB | 27017 | TCP | Base de datos |
| RabbitMQ | 5672 | AMQP | Mensajería |
| RabbitMQ Management | 15672 | HTTP | UI admin |
| Redis | 6379 | TCP | Caché (opcional) |
| PgAdmin | 5050 | HTTP | UI PostgreSQL |
| Mongo Express | 8082 | HTTP | UI MongoDB |

---

## 📂 Matriz de Responsabilidades

### edugo-shared (v0.7.0 FROZEN)

**Responsabilidades:**
- ✅ Proveer módulos reutilizables
- ✅ Mantener compatibilidad con consumidores
- ✅ Documentar breaking changes (en post-MVP)
- ❌ NO agregar features nuevas hasta post-MVP

**Consumidores:** api-admin, api-mobile, worker

**Módulos clave:**
- auth: Autenticación JWT
- logger: Logging estructurado
- evaluation: Modelos de evaluaciones
- messaging/rabbit: Dead Letter Queue

---

### edugo-infrastructure (v0.1.1)

**Responsabilidades:**
- ✅ Definir migraciones de PostgreSQL
- ✅ Documentar ownership de tablas
- ✅ Proveer JSON Schemas de eventos
- ✅ Mantener Docker Compose actualizado
- ✅ Proveer scripts de automatización
- ✅ Mantener seeds de datos de prueba

**Consumidores:** Todos los proyectos

**Componentes clave:**
- database/: Migraciones y ownership
- schemas/: Contratos de eventos
- docker/: Infraestructura local

**Pendiente:**
- migrate.go CLI
- validator.go

---

### edugo-api-administracion (v0.2.0)

**Responsabilidades:**
- ✅ Gestión de escuelas
- ✅ Gestión de jerarquía académica
- ✅ Gestión de usuarios
- ✅ Gestión de membresías
- ✅ Owner de tablas: users, schools, academic_units, memberships

**Consumidores:** api-mobile (lee datos de jerarquía)

**Dependencias:**
- shared v0.7.0
- infrastructure v0.1.1 (database)

**Estado:** COMPLETADO - Sirve como referencia

---

### edugo-api-mobile (En desarrollo - 40%)

**Responsabilidades:**
- 🔄 Gestión de materiales educativos
- 🔄 Sistema de evaluaciones
- 🔄 Consumo de resúmenes/quizzes de IA
- 🔄 Integración con jerarquía académica
- 🔄 Owner de tablas: materials, assessment, assessment_attempt, assessment_answer

**Consumidores:** Aplicación móvil (estudiantes/docentes)

**Dependencias:**
- shared v0.7.0 (evaluation, messaging/rabbit)
- infrastructure v0.1.1 (database, schemas)

**Eventos:**
- Publica: material.uploaded, material.deleted
- Consume: assessment.generated, student.enrolled

**Pendiente:**
- Actualizar dependencias a shared v0.7.0
- Integrar infrastructure/schemas
- Completar endpoints de evaluaciones

---

### edugo-worker (Pendiente - 0%)

**Responsabilidades:**
- ⬜ Procesamiento de PDFs
- ⬜ Generación de resúmenes con OpenAI
- ⬜ Generación de quizzes con OpenAI
- ⬜ Owner de colecciones MongoDB: material_summary, material_assessment, material_event

**Consumidores:** Ninguno (worker asíncrono)

**Dependencias:**
- shared v0.7.0 (messaging/rabbit con DLQ, evaluation)
- infrastructure v0.1.1 (schemas)

**Eventos:**
- Consume: material.uploaded
- Publica: assessment.generated

**Pendiente:**
- Documentar costos de OpenAI
- Documentar SLA de OpenAI
- Implementar procesamiento completo

---

### edugo-dev-environment (Completado - 100%)

**Responsabilidades:**
- ✅ Proveer perfiles de Docker Compose
- ✅ Scripts de setup rápido
- ✅ Seeds de datos de prueba
- ✅ Documentación de inicio rápido

**Consumidores:** Desarrolladores locales

**Dependencias:**
- infrastructure v0.1.1 (referencia para docker y scripts)

**Perfiles:**
- full, db-only, api-only, mobile-only, admin-only, worker-only

---

## 🔄 Matriz de Flujos de Datos

### Flujo 1: Subida de Material

```
Docente (móvil)
    ↓ [HTTP POST]
api-mobile (Puerto 8080)
    ↓ [SQL INSERT]
PostgreSQL (materials)
    ↓ [RabbitMQ PUBLISH]
material.uploaded event
    ↓ [AMQP]
worker
    ↓ [OpenAI API]
Resumen + Quiz generado
    ↓ [MongoDB INSERT]
material_summary + material_assessment
    ↓ [RabbitMQ PUBLISH]
assessment.generated event
    ↓ [AMQP]
api-mobile
    ↓ [SQL UPDATE]
PostgreSQL (assessment.mongo_document_id)
```

### Flujo 2: Estudiante Toma Quiz

```
Estudiante (móvil)
    ↓ [HTTP GET]
api-mobile
    ↓ [SQL SELECT]
PostgreSQL (assessment) → obtiene mongo_document_id
    ↓ [MongoDB FIND]
MongoDB (material_assessment) → obtiene preguntas
    ↓ [Merge datos]
api-mobile
    ↓ [HTTP RESPONSE]
Estudiante (móvil) → muestra quiz
    ↓ [HTTP POST respuestas]
api-mobile
    ↓ [SQL INSERT]
PostgreSQL (assessment_attempt + assessment_answer)
    ↓ [Cálculo score]
api-mobile (usa shared/evaluation)
    ↓ [HTTP RESPONSE]
Estudiante (móvil) → muestra resultado
```

### Flujo 3: Admin Crea Escuela

```
Admin (web)
    ↓ [HTTP POST]
api-administracion (Puerto 8081)
    ↓ [SQL INSERT]
PostgreSQL (schools)
    ↓ [SQL INSERT]
PostgreSQL (academic_units) → unidad raíz
    ↓ [HTTP RESPONSE]
Admin (web) → confirmación
```

### Flujo 4: Student Enrollment

```
Admin (api-admin)
    ↓ [SQL INSERT]
PostgreSQL (unit_membership)
    ↓ [RabbitMQ PUBLISH]
student.enrolled event
    ↓ [AMQP]
api-mobile
    ↓ [Actualiza caché/notificación]
api-mobile
```

---

## 🧪 Matriz de Testing

### Estrategia por Proyecto

| Proyecto | Unit Tests | Integration Tests | E2E Tests | Coverage Objetivo |
|----------|-----------|-------------------|-----------|------------------|
| shared | ✅ Sí | ✅ Sí (Testcontainers) | ❌ No | >80% |
| infrastructure | ❌ No | ✅ Sí (scripts) | ❌ No | N/A |
| api-admin | ✅ Sí | ✅ Sí (Testcontainers) | ✅ Sí | >80% |
| api-mobile | ✅ Sí | ✅ Sí (Testcontainers) | ✅ Sí | >80% |
| worker | ✅ Sí | ✅ Sí (Testcontainers) | ✅ Sí | >80% |

### Uso de shared/testing

| Proyecto | Usa Testcontainers de shared |
|----------|------------------------------|
| api-admin | ✅ Sí (PostgreSQL) |
| api-mobile | ✅ Sí (PostgreSQL + MongoDB + RabbitMQ) |
| worker | ✅ Sí (MongoDB + RabbitMQ) |

---

## 🚀 Matriz de Deployment

### Orden de Deployment

| Orden | Proyecto | Motivo |
|-------|----------|--------|
| 1 | infrastructure | Infraestructura base (PostgreSQL, MongoDB, RabbitMQ) |
| 2 | shared | Biblioteca compartida (no despliega, se consume) |
| 3 | api-administracion | Owner de tablas base |
| 4 | api-mobile | Requiere tablas de api-admin |
| 5 | worker | Requiere schemas y tablas de api-mobile |

### Environments

| Proyecto | Local | Dev | QA | Prod |
|----------|-------|-----|----|----|
| shared | N/A | N/A | N/A | N/A |
| infrastructure | ✅ Docker | ✅ K8s | ✅ K8s | ✅ K8s |
| api-admin | ✅ Go run | ✅ K8s | ✅ K8s | ✅ K8s |
| api-mobile | ✅ Go run | ✅ K8s | ✅ K8s | ✅ K8s |
| worker | ✅ Go run | ✅ K8s | ✅ K8s | ✅ K8s |

---

## 📊 Matriz de Métricas

### LOC (Lines of Code)

| Proyecto | LOC Estimadas | Estado |
|----------|---------------|--------|
| shared | ~5,000 | ✅ Completado |
| infrastructure | ~1,500 | ✅ 96% |
| api-admin | ~5,000 | ✅ Completado |
| api-mobile | ~6,000 (estimado) | 🔄 40% |
| worker | ~3,000 (estimado) | ⬜ 0% |

### Tests

| Proyecto | Tests Unitarios | Tests Integración | Total |
|----------|----------------|-------------------|-------|
| shared | 90+ | - | 90+ |
| infrastructure | - | - | - |
| api-admin | 40+ | 10+ | 50+ |
| api-mobile | (pendiente) | (pendiente) | 0 |
| worker | (pendiente) | (pendiente) | 0 |

### PRs Mergeados

| Proyecto | PRs |
|----------|-----|
| shared | 2 |
| infrastructure | 4 |
| api-admin | 9 |
| api-mobile | 2 |
| worker | 2 |
| dev-environment | 2 |

---

## 📝 Notas Importantes

### Dependencias entre Proyectos

1. **Orden crítico de ejecución:**
   - infrastructure debe ejecutarse primero (migraciones)
   - api-admin debe ejecutarse antes que api-mobile (tablas base)
   - worker puede ejecutarse después de api-mobile (eventos)

2. **shared está FROZEN:**
   - No esperar nuevas features
   - Consumir módulos existentes
   - Solo bug fixes críticos en v0.7.x

3. **infrastructure es la fuente de verdad:**
   - Migraciones: definidas en infrastructure/database
   - Eventos: esquemas en infrastructure/schemas
   - Docker: configuración en infrastructure/docker

4. **Sincronización PostgreSQL ↔ MongoDB:**
   - MongoDB primero (contenido)
   - Evento publicado (mongo_id)
   - PostgreSQL después (referencia)
   - Eventual consistency aceptable

### Para Desarrolladores

**Antes de iniciar desarrollo de un proyecto:**
1. Verificar que shared v0.7.0 está disponible
2. Verificar que infrastructure está configurado
3. Ejecutar migraciones en orden correcto
4. Validar eventos con schemas de infrastructure
5. Usar shared/testing para tests de integración

**Durante desarrollo:**
1. Seguir Clean Architecture (ver api-admin como referencia)
2. Mantener >80% test coverage
3. Validar eventos antes de publicar
4. Documentar decisiones técnicas

**Antes de merge:**
1. Todos los tests pasando
2. Coverage >80%
3. CI/CD pasando
4. Documentación actualizada

---

**Generado:** 16 de Noviembre, 2025  
**Por:** Claude Code  
**Versión:** 2.0.0
