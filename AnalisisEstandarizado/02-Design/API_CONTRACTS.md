# 📨 Contratos de API - Ecosistema EduGo

**Fecha:** 16 de Noviembre, 2025  
**Versión:** 2.0.0

---

## 🎯 Visión General

Este documento define los contratos entre servicios del ecosistema EduGo:
- **REST APIs:** Entre frontend y backend
- **Eventos RabbitMQ:** Entre microservicios

**Fuente de verdad:** `infrastructure/EVENT_CONTRACTS.md`

---

## 🌐 REST API Contracts

### api-administracion (Puerto 8081)

**Base URL:** `http://localhost:8081/api/v1`

#### Endpoints de Escuelas

**GET /schools**
```json
Request:
  Query params:
    - page: integer (default: 1)
    - limit: integer (default: 20)
    - active: boolean (optional)

Response 200:
{
  "data": [
    {
      "id": "uuid",
      "name": "Colegio San José",
      "slug": "colegio-san-jose",
      "address": "Calle Principal 123",
      "is_active": true,
      "created_at": "2025-11-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "total_pages": 3
  }
}
```

**POST /schools**
```json
Request:
{
  "name": "Colegio San José",
  "slug": "colegio-san-jose",
  "address": "Calle Principal 123",
  "phone": "+51 999 888 777",
  "email": "info@sanjo se.edu.pe"
}

Response 201:
{
  "id": "uuid",
  "name": "Colegio San José",
  "slug": "colegio-san-jose",
  "is_active": true,
  "created_at": "2025-11-15T10:30:00Z"
}
```

#### Endpoints de Jerarquía Académica

**GET /academic-units**
```json
Request:
  Query params:
    - school_id: uuid (required)
    - parent_id: uuid (optional, null = raíz)
    - type: string (optional: school, grade, section, subject)

Response 200:
{
  "data": [
    {
      "id": "uuid",
      "school_id": "uuid",
      "parent_id": "uuid",
      "name": "10th Grade",
      "type": "grade",
      "level": 1,
      "path": "/1/2",
      "children_count": 3
    }
  ]
}
```

**POST /academic-units**
```json
Request:
{
  "school_id": "uuid",
  "parent_id": "uuid",
  "name": "Mathematics",
  "type": "subject",
  "metadata": {
    "credits": 4,
    "hours_per_week": 6
  }
}

Response 201:
{
  "id": "uuid",
  "school_id": "uuid",
  "parent_id": "uuid",
  "name": "Mathematics",
  "type": "subject",
  "level": 3,
  "path": "/1/2/3/4",
  "created_at": "2025-11-15T10:30:00Z"
}
```

#### Endpoints de Membresías

**POST /memberships**
```json
Request:
{
  "user_id": "uuid",
  "unit_id": "uuid",
  "role": "student"
}

Response 201:
{
  "id": "uuid",
  "user_id": "uuid",
  "unit_id": "uuid",
  "role": "student",
  "joined_at": "2025-11-15T10:30:00Z"
}
```

---

### api-mobile (Puerto 8080)

**Base URL:** `http://localhost:8080/api/v1`

#### Endpoints de Materiales

**POST /materials**
```json
Request (multipart/form-data):
  - file: File (PDF)
  - unit_id: uuid
  - title: string
  - description: string (optional)

Response 201:
{
  "id": "uuid",
  "unit_id": "uuid",
  "teacher_id": "uuid",
  "title": "Física Cuántica - Introducción",
  "file_url": "s3://edugo-materials/abc123.pdf",
  "file_type": "application/pdf",
  "file_size_bytes": 2048000,
  "processing_status": "pending",
  "created_at": "2025-11-15T10:30:00Z"
}
```

**GET /materials/:id**
```json
Response 200:
{
  "id": "uuid",
  "unit_id": "uuid",
  "teacher_id": "uuid",
  "title": "Física Cuántica - Introducción",
  "description": "Material introductorio sobre mecánica cuántica",
  "file_url": "s3://edugo-materials/abc123.pdf",
  "processing_status": "completed",
  "summary": {
    "short": "Este material cubre los fundamentos...",
    "key_points": ["Principio de incertidumbre", "Dualidad onda-partícula"]
  },
  "assessment": {
    "id": "uuid",
    "title": "Quiz sobre Física Cuántica",
    "total_questions": 10,
    "is_published": true
  },
  "created_at": "2025-11-15T10:30:00Z"
}
```

