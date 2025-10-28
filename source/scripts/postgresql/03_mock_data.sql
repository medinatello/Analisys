-- =====================================================
-- EduGo - Datos Mock para PostgreSQL
-- Datos de prueba realistas para desarrollo y testing
-- =====================================================

-- =====================================================
-- LIMPIAR DATOS EXISTENTES (opcional)
-- =====================================================
-- TRUNCATE TABLE assessment_attempt_answer CASCADE;
-- TRUNCATE TABLE assessment_attempt CASCADE;
-- TRUNCATE TABLE assessment CASCADE;
-- TRUNCATE TABLE material_summary_link CASCADE;
-- TRUNCATE TABLE reading_log CASCADE;
-- TRUNCATE TABLE material_unit_link CASCADE;
-- TRUNCATE TABLE material_version CASCADE;
-- TRUNCATE TABLE learning_material CASCADE;
-- TRUNCATE TABLE subject CASCADE;
-- TRUNCATE TABLE unit_membership CASCADE;
-- TRUNCATE TABLE academic_unit CASCADE;
-- TRUNCATE TABLE guardian_student_relation CASCADE;
-- TRUNCATE TABLE guardian_profile CASCADE;
-- TRUNCATE TABLE student_profile CASCADE;
-- TRUNCATE TABLE teacher_profile CASCADE;
-- TRUNCATE TABLE school CASCADE;
-- TRUNCATE TABLE app_user CASCADE;

-- =====================================================
-- SECCIÓN 1: COLEGIOS
-- =====================================================

INSERT INTO school (id, name, external_code, location, metadata) VALUES
('11111111-1111-1111-1111-111111111111', 'Colegio San José', 'CSJ-001', 'Av. Principal 123, Lima, Perú', '{"phone": "+51-1-2345678", "website": "www.csj.edu.pe"}'::jsonb),
('22222222-2222-2222-2222-222222222222', 'Academia Tech', 'ATech-002', 'Jr. Tecnología 456, Lima, Perú', '{"phone": "+51-1-8765432", "type": "academia"}'::jsonb),
('33333333-3333-3333-3333-333333333333', 'Instituto Bilingüe Internacional', 'IBI-003', 'Av. Educación 789, Cusco, Perú', '{"phone": "+51-84-123456", "bilingual": true}'::jsonb);

-- =====================================================
-- SECCIÓN 2: USUARIOS
-- =====================================================

-- Docentes (5)
INSERT INTO app_user (id, email, credential_hash, system_role, status) VALUES
('d0000001-0000-0000-0000-000000000001', 'maria.garcia@csj.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active'),
('d0000002-0000-0000-0000-000000000002', 'juan.perez@csj.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active'),
('d0000003-0000-0000-0000-000000000003', 'carlos.rodriguez@atech.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active'),
('d0000004-0000-0000-0000-000000000004', 'ana.martinez@ibi.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active'),
('d0000005-0000-0000-0000-000000000005', 'luis.fernandez@ibi.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active');

