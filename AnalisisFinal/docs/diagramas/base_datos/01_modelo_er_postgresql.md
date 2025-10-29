# Modelo Entidad-Relación PostgreSQL - EduGo

## Descripción
Modelo de datos relacional completo para EduGo, incluyendo usuarios, jerarquía académica, materiales educativos, progreso y evaluaciones.

## Diagrama ER Completo

```mermaid
erDiagram
    APP_USER {
        uuid id PK
        varchar name
        varchar email UK
        varchar password_hash
        varchar system_role "admin|teacher|student|guardian"
        varchar status "active|inactive|suspended"
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at "soft delete"
    }

    TEACHER_PROFILE {
        uuid user_id PK_FK
        varchar specialization
        varchar preferred_language "es|en"
        jsonb preferences
        timestamptz created_at
    }

    STUDENT_PROFILE {
        uuid user_id PK_FK
        varchar current_grade
        varchar student_code UK
        jsonb extra_data
        timestamptz created_at
    }

    GUARDIAN_PROFILE {
        uuid user_id PK_FK
        varchar occupation
        varchar alternate_contact
        jsonb extra_data
        timestamptz created_at
    }

    GUARDIAN_STUDENT_RELATION {
        uuid id PK
        uuid guardian_id FK
        uuid student_id FK
        varchar relationship_type "parent|legal_guardian|tutor"
        varchar status "active|inactive"
        timestamptz created_at
        timestamptz updated_at
    }

    SCHOOL {
        uuid id PK
        varchar name
        varchar code UK
        text address
        varchar contact_email
        varchar contact_phone
        jsonb metadata
        timestamptz created_at
        timestamptz updated_at
    }

    ACADEMIC_UNIT {
        uuid id PK
        uuid parent_unit_id FK "NULL para root"
        uuid school_id FK
        varchar unit_type "school|grade|section|club|department"
        varchar display_name
        varchar code
        text description
        jsonb metadata
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    UNIT_MEMBERSHIP {
        uuid id PK
        uuid unit_id FK
        uuid user_id FK
        varchar role "owner|teacher|assistant|student|guardian"
        date valid_from
        date valid_until
        timestamptz created_at
        timestamptz updated_at
    }

    SUBJECT {
        uuid id PK
        uuid school_id FK
        varchar name
        text description
        varchar code UK
        jsonb metadata
        timestamptz created_at
    }

    LEARNING_MATERIAL {
        uuid id PK
        uuid author_id FK
        uuid subject_id FK
        varchar title
        text description
        varchar status "draft|published|archived"
        jsonb metadata
        timestamptz published_at
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
        uuid deleted_by FK "admin que eliminó"
    }

    MATERIAL_VERSION {
        uuid id PK
        uuid material_id FK
        varchar s3_key
        varchar file_hash UK
        bigint file_size
        varchar version_number
        jsonb processing_metadata
        timestamptz created_at
    }

    MATERIAL_UNIT_LINK {
        uuid id PK
        uuid material_id FK
        uuid unit_id FK
        timestamptz assigned_at
    }

    READING_LOG {
        uuid id PK
        uuid material_id FK
        uuid student_id FK
        decimal progress "0.00-100.00"
        integer time_spent "seconds"
        integer last_page
        timestamptz last_access_at
        timestamptz created_at
        timestamptz updated_at
    }

    MATERIAL_SUMMARY_LINK {
        uuid id PK
        uuid material_id FK UK
        varchar mongo_document_id
        varchar status "processing|completed|failed"
        timestamptz created_at
        timestamptz updated_at
    }

    ASSESSMENT {
        uuid id PK
        uuid material_id FK
        varchar mongo_document_id
        varchar title
        integer total_questions
        timestamptz created_at
    }

    ASSESSMENT_ATTEMPT {
        uuid id PK
        uuid assessment_id FK
        uuid student_id FK
        decimal score "0.00-100.00"
        decimal max_score "100.00"
        integer time_spent_seconds
        timestamptz started_at
        timestamptz completed_at
        timestamptz created_at
    }

    ASSESSMENT_ATTEMPT_ANSWER {
        uuid id PK
        uuid attempt_id FK
        varchar question_id
        varchar selected_option
        boolean is_correct
        timestamptz created_at
    }

    AUDIT_LOG {
        uuid id PK
        uuid admin_user_id FK
        varchar action "create|update|delete"
        varchar entity_type
        uuid entity_id
        jsonb changes
        inet ip_address
        text user_agent
        timestamptz created_at
    }

    %% Relaciones: Usuario y Perfiles
    APP_USER ||--o| TEACHER_PROFILE : "1:1"
    APP_USER ||--o| STUDENT_PROFILE : "1:1"
    APP_USER ||--o| GUARDIAN_PROFILE : "1:1"

    %% Relaciones: Tutores-Estudiantes
    GUARDIAN_PROFILE ||--o{ GUARDIAN_STUDENT_RELATION : "guardian_id"
    STUDENT_PROFILE ||--o{ GUARDIAN_STUDENT_RELATION : "student_id"

    %% Relaciones: Jerarquía Académica
    SCHOOL ||--o{ ACADEMIC_UNIT : "school_id"
    ACADEMIC_UNIT ||--o{ ACADEMIC_UNIT : "parent_unit_id (recursivo)"

    %% Relaciones: Membresías
    ACADEMIC_UNIT ||--o{ UNIT_MEMBERSHIP : "unit_id"
    APP_USER ||--o{ UNIT_MEMBERSHIP : "user_id"

    %% Relaciones: Materias y Materiales
    SCHOOL ||--o{ SUBJECT : "school_id"
    SUBJECT ||--o{ LEARNING_MATERIAL : "subject_id"
    APP_USER ||--o{ LEARNING_MATERIAL : "author_id"

    %% Relaciones: Versiones y Asignaciones
    LEARNING_MATERIAL ||--o{ MATERIAL_VERSION : "material_id"
    LEARNING_MATERIAL ||--o{ MATERIAL_UNIT_LINK : "material_id"
    ACADEMIC_UNIT ||--o{ MATERIAL_UNIT_LINK : "unit_id"

    %% Relaciones: Progreso y Resumen
    LEARNING_MATERIAL ||--o{ READING_LOG : "material_id"
    APP_USER ||--o{ READING_LOG : "student_id"
    LEARNING_MATERIAL ||--o| MATERIAL_SUMMARY_LINK : "material_id"

    %% Relaciones: Evaluaciones
    LEARNING_MATERIAL ||--o| ASSESSMENT : "material_id"
    ASSESSMENT ||--o{ ASSESSMENT_ATTEMPT : "assessment_id"
    APP_USER ||--o{ ASSESSMENT_ATTEMPT : "student_id"
    ASSESSMENT_ATTEMPT ||--o{ ASSESSMENT_ATTEMPT_ANSWER : "attempt_id"

    %% Relaciones: Auditoría
    APP_USER ||--o{ AUDIT_LOG : "admin_user_id"
    APP_USER ||--o{ LEARNING_MATERIAL : "deleted_by"
```

