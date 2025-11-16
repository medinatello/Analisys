# spec-02-worker - Worker de Procesamiento IA

**Estado:** ✅ DOCUMENTACIÓN COMPLETADA (100%)  
**Repositorio:** edugo-worker  
**Prioridad:** 🟡 P1 - HIGH  
**Versión:** 1.0.0  
**Fecha:** 14 de Noviembre, 2025

---

## ⚠️ IMPORTANTE: ESTADO ACTUAL

Esta especificación es **DOCUMENTACIÓN DE DISEÑO** para la implementación futura del worker de procesamiento IA.

**Estado de Implementación:** ⬜ PENDIENTE (0%)

La documentación está completa y lista para iniciar implementación cuando se priorice este proyecto.

---

## 📋 Descripción

Worker de procesamiento asíncrono que consume eventos de RabbitMQ, procesa materiales educativos con OpenAI, genera resúmenes y cuestionarios, y persiste resultados en MongoDB.

### Funcionalidades Clave
- ✅ Consumir eventos `material.uploaded` de RabbitMQ
- ✅ Descargar materiales desde S3/MinIO
- ✅ Generar resúmenes con OpenAI GPT-4
- ✅ Generar cuestionarios (5 preguntas) con OpenAI
- ✅ Persistir en MongoDB
- ✅ Publicar eventos `assessment.generated`
- ✅ Dead Letter Queue para errores
- ✅ Retry con backoff exponencial

---

## 🏗️ Arquitectura

### Stack Tecnológico
- **Backend:** Go 1.21+
- **Arquitectura:** Event-Driven Consumer
- **Mensajería:** RabbitMQ 3.12+ con DLQ
- **IA:** OpenAI API (GPT-4)
- **Storage:** S3/MinIO
- **Base de Datos:** MongoDB 7.0+
- **Testing:** shared/testing v0.6.2+ con testcontainers

### Dependencias Actuales

**Shared v0.7.0 (FROZEN):**
```go
require (
    github.com/EduGoGroup/edugo-shared/config v0.7.0
    github.com/EduGoGroup/edugo-shared/logger v0.7.0
    github.com/EduGoGroup/edugo-shared/common v0.7.0
    github.com/EduGoGroup/edugo-shared/database/mongodb v0.7.0
    github.com/EduGoGroup/edugo-shared/messaging/rabbit v0.7.0  // ⭐ Con DLQ
    github.com/EduGoGroup/edugo-shared/evaluation v0.7.0        // ⭐ Nuevo módulo
    github.com/EduGoGroup/edugo-shared/testing v0.7.0
)
```

**Infrastructure v0.1.1:**
```go
require (
    github.com/EduGoGroup/edugo-infrastructure/schemas v0.1.1  // Validación eventos
)
```

**Nota:** shared v0.7.0 está CONGELADO hasta post-MVP. Solo se permiten bug fixes críticos (v0.7.1, v0.7.2).

---

## 🔄 Flujo de Procesamiento

```mermaid
sequenceDiagram
    participant API as api-mobile/admin
    participant RMQ as RabbitMQ
    participant Worker as edugo-worker
    participant S3 as S3/MinIO
    participant OpenAI as OpenAI API
    participant Mongo as MongoDB
    participant DLQ as Dead Letter Queue

    API->>RMQ: Publish material.uploaded
    RMQ->>Worker: Consume event
    
    Worker->>S3: Download material
    S3-->>Worker: Material content
    
    Worker->>OpenAI: Generate summary (GPT-4)
    OpenAI-->>Worker: Summary
    
    Worker->>OpenAI: Generate quiz (GPT-4)
    OpenAI-->>Worker: 5 questions
    
    Worker->>Mongo: Save summary + quiz
    Mongo-->>Worker: Success
    
    Worker->>RMQ: Publish assessment.generated
    
    alt Error en procesamiento
        Worker->>Worker: Retry 3x con backoff
        Worker->>DLQ: Move to DLQ si falla
    end
```

---

## 💰 Costos y SLA de OpenAI

### Modelo Utilizado
**GPT-4 Turbo (gpt-4-turbo-preview)**

### Pricing (Actualizado Nov 2025)
| Operación | Tokens | Costo/1K tokens | Costo unitario |
|-----------|--------|-----------------|----------------|
| **Resumen (input)** | ~2,000 | $0.01 | $0.02 |
| **Resumen (output)** | ~500 | $0.03 | $0.015 |
| **Quiz (input)** | ~1,000 | $0.01 | $0.01 |
| **Quiz (output)** | ~800 | $0.03 | $0.024 |
| **Total por material** | ~4,300 | - | **$0.069** |

