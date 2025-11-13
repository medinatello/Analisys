# Diseño: Módulo Testing en edugo-shared

**Versión:** 1.0  
**Fecha:** 12 de Noviembre, 2025  
**Autor:** Claude Code + Jhoan Medina

---

## 🎯 Visión General

Crear un módulo **`edugo-shared/testing`** que proporcione infrastructure de testcontainers reutilizable, flexible y eficiente para todos los proyectos del ecosistema EduGo.

---

## 📊 Análisis del Patrón Actual

### Implementación en api-mobile

**Archivo:** `test/integration/shared_containers.go` (193 LOC)

**Patrón Singleton:**
```go
var (
    sharedContainers *SharedContainers
    setupOnce        sync.Once
    setupError       error
)

func GetSharedContainers(t *testing.T) (*SharedContainers, error) {
    setupOnce.Do(func() {
        // Crear containers UNA SOLA VEZ
        // PostgreSQL + MongoDB + RabbitMQ
    })
    return sharedContainers, setupError
}
```

**Ventajas del Patrón Actual:**
- ✅ Containers se crean UNA vez por test suite
- ✅ Reutilización entre múltiples tests
- ✅ Performance: Setup ~30s inicial, luego instantáneo
- ✅ Cleanup centralizado

**Limitaciones:**
- ❌ Hardcodeado: Siempre crea TODOS los containers
- ❌ No configurable (versiones, credenciales)
- ❌ Duplicado en cada proyecto
- ❌ No permite containers opcionales

---

## 🏗️ Diseño Propuesto

### Arquitectura del Módulo

```
edugo-shared/testing/
├── containers/
│   ├── manager.go           # Manager principal con singleton
│   ├── postgres.go          # PostgreSQL container
│   ├── mongodb.go           # MongoDB container
│   ├── rabbitmq.go          # RabbitMQ container
│   ├── s3.go               # S3/MinIO container (futuro)
│   ├── options.go          # Configuración
│   └── helpers.go          # Utilidades (retry, cleanup)
├── fixtures/
│   ├── postgres_seeds.sql  # Seeds comunes
│   └── mongodb_seeds.json  # Seeds MongoDB
├── go.mod
└── README.md
```

### API Propuesta

#### 1. Manager con Builder Pattern

```go
package containers

import (
    "context"
    "testing"
)

// Manager gestiona containers de testing
type Manager struct {
    postgres *postgres.PostgresContainer
    mongodb  *mongodb.MongoDBContainer
    rabbitmq *rabbitmq.RabbitMQContainer
    s3       *s3.Container
    config   *Config
    mu       sync.Mutex
}

// Config permite configurar qué containers usar
type Config struct {
    // Containers a crear
    UsePostgreSQL bool
    UseMongoDB    bool
    UseRabbitMQ   bool
    UseS3         bool
    
    // Configuraciones opcionales
    PostgresConfig *PostgresConfig
    MongoConfig    *MongoConfig
    RabbitConfig   *RabbitConfig
    S3Config       *S3Config
}

// Builder para Config
type ConfigBuilder struct {
    config *Config
}

func NewConfig() *ConfigBuilder {
    return &ConfigBuilder{
        config: &Config{},
    }
}

func (b *ConfigBuilder) WithPostgreSQL(cfg *PostgresConfig) *ConfigBuilder {
    b.config.UsePostgreSQL = true
    b.config.PostgresConfig = cfg
    return b
}

func (b *ConfigBuilder) WithMongoDB(cfg *MongoConfig) *ConfigBuilder {
    b.config.UseMongoDB = true
    b.config.MongoConfig = cfg
    return b
}

func (b *ConfigBuilder) WithRabbitMQ(cfg *RabbitConfig) *ConfigBuilder {
    b.config.UseRabbitMQ = true
    b.config.RabbitConfig = cfg
    return b
}

func (b *ConfigBuilder) Build() *Config {
    return b.config
}

// Manager singleton
var (
    globalManager *Manager
    setupOnce     sync.Once
    setupError    error
)

// GetManager obtiene o crea el manager global
func GetManager(t *testing.T, config *Config) (*Manager, error) {
    setupOnce.Do(func() {
        ctx := context.Background()
        m := &Manager{config: config}
        
        // Crear solo los containers solicitados
        if config.UsePostgreSQL {
            pg, err := createPostgres(ctx, config.PostgresConfig)
            if err != nil {
                setupError = err
                return
            }
            m.postgres = pg
            t.Log("✅ PostgreSQL container listo")
        }
        
        if config.UseMongoDB {
            mongo, err := createMongoDB(ctx, config.MongoConfig)
            if err != nil {
                m.Cleanup(ctx)
                setupError = err
                return
            }
            m.mongodb = mongo
            t.Log("✅ MongoDB container listo")
        }
        
        // ... similar para RabbitMQ, S3
        
        globalManager = m
    })
    
    return globalManager, setupError
}

// Cleanup limpia los containers
func (m *Manager) Cleanup(ctx context.Context) error {
    var errors []error
    
    if m.postgres != nil {
        if err := m.postgres.Terminate(ctx); err != nil {
            errors = append(errors, err)
        }
    }
    // ... similar para otros
    
    if len(errors) > 0 {
        return fmt.Errorf("cleanup errors: %v", errors)
    }
    return nil
}
```

