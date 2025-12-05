# Migraciones SQL - Fase Administración

> **Definiciones SQL completas** para las 12 tablas de la Fase Admin mencionadas en PLAN-TRABAJO-ORDENADO.md sección 1.2.

**Fecha**: 1 de Diciembre, 2025  
**Repositorio Destino**: edugo-infrastructure  
**Ubicación**: `/migrations/`

---

## Índice de Tablas

| # | Tabla | Sprint | Prioridad | Dependencias |
|---|-------|--------|-----------|--------------|
| 1 | `academic_cycles` | Admin Sprint 2 | 🟡 Media | schools |
| 2 | `academic_periods` | Admin Sprint 2 | 🟡 Media | academic_cycles |
| 3 | `schedules` | Admin Sprint 3 | 🟡 Media | academic_units, subjects, users, classrooms, academic_cycles |
| 4 | `schedule_blocks` | Admin Sprint 3 | 🟡 Media | schedules |
| 5 | `classrooms` | Admin Sprint 4 | 🟢 Baja | schools |
| 6 | `school_events` | Admin Sprint 4 | 🟢 Baja | schools, classrooms, academic_units |
| 7 | `import_jobs` | Admin Sprint 3 | 🟡 Media | schools, users |
| 8 | `grading_scales` | Admin Sprint 5 | 🟢 Baja | schools |
| 9 | `grading_scale_ranges` | Admin Sprint 5 | 🟢 Baja | grading_scales |
| 10 | `custom_roles` | Admin Sprint 5 | 🟢 Baja | schools |
| 11 | `role_permissions` | Admin Sprint 5 | 🟢 Baja | custom_roles |
| 12 | `certificates` | Admin Sprint 6 | 🟢 Baja | schools |
| 13 | `generated_certificates` | Admin Sprint 6 | 🟢 Baja | certificates, users |
| 14 | `fee_concepts` | Admin Sprint 6 | 🟢 Baja | schools, academic_cycles |
| 15 | `payments` | Admin Sprint 6 | 🟢 Baja | users, fee_concepts |

---

## Admin Sprint 2: Ciclos y Periodos Académicos

### 1. Tabla `academic_cycles`

**Propósito**: Representa un año escolar o ciclo académico completo (ej: "Ciclo 2024-2025").

```sql
-- Migración: 20251201_001_create_academic_cycles.sql

-- Enum para tipo de división del ciclo
CREATE TYPE cycle_division_type AS ENUM (
    'annual',       -- 1 periodo (todo el año)
    'semester',     -- 2 periodos (semestres)
    'trimester',    -- 3 periodos (trimestres)
    'quarter',      -- 4 periodos (cuatrimestres)
    'bimester'      -- 6 periodos (bimestres)
);

CREATE TABLE academic_cycles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    
    -- Información básica
    name VARCHAR(200) NOT NULL,           -- "Ciclo Escolar 2024-2025"
    code VARCHAR(50) NOT NULL,            -- "2024-2025" (único por escuela)
    description TEXT,
    
    -- Fechas del ciclo
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
    -- Configuración
    division_type cycle_division_type NOT NULL DEFAULT 'trimester',
    
    -- Estado
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_current BOOLEAN NOT NULL DEFAULT false,  -- Solo uno puede ser current por escuela
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT uq_academic_cycles_school_code UNIQUE(school_id, code),
    CONSTRAINT chk_academic_cycles_dates CHECK (end_date > start_date),
    CONSTRAINT chk_academic_cycles_duration CHECK (
        end_date - start_date >= INTERVAL '30 days' AND
        end_date - start_date <= INTERVAL '730 days'
    )
);

-- Índices
CREATE INDEX idx_academic_cycles_school ON academic_cycles(school_id);
CREATE INDEX idx_academic_cycles_active ON academic_cycles(school_id, is_active) WHERE is_active = true;
CREATE INDEX idx_academic_cycles_current ON academic_cycles(school_id, is_current) WHERE is_current = true;
CREATE INDEX idx_academic_cycles_dates ON academic_cycles(start_date, end_date);
CREATE INDEX idx_academic_cycles_deleted ON academic_cycles(deleted_at) WHERE deleted_at IS NULL;

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_academic_cycles
    BEFORE UPDATE ON academic_cycles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para asegurar solo un ciclo current por escuela
CREATE OR REPLACE FUNCTION ensure_single_current_cycle()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_current = true THEN
        UPDATE academic_cycles 
        SET is_current = false 
        WHERE school_id = NEW.school_id 
          AND id != NEW.id 
          AND is_current = true;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_single_current_cycle
    BEFORE INSERT OR UPDATE OF is_current ON academic_cycles
    FOR EACH ROW
    WHEN (NEW.is_current = true)
    EXECUTE FUNCTION ensure_single_current_cycle();

COMMENT ON TABLE academic_cycles IS 'Ciclos académicos (años escolares) de cada escuela';
COMMENT ON COLUMN academic_cycles.is_current IS 'Solo un ciclo puede ser el actual por escuela';
COMMENT ON COLUMN academic_cycles.division_type IS 'Determina cuántos periodos se generan automáticamente';
```

---

### 2. Tabla `academic_periods`

**Propósito**: Subdivisiones de un ciclo académico (semestres, trimestres, bimestres).

