# Diagrama Entidad–Relación (SQL + Referencias NoSQL)

[Volver a Diagramas](./README.md) · [Volver a Detalle del Enfoque Híbrido](../README.md)

```mermaid
erDiagram
    USUARIO {
        uuid id_usuario
        string email
        string hash_credencial
        string rol_sistema
        string estado
        datetime creado_en
    }

    PERFIL_DOCENTE {
        uuid id_usuario
        string especialidad
        jsonb preferencias
    }

    PERFIL_ALUMNO {
        uuid id_usuario
        uuid unidad_principal_id
        string grado_actual
        string codigo_estudiantil
    }

    PERFIL_PADRE {
        uuid id_usuario
        string ocupacion
        string contacto_alternativo
    }

    RELACION_TUTORIA {
        uuid id_relacion
        uuid id_padre
        uuid id_hijo
        string tipo_relacion
        string estado
        datetime creado_en
    }

    COLEGIO {
        uuid id_colegio
        string nombre
        string codigo_externo
        string ubicacion
        jsonb metadata
        datetime creado_en
    }

    UNIDAD_ACADEMICA {
        uuid id_unidad
        uuid colegio_id
        uuid parent_id
        string tipo_unidad
        string nombre
        string codigo
        jsonb metadata
        tstzrange vigencia
    }

    UNIDAD_MIEMBRO {
        uuid id_unidad_miembro
        uuid id_unidad
        uuid id_usuario
        string rol_unidad
        string estado
        datetime asignado_en
        datetime removido_en
    }

    MATERIA {
        uuid id_materia
        uuid colegio_id
        string nombre
        string descripcion
    }

    MATERIAL {
        uuid id_material
        uuid id_docente
        uuid id_materia
        string titulo
        string descripcion
        string url_s3
        jsonb metadatos_extra
        datetime publicado_en
        string estado
    }

    MATERIAL_VERSION {
        uuid id_material_version
        uuid id_material
        string url_s3_version
        string hash_archivo
        datetime generado_en
    }

    MATERIAL_UNIDAD {
        uuid id_material_unidad
        uuid id_material
        uuid id_unidad
        string alcance
        string visibilidad
    }

    REGISTRO_LECTURA {
        uuid id_registro
        uuid id_material
        uuid id_usuario
        decimal progreso
        datetime ultimo_acceso
    }

    CUESTIONARIO {
        uuid id_cuestionario
        uuid id_material
        string titulo
        uuid doc_mongo
        datetime creado_en
    }

    INTENTO_CUESTIONARIO {
        uuid id_intento
        uuid id_cuestionario
        uuid id_usuario
        decimal puntaje
        datetime completado_en
    }

    RESPUESTA_INTENTO {
        uuid id_respuesta_intento
        uuid id_intento
        uuid id_pregunta_mongo
        jsonb respuesta
        boolean es_correcta
    }

    RESUMEN_MATERIAL_SQL {
        uuid id_material
        uuid doc_mongo
        datetime actualizado_en
    }

    USUARIO ||--o| PERFIL_DOCENTE : extiende
    USUARIO ||--o| PERFIL_ALUMNO : extiende
    USUARIO ||--o| PERFIL_PADRE : extiende
    USUARIO ||--o{ RELACION_TUTORIA : tutor
    USUARIO ||--o{ RELACION_TUTORIA : tutelado
    COLEGIO ||--o{ UNIDAD_ACADEMICA : organiza
    UNIDAD_ACADEMICA ||--o{ UNIDAD_ACADEMICA : subunidad
    UNIDAD_ACADEMICA ||--o{ UNIDAD_MIEMBRO : agrupa
    USUARIO ||--o{ UNIDAD_MIEMBRO : participa
    COLEGIO ||--o{ MATERIA : ofrece
    MATERIA ||--o{ MATERIAL : contiene
    USUARIO ||--o{ MATERIAL : publica
    MATERIAL ||--o{ MATERIAL_VERSION : versiona
    MATERIAL ||--o{ MATERIAL_UNIDAD : asigna
    UNIDAD_ACADEMICA ||--o{ MATERIAL_UNIDAD : recibe
    MATERIAL ||--o{ REGISTRO_LECTURA : registra
    MATERIAL ||--o| CUESTIONARIO : evalua
    MATERIAL ||--o| RESUMEN_MATERIAL_SQL : resume
    CUESTIONARIO ||--o{ INTENTO_CUESTIONARIO : registra
    INTENTO_CUESTIONARIO ||--o{ RESPUESTA_INTENTO : detalla
```

