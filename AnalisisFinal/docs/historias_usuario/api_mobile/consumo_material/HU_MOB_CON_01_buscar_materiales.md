# HU-MOB-CON-01: Buscar y Explorar Materiales

## Historia de Usuario
**Como** estudiante
**Quiero** buscar y filtrar materiales educativos de mis unidades
**Para** encontrar rápidamente el contenido que necesito estudiar

## Actor Principal
**Estudiante** con membresía activa en al menos una unidad académica

## Flujo Principal
1. Estudiante abre sección "Materiales" en app
2. App llama `GET /v1/materials?unit_id={id}`
3. API consulta PostgreSQL: materiales + progreso del estudiante
4. API filtra solo materiales de unidades donde estudiante tiene membresía
5. API retorna lista con metadatos, estado de progreso, disponibilidad de resumen/quiz
6. App muestra materiales en cards con badges (nuevo, en progreso, completado)
7. Estudiante puede filtrar por:
   - Unidad académica (selector múltiple)
   - Materia (selector)
   - Estado (todos, nuevos, en progreso, completados)
8. Estudiante puede ordenar por:
   - Más recientes
   - Alfabético
   - Progreso

## Criterios de Aceptación
- CA-1: Lista carga en < 2 segundos
- CA-2: Filtros se aplican sin recargar página (local primero, luego API si cambia)
- CA-3: Cards muestran: título, materia, progreso (%), última actividad, badges
- CA-4: Si estudiante no tiene materiales, muestra mensaje amigable
- CA-5: Infinite scroll o paginación para > 20 materiales

## Request/Response Ejemplo
```http
GET /v1/materials?unit_id=uuid-5a&subject_id=uuid-prog&status=new
Authorization: Bearer {jwt}

Response 200 OK:
{
  "materials": [
    {
      "id": "uuid-1",
      "title": "Introducción a Pascal",
      "subject_name": "Programación",
      "unit_name": "5.º A - Programación",
      "status": "new",
      "progress": 0,
      "has_summary": true,
      "has_quiz": true,
      "published_at": "2025-01-15T12:00:00Z"
    }
  ],
  "total": 9,
  "page": 1
}
```

**Prioridad**: Alta (MVP)
**Estimación**: 5 puntos
