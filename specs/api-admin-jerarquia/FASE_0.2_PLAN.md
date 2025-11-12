# FASE 0.2: Plan de Migración API-Mobile a Shared Bootstrap

**Fecha Creación:** 13 de Noviembre, 2025  
**Estado:** 🟡 Pendiente de Aprobación  
**Precedente:** FASE 0.1 ✅ Completada  
**Documento Base:** [FASE_0.2_ANALISIS.md](./FASE_0.2_ANALISIS.md)

---

## 🎯 Objetivo

Migrar api-mobile desde su bootstrap interno (1,927 LOC) hacia shared/bootstrap v0.1.0, **manteniendo compatibilidad total** con código existente mediante capa de adaptación.

---

## ⚡ Estrategia: Adaptación por Capas

```
┌─────────────────────────────────────────────┐
│           main.go (Orchestration)           │
└─────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│  internal/bootstrap (Adapter Layer)         │
│  - Wrappers específicos de api-mobile      │
│  - Presigned URLs (S3)                      │
│  - sql.DB adapter                           │
│  - logger.Logger adapter                    │
└─────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│     shared/bootstrap v0.1.0 (Base)          │
│  - Factories genéricos                      │
│  - Lifecycle manager                        │
│  - Bootstrap() core                         │
└─────────────────────────────────────────────┘
```

**Ventajas:**
- ✅ Reutiliza shared/bootstrap
- ✅ Mantiene tipos actuales (sql.DB, logger.Logger)
- ✅ Preserva tests de integración
- ✅ Permite rollback fácil

---

## 📋 Plan Detallado (6 Etapas)

### ETAPA 1: Análisis de Dependencias (1-2 horas)

**Objetivo:** Mapear dependencias antes de tocar código.

#### T1.1: Análisis de internal/config
- [ ] Leer `internal/config/config.go` completo
- [ ] Verificar si usa shared/config.BaseConfig
- [ ] Listar campos custom no presentes en BaseConfig
- [ ] Decidir: ¿Migrar a BaseConfig o mantener custom?
- [ ] **Entregable:** `config_analysis.txt` con hallazgos

#### T1.2: Mapeo de Uso de Resources
- [ ] Buscar todos los usos de `bootstrap.Resources` en el código:
  ```bash
  grep -r "bootstrap.Resources" internal/
  ```
- [ ] Identificar qué paquetes dependen de `Resources.PostgreSQL`
- [ ] Identificar qué paquetes dependen de `Resources.Logger`
- [ ] Contar ocurrencias y evaluar impacto
- [ ] **Entregable:** `resources_usage.txt` con estadísticas

#### T1.3: Review de Tests de Integración
- [ ] Leer `bootstrap_integration_test.go` completo
- [ ] Documentar qué requiere (Docker, fixtures, etc.)
- [ ] Verificar que tests actuales pasen
- [ ] Identificar qué tests pueden romperse con cambios
- [ ] **Entregable:** Tests baseline (todos pasando)

**Checkpoint:** Crear documento `FASE_0.2_DEPENDENCIAS.md` con hallazgos.

**Criterio de Avance:** No pasar a Etapa 2 hasta tener claridad total.

---

### ETAPA 2: Crear Capa de Adaptación (2-3 horas)

**Objetivo:** Crear adapters sin romper nada existente.

#### T2.1: Adapter para Logger
**Archivo:** `internal/bootstrap/adapter/logger.go`

```go
package adapter

import (
    "github.com/EduGoGroup/edugo-shared/logger"
    "github.com/sirupsen/logrus"
)

// LoggerAdapter adapta logrus.Logger a logger.Logger (interfaz)
type LoggerAdapter struct {
    logrus *logrus.Logger
}

func NewLoggerAdapter(l *logrus.Logger) logger.Logger {
    return &LoggerAdapter{logrus: l}
}

// Implementar métodos de logger.Logger interface
func (a *LoggerAdapter) Info(msg string, fields ...interface{}) { ... }
func (a *LoggerAdapter) Debug(msg string, fields ...interface{}) { ... }
// ... resto de métodos
```

