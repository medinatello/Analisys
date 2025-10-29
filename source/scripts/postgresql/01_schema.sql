-- =====================================================
-- EduGo - Schema PostgreSQL
-- Base de Datos Relacional para Datos Transaccionales
-- =====================================================

-- Habilitar extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- SECCIÓN 1: GESTIÓN DE USUARIOS Y PERFILES
-- =====================================================

-- Tabla principal de usuarios
CREATE TABLE app_user (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    credential_hash VARCHAR(255) NOT NULL,
    system_role VARCHAR(50) NOT NULL CHECK (system_role IN ('teacher', 'student', 'admin', 'guardian')),
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_app_user_system_role ON app_user(system_role);
CREATE INDEX idx_app_user_email ON app_user(email);

-- Perfil de docentes
CREATE TABLE teacher_profile (
    user_id UUID PRIMARY KEY REFERENCES app_user(id) ON DELETE CASCADE,
    specialty VARCHAR(255),
    preferences JSONB DEFAULT '{}'::jsonb
);

-- Perfil de estudiantes
CREATE TABLE student_profile (
    user_id UUID PRIMARY KEY REFERENCES app_user(id) ON DELETE CASCADE,
    primary_unit_id UUID, -- FK se agregará después de crear academic_unit
    current_grade VARCHAR(50),
    student_code VARCHAR(100)
);

CREATE INDEX idx_student_profile_primary_unit ON student_profile(primary_unit_id);

-- Perfil de tutores/padres
CREATE TABLE guardian_profile (
    user_id UUID PRIMARY KEY REFERENCES app_user(id) ON DELETE CASCADE,
    occupation VARCHAR(255),
    alternate_contact VARCHAR(255)
);

-- Relación tutor-estudiante (N:M)
CREATE TABLE guardian_student_relation (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guardian_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    relationship_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(guardian_id, student_id, relationship_type)
);

CREATE INDEX idx_guardian_student_guardian ON guardian_student_relation(guardian_id);
CREATE INDEX idx_guardian_student_student ON guardian_student_relation(student_id);

-- =====================================================
-- SECCIÓN 2: JERARQUÍA ACADÉMICA
-- =====================================================

-- Organizaciones educativas (colegios/academias)
CREATE TABLE school (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    external_code VARCHAR(100) UNIQUE,
    location VARCHAR(500),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_school_external_code ON school(external_code);

-- Unidades académicas jerárquicas (recursiva)
CREATE TABLE academic_unit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES school(id) ON DELETE CASCADE,
    parent_unit_id UUID REFERENCES academic_unit(id) ON DELETE SET NULL,
    unit_type VARCHAR(50) NOT NULL CHECK (unit_type IN ('school', 'academic_year', 'section', 'club', 'academy_level')),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(100),
    metadata JSONB DEFAULT '{}'::jsonb,
    validity_period TSTZRANGE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_academic_unit_school ON academic_unit(school_id);
CREATE INDEX idx_academic_unit_parent ON academic_unit(parent_unit_id);
CREATE INDEX idx_academic_unit_type ON academic_unit(unit_type);
CREATE INDEX idx_academic_unit_code ON academic_unit(code);

-- Ahora podemos agregar la FK de student_profile
ALTER TABLE student_profile
ADD CONSTRAINT fk_student_primary_unit
FOREIGN KEY (primary_unit_id) REFERENCES academic_unit(id) ON DELETE SET NULL;

-- Membresías de usuarios en unidades (N:M con roles)
CREATE TABLE unit_membership (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID NOT NULL REFERENCES academic_unit(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    unit_role VARCHAR(50) NOT NULL CHECK (unit_role IN ('owner', 'teacher', 'assistant', 'student', 'guardian')),
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    removed_at TIMESTAMPTZ,
    UNIQUE(unit_id, user_id, unit_role, assigned_at)
);

CREATE INDEX idx_unit_membership_unit ON unit_membership(unit_id);
CREATE INDEX idx_unit_membership_user ON unit_membership(user_id);
CREATE INDEX idx_unit_membership_role ON unit_membership(unit_role);

-- =====================================================
-- SECCIÓN 3: MATERIALES Y CONTENIDOS ACADÉMICOS
-- =====================================================

-- Catálogo de materias
CREATE TABLE subject (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES school(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(school_id, name)
);

CREATE INDEX idx_subject_school ON subject(school_id);

-- Metadatos de materiales educativos
CREATE TABLE learning_material (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subject(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    s3_url VARCHAR(1000),
    extra_metadata JSONB DEFAULT '{}'::jsonb,
    published_at TIMESTAMPTZ,
    status VARCHAR(50) NOT NULL DEFAULT 'draft',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_learning_material_subject ON learning_material(subject_id);
CREATE INDEX idx_learning_material_author ON learning_material(author_id);
CREATE INDEX idx_learning_material_extra_metadata ON learning_material USING GIN (extra_metadata);

-- Historial de versiones de materiales
CREATE TABLE material_version (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES learning_material(id) ON DELETE CASCADE,
    s3_version_url VARCHAR(1000) NOT NULL,
    file_hash VARCHAR(64), -- SHA256
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_material_version_material ON material_version(material_id, generated_at DESC);

-- Asignación de materiales a unidades (N:M)
CREATE TABLE material_unit_link (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES learning_material(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES academic_unit(id) ON DELETE CASCADE,
    scope VARCHAR(100),
    visibility VARCHAR(50) NOT NULL DEFAULT 'public',
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(material_id, unit_id)
);

CREATE INDEX idx_material_unit_link_material ON material_unit_link(material_id);
CREATE INDEX idx_material_unit_link_unit ON material_unit_link(unit_id);

-- =====================================================
-- SECCIÓN 4: SEGUIMIENTO Y EVALUACIONES
-- =====================================================

-- Registro de progreso de lectura
CREATE TABLE reading_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES learning_material(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    progress DECIMAL(5,4) DEFAULT 0.0 CHECK (progress >= 0.0 AND progress <= 1.0),
    last_access_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reading_log_user_material ON reading_log(user_id, material_id);

-- Enlace a resúmenes en MongoDB
CREATE TABLE material_summary_link (
    material_id UUID PRIMARY KEY REFERENCES learning_material(id) ON DELETE CASCADE,
    mongo_document_id UUID NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(50) NOT NULL DEFAULT 'pending'
);

CREATE INDEX idx_material_summary_link_status ON material_summary_link(status);

-- Metadatos de evaluaciones
CREATE TABLE assessment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL UNIQUE REFERENCES learning_material(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    mongo_document_id UUID NOT NULL,
    config JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_assessment_material ON assessment(material_id);

-- Intentos de evaluación
CREATE TABLE assessment_attempt (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assessment_id UUID NOT NULL REFERENCES assessment(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    score DECIMAL(5,2),
    completed_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_assessment_attempt_user_assessment ON assessment_attempt(user_id, assessment_id);
CREATE INDEX idx_assessment_attempt_completed ON assessment_attempt(completed_at);

-- Respuestas individuales de intentos
CREATE TABLE assessment_attempt_answer (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attempt_id UUID NOT NULL REFERENCES assessment_attempt(id) ON DELETE CASCADE,
    question_mongo_id UUID NOT NULL,
    answer_payload JSONB NOT NULL,
    is_correct BOOLEAN,
    answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_assessment_attempt_answer_attempt ON assessment_attempt_answer(attempt_id);

-- =====================================================
-- COMENTARIOS ADICIONALES
-- =====================================================

COMMENT ON TABLE app_user IS 'Tabla principal de usuarios del sistema con credenciales y roles';
COMMENT ON TABLE academic_unit IS 'Jerarquía académica recursiva: colegio → año → sección → club';
COMMENT ON TABLE unit_membership IS 'Membresías N:M entre usuarios y unidades con roles polimórficos';
COMMENT ON TABLE learning_material IS 'Metadatos de materiales educativos, archivos en S3';
COMMENT ON TABLE material_unit_link IS 'Asignación N:M de materiales a múltiples unidades académicas';
COMMENT ON TABLE material_summary_link IS 'Referencias a resúmenes generados por IA almacenados en MongoDB';
COMMENT ON TABLE assessment IS 'Metadatos de evaluaciones, preguntas almacenadas en MongoDB';
