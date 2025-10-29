# Modelo de Datos Completo - EduGo

## PostgreSQL - 17 Tablas

### Usuarios (6 tablas)
- `app_user` - Credenciales y rol
- `teacher_profile`, `student_profile`, `guardian_profile` - Perfiles específicos
- `guardian_student_relation` - Vínculo tutores-estudiantes
- `school` - Organizaciones educativas

### Jerarquía (2 tablas)
- `academic_unit` - Estructura jerárquica recursiva (escuela→año→sección→club)
- `unit_membership` - Usuarios en unidades con roles

### Materiales (5 tablas)
- `subject` - Catálogo de materias
- `learning_material` - Metadatos de materiales
- `material_version` - Historial de versiones
- `material_unit_link` - Asignación material↔unidad (N:M)
- `reading_log` - Progreso de lectura

### Evaluaciones (4 tablas)
- `material_summary_link` - Enlace a resumen en MongoDB
- `assessment` - Metadatos de quiz
- `assessment_attempt` - Intentos de estudiantes
- `assessment_attempt_answer` - Respuestas individuales

## MongoDB - 3 Colecciones MVP

- `material_summary` - Resúmenes generados por IA
- `material_assessment` - Bancos de preguntas
- `material_event` - Logs de procesamiento (TTL 90 días)

## S3 - Estructura

```
{school_id}/{unit_id}/{material_id}/
├── source/       (PDFs originales)
├── processed/    (PDFs optimizados, JSON)
└── assets/       (Portadas, thumbnails)
```

Ver scripts ejecutables en: [../../source/scripts/](../../source/scripts/)
