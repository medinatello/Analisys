// Script para crear colecciones MongoDB con validación de schema
// Ejecutar con: mongosh mongodb://localhost:27017/edugo < 01_collections.js

use edugo;

// ========================================
// 1. material_summary
// ========================================

db.createCollection("material_summary", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["material_id", "version", "status", "sections", "created_at"],
      properties: {
        material_id: {
          bsonType: "string",
          description: "UUID del material en PostgreSQL (requerido)"
        },
        version: {
          bsonType: "int",
          minimum: 1,
          description: "Versión del resumen (incremental, requerido)"
        },
        status: {
          enum: ["processing", "completed", "failed"],
          description: "Estado del procesamiento (requerido)"
        },
        sections: {
          bsonType: "array",
          minItems: 1,
          description: "Secciones del resumen (requerido, mínimo 1)",
          items: {
            bsonType: "object",
            required: ["title", "content", "difficulty", "order"],
            properties: {
              title: {
                bsonType: "string",
                minLength: 3,
                description: "Título de la sección"
              },
              content: {
                bsonType: "string",
                minLength: 50,
                description: "Contenido de la sección (mínimo 50 caracteres)"
              },
              difficulty: {
                enum: ["basic", "medium", "advanced"],
                description: "Nivel de dificultad"
              },
              estimated_time_minutes: {
                bsonType: "int",
                minimum: 1,
                description: "Tiempo estimado de lectura en minutos"
              },
              order: {
                bsonType: "int",
                minimum: 1,
                description: "Orden de la sección"
              }
            }
          }
        },
        glossary: {
          bsonType: "array",
          description: "Glosario de términos",
          items: {
            bsonType: "object",
            required: ["term", "definition", "order"],
            properties: {
              term: {
                bsonType: "string",
                minLength: 2,
                description: "Término del glosario"
              },
              definition: {
                bsonType: "string",
                minLength: 10,
                description: "Definición del término"
              },
              order: {
                bsonType: "int",
                minimum: 1,
                description: "Orden del término"
              }
            }
          }
        },
        reflection_questions: {
          bsonType: "array",
          minItems: 3,
          description: "Preguntas reflexivas (mínimo 3)",
          items: {
            bsonType: "string",
            minLength: 10,
            description: "Pregunta reflexiva"
          }
        },
        processing_metadata: {
          bsonType: "object",
          description: "Metadatos del procesamiento",
          properties: {
            nlp_provider: { bsonType: "string" },
            model: { bsonType: "string" },
            tokens_used: { bsonType: "int" },
            processing_time_seconds: { bsonType: "int" },
            language: { bsonType: "string" },
            prompt_version: { bsonType: "string" }
          }
        },
        created_at: {
          bsonType: "date",
          description: "Fecha de creación (requerido)"
        },
        updated_at: {
          bsonType: "date",
          description: "Fecha de última actualización"
        }
      }
    }
  }
});

print("✓ Colección 'material_summary' creada con validación de schema");

// ========================================
// 2. material_assessment
// ========================================

