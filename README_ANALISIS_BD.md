# Análisis de Estructura de Base de Datos - Ecosistema EduGo

## Resumen Ejecutivo

Se ha completado un análisis exhaustivo de la estructura de base de datos del ecosistema EduGo, diseñado para servir como referencia durante el diseño de interfaz de usuario (UI/UX) para aplicaciones móviles y desktop.

### Documento Principal

**Archivo:** `EDUGO_DATABASE_ANALYSIS.md` (1657 líneas)

Este es el análisis completo que contiene:

## Contenido del Análisis

### 1. Stack Tecnológico
- **PostgreSQL 15:** 13 tablas relacionales
- **MongoDB 7.0:** 9 colecciones NoSQL
- **RabbitMQ 3.12:** 4 eventos principales

### 2. Base de Datos Relacional (PostgreSQL)

#### Tablas de Gestión de Usuarios y Escuelas
| Tabla | Propósito | Campos Clave |
|-------|-----------|------------|
| `users` | Información de usuarios | id, email, role (admin/teacher/student/guardian) |
| `schools` | Instituciones educativas | id, name, code, subscription_tier |
| `academic_units` | Estructura jerárquica (jerarquía flexible) | id, parent_unit_id (auto-referencia), type |
| `memberships` | Relación usuario-escuela-unidad con roles | user_id, school_id, academic_unit_id, role |
| `guardian_relations` | Relaciones apoderado-estudiante | guardian_id, student_id, relationship_type |

#### Tablas de Materiales y Evaluaciones
| Tabla | Propósito | Campos Clave |
|-------|-----------|------------|
| `materials` | Materiales educativos subidos | id, file_url, status (uploaded/processing/ready/failed) |
| `material_versions` | Historial de cambios | material_id, version_number, changed_by |
| `assessment` | Evaluaciones generadas por IA | material_id, mongo_document_id, status |
| `assessment_attempt` | Intentos del estudiante | assessment_id, student_id, status |
| `assessment_attempt_answer` | Respuestas por pregunta | attempt_id, question_index, is_correct |

#### Tablas de Catálogos y Seguimiento
| Tabla | Propósito | Campos Clave |
|-------|-----------|------------|
| `subjects` | Materias/asignaturas | name, description |
| `units` | Unidades organizacionales simples | school_id, parent_unit_id |
| `progress` | Progreso de lectura en materiales | material_id, user_id, percentage, status |

### 3. Base de Datos Documental (MongoDB)

#### Colecciones de Evaluaciones
| Colección | Propósito | Contenido |
|-----------|-----------|----------|
| `material_assessment` | Preguntas y opciones generadas por IA | questions[], metadata |
| `material_assessment_worker` | Versión enriquecida del worker | questions con difficulty, explanation, points |
| `assessment_attempt_result` | Resultados y respuestas del estudiante | answers[], score, timestamps |

#### Colecciones de Contenido y Resúmenes
| Colección | Propósito | Contenido |
|-----------|-----------|----------|
| `material_content` | Texto extraído de materiales | raw_text, structured_content, processing_info |
| `material_summary` | Resúmenes generados por IA | summary, key_points[], word_count |

#### Colecciones de Auditoría y Eventos
| Colección | Propósito | Contenido |
|-----------|-----------|----------|
| `audit_logs` | Registro de todas las acciones | event_type, actor_id, action, changes |
| `notifications` | Notificaciones para usuarios | user_id, notification_type, is_read |
| `material_event` | Cola de eventos para procesamiento | event_type, status (pending/processing/completed/failed) |
| `analytics_events` | Tracking de comportamiento del usuario | event_name, user_id, device, location |

### 4. Roles y Perfiles de Usuario

#### Roles Globales (tabla `users`)
- `admin` - Administrador del sistema
- `teacher` - Docente (puede ser en múltiples escuelas)
- `student` - Estudiante (puede ser en múltiples escuelas)
- `guardian` - Apoderado/Tutor

