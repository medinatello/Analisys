# spec-01-evaluaciones - Sistema de Evaluaciones

**Estado:** ✅ DOCUMENTACIÓN COMPLETADA (100%)  
**Repositorio:** edugo-api-mobile  
**Prioridad:** 🔴 P0 - CRITICAL  
**Versión:** 1.0.0  
**Fecha:** 14 de Noviembre, 2025

---

## ⚠️ IMPORTANTE: ESTADO ACTUAL

Esta especificación es **DOCUMENTACIÓN DE DISEÑO** para la implementación futura del módulo de evaluaciones en edugo-api-mobile.

**Estado de Implementación:** ⬜ PENDIENTE (0%)

La documentación está completa y lista para iniciar implementación cuando se priorice este proyecto.

---

## 📋 Descripción

Sistema de cuestionarios automáticos generados por IA para medir comprensión de materiales educativos. Estudiantes realizan evaluaciones y obtienen feedback inmediato con resultados persistidos.

### Funcionalidades Clave
- ✅ Obtener cuestionario de 5 preguntas por material
- ✅ Enviar respuestas y obtener calificación automática
- ✅ Ver historial de intentos con puntajes
- ✅ Feedback inmediato pregunta por pregunta
- ✅ Límite configurable de intentos (Post-MVP)

---

## 🏗️ Arquitectura

### Stack Tecnológico
- **Backend:** Go 1.21+ con Gin Framework
- **Arquitectura:** Clean Architecture (Hexagonal)
- **Bases de Datos:** 
  - PostgreSQL 15+ (intentos, respuestas)
  - MongoDB 7.0+ (preguntas, feedback)
- **Testing:** shared/testing v0.6.2+ con testcontainers

### Dependencias Actuales

**Shared v0.7.0 (FROZEN):**
```go
require (
    github.com/EduGoGroup/edugo-shared/auth v0.7.0
    github.com/EduGoGroup/edugo-shared/common v0.7.0
    github.com/EduGoGroup/edugo-shared/config v0.7.0
    github.com/EduGoGroup/edugo-shared/database/postgres v0.7.0
    github.com/EduGoGroup/edugo-shared/database/mongodb v0.7.0
    github.com/EduGoGroup/edugo-shared/logger v0.7.0
    github.com/EduGoGroup/edugo-shared/middleware/gin v0.7.0
    github.com/EduGoGroup/edugo-shared/evaluation v0.7.0
    github.com/EduGoGroup/edugo-shared/testing v0.7.0
)
```

**Infrastructure v0.1.1:**
```go
require (
    github.com/EduGoGroup/edugo-infrastructure/database v0.1.1
    github.com/EduGoGroup/edugo-infrastructure/schemas v0.1.1
)
```

**Nota:** shared v0.7.0 está CONGELADO hasta post-MVP. Solo se permiten bug fixes críticos (v0.7.1, v0.7.2).

---

## 🗂️ Estructura del Proyecto

### Modelo de Datos

**PostgreSQL (4 tablas nuevas):**
- `assessment` - Metadatos de evaluaciones
- `assessment_attempt` - Intentos de estudiantes
- `assessment_attempt_answer` - Respuestas individuales
- `material_summary_link` - Enlace opcional a MongoDB

**MongoDB (colección existente):**
- `material_assessment` - Preguntas, opciones, respuestas correctas

### Capas Clean Architecture

```
internal/
├── domain/               # Entidades, Value Objects, Interfaces
│   ├── entities/
│   │   ├── assessment.go
│   │   ├── attempt.go
│   │   └── answer.go
│   ├── value_objects/
│   │   └── score.go
│   └── repositories/
│       ├── assessment_repository.go
│       ├── attempt_repository.go
│       └── question_repository.go
│
├── application/          # Services, DTOs
│   ├── services/
│   │   ├── assessment_service.go
│   │   └── scoring_service.go
│   └── dto/
│       ├── assessment_dto.go
│       └── attempt_dto.go
│
└── infrastructure/       # Implementaciones
    ├── persistence/
    │   ├── postgres/
    │   └── mongodb/
    └── http/
        ├── handlers/
        ├── middleware/
        └── routes/
```

