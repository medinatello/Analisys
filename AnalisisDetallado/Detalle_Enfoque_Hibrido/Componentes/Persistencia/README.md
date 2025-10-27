# Persistencia: SQL, MongoDB y S3

[Volver a Componentes](../README.md) · [Volver a Detalle del Enfoque Híbrido](../../README.md)

Esta sección describe el modelo físico y las estrategias de persistencia para cada tecnología del enfoque híbrido, incorporando la jerarquía colegio → año escolar → sesión y las relaciones familiares y sociales proyectadas.

## PostgreSQL (Relacional)

PostgreSQL sigue siendo la pieza central para el MVP. El nuevo modelo aprovecha sus fortalezas:

- **Árboles y grafos ligeros:** `UNIDAD_ACADEMICA` utiliza `parent_id` y puede apoyarse en CTE recursivos o la extensión `ltree` para navegar niveles verticales y horizontales con buen rendimiento.
- **Integridad fuerte:** Constraints y `enum` (tipos) mantienen la consistencia entre colegios, años, sesiones, materiales y usuarios.
- **Flexibilidad controlada:** Campos `jsonb`/`tstzrange` permiten atributos variables sin perder esquema, ideal para evolucionar hacia funciones tipo red social.

### Tablas Principales del MVP

| Tabla | Objetivo | Campos clave | Índices sugeridos |
|-------|----------|--------------|-------------------|
| `usuario` | Autenticación y perfiles básicos | `id`, `email`, `hash_credencial`, `rol`, `estado` | `UNIQUE (email)`, `INDEX (rol)` |
| `perfil_docente` | Datos específicos del docente | `id_usuario`, `especialidad`, `preferencias` (`jsonb`) | `PK (id_usuario)` |
| `perfil_alumno` | Datos específicos del alumno | `id_usuario`, `unidad_principal_id`, `grado_actual` | `INDEX (unidad_principal_id)` |
| `perfil_padre` | Datos específicos del tutor | `id_usuario`, `ocupacion`, `contacto_alternativo` | `PK (id_usuario)` |
| `relacion_tutoria` | Vínculo padre ↔ hijo | `id`, `id_padre`, `id_hijo`, `tipo_relacion`, `estado` | `UNIQUE (id_padre, id_hijo, tipo_relacion)` |
| `colegio` | Organización base | `id`, `nombre`, `codigo_externo`, `ubicacion`, `metadata` (`jsonb`) | `UNIQUE (codigo_externo)` |
| `unidad_academica` | Jerarquía colegio → año → sesión | `id`, `colegio_id`, `parent_id`, `tipo_unidad`, `nombre`, `vigencia` (`tstzrange`), `metadata` (`jsonb`) | `INDEX (colegio_id)`, `INDEX (parent_id)`, `INDEX (tipo_unidad)` |
| `unidad_miembro` | Participación de usuarios en unidades | `id`, `unidad_id`, `usuario_id`, `rol_unidad`, `asignado_en`, `removido_en` | `UNIQUE (unidad_id, usuario_id, rol_unidad, asignado_en)` |
| `materia` | Catálogo por colegio | `id`, `colegio_id`, `nombre`, `descripcion` | `UNIQUE (colegio_id, nombre)` |
| `material` | Metadatos de archivos | `id`, `docente_id`, `materia_id`, `titulo`, `url_s3`, `estado`, `metadatos_extra` (`jsonb`) | `INDEX (materia_id)`, `GIN (metadatos_extra)` |
| `material_version` | Histórico de versiones de archivo | `id`, `material_id`, `url_s3_version`, `hash_archivo`, `generado_en` | `INDEX (material_id, generado_en DESC)` |
| `material_unidad` | Publicación de materiales en unidades | `id`, `material_id`, `unidad_id`, `alcance`, `visibilidad` | `UNIQUE (material_id, unidad_id)` |
| `registro_lectura` | Seguimiento de consumo | `id`, `material_id`, `usuario_id`, `progreso`, `ultimo_acceso` | `INDEX (usuario_id, material_id)` |
| `cuestionario` | Metadatos de cuestionarios | `id`, `material_id`, `doc_mongo`, `configuracion` (`jsonb`) | `UNIQUE (material_id)` |
| `intento_cuestionario` | Intentos del alumno | `id`, `cuestionario_id`, `usuario_id`, `puntaje`, `completado_en` | `INDEX (usuario_id, cuestionario_id)` |
| `respuesta_intento` | Respuestas detalladas | `id`, `intento_id`, `id_pregunta_mongo`, `respuesta` (`jsonb`), `es_correcta` | `INDEX (intento_id)` |
| `resumen_material_sql` | Referencia a resumen en Mongo | `material_id`, `doc_mongo`, `actualizado_en` | `PK (material_id)` |