#### 2. Uso Simple

**api-mobile (necesita todo):**
```go
func TestMain(m *testing.M) {
    config := containers.NewConfig().
        WithPostgreSQL(nil).  // nil = defaults
        WithMongoDB(nil).
        WithRabbitMQ(nil).
        Build()
    
    manager, err := containers.GetManager(nil, config)
    if err != nil {
        log.Fatal(err)
    }
    defer manager.Cleanup(context.Background())
    
    os.Exit(m.Run())
}

func TestSomething(t *testing.T) {
    manager, _ := containers.GetManager(t, nil) // reutiliza
    
    db := manager.PostgreSQL().DB()
    // usar db...
}
```

**api-administracion (solo PostgreSQL):**
```go
func TestMain(m *testing.M) {
    config := containers.NewConfig().
        WithPostgreSQL(nil).
        Build()
    
    manager, _ := containers.GetManager(nil, config)
    defer manager.Cleanup(context.Background())
    
    os.Exit(m.Run())
}
```

**worker (PostgreSQL + MongoDB + RabbitMQ):**
```go
func TestMain(m *testing.M) {
    config := containers.NewConfig().
        WithPostgreSQL(nil).
        WithMongoDB(nil).
        WithRabbitMQ(nil).
        Build()
    
    manager, _ := containers.GetManager(nil, config)
    defer manager.Cleanup(context.Background())
    
    os.Exit(m.Run())
}
```

---

## 🔧 Configuraciones por Container

### PostgreSQL

```go
type PostgresConfig struct {
    Image    string  // default: "postgres:15-alpine"
    Database string  // default: "edugo_test"
    Username string  // default: "edugo_user"
    Password string  // default: "edugo_pass"
    Port     int     // default: 0 (random)
    
    // Scripts SQL para ejecutar al iniciar
    InitScripts []string
}
```

### MongoDB

```go
type MongoConfig struct {
    Image    string  // default: "mongo:7.0"
    Database string  // default: "edugo_test"
    Username string  // default: ""
    Password string  // default: ""
}
```

### RabbitMQ

```go
type RabbitConfig struct {
    Image    string  // default: "rabbitmq:3.12-alpine"
    Username string  // default: "edugo_user"
    Password string  // default: "edugo_pass"
}
```

---

## 🧹 Helpers de Limpieza

```go
// CleanDatabase limpia una base de datos PostgreSQL
func (m *Manager) CleanPostgreSQL(ctx context.Context, tables []string) error {
    db := m.PostgreSQL().DB()
    
    for _, table := range tables {
        _, err := db.ExecContext(ctx, fmt.Sprintf("TRUNCATE TABLE %s CASCADE", table))
        if err != nil {
            // Log warning pero continuar
        }
    }
    return nil
}

// CleanMongoDB limpia colecciones de MongoDB
func (m *Manager) CleanMongoDB(ctx context.Context, collections []string) error {
    db := m.MongoDB().Database()
    
    for _, coll := range collections {
        db.Collection(coll).Drop(ctx)
    }
    return nil
}
```

---

## 📦 Beneficios del Diseño

### Para Developers

