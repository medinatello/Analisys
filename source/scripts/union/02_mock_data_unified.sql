-- =====================================================
-- EduGo - Datos Mock para PostgreSQL UNIFICADO
-- Incluye datos tradicionales + datos JSONB
-- =====================================================

-- NOTA: Este archivo reutiliza los datos de PostgreSQL tradicional
-- y añade datos JSONB que antes estaban en MongoDB

-- =====================================================
-- PARTE 1: DATOS TRADICIONALES
-- (Copiar desde 03_mock_data.sql de postgresql)
-- =====================================================

-- Colegios
INSERT INTO school (id, name, external_code, location, metadata) VALUES
('11111111-1111-1111-1111-111111111111', 'Colegio San José', 'CSJ-001', 'Av. Principal 123, Lima, Perú', '{"phone": "+51-1-2345678", "website": "www.csj.edu.pe"}'::jsonb),
('22222222-2222-2222-2222-222222222222', 'Academia Tech', 'ATech-002', 'Jr. Tecnología 456, Lima, Perú', '{"phone": "+51-1-8765432", "type": "academia"}'::jsonb),
('33333333-3333-3333-3333-333333333333', 'Instituto Bilingüe Internacional', 'IBI-003', 'Av. Educación 789, Cusco, Perú', '{"phone": "+51-84-123456", "bilingual": true}'::jsonb);

-- Usuarios - Docentes
INSERT INTO app_user (id, email, credential_hash, system_role, status) VALUES
('d0000001-0000-0000-0000-000000000001', 'maria.garcia@csj.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active'),
('d0000002-0000-0000-0000-000000000002', 'juan.perez@csj.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active'),
('d0000003-0000-0000-0000-000000000003', 'carlos.rodriguez@atech.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active'),
('d0000004-0000-0000-0000-000000000004', 'ana.martinez@ibi.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active'),
('d0000005-0000-0000-0000-000000000005', 'luis.fernandez@ibi.edu.pe', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'teacher', 'active');

-- Usuarios - Estudiantes
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

