// =====================================================
// EduGo - Datos Mock para MongoDB
// Datos de prueba para colecciones documentales
// =====================================================

// Conectar a la base de datos EduGo
use edugo;

// =====================================================
// LIMPIAR DATOS EXISTENTES (opcional)
// =====================================================
// db.material_summary.deleteMany({});
// db.material_assessment.deleteMany({});
// db.material_event.deleteMany({});
// db.unit_social_feed.deleteMany({});
// db.user_graph_relation.deleteMany({});

// =====================================================
// COLECCIÓN: material_summary
// Resúmenes generados por IA
// =====================================================

db.material_summary.insertMany([
  {
    _id: "mongo-sum-0000-0000-0000-000000000001",
    material_id: "m1000001-0000-0000-0000-000000000001",
    version: 1,
    sections: [
      {
        title: "Introducción a las Fracciones",
        content: "Las fracciones son números que representan partes de un todo. Se componen de dos elementos: el numerador (número superior) que indica cuántas partes tenemos, y el denominador (número inferior) que indica en cuántas partes se divide el todo.",
        level: "basic"
      },
      {
        title: "Tipos de Fracciones",
        content: "Existen tres tipos principales de fracciones: propias (numerador menor que denominador), impropias (numerador mayor que denominador) y mixtas (combinación de número entero y fracción). Cada tipo tiene sus características y usos específicos en matemáticas.",
        level: "intermediate"
      },
      {
        title: "Operaciones con Fracciones",
        content: "Para sumar o restar fracciones, necesitamos un denominador común. En la multiplicación, multiplicamos numeradores entre sí y denominadores entre sí. La división se realiza multiplicando por el inverso de la segunda fracción.",
        level: "advanced"
      }
    ],
    glossary: [
      {
        term: "Numerador",
        definition: "Número superior de una fracción que indica cuántas partes tenemos"
      },
      {
        term: "Denominador",
        definition: "Número inferior de una fracción que indica en cuántas partes se divide el todo"
      },
      {
        term: "Fracción propia",
        definition: "Fracción donde el numerador es menor que el denominador"
      },
      {
        term: "Fracción impropia",
        definition: "Fracción donde el numerador es mayor que el denominador"
      }
    ],
    reflection_questions: [
      "¿Por qué es importante tener un denominador común al sumar fracciones?",
      "¿En qué situaciones de la vida real utilizas fracciones sin darte cuenta?",
      "¿Cómo explicarías las fracciones a un niño de menor edad?"
    ],
    status: "complete",
    updated_at: new Date("2024-02-01T10:00:00Z")
  },
  {
    _id: "mongo-sum-0000-0000-0000-000000000002",
    material_id: "m1000002-0000-0000-0000-000000000002",
    version: 1,
    sections: [
      {
        title: "¿Qué es un Triángulo?",
        content: "Un triángulo es un polígono de tres lados y tres ángulos. Es una de las figuras geométricas más importantes y fundamentales en matemáticas. La suma de sus ángulos internos siempre es 180 grados.",
        level: "basic"
      },
      {
        title: "Clasificación de Triángulos",
        content: "Los triángulos se clasifican según sus lados (equilátero, isósceles, escaleno) y según sus ángulos (acutángulo, rectángulo, obtusángulo). Cada tipo tiene propiedades únicas que los definen.",
        level: "intermediate"
      }
    ],
    glossary: [
      {
        term: "Triángulo equilátero",
        definition: "Triángulo con tres lados iguales y tres ángulos de 60 grados"
      },
      {
        term: "Triángulo isósceles",
        definition: "Triángulo con dos lados iguales"
      },
      {
        term: "Triángulo escaleno",
        definition: "Triángulo con tres lados de diferente longitud"
      }
    ],
    reflection_questions: [
      "¿Por qué la suma de los ángulos de un triángulo siempre es 180 grados?",
      "¿Qué estructuras triangulares ves en tu entorno diario?"
    ],
    status: "complete",
    updated_at: new Date("2024-02-05T14:30:00Z")
  },
  {
    _id: "mongo-sum-0000-0000-0000-000000000003",
    material_id: "m2000001-0000-0000-0000-000000000001",
    version: 2,
    sections: [
      {
        title: "¿Qué es Python?",
        content: "Python es un lenguaje de programación de alto nivel, interpretado y de propósito general. Creado por Guido van Rossum en 1991, se caracteriza por su sintaxis clara y legible, lo que lo hace ideal para principiantes.",
        level: "basic"
      },
      {
        title: "Características Principales",
        content: "Python es un lenguaje de tipado dinámico, multiparadigma y con una amplia biblioteca estándar. Soporta programación orientada a objetos, funcional e imperativa. Su filosofía se resume en 'El Zen de Python': simple es mejor que complejo.",
        level: "intermediate"
      },
      {
        title: "Aplicaciones de Python",
        content: "Python se utiliza en desarrollo web (Django, Flask), ciencia de datos (Pandas, NumPy), inteligencia artificial (TensorFlow, PyTorch), automatización, testing y más. Su versatilidad lo hace uno de los lenguajes más populares del mundo.",
        level: "advanced"
      }
    ],
    glossary: [
      {
        term: "Lenguaje interpretado",
        definition: "Lenguaje que se ejecuta línea por línea sin necesidad de compilación previa"
      },
      {
        term: "Tipado dinámico",
        definition: "No es necesario declarar el tipo de las variables explícitamente"
      },
      {
        term: "Biblioteca estándar",
        definition: "Conjunto de módulos incluidos con Python que proporcionan funcionalidades comunes"
      }
    ],
    reflection_questions: [
      "¿Qué ventajas tiene Python sobre otros lenguajes de programación?",
      "¿En qué proyecto te gustaría aplicar Python?",
      "¿Por qué crees que Python es tan popular en ciencia de datos e IA?"
    ],
    status: "complete",
    updated_at: new Date("2024-02-10T09:15:00Z")
  },
  {
    _id: "mongo-sum-0000-0000-0000-000000000004",
    material_id: "m3000001-0000-0000-0000-000000000001",
    version: 1,
    sections: [
      {
        title: "El Tahuantinsuyo",
        content: "El Imperio Inca o Tahuantinsuyo fue el imperio más extenso de la América precolombina. Se extendió por gran parte de la cordillera de los Andes, abarcando territorios de los actuales Perú, Ecuador, Bolivia, Chile, Argentina y Colombia.",
        level: "basic"
      },
      {
        title: "Organización Social y Política",
        content: "El imperio estaba gobernado por el Sapa Inca, considerado hijo del Sol. La sociedad se organizaba jerárquicamente con la nobleza, los funcionarios, los artesanos y los campesinos. El sistema de reciprocidad (ayni) y redistribución era fundamental.",
        level: "intermediate"
      },
      {
        title: "Legado Cultural",
        content: "Los incas nos dejaron impresionantes obras arquitectónicas como Machu Picchu, un avanzado sistema de caminos (Qhapaq Ñan), técnicas agrícolas como las terrazas de cultivo, y un complejo sistema de administración basado en quipus.",
        level: "advanced"
      }
    ],
    glossary: [
      {
        term: "Sapa Inca",
        definition: "Título del emperador inca, considerado hijo del dios Sol"
      },
      {
        term: "Tahuantinsuyo",
        definition: "Nombre del imperio inca, significa 'las cuatro regiones'"
      },
      {
        term: "Quipu",
        definition: "Sistema de cuerdas con nudos utilizado para registrar información"
      },
      {
        term: "Ayni",
        definition: "Sistema de reciprocidad y ayuda mutua en la sociedad inca"
      }
    ],
    reflection_questions: [
      "¿Qué aspectos de la organización inca podrían ser útiles en la sociedad moderna?",
      "¿Cómo lograron los incas construir un imperio tan extenso sin escritura?",
      "¿Qué importancia tiene preservar el legado cultural inca?"
    ],
    status: "complete",
    updated_at: new Date("2024-02-08T16:45:00Z")
  },
  {
    _id: "mongo-sum-0000-0000-0000-000000000005",
    material_id: "m1000004-0000-0000-0000-000000000004",
    version: 1,
    sections: [],
    glossary: [],
    reflection_questions: [],
    status: "pending",
    updated_at: new Date()
  }
]);

