// Script para crear índices en MongoDB
// Ejecutar con: mongosh mongodb://localhost:27017/edugo < 02_indexes.js

use edugo;

// material_summary
db.material_summary.createIndex({ material_id: 1 }, { unique: true });
db.material_summary.createIndex({ status: 1 });
db.material_summary.createIndex({ "sections.title": "text", "glossary.term": "text" });
print("✓ Índices de material_summary creados");

// material_assessment  
db.material_assessment.createIndex({ material_id: 1 }, { unique: true });
db.material_assessment.createIndex({ "questions.id": 1 });
print("✓ Índices de material_assessment creados");

// material_event
db.material_event.createIndex({ material_id: 1, created_at: -1 });
db.material_event.createIndex({ event_type: 1 });
db.material_event.createIndex({ created_at: 1 }, { expireAfterSeconds: 7776000 });
print("✓ Índices de material_event creados (incluye TTL 90 días)");
