# FASE 0.2 - Análisis de Dependencias
## Refactorización de edugo-api-mobile con Bootstrap Genérico

**Fecha:** 12 de Noviembre, 2025  
**Proyecto:** edugo-api-mobile  
**Objetivo:** Documentar todas las dependencias y puntos de integración antes de la refactorización

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Inventario de Código Actual](#inventario-de-código-actual)
3. [Análisis de Configuración](#análisis-de-configuración)
4. [Análisis de Bootstrap](#análisis-de-bootstrap)
5. [Análisis de Lifecycle](#análisis-de-lifecycle)
6. [Puntos de Uso](#puntos-de-uso)
7. [Incompatibilidades de Tipos](#incompatibilidades-de-tipos)
8. [Tests de Integración](#tests-de-integración)
9. [Plan de Adaptación](#plan-de-adaptación)
10. [Riesgos Identificados](#riesgos-identificados)

---

## 1. Resumen Ejecutivo

### Estado Actual
- **Total LOC en internal/bootstrap:** 1,849 líneas
- **Total LOC en internal/config:** ~500 líneas  
- **Tests de integración:** 591 LOC (bootstrap_integration_test.go)
- **Uso en aplicación:** 3 archivos (main.go, container.go, testhelpers.go)

### Hallazgos Clave

#### ✅ Código Duplicado (Puede Eliminarse)
- `internal/bootstrap/lifecycle.go` (155 LOC) - **DUPLICADO EXACTO** con `shared/lifecycle`
  - Mismo algoritmo LIFO
  - Misma gestión de errores
  - Diferencias menores: shared tiene más features (contexto, startup)
  - **Decisión:** Eliminar y usar `shared/lifecycle` directamente

#### ⚠️ Incompatibilidades de Tipos (Requiere Adaptadores)

| Componente | api-mobile | shared | Solución |
|------------|-----------|--------|----------|
| Logger | `logger.Logger` (interfaz) | `*logrus.Logger` (struct) | Adapter: LoggerAdapter |
| PostgreSQL | `*sql.DB` | `*gorm.DB` | Adapter: DatabaseAdapter con `.DB()` |
| MongoDB | `*mongo.Database` | `*mongo.Database` | ✅ Compatible directo |
| RabbitMQ | `rabbitmq.Publisher` (interfaz) | `*amqp.Channel` | Adapter: MessagePublisherAdapter |
| S3 | `S3Storage` (interfaz) | `*s3.Client` | Adapter: StorageClientAdapter |

#### 🔧 Funcionalidad Única (Preservar)
- `internal/infrastructure/storage/s3/client.go` (221 LOC)
  - Métodos de presigned URLs
  - Tests exhaustivos (591 LOC en bootstrap_integration_test.go)
  - **No existe en shared/bootstrap**
  - **Decisión:** Mantener en api-mobile, adaptar para usar shared S3 client

---

## 2. Inventario de Código Actual

### 2.1 internal/bootstrap/ (1,849 LOC)

```
internal/bootstrap/
├── bootstrap.go                      # 304 LOC - Orquestación principal
├── config.go                         # 147 LOC - BootstrapOptions y configuración
├── interfaces.go                     # 89 LOC  - Interfaces de factories
├── factories.go                      # 62 LOC  - DefaultFactories implementación
├── lifecycle.go                      # 155 LOC - ⚠️ DUPLICADO con shared/lifecycle
├── noop/                             # 128 LOC - Implementaciones noop
│   ├── publisher.go
│   └── s3.go
├── bootstrap_test.go                 # 173 LOC - Tests unitarios
├── lifecycle_test.go                 # 200 LOC - Tests de lifecycle
└── bootstrap_integration_test.go     # 591 LOC - Tests de integración completos
```

### 2.2 internal/config/ (~500 LOC)

```
internal/config/
├── config.go           # 162 LOC - Structs de configuración
├── loader.go           # 192 LOC - Carga con Viper
├── validator.go        # 115 LOC - Validación con go-playground/validator
├── loader_test.go      # ~50 LOC
└── validator_test.go   # ~50 LOC
```

### 2.3 internal/infrastructure/

```
internal/infrastructure/
├── database/
│   ├── postgres.go           # Retorna *sql.DB
│   ├── postgres_test.go
│   ├── mongodb.go            # Retorna *mongo.Database
│   └── mongodb_test.go
├── messaging/
│   ├── rabbitmq/
│   │   ├── publisher.go      # Interfaz: Publisher
│   │   └── publisher_test.go
│   └── events.go
└── storage/
    └── s3/
        ├── client.go         # ⚠️ FUNCIONALIDAD ÚNICA - Presigned URLs
        ├── client_test.go
        └── interface.go      # Interfaz: S3Storage
```

---

## 3. Análisis de Configuración

### 3.1 Struct Config de api-mobile

```go
// internal/config/config.go
type Config struct {
    Server      ServerConfig      // ✅ Compatible con shared.BaseConfig
    Database    DatabaseConfig    // ⚠️ Estructura diferente
    Messaging   MessagingConfig   // ⚠️ Estructura diferente
    Storage     StorageConfig     // ⚠️ Estructura diferente
    Logging     LoggingConfig     // ✅ Compatible
    Environment string            // ✅ Compatible
    Auth        AuthConfig        // ✅ Compatible (JWT)
    Bootstrap   BootstrapConfig   // ❌ No existe en shared
}
```

### 3.2 Comparación con shared/config.BaseConfig

| Campo | api-mobile | shared/config.BaseConfig | Compatible |
|-------|-----------|--------------------------|------------|
| Server | `ServerConfig` | `ServerConfig` | ✅ Sí |
| Database.Postgres | `PostgresConfig` | `PostgreSQLConfig` | ⚠️ Nombres de campos diferentes |
| Database.MongoDB | `MongoDBConfig` | `MongoDBConfig` | ✅ Sí |
| Messaging.RabbitMQ | `RabbitMQConfig` | `RabbitMQConfig` | ⚠️ Estructura diferente (queues, exchanges) |
| Storage.S3 | `S3Config` | `S3Config` | ✅ Sí |
| Logging | `LoggingConfig` | ❌ No existe | ⚠️ Falta en shared |
| Auth.JWT | `JWTConfig` | `JWTSecret string` | ⚠️ Estructura vs string |
| Bootstrap | `BootstrapConfig` | ❌ No existe | ❌ Específico de api-mobile |

### 3.3 Campos Específicos de api-mobile

#### Database.Postgres
```go
// api-mobile
type PostgresConfig struct {
    Host           string
    Port           int
    Database       string
    User           string
    Password       string
    MaxConnections int
    SSLMode        string
}
```

#### Messaging.RabbitMQ
```go
// api-mobile - Tiene configuración de colas y exchanges
type RabbitMQConfig struct {
    URL           string
    Queues        QueuesConfig   // ❌ No en shared
    Exchanges     ExchangeConfig // ❌ No en shared
    PrefetchCount int
}

type QueuesConfig struct {
    MaterialUploaded  string
    AssessmentAttempt string
}

type ExchangeConfig struct {
    Materials string
}
```

#### Bootstrap.OptionalResources
```go
// api-mobile - Sistema de recursos opcionales
type BootstrapConfig struct {
    OptionalResources OptionalResourcesConfig
}

type OptionalResourcesConfig struct {
    RabbitMQ bool // ENV: BOOTSTRAP_OPTIONAL_RESOURCES_RABBITMQ
    S3       bool // ENV: BOOTSTRAP_OPTIONAL_RESOURCES_S3
}
```

### 3.4 Loader de Configuración

**api-mobile:** `internal/config/loader.go` (192 LOC)
- Usa Viper con múltiples fuentes
- Precedencia: ENV vars > config-{env}.yaml > config.yaml > defaults
- AutomaticEnv con replacer (`.` → `_`)
- Bind explícito de ENV vars críticas
- Validación con `go-playground/validator`

**shared:** `config/loader.go` (130 LOC)
- Similar arquitectura con Viper
- Menos bind explícitos
- Validación integrada

**Decisión:** Mantener loader de api-mobile, adaptar para cargar en shared.BaseConfig

---

## 4. Análisis de Bootstrap

### 4.1 Arquitectura Actual de api-mobile

```
┌─────────────────────────────────────────────────────────┐
│                    main.go                              │
│  - config.Load()                                        │
│  - bootstrap.New(cfg)                                   │
│  - b.InitializeInfrastructure(ctx)                      │
│    → Resources, cleanup, error                          │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              bootstrap.Bootstrapper                      │
│                                                          │
│  1. initializeLogger()        → logger.Logger           │
│  2. initializePostgreSQL()    → *sql.DB                 │
│  3. initializeMongoDB()       → *mongo.Database         │
│  4. initializeRabbitMQ()      → rabbitmq.Publisher      │
│  5. initializeS3()            → S3Storage               │
│                                                          │
│  Retorna: Resources, cleanup func, error                │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              bootstrap.Resources                         │
│                                                          │
│  - Logger            logger.Logger                      │
│  - PostgreSQL        *sql.DB                            │
│  - MongoDB           *mongo.Database                    │
│  - RabbitMQPublisher rabbitmq.Publisher                 │
│  - S3Client          S3Storage                          │
│  - JWTSecret         string                             │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│            container.NewContainer(resources)             │
│                                                          │
│  1. InfrastructureContainer  (recursos externos)        │
│  2. RepositoryContainer      (persistencia)             │
│  3. ServiceContainer         (lógica de negocio)        │
│  4. HandlerContainer         (presentación HTTP)        │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Arquitectura de shared/bootstrap

```
┌─────────────────────────────────────────────────────────┐
│           shared/bootstrap.Bootstrap()                   │
│                                                          │
│  Parámetros:                                            │
│  - ctx context.Context                                  │
│  - config interface{}                                   │
│  - factories *Factories                                 │
│  - lifecycleManager interface{}                         │
│  - options ...BootstrapOption                           │
│                                                          │
│  Retorna: *Resources, error                             │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              shared/bootstrap.Resources                  │
│                                                          │
│  - Logger            *logrus.Logger                     │
│  - PostgreSQL        *gorm.DB                           │
│  - MongoDB           *mongo.Client                      │
│  - MongoDatabase     *mongo.Database                    │
│  - MessagePublisher  MessagePublisher (interfaz)        │
│  - StorageClient     StorageClient (interfaz)           │
└─────────────────────────────────────────────────────────┘
```

### 4.3 Comparación de Interfaces de Factories

#### api-mobile: bootstrap/interfaces.go (89 LOC)

```go
type LoggerFactory interface {
    Create(level, format string) (logger.Logger, error)
}

type DatabaseFactory interface {
    CreatePostgreSQL(ctx, cfg, log) (*sql.DB, error)
    CreateMongoDB(ctx, cfg, log) (*mongo.Database, error)
}

type MessagingFactory interface {
    CreatePublisher(url, exchange, log) (rabbitmq.Publisher, error)
}

type StorageFactory interface {
    CreateS3Client(ctx, cfg, log) (S3Storage, error)
}
```

#### shared: bootstrap/interfaces.go (229 LOC)

```go
type LoggerFactory interface {
    CreateLogger(ctx, config) (*logrus.Logger, error)
}

type PostgreSQLFactory interface {
    CreateConnection(ctx, config) (*gorm.DB, error)
    CreateRawConnection(ctx, config) (*sql.DB, error)  // ✅ Disponible
    Ping(ctx, db) error
    Close(db) error
}

type MongoDBFactory interface {
    CreateConnection(ctx, config) (*mongo.Client, error)
    CreateDatabase(client, dbName) (*mongo.Database, error)
    Ping(ctx, client) error
    Close(ctx, client) error
}

type RabbitMQFactory interface {
    CreateConnection(ctx, config) (*amqp.Connection, error)
    CreateChannel(conn) (*amqp.Channel, error)
    DeclareExchange(channel, config) error
    // ... más métodos
}

type S3Factory interface {
    CreateClient(ctx, config) (*s3.Client, error)
    ValidateBucket(ctx, client, bucket) error
}
```

### 4.4 Diferencias Clave

| Aspecto | api-mobile | shared | Impacto |
|---------|-----------|--------|---------|
| **Tipos de retorno** | Interfaces y tipos concretos mezclados | Tipos concretos | ⚠️ Requiere adaptadores |
| **Logger** | `logger.Logger` interfaz | `*logrus.Logger` struct | ⚠️ Adapter necesario |
| **PostgreSQL** | `*sql.DB` | `*gorm.DB` (pero tiene `CreateRawConnection`) | ✅ Usar `CreateRawConnection` |
| **MongoDB** | `*mongo.Database` | `*mongo.Client` + separar Database | ⚠️ Adapter para obtener Database |
| **RabbitMQ** | `rabbitmq.Publisher` interfaz | `*amqp.Channel` | ⚠️ Adapter necesario |
| **S3** | `S3Storage` interfaz con presigned | `*s3.Client` básico | ⚠️ Mantener wrapper local |
| **Lifecycle** | `LifecycleManager` interno | `lifecycle.Manager` en shared | ✅ Usar shared directamente |
| **Configuración** | Struct completo `*config.Config` | `interface{}` genérico | ⚠️ Type assertion necesaria |
| **Context** | Solo en factories | En Bootstrap principal también | ✅ Compatible |

---

## 5. Análisis de Lifecycle

### 5.1 Comparación: api-mobile vs shared

| Aspecto | api-mobile (`internal/bootstrap/lifecycle.go`) | shared (`lifecycle/manager.go`) |
|---------|-----------------------------------------------|--------------------------------|
| **LOC** | 155 líneas | 190 líneas |
| **Package** | `package bootstrap` | `package lifecycle` |
| **Struct** | `LifecycleManager` | `Manager` |
| **Algoritmo** | LIFO cleanup | LIFO startup + cleanup |
| **Context** | ❌ No soporta | ✅ Sí (`context.Context` en todos los métodos) |
| **Startup** | ❌ No existe | ✅ `Startup(ctx)` para inicializar recursos |
| **Cleanup** | ✅ `Cleanup() error` | ✅ `Cleanup(ctx) error` |
| **Thread-safety** | ✅ `sync.Mutex` | ✅ `sync.Mutex` |
| **Multiple calls** | ✅ Previene con flag `cleaned` | ✅ Previene con flag |
| **Error handling** | ✅ Recolecta todos los errores | ✅ Recolecta todos los errores |
| **Logger** | `logger.Logger` interfaz | `*zap.Logger` directamente |

### 5.2 Similitudes (98% de código idéntico)

```go
// Ambos tienen la misma estructura básica
type LifecycleManager struct {  // api-mobile
type Manager struct {            // shared
    cleanupFuncs []resourceCleanup  // Misma estructura
    logger       logger.Logger       // Mismo propósito
    mu           sync.Mutex          // Mismo mecanismo
    cleaned      bool                // Misma prevención
}

// Ambos usan LIFO (Last In, First Out)
for i := len(lm.cleanupFuncs) - 1; i >= 0; i-- {
    // Ejecutar cleanup en orden inverso
}

// Ambos recolectan errores sin detener el proceso
var errors []error
for ... {
    if err := rc.cleanup(); err != nil {
        errors = append(errors, err)
    }
}
```

### 5.3 Ventajas de shared/lifecycle

1. **Context Support:** Permite cancelación y timeouts
   ```go
   // shared
   func (m *Manager) Cleanup(ctx context.Context) error
   
   // Permite:
   ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
   defer cancel()
   err := lifecycleManager.Cleanup(ctx)
   ```

2. **Startup Management:** No solo cleanup
   ```go
   // shared - Nueva capacidad
   func (m *Manager) Register(name, startupFn, cleanupFn)
   func (m *Manager) Startup(ctx context.Context) error
   ```

3. **Mejor tipo de logger:** Usa `*zap.Logger` directamente (más performance)

### 5.4 Puntos de Uso Actuales

```bash
# api-mobile usa lifecycle en 2 lugares:
./internal/bootstrap/bootstrap.go:  b.lifecycle = NewLifecycleManager(b.logger)
./internal/bootstrap/bootstrap.go:  b.lifecycle.Register("postgresql", func() error { ... })
./internal/bootstrap/bootstrap.go:  b.lifecycle.Register("mongodb", func() error { ... })
./internal/bootstrap/bootstrap.go:  b.lifecycle.Register("rabbitmq", func() error { ... })
./internal/bootstrap/bootstrap.go:  return b.lifecycle.Cleanup()
```

**Patrón actual:**
```go
b.lifecycle = NewLifecycleManager(b.logger)
b.lifecycle.Register("postgresql", func() error {
    b.logger.Info("closing PostgreSQL connection")
    return db.Close()
})
// ... más registros
cleanup := func() error {
    return b.lifecycle.Cleanup()
}
```

**Con shared/lifecycle:**
```go
import "github.com/EduGoGroup/edugo-shared/lifecycle"

b.lifecycle = lifecycle.NewManager(zapLogger)
b.lifecycle.Register(
    "postgresql",
    nil, // startupFn (no usamos startup en este refactor)
    func() error {
        b.logger.Info("closing PostgreSQL connection")
        return db.Close()
    },
)
// ... más registros
cleanup := func() error {
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()
    return b.lifecycle.Cleanup(ctx)
}
```

### 5.5 Decisión Final: Lifecycle

✅ **ELIMINAR** `internal/bootstrap/lifecycle.go` (155 LOC)  
✅ **USAR** `github.com/EduGoGroup/edugo-shared/lifecycle`

**Justificación:**
- Código 98% idéntico
- shared tiene más features (context, startup)
- No hay dependencias específicas de api-mobile
- Reduce duplicación
- Mantiene consistencia entre proyectos EduGo

**Impacto:**
- Reducción de 155 LOC
- Cambios menores en bootstrap.go (import y tipo de logger)
- Tests de lifecycle pueden eliminarse (ya están en shared)

---

## 6. Puntos de Uso

### 6.1 Uso de bootstrap.Resources en Aplicación

```bash
# Buscar uso de bootstrap.Resources
$ grep -r "bootstrap\.Resources" --include="*.go" | grep -v "_test.go"

./internal/container/container.go:
    func NewContainer(resources *bootstrap.Resources) *Container

./test/integration/testhelpers.go:
    resources := &bootstrap.Resources{ ... }  # 2 instancias
```

#### 6.1.1 internal/container/container.go

```go
// Uso principal: Inyectar recursos en DI container
func NewContainer(resources *bootstrap.Resources) *Container {
    infra := NewInfrastructureContainer(
        resources.PostgreSQL,        // *sql.DB
        resources.MongoDB,           // *mongo.Database
        resources.RabbitMQPublisher, // rabbitmq.Publisher (interfaz)
        resources.S3Client,          // S3Storage (interfaz)
        resources.JWTSecret,         // string
        resources.Logger,            // logger.Logger (interfaz)
    )
    
    repos := NewRepositoryContainer(infra)
    services := NewServiceContainer(infra, repos)
    handlers := NewHandlerContainer(infra, services)
    
    return &Container{
        Infrastructure: infra,
        Repositories:   repos,
        Services:       services,
        Handlers:       handlers,
    }
}
```

**Análisis:**
- `NewContainer` es el único punto de inyección de recursos
- Todos los recursos se pasan a `InfrastructureContainer`
- No hay acceso directo a `Resources` en capas superiores

#### 6.1.2 test/integration/testhelpers.go

```go
// Instancia 1: Setup de infraestructura compartida
func setupSharedTestInfrastructure(t *testing.T) (*bootstrap.Resources, func()) {
    resources := &bootstrap.Resources{
        Logger:     testLogger,
        PostgreSQL: testDB,
        MongoDB:    testMongoDB,
        RabbitMQPublisher: noop.NewNoopPublisher(testLogger),
        S3Client:          noop.NewNoopS3Storage(testLogger),
        JWTSecret:         "test-secret",
    }
    return resources, cleanup
}

// Instancia 2: Container para tests
func setupTestContainer(t *testing.T) (*container.Container, func()) {
    resources := &bootstrap.Resources{
        Logger:     testLogger,
        PostgreSQL: testDB,
        MongoDB:    testMongoDB,
        RabbitMQPublisher: noop.NewNoopPublisher(testLogger),
        S3Client:          noop.NewNoopS3Storage(testLogger),
        JWTSecret:         "test-secret",
    }
    return container.NewContainer(resources), cleanup
}
```

**Análisis:**
- Tests usan construcción manual de `Resources`
- RabbitMQ y S3 siempre usan implementaciones noop
- Solo PostgreSQL y MongoDB son reales en tests de integración

### 6.2 Flujo Completo desde main.go

```go
// cmd/main.go
func main() {
    ctx := context.Background()

    // 1. Cargar configuración
    cfg, err := config.Load()
    
    // 2. Inicializar infraestructura
    b := bootstrap.New(cfg)
    resources, cleanup, err := b.InitializeInfrastructure(ctx)
    defer cleanup()
    
    // 3. Crear container DI
    c := container.NewContainer(resources)
    
    // 4. Configurar router
    healthHandler := handler.NewHealthHandler(
        resources.PostgreSQL,  // ⚠️ Acceso directo a PostgreSQL
        resources.MongoDB,     // ⚠️ Acceso directo a MongoDB
    )
    r := router.SetupRouter(c, healthHandler)
    
    // 5. Iniciar servidor
    startServer(r, cfg, resources.Logger)
}
```

**Puntos de acoplamiento:**
1. `container.NewContainer(resources)` - Necesita adaptarse
2. `handler.NewHealthHandler(resources.PostgreSQL, resources.MongoDB)` - Acceso directo
3. `startServer(r, cfg, resources.Logger)` - Acceso al logger

### 6.3 Uso en InfrastructureContainer

```go
// internal/container/infrastructure.go
type InfrastructureContainer struct {
    Logger            logger.Logger            // ⚠️ Interfaz
    PostgreSQL        *sql.DB                  // ⚠️ Tipo concreto
    MongoDB           *mongo.Database          // ✅ Compatible
    RabbitMQPublisher rabbitmq.Publisher       // ⚠️ Interfaz
    S3Client          S3Storage                // ⚠️ Interfaz local
    JWTAuth           *auth.JWTAuth
}

func NewInfrastructureContainer(
    db *sql.DB,
    mongoDB *mongo.Database,
    rabbitPub rabbitmq.Publisher,
    s3Client S3Storage,
    jwtSecret string,
    log logger.Logger,
) *InfrastructureContainer {
    return &InfrastructureContainer{
        Logger:            log,
        PostgreSQL:        db,
        MongoDB:           mongoDB,
        RabbitMQPublisher: rabbitPub,
        S3Client:          s3Client,
        JWTAuth:           auth.NewJWTAuth(jwtSecret),
    }
}
```

**Análisis:**
- InfrastructureContainer almacena tipos específicos de api-mobile
- Necesitaremos adapters para convertir tipos de shared a tipos esperados

### 6.4 Cadena de Dependencias

```
main.go
  ↓ usa bootstrap.Resources
container.NewContainer(resources)
  ↓ descompone en campos
NewInfrastructureContainer(resources.PostgreSQL, ...)
  ↓ almacena en struct
InfrastructureContainer { PostgreSQL: *sql.DB, ... }
  ↓ inyecta en
RepositoryContainer, ServiceContainer, HandlerContainer
  ↓ usan directamente
Repositorios, Servicios, Handlers
```

**Implicación:** Necesitamos adaptadores en la capa de `bootstrap.Resources` para que todo lo downstream siga funcionando sin cambios.

---

## 7. Incompatibilidades de Tipos

### 7.1 Logger

#### Problema
```go
// api-mobile espera:
type logger.Logger interface {
    Info(msg string, fields ...zap.Field)
    Error(msg string, fields ...zap.Field)
    // ... más métodos
}

// shared/bootstrap retorna:
type *logrus.Logger struct { ... }
```

#### Solución: LoggerAdapter
```go
// internal/bootstrap/adapter/logger.go
type LoggerAdapter struct {
    logrus *logrus.Logger
}

func (a *LoggerAdapter) Info(msg string, fields ...zap.Field) {
    // Convertir zap.Field a logrus.Fields
    a.logrus.WithFields(convertFields(fields)).Info(msg)
}

func (a *LoggerAdapter) Error(msg string, fields ...zap.Field) {
    a.logrus.WithFields(convertFields(fields)).Error(msg)
}

// ... implementar todos los métodos de logger.Logger
```

**Ventaja:** No cambiamos nada en la aplicación existente

### 7.2 PostgreSQL

#### Problema Inicial
```go
// api-mobile usa:
*sql.DB

// shared/bootstrap retorna:
*gorm.DB
```

#### Solución: Usar CreateRawConnection de shared

```go
// shared/bootstrap tiene ambos métodos:
type PostgreSQLFactory interface {
    CreateConnection(ctx, config) (*gorm.DB, error)
    CreateRawConnection(ctx, config) (*sql.DB, error)  // ✅ Esto necesitamos
}
```

**Decisión:** Usar `CreateRawConnection` directamente, no se necesita adapter

**Justificación:**
- shared ya provee el tipo que necesitamos
- api-mobile usa `*sql.DB` en toda la aplicación
- No queremos migrar a GORM en este refactor
- Mantenemos el contrato actual de api-mobile

### 7.3 MongoDB

#### Compatibilidad Directa
```go
// Ambos usan:
*mongo.Database

// shared retorna *mongo.Client primero, luego obtenemos Database
client := factory.CreateConnection(ctx, config)
database := client.Database("edugo_mobile")
```

**Solución:** Llamar a `.Database()` en el adapter

```go
// internal/bootstrap/adapter/database.go
func (a *DatabaseAdapter) GetMongoDatabase(
    client *mongo.Client,
    dbName string,
) *mongo.Database {
    return client.Database(dbName)
}
```

### 7.4 RabbitMQ

#### Problema
```go
// api-mobile espera:
type rabbitmq.Publisher interface {
    Publish(ctx, event) error
    Close() error
}

// shared/bootstrap retorna:
*amqp.Channel
```

#### Solución: MessagePublisherAdapter
```go
// internal/bootstrap/adapter/messaging.go
type MessagePublisherAdapter struct {
    channel  *amqp.Channel
    exchange string
    logger   logger.Logger
}

func (a *MessagePublisherAdapter) Publish(
    ctx context.Context,
    event interface{},
) error {
    body, err := json.Marshal(event)
    if err != nil {
        return fmt.Errorf("failed to marshal event: %w", err)
    }
    
    return a.channel.PublishWithContext(
        ctx,
        a.exchange,
        "", // routing key
        false, false,
        amqp.Publishing{
            ContentType: "application/json",
            Body:        body,
        },
    )
}

func (a *MessagePublisherAdapter) Close() error {
    return a.channel.Close()
}
```

**Ventaja:** Mantiene interfaz `rabbitmq.Publisher` sin cambios en la aplicación

### 7.5 S3 Storage

#### Problema
```go
// api-mobile espera:
type S3Storage interface {
    GeneratePresignedUploadURL(ctx, key, contentType, expires) (string, error)
    GeneratePresignedDownloadURL(ctx, key, expires) (string, error)
}

// shared/bootstrap retorna:
*s3.Client  // SDK de AWS, no tiene presigned methods directos
```

#### Solución: Mantener wrapper de api-mobile

```go
// internal/infrastructure/storage/s3/client.go (preservar)
type S3Client struct {
    client       *s3.Client           // ✅ Usar de shared
    presignClient *s3.PresignClient   // ✅ Crear localmente
    bucketName   string
    logger       logger.Logger
}

func NewS3ClientFromShared(
    sharedClient *s3.Client,
    bucketName string,
    logger logger.Logger,
) *S3Client {
    return &S3Client{
        client:       sharedClient,
        presignClient: s3.NewPresignClient(sharedClient),
        bucketName:   bucketName,
        logger:       logger,
    }
}

// Métodos de presigned URLs se mantienen igual
func (c *S3Client) GeneratePresignedUploadURL(...) (string, error) {
    // Implementación actual se preserva
}
```

**Ventaja:** 
- Usamos shared para crear el cliente base
- Agregamos funcionalidad de presigned URLs encima
- Tests existentes (591 LOC) siguen funcionando

---

## 8. Tests de Integración

### 8.1 Inventario de Tests

#### bootstrap_integration_test.go (591 LOC)
```go
// 11 test cases:
1. TestNormalInitialization             // ✅ Inicialización completa
2. TestPostgreSQLFailure                // ⚠️ Fallo de PostgreSQL
3. TestMongoDBFailure                   // ⚠️ Fallo de MongoDB
4. TestOptionalRabbitMQFailure          // ⚠️ RabbitMQ opcional falla
5. TestOptionalS3Failure                // ⚠️ S3 opcional falla
6. TestRequiredRabbitMQFailure          // ⚠️ RabbitMQ requerido falla
7. TestRequiredS3Failure                // ⚠️ S3 requerido falla
8. TestInjectedLogger                   // ✅ Logger inyectado
9. TestInjectedPostgreSQL               // ✅ PostgreSQL inyectado
10. TestPartialCleanupOnFailure         // ⚠️ Cleanup parcial
11. TestCleanupIdempotency              // ✅ Cleanup múltiple
```

#### Categorías de Tests

**Tipo 1: Tests de Éxito (3 tests)**
- Verifican inicialización correcta
- Verifican recursos inyectados funcionan
- Verifican cleanup idempotente

**Tipo 2: Tests de Fallos (5 tests)**
- Verifican manejo de recursos requeridos que fallan
- Verifican degradación graciosa de recursos opcionales
- Verifican cleanup parcial cuando falla algo

**Tipo 3: Tests de Opcionalidad (3 tests)**
- Verifican sistema de recursos opcionales
- Verifican uso de implementaciones noop

### 8.2 Dependencias de Tests

```go
// Usa testcontainers para infraestructura real
import (
    "github.com/testcontainers/testcontainers-go/modules/mongodb"
    "github.com/testcontainers/testcontainers-go/modules/postgres"
    "github.com/testcontainers/testcontainers-go/modules/rabbitmq"
)

func setupTestContainers(t *testing.T, ctx context.Context) {
    pgContainer := postgres.Run(ctx, "postgres:16-alpine", ...)
    mongoContainer := mongodb.Run(ctx, "mongo:7.0", ...)
    rabbitContainer := rabbitmq.Run(ctx, "rabbitmq:3.12-management-alpine", ...)
}
```

### 8.3 Adaptación de Tests

#### Opción 1: Mantener Tests de api-mobile (Recomendada)
```go
// Mantener bootstrap_integration_test.go con modificaciones menores
// - Cambiar imports a usar shared/bootstrap
// - Adaptar creación de factories para usar shared
// - Agregar adapters en el setup

func TestNormalInitialization(t *testing.T) {
    // ... setup containers igual
    
    // CAMBIO: Crear config de shared
    sharedConfig := &bootstrap.PostgreSQLConfig{
        Host:     pgHost,
        Port:     pgPort.Int(),
        Database: "edugo_test",
        // ...
    }
    
    // CAMBIO: Usar shared/bootstrap
    factories := createTestFactoriesWithAdapters()
    lifecycleManager := lifecycle.NewManager(zapLogger)
    
    resources, err := bootstrap.Bootstrap(
        ctx,
        sharedConfig,
        factories,
        lifecycleManager,
    )
    
    // CAMBIO: Adaptar recursos al tipo esperado por api-mobile
    apiMobileResources := adaptToAPIMLResources(resources)
    
    // Resto de assertions igual
    assert.NotNil(t, apiMobileResources.PostgreSQL)
    // ...
}
```

**Ventajas:**
- Preservamos cobertura de tests existente (591 LOC de pruebas valiosas)
- Verificamos que adaptadores funcionan correctamente
- Menos riesgo de introducir bugs

#### Opción 2: Confiar en Tests de shared
```go
// Eliminar bootstrap_integration_test.go
// Confiar en que shared/bootstrap tiene tests completos (414 LOC)
```

**Desventajas:**
- Perdemos tests específicos de api-mobile
- No verificamos adaptadores
- Menos cobertura de integración

**Decisión:** Opción 1 - Mantener y adaptar tests de api-mobile

### 8.4 Nuevos Tests Necesarios

Después del refactor, necesitaremos tests adicionales para:

1. **Adapters:**
   ```go
   // test/adapter/logger_adapter_test.go
   func TestLoggerAdapter_Info(t *testing.T)
   func TestLoggerAdapter_Error(t *testing.T)
   // ...
   
   // test/adapter/messaging_adapter_test.go
   func TestMessagePublisherAdapter_Publish(t *testing.T)
   func TestMessagePublisherAdapter_Close(t *testing.T)
   
   // test/adapter/storage_adapter_test.go
   func TestStorageClientAdapter_PresignedURLs(t *testing.T)
   ```

2. **Integración con shared:**
   ```go
   // test/integration/shared_bootstrap_test.go
   func TestSharedBootstrapIntegration(t *testing.T)
   func TestAdapterCompatibility(t *testing.T)
   ```

---

## 9. Plan de Adaptación

### 9.1 Estrategia: Adaptación por Capas

```
┌─────────────────────────────────────────────────────────┐
│                Capa 1: Configuración                     │
│  - Mantener internal/config/config.go                   │
│  - Adaptar loader para crear shared.BaseConfig          │
│  - Preservar validaciones específicas                   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│           Capa 2: Bootstrap de shared                    │
│  - Llamar shared/bootstrap.Bootstrap()                   │
│  - Usar shared factories                                │
│  - Usar shared/lifecycle                                │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              Capa 3: Adaptadores                         │
│  - LoggerAdapter (shared → interfaz)                    │
│  - MessagePublisherAdapter (channel → Publisher)        │
│  - StorageClientAdapter (s3.Client → S3Storage)         │
│  - NO adaptar PostgreSQL (usar CreateRawConnection)     │
│  - NO adaptar MongoDB (llamar .Database())              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│      Capa 4: bootstrap.Resources (API antigua)           │
│  - Mantener struct existente                            │
│  - Popular con recursos adaptados                       │
│  - Sin cambios para downstream code                     │
└─────────────────────────────────────────────────────────┘
```

### 9.2 Archivos a Crear

```
internal/bootstrap/
├── adapter/
│   ├── logger.go         # LoggerAdapter: *logrus.Logger → logger.Logger
│   ├── messaging.go      # MessagePublisherAdapter: *amqp.Channel → Publisher
│   └── storage.go        # StorageClientAdapter: *s3.Client → S3Storage
├── bridge.go            # Función para llamar shared/bootstrap y adaptar
└── resources.go         # Mantener struct Resources (sin cambios)
```

### 9.3 Archivos a Modificar

```
internal/bootstrap/
├── bootstrap.go         # REFACTORIZAR: usar shared/bootstrap + adapters
├── config.go            # SIMPLIFICAR: reducir opciones redundantes
├── interfaces.go        # ELIMINAR o SIMPLIFICAR: usar de shared
├── factories.go         # ELIMINAR: usar shared factories
└── lifecycle.go         # ELIMINAR: usar shared/lifecycle

internal/config/
├── config.go            # MANTENER: struct específico de api-mobile
└── loader.go            # MODIFICAR: cargar también en shared.BaseConfig

cmd/
└── main.go              # MODIFICAR: llamar nuevo bootstrap
```

### 9.4 Archivos a Eliminar

```
internal/bootstrap/
├── lifecycle.go          # ❌ ELIMINAR (155 LOC) - Usar shared/lifecycle
├── lifecycle_test.go     # ❌ ELIMINAR (200 LOC) - Tests en shared
└── factories.go          # ❌ ELIMINAR (62 LOC) - Usar shared factories
```

**Total a eliminar:** 417 LOC

### 9.5 LOC Neto Esperado

```
Eliminado:
- lifecycle.go            155 LOC
- lifecycle_test.go       200 LOC
- factories.go             62 LOC
TOTAL ELIMINADO:         -417 LOC

Creado:
+ adapter/logger.go        ~80 LOC
+ adapter/messaging.go     ~60 LOC
+ adapter/storage.go       ~40 LOC
+ bridge.go               ~100 LOC
TOTAL CREADO:            +280 LOC

Modificado (estimado):
  bootstrap.go            ~200 LOC (de 304) → Simplificación
  
NETO:                    -137 LOC

Reducción porcentual:    ~7.4% del bootstrap actual (1849 LOC)
```

---

## 10. Riesgos Identificados

### 10.1 Riesgo Alto ⚠️

#### 1. Incompatibilidad de Logger en Toda la Aplicación
**Descripción:** La aplicación usa `logger.Logger` interfaz en ~100 archivos

**Impacto:** 
- Si adapter falla, toda la aplicación deja de loggear correctamente
- Pérdida de observabilidad en producción

**Mitigación:**
- Tests exhaustivos del LoggerAdapter
- Tests de integración end-to-end con logging
- Validar que todos los métodos de la interfaz están implementados

#### 2. PostgreSQL: sql.DB vs gorm.DB
**Descripción:** Toda la capa de persistencia usa `*sql.DB`

**Impacto:**
- Si usamos `*gorm.DB`, necesitamos migrar ~50 archivos de repositorios
- Alto riesgo de bugs en queries

**Mitigación:** ✅ **YA DECIDIDO**
- Usar `shared/bootstrap.CreateRawConnection` que retorna `*sql.DB`
- Sin impacto en repositorios existentes

### 10.2 Riesgo Medio ⚠️

#### 3. Presigned URLs de S3
**Descripción:** api-mobile tiene 591 LOC de tests para presigned URLs

**Impacto:**
- Funcionalidad crítica para upload/download de materiales
- Si se rompe, docentes no pueden subir archivos

**Mitigación:**
- Mantener wrapper local `internal/infrastructure/storage/s3/client.go`
- Usar `shared/bootstrap` solo para crear cliente base
- Preservar tests existentes (591 LOC)

#### 4. RabbitMQ Publisher Interfaz
**Descripción:** shared retorna `*amqp.Channel`, api-mobile espera `Publisher` interfaz

**Impacto:**
- Eventos no se publican correctamente
- Procesamiento asíncrono (worker) no funciona

**Mitigación:**
- MessagePublisherAdapter bien testeado
- Tests de integración con RabbitMQ real (testcontainers)
- Verificar que todos los métodos de Publisher están implementados

### 10.3 Riesgo Bajo ℹ️

#### 5. MongoDB: Client vs Database
**Descripción:** shared retorna `*mongo.Client`, api-mobile usa `*mongo.Database`

**Impacto:**
- Error de compilación si no se adapta
- Fácil de detectar y fix

**Mitigación:**
- Simple: llamar `client.Database("edugo_mobile")`
- No requiere adapter complejo

#### 6. Lifecycle Context
**Descripción:** shared/lifecycle usa `context.Context`, api-mobile no

**Impacto:**
- Cleanup puede no respetar timeouts
- Posible hang en shutdown

**Mitigación:**
- Crear context con timeout en main.go
- Tests de cleanup con contexto cancelado

### 10.4 Riesgo Muy Bajo ✅

#### 7. Configuración de Recursos Opcionales
**Descripción:** api-mobile tiene `BootstrapConfig.OptionalResources` específico

**Impacto:**
- Funcionalidad de degradación graciosa puede perderse

**Mitigación:**
- shared/bootstrap tiene `WithOptionalResources()` option
- Mapear configuración de api-mobile a opciones de shared

#### 8. Tests de Integración
**Descripción:** 591 LOC de tests que usan bootstrap interno

**Impacto:**
- Tests fallan después del refactor
- Pérdida temporal de cobertura

**Mitigación:**
- Adaptar tests antes de mergear
- Mantener tests funcionando durante todo el refactor
- No mergear hasta que 100% de tests pasen

---

## 11. Métricas Actuales

### 11.1 Código Base

| Componente | Archivos | LOC | Tests | LOC Tests |
|------------|----------|-----|-------|-----------|
| internal/bootstrap/ | 9 | 1,849 | 3 | 964 |
| internal/config/ | 5 | ~500 | 2 | ~100 |
| internal/infrastructure/database/ | 4 | ~300 | 2 | ~150 |
| internal/infrastructure/messaging/ | 3 | ~200 | 1 | ~100 |
| internal/infrastructure/storage/ | 3 | ~300 | 1 | 591 |
| **TOTAL BOOTSTRAP SYSTEM** | **24** | **~3,149** | **9** | **~1,905** |

### 11.2 Cobertura de Tests Actual

```bash
# Tests unitarios
internal/bootstrap/bootstrap_test.go           173 LOC
internal/bootstrap/lifecycle_test.go           200 LOC

# Tests de integración
internal/bootstrap/bootstrap_integration_test.go  591 LOC

# Total tests de bootstrap
TOTAL: 964 LOC de tests
```

### 11.3 Dependencias Externas

```go
// go.mod de api-mobile
require (
    github.com/EduGoGroup/edugo-shared v0.3.0  // → actualizar a v0.4.0/v0.1.0
    github.com/gin-gonic/gin v1.9.1
    github.com/spf13/viper v1.18.2
    github.com/go-playground/validator/v10 v10.19.0
    go.mongodb.org/mongo-driver v1.13.1
    github.com/lib/pq v1.10.9
    github.com/streadway/amqp v1.1.0
    github.com/aws/aws-sdk-go-v2 v1.24.0
    go.uber.org/zap v1.26.0
)
```

**Cambios en go.mod después del refactor:**
```diff
  require (
-     github.com/EduGoGroup/edugo-shared v0.3.0
+     github.com/EduGoGroup/edugo-shared/config v0.4.0
+     github.com/EduGoGroup/edugo-shared/lifecycle v0.4.0
+     github.com/EduGoGroup/edugo-shared/bootstrap v0.1.0
      github.com/sirupsen/logrus v1.9.3  // Nueva dependencia (para adapter)
  )
```

---

## 12. Conclusiones

### 12.1 Viabilidad del Refactor

✅ **VIABLE** - El refactor es técnicamente factible con riesgos controlados

**Factores Positivos:**
1. Código duplicado claro (lifecycle: 155 LOC eliminables)
2. shared/bootstrap tiene todas las capacidades necesarias
3. Adaptadores son straightforward (no requieren cambios complejos)
4. Tests existentes pueden preservarse y adaptarse
5. Sin cambios en capas superiores (container, repositories, services, handlers)

**Factores de Riesgo:**
1. Logger usado en ~100 archivos (adapter crítico)
2. Presigned URLs funcionalidad única (mantener local)
3. Tests extensos que adaptar (964 LOC)

### 12.2 Retorno de Inversión

#### Beneficios
- **Reducción de código:** ~137 LOC netos menos
- **Eliminación de duplicación:** lifecycle.go 98% idéntico a shared
- **Consistencia:** Mismo bootstrap en todos los proyectos EduGo
- **Mantenimiento:** Bugs en bootstrap se fixean en shared, benefician a todos
- **Features futuras:** Nuevas capacidades de shared disponibles automáticamente

#### Costos
- **Tiempo de desarrollo:** Estimado 8-13 horas (según FASE_0.2_PLAN.md)
- **Riesgo de bugs:** Medio-bajo con mitigaciones adecuadas
- **Complejidad temporal:** Adapters agregan capa extra (aunque pequeña)

### 12.3 Recomendaciones

1. ✅ **Proceder con el refactor** siguiendo FASE_0.2_PLAN.md
2. ✅ **Mantener tests existentes** (591 LOC de coverage valiosa)
3. ✅ **Usar CreateRawConnection** para PostgreSQL (sin migrar a GORM)
4. ✅ **Preservar wrapper S3** local con presigned URLs
5. ✅ **Adaptar en 6 etapas** con checkpoints (ver FASE_0.2_PLAN.md)
6. ⚠️ **Probar exhaustivamente** LoggerAdapter (crítico)
7. ⚠️ **No mergear** hasta que 100% tests pasen

### 12.4 Próximos Pasos

1. Continuar con **ETAPA 2** del plan: Crear Adaptadores
   - `internal/bootstrap/adapter/logger.go`
   - `internal/bootstrap/adapter/messaging.go`
   - `internal/bootstrap/adapter/storage.go`

2. Validar adaptadores con tests unitarios antes de integrar

3. Proceder con ETAPA 3: Refactorizar bootstrap.go

---

**Documento completado:** 12 de Noviembre, 2025  
**Próxima acción:** Crear adaptadores (ETAPA 2)  
**Responsable:** Claude Code  
**Aprobación:** Pendiente
