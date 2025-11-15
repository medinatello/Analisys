# 📄 API Contracts: Sistema de Evaluaciones

**Versión:** 1.0  
**Fecha:** 14 de Noviembre, 2025  
**Formato:** OpenAPI 3.0 compatible

---

## 1. API MOBILE ENDPOINTS

### 1.1 GET /v1/materials/:id/assessment

**Descripción:** Obtiene la evaluación asociada a un material desde MongoDB.

**Request:**
```http
GET /v1/materials/123e4567-e89b-12d3-a456-426614174000/assessment
Authorization: Bearer <jwt_token>
Accept: application/json
```

**Response 200 OK:**
```json
{
  "data": {
    "assessment_id": "550e8400-e29b-41d4-a716-446655440000",
    "material_id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Evaluación: Introducción a la Física",
    "description": "Evalúa tu comprensión de los conceptos básicos",
    "difficulty": "medium",
    "question_count": 20,
    "passing_score": 70,
    "time_limit_minutes": 30,
    "max_attempts_per_day": 3,
    "attempts_today": 1,
    "can_take": true,
    "questions": [
      {
        "id": "q1",
        "type": "multiple_choice",
        "text": "¿Cuál es la unidad de fuerza en el SI?",
        "options": [
          { "id": "a", "text": "Joule" },
          { "id": "b", "text": "Newton" },
          { "id": "c", "text": "Pascal" },
          { "id": "d", "text": "Watt" }
        ],
        "points": 1
      }
    ],
    "metadata": {
      "topics": ["physics", "mechanics"],
      "estimated_time_minutes": 15,
      "instructions": "Selecciona la mejor respuesta para cada pregunta"
    }
  },
  "meta": {
    "timestamp": "2024-01-01T10:00:00Z",
    "version": "1.0"
  }
}
```

**Response 404 Not Found:**
```json
{
  "error": {
    "code": "ASSESSMENT_NOT_FOUND",
    "message": "No assessment available for this material",
    "details": {
      "material_id": "123e4567-e89b-12d3-a456-426614174000"
    }
  }
}
```

**Response 403 Forbidden:**
```json
{
  "error": {
    "code": "DAILY_LIMIT_EXCEEDED",
    "message": "You have reached the maximum attempts for today",
    "details": {
      "attempts_today": 3,
      "max_attempts": 3,
      "next_available": "2024-01-02T00:00:00Z"
    }
  }
}
```

---

### 1.2 POST /v1/assessments/:id/attempts

**Descripción:** Inicia un nuevo intento de evaluación.

**Request:**
```json
{
  "assessment_id": "550e8400-e29b-41d4-a716-446655440000",
  "metadata": {
    "device": "mobile",
    "app_version": "1.2.3"
  }
}
```

**Response 201 Created:**
```json
{
  "data": {
    "attempt_id": "660e8400-e29b-41d4-a716-446655440001",
    "assessment_id": "550e8400-e29b-41d4-a716-446655440000",
    "user_id": "770e8400-e29b-41d4-a716-446655440002",
    "status": "in_progress",
    "started_at": "2024-01-01T10:00:00Z",
    "expires_at": "2024-01-01T10:30:00Z",
    "questions_order": ["q3", "q1", "q5", "q2", "q4"],
    "total_questions": 20
  },
  "meta": {
    "timestamp": "2024-01-01T10:00:00Z"
  }
}
```

**Response 409 Conflict:**
```json
{
  "error": {
    "code": "ATTEMPT_IN_PROGRESS",
    "message": "You already have an active attempt",
    "details": {
      "attempt_id": "existing-attempt-id",
      "started_at": "2024-01-01T09:45:00Z",
      "expires_at": "2024-01-01T10:15:00Z"
    }
  }
}
```

---

### 1.3 POST /v1/attempts/:id/answers

**Descripción:** Envía respuestas para un intento activo.

**Request:**
```json
{
  "answers": [
    {
      "question_id": "q1",
      "answer_value": "b",
      "time_spent_seconds": 45
    },
    {
      "question_id": "q2",
      "answer_value": "true",
      "time_spent_seconds": 30
    }
  ],
  "action": "submit"  // "save" for partial, "submit" for final
}
```

**Response 200 OK (action: save):**
```json
{
  "data": {
    "attempt_id": "660e8400-e29b-41d4-a716-446655440001",
    "saved_count": 2,
    "total_answered": 15,
    "total_questions": 20,
    "status": "in_progress"
  }
}
```

