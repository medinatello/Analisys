# Flujos Críticos - EduGo

**Última actualización:** 30 de Octubre, 2025
**Proyecto:** EduGo - Plataforma de Análisis de Evaluaciones

---

## 📋 Descripción General

Este documento describe los flujos críticos del sistema EduGo, mostrando cómo interactúan los microservicios, bases de datos y sistemas de mensajería.

---

## 🏗️ Arquitectura General

```
┌─────────────────────────────────────────────────────────────────┐
│                        USUARIOS FINALES                          │
│  (Profesores, Estudiantes, Tutores, Administradores)            │
└────────┬─────────────────────────────────┬────────────────────┘
         │                                 │
         │ HTTP/REST                       │ HTTP/REST
         ↓                                 ↓
┌──────────────────┐              ┌────────────────────────┐
│   API Mobile     │              │ API Administración     │
│   Puerto: 8080   │              │   Puerto: 8081         │
│                  │              │                        │
│ Funciones:       │              │ Funciones:             │
│ - Autenticación  │              │ - Gestión de usuarios  │
│ - Materiales     │              │ - Gestión de escuelas  │
│ - Evaluaciones   │              │ - Gestión de unidades  │
│ - Progreso       │              │ - Reportes admin       │
│ - Resúmenes      │              │                        │
└────┬────┬────┬───┘              └────┬───────┬───────────┘
     │    │    │                       │       │
     │    │    │                       │       │
     │    │    └───────┐               │       │
     │    │            │               │       │
     ↓    ↓            ↓               ↓       ↓
┌─────────────┐  ┌──────────┐   ┌──────────────────┐
│ PostgreSQL  │  │RabbitMQ  │   │   PostgreSQL     │
│  (Relacional)│  │(Message  │   │   (Relacional)   │
│             │  │ Queue)   │   │                  │
│ Tablas:     │  │          │   │ Tablas:          │
│ - users     │  │ Queues:  │   │ - users          │
│ - materials │  │ - material│   │ - schools        │
│ - progress  │  │   upload │   │ - units          │
└─────────────┘  │ - assess │   │ - subjects       │
                 │   attempt│   │ - guardians      │
                 └────┬─────┘   └──────────────────┘
                      │
                      │ Consume eventos
                      ↓
            ┌──────────────────┐
            │     Worker       │
            │   (Background)   │
            │                  │
            │ Funciones:       │
            │ - Procesar PDFs  │
            │ - Generar summaries│
            │ - Crear evaluaciones│
            │ - NLP con OpenAI │
            └───┬──────┬───────┘
                │      │
                ↓      ↓
         ┌───────┐  ┌────────┐
         │MongoDB│  │PostgreSQL│
         │       │  │          │
         │Colecciones:│   │Actualiza │
         │- summaries│   │estados   │
         │- assessments│ │          │
         └───────┘  └────────┘

┌─────────────────────────────────────────────────────┐
│              MÓDULO SHARED (Librería Go)            │
│                                                     │
│  auth • config • database • errors • logger         │
│  messaging • types • validator                      │
│                                                     │
│  Usado por TODOS los servicios                      │
└─────────────────────────────────────────────────────┘
```

---

## 🔄 FLUJO 1: Subida y Procesamiento de Material (Crítico)

Este es el flujo más importante del sistema.

### Descripción

Un profesor sube un archivo PDF de material educativo a través de la app móvil. El sistema debe procesar el PDF, generar un resumen usando IA, y crear evaluaciones automáticas.

### Actores

- **Usuario:** Profesor
- **Servicios:** API Mobile → RabbitMQ → Worker
- **Bases de Datos:** PostgreSQL, MongoDB

### Diagrama de Secuencia

