# Diagrama de Procesos Clave

[Volver a Diagramas](./README.md) · [Volver a Detalle del Enfoque Híbrido](../README.md)

```mermaid
flowchart TD
    A[Docente sube PDF] --> B[API valida metadatos]
    B --> C{Archivo válido?}
    C -- No --> C1[Rechazar y notificar]
    C -- Sí --> D[API sube archivo a S3]
    D --> E[API persiste MATERIAL en SQL]
    E --> F[Publica evento material_subido]
    F --> G[Cola de procesamiento]
    G --> H[Worker NLP descarga PDF]
    H --> I[Genera resumen y cuestionario]
    I --> J[Guarda documentos en MongoDB]
    J --> K[Actualiza enlaces en SQL]
    K --> L[Notifica a docente]
    K --> M[Disponible para alumnos]

    subgraph Consumo Alumno
        M --> N[App KMP consulta API]
        N --> O[API retorna metadatos SQL]
        O --> P[App descarga PDF desde S3]
        N --> Q{Hay resumen?}
        Q -- Sí --> R[API entrega resumen desde MongoDB]
        Q -- No --> S[API agenda generación on-demand]
        P --> T[App registra progreso]
        T --> U[API guarda REGISTRO_LECTURA]
        R --> V[Alumno resuelve cuestionario]
        V --> W[API registra intento en SQL/Mongo]
    end
```

## Puntos de Control

- **Validaciones tempranas:** La API bloquea archivos sin metadatos completos y escribe en S3 solamente tras validar tamaño, tipo MIME y permisos.
- **Procesamiento asíncrono desacoplado:** Los workers consumen de la cola `material_subido`, evitando saturar la API y permitiendo escalado horizontal.
- **Actualización incremental:** Una vez generado un resumen, se mantiene en MongoDB; regeneraciones futuras usan banderas en SQL (`MATERIAL.estado`).
- **Feedback inmediato:** Notificaciones al docente (email/webhook) tras finalizar cada etapa ayudan a detectar fallos tempranos.
- **Trazabilidad estudiantil:** `REGISTRO_LECTURA` e `INTENTO_CUESTIONARIO` permiten seguimiento del aprendizaje y auditoría.