**Response 200 OK (action: submit):**
```json
{
  "data": {
    "attempt_id": "660e8400-e29b-41d4-a716-446655440001",
    "status": "completed",
    "score": 85,
    "passed": true,
    "correct_answers": 17,
    "total_questions": 20,
    "time_spent_seconds": 720,
    "completed_at": "2024-01-01T10:12:00Z",
    "feedback": {
      "summary": "¡Excelente trabajo! Has demostrado un buen dominio del tema.",
      "strengths": ["Mecánica clásica", "Termodinámica"],
      "improvements": ["Óptica", "Ondas"]
    },
    "details": [
      {
        "question_id": "q1",
        "is_correct": true,
        "your_answer": "b",
        "correct_answer": "b"
      },
      {
        "question_id": "q2",
        "is_correct": false,
        "your_answer": "false",
        "correct_answer": "true",
        "explanation": "El agua hierve a 100°C al nivel del mar bajo presión normal"
      }
    ]
  }
}
```

**Response 400 Bad Request:**
```json
{
  "error": {
    "code": "INVALID_ANSWERS",
    "message": "Some answers are invalid",
    "details": {
      "invalid_questions": ["q99"],
      "missing_required": ["q3", "q4"]
    }
  }
}
```

---

### 1.4 GET /v1/attempts/:id/results

**Descripción:** Obtiene los resultados de un intento completado.

**Request:**
```http
GET /v1/attempts/660e8400-e29b-41d4-a716-446655440001/results
Authorization: Bearer <jwt_token>
```

**Response 200 OK:**
```json
{
  "data": {
    "attempt_id": "660e8400-e29b-41d4-a716-446655440001",
    "assessment": {
      "title": "Evaluación: Introducción a la Física",
      "material_id": "123e4567-e89b-12d3-a456-426614174000"
    },
    "score": 85,
    "passed": true,
    "passing_score": 70,
    "correct_answers": 17,
    "total_questions": 20,
    "started_at": "2024-01-01T10:00:00Z",
    "completed_at": "2024-01-01T10:12:00Z",
    "time_spent": "12:00",
    "percentile": 78,
    "question_results": [
      {
        "question_id": "q1",
        "question_text": "¿Cuál es la unidad de fuerza en el SI?",
        "is_correct": true,
        "your_answer": "Newton",
        "correct_answer": "Newton",
        "points_earned": 1,
        "points_possible": 1
      }
    ],
    "analysis": {
      "by_topic": [
        { "topic": "Mecánica", "score": 90 },
        { "topic": "Termodinámica", "score": 85 },
        { "topic": "Óptica", "score": 70 }
      ],
      "by_difficulty": [
        { "level": "easy", "score": 95 },
        { "level": "medium", "score": 85 },
        { "level": "hard", "score": 60 }
      ]
    }
  }
}
```

---

### 1.5 GET /v1/users/me/attempts

**Descripción:** Obtiene el historial de intentos del usuario autenticado.