## Descripción Detallada de Tablas

### 1. Usuarios y Perfiles

#### `app_user`
**Propósito**: Tabla principal de autenticación y datos comunes de todos los usuarios.

**Campos clave**:
- `id`: UUID v7 (incluye timestamp para orden cronológico)
- `email`: Único en el sistema, usado para login
- `password_hash`: bcrypt con cost 12
- `system_role`: Define permisos globales
- `deleted_at`: Soft delete (NULL = activo)

**Constraints**:
```sql
UNIQUE (email);
CHECK (system_role IN ('admin', 'teacher', 'student', 'guardian'));
CHECK (status IN ('active', 'inactive', 'suspended'));
```

---

#### `teacher_profile`
**Propósito**: Datos específicos de docentes.

**Relación**: 1:1 con `app_user` donde `system_role = 'teacher'`

**Campos clave**:
- `specialization`: Área de especialidad (ej: "Matemáticas", "Programación")
- `preferred_language`: Idioma por defecto para contenido generado
- `preferences`: JSONB con configuraciones personales

---

#### `student_profile`
**Propósito**: Datos específicos de estudiantes.

**Relación**: 1:1 con `app_user` donde `system_role = 'student'`

**Campos clave**:
- `current_grade`: Grado actual (ej: "5º", "Preparatoria 2")
- `student_code`: Código único del estudiante (matrícula)
- `extra_data`: JSONB para datos adicionales (fecha nacimiento, etc.)

