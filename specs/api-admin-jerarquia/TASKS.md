# Plan de Tareas - api-administracion Jerarquía Académica

**Proyecto:** edugo-api-administracion  
**Epic:** Modernización + Jerarquía Académica  
**Fecha Inicio:** (TBD)  
**Duración Estimada:** 24 días (~5 semanas)

---

## 📋 ÍNDICE DE FASES

| Fase | Nombre | Duración | Compilable | PR |
|------|--------|----------|------------|-----|
| [Fase 0](#fase-0) | Migrar utilidades a shared | 3 días | ✅ | PR-0 |
| [Fase 1](#fase-1) | Modernizar arquitectura | 5 días | ✅ | PR-1 |
| [Fase 2](#fase-2) | Schema BD jerarquía | 2 días | ✅ | PR-2 |
| [Fase 3](#fase-3) | Dominio jerarquía | 3 días | ✅ | PR-2 |
| [Fase 4](#fase-4) | Services jerarquía | 3 días | ✅ | PR-3 |
| [Fase 5](#fase-5) | API REST jerarquía | 4 días | ✅ | PR-3 |
| [Fase 6](#fase-6) | Testing completo | 3 días | ✅ | PR-4 |
| [Fase 7](#fase-7) | CI/CD | 1 día | ✅ | PR-4 |

**Total:** 8 fases, 4-5 PRs, 24 días

---

## 🔧 FASE 0: Migrar Utilidades a Shared

**Proyecto:** `edugo-shared`  
**Branch:** `feature/shared-bootstrap-migration`  
**Duración:** 3 días  
**Precedentes:** Ninguno  
**PR:** PR-0 → `shared/dev`

### Objetivo
Migrar bootstrap system y testcontainers helpers de `api-mobile` a `shared` para reutilizar en `api-admin`.

---

### Día 1: Setup y Análisis

- [ ] **T0.1.1** Crear rama `feature/shared-bootstrap-migration` desde `dev` en edugo-shared
- [ ] **T0.1.2** Verificar que rama `dev` existe en shared (sino crearla desde main)
- [ ] **T0.1.3** Pull última versión de `dev`
- [ ] **T0.1.4** Copiar carpeta `api-mobile/internal/bootstrap/` a `shared/bootstrap/`
- [ ] **T0.1.5** Renombrar imports para que usen `shared` en lugar de `api-mobile`
- [ ] **T0.1.6** Compilar y verificar que no hay errores

**Entregable Día 1:** Carpeta `bootstrap/` en shared compila ✅

---

### Día 2: Testcontainers Helpers

- [ ] **T0.2.1** Crear carpeta `shared/testing/` si no existe
- [ ] **T0.2.2** Crear `shared/testing/containers/postgres.go`
  ```go
  func NewPostgresContainer(ctx context.Context) (*PostgresContainer, error)
  func (c *PostgresContainer) ConnectionString() string
  func (c *PostgresContainer) Cleanup(ctx context.Context) error
  ```
- [ ] **T0.2.3** Crear `shared/testing/containers/mongodb.go`
  ```go
  func NewMongoDBContainer(ctx context.Context) (*MongoDBContainer, error)
  ```
- [ ] **T0.2.4** Crear `shared/testing/containers/rabbitmq.go`
  ```go
  func NewRabbitMQContainer(ctx context.Context) (*RabbitMQContainer, error)
  ```
- [ ] **T0.2.5** Agregar tests unitarios para cada helper
- [ ] **T0.2.6** Actualizar `shared/go.mod` con dependencias de testcontainers

**Entregable Día 2:** Helpers de testcontainers funcionando ✅

---

### Día 3: Actualizar api-mobile para Usar Shared

- [ ] **T0.3.1** En `api-mobile`: Cambiar imports de `internal/bootstrap` a `shared/bootstrap`
- [ ] **T0.3.2** En `api-mobile`: Cambiar setup de testcontainers a `shared/testing/containers`
- [ ] **T0.3.3** Ejecutar tests de `api-mobile`: `make test`
- [ ] **T0.3.4** Verificar que todos los tests pasan
- [ ] **T0.3.5** Commit en `shared`: "feat: agregar bootstrap y testcontainers helpers"
- [ ] **T0.3.6** Push y crear PR-0: `feature/shared-bootstrap-migration` → `shared/dev`
- [ ] **T0.3.7** Esperar aprobación de PR-0

**Entregable Día 3:** PR-0 listo para revisión ✅

**⚠️ BLOQUEANTE:** Fase 1 requiere que PR-0 esté mergeado.

---

## 🏗️ FASE 1: Modernizar Arquitectura de api-admin

**Proyecto:** `edugo-api-administracion`  
**Branch:** `feature/admin-modernizacion`  
**Duración:** 5 días  
**Precedentes:** ✅ Fase 0 completada (shared actualizado)  
**PR:** PR-1 → `api-admin/dev`

### Objetivo
Migrar arquitectura de api-admin desde código legacy a Clean Architecture moderna, usando patrón de api-mobile.

---

### Día 1: Setup Inicial

- [ ] **T1.1.1** Verificar rama `dev` en api-admin (sino crearla desde main)
- [ ] **T1.1.2** Crear rama `feature/admin-modernizacion` desde `dev`
- [ ] **T1.1.3** Actualizar `go.mod` con nuevas versiones de `shared`
  ```bash
  go get github.com/EduGoGroup/edugo-shared/bootstrap@latest
  go get github.com/EduGoGroup/edugo-shared/testing@latest
  ```
- [ ] **T1.1.4** Ejecutar `go mod tidy`
- [ ] **T1.1.5** Compilar para verificar: `go build ./...`

**Checkpoint:** Proyecto compila con shared actualizado ✅

---

### Día 2: Migrar Bootstrap System

- [ ] **T1.2.1** Crear `internal/bootstrap/bootstrap.go` (copiar patrón de api-mobile)
- [ ] **T1.2.2** Crear `internal/bootstrap/config.go`
- [ ] **T1.2.3** Crear `internal/bootstrap/factories.go`
- [ ] **T1.2.4** Crear `internal/bootstrap/lifecycle.go`
- [ ] **T1.2.5** Crear `internal/bootstrap/interfaces.go`
- [ ] **T1.2.6** Adaptar `cmd/main.go` para usar nuevo bootstrap
- [ ] **T1.2.7** Compilar: `make build`
- [ ] **T1.2.8** Ejecutar localmente: `make run`
- [ ] **T1.2.9** Verificar health check: `curl localhost:8081/health`

**Checkpoint:** API arranca con nuevo bootstrap ✅

---

### Día 3: Actualizar Container DI

- [ ] **T1.3.1** Refactorizar `internal/container/container.go` (patrón api-mobile)
- [ ] **T1.3.2** Crear `internal/container/infrastructure.go`
- [ ] **T1.3.3** Crear `internal/container/repositories.go`
- [ ] **T1.3.4** Crear `internal/container/services.go`
- [ ] **T1.3.5** Crear `internal/container/handlers.go`
- [ ] **T1.3.6** Actualizar bootstrap para usar nuevo container
- [ ] **T1.3.7** Compilar y ejecutar
- [ ] **T1.3.8** Verificar que endpoints existentes funcionan

**Checkpoint:** DI container modernizado ✅

---

### Día 4: Config y Testcontainers

- [ ] **T1.4.1** Migrar `internal/config/` al patrón de api-mobile
- [ ] **T1.4.2** Agregar `internal/config/validator.go`
- [ ] **T1.4.3** Crear tests de integración con testcontainers
- [ ] **T1.4.4** Crear `test/integration/setup_test.go`
  ```go
  func setupTestDB(t *testing.T) *sql.DB {
      container := containers.NewPostgresContainer(ctx)
      // ...
  }
  ```
- [ ] **T1.4.5** Ejecutar tests: `make test`
- [ ] **T1.4.6** Verificar coverage: `make coverage`

**Checkpoint:** Tests con testcontainers funcionando ✅

---

### Día 5: Limpieza y Documentación

- [ ] **T1.5.1** Eliminar carpeta `internal/models/` (patrón antiguo)
- [ ] **T1.5.2** Eliminar código legacy no usado
- [ ] **T1.5.3** Actualizar README.md con nueva arquitectura
- [ ] **T1.5.4** Actualizar `Makefile` (copiar de api-mobile)
- [ ] **T1.5.5** Ejecutar linting: `make lint`
- [ ] **T1.5.6** Corregir errores de linting
- [ ] **T1.5.7** Commit: "refactor: modernizar arquitectura a Clean Architecture"
- [ ] **T1.5.8** Push y crear PR-1: `feature/admin-modernizacion` → `dev`

**Entregable:** PR-1 listo para revisión ✅

**⚠️ BLOQUEANTE:** Fase 2 requiere que PR-1 esté mergeado.

---

## 🗄️ FASE 2: Schema de Base de Datos

**Proyecto:** `edugo-api-administracion`  
**Branch:** `feature/admin-schema-jerarquia`  
**Duración:** 2 días  
**Precedentes:** ✅ Fase 1 completada (arquitectura modernizada)  
**PR:** PR-2 (junto con Fase 3)

### Objetivo
Implementar las 3 tablas de jerarquía académica en PostgreSQL con índices, constraints y triggers.

---

### Día 1: Crear Tablas

- [ ] **T2.1.1** Crear rama `feature/admin-schema-jerarquia` desde `dev`
- [ ] **T2.1.2** Crear carpeta `scripts/postgresql/` si no existe
- [ ] **T2.1.3** Crear `scripts/postgresql/01_academic_hierarchy.sql`
- [ ] **T2.1.4** Implementar tabla `school`:
  ```sql
  CREATE TABLE school (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      name VARCHAR(255) NOT NULL,
      code VARCHAR(50) NOT NULL UNIQUE,
      address TEXT,
      contact_email VARCHAR(255),
      contact_phone VARCHAR(50),
      metadata JSONB,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
  );
  ```
- [ ] **T2.1.5** Implementar tabla `academic_unit`:
  ```sql
  CREATE TABLE academic_unit (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      parent_unit_id UUID REFERENCES academic_unit(id),
      school_id UUID NOT NULL REFERENCES school(id),
      unit_type VARCHAR(50) NOT NULL,
      display_name VARCHAR(255) NOT NULL,
      code VARCHAR(50),
      description TEXT,
      metadata JSONB,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW(),
      deleted_at TIMESTAMP,
      CHECK (unit_type IN ('school', 'grade', 'section', 'club', 'department'))
  );
  ```
- [ ] **T2.1.6** Implementar tabla `unit_membership`:
  ```sql
  CREATE TABLE unit_membership (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      unit_id UUID NOT NULL REFERENCES academic_unit(id),
      user_id UUID NOT NULL,
      role VARCHAR(50) NOT NULL,
      valid_from DATE,
      valid_until DATE,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW(),
      UNIQUE(unit_id, user_id),
      CHECK (role IN ('owner', 'teacher', 'assistant', 'student', 'guardian'))
  );
  ```
- [ ] **T2.1.7** Agregar función para prevenir ciclos jerárquicos:
  ```sql
  CREATE FUNCTION prevent_circular_hierarchy() RETURNS TRIGGER;
  CREATE TRIGGER check_circular_hierarchy BEFORE INSERT OR UPDATE ON academic_unit;
  ```

**Checkpoint Día 1:** 3 tablas creadas con constraints ✅

---

### Día 2: Índices, Vistas y Seeds

- [ ] **T2.2.1** Agregar índices de performance:
  ```sql
  CREATE INDEX idx_academic_unit_school ON academic_unit(school_id);
  CREATE INDEX idx_academic_unit_parent ON academic_unit(parent_unit_id);
  CREATE INDEX idx_unit_membership_unit ON unit_membership(unit_id);
  CREATE INDEX idx_unit_membership_user ON unit_membership(user_id);
  ```
- [ ] **T2.2.2** Crear vista `v_unit_tree` para consultas jerárquicas (CTE recursivo)
- [ ] **T2.2.3** Crear vista `v_active_memberships`
- [ ] **T2.2.4** Crear `scripts/postgresql/02_seeds_hierarchy.sql` con datos de prueba:
  - 3 escuelas ejemplo
  - 10 unidades académicas
  - 20 membresías
- [ ] **T2.2.5** Probar scripts en PostgreSQL local:
  ```bash
  psql -U edugo -d edugo_dev < scripts/postgresql/01_academic_hierarchy.sql
  psql -U edugo -d edugo_dev < scripts/postgresql/02_seeds_hierarchy.sql
  ```
- [ ] **T2.2.6** Verificar constraints (intentar ciclo, duplicado, etc.)
- [ ] **T2.2.7** Documentar schema en `docs/database/HIERARCHY_SCHEMA.md`

**Checkpoint Día 2:** Schema completo y probado ✅

**⚠️ NO hacer PR aún**, continuar con Fase 3 (dominio) para PR atómico.

---

## 🎨 FASE 3: Capa de Dominio

**Proyecto:** `edugo-api-administracion`  
**Branch:** `feature/admin-schema-jerarquia` (misma que Fase 2)  
**Duración:** 3 días  
**Precedentes:** ✅ Fase 2 completada (schema)  
**PR:** PR-2 (Fase 2 + 3 juntas) → `api-admin/dev`

### Objetivo
Implementar entities, value objects y repositories (interfaces) para jerarquía académica.

---

### Día 1: Entities

- [ ] **T3.1.1** Crear `internal/domain/entity/school.go`
  ```go
  type School struct {
      ID           valueobject.SchoolID
      Name         string
      Code         string
      Address      string
      ContactEmail valueobject.Email
      ContactPhone string
      Metadata     map[string]interface{}
      CreatedAt    time.Time
      UpdatedAt    time.Time
  }
  ```
- [ ] **T3.1.2** Agregar métodos de negocio a `School`:
  - `Validate() error`
  - `UpdateContactInfo(email, phone) error`
- [ ] **T3.1.3** Crear tests unitarios: `school_test.go`
- [ ] **T3.1.4** Crear `internal/domain/entity/academic_unit.go`
  ```go
  type AcademicUnit struct {
      ID           valueobject.UnitID
      ParentUnitID *valueobject.UnitID
      SchoolID     valueobject.SchoolID
      Type         valueobject.UnitType
      DisplayName  string
      Code         string
      Description  string
      Metadata     map[string]interface{}
      CreatedAt    time.Time
      UpdatedAt    time.Time
      DeletedAt    *time.Time
  }
  ```
- [ ] **T3.1.5** Agregar métodos de negocio a `AcademicUnit`:
  - `Validate() error`
  - `CanHaveChildren() bool`
  - `SetParent(parentID) error`
- [ ] **T3.1.6** Crear tests unitarios: `academic_unit_test.go`
- [ ] **T3.1.7** Crear `internal/domain/entity/unit_membership.go`
  ```go
  type UnitMembership struct {
      ID         valueobject.MembershipID
      UnitID     valueobject.UnitID
      UserID     valueobject.UserID
      Role       valueobject.MembershipRole
      ValidFrom  time.Time
      ValidUntil *time.Time
      CreatedAt  time.Time
      UpdatedAt  time.Time
  }
  ```
- [ ] **T3.1.8** Agregar métodos: `IsActive() bool`, `Validate() error`
- [ ] **T3.1.9** Crear tests: `unit_membership_test.go`

**Checkpoint Día 1:** 3 entities con tests ✅

---

### Día 2: Value Objects

- [ ] **T3.2.1** Crear `internal/domain/valueobject/school_id.go`
  ```go
  type SchoolID struct { value string }
  func NewSchoolID() SchoolID
  func SchoolIDFromString(s string) (SchoolID, error)
  ```
- [ ] **T3.2.2** Crear `internal/domain/valueobject/unit_id.go`
- [ ] **T3.2.3** Crear `internal/domain/valueobject/membership_id.go`
- [ ] **T3.2.4** Crear `internal/domain/valueobject/unit_type.go`
  ```go
  type UnitType string
  const (
      UnitTypeSchool     UnitType = "school"
      UnitTypeGrade      UnitType = "grade"
      UnitTypeSection    UnitType = "section"
      UnitTypeClub       UnitType = "club"
      UnitTypeDepartment UnitType = "department"
  )
  ```
- [ ] **T3.2.5** Crear `internal/domain/valueobject/membership_role.go`
  ```go
  type MembershipRole string
  const (
      RoleOwner     MembershipRole = "owner"
      RoleTeacher   MembershipRole = "teacher"
      RoleAssistant MembershipRole = "assistant"
      RoleStudent   MembershipRole = "student"
      RoleGuardian  MembershipRole = "guardian"
  )
  ```
- [ ] **T3.2.6** Agregar tests para cada VO
- [ ] **T3.2.7** Ejecutar tests: `go test ./internal/domain/...`

**Checkpoint Día 2:** Value objects completos ✅

---

### Día 3: Repository Interfaces

- [ ] **T3.3.1** Crear `internal/domain/repository/school_repository.go`
  ```go
  type SchoolRepository interface {
      Create(ctx context.Context, school *entity.School) error
      FindByID(ctx context.Context, id valueobject.SchoolID) (*entity.School, error)
      FindAll(ctx context.Context, offset, limit int) ([]*entity.School, error)
      Update(ctx context.Context, school *entity.School) error
      Delete(ctx context.Context, id valueobject.SchoolID) error
  }
  ```
- [ ] **T3.3.2** Crear `internal/domain/repository/unit_repository.go`
  ```go
  type UnitRepository interface {
      Create(ctx context.Context, unit *entity.AcademicUnit) error
      FindByID(ctx context.Context, id valueobject.UnitID) (*entity.AcademicUnit, error)
      FindBySchool(ctx context.Context, schoolID valueobject.SchoolID) ([]*entity.AcademicUnit, error)
      FindChildren(ctx context.Context, parentID valueobject.UnitID) ([]*entity.AcademicUnit, error)
      GetTree(ctx context.Context, rootID valueobject.UnitID) ([]*entity.AcademicUnit, error)
      Update(ctx context.Context, unit *entity.AcademicUnit) error
      Delete(ctx context.Context, id valueobject.UnitID) error
  }
  ```
- [ ] **T3.3.3** Crear `internal/domain/repository/membership_repository.go`
  ```go
  type MembershipRepository interface {
      Create(ctx context.Context, membership *entity.UnitMembership) error
      FindByUnit(ctx context.Context, unitID valueobject.UnitID) ([]*entity.UnitMembership, error)
      FindByUser(ctx context.Context, userID valueobject.UserID) ([]*entity.UnitMembership, error)
      Delete(ctx context.Context, unitID valueobject.UnitID, userID valueobject.UserID) error
  }
  ```
- [ ] **T3.3.4** Compilar dominio: `go build ./internal/domain/...`
- [ ] **T3.3.5** Commit: "feat(domain): agregar entities y repositories de jerarquía"
- [ ] **T3.3.6** Push y crear PR-2 (DRAFT): `feature/admin-schema-jerarquia` → `dev`

**Checkpoint Día 3:** Dominio completo ✅

**Entregable Fase 2+3:** PR-2 (DRAFT) con schema + dominio, compila ✅

**⚠️ BLOQUEANTE:** Fase 4 requiere PR-2 mergeado.

---

## 🔧 FASE 4: Capa de Aplicación (Services)

**Proyecto:** `edugo-api-administracion`  
**Branch:** `feature/admin-services-jerarquia`  
**Duración:** 3 días  
**Precedentes:** ✅ Fase 3 completada (dominio)  
**PR:** PR-3 (junto con Fase 5)

### Objetivo
Implementar servicios de aplicación, DTOs y mappers.

---

### Día 1: DTOs

- [ ] **T4.1.1** Crear rama `feature/admin-services-jerarquia` desde `dev`
- [ ] **T4.1.2** Crear `internal/application/dto/school_dto.go`
  ```go
  type CreateSchoolRequest struct {
      Name         string `json:"name" validate:"required,min=3,max=255"`
      Code         string `json:"code" validate:"required,min=2,max=50"`
      Address      string `json:"address"`
      ContactEmail string `json:"contact_email" validate:"omitempty,email"`
      ContactPhone string `json:"contact_phone"`
  }
  
  type SchoolResponse struct {
      ID           string    `json:"id"`
      Name         string    `json:"name"`
      Code         string    `json:"code"`
      Address      string    `json:"address"`
      ContactEmail string    `json:"contact_email"`
      ContactPhone string    `json:"contact_phone"`
      CreatedAt    time.Time `json:"created_at"`
      UpdatedAt    time.Time `json:"updated_at"`
  }
  ```
- [ ] **T4.1.3** Crear `internal/application/dto/unit_dto.go`
  ```go
  type CreateUnitRequest struct {
      ParentUnitID *string `json:"parent_unit_id" validate:"omitempty,uuid"`
      Type         string  `json:"type" validate:"required,oneof=grade section club department"`
      DisplayName  string  `json:"display_name" validate:"required"`
      Code         string  `json:"code"`
      Description  string  `json:"description"`
  }
  
  type UnitTreeResponse struct {
      ID          string              `json:"id"`
      DisplayName string              `json:"display_name"`
      Type        string              `json:"type"`
      Children    []UnitTreeResponse  `json:"children"`
  }
  ```
- [ ] **T4.1.4** Crear `internal/application/dto/membership_dto.go`
- [ ] **T4.1.5** Compilar: `go build ./internal/application/dto/...`

**Checkpoint Día 1:** DTOs definidos ✅

---

### Día 2: Services

- [ ] **T4.2.1** Crear `internal/application/service/school_service.go`
  ```go
  type SchoolService struct {
      repo   repository.SchoolRepository
      logger logger.Logger
  }
  
  func (s *SchoolService) Create(ctx context.Context, req dto.CreateSchoolRequest) (*dto.SchoolResponse, error)
  func (s *SchoolService) FindByID(ctx context.Context, id string) (*dto.SchoolResponse, error)
  func (s *SchoolService) List(ctx context.Context, page, limit int) ([]*dto.SchoolResponse, error)
  func (s *SchoolService) Update(ctx context.Context, id string, req dto.UpdateSchoolRequest) error
  func (s *SchoolService) Delete(ctx context.Context, id string) error
  ```
- [ ] **T4.2.2** Crear `internal/application/service/unit_service.go`
  ```go
  func (s *UnitService) Create(ctx context.Context, schoolID string, req dto.CreateUnitRequest) (*dto.UnitResponse, error)
  func (s *UnitService) GetTree(ctx context.Context, unitID string) (*dto.UnitTreeResponse, error)
  func (s *UnitService) List(ctx context.Context, schoolID string) ([]*dto.UnitResponse, error)
  func (s *UnitService) Update(ctx context.Context, id string, req dto.UpdateUnitRequest) error
  func (s *UnitService) Delete(ctx context.Context, id string) error
  ```
- [ ] **T4.2.3** Crear `internal/application/service/membership_service.go`
  ```go
  func (s *MembershipService) Assign(ctx context.Context, unitID, userID string, role string) error
  func (s *MembershipService) List(ctx context.Context, unitID string) ([]*dto.MembershipResponse, error)
  func (s *MembershipService) Remove(ctx context.Context, unitID, userID string) error
  ```
- [ ] **T4.2.4** Crear tests unitarios para cada service (mocks de repos)
- [ ] **T4.2.5** Ejecutar tests: `go test ./internal/application/service/...`

**Checkpoint Día 2:** Services implementados con tests ✅

---

### Día 3: Mappers e Infraestructura (Repositories)

- [ ] **T4.3.1** Crear `internal/application/mapper/school_mapper.go`
  ```go
  func ToSchoolResponse(school *entity.School) *dto.SchoolResponse
  func ToSchoolEntity(req *dto.CreateSchoolRequest) (*entity.School, error)
  ```
- [ ] **T4.3.2** Crear mappers para `unit` y `membership`
- [ ] **T4.3.3** Crear `internal/infrastructure/persistence/postgres/school_repository_impl.go`
  ```go
  type schoolRepositoryImpl struct {
      db *sql.DB
  }
  
  func (r *schoolRepositoryImpl) Create(ctx context.Context, school *entity.School) error {
      _, err := r.db.ExecContext(ctx,
          "INSERT INTO school (id, name, code, address, ...) VALUES ($1, $2, ...)",
          school.ID.String(), school.Name, school.Code, ...
      )
      return err
  }
  ```
- [ ] **T4.3.4** Implementar `unit_repository_impl.go` con query recursivo para `GetTree()`
- [ ] **T4.3.5** Implementar `membership_repository_impl.go`
- [ ] **T4.3.6** Crear tests de integración con testcontainers:
  ```go
  func TestSchoolRepository_Create(t *testing.T) {
      container := containers.NewPostgresContainer(ctx)
      defer container.Cleanup(ctx)
      
      db := container.DB()
      repo := NewSchoolRepository(db)
      // ...
  }
  ```
- [ ] **T4.3.7** Ejecutar tests integración: `make test-integration`
- [ ] **T4.3.8** Commit: "feat(application): agregar services y repositories de jerarquía"
- [ ] **T4.3.9** Marcar PR-2 como READY FOR REVIEW
- [ ] **T4.3.10** Esperar aprobación y merge de PR-2

**Entregable Fase 3:** PR-2 listo (Schema + Dominio + Repos), compila, tests pasan ✅

**⚠️ BLOQUEANTE:** Fase 5 requiere PR-2 mergeado.

---

## 🌐 FASE 5: API REST (Handlers y Routes)

**Proyecto:** `edugo-api-administracion`  
**Branch:** `feature/admin-api-jerarquia`  
**Duración:** 4 días  
**Precedentes:** ✅ Fase 4 completada (services)  
**PR:** PR-3 (Fase 4 + 5 juntas)

### Objetivo
Implementar endpoints REST completos con handlers, validación, y Swagger.

---

### Día 1: Handlers de Escuelas

- [ ] **T5.1.1** Crear rama `feature/admin-api-jerarquia` desde `dev`
- [ ] **T5.1.2** Crear `internal/infrastructure/http/handler/school_handler.go`
  ```go
  type SchoolHandler struct {
      service *service.SchoolService
      logger  logger.Logger
  }
  
  // @Summary Crear escuela
  // @Tags Schools
  // @Accept json
  // @Produce json
  // @Param request body dto.CreateSchoolRequest true "Datos de escuela"
  // @Success 201 {object} dto.SchoolResponse
  // @Router /v1/schools [post]
  func (h *SchoolHandler) Create(c *gin.Context) {
      var req dto.CreateSchoolRequest
      if err := c.ShouldBindJSON(&req); err != nil {
          c.JSON(400, gin.H{"error": "invalid request"})
          return
      }
      
      result, err := h.service.Create(c.Request.Context(), req)
      if err != nil {
          c.JSON(500, gin.H{"error": err.Error()})
          return
      }
      
      c.JSON(201, result)
  }
  
  func (h *SchoolHandler) List(c *gin.Context)     // GET /v1/schools
  func (h *SchoolHandler) GetByID(c *gin.Context)  // GET /v1/schools/:id
  func (h *SchoolHandler) Update(c *gin.Context)   // PUT /v1/schools/:id
  func (h *SchoolHandler) Delete(c *gin.Context)   // DELETE /v1/schools/:id
  ```
- [ ] **T5.1.3** Agregar anotaciones Swagger a todos los handlers
- [ ] **T5.1.4** Crear tests e2e: `school_handler_test.go` (httptest + testcontainers)

**Checkpoint Día 1:** Handlers de escuelas con tests ✅

---

### Día 2: Handlers de Unidades Académicas

- [ ] **T5.2.1** Crear `internal/infrastructure/http/handler/unit_handler.go`
  ```go
  func (h *UnitHandler) Create(c *gin.Context)         // POST /v1/schools/:schoolId/units
  func (h *UnitHandler) List(c *gin.Context)           // GET /v1/schools/:schoolId/units
  func (h *UnitHandler) GetByID(c *gin.Context)        // GET /v1/units/:id
  func (h *UnitHandler) GetTree(c *gin.Context)        // GET /v1/units/:id/tree
  func (h *UnitHandler) GetChildren(c *gin.Context)    // GET /v1/units/:id/children
  func (h *UnitHandler) GetAncestors(c *gin.Context)   // GET /v1/units/:id/ancestors
  func (h *UnitHandler) Update(c *gin.Context)         // PUT /v1/units/:id
  func (h *UnitHandler) Delete(c *gin.Context)         // DELETE /v1/units/:id
  ```
- [ ] **T5.2.2** Implementar lógica de árbol jerárquico en `GetTree()`
- [ ] **T5.2.3** Agregar validación: no eliminar unidad con hijos
- [ ] **T5.2.4** Anotaciones Swagger
- [ ] **T5.2.5** Tests e2e completos

**Checkpoint Día 2:** Handlers de unidades con tests ✅

---

### Día 3: Handlers de Membresías

- [ ] **T5.3.1** Crear `internal/infrastructure/http/handler/membership_handler.go`
  ```go
  func (h *MembershipHandler) Assign(c *gin.Context)   // POST /v1/units/:unitId/members
  func (h *MembershipHandler) List(c *gin.Context)     // GET /v1/units/:unitId/members
  func (h *MembershipHandler) Remove(c *gin.Context)   // DELETE /v1/units/:unitId/members/:userId
  ```
- [ ] **T5.3.2** Validar que user existe (consulta a tabla users compartida)
- [ ] **T5.3.3** Validar roles permitidos
- [ ] **T5.3.4** Anotaciones Swagger
- [ ] **T5.3.5** Tests e2e

**Checkpoint Día 3:** Handlers de membresías con tests ✅

---

### Día 4: Router y Middleware

- [ ] **T5.4.1** Actualizar `internal/infrastructure/http/router/router.go`
  ```go
  v1 := r.Group("/v1")
  {
      // Schools
      schools := v1.Group("/schools")
      schools.Use(middleware.RequireAdmin())  // Solo admins
      {
          schools.POST("", handlers.School.Create)
          schools.GET("", handlers.School.List)
          schools.GET("/:id", handlers.School.GetByID)
          schools.PUT("/:id", handlers.School.Update)
          schools.DELETE("/:id", handlers.School.Delete)
          
          // Units nested under school
          schools.POST("/:schoolId/units", handlers.Unit.Create)
          schools.GET("/:schoolId/units", handlers.Unit.List)
      }
      
      // Units (standalone)
      units := v1.Group("/units")
      units.Use(middleware.RequireAdmin())
      {
          units.GET("/:id", handlers.Unit.GetByID)
          units.GET("/:id/tree", handlers.Unit.GetTree)
          units.GET("/:id/children", handlers.Unit.GetChildren)
          units.PUT("/:id", handlers.Unit.Update)
          units.DELETE("/:id", handlers.Unit.Delete)
          
          // Memberships nested under unit
          units.POST("/:unitId/members", handlers.Membership.Assign)
          units.GET("/:unitId/members", handlers.Membership.List)
          units.DELETE("/:unitId/members/:userId", handlers.Membership.Remove)
      }
  }
  ```
- [ ] **T5.4.2** Crear middleware `RequireAdmin()` si no existe
- [ ] **T5.4.3** Actualizar container para inyectar nuevos handlers
- [ ] **T5.4.4** Compilar: `make build`
- [ ] **T5.4.5** Ejecutar localmente: `make run`
- [ ] **T5.4.6** Probar endpoints con curl/Postman
- [ ] **T5.4.7** Generar Swagger: `make swagger`
- [ ] **T5.4.8** Commit: "feat(api): agregar endpoints REST de jerarquía"
- [ ] **T5.4.9** Push y crear PR-3 (DRAFT)

**Entregable Fase 4+5:** PR-3 con services + API, compila, API funciona ✅

**⚠️ BLOQUEANTE:** Fase 6 requiere PR-3 mergeado.

---

## 🧪 FASE 6: Testing Completo

**Proyecto:** `edugo-api-administracion`  
**Branch:** `feature/admin-tests`  
**Duración:** 3 días  
**Precedentes:** ✅ Fase 5 completada (API REST)  
**PR:** PR-4 (junto con Fase 7)

### Objetivo
Alcanzar >80% code coverage con tests unitarios, integración y e2e.

---

### Día 1: Tests Unitarios

- [ ] **T6.1.1** Crear rama `feature/admin-tests` desde `dev`
- [ ] **T6.1.2** Revisar coverage actual: `make coverage`
- [ ] **T6.1.3** Agregar tests faltantes en `domain/entity/`
- [ ] **T6.1.4** Agregar tests faltantes en `domain/valueobject/`
- [ ] **T6.1.5** Agregar tests de services con mocks:
  ```go
  func TestSchoolService_Create(t *testing.T) {
      mockRepo := &mocks.SchoolRepository{}
      mockRepo.On("Create", mock.Anything, mock.Anything).Return(nil)
      
      service := NewSchoolService(mockRepo, logger)
      result, err := service.Create(ctx, createReq)
      
      assert.NoError(t, err)
      assert.NotNil(t, result)
      mockRepo.AssertExpectations(t)
  }
  ```
- [ ] **T6.1.6** Ejecutar: `go test ./internal/domain/... ./internal/application/...`
- [ ] **T6.1.7** Verificar coverage dominio + application >90%

**Checkpoint Día 1:** Tests unitarios completos ✅

---

### Día 2: Tests de Integración

- [ ] **T6.2.1** Crear `test/integration/school_repository_test.go`
  ```go
  func TestSchoolRepository_Integration(t *testing.T) {
      container := containers.NewPostgresContainer(ctx)
      defer container.Cleanup(ctx)
      
      db := container.DB()
      // Ejecutar migrations
      execSQL(db, "scripts/postgresql/01_academic_hierarchy.sql")
      
      repo := NewSchoolRepository(db)
      
      // Test Create
      school := &entity.School{...}
      err := repo.Create(ctx, school)
      assert.NoError(t, err)
      
      // Test FindByID
      found, err := repo.FindByID(ctx, school.ID)
      assert.NoError(t, err)
      assert.Equal(t, school.Name, found.Name)
  }
  ```
- [ ] **T6.2.2** Tests integración para `unit_repository` (especialmente `GetTree()`)
- [ ] **T6.2.3** Tests integración para `membership_repository`
- [ ] **T6.2.4** Tests de constraints (ciclos, duplicados)
- [ ] **T6.2.5** Ejecutar: `make test-integration`
- [ ] **T6.2.6** Verificar coverage infrastructure >75%

**Checkpoint Día 2:** Tests de integración completos ✅

---

### Día 3: Tests E2E

- [ ] **T6.3.1** Crear `test/e2e/hierarchy_flow_test.go`
  ```go
  func TestHierarchyCompleteFlow(t *testing.T) {
      // Setup: API + PostgreSQL con testcontainers
      
      // 1. Crear escuela
      resp := POST("/v1/schools", createSchoolReq)
      assert.Equal(t, 201, resp.StatusCode)
      schoolID := resp.Body.ID
      
      // 2. Crear año académico
      resp = POST("/v1/schools/"+schoolID+"/units", createGradeReq)
      assert.Equal(t, 201, resp.StatusCode)
      gradeID := resp.Body.ID
      
      // 3. Crear sección
      resp = POST("/v1/schools/"+schoolID+"/units", createSectionReq)
      assert.Equal(t, 201, resp.StatusCode)
      
      // 4. Obtener árbol jerárquico
      resp = GET("/v1/units/"+gradeID+"/tree")
      assert.Equal(t, 200, resp.StatusCode)
      assert.Len(t, resp.Body.Children, 1)  // La sección
      
      // 5. Asignar estudiante
      resp = POST("/v1/units/"+sectionID+"/members", assignReq)
      assert.Equal(t, 201, resp.StatusCode)
      
      // 6. Listar miembros
      resp = GET("/v1/units/"+sectionID+"/members")
      assert.Len(t, resp.Body, 1)
  }
  ```
- [ ] **T6.3.2** Test e2e de validaciones (ciclos, duplicados)
- [ ] **T6.3.3** Test e2e de casos de error
- [ ] **T6.3.4** Ejecutar: `make test-e2e`
- [ ] **T6.3.5** Ejecutar coverage total: `make coverage`
- [ ] **T6.3.6** Verificar >80% global
- [ ] **T6.3.7** Commit: "test: agregar tests completos de jerarquía académica"

**Checkpoint Día 3:** Tests e2e completos, coverage >80% ✅

**⚠️ NO hacer PR aún**, continuar con Fase 7 (CI/CD).

---

## ⚙️ FASE 7: CI/CD

**Proyecto:** `edugo-api-administracion`  
**Branch:** `feature/admin-tests` (misma que Fase 6)  
**Duración:** 1 día  
**Precedentes:** ✅ Fase 6 completada (tests)  
**PR:** PR-4 (Fase 6 + 7 juntas) → `api-admin/dev`

### Objetivo
Configurar GitHub Actions completo copiando workflows de api-mobile.

---

### Día 1: Workflows

- [ ] **T7.1.1** Copiar `.github/workflows/` de api-mobile a api-admin
- [ ] **T7.1.2** Actualizar `pr-to-dev.yml`:
  - Cambiar nombre del proyecto
  - Ajustar paths si es necesario
- [ ] **T7.1.3** Actualizar `pr-to-main.yml`
- [ ] **T7.1.4** Actualizar `test.yml`
- [ ] **T7.1.5** Actualizar `sync-main-to-dev.yml`
- [ ] **T7.1.6** Crear `manual-release.yml` si no existe
- [ ] **T7.1.7** Commit: "ci: agregar workflows de GitHub Actions"
- [ ] **T7.1.8** Push rama
- [ ] **T7.1.9** Crear PR-4: `feature/admin-tests` → `dev`
- [ ] **T7.1.10** Verificar que workflow `test.yml` se ejecuta automáticamente en el PR
- [ ] **T7.1.11** Verificar que todos los checks pasan (tests, lint, build)
- [ ] **T7.1.12** Marcar PR-4 como READY FOR REVIEW

**Entregable Fase 7:** PR-4 listo, CI/CD funcionando ✅

---

## 📊 RESUMEN DE ENTREGAS (PRs)

| PR | Título | Fases | Archivos | Tests | Compila | CI/CD |
|----|--------|-------|----------|-------|---------|-------|
| **PR-0** | Migrar bootstrap a shared | Fase 0 | ~15 | ✅ | ✅ | ✅ |
| **PR-1** | Modernizar arquitectura api-admin | Fase 1 | ~20 | ✅ | ✅ | 🟡 |
| **PR-2** | Schema + Dominio jerarquía | Fase 2-3 | ~30 | ✅ | ✅ | 🟡 |
| **PR-3** | Services + API jerarquía | Fase 4-5 | ~25 | ✅ | ✅ | 🟡 |
| **PR-4** | Tests + CI/CD | Fase 6-7 | ~20 | ✅ | ✅ | ✅ |

**Total:** 4-5 PRs, ~110 archivos modificados/creados

---

## ✅ CHECKLIST GLOBAL DE PROGRESO

### Fase 0: Shared (edugo-shared)
- [ ] Bootstrap migrado
- [ ] Testcontainers helpers creados
- [ ] PR-0 creado
- [ ] PR-0 aprobado y mergeado

### Fase 1: Modernización (api-admin)
- [ ] Bootstrap system implementado
- [ ] Container DI actualizado
- [ ] Config con validación
- [ ] Testcontainers funcionando
- [ ] PR-1 creado
- [ ] PR-1 aprobado y mergeado

### Fase 2-3: Schema + Dominio (api-admin)
- [ ] 3 tablas creadas (school, academic_unit, unit_membership)
- [ ] Índices y constraints
- [ ] Trigger para prevenir ciclos
- [ ] 3 entities implementadas
- [ ] Value objects completos
- [ ] Repository interfaces
- [ ] Repository implementations
- [ ] Tests unitarios de dominio
- [ ] Tests integración de repos
- [ ] PR-2 creado
- [ ] PR-2 aprobado y mergeado

### Fase 4-5: Services + API (api-admin)
- [ ] Services de escuelas, unidades, membresías
- [ ] DTOs y mappers
- [ ] Handlers REST completos (15 endpoints)
- [ ] Router actualizado
- [ ] Swagger generado
- [ ] Tests e2e de API
- [ ] PR-3 creado
- [ ] PR-3 aprobado y mergeado

### Fase 6-7: Tests + CI/CD (api-admin)
- [ ] Coverage >80%
- [ ] Workflows CI/CD actualizados
- [ ] PR-4 creado
- [ ] PR-4 aprobado y mergeado
- [ ] CI/CD pasando en `dev`

### Final
- [ ] Todas las fases completadas
- [ ] Todos los PRs mergeados a `dev`
- [ ] API desplegada a ambiente dev
- [ ] Validación manual exitosa
- [ ] Documentación actualizada
- [ ] Sprint declarado como DONE ✅

---

## 🚨 DEPENDENCIAS ENTRE TAREAS

### Diagrama de Precedencias

```
Fase 0 (Shared)
    ↓
Fase 1 (Modernización)
    ↓
Fase 2 (Schema) → Fase 3 (Dominio)
    ↓
Fase 4 (Services) → Fase 5 (API)
    ↓
Fase 6 (Tests) → Fase 7 (CI/CD)
```

**Regla:** No avanzar a siguiente fase sin completar precedente.

---

## 📝 NOTAS IMPORTANTES

### Commits
- Formato: `tipo(scope): descripción`
- Tipos: `feat`, `fix`, `refactor`, `test`, `docs`, `ci`, `chore`
- Ejemplos:
  - `feat(domain): agregar entity School`
  - `test(integration): agregar tests de repository`
  - `ci: actualizar workflow pr-to-dev`

### Cada Fase Debe
1. ✅ Compilar sin errores
2. ✅ Tests pasar (si existen)
3. ✅ Linting sin errores
4. ✅ Ser revisable independientemente

---

**Próximo paso:** Revisar `USER_STORIES.md` y `DESIGN.md`

---

**Generado con** 🤖 Claude Code