**Tests:** `logger_test.go` con 5 tests mínimo.

#### T2.2: Adapter para Database
**Archivo:** `internal/bootstrap/adapter/database.go`

```go
package adapter

import (
    "database/sql"
    "gorm.io/gorm"
)

// GormToSQL extrae sql.DB de gorm.DB
func GormToSQL(gormDB *gorm.DB) (*sql.DB, error) {
    sqlDB, err := gormDB.DB()
    if err != nil {
        return nil, err
    }
    return sqlDB, nil
}
```

**Tests:** `database_test.go` con casos de error.

#### T2.3: Adapter para S3 (con Presigned URLs)
**Archivo:** `internal/bootstrap/adapter/s3.go`

```go
package adapter

import (
    "context"
    "time"
    "github.com/aws/aws-sdk-go-v2/service/s3"
    "github.com/EduGoGroup/edugo-api-mobile/internal/bootstrap"
)

// S3StorageAdapter implementa bootstrap.S3Storage sobre s3.Client
type S3StorageAdapter struct {
    client        *s3.Client
    presignClient *s3.PresignClient
    bucket        string
}

func NewS3StorageAdapter(client *s3.Client, bucket string) bootstrap.S3Storage {
    return &S3StorageAdapter{
        client:        client,
        presignClient: s3.NewPresignClient(client),
        bucket:        bucket,
    }
}

func (a *S3StorageAdapter) GeneratePresignedUploadURL(ctx context.Context, key, contentType string, expires time.Duration) (string, error) {
    // Implementación con presignClient
}

func (a *S3StorageAdapter) GeneratePresignedDownloadURL(ctx context.Context, key string, expires time.Duration) (string, error) {
    // Implementación con presignClient
}
```

**Tests:** `s3_test.go` con mocks.

**Checkpoint:** Compilar adapter package y ejecutar tests.

**Criterio de Avance:** Todos los adapters compilan y tests pasan.

---

### ETAPA 3: Refactorizar bootstrap.go (2-3 horas)

**Objetivo:** Usar shared/bootstrap internamente, mantener API externa.

#### T3.1: Implementar Config Extractors
Completar los TODOs de shared/bootstrap:
- `extractPostgreSQLConfig(config)`
- `extractMongoDBConfig(config)`
- `extractRabbitMQConfig(config)`
- `extractS3Config(config)`

**Decisión Pendiente:** ¿Crear PRs en shared o implementar en api-mobile?

**Opción A (Recomendada):** Implementar en api-mobile primero, luego PR a shared.

#### T3.2: Refactorizar InitializeInfrastructure()

**Antes:**
```go
func (b *Bootstrap) InitializeInfrastructure(ctx context.Context) (*Resources, func() error, error) {
    // 348 líneas de inicialización manual
}
```

**Después:**
```go
func (b *Bootstrap) InitializeInfrastructure(ctx context.Context) (*Resources, func() error, error) {
    // 1. Llamar a shared/bootstrap
    sharedResources, err := sharedBootstrap.Bootstrap(
        ctx,
        b.config,
        b.factories,
        b.lifecycle,
        sharedBootstrap.WithRequiredResources("logger", "postgresql", "mongodb"),
        sharedBootstrap.WithOptionalResources("rabbitmq", "s3"),
    )
    if err != nil {
        return nil, nil, err
    }

    // 2. Aplicar adapters
    resources := &Resources{
        Logger:            adapter.NewLoggerAdapter(sharedResources.Logger),
        PostgreSQL:        adapter.GormToSQL(sharedResources.PostgreSQL),
        MongoDB:           sharedResources.MongoDatabase,
        RabbitMQPublisher: adapter.NewRabbitMQAdapter(sharedResources.MessagePublisher),
        S3Client:          adapter.NewS3StorageAdapter(sharedResources.StorageClient, config.S3Bucket),
        JWTSecret:         b.config.JWTSecret,
    }

    // 3. Retornar con cleanup function
    cleanup := func() error {
        return b.lifecycle.Cleanup()
    }

    return resources, cleanup, nil
}
```

