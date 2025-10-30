# INFORME: ANÁLISIS Y PROPUESTA DE ARQUITECTURA PROFESIONAL
## Sistema EduGo - API Administración, API Mobile y Worker

**Fecha:** 2025-10-29
**Autor:** Análisis de Arquitectura
**Versión:** 1.0

---

## ÍNDICE

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Estado Actual de los Proyectos](#estado-actual-de-los-proyectos)
3. [Problemas Identificados](#problemas-identificados)
4. [Propuesta de Arquitectura](#propuesta-de-arquitectura)
5. [Estructura de Carpetas Propuesta](#estructura-de-carpetas-propuesta)
6. [Plan de Implementación](#plan-de-implementación)
7. [Patrones y Principios a Aplicar](#patrones-y-principios-a-aplicar)
8. [Recursos Compartidos](#recursos-compartidos)
9. [Conclusiones y Recomendaciones](#conclusiones-y-recomendaciones)

---

## 1. RESUMEN EJECUTIVO

Los 3 proyectos (api-administracion, api-mobile, worker) se encuentran en **fase de configuración completada** con:
- ✅ Configuración multi-ambiente funcional
- ✅ Swagger/OpenAPI documentado
- ✅ Docker y docker-compose listos
- ✅ Makefile con automatización completa
- ✅ TestContainers configurados
- ✅ Endpoints/Consumers definidos con implementación MOCK

**Problema Principal:** Todos los proyectos tienen **endpoints/consumers MOCK sin lógica de negocio real**, sin capas de abstracción, sin inyección de dependencias y con arquitectura MVC básica.

**Propuesta:** Implementar **Arquitectura Hexagonal (Ports & Adapters)** con:
- Inyección de dependencias mediante interfaces
- Separación de capas (dominio, aplicación, infraestructura)
- Estructura modular para crecimiento
- Recursos compartidos en paquetes Go reutilizables

---

## 2. ESTADO ACTUAL DE LOS PROYECTOS

### 2.1 API ADMINISTRACIÓN

**Estructura Actual:**
```
api-administracion/
├── cmd/main.go               # Router + middleware + configuración
├── internal/
│   ├── config/               # Configuración Viper
│   ├── handlers/             # Controllers (lógica + HTTP mezclados)
│   └── models/               # DTOs de request/response
```

**Características:**
- 14 endpoints MOCK
- Middleware de autenticación básico
- Sin capa de servicio
- Sin capa de repositorio
- Sin inyección de dependencias
- Sin tests unitarios

**Tecnologías:** Gin, PostgreSQL, MongoDB, Swagger

---

### 2.2 API MOBILE

**Estructura Actual:**
```
api-mobile/
├── cmd/main.go               # Router + middleware + configuración
├── internal/
│   ├── config/               # Configuración Viper
│   ├── handlers/             # Controllers (lógica + HTTP mezclados)
│   ├── middleware/           # Auth, CORS, Rate Limiter
│   └── models/               # DTOs + Enums + MongoDB docs
```

**Características:**
- 10 endpoints MOCK
- Middleware más completo (Auth, CORS, Logging, Rate Limiter)
- Sin capa de servicio
- Sin capa de repositorio
- Sin inyección de dependencias
- Modelos bien definidos pero sin persistencia

**Tecnologías:** Gin, PostgreSQL, MongoDB, RabbitMQ, Swagger

---

### 2.3 WORKER

**Estructura Actual:**
```
worker/
├── cmd/main.go               # Consumer RabbitMQ + procesamiento
├── internal/
│   ├── config/               # Configuración Viper
│   ├── consumer/             # VACÍO
│   ├── models/               # VACÍO
│   ├── processors/           # VACÍO
│   └── services/             # VACÍO
```

**Características:**
- 1 consumer implementado (material.uploaded) MOCK
- Procesamiento secuencial con sleeps simulando operaciones
- Sin integraciones reales (S3, OpenAI, MongoDB, PostgreSQL)
- Carpetas preparadas pero vacías
- Sin inyección de dependencias

**Tecnologías:** RabbitMQ, PostgreSQL, MongoDB, AWS S3, OpenAI API

---

## 3. PROBLEMAS IDENTIFICADOS

### 3.1 Problemas Arquitectónicos

| Problema | Impacto | Severidad |
|----------|---------|-----------|
| **Sin separación de capas** | Mezcla de HTTP/lógica de negocio/persistencia | 🔴 Alto |
| **Sin inyección de dependencias** | Difícil testing y cambio de implementación | 🔴 Alto |
| **Handlers con múltiples responsabilidades** | Viola Single Responsibility Principle | 🟡 Medio |
| **Sin interfaces de abstracción** | Acoplamiento fuerte a implementaciones | 🔴 Alto |
| **Código MOCK no productivo** | No se puede usar en producción | 🔴 Alto |
| **Sin capa de dominio** | Lógica de negocio dispersa | 🟡 Medio |

### 3.2 Problemas de Testing

| Problema | Impacto |
|----------|---------|
| Sin tests unitarios | No hay validación de lógica de negocio |
| TestContainers configurados pero sin usar | Infraestructura subutilizada |
| Imposible mockear dependencias | Handlers dependen de implementaciones concretas |

### 3.3 Problemas de Mantenibilidad

| Problema | Impacto |
|----------|---------|
| Lógica de negocio en handlers | Difícil de reutilizar |
| Sin paquetes compartidos | Duplicación de código entre proyectos |
| Configuración repetida | Mantenimiento duplicado |

---

## 4. PROPUESTA DE ARQUITECTURA

### 4.1 Arquitectura Hexagonal (Ports & Adapters)

**Principios:**

1. **Dominio en el centro**: Entidades y lógica de negocio independientes
2. **Puertos**: Interfaces que definen contratos
3. **Adaptadores**: Implementaciones concretas de los puertos
4. **Inversión de dependencias**: El dominio no depende de infraestructura

**Capas Propuestas:**

```
┌─────────────────────────────────────────────┐
│         INFRASTRUCTURE LAYER                 │
│  (HTTP Handlers, DB Repos, Message Queues)  │
└─────────────────┬───────────────────────────┘
                  │ depends on
┌─────────────────▼───────────────────────────┐
│         APPLICATION LAYER                    │
│     (Use Cases, Services, DTOs)              │
└─────────────────┬───────────────────────────┘
                  │ depends on
┌─────────────────▼───────────────────────────┐
│            DOMAIN LAYER                      │
│  (Entities, Value Objects, Domain Logic)     │
└──────────────────────────────────────────────┘
```

### 4.2 Principios SOLID Aplicados

| Principio | Implementación |
|-----------|----------------|
| **S** - Single Responsibility | Cada capa tiene una única responsabilidad |
| **O** - Open/Closed | Extensible via interfaces, cerrado para modificación |
| **L** - Liskov Substitution | Implementaciones intercambiables via interfaces |
| **I** - Interface Segregation | Interfaces pequeñas y específicas (ports) |
| **D** - Dependency Inversion | Dependencias apuntan hacia abstracciones |

### 4.3 Inyección de Dependencias

**Patrón Propuesto: Constructor Injection**

```go
// Ejemplo para API
type MaterialHandler struct {
    materialService application.MaterialService  // Interface
    logger          shared.Logger                 // Interface
}

func NewMaterialHandler(
    materialService application.MaterialService,
    logger shared.Logger,
) *MaterialHandler {
    return &MaterialHandler{
        materialService: materialService,
        logger:          logger,
    }
}
```

**Ventajas:**
- ✅ Fácil testing con mocks
- ✅ Explícito en las dependencias
- ✅ Inmutable después de construcción
- ✅ Permite cambiar implementaciones sin cambiar código

---

## 5. ESTRUCTURA DE CARPETAS PROPUESTA

### 5.1 API ADMINISTRACIÓN (Nueva Estructura)

```
api-administracion/
├── cmd/
│   └── main.go                         # Bootstrap + DI container
│
├── internal/
│   ├── domain/                         # CAPA DE DOMINIO
│   │   ├── entity/                     # Entidades de negocio
│   │   │   ├── user.go
│   │   │   ├── school.go
│   │   │   ├── unit.go
│   │   │   ├── subject.go
│   │   │   └── guardian.go
│   │   ├── valueobject/                # Value Objects
│   │   │   ├── email.go
│   │   │   ├── user_id.go
│   │   │   └── relationship_type.go
│   │   └── repository/                 # Interfaces (ports)
│   │       ├── user_repository.go
│   │       ├── school_repository.go
│   │       ├── unit_repository.go
│   │       ├── subject_repository.go
│   │       └── guardian_repository.go
│   │
│   ├── application/                    # CAPA DE APLICACIÓN
│   │   ├── service/                    # Servicios de aplicación
│   │   │   ├── user_service.go
│   │   │   ├── school_service.go
│   │   │   ├── unit_service.go
│   │   │   ├── subject_service.go
│   │   │   └── guardian_service.go
│   │   ├── usecase/                    # Casos de uso complejos
│   │   │   ├── create_user_with_role.go
│   │   │   ├── assign_teacher_to_unit.go
│   │   │   └── create_guardian_relation.go
│   │   └── dto/                        # DTOs de aplicación
│   │       ├── user_dto.go
│   │       ├── school_dto.go
│   │       └── guardian_dto.go
│   │
│   ├── infrastructure/                 # CAPA DE INFRAESTRUCTURA
│   │   ├── http/                       # Adaptador HTTP
│   │   │   ├── handler/                # Handlers Gin
│   │   │   │   ├── user_handler.go
│   │   │   │   ├── school_handler.go
│   │   │   │   ├── unit_handler.go
│   │   │   │   ├── subject_handler.go
│   │   │   │   ├── guardian_handler.go
│   │   │   │   └── health_handler.go
│   │   │   ├── middleware/             # Middlewares HTTP
│   │   │   │   ├── auth.go
│   │   │   │   ├── logger.go
│   │   │   │   └── error_handler.go
│   │   │   ├── request/                # Request DTOs
│   │   │   │   └── admin_request.go
│   │   │   ├── response/               # Response DTOs
│   │   │   │   └── admin_response.go
│   │   │   └── router.go               # Configuración de rutas
│   │   │
│   │   ├── persistence/                # Adaptador de persistencia
│   │   │   ├── postgres/               # PostgreSQL
│   │   │   │   ├── repository/         # Implementaciones de repos
│   │   │   │   │   ├── user_repository_impl.go
│   │   │   │   │   ├── school_repository_impl.go
│   │   │   │   │   ├── unit_repository_impl.go
│   │   │   │   │   ├── subject_repository_impl.go
│   │   │   │   │   └── guardian_repository_impl.go
│   │   │   │   ├── mapper/             # Entity <-> DB mappers
│   │   │   │   │   ├── user_mapper.go
│   │   │   │   │   └── school_mapper.go
│   │   │   │   └── connection.go       # Pool de conexiones
│   │   │   │
│   │   │   └── mongodb/                # MongoDB (si aplica)
│   │   │       └── connection.go
│   │   │
│   │   └── config/                     # Configuración
│   │       ├── config.go
│   │       └── loader.go
│   │
│   └── container/                      # DI Container
│       └── container.go                # Wiring de dependencias
│
├── config/                             # Archivos YAML
├── test/
│   ├── unit/                           # Tests unitarios por capa
│   │   ├── domain/
│   │   ├── application/
│   │   └── infrastructure/
│   └── integration/                    # Tests de integración
│       ├── setup.go
│       └── api_test.go
│
├── docs/                               # Swagger
├── Dockerfile
├── docker-compose.yml
├── Makefile
└── README.md
```

### 5.2 API MOBILE (Nueva Estructura)

```
api-mobile/
├── cmd/
│   └── main.go
│
├── internal/
│   ├── domain/
│   │   ├── entity/
│   │   │   ├── material.go
│   │   │   ├── user.go
│   │   │   ├── progress.go
│   │   │   └── assessment.go
│   │   ├── valueobject/
│   │   │   ├── material_status.go
│   │   │   ├── progress_percentage.go
│   │   │   └── assessment_type.go
│   │   └── repository/
│   │       ├── material_repository.go
│   │       ├── progress_repository.go
│   │       └── assessment_repository.go
│   │
│   ├── application/
│   │   ├── service/
│   │   │   ├── material_service.go
│   │   │   ├── auth_service.go
│   │   │   ├── progress_service.go
│   │   │   └── assessment_service.go
│   │   ├── usecase/
│   │   │   ├── create_material_with_pdf.go
│   │   │   ├── record_assessment_attempt.go
│   │   │   └── update_reading_progress.go
│   │   └── dto/
│   │       ├── material_dto.go
│   │       ├── auth_dto.go
│   │       └── assessment_dto.go
│   │
│   ├── infrastructure/
│   │   ├── http/
│   │   │   ├── handler/
│   │   │   │   ├── auth_handler.go
│   │   │   │   ├── material_handler.go
│   │   │   │   ├── assessment_handler.go
│   │   │   │   └── health_handler.go
│   │   │   ├── middleware/
│   │   │   │   ├── auth.go
│   │   │   │   ├── cors.go
│   │   │   │   ├── rate_limiter.go
│   │   │   │   └── logger.go
│   │   │   ├── request/
│   │   │   ├── response/
│   │   │   └── router.go
│   │   │
│   │   ├── persistence/
│   │   │   ├── postgres/
│   │   │   │   ├── repository/
│   │   │   │   │   ├── material_repository_impl.go
│   │   │   │   │   ├── user_repository_impl.go
│   │   │   │   │   └── progress_repository_impl.go
│   │   │   │   ├── mapper/
│   │   │   │   └── connection.go
│   │   │   │
│   │   │   └── mongodb/
│   │   │       ├── repository/
│   │   │       │   ├── summary_repository_impl.go
│   │   │       │   └── assessment_repository_impl.go
│   │   │       ├── mapper/
│   │   │       └── connection.go
│   │   │
│   │   ├── messaging/                  # RabbitMQ
│   │   │   ├── publisher/
│   │   │   │   └── event_publisher.go
│   │   │   └── connection.go
│   │   │
│   │   ├── storage/                    # AWS S3
│   │   │   └── s3_client.go
│   │   │
│   │   └── config/
│   │       ├── config.go
│   │       └── loader.go
│   │
│   └── container/
│       └── container.go
│
├── config/
├── test/
│   ├── unit/
│   └── integration/
├── docs/
└── ...
```

### 5.3 WORKER (Nueva Estructura)

```
worker/
├── cmd/
│   └── main.go
│
├── internal/
│   ├── domain/
│   │   ├── entity/
│   │   │   ├── material.go
│   │   │   ├── summary.go
│   │   │   ├── assessment.go
│   │   │   └── event.go
│   │   ├── valueobject/
│   │   │   ├── material_id.go
│   │   │   ├── event_type.go
│   │   │   └── processing_status.go
│   │   └── service/                    # Domain services
│   │       ├── pdf_processor.go        # Interface
│   │       ├── nlp_service.go          # Interface
│   │       └── summary_generator.go    # Interface
│   │
│   ├── application/
│   │   ├── processor/                  # Event processors
│   │   │   ├── material_uploaded_processor.go
│   │   │   ├── material_reprocess_processor.go
│   │   │   ├── assessment_attempt_processor.go
│   │   │   ├── material_deleted_processor.go
│   │   │   └── student_enrolled_processor.go
│   │   ├── service/
│   │   │   ├── material_processing_service.go
│   │   │   ├── notification_service.go
│   │   │   └── stats_service.go
│   │   └── dto/
│   │       ├── event_dto.go
│   │       └── processing_result_dto.go
│   │
│   ├── infrastructure/
│   │   ├── messaging/
│   │   │   ├── consumer/
│   │   │   │   ├── rabbitmq_consumer.go
│   │   │   │   └── event_router.go
│   │   │   ├── publisher/
│   │   │   │   └── event_publisher.go
│   │   │   └── connection.go
│   │   │
│   │   ├── persistence/
│   │   │   ├── postgres/
│   │   │   │   ├── repository/
│   │   │   │   │   └── material_repository_impl.go
│   │   │   │   └── connection.go
│   │   │   │
│   │   │   └── mongodb/
│   │   │       ├── repository/
│   │   │       │   ├── summary_repository_impl.go
│   │   │       │   └── assessment_repository_impl.go
│   │   │       └── connection.go
│   │   │
│   │   ├── storage/                    # AWS S3
│   │   │   └── s3_downloader.go
│   │   │
│   │   ├── nlp/                        # OpenAI API
│   │   │   ├── openai_client.go
│   │   │   └── prompt_builder.go
│   │   │
│   │   ├── pdf/                        # PDF processing
│   │   │   └── pdf_extractor.go
│   │   │
│   │   └── config/
│   │       ├── config.go
│   │       └── loader.go
│   │
│   └── container/
│       └── container.go
│
├── config/
├── test/
│   ├── unit/
│   │   ├── processor/
│   │   └── service/
│   └── integration/
│       ├── setup.go
│       └── consumer_test.go
│
└── scripts/
    └── send_test_message.go
```

---

## 6. PLAN DE IMPLEMENTACIÓN

### FASE 1: CREAR PAQUETES COMPARTIDOS (Shared)

**Objetivo:** Evitar duplicación de código entre proyectos

**Ubicación:** `/Users/jhoanmedina/source/EduGo/Analisys/shared/`

**Estructura:**

```
shared/
├── pkg/
│   ├── logger/                         # Logger común
│   │   ├── logger.go                   # Interface
│   │   └── zap_logger.go               # Implementación con Zap
│   │
│   ├── database/                       # Database helpers
│   │   ├── postgres/
│   │   │   ├── connection.go
│   │   │   └── transaction.go
│   │   ├── mongodb/
│   │   │   └── connection.go
│   │   └── health.go
│   │
│   ├── messaging/                      # RabbitMQ helpers
│   │   ├── connection.go
│   │   ├── publisher.go                # Interface
│   │   └── consumer.go                 # Interface
│   │
│   ├── errors/                         # Error handling
│   │   ├── errors.go                   # Custom errors
│   │   └── error_handler.go
│   │
│   ├── validator/                      # Validaciones
│   │   └── validator.go
│   │
│   ├── auth/                           # JWT helpers
│   │   ├── jwt.go
│   │   └── claims.go
│   │
│   ├── config/                         # Config helpers
│   │   └── loader.go
│   │
│   └── types/                          # Tipos compartidos
│       ├── uuid.go
│       ├── timestamp.go
│       └── enum/
│           ├── role.go
│           ├── status.go
│           └── event_type.go
│
└── go.mod                              # Módulo Go compartido
```

**Tareas:**

1. Crear módulo shared con `go mod init github.com/edugo/shared`
2. Implementar logger con interfaz y Zap
3. Implementar helpers de database
4. Implementar helpers de messaging
5. Implementar error handling común
6. Implementar validador
7. Implementar JWT helpers
8. Implementar tipos compartidos

**Commits Recomendados:**
- `feat(shared): add logger interface and zap implementation`
- `feat(shared): add database connection helpers`
- `feat(shared): add rabbitmq messaging helpers`
- `feat(shared): add error handling utilities`
- `feat(shared): add JWT authentication helpers`

---

### FASE 2: REFACTORIZAR API ADMINISTRACIÓN

**Orden de Implementación:**

#### Paso 1: Crear Estructura de Carpetas con .gitkeep

```bash
# Crear todas las carpetas vacías
mkdir -p internal/domain/{entity,valueobject,repository}
mkdir -p internal/application/{service,usecase,dto}
mkdir -p internal/infrastructure/{http/{handler,middleware,request,response},persistence/{postgres/{repository,mapper},mongodb},config}
mkdir -p internal/container
mkdir -p test/unit/{domain,application,infrastructure}

# Crear .gitkeep en carpetas vacías
find internal -type d -empty -exec touch {}/.gitkeep \;
find test/unit -type d -empty -exec touch {}/.gitkeep \;
```

#### Paso 2: Implementar Capa de Dominio

**Orden:**
1. Value Objects (email, user_id, relationship_type)
2. Entities (user, school, unit, subject, guardian)
3. Repository Interfaces (ports)

**Ejemplo de Entity:**

```go
// internal/domain/entity/user.go
package entity

import (
    "time"
    "github.com/edugo/api-administracion/internal/domain/valueobject"
)

type User struct {
    ID        valueobject.UserID
    Email     valueobject.Email
    FirstName string
    LastName  string
    Role      valueobject.SystemRole
    IsActive  bool
    CreatedAt time.Time
    UpdatedAt time.Time
}

// Business logic methods
func (u *User) Deactivate() error {
    if !u.IsActive {
        return errors.New("user already inactive")
    }
    u.IsActive = false
    u.UpdatedAt = time.Now()
    return nil
}
```

**Ejemplo de Repository Interface:**

```go
// internal/domain/repository/user_repository.go
package repository

import (
    "context"
    "github.com/edugo/api-administracion/internal/domain/entity"
    "github.com/edugo/api-administracion/internal/domain/valueobject"
)

type UserRepository interface {
    Create(ctx context.Context, user *entity.User) error
    FindByID(ctx context.Context, id valueobject.UserID) (*entity.User, error)
    FindByEmail(ctx context.Context, email valueobject.Email) (*entity.User, error)
    Update(ctx context.Context, user *entity.User) error
    Delete(ctx context.Context, id valueobject.UserID) error
    List(ctx context.Context, filters ListFilters) ([]*entity.User, error)
}
```

#### Paso 3: Implementar Capa de Aplicación

**Orden:**
1. DTOs
2. Services
3. Use Cases (si aplica)

**Ejemplo de Service:**

```go
// internal/application/service/user_service.go
package service

import (
    "context"
    "github.com/edugo/api-administracion/internal/domain/entity"
    "github.com/edugo/api-administracion/internal/domain/repository"
    "github.com/edugo/api-administracion/internal/application/dto"
    "github.com/edugo/shared/pkg/logger"
)

type UserService interface {
    CreateUser(ctx context.Context, req dto.CreateUserRequest) (*dto.UserResponse, error)
    GetUser(ctx context.Context, userID string) (*dto.UserResponse, error)
    UpdateUser(ctx context.Context, userID string, req dto.UpdateUserRequest) error
    DeleteUser(ctx context.Context, userID string) error
}

type userService struct {
    userRepo repository.UserRepository
    logger   logger.Logger
}

func NewUserService(
    userRepo repository.UserRepository,
    logger logger.Logger,
) UserService {
    return &userService{
        userRepo: userRepo,
        logger:   logger,
    }
}

func (s *userService) CreateUser(ctx context.Context, req dto.CreateUserRequest) (*dto.UserResponse, error) {
    // 1. Validar input
    if err := req.Validate(); err != nil {
        return nil, err
    }

    // 2. Verificar que no exista
    existing, err := s.userRepo.FindByEmail(ctx, req.Email)
    if err == nil && existing != nil {
        return nil, errors.New("user already exists")
    }

    // 3. Crear entidad de dominio
    user := &entity.User{
        ID:        valueobject.NewUserID(),
        Email:     valueobject.NewEmail(req.Email),
        FirstName: req.FirstName,
        LastName:  req.LastName,
        Role:      valueobject.SystemRole(req.Role),
        IsActive:  true,
        CreatedAt: time.Now(),
    }

    // 4. Persistir
    if err := s.userRepo.Create(ctx, user); err != nil {
        s.logger.Error("failed to create user", "error", err)
        return nil, err
    }

    // 5. Retornar DTO
    return dto.ToUserResponse(user), nil
}
```

#### Paso 4: Implementar Capa de Infraestructura

**Orden:**
1. Configuración
2. Persistence (PostgreSQL repositories)
3. HTTP (handlers, middleware, router)

**Ejemplo de Repository Implementation:**

```go
// internal/infrastructure/persistence/postgres/repository/user_repository_impl.go
package repository

import (
    "context"
    "database/sql"
    "github.com/edugo/api-administracion/internal/domain/entity"
    "github.com/edugo/api-administracion/internal/domain/repository"
    "github.com/edugo/api-administracion/internal/infrastructure/persistence/postgres/mapper"
)

type postgresUserRepository struct {
    db *sql.DB
}

func NewPostgresUserRepository(db *sql.DB) repository.UserRepository {
    return &postgresUserRepository{db: db}
}

func (r *postgresUserRepository) Create(ctx context.Context, user *entity.User) error {
    query := `
        INSERT INTO users (id, email, first_name, last_name, role, is_active, created_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
    `

    _, err := r.db.ExecContext(ctx, query,
        user.ID.String(),
        user.Email.String(),
        user.FirstName,
        user.LastName,
        string(user.Role),
        user.IsActive,
        user.CreatedAt,
    )

    return err
}

func (r *postgresUserRepository) FindByID(ctx context.Context, id valueobject.UserID) (*entity.User, error) {
    query := `
        SELECT id, email, first_name, last_name, role, is_active, created_at, updated_at
        FROM users
        WHERE id = $1
    `

    var dbUser mapper.UserDB
    err := r.db.QueryRowContext(ctx, query, id.String()).Scan(
        &dbUser.ID,
        &dbUser.Email,
        &dbUser.FirstName,
        &dbUser.LastName,
        &dbUser.Role,
        &dbUser.IsActive,
        &dbUser.CreatedAt,
        &dbUser.UpdatedAt,
    )

    if err == sql.ErrNoRows {
        return nil, repository.ErrNotFound
    }
    if err != nil {
        return nil, err
    }

    return mapper.ToUserEntity(&dbUser), nil
}
```

**Ejemplo de Handler:**

```go
// internal/infrastructure/http/handler/user_handler.go
package handler

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/edugo/api-administracion/internal/application/service"
    "github.com/edugo/api-administracion/internal/infrastructure/http/request"
    "github.com/edugo/shared/pkg/logger"
)

type UserHandler struct {
    userService service.UserService
    logger      logger.Logger
}

func NewUserHandler(userService service.UserService, logger logger.Logger) *UserHandler {
    return &UserHandler{
        userService: userService,
        logger:      logger,
    }
}

// CreateUser godoc
// @Summary Create a new user
// @Tags users
// @Accept json
// @Produce json
// @Param request body request.CreateUserRequest true "User data"
// @Success 201 {object} response.UserResponse
// @Failure 400 {object} response.ErrorResponse
// @Router /v1/users [post]
func (h *UserHandler) CreateUser(c *gin.Context) {
    var req request.CreateUserRequest

    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Convertir a DTO de aplicación
    dto := req.ToDTO()

    // Llamar al servicio
    user, err := h.userService.CreateUser(c.Request.Context(), dto)
    if err != nil {
        h.logger.Error("failed to create user", "error", err)
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
        return
    }

    c.JSON(http.StatusCreated, user)
}
```

#### Paso 5: Implementar DI Container

**Ejemplo:**

```go
// internal/container/container.go
package container

import (
    "database/sql"
    "github.com/edugo/api-administracion/internal/application/service"
    "github.com/edugo/api-administracion/internal/infrastructure/http/handler"
    "github.com/edugo/api-administracion/internal/infrastructure/persistence/postgres/repository"
    "github.com/edugo/shared/pkg/logger"
)

type Container struct {
    // Repositories
    UserRepository     repository.UserRepository
    SchoolRepository   repository.SchoolRepository
    UnitRepository     repository.UnitRepository
    SubjectRepository  repository.SubjectRepository
    GuardianRepository repository.GuardianRepository

    // Services
    UserService     service.UserService
    SchoolService   service.SchoolService
    UnitService     service.UnitService
    SubjectService  service.SubjectService
    GuardianService service.GuardianService

    // Handlers
    UserHandler     *handler.UserHandler
    SchoolHandler   *handler.SchoolHandler
    UnitHandler     *handler.UnitHandler
    SubjectHandler  *handler.SubjectHandler
    GuardianHandler *handler.GuardianHandler
    HealthHandler   *handler.HealthHandler

    // Infrastructure
    DB     *sql.DB
    Logger logger.Logger
}

func NewContainer(db *sql.DB, logger logger.Logger) *Container {
    c := &Container{
        DB:     db,
        Logger: logger,
    }

    // Initialize repositories
    c.UserRepository = repository.NewPostgresUserRepository(db)
    c.SchoolRepository = repository.NewPostgresSchoolRepository(db)
    c.UnitRepository = repository.NewPostgresUnitRepository(db)
    c.SubjectRepository = repository.NewPostgresSubjectRepository(db)
    c.GuardianRepository = repository.NewPostgresGuardianRepository(db)

    // Initialize services
    c.UserService = service.NewUserService(c.UserRepository, logger)
    c.SchoolService = service.NewSchoolService(c.SchoolRepository, logger)
    c.UnitService = service.NewUnitService(c.UnitRepository, logger)
    c.SubjectService = service.NewSubjectService(c.SubjectRepository, logger)
    c.GuardianService = service.NewGuardianService(c.GuardianRepository, c.UserRepository, logger)

    // Initialize handlers
    c.UserHandler = handler.NewUserHandler(c.UserService, logger)
    c.SchoolHandler = handler.NewSchoolHandler(c.SchoolService, logger)
    c.UnitHandler = handler.NewUnitHandler(c.UnitService, logger)
    c.SubjectHandler = handler.NewSubjectHandler(c.SubjectService, logger)
    c.GuardianHandler = handler.NewGuardianHandler(c.GuardianService, logger)
    c.HealthHandler = handler.NewHealthHandler(db, logger)

    return c
}
```

#### Paso 6: Actualizar main.go

```go
// cmd/main.go
package main

import (
    "context"
    "log"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/edugo/api-administracion/internal/container"
    "github.com/edugo/api-administracion/internal/infrastructure/config"
    "github.com/edugo/api-administracion/internal/infrastructure/http/router"
    "github.com/edugo/shared/pkg/database/postgres"
    "github.com/edugo/shared/pkg/logger"
)

func main() {
    // 1. Cargar configuración
    cfg, err := config.Load()
    if err != nil {
        log.Fatalf("Failed to load config: %v", err)
    }

    // 2. Inicializar logger
    logger := logger.NewZapLogger(cfg.Logging.Level, cfg.Logging.Format)
    defer logger.Sync()

    logger.Info("Starting API Administración", "version", "1.0.0")

    // 3. Conectar a PostgreSQL
    db, err := postgres.Connect(postgres.Config{
        Host:           cfg.Database.Postgres.Host,
        Port:           cfg.Database.Postgres.Port,
        User:           cfg.Database.Postgres.User,
        Password:       cfg.Database.Postgres.Password,
        Database:       cfg.Database.Postgres.Database,
        MaxConnections: cfg.Database.Postgres.MaxConnections,
        SSLMode:        cfg.Database.Postgres.SSLMode,
    })
    if err != nil {
        logger.Fatal("Failed to connect to database", "error", err)
    }
    defer db.Close()

    logger.Info("Connected to PostgreSQL")

    // 4. Inicializar container (DI)
    container := container.NewContainer(db, logger)

    // 5. Configurar router
    router := router.SetupRouter(container, cfg)

    // 6. Iniciar servidor con graceful shutdown
    server := &http.Server{
        Addr:         cfg.Server.Host + ":" + cfg.Server.Port,
        Handler:      router,
        ReadTimeout:  cfg.Server.ReadTimeout,
        WriteTimeout: cfg.Server.WriteTimeout,
    }

    go func() {
        logger.Info("Server starting", "address", server.Addr)
        if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            logger.Fatal("Server failed", "error", err)
        }
    }()

    // 7. Esperar señal de terminación
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    logger.Info("Shutting down server...")

    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    if err := server.Shutdown(ctx); err != nil {
        logger.Fatal("Server forced to shutdown", "error", err)
    }

    logger.Info("Server exited")
}
```

#### Paso 7: Tests Unitarios

**Ejemplo de test de servicio:**

```go
// test/unit/application/user_service_test.go
package application_test

import (
    "context"
    "testing"

    "github.com/edugo/api-administracion/internal/application/dto"
    "github.com/edugo/api-administracion/internal/application/service"
    "github.com/edugo/api-administracion/internal/domain/entity"
    "github.com/edugo/api-administracion/test/mocks"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

func TestUserService_CreateUser(t *testing.T) {
    // Arrange
    mockRepo := new(mocks.MockUserRepository)
    mockLogger := new(mocks.MockLogger)

    svc := service.NewUserService(mockRepo, mockLogger)

    req := dto.CreateUserRequest{
        Email:     "test@example.com",
        FirstName: "John",
        LastName:  "Doe",
        Role:      "teacher",
    }

    mockRepo.On("FindByEmail", mock.Anything, mock.Anything).Return(nil, repository.ErrNotFound)
    mockRepo.On("Create", mock.Anything, mock.AnythingOfType("*entity.User")).Return(nil)

    // Act
    result, err := svc.CreateUser(context.Background(), req)

    // Assert
    assert.NoError(t, err)
    assert.NotNil(t, result)
    assert.Equal(t, req.Email, result.Email)
    mockRepo.AssertExpectations(t)
}
```

**Commits Recomendados para cada paso:**
- `feat(api-admin): create domain layer structure`
- `feat(api-admin): implement user entity and value objects`
- `feat(api-admin): add repository interfaces`
- `feat(api-admin): implement application services`
- `feat(api-admin): add postgres repository implementations`
- `feat(api-admin): refactor HTTP handlers with DI`
- `feat(api-admin): setup dependency injection container`
- `test(api-admin): add unit tests for user service`

---

### FASE 3: REFACTORIZAR API MOBILE

**Proceso Similar a API Administración:**

1. Crear estructura de carpetas con .gitkeep
2. Implementar capa de dominio (Material, User, Progress, Assessment)
3. Implementar capa de aplicación (MaterialService, AuthService, etc.)
4. Implementar capa de infraestructura:
   - PostgreSQL repositories
   - MongoDB repositories (summary, assessment)
   - RabbitMQ publisher
   - S3 client
5. Implementar DI container
6. Actualizar main.go
7. Tests unitarios

**Diferencias Clave:**
- MongoDB para summaries y assessments (agregar repositorios MongoDB)
- RabbitMQ para publicar eventos (material.uploaded, assessment.attempt_recorded)
- AWS S3 para generar URLs firmadas

**Commits Recomendados:**
- `feat(api-mobile): implement hexagonal architecture`
- `feat(api-mobile): add mongodb repositories for summaries`
- `feat(api-mobile): integrate rabbitmq event publishing`
- `feat(api-mobile): add s3 client for material storage`

---

### FASE 4: REFACTORIZAR WORKER

**Proceso Específico para Worker:**

1. Crear estructura de carpetas con .gitkeep
2. Implementar capa de dominio:
   - Entities: Material, Summary, Assessment, Event
   - Domain Services (interfaces): PDFProcessor, NLPService, SummaryGenerator
3. Implementar capa de aplicación:
   - Event Processors (uno por tipo de evento)
   - MaterialProcessingService
4. Implementar capa de infraestructura:
   - RabbitMQ consumer (con routing a procesadores)
   - PostgreSQL repositories
   - MongoDB repositories
   - AWS S3 downloader
   - OpenAI client (NLP)
   - PDF extractor
5. Implementar DI container
6. Actualizar main.go con consumer y routing
7. Tests unitarios y de integración

**Ejemplo de Event Processor:**

```go
// internal/application/processor/material_uploaded_processor.go
package processor

import (
    "context"
    "github.com/edugo/worker/internal/application/dto"
    "github.com/edugo/worker/internal/domain/service"
    "github.com/edugo/shared/pkg/logger"
)

type MaterialUploadedProcessor interface {
    Process(ctx context.Context, event dto.MaterialUploadedEvent) error
}

type materialUploadedProcessor struct {
    pdfProcessor       service.PDFProcessor
    nlpService         service.NLPService
    summaryRepo        repository.SummaryRepository
    assessmentRepo     repository.AssessmentRepository
    materialRepo       repository.MaterialRepository
    s3Downloader       storage.S3Downloader
    logger             logger.Logger
}

func NewMaterialUploadedProcessor(
    pdfProcessor service.PDFProcessor,
    nlpService service.NLPService,
    summaryRepo repository.SummaryRepository,
    assessmentRepo repository.AssessmentRepository,
    materialRepo repository.MaterialRepository,
    s3Downloader storage.S3Downloader,
    logger logger.Logger,
) MaterialUploadedProcessor {
    return &materialUploadedProcessor{
        pdfProcessor:   pdfProcessor,
        nlpService:     nlpService,
        summaryRepo:    summaryRepo,
        assessmentRepo: assessmentRepo,
        materialRepo:   materialRepo,
        s3Downloader:   s3Downloader,
        logger:         logger,
    }
}

func (p *materialUploadedProcessor) Process(ctx context.Context, event dto.MaterialUploadedEvent) error {
    p.logger.Info("Processing material uploaded event", "material_id", event.MaterialID)

    // 1. Descargar PDF desde S3
    pdfData, err := p.s3Downloader.Download(ctx, event.S3Key)
    if err != nil {
        return fmt.Errorf("failed to download PDF: %w", err)
    }

    // 2. Extraer texto del PDF
    text, err := p.pdfProcessor.ExtractText(pdfData)
    if err != nil {
        return fmt.Errorf("failed to extract text: %w", err)
    }

    // 3. Generar resumen con NLP
    summary, err := p.nlpService.GenerateSummary(ctx, text, event.PreferredLanguage)
    if err != nil {
        return fmt.Errorf("failed to generate summary: %w", err)
    }

    // 4. Guardar resumen en MongoDB
    if err := p.summaryRepo.Save(ctx, event.MaterialID, summary); err != nil {
        return fmt.Errorf("failed to save summary: %w", err)
    }

    // 5. Generar quiz con IA
    quiz, err := p.nlpService.GenerateQuiz(ctx, text, event.PreferredLanguage)
    if err != nil {
        return fmt.Errorf("failed to generate quiz: %w", err)
    }

    // 6. Guardar quiz en MongoDB
    if err := p.assessmentRepo.Save(ctx, event.MaterialID, quiz); err != nil {
        return fmt.Errorf("failed to save quiz: %w", err)
    }

    // 7. Actualizar PostgreSQL con links
    if err := p.materialRepo.UpdateProcessingStatus(ctx, event.MaterialID, "completed"); err != nil {
        return fmt.Errorf("failed to update status: %w", err)
    }

    p.logger.Info("Material processing completed", "material_id", event.MaterialID)
    return nil
}
```

**Commits Recomendados:**
- `feat(worker): implement hexagonal architecture`
- `feat(worker): add event processors for all event types`
- `feat(worker): integrate openai nlp service`
- `feat(worker): add pdf processing with extraction`
- `feat(worker): implement rabbitmq consumer with routing`

---

## 7. PATRONES Y PRINCIPIOS A APLICAR

### 7.1 Patrones de Diseño

| Patrón | Aplicación | Beneficio |
|--------|------------|-----------|
| **Repository Pattern** | Abstracción de persistencia | Desacopla dominio de DB |
| **Dependency Injection** | Constructor injection | Testing y flexibilidad |
| **Factory Pattern** | Creación de entidades complejas | Encapsula lógica de creación |
| **Strategy Pattern** | Múltiples implementaciones (NLP providers) | Intercambiable |
| **Adapter Pattern** | Integración con servicios externos | Aísla cambios externos |
| **Observer Pattern** | Eventos de dominio | Desacopla módulos |

### 7.2 Principios SOLID

#### Single Responsibility Principle (SRP)
- Cada handler solo maneja HTTP
- Cada service solo tiene lógica de aplicación
- Cada repository solo maneja persistencia

#### Open/Closed Principle (OCP)
- Extender funcionalidad via nuevas implementaciones de interfaces
- No modificar código existente

#### Liskov Substitution Principle (LSP)
- Cualquier implementación de `UserRepository` debe funcionar igual

#### Interface Segregation Principle (ISP)
- Interfaces pequeñas y específicas (no God interfaces)
- Ejemplo: `MaterialReader` vs `MaterialWriter` en vez de `MaterialManager`

#### Dependency Inversion Principle (DIP)
- Dependencias apuntan hacia abstracciones (interfaces)
- Dominio no conoce infraestructura

### 7.3 Otros Principios

| Principio | Descripción |
|-----------|-------------|
| **DRY** | Don't Repeat Yourself - usar paquete shared |
| **KISS** | Keep It Simple Stupid - evitar over-engineering |
| **YAGNI** | You Aren't Gonna Need It - implementar solo lo necesario |
| **Separation of Concerns** | Cada capa tiene una preocupación específica |

---

## 8. RECURSOS COMPARTIDOS

### 8.1 Estructura del Módulo Shared

```
shared/
├── pkg/
│   ├── logger/
│   ├── database/
│   ├── messaging/
│   ├── errors/
│   ├── validator/
│   ├── auth/
│   ├── config/
│   └── types/
├── go.mod
├── go.sum
└── README.md
```

### 8.2 Uso en Proyectos

**go.mod de cada proyecto:**

```go
module github.com/edugo/api-administracion

require (
    github.com/edugo/shared v0.1.0
    // otras dependencias...
)

replace github.com/edugo/shared => ../../../shared
```

**Importar en código:**

```go
import (
    "github.com/edugo/shared/pkg/logger"
    "github.com/edugo/shared/pkg/database/postgres"
    "github.com/edugo/shared/pkg/auth"
)
```

### 8.3 Versionamiento de Shared

**Estrategia:**
- Usar Git tags para versiones: `v0.1.0`, `v0.2.0`, etc.
- Incrementar versión minor al agregar features
- Incrementar versión major al cambiar interfaces (breaking changes)

**Ejemplo:**
```bash
cd shared
git tag v0.1.0
git push origin v0.1.0

# En proyectos
go get github.com/edugo/shared@v0.1.0
```

---

## 9. CONCLUSIONES Y RECOMENDACIONES

### 9.1 Resumen

Los 3 proyectos están en un **punto ideal para implementar arquitectura profesional**:
- ✅ Tienen toda la infraestructura configurada
- ✅ Endpoints/consumers definidos
- ✅ Testing preparado
- ❌ Pero sin lógica de negocio real
- ❌ Sin separación de capas
- ❌ Sin inyección de dependencias

**La propuesta de Arquitectura Hexagonal resuelve todos los problemas identificados.**

### 9.2 Ventajas de la Propuesta

| Ventaja | Descripción |
|---------|-------------|
| **Testeable** | Fácil crear mocks de interfaces |
| **Mantenible** | Cada capa tiene responsabilidad clara |
| **Escalable** | Estructura modular permite crecimiento |
| **Flexible** | Cambiar implementaciones sin afectar dominio |
| **Professional** | Sigue mejores prácticas de la industria |
| **DRY** | Paquete shared evita duplicación |

### 9.3 Orden de Implementación Recomendado

1. **FASE 1: Shared** (1-2 días)
   - Crear módulo shared
   - Implementar logger, database helpers, messaging helpers
   - Tests unitarios

2. **FASE 2: API Administración** (3-5 días)
   - Refactorizar con arquitectura hexagonal
   - Implementar lógica real de 14 endpoints
   - Tests unitarios y de integración

3. **FASE 3: API Mobile** (3-5 días)
   - Refactorizar con arquitectura hexagonal
   - Implementar lógica real de 10 endpoints
   - Integrar S3, MongoDB, RabbitMQ
   - Tests unitarios y de integración

4. **FASE 4: Worker** (3-5 días)
   - Refactorizar con arquitectura hexagonal
   - Implementar 5 event processors
   - Integrar OpenAI, S3, MongoDB, PostgreSQL
   - Tests unitarios y de integración

**Total estimado: 10-17 días de desarrollo**

### 9.4 Métricas de Éxito

| Métrica | Objetivo |
|---------|----------|
| Cobertura de tests | ≥ 80% |
| Líneas de código duplicado | < 5% |
| Complejidad ciclomática | < 15 por función |
| Dependencias entre capas | Solo hacia adentro (hexagonal) |
| Tiempo de build | < 2 minutos |

### 9.5 Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Sobre-ingeniería | Media | Medio | Empezar simple, iterar |
| Curva de aprendizaje | Alta | Bajo | Documentación y ejemplos |
| Refactor masivo | Baja | Alto | Fase incremental, tests |
| Incompatibilidad de shared | Baja | Medio | Versionamiento semántico |

### 9.6 Próximos Pasos Inmediatos

1. ✅ **Revisar y aprobar este informe**
2. 🟡 **Crear estructura de carpetas con .gitkeep en los 3 proyectos**
3. 🟡 **Crear módulo shared**
4. 🟡 **Implementar FASE 1 completa**
5. 🟡 **Commit de estructura base**
6. 🟡 **Iniciar FASE 2 (API Administración)**

---

## ANEXO A: COMANDOS ÚTILES

### Crear Estructura de Carpetas

```bash
# API Administración
cd source/api-administracion
mkdir -p internal/domain/{entity,valueobject,repository}
mkdir -p internal/application/{service,usecase,dto}
mkdir -p internal/infrastructure/{http/{handler,middleware,request,response},persistence/{postgres/{repository,mapper},mongodb},config}
mkdir -p internal/container
mkdir -p test/unit/{domain,application,infrastructure}
find internal test/unit -type d -empty -exec touch {}/.gitkeep \;

# API Mobile (similar)
cd ../api-mobile
mkdir -p internal/domain/{entity,valueobject,repository}
mkdir -p internal/application/{service,usecase,dto}
mkdir -p internal/infrastructure/{http/{handler,middleware,request,response},persistence/{postgres/{repository,mapper},mongodb/{repository,mapper}},messaging/{publisher},storage,config}
mkdir -p internal/container
mkdir -p test/unit/{domain,application,infrastructure}
find internal test/unit -type d -empty -exec touch {}/.gitkeep \;

# Worker
cd ../worker
mkdir -p internal/domain/{entity,valueobject,service}
mkdir -p internal/application/{processor,service,dto}
mkdir -p internal/infrastructure/{messaging/{consumer,publisher},persistence/{postgres/repository,mongodb/repository},storage,nlp,pdf,config}
mkdir -p internal/container
mkdir -p test/unit/{processor,service}
find internal test/unit -type d -empty -exec touch {}/.gitkeep \;

# Shared
cd ../../
mkdir -p shared/pkg/{logger,database/{postgres,mongodb},messaging,errors,validator,auth,config,types/enum}
cd shared
touch pkg/logger/.gitkeep pkg/database/postgres/.gitkeep pkg/database/mongodb/.gitkeep
```

### Inicializar Módulo Shared

```bash
cd shared
go mod init github.com/edugo/shared
```

### Actualizar Dependencias en Proyectos

```bash
cd source/api-administracion
go mod edit -replace github.com/edugo/shared=../../../shared
go mod tidy

cd ../api-mobile
go mod edit -replace github.com/edugo/shared=../../../shared
go mod tidy

cd ../worker
go mod edit -replace github.com/edugo/shared=../../../shared
go mod tidy
```

---

## ANEXO B: CHECKLIST DE IMPLEMENTACIÓN

### ✅ FASE 1: SHARED

- [ ] Crear módulo shared
- [ ] Implementar logger interface
- [ ] Implementar Zap logger
- [ ] Implementar postgres connection helper
- [ ] Implementar mongodb connection helper
- [ ] Implementar rabbitmq connection helper
- [ ] Implementar error handling
- [ ] Implementar validator
- [ ] Implementar JWT helpers
- [ ] Implementar tipos compartidos (UUID, Timestamp, Enums)
- [ ] Tests unitarios de shared
- [ ] Documentación README de shared

### ✅ FASE 2: API ADMINISTRACIÓN

**Dominio:**
- [ ] Value Objects (UserID, Email, Role, etc.)
- [ ] Entity: User
- [ ] Entity: School
- [ ] Entity: Unit
- [ ] Entity: Subject
- [ ] Entity: Guardian
- [ ] Repository interfaces

**Aplicación:**
- [ ] DTOs
- [ ] UserService
- [ ] SchoolService
- [ ] UnitService
- [ ] SubjectService
- [ ] GuardianService
- [ ] Use Cases (si aplica)

**Infraestructura:**
- [ ] Config loader
- [ ] PostgreSQL connection
- [ ] UserRepository implementation
- [ ] SchoolRepository implementation
- [ ] UnitRepository implementation
- [ ] SubjectRepository implementation
- [ ] GuardianRepository implementation
- [ ] Mappers
- [ ] UserHandler
- [ ] SchoolHandler
- [ ] UnitHandler
- [ ] SubjectHandler
- [ ] GuardianHandler
- [ ] HealthHandler
- [ ] Middleware (Auth, Logger, Error)
- [ ] Router setup

**DI & Main:**
- [ ] DI Container
- [ ] main.go refactorizado
- [ ] Graceful shutdown

**Tests:**
- [ ] Tests unitarios de servicios
- [ ] Tests unitarios de handlers
- [ ] Tests de integración

### ✅ FASE 3: API MOBILE

- [ ] Similar a API Administración
- [ ] + MongoDB repositories
- [ ] + RabbitMQ publisher
- [ ] + S3 client

### ✅ FASE 4: WORKER

- [ ] Dominio (entities, value objects, domain services)
- [ ] Event processors (5 tipos)
- [ ] Application services
- [ ] RabbitMQ consumer con routing
- [ ] PostgreSQL repositories
- [ ] MongoDB repositories
- [ ] S3 downloader
- [ ] OpenAI client
- [ ] PDF extractor
- [ ] DI Container
- [ ] main.go refactorizado
- [ ] Tests unitarios y de integración

---

**FIN DEL INFORME**

---

## PREGUNTAS PARA EL EQUIPO

1. ¿Están de acuerdo con la propuesta de Arquitectura Hexagonal?
2. ¿Prefieren otro nombre para las capas? (ej: "core" en vez de "domain")
3. ¿Quieren usar un framework de DI (como Wire o Fx) o manual?
4. ¿Hay algún patrón adicional que quieran incluir?
5. ¿El tiempo estimado (10-17 días) es razonable para el equipo?
6. ¿Debo proceder con la creación de carpetas y .gitkeep?

Por favor, revisar y aprobar para proceder con la implementación.
