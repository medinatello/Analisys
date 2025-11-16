# 🗄️ Modelo de Datos - Ecosistema EduGo

**Fecha:** 16 de Noviembre, 2025  
**Versión:** 2.0.0

---

## 🎯 Visión General

El ecosistema EduGo utiliza un modelo de datos híbrido:
- **PostgreSQL 15:** Datos relacionales y transaccionales
- **MongoDB 7.0:** Contenido generado por IA (documentos complejos)

**Fuente de verdad:** `infrastructure/database/TABLE_OWNERSHIP.md`

---

## 📊 PostgreSQL - Modelo Relacional

### Ownership de Tablas

| Tabla | Owner | Descripción | Migraciones |
|-------|-------|-------------|-------------|
| users | api-admin | Usuarios del sistema | 001 |
| schools | api-admin | Escuelas | 002 |
| academic_units | api-admin | Unidades académicas (jerarquía) | 003 |
| unit_membership | api-admin | Membresías en unidades | 004 |
| materials | api-mobile | Materiales educativos | 005 |
| assessment | api-mobile | Evaluaciones (ref a MongoDB) | 006 |
| assessment_attempt | api-mobile | Intentos de evaluación | 007 |
| assessment_answer | api-mobile | Respuestas de estudiantes | 008 |

**Orden de migraciones:** 001 → 002 → 003 → 004 → 005 → 006 → 007 → 008

---

## 📋 Esquemas Detallados

### 1. users (Owner: api-admin)

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'teacher', 'student')),
    school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_school ON users(school_id);
CREATE INDEX idx_users_role ON users(role);
```

**Campos clave:**
- `role`: admin (administrador), teacher (docente), student (estudiante)
- `school_id`: Relación con escuela (puede ser NULL para admins globales)
- `is_active`: Soft delete

**Acceso:**
- Owner: api-admin (CRUD completo)
- Reader: api-mobile (solo lectura para validaciones)

---

### 2. schools (Owner: api-admin)

```sql
CREATE TABLE schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    address TEXT,
    phone VARCHAR(50),
    email VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_schools_slug ON schools(slug);
CREATE INDEX idx_schools_active ON schools(is_active);
```

**Campos clave:**
- `slug`: Identificador único amigable (ej: "colegio-san-jose")
- `is_active`: Habilita/deshabilita escuela

**Acceso:**
- Owner: api-admin (CRUD completo)
- Reader: api-mobile (para filtrar por escuela)

---

### 3. academic_units (Owner: api-admin)

```sql
CREATE TABLE academic_units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES academic_units(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    unit_type VARCHAR(50) NOT NULL CHECK (unit_type IN ('school', 'grade', 'section', 'subject')),
    level INTEGER NOT NULL DEFAULT 0,
    path TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(school_id, parent_id, name)
);

CREATE INDEX idx_academic_units_school ON academic_units(school_id);
CREATE INDEX idx_academic_units_parent ON academic_units(parent_id);
CREATE INDEX idx_academic_units_type ON academic_units(unit_type);
CREATE INDEX idx_academic_units_path ON academic_units USING GIN(path gin_trgm_ops);
```

**Campos clave:**
- `parent_id`: Jerarquía de unidades (NULL para raíz)
- `unit_type`: Tipo de unidad (school, grade, section, subject)
- `level`: Profundidad en el árbol (0 = raíz)
- `path`: Ruta completa en formato materialized path (/1/2/3)
- `metadata`: Datos adicionales específicos del tipo

**Jerarquía ejemplo:**
```
School (level 0, path: /1)
  └─ Grade 10 (level 1, path: /1/2)
      └─ Section A (level 2, path: /1/2/3)
          └─ Mathematics (level 3, path: /1/2/3/4)