print("✓ Insertados 5 documentos en 'material_summary'");

// =====================================================
// COLECCIÓN: material_assessment
// Bancos de preguntas y evaluaciones
// =====================================================

db.material_assessment.insertMany([
  {
    _id: "mongo-assess-0000-0000-0000-000000000001",
    material_id: "m1000001-0000-0000-0000-000000000001",
    title: "Quiz: Fracciones Básicas",
    questions: [
      {
        id: "q-frac-001",
        text: "¿Qué representa el numerador en una fracción?",
        type: "multiple_choice",
        options: [
          "A) El número de partes que tenemos",
          "B) El número total de partes",
          "C) La suma de las partes",
          "D) El resultado de la división"
        ],
        answer: "A",
        feedback: "¡Correcto! El numerador indica cuántas partes tenemos del total.",
        difficulty: "easy",
        points: 2
      },
      {
        id: "q-frac-002",
        text: "En la fracción 3/4, ¿cuál es el denominador?",
        type: "multiple_choice",
        options: [
          "A) 3",
          "B) 4",
          "C) 7",
          "D) 12"
        ],
        answer: "B",
        feedback: "¡Exacto! El denominador es el número inferior, que en este caso es 4.",
        difficulty: "easy",
        points: 2
      },
      {
        id: "q-frac-003",
        text: "¿Qué tipo de fracción es 5/3?",
        type: "multiple_choice",
        options: [
          "A) Fracción impropia",
          "B) Fracción propia",
          "C) Fracción mixta",
          "D) Fracción decimal"
        ],
        answer: "A",
        feedback: "¡Correcto! Es una fracción impropia porque el numerador (5) es mayor que el denominador (3).",
        difficulty: "medium",
        points: 3
      },
      {
        id: "q-frac-004",
        text: "Explica con tus palabras por qué necesitamos un denominador común para sumar fracciones.",
        type: "open_ended",
        answer: null,
        rubric: "La respuesta debe mencionar que las fracciones deben tener la misma 'unidad' o tamaño de partes para poder sumarlas correctamente. Debe explicar que el denominador común representa el mismo tamaño de división del todo.",
        feedback: "Esta es una pregunta de respuesta abierta que será evaluada por tu profesor.",
        difficulty: "hard",
        points: 3
      }
    ],
    version: 1,
    total_points: 10,
    estimated_duration_minutes: 15,
    created_at: new Date("2024-01-25T10:00:00Z")
  },
  {
    _id: "mongo-assess-0000-0000-0000-000000000002",
    material_id: "m2000001-0000-0000-0000-000000000001",
    title: "Examen: Python Fundamentos",
    questions: [
      {
        id: "q-py-001",
        text: "¿Qué tipo de lenguaje es Python?",
        type: "multiple_choice",
        options: [
          "A) Interpretado y de alto nivel",
          "B) Compilado y de bajo nivel",
          "C) Solo orientado a objetos",
          "D) Lenguaje de marcado"
        ],
        answer: "A",
        feedback: "¡Correcto! Python es un lenguaje interpretado de alto nivel.",
        difficulty: "easy",
        points: 3
      },
      {
        id: "q-py-002",
        text: "¿Cuál es la salida de: print(type(5))?",
        type: "multiple_choice",
        options: [
          "A) <class 'str'>",
          "B) <class 'int'>",
          "C) <class 'float'>",
          "D) <class 'number'>"
        ],
        answer: "B",
        feedback: "¡Exacto! El número 5 es de tipo entero (int) en Python.",
        difficulty: "medium",
        points: 4
      },
      {
        id: "q-py-003",
        text: "¿Python requiere declarar el tipo de las variables?",
        type: "true_false",
        options: ["Verdadero", "Falso"],
        answer: "Falso",
        feedback: "¡Correcto! Python tiene tipado dinámico, no es necesario declarar el tipo de las variables.",
        difficulty: "easy",
        points: 3
      },
      {
        id: "q-py-004",
        text: "Escribe un programa en Python que imprima 'Hola Mundo' y explica cada línea de código.",
        type: "open_ended",
        answer: null,
        rubric: "Debe incluir: print('Hola Mundo') y explicar que print() es una función integrada que muestra texto en la consola. El texto debe estar entre comillas.",
        feedback: "Respuesta abierta para evaluación del instructor.",
        difficulty: "medium",
        points: 5
      }
    ],
    version: 1,
    total_points: 15,
    estimated_duration_minutes: 25,
    created_at: new Date("2024-01-20T14:00:00Z")
  },
  {
    _id: "mongo-assess-0000-0000-0000-000000000003",
    material_id: "m3000001-0000-0000-0000-000000000001",
    title: "Evaluación: Imperio Inca",
    questions: [
      {
        id: "q-inca-001",
        text: "¿Qué significa 'Tahuantinsuyo'?",
        type: "multiple_choice",
        options: [
          "A) Las cuatro regiones",
          "B) El gran imperio",
          "C) Tierra del Sol",
          "D) Reino de los Andes"
        ],
        answer: "A",
        feedback: "¡Correcto! Tahuantinsuyo significa 'las cuatro regiones' en quechua.",
        difficulty: "easy",
        points: 2
      },
      {
        id: "q-inca-002",
        text: "¿Quién era el Sapa Inca?",
        type: "multiple_choice",
        options: [
          "A) Un sacerdote inca",
          "B) El emperador inca, considerado hijo del Sol",
          "C) Un general del ejército",
          "D) El arquitecto principal"
        ],
        answer: "B",
        feedback: "¡Exacto! El Sapa Inca era el emperador y se le consideraba hijo del dios Sol.",
        difficulty: "easy",
        points: 2
      },
      {
        id: "q-inca-003",
        text: "¿Qué era un quipu?",
        type: "multiple_choice",
        options: [
          "A) Una herramienta agrícola",
          "B) Un instrumento musical",
          "C) Un sistema de cuerdas con nudos para registrar información",
          "D) Una construcción arquitectónica"
        ],
        answer: "C",
        feedback: "¡Correcto! Los quipus eran sistemas de cuerdas con nudos usados para llevar registros.",
        difficulty: "medium",
        points: 3
      },
      {
        id: "q-inca-004",
        text: "Explica la importancia del sistema de 'ayni' en la sociedad inca.",
        type: "open_ended",
        answer: null,
        rubric: "Debe explicar que el ayni era un sistema de reciprocidad y ayuda mutua fundamental en la organización social inca. Las familias se ayudaban entre sí en tareas agrícolas y de construcción, fortaleciendo los lazos comunitarios.",
        feedback: "Pregunta de desarrollo evaluada por el docente.",
        difficulty: "hard",
        points: 4
      }
    ],
    version: 1,
    total_points: 11,
    estimated_duration_minutes: 20,
    created_at: new Date("2024-01-28T11:30:00Z")
  }
]);

