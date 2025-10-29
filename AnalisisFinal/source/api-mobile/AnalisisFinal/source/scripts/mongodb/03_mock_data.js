// Script para insertar datos mock en MongoDB
// Ejecutar con: mongosh mongodb://localhost:27017/edugo < 03_mock_data.js

use edugo;

// Resumen mock
db.material_summary.insertOne({
  material_id: "material-uuid-1",
  version: 1,
  status: "completed",
  sections: [
    {
      title: "Contexto Histórico",
      content: "Pascal fue desarrollado por Niklaus Wirth en 1970...",
      difficulty: "basic",
      estimated_time_minutes: 5,
      order: 1
    }
  ],
  glossary: [
    { term: "Compilador", definition: "Programa que traduce código...", order: 1 }
  ],
  reflection_questions: [
    "¿Qué ventajas aportó Pascal?",
    "¿Por qué es importante la tipificación fuerte?"
  ],
  processing_metadata: {
    nlp_provider: "openai",
    model: "gpt-4",
    tokens_used: 3500
  },
  created_at: new Date()
});
print("✓ 1 resumen insertado");

// Quiz mock
db.material_assessment.insertOne({
  material_id: "material-uuid-1",
  title: "Cuestionario: Introducción a Pascal",
  questions: [
    {
      id: "q1",
      text: "¿Qué es un compilador?",
      type: "multiple_choice",
      difficulty: "basic",
      points: 20,
      order: 1,
      options: [
        { id: "a", text: "Un programa que traduce código" },
        { id: "b", text: "Un tipo de variable" }
      ],
      correct_answer: "a",
      feedback: {
        correct: "¡Correcto!",
        incorrect: "Incorrecto. Revisa el resumen."
      }
    }
  ],
  total_questions: 1,
  total_points: 20,
  version: 1,
  created_at: new Date()
});
print("✓ 1 quiz insertado");

// Eventos mock
db.material_event.insertOne({
  material_id: "material-uuid-1",
  event_type: "processing_completed",
  worker_id: "worker-1",
  status: "success",
  duration_seconds: 120,
  created_at: new Date()
});
print("✓ 1 evento insertado");
