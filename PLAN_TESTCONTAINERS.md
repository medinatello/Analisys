# 📋 PLAN: Testcontainers para Tests de Integración

**Objetivo**: Implementar tests de integración aislados con testcontainers (on-demand, no se ejecutan con `go test` normal)

---

## 🎯 REQUISITOS

1. ✅ **Aislado**: No se ejecuta con `go test` (usa build tags `-tags=integration`)
2. ✅ **On-demand**: Solo cuando se solicite explícitamente
3. ✅ **Por proyecto**: Cada proyecto puede probar su funcionalidad
4. ✅ **Global**: Probar los 3 proyectos juntos (end-to-end)
5. ✅ **Automatizado**: Crear contenedores → Cargar datos → Test → Tumbar

---

## 🏗️ ESTRUCTURA PROPUESTA

```
source/
├── api-mobile/
│   ├── test/
│   │   └── integration/
│   │       ├── setup.go              # Setup testcontainers
│   │       ├── postgres_test.go      # Tests PostgreSQL
│   │       ├── mongodb_test.go       # Tests MongoDB
│   │       ├── rabbitmq_test.go      # Tests RabbitMQ
│   │       └── handlers_test.go      # Tests handlers con DB real
│   │
├── api-administracion/
│   └── test/integration/             # Similar (sin RabbitMQ)
│
├── worker/
│   └── test/integration/             # Similar
│
└── test/
    └── integration/
        └── e2e_test.go               # Tests end-to-end (3 servicios)
```

---

## 🔧 IMPLEMENTACIÓN

### Build Tags

Usar `//go:build integration` en archivos de test:

```go
//go:build integration

package integration_test

import "testing"

func TestWithPostgres(t *testing.T) {
    // Test que usa testcontainers
}
```

**Resultado**: `go test ./...` NO ejecuta estos tests
**Ejecutar**: `go test -tags=integration ./test/integration/...`

---

## 📦 TESTCONTAINERS SETUP

### Setup Helper (test/integration/setup.go)

```go
//go:build integration

package integration

import (
    "context"
    "testing"
    
    "github.com/testcontainers/testcontainers-go/modules/postgres"
    "github.com/testcontainers/testcontainers-go/modules/mongodb"
    "github.com/testcontainers/testcontainers-go/modules/rabbitmq"
)

type TestContainers struct {
    Postgres *postgres.PostgresContainer
    MongoDB  *mongodb.MongoDBContainer
    RabbitMQ *rabbitmq.RabbitMQContainer
}

func SetupContainers(t *testing.T) (*TestContainers, func()) {
    ctx := context.Background()
    
    // PostgreSQL con scripts de inicialización
    pgContainer, err := postgres.Run(ctx, "postgres:15-alpine",
        postgres.WithDatabase("edugo"),
        postgres.WithUsername("edugo_user"),
        postgres.WithPassword("edugo_pass"),
        postgres.WithInitScripts(
            "../../scripts/postgresql/01_schema.sql",
            "../../scripts/postgresql/02_indexes.sql",
            "../../scripts/postgresql/03_mock_data.sql",
        ),
    )
    if err != nil {
        t.Fatalf("Failed to start Postgres: %v", err)
    }
    
    // MongoDB con scripts
    mongoContainer, err := mongodb.Run(ctx, "mongo:7.0")
    if err != nil {
        t.Fatalf("Failed to start MongoDB: %v", err)
    }
    
    // RabbitMQ con colas y exchanges
    rabbitContainer, err := rabbitmq.Run(ctx, "rabbitmq:3.12-management-alpine",
        rabbitmq.WithAdminUsername("edugo_user"),
        rabbitmq.WithAdminPassword("edugo_pass"),
    )
    if err != nil {
        t.Fatalf("Failed to start RabbitMQ: %v", err)
    }
    
    // Crear colas y exchanges
    // TODO: Usar rabbitmqadmin para crear edugo.material.uploaded, etc.
    
    containers := &TestContainers{
        Postgres: pgContainer,
        MongoDB:  mongoContainer,
        RabbitMQ: rabbitContainer,
    }
    
    // Cleanup function
    cleanup := func() {
        pgContainer.Terminate(ctx)
        mongoContainer.Terminate(ctx)
        rabbitContainer.Terminate(ctx)
    }
    
    return containers, cleanup
}
```

---

## 🧪 EJEMPLO DE TEST

### API Mobile - Handler Test con DB Real

```go
//go:build integration

package integration

import (
    "testing"
    "net/http/httptest"
    
    "github.com/stretchr/testify/assert"
)

func TestGetMaterialsIntegration(t *testing.T) {
    // Setup contenedores
    containers, cleanup := SetupContainers(t)
    defer cleanup()
    
    // Conectar a PostgreSQL
    connStr, _ := containers.Postgres.ConnectionString(context.Background())
    db := ConnectPostgres(connStr)
    defer db.Close()
    
    // Conectar a MongoDB
    mongoURI, _ := containers.MongoDB.ConnectionString(context.Background())
    mongoClient := ConnectMongoDB(mongoURI)
    defer mongoClient.Disconnect(context.Background())
    
    // Inicializar API con conexiones reales
    api := InitAPIWithRealConnections(db, mongoClient)
    
    // Ejecutar request
    req := httptest.NewRequest("GET", "/v1/materials", nil)
    w := httptest.NewRecorder()
    api.ServeHTTP(w, req)
    
    // Assertions
    assert.Equal(t, 200, w.Code)
    // Más assertions...
}
```