-- Usuarios - Tutores
INSERT INTO app_user (id, email, credential_hash, system_role, status) VALUES
('g0000001-0000-0000-0000-000000000001', 'roberto.lopez@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active'),
('g0000002-0000-0000-0000-000000000002', 'carmen.sanchez@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active'),
('g0000003-0000-0000-0000-000000000003', 'miguel.torres@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active'),
('g0000004-0000-0000-0000-000000000004', 'patricia.ramirez@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active'),
('g0000005-0000-0000-0000-000000000005', 'jorge.flores@gmail.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'guardian', 'active');

-- Admin
INSERT INTO app_user (id, email, credential_hash, system_role, status) VALUES
('a0000001-0000-0000-0000-000000000001', 'admin@edugo.com', '$2a$10$abcdefghijklmnopqrstuvwxyz', 'admin', 'active');

-- Perfiles
INSERT INTO teacher_profile (user_id, specialty, preferences) VALUES
('d0000001-0000-0000-0000-000000000001', 'Matemáticas', '{"notification_email": true, "theme": "light"}'::jsonb),
('d0000002-0000-0000-0000-000000000002', 'Programación', '{"notification_email": false, "theme": "dark"}'::jsonb),
('d0000003-0000-0000-0000-000000000003', 'Inglés', '{"notification_email": true, "language": "en"}'::jsonb),
('d0000004-0000-0000-0000-000000000004', 'Historia', '{"notification_email": true, "theme": "light"}'::jsonb),
('d0000005-0000-0000-0000-000000000005', 'Ciencias', '{"notification_email": true, "theme": "light"}'::jsonb);

INSERT INTO guardian_profile (user_id, occupation, alternate_contact) VALUES
('g0000001-0000-0000-0000-000000000001', 'Ingeniero', '+51-999-111-222'),
('g0000002-0000-0000-0000-000000000002', 'Médica', '+51-999-222-333'),
('g0000003-0000-0000-0000-000000000003', 'Arquitecto', '+51-999-333-444'),
('g0000004-0000-0000-0000-000000000004', 'Abogada', '+51-999-444-555'),
('g0000005-0000-0000-0000-000000000005', 'Empresario', '+51-999-555-666');

-- Unidades académicas
INSERT INTO academic_unit (id, school_id, parent_unit_id, unit_type, name, code, metadata) VALUES
-- Colegio San José
('u1000001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', NULL, 'school', 'Colegio San José - Principal', 'CSJ-MAIN', '{}'::jsonb),
('u1000002-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'u1000001-0000-0000-0000-000000000001', 'academic_year', '5º de Primaria', 'CSJ-5P', '{"level": "primaria"}'::jsonb),
('u1000003-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'u1000001-0000-0000-0000-000000000001', 'academic_year', '6º de Primaria', 'CSJ-6P', '{"level": "primaria"}'::jsonb),
('u1000004-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', 'u1000002-0000-0000-0000-000000000002', 'section', '5º A', 'CSJ-5P-A', '{}'::jsonb),
('u1000005-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', 'u1000002-0000-0000-0000-000000000002', 'section', '5º B', 'CSJ-5P-B', '{}'::jsonb),
('u1000006-0000-0000-0000-000000000006', '11111111-1111-1111-1111-111111111111', 'u1000003-0000-0000-0000-000000000003', 'section', '6º A', 'CSJ-6P-A', '{}'::jsonb),
-- Academia Tech
('u2000001-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', NULL, 'school', 'Academia Tech - Centro', 'ATECH-MAIN', '{}'::jsonb),
('u2000002-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'u2000001-0000-0000-0000-000000000001', 'academy_level', 'Programación Básica', 'ATECH-BASIC', '{"duration_weeks": 12}'::jsonb),
('u2000003-0000-0000-0000-000000000003', '22222222-2222-2222-2222-222222222222', 'u2000001-0000-0000-0000-000000000001', 'academy_level', 'Programación Intermedia', 'ATECH-INTER', '{"duration_weeks": 16}'::jsonb),
-- Instituto Bilingüe
('u3000001-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333333', NULL, 'school', 'Instituto Bilingüe - Campus', 'IBI-MAIN', '{}'::jsonb),
('u3000002-0000-0000-0000-000000000002', '33333333-3333-3333-3333-333333333333', 'u3000001-0000-0000-0000-000000000001', 'academic_year', '1º de Secundaria', 'IBI-1S', '{"level": "secundaria"}'::jsonb),
('u3000003-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333333', 'u3000002-0000-0000-0000-000000000002', 'section', '1º A', 'IBI-1S-A', '{}'::jsonb),
('u3000004-0000-0000-0000-000000000004', '33333333-3333-3333-3333-333333333333', 'u3000001-0000-0000-0000-000000000001', 'club', 'Club de Robótica', 'IBI-ROBO', '{"schedule": "Viernes 3pm"}'::jsonb);

-- Perfiles de estudiantes
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

-- Relaciones tutor-estudiante
INSERT INTO guardian_student_relation (guardian_id, student_id, relationship_type, status) VALUES
('g0000001-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', 'padre', 'active'),
('g0000002-0000-0000-0000-000000000002', 'e0000002-0000-0000-0000-000000000002', 'madre', 'active'),
('g0000003-0000-0000-0000-000000000003', 'e0000003-0000-0000-0000-000000000003', 'padre', 'active'),
('g0000004-0000-0000-0000-000000000004', 'e0000004-0000-0000-0000-000000000004', 'madre', 'active'),
('g0000005-0000-0000-0000-000000000005', 'e0000005-0000-0000-0000-000000000005', 'padre', 'active'),
('g0000001-0000-0000-0000-000000000001', 'e0000010-0000-0000-0000-000000000010', 'padre', 'active');

-- Membresías
INSERT INTO unit_membership (unit_id, user_id, unit_role, status) VALUES
('u1000004-0000-0000-0000-000000000004', 'd0000001-0000-0000-0000-000000000001', 'owner', 'active'),
('u1000006-0000-0000-0000-000000000006', 'd0000002-0000-0000-0000-000000000002', 'owner', 'active'),
('u2000002-0000-0000-0000-000000000002', 'd0000003-0000-0000-0000-000000000003', 'teacher', 'active'),
('u2000003-0000-0000-0000-000000000003', 'd0000003-0000-0000-0000-000000000003', 'teacher', 'active'),
('u3000003-0000-0000-0000-000000000003', 'd0000004-0000-0000-0000-000000000004', 'owner', 'active'),
('u3000004-0000-0000-0000-000000000004', 'd0000005-0000-0000-0000-000000000005', 'owner', 'active'),
-- Estudiantes
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
('u3000004-0000-0000-0000-000000000004', 'e0000007-0000-0000-0000-000000000007', 'student', 'active'),
('u3000004-0000-0000-0000-000000000004', 'e0000008-0000-0000-0000-000000000008', 'student', 'active');

-- Materias
INSERT INTO subject (id, school_id, name, description) VALUES
('s1000001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Matemáticas', 'Matemáticas para primaria'),
('s1000002-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'Comunicación', 'Lenguaje y comunicación'),
('s1000003-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'Ciencias Naturales', 'Ciencias para primaria'),
('s2000001-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', 'Programación', 'Desarrollo de software'),
('s2000002-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'Algoritmos', 'Estructuras de datos y algoritmos'),
('s3000001-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333333', 'Historia del Perú', 'Historia nacional'),
('s3000002-0000-0000-0000-000000000002', '33333333-3333-3333-3333-333333333333', 'Inglés', 'Idioma inglés'),
('s3000003-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333333', 'Robótica', 'Introducción a la robótica');

-- Materiales
INSERT INTO learning_material (id, author_id, subject_id, title, description, s3_url, extra_metadata, published_at, status) VALUES
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
('m2000001-0000-0000-0000-000000000001', 'd0000003-0000-0000-0000-000000000003', 's2000001-0000-0000-0000-000000000001',
 'Fundamentos de Python', 'Introducción a la programación con Python',
 's3://edugo-materials/22222222-2222-2222-2222-222222222222/u2000002/m2000001/source/python_basics.pdf',
 '{"keywords": ["python", "programación", "básico"], "language": "python"}'::jsonb,
 NOW() - INTERVAL '15 days', 'published'),
('m3000001-0000-0000-0000-000000000001', 'd0000004-0000-0000-0000-000000000004', 's3000001-0000-0000-0000-000000000001',
 'El Imperio Inca', 'Historia y cultura del Tahuantinsuyo',
 's3://edugo-materials/33333333-3333-3333-3333-333333333333/u3000003/m3000001/source/incas.pdf',
 '{"keywords": ["historia", "incas", "perú"], "level": "intermedio"}'::jsonb,
 NOW() - INTERVAL '8 days', 'published');

-- Versiones de materiales
INSERT INTO material_version (material_id, s3_version_url, file_hash) VALUES
('m1000001-0000-0000-0000-000000000001', 's3://edugo-materials/11111111-1111-1111-1111-111111111111/u1000004/m1000001/processed/v1.pdf', 'a1b2c3d4e5f6...'),
('m1000002-0000-0000-0000-000000000002', 's3://edugo-materials/11111111-1111-1111-1111-111111111111/u1000004/m1000002/processed/v1.pdf', 'b2c3d4e5f6a1...'),
('m2000001-0000-0000-0000-000000000001', 's3://edugo-materials/22222222-2222-2222-2222-222222222222/u2000002/m2000001/processed/v1.pdf', 'c3d4e5f6a1b2...');

-- Asignación de materiales
INSERT INTO material_unit_link (material_id, unit_id, scope, visibility) VALUES
('m1000001-0000-0000-0000-000000000001', 'u1000004-0000-0000-0000-000000000004', 'unit', 'public'),
('m1000002-0000-0000-0000-000000000002', 'u1000004-0000-0000-0000-000000000004', 'unit', 'public'),
('m2000001-0000-0000-0000-000000000001', 'u2000002-0000-0000-0000-000000000002', 'unit', 'public'),
('m3000001-0000-0000-0000-000000000001', 'u3000003-0000-0000-0000-000000000003', 'unit', 'public');

-- Progreso de lectura
INSERT INTO reading_log (material_id, user_id, progress, last_access_at) VALUES
('m1000001-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', 0.75, NOW() - INTERVAL '2 hours'),
('m1000001-0000-0000-0000-000000000001', 'e0000002-0000-0000-0000-000000000002', 1.0, NOW() - INTERVAL '1 day'),
('m2000001-0000-0000-0000-000000000001', 'e0000005-0000-0000-0000-000000000005', 0.85, NOW() - INTERVAL '5 hours');

-- =====================================================
-- PARTE 2: DATOS JSONB (ex-MongoDB)
-- =====================================================

-- Material Summary JSON
INSERT INTO material_summary_json (material_id, version, summary_data, status, updated_at) VALUES
('m1000001-0000-0000-0000-000000000001', 1, '{
  "sections": [
    {
      "title": "Introducción a las Fracciones",
      "content": "Las fracciones son números que representan partes de un todo...",
      "level": "basic"
    },
    {
      "title": "Tipos de Fracciones",
      "content": "Existen tres tipos principales de fracciones...",
      "level": "intermediate"
    }
  ],
  "glossary": [
    {"term": "Numerador", "definition": "Número superior de una fracción"},
    {"term": "Denominador", "definition": "Número inferior de una fracción"}
  ],
  "reflection_questions": [
    "¿Por qué es importante tener un denominador común al sumar fracciones?",
    "¿En qué situaciones de la vida real utilizas fracciones?"
  ]
}'::jsonb, 'complete', '2024-02-01T10:00:00Z'),

('m2000001-0000-0000-0000-000000000001', 2, '{
  "sections": [
    {
      "title": "¿Qué es Python?",
      "content": "Python es un lenguaje de programación de alto nivel...",
      "level": "basic"
    },
    {
      "title": "Características Principales",
      "content": "Python es un lenguaje de tipado dinámico...",
      "level": "intermediate"
    }
  ],
  "glossary": [
    {"term": "Lenguaje interpretado", "definition": "Lenguaje que se ejecuta línea por línea"},
    {"term": "Tipado dinámico", "definition": "No es necesario declarar el tipo de variables"}
  ],
  "reflection_questions": [
    "¿Qué ventajas tiene Python sobre otros lenguajes?",
    "¿En qué proyecto te gustaría aplicar Python?"
  ]
}'::jsonb, 'complete', '2024-02-10T09:15:00Z'),

('m3000001-0000-0000-0000-000000000001', 1, '{
  "sections": [
    {
      "title": "El Tahuantinsuyo",
      "content": "El Imperio Inca fue el imperio más extenso...",
      "level": "basic"
    },
    {
      "title": "Organización Social",
      "content": "El imperio estaba gobernado por el Sapa Inca...",
      "level": "intermediate"
    }
  ],
  "glossary": [
    {"term": "Sapa Inca", "definition": "Título del emperador inca"},
    {"term": "Tahuantinsuyo", "definition": "Las cuatro regiones"}
  ],
  "reflection_questions": [
    "¿Qué aspectos de la organización inca podrían ser útiles hoy?",
    "¿Cómo lograron construir un imperio sin escritura?"
  ]
}'::jsonb, 'complete', '2024-02-08T16:45:00Z');

-- Material Assessment JSON
INSERT INTO material_assessment_json (material_id, title, version, assessment_data, total_points, estimated_duration_minutes) VALUES
('m1000001-0000-0000-0000-000000000001', 'Quiz: Fracciones Básicas', 1, '{
  "questions": [
    {
      "id": "q-frac-001",
      "text": "¿Qué representa el numerador en una fracción?",
      "type": "multiple_choice",
      "options": ["A) El número de partes que tenemos", "B) El número total de partes"],
      "answer": "A",
      "feedback": "¡Correcto! El numerador indica cuántas partes tenemos.",
      "difficulty": "easy",
      "points": 2
    },
    {
      "id": "q-frac-002",
      "text": "En la fracción 3/4, ¿cuál es el denominador?",
      "type": "multiple_choice",
      "options": ["A) 3", "B) 4", "C) 7"],
      "answer": "B",
      "feedback": "¡Exacto! El denominador es el número inferior.",
      "difficulty": "easy",
      "points": 2
    }
  ]
}'::jsonb, 10.0, 15),

('m2000001-0000-0000-0000-000000000001', 'Examen: Python Fundamentos', 1, '{
  "questions": [
    {
      "id": "q-py-001",
      "text": "¿Qué tipo de lenguaje es Python?",
      "type": "multiple_choice",
      "options": ["A) Interpretado y de alto nivel", "B) Compilado"],
      "answer": "A",
      "feedback": "¡Correcto! Python es interpretado y de alto nivel.",
      "difficulty": "easy",
      "points": 3
    },
    {
      "id": "q-py-002",
      "text": "Escribe un programa que imprima Hola Mundo",
      "type": "open_ended",
      "answer": null,
      "rubric": "Debe incluir print(\"Hola Mundo\")",
      "difficulty": "medium",
      "points": 5
    }
  ]
}'::jsonb, 15.0, 25);

-- Assessment Attempts
INSERT INTO assessment_attempt (assessment_id, user_id, score, completed_at, started_at) VALUES
(
  (SELECT id FROM material_assessment_json WHERE material_id = 'm1000001-0000-0000-0000-000000000001'),
  'e0000001-0000-0000-0000-000000000001',
  85.0,
  NOW() - INTERVAL '1 day',
  NOW() - INTERVAL '1 day 20 minutes'
),
(
  (SELECT id FROM material_assessment_json WHERE material_id = 'm2000001-0000-0000-0000-000000000001'),
  'e0000005-0000-0000-0000-000000000005',
  88.0,
  NOW() - INTERVAL '3 days',
  NOW() - INTERVAL '3 days 28 minutes'
);

-- Material Events JSON
INSERT INTO material_event_json (material_id, event_type, worker_id, duration_seconds, event_metadata, created_at) VALUES
('m1000001-0000-0000-0000-000000000001', 'processing_started', 'worker-nlp-01', NULL, '{}'::jsonb, '2024-01-22T10:00:00Z'),
('m1000001-0000-0000-0000-000000000001', 'processing_completed', 'worker-nlp-01', 45.3,
 '{"nlp_provider": "openai", "model": "gpt-4", "tokens_used": 1500}'::jsonb, '2024-01-22T10:00:45Z'),
('m2000001-0000-0000-0000-000000000001', 'processing_completed', 'worker-nlp-02', 52.7,
 '{"nlp_provider": "openai", "model": "gpt-4", "tokens_used": 2100}'::jsonb, '2024-01-16T14:00:53Z'),
('m3000001-0000-0000-0000-000000000001', 'processing_completed', 'worker-nlp-01', 38.9,
 '{"nlp_provider": "openai", "model": "gpt-4", "tokens_used": 1800}'::jsonb, '2024-01-29T16:30:39Z');

-- Unit Social Feed JSON (POST-MVP)
INSERT INTO unit_social_feed_json (unit_id, author_id, post_type, content, post_data, likes_count, created_at) VALUES
('u1000004-0000-0000-0000-000000000004', 'd0000001-0000-0000-0000-000000000001', 'announcement',
 'Recordatorio: Mañana tendremos un quiz sobre fracciones.',
 '{"attachments": [], "comments": [{"author_id": "e0000001-0000-0000-0000-000000000001", "text": "Gracias!", "created_at": "2024-02-12T15:30:00Z"}]}'::jsonb,
 5, '2024-02-12T15:00:00Z'),

('u2000002-0000-0000-0000-000000000002', 'd0000003-0000-0000-0000-000000000003', 'resource_share',
 'Les comparto este tutorial de Python.',
 '{"attachments": [{"type": "link", "url": "https://docs.python.org/es/3/tutorial/"}], "comments": []}'::jsonb,
 12, '2024-02-10T10:00:00Z');

-- User Graph Relations JSON (POST-MVP)
INSERT INTO user_graph_relation_json (user_id, related_user_id, relation_type, relation_metadata) VALUES
('e0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'follows',
 '{"affinity_score": 0.85, "common_interests": ["matemáticas", "geometría"]}'::jsonb),
('e0000005-0000-0000-0000-000000000005', 'd0000003-0000-0000-0000-000000000003', 'follows',
 '{"affinity_score": 0.92, "common_interests": ["programación", "python"]}'::jsonb);

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

SELECT 'Usuarios: ' || COUNT(*) FROM app_user;
SELECT 'Materiales: ' || COUNT(*) FROM learning_material;
SELECT 'Resúmenes JSON: ' || COUNT(*) FROM material_summary_json;
SELECT 'Evaluaciones JSON: ' || COUNT(*) FROM material_assessment_json;
SELECT 'Eventos JSON: ' || COUNT(*) FROM material_event_json;

print('\n✓ Datos mock unificados insertados correctamente');
