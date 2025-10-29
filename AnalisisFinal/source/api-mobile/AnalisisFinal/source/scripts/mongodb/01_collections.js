// Script para crear colecciones MongoDB con validación de schema
// Ejecutar con: mongosh mongodb://localhost:27017/edugo < 01_collections.js

use edugo;

db.createCollection("material_summary", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["material_id", "version", "status", "sections", "created_at"],
      properties: {
        material_id: { bsonType: "string" },
        version: { bsonType: "int", minimum: 1 },
        status: { enum: ["processing", "completed", "failed"] },
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
              order: { bsonType: "int", minimum: 1 }
            }
          }
        }
      }
    }
  }
});

print("✓ Colección 'material_summary' creada");

db.createCollection("material_assessment", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["material_id", "title", "questions", "version"],
      properties: {
        material_id: { bsonType: "string" },
        title: { bsonType: "string", minLength: 5 },
        questions: {
          bsonType: "array",
          minItems: 3,
          items: {
            bsonType: "object",
            required: ["id", "text", "type", "options", "correct_answer"],
            properties: {
              id: { bsonType: "string" },
              text: { bsonType: "string", minLength: 10 },
              type: { enum: ["multiple_choice", "true_false"] },
              correct_answer: { bsonType: "string" }
            }
          }
        },
        version: { bsonType: "int", minimum: 1 }
      }
    }
  }
});

print("✓ Colección 'material_assessment' creada");

db.createCollection("material_event");

print("✓ Colección 'material_event' creada");