---

## 🎯 MAKEFILES ACTUALIZADOS

### Por Proyecto

```makefile
test-integration: ## Tests de integración (con testcontainers)
	@echo "$(YELLOW)🐳 Ejecutando tests de integración...$(RESET)"
	@go test -v -tags=integration ./test/integration/... -timeout 5m
	@echo "$(GREEN)✓ Tests de integración completados$(RESET)"

test-integration-verbose: ## Tests de integración (verbose)
	@go test -v -tags=integration ./test/integration/... -timeout 5m -v

test-integration-coverage: ## Tests de integración con coverage
	@mkdir -p $(COVERAGE_DIR)
	@go test -tags=integration -coverprofile=$(COVERAGE_DIR)/integration-coverage.out ./test/integration/...
	@go tool cover -html=$(COVERAGE_DIR)/integration-coverage.out -o $(COVERAGE_DIR)/integration-coverage.html
```

### Raíz (Orquestador)

```makefile
test-integration-all: ## Tests de integración en todos los proyectos
	@echo "$(BLUE)=== 🐳 TESTS DE INTEGRACIÓN ===$(RESET)"
	@for project in $(PROJECTS); do \
		cd $$project && make test-integration && cd ../../..; \
	done
	@echo "$(GREEN)✅ Tests de integración completados$(RESET)"

test-e2e: ## Tests end-to-end (3 servicios juntos)
	@echo "$(YELLOW)🌐 Ejecutando tests end-to-end...$(RESET)"
	@go test -v -tags=integration ./test/integration/... -timeout 10m
```

---

## 📋 FASES DE IMPLEMENTACIÓN

### FASE 1: Setup Básico (30min)

1.1. Agregar dependencias testcontainers:
```bash
cd source/api-mobile
go get github.com/testcontainers/testcontainers-go
go get github.com/testcontainers/testcontainers-go/modules/postgres
go get github.com/testcontainers/testcontainers-go/modules/mongodb
go get github.com/testcontainers/testcontainers-go/modules/rabbitmq
go get github.com/stretchr/testify/assert
```

1.2. Crear carpetas:
```bash
mkdir -p source/api-mobile/test/integration
mkdir -p source/api-administracion/test/integration
mkdir -p source/worker/test/integration
mkdir -p test/integration
```

1.3. Crear setup.go base en cada proyecto

**Commit**: `test: add testcontainers dependencies and structure`

---

### FASE 2: API Mobile Integration Tests (45min)

2.1. Crear `test/integration/setup.go`:
- SetupPostgres() con scripts
- SetupMongoDB() con collections
- SetupRabbitMQ() con queues/exchanges
- SetupAll() que retorna todo + cleanup

2.2. Crear tests básicos:
- `postgres_test.go`: Verificar que tablas existen
- `mongodb_test.go`: Verificar que collections existen
- `rabbitmq_test.go`: Verificar que colas existen
- `handlers_test.go`: Test básico de handler con DB real (simple)

2.3. Actualizar Makefile con targets integration

**Commit**: `test(api-mobile): add integration tests with testcontainers`

---

### FASE 3: API Admin Integration Tests (20min)

3.1. Copiar estructura de api-mobile
3.2. Ajustar (sin RabbitMQ)
3.3. Tests básicos

**Commit**: `test(api-admin): add integration tests`

---

### FASE 4: Worker Integration Tests (25min)

4.1. Copiar estructura
4.2. Tests específicos de worker

**Commit**: `test(worker): add integration tests`

---

### FASE 5: End-to-End Tests (30min)

5.1. Crear `test/integration/e2e_test.go`
5.2. Levantar 3 contenedores de servicios
5.3. Test completo de flujo (publicar → procesar → consumir)

**Commit**: `test: add end-to-end integration tests`

---

### FASE 6: Documentación (15min)

6.1. Actualizar docs/DEVELOPMENT.md
6.2. Crear test/integration/README.md

**Commit**: `docs: document integration testing with testcontainers`

---

## ⏱️ ESTIMACIÓN

| Fase | Tiempo | Archivos |
|------|--------|----------|
| 1. Setup | 30min | 4 archivos |
| 2. API Mobile | 45min | 5 archivos |
| 3. API Admin | 20min | 4 archivos |
| 4. Worker | 25min | 4 archivos |
| 5. E2E | 30min | 2 archivos |
| 6. Docs | 15min | 2 archivos |
| **TOTAL** | **2.5 horas** | **21 archivos** |

---

## 🎯 VENTAJAS

1. ✅ **Aislado**: No interfiere con tests unitarios
2. ✅ **Reproducible**: Mismo ambiente siempre
3. ✅ **Rápido**: Testcontainers es ligero
4. ✅ **Real**: Prueba con BD reales, no mocks
5. ✅ **Automático**: Setup/teardown automático
6. ✅ **CI-ready**: Funciona en GitHub Actions

---

## 📝 COMANDOS

```bash
# Tests unitarios (rápidos, sin contenedores)
make test

# Tests de integración (con contenedores) - Por proyecto
cd source/api-mobile
make test-integration

# Tests de integración - Todos los proyectos
make test-integration-all

# Tests end-to-end (3 servicios)
make test-e2e

# Solo ejecutar manualmente
go test -tags=integration -v ./test/integration/...
```

---

**¿Apruebas este plan? ¿Quieres que lo implemente ahora o lo dejamos documentado para más adelante?**
