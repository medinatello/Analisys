# 🏗️ Arquitectura del Ecosistema EduGo

**Fecha:** 16 de Noviembre, 2025  
**Versión:** 2.0.0

---

## 🎯 Visión Arquitectónica

EduGo sigue una arquitectura de **microservicios con base de datos compartida**, optimizada para una plataforma educativa escalable.

**Principios:**
- Separación de concerns por audiencia (admin vs mobile)
- Event-driven para procesamiento asíncrono
- Clean Architecture en cada servicio
- Shared library para código común

---

## 📐 Diagrama de Alto Nivel

```
┌─────────────────────────────────────────────────────────────┐
│                     Capa de Presentación                     │
├──────────────────────────┬──────────────────────────────────┤
│   Admin Web (React)      │   Mobile App (React Native)      │
│   Puerto: 3001           │   Puerto: 3000                   │
└──────────┬───────────────┴──────────────┬───────────────────┘
           │ HTTPS/JSON                   │ HTTPS/JSON
           │                              │
┌──────────▼───────────────┐   ┌─────────▼──────────────────┐
│   api-administracion     │   │      api-mobile            │
│   Puerto: 8081           │   │      Puerto: 8080          │
│   Go + Gin + GORM        │   │      Go + Gin + GORM       │
│   Clean Architecture     │   │      Clean Architecture    │
└──────────┬───────────────┘   └─────────┬──────────────────┘
           │                              │
           │  RabbitMQ Events             │
           │  ┌───────────────────────┐   │
           └──► edugo.topic (Exchange)◄───┘
              └───────────┬───────────┘
                          │
                   ┌──────▼──────┐
                   │   worker    │
                   │   Go + IA   │
                   └──────┬──────┘
                          │
       ┌──────────────────┼──────────────────┐
       │                  │                  │
┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
│ PostgreSQL  │   │  MongoDB    │   │  RabbitMQ   │
│   (15)      │   │   (7.0)     │   │   (3.12)    │
└─────────────┘   └─────────────┘   └─────────────┘
       │                  │
┌──────▼──────────────────▼──────┐
│    infrastructure (v0.1.1)     │
│  - Migraciones                 │
│  - Schemas de eventos          │
│  - Docker Compose              │
└────────────────────────────────┘
       │
┌──────▼──────────────────────┐
│   shared (v0.7.0 FROZEN)    │
│  - auth, logger, config     │
│  - database, messaging      │
│  - evaluation               │
└─────────────────────────────┘
```

---

## 🏛️ Arquitectura por Capas

### Capa 1: Presentación
- **Admin Web:** React (para administradores)
- **Mobile App:** React Native (para docentes/estudiantes)

### Capa 2: APIs
- **api-administracion:** Gestión académica
- **api-mobile:** Features de estudiantes/docentes

### Capa 3: Procesamiento Asíncrono
- **worker:** Procesamiento de PDFs con IA

### Capa 4: Infraestructura
- **infrastructure:** Migraciones, schemas, docker
- **shared:** Biblioteca compartida

### Capa 5: Datos
- **PostgreSQL:** Datos relacionales
- **MongoDB:** Documentos de IA
- **RabbitMQ:** Mensajería asíncrona

---

## 🔧 Clean Architecture en APIs

### Estructura Estándar

```
cmd/api/
  └─ main.go                    # Entry point

internal/
  ├─ domain/                    # Capa de Dominio
  │   ├─ entities/              # Entities (School, Material, etc.)
  │   ├─ value_objects/         # Value Objects (Email, Slug, etc.)
  │   └─ repositories/          # Interfaces de repositorios
  │
  ├─ application/               # Capa de Aplicación
  │   ├─ use_cases/             # Use Cases (CreateSchool, etc.)
  │   ├─ services/              # Services (AuthService, etc.)
  │   └─ dtos/                  # DTOs (Data Transfer Objects)
  │
  └─ infrastructure/            # Capa de Infraestructura
      ├─ http/                  # HTTP Handlers (Gin)
      ├─ persistence/           # Repositorios (PostgreSQL, MongoDB)
      ├─ messaging/             # Publishers/Consumers (RabbitMQ)
      └─ config/                # Configuración

tests/
  ├─ unit/                      # Tests unitarios
  └─ integration/               # Tests de integración
```

