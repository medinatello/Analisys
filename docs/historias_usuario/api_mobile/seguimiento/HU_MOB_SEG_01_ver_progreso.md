# HU-MOB-SEG-01: Ver Progreso de Estudiantes

## Historia de Usuario
**Como** docente
**Quiero** ver el progreso de mis estudiantes en un material
**Para** identificar quiénes necesitan ayuda y evaluar la efectividad del contenido

## Flujo Principal
1. Docente selecciona material de "Mis Materiales"
2. Docente toca "Ver Estadísticas"
3. App llama `GET /v1/materials/{id}/stats`
4. API valida que docente es autor O docente de alguna unidad asignada
5. API ejecuta query complejo PostgreSQL:
   - Lista todos los estudiantes de las unidades
   - Obtiene progreso de lectura (`reading_log`)
   - Obtiene mejor intento de quiz (`assessment_attempt`)
   - Calcula agregados (promedio, completados, pendientes)
6. API retorna estadísticas completas
7. App muestra dashboard con:
   - Cards de métricas clave (80% iniciaron, 32% completaron, promedio 75.5)
   - Tabla de estudiantes: nombre, progreso, puntaje, última actividad
8. Docente puede:
   - Filtrar por unidad o estado
   - Ordenar por cualquier columna
   - Ver detalle de un estudiante (progreso completo + historial de intentos)
   - Exportar a CSV (Post-MVP)

## Criterios de Aceptación
- CA-1: Query completa en < 3 seg para hasta 100 estudiantes
- CA-2: Tabla permite ordenar y filtrar sin recargar
- CA-3: Si no hay actividad aún, mostrar mensaje claro
- CA-4: Métricas actualizadas en tiempo real (al refrescar)
- CA-5: Identificar estudiantes en riesgo (progreso 0 tras 7 días)

## Request/Response
```http
GET /v1/materials/uuid-1/stats

Response 200 OK:
{
  "material": {"id": "uuid-1", "title": "Introducción a Pascal"},
  "summary": {
    "total_students": 25,
    "not_started": 5,
    "in_progress": 12,
    "completed": 8,
    "average_progress": 62.4,
    "average_score": 75.5,
    "completion_rate": 32.0
  },
  "students": [
    {
      "id": "uuid-st1",
      "name": "Ana García",
      "progress": 100,
      "latest_score": 95,
      "last_access": "2025-01-28T15:30:00Z",
      "status": "completed"
    }
  ]
}
```

**Prioridad**: Media (MVP)
**Estimación**: 8 puntos
