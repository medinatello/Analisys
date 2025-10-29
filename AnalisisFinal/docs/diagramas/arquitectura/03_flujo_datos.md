# Flujo de Datos en EduGo

## Descripción
Este diagrama muestra cómo fluyen los datos a través del sistema EduGo para los diferentes procesos de negocio, incluyendo flujos síncronos y asíncronos.

## Diagrama de Flujo General

```mermaid
sequenceDiagram
    participant D as Docente (KMP)
    participant E as Estudiante (KMP)
    participant API as API Mobile
    participant PG as PostgreSQL
    participant S3 as S3/MinIO
    participant Q as RabbitMQ
    participant W as Worker
    participant MONGO as MongoDB
    participant NLP as NLP Provider
    participant NOTIF as Notifications

    Note over D,NOTIF: FLUJO 1: PUBLICACIÓN DE MATERIAL (Síncrono + Asíncrono)

    D->>+API: POST /v1/materials
        {title, description, subject_id, unit_ids}
    API->>API: Validar permisos del docente
    API->>PG: INSERT INTO learning_material
    PG-->>API: material_id
    API->>PG: INSERT INTO material_unit_link (múltiples unidades)
    API->>S3: GeneratePresignedUploadURL(material_id)
    S3-->>API: upload_url (válido 15 min)
    API-->>D: 201 Created
        {material_id, upload_url}

    D->>+S3: PUT upload_url
        (multipart PDF)
    S3-->>-D: 200 OK

    D->>+API: POST /v1/materials/:id/upload-complete
    API->>PG: INSERT INTO material_version
        (file_hash, s3_key)
    API->>+Q: Publish event
        material_uploaded
        {material_id, s3_key, author_id}
    Q-->>-API: ACK
    API-->>-D: 202 Accepted
        "Procesando material..."

    Q->>+W: Consume material_uploaded
    W->>S3: DownloadFile(s3_key)
    S3-->>W: PDF bytes
    W->>W: ExtractText(PDF)
    W->>+NLP: GenerateSummary(text, language='es')
    NLP-->>-W: {sections[], glossary[], reflection_questions[]}
    W->>+MONGO: InsertOne(material_summary)
        {material_id, sections, glossary, ...}
    MONGO-->>-W: summary_id
    W->>+NLP: GenerateAssessment(text, language='es')
    NLP-->>-W: {questions[], title}
    W->>+MONGO: InsertOne(material_assessment)
        {material_id, questions[]}
    MONGO-->>-W: assessment_id
    W->>PG: UPDATE material_summary_link
        SET mongo_document_id = summary_id
    W->>PG: INSERT INTO assessment
        (material_id, mongo_document_id)
    W->>MONGO: InsertOne(material_event)
        {event_type, duration, status}
    W->>NOTIF: SendEmail(author_id)
        "Material listo"
    W->>-Q: ACK message

    Note over D,NOTIF: FLUJO 2: CONSUMO DE MATERIAL (Síncrono)

    E->>+API: GET /v1/materials?unit_id={id}
    API->>API: Extraer user_id de JWT
    API->>+PG: SELECT m.* FROM learning_material m
        JOIN material_unit_link mul ON m.id = mul.material_id
        WHERE mul.unit_id = $1
        AND EXISTS (SELECT 1 FROM unit_membership WHERE ...)
    PG-->>-API: [material1, material2, ...]
    API-->>-E: 200 OK
        [{id, title, description, subject_name, ...}]

    E->>+API: GET /v1/materials/:id
    API->>+PG: SELECT * FROM learning_material WHERE id = $1
    PG-->>-API: material
    API->>API: Validar permisos (unit_membership)
    API->>+S3: GeneratePresignedDownloadURL(material_id)
    S3-->>-API: download_url (válido 15 min)
    API->>+PG: SELECT mongo_document_id FROM material_summary_link
        WHERE material_id = $1
    PG-->>-API: summary_id
    API-->>-E: 200 OK
        {material, pdf_url: download_url, has_summary: true}

    E->>S3: GET download_url
    S3-->>E: PDF bytes (descarga directa)

    E->>+API: GET /v1/materials/:id/summary
    API->>+MONGO: FindOne(material_summary, {material_id: ...})
    MONGO-->>-API: {sections[], glossary[], reflection_questions[]}
    API-->>-E: 200 OK
        {sections[], glossary[], ...}

    E->>+API: PATCH /v1/materials/:id/progress
        {progress: 75, time_spent: 1200}
    API->>+PG: INSERT INTO reading_log
        (material_id, student_id, progress, time_spent)
        ON CONFLICT UPDATE
    PG-->>-API: OK
    API-->>-E: 200 OK

    Note over D,NOTIF: FLUJO 3: EVALUACIÓN (Síncrono + Asíncrono)

    E->>+API: GET /v1/materials/:id/assessment
    API->>+PG: SELECT mongo_document_id FROM assessment
        WHERE material_id = $1
    PG-->>-API: assessment_id
    API->>+MONGO: FindOne(material_assessment, {_id: assessment_id})
    MONGO-->>-API: {title, questions[]}
    API->>API: Remover respuestas correctas de questions[]
    API-->>-E: 200 OK
        {title, questions[{id, text, options[]}]}

    E->>+API: POST /v1/materials/:id/assessment/attempts
        {answers: [{question_id, selected_option}]}
    API->>+MONGO: FindOne(material_assessment, {_id: ...})
    MONGO-->>-API: {questions[]}
    API->>API: Calcular puntaje (comparar respuestas)
    API->>+PG: BEGIN TRANSACTION
    PG-->>-API: OK
    API->>+PG: INSERT INTO assessment_attempt
        (assessment_id, student_id, score, max_score)
    PG-->>-API: attempt_id
    API->>+PG: INSERT INTO assessment_attempt_answer
        (attempt_id, question_id, selected_option, is_correct)
        (múltiples inserts)
    PG-->>-API: OK
    API->>+PG: COMMIT TRANSACTION
    PG-->>-API: OK
    API->>+Q: Publish event
        assessment_attempt_recorded
        {attempt_id, student_id, material_id, score}
    Q-->>-API: ACK
    API-->>-E: 200 OK
        {attempt_id, score, max_score, feedback[]}

    Q->>+W: Consume assessment_attempt_recorded
    W->>+PG: SELECT m.title, u.name as student_name, a.score
        FROM assessment_attempt a
        JOIN learning_material m ON ...
        WHERE a.id = $1
    PG-->>-W: {material_title, student_name, score}
    W->>+PG: SELECT um.user_id FROM unit_membership um
        WHERE um.unit_id IN (...)
        AND um.role = 'teacher'
    PG-->>-W: [teacher_id1, teacher_id2]
    W->>NOTIF: SendEmail(teacher_ids)
        "Estudiante X completó Y con Z%"
    W->>-Q: ACK message

    Note over D,NOTIF: FLUJO 4: SEGUIMIENTO DE PROGRESO (Síncrono)

    D->>+API: GET /v1/materials/:id/stats
    API->>API: Validar permisos (autor o docente de unidad)
    API->>+PG: SELECT
          s.id, s.name,
          rl.progress, rl.last_access_at,
          aa.score, aa.created_at
        FROM unit_membership um
        JOIN student_profile s ON um.user_id = s.user_id
        LEFT JOIN reading_log rl ON rl.student_id = s.user_id AND rl.material_id = $1
        LEFT JOIN assessment_attempt aa ON aa.student_id = s.user_id
        WHERE um.unit_id IN (SELECT unit_id FROM material_unit_link WHERE material_id = $1)
        ORDER BY s.name
    PG-->>-API: [{student, progress, score, last_access}, ...]
    API->>API: Calcular agregados (promedio, completados, pendientes)
    API-->>-D: 200 OK
        {students: [...], summary: {avg_score, completion_rate}}
```

