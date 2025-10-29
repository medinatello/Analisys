# 📋 CHANGELOG - EduGo

## [1.0.0] - 2025-10-29 - Refactorización Completa

### ✨ Nuevas Funcionalidades

**Modelos Completos**:
- Resúmenes con glosario, preguntas reflexivas y metadata de procesamiento
- Quizzes con difficulty, points, order y feedback personalizado
- Respuestas de intentos con feedback detallado por pregunta

**Endpoints Post-MVP** (documentados, no implementados):
- `POST /v1/guardian-relations` - Crear vínculo tutor-estudiante
- `PATCH /v1/subjects/:id` - Actualizar materia

**Infraestructura**:
- Docker Compose completo (PostgreSQL, MongoDB, RabbitMQ)
- Dockerfiles multi-stage para 3 servicios
- Makefile con 15+ comandos útiles

### 🔄 Cambios Importantes (BREAKING CHANGES)

**Estructura de Proyecto**:
- Eliminada estructura nested `AnalisisFinal/`
- Nueva estructura plana: `source/api-mobile/`, `source/api-administracion/`, etc.
- Documentación movida a raíz: `docs/`

**API Responses**:
- `GET /materials/{id}/summary`:
  - **Antes**: `{ "summary": "string" }`
  - **Después**: `{ "sections": [], "glossary": [], "reflection_questions": [], "processing_metadata": {} }`

- `GET /materials/{id}/assessment`:
  - **Antes**: `{ "questions": [] }` (estructura simple)
  - **Después**: Incluye `title`, `description`, `total_points`, `passing_score`, `time_limit_minutes`
  - Questions ahora con `QuestionOption[]` en lugar de `string[]`

- `POST /materials/{id}/assessment/attempts`:
  - **Antes**: `{ "feedback": ["string1", "string2"] }`
  - **Después**: `{ "detailed_feedback": [{ "question_id", "is_correct", "your_answer", "feedback_message" }] }`

### 🔧 Mejoras Técnicas

- Modelos Go con tipos completos (5 nuevos structs)
- Handlers con mocks mejorados y estructuras type-safe
- Swagger auto-generado con modelos completos
- Tests unitarios básicos (3 tests passing)
- Scripts MongoDB con validación completa (341 líneas)

### 📚 Documentación

- `README.md` principal
- `CHANGELOG.md` (este archivo)
- `MIGRATION_GUIDE.md` - Guía de migración de BD
- `DOCKER.md` - Guía de Docker
- `DEVELOPMENT.md` - Guía de desarrollo
- `ESTADO_INICIAL.md` - Snapshot pre-refactorización

### 🐛 Fixes

- Estructura de carpetas corregida (eliminado 5 niveles de nesting)
- Scripts MongoDB completos (341 vs 68 líneas incompletas)
- Endpoints Post-MVP correctamente marcados en documentación

---

## Commits de la Refactorización

1. `837ce94` - FASE 0: Docker infrastructure
2. `d8c1465` - FASE 1: Initial audit
3. `19cbc5b` - FASE 2: Flatten folder structure
4. `78fbc41` - FASE 3: Mark Post-MVP endpoints
5. `ce95c5f` - FASE 4: Database migration guide
6. `2f28432` - FASE 5: Complete Go models
7. `b3af85b` - FASE 6: Improved handlers
8. `5d20fb8` - FASE 7: Regenerate Swagger
9. `7875f99` - FASE 8: Unit tests

---

**Total**: 9 commits, ~3,000 líneas agregadas, 14 fases de refactorización
