# GUÍA RÁPIDA DE REFACTORIZACIÓN
## Cómo refactorizar cualquier endpoint a Arquitectura Hexagonal

**Fecha:** 2025-10-29
**Objetivo:** Convertir endpoints MOCK a arquitectura hexagonal con shared
**Ejemplos completados:** GuardianRelation, User

---

## 📋 PATRÓN GENERAL (CHECKLIST)

Sigue estos pasos para refactorizar **cualquier endpoint**:

### ✅ PASO 1: Analizar el Endpoint MOCK

```bash
# Identificar en cmd/main.go o internal/handlers/
- ¿Qué hace el endpoint?
- ¿Qué entidades maneja?
- ¿Qué validaciones necesita?
- ¿Qué persistencia requiere? (PostgreSQL, MongoDB, ambos)
```

**Ejemplo:**
```go
// ANTES (MOCK)
router.POST("/v1/users", func(c *gin.Context) {
    c.JSON(201, gin.H{"user_id": "mock-uuid"})
})
```

---

### ✅ PASO 2: Capa de DOMINIO

#### 2.1 Value Objects (`internal/domain/valueobject/`)

Crear value objects para:
- IDs con UUID
- Emails con validación
- Enums con validación

**Template:**
```go
// {entity}_id.go
package valueobject

import "github.com/edugo/shared/pkg/types"

type EntityID struct {
    value types.UUID
}

func NewEntityID() EntityID {
    return EntityID{value: types.NewUUID()}
}

func EntityIDFromString(s string) (EntityID, error) {
    uuid, err := types.ParseUUID(s)
    if err != nil {
        return EntityID{}, err
    }
    return EntityID{value: uuid}, nil
}

func (e EntityID) String() string {
    return e.value.String()
}

func (e EntityID) IsZero() bool {
    return e.value.IsZero()
}
```

**Ejemplos creados:**
- ✅ `guardian_id.go`, `student_id.go`, `user_id.go`
- ✅ `email.go`
- ✅ `relationship_type.go`

---

#### 2.2 Entities (`internal/domain/entity/`)

**Template:**
```go
// {entity}.go
package entity

import (
    "time"
    "github.com/edugo/shared/pkg/errors"
    "github.com/edugo/shared/pkg/types"
)

type Entity struct {
    id        types.UUID           // O tu custom ID
    field1    string
    field2    SomeValueObject
    isActive  bool
    createdAt time.Time
    updatedAt time.Time
}

// Constructor con validaciones
func NewEntity(...) (*Entity, error) {
    // Validaciones de negocio
    if field1 == "" {
        return nil, errors.NewValidationError("field1 is required")
    }

    // Reglas de negocio
    if someBusinessRule {
        return nil, errors.NewBusinessRuleError("violated rule")
    }

    return &Entity{
        id: types.NewUUID(),
        // ...
        createdAt: time.Now(),
        updatedAt: time.Now(),
    }, nil
}

// Reconstruir desde DB
func ReconstructEntity(...) *Entity {
    return &Entity{...}
}

// Getters (no setters!)
func (e *Entity) ID() types.UUID { return e.id }
func (e *Entity) Field1() string { return e.field1 }

// Métodos de negocio
func (e *Entity) Deactivate() error {
    if !e.isActive {
        return errors.NewBusinessRuleError("already inactive")
    }
    e.isActive = false
    e.updatedAt = time.Now()
    return nil
}
```

**Ejemplos creados:**
- ✅ `guardian_relation.go`
- ✅ `user.go`

---

#### 2.3 Repository Interface (`internal/domain/repository/`)

**Template:**
```go
// {entity}_repository.go
package repository

import (
    "context"
    "github.com/edugo/api-administracion/internal/domain/entity"
)

type EntityRepository interface {
    Create(ctx context.Context, e *entity.Entity) error
    FindByID(ctx context.Context, id SomeID) (*entity.Entity, error)
    Update(ctx context.Context, e *entity.Entity) error
    Delete(ctx context.Context, id SomeID) error
    // Métodos específicos según necesidad
}
```

**Ejemplos creados:**
- ✅ `guardian_repository.go`
- ✅ `user_repository.go`

---

### ✅ PASO 3: Capa de APLICACIÓN

#### 3.1 DTOs (`internal/application/dto/`)