---

## 🚀 Endpoints API REST

### 1. Obtener Cuestionario
```http
GET /v1/materials/:materialId/assessment
Authorization: Bearer {jwt}
```

**Response:** Cuestionario con 5 preguntas (SIN respuestas correctas)

### 2. Crear Intento
```http
POST /v1/materials/:materialId/assessment/attempts
Authorization: Bearer {jwt}
Content-Type: application/json

{
  "answers": [
    {"question_id": "q1", "selected_option": "a"},
    {"question_id": "q2", "selected_option": "c"}
  ],
  "time_spent_seconds": 180
}
```

**Response:** Resultados con puntaje, feedback pregunta por pregunta

### 3. Historial de Intentos
```http
GET /v1/users/me/attempts?limit=10&offset=0
Authorization: Bearer {jwt}
```

**Response:** Lista de intentos pasados con puntajes

---

## 📚 Documentación Completa

### 01-Requirements (4 archivos)
- **[PRD.md](01-Requirements/PRD.md)** - Product Requirements Document
- **[FUNCTIONAL_SPECS.md](01-Requirements/FUNCTIONAL_SPECS.md)** - Especificación funcional
- **[TECHNICAL_SPECS.md](01-Requirements/TECHNICAL_SPECS.md)** - Stack tecnológico
- **[ACCEPTANCE_CRITERIA.md](01-Requirements/ACCEPTANCE_CRITERIA.md)** - Criterios de aceptación

### 02-Design (4 archivos)
- **[ARCHITECTURE.md](02-Design/ARCHITECTURE.md)** - Arquitectura Clean Architecture
- **[DATA_MODEL.md](02-Design/DATA_MODEL.md)** - Schema PostgreSQL + MongoDB
- **[API_CONTRACTS.md](02-Design/API_CONTRACTS.md)** - Contratos de API REST
- **[SECURITY_DESIGN.md](02-Design/SECURITY_DESIGN.md)** - Autenticación, autorización

### 03-Sprints (6 sprints × 5 archivos = 30 archivos)
Cada sprint contiene:
- README.md - Resumen del sprint
- TASKS.md - Tareas detalladas con código exacto
- DEPENDENCIES.md - Dependencias técnicas
- QUESTIONS.md - Decisiones de diseño
- VALIDATION.md - Checklist de validación

**Sprints:**
1. **Sprint-01-Schema-BD** - Migraciones PostgreSQL
2. **Sprint-02-Dominio** - Entities, Value Objects
3. **Sprint-03-Repositorios** - Implementaciones de repositorios
4. **Sprint-04-Services-API** - Services, Handlers, Routes
5. **Sprint-05-Testing** - Suite de tests (unit + integration)
6. **Sprint-06-CI-CD** - GitHub Actions workflows

### 04-Testing (3 archivos)
- **[TEST_STRATEGY.md](04-Testing/TEST_STRATEGY.md)** - Estrategia de testing
- **[TEST_CASES.md](04-Testing/TEST_CASES.md)** - Casos de prueba
- **[COVERAGE_REPORT.md](04-Testing/COVERAGE_REPORT.md)** - Reporte de coverage

### 05-Deployment (3 archivos)
- **[DEPLOYMENT_GUIDE.md](05-Deployment/DEPLOYMENT_GUIDE.md)** - Guía de despliegue
- **[INFRASTRUCTURE.md](05-Deployment/INFRASTRUCTURE.md)** - Infraestructura
- **[MONITORING.md](05-Deployment/MONITORING.md)** - Observabilidad

---

## 🔗 Integración con Infrastructure

Este módulo utiliza **edugo-infrastructure v0.1.1** para:

