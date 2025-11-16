# 🏗️ Spec-06: Infrastructure - Migraciones y Contratos

**Proyecto:** edugo-infrastructure  
**Versión:** v0.1.1 → v0.2.0  
**Prioridad:** P0 (Crítica - Cross-Proyecto)  
**Estado:** 96% Completado

---

## 🎯 Objetivo

Centralizar infraestructura compartida del ecosistema EduGo:
- Migraciones de base de datos PostgreSQL
- Contratos de eventos RabbitMQ (JSON Schemas)
- Docker Compose para desarrollo local
- Scripts de automatización

---

## 📦 Repositorio

**GitHub:** https://github.com/EduGoGroup/edugo-infrastructure  
**Local:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/`

---

## 📊 Estado Actual

### Módulos Implementados

| Módulo | Versión | Estado | Archivos |
|--------|---------|--------|----------|
| database/ | v0.1.1 | ✅ 95% | 17 archivos |
| docker/ | v0.1.1 | ✅ 100% | 3 archivos |
| schemas/ | v0.1.1 | ✅ 95% | 6 archivos |
| scripts/ | v0.1.1 | ✅ 100% | 3 archivos |
| seeds/ | v0.1.1 | ✅ 100% | 7 archivos |

**Total:** ~45 archivos creados

### Problemas Resueltos

Este proyecto resolvió **4 problemas críticos** cross-proyecto:

1. ✅ **Ownership de tablas compartidas** (P0-2)
   - Solución: database/TABLE_OWNERSHIP.md
   
2. ✅ **Contratos de eventos RabbitMQ** (P0-3)
   - Solución: EVENT_CONTRACTS.md + schemas/

3. ✅ **docker-compose.yml no existía** (P0-4)
   - Solución: docker/docker-compose.yml

4. ✅ **Sincronización PostgreSQL ↔ MongoDB** (P1-1)
   - Solución: Eventual Consistency pattern documentado

---

## 📋 Contenido

### 1. database/ - Migraciones PostgreSQL

**Archivos:**
- 8 migraciones SQL (UP + DOWN)
  - 001_create_users
  - 002_create_schools
  - 003_create_academic_units
  - 004_create_memberships
  - 005_create_materials
  - 006_create_assessments
  - 007_create_assessment_attempts
  - 008_create_assessment_answers

- TABLE_OWNERSHIP.md
- go.mod
- README.md
- migrate.go (⏳ pendiente)

**Ownership:**
- api-admin: users, schools, academic_units, memberships
- api-mobile: materials, assessment, assessment_attempt, assessment_answer

**Orden:** 001 → 008 (secuencial obligatorio)

---

### 2. docker/ - Docker Compose

**Archivos:**
- docker-compose.yml
- README.md
- .env.example

**Servicios:**
- PostgreSQL 15
- MongoDB 7.0
- RabbitMQ 3.12 (perfil: messaging)
- Redis 7 (perfil: cache)
- PgAdmin (perfil: tools)
- Mongo Express (perfil: tools)

**Profiles:**
- `core`: PostgreSQL + MongoDB
- `messaging`: + RabbitMQ
- `cache`: + Redis
- `tools`: + PgAdmin + Mongo Express

**Uso:**
```bash
make dev-up-core           # Solo BDs
make dev-up-messaging      # BDs + RabbitMQ
make dev-up-tools          # Todo + herramientas
```

---

### 3. schemas/ - JSON Schemas de Eventos

**Archivos:**
- events/material-uploaded-v1.schema.json
- events/assessment-generated-v1.schema.json
- events/material-deleted-v1.schema.json
- events/student-enrolled-v1.schema.json
- go.mod
- README.md
- validator.go (⏳ pendiente)

**Eventos:**
1. material.uploaded (api-mobile → worker)
2. assessment.generated (worker → api-mobile)
3. material.deleted (api-mobile → worker)
4. student.enrolled (api-admin → api-mobile)

**Versionamiento:** event_version "1.0" en JSON

---

### 4. scripts/ - Automatización

**Archivos:**
- dev-setup.sh (setup completo)
- seed-data.sh (carga de datos)
- validate-env.sh (validación de variables)

**Uso:**
```bash
./scripts/dev-setup.sh      # Setup en 5 minutos
./scripts/seed-data.sh      # Cargar datos de prueba
./scripts/validate-env.sh   # Validar .env
```

---

### 5. seeds/ - Datos de Prueba

**PostgreSQL:**
- users.sql (3 usuarios)
- schools.sql (2 escuelas)
- materials.sql (3 materiales)

**MongoDB:**
- assessments.js (2 quizzes)
- summaries.js (2 resúmenes)

---

## 🎯 Tareas Pendientes (4%)

### 1. database/migrate.go (1-2h)

**Objetivo:** CLI para ejecutar migraciones

**Comandos:**
```bash
go run migrate.go up          # Ejecutar migraciones
go run migrate.go down        # Revertir última migración
go run migrate.go status      # Ver estado
go run migrate.go create name # Crear nueva migración
```

**Ver:** `03-Tasks/MIGRATE_CLI.md`

---

### 2. schemas/validator.go (2-3h)

**Objetivo:** Validador Go automático

**API:**
```go
validator := schemas.NewValidator()
err := validator.Validate(event, "material-uploaded-v1")
```

**Ver:** `03-Tasks/VALIDATOR.md`

---

### 3. Release v0.2.0 (30min)

**Pasos:**
1. Completar migrate.go
2. Completar validator.go
3. Crear tags de módulos
4. Publicar GitHub Release

---

## 📚 Documentos de Este Spec

```
spec-06-infrastructure/
├── README.md                    # Este archivo
├── 01-Requirements/
│   └── REQUIREMENTS.md          # Requisitos del proyecto
├── 02-Design/
│   ├── ARCHITECTURE.md          # Diseño técnico
│   └── MODULES.md               # Diseño de módulos
├── 03-Tasks/
│   ├── MIGRATE_CLI.md           # Tarea: migrate.go
│   └── VALIDATOR.md             # Tarea: validator.go
└── 04-Integration/
    └── INTEGRATION_GUIDE.md     # Guía de integración