**Template:**
```go
// {entity}_dto.go
package dto

import (
    "github.com/edugo/shared/pkg/validator"
    "github.com/edugo/api-administracion/internal/domain/entity"
)

// Request DTO
type CreateEntityRequest struct {
    Field1 string `json:"field1"`
    Field2 string `json:"field2"`
}

// Validación con shared/validator
func (r *CreateEntityRequest) Validate() error {
    v := validator.New()

    v.Required(r.Field1, "field1")
    v.MinLength(r.Field1, 2, "field1")
    v.Email(r.Field2, "field2")  // Si aplica

    return v.GetError()  // Retorna AppError
}

// Response DTO
type EntityResponse struct {
    ID     string `json:"id"`
    Field1 string `json:"field1"`
    // ...
}

// Mapper: Entity → DTO
func ToEntityResponse(e *entity.Entity) *EntityResponse {
    return &EntityResponse{
        ID: e.ID().String(),
        // ...
    }
}
```

**Ejemplos creados:**
- ✅ `guardian_dto.go`
- ✅ `user_dto.go`

---

#### 3.2 Services (`internal/application/service/`)

**Template:**
```go
// {entity}_service.go
package service

import (
    "context"
    "github.com/edugo/shared/pkg/logger"
    "github.com/edugo/shared/pkg/errors"
)

// Interface del servicio
type EntityService interface {
    CreateEntity(ctx context.Context, req dto.CreateEntityRequest) (*dto.EntityResponse, error)
    // Más métodos...
}

// Implementación
type entityService struct {
    entityRepo repository.EntityRepository  // Interface!
    logger     logger.Logger                 // shared/logger
}

func NewEntityService(
    entityRepo repository.EntityRepository,
    logger logger.Logger,
) EntityService {
    return &entityService{
        entityRepo: entityRepo,
        logger:     logger,
    }
}

func (s *entityService) CreateEntity(
    ctx context.Context,
    req dto.CreateEntityRequest,
) (*dto.EntityResponse, error) {
    // 1. Validar
    if err := req.Validate(); err != nil {
        s.logger.Warn("validation failed", "error", err)
        return nil, err
    }

    // 2. Verificar reglas (si existe, etc.)
    exists, err := s.entityRepo.Exists(ctx, ...)
    if exists {
        return nil, errors.NewAlreadyExistsError("entity")
    }

    // 3. Crear entidad de dominio
    entity, err := entity.NewEntity(...)
    if err != nil {
        return nil, err
    }

    // 4. Persistir
    if err := s.entityRepo.Create(ctx, entity); err != nil {
        s.logger.Error("failed to save", "error", err)
        return nil, errors.NewDatabaseError("create", err)
    }

    s.logger.Info("entity created", "id", entity.ID())

    // 5. Retornar DTO
    return dto.ToEntityResponse(entity), nil
}
```

**Ejemplos creados:**
- ✅ `guardian_service.go`
- ✅ `user_service.go`

---

### ✅ PASO 4: Capa de INFRAESTRUCTURA

#### 4.1 Repository Implementation (`internal/infrastructure/persistence/postgres/repository/`)

**Template:**
```go
// {entity}_repository_impl.go
package repository

import (
    "context"
    "database/sql"
    "github.com/edugo/api-administracion/internal/domain/repository"
)

type postgresEntityRepository struct {
    db *sql.DB
}

func NewPostgresEntityRepository(db *sql.DB) repository.EntityRepository {
    return &postgresEntityRepository{db: db}
}

func (r *postgresEntityRepository) Create(ctx context.Context, e *entity.Entity) error {
    query := `
        INSERT INTO entities (id, field1, field2, created_at)
        VALUES ($1, $2, $3, $4)
    `

    _, err := r.db.ExecContext(ctx, query,
        e.ID().String(),
        e.Field1(),
        e.Field2(),
        e.CreatedAt(),
    )

    return err
}

func (r *postgresEntityRepository) FindByID(ctx context.Context, id SomeID) (*entity.Entity, error) {
    query := `SELECT ... FROM entities WHERE id = $1`

    var (/* campos */)

    err := r.db.QueryRowContext(ctx, query, id.String()).Scan(/* ... */)

    if err == sql.ErrNoRows {
        return nil, nil  // No encontrado
    }
    if err != nil {
        return nil, err
    }

    return r.scanToEntity(...)
}

// Helper para reconstruir entity
func (r *postgresEntityRepository) scanToEntity(...) (*entity.Entity, error) {
    // Parsear value objects
    id, err := valueobject.EntityIDFromString(idStr)
    // ...

    // Reconstruir
    return entity.ReconstructEntity(...), nil
}
```

**Ejemplos creados:**
- ✅ `guardian_repository_impl.go`
- ✅ `user_repository_impl.go`