### Flujo de Dependencias

```
HTTP Request
    ↓
Handler (infrastructure/http)
    ↓
Use Case (application/use_cases)
    ↓
Service (application/services)
    ↓
Repository Interface (domain/repositories)
    ↓
Repository Implementation (infrastructure/persistence)
    ↓
Database (PostgreSQL/MongoDB)
```

**Reglas:**
1. Domain NO depende de nada
2. Application depende de Domain
3. Infrastructure depende de Domain y Application
4. Comunicación via interfaces

---

## 📦 Módulos de shared v0.7.0

### Módulos Disponibles

| Módulo | Versión | Propósito | Usado por |
|--------|---------|-----------|-----------|
| **auth** | v0.7.0 | JWT, roles, refresh tokens | api-admin, api-mobile |
| **logger** | v0.7.0 | Logging estructurado (Zap) | Todos |
| **common** | v0.7.0 | Errors, types, validator | Todos |
| **config** | v0.7.0 | Multi-environment config | Todos |
| **bootstrap** | v0.7.0 | App initialization | api-admin, api-mobile |
| **lifecycle** | v0.7.0 | Graceful shutdown | api-admin, api-mobile, worker |
| **middleware/gin** | v0.7.0 | JWT, logging, CORS | api-admin, api-mobile |
| **messaging/rabbit** | v0.7.0 | Publisher, consumer, DLQ | api-mobile, worker |
| **database/postgres** | v0.7.0 | GORM utilities | api-admin, api-mobile |
| **database/mongodb** | v0.7.0 | MongoDB client | api-mobile, worker |
| **testing** | v0.7.0 | Testcontainers | Todos (tests) |
| **evaluation** | v0.7.0 | Assessment models | api-mobile, worker |

### Ejemplo de Uso

```go
// En api-mobile
import (
    "github.com/EduGoGroup/edugo-shared/auth"
    "github.com/EduGoGroup/edugo-shared/logger"
    "github.com/EduGoGroup/edugo-shared/database/postgres"
    "github.com/EduGoGroup/edugo-shared/messaging/rabbit"
    "github.com/EduGoGroup/edugo-shared/evaluation"
)

func main() {
    // Logger
    log := logger.New(logger.Config{Level: "info"})

    // Auth
    jwtManager := auth.NewJWTManager(secretKey, 15*time.Minute)

    // Database
    db := postgres.Connect(dbConfig)

    // Messaging
    publisher := rabbit.NewPublisher(rabbitConfig)

    // Evaluation models
    assessment := evaluation.Assessment{...}
}
```

---

## 🗄️ Patrón de Datos: Hybrid Database

### PostgreSQL (Relacional)

**Uso:** Datos estructurados y transaccionales

**Tablas:**
- users, schools, academic_units, memberships (api-admin)
- materials, assessment, assessment_attempt, assessment_answer (api-mobile)

**Ventajas:**
- Integridad referencial
- Transacciones ACID
- Queries complejas con JOINs

### MongoDB (Documentos)

**Uso:** Contenido generado por IA (flexible)

**Colecciones:**
- material_summary (resúmenes de IA)
- material_assessment (quizzes de IA)
- material_event (logs de procesamiento)

**Ventajas:**
- Schema flexible
- Documentos complejos (arrays de preguntas)
- Escalabilidad horizontal

### Sincronización

**Patrón:** MongoDB primero + Eventual Consistency

```
1. worker → MongoDB (fuente de verdad del contenido)
2. worker → RabbitMQ (evento con mongo_id)
3. api-mobile → PostgreSQL (índice con referencia)
```

**Manejo de inconsistencias:**
- DLQ captura fallos
- API valida existencia en MongoDB
- Eventual consistency aceptable (delay de segundos)

---

## 📨 Event-Driven Architecture

### RabbitMQ Configuration

**Exchange:** edugo.topic (tipo: topic)

**Routing Keys:**
- `material.uploaded`
- `assessment.generated`
- `material.deleted`
- `student.enrolled`