#### Roles por Escuela/Unidad (tabla `memberships`)
- `teacher` - Docente de unidad
- `student` - Estudiante de unidad
- `guardian` - Apoderado
- `coordinator` - Coordinador de unidad
- `admin` - Administrador de escuela
- `assistant` - Asistente

**Importante:** Un usuario puede tener MÚLTIPLES roles en diferentes escuelas/unidades. Ejemplo: Teacher en Escuela A, Admin en Escuela B.

### 5. Flujo Principal: Evaluación Automática

```
1. DOCENTE SUBE MATERIAL
   └─ INSERT materials (status='uploaded')
   └─ PUBLISH 'material.uploaded' event

2. WORKER PROCESA (asincronía vía RabbitMQ)
   └─ Descargar archivo de S3
   └─ Extraer texto (OCR)
   └─ Llamar OpenAI: generar resumen + evaluación
   └─ INSERT en MongoDB: material_content, material_summary, material_assessment
   └─ INSERT en PostgreSQL: assessment (status='generated')
   └─ UPDATE materials (status='ready')
   └─ PUBLISH 'assessment.generated' event

3. ESTUDIANTE VE EVALUACIÓN LISTA
   └─ CONSUME assessment.generated event
   └─ INSERT notifications (MongoDB)
   └─ Push notification: "Tu evaluación está lista"

4. ESTUDIANTE INTENTA EVALUACIÓN
   └─ INSERT assessment_attempt (status='in_progress')
   └─ Mostrar preguntas (obtener de MongoDB)
   └─ INSERT assessment_attempt_answer (por cada pregunta)
   └─ UPDATE assessment_attempt (completed_at, score%, time_spent)
   └─ INSERT assessment_attempt_result (MongoDB)
   └─ INSERT notifications (resultado)
```

### 6. Relaciones Principales

```
JERARQUÍA ACADÉMICA:
schools 1──N academic_units
  └─ Facultad → Carrera → Semestre → Grupo

USUARIOS EN ESCUELAS:
users N──M schools (a través de memberships)
  └─ Un usuario puede ser teacher en Escuela A, student en Escuela B

MATERIALES:
materials ─ uploaded_by_teacher_id ──→ users
materials ─ school_id ──→ schools
materials ─ academic_unit_id ──→ academic_units
  ├─ material_versions (historial)
  ├─ assessment (referencia a MongoDB)
  └─ progress (seguimiento usuario)

EVALUACIONES:
assessment ─ material_id ──→ materials
assessment ─ mongo_document_id ──→ material_assessment (MongoDB)
  └─ assessment_attempt
     ├─ student_id ──→ users
     ├─ assessment_attempt_answer (N respuestas por pregunta)
     └─ mongo_id ──→ assessment_attempt_result (MongoDB)

APODERADOS:
guardian_relations ─ guardian_id ──→ users
guardian_relations ─ student_id ──→ users
  └─ Un estudiante puede tener múltiples apoderados
```

### 7. Estados y Transiciones

**Material Status:**
```
uploaded → processing → ready ✅
                    ↓
                  failed ❌
```

**Assessment Status:**
```
draft → generated → published → archived
              ↓
            closed
```

**Assessment Attempt Status:**
```
in_progress → completed ✅
          ↓
        abandoned ❌
```

**Progress Status:**
```
not_started → in_progress → completed
```

### 8. Datos Obligatorios vs Opcionales

**Obligatorios (validación en formularios):**
- users: email, password, first_name, last_name, role
- schools: name, code, country
- academic_units: school_id, name, code, type
- memberships: user_id, school_id, role
- materials: school_id, teacher_id, title, file_url, file_type, size
- assessment: material_id
- assessment_attempt: assessment_id, student_id

**Opcionales (pueden ser NULL):**
- users: deleted_at, email_verified
- schools: address, city, phone, email, logo (metadata)
- academic_units: parent_unit_id, description, academic_year
- materials: academic_unit_id, subject, grade, description
- assessment_attempt: completed_at, score, percentage

