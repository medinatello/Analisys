# HU-MOB-EVA-01: Realizar Cuestionario

## Historia de Usuario
**Como** estudiante
**Quiero** realizar el cuestionario autogenerado de un material
**Para** evaluar mi comprensión y recibir retroalimentación inmediata

## Flujo Principal
1. Estudiante toca "Realizar Quiz" en detalle de material
2. App llama `GET /v1/materials/{id}/assessment`
3. API obtiene preguntas desde MongoDB **SIN respuestas correctas**
4. App muestra quiz con indicador "Pregunta 1 de 5"
5. Estudiante selecciona opciones para cada pregunta
6. Estudiante revisa respuestas y presiona "Enviar"
7. App confirma: "No podrás modificar tus respuestas"
8. App envía `POST /v1/materials/{id}/assessment/attempts` con respuestas
9. API obtiene preguntas CON respuestas correctas desde MongoDB
10. API valida cada respuesta y calcula puntaje
11. API persiste intento en `assessment_attempt` y respuestas en `assessment_attempt_answer`
12. API publica evento `assessment_attempt_recorded` (notificar docente)
13. API responde con puntaje y feedback detallado por pregunta
14. App muestra pantalla de resultados:
    - Puntaje: 80/100
    - Correctas: 4/5
    - Feedback por pregunta (correcta/incorrecta + mensaje educativo)
15. Estudiante puede reintentar quiz (si permitido)

## Criterios de Aceptación
- CA-1: Preguntas enviadas al cliente NO incluyen respuestas correctas
- CA-2: Validación de respuestas en servidor (nunca confiar en cliente)
- CA-3: Resultado disponible en < 2 seg
- CA-4: Feedback educativo específico por pregunta
- CA-5: Puntaje registrado permanentemente (inmutable)

## Request/Response
```http
POST /v1/materials/uuid-1/assessment/attempts
{
  "answers": [
    {"question_id": "q1", "selected_option": "a"},
    {"question_id": "q2", "selected_option": "c"}
  ],
  "time_spent_seconds": 720
}

Response 200 OK:
{
  "attempt_id": "uuid-attempt",
  "score": 80,
  "correct_answers": 4,
  "total_questions": 5,
  "passed": true,
  "feedback": [
    {
      "question_id": "q1",
      "is_correct": true,
      "message": "¡Correcto! Un compilador traduce..."
    },
    {
      "question_id": "q2",
      "is_correct": false,
      "correct_answer": "b",
      "message": "Incorrecto. Revisa la sección..."
    }
  ]
}
```

**Prioridad**: Alta (MVP)
**Estimación**: 8 puntos
