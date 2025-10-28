# Diagrama de Arquitectura

[Volver a Diagramas](./README.md) · [Volver a Detalle de Persistencia Híbrida](../README.md)

```mermaid
graph LR
    subgraph Clients
        APP[EduGo KMP App]
        ADMIN[Admin Web Panel]
    end

    subgraph API_Go["EduGo API (Go)"]
        REST[REST/GraphQL Controllers]
        AUTH[Authentication Service]
        MATERIAL[Learning Material Service]
        ASSESS[Assessment Service]
    end

    subgraph Persistence
        PG[(PostgreSQL)]
        MONGO[(MongoDB Atlas)]
        S3[(S3 / MinIO)]
        REDIS[(Redis Cache)]
    end

    subgraph Async["Asynchronous Processing"]
        QUEUE[[Message Queue]]
        WORKERS[Workers (NLP, orchestration)]
    end

    subgraph External
        NLP_API[[NLP Provider]]
        NOTIFY[[Notification Service]]
    end

    APP -->|HTTPS| REST
    ADMIN -->|HTTPS| REST
    REST --> AUTH
    REST --> MATERIAL
    REST --> ASSESS

    AUTH --> PG
    MATERIAL --> PG
    MATERIAL --> S3
    MATERIAL --> QUEUE
    MATERIAL --> REDIS
    ASSESS --> PG
    ASSESS --> MONGO

    WORKERS --> S3
    WORKERS --> MONGO
    WORKERS --> PG
    WORKERS --> NLP_API

    QUEUE --> WORKERS
    REST --> REDIS
    API_Go --> NOTIFY
```

## Capas y Responsabilidades

- **Clientes (KMP / Admin):** Consumidores de la API mediante OAuth 2.0 + JWT. La app KMP utiliza URLs firmadas para descargas desde S3.
- **API Go:** Arquitectura hexagonal donde controladores delegan la lógica a servicios de dominio. Cada servicio interactúa con adaptadores específicos (PostgreSQL, MongoDB, S3, cola).
- **Persistencia:** PostgreSQL aloja datos relacionales (`app_user`, `academic_unit`, `learning_material`, etc.); MongoDB conserva documentos flexibles; S3 almacena binarios; Redis soporta caché de sesiones, resúmenes y rate limiting.
- **Procesamiento asíncrono:** Workers especializados ejecutan tareas intensivas (NLP, reprocesos, notificaciones) desencadenadas por eventos.
- **Integraciones externas:** Proveedores de NLP y notificaciones se encapsulan para poder ser sustituidos sin impacto en la API.
