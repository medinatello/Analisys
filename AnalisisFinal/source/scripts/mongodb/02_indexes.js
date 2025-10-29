// Script para crear índices en colecciones MongoDB
// Ejecutar con: mongosh mongodb://localhost:27017/edugo < 02_indexes.js

use edugo;

print("Creando índices para colecciones de EduGo...\n");

// ========================================
// material_summary
// ========================================

print("Índices para material_summary:");

// Índice único por material_id
db.material_summary.createIndex(
  { material_id: 1 },
  { unique: true, name: "idx_material_id_unique" }
);
print("  ✓ idx_material_id_unique");

// Índice por estado
db.material_summary.createIndex(
  { status: 1 },
  { name: "idx_status" }
);
print("  ✓ idx_status");

// Índice compuesto para filtrado avanzado
db.material_summary.createIndex(
  { material_id: 1, version: -1, status: 1 },
  { name: "idx_material_version_status" }
);
print("  ✓ idx_material_version_status");

// Índice full-text para búsqueda en secciones y glosario
db.material_summary.createIndex(
  {
    "sections.title": "text",
    "sections.content": "text",
    "glossary.term": "text",
    "glossary.definition": "text"
  },
  { name: "idx_full_text_search" }
);
print("  ✓ idx_full_text_search");

// ========================================
// material_assessment
// ========================================

print("\nÍndices para material_assessment:");

// Índice único por material_id
db.material_assessment.createIndex(
  { material_id: 1 },
  { unique: true, name: "idx_material_id_unique" }
);
print("  ✓ idx_material_id_unique");

// Índice por question_id (para validación de respuestas)
db.material_assessment.createIndex(
  { "questions.id": 1 },
  { name: "idx_questions_id" }
);
print("  ✓ idx_questions_id");

// Índice full-text para búsqueda en preguntas
db.material_assessment.createIndex(
  { "questions.text": "text", title: "text" },
  { name: "idx_quiz_text_search" }
);
print("  ✓ idx_quiz_text_search");

// ========================================
// material_event
// ========================================

print("\nÍndices para material_event:");

// Índice compuesto por material_id y created_at (query principal)
db.material_event.createIndex(
  { material_id: 1, created_at: -1 },
  { name: "idx_material_created" }
);
print("  ✓ idx_material_created");

// Índice por event_type y created_at
db.material_event.createIndex(
  { event_type: 1, created_at: -1 },
  { name: "idx_event_type_created" }
);
print("  ✓ idx_event_type_created");

// Índice parcial para eventos fallidos (monitoreo)
db.material_event.createIndex(
  { status: 1, created_at: -1 },
  {
    partialFilterExpression: { status: "failed" },
    name: "idx_failed_events"
  }
);
print("  ✓ idx_failed_events");

// TTL Index: Eliminar eventos antiguos después de 90 días
db.material_event.createIndex(
  { created_at: 1 },
  {
    expireAfterSeconds: 7776000, // 90 días
    name: "idx_ttl_90_days"
  }
);
print("  ✓ idx_ttl_90_days (TTL: 90 días)");

// ========================================
// Resumen
// ========================================

print("\n========================================");
print("Índices creados exitosamente:");
print("  material_summary: 4 índices");
print("  material_assessment: 3 índices");
print("  material_event: 4 índices (incluye TTL)");
print("========================================\n");

print("Siguiente paso: Ejecutar 03_mock_data.js para insertar datos de prueba");