db.createCollection("material_assessment", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["material_id", "title", "questions", "version", "created_at"],
      properties: {
        material_id: {
          bsonType: "string",
          description: "UUID del material en PostgreSQL (requerido)"
        },
        title: {
          bsonType: "string",
          minLength: 5,
          description: "Título del cuestionario (requerido, mínimo 5 caracteres)"
        },
        description: {
          bsonType: "string",
          description: "Descripción del cuestionario"
        },
        questions: {
          bsonType: "array",
          minItems: 3,
          maxItems: 20,
          description: "Preguntas del cuestionario (mínimo 3, máximo 20)",
          items: {
            bsonType: "object",
            required: ["id", "text", "type", "options", "correct_answer", "order"],
            properties: {
              id: {
                bsonType: "string",
                description: "ID único de la pregunta"
              },
              text: {
                bsonType: "string",
                minLength: 10,
                description: "Texto de la pregunta (mínimo 10 caracteres)"
              },
              type: {
                enum: ["multiple_choice", "true_false", "short_answer"],
                description: "Tipo de pregunta"
              },
              difficulty: {
                enum: ["basic", "medium", "advanced"],
                description: "Nivel de dificultad"
              },
              points: {
                bsonType: "int",
                minimum: 1,
                description: "Puntos de la pregunta"
              },
              order: {
                bsonType: "int",
                minimum: 1,
                description: "Orden de la pregunta"
              },
              options: {
                bsonType: "array",
                minItems: 2,
                description: "Opciones de respuesta",
                items: {
                  bsonType: "object",
                  required: ["id", "text"],
                  properties: {
                    id: { bsonType: "string" },
                    text: { bsonType: "string" }
                  }
                }
              },
              correct_answer: {
                bsonType: "string",
                description: "ID de la opción correcta"
              },
              feedback: {
                bsonType: "object",
                description: "Retroalimentación para respuestas",
                properties: {
                  correct: { bsonType: "string" },
                  incorrect: { bsonType: "string" }
                }
              }
            }
          }
        },
        total_questions: {
          bsonType: "int",
          minimum: 1,
          description: "Número total de preguntas"
        },
        total_points: {
          bsonType: "int",
          minimum: 1,
          description: "Puntaje total del quiz"
        },
        passing_score: {
          bsonType: "int",
          minimum: 0,
          maximum: 100,
          description: "Puntaje mínimo para aprobar (0-100)"
        },
        time_limit_minutes: {
          bsonType: "int",
          minimum: 1,
          description: "Tiempo límite en minutos"
        },
        version: {
          bsonType: "int",
          minimum: 1,
          description: "Versión del cuestionario"
        },
        processing_metadata: {
          bsonType: "object",
          description: "Metadatos del procesamiento"
        },
        created_at: {
          bsonType: "date",
          description: "Fecha de creación (requerido)"
        },
        updated_at: {
          bsonType: "date",
          description: "Fecha de última actualización"
        }
      }
    }
  }
});

print("✓ Colección 'material_assessment' creada con validación de schema");

// ========================================
// 3. material_event
// ========================================

db.createCollection("material_event", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["material_id", "event_type", "status", "created_at"],
      properties: {
        material_id: {
          bsonType: "string",
          description: "UUID del material en PostgreSQL (requerido)"
        },
        event_type: {
          enum: [
            "processing_started",
            "processing_completed",
            "processing_failed",
            "summary_generated",
            "assessment_generated",
            "material_reprocessed"
          ],
          description: "Tipo de evento (requerido)"
        },
        worker_id: {
          bsonType: "string",
          description: "ID del worker que procesó el evento"
        },
        status: {
          enum: ["success", "failed", "pending"],
          description: "Estado del evento (requerido)"
        },
        duration_seconds: {
          bsonType: "int",
          minimum: 0,
          description: "Duración del procesamiento en segundos"
        },
        error_message: {
          bsonType: ["string", "null"],
          description: "Mensaje de error si status = failed"
        },
        retry_count: {
          bsonType: "int",
          minimum: 0,
          description: "Número de reintentos"
        },
        metadata: {
          bsonType: "object",
          description: "Metadatos adicionales del evento",
          properties: {
            nlp_provider: { bsonType: "string" },
            nlp_tokens_used: { bsonType: "int" },
            estimated_cost_usd: { bsonType: "double" },
            pdf_file_size_bytes: { bsonType: "long" },
            pdf_pages: { bsonType: "int" },
            extracted_text_length: { bsonType: "int" },
            summary_sections_generated: { bsonType: "int" },
            quiz_questions_generated: { bsonType: "int" }
          }
        },
        created_at: {
          bsonType: "date",
          description: "Fecha de creación (requerido)"
        }
      }
    }
  }
});

print("✓ Colección 'material_event' creada con validación de schema");

// ========================================
// Resumen
// ========================================

print("\n========================================");
print("Colecciones creadas exitosamente:");
print("  - material_summary");
print("  - material_assessment");
print("  - material_event");
print("========================================\n");

print("Siguiente paso: Ejecutar 02_indexes.js para crear índices");