**Dead Letter Queue:**
- Exchange DLX: `dlx`
- Queue: `{original}.dlq`
- Retry: 3x con exponential backoff

### Flujo de Eventos

```
api-mobile (publisher)
    ↓ [material.uploaded]
RabbitMQ (edugo.topic)
    ↓ [routing key]
worker (consumer)
    ↓ [procesa con OpenAI]
MongoDB (guarda resultado)
    ↓ [assessment.generated]
RabbitMQ (edugo.topic)
    ↓ [routing key]
api-mobile (consumer)
    ↓ [actualiza PostgreSQL]
PostgreSQL (referencia a MongoDB)
```

---

## 🔐 Seguridad

### Autenticación

**Método:** JWT con refresh tokens (shared/auth v0.7.0)

**Flow:**
```
1. Usuario login → api-admin o api-mobile
2. Validar credenciales → PostgreSQL
3. Generar tokens:
   - Access token (15 min)
   - Refresh token (7 días)
4. Retornar tokens
5. Cliente guarda en localStorage/SecureStorage
6. Cada request: Header Authorization: Bearer {access_token}
7. Access token expira → Usar refresh token
8. Renovar access token → Continuar sin re-login
```

### Autorización

**Roles:**
- `admin`: Acceso total (api-admin)
- `teacher`: Subir materiales, ver su contenido (api-mobile)
- `student`: Ver materiales, tomar quizzes (api-mobile)

**Validación:**
```go
// Middleware
if role != "teacher" && role != "admin" {
    return errors.Forbidden
}

// A nivel de datos
if material.TeacherID != userID && role != "admin" {
    return errors.Forbidden
}
```

### Secrets Management

**Herramienta:** SOPS + Age

**Archivos:**
- `.env.local` (sin encriptar, gitignored)
- `.env.dev.enc` (encriptado)
- `.env.qa.enc` (encriptado)
- `.env.prod.enc` (encriptado)

**Uso:**
```bash
# Encriptar
sops -e .env.dev > .env.dev.enc

# Desencriptar
sops -d .env.dev.enc > .env.dev
```

---

## 🧪 Testing Strategy

### Pirámide de Tests

```
        ▲
       ╱E2E╲         5% - End-to-End (pocos, críticos)
      ╱─────╲
     ╱Integ.╲       15% - Integración (APIs + DB + RabbitMQ)
    ╱────────╲
   ╱  Unit    ╲     80% - Unitarios (rápidos, muchos)
  ╱────────────╲
```

### Tests Unitarios

**Objetivo:** 80% coverage

**Herramientas:**
- `go test`
- `testify/assert`
- `testify/mock`

**Ejemplo:**
```go
func TestCreateSchool(t *testing.T) {
    repo := new(MockSchoolRepository)
    service := NewSchoolService(repo)

    school := &School{Name: "Test School"}
    repo.On("Create", school).Return(nil)

    err := service.Create(school)
    assert.NoError(t, err)
    repo.AssertExpectations(t)
}
```

### Tests de Integración

**Herramienta:** Testcontainers (shared/testing v0.7.0)

**Ejemplo:**
```go
func TestMaterialRepository(t *testing.T) {
    // Levantar PostgreSQL con Testcontainers
    pg := testing.NewPostgresContainer(t)
    defer pg.Terminate()

    // Ejecutar migraciones
    pg.RunMigrations("../../infrastructure/database/migrations")

    // Test contra DB real
    repo := NewPostgresRepo(pg.DB())
    material := &Material{...}
    
    err := repo.Create(material)
    assert.NoError(t, err)

    found := repo.Get(material.ID)
    assert.Equal(t, material.ID, found.ID)
}
```

### Tests E2E

**Herramientas:**
- Newman (Postman collections)
- Custom Go scripts

**Escenarios críticos:**
1. Subir material → Procesar → Tomar quiz
2. Crear escuela → Matricular estudiante → Acceder
3. Generar assessment → Intentar → Calificar

---

## 🚀 Deployment Architecture

### Environments

