# 🌐 Visión General del Ecosistema EduGo

**Fecha:** 16 de Noviembre, 2025  
**Versión:** 2.0.0  
**Estado:** Desarrollo Viable - Completitud 96%

---

## 🎯 Propósito del Ecosistema

EduGo es una plataforma educativa compuesta por 6 repositorios independientes que trabajan en conjunto para ofrecer gestión académica, evaluaciones inteligentes y procesamiento de contenido con IA.

---

## 📦 Proyectos del Ecosistema

### 1. edugo-shared (FROZEN)

**Rol:** Biblioteca compartida Go con módulos reutilizables  
**Versión:** v0.7.0 (CONGELADA hasta post-MVP)  
**Estado:** ✅ 100% Completado  
**Repositorio:** https://github.com/EduGoGroup/edugo-shared

**Módulos (12):**
- **auth** (87.3% coverage) - JWT authentication, roles, refresh tokens
- **logger** (95.8% coverage) - Structured logging con Zap
- **common** (>94% coverage) - Errors, types, validator
- **config** (82.9% coverage) - Multi-environment configuration
- **bootstrap** (31.9% coverage) - Application initialization
- **lifecycle** (91.8% coverage) - Graceful shutdown
- **middleware/gin** (98.5% coverage) - JWT, logging, CORS middlewares
- **messaging/rabbit** (3.2% coverage) - Publisher, consumer, Dead Letter Queue
- **database/postgres** (58.8% coverage) - GORM utilities, transactions
- **database/mongodb** (54.5% coverage) - MongoDB client, pooling
- **testing** (59.0% coverage) - Testcontainers helpers
- **evaluation** (100% coverage) - Assessment, Question, Attempt models

**Política de Congelamiento:**
- ✅ Bug fixes críticos permitidos (v0.7.x)
- ❌ NO nuevas features hasta post-MVP
- ✅ Documentación siempre permitida

**Consumido por:** Todos los proyectos

---

### 2. edugo-infrastructure

**Rol:** Centralización de infraestructura compartida  
**Versión:** v0.1.1  
**Estado:** ✅ 96% Completado  
**Repositorio:** https://github.com/EduGoGroup/edugo-infrastructure

**Responsabilidades:**
- Migraciones de base de datos PostgreSQL (8 tablas)
- Contratos de eventos RabbitMQ (4 eventos con JSON Schemas)
- Docker Compose para desarrollo local (4 perfiles)
- Scripts de automatización (setup, seeds, validación)
- Seeds de datos de prueba (PostgreSQL + MongoDB)

**Módulos:**

**database/ (v0.1.1)**
- 8 migraciones SQL con UP/DOWN
- TABLE_OWNERSHIP.md (ownership por tabla)
- migrate.go CLI (pendiente)

**docker/ (v0.1.1)**
- docker-compose.yml con perfiles: core, messaging, cache, tools
- Servicios: PostgreSQL 15, MongoDB 7.0, RabbitMQ 3.12, Redis 7, PgAdmin, Mongo Express
- Healthchecks y networking configurados

**schemas/ (v0.1.1)**
- 4 JSON Schemas de eventos (material.uploaded, assessment.generated, etc.)
- EVENT_CONTRACTS.md con documentación completa
- validator.go (pendiente)

**scripts/ (v0.1.1)**
- dev-setup.sh (setup automatizado)
- seed-data.sh (carga de datos)
- validate-env.sh (validación de variables)

