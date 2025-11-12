# FASE 0.1: Refactorización de Bootstrap para Shared

**Fecha Creación:** 12 de Noviembre, 2025  
**Tipo:** Fase Intermedia (descubierta durante ejecución)  
**Proyecto:** edugo-shared  
**Duración Estimada:** 1.5-2 días  
**Prioridad:** P0 - CRÍTICA (Bloquea Fase 0 y Fase 1)

---

## 🎯 CONTEXTO

Durante la ejecución de Fase 0 (Migración Bootstrap a Shared), se descubrió que el `bootstrap` de api-mobile tiene **dependencias fuertemente acopladas** que impiden una migración simple:

### 🔴 Problema Identificado

```
api-mobile/internal/bootstrap/
├── bootstrap.go          → Imports: config, database, s3, rabbitmq (específicos api-mobile)
├── factories.go          → Imports: config, database, rabbitmq, s3 (específicos api-mobile)
├── interfaces.go         → Imports: config, rabbitmq, s3 (específicos api-mobile)
├── config.go            → Imports: rabbitmq (específico api-mobile)
└── lifecycle.go         → Imports: logger (✅ shared - portable)
```

**No es posible:** "Copiar y renombrar imports" porque las estructuras son específicas de api-mobile.

**Necesario:** Refactorización completa para crear bootstrap genérico basado en interfaces puras.

---

## 🎯 OBJETIVO DE FASE 0.1

Crear componentes base reutilizables en `edugo-shared` que permitan:
1. ✅ Cada API (mobile, admin, worker) crear su propio bootstrap específico
2. ✅ Reutilizar lifecycle management, config base, factories genéricos
3. ✅ Testcontainers helpers 100% funcionales
4. ✅ Sin duplicación de código común

---

## 📋 PLAN DE TRABAJO

### **Etapa 1: Config Base (4 horas)**

**Objetivo:** Mover configuración base a shared, dejando campos específicos en cada API.

#### Archivos a Crear en `shared/config/`:

**1.1. `shared/config/base.go`** (~150 LOC)
```go
package config

// BaseConfig contiene configuración común a todos los servicios
type BaseConfig struct {
    Environment string
    ServiceName string
    Server      ServerConfig
    Database    DatabaseConfig
    MongoDB     MongoDBConfig
    Logger      LoggerConfig
}

type ServerConfig struct {
    Port         int
    ReadTimeout  time.Duration
    WriteTimeout time.Duration
    IdleTimeout  time.Duration
}

type DatabaseConfig struct {
    Host     string
    Port     int
    User     string
    Password string
    Database string
    SSLMode  string
}

type MongoDBConfig struct {
    URI      string
    Database string
}

type LoggerConfig struct {
    Level  string
    Format string
}
```

**1.2. `shared/config/loader.go`** (~100 LOC)
```go
package config

import (
    "fmt"
    "github.com/spf13/viper"
)

// Loader carga configuración desde archivos YAML y variables de entorno
type Loader struct {
    configPath string
    configName string
    configType string
}

// NewLoader crea un nuevo loader de configuración
func NewLoader(path, name, configType string) *Loader {
    return &Loader{
        configPath: path,
        configName: name,
        configType: configType,
    }
}

// Load carga la configuración y la desempaqueta en el struct destino
func (l *Loader) Load(cfg interface{}) error {
    viper.AddConfigPath(l.configPath)
    viper.SetConfigName(l.configName)
    viper.SetConfigType(l.configType)
    viper.AutomaticEnv()
    
    if err := viper.ReadInConfig(); err != nil {
        return fmt.Errorf("failed to read config: %w", err)
    }
    
    if err := viper.Unmarshal(cfg); err != nil {
        return fmt.Errorf("failed to unmarshal config: %w", err)
    }
    
    return nil
}
```

**1.3. `shared/config/validator.go`** (~80 LOC)
```go
package config

import (
    "fmt"
    "github.com/go-playground/validator/v10"
)

// Validator valida configuración usando tags
type Validator struct {
    validate *validator.Validate
}

// NewValidator crea un nuevo validador
func NewValidator() *Validator {
    return &Validator{
        validate: validator.New(),
    }
}

// Validate valida un struct de configuración
func (v *Validator) Validate(cfg interface{}) error {
    if err := v.validate.Struct(cfg); err != nil {
        return fmt.Errorf("config validation failed: %w", err)
    }
    return nil
}
```

**Entregable Etapa 1:** Config base en shared compila y tiene tests ✅