---

#### `guardian_profile`
**Propósito**: Datos específicos de tutores/padres.

**Relación**: 1:1 con `app_user` donde `system_role = 'guardian'`

**Campos clave**:
- `occupation`: Profesión del tutor
- `alternate_contact`: Teléfono/email alternativo

---

#### `guardian_student_relation`
**Propósito**: Vínculo N:M entre tutores y estudiantes.

**Casos de uso**:
- Un estudiante puede tener múltiples tutores (madre, padre, abuelo)
- Un tutor puede tener múltiples estudiantes (hermanos)

**Campos clave**:
- `relationship_type`: Tipo de relación (padre, tutor legal, etc.)
- `status`: Permite desactivar relaciones sin eliminarlas

**Constraints**:
```sql
FOREIGN KEY (guardian_id) REFERENCES app_user(id);
FOREIGN KEY (student_id) REFERENCES app_user(id);
CHECK (relationship_type IN ('parent', 'legal_guardian', 'tutor', 'other'));
UNIQUE (guardian_id, student_id); -- Prevenir duplicados
```

---

### 2. Jerarquía Académica

#### `school`
**Propósito**: Organizaciones educativas (colegios, academias).

**Campos clave**:
- `code`: Código único de la escuela (ej: "CSJ", "ACAD-MAT")
- `contact_email`: Email oficial del colegio
- `metadata`: JSONB con datos adicionales (logo URL, horarios, etc.)

---

#### `academic_unit`
**Propósito**: Estructura jerárquica flexible (años, secciones, clubes, departamentos).

**Jerarquía típica**:
```
School (root)
└── Grade (5.º Año)
    └── Section (Sección A)
        └── Club (Club de Programación)
```

**Campos clave**:
- `parent_unit_id`: NULL para unidades raíz, UUID de padre para subunidades
- `unit_type`: Tipo de unidad en la jerarquía
- `display_name`: Nombre visible (ej: "5.º A - Programación")
- `code`: Código corto (ej: "5A")

**Constraints**:
```sql
FOREIGN KEY (parent_unit_id) REFERENCES academic_unit(id);
FOREIGN KEY (school_id) REFERENCES school(id);
CHECK (unit_type IN ('school', 'grade', 'section', 'club', 'department'));
```

**Trigger para prevenir ciclos**:
```sql
CREATE OR REPLACE FUNCTION prevent_circular_hierarchy()
RETURNS TRIGGER AS $$
DECLARE
    ancestor_id UUID;
BEGIN
    ancestor_id := NEW.parent_unit_id;
    WHILE ancestor_id IS NOT NULL LOOP
        IF ancestor_id = NEW.id THEN
            RAISE EXCEPTION 'Jerarquía circular detectada';
        END IF;
        SELECT parent_unit_id INTO ancestor_id
        FROM academic_unit WHERE id = ancestor_id;
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_circular_hierarchy
BEFORE INSERT OR UPDATE ON academic_unit
FOR EACH ROW EXECUTE FUNCTION prevent_circular_hierarchy();
```

