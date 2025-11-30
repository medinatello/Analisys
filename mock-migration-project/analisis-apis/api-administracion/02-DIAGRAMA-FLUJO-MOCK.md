# Diagrama de Flujo - Mock Repositories en API Administración

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
│  config.Load() @ internal/config/loader.go                              │
│  ├─> Viper.SetConfigName("config")                                      │
│  ├─> Viper.ReadInConfig()           // config.yaml (base)               │
│  ├─> Viper.SetConfigName("config-local")                                │
│  ├─> Viper.MergeInConfig()          // config-local.yaml                │
│  │                                                                       │
│  ├─> Viper.SetEnvPrefix("EDUGO_ADMIN")                                  │
│  ├─> Viper.AutomaticEnv()                                               │
│  └─> Viper.SetEnvKeyReplacer(".", "_")                                  │
│                                                                          │
│  RESULTADO:                                                              │
│  cfg.Database.UseMockRepositories = ???                                  │
│                                                                          │
│  FUENTES (en orden de prioridad):                                       │
│  1. EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES env var                  │
│  2. config-local.yaml: database.use_mock_repositories                   │
│  3. config.yaml: database.use_mock_repositories                         │
│  4. Default: false                                                       │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PASO 2: Inicializar Bootstrap                                          │
│                                                                          │
│  bootstrap.Initialize() @ internal/bootstrap/bridge.go                  │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │ DECISIÓN: ¿UseMockRepositories == true?                      │      │
│  └──────────────────────┬───────────────────────────────────────┘      │
│                         │                                               │
│          ┌──────────────┴──────────────┐                                │
│          │ SÍ                           │ NO                             │
│          ▼                              ▼                                │
│  ┌───────────────────┐          ┌──────────────────┐                    │
│  │ requiredResources │          │ requiredResources│                    │
│  │ = ["logger"]      │          │ = ["logger",     │                    │
│  │                   │          │    "postgresql"] │                    │
│  │ PostgreSQL NO     │          │                  │                    │
│  │ requerido         │          │ PostgreSQL       │                    │
│  │                   │          │ REQUERIDO        │                    │
│  └─────────┬─────────┘          └────────┬─────────┘                    │
│            │                             │                               │
│            └──────────┬──────────────────┘                               │
│                       │                                                  │
│                       ▼                                                  │
│  sharedBootstrap.Bootstrap(ctx, config, factories, lifecycle,           │
│                            WithRequiredResources(requiredResources))    │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │ Bootstrap inicializa:                                       │         │
│  │ ✅ Logger (SIEMPRE)                                        │         │
│  │ ✅ PostgreSQL (solo si NO mock)                           │         │
│  │ ⏭️  MongoDB (skip - no factory)                            │         │
│  │ ⏭️  RabbitMQ (skip - no factory)                           │         │
│  │ ⏭️  S3 (skip - no factory)                                 │         │
│  └────────────────────────────────────────────────────────────┘         │
│                                                                          │
│  RETORNA:                                                                │
│  ├─> Resources.Logger: ✅ Siempre disponible                           │
│  ├─> Resources.PostgreSQL: ✅ si !mock, ❌ nil si mock                 │
│  └─> cleanup function                                                   │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PASO 3: Crear Container DI                                             │
│                                                                          │
│  container.NewContainer(db, logger, jwtSecret, cfg)                     │
│  @ internal/container/container.go                                      │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │ DECISIÓN: ¿cfg.Database.UseMockRepositories == true?         │      │
│  └──────────────────────┬───────────────────────────────────────┘      │
│                         │                                               │
│          ┌──────────────┴──────────────┐                                │
│          │ SÍ                           │ NO                             │
│          ▼                              ▼                                │
│  ┌───────────────────────────┐  ┌─────────────────────────────┐        │
│  │ repositoryFactory =       │  │ repositoryFactory =         │        │
│  │ factory.NewMock           │  │ factory.NewPostgres         │        │
│  │   RepositoryFactory()     │  │   RepositoryFactory(db)     │        │
│  │                           │  │                             │        │
│  │ LOG:                      │  │ LOG:                        │        │
│  │ "usando mock              │  │ "usando postgresql          │        │
│  │  repositories"            │  │  repositories"              │        │
│  │ mock_enabled=true         │  │ mock_enabled=false          │        │
│  │ postgres_required=false   │  │ postgres_required=true      │        │
│  └──────────┬────────────────┘  └────────┬────────────────────┘        │
│             │                            │                              │
│             └────────────┬───────────────┘                              │
│                          │                                              │
│                          ▼                                              │
│  ┌────────────────────────────────────────────────────────────┐        │
│  │ Crear Repositorios usando Factory:                         │        │
│  │                                                             │        │
│  │ SchoolRepository         = factory.CreateSchoolRepository()│        │
│  │ UserRepository           = factory.CreateUserRepository()  │        │
│  │ AcademicUnitRepository   = factory.Create...()             │        │
│  │ UnitMembershipRepository = factory.Create...()             │        │
│  │ UnitRepository           = factory.Create...()             │        │
│  │ SubjectRepository        = factory.Create...()             │        │
│  │ MaterialRepository       = factory.Create...()             │        │
│  │ StatsRepository          = factory.Create...()             │        │
│  │ GuardianRepository       = factory.Create...()             │        │
│  │                                                             │        │
│  │ TOTAL: 9 repositorios creados                              │        │
│  └────────────────────────────────────────────────────────────┘        │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────┐        │
│  │ Crear Services (usan repositorios via DI):                 │        │
│  │                                                             │        │
│  │ AuthService, UserService, SchoolService,                   │        │
│  │ AcademicUnitService, etc.                                  │        │
│  └────────────────────────────────────────────────────────────┘        │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────┐        │
│  │ Crear Handlers (usan services via DI):                     │        │
│  │                                                             │        │
│  │ AuthHandler, UserHandler, SchoolHandler, etc.              │        │
│  └────────────────────────────────────────────────────────────┘        │
│                                                                          │
│  RETORNA: Container con todas las dependencias inicializadas            │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PASO 4: Configurar Rutas Gin                                           │
│                                                                          │
│  r := gin.Default()                                                     │
│                                                                          │
│  Rutas Públicas:                                                        │
│  ├─> POST /v1/auth/login                                                │
│  ├─> POST /v1/auth/refresh                                              │
│  ├─> POST /v1/auth/logout                                               │
│  ├─> POST /v1/auth/verify                                               │
│  └─> POST /v1/auth/verify-bulk                                          │
│                                                                          │
│  Rutas Protegidas (requieren JWT):                                      │
│  ├─> GET/POST /v1/schools                                               │
│  ├─> GET/POST/PUT/DELETE /v1/schools/:id                                │
│  ├─> GET/POST /v1/schools/:id/units                                     │
│  ├─> GET/PUT/DELETE /v1/units/:id                                       │
│  ├─> GET/POST/PUT/DELETE /v1/memberships                                │
│  └─> ...                                                                 │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PASO 5: Servidor HTTP Listening                                        │
│                                                                          │
│  srv.ListenAndServe() en :8081                                          │
│                                                                          │
│  ✅ API LISTA PARA RECIBIR REQUESTS                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Flujo de una Request: POST /v1/auth/login