---

### **Etapa 2: Lifecycle Manager (2 horas)**

**Objetivo:** Mover gestión de ciclo de vida a shared (ya es genérico).

#### Archivos a Crear en `shared/lifecycle/`:

**2.1. `shared/lifecycle/manager.go`** (~150 LOC)
```go
package lifecycle

import (
    "context"
    "fmt"
    "sync"
    "time"
    "github.com/EduGoGroup/edugo-shared/logger"
    "go.uber.org/zap"
)

// Resource representa un recurso con startup y cleanup
type Resource struct {
    Name    string
    Startup func(ctx context.Context) error
    Cleanup func() error
}

// Manager gestiona el ciclo de vida de recursos
type Manager struct {
    resources []Resource
    mu        sync.Mutex
    logger    logger.Logger
}

// NewManager crea un nuevo lifecycle manager
func NewManager(log logger.Logger) *Manager {
    return &Manager{
        resources: make([]Resource, 0),
        logger:    log,
    }
}

// Register registra un recurso para gestión de ciclo de vida
func (m *Manager) Register(name string, startup func(ctx context.Context) error, cleanup func() error) {
    m.mu.Lock()
    defer m.mu.Unlock()
    
    m.resources = append(m.resources, Resource{
        Name:    name,
        Startup: startup,
        Cleanup: cleanup,
    })
    
    m.logger.Debug("resource registered", zap.String("resource", name))
}

// Cleanup ejecuta cleanup de todos los recursos en orden inverso
func (m *Manager) Cleanup() error {
    m.mu.Lock()
    defer m.mu.Unlock()
    
    m.logger.Info("starting cleanup of resources")
    
    var errors []error
    
    // Cleanup en orden inverso (LIFO)
    for i := len(m.resources) - 1; i >= 0; i-- {
        resource := m.resources[i]
        m.logger.Debug("cleaning up resource", zap.String("resource", resource.Name))
        
        if err := resource.Cleanup(); err != nil {
            m.logger.Error("cleanup failed", 
                zap.String("resource", resource.Name),
                zap.Error(err))
            errors = append(errors, fmt.Errorf("%s: %w", resource.Name, err))
        }
    }
    
    if len(errors) > 0 {
        return fmt.Errorf("cleanup errors: %v", errors)
    }
    
    m.logger.Info("cleanup completed successfully")
    return nil
}
```

**2.2. `shared/lifecycle/manager_test.go`** (~100 LOC)
- Tests unitarios del lifecycle manager

**Entregable Etapa 2:** Lifecycle manager en shared funcional ✅

---

### **Etapa 3: Factories Genéricos (3 horas)**

**Objetivo:** Crear interfaces y factories base para recursos de infraestructura.

#### Archivos a Crear en `shared/bootstrap/`:

**3.1. `shared/bootstrap/interfaces.go`** (~200 LOC)
```go
package bootstrap

import (
    "context"
    "database/sql"
    "time"
    "github.com/EduGoGroup/edugo-shared/logger"
    "go.mongodb.org/mongo-driver/mongo"
)

// LoggerFactory crea instancias de logger
type LoggerFactory interface {
    Create(level, format string) (logger.Logger, error)
}

// PostgreSQLFactory crea conexiones a PostgreSQL
type PostgreSQLFactory interface {
    Create(ctx context.Context, cfg PostgreSQLConfig, log logger.Logger) (*sql.DB, error)
}

type PostgreSQLConfig struct {
    Host     string
    Port     int
    User     string
    Password string
    Database string
    SSLMode  string
}

// MongoDBFactory crea conexiones a MongoDB
type MongoDBFactory interface {
    Create(ctx context.Context, cfg MongoDBConfig, log logger.Logger) (*mongo.Database, error)
}

type MongoDBConfig struct {
    URI      string
    Database string
}

// RabbitMQFactory crea conexiones a RabbitMQ
type RabbitMQFactory interface {
    Create(url, exchange string, log logger.Logger) (MessagePublisher, error)
}

// MessagePublisher interfaz genérica para publicadores de mensajes
type MessagePublisher interface {
    Publish(ctx context.Context, routingKey string, message interface{}) error
    Close() error
}

// S3Factory crea clientes de S3
type S3Factory interface {
    Create(ctx context.Context, cfg S3Config, log logger.Logger) (StorageClient, error)
}

type S3Config struct {
    Region          string
    Bucket          string
    AccessKeyID     string
    SecretAccessKey string
    Endpoint        string
}

// StorageClient interfaz genérica para almacenamiento de objetos
type StorageClient interface {
    GeneratePresignedUploadURL(ctx context.Context, key, contentType string, expires time.Duration) (string, error)
    GeneratePresignedDownloadURL(ctx context.Context, key string, expires time.Duration) (string, error)
    Close() error
}
```

