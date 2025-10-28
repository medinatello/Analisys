# Modelado de Unidades Académicas

[Volver a Documentación de Base de Datos](./README.md)

## 1. Contexto

Los requisitos incluyen múltiples niveles organizativos (colegio, año escolar, sesión, academias externas) y roles familiares. ¿Cómo se representa esta realidad en la base de datos? ¿Quién administra cada unidad? ¿Puede un estudiante participar en varias unidades? ¿Cómo se asigna el material?

## 2. Tablas Principales

El modelo se apoya en una jerarquía recursiva (`academic_unit`) y en una tabla de membresías (`unit_membership`) que otorga roles específicos a los usuarios.

| Tabla | Propósito | Campos relevantes | Notas |
|-------|-----------|-------------------|-------|
| `app_user` | Usuarios del sistema (credenciales + rol global) | `id`, `email`, `credential_hash`, `system_role`, `status`, `created_at` | `system_role` controla acceso general (docente, estudiante, admin, tutor). |
| `teacher_profile` | Datos adicionales del docente | `user_id`, `specialty`, `preferences` (`jsonb`) | `user_id` = FK `app_user.id`. |
| `student_profile` | Datos del estudiante | `user_id`, `primary_unit_id`, `current_grade`, `student_code` | `primary_unit_id` apunta a `academic_unit.id`. |
| `guardian_profile` | Datos del tutor/padre | `user_id`, `occupation`, `alternate_contact` | Soporta comunicaciones directas. |
| `guardian_student_relation` | Relación tutor ↔ estudiante | `id`, `guardian_id`, `student_id`, `relationship_type`, `status`, `created_at` | Multiplicidad muchos-a-muchos. |
| `school` | Entidad organizativa principal | `id`, `name`, `external_code`, `location`, `metadata`, `created_at` | Puede representar colegios o academias asociadas. |
| `academic_unit` | Jerarquía flexible | `id`, `school_id`, `parent_unit_id`, `unit_type`, `name`, `code`, `metadata`, `validity_period` (`tstzrange`) | `unit_type` enum: `school`, `academic_year`, `section`, `club`, `academy_level`, etc. |
| `unit_membership` | Participación de usuarios | `id`, `unit_id`, `user_id`, `unit_role`, `status`, `assigned_at`, `removed_at` | Roles: `owner`, `teacher`, `assistant`, `student`, `guardian`. |
| `subject` | Catálogo de materias | `id`, `school_id`, `name`, `description` | Vinculada a `learning_material`. |
| `learning_material` | Metadatos de recursos | `id`, `author_id`, `subject_id`, `title`, `description`, `s3_url`, `extra_metadata`, `published_at`, `status` | `author_id` = FK `app_user.id`. |
| `material_unit_link` | Publicación de material en unidades | `id`, `material_id`, `unit_id`, `scope`, `visibility` | Permite que un recurso esté en múltiples unidades. |

Complementan el modelo:

* `material_version`: histórico de archivos publicados (`s3_version_url`, `file_hash`, `generated_at`).
* `reading_log`: progreso de estudiantes en cada material (`progress`, `last_access_at`).
* `assessment`, `assessment_attempt`, `assessment_attempt_answer`: evaluaciones y resultados.
* `material_summary_link`: referencia a documentos en MongoDB.

## 3. Administración de Unidades

* **Administradores institucionales (`system_role = admin`)** crean colegios y definen la jerarquía macro (años, secciones, academias aliadas).
* **Docentes titulares (`unit_role = owner` o `teacher`)** pueden crear subunidades dentro de su ámbito, por ejemplo, grupos de proyecto o clubes.
* Las reglas de autorización derivan del par (`system_role`, `unit_role`). Por ejemplo, un docente titular puede añadir asistentes a su sección, pero no modificar otras secciones del colegio.

## 4. Ingreso de Usuarios

Dos mecanismos pueden convivir:

1. **Asignación directa:** API `POST /v1/units/{id}/members` crea un registro en `unit_membership` con el rol y vigencia deseada.
2. **Ingreso por código:** Se genera un token temporal asociado a la unidad; al validarlo, se crea el registro `unit_membership` correspondiente.

En ambos casos, `assigned_at` y `removed_at` preservan el historial de participación.

## 5. Participación Multinivel

* Un docente puede figurar como `teacher` en `academic_unit` distintas (ej. `school = Cristo Rey`, `unit_type = academic_year (5th)`, `unit_type = section (B)` y, adicionalmente, `school = Academia Americana`, `unit_type = academy_level (3rd)`, `section = D`).
* Un estudiante puede pertenecer simultáneamente a su colegio base y a academias externas; la app fusiona la información y permite filtrar por unidad.
* `guardian_student_relation` asegura que los tutores reciban visibilidad del progreso en todas las unidades donde participa el estudiante.

## 6. Ejemplo Narrativo

* **Estudiante:** María Pérez (`app_user.system_role = student`).
* **Unidad principal:** `academic_unit` con `unit_type = section`, nombre “5B”, bajo `school` “Colegio Cristo Rey”.
* **Unidad adicional:** `academic_unit` con `unit_type = section`, nombre “3D”, bajo `school` “Academia Americana”.
* **Tutor:** Juan Pérez (`system_role = guardian`) relacionado mediante `guardian_student_relation`.
* María recibe los materiales publicados en ambas unidades (`material_unit_link`), y su tutor puede revisar el progreso registrado en `reading_log` y `assessment_attempt`.

## 7. Interfaz y Experiencia

* **Docentes:** vista “Mis Unidades” agrupada por `school`, con opciones para crear subunidades (según permisos) y asignar material.
* **Estudiantes:** vista “Mis Espacios” mostrando la jerarquía (colegio, año, sesión, academia). Permite canjear códigos para nuevas unidades.
* **Tutores:** vista consolidada de las unidades de cada hijo, con acceso a métricas de progreso.

## 8. Conclusiones

El trinomio `academic_unit` + `unit_membership` + `material_unit_link` ofrece la flexibilidad requerida para representar colegios, academias, sesiones y actividades extracurriculares sin duplicar lógica. Esta base en PostgreSQL mantiene integridad y, junto con MongoDB y S3, prepara la evolución hacia funcionalidades colaborativas y sociales.
