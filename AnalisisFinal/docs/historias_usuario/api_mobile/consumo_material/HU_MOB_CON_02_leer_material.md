# HU-MOB-CON-02: Leer Material y Resumen

## Historia de Usuario
**Como** estudiante
**Quiero** descargar y leer el PDF y su resumen generado
**Para** aprender el contenido del material educativo

## Flujo Principal
1. Estudiante selecciona material de la lista
2. App llama `GET /v1/materials/{id}`
3. API genera URL firmada de S3 para PDF (válida 15 min)
4. API obtiene mongo_document_id de resumen
5. API retorna: metadatos + pdf_url + has_summary
6. App descarga PDF desde S3 directamente
7. App abre lector PDF nativo por plataforma
8. Estudiante lee PDF, app registra progreso cada 30 seg:
   - `PATCH /v1/materials/{id}/progress {progress: 45, time_spent: 900}`
9. Si estudiante toca "Ver Resumen":
   - App llama `GET /v1/materials/{id}/summary`
   - API obtiene documento desde MongoDB
   - App muestra resumen con secciones colapsables, glosario, preguntas

## Criterios de Aceptación
- CA-1: URL firmada válida por 15 min
- CA-2: PDF de 5 MB descarga en < 15 seg
- CA-3: Progreso se guarda automáticamente (no requiere acción del usuario)
- CA-4: Resumen carga en < 1 seg
- CA-5: Si resumen no disponible, mostrar "Generando resumen..." con tiempo estimado

## Request/Response
```http
GET /v1/materials/uuid-1

Response 200 OK:
{
  "material": {
    "id": "uuid-1",
    "title": "Introducción a Pascal",
    "author_name": "Prof. García",
    "file_size": 2048576,
    "my_progress": 0
  },
  "pdf_url": "https://s3.../presigned-url?expires=...",
  "pdf_url_expires_at": "2025-01-29T11:15:00Z",
  "has_summary": true,
  "has_quiz": true
}
```

**Prioridad**: Alta (MVP)
**Estimación**: 8 puntos