```
┌────────────────────────────────────────────────────────────────┐
│  REQUEST: POST /v1/auth/login                                  │
│  Body: {"email": "admin@edugo.test", "password": "edugo2024"}  │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  Gin Router                                                    │
│  ├─> Middleware: Logger, Recovery                             │
│  └─> Handler: AuthHandler.Login                               │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  AuthHandler.Login()                                           │
│  @ internal/auth/handler/auth_handler.go                       │
│                                                                 │
│  Llama a: authService.Login(email, password)                   │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  AuthService.Login()                                           │
│  @ internal/auth/service/auth_service.go                       │
│                                                                 │
│  1. Llama a: userRepository.FindByEmail(email)                 │
│                                                                 │
│     ┌─────────────────────────────────────────────────┐       │
│     │ MOCK: MockUserRepository.FindByEmail()          │       │
│     │ @ internal/infrastructure/persistence/          │       │
│     │   mock/repository/user_repository_mock.go       │       │
│     │                                                  │       │
│     │ 1. Busca en data.GetUsers() (in-memory map)     │       │
│     │ 2. Encuentra user con email="admin@edugo.test"  │       │
│     │ 3. Retorna copia inmutable del usuario          │       │
│     │                                                  │       │
│     │ Usuario encontrado:                              │       │
│     │ ├─> ID: a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a01   │       │
│     │ ├─> Email: admin@edugo.test                     │       │
│     │ ├─> PasswordHash: $2a$10$iqg7LOZsHxS8...       │       │
│     │ ├─> Role: admin                                 │       │
│     │ └─> IsActive: true                              │       │
│     └─────────────────────────────────────────────────┘       │
│                                                                 │
│  2. Valida password con PasswordHasher.Compare()               │
│     └─> Compara "edugo2024" con hash almacenado               │
│     └─> ✅ Match                                              │
│                                                                 │
│  3. Genera tokens con TokenService.GenerateTokens()            │
│     ├─> Access Token (JWT, 15 min TTL)                        │
│     └─> Refresh Token (JWT, 7 días TTL)                       │
│                                                                 │
│  4. Retorna AuthResponse con tokens + user info                │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  AuthHandler responde con JSON:                                │
│                                                                 │
│  {                                                              │
│    "access_token": "eyJhbGci...",                              │
│    "refresh_token": "eyJhbGci...",                             │
│    "expires_in": 899,                                          │
│    "token_type": "Bearer",                                     │
│    "user": {                                                   │
│      "id": "a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a01",            │
│      "email": "admin@edugo.test",                              │
│      "role": "admin",                                          │
│      "full_name": "Admin Demo"                                 │
│    }                                                           │
│  }                                                              │
│                                                                 │
│  Status: 200 OK                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Flujo de una Request Protegida: GET /v1/schools

```
┌────────────────────────────────────────────────────────────────┐
│  REQUEST: GET /v1/schools                                      │
│  Header: Authorization: Bearer eyJhbGci...                     │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  Gin Router                                                    │
│  ├─> Middleware: Logger, Recovery                             │
│  ├─> Middleware: JWTAuthMiddleware                            │
│  │   ├─> Extrae token del header                              │
│  │   ├─> Valida token con JWTManager                          │
│  │   ├─> Extrae claims (user_id, email, role)                 │
│  │   └─> Inyecta user_id en context                           │
│  └─> Handler: SchoolHandler.ListSchools                       │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  SchoolHandler.ListSchools()                                   │
│  @ internal/infrastructure/http/handler/school_handler.go      │
│                                                                 │
│  Llama a: schoolService.ListSchools()                          │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  SchoolService.ListSchools()                                   │
│  @ internal/application/service/school_service.go              │
│                                                                 │
│  Llama a: schoolRepository.List()                              │
│                                                                 │
│     ┌─────────────────────────────────────────────────┐       │
│     │ MOCK: MockSchoolRepository.List()               │       │
│     │ @ internal/infrastructure/persistence/          │       │
│     │   mock/repository/school_repository_mock.go     │       │
│     │                                                  │       │
│     │ 1. Itera sobre data.GetSchools() (in-memory)    │       │
│     │ 2. Filtra schools con DeletedAt == nil          │       │
│     │ 3. Ordena por Name                              │       │
│     │ 4. Retorna copias inmutables (no referencias)   │       │
│     │                                                  │       │
│     │ Escuelas retornadas: 3                          │       │
│     │ ├─> Escuela Primaria Demo (SCH_PRI_001)        │       │
│     │ ├─> Colegio Secundario Demo (SCH_SEC_001)      │       │
│     │ └─> Instituto Técnico Demo (SCH_TEC_001)       │       │
│     └─────────────────────────────────────────────────┘       │
│                                                                 │
│  Retorna lista de 3 schools                                    │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────┐
│  SchoolHandler responde con JSON:                              │
│                                                                 │
│  [                                                              │
│    {                                                            │
│      "id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",            │
│      "name": "Escuela Primaria Demo",                          │
│      "code": "SCH_PRI_001",                                    │
│      "address": "Calle Principal 123",                         │
│      ...                                                       │
│    },                                                           │
│    ...                                                          │
│  ]                                                              │
│                                                                 │
│  Status: 200 OK                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Componentes del Sistema Mock

