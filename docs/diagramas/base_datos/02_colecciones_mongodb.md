# Colecciones MongoDB - EduGo

## Descripción
MongoDB almacena documentos con esquema flexible para contenido generado por IA (resúmenes, cuestionarios, eventos), permitiendo evolución sin romper esquemas SQL.

## Decisión de Arquitectura

### ¿Por qué MongoDB?

1. **Esquema Flexible**: Resúmenes y cuestionarios generados por IA tienen estructuras variables
2. **Documentos Autocontenidos**: Todo el resumen o quiz en un solo documento
3. **Escalado Horizontal**: Preparado para crecimiento mediante sharding
4. **Evolución Sin Migración**: Añadir campos sin ALTER TABLE
5. **Query sobre JSON**: Filtros tipo `{ "sections.level": "basic" }`

### Alternativa: PostgreSQL JSONB

**Ventajas**:
- Un solo motor de base de datos
- Transacciones ACID entre datos relacionales y documentos
- JSONB con índices GIN para queries rápidos

**Cuándo usar**: Si volumen de documentos < 100K y equipo tiene más experiencia en PostgreSQL.

---

## Colecciones MVP

### 1. `material_summary`

**Propósito**: Almacenar resúmenes educativos generados por IA.

#### Estructura del Documento

```json
{
  "_id": ObjectId("..."),
  "material_id": "uuid-from-postgresql",
  "version": 1,
  "status": "completed",
  "sections": [
    {
      "title": "Contexto Histórico",
      "content": "Pascal fue desarrollado por Niklaus Wirth en 1970 como un lenguaje educativo...",
      "difficulty": "basic",
      "estimated_time_minutes": 5,
      "order": 1
    },
    {
      "title": "Sintaxis y Estructura",
      "content": "El lenguaje Pascal utiliza una sintaxis clara y estructurada...",
      "difficulty": "medium",
      "estimated_time_minutes": 10,
      "order": 2
    },
    {
      "title": "Aplicaciones Modernas",
      "content": "Aunque Pascal no es tan utilizado hoy, sentó las bases para lenguajes modernos...",
      "difficulty": "advanced",
      "estimated_time_minutes": 8,
      "order": 3
    }
  ],
  "glossary": [
    {
      "term": "Compilador",
      "definition": "Programa que traduce código fuente escrito en un lenguaje de programación a código máquina ejecutable.",
      "order": 1
    },
    {
      "term": "Variable",
      "definition": "Espacio en memoria reservado para almacenar un valor que puede cambiar durante la ejecución del programa.",
      "order": 2
    },
    {
      "term": "Tipo de Dato",
      "definition": "Clasificación que especifica qué tipo de valor puede almacenar una variable (integer, string, boolean, etc.).",
      "order": 3
    }
  ],
  "reflection_questions": [
    "¿Qué ventajas aportó Pascal sobre lenguajes de programación anteriores?",
    "¿Por qué es importante la tipificación fuerte en programación?",
    "¿En qué contextos se sigue utilizando Pascal actualmente?",
    "¿Cómo influyó Pascal en el diseño de lenguajes modernos como Java o C#?",
    "¿Cuáles son las diferencias entre un compilador y un intérprete?"
  ],
  "processing_metadata": {
    "nlp_provider": "openai",
    "model": "gpt-4",
    "tokens_used": 3500,
    "processing_time_seconds": 45,
    "language": "es",
    "prompt_version": "v1.2"
  },
  "created_at": ISODate("2025-01-15T12:30:00Z"),
  "updated_at": ISODate("2025-01-15T12:30:00Z")
}
```

#### Validación de Schema

```javascript
db.createCollection("material_summary", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["material_id", "version", "status", "sections", "created_at"],
      properties: {
        material_id: {
          bsonType: "string",
          description: "UUID del material en PostgreSQL"
        },
        version: {
          bsonType: "int",
          minimum: 1,
          description: "Versión del resumen (incremental)"
        },
        status: {
          enum: ["processing", "completed", "failed"],
          description: "Estado del procesamiento"
        },
        sections: {
          bsonType: "array",
          minItems: 1,
          items: {
            bsonType: "object",
            required: ["title", "content", "difficulty", "order"],
            properties: {
              title: { bsonType: "string" },
              content: { bsonType: "string", minLength: 50 },
              difficulty: { enum: ["basic", "medium", "advanced"] },
              estimated_time_minutes: { bsonType: "int", minimum: 1 },
              order: { bsonType: "int", minimum: 1 }
            }
          }
        },
        glossary: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["term", "definition", "order"],
            properties: {
              term: { bsonType: "string", minLength: 2 },
              definition: { bsonType: "string", minLength: 10 },
              order: { bsonType: "int", minimum: 1 }
            }
          }
        },
        reflection_questions: {
          bsonType: "array",
          minItems: 3,
          items: { bsonType: "string", minLength: 10 }
        }
      }
    }
  }
});
```

