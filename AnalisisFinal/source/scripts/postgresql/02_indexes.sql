-- =====================================================
-- EduGo - Índices y Constraints Adicionales
-- Optimizaciones para consultas comunes
-- =====================================================

-- =====================================================
-- ÍNDICES COMPUESTOS PARA CONSULTAS FRECUENTES
-- =====================================================

-- Búsqueda de materiales por subject y status
CREATE INDEX idx_learning_material_subject_status
ON learning_material(subject_id, status)
WHERE status = 'published';

-- Búsqueda de membresías activas por unidad
CREATE INDEX idx_unit_membership_active
ON unit_membership(unit_id, status, unit_role)
WHERE status = 'active';

-- Búsqueda de intentos completados por usuario
CREATE INDEX idx_assessment_attempt_user_completed
ON assessment_attempt(user_id, completed_at DESC)
WHERE completed_at IS NOT NULL;

-- Búsqueda de relaciones activas tutor-estudiante
CREATE INDEX idx_guardian_student_active
ON guardian_student_relation(guardian_id, status)
WHERE status = 'active';

-- =====================================================
-- ÍNDICES PARA CONSULTAS JERÁRQUICAS
-- =====================================================

-- Navegación por jerarquía de unidades académicas
CREATE INDEX idx_academic_unit_hierarchy
ON academic_unit(parent_unit_id, unit_type, school_id)
WHERE parent_unit_id IS NOT NULL;

-- Unidades raíz por colegio
CREATE INDEX idx_academic_unit_root
ON academic_unit(school_id, unit_type)
WHERE parent_unit_id IS NULL;

-- =====================================================
-- ÍNDICES PARA AUDITORÍA Y REPORTES
-- =====================================================

-- Materiales publicados recientemente
CREATE INDEX idx_learning_material_published
ON learning_material(published_at DESC)
WHERE published_at IS NOT NULL;

-- Últimos accesos a materiales
CREATE INDEX idx_reading_log_recent
ON reading_log(last_access_at DESC, user_id);

-- Progreso significativo en lectura
CREATE INDEX idx_reading_log_progress
ON reading_log(user_id, progress DESC)
WHERE progress > 0.0;

-- =====================================================
-- CONSTRAINTS ADICIONALES
-- =====================================================

-- Validar que tutores no sean estudiantes en guardian_student_relation
ALTER TABLE guardian_student_relation
ADD CONSTRAINT chk_guardian_not_student
CHECK (guardian_id != student_id);

-- Validar rango de scores en evaluaciones
ALTER TABLE assessment_attempt
ADD CONSTRAINT chk_score_range
CHECK (score IS NULL OR (score >= 0.0 AND score <= 100.0));

-- Validar que completed_at sea posterior a started_at
ALTER TABLE assessment_attempt
ADD CONSTRAINT chk_completion_after_start
CHECK (completed_at IS NULL OR completed_at >= started_at);

-- =====================================================
-- FUNCIONES Y TRIGGERS
-- =====================================================

-- Función para actualizar timestamp de material_summary_link
CREATE OR REPLACE FUNCTION update_material_summary_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_material_summary_timestamp
BEFORE UPDATE ON material_summary_link
FOR EACH ROW
EXECUTE FUNCTION update_material_summary_timestamp();

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

    -- Verificar que no se cree una jerarquía circular
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

-- Vista de usuarios con sus perfiles completos
CREATE OR REPLACE VIEW v_user_profiles AS
SELECT
    u.id,
    u.email,
    u.system_role,
    u.status,
    u.created_at,
    tp.specialty as teacher_specialty,
    tp.preferences as teacher_preferences,
    sp.current_grade as student_grade,
    sp.student_code,
    gp.occupation as guardian_occupation
FROM app_user u
LEFT JOIN teacher_profile tp ON u.id = tp.user_id
LEFT JOIN student_profile sp ON u.id = sp.user_id
LEFT JOIN guardian_profile gp ON u.id = gp.user_id;

-- Vista de materiales con información del autor y materia
CREATE OR REPLACE VIEW v_learning_materials_full AS
SELECT
    lm.id,
    lm.title,
    lm.description,
    lm.status,
    lm.published_at,
    lm.s3_url,
    u.email as author_email,
    s.name as subject_name,
    sch.name as school_name
FROM learning_material lm
JOIN app_user u ON lm.author_id = u.id
JOIN subject s ON lm.subject_id = s.id
JOIN school sch ON s.school_id = sch.id;

-- Vista de membresías activas con detalles
CREATE OR REPLACE VIEW v_active_memberships AS
SELECT
    um.id,
    um.unit_id,
    um.user_id,
    um.unit_role,
    um.assigned_at,
    u.email as user_email,
    u.system_role,
    au.name as unit_name,
    au.unit_type,
    au.code as unit_code,
    sch.name as school_name
FROM unit_membership um
JOIN app_user u ON um.user_id = u.id
JOIN academic_unit au ON um.unit_id = au.id
JOIN school sch ON au.school_id = sch.id
WHERE um.status = 'active';

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON INDEX idx_learning_material_subject_status IS 'Optimiza búsqueda de materiales publicados por materia';
COMMENT ON INDEX idx_unit_membership_active IS 'Optimiza consultas de membresías activas por unidad';
COMMENT ON FUNCTION check_circular_hierarchy IS 'Previene jerarquías circulares en academic_unit';
COMMENT ON VIEW v_user_profiles IS 'Vista consolidada de usuarios con todos sus perfiles';
COMMENT ON VIEW v_learning_materials_full IS 'Vista de materiales con información completa de autor y contexto';
