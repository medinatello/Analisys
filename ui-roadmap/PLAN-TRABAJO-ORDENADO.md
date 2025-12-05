# Plan de Trabajo Ordenado - EduGo UI Roadmap

> **Documento de Ejecución**: Orden secuencial de tareas para implementar todo el roadmap de UI.

**Fecha**: 1 de Diciembre, 2025
**Metodología**: Infraestructura → APIs → Cross-Platform → App Estudiantes → App Admin

---

## Filosofía del Plan

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORDEN DE EJECUCIÓN                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  FASE 1: BASE DE DATOS (edugo-infrastructure)                  │
│     ↓                                                           │
│  FASE 2: APIs (api-mobile primero, luego api-admin)            │
│     ↓                                                           │
│  FASE 3: MÓDULOS CROSS (SPM compartidos)                       │
│     ↓                                                           │
│  FASE 4: APP ESTUDIANTES (completa)                            │
│     ↓                                                           │
│  FASE 5: APP ADMINISTRACIÓN (completa)                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Razón del orden**:
- Sin BD → APIs no pueden funcionar
- Sin APIs → Apps no tienen datos
- Sin módulos cross → Duplicación de código entre apps
- App estudiantes primero → 95% de usuarios, MVP

---

## FASE 1: Base de Datos (edugo-infrastructure)

**Responsable**: edugo-infrastructure
**Ubicación**: `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure`
**Duración estimada**: 1-2 días

### 1.1 Nuevas Tablas PostgreSQL

#### Tarea 1.1.1: Tabla `user_active_context`
**Prioridad**: 🔴 CRÍTICA
**Bloquea**: Selector de escuela en UI

```sql
-- Migración: YYYYMMDD_create_user_active_context.sql

CREATE TABLE user_active_context (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    unit_id UUID REFERENCES academic_units(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT uq_user_active_context_user UNIQUE(user_id)
);

-- Índices
CREATE INDEX idx_user_active_context_user ON user_active_context(user_id);
CREATE INDEX idx_user_active_context_school ON user_active_context(school_id);

-- Trigger para updated_at
CREATE TRIGGER set_updated_at_user_active_context
    BEFORE UPDATE ON user_active_context
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE user_active_context IS 'Almacena el contexto/escuela activa del usuario para filtrar datos';
```

**Validaciones**:
- `user_id` debe existir en `users`
- `school_id` debe existir en `schools`
- Usuario debe tener membership activa en esa escuela (validar en API)

---

#### Tarea 1.1.2: Tabla `user_favorites`
**Prioridad**: 🟡 MEDIA
**Bloquea**: Funcionalidad de favoritos

```sql
-- Migración: YYYYMMDD_create_user_favorites.sql

CREATE TABLE user_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT uq_user_favorites_user_material UNIQUE(user_id, material_id)
);

-- Índices
CREATE INDEX idx_user_favorites_user ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_material ON user_favorites(material_id);
CREATE INDEX idx_user_favorites_created ON user_favorites(created_at DESC);

COMMENT ON TABLE user_favorites IS 'Materiales marcados como favoritos por usuarios';
```

---

#### Tarea 1.1.3: Tabla `user_activity_log`
**Prioridad**: 🟡 MEDIA
**Bloquea**: Actividad reciente en Home

```sql
-- Migración: YYYYMMDD_create_user_activity_log.sql

CREATE TYPE activity_type AS ENUM (
    'material_started',
    'material_progress',
    'material_completed',
    'summary_viewed',
    'quiz_started',
    'quiz_completed',
    'quiz_passed',
    'quiz_failed'
);

CREATE TABLE user_activity_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type activity_type NOT NULL,
    material_id UUID REFERENCES materials(id) ON DELETE SET NULL,
    school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para queries frecuentes
CREATE INDEX idx_user_activity_user_created ON user_activity_log(user_id, created_at DESC);
CREATE INDEX idx_user_activity_school ON user_activity_log(school_id, created_at DESC);
CREATE INDEX idx_user_activity_type ON user_activity_log(activity_type);

-- Particionamiento por fecha (opcional, para escala)
-- CREATE TABLE user_activity_log_y2025m12 PARTITION OF user_activity_log
--     FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

COMMENT ON TABLE user_activity_log IS 'Log de actividades del usuario para historial y analytics';
```

---

### 1.2 Migraciones Futuras (Fase Admin)

> 📄 **Definiciones SQL completas**: Ver **[MIGRACIONES-ADMIN.md](./MIGRACIONES-ADMIN.md)** para el código SQL detallado de cada tabla.

