# 🗂️ Esquema MongoDB - edugo-infrastructure

**Fecha:** 16 de Noviembre, 2025  
**MongoDB:** 7.0  
**Colecciones:** 3

---

## 📋 Lista Completa de Colecciones

| Colección | Owner | Escribe | Lee | Propósito |
|-----------|-------|---------|-----|-----------|
| material_summary | worker | worker | api-mobile | Resúmenes IA |
| material_assessment | worker | worker | api-mobile, worker | Quizzes IA |
| material_event | worker | worker | worker | Log de eventos |

---

## 📄 COLECCIÓN 1: material_summary

### Metadata
- **Propósito:** Resúmenes de materiales generados por OpenAI
- **Escribe:** worker
- **Lee:** api-mobile
- **PostgreSQL:** materials.id (UUID)

### Esquema
```javascript
{
  _id: ObjectId,              // (auto)
  material_id: String,        // (required, unique) - UUID
  summary: {
    short: String,            // (required, 1-500 chars)
    detailed: String,         // (required, 1-2000 chars)
    key_points: Array<String> // (required, 3-10 items)
  },
  metadata: {
    word_count: Number,       // (required, >= 0)
    difficulty_level: String, // (required, enum: beginner|intermediate|advanced)
    language: String          // (required, 2 chars)
  },
  generated_at: Date,         // (required)
  model_version: String       // (required)
}
```

### Índices
```javascript
{ material_id: 1 } unique
{ generated_at: -1 }
{ "summary.short": "text", "summary.detailed": "text" }
```

---

## 📄 COLECCIÓN 2: material_assessment

### Metadata
- **Propósito:** Quizzes generados por IA
- **Escribe:** worker
- **Lee:** api-mobile, worker
- **PostgreSQL:** materials.id, assessment.mongo_document_id

### Esquema
```javascript
{
  _id: ObjectId,
  material_id: String,        // (required, unique) - UUID
  title: String,              // (required, 1-255)
  questions: Array<{
    question_id: String,      // (required)
    question_text: String,    // (required, 1-500)
    question_type: String,    // (required, enum: multiple_choice|true_false|short_answer)
    points: Number,           // (required, 1-20)
    options: Array<{          // (for multiple_choice)
      option_id: String,      // (required)
      text: String,           // (required, 1-200)
      is_correct: Boolean     // (required)
    }>,
    correct_answer: Any       // (required)
  }>,                         // (required, 5-30 items)
  total_points: Number,       // (required, >= 0)
  generated_at: Date,         // (required)
  is_published: Boolean       // (required, default false)
}
```

### Índices
```javascript
{ material_id: 1 } unique
{ is_published: 1, generated_at: -1 }
{ title: "text", "questions.question_text": "text" }
```

---

## 📄 COLECCIÓN 3: material_event

### Metadata
- **Propósito:** Log de eventos de procesamiento
- **Escribe:** worker
- **Lee:** worker
- **TTL:** 90 días

### Esquema
```javascript
{
  _id: ObjectId,
  material_id: String,        // (required) - UUID
  event_type: String,         // (required, enum: processing_started|completed|failed|summary_generated|assessment_generated)
  status: String,             // (required, enum: success|error|warning|info)
  message: String,            // (required)
  error: {                    // (optional, si status='error')
    code: String,
    message: String
  },
  occurred_at: Date           // (required)
}
```

### Índices
```javascript
{ material_id: 1, occurred_at: -1 }
{ event_type: 1, occurred_at: -1 }
{ occurred_at: 1 } TTL 90 días (7776000 segundos)
```

---

**Ver documento completo en:** infrastructure/docs/MONGODB_SCHEMA_COMPLETE.md