**3.2. `shared/bootstrap/resources.go`** (~50 LOC)
```go
package bootstrap

import (
    "database/sql"
    "github.com/EduGoGroup/edugo-shared/logger"
    "go.mongodb.org/mongo-driver/mongo"
)

// Resources encapsula todos los recursos de infraestructura inicializados
type Resources struct {
    Logger            logger.Logger
    PostgreSQL        *sql.DB
    MongoDB           *mongo.Database
    RabbitMQ          MessagePublisher
    S3                StorageClient
    JWTSecret         string
    OptionalResources map[string]bool
}
```

**3.3. `shared/bootstrap/options.go`** (~80 LOC)
```go
package bootstrap

// BootstrapOptions configuración del bootstrapper
type BootstrapOptions struct {
    OptionalResources map[string]bool
    MockFactories     MockFactories
}

// MockFactories permite inyectar mocks para testing
type MockFactories struct {
    PostgreSQL PostgreSQLFactory
    MongoDB    MongoDBFactory
    RabbitMQ   RabbitMQFactory
    S3         S3Factory
}

// BootstrapOption función de configuración
type BootstrapOption func(*BootstrapOptions)

// WithOptionalResource marca un recurso como opcional
func WithOptionalResource(name string, optional bool) BootstrapOption {
    return func(opts *BootstrapOptions) {
        if opts.OptionalResources == nil {
            opts.OptionalResources = make(map[string]bool)
        }
        opts.OptionalResources[name] = optional
    }
}

// WithMockFactories inyecta factories mock para testing
func WithMockFactories(mocks MockFactories) BootstrapOption {
    return func(opts *BootstrapOptions) {
        opts.MockFactories = mocks
    }
}
```

**Entregable Etapa 3:** Interfaces y opciones base en shared ✅

---

### **Etapa 4: Testcontainers Helpers (3 horas)**

**Objetivo:** Crear helpers completos para testcontainers.

#### Archivos a Crear en `shared/testing/containers/`:

**4.1. `shared/testing/containers/postgres.go`** (~150 LOC)
```go
package containers

import (
    "context"
    "fmt"
    "time"
    
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/wait"
)

// PostgresContainer wrapper para contenedor PostgreSQL
type PostgresContainer struct {
    container testcontainers.Container
    host      string
    port      int
    database  string
    user      string
    password  string
}

// NewPostgresContainer crea y arranca un contenedor PostgreSQL para tests
func NewPostgresContainer(ctx context.Context) (*PostgresContainer, error) {
    req := testcontainers.ContainerRequest{
        Image:        "postgres:15-alpine",
        ExposedPorts: []string{"5432/tcp"},
        Env: map[string]string{
            "POSTGRES_DB":       "testdb",
            "POSTGRES_USER":     "testuser",
            "POSTGRES_PASSWORD": "testpass",
        },
        WaitingFor: wait.ForLog("database system is ready to accept connections").
            WithOccurrence(2).
            WithStartupTimeout(60 * time.Second),
    }
    
    container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
        ContainerRequest: req,
        Started:          true,
    })
    if err != nil {
        return nil, fmt.Errorf("failed to start postgres container: %w", err)
    }
    
    host, err := container.Host(ctx)
    if err != nil {
        return nil, fmt.Errorf("failed to get container host: %w", err)
    }
    
    mappedPort, err := container.MappedPort(ctx, "5432")
    if err != nil {
        return nil, fmt.Errorf("failed to get mapped port: %w", err)
    }
    
    return &PostgresContainer{
        container: container,
        host:      host,
        port:      mappedPort.Int(),
        database:  "testdb",
        user:      "testuser",
        password:  "testpass",
    }, nil
}

// ConnectionString retorna el DSN para conectar a PostgreSQL
func (c *PostgresContainer) ConnectionString() string {
    return fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
        c.host, c.port, c.user, c.password, c.database)
}

// Host retorna el host del contenedor
func (c *PostgresContainer) Host() string {
    return c.host
}

// Port retorna el puerto mapeado
func (c *PostgresContainer) Port() int {
    return c.port
}

// Cleanup detiene y elimina el contenedor
func (c *PostgresContainer) Cleanup(ctx context.Context) error {
    if c.container != nil {
        return c.container.Terminate(ctx)
    }
    return nil
}
```