```sql
-- Migración: 20251201_002_create_academic_periods.sql

CREATE TABLE academic_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cycle_id UUID NOT NULL REFERENCES academic_cycles(id) ON DELETE CASCADE,
    
    -- Información básica
    name VARCHAR(100) NOT NULL,           -- "Primer Trimestre", "Semestre 1"
    code VARCHAR(20) NOT NULL,            -- "T1", "S1", "B1"
    
    -- Fechas del periodo
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
    -- Orden dentro del ciclo
    sequence_order SMALLINT NOT NULL,     -- 1, 2, 3...
    
    -- Estado
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_current BOOLEAN NOT NULL DEFAULT false,
    
    -- Configuración de calificaciones
    grade_weight DECIMAL(5,2) DEFAULT 100.00,  -- Peso porcentual en calificación final
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT uq_academic_periods_cycle_code UNIQUE(cycle_id, code),
    CONSTRAINT uq_academic_periods_cycle_order UNIQUE(cycle_id, sequence_order),
    CONSTRAINT chk_academic_periods_dates CHECK (end_date > start_date),
    CONSTRAINT chk_academic_periods_order CHECK (sequence_order > 0),
    CONSTRAINT chk_academic_periods_weight CHECK (grade_weight >= 0 AND grade_weight <= 100)
);

-- Índices
CREATE INDEX idx_academic_periods_cycle ON academic_periods(cycle_id);
CREATE INDEX idx_academic_periods_current ON academic_periods(cycle_id, is_current) WHERE is_current = true;
CREATE INDEX idx_academic_periods_dates ON academic_periods(start_date, end_date);
CREATE INDEX idx_academic_periods_order ON academic_periods(cycle_id, sequence_order);

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_academic_periods
    BEFORE UPDATE ON academic_periods
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para asegurar solo un periodo current por ciclo
CREATE OR REPLACE FUNCTION ensure_single_current_period()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_current = true THEN
        UPDATE academic_periods 
        SET is_current = false 
        WHERE cycle_id = NEW.cycle_id 
          AND id != NEW.id 
          AND is_current = true;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_single_current_period
    BEFORE INSERT OR UPDATE OF is_current ON academic_periods
    FOR EACH ROW
    WHEN (NEW.is_current = true)
    EXECUTE FUNCTION ensure_single_current_period();

-- Trigger para validar que fechas estén dentro del ciclo
CREATE OR REPLACE FUNCTION validate_period_dates()
RETURNS TRIGGER AS $$
DECLARE
    cycle_start DATE;
    cycle_end DATE;
BEGIN
    SELECT start_date, end_date INTO cycle_start, cycle_end
    FROM academic_cycles WHERE id = NEW.cycle_id;
    
    IF NEW.start_date < cycle_start OR NEW.end_date > cycle_end THEN
        RAISE EXCEPTION 'Las fechas del periodo deben estar dentro del rango del ciclo académico (% - %)', 
            cycle_start, cycle_end;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_period_dates
    BEFORE INSERT OR UPDATE ON academic_periods
    FOR EACH ROW
    EXECUTE FUNCTION validate_period_dates();

COMMENT ON TABLE academic_periods IS 'Periodos dentro de un ciclo académico (trimestres, semestres, etc.)';
COMMENT ON COLUMN academic_periods.sequence_order IS 'Orden del periodo dentro del ciclo (1=primero, 2=segundo, etc.)';
COMMENT ON COLUMN academic_periods.grade_weight IS 'Peso porcentual de este periodo en la calificación final del ciclo';
```

---

## Admin Sprint 3: Horarios e Importación

### 3. Tabla `classrooms` (prerequisito para schedules)

**Propósito**: Aulas, laboratorios y espacios físicos de la escuela.

```sql
-- Migración: 20251201_003_create_classrooms.sql

-- Enum para tipo de espacio
CREATE TYPE classroom_type AS ENUM (
    'standard',         -- Aula regular
    'laboratory',       -- Laboratorio de ciencias
    'computer_lab',     -- Sala de cómputo
    'library',          -- Biblioteca
    'gymnasium',        -- Gimnasio
    'auditorium',       -- Auditorio
    'workshop',         -- Taller
    'music_room',       -- Sala de música
    'art_room',         -- Sala de arte
    'meeting_room',     -- Sala de reuniones
    'outdoor',          -- Espacio al aire libre
    'other'             -- Otro
);

CREATE TABLE classrooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    
    -- Información básica
    name VARCHAR(100) NOT NULL,           -- "Aula 201", "Laboratorio de Química"
    code VARCHAR(50) NOT NULL,            -- "A-201", "LAB-QUIM-01"
    type classroom_type NOT NULL DEFAULT 'standard',
    description TEXT,
    
    -- Ubicación física
    building VARCHAR(100),                -- "Edificio A", "Módulo Norte"
    floor SMALLINT,                       -- Número de piso (puede ser negativo para sótanos)
    
    -- Capacidad
    capacity SMALLINT NOT NULL,           -- Máximo de personas
    
    -- Equipamiento (array de tags)
    equipment TEXT[] DEFAULT '{}',        -- ['proyector', 'pizarra_digital', 'aire_acondicionado']
    
    -- Accesibilidad
    wheelchair_accessible BOOLEAN DEFAULT false,
    has_elevator_access BOOLEAN DEFAULT false,
    
    -- Estado
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_available BOOLEAN NOT NULL DEFAULT true,  -- Puede estar en mantenimiento
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT uq_classrooms_school_code UNIQUE(school_id, code),
    CONSTRAINT chk_classrooms_capacity CHECK (capacity > 0 AND capacity <= 500)
);

-- Índices
CREATE INDEX idx_classrooms_school ON classrooms(school_id);
CREATE INDEX idx_classrooms_type ON classrooms(school_id, type);
CREATE INDEX idx_classrooms_available ON classrooms(school_id, is_available) WHERE is_available = true;
CREATE INDEX idx_classrooms_capacity ON classrooms(school_id, capacity);
CREATE INDEX idx_classrooms_building ON classrooms(school_id, building);
CREATE INDEX idx_classrooms_deleted ON classrooms(deleted_at) WHERE deleted_at IS NULL;

-- Índice GIN para búsqueda en equipment
CREATE INDEX idx_classrooms_equipment ON classrooms USING GIN(equipment);

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_classrooms
    BEFORE UPDATE ON classrooms
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE classrooms IS 'Espacios físicos de la escuela (aulas, laboratorios, etc.)';
COMMENT ON COLUMN classrooms.equipment IS 'Lista de equipamiento disponible en el espacio';
COMMENT ON COLUMN classrooms.is_available IS 'False si está en mantenimiento o no disponible temporalmente';
```

---

### 4. Tabla `schedules`

**Propósito**: Horarios de clases (asignación de materia, docente, aula, día/hora).