#### Índices

```javascript
// Búsqueda por material_id (query principal)
db.material_summary.createIndex({ material_id: 1 }, { unique: true });

// Búsqueda por estado
db.material_summary.createIndex({ status: 1 });

// Búsqueda full-text en secciones y glosario
db.material_summary.createIndex(
  {
    "sections.title": "text",
    "sections.content": "text",
    "glossary.term": "text",
    "glossary.definition": "text"
  },
  { name: "full_text_search" }
);

// Índice compuesto para filtrado avanzado
db.material_summary.createIndex({ material_id: 1, version: -1, status: 1 });
```

#### Queries Comunes

```javascript
// Obtener resumen completado de un material
db.material_summary.findOne({
  material_id: "uuid",
  status: "completed"
});

// Buscar términos en glosario
db.material_summary.find({
  "glossary.term": /compilador/i
}, {
  "glossary.$": 1
});

// Filtrar secciones por dificultad
db.material_summary.aggregate([
  { $match: { material_id: "uuid" } },
  { $unwind: "$sections" },
  { $match: { "sections.difficulty": "basic" } },
  { $project: { "sections.title": 1, "sections.content": 1 } }
]);
```

---

### 2. `material_assessment`

**Propósito**: Almacenar cuestionarios autogenerados con preguntas y respuestas.

#### Estructura del Documento

```json
{
  "_id": ObjectId("..."),
  "material_id": "uuid-from-postgresql",
  "title": "Cuestionario: Introducción a Pascal",
  "description": "Evaluación de conceptos básicos sobre el lenguaje Pascal",
  "questions": [
    {
      "id": "q1",
      "text": "¿Qué es un compilador?",
      "type": "multiple_choice",
      "difficulty": "basic",
      "points": 20,
      "order": 1,
      "options": [
        {
          "id": "a",
          "text": "Un programa que traduce código fuente a código máquina"
        },
        {
          "id": "b",
          "text": "Un tipo de variable en Pascal"
        },
        {
          "id": "c",
          "text": "Una estructura de control para bucles"
        },
        {
          "id": "d",
          "text": "Un editor de texto especializado"
        }
      ],
      "correct_answer": "a",
      "feedback": {
        "correct": "¡Correcto! Un compilador traduce código fuente a código máquina ejecutable, permitiendo que las computadoras ejecuten los programas.",
        "incorrect": "Incorrecto. Revisa la sección 'Herramientas de Desarrollo' en el resumen. Un compilador es fundamental en el proceso de creación de software."
      }
    },
    {
      "id": "q2",
      "text": "¿Cuál es la principal ventaja de la tipificación fuerte en Pascal?",
      "type": "multiple_choice",
      "difficulty": "medium",
      "points": 20,
      "order": 2,
      "options": [
        {
          "id": "a",
          "text": "Hace que el código se ejecute más rápido"
        },
        {
          "id": "b",
          "text": "Previene errores detectándolos en tiempo de compilación"
        },
        {
          "id": "c",
          "text": "Reduce el tamaño del ejecutable final"
        },
        {
          "id": "d",
          "text": "Permite usar menos memoria RAM"
        }
      ],
      "correct_answer": "b",
      "feedback": {
        "correct": "¡Exacto! La tipificación fuerte detecta errores antes de ejecutar el programa, evitando bugs que solo se manifestarían en runtime.",
        "incorrect": "No es correcto. Piensa en qué sucede durante la compilación cuando los tipos están bien definidos. La seguridad es la clave."
      }
    },
    {
      "id": "q3",
      "text": "¿En qué año fue creado el lenguaje Pascal?",
      "type": "multiple_choice",
      "difficulty": "basic",
      "points": 20,
      "order": 3,
      "options": [
        { "id": "a", "text": "1965" },
        { "id": "b", "text": "1970" },
        { "id": "c", "text": "1980" },
        { "id": "d", "text": "1990" }
      ],
      "correct_answer": "b",
      "feedback": {
        "correct": "¡Correcto! Niklaus Wirth creó Pascal en 1970 como un lenguaje educativo.",
        "incorrect": "Incorrecto. Revisa la sección 'Contexto Histórico' del resumen."
      }
    },
    {
      "id": "q4",
      "text": "¿Cuál de las siguientes NO es una estructura de control en Pascal?",
      "type": "multiple_choice",
      "difficulty": "medium",
      "points": 20,
      "order": 4,
      "options": [
        { "id": "a", "text": "IF...THEN...ELSE" },
        { "id": "b", "text": "WHILE...DO" },
        { "id": "c", "text": "FOR...TO...DO" },
        { "id": "d", "text": "CLASS...METHOD" }
      ],
      "correct_answer": "d",
      "feedback": {
        "correct": "¡Correcto! CLASS y METHOD son conceptos de programación orientada a objetos, no presentes en Pascal estándar.",
        "incorrect": "Revisa las estructuras de control básicas de Pascal. Piensa en qué pertenece a POO vs programación estructurada."
      }
    },
    {
      "id": "q5",
      "text": "¿Qué lenguaje moderno fue influenciado directamente por Pascal?",
      "type": "multiple_choice",
      "difficulty": "advanced",
      "points": 20,
      "order": 5,
      "options": [
        { "id": "a", "text": "Python" },
        { "id": "b", "text": "Ada" },
        { "id": "c", "text": "JavaScript" },
        { "id": "d", "text": "Ruby" }
      ],
      "correct_answer": "b",
      "feedback": {
        "correct": "¡Excelente! Ada fue diseñado con influencias directas de Pascal, manteniendo su filosofía de tipificación fuerte y claridad.",
        "incorrect": "Piensa en lenguajes que comparten la filosofía de Pascal sobre tipos fuertes y claridad sintáctica."
      }
    }
  ],
  "total_questions": 5,
  "total_points": 100,
  "passing_score": 70,
  "time_limit_minutes": 15,
  "version": 1,
  "processing_metadata": {
    "nlp_provider": "openai",
    "model": "gpt-4",
    "tokens_used": 2800,
    "processing_time_seconds": 38,
    "language": "es"
  },
  "created_at": ISODate("2025-01-15T12:35:00Z"),
  "updated_at": ISODate("2025-01-15T12:35:00Z")
}
```