---

#### 4.2 HTTP Handler (`internal/infrastructure/http/handler/`)

**Template:**
```go
// {entity}_handler.go
package handler

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/edugo/shared/pkg/errors"
    "github.com/edugo/shared/pkg/logger"
)

type EntityHandler struct {
    entityService service.EntityService  // Interface!
    logger        logger.Logger          // shared/logger
}

func NewEntityHandler(
    entityService service.EntityService,
    logger logger.Logger,
) *EntityHandler {
    return &EntityHandler{
        entityService: entityService,
        logger:        logger,
    }
}

func (h *EntityHandler) CreateEntity(c *gin.Context) {
    var req dto.CreateEntityRequest

    // 1. Bind JSON
    if err := c.ShouldBindJSON(&req); err != nil {
        h.logger.Warn("invalid request", "error", err)
        c.JSON(400, ErrorResponse{...})
        return
    }

    // 2. Llamar servicio
    result, err := h.entityService.CreateEntity(c.Request.Context(), req)

    // 3. Manejar errores con shared/errors
    if err != nil {
        if appErr, ok := errors.GetAppError(err); ok {
            h.logger.Error("failed", "error", appErr.Message, "code", appErr.Code)

            c.JSON(appErr.StatusCode, ErrorResponse{  // ← Mapeo automático!
                Error: appErr.Message,
                Code:  string(appErr.Code),
            })
            return
        }

        h.logger.Error("unexpected error", "error", err)
        c.JSON(500, ErrorResponse{...})
        return
    }

    // 4. Log y respuesta
    h.logger.Info("success", "id", result.ID)
    c.JSON(201, result)
}

type ErrorResponse struct {
    Error string `json:"error"`
    Code  string `json:"code"`
}
```

**Ejemplos creados:**
- ✅ `guardian_handler.go`
- ✅ `user_handler.go`

---

### ✅ PASO 5: DI Container

**Actualizar `internal/container/container.go`:**

```go
type Container struct {
    // Agregar nuevos campos
    EntityRepository repository.EntityRepository
    EntityService    service.EntityService
    EntityHandler    *handler.EntityHandler
}

func NewContainer(db *sql.DB, logger logger.Logger) *Container {
    c := &Container{DB: db, Logger: logger}

    // 1. Repository
    c.EntityRepository = postgresRepo.NewPostgresEntityRepository(db)

    // 2. Service
    c.EntityService = service.NewEntityService(c.EntityRepository, logger)

    // 3. Handler
    c.EntityHandler = handler.NewEntityHandler(c.EntityService, logger)

    return c
}
```

---

### ✅ PASO 6: Actualizar Rutas en main.go

```go
// En main.go
v1 := router.Group("/v1")
{
    v1.POST("/entities", container.EntityHandler.CreateEntity)
    v1.GET("/entities/:id", container.EntityHandler.GetEntity)
    v1.PATCH("/entities/:id", container.EntityHandler.UpdateEntity)
    v1.DELETE("/entities/:id", container.EntityHandler.DeleteEntity)
}
```

---

## 🎯 FLUJO DE TRABAJO COMPLETO

### Para refactorizar un endpoint completo (ej: CreateSchool):

```bash
# 1. DOMINIO (15-30 min)
touch internal/domain/valueobject/school_id.go
touch internal/domain/entity/school.go
touch internal/domain/repository/school_repository.go

# 2. APLICACIÓN (15-20 min)
touch internal/application/dto/school_dto.go
touch internal/application/service/school_service.go

# 3. INFRAESTRUCTURA (30-40 min)
touch internal/infrastructure/persistence/postgres/repository/school_repository_impl.go
touch internal/infrastructure/http/handler/school_handler.go

# 4. DI CONTAINER (5 min)
# Editar internal/container/container.go

# 5. RUTAS (5 min)
# Editar cmd/main.go

# 6. COMPILAR Y PROBAR
go build ./internal/...
go run cmd/main.go
```

**Tiempo estimado por endpoint:** 70-100 minutos

---

## 📚 EJEMPLOS DISPONIBLES

### 1. GuardianRelation (COMPLETO)

**Archivos:**
```
domain/valueobject/
├── guardian_id.go
├── student_id.go
└── relationship_type.go

domain/entity/
└── guardian_relation.go

domain/repository/
└── guardian_repository.go

application/dto/
└── guardian_dto.go

application/service/
└── guardian_service.go

infrastructure/persistence/postgres/repository/
└── guardian_repository_impl.go

infrastructure/http/handler/
└── guardian_handler.go
```