-- Estudiantes (10)
INSERT INTO app_user (id, email, credential_hash, system_role, status) VALUES
('e0000001-0000-0000-0000-000000000001', 'pedro.lopez@estudiante.csj.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active'),
('e0000002-0000-0000-0000-000000000002', 'lucia.sanchez@estudiante.csj.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active'),
('e0000003-0000-0000-0000-000000000003', 'sofia.torres@estudiante.csj.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active'),
('e0000004-0000-0000-0000-000000000004', 'diego.ramirez@estudiante.csj.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active'),
('e0000005-0000-0000-0000-000000000005', 'camila.flores@estudiante.atech.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active'),
('e0000006-0000-0000-0000-000000000006', 'mateo.vargas@estudiante.atech.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active'),
('e0000007-0000-0000-0000-000000000007', 'valentina.castro@estudiante.ibi.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active'),
('e0000008-0000-0000-0000-000000000008', 'santiago.morales@estudiante.ibi.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active'),
('e0000009-0000-0000-0000-000000000009', 'isabella.gutierrez@estudiante.ibi.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active'),
('e0000010-0000-0000-0000-000000000010', 'nicolas.herrera@estudiante.csj.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'student', 'active');

-- Tutores/Padres (5)
INSERT INTO app_user (id, email, credential_hash, system_role, status) VALUES
('g0000001-0000-0000-0000-000000000001', 'roberto.lopez@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active'),
('g0000002-0000-0000-0000-000000000002', 'carmen.sanchez@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active'),
('g0000003-0000-0000-0000-000000000003', 'miguel.torres@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active'),
('g0000004-0000-0000-0000-000000000004', 'patricia.ramirez@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active'),
('g0000005-0000-0000-0000-000000000005', 'jorge.flores@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active');

-- Administrador (1)
INSERT INTO app_user (id, email, credential_hash, system_role, status) VALUES
('a0000001-0000-0000-0000-000000000001', 'admin@edugo.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'admin', 'active');

-- =====================================================
-- SECCIÓN 3: PERFILES DE USUARIOS
-- =====================================================

-- Perfiles de docentes
INSERT INTO teacher_profile (user_id, specialty, preferences) VALUES
('d0000001-0000-0000-0000-000000000001', 'Matemáticas', '{"notification_email": true, "theme": "light"}'::jsonb),
('d0000002-0000-0000-0000-000000000002', 'Programación', '{"notification_email": false, "theme": "dark"}'::jsonb),
('d0000003-0000-0000-0000-000000000003', 'Inglés', '{"notification_email": true, "language": "en"}'::jsonb),
('d0000004-0000-0000-0000-000000000004', 'Historia', '{"notification_email": true, "theme": "light"}'::jsonb),
('d0000005-0000-0000-0000-000000000005', 'Ciencias', '{"notification_email": true, "theme": "light"}'::jsonb);

-- Perfiles de estudiantes (se completará después de crear academic_unit)
-- Se insertarán después de crear las unidades académicas

-- Perfiles de tutores
INSERT INTO guardian_profile (user_id, occupation, alternate_contact) VALUES
('g0000001-0000-0000-0000-000000000001', 'Ingeniero', '+51-999-111-222'),
('g0000002-0000-0000-0000-000000000002', 'Médica', '+51-999-222-333'),
('g0000003-0000-0000-0000-000000000003', 'Arquitecto', '+51-999-333-444'),
('g0000004-0000-0000-0000-000000000004', 'Abogada', '+51-999-444-555'),
('g0000005-0000-0000-0000-000000000005', 'Empresario', '+51-999-555-666');

-- =====================================================
-- SECCIÓN 4: JERARQUÍA ACADÉMICA
-- =====================================================

-- Unidades académicas para Colegio San José
INSERT INTO academic_unit (id, school_id, parent_unit_id, unit_type, name, code, metadata) VALUES
-- Nivel colegio
('u1000001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', NULL, 'school', 'Colegio San José - Principal', 'CSJ-MAIN', '{}'::jsonb),
-- Años escolares
('u1000002-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'u1000001-0000-0000-0000-000000000001', 'academic_year', '5º de Primaria', 'CSJ-5P', '{"level": "primaria"}'::jsonb),
('u1000003-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'u1000001-0000-0000-0000-000000000001', 'academic_year', '6º de Primaria', 'CSJ-6P', '{"level": "primaria"}'::jsonb),
-- Secciones de 5º
('u1000004-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', 'u1000002-0000-0000-0000-000000000002', 'section', '5º A', 'CSJ-5P-A', '{}'::jsonb),
('u1000005-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', 'u1000002-0000-0000-0000-000000000002', 'section', '5º B', 'CSJ-5P-B', '{}'::jsonb),
-- Secciones de 6º
('u1000006-0000-0000-0000-000000000006', '11111111-1111-1111-1111-111111111111', 'u1000003-0000-0000-0000-000000000003', 'section', '6º A', 'CSJ-6P-A', '{}'::jsonb);

-- Unidades académicas para Academia Tech
INSERT INTO academic_unit (id, school_id, parent_unit_id, unit_type, name, code, metadata) VALUES
-- Nivel academia
('u2000001-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', NULL, 'school', 'Academia Tech - Centro', 'ATECH-MAIN', '{}'::jsonb),
-- Niveles de academia
('u2000002-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'u2000001-0000-0000-0000-000000000001', 'academy_level', 'Programación Básica', 'ATECH-BASIC', '{"duration_weeks": 12}'::jsonb),
('u2000003-0000-0000-0000-000000000003', '22222222-2222-2222-2222-222222222222', 'u2000001-0000-0000-0000-000000000001', 'academy_level', 'Programación Intermedia', 'ATECH-INTER', '{"duration_weeks": 16}'::jsonb);

-- Unidades académicas para Instituto Bilingüe
INSERT INTO academic_unit (id, school_id, parent_unit_id, unit_type, name, code, metadata) VALUES
-- Nivel colegio
('u3000001-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333333', NULL, 'school', 'Instituto Bilingüe - Campus', 'IBI-MAIN', '{}'::jsonb),
-- Años
('u3000002-0000-0000-0000-000000000002', '33333333-3333-3333-3333-333333333333', 'u3000001-0000-0000-0000-000000000001', 'academic_year', '1º de Secundaria', 'IBI-1S', '{"level": "secundaria"}'::jsonb),
-- Secciones
('u3000003-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333333', 'u3000002-0000-0000-0000-000000000002', 'section', '1º A', 'IBI-1S-A', '{}'::jsonb),
-- Clubs
('u3000004-0000-0000-0000-000000000004', '33333333-3333-3333-3333-333333333333', 'u3000001-0000-0000-0000-000000000001', 'club', 'Club de Robótica', 'IBI-ROBO', '{"schedule": "Viernes 3pm"}'::jsonb);

-- =====================================================
-- AHORA SÍ: COMPLETAR PERFILES DE ESTUDIANTES
-- =====================================================

INSERT INTO student_profile (user_id, primary_unit_id, current_grade, student_code) VALUES
('e0000001-0000-0000-0000-000000000001', 'u1000004-0000-0000-0000-000000000004', '5º Primaria', 'CSJ-2024-001'),
('e0000002-0000-0000-0000-000000000002', 'u1000004-0000-0000-0000-000000000004', '5º Primaria', 'CSJ-2024-002'),
('e0000003-0000-0000-0000-000000000003', 'u1000005-0000-0000-0000-000000000005', '5º Primaria', 'CSJ-2024-003'),
('e0000004-0000-0000-0000-000000000004', 'u1000006-0000-0000-0000-000000000006', '6º Primaria', 'CSJ-2024-004'),
('e0000005-0000-0000-0000-000000000005', 'u2000002-0000-0000-0000-000000000002', 'Básico', 'ATECH-2024-001'),
('e0000006-0000-0000-0000-000000000006', 'u2000003-0000-0000-0000-000000000003', 'Intermedio', 'ATECH-2024-002'),
('e0000007-0000-0000-0000-000000000007', 'u3000003-0000-0000-0000-000000000003', '1º Secundaria', 'IBI-2024-001'),
('e0000008-0000-0000-0000-000000000008', 'u3000003-0000-0000-0000-000000000003', '1º Secundaria', 'IBI-2024-002'),
('e0000009-0000-0000-0000-000000000009', 'u3000003-0000-0000-0000-000000000003', '1º Secundaria', 'IBI-2024-003'),
('e0000010-0000-0000-0000-000000000010', 'u1000006-0000-0000-0000-000000000006', '6º Primaria', 'CSJ-2024-005');

-- =====================================================
-- SECCIÓN 5: RELACIONES TUTOR-ESTUDIANTE
-- =====================================================

INSERT INTO guardian_student_relation (guardian_id, student_id, relationship_type, status) VALUES
('g0000001-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', 'padre', 'active'),
('g0000002-0000-0000-0000-000000000002', 'e0000002-0000-0000-0000-000000000002', 'madre', 'active'),
('g0000003-0000-0000-0000-000000000003', 'e0000003-0000-0000-0000-000000000003', 'padre', 'active'),
('g0000004-0000-0000-0000-000000000004', 'e0000004-0000-0000-0000-000000000004', 'madre', 'active'),
('g0000005-0000-0000-0000-000000000005', 'e0000005-0000-0000-0000-000000000005', 'padre', 'active'),
('g0000001-0000-0000-0000-000000000001', 'e0000010-0000-0000-0000-000000000010', 'padre', 'active'); -- Roberto es padre de Pedro y Nicolás

-- =====================================================
-- SECCIÓN 6: MEMBRESÍAS EN UNIDADES
-- =====================================================

-- Docentes en sus unidades
INSERT INTO unit_membership (unit_id, user_id, unit_role, status) VALUES
-- María García en 5º A (owner)
('u1000004-0000-0000-0000-000000000004', 'd0000001-0000-0000-0000-000000000001', 'owner', 'active'),
-- Juan Pérez en 6º A (owner)
('u1000006-0000-0000-0000-000000000006', 'd0000002-0000-0000-0000-000000000002', 'owner', 'active'),
-- Carlos en Academia Tech
('u2000002-0000-0000-0000-000000000002', 'd0000003-0000-0000-0000-000000000003', 'teacher', 'active'),
('u2000003-0000-0000-0000-000000000003', 'd0000003-0000-0000-0000-000000000003', 'teacher', 'active'),
-- Ana en Instituto Bilingüe
('u3000003-0000-0000-0000-000000000003', 'd0000004-0000-0000-0000-000000000004', 'owner', 'active'),
-- Luis en Club de Robótica
('u3000004-0000-0000-0000-000000000004', 'd0000005-0000-0000-0000-000000000005', 'owner', 'active');

-- Estudiantes en sus unidades
INSERT INTO unit_membership (unit_id, user_id, unit_role, status) VALUES
('u1000004-0000-0000-0000-000000000004', 'e0000001-0000-0000-0000-000000000001', 'student', 'active'),
('u1000004-0000-0000-0000-000000000004', 'e0000002-0000-0000-0000-000000000002', 'student', 'active'),
('u1000005-0000-0000-0000-000000000005', 'e0000003-0000-0000-0000-000000000003', 'student', 'active'),
('u1000006-0000-0000-0000-000000000006', 'e0000004-0000-0000-0000-000000000004', 'student', 'active'),
('u1000006-0000-0000-0000-000000000006', 'e0000010-0000-0000-0000-000000000010', 'student', 'active'),
('u2000002-0000-0000-0000-000000000002', 'e0000005-0000-0000-0000-000000000005', 'student', 'active'),
('u2000003-0000-0000-0000-000000000003', 'e0000006-0000-0000-0000-000000000006', 'student', 'active'),
('u3000003-0000-0000-0000-000000000003', 'e0000007-0000-0000-0000-000000000007', 'student', 'active'),
('u3000003-0000-0000-0000-000000000003', 'e0000008-0000-0000-0000-000000000008', 'student', 'active'),
('u3000003-0000-0000-0000-000000000003', 'e0000009-0000-0000-0000-000000000009', 'student', 'active'),
-- Algunos estudiantes también en club de robótica
('u3000004-0000-0000-0000-000000000004', 'e0000007-0000-0000-0000-000000000007', 'student', 'active'),
('u3000004-0000-0000-0000-000000000004', 'e0000008-0000-0000-0000-000000000008', 'student', 'active');

-- =====================================================
-- SECCIÓN 7: MATERIAS
-- =====================================================

INSERT INTO subject (id, school_id, name, description) VALUES
('s1000001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Matemáticas', 'Matemáticas para primaria'),
('s1000002-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'Comunicación', 'Lenguaje y comunicación'),
('s1000003-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'Ciencias Naturales', 'Ciencias para primaria'),
('s2000001-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', 'Programación', 'Desarrollo de software'),
('s2000002-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'Algoritmos', 'Estructuras de datos y algoritmos'),
('s3000001-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333333', 'Historia del Perú', 'Historia nacional'),
('s3000002-0000-0000-0000-000000000002', '33333333-3333-3333-3333-333333333333', 'Inglés', 'Idioma inglés'),
('s3000003-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333333', 'Robótica', 'Introducción a la robótica');

-- =====================================================
-- SECCIÓN 8: MATERIALES EDUCATIVOS
-- =====================================================

INSERT INTO learning_material (id, author_id, subject_id, title, description, s3_url, extra_metadata, published_at, status) VALUES
-- Materiales del Colegio San José
('m1000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 's1000001-0000-0000-0000-000000000001',
 'Introducción a las Fracciones', 'Material sobre fracciones básicas para 5º grado',
 's3://edugo-materials/11111111-1111-1111-1111-111111111111/u1000004/m1000001/source/fracciones.pdf',
 '{"keywords": ["fracciones", "matemáticas", "primaria"], "level": "básico"}'::jsonb,
 NOW() - INTERVAL '10 days', 'published'),

('m1000002-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000001', 's1000001-0000-0000-0000-000000000001',
 'Geometría Básica: Triángulos', 'Introducción a los triángulos y sus propiedades',
 's3://edugo-materials/11111111-1111-1111-1111-111111111111/u1000004/m1000002/source/triangulos.pdf',
 '{"keywords": ["geometría", "triángulos", "matemáticas"], "level": "básico"}'::jsonb,
 NOW() - INTERVAL '5 days', 'published'),

('m1000003-0000-0000-0000-000000000003', 'd0000002-0000-0000-0000-000000000002', 's1000003-0000-0000-0000-000000000003',
 'El Sistema Solar', 'Explorando los planetas de nuestro sistema solar',
 's3://edugo-materials/11111111-1111-1111-1111-111111111111/u1000006/m1000003/source/sistema_solar.pdf',
 '{"keywords": ["ciencias", "astronomía", "planetas"], "level": "intermedio"}'::jsonb,
 NOW() - INTERVAL '3 days', 'published'),

-- Materiales de Academia Tech
('m2000001-0000-0000-0000-000000000001', 'd0000003-0000-0000-0000-000000000003', 's2000001-0000-0000-0000-000000000001',
 'Fundamentos de Python', 'Introducción a la programación con Python',
 's3://edugo-materials/22222222-2222-2222-2222-222222222222/u2000002/m2000001/source/python_basics.pdf',
 '{"keywords": ["python", "programación", "básico"], "language": "python"}'::jsonb,
 NOW() - INTERVAL '15 days', 'published'),

('m2000002-0000-0000-0000-000000000002', 'd0000003-0000-0000-0000-000000000003', 's2000001-0000-0000-0000-000000000001',
 'Variables y Tipos de Datos', 'Conceptos fundamentales de programación',
 's3://edugo-materials/22222222-2222-2222-2222-222222222222/u2000002/m2000002/source/variables.pdf',
 '{"keywords": ["variables", "tipos de datos", "programación"], "language": "python"}'::jsonb,
 NOW() - INTERVAL '12 days', 'published'),

('m2000003-0000-0000-0000-000000000003', 'd0000003-0000-0000-0000-000000000003', 's2000002-0000-0000-0000-000000000002',
 'Estructuras de Control', 'If, while, for y estructuras de control',
 's3://edugo-materials/22222222-2222-2222-2222-222222222222/u2000003/m2000003/source/control_structures.pdf',
 '{"keywords": ["control", "if", "while", "for"], "language": "python"}'::jsonb,
 NOW() - INTERVAL '7 days', 'published'),

-- Materiales del Instituto Bilingüe
('m3000001-0000-0000-0000-000000000001', 'd0000004-0000-0000-0000-000000000004', 's3000001-0000-0000-0000-000000000001',
 'El Imperio Inca', 'Historia y cultura del Tahuantinsuyo',
 's3://edugo-materials/33333333-3333-3333-3333-333333333333/u3000003/m3000001/source/incas.pdf',
 '{"keywords": ["historia", "incas", "perú"], "level": "intermedio"}'::jsonb,
 NOW() - INTERVAL '8 days', 'published'),

('m3000002-0000-0000-0000-000000000002', 'd0000004-0000-0000-0000-000000000004', 's3000002-0000-0000-0000-000000000002',
 'Present Simple Tense', 'Grammar guide for present simple in English',
 's3://edugo-materials/33333333-3333-3333-3333-333333333333/u3000003/m3000002/source/present_simple.pdf',
 '{"keywords": ["english", "grammar", "present simple"], "language": "en"}'::jsonb,
 NOW() - INTERVAL '6 days', 'published'),

('m3000003-0000-0000-0000-000000000003', 'd0000005-0000-0000-0000-000000000005', 's3000003-0000-0000-0000-000000000003',
 'Arduino Básico', 'Introducción a Arduino y programación de microcontroladores',
 's3://edugo-materials/33333333-3333-3333-3333-333333333333/u3000004/m3000003/source/arduino.pdf',
 '{"keywords": ["arduino", "robótica", "electrónica"], "level": "básico"}'::jsonb,
 NOW() - INTERVAL '4 days', 'published');

-- Material en borrador
INSERT INTO learning_material (id, author_id, subject_id, title, description, status) VALUES
('m1000004-0000-0000-0000-000000000004', 'd0000001-0000-0000-0000-000000000001', 's1000001-0000-0000-0000-000000000001',
 'Números Decimales', 'Material en preparación sobre decimales', 'draft');

-- =====================================================
-- SECCIÓN 9: VERSIONES DE MATERIALES
-- =====================================================

INSERT INTO material_version (material_id, s3_version_url, file_hash) VALUES
('m1000001-0000-0000-0000-000000000001', 's3://edugo-materials/11111111-1111-1111-1111-111111111111/u1000004/m1000001/processed/v1.pdf', 'a1b2c3d4e5f6...'),
('m1000002-0000-0000-0000-000000000002', 's3://edugo-materials/11111111-1111-1111-1111-111111111111/u1000004/m1000002/processed/v1.pdf', 'b2c3d4e5f6a1...'),
('m2000001-0000-0000-0000-000000000001', 's3://edugo-materials/22222222-2222-2222-2222-222222222222/u2000002/m2000001/processed/v1.pdf', 'c3d4e5f6a1b2...'),
('m2000001-0000-0000-0000-000000000001', 's3://edugo-materials/22222222-2222-2222-2222-222222222222/u2000002/m2000001/processed/v2.pdf', 'd4e5f6a1b2c3...'), -- Segunda versión
('m3000001-0000-0000-0000-000000000001', 's3://edugo-materials/33333333-3333-3333-3333-333333333333/u3000003/m3000001/processed/v1.pdf', 'e5f6a1b2c3d4...');

-- =====================================================
-- SECCIÓN 10: ASIGNACIÓN DE MATERIALES A UNIDADES
-- =====================================================

INSERT INTO material_unit_link (material_id, unit_id, scope, visibility) VALUES
-- Materiales de matemáticas en 5º A
('m1000001-0000-0000-0000-000000000001', 'u1000004-0000-0000-0000-000000000004', 'unit', 'public'),
('m1000002-0000-0000-0000-000000000002', 'u1000004-0000-0000-0000-000000000004', 'unit', 'public'),
-- También en 5º B
('m1000001-0000-0000-0000-000000000001', 'u1000005-0000-0000-0000-000000000005', 'unit', 'public'),
-- Material de ciencias en 6º A
('m1000003-0000-0000-0000-000000000003', 'u1000006-0000-0000-0000-000000000006', 'unit', 'public'),
-- Materiales de programación
('m2000001-0000-0000-0000-000000000001', 'u2000002-0000-0000-0000-000000000002', 'unit', 'public'),
('m2000002-0000-0000-0000-000000000002', 'u2000002-0000-0000-0000-000000000002', 'unit', 'public'),
('m2000003-0000-0000-0000-000000000003', 'u2000003-0000-0000-0000-000000000003', 'unit', 'public'),
-- Materiales del Instituto Bilingüe
('m3000001-0000-0000-0000-000000000001', 'u3000003-0000-0000-0000-000000000003', 'unit', 'public'),
('m3000002-0000-0000-0000-000000000002', 'u3000003-0000-0000-0000-000000000003', 'unit', 'public'),
('m3000003-0000-0000-0000-000000000003', 'u3000004-0000-0000-0000-000000000004', 'club', 'public');

-- =====================================================
-- SECCIÓN 11: PROGRESO DE LECTURA
-- =====================================================

INSERT INTO reading_log (material_id, user_id, progress, last_access_at) VALUES
-- Pedro leyendo fracciones
('m1000001-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', 0.75, NOW() - INTERVAL '2 hours'),
-- Lucía completó fracciones
('m1000001-0000-0000-0000-000000000001', 'e0000002-0000-0000-0000-000000000002', 1.0, NOW() - INTERVAL '1 day'),
-- Lucía leyendo triángulos
('m1000002-0000-0000-0000-000000000002', 'e0000002-0000-0000-0000-000000000002', 0.50, NOW() - INTERVAL '3 hours'),
-- Diego leyendo sistema solar
('m1000003-0000-0000-0000-000000000003', 'e0000004-0000-0000-0000-000000000004', 0.30, NOW() - INTERVAL '1 day'),
-- Camila en Python
('m2000001-0000-0000-0000-000000000001', 'e0000005-0000-0000-0000-000000000005', 0.85, NOW() - INTERVAL '5 hours'),
('m2000002-0000-0000-0000-000000000002', 'e0000005-0000-0000-0000-000000000005', 0.60, NOW() - INTERVAL '1 hour'),
-- Valentina en historia
('m3000001-0000-0000-0000-000000000001', 'e0000007-0000-0000-0000-000000000007', 0.40, NOW() - INTERVAL '2 days');

-- =====================================================
-- SECCIÓN 12: ENLACES A RESÚMENES EN MONGODB
-- =====================================================

INSERT INTO material_summary_link (material_id, mongo_document_id, status) VALUES
('m1000001-0000-0000-0000-000000000001', 'mongo-sum-0000-0000-0000-000000000001', 'complete'),
('m1000002-0000-0000-0000-000000000002', 'mongo-sum-0000-0000-0000-000000000002', 'complete'),
('m2000001-0000-0000-0000-000000000001', 'mongo-sum-0000-0000-0000-000000000003', 'complete'),
('m3000001-0000-0000-0000-000000000001', 'mongo-sum-0000-0000-0000-000000000004', 'complete'),
('m1000004-0000-0000-0000-000000000004', 'mongo-sum-0000-0000-0000-000000000005', 'pending');

-- =====================================================
-- SECCIÓN 13: EVALUACIONES
-- =====================================================

INSERT INTO assessment (id, material_id, title, mongo_document_id, config) VALUES
('a1000001-0000-0000-0000-000000000001', 'm1000001-0000-0000-0000-000000000001',
 'Quiz: Fracciones Básicas', 'mongo-assess-0000-0000-0000-000000000001',
 '{"time_limit_minutes": 20, "max_attempts": 3}'::jsonb),

('a2000001-0000-0000-0000-000000000001', 'm2000001-0000-0000-0000-000000000001',
 'Examen: Python Fundamentos', 'mongo-assess-0000-0000-0000-000000000002',
 '{"time_limit_minutes": 30, "max_attempts": 2}'::jsonb),

('a3000001-0000-0000-0000-000000000001', 'm3000001-0000-0000-0000-000000000001',
 'Evaluación: Imperio Inca', 'mongo-assess-0000-0000-0000-000000000003',
 '{"time_limit_minutes": 25, "max_attempts": 2}'::jsonb);

-- =====================================================
-- SECCIÓN 14: INTENTOS DE EVALUACIÓN
-- =====================================================

INSERT INTO assessment_attempt (id, assessment_id, user_id, score, completed_at, started_at) VALUES
-- Pedro intentó el quiz de fracciones
('at100001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000001',
 'e0000001-0000-0000-0000-000000000001', 85.0, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day 20 minutes'),

-- Lucía intentó el quiz de fracciones (dos intentos)
('at100002-0000-0000-0000-000000000002', 'a1000001-0000-0000-0000-000000000001',
 'e0000002-0000-0000-0000-000000000002', 75.0, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days 20 minutes'),
('at100003-0000-0000-0000-000000000003', 'a1000001-0000-0000-0000-000000000001',
 'e0000002-0000-0000-0000-000000000002', 95.0, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day 18 minutes'),

-- Camila en examen de Python
('at200001-0000-0000-0000-000000000001', 'a2000001-0000-0000-0000-000000000001',
 'e0000005-0000-0000-0000-000000000005', 88.0, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days 28 minutes'),

-- Valentina en evaluación de Historia (en progreso)
('at300001-0000-0000-0000-000000000001', 'a3000001-0000-0000-0000-000000000001',
 'e0000007-0000-0000-0000-000000000007', NULL, NULL, NOW() - INTERVAL '10 minutes');

-- =====================================================
-- SECCIÓN 15: RESPUESTAS DE EVALUACIONES
-- =====================================================

-- Respuestas de Pedro en quiz de fracciones
INSERT INTO assessment_attempt_answer (attempt_id, question_mongo_id, answer_payload, is_correct) VALUES
('at100001-0000-0000-0000-000000000001', 'q-frac-001', '{"answer": "A"}'::jsonb, true),
('at100001-0000-0000-0000-000000000001', 'q-frac-002', '{"answer": "B"}'::jsonb, true),
('at100001-0000-0000-0000-000000000001', 'q-frac-003', '{"answer": "C"}'::jsonb, false),
('at100001-0000-0000-0000-000000000001', 'q-frac-004', '{"answer": "A"}'::jsonb, true);

-- Respuestas del segundo intento de Lucía
INSERT INTO assessment_attempt_answer (attempt_id, question_mongo_id, answer_payload, is_correct) VALUES
('at100003-0000-0000-0000-000000000003', 'q-frac-001', '{"answer": "A"}'::jsonb, true),
('at100003-0000-0000-0000-000000000003', 'q-frac-002', '{"answer": "B"}'::jsonb, true),
('at100003-0000-0000-0000-000000000003', 'q-frac-003', '{"answer": "A"}'::jsonb, true),
('at100003-0000-0000-0000-000000000003', 'q-frac-004', '{"answer": "A"}'::jsonb, true);

-- Respuestas de Camila en Python
INSERT INTO assessment_attempt_answer (attempt_id, question_mongo_id, answer_payload, is_correct) VALUES
('at200001-0000-0000-0000-000000000001', 'q-py-001', '{"answer": "A"}'::jsonb, true),
('at200001-0000-0000-0000-000000000001', 'q-py-002', '{"answer": "B"}'::jsonb, true),
('at200001-0000-0000-0000-000000000001', 'q-py-003', '{"answer": "D"}'::jsonb, false);

-- =====================================================
-- FIN DE DATOS MOCK
-- =====================================================

-- Verificación de datos insertados
SELECT 'Usuarios creados: ' || COUNT(*) FROM app_user;
SELECT 'Colegios creados: ' || COUNT(*) FROM school;
SELECT 'Unidades académicas: ' || COUNT(*) FROM academic_unit;
SELECT 'Materiales: ' || COUNT(*) FROM learning_material;
SELECT 'Membresías: ' || COUNT(*) FROM unit_membership;
SELECT 'Evaluaciones: ' || COUNT(*) FROM assessment;