```sql
-- Migración: 20251201_004_create_schedules.sql

-- Enum para recurrencia
CREATE TYPE schedule_recurrence AS ENUM (
    'weekly',           -- Cada semana
    'biweekly',         -- Cada dos semanas
    'monthly',          -- Una vez al mes
    'once'              -- Evento único
);

CREATE TABLE schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Referencias principales
    unit_id UUID NOT NULL REFERENCES academic_units(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE RESTRICT,
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    classroom_id UUID REFERENCES classrooms(id) ON DELETE SET NULL,
    cycle_id UUID NOT NULL REFERENCES academic_cycles(id) ON DELETE CASCADE,
    
    -- Temporalidad
    day_of_week SMALLINT NOT NULL,        -- 0=Domingo, 1=Lunes, ..., 6=Sábado
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    
    -- Recurrencia
    recurrence schedule_recurrence NOT NULL DEFAULT 'weekly',
    
    -- Fechas efectivas (para casos especiales)
    effective_from DATE,                  -- Null = desde inicio del ciclo
    effective_until DATE,                 -- Null = hasta fin del ciclo
    
    -- Estado
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Metadatos
    notes TEXT,                           -- Notas adicionales
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT chk_schedules_day CHECK (day_of_week >= 0 AND day_of_week <= 6),
    CONSTRAINT chk_schedules_time CHECK (end_time > start_time),
    CONSTRAINT chk_schedules_duration CHECK (
        end_time - start_time >= INTERVAL '15 minutes' AND
        end_time - start_time <= INTERVAL '6 hours'
    ),
    CONSTRAINT chk_schedules_effective_dates CHECK (
        effective_until IS NULL OR effective_from IS NULL OR 
        effective_until >= effective_from
    )
);

-- Índices para consultas frecuentes
CREATE INDEX idx_schedules_unit ON schedules(unit_id);
CREATE INDEX idx_schedules_teacher ON schedules(teacher_id);
CREATE INDEX idx_schedules_classroom ON schedules(classroom_id);
CREATE INDEX idx_schedules_cycle ON schedules(cycle_id);
CREATE INDEX idx_schedules_subject ON schedules(subject_id);
CREATE INDEX idx_schedules_day ON schedules(day_of_week);
CREATE INDEX idx_schedules_active ON schedules(is_active) WHERE is_active = true;

-- Índice compuesto para detección de conflictos de docente
CREATE INDEX idx_schedules_teacher_conflict ON schedules(
    teacher_id, cycle_id, day_of_week, start_time, end_time
) WHERE is_active = true;

-- Índice compuesto para detección de conflictos de aula
CREATE INDEX idx_schedules_classroom_conflict ON schedules(
    classroom_id, cycle_id, day_of_week, start_time, end_time
) WHERE is_active = true AND classroom_id IS NOT NULL;

-- Índice compuesto para detección de conflictos de unidad
CREATE INDEX idx_schedules_unit_conflict ON schedules(
    unit_id, cycle_id, day_of_week, start_time, end_time
) WHERE is_active = true;

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_schedules
    BEFORE UPDATE ON schedules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Función para detectar solapamiento de horarios
CREATE OR REPLACE FUNCTION check_schedule_conflicts()
RETURNS TRIGGER AS $$
DECLARE
    conflict_count INTEGER;
    conflict_type TEXT;
BEGIN
    -- Solo verificar si está activo
    IF NEW.is_active = false THEN
        RETURN NEW;
    END IF;

    -- Verificar conflicto de docente
    SELECT COUNT(*) INTO conflict_count
    FROM schedules s
    WHERE s.teacher_id = NEW.teacher_id
      AND s.cycle_id = NEW.cycle_id
      AND s.day_of_week = NEW.day_of_week
      AND s.is_active = true
      AND s.id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
      AND (
          (NEW.start_time >= s.start_time AND NEW.start_time < s.end_time) OR
          (NEW.end_time > s.start_time AND NEW.end_time <= s.end_time) OR
          (NEW.start_time <= s.start_time AND NEW.end_time >= s.end_time)
      );
    
    IF conflict_count > 0 THEN
        RAISE EXCEPTION 'Conflicto de horario: El docente ya tiene una clase asignada en ese horario';
    END IF;

    -- Verificar conflicto de aula (si se especificó)
    IF NEW.classroom_id IS NOT NULL THEN
        SELECT COUNT(*) INTO conflict_count
        FROM schedules s
        WHERE s.classroom_id = NEW.classroom_id
          AND s.cycle_id = NEW.cycle_id
          AND s.day_of_week = NEW.day_of_week
          AND s.is_active = true
          AND s.id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
          AND (
              (NEW.start_time >= s.start_time AND NEW.start_time < s.end_time) OR
              (NEW.end_time > s.start_time AND NEW.end_time <= s.end_time) OR
              (NEW.start_time <= s.start_time AND NEW.end_time >= s.end_time)
          );
        
        IF conflict_count > 0 THEN
            RAISE EXCEPTION 'Conflicto de horario: El aula ya está ocupada en ese horario';
        END IF;
    END IF;

    -- Verificar conflicto de unidad (grupo/sección)
    SELECT COUNT(*) INTO conflict_count
    FROM schedules s
    WHERE s.unit_id = NEW.unit_id
      AND s.cycle_id = NEW.cycle_id
      AND s.day_of_week = NEW.day_of_week
      AND s.is_active = true
      AND s.id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
      AND (
          (NEW.start_time >= s.start_time AND NEW.start_time < s.end_time) OR
          (NEW.end_time > s.start_time AND NEW.end_time <= s.end_time) OR
          (NEW.start_time <= s.start_time AND NEW.end_time >= s.end_time)
      );
    
    IF conflict_count > 0 THEN
        RAISE EXCEPTION 'Conflicto de horario: La sección ya tiene una clase asignada en ese horario';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_schedule_conflicts
    BEFORE INSERT OR UPDATE ON schedules
    FOR EACH ROW
    EXECUTE FUNCTION check_schedule_conflicts();

COMMENT ON TABLE schedules IS 'Horarios de clases: asignación de materia, docente, aula a día/hora';
COMMENT ON COLUMN schedules.day_of_week IS '0=Domingo, 1=Lunes, 2=Martes, 3=Miércoles, 4=Jueves, 5=Viernes, 6=Sábado';
COMMENT ON COLUMN schedules.effective_from IS 'Fecha desde la cual aplica este horario (null = desde inicio del ciclo)';
```

---

### 5. Tabla `schedule_blocks`

**Propósito**: Excepciones o modificaciones puntuales a un horario regular (cancelaciones, cambios de aula).

