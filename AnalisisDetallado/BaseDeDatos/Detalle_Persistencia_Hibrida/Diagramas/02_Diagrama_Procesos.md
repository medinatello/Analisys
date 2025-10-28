# Diagrama de Procesos

[Volver a Diagramas](./README.md) · [Volver a Detalle de Persistencia Híbrida](../README.md)

```mermaid
flowchart TD
    A[Teacher uploads PDF] --> B[API validates metadata]
    B --> C{Is file valid?}
    C -- No --> C1[Reject and notify]
    C -- Yes --> D[API uploads object to S3]
    D --> E[Persist learning_material + material_unit_link]
    E --> F[Emit event material_uploaded]
    F --> G[Message queue]
    G --> H[NLP worker downloads PDF]
    H --> I[Generate summary & assessment]
    I --> J[Upsert documents in MongoDB]
    J --> K[Update material_summary_link & assessment]
    K --> L[Notify teacher]
    K --> M[Material available for students]

    subgraph StudentConsumption
        M --> N[KMP app requests material]
        N --> O[API fetches metadata from PostgreSQL]
        O --> P[App downloads PDF via signed URL]
        N --> Q{Summary exists?}
        Q -- Yes --> R[API returns summary from MongoDB]
        Q -- No --> S[API schedules regeneration]
        P --> T[App reports reading progress]
        T --> U[API stores reading_log]
        R --> V[Student completes assessment]
        V --> W[API records assessment_attempt (+ answers)]
    end
```

## Puntos de Control

- **Validaciones tempranas:** La API bloquea archivos que no cumplan con el tipo esperado, tamaño o permisos antes de escribir en S3.
- **Procesamiento asíncrono:** Los workers operan sobre eventos `material_uploaded` y `material_reprocess`, asegurando que la API permanezca ligera.
- **Actualizaciones incrementales:** `material_summary_link` y `assessment` incorporan la referencia a MongoDB una vez concluido el procesamiento.
- **Feedback oportuno:** Notificaciones a docentes ante éxito o fallo permiten intervenir rápidamente.
- **Trazabilidad estudiantil:** `reading_log` y `assessment_attempt` capturan progreso y resultados en la base relacional.