**Endpoints:**
- POST /v1/guardian-relations
- GET /v1/guardian-relations/:id
- GET /v1/guardians/:guardian_id/relations
- GET /v1/students/:student_id/guardians

---

### 2. User (COMPLETO)

**Archivos:**
```
domain/valueobject/
├── user_id.go
└── email.go

domain/entity/
└── user.go

domain/repository/
└── user_repository.go

application/dto/
└── user_dto.go

application/service/
└── user_service.go

infrastructure/persistence/postgres/repository/
└── user_repository_impl.go

infrastructure/http/handler/
└── user_handler.go
```

**Endpoints:**
- POST /v1/users
- GET /v1/users/:id
- PATCH /v1/users/:id
- DELETE /v1/users/:id

---

## ⚡ ATAJOS Y TIPS

### Copiar y Adaptar

1. **Copiar** archivo de ejemplo (user o guardian)
2. **Buscar y reemplazar**:
   - `User` → `School`
   - `user` → `school`
   - `UserID` → `SchoolID`
3. **Adaptar** campos específicos
4. **Compilar** para ver errores
5. **Ajustar** según necesidad

### Usar VSCode Multi-Cursor

```
Ctrl+F → "User" → Ctrl+Shift+L (Select All) → Type "School"
```

### Generar SQL desde Entity

```sql
-- Template basado en entity fields
CREATE TABLE entities (
    id UUID PRIMARY KEY,
    field1 VARCHAR(100) NOT NULL,
    field2 VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

## 📊 ENDPOINTS PENDIENTES EN API ADMINISTRACIÓN

| Endpoint | Prioridad | Complejidad | Tiempo Est. |
|----------|-----------|-------------|-------------|
| ✅ POST /v1/guardian-relations | - | Media | ✓ Completado |
| ✅ POST /v1/users | - | Media | ✓ Completado |
| 🔴 POST /v1/schools | Alta | Baja | 1h |
| 🔴 POST /v1/units | Alta | Media | 1.5h |
| 🟡 PATCH /v1/units/:id | Media | Baja | 45min |
| 🟡 POST /v1/units/:id/members | Media | Media | 1h |
| 🟡 POST /v1/subjects | Media | Baja | 1h |
| 🟡 PATCH /v1/subjects/:id | Baja | Baja | 45min |
| 🟢 DELETE /v1/materials/:id | Baja | Baja | 30min |
| 🟢 GET /v1/stats/global | Baja | Baja | 30min |

**Total estimado:** ~8-10 horas para completar todos

---

## 🎓 PATRONES APRENDIDOS

### Patrón 1: Value Objects para IDs

```go
// Siempre usar value objects para IDs
type UserID struct {
    value types.UUID  // ← shared/types
}

// Beneficio: Type safety, no confundir UserID con SchoolID
```

### Patrón 2: Validación en 2 Niveles

```go
// Nivel 1: DTO (formato, campos requeridos)
func (r *Request) Validate() error {
    v := validator.New()  // ← shared/validator
    v.Required(...)
    v.Email(...)
    return v.GetError()
}

// Nivel 2: Entity (reglas de negocio)
func NewEntity(...) (*Entity, error) {
    if violatesBusinessRule {
        return nil, errors.NewBusinessRuleError(...)  // ← shared/errors
    }
}
```

### Patrón 3: Error Handling Consistente

```go
// En Service
if err := repo.Create(ctx, entity); err != nil {
    s.logger.Error("failed", "error", err)  // ← shared/logger
    return nil, errors.NewDatabaseError("create", err)  // ← shared/errors
}

// En Handler
if err != nil {
    if appErr, ok := errors.GetAppError(err); ok {
        c.JSON(appErr.StatusCode, ...)  // ← Mapeo automático HTTP
        return
    }
    c.JSON(500, ...)
}
```

### Patrón 4: Dependency Injection

```go
// Siempre inyectar por constructor
func NewService(repo Repository, logger logger.Logger) Service {
    return &service{repo: repo, logger: logger}
}