```
Profesor          API Mobile       PostgreSQL      RabbitMQ        Worker         MongoDB
   │                  │                │              │              │              │
   │  1. POST         │                │              │              │              │
   │  /materials      │                │              │              │              │
   │  + PDF file      │                │              │              │              │
   ├─────────────────>│                │              │              │              │
   │                  │                │              │              │              │
   │                  │  2. Guardar    │              │              │              │
   │                  │  metadata      │              │              │              │
   │                  ├───────────────>│              │              │              │
   │                  │                │              │              │              │
   │                  │  3. INSERT     │              │              │              │
   │                  │  materials     │              │              │              │
   │                  │  (status=      │              │              │              │
   │                  │   pending)     │              │              │              │
   │                  │<───────────────┤              │              │              │
   │                  │  material_id   │              │              │              │
   │                  │                │              │              │              │
   │                  │  4. Publicar   │              │              │              │
   │                  │  evento        │              │              │              │
   │                  ├───────────────────────────────>│              │              │
   │                  │  {                            │              │              │
   │                  │   type: "MATERIAL_UPLOADED",  │              │              │
   │                  │   material_id: "uuid",        │              │              │
   │                  │   file_path: "/uploads/..."   │              │              │
   │                  │  }                            │              │              │
   │                  │                               │              │              │
   │  5. Response     │                               │              │              │
   │  201 Created     │                               │              │              │
   │<─────────────────┤                               │              │              │
   │  {material_id}   │                               │              │              │
   │                  │                               │              │              │
   │                  │                               │  6. Consume  │              │
   │                  │                               │  evento      │              │
   │                  │                               ├─────────────>│              │
   │                  │                               │              │              │
   │                  │                               │              │  7. Actualizar│
   │                  │                               │              │  estado      │
   │                  │                               │              ├────────────> │
   │                  │                               │              │  UPDATE      │
   │                  │                               │              │  materials   │
   │                  │                               │              │  status=     │
   │                  │                               │              │  processing  │
   │                  │                               │              │              │
   │                  │                               │              │  8. Leer PDF │
   │                  │                               │              ├──────────┐   │
   │                  │                               │              │  Extraer │   │
   │                  │                               │              │  texto   │   │
   │                  │                               │              │<─────────┘   │
   │                  │                               │              │              │
   │                  │                               │              │  9. OpenAI   │
   │                  │                               │              │  API         │
   │                  │                               │              ├──────────┐   │
   │                  │                               │              │  Generar │   │
   │                  │                               │              │  resumen │   │
   │                  │                               │              │<─────────┘   │
   │                  │                               │              │              │
   │                  │                               │              │  10. Guardar │
   │                  │                               │              │  summary     │
   │                  │                               │              ├─────────────>│
   │                  │                               │              │  INSERT      │
   │                  │                               │              │  summaries   │
   │                  │                               │              │              │
   │                  │                               │              │  11. Generar │
   │                  │                               │              │  preguntas   │
   │                  │                               │              ├──────────┐   │
   │                  │                               │              │  OpenAI  │   │
   │                  │                               │              │<─────────┘   │
   │                  │                               │              │              │
   │                  │                               │              │  12. Guardar │
   │                  │                               │              │  assessment  │
   │                  │                               │              ├─────────────>│
   │                  │                               │              │  INSERT      │
   │                  │                               │              │  assessments │
   │                  │                               │              │              │
   │                  │                               │              │  13. Actualizar│
   │                  │                               │              │  estado final│
   │                  │                               │              ├────────────> │
   │                  │                               │              │  UPDATE      │
   │                  │                               │              │  materials   │
   │                  │                               │              │  status=     │
   │                  │                               │              │  completed   │
   │                  │                               │              │              │
```

### Pasos Detallados

1. **Profesor sube material (POST /v1/materials)**
   - Endpoint: `POST /v1/materials`
   - Headers: `Authorization: Bearer {jwt_token}`
   - Body: Multipart form con archivo PDF
   - Validaciones:
     - Token JWT válido
     - Tipo de archivo permitido (PDF)
     - Tamaño máximo (ej: 50MB)

2. **API Mobile guarda metadata en PostgreSQL**
   - Tabla: `materials`
   - Campos:
     ```sql
     INSERT INTO materials (
       id,           -- UUID
       title,        -- Título del material
       subject_id,   -- Asignatura
       teacher_id,   -- Profesor que lo subió
       file_path,    -- Ruta al archivo
       status,       -- 'pending'
       created_at
     ) VALUES (...)
     ```

3. **API Mobile publica evento a RabbitMQ**
   - Queue: `edugo.material.uploaded`
   - Exchange: `edugo.materials`
   - Mensaje:
     ```json
     {
       "type": "MATERIAL_UPLOADED",
       "material_id": "550e8400-e29b-41d4-a716-446655440000",
       "file_path": "/uploads/materials/2025/10/filename.pdf",
       "teacher_id": "uuid-del-profesor",
       "subject_id": "uuid-de-la-asignatura",
       "timestamp": "2025-10-30T10:30:00Z"
     }
     ```