**4.2. `shared/testing/containers/mongodb.go`** (~120 LOC)
```go
package containers

import (
    "context"
    "fmt"
    "time"
    
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/wait"
)

// MongoDBContainer wrapper para contenedor MongoDB
type MongoDBContainer struct {
    container testcontainers.Container
    host      string
    port      int
    database  string
}

// NewMongoDBContainer crea y arranca un contenedor MongoDB para tests
func NewMongoDBContainer(ctx context.Context) (*MongoDBContainer, error) {
    req := testcontainers.ContainerRequest{
        Image:        "mongo:7.0",
        ExposedPorts: []string{"27017/tcp"},
        WaitingFor: wait.ForLog("Waiting for connections").
            WithStartupTimeout(60 * time.Second),
    }
    
    container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
        ContainerRequest: req,
        Started:          true,
    })
    if err != nil {
        return nil, fmt.Errorf("failed to start mongodb container: %w", err)
    }
    
    host, err := container.Host(ctx)
    if err != nil {
        return nil, fmt.Errorf("failed to get container host: %w", err)
    }
    
    mappedPort, err := container.MappedPort(ctx, "27017")
    if err != nil {
        return nil, fmt.Errorf("failed to get mapped port: %w", err)
    }
    
    return &MongoDBContainer{
        container: container,
        host:      host,
        port:      mappedPort.Int(),
        database:  "testdb",
    }, nil
}

// ConnectionString retorna la URI para conectar a MongoDB
func (c *MongoDBContainer) ConnectionString() string {
    return fmt.Sprintf("mongodb://%s:%d/%s", c.host, c.port, c.database)
}

// Cleanup detiene y elimina el contenedor
func (c *MongoDBContainer) Cleanup(ctx context.Context) error {
    if c.container != nil {
        return c.container.Terminate(ctx)
    }
    return nil
}
```

**4.3. `shared/testing/containers/rabbitmq.go`** (~100 LOC)
```go
package containers

import (
    "context"
    "fmt"
    "time"
    
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/wait"
)

// RabbitMQContainer wrapper para contenedor RabbitMQ
type RabbitMQContainer struct {
    container testcontainers.Container
    host      string
    port      int
    user      string
    password  string
}

// NewRabbitMQContainer crea y arranca un contenedor RabbitMQ para tests
func NewRabbitMQContainer(ctx context.Context) (*RabbitMQContainer, error) {
    req := testcontainers.ContainerRequest{
        Image:        "rabbitmq:3.12-management-alpine",
        ExposedPorts: []string{"5672/tcp", "15672/tcp"},
        Env: map[string]string{
            "RABBITMQ_DEFAULT_USER": "guest",
            "RABBITMQ_DEFAULT_PASS": "guest",
        },
        WaitingFor: wait.ForLog("Server startup complete").
            WithStartupTimeout(60 * time.Second),
    }
    
    container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
        ContainerRequest: req,
        Started:          true,
    })
    if err != nil {
        return nil, fmt.Errorf("failed to start rabbitmq container: %w", err)
    }
    
    host, err := container.Host(ctx)
    if err != nil {
        return nil, fmt.Errorf("failed to get container host: %w", err)
    }
    
    mappedPort, err := container.MappedPort(ctx, "5672")
    if err != nil {
        return nil, fmt.Errorf("failed to get mapped port: %w", err)
    }
    
    return &RabbitMQContainer{
        container: container,
        host:      host,
        port:      mappedPort.Int(),
        user:      "guest",
        password:  "guest",
    }, nil
}

// ConnectionString retorna la URL AMQP para conectar
func (c *RabbitMQContainer) ConnectionString() string {
    return fmt.Sprintf("amqp://%s:%s@%s:%d/", c.user, c.password, c.host, c.port)
}

// Cleanup detiene y elimina el contenedor
func (c *RabbitMQContainer) Cleanup(ctx context.Context) error {
    if c.container != nil {
        return c.container.Terminate(ctx)
    }
    return nil
}
```

**4.4. Tests para cada helper** (~200 LOC total)

**Entregable Etapa 4:** Testcontainers helpers funcionales ✅

---

### **Etapa 5: Implementaciones Noop (1 hora)**