### 1. Factory Pattern

```
RepositoryFactory (Interface)
├─> MockRepositoryFactory
│   └─> Crea instancias de Mock*Repository
└─> PostgresRepositoryFactory
    └─> Crea instancias de Postgres*Repository
```

### 2. Mock Repositories (9 implementaciones)

```
internal/infrastructure/persistence/mock/repository/
├─> school_repository_mock.go           (9 métodos)
├─> user_repository_mock.go             (7 métodos)
├─> academic_unit_repository_mock.go    (13 métodos)
├─> unit_membership_repository_mock.go  (8 métodos)
├─> unit_repository_mock.go             (5 métodos)
├─> subject_repository_mock.go          (6 métodos)
├─> material_repository_mock.go         (2 métodos)
├─> guardian_repository_mock.go         (13 métodos)
└─> stats_repository_mock.go            (1 método)

TOTAL: 64 métodos implementados
```

### 3. Mock Data (8 entidades)

```
internal/infrastructure/persistence/mock/data/
├─> users.go              (8 usuarios con password hash)
├─> schools.go            (3 escuelas)
├─> academic_units.go     (12 unidades académicas jerárquicas)
├─> memberships.go        (5 memberships usuario-unidad)
├─> subjects.go           (6 materias)
├─> units.go              (4 unidades organizacionales)
├─> materials.go          (4 materiales educativos)
└─> guardian_relations.go (3 relaciones tutor-estudiante)

TOTAL: 42 registros precargados
```