4. **API Mobile responde al profesor**
   - Status: `201 Created`
   - Body:
     ```json
     {
       "success": true,
       "data": {
         "material_id": "550e8400-e29b-41d4-a716-446655440000",
         "status": "pending",
         "message": "Material subido. Procesamiento en curso."
       }
     }
     ```

5. **Worker consume evento de RabbitMQ**
   - Consumer escuchando en queue `edugo.material.uploaded`
   - Prefetch: 5 mensajes
   - Timeout: 10 minutos por mensaje

6. **Worker actualiza estado a "processing"**
   ```sql
   UPDATE materials
   SET status = 'processing',
       processing_started_at = NOW()
   WHERE id = 'material_id'
   ```

7. **Worker lee y extrae texto del PDF**
   - Librería: `pdftotext` o similar
   - Extrae texto plano del PDF
   - Limpia formato y caracteres especiales

8. **Worker llama a OpenAI API para generar resumen**
   - Modelo: `gpt-4`
   - Prompt:
     ```
     Genera un resumen conciso de este material educativo.
     Identifica los conceptos clave y objetivos de aprendizaje.

     Texto: {texto_extraido}
     ```
   - Max tokens: 4000
   - Temperature: 0.7

9. **Worker guarda resumen en MongoDB**
   - Colección: `summaries`
   - Documento:
     ```json
     {
       "_id": "ObjectId",
       "material_id": "uuid",
       "summary": "Resumen generado por IA...",
       "key_concepts": ["concepto1", "concepto2"],
       "learning_objectives": ["objetivo1", "objetivo2"],
       "created_at": "2025-10-30T10:35:00Z"
     }
     ```

10. **Worker genera preguntas de evaluación con OpenAI**
    - Prompt:
      ```
      Basándote en este resumen, genera 5 preguntas de opción múltiple
      para evaluar la comprensión del estudiante.

      Resumen: {resumen}
      ```
    - Respuesta esperada: JSON con preguntas y respuestas

11. **Worker guarda evaluación en MongoDB**
    - Colección: `assessments`
    - Documento:
      ```json
      {
        "_id": "ObjectId",
        "material_id": "uuid",
        "questions": [
          {
            "question": "¿Cuál es el concepto principal?",
            "options": ["A", "B", "C", "D"],
            "correct_answer": "B",
            "explanation": "..."
          }
        ],
        "created_at": "2025-10-30T10:40:00Z"
      }
      ```

12. **Worker actualiza estado final a "completed"**
    ```sql
    UPDATE materials
    SET status = 'completed',
        processing_completed_at = NOW()
    WHERE id = 'material_id'
    ```

### Estados del Material

```
pending → processing → completed
                    ↓
                  failed
```

- **pending**: Material subido, esperando procesamiento
- **processing**: Worker está procesando el PDF
- **completed**: Resumen y evaluación generados exitosamente
- **failed**: Error durante el procesamiento

### Tiempos Esperados

- **Subida del PDF:** < 5 segundos
- **Publicación a RabbitMQ:** < 100ms
- **Consumo por Worker:** < 1 segundo
- **Procesamiento completo:** 1-3 minutos (depende de tamaño del PDF)
  - Extracción de texto: 10-30 segundos
  - OpenAI resumen: 30-60 segundos
  - OpenAI evaluación: 30-60 segundos
  - Guardado en BD: < 1 segundo

### Manejo de Errores

| Error | Acción |
|-------|--------|
| PDF corrupto | Worker marca material como `failed`, logs error |
| OpenAI API falla | Reintentos (3x con backoff exponencial), luego `failed` |
| MongoDB down | Mensaje vuelve a RabbitMQ (requeue), Worker reintenta |
| PostgreSQL down | Worker espera reconexión automática (shared/database) |

---

## 🎯 FLUJO 2: Intento de Evaluación por Estudiante

### Descripción

Un estudiante realiza un intento de evaluación asociada a un material.

### Diagrama

