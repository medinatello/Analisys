# Diagrama de Flujo - Mock Repositories en API Mobile

**Fecha:** 30 de Noviembre de 2025  
**API:** edugo-api-mobile  
**Ubicación:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile`

---

## Flujo Completo de Inicialización con Mocks

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         INICIO: main.go                                  │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PASO 1: Cargar Configuración                                           │
│                                                                          │
│  config.Load() @ internal/config/config.go                              │
│  ├─> Viper.SetConfigName("config")                                      │
│  ├─> Viper.ReadInConfig()           // config.yaml (base)               │
│  ├─> Viper.SetConfigName("config-local")                                │
│  ├─> Viper.MergeInConfig()          // config-local.yaml                │
│  │                                                                       │
│  ├─> Viper.SetEnvPrefix("DEVELOPMENT")                                  │
│  ├─> Viper.AutomaticEnv()                                               │
│  └─> Viper.SetEnvKeyReplacer(".", "_")                                  │
│                                                                          │
│  RESULTADO:                                                              │
│  cfg.Development.UseMockRepositories = ???                               │
│                                                                          │
│  FUENTES (en orden de prioridad):                                       │
│  1. DEVELOPMENT_USE_MOCK_REPOSITORIES env var                           │
│  2. config-local.yaml: development.use_mock_repositories                │
│  3. config.yaml: development.use_mock_repositories                      │
│  4. Default: false                                                       │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PASO 2: Inicializar Bootstrap                                          │
│                                                                          │
│  bootstrap.Initialize() @ internal/bootstrap/bootstrap.go               │
│  └─> bridgeToSharedBootstrap() @ internal/bootstrap/bridge.go           │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │ DECISIÓN: ¿Hay recursos inyectados (opts.PostgreSQL != nil)?│      │
│  └──────────────────────┬───────────────────────────────────────┘      │
│                         │                                               │
│          ┌──────────────┴──────────────┐                                │
│          │ SÍ (Mocks inyectados)        │ NO (Inicialización normal)     │
│          ▼                              ▼                                │
│  ┌───────────────────┐          ┌──────────────────┐                    │
│  │ Retornar recursos │          │ Llamar shared/   │                    │
│  │ inyectados        │          │ bootstrap con    │                    │
│  │ directamente      │          │ factories reales │                    │
│  │                   │          │                  │                    │
│  │ PostgreSQL: ❌    │          │ PostgreSQL: ✅   │                    │
│  │ MongoDB: ❌       │          │ MongoDB: ✅      │                    │
│  │ RabbitMQ: ❌      │          │ RabbitMQ: ✅     │                    │
│  │ S3: ❌            │          │ S3: ✅           │                    │
│  └─────────┬─────────┘          └────────┬─────────┘                    │
│            │                             │                               │
│            └──────────┬──────────────────┘                               │
│                       │                                                  │
│                       ▼                                                  │
│  RETORNA:                                                                │
│  ├─> Resources.Logger: ✅ Siempre disponible                           │
│  ├─> Resources.PostgreSQL: ✅ si !mock, ❌ nil si mock                 │
│  ├─> Resources.MongoDB: ✅ si !mock, ❌ nil si mock                    │
│  ├─> Resources.RabbitMQPublisher: ⚠️  opcional                         │
│  ├─> Resources.S3Client: ⚠️  opcional                                  │
│  └─> cleanup function                                                   │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PASO 3: Crear Container DI                                             │
│                                                                          │
│  container.NewContainer(resources)                                      │
│  @ internal/container/container.go                                      │
│                                                                          │
│  Paso 3.1: Crear InfrastructureContainer                                │
│  └─> Almacena referencias a DB, Logger, Messaging, Storage              │
│                                                                          │
│  Paso 3.2: Crear RepositoryContainer                                    │
│  └─> NewRepositoryContainer(infra, resources.Config)                    │
│      @ internal/container/repositories.go                               │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │ DECISIÓN: ¿cfg.Development.UseMockRepositories == true?      │      │
│  └──────────────────────┬───────────────────────────────────────┘      │
│                         │                                               │
│          ┌──────────────┴──────────────┐                                │
│          │ SÍ                           │ NO                             │
│          ▼                              ▼                                │
│  ┌───────────────────────────┐  ┌─────────────────────────────┐        │
│  │ RepositoryFactory usa     │  │ RepositoryFactory usa       │        │
│  │ mock implementations      │  │ real implementations        │        │
│  │                           │  │                             │        │
│  │ UserRepository =          │  │ UserRepository =            │        │
│  │  mockPostgres.New         │  │  postgresRepo.New           │        │
│  │  MockUserRepository()     │  │  PostgresUserRepository(db) │        │
│  │                           │  │                             │        │
│  │ MaterialRepository =      │  │ MaterialRepository =        │        │
│  │  mockPostgres.New         │  │  postgresRepo.New           │        │
│  │  MockMaterialRepository() │  │  PostgresMaterialRepo...(db)│        │
│  │                           │  │                             │        │
│  │ LOG:                      │  │ LOG:                        │        │
│  │ "usando mock              │  │ "usando postgresql/mongodb  │        │
│  │  repositories"            │  │  repositories"              │        │
│  │ mock_enabled=true         │  │ mock_enabled=false          │        │
│  │ db_required=false         │  │ db_required=true            │        │
│  └──────────┬────────────────┘  └────────┬────────────────────┘        │
│             │                            │                              │
│             └────────────┬───────────────┘                              │
│                          │                                              │
│                          ▼                                              │
│  ┌────────────────────────────────────────────────────────────┐        │
│  │ Repositorios creados (vía Factory):                        │        │
│  │                                                             │        │
│  │ PostgreSQL:                                                 │        │
│  │ ├─> UserRepository                                         │        │
│  │ ├─> MaterialRepository                                     │        │
│  │ ├─> ProgressRepository                                     │        │
│  │ ├─> RefreshTokenRepository                                 │        │
│  │ ├─> LoginAttemptRepository                                 │        │
│  │ ├─> AssessmentRepoV2                                       │        │
│  │ ├─> AttemptRepo                                            │        │
│  │ └─> AnswerRepo                                             │        │
│  │                                                             │        │
│  │ MongoDB:                                                    │        │
│  │ ├─> SummaryRepository                                      │        │
│  │ ├─> AssessmentRepository (legacy)                          │        │
│  │ └─> AssessmentDocumentRepo                                 │        │
│  │                                                             │        │
│  │ TOTAL: 11 repositorios creados                             │        │
│  └────────────────────────────────────────────────────────────┘        │
│                                                                          │
│  Paso 3.3: Crear ServiceContainer                                       │
│  └─> Servicios usan repositorios via DI                                 │
│                                                                          │
│  Paso 3.4: Crear HandlerContainer                                       │
│  └─> Handlers HTTP usan services via DI                                 │
│                                                                          │
│  RETORNA: Container con todas las dependencias inicializadas            │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PASO 4: Configurar Rutas Gin                                           │
│                                                                          │
│  router := setupRouter(container, cfg) @ cmd/main.go                    │
│                                                                          │
│  Rutas Públicas:                                                        │
│  └─> GET /health                                                        │
│                                                                          │
│  Rutas Protegidas (requieren token de api-admin):                       │
│  ├─> GET /api/v1/materials                                              │
│  ├─> GET /api/v1/materials/:id                                          │
│  ├─> POST /api/v1/materials/:id/upload                                  │
│  ├─> GET /api/v1/materials/:id/download                                 │
│  ├─> PUT /api/v1/materials/:id                                          │
│  ├─> DELETE /api/v1/materials/:id                                       │
│  ├─> GET /api/v1/progress                                               │
│  ├─> POST /api/v1/progress                                              │
│  ├─> PUT /api/v1/progress/:id                                           │
│  ├─> GET /api/v1/assessments/:id                                        │
│  ├─> POST /api/v1/assessments/:id/attempts                              │
│  ├─> GET /api/v1/assessments/:id/attempts/:attemptId                    │
│  └─> POST /api/v1/assessments/:id/attempts/:attemptId/submit            │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PASO 5: Servidor HTTP Listening                                        │
│                                                                          │
│  srv.ListenAndServe() en :8080                                          │
│                                                                          │
│  ✅ API LISTA PARA RECIBIR REQUESTS                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Flujo de una Request: GET /health

```
┌────────────────────────────────────────────────────────────────┐
│  REQUEST: GET /health                                          │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  Gin Router                                                    │
│  ├─> Middleware: Logger, Recovery                             │
│  └─> Handler: HealthHandler.CheckHealth                       │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  HealthHandler.CheckHealth()                                   │
│  @ internal/infrastructure/http/handler/health_handler.go      │
│                                                                 │
│  Verifica estado de bases de datos:                            │
│                                                                 │
│  ┌─────────────────────────────────────────────────┐          │
│  │ DECISIÓN: ¿Mock Mode?                           │          │
│  └──────────────────────┬──────────────────────────┘          │
│                         │                                      │
│          ┌──────────────┴──────────────┐                       │
│          │ SÍ                           │ NO                    │
│          ▼                              ▼                       │
│  ┌───────────────────┐          ┌──────────────────┐          │
│  │ DB PostgreSQL:    │          │ DB PostgreSQL:   │          │
│  │ Status: "mock"    │          │ db.Ping() -> OK  │          │
│  │                   │          │ Status: "healthy"│          │
│  │ DB MongoDB:       │          │                  │          │
│  │ Status: "mock"    │          │ DB MongoDB:      │          │
│  │                   │          │ ping -> OK       │          │
│  │                   │          │ Status: "healthy"│          │
│  └─────────┬─────────┘          └────────┬─────────┘          │
│            │                             │                     │
│            └──────────┬──────────────────┘                     │
│                       │                                        │
│                       ▼                                        │
│  Retorna JSON con status de servicios                         │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  Response JSON:                                                 │
│                                                                 │
│  {                                                              │
│    "status": "healthy",                                        │
│    "services": {                                               │
│      "database": {                                             │
│        "postgres": "mock",    // o "healthy"                   │
│        "mongodb": "mock"      // o "healthy"                   │
│      }                                                         │
│    },                                                          │
│    "timestamp": "2025-11-30T..."                               │
│  }                                                              │
│                                                                 │
│  Status: 200 OK                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Flujo de una Request Protegida: GET /api/v1/materials (Con Mock Vacío)

