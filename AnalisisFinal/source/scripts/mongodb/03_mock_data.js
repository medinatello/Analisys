// Script para insertar datos mock en MongoDB
// Ejecutar con: mongosh mongodb://localhost:27017/edugo < 03_mock_data.js

use edugo;

print("Insertando datos mock en colecciones de EduGo...\n");

// ========================================
// 1. material_summary - 3 resúmenes
// ========================================

print("Insertando resúmenes en material_summary...");

db.material_summary.insertMany([
  {
    material_id: "material-uuid-1",
    version: 1,
    status: "completed",
    sections: [
      {
        title: "Contexto Histórico",
        content: "Pascal fue desarrollado por Niklaus Wirth en 1970 como un lenguaje educativo que enfatizaba la programación estructurada. El lenguaje fue nombrado en honor al matemático francés Blaise Pascal.",
        difficulty: "basic",
        estimated_time_minutes: 5,
        order: 1
      },
      {
        title: "Sintaxis y Estructura",
        content: "El lenguaje Pascal utiliza una sintaxis clara y estructurada. Los programas se organizan en bloques con begin y end, y utilizan tipificación fuerte para prevenir errores en tiempo de compilación.",
        difficulty: "medium",
        estimated_time_minutes: 8,
        order: 2
      },
      {
        title: "Aplicaciones Modernas",
        content: "Aunque Pascal no es tan utilizado hoy en producción, sentó las bases para lenguajes modernos como Ada y Modula-2. Sigue siendo valioso para enseñar conceptos fundamentales de programación.",
        difficulty: "advanced",
        estimated_time_minutes: 6,
        order: 3
      }
    ],
    glossary: [
      {
        term: "Compilador",
        definition: "Programa que traduce código fuente a código máquina ejecutable.",
        order: 1
      },
      {
        term: "Variable",
        definition: "Espacio en memoria para almacenar un valor que puede cambiar.",
        order: 2
      },
      {
        term: "Tipo de Dato",
        definition: "Clasificación que especifica qué tipo de valor puede almacenar una variable.",
        order: 3
      }
    ],
    reflection_questions: [
      "¿Qué ventajas aportó Pascal sobre lenguajes anteriores?",
      "¿Por qué es importante la tipificación fuerte en programación?",
      "¿En qué contextos se sigue usando Pascal actualmente?"
    ],
    processing_metadata: {
      nlp_provider: "openai",
      model: "gpt-4",
      tokens_used: 3500,
      processing_time_seconds: 45,
      language: "es",
      prompt_version: "v1.2"
    },
    created_at: new Date("2025-01-15T12:30:00Z"),
    updated_at: new Date("2025-01-15T12:30:00Z")
  },
  {
    material_id: "material-uuid-2",
    version: 1,
    status: "completed",
    sections: [
      {
        title: "Definición de Estructura de Control",
        content: "Las estructuras de control permiten dirigir el flujo de ejecución de un programa. En Pascal, las principales son IF-THEN-ELSE para decisiones y WHILE-DO para iteraciones.",
        difficulty: "basic",
        estimated_time_minutes: 7,
        order: 1
      }
    ],
    glossary: [
      {
        term: "Bucle",
        definition: "Estructura que repite un bloque de código mientras se cumple una condición.",
        order: 1
      }
    ],
    reflection_questions: [
      "¿Cuándo usar WHILE en lugar de FOR?",
      "¿Qué riesgos tiene un bucle infinito?"
    ],
    processing_metadata: {
      nlp_provider: "openai",
      model: "gpt-4",
      tokens_used: 2800,
      processing_time_seconds: 38,
      language: "es",
      prompt_version: "v1.2"
    },
    created_at: new Date("2025-01-20T10:00:00Z"),
    updated_at: new Date("2025-01-20T10:00:00Z")
  }
]);

print("  ✓ 2 resúmenes insertados");

// ========================================
// 2. material_assessment - 2 cuestionarios
// ========================================

print("\nInsertando cuestionarios en material_assessment...");