```
Estudiante    API Mobile    PostgreSQL    RabbitMQ    Worker    MongoDB
   │              │             │            │          │          │
   │  1. POST     │             │            │          │          │
   │  /materials/ │             │            │          │          │
   │  {id}/       │             │            │          │          │
   │  assessment/ │             │            │          │          │
   │  attempts    │             │            │          │          │
   ├─────────────>│             │            │          │          │
   │              │             │            │          │          │
   │              │  2. Validar │            │          │          │
   │              │  material   │            │          │          │
   │              │  existe     │            │          │          │
   │              ├────────────>│            │          │          │
   │              │<────────────┤            │          │          │
   │              │             │            │          │          │
   │              │  3. Publicar│            │          │          │
   │              │  evento     │            │          │          │
   │              ├─────────────────────────>│          │          │
   │              │  ASSESSMENT_ATTEMPT      │          │          │
   │              │             │            │          │          │
   │  4. Response │             │            │          │          │
   │  202 Accepted│             │            │          │          │
   │<─────────────┤             │            │          │          │
   │              │             │            │          │          │
   │              │             │            │  5. Consume        │
   │              │             │            │  evento │          │
   │              │             │            ├────────>│          │
   │              │             │            │          │          │
   │              │             │            │          │  6. Obtener│
   │              │             │            │          │  assessment│
   │              │             │            │          ├─────────>│
   │              │             │            │          │          │
   │              │             │            │          │  7. Evaluar│
   │              │             │            │          │  respuestas│
   │              │             │            │          ├────┐     │
   │              │             │            │          │    │     │
   │              │             │            │          │<───┘     │
   │              │             │            │          │          │
   │              │             │            │          │  8. Guardar│
   │              │             │            │          │  resultado│
   │              │             │            │          ├─────────>│
   │              │             │            │          │          │
   │              │             │  9. Actualizar       │          │
   │              │             │  progreso            │          │
   │              │             │<─────────────────────┤          │
   │              │             │                      │          │
```

### Pasos

1. Estudiante envía respuestas del assessment
2. API Mobile valida que el material existe y tiene assessment
3. API Mobile publica evento `ASSESSMENT_ATTEMPT` a RabbitMQ
4. API Mobile responde inmediatamente (202 Accepted)
5. Worker consume el evento
6. Worker obtiene las preguntas y respuestas correctas de MongoDB
7. Worker califica las respuestas del estudiante
8. Worker guarda resultado en MongoDB (colección `assessment_results`)
9. Worker actualiza progreso del estudiante en PostgreSQL

---

## 🔐 FLUJO 3: Autenticación de Usuario

### Descripción

Login de un usuario (profesor, estudiante, tutor o admin).

### Diagrama

```
Usuario      API Mobile/Admin    PostgreSQL    Shared (auth)
   │              │                  │               │
   │  1. POST     │                  │               │
   │  /auth/login │                  │               │
   │  {email,pwd} │                  │               │
   ├─────────────>│                  │               │
   │              │                  │               │
   │              │  2. Buscar user  │               │
   │              │  por email       │               │
   │              ├─────────────────>│               │
   │              │                  │               │
   │              │  3. User data    │               │
   │              │<─────────────────┤               │
   │              │                  │               │
   │              │  4. Verificar    │               │
   │              │  password hash   │               │
   │              ├────────┐          │               │
   │              │        │          │               │
   │              │<───────┘          │               │
   │              │                  │               │
   │              │  5. Generar JWT  │               │
   │              ├─────────────────────────────────>│
   │              │  GenerateToken(  │               │
   │              │    user_id,      │               │
   │              │    role          │               │
   │              │  )               │               │
   │              │                  │               │
   │              │  6. JWT token    │               │
   │              │<─────────────────────────────────┤
   │              │                  │               │
   │  7. Response │                  │               │
   │  200 OK      │                  │               │
   │  {token}     │                  │               │
   │<─────────────┤                  │               │
```

### Pasos

1. Usuario envía credenciales (email + password)
2. API busca usuario en PostgreSQL por email
3. API verifica hash de password (bcrypt)
4. API llama a `shared/pkg/auth` para generar JWT
5. JWT contiene claims: `user_id`, `role`, `exp` (expiración)
6. API responde con token
7. Usuario usa token en header `Authorization: Bearer {token}` para requests subsecuentes

---

## 📊 FLUJO 4: Consulta de Resumen de Material

### Descripción

Un estudiante consulta el resumen de un material ya procesado.

### Diagrama

