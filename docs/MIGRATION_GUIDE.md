# 📖 GUÍA DE MIGRACIÓN DE BASE DE DATOS - EduGo

**Versión**: 1.0.0
**Fecha**: 2025-10-29

---

## 📊 RESUMEN DE SCHEMAS

### PostgreSQL
- **Líneas totales**: 866 líneas
- **Tablas**: 17 tablas
- **Scripts**: 01_schema.sql, 02_indexes.sql, 03_mock_data.sql

### MongoDB
- **Líneas totales**: 745 líneas
- **Colecciones**: 3 colecciones con validación $jsonSchema completa
- **Scripts**: 01_collections.js (341 líneas), 02_indexes.js, 03_mock_data.js

---

## 🗄️ POSTGRESQL - Tablas Principales

**Jerarquía Organizacional**:
- `school` - Escuelas
- `unit` - Unidades (secciones, grados)
- `unit_member` - Membresías

**Usuarios**:
- `user` - Todos los usuarios del sistema
- `guardian_student_relation` - Vínculos tutor-estudiante

**Contenido**:
- `subject` - Materias del catálogo
- `grade_level` - Niveles de grado
- `material` - Materiales educativos

**Seguimiento**:
- `student_material_progress` - Progreso de lectura
- `material_consumption_event` - Eventos de consumo
- `quiz_attempt` - Intentos de quiz
- `quiz_attempt_answer` - Respuestas

**Sistema**:
- `notification` - Notificaciones
- `s3_upload_tracking` - Tracking de uploads

---

## 📝 MONGODB - Colecciones

### 1. material_summary
Resúmenes generados por NLP.

**Campos principales**:
- `material_id` - Referencia a PostgreSQL
- `sections[]` - Secciones con difficulty y estimated_time_minutes
- `glossary[]` - Términos técnicos
- `reflection_questions[]` - Preguntas pedagógicas
- `processing_metadata` - Metadata de NLP (provider, model, tokens, etc.)

### 2. material_assessment
Quizzes/evaluaciones generadas.

**Campos principales**:
- `material_id`
- `questions[]` - Con difficulty, points, order, feedback
- `total_questions`, `total_points`, `passing_score`
- `time_limit_minutes`
- `processing_metadata`

### 3. material_event
Eventos de consumo de materiales.

---

## 🚀 PASOS DE MIGRACIÓN

### Con Docker Compose (Recomendado)
```bash
make up
```
Los scripts se ejecutan automáticamente.

### Manual
```bash
# PostgreSQL
psql -h localhost -U edugo_user -d edugo < source/scripts/postgresql/01_schema.sql
psql -h localhost -U edugo_user -d edugo < source/scripts/postgresql/02_indexes.sql
psql -h localhost -U edugo_user -d edugo < source/scripts/postgresql/03_mock_data.sql

# MongoDB
mongosh mongodb://edugo_admin:edugo_pass@localhost:27017/edugo < source/scripts/mongodb/01_collections.js
mongosh mongodb://edugo_admin:edugo_pass@localhost:27017/edugo < source/scripts/mongodb/02_indexes.js
mongosh mongodb://edugo_admin:edugo_pass@localhost:27017/edugo < source/scripts/mongodb/03_mock_data.js
```

---

## ⚠️ BREAKING CHANGES

Ver detalles completos de cambios en modelos Go y endpoints en las siguientes fases.

---

**Documento generado**: Fase 4 - Refactorización EduGo