**Request:**
```http
GET /v1/users/me/attempts?page=1&limit=20&status=completed&from=2024-01-01
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `page` (int): Número de página (default: 1)
- `limit` (int): Items por página (default: 20, max: 100)
- `status` (string): Filtrar por estado (in_progress|completed|abandoned|all)
- `from` (date): Fecha desde (ISO 8601)
- `to` (date): Fecha hasta (ISO 8601)
- `material_id` (uuid): Filtrar por material
- `passed` (boolean): Solo aprobados/reprobados

**Response 200 OK:**
```json
{
  "data": [
    {
      "attempt_id": "660e8400-e29b-41d4-a716-446655440001",
      "assessment": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Evaluación: Introducción a la Física"
      },
      "material": {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "title": "Introducción a la Física"
      },
      "score": 85,
      "passed": true,
      "status": "completed",
      "started_at": "2024-01-01T10:00:00Z",
      "completed_at": "2024-01-01T10:12:00Z",
      "time_spent_seconds": 720
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "total_pages": 3,
    "has_next": true,
    "has_prev": false
  },
  "summary": {
    "total_attempts": 45,
    "completed": 40,
    "passed": 32,
    "average_score": 76.5
  }
}
```

---

## 2. API ADMINISTRACIÓN ENDPOINTS

### 2.1 GET /v1/reports/assessments/:id/stats

**Descripción:** Obtiene estadísticas detalladas de una evaluación.

**Request:**
```http
GET /v1/reports/assessments/550e8400-e29b-41d4-a716-446655440000/stats
Authorization: Bearer <admin_jwt_token>
X-Admin-Role: supervisor
```

**Response 200 OK:**
```json
{
  "data": {
    "assessment_id": "550e8400-e29b-41d4-a716-446655440000",
    "material": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "title": "Introducción a la Física"
    },
    "statistics": {
      "total_attempts": 250,
      "unique_users": 89,
      "completed_attempts": 230,
      "abandoned_attempts": 20,
      "average_score": 74.3,
      "median_score": 75,
      "min_score": 35,
      "max_score": 100,
      "standard_deviation": 12.5,
      "pass_rate": 68.5,
      "average_time_minutes": 18.5
    },
    "distribution": {
      "score_ranges": [
        { "range": "0-20", "count": 2 },
        { "range": "21-40", "count": 8 },
        { "range": "41-60", "count": 35 },
        { "range": "61-80", "count": 120 },
        { "range": "81-100", "count": 65 }
      ]
    },
    "questions_analysis": [
      {
        "question_id": "q1",
        "success_rate": 92.5,
        "average_time_seconds": 45,
        "difficulty_perceived": "easy"
      },
      {
        "question_id": "q15",
        "success_rate": 45.2,
        "average_time_seconds": 120,
        "difficulty_perceived": "hard",
        "flag": "review_needed"
      }
    ],
    "trends": {
      "last_7_days": {
        "attempts": 45,
        "average_score": 76.2,
        "trend": "improving"
      },
      "last_30_days": {
        "attempts": 180,
        "average_score": 74.8,
        "trend": "stable"
      }
    },
    "generated_at": "2024-01-01T10:00:00Z"
  }
}
```

---

### 2.2 GET /v1/reports/students/:id/performance

**Descripción:** Obtiene el rendimiento detallado de un estudiante.

**Request:**
```http
GET /v1/reports/students/770e8400-e29b-41d4-a716-446655440002/performance?period=last_30_days
Authorization: Bearer <admin_jwt_token>
```

**Query Parameters:**
- `period` (string): last_7_days|last_30_days|last_90_days|all_time
- `group_by` (string): day|week|month

**Response 200 OK:**
```json
{
  "data": {
    "student": {
      "id": "770e8400-e29b-41d4-a716-446655440002",
      "name": "Juan Pérez",
      "email": "juan.perez@example.com",
      "enrollment_date": "2023-09-01"
    },
    "overall_stats": {
      "total_assessments_taken": 25,
      "unique_materials_evaluated": 18,
      "total_attempts": 32,
      "completion_rate": 87.5,
      "average_score": 78.4,
      "best_score": 95,
      "worst_score": 55,
      "total_time_hours": 8.5,
      "pass_rate": 72.0
    },
    "progress_timeline": [
      {
        "date": "2024-01-01",
        "attempts": 2,
        "average_score": 82,
        "materials": ["Physics", "Chemistry"]
      },
      {
        "date": "2024-01-02",
        "attempts": 1,
        "average_score": 75,
        "materials": ["Mathematics"]
      }
    ],
    "performance_by_topic": [
      {
        "topic": "Physics",
        "attempts": 8,
        "average_score": 85,
        "trend": "improving",
        "last_attempt": "2024-01-01"
      },
      {
        "topic": "Mathematics",
        "attempts": 10,
        "average_score": 72,
        "trend": "stable",
        "last_attempt": "2024-01-02"
      }
    ],
    "strengths": [
      "Consistent improvement in Physics",
      "High completion rate",
      "Good time management"
    ],
    "areas_for_improvement": [
      "Mathematics conceptual understanding",
      "Complex problem solving",
      "Review of failed questions"
    ],
    "recent_activity": [
      {
        "date": "2024-01-01T10:00:00Z",
        "assessment": "Physics Quiz",
        "score": 85,
        "passed": true,
        "time_minutes": 18
      }
    ],
    "comparison": {
      "vs_class_average": {
        "student_score": 78.4,
        "class_average": 74.2,
        "percentile": 65
      }
    }
  }
}
```

---

### 2.3 GET /v1/reports/materials/:id/assessment-analytics

**Descripción:** Analytics de evaluación por material.

**Request:**
```http
GET /v1/reports/materials/123e4567-e89b-12d3-a456-426614174000/assessment-analytics
Authorization: Bearer <admin_jwt_token>
```

**Response 200 OK:**
```json
{
  "data": {
    "material": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "title": "Introducción a la Física",
      "type": "pdf",
      "unit": "Physics 101"
    },
    "assessment_effectiveness": {
      "engagement_rate": 85.5,
      "completion_rate": 92.0,
      "retry_rate": 35.2,
      "improvement_on_retry": 15.3,
      "average_score_first_attempt": 68.5,
      "average_score_best_attempt": 78.9
    },
    "learning_outcomes": {
      "objectives_covered": 8,
      "objectives_mastered": 6,
      "mastery_rate": 75.0,
      "knowledge_gaps": [
        "Wave mechanics",
        "Quantum basics"
      ]
    },
    "question_quality": {
      "discrimination_index": 0.72,
      "reliability_coefficient": 0.85,
      "questions_needing_review": 3,
      "optimal_difficulty_mix": true
    },
    "student_feedback": {
      "difficulty_rating": 3.8,
      "usefulness_rating": 4.2,
      "clarity_rating": 4.5,
      "total_ratings": 45
    },
    "recommendations": [
      "Consider adding more practice questions for wave mechanics",
      "Question q15 has low discrimination - consider revision",
      "Overall assessment is well-balanced and effective"
    ]
  }
}
```

---

## 3. MODELOS COMPARTIDOS (DTOs)

### 3.1 Error Response

```typescript
interface ErrorResponse {
  error: {
    code: string;           // Código único del error
    message: string;        // Mensaje legible
    details?: any;          // Detalles adicionales
    timestamp: string;      // ISO 8601
    trace_id?: string;      // Para debugging
  };
}
```

### 3.2 Pagination

```typescript
interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  total_pages: number;
  has_next: boolean;
  has_prev: boolean;
}
```

### 3.3 Assessment Types

```typescript
enum QuestionType {
  MULTIPLE_CHOICE = "multiple_choice",
  TRUE_FALSE = "true_false",
  SHORT_ANSWER = "short_answer"
}