// Nunca crear dependencias dentro de structs
// ❌ MALO: s.logger = logger.NewZapLogger()
// ✅ BUENO: s.logger = logger (inyectado)
```

---

## ✅ CHECKLIST DE REFACTORIZACIÓN

Usar este checklist para cada endpoint:

### Dominio
- [ ] Crear value objects necesarios (IDs, emails, etc.)
- [ ] Crear entity con constructor NewEntity()
- [ ] Agregar método Reconstruct para DB
- [ ] Agregar getters (no setters)
- [ ] Agregar métodos de negocio
- [ ] Crear repository interface

### Aplicación
- [ ] Crear request DTOs
- [ ] Agregar método Validate() en requests
- [ ] Crear response DTOs
- [ ] Crear mapper ToResponse()
- [ ] Crear service interface
- [ ] Implementar service con logging y error handling

### Infraestructura
- [ ] Implementar repository con queries SQL
- [ ] Crear handler con error handling
- [ ] Agregar Swagger annotations
- [ ] Actualizar container
- [ ] Agregar rutas en main.go (o router)

### Testing (Opcional pero recomendado)
- [ ] Test unitario de entity
- [ ] Test unitario de service (con mocks)
- [ ] Test unitario de handler (con mocks)
- [ ] Test de integración con testcontainers

---

## 🚀 QUICK START

Para refactorizar tu próximo endpoint en **20 minutos**:

```bash
# 1. Copiar archivos de user/
cp internal/domain/valueobject/user_id.go internal/domain/valueobject/school_id.go
cp internal/domain/entity/user.go internal/domain/entity/school.go
cp internal/domain/repository/user_repository.go internal/domain/repository/school_repository.go
cp internal/application/dto/user_dto.go internal/application/dto/school_dto.go
cp internal/application/service/user_service.go internal/application/service/school_service.go
cp internal/infrastructure/persistence/postgres/repository/user_repository_impl.go internal/infrastructure/persistence/postgres/repository/school_repository_impl.go
cp internal/infrastructure/http/handler/user_handler.go internal/infrastructure/http/handler/school_handler.go

# 2. Buscar y reemplazar
sed -i '' 's/User/School/g' internal/domain/entity/school.go
sed -i '' 's/user/school/g' internal/domain/entity/school.go
# Repetir para todos los archivos...

# 3. Ajustar campos específicos manualmente

# 4. Actualizar container.go

# 5. Compilar
go build ./internal/...

# 6. Si compila, commit!
```

---

## 💡 CONSEJOS PRO

### 1. Empezar por el más simple
- CreateSchool (solo nombre, dirección)
- CreateSubject (solo nombre, descripción)
- Luego los complejos (Units con jerarquía)

### 2. Reusar value objects
- UserID se puede reusar en muchas entities (CreatedBy, AuthorID, etc.)
- Email se reusa en User, Guardian, etc.

### 3. Logger en cada paso
```go
s.logger.Info("starting operation", "field", value)
// operación
s.logger.Info("operation completed", "result", result)
```

### 4. Errors con contexto
```go
return errors.NewNotFoundError("user").
    WithField("user_id", userID).
    WithDetails("user not found in database")
```

### 5. Validación estricta
```go
// DTO: validaciones de formato
v.Email(email, "email")
v.UUID(id, "id")

// Entity: validaciones de negocio
if violatesRule {
    return errors.NewBusinessRuleError("explanation")
}
```

---

## 📦 DEPENDENCIAS DE SHARED POR CAPA

| Capa | Paquetes Usados |
|------|-----------------|
| **Domain** | types, errors |
| **Application** | logger, errors, validator |
| **Infrastructure** | logger, errors, types, database/postgres |
| **Main** | logger, database/postgres, config |

---

## 🎯 RESULTADO ESPERADO

Después de refactorizar un endpoint:

```
✅ Compila sin errores
✅ Logging estructurado en cada paso
✅ Validaciones en DTO con shared/validator
✅ Error handling con shared/errors
✅ Códigos HTTP correctos automáticamente
✅ Lógica de negocio en entity
✅ Persistencia en repository
✅ Handler delgado (solo HTTP)
✅ Testeable con mocks
✅ Código profesional
```

---

## 🔗 REFERENCIAS

- Ejemplo completo: `EJEMPLO_IMPLEMENTACION_COMPLETO.md`
- Shared: `GUIA_USO_SHARED.md`
- Arquitectura: `INFORME_ARQUITECTURA.md`
- Código fuente:
  - `source/api-administracion/internal/domain/entity/user.go`
  - `source/api-administracion/internal/domain/entity/guardian_relation.go`

---

**¡Con esta guía puedes refactorizar todos los endpoints en 1-2 días!** 🚀

**Tiempo por endpoint:** 1-2 horas
**Endpoints restantes:** 10
**Total:** 10-20 horas = 1.5-2.5 días de trabajo

---

**FIN DE LA GUÍA RÁPIDA**