```sql
-- Migración: 20251201_005_create_schedule_blocks.sql

-- Enum para tipo de bloqueo/modificación
CREATE TYPE schedule_block_type AS ENUM (
    'cancelled',        -- Clase cancelada
    'rescheduled',      -- Reagendada a otro horario
    'room_change',      -- Cambio de aula
    'teacher_change',   -- Cambio de docente (suplente)
    'holiday',          -- Día feriado
    'special_event'     -- Evento especial que reemplaza la clase
);

CREATE TABLE schedule_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id UUID NOT NULL REFERENCES schedules(id) ON DELETE CASCADE,
    
    -- Tipo de modificación
    block_type schedule_block_type NOT NULL,
    
    -- Fecha específica afectada
    affected_date DATE NOT NULL,
    
    -- Para cambios de aula
    new_classroom_id UUID REFERENCES classrooms(id) ON DELETE SET NULL,
    
    -- Para cambios de docente (suplente)
    substitute_teacher_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    -- Para reagendamientos
    new_start_time TIME,
    new_end_time TIME,
    
    -- Información adicional
    reason TEXT,                          -- "Docente enfermo", "Feriado nacional"
    notes TEXT,
    
    -- Estado de notificación
    notification_sent BOOLEAN DEFAULT false,
    notification_sent_at TIMESTAMP WITH TIME ZONE,
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT uq_schedule_blocks_date UNIQUE(schedule_id, affected_date),
    CONSTRAINT chk_schedule_blocks_time CHECK (
        new_end_time IS NULL OR new_start_time IS NULL OR 
        new_end_time > new_start_time
    )
);

-- Índices
CREATE INDEX idx_schedule_blocks_schedule ON schedule_blocks(schedule_id);
CREATE INDEX idx_schedule_blocks_date ON schedule_blocks(affected_date);
CREATE INDEX idx_schedule_blocks_type ON schedule_blocks(block_type);

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_schedule_blocks
    BEFORE UPDATE ON schedule_blocks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE schedule_blocks IS 'Excepciones o modificaciones puntuales a horarios regulares';
COMMENT ON COLUMN schedule_blocks.affected_date IS 'Fecha específica en la que aplica esta excepción';
```

---

### 6. Tabla `import_jobs`

**Propósito**: Registro de importaciones masivas de datos (estudiantes, docentes, etc.).

```sql
-- Migración: 20251201_006_create_import_jobs.sql

-- Enum para tipo de importación
CREATE TYPE import_type AS ENUM (
    'students',         -- Importar estudiantes
    'teachers',         -- Importar docentes
    'guardians',        -- Importar tutores
    'memberships',      -- Importar membresías/inscripciones
    'subjects',         -- Importar materias
    'grades',           -- Importar calificaciones
    'attendance'        -- Importar asistencias
);

-- Enum para estado del job
CREATE TYPE import_status AS ENUM (
    'pending',          -- Pendiente de procesar
    'validating',       -- Validando datos
    'processing',       -- Procesando
    'completed',        -- Completado exitosamente
    'completed_with_errors',  -- Completado con algunos errores
    'failed',           -- Falló completamente
    'cancelled'         -- Cancelado por usuario
);

CREATE TABLE import_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    
    -- Tipo y origen
    import_type import_type NOT NULL,
    source_filename VARCHAR(255) NOT NULL,     -- Nombre del archivo original
    source_file_url TEXT,                      -- URL al archivo en storage
    source_file_hash VARCHAR(64),              -- SHA-256 del archivo
    
    -- Estado
    status import_status NOT NULL DEFAULT 'pending',
    
    -- Progreso
    total_rows INTEGER DEFAULT 0,
    processed_rows INTEGER DEFAULT 0,
    success_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    warning_count INTEGER DEFAULT 0,
    
    -- Resultados
    result_summary JSONB DEFAULT '{}',         -- Resumen de resultados
    errors_file_url TEXT,                      -- URL a archivo con errores detallados
    
    -- Configuración de importación
    options JSONB DEFAULT '{}',                -- Opciones específicas del tipo
    column_mapping JSONB DEFAULT '{}',         -- Mapeo de columnas
    
    -- Temporalidad
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID NOT NULL REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT chk_import_jobs_progress CHECK (
        processed_rows <= total_rows AND
        success_count + error_count <= processed_rows
    )
);

-- Índices
CREATE INDEX idx_import_jobs_school ON import_jobs(school_id);
CREATE INDEX idx_import_jobs_status ON import_jobs(status);
CREATE INDEX idx_import_jobs_type ON import_jobs(import_type);
CREATE INDEX idx_import_jobs_created ON import_jobs(created_at DESC);
CREATE INDEX idx_import_jobs_user ON import_jobs(created_by);

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_import_jobs
    BEFORE UPDATE ON import_jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE import_jobs IS 'Registro de trabajos de importación masiva de datos';
COMMENT ON COLUMN import_jobs.column_mapping IS 'Mapeo de columnas del archivo a campos del sistema';
COMMENT ON COLUMN import_jobs.options IS 'Opciones como: skip_duplicates, update_existing, etc.';
```

---

## Admin Sprint 4: Eventos Escolares

### 7. Tabla `school_events`

**Propósito**: Eventos, actividades y calendario escolar.

```sql
-- Migración: 20251201_007_create_school_events.sql

-- Enum para tipo de evento
CREATE TYPE school_event_type AS ENUM (
    'exam',                 -- Examen
    'parent_meeting',       -- Reunión de padres
    'holiday',              -- Feriado/vacación
    'extracurricular',      -- Actividad extracurricular
    'teacher_training',     -- Capacitación docente
    'ceremony',             -- Ceremonia (graduación, inicio de clases)
    'sports',               -- Evento deportivo
    'cultural',             -- Evento cultural
    'field_trip',           -- Excursión/salida
    'other'                 -- Otro
);

-- Enum para estado del evento
CREATE TYPE event_status AS ENUM (
    'scheduled',            -- Programado
    'ongoing',              -- En curso
    'completed',            -- Completado
    'cancelled',            -- Cancelado
    'postponed'             -- Pospuesto
);

CREATE TABLE school_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    
    -- Información básica
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_type school_event_type NOT NULL,
    
    -- Temporalidad
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    all_day BOOLEAN DEFAULT false,
    
    -- Ubicación
    location VARCHAR(200),
    classroom_id UUID REFERENCES classrooms(id) ON DELETE SET NULL,
    
    -- Participantes
    is_school_wide BOOLEAN DEFAULT false,          -- Aplica a toda la escuela
    
    -- Asociaciones opcionales
    subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
    cycle_id UUID REFERENCES academic_cycles(id) ON DELETE SET NULL,
    
    -- Organizador
    organizer_id UUID NOT NULL REFERENCES users(id),
    
    -- Estado
    status event_status NOT NULL DEFAULT 'scheduled',
    cancel_reason TEXT,
    
    -- Configuración de notificaciones
    notify_participants BOOLEAN DEFAULT true,
    notification_sent BOOLEAN DEFAULT false,
    reminder_sent BOOLEAN DEFAULT false,
    
    -- Metadatos
    color VARCHAR(7),                             -- Color hex para calendario (ej: #FF5733)
    attachments JSONB DEFAULT '[]',               -- [{name, url, size}]
    metadata JSONB DEFAULT '{}',
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT chk_school_events_dates CHECK (end_datetime >= start_datetime),
    CONSTRAINT chk_school_events_color CHECK (color IS NULL OR color ~ '^#[0-9A-Fa-f]{6}$')
);

-- Índices
CREATE INDEX idx_school_events_school ON school_events(school_id);
CREATE INDEX idx_school_events_dates ON school_events(start_datetime, end_datetime);
CREATE INDEX idx_school_events_type ON school_events(event_type);
CREATE INDEX idx_school_events_status ON school_events(status);
CREATE INDEX idx_school_events_organizer ON school_events(organizer_id);
CREATE INDEX idx_school_events_cycle ON school_events(cycle_id);
CREATE INDEX idx_school_events_deleted ON school_events(deleted_at) WHERE deleted_at IS NULL;

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_school_events
    BEFORE UPDATE ON school_events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE school_events IS 'Eventos, actividades y calendario escolar';
COMMENT ON COLUMN school_events.is_school_wide IS 'True si el evento aplica a toda la escuela (no a unidades específicas)';
```