✅ **Simplicidad:** Builder pattern intuitivo  
✅ **Flexibilidad:** Solo los containers necesarios  
✅ **Performance:** Singleton reutiliza containers  
✅ **Consistencia:** Mismo patrón en todos los proyectos  

### Para el Proyecto

✅ **Reducción de código:** ~400 LOC eliminadas (duplicación)  
✅ **Mantenibilidad:** Cambios en un solo lugar  
✅ **Testeable:** Cada container se puede testear independiente  
✅ **Extensible:** Fácil agregar nuevos containers (Redis, Kafka, etc.)  

---

## 🚀 Plan de Implementación

### Fase 1: Módulo en shared (2-3 días)
1. Crear estructura `shared/testing/containers/`
2. Implementar Manager con singleton
3. Implementar cada container (postgres, mongodb, rabbitmq, s3)
4. Crear tests del módulo
5. Releases v0.6.0

### Fase 2: Migración api-mobile (1 día)
1. Actualizar imports a shared/testing
2. Simplificar shared_containers.go
3. Ejecutar tests
4. PR y release

### Fase 3: Migración api-administracion (1 día)
1. Reemplazar setup actual
2. Usar solo PostgreSQL
3. Ejecutar tests
4. PR

### Fase 4: Implementar en worker (1 día)
1. Crear tests de integración
2. Usar PostgreSQL + MongoDB + RabbitMQ
3. PR

### Fase 5: dev-environment (2 días)
1. Scripts para devs frontend
2. docker-compose profiles
3. Seeds de datos
4. Documentación

**Total:** 7-8 días

---

## 🎯 Casos de Uso

### UC-1: Developer de api-mobile ejecuta tests
```bash
cd edugo-api-mobile
go test -tags=integration ./test/integration/
# Containers se crean automáticamente
# Tests se ejecutan
# Containers se destruyen al final
```

### UC-2: Developer de api-admin ejecuta tests
```bash
cd edugo-api-administracion  
go test -tags=integration ./test/integration/
# Solo PostgreSQL se crea
# Más rápido que crear todos
```

### UC-3: Frontend dev quiere ambiente completo
```bash
cd edugo-dev-environment
./scripts/setup.sh --profile full
# Levanta: PostgreSQL, MongoDB, RabbitMQ, S3
# Carga seeds de datos
# APIs disponibles en :8080, :8081
```

### UC-4: Frontend dev solo necesita APIs
```bash
cd edugo-dev-environment
./scripts/setup.sh --profile api-only
# Levanta: PostgreSQL (shared), APIs
# No levanta MongoDB, RabbitMQ (no necesarios)
```

---

## 🔍 Consideraciones Técnicas

### Performance

**Problema:** Levantar 4 containers tarda ~60-90s

**Solución:**
- Singleton pattern: Se crean UNA vez
- Cleanup entre tests: TRUNCATE (no DROP)
- Parallel start: containers en paralelo

**Resultado:** 
- Primera ejecución: ~60s
- Tests subsiguientes: <1s

### Cleanup Strategy

**Opción 1: Truncate (Recomendado)**
- Entre tests: TRUNCATE tables
- Al final: DROP containers
- Ventaja: Rápido, mantiene schema

**Opción 2: Drop/Recreate**
- Entre tests: DROP database, CREATE
- Ventaja: Estado 100% limpio
- Desventaja: Lento

**Opción 3: Transacciones (Ideal pero complejo)**
- Cada test en transacción, ROLLBACK al final
- Requiere cambios en código de aplicación

**Decisión:** Opción 1 (Truncate)

### Versionado de Imágenes

**Problema:** ¿Qué versiones usar?

**Decisión:**
- PostgreSQL: **15-alpine** (match con producción)
- MongoDB: **7.0** (match con producción)
- RabbitMQ: **3.12-alpine** (match con producción)
- S3: **MinIO latest** (solo para desarrollo)

Configurables via `*Config`

### Orden de Inicio

**Dependencias:**
1. PostgreSQL (independiente)
2. MongoDB (independiente)
3. RabbitMQ (independiente)
4. S3 (independiente)

**Inicio en Paralelo:** ✅ Posible, todos son independientes

---

## 📁 Estructura Detallada

### containers/manager.go (~150 LOC)
- Manager struct
- Singleton setup
- GetManager()
- Cleanup()
- Helper methods