## Descripción Detallada de Flujos

---

## FLUJO 1: Publicación de Material

### Fase Síncrona (API Mobile)

**Paso 1-5**: Creación de Material
- **Entrada**: Docente envía metadatos del material (título, descripción, materia, unidades)
- **Validaciones**:
  - Docente tiene permiso en las unidades especificadas (`unit_membership` con rol `teacher` o `owner`)
  - La materia existe y pertenece a la escuela correcta
  - Límite de materiales no excedido (configurable)
- **Persistencia PostgreSQL**:
  - `learning_material`: Registro principal con `author_id`
  - `material_unit_link`: Uno por cada unidad asignada
- **Generación de URL firmada**:
  - S3 genera URL presignada para upload directo
  - Expiración: 15 minutos
  - Operación permitida: PUT únicamente
  - Prefijo: `{school_id}/{unit_id}/{material_id}/source/`
- **Respuesta**: `201 Created` con `material_id` y `upload_url`

**Paso 6-7**: Upload de Archivo
- **Flujo**: Cliente sube PDF directamente a S3 (no pasa por API)
- **Ventajas**:
  - Reduce carga en API
  - Mejor rendimiento para archivos grandes
  - Progreso de subida en cliente
- **Validaciones S3**:
  - Tamaño máximo: 100 MB (configurable)
  - Tipo de contenido: `application/pdf`
