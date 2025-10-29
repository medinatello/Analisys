# PROC-WRK-RES-01: Generación de Resumen y Quiz con IA

## Descripción del Proceso
Worker consume evento `material_uploaded` de RabbitMQ, descarga PDF de S3, extrae texto, llama API de NLP (OpenAI GPT-4) para generar resumen y cuestionario, persiste en MongoDB y actualiza PostgreSQL.

## Flujo Detallado
1. **Consumer** escucha cola `material_processing_high` (FIFO, prioridad 10)
2. **Recibe evento**:
   ```json
   {
     "event_type": "material_uploaded",
     "material_id": "uuid",
     "s3_key": "school-1/unit-5/material-123/source/original.pdf",
     "author_id": "uuid",
     "preferred_language": "es"
   }
   ```
3. **Descarga PDF** desde S3 usando IAM credentials
4. **Extrae texto** con `pdftotext` (OCR con Tesseract si es escaneo)
5. **Valida contenido**: Mínimo 500 palabras útiles
6. **Construye prompt para resumen**:
   ```
   Genera un resumen educativo del siguiente material:
   [TEXTO]

   Formato JSON:
   {
     "sections": [{title, content, difficulty}],
     "glossary": [{term, definition}],
     "reflection_questions": [...]
   }

   Idioma: español
   Nivel: secundaria/preparatoria
   Secciones: 5-7
   Términos: 10-15
   Preguntas: 5-7
   ```
7. **Llama OpenAI GPT-4** (temperature 0.3, max_tokens 4000, timeout 60s)
8. **Parsea y valida respuesta** JSON
9. **Upsert en MongoDB** `material_summary`:
   ```javascript
   db.material_summary.updateOne(
     { material_id: "uuid" },
     { $set: {sections, glossary, reflection_questions, status: "completed", ...} },
     { upsert: true }
   )
   ```
10. **Genera quiz** con segundo prompt similar
11. **Upsert en MongoDB** `material_assessment`
12. **Actualiza PostgreSQL**:
    ```sql
    INSERT INTO material_summary_link (material_id, mongo_document_id, status)
    VALUES ($1, $2, 'completed')
    ON CONFLICT (material_id) DO UPDATE SET status = 'completed';

    INSERT INTO assessment (material_id, mongo_document_id, total_questions)
    VALUES ($1, $2, 5);
    ```
13. **Registra evento** en `material_event` (duración, tokens usados, costo estimado)
14. **Notifica docente** via email/push: "Material listo"
15. **ACK mensaje** RabbitMQ (confirma procesamiento exitoso)

## Manejo de Errores
| Error | Acción |
|-------|--------|
| PDF corrupto | No reintentar, notificar docente, ACK mensaje |
| Texto insuficiente | No reintentar, notificar docente, ACK mensaje |
| NLP timeout | Reintentar con backoff (1min, 5min, 15min, 1h, 6h) |
| NLP rate limit | Esperar tiempo indicado, reintentar |
| MongoDB caído | Reintentar indefinidamente con backoff |
| Tras 5 intentos | Enviar a Dead Letter Queue, alertar ops |

## Métricas de Éxito
- Tiempo promedio procesamiento: < 3 min
- Tasa de éxito: > 95%
- Costo promedio por material: < $0.20 USD
- Calidad resumen (manual): > 4/5

## Modelos de Eventos
```go
// Event payload
type MaterialUploadedEvent struct {
    EventType         string    `json:"event_type"`
    MaterialID        string    `json:"material_id"`
    AuthorID          string    `json:"author_id"`
    S3Key             string    `json:"s3_key"`
    PreferredLanguage string    `json:"preferred_language"`
    Timestamp         time.Time `json:"timestamp"`
}

// MongoDB Summary
type MaterialSummary struct {
    ID                   string               `bson:"_id"`
    MaterialID           string               `bson:"material_id"`
    Version              int                  `bson:"version"`
    Status               string               `bson:"status"`
    Sections             []Section            `bson:"sections"`
    Glossary             []GlossaryTerm       `bson:"glossary"`
    ReflectionQuestions  []string             `bson:"reflection_questions"`
    ProcessingMetadata   ProcessingMetadata   `bson:"processing_metadata"`
    CreatedAt            time.Time            `bson:"created_at"`
}
```

**Prioridad**: Crítica (MVP Core)
**Complejidad**: Alta
**Dependencias**: S3 Client, OpenAI API, MongoDB, PostgreSQL, RabbitMQ