print("✓ Insertados 3 documentos en 'material_assessment'");

// =====================================================
// COLECCIÓN: material_event
// Logs de procesamiento
// =====================================================

db.material_event.insertMany([
  {
    _id: "event-0000-0000-0000-000000000001",
    material_id: "m1000001-0000-0000-0000-000000000001",
    event_type: "processing_started",
    worker_id: "worker-nlp-01",
    created_at: new Date("2024-01-22T10:00:00Z")
  },
  {
    _id: "event-0000-0000-0000-000000000002",
    material_id: "m1000001-0000-0000-0000-000000000001",
    event_type: "processing_completed",
    worker_id: "worker-nlp-01",
    duration_seconds: 45.3,
    metadata: {
      nlp_provider: "openai",
      model: "gpt-4",
      tokens_used: 1500
    },
    created_at: new Date("2024-01-22T10:00:45Z")
  },
  {
    _id: "event-0000-0000-0000-000000000003",
    material_id: "m2000001-0000-0000-0000-000000000001",
    event_type: "processing_started",
    worker_id: "worker-nlp-02",
    created_at: new Date("2024-01-16T14:00:00Z")
  },
  {
    _id: "event-0000-0000-0000-000000000004",
    material_id: "m2000001-0000-0000-0000-000000000001",
    event_type: "processing_completed",
    worker_id: "worker-nlp-02",
    duration_seconds: 52.7,
    metadata: {
      nlp_provider: "openai",
      model: "gpt-4",
      tokens_used: 2100
    },
    created_at: new Date("2024-01-16T14:00:53Z")
  },
  {
    _id: "event-0000-0000-0000-000000000005",
    material_id: "m2000001-0000-0000-0000-000000000001",
    event_type: "reprocessing_requested",
    worker_id: "worker-nlp-02",
    metadata: {
      reason: "Updated to version 2",
      nlp_provider: "openai",
      model: "gpt-4-turbo"
    },
    created_at: new Date("2024-02-10T09:00:00Z")
  },
  {
    _id: "event-0000-0000-0000-000000000006",
    material_id: "m3000001-0000-0000-0000-000000000001",
    event_type: "processing_started",
    worker_id: "worker-nlp-01",
    created_at: new Date("2024-01-29T16:30:00Z")
  },
  {
    _id: "event-0000-0000-0000-000000000007",
    material_id: "m3000001-0000-0000-0000-000000000001",
    event_type: "processing_completed",
    worker_id: "worker-nlp-01",
    duration_seconds: 38.9,
    metadata: {
      nlp_provider: "openai",
      model: "gpt-4",
      tokens_used: 1800
    },
    created_at: new Date("2024-01-29T16:30:39Z")
  },
  {
    _id: "event-0000-0000-0000-000000000008",
    material_id: "m1000004-0000-0000-0000-000000000004",
    event_type: "processing_started",
    worker_id: "worker-nlp-03",
    created_at: new Date()
  }
]);