```

---

## 🚀 Uso por Proyectos

### api-administracion

**Consume:**
- ✅ database/migrations (owner)
- ✅ docker/docker-compose.yml
- ✅ scripts/

**go.mod:**
```go
require (
    github.com/EduGoGroup/edugo-infrastructure/database v0.1.1
)
```

---

### api-mobile

**Consume:**
- ✅ database/migrations (consumer)
- ✅ docker/docker-compose.yml
- ✅ schemas/ (validación de eventos)
- ✅ scripts/

**go.mod:**
```go
require (
    github.com/EduGoGroup/edugo-infrastructure/database v0.1.1
    github.com/EduGoGroup/edugo-infrastructure/schemas v0.1.1
)
```

---

### worker

**Consume:**
- ✅ docker/docker-compose.yml
- ✅ schemas/ (validación de eventos)
- ✅ scripts/

**go.mod:**
```go
require (
    github.com/EduGoGroup/edugo-infrastructure/schemas v0.1.1
)
```

---

## 📈 Impacto

### Métricas

- **Setup de desarrollo:** 5 minutos (automatizado)
- **Proyectos desbloqueados:** 5/5 (100%)
- **Completitud del ecosistema:** +8%
- **Problemas críticos resueltos:** 4

### Beneficios

1. **Ownership claro** de tablas
2. **Contratos validados** de eventos
3. **Setup automatizado** de desarrollo
4. **Sincronización documentada** PostgreSQL ↔ MongoDB

---

## 🔗 Referencias

**Documentación en repo:**
- TABLE_OWNERSHIP.md
- EVENT_CONTRACTS.md
- INTEGRATION_GUIDE.md
- Makefile (20+ comandos)

**Documentación en AnalisisEstandarizado:**
- 00-Overview/PROJECTS_MATRIX.md
- 02-Design/DATA_MODEL.md
- 02-Design/API_CONTRACTS.md

---

**Generado:** 16 de Noviembre, 2025  
**Por:** Claude Code  
**Versión:** 1.0.0