db.material_assessment.insertMany([
  {
    material_id: "material-uuid-1",
    title: "Cuestionario: Introducción a Pascal",
    description: "Evaluación de conceptos básicos sobre el lenguaje Pascal",
    questions: [
      {
        id: "q1",
        text: "¿Qué es un compilador?",
        type: "multiple_choice",
        difficulty: "basic",
        points: 20,
        order: 1,
        options: [
          { id: "a", text: "Un programa que traduce código fuente a código máquina" },
          { id: "b", text: "Un tipo de variable en Pascal" },
          { id: "c", text: "Una estructura de control para bucles" },
          { id: "d", text: "Un editor de texto especializado" }
        ],
        correct_answer: "a",
        feedback: {
          correct: "¡Correcto! Un compilador traduce código fuente a código máquina ejecutable.",
          incorrect: "Incorrecto. Revisa la sección 'Herramientas de Desarrollo' en el resumen."
        }
      },
      {
        id: "q2",
        text: "¿Cuál es la principal ventaja de la tipificación fuerte en Pascal?",
        type: "multiple_choice",
        difficulty: "medium",
        points: 20,
        order: 2,
        options: [
          { id: "a", text: "Hace que el código se ejecute más rápido" },
          { id: "b", text: "Previene errores detectándolos en tiempo de compilación" },
          { id: "c", text: "Reduce el tamaño del ejecutable final" },
          { id: "d", text: "Permite usar menos memoria RAM" }
        ],
        correct_answer: "b",
        feedback: {
          correct: "¡Exacto! La tipificación fuerte detecta errores antes de ejecutar el programa.",
          incorrect: "No es correcto. Piensa en qué sucede durante la compilación con tipos bien definidos."
        }
      },
      {
        id: "q3",
        text: "¿En qué año fue creado el lenguaje Pascal?",
        type: "multiple_choice",
        difficulty: "basic",
        points: 20,
        order: 3,
        options: [
          { id: "a", text: "1965" },
          { id: "b", text: "1970" },
          { id: "c", text: "1980" },
          { id: "d", text: "1990" }
        ],
        correct_answer: "b",
        feedback: {
          correct: "¡Correcto! Niklaus Wirth creó Pascal en 1970 como un lenguaje educativo.",
          incorrect: "Incorrecto. Revisa la sección 'Contexto Histórico' del resumen."
        }
      }
    ],
    total_questions: 3,
    total_points: 60,
    passing_score: 70,
    time_limit_minutes: 10,
    version: 1,
    processing_metadata: {
      nlp_provider: "openai",
      model: "gpt-4",
      tokens_used: 2200,
      processing_time_seconds: 32,
      language: "es"
    },
    created_at: new Date("2025-01-15T12:35:00Z"),
    updated_at: new Date("2025-01-15T12:35:00Z")
  }
]);

print("  ✓ 1 cuestionario insertado");

// ========================================
// 3. material_event - 4 eventos
// ========================================

print("\nInsertando eventos en material_event...");

db.material_event.insertMany([
  {
    material_id: "material-uuid-1",
    event_type: "processing_completed",
    worker_id: "worker-pod-1",
    status: "success",
    duration_seconds: 120,
    error_message: null,
    retry_count: 0,
    metadata: {
      nlp_provider: "openai",
      nlp_tokens_used: 6300,
      estimated_cost_usd: 0.14,
      pdf_file_size_bytes: 2048576,
      pdf_pages: 25,
      extracted_text_length: 15000,
      summary_sections_generated: 3,
      quiz_questions_generated: 3
    },
    created_at: new Date("2025-01-15T12:35:00Z")
  },
  {
    material_id: "material-uuid-2",
    event_type: "processing_completed",
    worker_id: "worker-pod-2",
    status: "success",
    duration_seconds: 95,
    error_message: null,
    retry_count: 0,
    metadata: {
      nlp_provider: "openai",
      nlp_tokens_used: 5000,
      estimated_cost_usd: 0.11,
      pdf_file_size_bytes: 1500000,
      pdf_pages: 18,
      extracted_text_length: 12000,
      summary_sections_generated: 1,
      quiz_questions_generated: 0
    },
    created_at: new Date("2025-01-20T10:05:00Z")
  },
  {
    material_id: "material-uuid-3",
    event_type: "processing_failed",
    worker_id: "worker-pod-1",
    status: "failed",
    duration_seconds: 15,
    error_message: "PDF corrupted or unreadable",
    retry_count: 3,
    metadata: {
      pdf_file_size_bytes: 500000,
      error_details: "Could not extract text from PDF"
    },
    created_at: new Date("2025-01-25T14:00:00Z")
  }
]);

print("  ✓ 3 eventos insertados");

// ========================================
// Resumen
// ========================================

print("\n========================================");
print("Datos mock insertados exitosamente:");
print("  - 2 resúmenes en material_summary");
print("  - 1 cuestionario en material_assessment");
print("  - 3 eventos en material_event");
print("========================================\n");

print("Base de datos MongoDB lista para usar con datos de prueba");