**Objetivo:** Crear implementaciones noop para recursos opcionales.

**5.1. `shared/bootstrap/noop/publisher.go`** (~50 LOC)
```go
package noop

import (
    "context"
    "github.com/EduGoGroup/edugo-shared/logger"
    "go.uber.org/zap"
)

// Publisher implementación noop de MessagePublisher
type Publisher struct {
    logger logger.Logger
}

// NewPublisher crea un publisher noop
func NewPublisher(log logger.Logger) *Publisher {
    return &Publisher{logger: log}
}

// Publish no hace nada, solo loguea
func (p *Publisher) Publish(ctx context.Context, routingKey string, message interface{}) error {
    p.logger.Debug("noop: message not published (rabbitmq disabled)",
        zap.String("routing_key", routingKey))
    return nil
}

// Close no hace nada
func (p *Publisher) Close() error {
    return nil
}
```

**5.2. `shared/bootstrap/noop/storage.go`** (~60 LOC)
```go
package noop

import (
    "context"
    "time"
    "github.com/EduGoGroup/edugo-shared/logger"
    "go.uber.org/zap"
)

// Storage implementación noop de StorageClient
type Storage struct {
    logger logger.Logger
}

// NewStorage crea un storage noop
func NewStorage(log logger.Logger) *Storage {
    return &Storage{logger: log}
}

// GeneratePresignedUploadURL retorna una URL fake
func (s *Storage) GeneratePresignedUploadURL(ctx context.Context, key, contentType string, expires time.Duration) (string, error) {
    s.logger.Debug("noop: presigned upload URL not generated (s3 disabled)",
        zap.String("key", key))
    return "https://noop-storage.example.com/upload", nil
}

// GeneratePresignedDownloadURL retorna una URL fake
func (s *Storage) GeneratePresignedDownloadURL(ctx context.Context, key string, expires time.Duration) (string, error) {
    s.logger.Debug("noop: presigned download URL not generated (s3 disabled)",
        zap.String("key", key))
    return "https://noop-storage.example.com/download", nil
}

// Close no hace nada
func (s *Storage) Close() error {
    return nil
}
```

**Entregable Etapa 5:** Implementaciones noop listas ✅

---

### **Etapa 6: Actualizar go.mod y Compilar (1 hora)**

**6.1. Actualizar `shared/go.mod`**
```bash
cd edugo-shared
go get github.com/spf13/viper@latest
go get github.com/go-playground/validator/v10@latest
go get github.com/testcontainers/testcontainers-go@latest
go mod tidy
```

**6.2. Compilar todo**
```bash
go build ./...
```

**6.3. Ejecutar tests**
```bash
go test ./... -v
```

**Entregable Etapa 6:** Shared compila sin errores y tests pasan ✅

---

## 📊 RESUMEN DE ARCHIVOS CREADOS

| Paquete | Archivos | LOC Estimado |
|---------|----------|--------------|
| `shared/config/` | 3 archivos + tests | ~400 |
| `shared/lifecycle/` | 1 archivo + tests | ~300 |
| `shared/bootstrap/` | 3 archivos | ~350 |
| `shared/bootstrap/noop/` | 2 archivos | ~110 |
| `shared/testing/containers/` | 3 archivos + tests | ~700 |
| **TOTAL** | **12 archivos principales** | **~1,860 LOC** |

---

## ✅ CRITERIOS DE ÉXITO

- [ ] Todos los archivos compilan sin errores
- [ ] Todos los tests pasan (coverage > 70%)
- [ ] go.mod actualizado con dependencias correctas
- [ ] Documentación inline completa (godoc)
- [ ] Código linted sin warnings

---

## 🔄 SIGUIENTE PASO (Fase 0 Original)

Una vez completada Fase 0.1, continuar con:

**Fase 0.2: Migrar api-mobile para usar shared** (Día 3 original)
- Actualizar api-mobile/internal/bootstrap para usar shared/
- Crear factories concretos en api-mobile
- Ejecutar tests de api-mobile

---

## 📝 NOTAS IMPORTANTES

1. **Esta fase es crítica:** Sin ella, no podemos avanzar a Fase 1
2. **Scope creep controlado:** Solo movemos lo genérico, no toda la lógica de negocio
3. **Tests son obligatorios:** Cada paquete debe tener >70% coverage
4. **Compilación incremental:** Validar que compila después de cada etapa

---

**Próxima acción:** Ejecutar Fase 0.1 - Etapa 1 (Config Base)