**seeds/**
- PostgreSQL: users, schools, materials, etc.
- MongoDB: assessments, summaries

**Consumido por:** Todos los proyectos

**Pendiente:**
- database/migrate.go (1-2h)
- schemas/validator.go (2-3h)

---

### 3. edugo-api-administracion

**Rol:** API REST para administración académica  
**Versión:** v0.2.0  
**Estado:** ✅ 100% Completado  
**Repositorio:** https://github.com/EduGoGroup/edugo-api-administracion

**Puerto:** 8081

**Funcionalidades:**
- Gestión de escuelas (schools)
- Gestión de unidades académicas con jerarquía (academic_units)
- Gestión de usuarios (admins, tutores, estudiantes)
- Gestión de membresías (unit_membership)
- Sistema de jerarquía académica completo

**Arquitectura:**
- Clean Architecture implementada
- Capas: domain, application, infrastructure
- 15+ endpoints REST
- >80% test coverage

**Dependencias:**
- shared v0.7.0 (auth, logger, config, database/postgres, lifecycle)
- infrastructure v0.1.1 (database para migraciones)

**Base de datos:**
- PostgreSQL (owner de: users, schools, academic_units, memberships)

---

### 4. edugo-api-mobile

**Rol:** API REST para aplicación móvil de estudiantes/docentes  
**Versión:** En desarrollo  
**Estado:** 🔄 40% Completado  
**Repositorio:** https://github.com/EduGoGroup/edugo-api-mobile

**Puerto:** 8080

**Funcionalidades (planificadas):**
- Gestión de materiales educativos
- Sistema de evaluaciones (quizzes, attempts, scoring)
- Consumo de resúmenes generados por IA
- Integración con jerarquía académica

**Arquitectura:**
- Clean Architecture
- Capas: domain, application, infrastructure
- Integración con MongoDB para assessments

**Dependencias:**
- shared v0.7.0 (auth, logger, config, database/postgres, database/mongodb, evaluation, messaging/rabbit)
- infrastructure v0.1.1 (database, schemas para validación de eventos)

**Base de datos:**
- PostgreSQL (owner de: materials, assessment, assessment_attempt, assessment_answer)
- MongoDB (consumer de: material_summary, material_assessment)

**Estado actual:** Pendiente actualizar dependencias y completar endpoints

---

### 5. edugo-worker

**Rol:** Worker de procesamiento asíncrono con IA  
**Versión:** En desarrollo  
**Estado:** ⬜ 0% Completado  
**Repositorio:** https://github.com/EduGoGroup/edugo-worker

**Funcionalidades (planificadas):**
- Procesamiento de PDFs subidos por docentes
- Generación de resúmenes con OpenAI
- Generación de quizzes automáticos con OpenAI
- Publicación de eventos de procesamiento completado

**Arquitectura:**
- Event-driven con RabbitMQ
- Procesamiento asíncrono
- Retry con Dead Letter Queue

**Dependencias:**
- shared v0.7.0 (logger, config, messaging/rabbit con DLQ, database/mongodb, evaluation)
- infrastructure v0.1.1 (schemas para validación de eventos)

**Base de datos:**
- MongoDB (owner de: material_summary, material_assessment)

**Eventos:**
- Consume: material.uploaded
- Publica: assessment.generated, material.deleted

**Pendiente:**
- Documentar costos de OpenAI
- Documentar SLA de OpenAI
- Implementar procesamiento completo

---

### 6. edugo-dev-environment

**Rol:** Entorno de desarrollo local configurado  
**Versión:** Actualizado  
**Estado:** ✅ 100% Completado  
**Repositorio:** https://github.com/EduGoGroup/edugo-dev-environment

**Funcionalidades:**
- Docker Compose profiles para diferentes escenarios
- Scripts de setup automatizado
- Seeds de datos de prueba
- Documentación de inicio rápido

**Profiles disponibles:**
- `full`: Todos los servicios
- `db-only`: Solo bases de datos
- `api-only`: APIs + BDs
- `mobile-only`: api-mobile + BDs
- `admin-only`: api-admin + BDs
- `worker-only`: worker + BDs

**Scripts:**
- setup.sh (con flags --profile, --seed)
- seed-data.sh
- stop.sh

**Integración:**
- Referencia infrastructure/docker para configuración completa
- Usa infrastructure/scripts para automatización
- Seeds sincronizados con infrastructure/seeds

**Uso recomendado:**
```bash
# Setup rápido para development
./scripts/setup.sh --profile db-only --seed

# Para setup completo del ecosistema, usar infrastructure:
cd ../edugo-infrastructure
make dev-setup
```

---

## 🔄 Flujo de Datos del Ecosistema

### Flujo Principal: Subida de Material

```
1. Docente sube PDF
   ↓
2. api-mobile recibe archivo
   ↓
3. api-mobile guarda en PostgreSQL (materials)
   ↓
4. api-mobile publica evento: material.uploaded (RabbitMQ)
   ↓
5. worker consume evento
   ↓
6. worker procesa PDF con OpenAI
   ↓
7. worker guarda en MongoDB (material_summary, material_assessment)
   ↓
8. worker publica evento: assessment.generated
   ↓
9. api-mobile consume evento
   ↓
10. api-mobile actualiza PostgreSQL (assessment.mongo_document_id)
```

### Patrón de Sincronización PostgreSQL ↔ MongoDB

**MongoDB primero + Eventual Consistency:**
1. Worker crea documento en MongoDB (fuente de verdad del contenido)
2. Worker publica evento con mongo_document_id
3. api-mobile consume evento
4. api-mobile crea registro en PostgreSQL con referencia a MongoDB
5. Si PostgreSQL falla: Retry 3x → Dead Letter Queue

---

## 🗄️ Base de Datos

### PostgreSQL 15

**Ownership de Tablas:**

| Tabla | Owner | Descripción |
|-------|-------|-------------|
| users | api-admin | Usuarios del sistema |
| schools | api-admin | Escuelas |
| academic_units | api-admin | Unidades académicas (jerarquía) |
| unit_membership | api-admin | Membresías en unidades |
| materials | api-mobile | Materiales educativos |
| assessment | api-mobile | Evaluaciones (referencia a MongoDB) |
| assessment_attempt | api-mobile | Intentos de evaluación |
| assessment_answer | api-mobile | Respuestas de estudiantes |

**Orden de migraciones:**
1. api-admin ejecuta primero (tablas base)
2. api-mobile ejecuta después (tablas que referencian a base)

**Fuente de verdad:** infrastructure/database/TABLE_OWNERSHIP.md

### MongoDB 7.0

**Colecciones:**

| Colección | Owner | Descripción |
|-----------|-------|-------------|
| material_summary | worker | Resúmenes de materiales generados por IA |
| material_assessment | worker | Quizzes generados por IA |
| material_event | worker | Log de eventos de procesamiento |

---

## 📨 Sistema de Mensajería

### RabbitMQ 3.12

**Exchange:** edugo.topic (tipo: topic)

**Eventos Documentados:**

| Evento | Publisher | Consumer | Schema |
|--------|-----------|----------|--------|
| material.uploaded | api-mobile | worker | material-uploaded-v1.schema.json |
| assessment.generated | worker | api-mobile | assessment-generated-v1.schema.json |
| material.deleted | api-mobile | worker | material-deleted-v1.schema.json |
| student.enrolled | api-admin | api-mobile | student-enrolled-v1.schema.json |

**Configuración:**
- Dead Letter Queue habilitada (shared/messaging/rabbit)
- Retry automático: 3 intentos con exponential backoff
- Validación automática con infrastructure/schemas

**Fuente de verdad:** infrastructure/EVENT_CONTRACTS.md

---

## 🛠️ Stack Tecnológico

### Backend
- **Lenguaje:** Go 1.24
- **Framework Web:** Gin
- **ORM:** GORM (PostgreSQL)
- **MongoDB Driver:** mongo-driver oficial

### Bases de Datos
- **PostgreSQL:** 15 (relacional)
- **MongoDB:** 7.0 (documentos)
- **Redis:** 7 (caché - opcional)

### Mensajería
- **RabbitMQ:** 3.12

### IA
- **OpenAI:** GPT-4 para resúmenes y quizzes

### Infraestructura
- **Docker:** Contenedores
- **Docker Compose:** Orquestación local

### Testing
- **Testcontainers:** Tests de integración
- **Coverage:** >80% objetivo

### CI/CD
- **GitHub Actions:** Workflows automatizados
- **GitLab CI:** Mirrors (opcional)

---

## 📊 Métricas del Ecosistema

### Completitud Global
- **Documentación:** 96%
- **Proyectos completados:** 3/6 (50%)
- **Proyectos en progreso:** 1/6 (17%)
- **Proyectos pendientes:** 2/6 (33%)

### Estado de Desarrollo
- **Desarrollo viable:** ✅ SÍ
- **Bloqueantes críticos:** 0
- **Bloqueantes importantes:** 2 (costos y SLA OpenAI - no críticos)

### Código
- **Total LOC:** +12,167 (shared + infrastructure + api-admin)
- **Total Tests:** 140+
- **Total PRs mergeados:** 17
- **Total Releases:** 8

---

## 🚀 Setup del Ecosistema

### Opción 1: Setup Completo (infrastructure)

```bash
cd edugo-infrastructure
make dev-setup
# → Levanta todos los servicios en 5 minutos
# → Ejecuta migraciones automáticamente
# → Carga seeds de datos
```

### Opción 2: Setup por Perfil (dev-environment)

```bash
cd edugo-dev-environment

# Solo bases de datos
./scripts/setup.sh --profile db-only --seed

# APIs + BDs
./scripts/setup.sh --profile api-only --seed

# Todo el ecosistema
./scripts/setup.sh --profile full --seed
```

### Opción 3: Manual (para desarrollo)

```bash
# 1. Levantar servicios base
cd edugo-infrastructure/docker
docker-compose up -d postgres mongodb rabbitmq

# 2. Ejecutar migraciones
cd ../database
# (pendiente: go run migrate.go up)
# Por ahora: ejecutar SQLs manualmente

# 3. Cargar seeds
cd ../scripts
./seed-data.sh

# 4. Levantar API específica
cd ../../edugo-api-administracion
go run cmd/api/main.go
```

---

## 📁 Estructura de Repositorios

```
EduGoGroup/
├── edugo-shared/              # v0.7.0 FROZEN
│   ├── auth/
│   ├── logger/
│   ├── common/
│   ├── config/
│   ├── bootstrap/
│   ├── lifecycle/
│   ├── middleware/gin/
│   ├── messaging/rabbit/
│   ├── database/postgres/
│   ├── database/mongodb/
│   ├── testing/
│   └── evaluation/            # NUEVO en v0.7.0
│
├── edugo-infrastructure/      # v0.1.1
│   ├── database/
│   │   ├── migrations/
│   │   └── TABLE_OWNERSHIP.md
│   ├── docker/
│   │   └── docker-compose.yml
│   ├── schemas/
│   │   └── events/
│   ├── scripts/
│   └── seeds/
│
├── edugo-api-administracion/  # v0.2.0
│   ├── cmd/api/
│   ├── internal/
│   │   ├── domain/
│   │   ├── application/
│   │   └── infrastructure/
│   └── tests/
│
├── edugo-api-mobile/          # En desarrollo
│   ├── cmd/api/
│   ├── internal/
│   │   ├── domain/
│   │   ├── application/
│   │   └── infrastructure/
│   └── tests/
│
├── edugo-worker/              # Pendiente
│   ├── cmd/worker/
│   ├── internal/
│   │   ├── processors/
│   │   └── services/
│   └── tests/
│
└── edugo-dev-environment/     # Actualizado
    ├── docker/
    ├── scripts/
    └── seeds/
```

---

## 🔗 Links Importantes

### Repositorios
- **Organización:** https://github.com/EduGoGroup
- **shared:** https://github.com/EduGoGroup/edugo-shared
- **infrastructure:** https://github.com/EduGoGroup/edugo-infrastructure
- **api-admin:** https://github.com/EduGoGroup/edugo-api-administracion
- **api-mobile:** https://github.com/EduGoGroup/edugo-api-mobile
- **worker:** https://github.com/EduGoGroup/edugo-worker
- **dev-environment:** https://github.com/EduGoGroup/edugo-dev-environment

### Rutas Locales
- **Documentación:** `/Users/jhoanmedina/source/EduGo/Analisys`
- **Repositorios:** `/Users/jhoanmedina/source/EduGo/repos-separados/`

### Documentación Clave
- **shared:** FROZEN.md, CHANGELOG.md
- **infrastructure:** TABLE_OWNERSHIP.md, EVENT_CONTRACTS.md
- **AnalisisEstandarizado:** MASTER_PLAN.md, MASTER_PROGRESS.json

---

## 📝 Notas Importantes

### Para Desarrolladores

1. **shared está FROZEN (v0.7.0)**
   - No agregar features nuevas
   - Solo bug fixes críticos
   - Consumir módulos existentes

2. **infrastructure es la fuente de verdad**
   - Migraciones: infrastructure/database
   - Eventos: infrastructure/schemas
   - Docker: infrastructure/docker

3. **Orden de migraciones importa**
   - api-admin ejecuta PRIMERO
   - api-mobile ejecuta DESPUÉS
   - Ver TABLE_OWNERSHIP.md

4. **Validar eventos con schemas**
   - Usar infrastructure/schemas
   - Validar antes de publicar
   - Validar al consumir

5. **Dead Letter Queue habilitada**
   - Usar shared/messaging/rabbit v0.7.0
   - Retry automático 3x
   - Manejo de errores robusto

### Para Product Owners

1. **Desarrollo es viable**
   - Todos los bloqueantes críticos resueltos
   - Base estable (shared FROZEN + infrastructure)
   - Proyectos desbloqueados

2. **Prioridades claras**
   - api-mobile evaluaciones (P0)
   - worker procesamiento (P1)
   - Documentar costos/SLA OpenAI (P1)

3. **Tiempo estimado**
   - api-mobile: 2-3 semanas
   - worker: 3-4 semanas
   - Total hasta MVP: 5-7 semanas

---

**Generado:** 16 de Noviembre, 2025  
**Por:** Claude Code  
**Versión del documento:** 2.0.0