---

## Características Técnicas de Mock Repositories

### Thread Safety
```go
type MockSchoolRepository struct {
    mu      sync.RWMutex  // Protege acceso concurrente
    schools map[uuid.UUID]*entities.School
}

func (r *MockSchoolRepository) FindByID(ctx context.Context, id uuid.UUID) (*entities.School, error) {
    r.mu.RLock()         // Read lock
    defer r.mu.RUnlock()
    
    school, exists := r.schools[id]
    if !exists {
        return nil, repository.ErrSchoolNotFound
    }
    
    // Retorna COPIA, no referencia
    return copySchool(school), nil
}
```

### Inmutabilidad
Todos los métodos retornan **copias profundas** de las entidades, nunca referencias directas al map interno. Esto previene modificaciones accidentales del estado compartido.

### Validaciones
Replican las validaciones de PostgreSQL:
- Unique constraints (ej: `school.code` debe ser único)
- Foreign key checks (ej: `academic_unit.school_id` debe existir)
- NOT NULL constraints
- Soft delete (respetan `DeletedAt`)

---

## Ventajas del Sistema Actual

✅ **Sin infraestructura externa:** No requiere PostgreSQL, MongoDB, RabbitMQ  
✅ **Arranque rápido:** <3 segundos vs 15s con Docker  
✅ **Ahorro de RAM:** ~1.2GB menos  
✅ **Datos predecibles:** Siempre el mismo dataset  
✅ **Thread-safe:** Soporta requests concurrentes  
✅ **Portable:** Funciona en cualquier máquina sin setup  

---

## Limitaciones Conocidas

⚠️ **Sin persistencia:** Datos se pierden al reiniciar  
⚠️ **Sin transacciones:** Operaciones son atómicas pero independientes  
⚠️ **Capacidad limitada:** Diseñado para <1000 registros  
⚠️ **Sin validaciones complejas:** No replica 100% las constraints de PostgreSQL  