print("✓ Insertados 8 documentos en 'material_event'");

// =====================================================
// COLECCIÓN: unit_social_feed (POST-MVP - Ejemplos)
// =====================================================

db.unit_social_feed.insertMany([
  {
    _id: "post-0000-0000-0000-000000000001",
    unit_id: "u1000004-0000-0000-0000-000000000004",
    author_id: "d0000001-0000-0000-0000-000000000001",
    post_type: "announcement",
    content: "Recordatorio: Mañana tendremos un quiz sobre fracciones. Por favor repasen el material.",
    attachments: [],
    likes_count: 5,
    comments: [
      {
        author_id: "e0000001-0000-0000-0000-000000000001",
        text: "Gracias por el recordatorio, profesora!",
        created_at: new Date("2024-02-12T15:30:00Z")
      },
      {
        author_id: "e0000002-0000-0000-0000-000000000002",
        text: "¿A qué hora será el quiz?",
        created_at: new Date("2024-02-12T15:35:00Z")
      }
    ],
    created_at: new Date("2024-02-12T15:00:00Z"),
    updated_at: new Date("2024-02-12T15:35:00Z")
  },
  {
    _id: "post-0000-0000-0000-000000000002",
    unit_id: "u2000002-0000-0000-0000-000000000002",
    author_id: "d0000003-0000-0000-0000-000000000003",
    post_type: "resource_share",
    content: "Les comparto este excelente tutorial de Python para complementar nuestras clases.",
    attachments: [
      {
        type: "link",
        url: "https://docs.python.org/es/3/tutorial/",
        thumbnail_url: ""
      }
    ],
    likes_count: 12,
    comments: [],
    created_at: new Date("2024-02-10T10:00:00Z"),
    updated_at: new Date("2024-02-10T10:00:00Z")
  },
  {
    _id: "post-0000-0000-0000-000000000003",
    unit_id: "u3000004-0000-0000-0000-000000000004",
    author_id: "e0000007-0000-0000-0000-000000000007",
    post_type: "question",
    content: "¿Alguien me puede ayudar con la programación del sensor ultrasónico en Arduino?",
    attachments: [],
    likes_count: 3,
    comments: [
      {
        author_id: "d0000005-0000-0000-0000-000000000005",
        text: "Claro, el viernes en el club lo revisamos juntos.",
        created_at: new Date("2024-02-11T17:15:00Z")
      },
      {
        author_id: "e0000008-0000-0000-0000-000000000008",
        text: "Yo también tengo esa duda!",
        created_at: new Date("2024-02-11T17:20:00Z")
      }
    ],
    created_at: new Date("2024-02-11T17:00:00Z"),
    updated_at: new Date("2024-02-11T17:20:00Z")
  }
]);