### containers/postgres.go (~100 LOC)
- PostgresContainer wrapper
- createPostgres()
- ConnectionString()
- DB() *sql.DB
- ExecScript()
- Truncate()

### containers/mongodb.go (~80 LOC)
- MongoDBContainer wrapper
- createMongoDB()
- ConnectionString()
- Database() *mongo.Database
- DropCollections()

### containers/rabbitmq.go (~80 LOC)
- RabbitMQContainer wrapper
- createRabbitMQ()
- ConnectionString()
- Channel() *amqp.Channel

### containers/options.go (~120 LOC)
- Config struct
- ConfigBuilder
- PostgresConfig, MongoConfig, RabbitConfig
- Defaults

### containers/helpers.go (~70 LOC)
- ConnectWithRetry()
- WaitFor()
- ExecSQLFile()

**Total estimado:** ~600 LOC

---

## 🔄 Migración de Proyectos

### api-mobile

**Antes (193 LOC):**
```go
// test/integration/shared_containers.go
type SharedContainers struct {
    Postgres *postgres.PostgresContainer
    MongoDB  *mongodb.MongoDBContainer
    RabbitMQ *rabbitmq.RabbitMQContainer
}

func GetSharedContainers(t *testing.T) (*SharedContainers, error) {
    // 193 líneas de setup
}
```

**Después (~30 LOC):**
```go
import "github.com/EduGoGroup/edugo-shared/testing/containers"

func TestMain(m *testing.M) {
    config := containers.NewConfig().
        WithPostgreSQL(nil).
        WithMongoDB(nil).
        WithRabbitMQ(nil).
        Build()
    
    mgr, _ := containers.GetManager(nil, config)
    defer mgr.Cleanup(context.Background())
    
    os.Exit(m.Run())
}
```

**Reducción:** 163 LOC (84%)

### api-administracion

**Antes (~150 LOC):**
```go
// test/integration/setup.go + setup_test.go
func setupTestDB(t *testing.T) (*sql.DB, func()) {
    // Custom setup
}
```

**Después (~20 LOC):**
```go
import "github.com/EduGoGroup/edugo-shared/testing/containers"

func TestMain(m *testing.M) {
    config := containers.NewConfig().
        WithPostgreSQL(&containers.PostgresConfig{
            InitScripts: []string{"../../scripts/postgresql/01_academic_hierarchy.sql"},
        }).
        Build()
    
    mgr, _ := containers.GetManager(nil, config)
    defer mgr.Cleanup(context.Background())
    
    os.Exit(m.Run())
}
```

**Reducción:** 130 LOC (87%)

### worker

**Antes:** Sin tests de integración (0 LOC)

**Después (~30 LOC):**
```go
import "github.com/EduGoGroup/edugo-shared/testing/containers"

func TestMain(m *testing.M) {
    config := containers.NewConfig().
        WithPostgreSQL(nil).
        WithMongoDB(nil).
        WithRabbitMQ(nil).
        Build()
    
    mgr, _ := containers.GetManager(nil, config)
    defer mgr.Cleanup(context.Background())
    
    os.Exit(m.Run())
}
```

**Ganancia:** Tests de integración habilitados

---

## 🎯 dev-environment: Plan de Mejora

### Situación Actual

**Servicios en docker-compose.yml:**
- ✅ PostgreSQL 16-alpine
- ✅ MongoDB 7.0
- ✅ RabbitMQ 3.12-management
- ✅ api-mobile (imagen)
- ✅ api-administracion (imagen)
- ✅ worker (imagen)

**Scripts:**
- setup.sh
- cleanup.sh
- update-images.sh

### Propuesta de Mejora

#### 1. Docker Compose Profiles

**docker-compose.yml actualizado:**
```yaml
services:
  postgres:
    profiles: ["full", "db-only", "api-only"]
    # ...
  
  mongodb:
    profiles: ["full", "db-only"]
    # ...
  
  rabbitmq:
    profiles: ["full", "api-only"]
    # ...
  
  api-mobile:
    profiles: ["full", "api-only", "mobile-only"]
    depends_on: [postgres, rabbitmq]
    # ...
  
  api-administracion:
    profiles: ["full", "api-only", "admin-only"]
    depends_on: [postgres]
    # ...
  
  worker:
    profiles: ["full", "worker-only"]
    depends_on: [postgres, mongodb, rabbitmq]
    # ...
```

