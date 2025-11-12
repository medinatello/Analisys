# FASE 0.3: Plan de Migración Worker a Shared Bootstrap

**Fecha Creación:** 12 de Noviembre, 2025  
**Estado:** 🟢 Listo para Implementación  
**Precedentes:** FASE 0.1 ✅, FASE 0.2 ✅  
**Proyecto:** edugo-worker

---

## 🎯 Objetivo

Migrar edugo-worker para usar shared/bootstrap, eliminando inicialización manual y centralizando configuración.

**Diferencia clave con FASE 0.2:**
- Worker NO tiene bootstrap interno estructurado
- Inicialización está en cmd/main.go (~191 LOC)
- Arquitectura más simple: Consumer + Processors
- No requiere adapters complejos

---

## 📊 Análisis Actual

### Estructura de edugo-worker

```
edugo-worker/
├── cmd/main.go                    (191 LOC) - Inicialización manual
├── internal/
│   ├── config/                    - Config custom con Viper
│   ├── container/                 - DI container simple
│   ├── application/processor/     - Event processors
│   ├── domain/valueobject/        - VOs
│   └── infrastructure/
│       └── messaging/consumer/    - RabbitMQ consumer
├── go.mod                         - Dependencias viejas de shared
└── Total: ~1,029 LOC
```

### Dependencias Actuales de shared

❌ **Versiones viejas (sin releases):**
- `edugo-shared/common` v0.0.0-20251031204120
- `edugo-shared/database/postgres` v0.0.0-20251031175907
- `edugo-shared/logger` v0.0.0-20251031204214

✅ **Necesitamos actualizar a:**
- `edugo-shared/config` v0.4.0
- `edugo-shared/lifecycle` v0.4.0
- `edugo-shared/bootstrap` v0.1.0
- `edugo-shared/logger` v0.3.3 (latest)

### Recursos que Worker Necesita

| Recurso | Actual | Después |
|---------|--------|---------|
| Logger | ✅ shared/logger (viejo) | shared/bootstrap → logger |
| PostgreSQL | ✅ shared/database/postgres | shared/bootstrap → *sql.DB o *gorm.DB |
| MongoDB | ❌ Conexión manual en main.go | shared/bootstrap → *mongo.Client |
| RabbitMQ | ❌ streadway/amqp manual | shared/bootstrap → *amqp.Channel |
| Config | ✅ internal/config custom | ¿Migrar a shared/config? |

---

## ⚡ Estrategia: Refactor Directo (No Adapters)

**Diferencia con api-mobile:**

api-mobile tenía bootstrap interno complejo → requería adapters para compatibilidad.

Worker tiene inicialización simple en main.go → podemos usar shared/bootstrap directamente.

```
┌─────────────────────────────────────┐
│        cmd/main.go (simple)         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   shared/bootstrap.Bootstrap()      │
│   - Logger, PostgreSQL, MongoDB,    │
│   - RabbitMQ, Lifecycle             │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  internal/container (DI)            │
│  internal/application/processor     │
└─────────────────────────────────────┘
```

**Ventajas:**
- ✅ Más simple que api-mobile (sin adapters)
- ✅ Reduce main.go de 191 a ~50 LOC
- ✅ Elimina duplicación de config
- ✅ Fácil rollback

---

## 📋 Plan Detallado (4 Etapas)

### ETAPA 1: Análisis y Preparación (30 min)

#### T1.1: Análisis de main.go
- [ ] Leer `cmd/main.go` completo (191 LOC)
- [ ] Identificar lógica de inicialización de recursos:
  - Logger
  - PostgreSQL (shared/database/postgres)
  - MongoDB (conexión manual)
  - RabbitMQ (conexión manual con streadway/amqp)
- [ ] Documentar qué se puede eliminar vs qué se debe mantener
- [ ] **Entregable:** `FASE_0.3_ANALISIS.md`

#### T1.2: Revisión de internal/config
- [ ] Leer `internal/config/config.go` y `loader.go`
- [ ] Verificar compatibilidad con shared/config.BaseConfig
- [ ] Decisión: ¿Migrar a BaseConfig o mantener custom?
- [ ] **Entregable:** Decisión documentada

**Checkpoint:** Análisis completo, estrategia clara

---

### ETAPA 2: Actualizar Dependencias (30 min)

#### T2.1: Crear Rama Nueva
```bash
cd edugo-worker
git checkout dev
git pull origin dev
git checkout -b feature/worker-use-shared-bootstrap
```

