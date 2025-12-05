# Endpoints Faltantes - API Administración EduGo

Este documento detalla los endpoints que aún no están implementados en la API de administración (puerto 8081) pero que son necesarios para completar la funcionalidad de la app administrativa.

## Índice

1. [Ciclos y Periodos Académicos](#1-ciclos-y-periodos-académicos)
2. [Horarios y Programación](#2-horarios-y-programación)
3. [Aulas y Recursos](#3-aulas-y-recursos)
4. [Escalas de Calificación](#4-escalas-de-calificación)
5. [Roles y Permisos Granulares](#5-roles-y-permisos-granulares)
6. [Auditoría y Logs](#6-auditoría-y-logs)
7. [Reportes Administrativos](#7-reportes-administrativos)
8. [Certificados y Documentos](#8-certificados-y-documentos)
9. [Eventos Escolares](#9-eventos-escolares)
10. [Configuración de Notificaciones](#10-configuración-de-notificaciones)
11. [Pagos y Finanzas](#11-pagos-y-finanzas)
12. [Importación Masiva](#12-importación-masiva)

---

## 1. Ciclos y Periodos Académicos

### Descripción
Gestión de periodos académicos (años escolares, semestres, trimestres, bimestres) para organizar el calendario educativo.

### Endpoints Sugeridos

#### 1.1 Listar Ciclos Académicos
```
GET /v1/cycles
```

**Query Parameters**:
- `school_id` (uuid, opcional para super_admin)
- `active` (boolean, filtrar solo activos)
- `year` (integer, ej: 2024)
- `page`, `limit` (paginación)

**Response**:
```json
{
  "cycles": [
    {
      "id": "uuid-cycle",
      "school_id": "uuid-school",
      "name": "Ciclo Escolar 2024-2025",
      "code": "2024-2025",
      "start_date": "2024-09-01",
      "end_date": "2025-06-30",
      "active": true,
      "current": true,
      "periods": [
        {
          "id": "uuid-period-1",
          "name": "Primer Trimestre",
          "start_date": "2024-09-01",
          "end_date": "2024-11-30",
          "type": "trimestre"
        },
        {
          "id": "uuid-period-2",
          "name": "Segundo Trimestre",
          "start_date": "2024-12-01",
          "end_date": "2025-02-28",
          "type": "trimestre"
        },
        {
          "id": "uuid-period-3",
          "name": "Tercer Trimestre",
          "start_date": "2025-03-01",
          "end_date": "2025-06-30",
          "type": "trimestre"
        }
      ],
      "created_at": "2024-07-15T10:00:00Z",
      "updated_at": "2024-08-20T14:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 3
  }
}
```

---

#### 1.2 Obtener Detalle de Ciclo
```
GET /v1/cycles/:id
```

**Response**: Objeto cycle completo con todos sus periodos.

---

#### 1.3 Crear Ciclo Académico
```
POST /v1/cycles
```

**Request Body**:
```json
{
  "school_id": "uuid-school",
  "name": "Ciclo Escolar 2024-2025",
  "code": "2024-2025",
  "start_date": "2024-09-01",
  "end_date": "2025-06-30",
  "division_type": "trimestre",
  "active": true
}
```

**Validaciones Requeridas**:
- `school_id`: requerido, debe existir
- `name`: requerido, 5-200 caracteres
- `code`: requerido, único por escuela
- `start_date`: requerido, formato ISO 8601 (YYYY-MM-DD)
- `end_date`: requerido, debe ser posterior a start_date
- `division_type`: enum (semestre, trimestre, bimestre, cuatrimestre, anual)
- `active`: boolean (default: true)

**Reglas de Negocio**:
1. No permitir solapamiento de fechas entre ciclos activos de la misma escuela
2. Generar automáticamente periodos según `division_type`:
   - `semestre`: 2 periodos
   - `trimestre`: 3 periodos
   - `bimestre`: 6 periodos (para año completo) o proporcional
   - `cuatrimestre`: 3 periodos
   - `anual`: 1 periodo (todo el año)
3. Solo puede haber un ciclo `current=true` por escuela
4. Duración mínima: 1 mes
5. Duración máxima: 2 años

**Response**:
```json
{
  "id": "uuid-cycle",
  "school_id": "uuid-school",
  "name": "Ciclo Escolar 2024-2025",
  "code": "2024-2025",
  "start_date": "2024-09-01",
  "end_date": "2025-06-30",
  "active": true,
  "current": true,
  "periods": [
    {
      "id": "uuid-period-1",
      "name": "Primer Trimestre",
      "start_date": "2024-09-01",
      "end_date": "2024-11-30",
      "type": "trimestre"
    }
  ],
  "created_at": "2024-07-15T10:00:00Z"
}
```

---

#### 1.4 Actualizar Ciclo Académico
```
PATCH /v1/cycles/:id
```

**Request Body**:
```json
{
  "name": "Ciclo Escolar 2024-2025 Actualizado",
  "end_date": "2025-07-15",
  "active": false
}
```

**Validaciones**:
- No permitir cambiar `start_date` si el ciclo ya comenzó
- No permitir cambiar `division_type` si ya tiene periodos con datos
- Validar que `end_date` sea consistente con periodos existentes

**Campos NO Editables**:
- `school_id`
- `code`
- `division_type` (si ya tiene calificaciones/horarios)

---

#### 1.5 Activar/Desactivar Ciclo
```
PATCH /v1/cycles/:id/status
```

**Request Body**:
```json
{
  "active": false,
  "current": false
}
```

**Validaciones**:
- Si se marca `current=true`, desmarcar otros ciclos activos de la escuela
- No permitir desactivar si es el único ciclo activo de la escuela
- Advertir si hay horarios/calificaciones activas

---

#### 1.6 Eliminar Ciclo Académico
```
DELETE /v1/cycles/:id
```

**Validaciones**:
- Solo permitir si no tiene calificaciones registradas
- Solo permitir si no tiene horarios activos
- Requiere confirmación con password de admin
- Soft delete recomendado

**Impacto**:
- Elimina todos los periodos asociados
- Puede afectar reportes históricos

---

### Modelo de Datos Sugerido

```go
type Cycle struct {
    ID           uuid.UUID  `gorm:"type:uuid;primary_key"`
    SchoolID     uuid.UUID  `gorm:"type:uuid;not null;index"`
    Name         string     `gorm:"size:200;not null"`
    Code         string     `gorm:"size:50;not null;uniqueIndex:idx_school_cycle_code"`
    StartDate    time.Time  `gorm:"not null"`
    EndDate      time.Time  `gorm:"not null"`
    DivisionType string     `gorm:"size:20;not null"` // semestre, trimestre, bimestre, cuatrimestre, anual
    Active       bool       `gorm:"default:true"`
    Current      bool       `gorm:"default:false;index"` // Solo uno puede ser current por escuela
    CreatedAt    time.Time
    UpdatedAt    time.Time
    DeletedAt    *time.Time `gorm:"index"`
    
    School  School   `gorm:"foreignKey:SchoolID"`
    Periods []Period `gorm:"foreignKey:CycleID"`
}

type Period struct {
    ID        uuid.UUID  `gorm:"type:uuid;primary_key"`
    CycleID   uuid.UUID  `gorm:"type:uuid;not null;index"`
    Name      string     `gorm:"size:100;not null"`
    StartDate time.Time  `gorm:"not null"`
    EndDate   time.Time  `gorm:"not null"`
    Type      string     `gorm:"size:20;not null"` // mismo que DivisionType del ciclo
    Order     int        `gorm:"not null"` // 1, 2, 3...
    CreatedAt time.Time
    UpdatedAt time.Time
    
    Cycle Cycle `gorm:"foreignKey:CycleID"`
}
```

---

### Permisos
- **super_admin**: CRUD completo en todos los ciclos
- **director_escuela**: CRUD en ciclos de su escuela
- **director_academico**: CRUD en ciclos de su escuela
- **coordinador**: Solo lectura
- **Otros roles**: Solo lectura

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **CyclesView**: CRUD completo de ciclos
2. **DashboardAdminView**: Mostrar ciclo activo actual
3. **SchedulesView**: Filtrar horarios por ciclo/periodo
4. **ReportsView**: Generar reportes por periodo
5. **GradingView** (futuro): Asociar calificaciones a periodos

---

## 2. Horarios y Programación

### Descripción
Gestión de horarios de clases (asignación de materia, docente, aula, día/hora) por unidad académica.

### Endpoints Sugeridos

#### 2.1 Listar Horarios
```
GET /v1/schedules
```

**Query Parameters**:
- `unit_id` (uuid, filtrar por sección/grupo)
- `teacher_id` (uuid, filtrar por docente)
- `classroom_id` (uuid, filtrar por aula)
- `cycle_id` (uuid, filtrar por ciclo académico)
- `day_of_week` (integer, 0-6, 0=domingo)
- `page`, `limit` (paginación)

**Response**:
```json
{
  "schedules": [
    {
      "id": "uuid-schedule",
      "unit_id": "uuid-unit",
      "unit_name": "Sección A - 1er Grado",
      "subject_id": "uuid-subject",
      "subject_name": "Matemáticas",
      "teacher_id": "uuid-teacher",
      "teacher_name": "Prof. Roberto Sánchez",
      "classroom_id": "uuid-classroom",
      "classroom_name": "Aula 201",
      "cycle_id": "uuid-cycle",
      "day_of_week": 1,
      "start_time": "08:00:00",
      "end_time": "09:00:00",
      "recurrence": "weekly",
      "active": true,
      "created_at": "2024-08-15T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 120
  }
}
```

---

#### 2.2 Obtener Horario Semanal por Unidad
```
GET /v1/schedules/weekly?unit_id={id}&cycle_id={id}
```

**Response**: Horario estructurado por día de la semana y bloques horarios.

```json
{
  "unit": {
    "id": "uuid-unit",
    "name": "Sección A - 1er Grado"
  },
  "cycle": {
    "id": "uuid-cycle",
    "name": "Ciclo 2024-2025"
  },
  "weekly_schedule": {
    "monday": [
      {
        "start_time": "08:00",
        "end_time": "09:00",
        "subject": "Matemáticas",
        "teacher": "R. Sánchez",
        "classroom": "Aula 201"
      },
      {
        "start_time": "09:00",
        "end_time": "10:00",
        "subject": "Lenguaje",
        "teacher": "A. Martínez",
        "classroom": "Aula 201"
      }
    ],
    "tuesday": [...],
    "wednesday": [...],
    "thursday": [...],
    "friday": [...]
  }
}
```

---

#### 2.3 Obtener Horario de Docente
```
GET /v1/schedules/teacher/:teacher_id?cycle_id={id}
```

**Response**: Horario completo del docente (todas sus clases).

---

#### 2.4 Crear Bloque Horario
```
POST /v1/schedules
```

**Request Body**:
```json
{
  "unit_id": "uuid-unit",
  "subject_id": "uuid-subject",
  "teacher_id": "uuid-teacher",
  "classroom_id": "uuid-classroom",
  "cycle_id": "uuid-cycle",
  "day_of_week": 1,
  "start_time": "08:00:00",
  "end_time": "09:00:00",
  "recurrence": "weekly"
}
```

**Validaciones Requeridas**:
- `unit_id`: requerido, debe existir
- `subject_id`: requerido, debe estar asociado a la unidad
- `teacher_id`: requerido, debe tener membresía en la unidad
- `classroom_id`: opcional
- `cycle_id`: requerido, debe estar activo
- `day_of_week`: requerido, entero 0-6 (0=domingo, 1=lunes, ..., 6=sábado)
- `start_time`: requerido, formato HH:MM:SS
- `end_time`: requerido, debe ser > start_time
- `recurrence`: enum (weekly, biweekly, custom)

**Validaciones de Conflictos**:
1. **Conflicto de Docente**: El docente no debe tener otra clase al mismo tiempo
2. **Conflicto de Aula**: El aula no debe estar ocupada al mismo tiempo
3. **Conflicto de Unidad**: La sección no debe tener otra clase al mismo tiempo
4. **Duración**: Mínimo 30 minutos, máximo 4 horas

**Response**:
```json
{
  "id": "uuid-schedule",
  "unit_id": "uuid-unit",
  "subject_id": "uuid-subject",
  "teacher_id": "uuid-teacher",
  "classroom_id": "uuid-classroom",
  "cycle_id": "uuid-cycle",
  "day_of_week": 1,
  "start_time": "08:00:00",
  "end_time": "09:00:00",
  "recurrence": "weekly",
  "active": true,
  "conflicts": [],
  "created_at": "2024-08-15T10:00:00Z"
}
```

**En caso de conflicto**:
```json
{
  "error": "schedule_conflict",
  "message": "Conflicto detectado",
  "conflicts": [
    {
      "type": "teacher",
      "message": "El docente Roberto Sánchez ya tiene una clase los lunes de 08:00 a 09:00 (Ciencias en Aula 301)",
      "conflicting_schedule_id": "uuid-other-schedule"
    }
  ]
}
```

---

#### 2.5 Actualizar Bloque Horario
```
PUT /v1/schedules/:id
```

**Request Body**: Similar a POST, valida conflictos.

---

#### 2.6 Eliminar Bloque Horario
```
DELETE /v1/schedules/:id
```

**Validaciones**:
- Verificar si hay asistencias registradas (advertir)
- Requiere confirmación

---

#### 2.7 Detectar Conflictos (Validación Previa)
```
POST /v1/schedules/validate
```

**Request Body**: Mismo que POST `/v1/schedules`

**Response**:
```json
{
  "valid": false,
  "conflicts": [
    {
      "type": "classroom",
      "message": "Aula 201 ocupada por Sección B de 08:00 a 09:00",
      "severity": "error"
    },
    {
      "type": "teacher_overload",
      "message": "El docente tendría 35 horas semanales (límite: 30)",
      "severity": "warning"
    }
  ]
}
```

---

### Modelo de Datos Sugerido

```go
type Schedule struct {
    ID          uuid.UUID  `gorm:"type:uuid;primary_key"`
    UnitID      uuid.UUID  `gorm:"type:uuid;not null;index"`
    SubjectID   uuid.UUID  `gorm:"type:uuid;not null;index"`
    TeacherID   uuid.UUID  `gorm:"type:uuid;not null;index"`
    ClassroomID *uuid.UUID `gorm:"type:uuid;index"` // Opcional
    CycleID     uuid.UUID  `gorm:"type:uuid;not null;index"`
    DayOfWeek   int        `gorm:"not null"` // 0=domingo, 1=lunes, ..., 6=sábado
    StartTime   time.Time  `gorm:"type:time;not null"`
    EndTime     time.Time  `gorm:"type:time;not null"`
    Recurrence  string     `gorm:"size:20;default:weekly"` // weekly, biweekly, custom
    Active      bool       `gorm:"default:true"`
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   *time.Time `gorm:"index"`
    
    Unit      Unit      `gorm:"foreignKey:UnitID"`
    Subject   Subject   `gorm:"foreignKey:SubjectID"`
    Teacher   User      `gorm:"foreignKey:TeacherID"`
    Classroom *Classroom `gorm:"foreignKey:ClassroomID"`
    Cycle     Cycle     `gorm:"foreignKey:CycleID"`
}
```

**Índices Compuestos Recomendados**:
```sql
CREATE INDEX idx_schedule_unit_day ON schedules(unit_id, day_of_week, cycle_id);
CREATE INDEX idx_schedule_teacher_day ON schedules(teacher_id, day_of_week, cycle_id);
CREATE INDEX idx_schedule_classroom_day ON schedules(classroom_id, day_of_week, cycle_id);
```

---

### Permisos
- **super_admin**: CRUD completo
- **director_escuela**: CRUD en su escuela
- **director_academico**: CRUD en su escuela
- **coordinador**: CRUD en unidades asignadas
- **teacher**: Solo lectura de sus horarios
- **student/parent**: Solo lectura de horarios de sus unidades

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **SchedulesView**: CRUD completo de horarios (calendario semanal interactivo)
2. **AcademicTreeView**: Ver horario de sección
3. **ClassroomsView**: Ocupación de aulas por horario
4. **UserDetailView** (docente): Ver carga horaria del docente
5. **App Principal** (estudiante/tutor): Ver horario de clases

---

## 3. Aulas y Recursos

### Descripción
Gestión de aulas, laboratorios, gimnasios y otros espacios físicos de la escuela.

### Endpoints Sugeridos

#### 3.1 Listar Aulas
```
GET /v1/classrooms
```

**Query Parameters**:
- `school_id` (uuid, filtrar por escuela)
- `type` (enum, filtrar por tipo)
- `capacity_min`, `capacity_max` (enteros, rango de capacidad)
- `available` (boolean, solo disponibles)
- `building` (string, filtrar por edificio)
- `page`, `limit` (paginación)

**Response**:
```json
{
  "classrooms": [
    {
      "id": "uuid-classroom",
      "school_id": "uuid-school",
      "name": "Aula 201",
      "code": "A-201",
      "type": "aula_standard",
      "capacity": 35,
      "building": "Edificio A",
      "floor": 2,
      "equipment": [
        "proyector",
        "pizarra_digital",
        "aire_acondicionado"
      ],
      "active": true,
      "created_at": "2024-01-15T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45
  }
}
```

---

#### 3.2 Obtener Detalle de Aula
```
GET /v1/classrooms/:id
```

**Response**: Incluye horarios asignados y disponibilidad.

```json
{
  "id": "uuid-classroom",
  "school_id": "uuid-school",
  "name": "Aula 201",
  "code": "A-201",
  "type": "aula_standard",
  "capacity": 35,
  "building": "Edificio A",
  "floor": 2,
  "description": "Aula estándar con proyector y pizarra digital",
  "equipment": [
    "proyector",
    "pizarra_digital",
    "aire_acondicionado",
    "computadora"
  ],
  "accessibility": {
    "wheelchair_accessible": true,
    "elevator_access": true
  },
  "active": true,
  "current_occupancy": {
    "occupied": true,
    "schedule_id": "uuid-schedule",
    "subject": "Matemáticas",
    "teacher": "R. Sánchez",
    "until": "09:00:00"
  },
  "weekly_occupancy_rate": 85.5,
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-08-20T14:30:00Z"
}
```

---

#### 3.3 Crear Aula
```
POST /v1/classrooms
```

**Request Body**:
```json
{
  "school_id": "uuid-school",
  "name": "Laboratorio de Ciencias",
  "code": "LAB-SCI-01",
  "type": "laboratorio",
  "capacity": 25,
  "building": "Edificio B",
  "floor": 1,
  "description": "Laboratorio equipado para experimentos de química y física",
  "equipment": [
    "mesas_laboratorio",
    "lavaojos",
    "extractor",
    "armario_reactivos"
  ],
  "accessibility": {
    "wheelchair_accessible": false,
    "elevator_access": true
  },
  "active": true
}
```

**Validaciones Requeridas**:
- `school_id`: requerido, debe existir
- `name`: requerido, 3-100 caracteres
- `code`: requerido, único por escuela, 3-50 caracteres
- `type`: enum (aula_standard, laboratorio, gimnasio, biblioteca, auditorio, sala_computo, taller, otro)
- `capacity`: requerido, entero > 0, máximo razonable (ej: 200)
- `building`: opcional, 2-50 caracteres
- `floor`: opcional, entero (puede ser negativo para sótanos)
- `equipment`: opcional, array de strings
- `active`: boolean (default: true)

**Response**: Objeto classroom creado

---

#### 3.4 Actualizar Aula
```
PUT /v1/classrooms/:id
```

**Request Body**: Similar a POST

**Validaciones**:
- Si se reduce `capacity`, verificar que no haya horarios con más estudiantes asignados

---

#### 3.5 Eliminar Aula
```
DELETE /v1/classrooms/:id
```

**Validaciones**:
- No permitir si tiene horarios activos asignados
- No permitir si está en uso (ocupada actualmente)
- Requiere confirmación

---

#### 3.6 Obtener Disponibilidad de Aula
```
GET /v1/classrooms/:id/availability?date={YYYY-MM-DD}&cycle_id={id}
```

**Response**:
```json
{
  "classroom_id": "uuid-classroom",
  "classroom_name": "Aula 201",
  "date": "2024-11-28",
  "availability": [
    {
      "time_slot": "08:00-09:00",
      "available": false,
      "schedule_id": "uuid-schedule",
      "subject": "Matemáticas",
      "unit": "Sección A - 1er Grado"
    },
    {
      "time_slot": "09:00-10:00",
      "available": true
    },
    {
      "time_slot": "10:00-11:00",
      "available": false,
      "schedule_id": "uuid-schedule-2",
      "subject": "Lenguaje",
      "unit": "Sección B - 1er Grado"
    }
  ]
}
```

---

### Modelo de Datos Sugerido

```go
type Classroom struct {
    ID            uuid.UUID      `gorm:"type:uuid;primary_key"`
    SchoolID      uuid.UUID      `gorm:"type:uuid;not null;index"`
    Name          string         `gorm:"size:100;not null"`
    Code          string         `gorm:"size:50;not null;uniqueIndex:idx_school_classroom_code"`
    Type          string         `gorm:"size:50;not null"` // aula_standard, laboratorio, gimnasio, etc.
    Capacity      int            `gorm:"not null"`
    Building      string         `gorm:"size:50"`
    Floor         int
    Description   string         `gorm:"size:500"`
    Equipment     pq.StringArray `gorm:"type:text[]"` // PostgreSQL array
    Accessibility JSON           `gorm:"type:jsonb"` // wheelchair_accessible, elevator_access, etc.
    Active        bool           `gorm:"default:true"`
    CreatedAt     time.Time
    UpdatedAt     time.Time
    DeletedAt     *time.Time     `gorm:"index"`
    
    School    School     `gorm:"foreignKey:SchoolID"`
    Schedules []Schedule `gorm:"foreignKey:ClassroomID"`
}

type JSON map[string]interface{} // Para Accessibility y otros campos JSON
```

---

### Permisos
- **super_admin**: CRUD completo
- **director_escuela**: CRUD en su escuela
- **director_academico**: CRUD en su escuela
- **coordinador**: Solo lectura
- **teacher**: Solo lectura
- **Otros roles**: Solo lectura

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **ClassroomsView**: CRUD completo de aulas
2. **SchedulesView**: Seleccionar aula al crear horario, ver disponibilidad
3. **SchoolDetailView**: Lista de recursos de la escuela
4. **EventsView** (futuro): Reservar aula para eventos

---

## 4. Escalas de Calificación

### Descripción
Configuración de escalas de calificación por escuela o unidad (numérica, alfabética, conceptual).

### Endpoints Sugeridos

#### 4.1 Listar Escalas de Calificación
```
GET /v1/grading-scales
```

**Query Parameters**:
- `school_id` (uuid)
- `unit_id` (uuid, opcional, filtrar por unidad)
- `active` (boolean)

**Response**:
```json
{
  "grading_scales": [
    {
      "id": "uuid-scale",
      "school_id": "uuid-school",
      "name": "Escala Numérica 1-10",
      "type": "numeric",
      "min_value": 1.0,
      "max_value": 10.0,
      "passing_grade": 6.0,
      "ranges": [
        {
          "min": 9.0,
          "max": 10.0,
          "label": "Excelente",
          "letter": "A"
        },
        {
          "min": 7.0,
          "max": 8.99,
          "label": "Notable",
          "letter": "B"
        },
        {
          "min": 6.0,
          "max": 6.99,
          "label": "Aprobado",
          "letter": "C"
        },
        {
          "min": 1.0,
          "max": 5.99,
          "label": "Reprobado",
          "letter": "F"
        }
      ],
      "active": true,
      "default": true
    }
  ]
}
```

---

#### 4.2 Crear Escala de Calificación
```
POST /v1/grading-scales
```

**Request Body**:
```json
{
  "school_id": "uuid-school",
  "name": "Escala Alfabética A-F",
  "type": "alphabetic",
  "ranges": [
    {"label": "A", "min": 90, "max": 100, "passing": true},
    {"label": "B", "min": 80, "max": 89, "passing": true},
    {"label": "C", "min": 70, "max": 79, "passing": true},
    {"label": "D", "min": 60, "max": 69, "passing": true},
    {"label": "F", "min": 0, "max": 59, "passing": false}
  ],
  "active": true,
  "default": false
}
```

**Validaciones**:
- `type`: enum (numeric, alphabetic, conceptual, custom)
- `ranges`: debe cubrir todo el rango sin solapamientos
- Solo puede haber una escala `default=true` por escuela

---

### Modelo de Datos Sugerido

```go
type GradingScale struct {
    ID           uuid.UUID `gorm:"type:uuid;primary_key"`
    SchoolID     uuid.UUID `gorm:"type:uuid;not null;index"`
    Name         string    `gorm:"size:100;not null"`
    Type         string    `gorm:"size:20;not null"` // numeric, alphabetic, conceptual, custom
    MinValue     float64
    MaxValue     float64
    PassingGrade float64
    Ranges       JSON      `gorm:"type:jsonb"` // Array de ranges
    Active       bool      `gorm:"default:true"`
    Default      bool      `gorm:"default:false;index"`
    CreatedAt    time.Time
    UpdatedAt    time.Time
    
    School School `gorm:"foreignKey:SchoolID"`
}
```

---

### Permisos
- **super_admin**: CRUD completo
- **director_escuela**: CRUD en su escuela
- **director_academico**: CRUD en su escuela
- **Otros roles**: Solo lectura

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **GradingScalesView** (nueva): CRUD de escalas
2. **SchoolDetailView**: Configurar escala por defecto
3. **SubjectsView**: Asignar escala a materia
4. **GradingView** (futuro): Ingresar calificaciones según escala

---

## 5. Roles y Permisos Granulares

### Descripción
Sistema de permisos granulares más allá de roles básicos (RBAC avanzado).

### Endpoints Sugeridos

#### 5.1 Listar Permisos Disponibles
```
GET /v1/permissions
```

**Response**:
```json
{
  "permissions": [
    {
      "id": "uuid-permission",
      "name": "schools.create",
      "description": "Crear nuevas escuelas",
      "category": "schools",
      "default_roles": ["super_admin"]
    },
    {
      "id": "uuid-permission-2",
      "name": "users.edit_all",
      "description": "Editar todos los usuarios",
      "category": "users",
      "default_roles": ["super_admin", "director_escuela"]
    },
    {
      "id": "uuid-permission-3",
      "name": "reports.financial",
      "description": "Acceder a reportes financieros",
      "category": "reports",
      "default_roles": ["super_admin", "director_escuela"]
    }
  ]
}
```

---

#### 5.2 Obtener Permisos de Usuario
```
GET /v1/users/:id/permissions
```

**Response**:
```json
{
  "user_id": "uuid-user",
  "role": "director_academico",
  "permissions": [
    "users.view_school",
    "users.edit_school",
    "units.create",
    "units.edit",
    "subjects.create",
    "subjects.edit",
    "schedules.create",
    "schedules.edit",
    "reports.academic"
  ],
  "custom_permissions": [
    {
      "permission": "reports.financial",
      "granted_by": "uuid-super-admin",
      "granted_at": "2024-09-01T10:00:00Z",
      "expires_at": null
    }
  ]
}
```

---

#### 5.3 Asignar Permiso Custom a Usuario
```
POST /v1/users/:id/permissions
```

**Request Body**:
```json
{
  "permission": "reports.financial",
  "expires_at": "2025-12-31T23:59:59Z"
}
```

**Validaciones**:
- Solo `super_admin` o `director_escuela` pueden asignar permisos
- No duplicar permisos que ya tiene por su rol
- Validar que el permiso exista

---

#### 5.4 Revocar Permiso Custom
```
DELETE /v1/users/:id/permissions/:permission
```

---

### Modelo de Datos Sugerido

```go
type Permission struct {
    ID           uuid.UUID      `gorm:"type:uuid;primary_key"`
    Name         string         `gorm:"size:100;not null;unique"` // ej: "users.edit_all"
    Description  string         `gorm:"size:200"`
    Category     string         `gorm:"size:50;index"` // users, schools, reports, etc.
    DefaultRoles pq.StringArray `gorm:"type:text[]"` // Roles que tienen este permiso por defecto
    CreatedAt    time.Time
}

type UserPermission struct {
    ID         uuid.UUID  `gorm:"type:uuid;primary_key"`
    UserID     uuid.UUID  `gorm:"type:uuid;not null;index"`
    Permission string     `gorm:"size:100;not null"` // FK a Permission.Name
    GrantedBy  uuid.UUID  `gorm:"type:uuid;not null"`
    GrantedAt  time.Time  `gorm:"not null"`
    ExpiresAt  *time.Time
    CreatedAt  time.Time
    
    User       User `gorm:"foreignKey:UserID"`
    GrantedByUser User `gorm:"foreignKey:GrantedBy"`
}
```

---

### Categorías de Permisos Sugeridas

```
schools.*
  - schools.create
  - schools.edit_all
  - schools.edit_own
  - schools.delete
  
users.*
  - users.create
  - users.edit_all
  - users.edit_school
  - users.delete
  - users.view_all
  - users.view_school
  
units.*
  - units.create
  - units.edit
  - units.delete
  
subjects.*
  - subjects.create
  - subjects.edit
  - subjects.delete
  
memberships.*
  - memberships.create
  - memberships.edit
  - memberships.delete
  
schedules.*
  - schedules.create
  - schedules.edit
  - schedules.delete
  
reports.*
  - reports.academic
  - reports.financial
  - reports.administrative
  - reports.export
  
audit.*
  - audit.view_all
  - audit.view_school
  
payments.*
  - payments.create
  - payments.edit
  - payments.delete
  - payments.view
```

---

### Permisos
- **super_admin**: Gestión completa de permisos
- **director_escuela**: Asignar permisos dentro de su escuela
- **Otros roles**: Sin acceso

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **UserDetailView**: Ver y asignar permisos custom
2. **RolesView** (nueva): Gestionar roles y permisos por defecto
3. **Todas las pantallas**: Validar permisos antes de mostrar/ocultar acciones

---

## 6. Auditoría y Logs

### Descripción
Registro inmutable de todas las acciones CRUD realizadas en el sistema.

### Endpoints Sugeridos

#### 6.1 Listar Logs de Auditoría
```
GET /v1/audit-logs
```

**Query Parameters**:
- `user_id` (uuid, filtrar por usuario que realizó la acción)
- `entity_type` (string, filtrar por tipo de entidad: User, School, Unit, etc.)
- `entity_id` (uuid, filtrar por entidad específica)
- `action` (enum, filtrar por acción: create, update, delete, view)
- `from` (datetime ISO 8601)
- `to` (datetime ISO 8601)
- `school_id` (uuid, filtrar por escuela - para director_escuela)
- `page`, `limit` (paginación)

**Response**:
```json
{
  "logs": [
    {
      "id": "uuid-log",
      "user_id": "uuid-user",
      "user_name": "Roberto Sánchez",
      "user_email": "roberto.sanchez@sanmartin.edu",
      "action": "update",
      "entity_type": "User",
      "entity_id": "uuid-target-user",
      "entity_name": "Juan Pérez",
      "changes": {
        "before": {
          "active": true,
          "phone": "+34 612345678"
        },
        "after": {
          "active": false,
          "phone": "+34 600000000"
        }
      },
      "ip_address": "192.168.1.100",
      "user_agent": "Mozilla/5.0...",
      "timestamp": "2024-11-28T14:35:22Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 1250
  }
}
```

---

#### 6.2 Obtener Detalle de Log
```
GET /v1/audit-logs/:id
```

**Response**: Log completo con cambios detallados (diff JSON).

```json
{
  "id": "uuid-log",
  "user_id": "uuid-user",
  "user": {
    "id": "uuid-user",
    "name": "Roberto Sánchez",
    "email": "roberto.sanchez@sanmartin.edu",
    "role": "director_academico"
  },
  "action": "update",
  "entity_type": "User",
  "entity_id": "uuid-target-user",
  "entity": {
    "id": "uuid-target-user",
    "name": "Juan Pérez",
    "email": "juan.perez@ejemplo.com"
  },
  "changes": {
    "before": {
      "name": "Juan Pérez",
      "active": true,
      "phone": "+34 612345678",
      "metadata": {
        "allergies": "Ninguna"
      }
    },
    "after": {
      "name": "Juan Pérez García",
      "active": false,
      "phone": "+34 600000000",
      "metadata": {
        "allergies": "Polen"
      }
    }
  },
  "diff": [
    {
      "field": "name",
      "old_value": "Juan Pérez",
      "new_value": "Juan Pérez García"
    },
    {
      "field": "active",
      "old_value": true,
      "new_value": false
    },
    {
      "field": "phone",
      "old_value": "+34 612345678",
      "new_value": "+34 600000000"
    },
    {
      "field": "metadata.allergies",
      "old_value": "Ninguna",
      "new_value": "Polen"
    }
  ],
  "ip_address": "192.168.1.100",
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
  "timestamp": "2024-11-28T14:35:22Z"
}
```

---

#### 6.3 Obtener Historial de Entidad
```
GET /v1/audit-logs/entity/:entity_type/:entity_id
```

**Ejemplo**:
```
GET /v1/audit-logs/entity/User/uuid-user-123
```

**Response**: Todos los logs relacionados con esa entidad (historial completo de cambios).

---

### Modelo de Datos Sugerido

```go
type AuditLog struct {
    ID         uuid.UUID  `gorm:"type:uuid;primary_key"`
    UserID     uuid.UUID  `gorm:"type:uuid;not null;index"`
    Action     string     `gorm:"size:20;not null;index"` // create, update, delete, view
    EntityType string     `gorm:"size:50;not null;index"` // User, School, Unit, Membership, etc.
    EntityID   uuid.UUID  `gorm:"type:uuid;not null;index"`
    EntityName string     `gorm:"size:200"` // Nombre legible de la entidad
    Changes    JSON       `gorm:"type:jsonb"` // {before: {...}, after: {...}}
    IPAddress  string     `gorm:"size:45"` // Soporta IPv6
    UserAgent  string     `gorm:"size:500"`
    Timestamp  time.Time  `gorm:"not null;index"`
    
    User User `gorm:"foreignKey:UserID"`
}
```

**Índices Compuestos Recomendados**:
```sql
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id, timestamp DESC);
CREATE INDEX idx_audit_user_timestamp ON audit_logs(user_id, timestamp DESC);
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp DESC);
```

---

### Eventos Auditables

**Siempre auditar**:
1. **Users**: create, update (cambios sensibles: active, role, email), delete
2. **Schools**: create, update, delete
3. **Units**: create, update, delete
4. **Memberships**: create, delete
5. **Subjects**: create, update, delete
6. **Schedules**: create, update, delete
7. **Payments** (futuro): create, update, delete
8. **Grading Scales**: create, update, delete
9. **Permissions**: grant, revoke

**Opcional auditar** (puede generar mucho volumen):
- `view` en datos sensibles (reportes financieros, datos personales)
- Login/logout de usuarios
- Cambios en configuración

---

### Permisos
- **super_admin**: Ver todos los logs
- **director_escuela**: Ver logs de su escuela
- **director_academico**: Ver logs académicos de su escuela
- **Otros roles**: Sin acceso

**IMPORTANTE**: Los logs son **inmutables** (solo lectura). No se pueden editar o eliminar.

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **AuditLogView**: Vista principal de logs con filtros
2. **DashboardAdminView**: Actividad reciente (últimos 10 logs)
3. **UserDetailView**: Historial de cambios del usuario
4. **SchoolDetailView**: Historial de cambios de la escuela
5. **UnitDetailView**: Historial de cambios de la unidad

---

## 7. Reportes Administrativos

### Descripción
Generación de reportes administrativos y académicos en múltiples formatos.

### Endpoints Sugeridos

#### 7.1 Listar Tipos de Reportes Disponibles
```
GET /v1/reports/types
```

**Response**:
```json
{
  "categories": [
    {
      "name": "academic",
      "label": "Reportes Académicos",
      "reports": [
        {
          "id": "grades_by_period",
          "name": "Calificaciones por Periodo",
          "description": "Reporte de calificaciones de estudiantes por periodo académico",
          "parameters": ["cycle_id", "period_id", "unit_id"],
          "formats": ["pdf", "xlsx", "csv"]
        },
        {
          "id": "attendance_report",
          "name": "Reporte de Asistencia",
          "description": "Asistencia de estudiantes por materia y fecha",
          "parameters": ["from_date", "to_date", "unit_id", "subject_id"],
          "formats": ["pdf", "xlsx", "csv"]
        }
      ]
    },
    {
      "name": "administrative",
      "label": "Reportes Administrativos",
      "reports": [
        {
          "id": "students_list",
          "name": "Lista de Estudiantes",
          "description": "Lista completa de estudiantes con datos personales",
          "parameters": ["unit_id", "active_only"],
          "formats": ["pdf", "xlsx", "csv"]
        },
        {
          "id": "teachers_schedule",
          "name": "Carga Horaria de Docentes",
          "description": "Horarios y carga semanal de docentes",
          "parameters": ["teacher_id", "cycle_id"],
          "formats": ["pdf", "xlsx"]
        }
      ]
    },
    {
      "name": "financial",
      "label": "Reportes Financieros",
      "reports": [
        {
          "id": "payments_status",
          "name": "Estado de Pagos",
          "description": "Estado de pagos de estudiantes por periodo",
          "parameters": ["cycle_id", "payment_status"],
          "formats": ["pdf", "xlsx", "csv"]
        }
      ]
    }
  ]
}
```

---

#### 7.2 Generar Reporte (Asíncrono)
```
POST /v1/reports/generate
```

**Request Body**:
```json
{
  "report_type": "students_list",
  "parameters": {
    "unit_id": "uuid-unit",
    "active_only": true,
    "include_guardians": true
  },
  "format": "xlsx"
}
```

**Validaciones**:
- `report_type`: debe existir en tipos disponibles
- `parameters`: deben cumplir con esquema del reporte
- `format`: debe estar soportado por el reporte

**Response** (202 Accepted):
```json
{
  "job_id": "uuid-job",
  "status": "queued",
  "estimated_completion": "2024-11-28T15:00:00Z",
  "message": "El reporte se está generando. Recibirás una notificación cuando esté listo."
}
```

---

#### 7.3 Consultar Estado de Reporte
```
GET /v1/reports/jobs/:job_id
```

**Response** (En progreso):
```json
{
  "job_id": "uuid-job",
  "status": "processing",
  "progress": 45,
  "created_at": "2024-11-28T14:45:00Z",
  "estimated_completion": "2024-11-28T15:00:00Z"
}
```

**Response** (Completado):
```json
{
  "job_id": "uuid-job",
  "status": "completed",
  "progress": 100,
  "report_id": "uuid-report",
  "download_url": "https://cdn.edugo.com/reports/uuid-report.xlsx",
  "expires_at": "2024-12-05T14:50:00Z",
  "created_at": "2024-11-28T14:45:00Z",
  "completed_at": "2024-11-28T14:50:22Z"
}
```

**Response** (Error):
```json
{
  "job_id": "uuid-job",
  "status": "failed",
  "error": "No se encontraron datos para los parámetros proporcionados",
  "created_at": "2024-11-28T14:45:00Z",
  "failed_at": "2024-11-28T14:46:15Z"
}
```

---

#### 7.4 Descargar Reporte
```
GET /v1/reports/:report_id/download
```

**Response**: Archivo en el formato solicitado (Content-Type apropiado, Content-Disposition: attachment).

**Headers**:
```
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="estudiantes_seccion_a_2024-11-28.xlsx"
```

---

#### 7.5 Listar Mis Reportes Generados
```
GET /v1/reports/my-reports?status={status}&page={page}&limit={limit}
```

**Response**:
```json
{
  "reports": [
    {
      "report_id": "uuid-report",
      "job_id": "uuid-job",
      "report_type": "students_list",
      "report_name": "Lista de Estudiantes",
      "format": "xlsx",
      "status": "completed",
      "download_url": "https://cdn.edugo.com/reports/uuid-report.xlsx",
      "expires_at": "2024-12-05T14:50:00Z",
      "created_at": "2024-11-28T14:45:00Z",
      "file_size": 245678
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45
  }
}
```

---

### Modelo de Datos Sugerido

```go
type ReportJob struct {
    ID              uuid.UUID  `gorm:"type:uuid;primary_key"`
    UserID          uuid.UUID  `gorm:"type:uuid;not null;index"`
    ReportType      string     `gorm:"size:50;not null"`
    Parameters      JSON       `gorm:"type:jsonb"`
    Format          string     `gorm:"size:10;not null"` // pdf, xlsx, csv
    Status          string     `gorm:"size:20;not null;index"` // queued, processing, completed, failed
    Progress        int        `gorm:"default:0"` // 0-100
    ReportID        *uuid.UUID `gorm:"type:uuid;index"`
    DownloadURL     string     `gorm:"size:500"`
    ExpiresAt       *time.Time
    ErrorMessage    string     `gorm:"size:500"`
    CreatedAt       time.Time  `gorm:"index"`
    CompletedAt     *time.Time
    FileSize        int64      // Bytes
    
    User   User    `gorm:"foreignKey:UserID"`
}
```

---

### Tipos de Reportes Sugeridos

#### Académicos
1. **Calificaciones por Periodo**: Calificaciones de estudiantes
2. **Reporte de Asistencia**: Asistencias por materia/fecha
3. **Progreso de Estudiantes**: Avance académico
4. **Estadísticas por Materia**: Promedios, aprobados, reprobados

#### Administrativos
5. **Lista de Estudiantes**: Datos personales completos
6. **Lista de Docentes**: Datos de docentes
7. **Carga Horaria de Docentes**: Horarios semanales
8. **Ocupación de Secciones**: Capacidad vs matriculados
9. **Membresías Activas**: Asignaciones vigentes

#### Financieros (Futuro)
10. **Estado de Pagos**: Pagos por estudiante
11. **Deudas Pendientes**: Pagos vencidos
12. **Ingresos por Periodo**: Resumen de cobros

---

### Formatos Soportados

1. **PDF**: Reportes formateados para impresión
2. **XLSX**: Excel con fórmulas y formato
3. **CSV**: Datos crudos separados por comas

---

### Permisos
- **super_admin**: Todos los reportes
- **director_escuela**: Reportes de su escuela (académicos, administrativos, financieros)
- **director_academico**: Reportes académicos y administrativos
- **coordinador**: Reportes de sus unidades
- **teacher**: Solo reportes de sus materias
- **Otros roles**: Sin acceso

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **ReportsView**: Catálogo de reportes, generación, historial
2. **DashboardAdminView**: Accesos rápidos a reportes frecuentes
3. **Todas las vistas de gestión**: Botón "Exportar" para exportar datos visibles

---

## 8. Certificados y Documentos

### Descripción
Generación de certificados, constancias y documentos oficiales con firma digital.

### Endpoints Sugeridos

#### 8.1 Listar Plantillas de Documentos
```
GET /v1/documents/templates
```

**Response**:
```json
{
  "templates": [
    {
      "id": "uuid-template",
      "name": "Certificado de Estudios",
      "type": "certificado_estudios",
      "description": "Certificado oficial de estudios cursados",
      "variables": ["student_name", "grades", "school_name", "date"],
      "requires_signature": true,
      "active": true
    },
    {
      "id": "uuid-template-2",
      "name": "Constancia de Inscripción",
      "type": "constancia_inscripcion",
      "description": "Constancia de alumno inscrito",
      "variables": ["student_name", "unit_name", "cycle_name"],
      "requires_signature": true,
      "active": true
    }
  ]
}
```

---

#### 8.2 Generar Documento
```
POST /v1/documents/generate
```

**Request Body**:
```json
{
  "template_id": "uuid-template",
  "student_id": "uuid-student",
  "cycle_id": "uuid-cycle",
  "additional_data": {
    "purpose": "Trámite bancario",
    "guardian_request": true
  }
}
```

**Response** (202 Accepted):
```json
{
  "job_id": "uuid-job",
  "status": "processing",
  "estimated_completion": "2024-11-28T15:05:00Z"
}
```

---

#### 8.3 Descargar Documento Generado
```
GET /v1/documents/:document_id/download
```

**Response**: PDF con firma digital o watermark.

---

#### 8.4 Listar Documentos de Estudiante
```
GET /v1/documents?student_id={id}
```

**Response**:
```json
{
  "documents": [
    {
      "id": "uuid-doc",
      "template_name": "Certificado de Estudios",
      "student_id": "uuid-student",
      "student_name": "Juan Pérez",
      "cycle_name": "Ciclo 2024-2025",
      "generated_at": "2024-11-28T14:55:00Z",
      "generated_by": "uuid-admin",
      "signed": true,
      "signature_verified": true,
      "download_url": "https://cdn.edugo.com/docs/uuid-doc.pdf",
      "expires_at": null
    }
  ]
}
```

---

### Modelo de Datos Sugerido

```go
type DocumentTemplate struct {
    ID                uuid.UUID `gorm:"type:uuid;primary_key"`
    SchoolID          *uuid.UUID `gorm:"type:uuid;index"` // Null = global template
    Name              string    `gorm:"size:100;not null"`
    Type              string    `gorm:"size:50;not null;index"`
    Description       string    `gorm:"size:500"`
    TemplateFileURL   string    `gorm:"size:500"` // URL a plantilla (.docx, .html)
    Variables         pq.StringArray `gorm:"type:text[]"` // student_name, grades, etc.
    RequiresSignature bool      `gorm:"default:false"`
    Active            bool      `gorm:"default:true"`
    CreatedAt         time.Time
    UpdatedAt         time.Time
}

type GeneratedDocument struct {
    ID             uuid.UUID  `gorm:"type:uuid;primary_key"`
    TemplateID     uuid.UUID  `gorm:"type:uuid;not null;index"`
    StudentID      uuid.UUID  `gorm:"type:uuid;not null;index"`
    CycleID        *uuid.UUID `gorm:"type:uuid;index"`
    GeneratedBy    uuid.UUID  `gorm:"type:uuid;not null"`
    FileURL        string     `gorm:"size:500"`
    Signed         bool       `gorm:"default:false"`
    SignatureHash  string     `gorm:"size:256"` // Hash de firma digital
    AdditionalData JSON       `gorm:"type:jsonb"`
    GeneratedAt    time.Time  `gorm:"not null"`
    ExpiresAt      *time.Time
    
    Template    DocumentTemplate `gorm:"foreignKey:TemplateID"`
    Student     User             `gorm:"foreignKey:StudentID"`
    Cycle       *Cycle           `gorm:"foreignKey:CycleID"`
    GeneratedByUser User         `gorm:"foreignKey:GeneratedBy"`
}
```

---

### Tipos de Documentos Sugeridos

1. **Certificado de Estudios**: Calificaciones de ciclo completo
2. **Constancia de Inscripción**: Alumno inscrito en ciclo actual
3. **Constancia de Buena Conducta**: Comportamiento del alumno
4. **Carta de Recomendación**: Firmada por director/docente
5. **Boleta de Calificaciones**: Calificaciones por periodo
6. **Diploma de Graduación**: Completó nivel educativo

---

### Permisos
- **super_admin**: CRUD de plantillas, generar todos los documentos
- **director_escuela**: Generar documentos de su escuela
- **director_academico**: Generar documentos académicos
- **parent**: Solicitar documentos de sus hijos (requiere aprobación)
- **Otros roles**: Sin acceso

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **DocumentsView** (nueva): CRUD de plantillas, generar documentos
2. **UserDetailView** (estudiante): Ver y descargar documentos generados
3. **App Principal** (tutor): Solicitar documentos oficiales

---

## 9. Eventos Escolares

### Descripción
Gestión de eventos, actividades y calendario escolar.

### Endpoints Sugeridos

#### 9.1 Listar Eventos
```
GET /v1/events
```

**Query Parameters**:
- `school_id` (uuid)
- `unit_id` (uuid, filtrar por unidad)
- `type` (enum, filtrar por tipo)
- `from` (date, ISO 8601)
- `to` (date, ISO 8601)
- `status` (enum: scheduled, ongoing, completed, cancelled)
- `page`, `limit` (paginación)

**Response**:
```json
{
  "events": [
    {
      "id": "uuid-event",
      "school_id": "uuid-school",
      "title": "Reunión de Padres - 1er Grado",
      "description": "Reunión informativa sobre progreso académico",
      "type": "reunion_padres",
      "start_date": "2024-12-05T18:00:00Z",
      "end_date": "2024-12-05T20:00:00Z",
      "location": "Auditorio Principal",
      "classroom_id": "uuid-classroom",
      "units": [
        {"id": "uuid-unit", "name": "1er Grado"}
      ],
      "organizer_id": "uuid-user",
      "organizer_name": "Directora Ana López",
      "participants_count": 45,
      "status": "scheduled",
      "created_at": "2024-11-20T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 35
  }
}
```

---

#### 9.2 Obtener Detalle de Evento
```
GET /v1/events/:id
```

**Response**:
```json
{
  "id": "uuid-event",
  "school_id": "uuid-school",
  "title": "Examen Final de Matemáticas",
  "description": "Evaluación final del trimestre",
  "type": "examen",
  "start_date": "2024-12-10T09:00:00Z",
  "end_date": "2024-12-10T11:00:00Z",
  "location": "Aula 201",
  "classroom_id": "uuid-classroom",
  "subject_id": "uuid-subject",
  "subject_name": "Matemáticas",
  "units": [
    {"id": "uuid-unit", "name": "Sección A - 1er Grado"}
  ],
  "organizer_id": "uuid-teacher",
  "organizer_name": "Prof. Roberto Sánchez",
  "participants": [
    {
      "user_id": "uuid-student-1",
      "name": "Juan Pérez",
      "role": "student",
      "attendance": null
    }
  ],
  "attachments": [
    {
      "name": "Temario_Examen.pdf",
      "url": "https://cdn.edugo.com/events/uuid-event/temario.pdf",
      "size": 125678
    }
  ],
  "notifications_sent": true,
  "status": "scheduled",
  "created_at": "2024-11-15T10:00:00Z",
  "updated_at": "2024-11-20T14:30:00Z"
}
```

---

#### 9.3 Crear Evento
```
POST /v1/events
```

**Request Body**:
```json
{
  "school_id": "uuid-school",
  "title": "Feria de Ciencias 2024",
  "description": "Exhibición de proyectos científicos de todos los grados",
  "type": "actividad_extracurricular",
  "start_date": "2024-12-15T10:00:00Z",
  "end_date": "2024-12-15T16:00:00Z",
  "location": "Gimnasio",
  "classroom_id": "uuid-classroom-gimnasio",
  "units": ["uuid-unit-1", "uuid-unit-2"],
  "organizer_id": "uuid-director",
  "send_notifications": true
}
```

**Validaciones**:
- `title`: requerido, 5-200 caracteres
- `start_date`: requerido, fecha futura
- `end_date`: requerido, debe ser >= start_date
- `type`: enum (examen, reunion_padres, festividad, actividad_extracurricular, capacitacion_docente, otro)
- `units`: array de UUIDs de unidades participantes
- `classroom_id`: opcional, debe estar disponible en ese horario

**Response**: Objeto event creado

---

#### 9.4 Actualizar Evento
```
PUT /v1/events/:id
```

**Request Body**: Similar a POST

**Validaciones**:
- Si cambian fechas/ubicación y ya hay participantes confirmados, enviar notificación de cambio

---

#### 9.5 Cancelar Evento
```
PATCH /v1/events/:id/cancel
```

**Request Body**:
```json
{
  "reason": "Condiciones climáticas adversas",
  "send_notifications": true
}
```

**Response**:
```json
{
  "id": "uuid-event",
  "status": "cancelled",
  "cancelled_at": "2024-12-01T10:00:00Z",
  "cancel_reason": "Condiciones climáticas adversas",
  "notifications_sent": true
}
```

---

#### 9.6 Registrar Asistencia a Evento
```
POST /v1/events/:id/attendance
```

**Request Body**:
```json
{
  "participants": [
    {"user_id": "uuid-student-1", "attended": true},
    {"user_id": "uuid-student-2", "attended": false},
    {"user_id": "uuid-student-3", "attended": true}
  ]
}
```

**Response**:
```json
{
  "event_id": "uuid-event",
  "total_registered": 30,
  "attended": 28,
  "absent": 2,
  "attendance_rate": 93.3
}
```

---

### Modelo de Datos Sugerido

```go
type Event struct {
    ID                uuid.UUID      `gorm:"type:uuid;primary_key"`
    SchoolID          uuid.UUID      `gorm:"type:uuid;not null;index"`
    Title             string         `gorm:"size:200;not null"`
    Description       string         `gorm:"type:text"`
    Type              string         `gorm:"size:50;not null;index"`
    StartDate         time.Time      `gorm:"not null;index"`
    EndDate           time.Time      `gorm:"not null"`
    Location          string         `gorm:"size:200"`
    ClassroomID       *uuid.UUID     `gorm:"type:uuid;index"`
    SubjectID         *uuid.UUID     `gorm:"type:uuid;index"`
    OrganizerID       uuid.UUID      `gorm:"type:uuid;not null"`
    NotificationsSent bool           `gorm:"default:false"`
    Status            string         `gorm:"size:20;default:scheduled"` // scheduled, ongoing, completed, cancelled
    CancelReason      string         `gorm:"size:500"`
    CancelledAt       *time.Time
    CreatedAt         time.Time
    UpdatedAt         time.Time
    DeletedAt         *time.Time     `gorm:"index"`
    
    School     School      `gorm:"foreignKey:SchoolID"`
    Classroom  *Classroom  `gorm:"foreignKey:ClassroomID"`
    Subject    *Subject    `gorm:"foreignKey:SubjectID"`
    Organizer  User        `gorm:"foreignKey:OrganizerID"`
    Units      []Unit      `gorm:"many2many:event_units;"`
    Participants []EventParticipant `gorm:"foreignKey:EventID"`
    Attachments []EventAttachment `gorm:"foreignKey:EventID"`
}

type EventParticipant struct {
    ID         uuid.UUID  `gorm:"type:uuid;primary_key"`
    EventID    uuid.UUID  `gorm:"type:uuid;not null;index"`
    UserID     uuid.UUID  `gorm:"type:uuid;not null;index"`
    Role       string     `gorm:"size:20"` // organizer, participant, observer
    Attended   *bool      // Null = no registrado, true/false = asistió o no
    CreatedAt  time.Time
    
    Event Event `gorm:"foreignKey:EventID"`
    User  User  `gorm:"foreignKey:UserID"`
}

type EventAttachment struct {
    ID        uuid.UUID `gorm:"type:uuid;primary_key"`
    EventID   uuid.UUID `gorm:"type:uuid;not null;index"`
    Name      string    `gorm:"size:200;not null"`
    FileURL   string    `gorm:"size:500;not null"`
    FileSize  int64
    UploadedBy uuid.UUID `gorm:"type:uuid;not null"`
    CreatedAt time.Time
    
    Event Event `gorm:"foreignKey:EventID"`
    User  User  `gorm:"foreignKey:UploadedBy"`
}
```

---

### Tipos de Eventos Sugeridos

1. **examen**: Evaluaciones académicas
2. **reunion_padres**: Reuniones con tutores
3. **festividad**: Celebraciones, ceremonias
4. **actividad_extracurricular**: Deportes, arte, clubes
5. **capacitacion_docente**: Formación de profesores
6. **junta_docentes**: Reuniones de personal
7. **otro**: Eventos no categorizados

---

### Permisos
- **super_admin**: CRUD completo
- **director_escuela**: CRUD en su escuela
- **director_academico**: CRUD en su escuela
- **coordinador**: CRUD en eventos de sus unidades
- **teacher**: Crear eventos de sus materias, editar los que organizó
- **student/parent**: Solo lectura de eventos que les aplican

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **EventsView**: CRUD completo, calendario visual
2. **DashboardAdminView**: Próximos eventos
3. **ClassroomsView**: Reservas de aulas para eventos
4. **App Principal**: Calendario de estudiante/tutor con eventos

---

## 10. Configuración de Notificaciones

### Descripción
Configuración de notificaciones push, email y SMS por tipo de evento.

### Endpoints Sugeridos

#### 10.1 Obtener Configuración de Notificaciones
```
GET /v1/notifications/config
```

**Response**:
```json
{
  "user_id": "uuid-user",
  "channels": {
    "email": {
      "enabled": true,
      "address": "juan.perez@ejemplo.com",
      "verified": true
    },
    "push": {
      "enabled": true,
      "devices": [
        {
          "device_id": "token-fcm-123",
          "platform": "android",
          "registered_at": "2024-09-01T10:00:00Z"
        }
      ]
    },
    "sms": {
      "enabled": false,
      "phone": "+34 612345678",
      "verified": false
    }
  },
  "preferences": [
    {
      "event_type": "new_material",
      "email": true,
      "push": true,
      "sms": false
    },
    {
      "event_type": "grade_posted",
      "email": true,
      "push": true,
      "sms": false
    },
    {
      "event_type": "event_reminder",
      "email": true,
      "push": true,
      "sms": false
    },
    {
      "event_type": "payment_due",
      "email": true,
      "push": true,
      "sms": true
    }
  ]
}
```

---

#### 10.2 Actualizar Preferencias de Notificaciones
```
PATCH /v1/notifications/config
```

**Request Body**:
```json
{
  "channels": {
    "email": {
      "enabled": true
    },
    "push": {
      "enabled": true
    },
    "sms": {
      "enabled": true
    }
  },
  "preferences": [
    {
      "event_type": "new_material",
      "email": true,
      "push": true,
      "sms": false
    },
    {
      "event_type": "payment_due",
      "email": true,
      "push": true,
      "sms": true
    }
  ]
}
```

**Response**: Configuración actualizada

---

#### 10.3 Registrar Dispositivo para Push Notifications
```
POST /v1/notifications/devices
```

**Request Body**:
```json
{
  "device_id": "token-fcm-abc123",
  "platform": "ios",
  "app_version": "1.2.0"
}
```

**Response**:
```json
{
  "device_id": "token-fcm-abc123",
  "platform": "ios",
  "registered_at": "2024-11-28T15:00:00Z",
  "active": true
}
```

---

#### 10.4 Eliminar Dispositivo
```
DELETE /v1/notifications/devices/:device_id
```

---

### Modelo de Datos Sugerido

```go
type NotificationConfig struct {
    UserID        uuid.UUID `gorm:"type:uuid;primary_key"`
    EmailEnabled  bool      `gorm:"default:true"`
    PushEnabled   bool      `gorm:"default:true"`
    SMSEnabled    bool      `gorm:"default:false"`
    Preferences   JSON      `gorm:"type:jsonb"` // Array de event_type + channels
    UpdatedAt     time.Time
    
    User User `gorm:"foreignKey:UserID"`
}

type NotificationDevice struct {
    ID           uuid.UUID `gorm:"type:uuid;primary_key"`
    UserID       uuid.UUID `gorm:"type:uuid;not null;index"`
    DeviceID     string    `gorm:"size:500;not null;unique"` // FCM/APNS token
    Platform     string    `gorm:"size:20;not null"` // ios, android, web
    AppVersion   string    `gorm:"size:20"`
    Active       bool      `gorm:"default:true;index"`
    RegisteredAt time.Time `gorm:"not null"`
    LastUsedAt   *time.Time
    
    User User `gorm:"foreignKey:UserID"`
}
```

---

### Tipos de Eventos de Notificación Sugeridos

1. **new_material**: Nuevo material educativo publicado
2. **grade_posted**: Nueva calificación registrada
3. **event_reminder**: Recordatorio de evento próximo (24h antes)
4. **payment_due**: Pago próximo a vencer
5. **payment_overdue**: Pago vencido
6. **attendance_alert**: Inasistencia registrada
7. **message_received**: Nuevo mensaje de docente/admin
8. **announcement**: Anuncio general de la escuela
9. **schedule_change**: Cambio en horario
10. **emergency**: Notificación de emergencia

---

### Permisos
- **Todos los usuarios**: Gestionar sus propias preferencias
- **super_admin/director_escuela**: Ver configuraciones globales (estadísticas)

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **UserDetailView**: Configurar preferencias de notificaciones
2. **SettingsView** (app principal): Gestionar dispositivos y canales
3. **Todas las apps**: Recibir y mostrar notificaciones push

---

## 11. Pagos y Finanzas

### Descripción
Gestión de conceptos de pago, registro de pagos y estados financieros de estudiantes.

### Endpoints Sugeridos

#### 11.1 Listar Conceptos de Pago
```
GET /v1/payment-concepts
```

**Query Parameters**:
- `school_id` (uuid)
- `cycle_id` (uuid)
- `active` (boolean)

**Response**:
```json
{
  "concepts": [
    {
      "id": "uuid-concept",
      "school_id": "uuid-school",
      "name": "Matrícula",
      "code": "MAT",
      "description": "Inscripción anual",
      "amount": 500.00,
      "currency": "EUR",
      "recurrence": "anual",
      "category": "inscripcion",
      "active": true
    },
    {
      "id": "uuid-concept-2",
      "name": "Mensualidad",
      "code": "MEN",
      "description": "Cuota mensual",
      "amount": 150.00,
      "currency": "EUR",
      "recurrence": "mensual",
      "category": "mensualidad",
      "active": true
    }
  ]
}
```

---

#### 11.2 Crear Concepto de Pago
```
POST /v1/payment-concepts
```

**Request Body**:
```json
{
  "school_id": "uuid-school",
  "name": "Seguro Escolar",
  "code": "SEG",
  "description": "Seguro de accidentes escolares",
  "amount": 75.00,
  "currency": "EUR",
  "recurrence": "anual",
  "category": "otros",
  "active": true
}
```

---

#### 11.3 Listar Pagos de Estudiante
```
GET /v1/payments?student_id={id}&cycle_id={id}&status={status}
```

**Query Parameters**:
- `student_id` (uuid)
- `cycle_id` (uuid)
- `status` (enum: pendiente, pagado, vencido, anulado)
- `from`, `to` (fechas)
- `page`, `limit`

**Response**:
```json
{
  "payments": [
    {
      "id": "uuid-payment",
      "student_id": "uuid-student",
      "student_name": "Juan Pérez",
      "concept_id": "uuid-concept",
      "concept_name": "Mensualidad Octubre 2024",
      "amount": 150.00,
      "currency": "EUR",
      "due_date": "2024-10-05",
      "paid_date": "2024-10-03T10:30:00Z",
      "status": "pagado",
      "payment_method": "transferencia",
      "reference": "TRF-20241003-001",
      "created_at": "2024-09-25T10:00:00Z"
    },
    {
      "id": "uuid-payment-2",
      "student_id": "uuid-student",
      "student_name": "Juan Pérez",
      "concept_id": "uuid-concept",
      "concept_name": "Mensualidad Noviembre 2024",
      "amount": 150.00,
      "currency": "EUR",
      "due_date": "2024-11-05",
      "paid_date": null,
      "status": "pendiente",
      "payment_method": null,
      "reference": null,
      "created_at": "2024-10-25T10:00:00Z"
    }
  ],
  "summary": {
    "total_pending": 150.00,
    "total_paid": 150.00,
    "total_overdue": 0.00
  }
}
```

---

#### 11.4 Registrar Pago
```
POST /v1/payments
```

**Request Body** (Crear cargo pendiente):
```json
{
  "student_id": "uuid-student",
  "concept_id": "uuid-concept",
  "amount": 150.00,
  "currency": "EUR",
  "due_date": "2024-12-05",
  "notes": "Mensualidad Diciembre 2024"
}
```

**Request Body** (Registrar pago realizado):
```json
{
  "payment_id": "uuid-payment",
  "paid_date": "2024-11-28T14:30:00Z",
  "payment_method": "efectivo",
  "reference": "REC-001234",
  "amount": 150.00,
  "notes": "Pago en oficina"
}
```

**Validaciones**:
- `student_id`: requerido, debe existir
- `concept_id`: requerido, debe existir y estar activo
- `amount`: requerido, > 0
- `due_date`: requerido, fecha futura o presente
- `payment_method`: enum (efectivo, transferencia, tarjeta, cheque, online)

**Response**: Objeto payment creado/actualizado

---

#### 11.5 Anular Pago
```
PATCH /v1/payments/:id/void
```

**Request Body**:
```json
{
  "reason": "Duplicado por error"
}
```

**Response**:
```json
{
  "id": "uuid-payment",
  "status": "anulado",
  "void_reason": "Duplicado por error",
  "voided_at": "2024-11-28T15:00:00Z"
}
```

---

#### 11.6 Generar Recibo de Pago
```
GET /v1/payments/:id/receipt
```

**Response**: PDF con recibo oficial del pago.

---

### Modelo de Datos Sugerido

```go
type PaymentConcept struct {
    ID          uuid.UUID `gorm:"type:uuid;primary_key"`
    SchoolID    uuid.UUID `gorm:"type:uuid;not null;index"`
    Name        string    `gorm:"size:100;not null"`
    Code        string    `gorm:"size:20;not null;uniqueIndex:idx_school_concept_code"`
    Description string    `gorm:"size:500"`
    Amount      float64   `gorm:"not null"`
    Currency    string    `gorm:"size:3;default:EUR"` // ISO 4217
    Recurrence  string    `gorm:"size:20"` // anual, mensual, trimestral, unico
    Category    string    `gorm:"size:50;index"` // inscripcion, mensualidad, uniforme, libros, otros
    Active      bool      `gorm:"default:true"`
    CreatedAt   time.Time
    UpdatedAt   time.Time
    
    School   School    `gorm:"foreignKey:SchoolID"`
    Payments []Payment `gorm:"foreignKey:ConceptID"`
}

type Payment struct {
    ID            uuid.UUID  `gorm:"type:uuid;primary_key"`
    StudentID     uuid.UUID  `gorm:"type:uuid;not null;index"`
    ConceptID     uuid.UUID  `gorm:"type:uuid;not null;index"`
    Amount        float64    `gorm:"not null"`
    Currency      string     `gorm:"size:3;default:EUR"`
    DueDate       time.Time  `gorm:"not null;index"`
    PaidDate      *time.Time
    Status        string     `gorm:"size:20;not null;index"` // pendiente, pagado, vencido, anulado
    PaymentMethod string     `gorm:"size:50"` // efectivo, transferencia, tarjeta, cheque, online
    Reference     string     `gorm:"size:100"` // Número de transacción/recibo
    Notes         string     `gorm:"size:500"`
    VoidReason    string     `gorm:"size:500"`
    VoidedAt      *time.Time
    CreatedAt     time.Time
    UpdatedAt     time.Time
    
    Student User           `gorm:"foreignKey:StudentID"`
    Concept PaymentConcept `gorm:"foreignKey:ConceptID"`
}
```

---

### Estados de Pago

1. **pendiente**: Cargo creado, aún no pagado, dentro de fecha
2. **pagado**: Pago realizado y confirmado
3. **vencido**: Pago pendiente con fecha vencida
4. **anulado**: Pago cancelado/invalidado

**Cambio automático de estado**:
- `pendiente` → `vencido`: Si `due_date < now()` y no está pagado
- `pendiente/vencido` → `pagado`: Al registrar `paid_date`

---

### Permisos
- **super_admin**: CRUD completo de conceptos y pagos
- **director_escuela**: CRUD en su escuela
- **parent**: Ver pagos de sus hijos, realizar pagos online (futuro)
- **Otros roles**: Sin acceso (o solo lectura limitada)

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **PaymentsView**: CRUD completo de conceptos y pagos
2. **UserDetailView** (estudiante): Estado de cuenta
3. **DashboardAdminView**: Resumen financiero (ingresos, deudas)
4. **ReportsView**: Reportes financieros
5. **App Principal** (tutor): Ver y pagar mensualidades

---

## 12. Importación Masiva

### Descripción
Importación de datos desde archivos Excel/CSV con validación y rollback.

### Endpoints Sugeridos

#### 12.1 Descargar Plantilla
```
GET /v1/import/templates/{entity}
```

**Parámetros**:
- `entity`: users, units, memberships, subjects

**Response**: Archivo Excel con columnas predefinidas y ejemplos.

**Ejemplo de plantilla `users.xlsx`**:
```
| name          | email                  | role      | phone          | school_code | date_of_birth | address        | city   | country |
|---------------|------------------------|-----------|----------------|-------------|---------------|----------------|--------|---------|
| Juan Pérez    | juan.perez@ejemplo.com | student   | +34 612345678  | ESP-001     | 2010-03-15    | Calle Ej. 123  | Madrid | España  |
| María García  | maria.g@ejemplo.com    | student   | +34 687654321  | ESP-001     | 2010-08-20    | Av. Prin. 456  | Madrid | España  |
```

---

#### 12.2 Validar Archivo de Importación
```
POST /v1/import/validate
```

**Request**: Multipart form-data con archivo Excel/CSV

**Form Fields**:
- `file`: archivo (.xlsx, .csv)
- `entity`: tipo de entidad (users, units, memberships, subjects)
- `school_id`: uuid de escuela (si aplica)

**Response** (Validación exitosa):
```json
{
  "valid": true,
  "total_rows": 150,
  "valid_rows": 148,
  "invalid_rows": 2,
  "warnings": [],
  "errors": [
    {
      "row": 45,
      "field": "email",
      "message": "Email duplicado: juan.perez@ejemplo.com ya existe"
    },
    {
      "row": 102,
      "field": "date_of_birth",
      "message": "Formato de fecha inválido: '15-03-2010' (esperado: YYYY-MM-DD)"
    }
  ]
}
```

**Response** (Validación fallida):
```json
{
  "valid": false,
  "total_rows": 50,
  "valid_rows": 0,
  "invalid_rows": 50,
  "errors": [
    {
      "row": 0,
      "field": "headers",
      "message": "Columna requerida faltante: 'email'"
    }
  ]
}
```

---

#### 12.3 Ejecutar Importación
```
POST /v1/import/execute
```

**Request**: Multipart form-data

**Form Fields**:
- `file`: archivo (.xlsx, .csv)
- `entity`: tipo de entidad
- `school_id`: uuid (si aplica)
- `skip_errors`: boolean (default: false) - Si true, omite filas con error y continúa

**Validaciones**:
- El archivo debe haber sido validado previamente
- Solo proceder si `valid_rows > 0`
- Confirmar acción (puede ser destructivo)

**Response** (202 Accepted):
```json
{
  "job_id": "uuid-job",
  "status": "queued",
  "message": "La importación se está procesando. Recibirás una notificación cuando termine."
}
```

---

#### 12.4 Consultar Estado de Importación
```
GET /v1/import/jobs/:job_id
```

**Response** (En progreso):
```json
{
  "job_id": "uuid-job",
  "status": "processing",
  "progress": 60,
  "total_rows": 150,
  "processed_rows": 90,
  "created_count": 85,
  "updated_count": 3,
  "error_count": 2,
  "started_at": "2024-11-28T15:00:00Z",
  "estimated_completion": "2024-11-28T15:05:00Z"
}
```

**Response** (Completado):
```json
{
  "job_id": "uuid-job",
  "status": "completed",
  "progress": 100,
  "total_rows": 150,
  "processed_rows": 150,
  "created_count": 148,
  "updated_count": 0,
  "error_count": 2,
  "errors": [
    {
      "row": 45,
      "message": "Email duplicado: juan.perez@ejemplo.com"
    },
    {
      "row": 102,
      "message": "Fecha de nacimiento inválida"
    }
  ],
  "started_at": "2024-11-28T15:00:00Z",
  "completed_at": "2024-11-28T15:04:35Z",
  "report_url": "https://cdn.edugo.com/imports/uuid-job-report.xlsx"
}
```

**Response** (Error crítico):
```json
{
  "job_id": "uuid-job",
  "status": "failed",
  "error": "Error de conexión con base de datos",
  "rollback": true,
  "message": "La importación fue revertida debido a un error crítico",
  "started_at": "2024-11-28T15:00:00Z",
  "failed_at": "2024-11-28T15:02:18Z"
}
```

---

### Modelo de Datos Sugerido

```go
type ImportJob struct {
    ID              uuid.UUID  `gorm:"type:uuid;primary_key"`
    UserID          uuid.UUID  `gorm:"type:uuid;not null;index"`
    Entity          string     `gorm:"size:50;not null"` // users, units, memberships, subjects
    SchoolID        *uuid.UUID `gorm:"type:uuid;index"`
    FileName        string     `gorm:"size:200"`
    FileURL         string     `gorm:"size:500"`
    Status          string     `gorm:"size:20;not null;index"` // queued, processing, completed, failed
    Progress        int        `gorm:"default:0"` // 0-100
    TotalRows       int
    ProcessedRows   int
    CreatedCount    int
    UpdatedCount    int
    ErrorCount      int
    Errors          JSON       `gorm:"type:jsonb"` // Array de errores con row + message
    SkipErrors      bool       `gorm:"default:false"`
    Rollback        bool       `gorm:"default:false"`
    ReportURL       string     `gorm:"size:500"`
    StartedAt       *time.Time
    CompletedAt     *time.Time
    FailedAt        *time.Time
    CreatedAt       time.Time
    
    User   User    `gorm:"foreignKey:UserID"`
    School *School `gorm:"foreignKey:SchoolID"`
}
```

---

### Entidades Importables

#### 1. Usuarios (users)
**Columnas requeridas**:
- name
- email
- role (student, teacher, parent, coordinator)
- school_code (código único de escuela)

**Columnas opcionales**:
- phone
- date_of_birth
- address, city, country
- metadata (JSON string o columnas adicionales)

**Validaciones**:
- Email único
- Role válido
- School_code debe existir
- Formato de fecha: YYYY-MM-DD

---

#### 2. Unidades Académicas (units)
**Columnas requeridas**:
- name
- type (nivel, grado, seccion, grupo)
- school_code
- parent_name (opcional, nombre de unidad padre)

**Columnas opcionales**:
- capacity
- description
- order

**Validaciones**:
- Jerarquía válida (tipo de padre compatible)
- School_code debe existir
- Parent_name debe existir (si se proporciona)

---

#### 3. Membresías (memberships)
**Columnas requeridas**:
- user_email (email del usuario)
- unit_name (nombre de unidad)
- role (student, teacher, coordinator)
- school_code

**Columnas opcionales**:
- enrolled_at (default: now)
- expires_at

**Validaciones**:
- user_email debe existir
- unit_name debe existir en school_code
- role compatible con tipo de usuario

---

#### 4. Materias (subjects)
**Columnas requeridas**:
- name
- code
- unit_name (nombre de unidad)
- school_code

**Columnas opcionales**:
- teacher_email (asignar docente)
- hours_per_week
- description

**Validaciones**:
- code único por escuela
- unit_name debe existir
- teacher_email debe existir y ser docente

---

### Permisos
- **super_admin**: Importar en cualquier escuela
- **director_escuela**: Importar en su escuela
- **director_academico**: Importar usuarios y membresías académicas
- **Otros roles**: Sin acceso

---

### Impacto en UI
**Pantallas que lo usarían**:
1. **ImportView**: Cargar archivo, validar, ejecutar importación, ver resultados
2. **UsersListView**: Botón "Importar Usuarios"
3. **AcademicTreeView**: Botón "Importar Estructura"
4. **MembershipsView**: Botón "Importar Asignaciones"

---

## Resumen de Prioridades

### Alta Prioridad (Q1 2026)
1. ✅ Ciclos y Periodos Académicos
2. ✅ Horarios y Programación
3. ✅ Importación Masiva

### Media Prioridad (Q2 2026)
4. ✅ Aulas y Recursos
5. ✅ Eventos Escolares
6. ✅ Reportes Administrativos
7. ✅ Auditoría y Logs

### Baja Prioridad (Q3-Q4 2026)
8. ✅ Escalas de Calificación
9. ✅ Roles y Permisos Granulares
10. ✅ Certificados y Documentos
11. ✅ Configuración de Notificaciones
12. ✅ Pagos y Finanzas

---

**Última actualización**: 1 de Diciembre, 2025  
**Versión**: 1.0.0  
**Estado**: Planificación completa