```
Estudiante    API Mobile    MongoDB
   │              │            │
   │  1. GET      │            │
   │  /materials/ │            │
   │  {id}/summary│            │
   ├─────────────>│            │
   │              │            │
   │              │  2. Buscar │
   │              │  summary   │
   │              ├───────────>│
   │              │            │
   │              │  3. Summary│
   │              │  document  │
   │              │<───────────┤
   │              │            │
   │  4. Response │            │
   │  200 OK      │            │
   │  {summary}   │            │
   │<─────────────┤            │
```

Simple consulta a MongoDB para obtener el resumen ya generado.

---

## 🗄️ FLUJO 5: Gestión de Usuarios (Admin)

### Descripción

Un administrador crea un nuevo usuario (profesor/estudiante/tutor).

### Diagrama

```
Admin    API Admin    PostgreSQL
  │          │            │
  │  1. POST │            │
  │  /users  │            │
  ├─────────>│            │
  │          │            │
  │          │  2. Validar│
  │          │  datos     │
  │          ├───┐        │
  │          │   │        │
  │          │<──┘        │
  │          │            │
  │          │  3. Hash   │
  │          │  password  │
  │          ├───┐        │
  │          │   │        │
  │          │<──┘        │
  │          │            │
  │          │  4. INSERT │
  │          │  users     │
  │          ├───────────>│
  │          │            │
  │          │  5. user_id│
  │          │<───────────┤
  │          │            │
  │  6. 201  │            │
  │  Created │            │
  │<─────────┤            │
```

API Administración maneja operaciones CRUD de usuarios en PostgreSQL.

---

## 🔄 Resumen de Interacciones entre Servicios

### API Mobile

**Usa:**
- PostgreSQL (lectura/escritura de users, materials, progress)
- MongoDB (lectura de summaries, assessments)
- RabbitMQ (publica eventos)
- Shared (todos los paquetes)

**Expone:**
- Endpoints REST para mobile app

### API Administración

**Usa:**
- PostgreSQL (CRUD de users, schools, units, subjects)
- Shared (auth, logger, database, errors, types)

**Expone:**
- Endpoints REST para admin panel

### Worker

**Usa:**
- PostgreSQL (actualiza estados)
- MongoDB (guarda summaries, assessments)
- RabbitMQ (consume eventos)
- OpenAI API (procesamiento NLP)
- Shared (logger, database, messaging, types)

**No expone:**
- Sin endpoints HTTP (background job)

---

## ⚠️ Puntos Críticos de Falla

### 1. RabbitMQ Caído

**Impacto:** Eventos no se publican/consumen
**Mitigación:**
- Reconexión automática en `shared/pkg/messaging`
- Dead Letter Queue (DLQ) para mensajes fallidos
- Health checks en docker-compose

### 2. OpenAI API Falla

**Impacto:** Materiales quedan en estado `processing`
**Mitigación:**
- Reintentos con backoff exponencial (3 intentos)
- Marcar material como `failed` después de reintentos
- Logging detallado para debugging

### 3. MongoDB Caído

**Impacto:** No se pueden guardar summaries/assessments
**Mitigación:**
- Mensajes vuelven a RabbitMQ (requeue)
- Worker reintenta cuando MongoDB vuelve
- Reconexión automática en `shared/pkg/database/mongodb`

### 4. PostgreSQL Caído

**Impacto:** No se pueden guardar/leer materiales y usuarios
**Mitigación:**
- Reconexión automática en `shared/pkg/database/postgres`
- Pool de conexiones con health checks
- Endpoint de API responde con 503 Service Unavailable

---

## 📈 Métricas Clave a Monitorear

1. **Latencia de procesamiento de materiales**
   - Objetivo: < 3 minutos
   - Alerta: > 5 minutos

2. **Tasa de éxito de procesamiento**
   - Objetivo: > 95%
   - Alerta: < 90%

3. **Tamaño de queue de RabbitMQ**
   - Objetivo: < 100 mensajes
   - Alerta: > 500 mensajes

4. **Latencia de APIs**
   - Objetivo: p95 < 500ms
   - Alerta: p95 > 1000ms

5. **Disponibilidad de servicios**
   - Objetivo: 99.9% uptime
   - Alerta: < 99%

---

**Última actualización:** 30 de Octubre, 2025
**Mantenedor:** Equipo EduGo