**Estimación Mensual:**
- 1,000 materiales/mes = **$69/mes**
- 10,000 materiales/mes = **$690/mes**

### SLA de OpenAI

#### Límites de Rate (Tier 1 - Free)
- **Requests:** 500 RPM (requests per minute)
- **Tokens:** 200,000 TPM (tokens per minute)
- **Daily:** 10,000 requests/day

#### Latencia Esperada
| Operación | p50 | p95 | p99 |
|-----------|-----|-----|-----|
| Generate Summary | 3s | 8s | 15s |
| Generate Quiz | 4s | 10s | 18s |
| **Total** | 7s | 18s | 33s |

#### Disponibilidad
- **SLA oficial:** 99.9% uptime
- **Error rate esperado:** <0.1%

### Estrategia de Mitigación

**1. Retry con Backoff Exponencial**
```go
maxRetries := 3
backoff := 1 * time.Second

for i := 0; i < maxRetries; i++ {
    result, err := callOpenAI(prompt)
    if err == nil {
        return result
    }
    
    if isRateLimitError(err) {
        time.Sleep(backoff)
        backoff *= 2
        continue
    }
    
    return err
}
```

**2. Dead Letter Queue**
- Usar `shared/messaging/rabbit` con DLQ
- Mensajes fallidos → `worker.dlq` queue
- Monitoreo de DLQ con alertas

**3. Circuit Breaker (Post-MVP)**
- Abrir circuito si >10% errores
- Reintentar cada 60s
- Evitar sobrecarga de OpenAI

---

## 📦 Módulo shared/messaging/rabbit con DLQ

### Feature en v0.7.0

**Configuración DLQ:**
```go
import "github.com/EduGoGroup/edugo-shared/messaging/rabbit"

config := rabbit.Config{
    URL:         "amqp://guest:guest@localhost:5672/",
    Queue:       "worker.materials",
    DLQEnabled:  true,
    MaxRetries:  3,
}

consumer, err := rabbit.NewConsumer(config)
```

**Flujo Automático:**
1. Mensaje falla → retry interno (3x)
2. Si falla 3x → mueve a `worker.materials.dlq`
3. Worker puede consumir DLQ para reprocesar

**Ventajas:**
- No perder mensajes
- Visibilidad de errores
- Reprocesamiento manual posible

---

## 🗂️ Estructura del Proyecto

```
edugo-worker/
├── cmd/
│   └── worker/
│       └── main.go                     # Entry point
│
├── internal/
│   ├── domain/                         # Dominio
│   │   ├── entities/
│   │   │   ├── material.go
│   │   │   ├── summary.go
│   │   │   └── assessment.go
│   │   └── repositories/
│   │       ├── material_repository.go
│   │       └── assessment_repository.go
│   │
│   ├── application/                    # Services
│   │   ├── services/
│   │   │   ├── openai_service.go       # Llamadas a OpenAI
│   │   │   ├── summary_service.go
│   │   │   └── assessment_service.go
│   │   └── handlers/
│   │       └── material_handler.go     # Procesa eventos RabbitMQ
│   │
│   └── infrastructure/                 # Implementaciones
│       ├── persistence/
│       │   └── mongodb/
│       │       ├── material_repo.go
│       │       └── assessment_repo.go
│       │
│       ├── messaging/
│       │   ├── consumer.go             # RabbitMQ consumer
│       │   └── publisher.go            # RabbitMQ publisher
│       │
│       └── storage/
│           └── s3_client.go            # S3/MinIO client
│
└── tests/
    ├── unit/
    └── integration/
```

---

## 📚 Documentación Completa

### 01-Requirements (4 archivos)
- **[PRD.md](01-Requirements/PRD.md)** - Product Requirements Document
- **[FUNCTIONAL_SPECS.md](01-Requirements/FUNCTIONAL_SPECS.md)** - Especificación funcional
- **[TECHNICAL_SPECS.md](01-Requirements/TECHNICAL_SPECS.md)** - Stack tecnológico
- **[ACCEPTANCE_CRITERIA.md](01-Requirements/ACCEPTANCE_CRITERIA.md)** - Criterios de aceptación

### 02-Design (4 archivos)
- **[ARCHITECTURE.md](02-Design/ARCHITECTURE.md)** - Arquitectura Event-Driven
- **[DATA_MODEL.md](02-Design/DATA_MODEL.md)** - Schema MongoDB
- **[MESSAGE_CONTRACTS.md](02-Design/MESSAGE_CONTRACTS.md)** - Contratos de eventos
- **[INTEGRATION_DESIGN.md](02-Design/INTEGRATION_DESIGN.md)** - OpenAI, S3, RabbitMQ