- **Confirmación**: Cliente notifica a API cuando upload completó

**Paso 8-12**: Registro de Versión y Evento
- **Persistencia PostgreSQL**:
  - `material_version`: Registro con `file_hash`, `s3_key`, `file_size`
  - Deduplicación: Si `file_hash` existe, reutilizar procesamiento
- **Publicación de Evento**:
  - Exchange: `edugo_events`
  - Routing Key: `material.uploaded`
  - Priority: 9 (alta)
  - Payload:
    ```json
    {
      "event_type": "material_uploaded",
      "event_id": "uuid",
      "material_id": "uuid",
      "author_id": "uuid",
      "s3_key": "school-1/unit-5/material-123/source/original.pdf",
      "preferred_language": "es",
      "timestamp": "2025-01-29T10:30:00Z"
    }
    ```
- **Respuesta**: `202 Accepted` - "Material en procesamiento, te notificaremos cuando esté listo"

### Fase Asíncrona (Worker)

**Paso 13-16**: Descarga y Extracción de Texto
- **Worker**: Consume mensaje de cola `material_processing_high` (FIFO)
- **Descarga**: Obtiene PDF de S3 usando credenciales IAM del worker
- **Extracción de Texto**:
  - Librerías: `pdftotext`, `Apache Tika`
  - OCR (si es necesario): Tesseract para PDFs escaneados
  - Límite: 50,000 palabras (fragmentar si excede)
- **Validación**: Mínimo 500 palabras de contenido útil

**Paso 17-19**: Generación de Resumen con IA
- **Construcción de Prompt**:
  ```
  Eres un asistente educativo especializado en crear resúmenes para estudiantes.

  Texto del material:
  [TEXTO EXTRAÍDO]

  Genera un resumen estructurado en JSON con:
  - 5-7 secciones temáticas con títulos descriptivos
  - Cada sección debe tener contenido de 100-200 palabras
  - Clasificar dificultad de cada sección: basic, medium, advanced
  - 10-15 términos clave con definiciones claras
  - 5-7 preguntas reflexivas que fomenten el pensamiento crítico

  Idioma: español
  Nivel educativo: secundaria/preparatoria
  ```
- **Llamada a NLP**:
  - Provider: OpenAI GPT-4 (configurado)
  - Temperature: 0.3 (respuestas consistentes)
  - Max tokens: 4000
  - Timeout: 60 segundos
