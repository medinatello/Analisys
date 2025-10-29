# Arquitectura Completa de EduGo

## Diagrama General

```mermaid
graph TB
    subgraph "Clientes"
        KMP[App KMP<br/>Android/iOS/Desktop]
        ADMIN[Panel Admin Web]
    end

    subgraph "APIs Go"
        API_MOB[API Mobile :8080<br/>9 Endpoints]
        API_ADM[API Admin :8081<br/>11 Endpoints]
    end

    subgraph "Procesamiento"
        QUEUE[RabbitMQ<br/>3 Colas Priorizadas]
        WORKER[Worker Go<br/>5 Eventos]
    end

    subgraph "Persistencia"
        PG[(PostgreSQL<br/>17 Tablas)]
        MONGO[(MongoDB<br/>3 Colecciones)]
        S3[S3/MinIO<br/>PDFs]
    end

    subgraph "Externos"
        NLP[OpenAI GPT-4]
        NOTIF[Email/Push]
    end

    KMP --> API_MOB
    ADMIN --> API_ADM
    
    API_MOB --> PG
    API_MOB --> MONGO
    API_MOB --> S3
    API_MOB -.-> QUEUE
    
    API_ADM --> PG
    API_ADM -.-> QUEUE
    
    QUEUE --> WORKER
    WORKER --> S3
    WORKER --> NLP
    WORKER --> MONGO
    WORKER --> PG
    WORKER --> NOTIF
```

## Decisiones Clave

**PostgreSQL**: Usuarios, jerarquía, materiales (metadata), progreso
**MongoDB**: Resúmenes IA, quizzes, eventos  
**S3**: PDFs y archivos binarios
**RabbitMQ**: Eventos asíncronos con reintentos
**OpenAI**: Generación de contenido educativo

**Separación de APIs**:
- Mobile (8080): Alta frecuencia, uso diario
- Admin (8081): Baja frecuencia, CRUD maestro

Ver archivo [DISTRIBUCION_PROCESOS.md](../../DISTRIBUCION_PROCESOS.md) para detalles.
