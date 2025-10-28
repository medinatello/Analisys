# Estrategia de Persistencia Híbrida

[Volver a Documentación de Base de Datos](./README.md)

## 1. Pregunta Original

Se propone usar una base de datos SQL y a la vez MongoDB/S3 para los materiales. ¿Cuál es el razonamiento para usar este enfoque híbrido? ¿Qué datos específicos irán en cada sistema?

## 2. Enfoque General

El uso de una base de datos relacional (PostgreSQL), una base documental (MongoDB) y almacenamiento de objetos (S3) sigue el patrón de **persistencia políglota**. Cada sistema resuelve una necesidad concreta y, en conjunto, permiten soportar escenarios complejos como estudiantes que pertenecen simultáneamente a múltiples colegios, años y sesiones.

> El modelado detallado (diagramas ER, jerarquías de unidades y colecciones NoSQL) se amplía en [Detalle_Persistencia_Hibrida](./Detalle_Persistencia_Hibrida/README.md).

### A. PostgreSQL (Relacional)

* **Datos Clave**
  * `app_user`: credenciales, rol del sistema y estado (docente, estudiante, administrador, tutor).
  * `academic_unit`: jerarquía colegio → año → sesión → grupos especiales, con recursividad mediante `parent_unit_id`.
  * `unit_membership`: relación N:M entre usuarios y unidades, controlando roles (`unit_role`) y vigencia.
  * `guardian_student_relation`: vínculos entre tutores y estudiantes.
  * `subject`, `learning_material`, `material_unit_link`: metadatos académicos y asignación de recursos.
  * `material_version`, `reading_log`, `assessment`, `assessment_attempt`, `assessment_attempt_answer`, `material_summary_link`: historial de versiones y resultados de aprendizaje.

* **Motivaciones**
  * **Consistencia ACID:** Integridad referencial entre usuarios, familias y unidades académicas.
  * **Consultas jerárquicas complejas:** CTE recursivos o extensiones (`ltree`) para navegar la estructura vertical y horizontal de colegios y academias.
  * **Esquema controlado + flexibilidad:** Columnas `jsonb`, campos de rango (`tstzrange`) y claves UUIDv7 permiten evolucionar sin perder gobernanza.

### B. S3 / MinIO (Objetos)

* **Datos Clave:** PDFs, videos, audios, assets derivados (portadas, archivos procesados).
* **Motivaciones:** Costos bajos, escalabilidad masiva y entrega directa por URL firmada. Se evitan binarios en la base relacional.

### C. MongoDB (Documental)

* **Colecciones**
  * `material_summary`: resúmenes generados por IA.
  * `material_assessment`: banco de preguntas y opciones.
  * `material_event`: trazas de procesamiento y métricas.
  * `unit_social_feed`, `user_graph_relation` (post-MVP): contenidos sociales y grafos de afinidad.

* **Motivaciones:** Esquemas flexibles, escalado horizontal y rapidez para documentos autocontenidos (resumen + preguntas), allanando el camino a funcionalidades tipo red social sin romper el modelo SQL.

## 3. Flujo de Datos

1. **Publicación de material**
   * Docente carga PDF -> API valida -> almacena binario en S3.
   * API persiste metadatos en `learning_material` y crea los enlaces en `material_unit_link`.
   * Evento `material_uploaded` se envía a la cola; los workers generan resumen/quiz y guardan en MongoDB.
   * Se actualiza `material_summary_link` y `material_assessment` con la referencia (`mongo_document_id`).

2. **Consumo del material**
   * Estudiante solicita contenido -> API consulta PostgreSQL (metadatos, permisos).
   * La app descarga el archivo de S3 mediante URL firmada.
   * Si hay resumen/cuestionario, la API lo obtiene desde MongoDB; si falta, programa re-generación.
   * El progreso se anota en `reading_log`; los intentos de evaluación en `assessment_attempt` / `assessment_attempt_answer`.

## 4. Conclusiones

* **PostgreSQL** sigue siendo el corazón transaccional: usuarios, roles, relaciones familiares y jerarquías requieren integridad fuerte.
* **S3** evita sobrecargar la base de datos con archivos pesados y facilita escalamiento.
* **MongoDB** ofrece elasticidad para contenido generado, eventos y futuros feeds sociales.

Este esquema híbrido provee una base sólida para el MVP y permite evolucionar hacia una plataforma educativa con características sociales avanzadas. La implementación inicial puede simplificarse guardando los documentos flexibles en columnas `jsonb`; la migración a MongoDB se planifica a medida que la complejidad y el volumen crecen.