Estas se implementarán cuando se trabaje la app de administración:

| Tabla | Prioridad | Sprint | Definición SQL |
|-------|-----------|--------|----------------|
| `academic_cycles` | 🟡 Media | Admin Sprint 2 | [Ver SQL](./MIGRACIONES-ADMIN.md#1-tabla-academic_cycles) |
| `academic_periods` | 🟡 Media | Admin Sprint 2 | [Ver SQL](./MIGRACIONES-ADMIN.md#2-tabla-academic_periods) |
| `classrooms` | 🟢 Baja | Admin Sprint 3 | [Ver SQL](./MIGRACIONES-ADMIN.md#3-tabla-classrooms-prerequisito-para-schedules) |
| `schedules` | 🟡 Media | Admin Sprint 3 | [Ver SQL](./MIGRACIONES-ADMIN.md#4-tabla-schedules) |
| `schedule_blocks` | 🟡 Media | Admin Sprint 3 | [Ver SQL](./MIGRACIONES-ADMIN.md#5-tabla-schedule_blocks) |
| `import_jobs` | 🟡 Media | Admin Sprint 3 | [Ver SQL](./MIGRACIONES-ADMIN.md#6-tabla-import_jobs) |
| `school_events` | 🟢 Baja | Admin Sprint 4 | [Ver SQL](./MIGRACIONES-ADMIN.md#7-tabla-school_events) |
| `event_participants` | 🟢 Baja | Admin Sprint 4 | [Ver SQL](./MIGRACIONES-ADMIN.md#8-tabla-event_participants) |
| `grading_scales` | 🟢 Baja | Admin Sprint 5 | [Ver SQL](./MIGRACIONES-ADMIN.md#9-tabla-grading_scales) |
| `grading_scale_ranges` | 🟢 Baja | Admin Sprint 5 | [Ver SQL](./MIGRACIONES-ADMIN.md#10-tabla-grading_scale_ranges) |
| `custom_roles` | 🟢 Baja | Admin Sprint 5 | [Ver SQL](./MIGRACIONES-ADMIN.md#11-tabla-custom_roles) |
| `role_permissions` | 🟢 Baja | Admin Sprint 5 | [Ver SQL](./MIGRACIONES-ADMIN.md#12-tabla-role_permissions) |
| `certificates` | 🟢 Baja | Admin Sprint 6 | [Ver SQL](./MIGRACIONES-ADMIN.md#13-tabla-certificates) |
| `generated_certificates` | 🟢 Baja | Admin Sprint 6 | [Ver SQL](./MIGRACIONES-ADMIN.md#14-tabla-generated_certificates) |
| `fee_concepts` | 🟢 Baja | Admin Sprint 6 | [Ver SQL](./MIGRACIONES-ADMIN.md#15-tabla-fee_concepts) |
| `payments` | 🟢 Baja | Admin Sprint 6 | [Ver SQL](./MIGRACIONES-ADMIN.md#16-tabla-payments) |

---

### 1.3 Checklist Fase 1

```
□ 1.1.1 Crear migración user_active_context
□ 1.1.2 Crear migración user_favorites
□ 1.1.3 Crear migración user_activity_log
□ Ejecutar migraciones en ambiente local
□ Ejecutar migraciones en ambiente dev
□ Verificar índices creados correctamente
□ Documentar en README de infrastructure
```

**Criterio de completitud**: Migraciones ejecutadas en dev sin errores.

---

## FASE 2: APIs

### 2.1 API-Mobile (Puerto 8080) - PRIMERO

**Responsable**: edugo-api-mobile
**Ubicación**: `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile`
**Duración estimada**: 1-2 semanas

#### Sprint API-Mobile 1: Contexto de Usuario (CRÍTICO)

| # | Endpoint | Método | Esfuerzo | Dependencia BD |
|---|----------|--------|----------|----------------|
| 2.1.1 | `/v1/users/me` | GET | 2h | users (existe) |
| 2.1.2 | `/v1/users/me/schools` | GET | 4h | memberships, schools |
| 2.1.3 | `/v1/users/me/active-school` | GET | 2h | user_active_context |
| 2.1.4 | `/v1/users/me/active-school` | POST | 3h | user_active_context |

**Orden de implementación**: 2.1.1 → 2.1.2 → 2.1.3 → 2.1.4

---

##### Tarea 2.1.1: GET /v1/users/me

**Archivo**: `internal/infrastructure/http/handler/user_handler.go`

```go
// Handler
func (h *UserHandler) GetCurrentUser(c *gin.Context) {
    userID := ginmiddleware.MustGetUserID(c)

    user, err := h.userService.GetByID(c.Request.Context(), userID)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "user_not_found"})
        return
    }

    c.JSON(http.StatusOK, dto.ToUserResponse(user))
}
```

**Ruta**: `router.go`
```go
userGroup := v1.Group("/users")
{
    userGroup.GET("/me", authMiddleware, userHandler.GetCurrentUser)
}
```

**DTO Response**:
```go
type UserMeResponse struct {
    ID        uuid.UUID  `json:"id"`
    Email     string     `json:"email"`
    FirstName string     `json:"first_name"`
    LastName  string     `json:"last_name"`
    FullName  string     `json:"full_name"`
    AvatarURL *string    `json:"avatar_url"`
    Role      string     `json:"role"`
    IsActive  bool       `json:"is_active"`
    CreatedAt time.Time  `json:"created_at"`
    UpdatedAt time.Time  `json:"updated_at"`
}
```

---

##### Tarea 2.1.2: GET /v1/users/me/schools

**Archivo**: `internal/infrastructure/http/handler/user_context_handler.go` (nuevo)

```go
func (h *UserContextHandler) GetUserSchools(c *gin.Context) {
    userID := ginmiddleware.MustGetUserID(c)

    schools, err := h.contextService.GetUserSchools(c.Request.Context(), userID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal_error"})
        return
    }

    // Obtener escuela activa
    activeSchoolID, _ := h.contextService.GetActiveSchool(c.Request.Context(), userID)

    c.JSON(http.StatusOK, dto.UserSchoolsResponse{
        Schools:        dto.ToSchoolsWithRoles(schools),
        ActiveSchoolID: activeSchoolID,
        TotalCount:     len(schools),
    })
}
```

**Service** (nuevo): `internal/application/service/user_context_service.go`

```go
type UserContextService interface {
    GetUserSchools(ctx context.Context, userID uuid.UUID) ([]SchoolWithRoles, error)
    GetActiveSchool(ctx context.Context, userID uuid.UUID) (*uuid.UUID, error)
    SetActiveSchool(ctx context.Context, userID, schoolID uuid.UUID) error
}
```

**Repository** (nuevo): `internal/domain/repository/user_context_repository.go`

```go
type UserContextRepository interface {
    GetSchoolsByUser(ctx context.Context, userID uuid.UUID) ([]SchoolWithMembership, error)
    GetActiveContext(ctx context.Context, userID uuid.UUID) (*UserActiveContext, error)
    UpsertActiveContext(ctx context.Context, ctx UserActiveContext) error
}
```

---

##### Tarea 2.1.3: GET /v1/users/me/active-school

```go
func (h *UserContextHandler) GetActiveSchool(c *gin.Context) {
    userID := ginmiddleware.MustGetUserID(c)

    context, err := h.contextService.GetActiveContext(c.Request.Context(), userID)
    if err != nil {
        c.JSON(http.StatusOK, gin.H{"school_id": nil, "message": "No hay escuela activa"})
        return
    }

    c.JSON(http.StatusOK, dto.ToActiveSchoolResponse(context))
}
```

---

##### Tarea 2.1.4: POST /v1/users/me/active-school

```go
func (h *UserContextHandler) SetActiveSchool(c *gin.Context) {
    userID := ginmiddleware.MustGetUserID(c)

    var req dto.SetActiveSchoolRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid_request"})
        return
    }

    // Validar que usuario tiene membership en esa escuela
    hasMembership, err := h.contextService.ValidateUserSchoolAccess(c.Request.Context(), userID, req.SchoolID)
    if err != nil || !hasMembership {
        c.JSON(http.StatusForbidden, gin.H{"error": "forbidden", "message": "No tiene acceso a esta escuela"})
        return
    }

    if err := h.contextService.SetActiveSchool(c.Request.Context(), userID, req.SchoolID); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal_error"})
        return
    }

    // Obtener datos completos para response
    context, _ := h.contextService.GetActiveContext(c.Request.Context(), userID)

    c.JSON(http.StatusOK, dto.ToActiveSchoolResponse(context))
}
```

---

#### Sprint API-Mobile 2: Estadísticas y Actividad

| # | Endpoint | Método | Esfuerzo | Dependencia BD |
|---|----------|--------|----------|----------------|
| 2.1.5 | `/v1/users/me/stats` | GET | 6h | progress, assessment_attempt |
| 2.1.6 | `/v1/users/me/activity` | GET | 4h | user_activity_log |

---

##### Tarea 2.1.5: GET /v1/users/me/stats

**Archivo**: `internal/infrastructure/http/handler/stats_handler.go`

```go
func (h *StatsHandler) GetUserStats(c *gin.Context) {
    userID := ginmiddleware.MustGetUserID(c)

    // Obtener contexto activo para filtrar
    activeSchoolID, _ := h.contextService.GetActiveSchool(c.Request.Context(), userID)

    stats, err := h.statsService.GetUserStats(c.Request.Context(), userID, activeSchoolID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal_error"})
        return
    }

    c.JSON(http.StatusOK, stats)
}
```

**Service**: Calcular estadísticas agregando datos de:
- `progress` → materiales completados, en progreso
- `assessment_attempt` → quizzes, scores
- `user_activity_log` → última actividad

---

##### Tarea 2.1.6: GET /v1/users/me/activity

```go
func (h *UserContextHandler) GetUserActivity(c *gin.Context) {
    userID := ginmiddleware.MustGetUserID(c)
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

    activities, err := h.activityService.GetRecentActivity(c.Request.Context(), userID, limit)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal_error"})
        return
    }

    c.JSON(http.StatusOK, dto.UserActivityResponse{
        Activities: dto.ToActivityList(activities),
        TotalCount: len(activities),
    })
}
```

---

#### Sprint API-Mobile 3: Favoritos

| # | Endpoint | Método | Esfuerzo | Dependencia BD |
|---|----------|--------|----------|----------------|
| 2.1.7 | `/v1/materials/:id/favorite` | POST | 2h | user_favorites |
| 2.1.8 | `/v1/materials/:id/favorite` | DELETE | 1h | user_favorites |
| 2.1.9 | `/v1/users/me/favorites` | GET | 2h | user_favorites |

---

#### Sprint API-Mobile 4: Modificaciones

| # | Cambio | Esfuerzo |
|---|--------|----------|
| 2.1.10 | Modificar `GET /v1/materials` para filtrar por escuela activa | 2h |
| 2.1.11 | Agregar logging a `user_activity_log` en endpoints existentes | 3h |

---

### 2.2 API-Admin (Puerto 8081) - DESPUÉS

**Responsable**: edugo-api-administracion
**Ubicación**: `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion`
**Duración estimada**: 4-6 semanas (paralelo con App Estudiantes)

> **Nota**: Los endpoints de api-admin se implementan cuando se trabaje la App de Administración.
> Ver [ENDPOINTS-FALTANTES.md](./administracion/ENDPOINTS-FALTANTES.md) para especificaciones completas.

#### Resumen de Sprints API-Admin

| Sprint | Funcionalidad | Endpoints | Esfuerzo |
|--------|---------------|-----------|----------|
| Admin Sprint 1 | Mejoras usuarios existentes | 3 | 8h |
| Admin Sprint 2 | Ciclos académicos | 6 | 16h |
| Admin Sprint 3 | Horarios | 7 | 24h |
| Admin Sprint 3 | Importación masiva | 4 | 20h |
| Admin Sprint 4 | Aulas y eventos | 12 | 20h |
| Admin Sprint 5 | Reportes y auditoría | 8 | 24h |
| Admin Sprint 6 | Resto (roles, certificados, pagos) | ~20 | 40h |

---

### 2.3 Checklist Fase 2

```
API-Mobile Sprint 1:
□ 2.1.1 GET /v1/users/me
□ 2.1.2 GET /v1/users/me/schools
□ 2.1.3 GET /v1/users/me/active-school
□ 2.1.4 POST /v1/users/me/active-school
□ Tests unitarios
□ Tests de integración
□ Documentar en Swagger

API-Mobile Sprint 2:
□ 2.1.5 GET /v1/users/me/stats
□ 2.1.6 GET /v1/users/me/activity
□ Tests
□ Swagger

API-Mobile Sprint 3:
□ 2.1.7 POST /v1/materials/:id/favorite
□ 2.1.8 DELETE /v1/materials/:id/favorite
□ 2.1.9 GET /v1/users/me/favorites
□ Tests
□ Swagger

API-Mobile Sprint 4:
□ 2.1.10 Modificar GET /v1/materials (filtro escuela)
□ 2.1.11 Logging a user_activity_log
□ Tests de regresión
```

---

## FASE 3: Módulos Cross-Platform (SPM)

**Responsable**: edugo-apple-app (Packages/)
**Ubicación**: `/Users/jhoanmedina/source/EduGo/EduUI/apple-app/Packages`
**Duración estimada**: 1 semana

### 3.1 Módulos a Crear/Actualizar

Estos módulos SPM serán compartidos entre App Estudiantes y App Admin.

#### 3.1.1 EduGoDomainCore (Actualizar)

**Nuevas entidades**:

```swift
// Entities/UserContext.swift
public struct UserActiveContext: Codable, Sendable {
    public let schoolID: UUID
    public let schoolName: String
    public let roles: [UserRole]
    public let primaryUnit: AcademicUnit?
    public let setAt: Date
}

// Entities/UserSchool.swift
public struct UserSchool: Codable, Sendable, Identifiable {
    public let id: UUID // school_id
    public let name: String
    public let code: String
    public let logoURL: URL?
    public let roles: [UserRole]
    public let units: [AcademicUnit]
    public let isActive: Bool
    public let joinedAt: Date
}

// Entities/UserStats.swift
public struct UserStats: Codable, Sendable {
    public let materials: MaterialStats
    public let quizzes: QuizStats
    public let progress: ProgressStats
    public let lastActivity: UserActivity?
}

// Entities/UserActivity.swift
public struct UserActivity: Codable, Sendable, Identifiable {
    public let id: UUID
    public let type: ActivityType
    public let materialID: UUID?
    public let materialTitle: String?
    public let details: [String: AnyCodable]
    public let timestamp: Date
}
```

**Nuevos protocolos de repositorio**:

```swift
// Repositories/UserContextRepository.swift
public protocol UserContextRepository: Sendable {
    func getSchools() async -> Result<[UserSchool], AppError>
    func getActiveContext() async -> Result<UserActiveContext?, AppError>
    func setActiveSchool(_ schoolID: UUID) async -> Result<UserActiveContext, AppError>
}

// Repositories/UserStatsRepository.swift
public protocol UserStatsRepository: Sendable {
    func getStats() async -> Result<UserStats, AppError>
    func getActivity(limit: Int) async -> Result<[UserActivity], AppError>
}

// Repositories/FavoritesRepository.swift
public protocol FavoritesRepository: Sendable {
    func getFavorites(limit: Int, offset: Int) async -> Result<[Material], AppError>
    func addFavorite(materialID: UUID) async -> Result<Void, AppError>
    func removeFavorite(materialID: UUID) async -> Result<Void, AppError>
    func isFavorite(materialID: UUID) async -> Result<Bool, AppError>
}
```

---

#### 3.1.2 EduGoDataLayer (Actualizar)

**Nuevos DTOs**:

```swift
// DTOs/UserContextDTO.swift
struct UserSchoolsResponseDTO: Codable {
    let schools: [UserSchoolDTO]
    let activeSchoolID: UUID?
    let totalCount: Int
}

struct SetActiveSchoolRequestDTO: Codable {
    let schoolID: UUID
}

// DTOs/UserStatsDTO.swift
struct UserStatsDTO: Codable {
    let userID: UUID
    let period: String
    let materials: MaterialStatsDTO
    let quizzes: QuizStatsDTO
    let progress: ProgressStatsDTO
    let lastActivity: UserActivityDTO?
    let generatedAt: Date
}
```

**Nuevos endpoints**:

```swift
// Network/Endpoints/UserEndpoints.swift
enum UserEndpoints {
    case getMe
    case getSchools
    case getActiveSchool
    case setActiveSchool(schoolID: UUID)
    case getStats
    case getActivity(limit: Int)
}

extension UserEndpoints: Endpoint {
    var path: String {
        switch self {
        case .getMe: return "/v1/users/me"
        case .getSchools: return "/v1/users/me/schools"
        case .getActiveSchool: return "/v1/users/me/active-school"
        case .setActiveSchool: return "/v1/users/me/active-school"
        case .getStats: return "/v1/users/me/stats"
        case .getActivity: return "/v1/users/me/activity"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .setActiveSchool: return .post
        default: return .get
        }
    }
}
```

**Nuevas implementaciones de repositorio**:

```swift
// Repositories/UserContextRepositoryImpl.swift
@MainActor
final class UserContextRepositoryImpl: UserContextRepository {
    private let apiClient: APIClient

    func getSchools() async -> Result<[UserSchool], AppError> {
        let result: Result<UserSchoolsResponseDTO, NetworkError> = await apiClient.request(.getSchools)
        return result
            .map { $0.schools.map { $0.toDomain() } }
            .mapError { AppError.network($0) }
    }

    // ... resto de métodos
}
```

---

#### 3.1.3 EduGoDesignSystem (Actualizar)

**Nuevos componentes UI**:

```swift
// Components/DSSchoolCard.swift
public struct DSSchoolCard: View {
    let school: UserSchool
    let isActive: Bool
    let onTap: () -> Void
}

// Components/DSSchoolSelectorRow.swift
public struct DSSchoolSelectorRow: View {
    let school: UserSchool
    let isSelected: Bool
}

// Components/DSActivityRow.swift
public struct DSActivityRow: View {
    let activity: UserActivity
}

// Components/DSStatsCard.swift
public struct DSStatsCard: View {
    let title: String
    let value: String
    let icon: String
    let trend: Trend?
}

// Components/DSEmptyState.swift (si no existe)
public struct DSEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
}
```

---

### 3.2 Checklist Fase 3

```
EduGoDomainCore:
□ Entities: UserActiveContext, UserSchool, UserStats, UserActivity
□ Repositories: UserContextRepository, UserStatsRepository, FavoritesRepository
□ Use Cases: GetUserSchoolsUseCase, SetActiveSchoolUseCase, GetUserStatsUseCase

EduGoDataLayer:
□ DTOs para todos los nuevos endpoints
□ UserEndpoints enum
□ UserContextRepositoryImpl
□ UserStatsRepositoryImpl
□ FavoritesRepositoryImpl
□ Tests unitarios con mocks

EduGoDesignSystem:
□ DSSchoolCard
□ DSSchoolSelectorRow
□ DSActivityRow
□ DSStatsCard
□ DSEmptyState (si no existe)
□ Previews para todos los componentes
```

---

## FASE 4: App Estudiantes (Completa)

**Responsable**: edugo-apple-app
**Ubicación**: `/Users/jhoanmedina/source/EduGo/EduUI/apple-app`
**Duración estimada**: 6-8 semanas

### 4.1 Orden de Implementación

```
┌─────────────────────────────────────────────────────────────┐
│              APP ESTUDIANTES - ORDEN DE TAREAS              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Sprint 1: Infraestructura y Unificación                    │
│  ├── 4.1.1 Limpiar DummyJSON (eliminar referencias)         │
│  ├── 4.1.2 Unificar HomeView (3 versiones → 1 adaptativa)   │
│  ├── 4.1.3 Unificar SettingsView                            │
│  └── 4.1.4 Integrar UserContextRepository en DI             │
│                                                             │
│  Sprint 2: Selector de Contexto                             │
│  ├── 4.2.1 SchoolSelectorView (nueva)                       │
│  ├── 4.2.2 Integrar selector en navegación                  │
│  └── 4.2.3 Filtrar datos por escuela activa                 │
│                                                             │
│  Sprint 3: Home Mejorado                                    │
│  ├── 4.3.1 Conectar Home a /users/me/stats                  │
│  ├── 4.3.2 Conectar Home a /users/me/activity               │
│  └── 4.3.3 Implementar estados (loading, empty, error)      │
│                                                             │
│  Sprint 4: Materiales                                       │
│  ├── 4.4.1 MaterialsListView (nueva)                        │
│  ├── 4.4.2 MaterialDetailView (nueva)                       │
│  ├── 4.4.3 Favoritos (toggle en detail)                     │
│  └── 4.4.4 Filtros y búsqueda                               │
│                                                             │
│  Sprint 5: PDF y Resumen                                    │
│  ├── 4.5.1 PDFReaderView (nueva)                            │
│  ├── 4.5.2 Tracking de progreso automático                  │
│  ├── 4.5.3 SummaryView (nueva)                              │
│  └── 4.5.4 Manejo de estado "processing" (202)              │
│                                                             │
│  Sprint 6: Quizzes                                          │
│  ├── 4.6.1 QuizView (nueva)                                 │
│  ├── 4.6.2 QuizResultView (nueva)                           │
│  ├── 4.6.3 AttemptHistoryView (nueva)                       │
│  └── 4.6.4 Navegación completa del flujo                    │
│                                                             │
│  Sprint 7: Pantallas Restantes                              │
│  ├── 4.7.1 ProgressView (conectar a datos reales)           │
│  ├── 4.7.2 CoursesView (conectar a datos reales)            │
│  ├── 4.7.3 CalendarView (conectar a datos reales)           │
│  └── 4.7.4 CommunityView (placeholder mejorado)             │
│                                                             │
│  Sprint 8: Polish y Testing                                 │
│  ├── 4.8.1 Tests unitarios ViewModels                       │
│  ├── 4.8.2 Tests de integración                             │
│  ├── 4.8.3 Accessibility audit                              │
│  └── 4.8.4 Performance optimization                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### 4.2 Detalle por Sprint

#### Sprint 1: Infraestructura y Unificación (Semana 1)

##### Tarea 4.1.1: Limpiar DummyJSON
**Archivos a modificar**:
- `Config/Development.xcconfig` → Cambiar `API_BASE_URL`
- `App/Environment.swift` → Eliminar referencias a DummyJSON
- Buscar y eliminar: `grep -r "dummyjson" .`

##### Tarea 4.1.2: Unificar HomeView
**Problema**: Existen 3 archivos separados:
- `HomeView.swift` (iPhone)
- `IPadHomeView.swift` (iPad)
- `VisionOSHomeView.swift` (visionOS)

**Solución**: Una sola vista adaptativa:

```swift
// Presentation/Scenes/Home/HomeView.swift
struct HomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var viewModel: HomeViewModel

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                CompactHomeLayout(viewModel: viewModel)
            } else {
                RegularHomeLayout(viewModel: viewModel)
            }
        }
    }
}

// Layouts separados pero mismo ViewModel
private struct CompactHomeLayout: View { ... }  // iPhone
private struct RegularHomeLayout: View { ... }  // iPad, Mac
```

**Archivos a eliminar después**:
- `IPadHomeView.swift`
- `VisionOSHomeView.swift`

---

#### Sprint 2: Selector de Contexto (Semana 2)

##### Tarea 4.2.1: SchoolSelectorView

```swift
// Presentation/Scenes/SchoolSelector/SchoolSelectorView.swift
struct SchoolSelectorView: View {
    @State private var viewModel: SchoolSelectorViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(viewModel.schools) { school in
                DSSchoolCard(
                    school: school,
                    isActive: school.id == viewModel.activeSchoolID,
                    onTap: { viewModel.selectSchool(school) }
                )
            }
            .navigationTitle("Seleccionar Escuela")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .task { await viewModel.loadSchools() }
    }
}
```

##### Tarea 4.2.2: Integrar en navegación

Mostrar selector:
- En primer login si tiene múltiples escuelas
- En Settings como opción "Cambiar Escuela"
- En toolbar de Home (icono de escuela)

---

#### Sprint 4-6: Pantallas Nuevas

Ver documentación detallada en:
- [PANTALLAS-NUEVAS-PARTE1.md](./estudiantes/PANTALLAS-NUEVAS-PARTE1.md)
- [PANTALLAS-NUEVAS-PARTE2.md](./estudiantes/PANTALLAS-NUEVAS-PARTE2.md)

---

### 4.3 Checklist Fase 4

```
Sprint 1:
□ Eliminar DummyJSON
□ Unificar HomeView
□ Unificar SettingsView
□ Registrar nuevos repos en DI

Sprint 2:
□ SchoolSelectorView
□ SchoolSelectorViewModel
□ Integrar en navegación
□ Filtrar datos por escuela

Sprint 3:
□ HomeViewModel conectado a API
□ Stats cards con datos reales
□ Activity list con datos reales
□ Estados loading/empty/error

Sprint 4:
□ MaterialsListView
□ MaterialDetailView
□ Favoritos
□ Filtros y búsqueda

Sprint 5:
□ PDFReaderView
□ Tracking de progreso
□ SummaryView
□ Manejo de "processing"

Sprint 6:
□ QuizView
□ QuizResultView
□ AttemptHistoryView
□ Navegación completa

Sprint 7:
□ ProgressView (datos reales)
□ CoursesView (datos reales)
□ CalendarView (datos reales)
□ CommunityView (mejorado)

Sprint 8:
□ Tests unitarios
□ Tests integración
□ Accessibility
□ Performance
```

---

## FASE 5: App Administración (Completa)

**Responsable**: Nuevo proyecto (edugo-admin-app)
**Ubicación**: Por crear
**Duración estimada**: 8-12 semanas
**Dependencias**: Fase 2 (API-Admin) debe estar avanzada

### 5.1 Setup Inicial

#### Tarea 5.1.1: Crear proyecto nuevo

```bash
# Crear proyecto Xcode
# File → New → Project → Multiplatform App
# Nombre: EduGo Admin
# Bundle ID: com.edugo.admin

# Estructura sugerida:
edugo-admin-app/
├── edugo-admin-app/
│   ├── App/
│   ├── Core/
│   ├── Data/
│   ├── Domain/
│   └── Presentation/
├── Packages/           # Symlink a packages compartidos
│   ├── EduGoDomainCore → ../../apple-app/Packages/EduGoDomainCore
│   ├── EduGoDesignSystem → ../../apple-app/Packages/EduGoDesignSystem
│   └── EduGoDataLayer → ../../apple-app/Packages/EduGoDataLayer
└── edugo-admin-appTests/
```

---

### 5.2 Orden de Implementación

```
┌─────────────────────────────────────────────────────────────┐
│            APP ADMINISTRACIÓN - ORDEN DE TAREAS             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Sprint Admin 1: Setup y Dashboard                          │
│  ├── 5.2.1 Crear proyecto y configurar                      │
│  ├── 5.2.2 Referenciar packages compartidos                 │
│  ├── 5.2.3 Login (reutilizar de app estudiantes)            │
│  └── 5.2.4 DashboardAdminView                               │
│                                                             │
│  Sprint Admin 2: Escuelas                                   │
│  ├── 5.3.1 SchoolsListView                                  │
│  ├── 5.3.2 SchoolDetailView                                 │
│  └── 5.3.3 CRUD completo                                    │
│                                                             │
│  Sprint Admin 3: Estructura Académica                       │
│  ├── 5.4.1 AcademicTreeView                                 │
│  ├── 5.4.2 UnitDetailView                                   │
│  └── 5.4.3 Drag & drop para reorganizar                     │
│                                                             │
│  Sprint Admin 4: Usuarios                                   │
│  ├── 5.5.1 UsersListView                                    │
│  ├── 5.5.2 UserDetailView                                   │
│  ├── 5.5.3 MembershipsView                                  │
│  └── 5.5.4 GuardiansView                                    │
│                                                             │
│  Sprint Admin 5: Materias                                   │
│  └── 5.6.1 SubjectsView                                     │
│                                                             │
│  Sprint Admin 6+: Features Avanzados                        │
│  ├── Ciclos académicos (cuando API esté lista)              │
│  ├── Horarios (cuando API esté lista)                       │
│  ├── Importación masiva                                     │
│  └── Reportes                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### 5.3 Checklist Fase 5

```
Sprint Admin 1:
□ Proyecto creado
□ Packages referenciados
□ Login funcionando
□ Dashboard con stats

Sprint Admin 2:
□ Lista de escuelas
□ Detalle de escuela
□ Crear/editar/eliminar

Sprint Admin 3:
□ Árbol jerárquico
□ CRUD unidades
□ Drag & drop

Sprint Admin 4:
□ Lista usuarios
□ Detalle usuario
□ Membresías
□ Tutores

Sprint Admin 5:
□ Materias

Sprint Admin 6+:
□ Según disponibilidad de APIs
```

---

## Resumen de Timeline

```
┌─────────────────────────────────────────────────────────────┐
│                    TIMELINE GENERAL                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Semana 1:     FASE 1 - Base de Datos                       │
│  Semana 2-3:   FASE 2 - API Mobile (Sprint 1-2)             │
│  Semana 3:     FASE 3 - Módulos Cross (paralelo)            │
│  Semana 4-11:  FASE 4 - App Estudiantes (8 sprints)         │
│                                                             │
│  --- MILESTONE: App Estudiantes v1.0 ---                    │
│                                                             │
│  Semana 4-9:   FASE 2 - API Admin (paralelo)                │
│  Semana 12-23: FASE 5 - App Administración                  │
│                                                             │
│  --- MILESTONE: App Admin v1.0 ---                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Tiempo total estimado:
- App Estudiantes completa: ~11 semanas
- App Admin completa: ~12 semanas adicionales
- Total proyecto: ~23 semanas (5-6 meses)

Con equipo de 2 devs iOS + 1 dev Backend:
- Puede reducirse a ~16-18 semanas
```

---

## Referencias

| Documento | Propósito |
|-----------|-----------|
| [README.md](./README.md) | Índice principal |
| [ENDPOINTS-BACKEND-REQUERIDOS.md](./ENDPOINTS-BACKEND-REQUERIDOS.md) | Todos los endpoints |
| [PANTALLAS-EXISTENTES.md](./estudiantes/PANTALLAS-EXISTENTES.md) | Qué mejorar |
| [PANTALLAS-NUEVAS-PARTE1.md](./estudiantes/PANTALLAS-NUEVAS-PARTE1.md) | Materiales, PDF, Summary |
| [PANTALLAS-NUEVAS-PARTE2.md](./estudiantes/PANTALLAS-NUEVAS-PARTE2.md) | Quiz, Results, Selector |
| [ANALISIS-APPS.md](./arquitectura/ANALISIS-APPS.md) | Por qué 2 apps |
| [ENDPOINTS-FALTANTES.md](./administracion/ENDPOINTS-FALTANTES.md) | APIs admin detalladas |

---

**Generado por**: Claude Code con UltraThink
**Fecha**: 1 de Diciembre, 2025