| Environment | Propósito | Configuración |
|-------------|-----------|---------------|
| **local** | Desarrollo en laptop | Docker Compose |
| **dev** | Desarrollo compartido | Kubernetes (staging) |
| **qa** | Testing de calidad | Kubernetes (staging) |
| **prod** | Producción | Kubernetes (production) |

### Kubernetes Resources

**Por servicio (api-admin, api-mobile, worker):**

```yaml
Deployment
  replicas: 3
  containers:
    - image: ghcr.io/edugogroup/api-mobile:v1.0.0
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 500m
          memory: 512Mi

Service (solo APIs)
  type: ClusterIP
  port: 80
  targetPort: 8080

HorizontalPodAutoscaler
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

ConfigMap
  .env values (no secrets)

Secret
  DB passwords, JWT secret, etc.
```

### Orden de Deployment

```
1. PostgreSQL (StatefulSet)
2. MongoDB (StatefulSet)
3. RabbitMQ (StatefulSet)
4. api-administracion (Deployment)
5. api-mobile (Deployment)
6. worker (Deployment)
```

---

## 📊 Observability

### Logging

**Herramienta:** shared/logger v0.7.0 (Zap)

**Formato:** JSON estructurado

```json
{
  "level": "info",
  "timestamp": "2025-11-15T10:30:00Z",
  "service": "api-mobile",
  "request_id": "req-uuid",
  "user_id": "user-uuid",
  "message": "Material uploaded successfully",
  "fields": {
    "material_id": "mat-uuid",
    "file_size": 2048000
  }
}
```

**Agregación:** Elasticsearch + Kibana (futuro)

### Metrics

**Herramienta:** Prometheus (futuro)

**Métricas clave:**
- `http_requests_total` (counter)
- `http_request_duration_seconds` (histogram)
- `db_query_duration_seconds` (histogram)
- `rabbitmq_messages_published_total` (counter)
- `rabbitmq_messages_consumed_total` (counter)

### Tracing

**Herramienta:** OpenTelemetry (futuro)

**Traces:**
- HTTP request → Use Case → Repository → DB
- Event publish → Queue → Consumer → Process

### Health Checks

**Endpoints:**
- `GET /health` - Liveness probe
- `GET /ready` - Readiness probe

**Respuesta:**
```json
{
  "status": "healthy",
  "version": "v1.0.0",
  "checks": {
    "database": "healthy",
    "rabbitmq": "healthy"
  }
}
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

```yaml
name: CI/CD

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.24'
      - run: go test ./... -coverprofile=coverage.out
      - run: go tool cover -func=coverage.out | grep total
      # Fail si coverage < 80%

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: golangci/golangci-lint-action@v3

  build:
    needs: [test, lint]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: docker/build-push-action@v4
        with:
          push: true
          tags: ghcr.io/edugogroup/api-mobile:${{ github.sha }}

  deploy-dev:
    needs: build
    if: github.ref == 'refs/heads/dev'
    runs-on: ubuntu-latest
    steps:
      - run: kubectl set image deployment/api-mobile ...
```

---

## 📝 Decisiones Arquitectónicas Clave

### 1. Microservicios con BD Compartida

**Decisión:** Separar APIs pero compartir PostgreSQL

**Rationale:**
- Dominio pequeño (no justifica BD separadas)
- Evitar complejidad de transacciones distribuidas
- Escalado independiente de APIs

### 2. MongoDB para Contenido de IA

**Decisión:** Usar MongoDB para documentos generados

**Rationale:**
- Schema flexible (preguntas varían)
- Mejor para arrays complejos
- Worker es owner del contenido

### 3. Eventual Consistency

**Decisión:** MongoDB primero, PostgreSQL después

**Rationale:**
- Más simple que 2PC/Saga
- Delay de segundos es aceptable
- DLQ maneja fallos

### 4. shared FROZEN en v0.7.0

**Decisión:** Congelar hasta post-MVP

**Rationale:**
- Estabilidad durante desarrollo
- Evitar breaking changes
- Foco en features, no en infraestructura

---

**Generado:** 16 de Noviembre, 2025  
**Por:** Claude Code  
**Versión:** 2.0.0