**Consulta jerárquica (CTE recursivo)**:
```sql
WITH RECURSIVE unit_tree AS (
    -- Base: unidad raíz
    SELECT id, parent_unit_id, display_name, 1 as level
    FROM academic_unit
    WHERE id = $1

    UNION ALL

    -- Recursión: hijos
    SELECT au.id, au.parent_unit_id, au.display_name, ut.level + 1
    FROM academic_unit au
    INNER JOIN unit_tree ut ON au.parent_unit_id = ut.id
)
SELECT * FROM unit_tree ORDER BY level, display_name;
```

---

#### `unit_membership`
**Propósito**: Asignación de usuarios a unidades académicas con roles específicos.

**Casos de uso**:
- Docente es `owner` de "5.º A - Programación"
- Estudiante es `student` de "5.º A - Programación"
- Tutor es `guardian` de la misma unidad (para ver progreso)

**Campos clave**:
- `role`: Rol del usuario en esta unidad específica
- `valid_from` / `valid_until`: Vigencia de la membresía (ej: año escolar)

**Constraints**:
```sql
UNIQUE (unit_id, user_id); -- Un usuario, un rol por unidad
CHECK (role IN ('owner', 'teacher', 'assistant', 'student', 'guardian'));
```

---

### 3. Materiales Educativos

#### `subject`
**Propósito**: Catálogo de materias por escuela.

**Ejemplos**:
- Matemáticas, Programación, Historia, Física

**Campos clave**:
- `school_id`: Permite que cada escuela tenga su propio catálogo
- `code`: Código único (ej: "MAT-001", "PROG-101")

---

#### `learning_material`
**Propósito**: Registro de materiales educativos (PDFs, videos, etc.).

**Campos clave**:
- `author_id`: Docente que creó el material
- `subject_id`: Materia a la que pertenece
- `status`: Estado del material (borrador, publicado, archivado)
- `published_at`: Timestamp de cuándo se publicó
- `deleted_at`: Soft delete
- `deleted_by`: Admin que eliminó el material (auditoría)

**Metadata JSONB**:
```json
{
  "level": "intermediate",
  "keywords": ["compilador", "pascal", "historia"],
  "estimated_reading_time_minutes": 45
}
```

---

#### `material_version`
**Propósito**: Historial de versiones de un material.

**Casos de uso**:
- Docente sube nueva versión de PDF
- Se conserva histórico para auditoría
- Deduplicación por `file_hash`

**Campos clave**:
- `s3_key`: Ruta completa en S3
- `file_hash`: SHA-256 del archivo
- `file_size`: Tamaño en bytes
- `version_number`: Secuencial (v1, v2, v3...)

**Deduplicación**:
```sql
-- Antes de procesar, verificar si hash ya existe
SELECT id, material_id FROM material_version
WHERE file_hash = $1 AND material_id != $2;
-- Si existe, reutilizar procesamiento
```

---

#### `material_unit_link`
**Propósito**: Asignación N:M de materiales a unidades.

**Casos de uso**:
- Un material puede asignarse a múltiples secciones ("5.º A" y "5.º B")
- Una unidad tiene múltiples materiales

**Sin duplicación**: El mismo material se referencia, no se copia.

---

### 4. Progreso y Tracking

#### `reading_log`
**Propósito**: Registro de progreso de lectura de cada estudiante por material.

**Campos clave**:
- `progress`: Porcentaje (0.00 - 100.00)
- `time_spent`: Segundos totales invertidos
- `last_page`: Última página visitada
- `last_access_at`: Timestamp del último acceso

**Upsert pattern**:
```sql
INSERT INTO reading_log (material_id, student_id, progress, time_spent, last_page, last_access_at)
VALUES ($1, $2, $3, $4, $5, NOW())
ON CONFLICT (material_id, student_id)
DO UPDATE SET
  progress = GREATEST(reading_log.progress, EXCLUDED.progress),
  time_spent = reading_log.time_spent + EXCLUDED.time_spent,
  last_page = EXCLUDED.last_page,
  last_access_at = NOW();
```