- **Respuesta NLP**:
  ```json
  {
    "sections": [
      {
        "title": "Contexto Histórico",
        "content": "...",
        "difficulty": "basic"
      }
    ],
    "glossary": [
      {"term": "Compilador", "definition": "..."}
    ],
    "reflection_questions": [
      "¿Qué ventajas aporta Pascal sobre lenguajes anteriores?"
    ]
  }
  ```

**Paso 20-21**: Persistencia en MongoDB
- **Colección**: `material_summary`
- **Documento**:
  ```json
  {
    "_id": ObjectId("..."),
    "material_id": "uuid",
    "version": 1,
    "status": "completed",
    "sections": [...],
    "glossary": [...],
    "reflection_questions": [...],
    "processing_metadata": {
      "nlp_provider": "openai",
      "model": "gpt-4",
      "tokens_used": 3500,
      "processing_time_seconds": 45
    },
    "created_at": ISODate("2025-01-29T10:35:00Z"),
    "updated_at": ISODate("2025-01-29T10:35:00Z")
  }
  ```
- **Validación de Schema**: MongoDB valida con `$jsonSchema`

**Paso 22-24**: Generación de Evaluación
- **Reutiliza pipeline**: Mismo flujo que resumen
- **Prompt específico**:
  ```
  Genera 5 preguntas de opción múltiple basadas en el texto.

  Cada pregunta debe:
  - Tener 4 opciones (A, B, C, D)
  - Tener solo 1 respuesta correcta
  - Incluir retroalimentación para respuesta correcta e incorrecta
  - Variar tipos: recordación, comprensión, aplicación
  ```
- **Persistencia MongoDB**: Colección `material_assessment`

**Paso 25-28**: Actualización de Referencias y Notificación
- **Actualización PostgreSQL**:
  - `material_summary_link`: Liga `material_id` con `mongo_document_id` (summary)
  - `assessment`: Registro con `material_id`, `mongo_document_id` (assessment), `total_questions`
- **Registro de Evento**: Colección `material_event` en MongoDB
- **Notificación**:
  - Email al docente: "Tu material 'X' está listo para ser usado"
  - Push notification (si docente tiene app instalada)
- **ACK del mensaje**: Worker confirma procesamiento exitoso a RabbitMQ

---

## FLUJO 2: Consumo de Material

### Paso 1-5: Búsqueda de Materiales
- **Entrada**: Estudiante filtra por unidad académica
- **Extracción de JWT**: Middleware obtiene `user_id` del token
- **Query PostgreSQL**:
  ```sql
  SELECT
    m.id, m.title, m.description, m.created_at,
    s.name as subject_name,
    EXISTS(SELECT 1 FROM reading_log WHERE material_id = m.id AND student_id = $2) as started,
    rl.progress
  FROM learning_material m
  INNER JOIN material_unit_link mul ON m.id = mul.material_id
  INNER JOIN subject s ON m.subject_id = s.id
  LEFT JOIN reading_log rl ON rl.material_id = m.id AND rl.student_id = $2
  WHERE mul.unit_id = $1
  AND EXISTS (
    SELECT 1 FROM unit_membership um
    WHERE um.unit_id = $1 AND um.user_id = $2
  )
  ORDER BY m.created_at DESC
  ```
- **Validación de Permisos**: Query automáticamente filtra por `unit_membership`
- **Respuesta**: Lista de materiales con estado de progreso

### Paso 6-12: Obtención de Detalle
- **Entrada**: Estudiante selecciona material específico
- **Query PostgreSQL**: Obtiene metadatos completos
- **Validación de Permisos**: Verifica `unit_membership` antes de continuar
- **Generación de URL firmada**:
  - S3 genera URL para descarga (GET)
  - Expiración: 15 minutos
  - Headers: `Content-Disposition: attachment; filename="material.pdf"`