### Tablas Post-MVP y Evolución

- `unidad_enlace_social`: relaciones transversales entre unidades (ej. sesiones hermanas o colaboraciones inter-colegio).
- `actividad_social_sql`: events ligeros (me gusta, insignias) con fan-out hacia Mongo o Redis Streams.
- Tablas de auditoría (`*_audit`) mediante `logical replication` para historial completo.

### Buenas Prácticas

- Claves UUIDv7 para mantener orden cronológico y compatibilidad multi-región.
- Constraints `CHECK (tipo_unidad IN (...))` y triggers que impiden jerarquías inconsistentes (por ejemplo, `parent_id` de una sesión debe ser un año escolar).
- Uso de `generated columns` para derivar rutas jerárquicas (`path` con `ltree`) y acelerar consultas de árbol.

## MongoDB (Documental)

### Colecciones

1. **`resumen_material`**  
   Resúmenes generados por IA; versionados y auditables.
   - Índices: `{ material_id: 1 }`, `{ estado_generacion: 1 }`.

2. **`cuestionario_material`**  
   Banco de preguntas estructurado; soporta distintos tipos.
   - Índices: `{ material_id: 1 }`, `{ "preguntas.id": 1 }`.

3. **`evento_material`**  
   Logs, errores, métricas de procesamiento.  
   - Índices: `{ material_id: 1, created_at: -1 }`.

4. **`unidad_social_feed`** *(Post-MVP)*  
   Publicaciones, comentarios, reacciones ligadas a `unidad_id`.  
   - ÍNDICES: `{ unidad_id: 1, created_at: -1 }`, `{ autor_id: 1 }`.

5. **`relacion_usuario_grafo`** *(Post-MVP)*  
   Representación flexible de conexiones sociales (seguimientos, afinidades, recomendaciones).  
   - Índices: `{ usuario_id: 1, tipo_relacion: 1 }`, `{ destino_id: 1 }`.

### Lineamientos

- Documentos ≤ 16 MB; dividir cuestionarios extensos.
- Schema validation (`$jsonSchema`) para acuerdos con la API.
- Estrategia de versionado interno (`version`) para migraciones backward-compatible.
- TTL opcional en colecciones sociales para contenidos efímeros.

## S3 / MinIO (Objetos)

- **Buckets:** `edugo-materiales-{env}`, separados por entorno.
- **Estructura:** Ver [Diagrama ER](../../Diagramas/01_Diagrama_ER.md). Prefijos incluyen `id_colegio` y `id_unidad` para facilitar reglas de acceso.
- **Metadatos:** `x-amz-meta-unidad`, `x-amz-meta-materia`, `x-amz-meta-docente` para filtros rápidos y auditoría.
- **Retención:** Lifecycle para trasladar versiones antiguas a Glacier o purgarlas pasados 90 días.
- **Seguridad:** URLs presignadas de corta duración; políticas IAM restringen workers a prefijos específicos.

## ¿Por qué PostgreSQL sigue siendo práctico para el MVP?

- **Consistencia ante todo:** Las relaciones estudiante‑padre‑docente‑sesión requieren integridad referencial estricta; PostgreSQL ofrece ACID y constraints avanzados que evitan datos huérfanos.
- **Consultas jerárquicas viables:** Reportes como “todas las sesiones activas de este colegio y sus docentes titulares” se resuelven con CTE recursivos (`WITH RECURSIVE`) o extensiones como `ltree`, sin sufrir los límites de NoSQL en joins complejos.
- **Extensibilidad:** Con `jsonb`, `range types` y `table partitioning`, PostgreSQL se adapta a crecimiento horizontal (sharding por colegio) y a la incorporación de atributos dinámicos sin sacrificar esquema.
- **Complemento NoSQL:** MongoDB y S3 cubren contenido flexible y archivos. Para un MVP, mantener el núcleo relacional en PostgreSQL reduce complejidad operativa y acelera validaciones; la evolución hacia una “red social educativa” se aborda con colecciones/documentos y, si es necesario, extensiones de grafos (`pgvector`, `AGE`).

## Sincronización entre Sistemas

- Eventos `material_subido`/`material_reprocesar` sincronizan SQL ↔ Mongo ↔ S3 mediante workers.
- Cambios en jerarquías (`unidad_academica`) disparan snapshots opcionales a `unidad_social_feed` para mantener timelines consistentes.
- Scripts ETL (`airflow`, `prefect`) validan la integridad entre `relacion_tutoria` en SQL y `relacion_usuario_grafo` en Mongo para evitar divergencias al habilitar funciones sociales.