### Migraciones de Base de Datos
```bash
# Usar migraciones desde infrastructure
cd edugo-infrastructure
go run database/migrate.go up
```

**Migraciones relevantes:**
- `008_assessment_tables.up.sql` - Tablas de evaluaciones
- `008_assessment_tables.down.sql` - Rollback

### Validación de Eventos
```go
import "github.com/EduGoGroup/edugo-infrastructure/schemas"

// Validar evento antes de publicar
err := schemas.ValidateEvent("assessment.completed", eventData)
```

**Schemas disponibles en infrastructure/schemas:**
- `assessment.completed.json` - Evento de evaluación completada
- `assessment.generated.json` - Evento de evaluación generada

---

## 📊 Métricas del Proyecto

### Documentación
- **Archivos totales:** 46
- **Completitud:** 100%
- **Palabras:** ~85,000
- **Sprints:** 6

### Estado de Implementación
- **Código:** 0% (pendiente)
- **Tests:** 0% (pendiente)
- **CI/CD:** 0% (pendiente)

---

## 🎯 Próximos Pasos (Cuando se Priorice)

1. **Preparación:**
   - Actualizar go.mod con dependencias shared v0.7.0
   - Integrar infrastructure v0.1.1
   - Configurar entorno local

2. **Sprint 1:** Schema BD (3 días)
   - Ejecutar migraciones PostgreSQL
   - Verificar constraints y índices

3. **Sprint 2:** Dominio (4 días)
   - Implementar entities y value objects
   - Definir interfaces de repositorios

4. **Sprint 3-6:** Continuar según plan de sprints

---

## 🔄 Sistema de Tracking

### Archivo de Progreso
**[PROGRESS.json](PROGRESS.json)** - Estado actual de ejecución

```bash
# Ver progreso
jq '{files_completed, current_phase, completion_percentage}' PROGRESS.json
```

### Sistema de Tracking
**[TRACKING_SYSTEM.md](TRACKING_SYSTEM.md)** - Guía de continuación

**Para continuar desde interrupciones:**
1. Leer PROGRESS.json
2. Identificar current_phase
3. Continuar desde último archivo completado

---

## 📝 Uso de Módulo shared/evaluation

Este proyecto utilizará el módulo **shared/evaluation v0.7.0** para modelos compartidos:

```go
import "github.com/EduGoGroup/edugo-shared/evaluation"

// Usar tipos compartidos
assessment := evaluation.Assessment{
    ID:            uuid.New(),
    MaterialID:    materialID,
    TotalQuestions: 5,
    PassThreshold:  70,
}

attempt := evaluation.Attempt{
    AssessmentID: assessment.ID,
    StudentID:    userID,
    Score:        85,
}
```

**Ventajas:**
- Consistencia entre api-mobile y worker
- Validaciones reutilizables
- Tipos bien definidos

---

## ⚠️ Consideraciones Importantes

### Seguridad
- **NUNCA** enviar respuestas correctas al cliente antes de que envíe sus respuestas
- Validación de respuestas SOLO en servidor
- Autenticación JWT obligatoria en todos los endpoints

### Performance
- Índices en PostgreSQL para queries frecuentes
- Transacciones ACID para intento + respuestas
- Tiempo de respuesta objetivo: <1.5s (p95)

### Testing
- Coverage mínimo: 80%
- Tests unitarios para toda la lógica de negocio
- Tests de integración con testcontainers

---

## 📞 Recursos

- **Repositorio:** https://github.com/EduGoGroup/edugo-api-mobile
- **Shared:** https://github.com/EduGoGroup/edugo-shared (v0.7.0 FROZEN)
- **Infrastructure:** https://github.com/EduGoGroup/edugo-infrastructure (v0.1.1)
- **Documentación Plan:** /Analisys/docs/roadmap/PLAN_IMPLEMENTACION.md

---

**Generado con:** Claude Code  
**Última actualización:** 16 de Noviembre, 2025  
**Estado:** Documentación completa, implementación pendiente