**Perfiles:**
- `full` - Todo el stack
- `db-only` - Solo bases de datos
- `api-only` - DBs + APIs (sin worker)
- `mobile-only` - PostgreSQL + RabbitMQ + api-mobile
- `admin-only` - PostgreSQL + api-administracion
- `worker-only` - Todo para worker

#### 2. Scripts Mejorados

**setup.sh actualizado:**
```bash
#!/bin/bash
# Usage: ./setup.sh [profile] [options]
# Profiles: full, db-only, api-only, mobile-only, admin-only, worker-only
# Options: --seed (cargar datos de prueba)

PROFILE=${1:-full}
SEED_DATA=false

if [[ "$2" == "--seed" ]]; then
    SEED_DATA=true
fi

echo "🚀 Levantando perfil: $PROFILE"
docker-compose --profile $PROFILE up -d

if [[ $SEED_DATA == true ]]; then
    echo "🌱 Cargando datos de prueba..."
    ./scripts/seed-data.sh
fi

echo "✅ Ambiente listo: $PROFILE"
```

**seed-data.sh (nuevo):**
```bash
#!/bin/bash
# Carga seeds en PostgreSQL y MongoDB

echo "🐘 Seeds PostgreSQL..."
docker exec edugo-postgres psql -U edugo -d edugo_dev -f /seeds/schools.sql
docker exec edugo-postgres psql -U edugo -d edugo_dev -f /seeds/users.sql
docker exec edugo-postgres psql -U edugo -d edugo_dev -f /seeds/materials.sql

echo "🍃 Seeds MongoDB..."
docker exec edugo-mongodb mongosh edugo_test --eval "load('/seeds/material_summaries.js')"

echo "✅ Seeds cargados"
```

#### 3. Seeds de Datos

**seeds/ (nuevo):**
```
seeds/
├── postgresql/
│   ├── 01_schools.sql          # 5 escuelas ejemplo
│   ├── 02_users.sql            # 50 usuarios (admins, teachers, students)
│   ├── 03_academic_units.sql   # Jerarquía de ejemplo
│   ├── 04_materials.sql        # 20 materiales
│   └── 05_subjects.sql         # 10 materias
├── mongodb/
│   └── material_summaries.js   # Resúmenes de ejemplo
└── README.md
```

---

## 📊 Comparación: Antes vs Después

### Testing (Developers Backend)

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Setup code** | 193 LOC (api-mobile) | 30 LOC (reutilizable) |
| **Duplicación** | 60% entre proyectos | 0% |
| **Flexibilidad** | Hardcoded | Configurable |
| **Mantenibilidad** | Alta (cambios en 3 lugares) | Baja (cambios en 1 lugar) |
| **Tiempo setup** | ~60s todos | ~20-60s según necesidad |

### Development (Developers Frontend)

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Perfiles** | Solo "full" | 6 perfiles |
| **Startup time** | ~90s siempre | ~30-90s según perfil |
| **Seeds** | Manual | Automático con --seed |
| **Documentación** | README básico | Guías por perfil |

---

## 🎓 Decisiones de Diseño

### 1. ¿Por qué Singleton?
- ✅ Performance: Containers tardan 60s en crear
- ✅ Costo: Docker usa recursos
- ✅ Limpieza: Truncate entre tests es rápido

### 2. ¿Por qué Builder Pattern?
- ✅ API clara y autodocumentada
- ✅ Defaults sensatos
- ✅ Opcional configurar cada container

### 3. ¿Por qué NO un container por test?
- ❌ Muy lento (60s × N tests)
- ❌ Alto uso de recursos
- ✅ Truncate es suficiente para aislamiento

### 4. ¿Incluir S3/MinIO?
- ✅ Sí, para api-mobile (uploads de materiales)
- ⏳ Futuro: Redis, Elasticsearch si es necesario

---

## 📝 Próximos Pasos

1. Crear PRD.md y USER_STORIES.md
2. Crear TASKS.md con plan detallado
3. Crear RULES.md
4. Implementar Fase 1
5. Migrar proyectos

---

**Diseño completado** ✅  
**Próximo:** Crear resto de documentos de la spec

