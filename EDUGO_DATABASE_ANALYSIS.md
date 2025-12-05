# ANÁLISIS COMPLETO DE ESTRUCTURA DE BASE DE DATOS - ECOSISTEMA EDUGO

**Fecha:** 1 de Diciembre, 2025
**Proyecto:** EduGo - Plataforma Educativa
**Repositorio:** edugo-infrastructure
**Propósito:** Documento de referencia para diseño de UI en app móvil/desktop

---

## TABLA DE CONTENIDOS

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [PostgreSQL - Tablas Relacionales](#postgresql---tablas-relacionales)
3. [MongoDB - Colecciones NoSQL](#mongodb---colecciones-nosql)
4. [Roles y Perfiles de Usuario](#roles-y-perfiles-de-usuario)
5. [Relaciones Entre Entidades](#relaciones-entre-entidades)
6. [Diagrama de Entidades](#diagrama-de-entidades)
7. [Consideraciones para UI](#consideraciones-para-ui)
8. [Flujo de Datos](#flujo-de-datos)

---

## RESUMEN EJECUTIVO

### Stack Tecnológico
- **PostgreSQL 15:** Base de datos relacional (17 tablas, 11 migraciones)
- **MongoDB 7.0:** Base de datos documental (9 colecciones)
- **RabbitMQ 3.12:** Mensajería asíncrona (4 eventos principales)

### Números Clave
- **16 Tablas PostgreSQL** con soporte de jerarquía
- **9 Colecciones MongoDB** para contenido, evaluaciones y auditoría
- **4 Roles principales:** admin, teacher, student, guardian
- **6 Roles extendidos en memberships:** teacher, student, guardian, coordinator, admin, assistant
- **4 Eventos RabbitMQ** para comunicación asíncrona

### Principales Características
- Jerarquía flexible de unidades académicas (Facultad → Departamento → Clase)
- Evaluaciones generadas por IA con múltiples intentos
- Seguimiento de progreso en materiales
- Relaciones apoderado-estudiante
- Versioning de materiales
- Auditoría completa de eventos

---

## POSTGRESQL - TABLAS RELACIONALES

### Tabla 1: USERS (Usuarios)

**Propósito:** Almacenar información de todos los usuarios del sistema

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| email | VARCHAR(255) | NOT NULL, UNIQUE | Email único para login |
| password_hash | VARCHAR(255) | NOT NULL | Contraseña hasheada (bcrypt) |
| first_name | VARCHAR(100) | NOT NULL | Nombre del usuario |
| last_name | VARCHAR(100) | NOT NULL | Apellido del usuario |
| role | VARCHAR(50) | NOT NULL, CHECK | admin, teacher, student, guardian |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Usuario activo/inactivo |
| email_verified | BOOLEAN | NOT NULL, DEFAULT false | Email verificado |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |
| deleted_at | TIMESTAMP | NULL | Soft delete (si está nulo, usuario activo) |

**Índices:**
- idx_users_email (búsqueda por email)
- idx_users_role (filtrado por rol)
- idx_users_active (usuarios activos)
- idx_users_created_at (orden cronológico)

**Consideraciones UI:**
- El campo `role` en users es el rol GLOBAL
- Roles específicos por escuela se definen en `memberships`
- Email debe ser único en el sistema
- Soft delete: verificar `deleted_at IS NULL` en consultas

---

### Tabla 2: SCHOOLS (Escuelas)

**Propósito:** Almacenar información de instituciones educativas

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| name | VARCHAR(255) | NOT NULL | Nombre de la escuela |
| code | VARCHAR(50) | NOT NULL, UNIQUE | Código identificador (ej: "IST-001") |
| address | TEXT | NULL | Dirección física |
| city | VARCHAR(100) | NULL | Ciudad |
| country | VARCHAR(100) | NOT NULL, DEFAULT 'Chile' | País |
| phone | VARCHAR(50) | NULL | Teléfono |
| email | VARCHAR(255) | NULL | Email institucional |
| metadata | JSONB | DEFAULT '{}' | Datos extensibles (logo, config) |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Escuela activa |
| subscription_tier | VARCHAR(50) | NOT NULL, CHECK | free, basic, premium, enterprise |
| max_teachers | INTEGER | NOT NULL, DEFAULT 10 | Límite de docentes |
| max_students | INTEGER | NOT NULL, DEFAULT 100 | Límite de estudiantes |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |
| deleted_at | TIMESTAMP | NULL | Soft delete |

**Índices:**
- idx_schools_code
- idx_schools_active
- idx_schools_tier (filtrado por plan)

**Consideraciones UI:**
- El campo `metadata` permite agregar datos sin migración (logo, colores)
- `subscription_tier` define features disponibles
- `max_teachers` y `max_students` son validaciones de negocio

---

### Tabla 3: ACADEMIC_UNITS (Unidades Académicas)

**Propósito:** Estructura jerárquica flexible de unidades (Facultad → Departamento → Clase)

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| parent_unit_id | UUID | FK academic_units(id), NULL | Padre en jerarquía (NULL = raíz) |
| school_id | UUID | FK schools(id), NOT NULL | Escuela a la que pertenece |
| name | VARCHAR(255) | NOT NULL | Nombre de la unidad |
| code | VARCHAR(50) | NOT NULL | Código (ej: "GR-1A") |
| type | VARCHAR(50) | NOT NULL, CHECK | school, grade, class, section, club, department |
| description | TEXT | NULL | Descripción |
| level | VARCHAR(50) | NULL | Nivel (ej: "1st", "2nd", "3rd") |
| academic_year | INTEGER | NULL, DEFAULT 0 | Año académico (0 = sin año) |
| metadata | JSONB | DEFAULT '{}' | Extensibilidad |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Unidad activa |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |
| deleted_at | TIMESTAMP | NULL | Soft delete |

**Constraints:**
- UNIQUE(school_id, code, academic_year) - Código único por escuela y año
- CHECK (id != parent_unit_id) - Prevenir auto-referencia
- TRIGGER prevent_academic_unit_cycles - Prevenir ciclos en jerarquía

**Índices:**
- idx_academic_units_parent (para jerarquía)
- idx_academic_units_school
- idx_academic_units_type
- idx_academic_units_year

**Vista especial:**
- `v_academic_unit_tree` - Vista con CTE recursivo que muestra árbol completo

**Consideraciones UI:**
- Soporta estructura jerárquica profunda (Facultad → Carrera → Semestre → Grupo)
- El campo `parent_unit_id IS NULL` indica unidad raíz
- Función trigger `prevent_academic_unit_cycles()` garantiza no hay ciclos
- Vista `v_academic_unit_tree` proporciona path jerárquico completo

---

### Tabla 4: MEMBERSHIPS (Membresías Usuario-Escuela-Unidad)

**Propósito:** Relación muchos-a-muchos entre usuarios, escuelas y unidades académicas

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| user_id | UUID | FK users(id), NOT NULL | Usuario |
| school_id | UUID | FK schools(id), NOT NULL | Escuela |
| academic_unit_id | UUID | FK academic_units(id), NULL | Unidad académica (NULL = nivel escuela) |
| role | VARCHAR(50) | NOT NULL, CHECK | teacher, student, guardian, coordinator, admin, assistant |
| metadata | JSONB | DEFAULT '{}' | Permisos específicos, historial |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Membresía activa |
| enrolled_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de inscripción |
| withdrawn_at | TIMESTAMP | NULL | Fecha de retiro (NULL = activo) |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |

**Constraints:**
- UNIQUE(user_id, school_id, academic_unit_id, role) - Evita duplicados

**Índices:**
- idx_memberships_user
- idx_memberships_school
- idx_memberships_unit
- idx_memberships_role
- idx_memberships_active

**Consideraciones UI:**
- Un usuario puede tener MÚLTIPLES roles en diferentes escuelas/unidades
- El campo `role` aquí es específico a la escuela (vs `users.role` que es global)
- Un mismo usuario puede ser "teacher" en escuela A y "student" en escuela B
- Un docente puede ser miembro de múltiples unidades académicas
- El campo `metadata` almacena permisos específicos sin alterar la tabla

---

### Tabla 5: MATERIALS (Materiales Educativos)

**Propósito:** Almacenar metadatos de materiales educativos subidos

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| school_id | UUID | FK schools(id), NOT NULL | Escuela propietaria |
| uploaded_by_teacher_id | UUID | FK users(id), NOT NULL | Docente que lo subió |
| academic_unit_id | UUID | FK academic_units(id), NULL | Unidad académica (NULL = material general) |
| title | VARCHAR(255) | NOT NULL | Título del material |
| description | TEXT | NULL | Descripción |
| subject | VARCHAR(100) | NULL | Materia/asignatura |
| grade | VARCHAR(50) | NULL | Grado/nivel |
| file_url | TEXT | NOT NULL | URL del archivo en S3 |
| file_type | VARCHAR(100) | NOT NULL | MIME type (application/pdf, etc) |
| file_size_bytes | BIGINT | NOT NULL | Tamaño en bytes |
| status | VARCHAR(50) | NOT NULL, DEFAULT 'uploaded', CHECK | uploaded, processing, ready, failed |
| processing_started_at | TIMESTAMP | NULL | Inicio de procesamiento |
| processing_completed_at | TIMESTAMP | NULL | Fin de procesamiento |
| is_public | BOOLEAN | NOT NULL, DEFAULT false | Material público o privado |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |
| deleted_at | TIMESTAMP | NULL | Soft delete |

**Índices:**
- idx_materials_school
- idx_materials_teacher
- idx_materials_unit
- idx_materials_status (importante para procesamiento)
- idx_materials_created_at
- idx_materials_subject

**Flujo de estado:**
```
uploaded → processing → ready   ✅ Éxito
       ↘ processing → failed    ❌ Error
```

**Consideraciones UI:**
- `status` indica si el material está listo (IA ha procesado)
- Materials con `status = 'ready'` tienen assessment en MongoDB
- `file_size_bytes` importante para mostrar tamaño
- El docente (teacher_id) debe tener permiso en la unidad académica

---

### Tabla 6: ASSESSMENT (Evaluaciones/Quizzes)

**Propósito:** Referencia a evaluaciones generadas por IA

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| material_id | UUID | FK materials(id), NOT NULL | Material evaluado |
| mongo_document_id | VARCHAR(24) | NOT NULL, UNIQUE | ObjectId en MongoDB material_assessment |
| questions_count | INTEGER | NOT NULL, DEFAULT 0 | Cantidad de preguntas (deprecated, usar total_questions) |
| total_questions | INTEGER | NULL | Total de preguntas (reemplaza questions_count) |
| title | VARCHAR(255) | NULL | Título del assessment |
| pass_threshold | INTEGER | DEFAULT 70 | Porcentaje mínimo para aprobar (0-100) |
| max_attempts | INTEGER | NULL | Máximo de intentos (NULL = ilimitado) |
| time_limit_minutes | INTEGER | NULL | Límite de tiempo (NULL = sin límite) |
| status | VARCHAR(50) | NOT NULL, DEFAULT 'generated', CHECK | draft, generated, published, archived, closed |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |
| deleted_at | TIMESTAMP | NULL | Soft delete |

**Índices:**
- idx_assessment_material
- idx_assessment_mongo (búsqueda por ObjectId)
- idx_assessment_status
- idx_assessment_created_at

**Consideraciones UI:**
- El contenido real (preguntas, opciones) está en MongoDB
- PostgreSQL solo guarda referencia y metadatos
- `pass_threshold`, `max_attempts`, `time_limit_minutes` son configurables
- Trigger `sync_questions_count()` mantiene sincronizados `questions_count` y `total_questions`

---

### Tabla 7: ASSESSMENT_ATTEMPT (Intentos de Evaluación)

**Propósito:** Registrar intentos de un estudiante en un assessment

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| assessment_id | UUID | FK assessment(id), NOT NULL | Assessment intentado |
| student_id | UUID | FK users(id), NOT NULL | Estudiante |
| started_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Inicio del intento |
| completed_at | TIMESTAMP | NULL | Fin del intento (NULL = en progreso) |
| score | DECIMAL(5,2) | NULL | Puntuación obtenida |
| max_score | DECIMAL(5,2) | NULL | Puntuación máxima |
| percentage | DECIMAL(5,2) | NULL | Porcentaje (0-100) |
| time_spent_seconds | INTEGER | NULL | Tiempo total en segundos (max 7200 = 2h) |
| idempotency_key | VARCHAR(64) | NULL | Clave para prevenir duplicados |
| status | VARCHAR(50) | NOT NULL, DEFAULT 'in_progress', CHECK | in_progress, completed, abandoned |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |

**Constraints:**
- CHECK (completed_at IS NULL OR completed_at > started_at)
- UNIQUE(idempotency_key)

**Índices:**
- idx_attempt_assessment
- idx_attempt_student
- idx_attempt_status
- idx_attempt_completed_at
- idx_attempt_idempotency_key (parcial)

**Consideraciones UI:**
- `status = 'in_progress'` = estudiante está resolviendo ahora
- `completed_at IS NULL` = intento no terminado
- `percentage` es NULL hasta que se califica
- `time_spent_seconds` se calcula al finalizar

---

### Tabla 8: ASSESSMENT_ATTEMPT_ANSWER (Respuestas Individuales)

**Propósito:** Almacenar respuesta del estudiante a cada pregunta

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| attempt_id | UUID | FK assessment_attempt(id), NOT NULL | Intento padre |
| question_index | INTEGER | NOT NULL | Índice de pregunta (0-based) |
| student_answer | TEXT | NULL | Respuesta del estudiante (JSON/string flexible) |
| is_correct | BOOLEAN | NULL | ¿Respuesta correcta? |
| points_earned | DECIMAL(5,2) | NULL | Puntos obtenidos |
| max_points | DECIMAL(5,2) | NULL | Puntos máximos |
| time_spent_seconds | INTEGER | NULL | Tiempo para responder esta pregunta |
| answered_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Cuándo respondió |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |

**Constraints:**
- UNIQUE(attempt_id, question_index)

**Índices:**
- idx_answer_attempt
- idx_answer_correct

**Consideraciones UI:**
- `question_index` es 0-based (primera pregunta = 0)
- `student_answer` es flexible TEXT (puede ser JSON stringified)
- `is_correct` es NULL hasta que se califica
- Un intento = múltiples respuestas (una por pregunta)

---

### Tabla 9: MATERIAL_VERSIONS (Versiones de Materiales)

**Propósito:** Historial de cambios en materiales

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| material_id | UUID | FK materials(id), NOT NULL | Material parent |
| version_number | INTEGER | NOT NULL, CHECK (>0) | Número de versión (1, 2, 3...) |
| title | VARCHAR(255) | NOT NULL | Título de esta versión |
| content_url | TEXT | NOT NULL | URL del contenido (S3) |
| changed_by | UUID | FK users(id), NOT NULL | Usuario que hizo el cambio |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de cambio |

**Constraints:**
- UNIQUE(material_id, version_number)

**Índices:**
- idx_material_versions_material_id
- idx_material_versions_version_number
- idx_material_versions_changed_by
- idx_material_versions_created_at

**Consideraciones UI:**
- Tabla de auditoría de cambios
- `version_number` es secuencial y único por material
- Permite recuperar versiones anteriores

---

### Tabla 10: SUBJECTS (Asignaturas)

**Propósito:** Catálogo de materias del sistema

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| name | VARCHAR(255) | NOT NULL | Nombre de la materia |
| description | TEXT | NULL | Descripción |
| metadata | JSONB | NULL | Datos extensibles |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Materia activa |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |

**Índices:**
- idx_subjects_name
- idx_subjects_is_active
- idx_subjects_created_at
- idx_subjects_metadata (GIN)

**Consideraciones UI:**
- Tabla de referencia (no tiene FK)
- Se usa para clasificar materiales

---

### Tabla 11: UNITS (Unidades Organizacionales)

**Propósito:** Similar a academic_units pero más simple, para jerarquías organizacionales

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| school_id | UUID | FK schools(id), NOT NULL | Escuela |
| parent_unit_id | UUID | FK units(id), NULL | Unidad padre (NULL = raíz) |
| name | VARCHAR(255) | NOT NULL, CHECK (length >= 2) | Nombre (mínimo 2 caracteres) |
| description | TEXT | NULL | Descripción |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Unidad activa |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |

**Constraints:**
- CHECK (id != parent_unit_id)

**Índices:**
- idx_units_school_id
- idx_units_parent_unit_id
- idx_units_name
- idx_units_is_active
- idx_units_created_at
- idx_units_hierarchy (compuesto para queries jerárquicas)

**Consideraciones UI:**
- Alternativa más simple a academic_units
- Soporta jerarquía (Departamento → Subunidad)
- Nombre debe tener mínimo 2 caracteres

---

### Tabla 12: GUARDIAN_RELATIONS (Relaciones Apoderado-Estudiante)

**Propósito:** Registrar quién es apoderado/tutor de quién

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Identificador único |
| guardian_id | UUID | FK users(id), NOT NULL | Usuario apoderado |
| student_id | UUID | FK users(id), NOT NULL | Usuario estudiante |
| relationship_type | VARCHAR(50) | NOT NULL, CHECK | father, mother, grandfather, grandmother, uncle, aunt, sibling, legal_guardian, other |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Relación activa |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |
| created_by | VARCHAR(255) | NOT NULL | Quién creó la relación |

**Constraints:**
- UNIQUE(guardian_id, student_id) - Un apoderado por estudiante
- CHECK (guardian_id != student_id) - No puede ser apoderado de sí mismo

**Índices:**
- idx_guardian_relations_guardian_id
- idx_guardian_relations_student_id
- idx_guardian_relations_relationship_type
- idx_guardian_relations_is_active
- idx_guardian_relations_created_at
- idx_guardian_relations_active_guardian
- idx_guardian_relations_active_student

**Consideraciones UI:**
- Un estudiante puede tener múltiples apoderados
- Un apoderado puede tener múltiples estudiantes
- `relationship_type` especifica la relación familiar
- `is_active` permite inactivar sin eliminar

---

### Tabla 13: PROGRESS (Progreso de Lectura)

**Propósito:** Tracking de avance del usuario en cada material

**Campos:**

| Campo | Tipo | Restricción | Descripción |
|-------|------|-------------|-------------|
| material_id | UUID | FK materials(id), NOT NULL | Material |
| user_id | UUID | FK users(id), NOT NULL | Usuario |
| percentage | INTEGER | NOT NULL, DEFAULT 0, CHECK (0-100) | Porcentaje completado |
| last_page | INTEGER | NOT NULL, DEFAULT 0, CHECK (>=0) | Última página leída |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'not_started', CHECK | not_started, in_progress, completed |
| last_accessed_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Último acceso |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de creación |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de actualización |

**Constraints:**
- PRIMARY KEY (material_id, user_id) - Un progreso por material/usuario

**Índices:**
- idx_progress_user_id
- idx_progress_material_id
- idx_progress_status
- idx_progress_last_accessed_at
- idx_progress_percentage
- idx_progress_user_status
- idx_progress_material_status

**Consideraciones UI:**
- Un registro por (material, usuario)
- Status indica: no comenzó, en curso, completado
- Permite visualizar: "Completaste 75% del material"
- `last_accessed_at` para ordenar "Últimos visitados"

---

## MONGODB - COLECCIONES NOSQL

### Colección 1: MATERIAL_ASSESSMENT

**Propósito:** Preguntas y opciones de evaluaciones generadas por IA

**Estructura:**

```javascript
{
  "_id": ObjectId,
  "material_id": "UUID",  // Referencia a materials.id
  "questions": [
    {
      "question_index": 0,
      "question_text": "¿Cuál es la fórmula de...?",
      "question_type": "multiple_choice",  // "multiple_choice", "true_false", "open"
      "options": [
        { "index": 0, "text": "Opción A" },
        { "index": 1, "text": "Opción B" },
        { "index": 2, "text": "Opción C" },
        { "index": 3, "text": "Opción D" }
      ],
      "correct_answer_index": 2,  // Índice de opción correcta
      "explanation": "La respuesta correcta es..."
    },
    // ... más preguntas
  ],
  "metadata": {
    "generated_by": "gpt-4",
    "generation_timestamp": ISODate,
    "version": 1
  },
  "created_at": ISODate,
  "updated_at": ISODate
}
```

**Validación JSON Schema:**
- Campo requerido: material_id (UUID)
- Campo requerido: questions (array)
- Campo requerido: metadata
- Campo requerido: created_at, updated_at

**Índices:**
- { material_id: 1 }
- { "metadata.generated_by": 1 }
- { created_at: -1 }

**Consideraciones UI:**
- Contiene todas las preguntas del assessment
- Está enlazado por `assessment.mongo_document_id` en PostgreSQL
- Respuestas del estudiante se guardan en `assessment_attempt_result`

---

### Colección 2: MATERIAL_CONTENT

**Propósito:** Contenido extraído y procesado de materiales

**Estructura:**

```javascript
{
  "_id": ObjectId,
  "material_id": "UUID",
  "content_type": "pdf_extracted",  // "pdf_extracted", "video_transcript", "document_parsed", "slides_extracted"
  "raw_text": "Contenido completo del material...",
  "structured_content": {
    "title": "Introducción a Física Cuántica",
    "sections": [
      {
        "heading": "1. Conceptos Básicos",
        "content": "...",
        "subsections": []
      }
    ],
    "summary": "Resumen extractado automáticamente",
    "key_concepts": ["Concepto 1", "Concepto 2", "Concepto 3"]
  },
  "processing_info": {
    "processor": "worker-service",
    "timestamp": ISODate,
    "processing_time_ms": 5000
  },
  "created_at": ISODate,
  "updated_at": ISODate
}
```

**Consideraciones UI:**
- Usado por worker para generar resúmenes y evaluaciones
- `raw_text` es el contenido sin procesar
- `structured_content` es el resultado del procesamiento

---

### Colección 3: ASSESSMENT_ATTEMPT_RESULT

**Propósito:** Resultados detallados de un intento de assessment

**Estructura:**

```javascript
{
  "_id": ObjectId,
  "attempt_id": "UUID",  // Referencia a assessment_attempt.id
  "student_id": "UUID",
  "assessment_id": "UUID",
  "answers": [
    {
      "question_index": 0,
      "selected_option_index": 2,
      "is_correct": true,
      "time_spent_seconds": 45,
      "answered_at": ISODate
    },
    {
      "question_index": 1,
      "selected_option_index": 0,
      "is_correct": false,
      "time_spent_seconds": 30,
      "answered_at": ISODate
    }
    // ... más respuestas
  ],
  "score": {
    "correct_count": 7,
    "total_questions": 10,
    "percentage": 70.0,
    "max_score": 100,
    "obtained_score": 70
  },
  "started_at": ISODate,
  "submitted_at": ISODate,
  "created_at": ISODate
}
```

**Validación JSON Schema:**
- Requerido: attempt_id, student_id, assessment_id, answers, score, started_at, submitted_at
- Requerido en answers: question_index, selected_option_index, is_correct, time_spent_seconds

**Consideraciones UI:**
- Un documento por intento (enlazado por `assessment_attempt.id`)
- Contiene detalles completos de respuestas y tiempo
- Score contiene cálculos consolidados

---

### Colección 4: MATERIAL_SUMMARY

**Propósito:** Resúmenes generados por IA del material

**Estructura:**

```javascript
{
  "_id": ObjectId,
  "material_id": "UUID",
  "summary": "Resumen en texto del material educativo...",
  "key_points": [
    "Punto clave 1",
    "Punto clave 2",
    "Punto clave 3",
    "Punto clave 4",
    "Punto clave 5"
  ],
  "language": "es",  // "es", "en", "pt"
  "word_count": 250,
  "version": 1,
  "ai_model": "gpt-4",
  "processing_time_ms": 8000,
  "metadata": {
    "confidence_score": 0.95,
    "extracted_keywords": ["keyword1", "keyword2", ...]
  },
  "created_at": ISODate,
  "updated_at": ISODate
}
```

**Validación JSON Schema:**
- Requerido: material_id, summary, key_points, language, word_count, version, ai_model, processing_time_ms
- summary: 10-5000 caracteres
- key_points: array de 1-10 strings

**Consideraciones UI:**
- Proporciona resumen rápido del material
- `key_points` es lista de conceptos principales
- `word_count` indica extensión del resumen
- Un resumen por material (versión incremental)

---

### Colección 5: MATERIAL_ASSESSMENT_WORKER

**Propósito:** Assessment procesado por worker (versión enriquecida)

**Estructura:**

```javascript
{
  "_id": ObjectId,
  "material_id": "UUID",
  "questions": [
    {
      "question_id": "q-001",
      "question_text": "¿Cuál es la definición de...?",
      "question_type": "multiple_choice",  // "multiple_choice", "true_false", "open"
      "options": [
        { "id": "opt-1", "text": "Opción 1" },
        { "id": "opt-2", "text": "Opción 2" },
        { "id": "opt-3", "text": "Opción 3" },
        { "id": "opt-4", "text": "Opción 4" }
      ],
      "correct_answer": "opt-3",
      "explanation": "Explicación de por qué es correcta...",
      "points": 10,
      "difficulty": "medium"  // "easy", "medium", "hard"
    }
  ],
  "total_questions": 8,
  "total_points": 100,
  "version": 1,
  "ai_model": "gpt-4",
  "processing_time_ms": 12000,
  "metadata": {
    "coverage": 0.85,
    "diversity_score": 0.90
  },
  "created_at": ISODate,
  "updated_at": ISODate
}
```

**Diferencia con MATERIAL_ASSESSMENT:**
- Incluye más metadatos (difficulty, explanation, points)
- Usado internamente por worker
- `correct_answer` es ID string vs índice

---

### Colección 6: AUDIT_LOGS

**Propósito:** Registro de auditoría de todas las acciones del sistema

**Estructura:**

```javascript
{
  "_id": ObjectId,
  "event_type": "material.uploaded",  // "user.created", "material.uploaded", "assessment.published", etc
  "actor_id": "UUID",
  "actor_type": "user",  // "user", "system", "api", "worker"
  "timestamp": ISODate,
  "resource_type": "material",  // "user", "school", "material", "assessment", etc
  "resource_id": "UUID",
  "action": "create",  // "create", "read", "update", "delete", "login", etc
  "changes": {
    "field_name": { "old_value": "...", "new_value": "..." },
    // ... más cambios
  },
  "metadata": {
    "reason": "Material desactualizado",
    "ip_address": "192.168.1.100"
  },
  "ip_address": "192.168.1.100",
  "user_agent": "Mozilla/5.0...",
  "severity": "info"  // "info", "warning", "error", "critical"
}
```

**Validación JSON Schema:**
- Requerido: event_type, actor_id, timestamp, resource_type, action

**Indexing:**
- { timestamp: -1 }
- { actor_id: 1, timestamp: -1 }
- { resource_type: 1, resource_id: 1 }
- { event_type: 1, timestamp: -1 }

**Consideraciones UI:**
- Completa auditoría de cambios
- Permite rastrear quién hizo qué y cuándo
- `severity` indica importancia del evento

---

### Colección 7: NOTIFICATIONS

**Propósito:** Notificaciones para usuarios

**Estructura:**

```javascript
{
  "_id": ObjectId,
  "user_id": "UUID",
  "notification_type": "assessment.ready",  // "assessment.ready", "material.uploaded", "deadline.approaching", etc
  "title": "Tu evaluación está lista",
  "message": "El assessment de Física ha sido generado y está disponible",
  "is_read": false,
  "priority": "high",  // "low", "medium", "high", "urgent"
  "category": "academic",  // "academic", "administrative", "social", "system"
  "action_url": "/assessments/66666666-6666-6666-6666-666666666666",
  "metadata": {
    "material_id": "UUID",
    "assessment_id": "UUID"
  },
  "read_at": null,  // ISODate si fue leída
  "created_at": ISODate,
  "expires_at": ISODate  // Fecha de expiración
}
```

**Validación JSON Schema:**
- Requerido: user_id, notification_type, title, is_read, created_at

**Indexing:**
- { user_id: 1, is_read: 1, created_at: -1 }
- { user_id: 1, created_at: -1 }
- { expires_at: 1 }

**Consideraciones UI:**
- `is_read` para distinguir notificaciones leídas/no leídas
- `priority` para resaltar notificaciones importantes
- `action_url` para navegación directa
- `expires_at` para limpiar automáticamente notificaciones antiguas

---

### Colección 8: ANALYTICS_EVENTS

**Propósito:** Eventos de análisis para entender comportamiento del usuario

**Estructura:**

```javascript
{
  "_id": ObjectId,
  "event_name": "material.view",  // "page.view", "material.view", "assessment.complete", "video.play", etc
  "user_id": "UUID",
  "session_id": "session-xxxxx",
  "timestamp": ISODate,
  "properties": {
    "material_id": "UUID",
    "duration_seconds": 300,
    "scroll_percentage": 75
  },
  "device": {
    "type": "mobile",  // "mobile", "tablet", "desktop"
    "os": "iOS",       // "iOS", "Android", "Windows", "macOS"
    "browser": "Safari"
  },
  "location": {
    "country": "CL",
    "city": "Santiago",
    "timezone": "America/Santiago"
  },
  "context": {
    "page": "/materials/view",
    "referrer": "/dashboard",
    "url": "https://app.edugo.io/materials/UUID"
  }
}
```

**Validación JSON Schema:**
- Requerido: event_name, timestamp

**Indexing:**
- { user_id: 1, timestamp: -1 }
- { event_name: 1, timestamp: -1 }
- { session_id: 1 }

**Consideraciones UI:**
- Eventos sin restricciones de estructura (properties es flexible)
- Usado para dashboards de analytics
- Permite entender flujos de usuario

---

### Colección 9: MATERIAL_EVENT

**Propósito:** Cola de eventos para procesamiento asíncrono

**Estructura:**

```javascript
{
  "_id": ObjectId,
  "event_type": "material_uploaded",  // "material_uploaded", "material_reprocess", "material_deleted", "assessment_attempt", etc
  "material_id": "UUID",
  "user_id": "UUID",
  "payload": {
    "file_url": "s3://bucket/file.pdf",
    "file_type": "application/pdf",
    "file_size_bytes": 2048000,
    "metadata": { ... }
  },
  "status": "pending",  // "pending", "processing", "completed", "failed"
  "error_msg": null,
  "stack_trace": null,
  "retry_count": 0,
  "next_retry_at": null,  // ISODate si está programado retry
  "processed_at": null,   // ISODate cuando se completó
  "created_at": ISODate,
  "updated_at": ISODate
}
```

**Validación JSON Schema:**
- Requerido: event_type, payload, status, retry_count

**Indexing:**
- { status: 1, created_at: -1 }
- { event_type: 1, status: 1 }
- { next_retry_at: 1 }

**Consideraciones UI:**
- Usado internamente por worker para procesar eventos
- `status = 'pending'` = esperando procesamiento
- `retry_count` indica intentos fallidos
- `next_retry_at` para scheduling de reintentos

---

## ROLES Y PERFILES DE USUARIO

### Roles en la Tabla USERS (Global)

```
┌─────────────┬──────────────────────────────────────────┐
│ Rol         │ Descripción                              │
├─────────────┼──────────────────────────────────────────┤
│ admin       │ Administrador del sistema (solo personal) │
│ teacher     │ Docente (puede ser en múltiples escuelas)│
│ student     │ Estudiante (puede ser en múltiples escuelas) │
│ guardian    │ Apoderado/Tutor                          │
└─────────────┴──────────────────────────────────────────┘
```

### Roles en MEMBERSHIPS (Por Escuela/Unidad)

```
┌─────────────┬──────────────────────────────────┬──────────┐
│ Rol         │ Descripción                      │ Escuela  │
├─────────────┼──────────────────────────────────┼──────────┤
│ teacher     │ Docente de unidad académica      │ Sí       │
│ student     │ Estudiante de unidad académica   │ Sí       │
│ guardian    │ Apoderado (acceso a estudiante)  │ Sí       │
│ coordinator │ Coordinador de unidad            │ Sí       │
│ admin       │ Administrador de escuela         │ Sí       │
│ assistant   │ Asistente de docente/unidad      │ Sí       │
└─────────────┴──────────────────────────────────┴──────────┘
```

### Ejemplo Práctico: Usuario con Múltiples Roles

**Usuario:** Juan Pérez
- **users.id:** UUID-1
- **users.role:** "teacher" (rol global)

**Memberships:**
1. Escuela A, Unidad Matemáticas → Rol "teacher" (docente)
2. Escuela B, Unidad Director → Rol "admin" (administrador)
3. Escuela C, Unidad Física → Rol "assistant" (asistente)

### Permisos Implícitos por Rol

| Rol | Puede crear material | Puede crear evaluación | Puede ver resultados | Puede editar escuela |
|-----|----------------------|------------------------|----------------------|----------------------|
| admin | ✅ | ✅ | ✅ | ✅ |
| teacher | ✅ | ✅ (automática) | ✅ (sus estudiantes) | ❌ |
| coordinator | ❌ | ❌ | ✅ (su unidad) | ❌ |
| student | ❌ | ❌ | ✅ (propios) | ❌ |
| guardian | ❌ | ❌ | ✅ (sus pupilos) | ❌ |

---

## RELACIONES ENTRE ENTIDADES

### Relaciones Directas (Foreign Keys)

```
USERS
  ├─ PK: id (UUID)
  ├─ 1──N→ MEMBERSHIPS (user_id)
  ├─ 1──N→ MATERIALS (uploaded_by_teacher_id)
  ├─ 1──N→ ASSESSMENT_ATTEMPT (student_id)
  ├─ 1──N→ ASSESSMENT_ATTEMPT_ANSWER (indirecto via attempt)
  ├─ 1──N→ GUARDIAN_RELATIONS (guardian_id or student_id)
  ├─ 1──N→ MATERIAL_VERSIONS (changed_by)
  └─ 1──N→ PROGRESS (user_id)

SCHOOLS
  ├─ PK: id (UUID)
  ├─ 1──N→ ACADEMIC_UNITS (school_id)
  ├─ 1──N→ MEMBERSHIPS (school_id)
  ├─ 1──N→ MATERIALS (school_id)
  └─ 1──N→ UNITS (school_id)

ACADEMIC_UNITS
  ├─ PK: id (UUID)
  ├─ FK: parent_unit_id (self-reference, jerarquía)
  ├─ FK: school_id → SCHOOLS
  ├─ 1──N→ ACADEMIC_UNITS (parent_unit_id, jerarquía)
  ├─ 1──N→ MEMBERSHIPS (academic_unit_id)
  └─ 1──N→ MATERIALS (academic_unit_id)

MEMBERSHIPS
  ├─ PK: id (UUID)
  ├─ FK: user_id → USERS
  ├─ FK: school_id → SCHOOLS
  ├─ FK: academic_unit_id → ACADEMIC_UNITS
  └─ UNIQUE(user_id, school_id, academic_unit_id, role)

MATERIALS
  ├─ PK: id (UUID)
  ├─ FK: school_id → SCHOOLS
  ├─ FK: uploaded_by_teacher_id → USERS
  ├─ FK: academic_unit_id → ACADEMIC_UNITS
  ├─ 1──N→ ASSESSMENT (material_id)
  ├─ 1──N→ MATERIAL_VERSIONS (material_id)
  ├─ 1──N→ PROGRESS (material_id)
  └─ Status: uploaded → processing → ready ✅ | failed ❌

ASSESSMENT
  ├─ PK: id (UUID)
  ├─ FK: material_id → MATERIALS
  ├─ mongo_document_id ──→ material_assessment (MongoDB)
  ├─ 1──N→ ASSESSMENT_ATTEMPT (assessment_id)
  └─ Status: draft → generated → published → archived | closed

ASSESSMENT_ATTEMPT
  ├─ PK: id (UUID)
  ├─ FK: assessment_id → ASSESSMENT
  ├─ FK: student_id → USERS
  ├─ 1──N→ ASSESSMENT_ATTEMPT_ANSWER (attempt_id)
  ├─ mongo_document_id ──→ assessment_attempt_result (MongoDB)
  └─ Status: in_progress → completed | abandoned

ASSESSMENT_ATTEMPT_ANSWER
  ├─ PK: id (UUID)
  ├─ FK: attempt_id → ASSESSMENT_ATTEMPT
  └─ UNIQUE(attempt_id, question_index)

MATERIAL_VERSIONS
  ├─ PK: id (UUID)
  ├─ FK: material_id → MATERIALS
  ├─ FK: changed_by → USERS
  └─ UNIQUE(material_id, version_number)

GUARDIAN_RELATIONS
  ├─ PK: id (UUID)
  ├─ FK: guardian_id → USERS
  ├─ FK: student_id → USERS
  └─ UNIQUE(guardian_id, student_id)

PROGRESS
  ├─ PK: (material_id, user_id)
  ├─ FK: material_id → MATERIALS
  └─ FK: user_id → USERS
```

### Relaciones Cross-Database

```
PostgreSQL ASSESSMENT
  └─ mongo_document_id ──→ MongoDB MATERIAL_ASSESSMENT
                              └─ questions[], metadata

PostgreSQL ASSESSMENT_ATTEMPT
  └─ id ──→ MongoDB ASSESSMENT_ATTEMPT_RESULT
               └─ answers[], score, timestamps
```

---

## DIAGRAMA DE ENTIDADES

### Vista de Alto Nivel

```
┌─────────────────────────────────────────────────────────────────┐
│                          ECOSISTEMA EDUGO                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    POSTGRESQL (Relacional)               │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                          │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │  USERS (4 roles)                               │    │   │
│  │  │  ├─ id, email, role (admin,teacher,student...  │    │   │
│  │  │  └─ email_verified, is_active, created_at      │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  │         │           │              │         │          │   │
│  │         ▼           ▼              ▼         ▼          │   │
│  │  ┌────────────┐  ┌──────────┐  ┌────────┐ ┌──────────┐│   │
│  │  │ MEMBERSHIPS│  │MATERIALS │  │GUARDIAN│ │ PROGRESS ││   │
│  │  │ (6 roles)  │  │(subidos) │  │RELATIONS│         ││   │
│  │  └────────────┘  └──────────┘  └────────┘ └──────────┘│   │
│  │         │              │                               │   │
│  │    ┌────┴──────────────┴──────┐                        │   │
│  │    │                           │                        │   │
│  │    ▼                           ▼                        │   │
│  │  ┌─────────────┐   ┌──────────────────────────┐       │   │
│  │  │SCHOOLS      │   │ACADEMIC_UNITS (Jerarquía)│       │   │
│  │  │(Instituciones)│   │Facultad→Depto→Clase│       │   │
│  │  └─────────────┘   └──────────────────────────┘       │   │
│  │                                                          │   │
│  │  ┌──────────────────────────────────────────────────┐  │   │
│  │  │ ASSESSMENT PIPELINE                             │  │   │
│  │  ├──────────────────────────────────────────────────┤  │   │
│  │  │ MATERIALS (status: processing → ready)           │  │   │
│  │  │     │                                             │  │   │
│  │  │     ▼                                             │  │   │
│  │  │ ASSESSMENT (referencia a MongoDB)                │  │   │
│  │  │     │                                             │  │   │
│  │  │     ▼                                             │  │   │
│  │  │ ASSESSMENT_ATTEMPT (intento del estudiante)      │  │   │
│  │  │     │                                             │  │   │
│  │  │     ▼                                             │  │   │
│  │  │ ASSESSMENT_ATTEMPT_ANSWER (respuesta por preg)   │  │   │
│  │  └──────────────────────────────────────────────────┘  │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              MONGODB (Documental)                        │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                          │   │
│  │  ┌──────────────────────┐  ┌──────────────────────┐    │   │
│  │  │material_assessment   │  │ material_summary     │    │   │
│  │  │ (Preguntas IA)       │  │ (Resumen IA)         │    │   │
│  │  │ ├─ questions[]       │  │ ├─ summary (texto)   │    │   │
│  │  │ ├─ metadata          │  │ ├─ key_points[]      │    │   │
│  │  │ └─ created_at        │  │ └─ version           │    │   │
│  │  └──────────────────────┘  └──────────────────────┘    │   │
│  │                                                          │   │
│  │  ┌──────────────────────┐  ┌──────────────────────┐    │   │
│  │  │assessment_attempt_   │  │ material_content     │    │   │
│  │  │result (Respuestas)   │  │ (Texto extraído)     │    │   │
│  │  │ ├─ answers[]         │  │ ├─ raw_text          │    │   │
│  │  │ ├─ score{..}         │  │ ├─ structured_content│    │   │
│  │  │ └─ submitted_at      │  │ └─ processing_info   │    │   │
│  │  └──────────────────────┘  └──────────────────────┘    │   │
│  │                                                          │   │
│  │  ┌──────────────────────┐  ┌──────────────────────┐    │   │
│  │  │ audit_logs           │  │ notifications        │    │   │
│  │  │ (Auditoría)          │  │ (Notificaciones)     │    │   │
│  │  │ ├─ event_type        │  │ ├─ user_id           │    │   │
│  │  │ ├─ actor_id          │  │ ├─ notification_type │    │   │
│  │  │ └─ timestamp         │  │ └─ is_read           │    │   │
│  │  └──────────────────────┘  └──────────────────────┘    │   │
│  │                                                          │   │
│  │  ┌──────────────────────┐  ┌──────────────────────┐    │   │
│  │  │analytics_events      │  │ material_event       │    │   │
│  │  │ (Análisis)           │  │ (Cola de eventos)    │    │   │
│  │  │ ├─ event_name        │  │ ├─ event_type        │    │   │
│  │  │ ├─ user_id           │  │ ├─ status (pending)  │    │   │
│  │  │ └─ timestamp         │  │ └─ retry_count       │    │   │
│  │  └──────────────────────┘  └──────────────────────┘    │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           RABBITMQ (Mensajería Asíncrona)               │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                          │   │
│  │  material.uploaded ──→ worker (procesar)                │   │
│  │  assessment.generated ──→ api-mobile (notificar)        │   │
│  │  material.deleted ──→ worker (limpiar)                  │   │
│  │  student.enrolled ──→ api-mobile (sincronizar)          │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Flujo de Evaluación en Detalle

```
1. DOCENTE SUBE MATERIAL
   ┌─────────────────────┐
   │ api-mobile/         │
   │ uploadMaterial()    │
   └──────────┬──────────┘
              │
              ▼
   ┌─────────────────────────────────────────┐
   │ INSERT: materials                       │
   │ status = 'uploaded'                     │
   │ file_url = 's3://...'                   │
   └──────────┬──────────────────────────────┘
              │
              ▼
   ┌─────────────────────────────────────────┐
   │ PUBLISH: material.uploaded event        │
   │ routing_key: material.uploaded          │
   │ payload: { material_id, file_url, ... } │
   └──────────┬──────────────────────────────┘
              │
    ═══════════╧════════════════════════════════════════════
    ║  RabbitMQ                                              ║
    ║  (material.uploaded → edugo.topic exchange)            ║
    ════════════════════════════════════════════╤═══════════
                                                 │
                                   ┌─────────────▼──────────────┐
                                   │ worker subscribes to       │
                                   │ material.processing queue  │
                                   └──────────┬─────────────────┘
                                              │
2. WORKER PROCESA
   ┌──────────────────────────────────────────┐
   │ worker/                                  │
   │ processMaterialEvent()                   │
   └──────────┬───────────────────────────────┘
              │
              ├─ Descargar archivo de S3
              │
              ├─ Extraer texto (PDF, Word, etc)
              │
              ├─ INSERT: material_content (MongoDB)
              │
              ├─ Llamar OpenAI para generar evaluación
              │
              ├─ INSERT: material_assessment (MongoDB)
              │
              ├─ INSERT: assessment (PostgreSQL)
              │         status = 'generated'
              │         mongo_document_id = ObjectId
              │
              ├─ UPDATE: materials
              │         status = 'ready' ✅
              │
              └─▶ PUBLISH: assessment.generated event
                  routing_key: assessment.generated
                  payload: { material_id, mongo_document_id, questions_count }

3. ESTUDIANTE VE EVALUACIÓN LISTA
   ┌──────────────────────────────────────────┐
   │ api-mobile receives assessment.generated  │
   │ event via RabbitMQ                       │
   └──────────┬───────────────────────────────┘
              │
              ├─ UPDATE: notifications (MongoDB)
              │ "Tu evaluación está lista"
              │
              └─ Notificar estudiante (push/email)

4. ESTUDIANTE INTENTA EVALUACIÓN
   ┌──────────────────────────────────────────┐
   │ api-mobile/                              │
   │ startAssessmentAttempt()                 │
   └──────────┬───────────────────────────────┘
              │
              ▼
   ┌──────────────────────────────────────────┐
   │ INSERT: assessment_attempt                │
   │ status = 'in_progress'                   │
   │ started_at = NOW()                       │
   │ completed_at = NULL                      │
   └──────────┬───────────────────────────────┘
              │
              ▼ (para cada pregunta que responde)
   ┌──────────────────────────────────────────┐
   │ INSERT: assessment_attempt_answer         │
   │ question_index = 0, 1, 2, ...            │
   │ student_answer = 'A' (opciones)          │
   │ answered_at = NOW()                      │
   └──────────┬───────────────────────────────┘
              │
              ▼ (cuando termina)
   ┌──────────────────────────────────────────┐
   │ UPDATE: assessment_attempt                │
   │ status = 'completed'                     │
   │ completed_at = NOW()                     │
   │ score, percentage calculados (API)       │
   └──────────┬───────────────────────────────┘
              │
              ▼
   ┌──────────────────────────────────────────┐
   │ INSERT: assessment_attempt_result (MongoDB) │
   │ answers[] con is_correct evaluado        │
   │ score{ correct_count, percentage }       │
   │ submitted_at = NOW()                     │
   └──────────────────────────────────────────┘
```

---

## CONSIDERACIONES PARA UI

### Datos Obligatorios vs Opcionales

**Obligatorios (no pueden ser NULL):**
- users: email, password_hash, first_name, last_name, role
- schools: name, code, country
- academic_units: school_id, name, code, type
- memberships: user_id, school_id, role
- materials: school_id, uploaded_by_teacher_id, title, file_url, file_type, file_size_bytes
- assessment: material_id
- assessment_attempt: assessment_id, student_id
- assessment_attempt_answer: attempt_id, question_index

**Opcionales (pueden ser NULL):**
- users: deleted_at, email_verified
- schools: address, city, phone, email
- academic_units: parent_unit_id (jerarquía), academic_unit_id
- materials: academic_unit_id, subject, grade, description
- assessment_attempt: completed_at, score, percentage
- assessment_attempt_answer: is_correct, points_earned, student_answer

### Estados y Transiciones

**Material Status:**
```
uploaded ──→ processing ──→ ready ✅
                      ↓
                    failed ❌
```

**Assessment Status:**
```
draft → generated → published → archived
                  → closed
```

**Assessment Attempt Status:**
```
in_progress ──→ completed ✅
         ↓
       abandoned ❌
```

**Progress Status:**
```
not_started → in_progress → completed
```

### Búsquedas Frecuentes

```sql
-- Materiales de un docente
SELECT * FROM materials 
WHERE uploaded_by_teacher_id = $1 AND deleted_at IS NULL;

-- Evaluaciones listas para un estudiante
SELECT a.*, m.title 
FROM assessment a
JOIN materials m ON a.material_id = m.id
WHERE m.school_id = (
  SELECT school_id FROM memberships 
  WHERE user_id = $1 AND is_active = true LIMIT 1
)
AND a.status = 'published';

-- Resultados de un estudiante
SELECT * FROM assessment_attempt
WHERE student_id = $1 AND status = 'completed'
ORDER BY completed_at DESC;

-- Estudiantes en una unidad académica
SELECT u.* FROM users u
JOIN memberships m ON u.id = m.user_id
WHERE m.academic_unit_id = $1 
  AND m.role = 'student'
  AND m.is_active = true;

-- Apoderados de un estudiante
SELECT u.* FROM users u
JOIN guardian_relations gr ON u.id = gr.guardian_id
WHERE gr.student_id = $1 AND gr.is_active = true;

-- Progreso de un usuario en materiales
SELECT p.*, m.title, m.file_type
FROM progress p
JOIN materials m ON p.material_id = m.id
WHERE p.user_id = $1
ORDER BY p.last_accessed_at DESC;
```

### Índices Críticos para Performance

La mayoría ya están creados, pero son críticos:

1. **idx_users_email** - Login, búsqueda
2. **idx_memberships_user** - Determinar roles de usuario
3. **idx_materials_school** - Listar materiales de escuela
4. **idx_assessment_status** - Filtrar evaluaciones listas
5. **idx_attempt_student** - Historial de intentos
6. **idx_progress_user_status** - Dashboard de progreso
7. **idx_academic_units_school** - Jerarquía de escuela

---

## FLUJO DE DATOS

### Flujo 1: Upload de Material y Procesamiento

```
[api-mobile]
    │
    ├─ POST /materials/upload
    │  {file, title, subject, ...}
    │
    ▼
[PostgreSQL]
    INSERT materials (status='uploaded')
    │
    ├─ INSERT into S3 (file)
    │
    ├─ PUBLISH 'material.uploaded' event
    │
    └─▶ id: UUID-material

[RabbitMQ]
    material.uploaded event
    routing_key: 'material.uploaded'
    │
    ├─ Exchange: edugo.topic
    │
    └─▶ Queue: material.processing

[worker]
    ├─ CONSUME material.uploaded
    │
    ├─ Download file from S3
    │
    ├─ Extract text
    │
    ├─ INSERT material_content [MongoDB]
    │
    ├─ Call OpenAI API
    │  ├─ Generate summary
    │  ├─ Generate assessment (8-10 preguntas)
    │
    ├─ INSERT material_summary [MongoDB]
    │
    ├─ INSERT material_assessment [MongoDB]
    │
    ├─ INSERT assessment [PostgreSQL]
    │  status = 'generated'
    │  mongo_document_id = <ObjectId>
    │
    ├─ UPDATE materials
    │  status = 'ready'
    │
    ├─ INSERT audit_logs [MongoDB]
    │
    └─ PUBLISH 'assessment.generated' event

[api-mobile]
    ├─ CONSUME assessment.generated
    │
    ├─ INSERT notifications [MongoDB]
    │  "Tu evaluación está lista"
    │
    └─ Push notification a estudiantes
```

### Flujo 2: Intento de Evaluación

```
[Student via api-mobile]
    │
    ├─ GET /assessments/{assessmentId}
    │  → Obtiene preguntas de MongoDB
    │
    ├─ POST /attempts/start
    │  { assessmentId }
    │
    ▼
[PostgreSQL]
    INSERT assessment_attempt
    (assessment_id, student_id, status='in_progress', started_at=NOW())
    │
    └─▶ return: attemptId: UUID-attempt

[Student answers questions]
    │
    └─ POST /attempts/{attemptId}/answers
       { 
         [
           { questionIndex: 0, selectedOptionIndex: 2, timeSpent: 45 },
           { questionIndex: 1, selectedOptionIndex: 1, timeSpent: 30 },
           ...
         ]
       }

[PostgreSQL]
    INSERT assessment_attempt_answer (múltiples)
    UPDATE assessment_attempt
        completed_at = NOW()
        time_spent_seconds = sum(answers.timeSpent)

[api-mobile calculates]
    ├─ Para cada respuesta: is_correct = check vs MongoDB
    │
    ├─ Calcula score
    │  percentage = (correct_count / total_questions) * 100
    │
    └─ INSERT assessment_attempt_result [MongoDB]
       {
         attempt_id, student_id, assessment_id,
         answers: [ { question_index, is_correct, ... } ],
         score: { correct_count, percentage, ... },
         submitted_at: NOW()
       }

[Opcional: si % >= pass_threshold]
    └─ INSERT notifications [MongoDB]
       "¡Aprobaste la evaluación con 75%!"

[INSERT audit_logs + analytics_events]
```

### Flujo 3: Visualización de Calificaciones

```
[api-mobile]
    │
    ├─ GET /attempts?studentId={id}
    │
    ▼
[PostgreSQL]
    SELECT assessment_attempt WHERE student_id = $1
    │
    └─ For each attempt:
       └─ GET assessment_attempt_result [MongoDB]
          └─ Obtiene respuestas y detalles

[Retorna a app]
    {
      attempts: [
        {
          id: UUID-attempt-1,
          assessment: { title, material: { title } },
          startedAt, completedAt,
          score: 75%, percentage: 75,
          status: 'completed'
        },
        ...
      ]
    }
```

---

## RESUMEN DE PATRONES DE DISEÑO

### Patrón 1: Soft Delete

Todas las tablas usan soft delete:
```sql
deleted_at TIMESTAMP NULL DEFAULT NULL
```

**Búsqueda siempre incluye:**
```sql
WHERE deleted_at IS NULL
```

### Patrón 2: Jerarquía Flexible

`academic_units` soporta jerarquía con:
- `parent_unit_id` (auto-referencia)
- Función trigger para prevenir ciclos
- Vista `v_academic_unit_tree` con CTE recursivo

### Patrón 3: Metadata JSONB

Campos `metadata JSONB` en:
- schools (logo, configuración)
- academic_units (extensibilidad)
- memberships (permisos específicos)

### Patrón 4: Enum CHECK

Estados manejan con CHECK constraints:
```sql
CHECK (status IN ('value1', 'value2', ...))
```

### Patrón 5: Timestamps Auditables

Todas las tablas tienen:
- `created_at TIMESTAMP NOT NULL DEFAULT NOW()`
- `updated_at TIMESTAMP NOT NULL DEFAULT NOW()`
- `deleted_at TIMESTAMP NULL` (soft delete)

### Patrón 6: Asincronía con RabbitMQ

Operaciones de larga duración (procesamiento IA):
1. API publica evento
2. Worker consume y procesa
3. Worker publica evento de finalización
4. API consume y notifica usuario

### Patrón 7: PostgreSQL + MongoDB

**PostgreSQL:** Datos relacionales críticos (usuarios, jerarquía, auditoría)
**MongoDB:** Documentos flexibles grandes (evaluaciones, resúmenes, logs)

```
┌─ PostgreSQL: Estructura rígida
│  ├─ Assessment (referencia)
│  └─ Assessment_Attempt (registro del intento)
│
└─ MongoDB: Contenido flexible
   ├─ material_assessment (preguntas + opciones)
   └─ assessment_attempt_result (respuestas + análisis)
```

---

**Documento Finalizado:** 1 de Diciembre, 2025
**Versión:** 1.0
**Última revisión:** Análisis completo de estructura EduGo