## Jerarquía Académica Flexible

- **Unidades escalables:** `UNIDAD_ACADEMICA` modela cualquier nivel (colegio → año escolar → sesión → subgrupos), con `parent_id` recursivo y metadatos `jsonb` para adaptar atributos específicos sin migraciones masivas.
- **Participación polimórfica:** `UNIDAD_MIEMBRO` permite que un usuario tenga múltiples roles simultáneos (docente titular en un año, co-docente en varias sesiones, alumno con sesiones optativas), preservando historial mediante `asignado_en` y `removido_en`.
- **Relaciones familiares:** `RELACION_TUTORIA` soporta que padres/tutores se vinculen a uno o varios alumnos, habilitando vistas familiares y permisos delegados.
- **Materiales reutilizables:** `MATERIAL_UNIDAD` conecta recursos con varias unidades (por ejemplo, compartir un material entre distintas sesiones o incluso entre colegios aliados).

## Claves del Modelo Relacional

- **Consultas jerárquicas eficientes:** PostgreSQL maneja árboles con CTE recursivos o extensiones como `ltree`, manteniendo integridad y buen rendimiento para navegar niveles verticales y horizontales.
- **Control de integridad:** Constraints (`CHECK tipo_unidad`, claves foráneas, `EXCLUDE` para vigencias superpuestas) garantizan consistencia ante la expansión de relaciones.
- **Históricos nativos:** Campos temporales (`tstzrange`, `asignado_en`, `removido_en`) facilitan auditoría y reportes evolutivos sin duplicar tablas.

## Documentos en MongoDB (NoSQL)

| Colección | Clave primaria | Contenido | Origen SQL relacionado |
|-----------|----------------|-----------|------------------------|
| `resumen_material` | `_id` (`doc_mongo`) | Secciones, glosario, tareas sugeridas, métricas de calidad | `RESUMEN_MATERIAL_SQL.doc_mongo` |
| `cuestionario_material` | `_id` (`doc_mongo`) | Preguntas, opciones, respuestas, retroalimentación | `CUESTIONARIO.doc_mongo` + `RESPUESTA_INTENTO.id_pregunta_mongo` |
| `evento_material` | `_id` autogenerado | Logs de actividades (visitas, descargas, errores IA) | `MATERIAL.id_material` |
| `unidad_social_feed` | `_id` autogenerado | Publicaciones, comentarios y reacciones por unidad académica | `UNIDAD_ACADEMICA.id_unidad` |
| `relacion_usuario_grafo` | `_id` (`uuid`) | Representación flexible de conexiones sociales (seguimientos, afinidades) | Complementa a `RELACION_TUTORIA` y futuros vínculos |

Las colecciones sociales permiten evolucionar hacia funcionalidades tipo red social sin comprometer la normalización del esquema SQL; se indexan por `unidad_id` y `usuario_id` para lecturas rápidas de feed.

## Organización en S3 (Almacenamiento de Objetos)

```
s3://edugo-materiales/{id_colegio}/{id_unidad}/{id_material}/
  ├─ source/
  │   ├─ {timestamp}_original.pdf
  ├─ processed/
  │   ├─ {id_material_version}.pdf
  │   └─ {id_material_version}.json   # resultados NLP opcionales
  └─ assets/
      └─ portada_{id_material_version}.png
```

- El prefijo ahora incluye `id_unidad` para aislar materiales por sesión o año escolar.
- `MATERIAL_UNIDAD.alcance` define si un recurso es público en todo el colegio, limitado a una sesión o compartido entre aliados externos.
- Eventos de subida disparan trabajos en cola para generar resúmenes y cuestionarios, manteniendo trazabilidad entre S3, SQL y MongoDB.