#### T2.2: Actualizar go.mod
```bash
# Remover versiones viejas
go get github.com/EduGoGroup/edugo-shared/config@v0.4.0
go get github.com/EduGoGroup/edugo-shared/lifecycle@v0.4.0
go get github.com/EduGoGroup/edugo-shared/bootstrap@v0.1.0
go get github.com/EduGoGroup/edugo-shared/logger@v0.3.3

# Actualizar RabbitMQ a rabbitmq/amqp091-go (recomendado)
go get github.com/rabbitmq/amqp091-go@latest

# Limpiar
go mod tidy
```

#### T2.3: Verificar Compilación
```bash
go build ./...
```

**Checkpoint:** go.mod actualizado, compilación sin errores grandes

---

### ETAPA 3: Refactorizar main.go (1-2 horas)

#### T3.1: Crear Configuración para Bootstrap

**Archivo:** `cmd/main.go` (refactorizado)

**Antes** (~191 LOC con inicialización manual):
```go
func main() {
    // Leer env vars manualmente
    rabbitmqHost := getEnv("RABBITMQ_HOST", "localhost")
    // ... 50 líneas de setup manual
    
    // Conectar a RabbitMQ manualmente
    conn, err := amqp.Dial(rabbitmqURL)
    // ... 30 líneas de setup channel
    
    // Conectar a MongoDB manualmente
    mongoClient, err := mongo.Connect(...)
    // ... 20 líneas de config
    
    // Inicializar consumer
    consumer := consumer.New(...)
    // ... resto del código
}
```

**Después** (~50-70 LOC con shared/bootstrap):
```go
func main() {
    ctx := context.Background()
    
    // 1. Cargar configuración
    cfg, err := config.Load()
    if err != nil {
        log.Fatal("failed to load config:", err)
    }
    
    // 2. Inicializar infraestructura con shared/bootstrap
    resources, cleanup, err := bootstrap.InitializeWorkerInfrastructure(ctx, cfg)
    if err != nil {
        log.Fatal("failed to initialize infrastructure:", err)
    }
    defer cleanup()
    
    // 3. Crear container
    container := container.NewWorkerContainer(resources)
    
    // 4. Inicializar y ejecutar consumer
    consumer := eventconsumer.New(
        container.RabbitMQChannel,
        container.Processors,
        resources.Logger,
    )
    
    if err := consumer.Start(ctx); err != nil {
        resources.Logger.Fatal("consumer failed", "error", err)
    }
}
```

#### T3.2: Crear Wrapper de Bootstrap para Worker

**Archivo:** `internal/bootstrap/worker.go` (nuevo, ~100 LOC)

```go
package bootstrap

import (
    "context"
    sharedBootstrap "github.com/EduGoGroup/edugo-shared/bootstrap"
    "github.com/EduGoGroup/edugo-shared/lifecycle"
    "github.com/EduGoGroup/edugo-worker/internal/config"
)

// Resources contiene todos los recursos inicializados para el worker
type Resources struct {
    Logger            logger.Logger
    PostgreSQL        *sql.DB
    MongoDB           *mongo.Database
    RabbitMQChannel   *amqp.Channel
    LifecycleManager  *lifecycle.Manager
}

// InitializeWorkerInfrastructure inicializa todos los recursos usando shared/bootstrap
func InitializeWorkerInfrastructure(
    ctx context.Context,
    cfg *config.Config,
) (*Resources, func() error, error) {
    // 1. Crear configs para shared/bootstrap
    postgresConfig := sharedBootstrap.PostgreSQLConfig{
        Host:     cfg.Database.Postgres.Host,
        Port:     cfg.Database.Postgres.Port,
        User:     cfg.Database.Postgres.User,
        Password: cfg.Database.Postgres.Password,
        Database: cfg.Database.Postgres.Database,
        SSLMode:  cfg.Database.Postgres.SSLMode,
    }
    
    mongoConfig := sharedBootstrap.MongoDBConfig{
        URI:      cfg.Database.MongoDB.URI,
        Database: cfg.Database.MongoDB.Database,
    }
    
    rabbitMQConfig := sharedBootstrap.RabbitMQConfig{
        URL: cfg.Messaging.RabbitMQ.URL,
    }
    
    // 2. Llamar shared/bootstrap
    sharedResources, err := sharedBootstrap.Bootstrap(
        ctx,
        postgresConfig,
        mongoConfig,
        rabbitMQConfig,
        sharedBootstrap.WithRequiredResources("logger", "postgresql", "mongodb", "rabbitmq"),
    )
    if err != nil {
        return nil, nil, err
    }
    
    // 3. Construir Resources de worker
    // (Si worker usa tipos diferentes, agregar adapters simples aquí)
    resources := &Resources{
        Logger:           sharedResources.Logger,
        PostgreSQL:       sharedResources.PostgreSQL,
        MongoDB:          sharedResources.MongoDB.Database(cfg.Database.MongoDB.Database),
        RabbitMQChannel:  sharedResources.RabbitMQChannel,
        LifecycleManager: sharedResources.Lifecycle,
    }
    
    // 4. Cleanup function
    cleanup := func() error {
        return resources.LifecycleManager.Cleanup()
    }
    
    return resources, cleanup, nil
}
```