- **Consulta de Resumen**: Verifica si existe en `material_summary_link`
- **Respuesta Combinada**:
  ```json
  {
    "material": {
      "id": "uuid",
      "title": "Introducción a Pascal",
      "description": "...",
      "subject_name": "Programación",
      "created_at": "2025-01-15T12:00:00Z"
    },
    "pdf_url": "https://s3.../presigned-url",
    "has_summary": true,
    "has_assessment": true,
    "progress": 0
  }
  ```

### Paso 13-14: Descarga de PDF
- **Flujo**: Cliente descarga directamente desde S3 (no pasa por API)
- **Ventajas**: Reduce latencia y carga en API
- **Progreso**: Cliente puede mostrar barra de progreso de descarga

### Paso 15-18: Obtención de Resumen
- **Entrada**: Estudiante solicita resumen (puede ser antes/durante/después de leer PDF)
- **Query MongoDB**: Busca documento en `material_summary`
- **Respuesta**: Resumen completo con secciones, glosario y preguntas reflexivas
- **Caché**: Cliente puede cachear resumen localmente (SQLDelight - Post-MVP)

### Paso 19-22: Registro de Progreso
- **Entrada**: Cliente envía progreso periódicamente (cada 30 segundos de lectura)
- **Payload**:
  ```json
  {
    "progress": 75,
    "time_spent": 1200,
    "last_page": 15
  }
  ```
- **Upsert PostgreSQL**:
  ```sql
  INSERT INTO reading_log (material_id, student_id, progress, time_spent, last_access_at)
  VALUES ($1, $2, $3, $4, NOW())
  ON CONFLICT (material_id, student_id)
  DO UPDATE SET
    progress = GREATEST(reading_log.progress, EXCLUDED.progress),
    time_spent = reading_log.time_spent + EXCLUDED.time_spent,
    last_access_at = NOW()
  ```
- **Idempotencia**: Usa `GREATEST` para evitar regresiones de progreso

---

## FLUJO 3: Evaluación

### Paso 1-7: Obtención de Cuestionario
- **Consulta PostgreSQL**: Obtiene `mongo_document_id` de tabla `assessment`
- **Consulta MongoDB**: Obtiene documento completo de `material_assessment`
- **Sanitización**: **Remueve respuestas correctas** antes de enviar al cliente
- **Transformación**:
  ```json
  // Original en MongoDB
  {
    "questions": [
      {
        "id": "q1",
        "text": "¿Qué es un compilador?",
        "type": "multiple_choice",
        "options": [
          {"id": "a", "text": "Un programa que traduce código"},
          {"id": "b", "text": "Un tipo de variable"}
        ],
        "correct_answer": "a",  // ← REMOVIDO
        "feedback": {
          "correct": "¡Correcto! Un compilador traduce...",
          "incorrect": "Incorrecto. Revisa la sección..."
        }
      }
    ]
  }

  // Respuesta al cliente (sin respuestas)
  {
    "title": "Cuestionario de Pascal",
    "questions": [
      {
        "id": "q1",
        "text": "¿Qué es un compilador?",
        "options": [
          {"id": "a", "text": "Un programa que traduce código"},
          {"id": "b", "text": "Un tipo de variable"}
        ]
      }
    ]
  }
  ```

### Paso 8-19: Envío y Validación de Respuestas
- **Entrada**: Estudiante completa quiz y envía respuestas
- **Payload**:
  ```json
  {
    "answers": [
      {"question_id": "q1", "selected_option": "a"},
      {"question_id": "q2", "selected_option": "b"}
    ]
  }
  ```
- **Validación**:
  1. API obtiene preguntas originales de MongoDB (con respuestas correctas)
  2. Compara cada respuesta seleccionada con `correct_answer`
  3. Calcula puntaje: `(correctas / total) * 100`