---

### 8. Tabla `event_participants`

**Propósito**: Relación many-to-many entre eventos y unidades/usuarios participantes.

```sql
-- Migración: 20251201_008_create_event_participants.sql

-- Enum para tipo de participante
CREATE TYPE participant_type AS ENUM (
    'unit',         -- Unidad académica completa
    'user'          -- Usuario individual
);

-- Enum para estado de asistencia
CREATE TYPE attendance_status AS ENUM (
    'pending',      -- Pendiente de confirmar
    'confirmed',    -- Confirmada asistencia
    'declined',     -- Declinó
    'attended',     -- Asistió
    'absent'        -- No asistió
);

CREATE TABLE event_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES school_events(id) ON DELETE CASCADE,
    
    -- Tipo de participante
    participant_type participant_type NOT NULL,
    unit_id UUID REFERENCES academic_units(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Estado de participación
    attendance_status attendance_status DEFAULT 'pending',
    
    -- Rol en el evento
    role VARCHAR(50),                     -- "presenter", "attendee", "volunteer"
    
    -- Confirmación
    confirmed_at TIMESTAMP WITH TIME ZONE,
    attended_at TIMESTAMP WITH TIME ZONE,
    
    -- Notas
    notes TEXT,
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT chk_event_participants_ref CHECK (
        (participant_type = 'unit' AND unit_id IS NOT NULL AND user_id IS NULL) OR
        (participant_type = 'user' AND user_id IS NOT NULL AND unit_id IS NULL)
    ),
    CONSTRAINT uq_event_participants_unit UNIQUE(event_id, unit_id),
    CONSTRAINT uq_event_participants_user UNIQUE(event_id, user_id)
);

-- Índices
CREATE INDEX idx_event_participants_event ON event_participants(event_id);
CREATE INDEX idx_event_participants_unit ON event_participants(unit_id) WHERE unit_id IS NOT NULL;
CREATE INDEX idx_event_participants_user ON event_participants(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_event_participants_status ON event_participants(attendance_status);

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_event_participants
    BEFORE UPDATE ON event_participants
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE event_participants IS 'Participantes de eventos escolares (unidades o usuarios individuales)';
```

---

## Admin Sprint 5: Calificaciones y Roles

### 9. Tabla `grading_scales`

**Propósito**: Escalas de calificación configurables por escuela.

```sql
-- Migración: 20251201_009_create_grading_scales.sql

-- Enum para tipo de escala
CREATE TYPE grading_scale_type AS ENUM (
    'numeric',          -- Numérica (ej: 0-10, 0-100)
    'alphabetic',       -- Alfabética (ej: A-F)
    'conceptual',       -- Conceptual (ej: Excelente, Bueno, Regular)
    'custom'            -- Personalizada
);

CREATE TABLE grading_scales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    
    -- Información básica
    name VARCHAR(100) NOT NULL,           -- "Escala Numérica 1-10"
    description TEXT,
    scale_type grading_scale_type NOT NULL,
    
    -- Para escalas numéricas
    min_value DECIMAL(5,2),               -- Valor mínimo (ej: 0, 1)
    max_value DECIMAL(5,2),               -- Valor máximo (ej: 10, 100)
    passing_grade DECIMAL(5,2),           -- Nota mínima para aprobar (ej: 6, 60)
    
    -- Estado
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_default BOOLEAN NOT NULL DEFAULT false,  -- Solo una por escuela
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT uq_grading_scales_school_name UNIQUE(school_id, name),
    CONSTRAINT chk_grading_scales_values CHECK (
        (scale_type != 'numeric') OR
        (min_value IS NOT NULL AND max_value IS NOT NULL AND max_value > min_value)
    ),
    CONSTRAINT chk_grading_scales_passing CHECK (
        passing_grade IS NULL OR
        (passing_grade >= min_value AND passing_grade <= max_value)
    )
);

-- Índices
CREATE INDEX idx_grading_scales_school ON grading_scales(school_id);
CREATE INDEX idx_grading_scales_active ON grading_scales(school_id, is_active) WHERE is_active = true;
CREATE INDEX idx_grading_scales_default ON grading_scales(school_id, is_default) WHERE is_default = true;

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_grading_scales
    BEFORE UPDATE ON grading_scales
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para asegurar solo una escala default por escuela
CREATE OR REPLACE FUNCTION ensure_single_default_scale()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_default = true THEN
        UPDATE grading_scales 
        SET is_default = false 
        WHERE school_id = NEW.school_id 
          AND id != NEW.id 
          AND is_default = true;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_single_default_scale
    BEFORE INSERT OR UPDATE OF is_default ON grading_scales
    FOR EACH ROW
    WHEN (NEW.is_default = true)
    EXECUTE FUNCTION ensure_single_default_scale();

COMMENT ON TABLE grading_scales IS 'Escalas de calificación configurables por escuela';
```

---

### 10. Tabla `grading_scale_ranges`

**Propósito**: Rangos dentro de una escala de calificación (para mapeo y etiquetas).

