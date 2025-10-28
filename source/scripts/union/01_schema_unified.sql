-- =====================================================
-- EduGo - Schema PostgreSQL UNIFICADO
-- Enfoque Híbrido: Todo en PostgreSQL con JSONB
-- (MongoDB integrado como campos JSON)
-- =====================================================

-- Habilitar extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- SECCIÓN 1: TABLAS ORIGINALES DE POSTGRESQL
-- (Igual que en el enfoque separado)
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
    primary_unit_id UUID,
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

-- FK de student_profile
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
    file_hash VARCHAR(64),
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

-- Registro de progreso de lectura
CREATE TABLE reading_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES learning_material(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    progress DECIMAL(5,4) DEFAULT 0.0 CHECK (progress >= 0.0 AND progress <= 1.0),
    last_access_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reading_log_user_material ON reading_log(user_id, material_id);

-- =====================================================
-- SECCIÓN 2: TABLAS NUEVAS CON JSONB
-- (Reemplazan colecciones de MongoDB)
-- =====================================================

-- Tabla: material_summary_json
-- (Reemplaza colección material_summary de MongoDB)
CREATE TABLE material_summary_json (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL UNIQUE REFERENCES learning_material(id) ON DELETE CASCADE,
    version INT NOT NULL DEFAULT 1,
    summary_data JSONB NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_summary_data_valid CHECK (
        jsonb_typeof(summary_data) = 'object'
        AND summary_data ? 'sections'
    )
);

CREATE INDEX idx_material_summary_json_material ON material_summary_json(material_id);
CREATE INDEX idx_material_summary_json_status ON material_summary_json(status);
CREATE INDEX idx_material_summary_json_data ON material_summary_json USING GIN (summary_data);

COMMENT ON TABLE material_summary_json IS 'Resúmenes generados por IA almacenados como JSONB';
COMMENT ON COLUMN material_summary_json.summary_data IS 'JSON con estructura: {sections: [...], glossary: [...], reflection_questions: [...]}';

-- Tabla: material_assessment_json
-- (Reemplaza colección material_assessment de MongoDB)
CREATE TABLE material_assessment_json (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL UNIQUE REFERENCES learning_material(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    version INT NOT NULL DEFAULT 1,
    assessment_data JSONB NOT NULL,
    total_points DECIMAL(5,2) NOT NULL,
    estimated_duration_minutes INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_assessment_data_valid CHECK (
        jsonb_typeof(assessment_data) = 'object'
        AND assessment_data ? 'questions'
    )
);

CREATE INDEX idx_material_assessment_json_material ON material_assessment_json(material_id);
CREATE INDEX idx_material_assessment_json_data ON material_assessment_json USING GIN (assessment_data);
CREATE INDEX idx_material_assessment_json_questions ON material_assessment_json USING GIN ((assessment_data->'questions'));

COMMENT ON TABLE material_assessment_json IS 'Evaluaciones con preguntas almacenadas como JSONB';
COMMENT ON COLUMN material_assessment_json.assessment_data IS 'JSON con estructura: {questions: [{id, text, type, options, answer, ...}]}';

-- Intentos de evaluación (mantiene relación con assessment_json)
CREATE TABLE assessment_attempt (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assessment_id UUID NOT NULL REFERENCES material_assessment_json(id) ON DELETE CASCADE,
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
    question_id UUID NOT NULL,
    answer_payload JSONB NOT NULL,
    is_correct BOOLEAN,
    answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_assessment_attempt_answer_attempt ON assessment_attempt_answer(attempt_id);
CREATE INDEX idx_assessment_attempt_answer_question ON assessment_attempt_answer(question_id);

-- Tabla: material_event_json
-- (Reemplaza colección material_event de MongoDB)
CREATE TABLE material_event_json (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES learning_material(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    worker_id VARCHAR(255),
    duration_seconds DECIMAL(10,2),
    error_message TEXT,
    event_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_material_event_json_material ON material_event_json(material_id, created_at DESC);
CREATE INDEX idx_material_event_json_type ON material_event_json(event_type);
CREATE INDEX idx_material_event_json_worker ON material_event_json(worker_id);
CREATE INDEX idx_material_event_json_created ON material_event_json(created_at);

COMMENT ON TABLE material_event_json IS 'Eventos y logs de procesamiento de materiales';
COMMENT ON COLUMN material_event_json.event_metadata IS 'JSON con metadatos del procesamiento: {nlp_provider, model, tokens_used, ...}';

-- Tabla: unit_social_feed_json (POST-MVP)
-- (Reemplaza colección unit_social_feed de MongoDB)
CREATE TABLE unit_social_feed_json (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID NOT NULL REFERENCES academic_unit(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    post_type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    post_data JSONB DEFAULT '{}'::jsonb,
    likes_count INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_unit_social_feed_json_unit ON unit_social_feed_json(unit_id, created_at DESC);
CREATE INDEX idx_unit_social_feed_json_author ON unit_social_feed_json(author_id);
CREATE INDEX idx_unit_social_feed_json_type ON unit_social_feed_json(post_type);
CREATE INDEX idx_unit_social_feed_json_data ON unit_social_feed_json USING GIN (post_data);

COMMENT ON TABLE unit_social_feed_json IS 'Feed social de unidades académicas (POST-MVP)';
COMMENT ON COLUMN unit_social_feed_json.post_data IS 'JSON con attachments, comments, etc: {attachments: [...], comments: [...]}';

-- Tabla: user_graph_relation_json (POST-MVP)
-- (Reemplaza colección user_graph_relation de MongoDB)
CREATE TABLE user_graph_relation_json (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    related_user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    relation_type VARCHAR(50) NOT NULL,
    relation_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, related_user_id, relation_type)
);

CREATE INDEX idx_user_graph_relation_json_user ON user_graph_relation_json(user_id, relation_type);
CREATE INDEX idx_user_graph_relation_json_related ON user_graph_relation_json(related_user_id);
CREATE INDEX idx_user_graph_relation_json_metadata ON user_graph_relation_json USING GIN (relation_metadata);

COMMENT ON TABLE user_graph_relation_json IS 'Grafo de relaciones entre usuarios (POST-MVP)';
COMMENT ON COLUMN user_graph_relation_json.relation_metadata IS 'JSON con metadatos: {affinity_score, common_interests: [...]}';

-- =====================================================
-- TRIGGERS Y FUNCIONES ADICIONALES
-- =====================================================

-- Trigger para actualizar updated_at en material_summary_json
CREATE OR REPLACE FUNCTION update_summary_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_summary_timestamp
BEFORE UPDATE ON material_summary_json
FOR EACH ROW
EXECUTE FUNCTION update_summary_timestamp();

-- Trigger para actualizar updated_at en unit_social_feed_json
CREATE TRIGGER trg_update_feed_timestamp
BEFORE UPDATE ON unit_social_feed_json
FOR EACH ROW
EXECUTE FUNCTION update_summary_timestamp();

-- Función para validar jerarquía circular en academic_unit
CREATE OR REPLACE FUNCTION check_circular_hierarchy()
RETURNS TRIGGER AS $$
DECLARE
    current_parent UUID;
    depth INT := 0;
    max_depth INT := 10;
BEGIN
    IF NEW.parent_unit_id IS NULL THEN
        RETURN NEW;
    END IF;

    current_parent := NEW.parent_unit_id;
    WHILE current_parent IS NOT NULL AND depth < max_depth LOOP
        IF current_parent = NEW.id THEN
            RAISE EXCEPTION 'Jerarquía circular detectada en academic_unit';
        END IF;

        SELECT parent_unit_id INTO current_parent
        FROM academic_unit
        WHERE id = current_parent;

        depth := depth + 1;
    END LOOP;

    IF depth >= max_depth THEN
        RAISE EXCEPTION 'Profundidad máxima de jerarquía excedida (máx: %)', max_depth;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_circular_hierarchy
BEFORE INSERT OR UPDATE ON academic_unit
FOR EACH ROW
EXECUTE FUNCTION check_circular_hierarchy();

-- =====================================================
-- VISTAS ÚTILES
-- =====================================================

-- Vista de materiales con su resumen
CREATE OR REPLACE VIEW v_materials_with_summary AS
SELECT
    lm.id,
    lm.title,
    lm.status,
    lm.published_at,
    u.email as author_email,
    s.name as subject_name,
    ms.version as summary_version,
    ms.status as summary_status,
    ms.summary_data
FROM learning_material lm
LEFT JOIN app_user u ON lm.author_id = u.id
LEFT JOIN subject s ON lm.subject_id = s.id
LEFT JOIN material_summary_json ms ON lm.id = ms.material_id;

-- Vista de evaluaciones con sus materiales
CREATE OR REPLACE VIEW v_assessments_full AS
SELECT
    ma.id,
    ma.title,
    ma.total_points,
    ma.estimated_duration_minutes,
    lm.title as material_title,
    lm.status as material_status,
    u.email as author_email,
    jsonb_array_length(ma.assessment_data->'questions') as question_count
FROM material_assessment_json ma
JOIN learning_material lm ON ma.material_id = lm.id
JOIN app_user u ON lm.author_id = u.id;

-- =====================================================
-- COMENTARIOS FINALES
-- =====================================================

COMMENT ON DATABASE current_database() IS 'EduGo - Base de datos unificada con enfoque híbrido PostgreSQL + JSONB';
COMMENT ON SCHEMA public IS 'Schema principal con todas las tablas relacionales y documentales en PostgreSQL';