**Constraints**:
```sql
UNIQUE (material_id, student_id);
CHECK (progress >= 0 AND progress <= 100);
CHECK (time_spent >= 0);
```

---

### 5. Resúmenes (Enlace a MongoDB)

#### `material_summary_link`
**Propósito**: Enlace entre material (PostgreSQL) y resumen (MongoDB).

**Campos clave**:
- `material_id`: Único (un material, un resumen)
- `mongo_document_id`: ObjectId del documento en MongoDB
- `status`: Estado del procesamiento

**Estados**:
- `processing`: Worker generando resumen
- `completed`: Resumen disponible
- `failed`: Error en generación

**Constraints**:
```sql
UNIQUE (material_id);
CHECK (status IN ('processing', 'completed', 'failed'));
```

---

### 6. Evaluaciones

#### `assessment`
**Propósito**: Metadatos de evaluaciones (quiz), preguntas en MongoDB.

**Campos clave**:
- `material_id`: Material al que pertenece el quiz
- `mongo_document_id`: ObjectId del documento con preguntas en MongoDB
- `total_questions`: Número de preguntas (desnormalizado para rendimiento)

---

#### `assessment_attempt`
**Propósito**: Registro de cada intento de un estudiante en un quiz.

**Campos clave**:
- `score`: Puntaje obtenido (0.00 - 100.00)
- `max_score`: Puntaje máximo posible (siempre 100.00)
- `time_spent_seconds`: Tiempo que tomó completar
- `started_at`: Calculado como `completed_at - time_spent_seconds`
- `completed_at`: Timestamp de envío

**Constraints**:
```sql
CHECK (score >= 0 AND score <= max_score);
CHECK (time_spent_seconds >= 0);
```

**Mejor intento por estudiante**:
```sql
SELECT DISTINCT ON (student_id)
    student_id, score, completed_at
FROM assessment_attempt
WHERE assessment_id = $1
ORDER BY student_id, score DESC, completed_at DESC;
```

---

#### `assessment_attempt_answer`
**Propósito**: Detalle de cada respuesta individual en un intento.

**Campos clave**:
- `question_id`: ID de la pregunta (del documento MongoDB)
- `selected_option`: Opción seleccionada (ej: "a", "b", "c", "d")
- `is_correct`: Resultado de la validación

**Inmutabilidad**: Esta tabla NO se puede editar tras inserción (auditoría).

---

### 7. Auditoría

#### `audit_log`
**Propósito**: Registro de todas las operaciones administrativas.

**Campos clave**:
- `admin_user_id`: Admin que realizó la acción
- `action`: Tipo de operación
- `entity_type`: Qué se modificó (user, material, unit)
- `entity_id`: ID de la entidad afectada
- `changes`: JSONB con before/after
- `ip_address`: IP del admin
- `user_agent`: Navegador/app usada

**Ejemplo de `changes`**:
```json
{
  "before": {"name": "Juan Pérez", "role": "student"},
  "after": {"name": "Juan Pérez", "role": "teacher"}
}
```

**Inmutabilidad**: Esta tabla SOLO permite INSERT, nunca UPDATE o DELETE.

---

## Índices Principales

### Índices por Performance

```sql
-- Usuarios: Búsqueda por email (login)
CREATE UNIQUE INDEX idx_app_user_email ON app_user(email);

-- Usuarios activos (filtro común)
CREATE INDEX idx_app_user_active ON app_user(id) WHERE deleted_at IS NULL;

-- Membresías por unidad y rol
CREATE INDEX idx_unit_membership_unit_role ON unit_membership(unit_id, role);

-- Materiales por autor y estado
CREATE INDEX idx_learning_material_author_status ON learning_material(author_id, status) WHERE deleted_at IS NULL;

-- Materiales por unidad (consulta frecuente)
CREATE INDEX idx_material_unit_link_unit ON material_unit_link(unit_id, material_id);

-- Progreso de lectura por estudiante
CREATE INDEX idx_reading_log_student ON reading_log(student_id, last_access_at DESC);

-- Progreso de lectura por material
CREATE INDEX idx_reading_log_material ON reading_log(material_id, student_id);

-- Intentos de evaluación (mejor puntaje)
CREATE INDEX idx_assessment_attempt_student_score ON assessment_attempt(student_id, assessment_id, score DESC, completed_at DESC);

-- Versiones de material por hash (deduplicación)
CREATE UNIQUE INDEX idx_material_version_hash ON material_version(file_hash);
```