```
┌────────────────────────────────────────────────────────────────┐
│  REQUEST: GET /api/v1/materials                                │
│  Header: Authorization: Bearer <token-de-api-admin>            │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  Gin Router                                                    │
│  ├─> Middleware: Logger, Recovery                             │
│  ├─> Middleware: RemoteAuthMiddleware                         │
│  │   ├─> Extrae token del header                              │
│  │   ├─> LLAMA A api-admin: POST /v1/auth/verify              │
│  │   │   ├─> api-admin valida el token                        │
│  │   │   └─> Retorna user info (id, email, role)              │
│  │   ├─> Inyecta user_id en context de Gin                    │
│  │   └─> ✅ PERMITE REQUEST (token válido)                   │
│  └─> Handler: MaterialHandler.ListMaterials                   │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  MaterialHandler.ListMaterials()                               │
│  @ internal/infrastructure/http/handler/material_handler.go    │
│                                                                 │
│  Llama a: materialService.ListMaterials(userID, filters)       │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  MaterialService.ListMaterials()                               │
│  @ internal/domain/service/material_service.go                 │
│                                                                 │
│  Llama a: materialRepository.List(ctx, filters)                │
│                                                                 │
│     ┌─────────────────────────────────────────────────┐       │
│     │ MOCK: mockMaterialRepository.List()             │       │
│     │ @ internal/infrastructure/persistence/          │       │
│     │   mock/postgres/stubs.go:25                     │       │
│     │                                                  │       │
│     │ func (r *mockMaterialRepository) List(...) {    │       │
│     │     return []*entities.Material{}, nil          │       │
│     │ }                                                │       │
│     │                                                  │       │
│     │ ❌ RETORNA: ARRAY VACÍO (sin datos mock)       │       │
│     │                                                  │       │
│     │ Materiales retornados: 0                        │       │
│     └─────────────────────────────────────────────────┘       │
│                                                                 │
│  Retorna lista vacía de materials                              │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  MaterialHandler responde con JSON:                            │
│                                                                 │
│  []  // ❌ ARRAY VACÍO - No hay datos mock                    │
│                                                                 │
│  Status: 200 OK                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Flujo de Validación de Token Remoto (RemoteAuthMiddleware)

```
┌────────────────────────────────────────────────────────────────┐
│  Request con token → RemoteAuthMiddleware                      │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  RemoteAuthMiddleware.Handle()                                 │
│  @ internal/infrastructure/http/middleware/remote_auth.go      │
│                                                                 │
│  1. Extrae token del header "Authorization: Bearer <token>"    │
│                                                                 │
│  2. Llama a AuthClient.VerifyToken(token)                      │
│     └─> POST http://api-admin:8081/v1/auth/verify              │
│         Body: {"token": "<access_token>"}                      │
│                                                                 │
│     ┌─────────────────────────────────────────────────┐       │
│     │ api-admin VALIDA:                                │       │
│     │ ├─> Verifica firma JWT                          │       │
│     │ ├─> Verifica expiración                         │       │
│     │ ├─> Verifica issuer                             │       │
│     │ └─> Extrae claims (user_id, email, role)        │       │
│     │                                                  │       │
│     │ Response de api-admin:                          │       │
│     │ {                                                │       │
│     │   "valid": true,                                 │       │
│     │   "user": {                                      │       │
│     │     "id": "a1eebc99-...",                        │       │
│     │     "email": "admin@edugo.test",                 │       │
│     │     "role": "admin"                              │       │
│     │   }                                              │       │
│     │ }                                                │       │
│     └─────────────────────────────────────────────────┘       │
│                                                                 │
│  3. Inyecta user info en context de Gin:                       │
│     c.Set("user_id", userInfo.ID)                              │
│     c.Set("user_email", userInfo.Email)                        │
│     c.Set("user_role", userInfo.Role)                          │
│                                                                 │
│  4. Permite que request continúe al handler                    │
│     c.Next()                                                   │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  Handler recibe request con context enriquecido                │
│  - Puede acceder a user_id desde c.MustGet("user_id")          │
│  - Sabe qué usuario hizo el request                            │
└────────────────────────────────────────────────────────────────┘
```

**IMPORTANTE:** api-mobile NO genera tokens JWT propios. Delega autenticación 100% a api-admin.

---

## Componentes del Sistema Mock

### 1. Factory Pattern

```
RepositoryFactory
├─> CreateUserRepository()
│   ├─> if UseMockRepositories: mockPostgres.NewMockUserRepository()
│   └─> else: postgresRepo.NewPostgresUserRepository(db)
├─> CreateMaterialRepository()
│   ├─> if UseMockRepositories: mockPostgres.NewMockMaterialRepository()
│   └─> else: postgresRepo.NewPostgresMaterialRepository(db)
└─> ... (11 repositorios en total)
```

### 2. Mock Repositories (11 implementaciones)

```
internal/infrastructure/persistence/mock/
├─> postgres/
│   ├─> user_repository_mock.go         ✅ IMPLEMENTADO (con datos)
│   └─> stubs.go                        ❌ STUBS VACÍOS
│       ├─> MaterialRepository          (retorna [])
│       ├─> ProgressRepository          (retorna [])
│       ├─> RefreshTokenRepository      (retorna nil)
│       ├─> LoginAttemptRepository      (retorna 0)
│       ├─> AssessmentRepository        (retorna nil)
│       ├─> AttemptRepository           (retorna [])
│       └─> AnswerRepository            (retorna [])
│
└─> mongodb/
    └─> stubs.go                        ❌ STUBS VACÍOS
        ├─> SummaryRepository           (retorna nil)
        ├─> LegacyAssessmentRepository  (retorna nil)
        └─> AssessmentDocumentRepository(retorna [])