```

**Acceso:**
- Owner: api-admin (CRUD completo)
- Reader: api-mobile (para filtrar materiales)

---

### 4. unit_membership (Owner: api-admin)

```sql
CREATE TABLE unit_membership (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES academic_units(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL CHECK (role IN ('teacher', 'student')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, unit_id, role)
);

CREATE INDEX idx_memberships_user ON unit_membership(user_id);
CREATE INDEX idx_memberships_unit ON unit_membership(unit_id);
CREATE INDEX idx_memberships_role ON unit_membership(role);
```

**Campos clave:**
- `user_id`: Usuario miembro
- `unit_id`: Unidad académica
- `role`: Rol en la unidad (teacher o student)

**Casos de uso:**
- Estudiante matriculado en "Mathematics"
- Profesor asignado a "Grade 10"

**Acceso:**
- Owner: api-admin (CRUD completo)
- Reader: api-mobile (para filtrar contenido por membresía)

---

### 5. materials (Owner: api-mobile)

```sql
CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    unit_id UUID NOT NULL REFERENCES academic_units(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    processing_status VARCHAR(50) DEFAULT 'pending' CHECK (
        processing_status IN ('pending', 'processing', 'completed', 'failed')
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_materials_unit ON materials(unit_id);
CREATE INDEX idx_materials_teacher ON materials(teacher_id);
CREATE INDEX idx_materials_status ON materials(processing_status);
CREATE INDEX idx_materials_created ON materials(created_at DESC);
```

**Campos clave:**
- `unit_id`: Unidad académica a la que pertenece
- `teacher_id`: Docente que subió el material
- `file_url`: URL del archivo en S3/storage
- `processing_status`: Estado del procesamiento por worker

**Flujo de estados:**
```
pending → processing → completed
              ↓
            failed
```

**Acceso:**
- Owner: api-mobile (CRUD completo)
- Reader: worker (para procesar archivos)

---

### 6. assessment (Owner: api-mobile)

```sql
CREATE TABLE assessment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    mongo_document_id VARCHAR(24),
    title VARCHAR(255) NOT NULL,
    passing_score INTEGER NOT NULL DEFAULT 70,
    time_limit_minutes INTEGER,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(material_id)
);

CREATE INDEX idx_assessment_material ON assessment(material_id);
CREATE INDEX idx_assessment_mongo ON assessment(mongo_document_id);
CREATE INDEX idx_assessment_published ON assessment(is_published);
```

**Campos clave:**
- `material_id`: Material del que se generó el assessment
- `mongo_document_id`: **Referencia a MongoDB** (ObjectId como string)
- `passing_score`: Puntaje mínimo para aprobar (0-100)
- `time_limit_minutes`: Límite de tiempo (NULL = sin límite)
- `is_published`: Si está disponible para estudiantes

**Sincronización con MongoDB:**
1. Worker crea documento en MongoDB (material_assessment)
2. Worker publica evento `assessment.generated` con `mongo_document_id`
3. api-mobile consume evento
4. api-mobile crea registro en PostgreSQL con `mongo_document_id`

**Acceso:**
- Owner: api-mobile (CRUD completo)
- Writer: worker (vía evento, actualiza mongo_document_id)

---

### 7. assessment_attempt (Owner: api-mobile)

```sql
CREATE TABLE assessment_attempt (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL REFERENCES assessment(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER,
    max_score INTEGER NOT NULL,
    passed BOOLEAN,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    time_spent_seconds INTEGER
);

CREATE INDEX idx_attempts_assessment ON assessment_attempt(assessment_id);
CREATE INDEX idx_attempts_student ON assessment_attempt(student_id);
CREATE INDEX idx_attempts_completed ON assessment_attempt(completed_at);
```

**Campos clave:**
- `assessment_id`: Assessment que se está intentando
- `student_id`: Estudiante que realiza el intento
- `score`: Puntaje obtenido (NULL si no completado)
- `max_score`: Puntaje máximo posible
- `passed`: Si aprobó o no (calculado: score >= assessment.passing_score)
- `completed_at`: NULL mientras está en progreso

**Flujo:**
1. Estudiante inicia: `started_at = NOW(), completed_at = NULL`
2. Estudiante responde preguntas (se guardan en assessment_answer)
3. Estudiante completa: `completed_at = NOW(), score = calculado, passed = calculado`

**Acceso:**
- Owner: api-mobile (CRUD completo)

---

### 8. assessment_answer (Owner: api-mobile)

```sql
CREATE TABLE assessment_answer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES assessment_attempt(id) ON DELETE CASCADE,
    question_id VARCHAR(100) NOT NULL,
    answer_value TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL,
    points_earned INTEGER NOT NULL DEFAULT 0,
    answered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_answers_attempt ON assessment_answer(attempt_id);
CREATE INDEX idx_answers_question ON assessment_answer(question_id);
```

**Campos clave:**
- `attempt_id`: Intento al que pertenece la respuesta
- `question_id`: ID de la pregunta (referencia a MongoDB)
- `answer_value`: Respuesta del estudiante (texto o ID de opción)
- `is_correct`: Si la respuesta es correcta (evaluado con shared/evaluation)
- `points_earned`: Puntos ganados por esta respuesta

**Acceso:**
- Owner: api-mobile (CRUD completo)

---

## 🗂️ MongoDB - Modelo de Documentos

### Colecciones

| Colección | Owner | Descripción |
|-----------|-------|-------------|
| material_summary | worker | Resúmenes de materiales generados por IA |
| material_assessment | worker | Quizzes/evaluaciones generadas por IA |
| material_event | worker | Log de eventos de procesamiento |

---

### 1. material_summary

**Owner:** worker  
**Schema:** Flexible (NoSQL)

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "material_id": "uuid-from-postgresql",
  "summary": {
    "short": "Resumen de 1-2 párrafos...",
    "detailed": "Resumen extenso con puntos clave...",
    "key_points": [
      "Punto clave 1",
      "Punto clave 2"
    ],
    "topics_covered": ["Tema 1", "Tema 2"]
  },
  "metadata": {
    "word_count": 1500,
    "estimated_reading_time_minutes": 5,
    "difficulty_level": "intermediate",
    "language": "es"
  },
  "generated_at": ISODate("2025-11-15T10:30:00Z"),
  "model_version": "gpt-4-turbo",
  "processing_time_seconds": 12.5
}
```

**Campos clave:**
- `material_id`: Referencia a PostgreSQL materials.id
- `summary`: Objeto con diferentes niveles de detalle
- `metadata`: Información sobre el contenido
- `model_version`: Versión del modelo de IA usado

**Acceso:**
- Owner: worker (INSERT completo)
- Reader: api-mobile (READ para mostrar a usuarios)

---

### 2. material_assessment

**Owner:** worker  
**Schema:** Validado con shared/evaluation

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439012"),
  "material_id": "uuid-from-postgresql",
  "title": "Quiz sobre Física Cuántica",
  "description": "Evalúa tu comprensión de los conceptos básicos",
  "passing_score": 70,
  "time_limit_minutes": 30,
  "questions": [
    {
      "id": "q1",
      "type": "multiple_choice",
      "question_text": "¿Qué es el principio de incertidumbre?",
      "points": 10,
      "options": [
        {
          "id": "opt1",
          "text": "No se puede medir posición y velocidad simultáneamente",
          "is_correct": true
        },
        {
          "id": "opt2",
          "text": "La energía no puede crearse ni destruirse",
          "is_correct": false
        }
      ],
      "explanation": "El principio de Heisenberg establece que..."
    },
    {
      "id": "q2",
      "type": "true_false",
      "question_text": "Los electrones tienen carga positiva",
      "points": 5,
      "correct_answer": false,
      "explanation": "Los electrones tienen carga negativa"
    }
  ],
  "total_points": 100,
  "generated_at": ISODate("2025-11-15T10:35:00Z"),
  "model_version": "gpt-4-turbo"
}
```

**Campos clave:**
- `material_id`: Referencia a PostgreSQL materials.id
- `questions`: Array de preguntas (validado con shared/evaluation)
- `total_points`: Suma de puntos de todas las preguntas

**Tipos de pregunta soportados:**
- `multiple_choice`: Opción múltiple
- `true_false`: Verdadero/Falso
- `short_answer`: Respuesta corta

**Acceso:**
- Owner: worker (INSERT completo)
- Reader: api-mobile (READ para mostrar quizzes)

---

### 3. material_event

**Owner:** worker  
**Schema:** Flexible

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439013"),
  "material_id": "uuid-from-postgresql",
  "event_type": "processing_started",
  "status": "success",
  "message": "Procesamiento de PDF iniciado",
  "metadata": {
    "file_size_bytes": 2048000,
    "pages": 15
  },
  "occurred_at": ISODate("2025-11-15T10:30:00Z")
}
```

**Tipos de evento:**
- `processing_started`: Inicio de procesamiento
- `processing_completed`: Procesamiento exitoso
- `processing_failed`: Error en procesamiento
- `summary_generated`: Resumen creado
- `assessment_generated`: Quiz creado

**Acceso:**
- Owner: worker (INSERT completo)
- Reader: worker (para debugging)

---

## 🔄 Sincronización PostgreSQL ↔ MongoDB

### Patrón: MongoDB Primero + Eventual Consistency

**Flujo para assessment:**

```
1. Worker procesa material
   ↓
2. Worker genera assessment en MongoDB
   collection: material_assessment
   → Obtiene ObjectId: "507f1f77bcf86cd799439012"
   ↓
3. Worker publica evento: assessment.generated
   payload: {
     material_id: "uuid-postgres",
     mongo_document_id: "507f1f77bcf86cd799439012",
     title: "Quiz sobre Física Cuántica"
   }
   ↓
4. api-mobile consume evento
   ↓
5. api-mobile crea registro en PostgreSQL
   INSERT INTO assessment (
     material_id,
     mongo_document_id,
     title,
     passing_score
   )
   ↓
6. Si PostgreSQL falla:
   → Retry 3x (DLQ de shared/messaging/rabbit)
   → Dead Letter Queue captura evento
```

**Manejo de inconsistencias:**

```go
// api-mobile valida sincronización
func (s *AssessmentService) Get(id uuid.UUID) (*Assessment, error) {
    // 1. Buscar en PostgreSQL
    pgRecord := s.pgRepo.Get(id)
    if pgRecord == nil {
        return nil, ErrNotFound
    }

    // 2. Validar que MongoDB existe
    mongoDoc := s.mongoRepo.Get(pgRecord.MongoDocumentID)
    if mongoDoc == nil {
        // Inconsistencia detectada
        return nil, ErrAssessmentIncomplete
    }

    // 3. Merge datos
    return merge(pgRecord, mongoDoc), nil
}
```

---

## 📊 Diagrama de Relaciones

```
schools (1) ──────┐
                  │
                  ↓ (N)
users (N) ← ─ ─ ─ school_id
  │
  ├─ (1) teacher_id
  │         ↓
  │      materials (N)
  │         │
  │         ├─ (1) material_id
  │         │         ↓
  │         │      assessment (1)
  │         │         │
  │         │         ├─ mongo_document_id → MongoDB.material_assessment
  │         │         │
  │         │         └─ (1) assessment_id
  │         │                   ↓
  │         │              assessment_attempt (N)
  │         │                   │
  │         │                   └─ (1) attempt_id
  │         │                             ↓
  │         │                        assessment_answer (N)
  │         │
  │         └─ material_id → MongoDB.material_summary
  │
  └─ (N) student_id
           ↓
      assessment_attempt (N)

academic_units (árbol)
  │
  ├─ (1) school_id → schools
  ├─ (1) parent_id → academic_units (self-reference)
  │
  └─ (N) unit_id
           ↓
      unit_membership (N)
           │
           └─ (1) user_id → users
```

---

## 🔐 Constraints y Validaciones

### Constraints de Integridad Referencial

```sql
-- Cascadas de eliminación
materials.unit_id → academic_units.id ON DELETE CASCADE
assessment.material_id → materials.id ON DELETE CASCADE
assessment_attempt.assessment_id → assessment.id ON DELETE CASCADE

-- Set NULL en eliminación
users.school_id → schools.id ON DELETE SET NULL
```

### Validaciones a Nivel de Aplicación

**shared/evaluation valida:**
- Estructura de Assessment
- Tipos de Question
- Rango de scores (0-100)
- Tiempo límite positivo

**infrastructure/schemas valida:**
- Formato de eventos RabbitMQ
- Campos requeridos
- Tipos de datos

---

## 📝 Notas de Implementación

### Para Desarrolladores

1. **Migraciones:**
   - Usar `infrastructure/database/migrations/`
   - Ejecutar en orden (001 → 008)
   - Siempre crear UP y DOWN

2. **Sincronización:**
   - MongoDB es fuente de verdad del contenido
   - PostgreSQL es índice/metadata
   - Eventual consistency es aceptable

3. **Validación:**
   - Usar shared/evaluation para modelos
   - Usar infrastructure/schemas para eventos
   - Validar antes de INSERT

4. **Queries:**
   - Usar índices (todos creados en migraciones)
   - Evitar N+1 (usar JOINs o eager loading)
   - Paginar resultados grandes

---

**Generado:** 16 de Noviembre, 2025  
**Por:** Claude Code  
**Versión:** 2.0.0  
**Fuente de verdad:** infrastructure/database/TABLE_OWNERSHIP.md