```sql
-- Migración: 20251201_010_create_grading_scale_ranges.sql

CREATE TABLE grading_scale_ranges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scale_id UUID NOT NULL REFERENCES grading_scales(id) ON DELETE CASCADE,
    
    -- Rango numérico
    min_value DECIMAL(5,2) NOT NULL,      -- Límite inferior (inclusivo)
    max_value DECIMAL(5,2) NOT NULL,      -- Límite superior (inclusivo)
    
    -- Representación
    label VARCHAR(50) NOT NULL,           -- "Excelente", "A", "Aprobado"
    letter VARCHAR(5),                    -- "A", "B+", etc. (para escalas numéricas)
    
    -- Estado de aprobación
    is_passing BOOLEAN NOT NULL DEFAULT false,
    
    -- Color para UI
    color VARCHAR(7),                     -- Color hex (ej: #4CAF50 para verde)
    
    -- Orden
    sequence_order SMALLINT NOT NULL,     -- Para mantener orden en UI
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT chk_grading_scale_ranges_values CHECK (max_value >= min_value),
    CONSTRAINT chk_grading_scale_ranges_color CHECK (color IS NULL OR color ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT uq_grading_scale_ranges_order UNIQUE(scale_id, sequence_order)
);

-- Índices
CREATE INDEX idx_grading_scale_ranges_scale ON grading_scale_ranges(scale_id);
CREATE INDEX idx_grading_scale_ranges_order ON grading_scale_ranges(scale_id, sequence_order);

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_grading_scale_ranges
    BEFORE UPDATE ON grading_scale_ranges
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE grading_scale_ranges IS 'Rangos y etiquetas dentro de una escala de calificación';
COMMENT ON COLUMN grading_scale_ranges.is_passing IS 'True si este rango representa una calificación aprobatoria';
```

---

### 11. Tabla `custom_roles`

**Propósito**: Roles personalizados adicionales a los roles base del sistema.

```sql
-- Migración: 20251201_011_create_custom_roles.sql

CREATE TABLE custom_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    
    -- Información básica
    name VARCHAR(100) NOT NULL,           -- "Coordinador de Primaria"
    code VARCHAR(50) NOT NULL,            -- "coord_primaria"
    description TEXT,
    
    -- Rol base del cual hereda
    base_role VARCHAR(50) NOT NULL,       -- Uno de los roles base del sistema
    
    -- Estado
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT uq_custom_roles_school_code UNIQUE(school_id, code),
    CONSTRAINT uq_custom_roles_school_name UNIQUE(school_id, name),
    CONSTRAINT chk_custom_roles_code CHECK (code ~ '^[a-z][a-z0-9_]*$')
);

-- Índices
CREATE INDEX idx_custom_roles_school ON custom_roles(school_id);
CREATE INDEX idx_custom_roles_base ON custom_roles(base_role);
CREATE INDEX idx_custom_roles_active ON custom_roles(school_id, is_active) WHERE is_active = true;

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_custom_roles
    BEFORE UPDATE ON custom_roles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE custom_roles IS 'Roles personalizados creados por cada escuela';
COMMENT ON COLUMN custom_roles.base_role IS 'Rol base del sistema del cual hereda permisos base';
COMMENT ON COLUMN custom_roles.code IS 'Código único para identificación programática (solo minúsculas, números y guiones bajos)';
```

---

### 12. Tabla `role_permissions`

**Propósito**: Permisos adicionales o restricciones para roles personalizados.

```sql
-- Migración: 20251201_012_create_role_permissions.sql

-- Enum para tipo de modificación de permiso
CREATE TYPE permission_modifier AS ENUM (
    'grant',        -- Otorgar permiso adicional
    'revoke'        -- Revocar permiso del rol base
);

CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL REFERENCES custom_roles(id) ON DELETE CASCADE,
    
    -- Permiso
    permission VARCHAR(100) NOT NULL,     -- "users.edit_all", "reports.financial"
    modifier permission_modifier NOT NULL DEFAULT 'grant',
    
    -- Condiciones opcionales (para permisos con scope)
    conditions JSONB DEFAULT '{}',        -- {"unit_ids": [...], "subject_ids": [...]}
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    granted_by UUID REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT uq_role_permissions UNIQUE(role_id, permission)
);

-- Índices
CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission);

COMMENT ON TABLE role_permissions IS 'Permisos adicionales o revocados para roles personalizados';
COMMENT ON COLUMN role_permissions.conditions IS 'Condiciones que limitan el scope del permiso (ej: solo ciertas unidades)';
```

---

## Admin Sprint 6: Certificados y Pagos

### 13. Tabla `certificates`

**Propósito**: Plantillas de certificados y constancias.

```sql
-- Migración: 20251201_013_create_certificates.sql

-- Enum para tipo de certificado
CREATE TYPE certificate_type AS ENUM (
    'enrollment',           -- Constancia de inscripción
    'study_certificate',    -- Certificado de estudios
    'transcript',           -- Boleta/Kardex de calificaciones
    'good_conduct',         -- Constancia de buena conducta
    'graduation',           -- Diploma de graduación
    'attendance',           -- Constancia de asistencia
    'recommendation',       -- Carta de recomendación
    'custom'                -- Personalizado
);

CREATE TABLE certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE,  -- NULL = plantilla global
    
    -- Información básica
    name VARCHAR(200) NOT NULL,           -- "Constancia de Inscripción"
    description TEXT,
    certificate_type certificate_type NOT NULL,
    
    -- Plantilla
    template_url TEXT,                    -- URL a archivo de plantilla (.docx, .html)
    template_version INTEGER DEFAULT 1,
    
    -- Variables disponibles
    available_variables TEXT[] DEFAULT '{}',  -- ['student_name', 'grades', 'date']
    
    -- Configuración
    requires_signature BOOLEAN DEFAULT true,
    requires_seal BOOLEAN DEFAULT true,
    validity_days INTEGER,                -- Días de validez (NULL = sin vencimiento)
    
    -- Estado
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT uq_certificates_school_name UNIQUE(school_id, name)
);

-- Índices
CREATE INDEX idx_certificates_school ON certificates(school_id);
CREATE INDEX idx_certificates_type ON certificates(certificate_type);
CREATE INDEX idx_certificates_active ON certificates(is_active) WHERE is_active = true;

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_certificates
    BEFORE UPDATE ON certificates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE certificates IS 'Plantillas de certificados y constancias';
COMMENT ON COLUMN certificates.school_id IS 'NULL indica una plantilla global disponible para todas las escuelas';
```

---

### 14. Tabla `generated_certificates`

**Propósito**: Certificados generados para estudiantes.