#### Validación de Schema

```javascript
db.createCollection("material_assessment", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["material_id", "title", "questions", "version", "created_at"],
      properties: {
        material_id: {
          bsonType: "string"
        },
        title: {
          bsonType: "string",
          minLength: 5
        },
        questions: {
          bsonType: "array",
          minItems: 3,
          maxItems: 20,
          items: {
            bsonType: "object",
            required: ["id", "text", "type", "options", "correct_answer", "order"],
            properties: {
              id: { bsonType: "string" },
              text: { bsonType: "string", minLength: 10 },
              type: { enum: ["multiple_choice", "true_false", "short_answer"] },
              difficulty: { enum: ["basic", "medium", "advanced"] },
              points: { bsonType: "int", minimum: 1 },
              order: { bsonType: "int", minimum: 1 },
              options: {
                bsonType: "array",
                minItems: 2
              },
              correct_answer: { bsonType: "string" }
            }
          }
        },
        total_points: {
          bsonType: "int",
          minimum: 1
        },
        version: {
          bsonType: "int",
          minimum: 1
        }
      }
    }
  }
});
```

#### Índices

```javascript
// Búsqueda por material_id
db.material_assessment.createIndex({ material_id: 1 }, { unique: true });

// Búsqueda por question_id (para validación de respuestas)
db.material_assessment.createIndex({ "questions.id": 1 });

// Full-text search en preguntas
db.material_assessment.createIndex(
  { "questions.text": "text", title: "text" },
  { name: "quiz_text_search" }
);
```

#### Queries Comunes

```javascript
// Obtener quiz completo (CON respuestas - solo servidor)
db.material_assessment.findOne({ material_id: "uuid" });

// Obtener quiz SIN respuestas (para enviar a cliente)
db.material_assessment.findOne(
  { material_id: "uuid" },
  {
    "questions.correct_answer": 0,
    "questions.feedback": 0
  }
);

// Validar respuesta de una pregunta específica
db.material_assessment.findOne(
  {
    material_id: "uuid",
    "questions.id": "q1"
  },
  {
    "questions.$": 1
  }
);
```

---

### 3. `material_event`

**Propósito**: Registro de eventos de procesamiento y métricas de workers.

#### Estructura del Documento

```json
{
  "_id": ObjectId("..."),
  "material_id": "uuid-from-postgresql",
  "event_type": "processing_completed",
  "worker_id": "worker-pod-1",
  "status": "success",
  "duration_seconds": 120,
  "error_message": null,
  "retry_count": 0,
  "metadata": {
    "nlp_provider": "openai",
    "nlp_tokens_used": 6300,
    "estimated_cost_usd": 0.14,
    "pdf_file_size_bytes": 2048576,
    "pdf_pages": 25,
    "extracted_text_length": 15000,
    "summary_sections_generated": 7,
    "quiz_questions_generated": 5
  },
  "created_at": ISODate("2025-01-15T12:40:00Z")
}
```

#### Tipos de Eventos