- **Transacción PostgreSQL**:
  ```sql
  BEGIN;

  INSERT INTO assessment_attempt (assessment_id, student_id, score, max_score, started_at, completed_at)
  VALUES ($1, $2, $3, $4, $5, NOW())
  RETURNING id;

  INSERT INTO assessment_attempt_answer (attempt_id, question_id, selected_option, is_correct)
  VALUES
    ($1, 'q1', 'a', true),
    ($1, 'q2', 'b', false);

  COMMIT;
  ```
- **Publicación de Evento**: `assessment_attempt_recorded` a RabbitMQ
- **Respuesta con Feedback**:
  ```json
  {
    "attempt_id": "uuid",
    "score": 80,
    "max_score": 100,
    "correct_answers": 4,
    "total_questions": 5,
    "feedback": [
      {
        "question_id": "q1",
        "is_correct": true,
        "message": "¡Correcto! Un compilador traduce..."
      },
      {
        "question_id": "q2",
        "is_correct": false,
        "correct_answer": "a",
        "message": "Incorrecto. Revisa la sección sobre variables."
      }
    ]
  }
  ```

### Paso 20-26: Notificación Asíncrona
- **Worker**: Consume evento `assessment_attempt_recorded`
- **Consulta PostgreSQL**: Obtiene datos del intento, estudiante y material
- **Identificación de Docentes**:
  ```sql
  SELECT DISTINCT u.id, u.email
  FROM unit_membership um
  INNER JOIN app_user u ON um.user_id = u.id
  WHERE um.unit_id IN (
    SELECT unit_id FROM material_unit_link WHERE material_id = $1
  )
  AND um.role IN ('teacher', 'owner')
  ```
- **Envío de Notificaciones**:
  - Email: "Juan Pérez completó 'Introducción a Pascal' con 80%"
  - Push (si docente tiene app): Notificación similar
- **ACK**: Worker confirma procesamiento

---

## FLUJO 4: Seguimiento de Progreso

### Paso 1-7: Consulta de Estadísticas
- **Entrada**: Docente solicita estadísticas de un material
- **Validación de Permisos**: Verifica que docente es autor o tiene permiso en unidades asignadas
- **Query Compleja PostgreSQL**:
  ```sql
  SELECT
    sp.user_id,
    au.name as student_name,
    rl.progress,
    rl.time_spent,
    rl.last_access_at,
    (
      SELECT score
      FROM assessment_attempt aa
      WHERE aa.student_id = sp.user_id
      AND aa.assessment_id = (SELECT id FROM assessment WHERE material_id = $1)
      ORDER BY aa.created_at DESC
      LIMIT 1
    ) as latest_score,
    (
      SELECT created_at
      FROM assessment_attempt aa
      WHERE aa.student_id = sp.user_id
      AND aa.assessment_id = (SELECT id FROM assessment WHERE material_id = $1)
      ORDER BY aa.created_at DESC
      LIMIT 1
    ) as latest_attempt_date
  FROM unit_membership um
  INNER JOIN student_profile sp ON um.user_id = sp.user_id
  INNER JOIN app_user au ON sp.user_id = au.id
  LEFT JOIN reading_log rl ON rl.student_id = sp.user_id AND rl.material_id = $1
  WHERE um.unit_id IN (
    SELECT unit_id FROM material_unit_link WHERE material_id = $1
  )
  AND um.role = 'student'
  ORDER BY au.name
  ```
- **Agregaciones en API**:
  - Promedio de puntajes
  - Tasa de completación (progress = 100)
  - Estudiantes que no han iniciado
  - Tiempo promedio de lectura
