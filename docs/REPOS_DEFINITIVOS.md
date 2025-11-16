# 📦 Repositorios Definitivos - EduGo

**Organización GitHub:** https://github.com/EduGoGroup  
**Total de repositorios:** 6

---

## 🗂️ Repositorios del Ecosistema

### 1. edugo-shared

**Propósito:** Biblioteca compartida Go con arquitectura modular  
**URL:** https://github.com/EduGoGroup/edugo-shared  
**Versión actual:** v0.7.0 (FROZEN hasta post-MVP)  
**Tecnología:** Go 1.24.10

**Módulos (12):**
- auth, logger, common, config, bootstrap, lifecycle
- middleware/gin, messaging/rabbit
- database/postgres, database/mongodb
- testing, evaluation

**Estado:** ✅ Completado y congelado

---

### 2. edugo-infrastructure ⭐ NUEVO

**Propósito:** Infraestructura compartida (migraciones, docker, schemas)  
**URL:** https://github.com/EduGoGroup/edugo-infrastructure  
**Versión actual:** v0.1.0 (en desarrollo)  
**Tecnología:** Go 1.24 + Docker Compose + JSON Schema

**Módulos (3):**
- database (migraciones PostgreSQL, CLI)
- docker (docker-compose con profiles)
- schemas (JSON Schemas + validador)

**Contenido:**
- 8 migraciones SQL (users, schools, materials, assessment, etc.)
- Docker Compose con 4 perfiles (core, messaging, cache, tools)
- 4 JSON Schemas de eventos RabbitMQ
- Scripts automatizados (setup, seeds, validación)
- Seeds de datos de prueba

**Estado:** ✅ Funcional (~90% completado)

---

### 3. edugo-api-mobile

**Propósito:** API REST para aplicación móvil de estudiantes  
**URL:** https://github.com/EduGoGroup/edugo-api-mobile  
**Puerto:** 8080  
**Tecnología:** Go + Gin + GORM + Swagger

**Endpoints principales:**
- Autenticación (login, refresh)
- Materiales educativos
- Assessments/Quizzes
- Progreso del estudiante

**Dependencias:**
- edugo-shared v0.7.0
- edugo-infrastructure v0.1.0 (database, schemas)

**Estado:** ⬜ Pendiente (desbloqueado para desarrollo)

---

### 4. edugo-api-administracion

**Propósito:** API REST administrativa (gestión de escuelas, usuarios)  
**URL:** https://github.com/EduGoGroup/edugo-api-administracion  
**Puerto:** 8081  
**Tecnología:** Go + Gin + GORM + Swagger

**Endpoints principales:**
- Gestión de usuarios
- Gestión de escuelas
- Configuración de cursos/clases
- Reportes administrativos

**Dependencias:**
- edugo-shared v0.7.0
- edugo-infrastructure v0.1.0 (database)

**Estado:** 🔄 En progreso (jerarquía completada)

---

### 5. edugo-worker

**Propósito:** Worker de procesamiento asíncrono (generación de contenido con IA)  
**URL:** https://github.com/EduGoGroup/edugo-worker  
**Tecnología:** Go + RabbitMQ + OpenAI API

**Funcionalidades:**
- Consumir eventos de RabbitMQ
- Generar resúmenes educativos con IA
- Generar quizzes automáticos
- Guardar resultados en MongoDB

**Dependencias:**
- edugo-shared v0.7.0 (logger, messaging, evaluation)
- edugo-infrastructure v0.1.0 (schemas)

**Estado:** ⬜ Pendiente (desbloqueado para desarrollo)

---

### 6. edugo-dev-environment

**Propósito:** Entorno Docker completo para desarrollo local  
**URL:** https://github.com/EduGoGroup/edugo-dev-environment  
**Tecnología:** Docker Compose + Shell Scripts

**Contenido:**
- Docker Compose de infraestructura (ahora movido a edugo-infrastructure)
- Documentación de setup
- Scripts de utilidades

**Estado:** ✅ Funcionalidad movida a edugo-infrastructure

---

## 🔗 Dependencias entre Repositorios

```
edugo-infrastructure (base)
    ├── Migraciones SQL
    ├── Docker Compose
    └── JSON Schemas
         │
         ├──> edugo-shared v0.7.0 (biblioteca)
         │      └──> 12 módulos Go reutilizables
         │
         ├──> edugo-api-admin
         │      └──> Usa: infrastructure/database, shared/*
         │
         ├──> edugo-api-mobile
         │      └──> Usa: infrastructure/database+schemas, shared/*
         │
         └──> edugo-worker
                └──> Usa: infrastructure/schemas, shared/*
```

---

## 📊 Estado por Repositorio

| Repo | Versión | Estado | Última actualización |
|------|---------|--------|---------------------|
| **edugo-shared** | v0.7.0 | 🔒 FROZEN | 15 Nov 2025 |
| **edugo-infrastructure** | v0.1.0-dev | ✅ Funcional | 15 Nov 2025 |
| **edugo-api-admin** | - | 🔄 En desarrollo | 14 Nov 2025 |
| **edugo-api-mobile** | - | ⬜ Pendiente | - |
| **edugo-worker** | - | ⬜ Pendiente | - |
| **edugo-dev-environment** | - | ✅ Funcionalidad en infrastructure | - |

---

## 🚀 Próximos Pasos

### Inmediato
1. Publicar **edugo-infrastructure v0.1.0** (tags y release)
2. Actualizar **go.mod** en api-admin, api-mobile, worker

### Corto Plazo
3. Desarrollar **api-mobile** (evaluaciones)
4. Desarrollar **worker** (procesamiento IA)

---

**Última actualización:** 15 de Noviembre, 2025  
**Mantenedor:** Equipo EduGo
