# Plan de Migración a Shared - Consolidación de Utilidades

**Proyecto Origen:** edugo-api-mobile  
**Proyecto Destino:** edugo-shared  
**Objetivo:** Evitar duplicación de código, facilitar desarrollo de api-admin y worker

---

## 🎯 OBJETIVO

Migrar funcionalidades comunes de `api-mobile` a `shared` para que puedan ser reutilizadas por:
- ✅ `edugo-api-administracion` (beneficiario inmediato)
- ✅ `edugo-worker` (beneficiario futuro)
- ✅ Futuros microservicios

---

## 📊 ANÁLISIS DE CÓDIGO DUPLICADO

### Funcionalidades en api-mobile que Deberían Estar en Shared

| # | Funcionalidad | Ubicación Actual | Ubicación Ideal | LOC | Complejidad | Prioridad |
|---|---------------|------------------|-----------------|-----|-------------|-----------|
| 1 | **Bootstrap System** | api-mobile/internal/bootstrap/ | shared/bootstrap/ | ~500 | 🟡 Media | 🔴 P0 |
| 2 | **Testcontainers Helpers** | api-mobile/internal/bootstrap/noop/ | shared/testing/containers/ | ~300 | 🟢 Baja | 🔴 P0 |
| 3 | **Config Validator** | api-mobile/internal/config/validator.go | shared/config/validator.go | ~200 | 🟢 Baja | 🟡 P1 |
| 4 | **Lifecycle Manager** | api-mobile/internal/bootstrap/lifecycle.go | shared/lifecycle/ | ~150 | 🟢 Baja | 🟡 P1 |
| 5 | **Container DI Patterns** | api-mobile/internal/container/ | shared/container/ (base) | ~400 | 🟡 Media | 🟢 P2 |

**Total a migrar (P0):** ~800 líneas de código

---

## 🔄 FASE 0: Migración a Shared (Sprint Shared-1)

**Duración:** 3 días  
**Branch:** `feature/shared-bootstrap-migration` en edugo-shared  
**Precedentes:** Ninguno  
**Bloqueante para:** Fase 1 de api-admin

---

### Migración 1: Bootstrap System (P0)

#### Estado Actual