```sql
-- Migración: 20251201_014_create_generated_certificates.sql

-- Enum para estado del certificado generado
CREATE TYPE generated_certificate_status AS ENUM (
    'pending',          -- Pendiente de generación
    'processing',       -- Generándose
    'ready',            -- Listo para descargar
    'delivered',        -- Entregado físicamente
    'expired',          -- Vencido
    'revoked'           -- Revocado
);

CREATE TABLE generated_certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    certificate_id UUID NOT NULL REFERENCES certificates(id) ON DELETE RESTRICT,
    
    -- Estudiante
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    
    -- Contexto académico
    cycle_id UUID REFERENCES academic_cycles(id),
    period_id UUID REFERENCES academic_periods(id),
    
    -- Archivo generado
    file_url TEXT,
    file_hash VARCHAR(64),               -- SHA-256 para verificación
    
    -- Identificador único del certificado (para verificación)
    verification_code VARCHAR(20) NOT NULL,  -- Código único para verificar autenticidad
    qr_code_url TEXT,                    -- URL a imagen QR
    
    -- Estado
    status generated_certificate_status NOT NULL DEFAULT 'pending',
    
    -- Firma digital
    signed BOOLEAN DEFAULT false,
    signature_hash VARCHAR(256),
    signed_by UUID REFERENCES users(id),
    signed_at TIMESTAMP WITH TIME ZONE,
    
    -- Validez
    issued_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Para revocación
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoke_reason TEXT,
    revoked_by UUID REFERENCES users(id),
    
    -- Datos adicionales usados en generación
    generation_data JSONB DEFAULT '{}',
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    requested_by UUID NOT NULL REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT uq_generated_certificates_code UNIQUE(verification_code)
);

-- Índices
CREATE INDEX idx_generated_certificates_template ON generated_certificates(certificate_id);
CREATE INDEX idx_generated_certificates_student ON generated_certificates(student_id);
CREATE INDEX idx_generated_certificates_status ON generated_certificates(status);
CREATE INDEX idx_generated_certificates_code ON generated_certificates(verification_code);
CREATE INDEX idx_generated_certificates_cycle ON generated_certificates(cycle_id);
CREATE INDEX idx_generated_certificates_created ON generated_certificates(created_at DESC);

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_generated_certificates
    BEFORE UPDATE ON generated_certificates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Función para generar código de verificación único
CREATE OR REPLACE FUNCTION generate_verification_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.verification_code IS NULL THEN
        NEW.verification_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NOW()::TEXT) FROM 1 FOR 12));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_generate_verification_code
    BEFORE INSERT ON generated_certificates
    FOR EACH ROW
    EXECUTE FUNCTION generate_verification_code();

COMMENT ON TABLE generated_certificates IS 'Certificados generados para estudiantes';
COMMENT ON COLUMN generated_certificates.verification_code IS 'Código único para verificar autenticidad del certificado';
```

---

### 15. Tabla `fee_concepts`

**Propósito**: Conceptos de cobro (colegiaturas, inscripciones, uniformes, etc.).

```sql
-- Migración: 20251201_015_create_fee_concepts.sql

-- Enum para tipo de concepto
CREATE TYPE fee_type AS ENUM (
    'tuition',              -- Colegiatura mensual
    'enrollment',           -- Inscripción
    'reinscription',        -- Reinscripción
    'uniform',              -- Uniforme
    'books',                -- Libros/materiales
    'transport',            -- Transporte
    'food',                 -- Alimentación/cafetería
    'extracurricular',      -- Actividades extracurriculares
    'exam',                 -- Exámenes
    'certificate',          -- Certificados/constancias
    'late_fee',             -- Recargo por mora
    'discount',             -- Descuento (monto negativo)
    'scholarship',          -- Beca (monto negativo)
    'other'                 -- Otro
);

-- Enum para frecuencia de cobro
CREATE TYPE fee_frequency AS ENUM (
    'once',                 -- Pago único
    'monthly',              -- Mensual
    'bimonthly',            -- Bimestral
    'quarterly',            -- Trimestral
    'semester',             -- Semestral
    'annual'                -- Anual
);

CREATE TABLE fee_concepts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    cycle_id UUID REFERENCES academic_cycles(id) ON DELETE SET NULL,
    
    -- Información básica
    name VARCHAR(200) NOT NULL,           -- "Colegiatura Mensual"
    code VARCHAR(50) NOT NULL,            -- "COLE-2024"
    description TEXT,
    fee_type fee_type NOT NULL,
    
    -- Monto
    amount DECIMAL(12,2) NOT NULL,        -- Monto base
    currency VARCHAR(3) DEFAULT 'MXN',    -- Código ISO de moneda
    
    -- Frecuencia
    frequency fee_frequency NOT NULL DEFAULT 'once',
    
    -- Aplicabilidad
    applies_to_all BOOLEAN DEFAULT true,  -- Aplica a todos los estudiantes
    
    -- Fechas de vigencia
    valid_from DATE,
    valid_until DATE,
    
    -- Fechas de vencimiento para pago
    due_day_of_month SMALLINT,            -- Día del mes en que vence (ej: 10)
    grace_days SMALLINT DEFAULT 0,        -- Días de gracia antes de recargo
    
    -- Recargo por mora
    late_fee_percentage DECIMAL(5,2),     -- % de recargo (ej: 5.00 = 5%)
    late_fee_fixed DECIMAL(12,2),         -- Monto fijo de recargo
    
    -- Estado
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT uq_fee_concepts_school_code UNIQUE(school_id, code),
    CONSTRAINT chk_fee_concepts_amount CHECK (
        (fee_type IN ('discount', 'scholarship') AND amount <= 0) OR
        (fee_type NOT IN ('discount', 'scholarship') AND amount >= 0)
    ),
    CONSTRAINT chk_fee_concepts_due_day CHECK (due_day_of_month IS NULL OR (due_day_of_month >= 1 AND due_day_of_month <= 28)),
    CONSTRAINT chk_fee_concepts_grace CHECK (grace_days IS NULL OR grace_days >= 0),
    CONSTRAINT chk_fee_concepts_late_fee CHECK (
        late_fee_percentage IS NULL OR (late_fee_percentage >= 0 AND late_fee_percentage <= 100)
    )
);

-- Índices
CREATE INDEX idx_fee_concepts_school ON fee_concepts(school_id);
CREATE INDEX idx_fee_concepts_cycle ON fee_concepts(cycle_id);
CREATE INDEX idx_fee_concepts_type ON fee_concepts(fee_type);
CREATE INDEX idx_fee_concepts_active ON fee_concepts(school_id, is_active) WHERE is_active = true;

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_fee_concepts
    BEFORE UPDATE ON fee_concepts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE fee_concepts IS 'Conceptos de cobro (colegiaturas, inscripciones, etc.)';
COMMENT ON COLUMN fee_concepts.due_day_of_month IS 'Día del mes en que vence el pago (1-28 para evitar problemas con meses cortos)';
```