enum AttemptStatus {
  IN_PROGRESS = "in_progress",
  COMPLETED = "completed",
  ABANDONED = "abandoned",
  TIMEOUT = "timeout"
}

enum Difficulty {
  EASY = "easy",
  MEDIUM = "medium",
  HARD = "hard"
}
```

---

## 4. HEADERS Y AUTENTICACIÓN

### 4.1 Request Headers Requeridos

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
X-Request-ID: <uuid>           # Opcional pero recomendado
X-Client-Version: 1.2.3         # Versión del cliente
```

### 4.2 Response Headers Estándar

```http
Content-Type: application/json
X-Request-ID: <uuid>
X-Response-Time: 125ms
X-Rate-Limit-Limit: 1000
X-Rate-Limit-Remaining: 999
X-Rate-Limit-Reset: 1609459200
```

---

## 5. CÓDIGOS DE ERROR

| Código | HTTP Status | Descripción |
|--------|-------------|-------------|
| `ASSESSMENT_NOT_FOUND` | 404 | Evaluación no existe |
| `ATTEMPT_NOT_FOUND` | 404 | Intento no existe |
| `UNAUTHORIZED` | 401 | Token inválido o expirado |
| `FORBIDDEN` | 403 | Sin permisos para la acción |
| `DAILY_LIMIT_EXCEEDED` | 403 | Límite diario alcanzado |
| `ATTEMPT_IN_PROGRESS` | 409 | Ya hay un intento activo |
| `ATTEMPT_EXPIRED` | 410 | Intento expiró por timeout |
| `INVALID_ANSWERS` | 400 | Respuestas con formato inválido |
| `INVALID_REQUEST` | 400 | Request malformado |
| `INTERNAL_ERROR` | 500 | Error interno del servidor |
| `SERVICE_UNAVAILABLE` | 503 | Servicio temporalmente no disponible |

---

## 6. RATE LIMITING

### 6.1 Límites por Endpoint

| Endpoint | Límite | Ventana | 
|----------|--------|---------|
| GET /materials/*/assessment | 100 | 1 minuto |
| POST /assessments/*/attempts | 10 | 1 minuto |
| POST /attempts/*/answers | 30 | 1 minuto |
| GET /users/me/attempts | 60 | 1 minuto |
| GET /reports/* | 30 | 1 minuto |

### 6.2 Respuesta cuando se excede límite

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "details": {
      "limit": 100,
      "remaining": 0,
      "reset_at": "2024-01-01T10:01:00Z"
    }
  }
}
```

---

## 7. WEBHOOKS (Futuro)

### 7.1 Eventos Disponibles

```json
{
  "event": "assessment.attempt.completed",
  "data": {
    "attempt_id": "660e8400-e29b-41d4-a716-446655440001",
    "user_id": "770e8400-e29b-41d4-a716-446655440002",
    "assessment_id": "550e8400-e29b-41d4-a716-446655440000",
    "score": 85,
    "passed": true,
    "completed_at": "2024-01-01T10:12:00Z"
  },
  "timestamp": "2024-01-01T10:12:01Z",
  "signature": "sha256=..."
}
```

---

**Última actualización:** 14 de Noviembre, 2025  
**Versión API:** 1.0.0  
**Compatibilidad:** OpenAPI 3.0