- **Respuesta**:
  ```json
  {
    "material": {
      "id": "uuid",
      "title": "Introducción a Pascal"
    },
    "students": [
      {
        "id": "uuid",
        "name": "Juan Pérez",
        "progress": 100,
        "time_spent": 3600,
        "last_access": "2025-01-28T15:30:00Z",
        "latest_score": 80,
        "attempt_date": "2025-01-28T16:00:00Z",
        "status": "completed"
      },
      {
        "id": "uuid",
        "name": "María García",
        "progress": 45,
        "time_spent": 1200,
        "last_access": "2025-01-29T10:00:00Z",
        "latest_score": null,
        "attempt_date": null,
        "status": "in_progress"
      }
    ],
    "summary": {
      "total_students": 25,
      "completed": 10,
      "in_progress": 8,
      "not_started": 7,
      "average_score": 75.5,
      "average_time_spent": 2400
    }
  }
  ```

---

## Consideraciones de Rendimiento

### Optimizaciones de Queries

1. **Índices Compuestos**:
   - `(material_unit_link.unit_id, material_unit_link.material_id)`
   - `(reading_log.student_id, reading_log.material_id)`
   - `(assessment_attempt.student_id, assessment_attempt.assessment_id, assessment_attempt.created_at DESC)`

2. **Connection Pooling**:
   - PostgreSQL: Pool de 25 conexiones por instancia de API
   - MongoDB: Pool de 20 conexiones por instancia

3. **Caché (Post-MVP)**:
   - Redis para materiales frecuentes (TTL 5 min)
   - Caché de permisos de unidades (TTL 15 min)

### Optimizaciones de S3

1. **CloudFront/CDN**: Para PDFs frecuentemente accedidos
2. **Transfer Acceleration**: Para uploads grandes desde ubicaciones lejanas
3. **Multipart Upload**: Para PDFs > 5 MB

### Optimizaciones de MongoDB

1. **Proyecciones**: Obtener solo campos necesarios
   ```javascript
   db.material_summary.find(
     { material_id: "..." },
     { sections: 1, glossary: 1, _id: 0 }
   )
   ```

2. **Índices Text**: Para búsqueda en glosario y secciones
3. **Read Preference**: Secondary para consultas de solo lectura

---

## Manejo de Errores y Reintentos

### Errores Síncronos (API)

| Error | Código HTTP | Acción |
|-------|-------------|--------|
| Usuario no autenticado | 401 | Redirigir a login, refrescar JWT |
| Sin permisos | 403 | Mostrar mensaje educativo |
| Material no encontrado | 404 | Sugerir materiales similares |
| Validación fallida | 400 | Mostrar errores específicos por campo |
| Error de servidor | 500 | Retry con backoff (3 intentos), luego mostrar error |

### Errores Asíncronos (Worker)

| Error | Estrategia | DLQ |
|-------|-----------|-----|
| PDF corrupto | No reintentar, notificar docente | Sí |
| NLP timeout | Reintentar con backoff (5 intentos) | Sí |
| NLP rate limit | Reintentar después de espera indicada | No |
| MongoDB temporalmente caído | Reintentar indefinidamente con backoff | No |
| S3 temporalmente caído | Reintentar indefinidamente con backoff | No |

**Backoff Exponencial**:
- Intento 1: Inmediato
- Intento 2: 1 minuto
- Intento 3: 5 minutos
- Intento 4: 15 minutos
- Intento 5: 1 hora

---

## Consistencia Eventual

### Escenarios

1. **Material publicado pero resumen no disponible**:
   - Estado intermedio: `material_summary_link.status = 'processing'`
   - Cliente muestra: "Resumen en generación, disponible en breve"
   - Polling: Cliente puede consultar cada 30 segundos

2. **Evaluación completada pero notificación pendiente**:
   - Estudiante recibe feedback inmediato
   - Docente recibe notificación eventualmente (hasta 5 min)
   - No afecta experiencia del estudiante

3. **Progreso registrado pero stats desactualizados**:
   - Progreso individual es inmediato
   - Estadísticas agregadas pueden tener desfase de 1-2 segundos
   - Aceptable para uso docente

---

**Documento**: Flujo de Datos en EduGo
**Versión**: 1.0
**Fecha**: 2025-01-29
**Autor**: Equipo EduGo