### 03-Sprints (6 sprints × 5 archivos = 30 archivos)
Cada sprint contiene:
- README.md - Resumen del sprint
- TASKS.md - Tareas detalladas con código exacto
- DEPENDENCIES.md - Dependencias técnicas
- QUESTIONS.md - Decisiones de diseño
- VALIDATION.md - Checklist de validación

**Sprints:**
1. **Sprint-01-Schema-MongoDB** - Colecciones y schemas
2. **Sprint-02-Dominio** - Entities, Repositories
3. **Sprint-03-RabbitMQ** - Consumer, Publisher, DLQ
4. **Sprint-04-OpenAI** - Integration con GPT-4
5. **Sprint-05-Testing** - Suite de tests
6. **Sprint-06-CI-CD** - GitHub Actions

### 04-Testing (3 archivos)
- **[TEST_STRATEGY.md](04-Testing/TEST_STRATEGY.md)** - Estrategia de testing
- **[TEST_CASES.md](04-Testing/TEST_CASES.md)** - Casos de prueba
- **[COVERAGE_REPORT.md](04-Testing/COVERAGE_REPORT.md)** - Reporte de coverage

### 05-Deployment (3 archivos)
- **[DEPLOYMENT_GUIDE.md](05-Deployment/DEPLOYMENT_GUIDE.md)** - Guía de despliegue
- **[INFRASTRUCTURE.md](05-Deployment/INFRASTRUCTURE.md)** - Infraestructura
- **[MONITORING.md](05-Deployment/MONITORING.md)** - Observabilidad

---

## 🔗 Integración con Infrastructure

### Validación de Eventos

```go
import "github.com/EduGoGroup/edugo-infrastructure/schemas"

// Validar evento recibido
err := schemas.ValidateEvent("material.uploaded", eventData)
if err != nil {
    logger.Error("Invalid event", zap.Error(err))
    return err
}

// Validar evento antes de publicar
err = schemas.ValidateEvent("assessment.generated", responseEvent)
if err != nil {
    logger.Error("Invalid response event", zap.Error(err))
    return err
}
```

**Schemas disponibles:**
- `material.uploaded.json` - Evento de material subido
- `assessment.generated.json` - Evento de assessment generado
- `material.processed.json` - Evento de procesamiento completo

---

## 📊 Métricas del Proyecto

### Documentación
- **Archivos totales:** 46
- **Completitud:** 100%
- **Palabras:** ~80,000
- **Sprints:** 6

### Estado de Implementación
- **Código:** 0% (pendiente)
- **Tests:** 0% (pendiente)
- **CI/CD:** 0% (pendiente)

---

## 🎯 Próximos Pasos (Cuando se Priorice)

1. **Preparación:**
   - Actualizar go.mod con shared v0.7.0
   - Integrar infrastructure v0.1.1
   - Obtener API Key de OpenAI

2. **Sprint 1:** Schema MongoDB (2 días)
   - Crear colecciones
   - Definir índices

3. **Sprint 2:** Dominio (3 días)
   - Entities y repositorios
   - Usar shared/evaluation

4. **Sprint 3:** RabbitMQ (4 días)
   - Consumer con DLQ
   - Publisher de eventos

5. **Sprint 4:** OpenAI (5 días)
   - Integration con GPT-4
   - Manejo de costos y rate limits

6. **Sprint 5-6:** Testing + CI/CD

---

## ⚠️ Consideraciones Importantes

### Costos OpenAI
- Monitorear uso diario
- Establecer límites de gasto
- Alertas si excede presupuesto

### Performance
- Procesamiento asíncrono (no bloquear)
- Timeout por material: 60s
- Throughput objetivo: 100 materiales/hora

### Resiliencia
- DLQ para mensajes fallidos
- Retry con backoff
- Circuit breaker para OpenAI
- Logs detallados de errores

### Testing
- Mocks de OpenAI para tests
- Tests de integración con testcontainers
- Coverage mínimo: 70%

---

## 📞 Recursos

- **Repositorio:** https://github.com/EduGoGroup/edugo-worker
- **Shared:** https://github.com/EduGoGroup/edugo-shared (v0.7.0 FROZEN)
- **Infrastructure:** https://github.com/EduGoGroup/edugo-infrastructure (v0.1.1)
- **OpenAI Docs:** https://platform.openai.com/docs
- **Plan:** /Analisys/docs/roadmap/PLAN_IMPLEMENTACION.md

---

**Generado con:** Claude Code  
**Última actualización:** 16 de Noviembre, 2025  
**Estado:** Documentación completa, implementación pendiente