#### T3.3: Actualizar internal/container

**Archivo:** `internal/container/container.go`

Ajustar para recibir `bootstrap.Resources` en lugar de recursos individuales.

**Checkpoint:** main.go refactorizado, compila sin errores

---

### ETAPA 4: Testing y Validación (30 min)

#### T4.1: Tests Unitarios
```bash
go test ./... -short -v
```

#### T4.2: Prueba Local
```bash
# Levantar dependencias con Docker
cd ../edugo-dev-environment
docker-compose up -d postgres mongodb rabbitmq

# Ejecutar worker
cd ../edugo-worker
go run cmd/main.go
```

**Validaciones:**
- ✅ Worker conecta a RabbitMQ
- ✅ Worker consume eventos
- ✅ Logger funciona
- ✅ No hay errores de inicialización

#### T4.3: Commit y Push
```bash
git add .
git commit -m "refactor: migrar worker a shared/bootstrap

- Reducir main.go de 191 a ~70 LOC
- Usar shared/bootstrap para inicialización
- Actualizar dependencias a releases v0.4.0/v0.1.0
- Eliminar configuración manual de recursos"

git push origin feature/worker-use-shared-bootstrap
```

#### T4.4: Crear PR
- Crear PR-0.3: `feature/worker-use-shared-bootstrap` → `worker/dev`
- Esperar CI/CD (máx 5 min)
- Resolver comentarios de Copilot si aplica
- Merge

**Checkpoint:** Worker migrado exitosamente ✅

---

## ⏱️ Estimación

| Etapa | Estimación | Complejidad |
|-------|------------|-------------|
| 1. Análisis | 30 min | 🟢 Baja |
| 2. Dependencias | 30 min | 🟢 Baja |
| 3. Refactor main.go | 1-2h | 🟡 Media |
| 4. Testing | 30 min | 🟢 Baja |
| **TOTAL** | **2.5-3.5h** | 🟢 **Baja** |

**Razón de baja complejidad:**
- Worker no tiene bootstrap interno
- Arquitectura simple (consumer pattern)
- main.go pequeño (191 LOC)
- Sin necesidad de adapters complejos

---

## 📊 Métricas de Éxito

### Código
- ✅ main.go reducido: 191 → ~70 LOC (-63%)
- ✅ Eliminación de inicialización manual
- ✅ Dependencias actualizadas a releases
- ✅ Sin breaking changes en processors

### Tests
- ✅ Tests existentes siguen pasando
- ✅ Worker funciona localmente
- ✅ Consumer conecta y procesa eventos

### Funcionalidad
- ✅ Worker levanta sin errores
- ✅ Conecta a RabbitMQ
- ✅ Procesa eventos correctamente
- ✅ Logging estructurado funciona

---

## 🎯 Decisiones Clave

### Decisión 1: No usar Adapters
- ✅ **APROBADO:** Usar tipos de shared directamente
- **Razón:** Worker no tiene código legacy que preservar
- **Acción:** Refactor directo de main.go

### Decisión 2: Actualizar internal/config
- ⏳ **PENDIENTE:** Evaluar en Etapa 1
- **Opciones:**
  - A) Mantener config custom (más simple)
  - B) Migrar a shared/config.BaseConfig (más consistente)

### Decisión 3: Container Simple
- ✅ **APROBADO:** Mantener container actual, solo ajustar firma
- **Razón:** Container de worker es simple (~30 LOC)

---

## 🚀 Próxima Acción

**Iniciar ETAPA 1:** Análisis de main.go y config

**Tiempo estimado:** 2.5-3.5 horas total  
**Complejidad:** 🟢 Baja (más simple que api-mobile)

---

**Plan creado:** 12 de Noviembre, 2025  
**Autor:** Claude Code  
**Estado:** 🟢 Listo para implementación