TOTAL: 11 repositorios
IMPLEMENTADOS CON DATOS: 1 (9%)
STUBS VACÍOS: 10 (91%)
```

### 3. Mock Data (Solo 1 entidad)

```
internal/infrastructure/persistence/mock/fixtures/
└─> users.go              (3 usuarios con password hash)

Usuarios disponibles:
├─> admin@edugo.com / password123 (admin)
├─> teacher@edugo.com / password123 (teacher)
└─> student@edugo.com / password123 (student)

TOTAL: 3 registros precargados
```

---

## Comparación: Mock Real vs Mock Stub

### Ejemplo: UserRepository (IMPLEMENTADO CORRECTAMENTE)

```go
// user_repository_mock.go
type mockUserRepository struct {
    users map[string]*pgentities.User
    mu    sync.RWMutex
}

func NewMockUserRepository() repository.UserRepository {
    return &mockUserRepository{
        users: fixtures.GetDefaultUsers(), // ✅ Carga datos
    }
}

func (r *mockUserRepository) FindByEmail(ctx, email) (*User, error) {
    r.mu.RLock()
    defer r.mu.RUnlock()
    
    for _, u := range r.users {
        if u.Email == email.String() {
            c := *u  // ✅ Copia inmutable
            return &c, nil
        }
    }
    return nil, nil
}
```

**Características:**
- ✅ Thread-safe con sync.RWMutex
- ✅ Datos precargados desde fixtures
- ✅ Retorna copias inmutables
- ✅ Lógica real de búsqueda

---

### Ejemplo: MaterialRepository (STUB VACÍO)

```go
// stubs.go
type mockMaterialRepository struct{}

