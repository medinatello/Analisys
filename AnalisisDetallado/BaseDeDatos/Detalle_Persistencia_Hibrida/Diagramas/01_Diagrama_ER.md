# Diagrama Entidad–Relación

[Volver a Diagramas](./README.md) · [Volver a Detalle de Persistencia Híbrida](../README.md)

```mermaid
erDiagram
    APP_USER {
        uuid id
        string email
        string credential_hash
        string system_role
        string status
        datetime created_at
    }

    TEACHER_PROFILE {
        uuid user_id
        string specialty
        jsonb preferences
    }

    STUDENT_PROFILE {
        uuid user_id
        uuid primary_unit_id
        string current_grade
        string student_code
    }

    GUARDIAN_PROFILE {
        uuid user_id
        string occupation
        string alternate_contact
    }

    GUARDIAN_STUDENT_RELATION {
        uuid id
        uuid guardian_id
        uuid student_id
        string relationship_type
        string status
        datetime created_at
    }

    SCHOOL {
        uuid id
        string name
        string external_code
        string location
        jsonb metadata
        datetime created_at
    }

    ACADEMIC_UNIT {
        uuid id
        uuid school_id
        uuid parent_unit_id
        string unit_type
        string name
        string code
        jsonb metadata
        tstzrange validity_period
    }

    UNIT_MEMBERSHIP {
        uuid id
        uuid unit_id
        uuid user_id
        string unit_role
        string status
        datetime assigned_at
        datetime removed_at
    }

    SUBJECT {
        uuid id
        uuid school_id
        string name
        string description
    }

    LEARNING_MATERIAL {
        uuid id
        uuid author_id
        uuid subject_id
        string title
        string description
        string s3_url
        jsonb extra_metadata
        datetime published_at
        string status
    }

    MATERIAL_VERSION {
        uuid id
        uuid material_id
        string s3_version_url
        string file_hash
        datetime generated_at
    }

    MATERIAL_UNIT_LINK {
        uuid id
        uuid material_id
        uuid unit_id
        string scope
        string visibility
    }

    READING_LOG {
        uuid id
        uuid material_id
        uuid user_id
        decimal progress
        datetime last_access_at
    }

    ASSESSMENT {
        uuid id
        uuid material_id
        string title
        uuid mongo_document_id
        datetime created_at
    }

    ASSESSMENT_ATTEMPT {
        uuid id
        uuid assessment_id
        uuid user_id
        decimal score
        datetime completed_at
    }

    ASSESSMENT_ATTEMPT_ANSWER {
        uuid id
        uuid attempt_id
        uuid question_mongo_id
        jsonb answer_payload
        boolean is_correct
    }

    MATERIAL_SUMMARY_LINK {
        uuid material_id
        uuid mongo_document_id
        datetime updated_at
    }

    APP_USER ||--o| TEACHER_PROFILE : extends
    APP_USER ||--o| STUDENT_PROFILE : extends
    APP_USER ||--o| GUARDIAN_PROFILE : extends
    APP_USER ||--o{ UNIT_MEMBERSHIP : participates
    ACADEMIC_UNIT ||--o{ UNIT_MEMBERSHIP : enrolls
    SCHOOL ||--o{ ACADEMIC_UNIT : organizes
    ACADEMIC_UNIT ||--o{ ACADEMIC_UNIT : subunit
    SCHOOL ||--o{ SUBJECT : offers
    SUBJECT ||--o{ LEARNING_MATERIAL : contains
    APP_USER ||--o{ LEARNING_MATERIAL : authors
    LEARNING_MATERIAL ||--o{ MATERIAL_VERSION : versions
    LEARNING_MATERIAL ||--o{ MATERIAL_UNIT_LINK : assigned_to
    ACADEMIC_UNIT ||--o{ MATERIAL_UNIT_LINK : receives
    LEARNING_MATERIAL ||--o{ READING_LOG : tracked_by
    LEARNING_MATERIAL ||--o| ASSESSMENT : evaluates
    ASSESSMENT ||--o{ ASSESSMENT_ATTEMPT : produces
    ASSESSMENT_ATTEMPT ||--o{ ASSESSMENT_ATTEMPT_ANSWER : details
    LEARNING_MATERIAL ||--o| MATERIAL_SUMMARY_LINK : summarized_in
    APP_USER ||--o{ GUARDIAN_STUDENT_RELATION : guardian
    APP_USER ||--o{ GUARDIAN_STUDENT_RELATION : student
```

## Claves del Modelo

- **Jerarquía flexible:** `academic_unit` con `parent_unit_id` soporta colegios, años, sesiones y academias externas; los CTE recursivos permiten recorrer la estructura.
- **Roles polimórficos:** `unit_membership.unit_role` permite que un usuario tenga responsabilidades distintas en cada unidad (owner, teacher, assistant, student, guardian).
- **Relaciones familiares:** `guardian_student_relation` habilita permisos delegados y seguimiento del progreso por los tutores.
- **Asignación granular de recursos:** `material_unit_link` comparte materiales entre múltiples unidades sin duplicarlos.
- **Integración con MongoDB:** campos `mongo_document_id` conectan resúmenes y evaluaciones almacenados como documentos flexibles.

## Organización en S3

```
s3://edugo-materials/{school_id}/{unit_id}/{material_id}/
  ├─ source/
  │   └─ {timestamp}_original.pdf
  ├─ processed/
  │   ├─ {material_version_id}.pdf
  │   └─ {material_version_id}.json
  └─ assets/
      └─ cover_{material_version_id}.png
```

- El prefijo incluye `school_id` y `unit_id` para aplicar políticas de acceso diferenciadas.
- `material_version.file_hash` permite deduplicar cargas antes de lanzar workflows de procesamiento.