### 9. Eventos RabbitMQ

| Evento | Publisher | Consumer | Payload |
|--------|-----------|----------|---------|
| `material.uploaded` | api-mobile | worker | { material_id, file_url, file_type, ... } |
| `assessment.generated` | worker | api-mobile | { material_id, mongo_document_id, questions_count } |
| `material.deleted` | api-mobile | worker | { material_id, school_id, deleted_by_user_id } |
| `student.enrolled` | api-admin | api-mobile | { student_id, school_id, membership_id, ... } |

### 10. Consideraciones para Diseño de UI

#### Dashboard Docente
- Listar mis materiales (con status: processing, ready, failed)
- Ver cuántos estudiantes tienen evaluación pendiente
- Descargar resultados de evaluaciones en CSV
- Historiales de cambios (material_versions)

#### Dashboard Estudiante
- Mis materiales (con progreso de lectura: 0%, 50%, 100%)
- Mis evaluaciones disponibles (status='published')
- Mis calificaciones (intentos completados)
- Mis notificaciones (assessment ready, calificaciones)

#### Dashboard Coordinador/Admin
- Estudiantes en unidad académica
- Materiales por unidad (con status)
- Reportes de participación y calificaciones

#### Notificaciones (Push/Email)
- "Tu evaluación de Física está lista" (assessment.generated)
- "Completaste la evaluación con 75%" (assessment.completed)
- "Nuevo material disponible: Introducción a Cálculo" (material.uploaded)
- "Tu apoderado ha revisado tu progreso" (system notification)

#### Índices Críticos para Performance
- `idx_memberships_user` - Determinar qué escuelas/unidades ver
- `idx_materials_school` - Listar materiales
- `idx_assessment_status` - Evaluaciones listas
- `idx_attempt_student` - Historial de evaluaciones
- `idx_progress_user` - Progreso en materiales

## Cómo Usar Este Análisis

### Para Diseñadores UI/UX
1. Revisar la sección **10. Consideraciones para Diseño de UI**
2. Entender qué datos son obligatorios vs opcionales
3. Considerar los estados y transiciones de cada entidad
4. Diseñar formularios con validaciones apropiadas

### Para Desarrolladores Backend
1. Revisar tablas PostgreSQL y colecciones MongoDB
2. Entender las relaciones entre entidades
3. Implementar queries basadas en índices críticos
4. Publicar/consumir eventos RabbitMQ correctamente

### Para Desarrolladores Frontend
1. Entender los roles y permisos (múltiples por usuario)
2. Manejo de estados y transiciones
3. Integración con notificaciones y eventos
4. Considerar datos disponibles vs opcionales

## Archivos de Referencia

- **EDUGO_DATABASE_ANALYSIS.md** - Análisis detallado completo (1657 líneas)
- **README_ANALISIS_BD.md** - Este archivo (guía rápida)

## Repositorios Relacionados

- **edugo-infrastructure** - Migraciones y configuración BD
- **edugo-api-mobile** - Consume esta BD
- **edugo-api-administracion** - Consume esta BD
- **edugo-worker** - Procesa asincronía
- **edugo-shared** - Módulos compartidos

## Notas Importantes

1. **Soft Delete:** Todas las tablas usan `deleted_at IS NULL` para datos activos
2. **Jerarquía:** `academic_units` soporta estructura jerárquica profunda con validación de ciclos
3. **Múltiples Roles:** Un usuario puede tener roles diferentes en escuelas/unidades distintas
4. **Asincronía:** Procesamiento de IA ocurre en worker vía RabbitMQ
5. **Cross-Database:** Assessment está en PostgreSQL pero contenido en MongoDB
6. **Metadata JSONB:** Permite extensibilidad sin alterar schema

---

**Generado:** 1 de Diciembre, 2025
**Análisis Completo:** EDUGO_DATABASE_ANALYSIS.md
**Versión:** 1.0