**api-mobile/internal/bootstrap/**
```
bootstrap/
├── bootstrap.go              # Inicialización principal
├── config.go                 # Carga de configuración
├── factories.go              # Factories de servicios
├── lifecycle.go              # Startup/Shutdown
├── interfaces.go             # Interfaces de servicios
├── bootstrap_test.go         # Tests unitarios
├── lifecycle_test.go         # Tests de lifecycle
├── bootstrap_integration_test.go  # Tests integración
└── noop/                     # Mocks para testing
    ├── storage.go
    └── publisher.go
```

**Archivos:** 12 archivos, ~500 LOC

#### Plan de Migración

**Día 1:**
- [ ] M1.1 Crear carpeta `shared/bootstrap/`
- [ ] M1.2 Copiar archivos de `api-mobile/internal/bootstrap/` → `shared/bootstrap/`
- [ ] M1.3 Renombrar imports:
  ```go
  // Antes:
  import "github.com/EduGoGroup/edugo-api-mobile/internal/config"
  
  // Después:
  import "github.com/EduGoGroup/edugo-shared/config"
  ```
- [ ] M1.4 Hacer bootstrap genérico (remover dependencias específicas de api-mobile)
- [ ] M1.5 Compilar: `go build ./bootstrap/...`
- [ ] M1.6 Ejecutar tests: `go test ./bootstrap/...`

**Día 1 Checkpoint:** Bootstrap en shared compila ✅

**Día 2:**
- [ ] M1.7 Actualizar `api-mobile` para usar `shared/bootstrap`
  ```go
  // cmd/main.go
  import "github.com/EduGoGroup/edugo-shared/bootstrap"
  ```
- [ ] M1.8 Compilar api-mobile: `make build`
- [ ] M1.9 Ejecutar tests api-mobile: `make test`
- [ ] M1.10 Verificar que TODO funciona igual

**Día 2 Checkpoint:** api-mobile usa shared/bootstrap ✅

---

### Migración 2: Testcontainers Helpers (P0)

#### Estado Actual

**api-mobile/internal/bootstrap/noop/** tiene mocks  
**api-mobile usa testcontainers directamente en tests**

Código disperso en múltiples `*_test.go`:
```go
// Patrón repetido en cada test
postgresContainer, _ := testcontainers.PostgresContainer{...}
defer postgresContainer.Terminate(ctx)
```

#### Plan de Migración

**Día 2-3:**
- [ ] M2.1 Crear `shared/testing/containers/postgres.go`
  ```go
  package containers
  
  import (
      "context"
      "database/sql"
      "github.com/testcontainers/testcontainers-go/modules/postgres"
  )
  
  type PostgresContainer struct {
      container *postgres.PostgresContainer
      db        *sql.DB
  }
  
  func NewPostgresContainer(ctx context.Context) (*PostgresContainer, error) {
      container, err := postgres.Run(ctx,
          "postgres:15-alpine",
          postgres.WithDatabase("edugo_test"),
          postgres.WithUsername("edugo"),
          postgres.WithPassword("test123"),
      )
      if err != nil {
          return nil, err
      }
      
      connStr, _ := container.ConnectionString(ctx)
      db, _ := sql.Open("postgres", connStr)
      
      return &PostgresContainer{
          container: container,
          db:        db,
      }, nil
  }
  
  func (c *PostgresContainer) DB() *sql.DB {
      return c.db
  }
  
  func (c *PostgresContainer) ExecSQL(sqlFile string) error {
      // Helper para ejecutar archivos .sql
  }
  
  func (c *PostgresContainer) Cleanup(ctx context.Context) error {
      c.db.Close()
      return c.container.Terminate(ctx)
  }
  ```
- [ ] M2.2 Crear `shared/testing/containers/mongodb.go` (mismo patrón)
- [ ] M2.3 Crear `shared/testing/containers/rabbitmq.go` (mismo patrón)
- [ ] M2.4 Agregar tests para cada helper
- [ ] M2.5 Actualizar `shared/go.mod`:
  ```
  require (
      github.com/testcontainers/testcontainers-go/modules/postgres v0.39.0
      github.com/testcontainers/testcontainers-go/modules/mongodb v0.39.0
      github.com/testcontainers/testcontainers-go/modules/rabbitmq v0.39.0
  )
  ```

**Día 3 Checkpoint:** Helpers de testcontainers en shared ✅

**Día 3:**
- [ ] M2.6 Refactorizar tests de `api-mobile` para usar helpers:
  ```go
  // Antes:
  container := testcontainers.PostgresContainer{...}  // 10 líneas
  
  // Después:
  container, _ := containers.NewPostgresContainer(ctx)  // 1 línea
  defer container.Cleanup(ctx)
  ```
- [ ] M2.7 Ejecutar tests api-mobile
- [ ] M2.8 Verificar que siguen pasando

**Entregable:** Helpers reutilizables listos ✅

---

### Migración 3: Config Validator (P1)

#### Estado Actual

**api-mobile/internal/config/validator.go**
```go
func ValidateConfig(cfg *Config) error {
    if cfg.Server.Port < 1024 || cfg.Server.Port > 65535 {
        return errors.New("invalid port")
    }
    
    if cfg.Database.MaxConnections < 1 {
        return errors.New("invalid max connections")
    }
    
    // ... más validaciones
}
```

**Archivos:** 2 archivos (~200 LOC)

#### Plan de Migración

- [ ] M3.1 Crear `shared/config/validator.go`
- [ ] M3.2 Hacer validaciones genéricas (no específicas de api-mobile)
- [ ] M3.3 Usar reflection para validar cualquier struct de config
- [ ] M3.4 Agregar tags de validación:
  ```go
  type ServerConfig struct {
      Port int `validate:"required,min=1024,max=65535"`
      Host string `validate:"required,hostname"`
  }
  ```
- [ ] M3.5 Usar librería `go-playground/validator`
- [ ] M3.6 Migrar a api-mobile y api-admin

**Esfuerzo:** 1 día

---

## 📦 ESTRUCTURA FINAL DE SHARED

```
edugo-shared/
├── auth/                    # ✅ Existente (JWT, tokens)
├── bootstrap/               # ⭐ NUEVO (de api-mobile)
│   ├── bootstrap.go
│   ├── config.go
│   ├── factories.go
│   ├── lifecycle.go
│   └── interfaces.go
├── common/                  # ✅ Existente (errors, types)
├── config/                  # ⭐ MEJORADO
│   └── validator.go         # NUEVO (de api-mobile)
├── database/                # ✅ Existente (postgres, mongodb)
├── logger/                  # ✅ Existente
├── messaging/               # ✅ Existente (rabbitmq)
├── middleware/              # ✅ Existente
└── testing/                 # ⭐ NUEVO
    └── containers/          # Testcontainers helpers
        ├── postgres.go
        ├── mongodb.go
        └── rabbitmq.go
```

---

## 🚀 PLAN DE EJECUCIÓN

### Sprint Shared-1 (3 días)

| Día | Tarea | Entregable |
|-----|-------|------------|
| 1 | Migrar bootstrap system | Bootstrap en shared compila |
| 2 | Crear testcontainers helpers | Helpers funcionando |
| 3 | Actualizar api-mobile | api-mobile usa shared, tests pasan |

**Branch:** `feature/shared-bootstrap-migration`  
**PR:** PR-S1 → `shared/dev`

---

### Beneficios Inmediatos

| Proyecto | Beneficio |
|----------|-----------|
| **api-administracion** | Puede usar bootstrap y testcontainers inmediatamente |
| **worker** | Puede usar helpers para tests |
| **api-mobile** | Código más limpio, menos duplicación |

---

## ⚠️ CONSIDERACIONES

### Versionado de Shared

Cada cambio en shared requiere:
1. Incrementar versión en `shared/go.mod`
2. Tag en git: `v0.X.Y`
3. Actualizar dependencia en proyectos consumidores:
   ```bash
   go get github.com/EduGoGroup/edugo-shared/bootstrap@v0.2.0
   ```

### Compatibilidad

- ✅ Mantener backwards compatibility
- ✅ No romper api-mobile existente
- ✅ Tests deben pasar antes y después de migración

---

## 📋 CHECKLIST DE MIGRACIÓN

### Pre-Migración
- [ ] Identificar código a migrar
- [ ] Verificar que es genérico (no específico de api-mobile)
- [ ] Crear tests para ese código

### Durante Migración
- [ ] Copiar código a shared
- [ ] Ajustar imports
- [ ] Compilar shared
- [ ] Tests de shared pasan
- [ ] Actualizar api-mobile para usar shared
- [ ] Tests de api-mobile pasan

### Post-Migración
- [ ] Eliminar código duplicado de api-mobile
- [ ] Actualizar documentación
- [ ] Tag de versión en shared
- [ ] Actualizar go.mod en proyectos

---

## 🎯 CRITERIO DE ÉXITO

Sprint Shared-1 se considera completo cuando:
- [ ] Bootstrap y testcontainers en shared
- [ ] api-mobile usa shared (sin duplicación)
- [ ] api-admin puede usar shared
- [ ] Todos los tests pasan
- [ ] PR-S1 mergeado a `shared/dev`
- [ ] Tag `v0.2.0` creado en shared

---

**Generado con** 🤖 Claude Code