**Tests:** Actualizar `bootstrap_test.go` para usar nuevos mocks.

#### T3.3: Crear Factories Bridge
**Archivo:** `internal/bootstrap/factories_bridge.go`

Conectar factories de api-mobile con shared/bootstrap:
```go
// Implementar interfaces de shared/bootstrap usando factories de api-mobile
type LoggerFactoryBridge struct { internal LoggerFactory }
func (f *LoggerFactoryBridge) CreateLogger(ctx, env, version) (*logrus.Logger, error) {
    logger, err := f.internal.Create(level, format)
    // Convertir logger.Logger → *logrus.Logger
}
```

**Checkpoint:** Compilar bootstrap.go y ejecutar tests unitarios.

**Criterio de Avance:** Tests unitarios de bootstrap pasan.

---

### ETAPA 4: Actualizar main.go (1 hora)

**Objetivo:** Simplificar orchestration en main.go.

#### T4.1: Simplificar main.go

**Cambios Mínimos:**
```go
// Antes
b := bootstrap.New(cfg)
resources, cleanup, err := b.InitializeInfrastructure(ctx)

// Después (sin cambios externos, pero internamente usa shared)
b := bootstrap.New(cfg)
resources, cleanup, err := b.InitializeInfrastructure(ctx)
```

**Validación:**
- App levanta correctamente
- Swagger funciona
- Health checks responden
- Endpoints funcionan

**Checkpoint:** Ejecutar app localmente y validar funcionamiento.

**Criterio de Avance:** App funcional sin errores.

---

### ETAPA 5: Limpieza y Reorganización (1-2 horas)

**Objetivo:** Eliminar código duplicado, reorganizar estructura.

#### T5.1: Eliminar lifecycle.go
- [ ] Eliminar `internal/bootstrap/lifecycle.go` (155 LOC)
- [ ] Eliminar `internal/bootstrap/lifecycle_test.go` (269 LOC)
- [ ] Actualizar imports para usar `shared/lifecycle`
- [ ] Ejecutar tests para validar

**Ahorro:** 424 LOC eliminadas

#### T5.2: Reorganizar Noops
- [ ] Crear `internal/bootstrap/testutil/`
- [ ] Mover `noop/publisher.go` → `testutil/noop_publisher.go`
- [ ] Mover `noop/storage.go` → `testutil/noop_storage.go`
- [ ] Actualizar imports en tests

#### T5.3: Actualizar Imports Globales
```bash
# Buscar y reemplazar imports viejos
find internal/ -name "*.go" -exec sed -i '' 's/internal\/bootstrap\/lifecycle/shared\/lifecycle/g' {} +
```

**Checkpoint:** Compilar proyecto completo.

**Criterio de Avance:** Sin errores de compilación.

---

### ETAPA 6: Testing Exhaustivo (1-2 horas)

**Objetivo:** Garantizar cero regresiones.

#### T6.1: Tests Unitarios
- [ ] Ejecutar: `go test ./internal/bootstrap/... -v`
- [ ] Coverage mínimo: 70%
- [ ] Todos los tests PASS

#### T6.2: Tests de Integración
- [ ] Levantar Docker: `docker-compose up -d`
- [ ] Ejecutar: `go test ./internal/bootstrap/... -tags=integration -v`
- [ ] Validar que NO se rompieron tests existentes
- [ ] Todos los tests PASS

#### T6.3: Tests End-to-End
- [ ] Levantar app completa: `go run cmd/main.go`
- [ ] Validar endpoints principales:
  - `GET /health`
  - `POST /auth/login`
  - `GET /materials`
- [ ] Validar Swagger UI funciona

#### T6.4: Documentación
- [ ] Actualizar CHANGELOG.md
- [ ] Documentar cambios en README si es necesario
- [ ] Crear migration guide si hay breaking changes

**Checkpoint:** Todos los tests pasando.

**Criterio de Avance:** 100% tests PASS, documentación lista.

---

## ⏱️ Estimación Total Revisada

