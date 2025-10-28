# Persistencia Física: PostgreSQL, MongoDB y S3

[Volver a Componentes](../README.md) · [Volver a Detalle de Persistencia Híbrida](../../README.md)

## PostgreSQL

### Tablas Prioritarias (MVP)

| Tabla | Propósito | Campos principales | Índices sugeridos |
|-------|-----------|--------------------|-------------------|
| `app_user` | Usuarios y credenciales | `id`, `email`, `credential_hash`, `system_role`, `status`, `created_at` | `UNIQUE (email)`, `INDEX (system_role)` |
| `teacher_profile` | Datos de docente | `user_id`, `specialty`, `preferences` (`jsonb`) | `PK (user_id)` |
| `student_profile` | Datos de estudiante | `user_id`, `primary_unit_id`, `current_grade`, `student_code` | `INDEX (primary_unit_id)` |
| `guardian_profile` | Datos de tutor | `user_id`, `occupation`, `alternate_contact` | `PK (user_id)` |
| `guardian_student_relation` | Tutor ↔ estudiante | `id`, `guardian_id`, `student_id`, `relationship_type`, `status` | `UNIQUE (guardian_id, student_id, relationship_type)` |
| `school` | Organización | `id`, `name`, `external_code`, `location`, `metadata` | `UNIQUE (external_code)` |
| `academic_unit` | Jerarquía colegio → año → sesión | `id`, `school_id`, `parent_unit_id`, `unit_type`, `name`, `code`, `metadata`, `validity_period` (`tstzrange`) | `INDEX (school_id)`, `INDEX (parent_unit_id)`, `INDEX (unit_type)` |
| `unit_membership` | Usuarios por unidad | `id`, `unit_id`, `user_id`, `unit_role`, `status`, `assigned_at`, `removed_at` | `UNIQUE (unit_id, user_id, unit_role, assigned_at)` |
| `subject` | Catálogo de materias | `id`, `school_id`, `name`, `description` | `UNIQUE (school_id, name)` |
| `learning_material` | Metadatos de material | `id`, `author_id`, `subject_id`, `title`, `description`, `s3_url`, `extra_metadata`, `published_at`, `status` | `INDEX (subject_id)`, `GIN (extra_metadata)` |
| `material_unit_link` | Distribución de materiales | `id`, `material_id`, `unit_id`, `scope`, `visibility` | `UNIQUE (material_id, unit_id)` |
| `material_version` | Versiones de archivo | `id`, `material_id`, `s3_version_url`, `file_hash`, `generated_at` | `INDEX (material_id, generated_at DESC)` |
| `reading_log` | Seguimiento de lectura | `id`, `material_id`, `user_id`, `progress`, `last_access_at` | `INDEX (user_id, material_id)` |
| `assessment` | Metadatos de evaluaciones | `id`, `material_id`, `mongo_document_id`, `config` (`jsonb`), `created_at` | `UNIQUE (material_id)` |
| `assessment_attempt` | Intentos | `id`, `assessment_id`, `user_id`, `score`, `completed_at` | `INDEX (user_id, assessment_id)` |
| `assessment_attempt_answer` | Respuestas | `id`, `attempt_id`, `question_mongo_id`, `answer_payload` (`jsonb`), `is_correct` | `INDEX (attempt_id)` |
| `material_summary_link` | Resumen en Mongo | `material_id`, `mongo_document_id`, `updated_at`, `status` | `PK (material_id)` |

### Tablas Post-MVP

- `unit_social_link`: relaciones entre unidades (intercambios, sesiones hermanas).
- `social_activity_sql`: eventos ligeros (likes, badges) con fan-out a MongoDB o Redis Streams.
- Tablas de auditoría (`*_audit`) usando `logical replication`.

### Buenas Prácticas

- Claves UUIDv7 para orden cronológico y compatibilidad multi-región.
- `CHECK (unit_type IN (...))` y triggers que previenen jerarquías incorrectas.
- Columnas generadas (`path`) con extensión `ltree` para acelerar consultas jerárquicas.

## MongoDB

### Colecciones

1. **`material_summary`**  
   ```json
   {
     "_id": "uuid",
     "material_id": "uuid",
     "version": 3,
     "sections": [
       {"title": "Introduction", "content": "...", "level": "basic"}
     ],
     "glossary": [{"term": "AI", "definition": "Artificial Intelligence"}],
     "status": "complete",
     "updated_at": "2024-02-01T10:00:00Z"
   }
   ```
   Índices: `{ material_id: 1 }`, `{ status: 1 }`.

2. **`material_assessment`**  
   ```json
   {
     "_id": "uuid",
     "material_id": "uuid",
     "title": "Quick check",
     "questions": [
       {
         "id": "uuid",
         "text": "...",
         "type": "multiple_choice",
         "options": ["A", "B", "C"],
         "answer": "A",
         "feedback": "..."
       }
     ],
     "version": 1
   }
   ```
   Índices: `{ material_id: 1 }`, `{ "questions.id": 1 }`.

3. **`material_event`**  
   Logs y métricas de procesamiento (errores, tiempos). Índices: `{ material_id: 1, created_at: -1 }`.

4. **`unit_social_feed`** *(Post-MVP)*  
   Publicaciones/comentarios asociados a `unit_id`. Índices: `{ unit_id: 1, created_at: -1 }`, `{ author_id: 1 }`.

5. **`user_graph_relation`** *(Post-MVP)*  
   Relaciones sociales (seguir, recomendar). Índices: `{ user_id: 1, relation_type: 1 }`.

### Lineamientos

- Documentos ≤16 MB; fragmentar cuestionarios extensos.
- Validación de esquema con `$jsonSchema` para proteger contratos.
- Versionado interno (`version`) para mantener compatibilidad hacia atrás.
- TTL opcional para contenidos efímeros en feeds sociales.

## S3 / MinIO

- **Buckets:** `edugo-materials-{env}` segregados por entorno.
- **Estructura:** `s3://edugo-materials/{school_id}/{unit_id}/{material_id}/...` (ver diagrama ER).
- **Metadatos:** headers `x-amz-meta-unit`, `x-amz-meta-subject`, `x-amz-meta-author` para filtros rápidos.
- **Retención:** políticas de ciclo de vida para archivar versiones antiguas (Glacier) o eliminarlas tras 90 días.
- **Seguridad:** URLs presignadas de corta duración; políticas IAM con privilegios mínimos para workers (`getObject`/`putObject` sobre prefijos limitados).

## Sincronización

- Eventos `material_uploaded`/`material_reprocess` mantienen alineados PostgreSQL, MongoDB y S3.
- Cambios en `academic_unit` pueden disparar snapshots para `unit_social_feed`.
- Pipelines ETL (`airflow`, `prefect`) validan divergencias entre `guardian_student_relation` y `user_graph_relation`.