| `event_type` | Descripción |
|--------------|-------------|
| `processing_started` | Worker inició procesamiento |
| `processing_completed` | Procesamiento exitoso |
| `processing_failed` | Error en procesamiento |
| `summary_generated` | Resumen generado específicamente |
| `assessment_generated` | Quiz generado específicamente |
| `material_reprocessed` | Material reprocesado a solicitud |

#### Validación de Schema

```javascript
db.createCollection("material_event", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["material_id", "event_type", "status", "created_at"],
      properties: {
        material_id: { bsonType: "string" },
        event_type: {
          enum: [
            "processing_started",
            "processing_completed",
            "processing_failed",
            "summary_generated",
            "assessment_generated",
            "material_reprocessed"
          ]
        },
        status: { enum: ["success", "failed", "pending"] },
        duration_seconds: { bsonType: "int", minimum: 0 }
      }
    }
  }
});
```

#### Índices

```javascript
// Eventos por material (ordenados por fecha)
db.material_event.createIndex({ material_id: 1, created_at: -1 });

// Eventos por tipo
db.material_event.createIndex({ event_type: 1, created_at: -1 });

// Eventos fallidos (para monitoreo)
db.material_event.createIndex(
  { status: 1, created_at: -1 },
  { partialFilterExpression: { status: "failed" } }
);

// TTL index: Eliminar eventos antiguos después de 90 días
db.material_event.createIndex(
  { created_at: 1 },
  { expireAfterSeconds: 7776000 } // 90 días
);
```

#### Queries Comunes

```javascript
// Historial de procesamiento de un material
db.material_event.find({ material_id: "uuid" }).sort({ created_at: -1 });

// Eventos fallidos en las últimas 24 horas
db.material_event.find({
  status: "failed",
  created_at: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) }
});

// Costo promedio de procesamiento
db.material_event.aggregate([
  { $match: { event_type: "processing_completed", status: "success" } },
  {
    $group: {
      _id: null,
      avg_cost: { $avg: "$metadata.estimated_cost_usd" },
      avg_duration: { $avg: "$duration_seconds" }
    }
  }
]);
```

---

## Colecciones Post-MVP

### 4. `unit_social_feed`

**Propósito**: Publicaciones y comentarios en unidades académicas (red social educativa).

#### Estructura del Documento

```json
{
  "_id": ObjectId("..."),
  "unit_id": "uuid-from-postgresql",
  "author_id": "uuid-from-postgresql",
  "post_type": "text",
  "content": "¿Alguien puede ayudarme con el ejercicio 5 del quiz de Pascal?",
  "attachments": [],
  "related_material_id": "uuid-from-postgresql",
  "likes_count": 3,
  "comments_count": 2,
  "comments": [
    {
      "id": "comment-1",
      "author_id": "uuid",
      "content": "Revisa la sección sobre estructuras de control",
      "created_at": ISODate("2025-01-15T14:00:00Z")
    }
  ],
  "created_at": ISODate("2025-01-15T13:30:00Z"),
  "updated_at": ISODate("2025-01-15T14:00:00Z")
}
```

### 5. `user_graph_relation`

**Propósito**: Grafos de relaciones sociales entre usuarios (seguimiento, recomendaciones).

#### Estructura del Documento

```json
{
  "_id": ObjectId("..."),
  "user_id": "uuid-from-postgresql",
  "relation_type": "follows",
  "target_user_id": "uuid-from-postgresql",
  "metadata": {
    "common_units": ["uuid-1", "uuid-2"],
    "interaction_score": 85
  },
  "created_at": ISODate("2025-01-15T13:00:00Z")
}
```

---

## Estrategias de Escalado

### Sharding

**Shard Key**: `material_id` (distribución uniforme por material)

```javascript
sh.shardCollection("edugo.material_summary", { material_id: 1 });
sh.shardCollection("edugo.material_assessment", { material_id: 1 });
sh.shardCollection("edugo.material_event", { material_id: 1, created_at: -1 });
```

### Replica Sets

- **Primary**: Escrituras
- **Secondary 1**: Lecturas de resúmenes (alta demanda)
- **Secondary 2**: Backups y analytics

```javascript
// Read Preference para queries de solo lectura
db.material_summary.find().readPref("secondaryPreferred");
```

---

## Backup y Recuperación

### Estrategia

1. **Snapshots diarios** vía MongoDB Atlas
2. **Point-in-time recovery** habilitado
3. **Retención**: 7 días snapshots diarios, 4 semanas snapshots semanales

### Pruebas de Restauración

```bash
# Restaurar colección específica
mongorestore --collection=material_summary --db=edugo /path/to/backup/material_summary.bson
```

---

**Documento**: Colecciones MongoDB de EduGo
**Versión**: 1.0
**Fecha**: 2025-01-29
**Autor**: Equipo EduGo
**Total de Colecciones MVP**: 3
**Total de Colecciones Post-MVP**: 2