| Etapa | Estimación | Real Esperado | Complejidad |
|-------|------------|---------------|-------------|
| 1. Análisis Dependencias | 1-2h | ~1.5h | 🟢 Baja |
| 2. Crear Adapters | 2-3h | ~2.5h | 🟡 Media |
| 3. Refactor Bootstrap | 2-3h | ~3h | 🔴 Alta |
| 4. Update Main | 1h | ~0.5h | 🟢 Baja |
| 5. Limpieza | 1-2h | ~1.5h | 🟡 Media |
| 6. Testing | 1-2h | ~2h | 🟡 Media |
| **TOTAL** | **8-13h** | **~11h** | 🟡 Media-Alta |

**Recomendación:** Dividir en 3 sesiones:
- Sesión 1: Etapas 1-2 (3-4h)
- Sesión 2: Etapas 3-4 (3-4h)
- Sesión 3: Etapas 5-6 (3-4h)

---

## 📊 Métricas de Éxito

### Código
- ✅ LOC eliminadas: ~424 (lifecycle duplicado)
- ✅ LOC nuevas: ~200 (adapters)
- ✅ LOC netas: -224 (reducción)
- ✅ Duplicación: 0% (lifecycle)

### Tests
- ✅ Tests unitarios: 100% PASS
- ✅ Tests integración: 100% PASS
- ✅ Coverage: ≥70%
- ✅ Tests nuevos: 15+ (adapters)

### Funcionalidad
- ✅ App levanta sin errores
- ✅ Todos los endpoints funcionan
- ✅ Health checks OK
- ✅ Swagger UI funcional

---

## ⚠️ Riesgos y Mitigaciones

### Riesgo 1: Incompatibilidad de Tipos
**Impacto:** Alto  
**Probabilidad:** Media  
**Mitigación:**
- Crear adapters exhaustivos
- Tests de compatibilidad
- Validar con tests de integración

### Riesgo 2: Tests de Integración Rotos
**Impacto:** Alto  
**Probabilidad:** Media  
**Mitigación:**
- Ejecutar tests después de CADA cambio
- Mantener Docker compose funcionando
- Rollback rápido si algo falla

### Riesgo 3: Performance Degradation
**Impacto:** Medio  
**Probabilidad:** Baja  
**Mitigación:**
- Benchmarks antes/después
- Monitorear tiempo de startup
- Profiling si es necesario

### Riesgo 4: Breaking Changes Ocultos
**Impacto:** Alto  
**Probabilidad:** Baja  
**Mitigación:**
- Tests E2E completos
- Deployment a staging primero
- Canary deployment en prod

---

## 🔄 Rollback Plan

Si algo sale mal en cualquier etapa:

**Opción A: Rollback Git**
```bash
git checkout dev
git branch -D feature/mobile-use-shared-bootstrap
```

**Opción B: Feature Flag**
Implementar flag para usar bootstrap viejo o nuevo:
```go
if config.UseNewBootstrap {
    // shared/bootstrap path
} else {
    // internal/bootstrap path
}
```

---

## 📝 Checklist de Pre-Implementación

Antes de empezar ETAPA 1, validar:

- [ ] FASE_0.2_ANALISIS.md revisado y aprobado
- [ ] Este plan revisado y aprobado
- [ ] Decisión tomada: ¿sql.DB o gorm.DB?
- [ ] Decisión tomada: ¿Migrar internal/config?
- [ ] Rama limpia: `feature/mobile-use-shared-bootstrap`
- [ ] Tests baseline: Todos pasando
- [ ] Ventana de tiempo: 3-4 horas disponibles
- [ ] Backup: Rama respaldada

---

## 🎯 Próxima Acción

1. **Revisar** este plan con el equipo
2. **Validar** decisiones pendientes
3. **Aprobar** plan antes de implementar
4. **Iniciar** ETAPA 1 en nueva sesión

---

**Plan creado:** 13 de Noviembre, 2025  
**Autor:** Claude Code + Jhoan Medina  
**Estado:** 🟡 Pendiente de aprobación  
**Versión:** 1.0
