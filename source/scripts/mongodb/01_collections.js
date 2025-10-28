// =====================================================
// EduGo - Colecciones MongoDB con Validación
// Base de Datos Documental para Contenidos Flexibles
// =====================================================

// Conectar a la base de datos EduGo
use edugo;

// =====================================================
// COLECCIÓN 1: material_summary
// Resúmenes generados por IA
// =====================================================

db.createCollection("material_summary", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "material_id", "version", "sections", "status", "updated_at"],
      properties: {
        _id: {
          bsonType: "string",
          description: "UUID del documento"
        },
        material_id: {
          bsonType: "string",
          description: "UUID del material en PostgreSQL (FK lógico)"
        },
        version: {
          bsonType: "int",
          minimum: 1,
          description: "Versión del resumen"
        },
        sections: {
          bsonType: "array",
          description: "Secciones del resumen",
          items: {
            bsonType: "object",
            required: ["title", "content", "level"],
            properties: {
              title: {
                bsonType: "string",
                description: "Título de la sección"
              },
              content: {
                bsonType: "string",
                description: "Contenido del resumen"
              },
              level: {
                enum: ["basic", "intermediate", "advanced"],
                description: "Nivel de complejidad"
              }
            }
          }
        },
        glossary: {
          bsonType: "array",
          description: "Glosario de términos",
          items: {
            bsonType: "object",
            required: ["term", "definition"],
            properties: {
              term: {
                bsonType: "string",
                description: "Término"
              },
              definition: {
                bsonType: "string",
                description: "Definición del término"
              }
            }
          }
        },
        reflection_questions: {
          bsonType: "array",
          description: "Preguntas de reflexión",
          items: {
            bsonType: "string"
          }
        },
        status: {
          enum: ["pending", "processing", "complete", "failed"],
          description: "Estado del procesamiento"
        },
        updated_at: {
          bsonType: "date",
          description: "Fecha de última actualización"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// Crear índices para material_summary
db.material_summary.createIndex({ material_id: 1 }, { unique: true });
db.material_summary.createIndex({ status: 1 });
db.material_summary.createIndex({ updated_at: -1 });

print("✓ Colección 'material_summary' creada con validación");

// =====================================================
// COLECCIÓN 2: material_assessment
// Banco de preguntas y evaluaciones
// =====================================================

db.createCollection("material_assessment", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "material_id", "title", "questions", "version", "total_points", "created_at"],
      properties: {
        _id: {
          bsonType: "string",
          description: "UUID del documento"
        },
        material_id: {
          bsonType: "string",
          description: "UUID del material en PostgreSQL (FK lógico)"
        },
        title: {
          bsonType: "string",
          description: "Título de la evaluación"
        },
        questions: {
          bsonType: "array",
          description: "Lista de preguntas",
          minItems: 1,
          items: {
            bsonType: "object",
            required: ["id", "text", "type", "difficulty"],
            properties: {
              id: {
                bsonType: "string",
                description: "UUID de la pregunta"
              },
              text: {
                bsonType: "string",
                description: "Texto de la pregunta"
              },
              type: {
                enum: ["multiple_choice", "true_false", "open_ended"],
                description: "Tipo de pregunta"
              },
              options: {
                bsonType: "array",
                description: "Opciones para multiple_choice",
                items: {
                  bsonType: "string"
                }
              },
              answer: {
                description: "Respuesta correcta (puede ser null para open_ended)"
              },
              feedback: {
                bsonType: "string",
                description: "Retroalimentación para el estudiante"
              },
              rubric: {
                bsonType: "string",
                description: "Rúbrica para preguntas abiertas"
              },
              difficulty: {
                enum: ["easy", "medium", "hard"],
                description: "Nivel de dificultad"
              },
              points: {
                bsonType: "number",
                minimum: 0,
                description: "Puntos que vale la pregunta"
              }
            }
          }
        },
        version: {
          bsonType: "int",
          minimum: 1,
          description: "Versión de la evaluación"
        },
        total_points: {
          bsonType: "number",
          minimum: 0,
          description: "Puntos totales de la evaluación"
        },
        estimated_duration_minutes: {
          bsonType: "int",
          minimum: 1,
          description: "Duración estimada en minutos"
        },
        created_at: {
          bsonType: "date",
          description: "Fecha de creación"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// Crear índices para material_assessment
db.material_assessment.createIndex({ material_id: 1 }, { unique: true });
db.material_assessment.createIndex({ "questions.id": 1 });
db.material_assessment.createIndex({ created_at: -1 });

print("✓ Colección 'material_assessment' creada con validación");

// =====================================================
// COLECCIÓN 3: material_event
// Logs y métricas de procesamiento
// =====================================================

db.createCollection("material_event", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "material_id", "event_type", "created_at"],
      properties: {
        _id: {
          bsonType: "string",
          description: "UUID del evento"
        },
        material_id: {
          bsonType: "string",
          description: "UUID del material en PostgreSQL"
        },
        event_type: {
          enum: ["processing_started", "processing_completed", "processing_failed", "reprocessing_requested"],
          description: "Tipo de evento"
        },
        worker_id: {
          bsonType: "string",
          description: "ID del worker que procesó"
        },
        duration_seconds: {
          bsonType: "number",
          minimum: 0,
          description: "Duración del procesamiento en segundos"
        },
        error_message: {
          bsonType: "string",
          description: "Mensaje de error si falló"
        },
        metadata: {
          bsonType: "object",
          description: "Metadatos adicionales del procesamiento",
          properties: {
            nlp_provider: {
              bsonType: "string",
              description: "Proveedor de NLP utilizado"
            },
            model: {
              bsonType: "string",
              description: "Modelo de IA utilizado"
            },
            tokens_used: {
              bsonType: "int",
              minimum: 0,
              description: "Tokens consumidos"
            }
          }
        },
        created_at: {
          bsonType: "date",
          description: "Fecha del evento"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// Crear índices para material_event
db.material_event.createIndex({ material_id: 1, created_at: -1 });
db.material_event.createIndex({ event_type: 1 });
db.material_event.createIndex({ created_at: -1 });
db.material_event.createIndex({ worker_id: 1 });

// Configurar TTL index para eliminar eventos antiguos después de 90 días
db.material_event.createIndex(
  { created_at: 1 },
  { expireAfterSeconds: 7776000 } // 90 días
);

print("✓ Colección 'material_event' creada con validación y TTL");

// =====================================================
// COLECCIÓN 4: unit_social_feed (POST-MVP)
// Feeds sociales de unidades académicas
// =====================================================

db.createCollection("unit_social_feed", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "unit_id", "author_id", "post_type", "content", "created_at"],
      properties: {
        _id: {
          bsonType: "string",
          description: "UUID del post"
        },
        unit_id: {
          bsonType: "string",
          description: "UUID de la unidad académica en PostgreSQL"
        },
        author_id: {
          bsonType: "string",
          description: "UUID del autor en PostgreSQL"
        },
        post_type: {
          enum: ["announcement", "discussion", "resource_share", "question"],
          description: "Tipo de publicación"
        },
        content: {
          bsonType: "string",
          description: "Contenido del post"
        },
        attachments: {
          bsonType: "array",
          description: "Archivos adjuntos",
          items: {
            bsonType: "object",
            required: ["type", "url"],
            properties: {
              type: {
                enum: ["image", "video", "document", "link"],
                description: "Tipo de adjunto"
              },
              url: {
                bsonType: "string",
                description: "URL del adjunto"
              },
              thumbnail_url: {
                bsonType: "string",
                description: "URL del thumbnail"
              }
            }
          }
        },
        likes_count: {
          bsonType: "int",
          minimum: 0,
          description: "Contador de likes"
        },
        comments: {
          bsonType: "array",
          description: "Comentarios del post",
          items: {
            bsonType: "object",
            required: ["author_id", "text", "created_at"],
            properties: {
              author_id: {
                bsonType: "string",
                description: "UUID del autor del comentario"
              },
              text: {
                bsonType: "string",
                description: "Texto del comentario"
              },
              created_at: {
                bsonType: "date",
                description: "Fecha del comentario"
              }
            }
          }
        },
        created_at: {
          bsonType: "date",
          description: "Fecha de creación"
        },
        updated_at: {
          bsonType: "date",
          description: "Fecha de última actualización"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// Crear índices para unit_social_feed
db.unit_social_feed.createIndex({ unit_id: 1, created_at: -1 });
db.unit_social_feed.createIndex({ author_id: 1 });
db.unit_social_feed.createIndex({ post_type: 1 });

print("✓ Colección 'unit_social_feed' creada con validación (POST-MVP)");

// =====================================================
// COLECCIÓN 5: user_graph_relation (POST-MVP)
// Grafos sociales entre usuarios
// =====================================================

db.createCollection("user_graph_relation", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "user_id", "relation_type", "related_user_id", "created_at"],
      properties: {
        _id: {
          bsonType: "string",
          description: "UUID de la relación"
        },
        user_id: {
          bsonType: "string",
          description: "UUID del usuario origen"
        },
        relation_type: {
          enum: ["follows", "recommends", "mentors", "blocks"],
          description: "Tipo de relación"
        },
        related_user_id: {
          bsonType: "string",
          description: "UUID del usuario destino"
        },
        metadata: {
          bsonType: "object",
          description: "Metadatos de la relación",
          properties: {
            affinity_score: {
              bsonType: "number",
              minimum: 0.0,
              maximum: 1.0,
              description: "Puntuación de afinidad"
            },
            common_interests: {
              bsonType: "array",
              description: "Intereses comunes",
              items: {
                bsonType: "string"
              }
            }
          }
        },
        created_at: {
          bsonType: "date",
          description: "Fecha de creación de la relación"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// Crear índices para user_graph_relation
db.user_graph_relation.createIndex({ user_id: 1, relation_type: 1 });
db.user_graph_relation.createIndex({ related_user_id: 1 });
db.user_graph_relation.createIndex({ user_id: 1, related_user_id: 1, relation_type: 1 }, { unique: true });

print("✓ Colección 'user_graph_relation' creada con validación (POST-MVP)");

// =====================================================
// VERIFICACIÓN Y ESTADÍSTICAS
// =====================================================

print("\n=== RESUMEN DE COLECCIONES CREADAS ===");
print("Total de colecciones: " + db.getCollectionNames().length);
print("\nColecciones disponibles:");
db.getCollectionNames().forEach(function(collection) {
  print("  - " + collection);
});

print("\n=== VALIDACIÓN DE ESQUEMAS ===");
print("Todas las colecciones tienen validación estricta activada");
print("Nivel de validación: strict");
print("Acción ante error: error (rechazar documento inválido)");

print("\n✓ Script de creación de colecciones completado exitosamente");