print("✓ Insertados 3 documentos en 'unit_social_feed' (POST-MVP)");

// =====================================================
// COLECCIÓN: user_graph_relation (POST-MVP - Ejemplos)
// =====================================================

db.user_graph_relation.insertMany([
  {
    _id: "relation-0000-0000-0000-000000000001",
    user_id: "e0000001-0000-0000-0000-000000000001",
    relation_type: "follows",
    related_user_id: "d0000001-0000-0000-0000-000000000001",
    metadata: {
      affinity_score: 0.85,
      common_interests: ["matemáticas", "geometría"]
    },
    created_at: new Date("2024-02-01T10:00:00Z")
  },
  {
    _id: "relation-0000-0000-0000-000000000002",
    user_id: "e0000005-0000-0000-0000-000000000005",
    relation_type: "follows",
    related_user_id: "d0000003-0000-0000-0000-000000000003",
    metadata: {
      affinity_score: 0.92,
      common_interests: ["programación", "python", "desarrollo web"]
    },
    created_at: new Date("2024-01-15T14:30:00Z")
  },
  {
    _id: "relation-0000-0000-0000-000000000003",
    user_id: "e0000007-0000-0000-0000-000000000007",
    relation_type: "follows",
    related_user_id: "e0000008-0000-0000-0000-000000000008",
    metadata: {
      affinity_score: 0.78,
      common_interests: ["robótica", "arduino", "electrónica"]
    },
    created_at: new Date("2024-02-05T16:00:00Z")
  }
]);

print("✓ Insertados 3 documentos en 'user_graph_relation' (POST-MVP)");

// =====================================================
// VERIFICACIÓN Y ESTADÍSTICAS
// =====================================================

print("\n=== RESUMEN DE DATOS INSERTADOS ===");
print("material_summary: " + db.material_summary.countDocuments() + " documentos");
print("material_assessment: " + db.material_assessment.countDocuments() + " documentos");
print("material_event: " + db.material_event.countDocuments() + " documentos");
print("unit_social_feed: " + db.unit_social_feed.countDocuments() + " documentos (POST-MVP)");
print("user_graph_relation: " + db.user_graph_relation.countDocuments() + " documentos (POST-MVP)");

print("\n=== VERIFICACIÓN DE ÍNDICES ===");
print("Índices en material_summary:");
db.material_summary.getIndexes().forEach(function(index) {
  print("  - " + JSON.stringify(index.key));
});

print("\n✓ Script de datos mock completado exitosamente");