#### Endpoints de Evaluaciones

**GET /assessments/:id**
```json
Response 200:
{
  "id": "uuid",
  "material_id": "uuid",
  "title": "Quiz sobre Física Cuántica",
  "description": "Evalúa tu comprensión",
  "passing_score": 70,
  "time_limit_minutes": 30,
  "total_questions": 10,
  "total_points": 100,
  "is_published": true,
  "questions": [
    {
      "id": "q1",
      "type": "multiple_choice",
      "question_text": "¿Qué es el principio de incertidumbre?",
      "points": 10,
      "options": [
        {
          "id": "opt1",
          "text": "No se puede medir posición y velocidad simultáneamente"
        },
        {
          "id": "opt2",
          "text": "La energía no puede crearse ni destruirse"
        }
      ]
    }
  ]
}
```

**POST /assessments/:id/attempts**
```json
Request:
{
  "student_id": "uuid"
}

Response 201:
{
  "id": "uuid",
  "assessment_id": "uuid",
  "student_id": "uuid",
  "max_score": 100,
  "started_at": "2025-11-15T10:30:00Z",
  "time_limit_expires_at": "2025-11-15T11:00:00Z"
}
```

**POST /attempts/:id/answers**
```json
Request:
{
  "question_id": "q1",
  "answer_value": "opt1"
}

Response 201:
{
  "id": "uuid",
  "attempt_id": "uuid",
  "question_id": "q1",
  "is_correct": true,
  "points_earned": 10,
  "answered_at": "2025-11-15T10:35:00Z"
}
```

**POST /attempts/:id/complete**
```json
Request: {}

Response 200:
{
  "id": "uuid",
  "assessment_id": "uuid",
  "student_id": "uuid",
  "score": 85,
  "max_score": 100,
  "passed": true,
  "started_at": "2025-11-15T10:30:00Z",
  "completed_at": "2025-11-15T10:45:00Z",
  "time_spent_seconds": 900,
  "answers": [
    {
      "question_id": "q1",
      "is_correct": true,
      "points_earned": 10
    }
  ]
}
```

---

## 📨 RabbitMQ Event Contracts