func NewMockMaterialRepository() repository.MaterialRepository {
    return &mockMaterialRepository{}
}

func (r *mockMaterialRepository) List(ctx, filters) ([]*Material, error) {
    return []*pgentities.Material{}, nil  // ❌ Retorna array vacío
}

func (r *mockMaterialRepository) FindByID(ctx, id) (*Material, error) {
    return nil, nil  // ❌ Retorna nil
}
```

**Problemas:**
- ❌ No tiene datos mock
- ❌ Retorna valores vacíos/nil
- ❌ No sirve para desarrollo frontend
- ❌ No tiene thread-safety
- ❌ No tiene validaciones

---

## Características Técnicas de Mock Repositories

### Thread Safety (Solo UserRepository)
```go
type mockUserRepository struct {
    mu    sync.RWMutex  // Protege acceso concurrente
    users map[string]*pgentities.User
}

func (r *mockUserRepository) FindByID(ctx, id) (*User, error) {
    r.mu.RLock()         // Read lock
    defer r.mu.RUnlock()
    
    if u, ok := r.users[id.String()]; ok {
        c := *u  // Retorna COPIA
        return &c, nil
    }
    return nil, nil
}
```

### Inmutabilidad (Solo UserRepository)
UserRepository retorna **copias profundas** de las entidades, no referencias directas al map interno.

**Los demás repositorios (stubs) NO implementan estas características.**

---

## Ventajas del Sistema Actual

✅ **Sin infraestructura externa:** No requiere PostgreSQL, MongoDB, RabbitMQ  
✅ **Arranque rápido:** ~1.5 segundos vs 30s con Docker  
✅ **Ahorro de RAM:** ~200MB vs ~4GB con Docker  
✅ **Validación de tokens funcional:** Integración con api-admin OK  
✅ **Arquitectura correcta:** Factory pattern bien implementado  

---

## Limitaciones Críticas

❌ **Sin datos mock útiles:** 10 de 11 repositorios retornan vacío/nil  
❌ **No sirve para desarrollo frontend:** Frontend no puede probar UI con datos  
❌ **Solo 3 usuarios:** Comparado con 42 registros en api-administracion  
❌ **Sin thread-safety:** 10 de 11 repositorios no son thread-safe  
❌ **Sin validaciones:** Stubs no replican constraints de DB  

---

## Diferencias con api-administracion

| Aspecto | api-administracion | api-mobile |
|---------|-------------------|------------|
| Variable de entorno | EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES | DEVELOPMENT_USE_MOCK_REPOSITORIES |
| Repositorios totales | 9 | 11 |
| Repositorios con datos | 9/9 (100%) | 1/11 (9%) |
| Datos mock totales | 42 registros en 8 entidades | 3 registros en 1 entidad |
| Thread-safety | ✅ Todos con sync.RWMutex | ⚠️ Solo UserRepository |
| Validaciones | ✅ Replican PostgreSQL | ❌ No implementadas |
| Estado funcional | ✅ Listo para desarrollo | ❌ Solo autenticación remota funciona |

---

## Conclusión

La arquitectura de mock repositories en `edugo-api-mobile` es **correcta** (factory pattern, DI), pero la **implementación está incompleta**. 

**10 de 11 repositorios son stubs vacíos** que no proveen datos útiles para desarrollo, lo que hace el sistema **no funcional para desarrollo frontend**.

**Próximo paso:** Implementar fixtures y lógica real en los 10 repositorios faltantes.