---

### 16. Tabla `payments`

**Propósito**: Registro de pagos realizados por estudiantes/tutores.

```sql
-- Migración: 20251201_016_create_payments.sql

-- Enum para estado del pago
CREATE TYPE payment_status AS ENUM (
    'pending',              -- Pendiente
    'partial',              -- Pago parcial
    'paid',                 -- Pagado completo
    'overdue',              -- Vencido
    'cancelled',            -- Cancelado
    'refunded'              -- Reembolsado
);

-- Enum para método de pago
CREATE TYPE payment_method AS ENUM (
    'cash',                 -- Efectivo
    'card',                 -- Tarjeta (crédito/débito)
    'transfer',             -- Transferencia bancaria
    'check',                -- Cheque
    'online',               -- Pago en línea
    'other'                 -- Otro
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Referencias
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    fee_concept_id UUID NOT NULL REFERENCES fee_concepts(id) ON DELETE RESTRICT,
    
    -- Periodo al que aplica (para cobros recurrentes)
    period_month SMALLINT,                -- Mes (1-12)
    period_year SMALLINT,                 -- Año
    
    -- Montos
    original_amount DECIMAL(12,2) NOT NULL,   -- Monto original del concepto
    discount_amount DECIMAL(12,2) DEFAULT 0,  -- Descuentos aplicados
    late_fee_amount DECIMAL(12,2) DEFAULT 0,  -- Recargos por mora
    total_amount DECIMAL(12,2) NOT NULL,      -- Monto final a pagar
    paid_amount DECIMAL(12,2) DEFAULT 0,      -- Monto pagado hasta ahora
    currency VARCHAR(3) DEFAULT 'MXN',
    
    -- Fechas
    due_date DATE NOT NULL,               -- Fecha de vencimiento
    paid_at TIMESTAMP WITH TIME ZONE,     -- Fecha de pago completo
    
    -- Método de pago
    payment_method payment_method,
    payment_reference VARCHAR(100),       -- Referencia del pago (folio, número de transferencia)
    
    -- Estado
    status payment_status NOT NULL DEFAULT 'pending',
    
    -- Facturación
    invoice_requested BOOLEAN DEFAULT false,
    invoice_number VARCHAR(50),
    invoice_url TEXT,
    
    -- Metadatos
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    
    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_by UUID REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT chk_payments_amounts CHECK (
        discount_amount >= 0 AND
        late_fee_amount >= 0 AND
        paid_amount >= 0 AND
        total_amount = original_amount - discount_amount + late_fee_amount AND
        paid_amount <= total_amount
    ),
    CONSTRAINT chk_payments_period CHECK (
        (period_month IS NULL AND period_year IS NULL) OR
        (period_month >= 1 AND period_month <= 12 AND period_year >= 2020)
    )
);

-- Índices
CREATE INDEX idx_payments_student ON payments(student_id);
CREATE INDEX idx_payments_concept ON payments(fee_concept_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_due_date ON payments(due_date);
CREATE INDEX idx_payments_period ON payments(period_year, period_month);
CREATE INDEX idx_payments_created ON payments(created_at DESC);

-- Índice para pagos pendientes/vencidos
CREATE INDEX idx_payments_pending ON payments(student_id, due_date) 
    WHERE status IN ('pending', 'partial', 'overdue');

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_payments
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para actualizar status basado en paid_amount
CREATE OR REPLACE FUNCTION update_payment_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.paid_amount >= NEW.total_amount THEN
        NEW.status := 'paid';
        IF NEW.paid_at IS NULL THEN
            NEW.paid_at := NOW();
        END IF;
    ELSIF NEW.paid_amount > 0 THEN
        NEW.status := 'partial';
    ELSIF NEW.due_date < CURRENT_DATE AND NEW.status NOT IN ('paid', 'cancelled', 'refunded') THEN
        NEW.status := 'overdue';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_payment_status
    BEFORE INSERT OR UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_payment_status();

COMMENT ON TABLE payments IS 'Registro de pagos de estudiantes';
COMMENT ON COLUMN payments.period_month IS 'Mes al que corresponde el pago (para cobros mensuales)';
COMMENT ON COLUMN payments.total_amount IS 'Calculado: original_amount - discount_amount + late_fee_amount';
```

---

## Resumen de Migraciones

### Orden de Ejecución

```bash
# Sprint 2: Ciclos Académicos
20251201_001_create_academic_cycles.sql
20251201_002_create_academic_periods.sql

# Sprint 3: Horarios (requiere classrooms primero)
20251201_003_create_classrooms.sql
20251201_004_create_schedules.sql
20251201_005_create_schedule_blocks.sql
20251201_006_create_import_jobs.sql

# Sprint 4: Eventos
20251201_007_create_school_events.sql
20251201_008_create_event_participants.sql

# Sprint 5: Calificaciones y Roles
20251201_009_create_grading_scales.sql
20251201_010_create_grading_scale_ranges.sql
20251201_011_create_custom_roles.sql
20251201_012_create_role_permissions.sql

# Sprint 6: Certificados y Pagos
20251201_013_create_certificates.sql
20251201_014_create_generated_certificates.sql
20251201_015_create_fee_concepts.sql
20251201_016_create_payments.sql
```

### Dependencias Entre Tablas

```
schools (existente)
├── academic_cycles
│   └── academic_periods
├── classrooms
├── schedules (→ academic_units, subjects, users, classrooms, academic_cycles)
│   └── schedule_blocks
├── school_events (→ classrooms, academic_cycles)
│   └── event_participants (→ academic_units, users)
├── grading_scales
│   └── grading_scale_ranges
├── custom_roles
│   └── role_permissions
├── certificates
│   └── generated_certificates (→ users, academic_cycles, academic_periods)
├── fee_concepts (→ academic_cycles)
│   └── payments (→ users)
└── import_jobs (→ users)
```

---

## Funciones Auxiliares Requeridas

Si no existen, crear estas funciones auxiliares:

```sql
-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## Referencias

| Documento | Propósito |
|-----------|-----------|
| [PLAN-TRABAJO-ORDENADO.md](./PLAN-TRABAJO-ORDENADO.md) | Plan general que referencia estas migraciones |
| [ENDPOINTS-FALTANTES.md](./administracion/ENDPOINTS-FALTANTES.md) | Endpoints API que usan estas tablas |
| [PANTALLAS.md](./administracion/PANTALLAS.md) | UI que consume estos datos |

---

**Generado por**: Claude Code  
**Fecha**: 1 de Diciembre, 2025