**Exchange:** edugo.topic (tipo: topic)  
**Validación:** infrastructure/schemas/events/*.schema.json

### Evento 1: material.uploaded

**Publisher:** api-mobile  
**Consumer:** worker  
**Routing Key:** `material.uploaded`

**Schema:** `infrastructure/schemas/events/material-uploaded-v1.schema.json`

```json
{
  "event_id": "01JCXYZ123ABC456DEF789GHI",
  "event_type": "material.uploaded",
  "event_version": "1.0",
  "timestamp": "2025-11-15T10:30:00Z",
  "payload": {
    "material_id": "550e8400-e29b-41d4-a716-446655440000",
    "school_id": "660e8400-e29b-41d4-a716-446655440001",
    "teacher_id": "770e8400-e29b-41d4-a716-446655440002",
    "unit_id": "880e8400-e29b-41d4-a716-446655440003",
    "file_url": "s3://edugo-materials/2025/11/abc123.pdf",
    "file_size_bytes": 2048000,
    "file_type": "application/pdf",
    "title": "Física Cuántica - Introducción"
  }
}
```

**Campos requeridos:**
- `event_id`: UUID v7 (contiene timestamp)
- `event_type`: Siempre "material.uploaded"
- `event_version`: "1.0"
- `timestamp`: ISO 8601
- `payload.material_id`: UUID del material en PostgreSQL
- `payload.file_url`: URL del archivo a procesar

**Manejo de errores:**
- Retry: 3 intentos (1s, 2s, 4s backoff)
- DLQ: `material.processing.dlq`

---

### Evento 2: assessment.generated

**Publisher:** worker  
**Consumer:** api-mobile  
**Routing Key:** `assessment.generated`

**Schema:** `infrastructure/schemas/events/assessment-generated-v1.schema.json`

```json
{
  "event_id": "01JCXYZ123ABC456DEF789GHJ",
  "event_type": "assessment.generated",
  "event_version": "1.0",
  "timestamp": "2025-11-15T10:35:00Z",
  "payload": {
    "material_id": "550e8400-e29b-41d4-a716-446655440000",
    "mongo_document_id": "507f1f77bcf86cd799439011",
    "title": "Quiz sobre Física Cuántica",
    "total_questions": 10,
    "total_points": 100,
    "passing_score": 70,
    "time_limit_minutes": 30
  }
}
```

**Campos requeridos:**
- `payload.material_id`: UUID del material en PostgreSQL
- `payload.mongo_document_id`: ObjectId del assessment en MongoDB
- `payload.title`: Título del quiz generado

**Acción del consumer:**
```go
// api-mobile crea registro en PostgreSQL
assessment := &Assessment{
    MaterialID:      event.Payload.MaterialID,
    MongoDocumentID: event.Payload.MongoDocumentID,
    Title:           event.Payload.Title,
    PassingScore:    event.Payload.PassingScore,
    TimeLimitMinutes: event.Payload.TimeLimitMinutes,
}
repo.Create(assessment)
```

---

### Evento 3: material.deleted

**Publisher:** api-mobile  
**Consumer:** worker  
**Routing Key:** `material.deleted`

**Schema:** `infrastructure/schemas/events/material-deleted-v1.schema.json`

```json
{
  "event_id": "01JCXYZ123ABC456DEF789GHK",
  "event_type": "material.deleted",
  "event_version": "1.0",
  "timestamp": "2025-11-15T11:00:00Z",
  "payload": {
    "material_id": "550e8400-e29b-41d4-a716-446655440000",
    "mongo_summary_id": "507f1f77bcf86cd799439011",
    "mongo_assessment_id": "507f1f77bcf86cd799439012",
    "file_url": "s3://edugo-materials/2025/11/abc123.pdf"
  }
}
```

**Acción del consumer:**
```go
// worker elimina documentos de MongoDB
mongoRepo.DeleteSummary(event.Payload.MongoSummaryID)
mongoRepo.DeleteAssessment(event.Payload.MongoAssessmentID)
// Opcionalmente eliminar archivo de S3
```

---

### Evento 4: student.enrolled

**Publisher:** api-admin  
**Consumer:** api-mobile  
**Routing Key:** `student.enrolled`

**Schema:** `infrastructure/schemas/events/student-enrolled-v1.schema.json`

```json
{
  "event_id": "01JCXYZ123ABC456DEF789GHL",
  "event_type": "student.enrolled",
  "event_version": "1.0",
  "timestamp": "2025-11-15T09:00:00Z",
  "payload": {
    "membership_id": "990e8400-e29b-41d4-a716-446655440000",
    "student_id": "770e8400-e29b-41d4-a716-446655440002",
    "unit_id": "880e8400-e29b-41d4-a716-446655440003",
    "school_id": "660e8400-e29b-41d4-a716-446655440001",
    "enrolled_at": "2025-11-15T09:00:00Z"
  }
}
```

**Acción del consumer:**
```go
// api-mobile puede actualizar caché o enviar notificación
cacheService.InvalidateStudentUnits(event.Payload.StudentID)
notificationService.NotifyEnrollment(event.Payload.StudentID, event.Payload.UnitID)
```

---

## 🔄 Versionamiento de Contratos

### Estrategia de Versionamiento

**Campo:** `event_version` en JSON

**Formato:** "MAJOR.MINOR"
- MAJOR: Breaking changes (1.0 → 2.0)
- MINOR: Features compatibles (1.0 → 1.1)

**Ejemplo de breaking change:**
```json
// v1.0
{
  "payload": {
    "material_id": "uuid"
  }
}

// v2.0 (breaking: campo renombrado)
{
  "payload": {
    "resource_id": "uuid"  // ← Breaking change
  }
}
```

**Manejo en consumer:**
```go
switch event.EventVersion {
case "1.0":
    handleV1(event)
case "2.0":
    handleV2(event)
default:
    return fmt.Errorf("unsupported version: %s", event.EventVersion)
}
```

---

## ✅ Validación de Contratos

### En Publisher (antes de publicar)

```go
// api-mobile publica evento
event := Event{
    EventID:      generateUUIDv7(),
    EventType:    "material.uploaded",
    EventVersion: "1.0",
    Timestamp:    time.Now(),
    Payload:      payload,
}

// Validar contra schema
if err := validator.Validate(event, "material-uploaded-v1"); err != nil {
    return fmt.Errorf("invalid event: %w", err)
}

// Publicar
publisher.Publish("material.uploaded", event)
```

### En Consumer (al recibir)

```go
// worker consume evento
func handleMaterialUploaded(msg []byte) error {
    var event Event
    json.Unmarshal(msg, &event)

    // Validar contra schema
    if err := validator.Validate(event, "material-uploaded-v1"); err != nil {
        logger.Error("invalid event received", err)
        // Enviar a DLQ (no reintentar)
        return nil
    }

    // Procesar
    processMaterial(event.Payload)
    return nil
}
```

---

## 🔐 Autenticación y Autorización

### JWT Token (shared/auth v0.7.0)

**Header:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Payload:**
```json
{
  "sub": "user-uuid",
  "email": "teacher@school.edu",
  "role": "teacher",
  "school_id": "school-uuid",
  "exp": 1700000000,
  "iat": 1699999100
}
```

**Validación:**
```go
// Middleware de shared/middleware/gin v0.7.0
router.Use(middleware.JWTAuth(jwtManager))

// En handler
userID := c.GetString("user_id")
role := c.GetString("role")

if role != "teacher" {
    c.JSON(403, gin.H{"error": "forbidden"})
    return
}
```

---

## 📊 Rate Limiting

### Por Proyecto

| Proyecto | Rate Limit | Burst | Aplicado en |
|----------|-----------|-------|-------------|
| api-admin | 100 req/min | 20 | Middleware |
| api-mobile | 1000 req/min | 100 | Middleware |

**Implementación:**
```go
// Middleware de rate limiting
router.Use(middleware.RateLimit(1000, 100))
```

**Response cuando se excede:**
```json
HTTP 429 Too Many Requests
{
  "error": "rate_limit_exceeded",
  "message": "Too many requests, please try again later",
  "retry_after_seconds": 60
}
```

---

## 📝 Códigos de Error Estándar

### HTTP Status Codes

| Código | Significado | Uso |
|--------|-------------|-----|
| 200 | OK | Operación exitosa |
| 201 | Created | Recurso creado |
| 400 | Bad Request | Datos inválidos |
| 401 | Unauthorized | Token inválido/expirado |
| 403 | Forbidden | Sin permisos |
| 404 | Not Found | Recurso no existe |
| 409 | Conflict | Conflicto (ej: slug duplicado) |
| 422 | Unprocessable Entity | Validación fallida |
| 429 | Too Many Requests | Rate limit excedido |
| 500 | Internal Server Error | Error del servidor |

### Formato de Error

```json
{
  "error": "validation_error",
  "message": "Invalid input data",
  "details": [
    {
      "field": "email",
      "message": "must be a valid email address"
    }
  ],
  "request_id": "req-uuid"
}
```

---

## 🧪 Testing de Contratos

### Contract Testing (Pact)

```go
// Test en api-mobile (consumer)
func TestMaterialUploadedEvent(t *testing.T) {
    event := Event{
        EventType:    "material.uploaded",
        EventVersion: "1.0",
        Payload: map[string]interface{}{
            "material_id": "uuid",
            "file_url":    "s3://...",
        },
    }

    // Validar contra schema
    err := validator.Validate(event, "material-uploaded-v1")
    assert.NoError(t, err)
}
```

---

**Generado:** 16 de Noviembre, 2025  
**Por:** Claude Code  
**Versión:** 2.0.0  
**Fuente de verdad:** infrastructure/EVENT_CONTRACTS.md