### Índices JSONB (GIN)

```sql
-- Metadata de materiales
CREATE INDEX idx_learning_material_metadata ON learning_material USING GIN (metadata);

-- Preferencias de docentes
CREATE INDEX idx_teacher_profile_preferences ON teacher_profile USING GIN (preferences);

-- Cambios en auditoría
CREATE INDEX idx_audit_log_changes ON audit_log USING GIN (changes);
```

---

## Triggers y Funciones

### Auto-actualización de Timestamps

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_app_user_updated_at
BEFORE UPDATE ON app_user
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_learning_material_updated_at
BEFORE UPDATE ON learning_material
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### Validación de Jerarquía Circular

*(Ver sección de `academic_unit` arriba)*

---

## Vistas Útiles

### Vista: Usuarios con Perfiles

```sql
CREATE VIEW v_user_profiles AS
SELECT
    u.id,
    u.name,
    u.email,
    u.system_role,
    u.status,
    tp.specialization as teacher_specialization,
    sp.student_code,
    sp.current_grade,
    gp.occupation as guardian_occupation
FROM app_user u
LEFT JOIN teacher_profile tp ON u.id = tp.user_id
LEFT JOIN student_profile sp ON u.id = sp.user_id
LEFT JOIN guardian_profile gp ON u.id = gp.user_id
WHERE u.deleted_at IS NULL;
```

### Vista: Materiales con Información Completa

```sql
CREATE VIEW v_learning_materials_full AS
SELECT
    m.id,
    m.title,
    m.description,
    m.status,
    u.name as author_name,
    s.name as subject_name,
    sc.name as school_name,
    m.published_at,
    sl.status as summary_status,
    CASE WHEN a.id IS NOT NULL THEN true ELSE false END as has_quiz
FROM learning_material m
INNER JOIN app_user u ON m.author_id = u.id
INNER JOIN subject s ON m.subject_id = s.id
INNER JOIN school sc ON s.school_id = sc.id
LEFT JOIN material_summary_link sl ON m.id = sl.material_id
LEFT JOIN assessment a ON m.id = a.material_id
WHERE m.deleted_at IS NULL;
```

### Vista: Membresías Activas

```sql
CREATE VIEW v_active_memberships AS
SELECT
    um.id,
    u.name as user_name,
    u.email,
    au.display_name as unit_name,
    au.unit_type,
    um.role,
    um.valid_from,
    um.valid_until
FROM unit_membership um
INNER JOIN app_user u ON um.user_id = u.id
INNER JOIN academic_unit au ON um.unit_id = au.id
WHERE (um.valid_until IS NULL OR um.valid_until >= CURRENT_DATE)
  AND u.deleted_at IS NULL
  AND au.deleted_at IS NULL;
```

---

## Estadísticas y Mantenimiento

### Análisis de Tablas

```sql
ANALYZE app_user;
ANALYZE learning_material;
ANALYZE reading_log;
ANALYZE assessment_attempt;
```

### Vacuum Regular

```sql
VACUUM ANALYZE app_user;
VACUUM ANALYZE learning_material;
```

---

**Documento**: Modelo ER PostgreSQL de EduGo
**Versión**: 1.0
**Fecha**: 2025-01-29
**Autor**: Equipo EduGo
**Total de Tablas**: 17
