# Especificaciones Técnicas: Valores Concretos

**Propósito:** Eliminar ambigüedades - todos los valores y mapeos están definidos aquí

---

## 1. Mapeos de Tablas a Entities

### PostgreSQL

| Tabla SQL | Entity Go | Paquete | Primary Key Type |
|-----------|-----------|---------|------------------|
| users | User | entities.User | uuid.UUID |
| schools | School | entities.School | uuid.UUID |
| academic_units | AcademicUnit | entities.AcademicUnit | uuid.UUID |
| memberships | Membership | entities.Membership | uuid.UUID |
| materials | Material | entities.Material | uuid.UUID |
| subjects | Subject | entities.Subject | uuid.UUID |
| units | Unit | entities.Unit | uuid.UUID |
| guardian_relations | GuardianRelation | entities.GuardianRelation | uuid.UUID |

**Código Generado:**
```go
// Mapeo hardcoded en generator
var TableToEntity = map[string]string{
    "users":             "User",
    "schools":           "School",
    "academic_units":    "AcademicUnit",
    "memberships":       "Membership",
    "materials":         "Material",
    "subjects":          "Subject",
    "units":             "Unit",
    "guardian_relations": "GuardianRelation",
}
```

---

## 2. Mapeos de Tipos SQL a Go

| Tipo SQL | Tipo Go | Import Requerido |
|----------|---------|------------------|
| UUID | uuid.UUID | github.com/google/uuid |
| VARCHAR(n) | string | - |
| TEXT | string | - |
| BOOLEAN | bool | - |
| INTEGER | int | - |
| BIGINT | int64 | - |
| DECIMAL | float64 | - |
| TIMESTAMP WITH TIME ZONE | time.Time | time |
| TIMESTAMP (nullable) | *time.Time | time |
| JSONB | []byte | - |
| ARRAY | []string | - |

**Código Generado:**
```go
func sqlTypeToGoType(sqlType string) string {
    mapping := map[string]string{
        "UUID":                         "uuid.UUID",
        "VARCHAR":                      "string",
        "TEXT":                         "string",
        "BOOLEAN":                      "bool",
        "INTEGER":                      "int",
        "BIGINT":                       "int64",
        "DECIMAL":                      "float64",
        "TIMESTAMP WITH TIME ZONE":     "time.Time",
        "JSONB":                        "[]byte",
    }
    return mapping[sqlType]
}
```

---

## 3. Funciones SQL a Go

| Función SQL | Valor Go | Comentario |
|-------------|----------|------------|
| NOW() | time.Now() | Timestamp actual |
| gen_random_uuid() | uuid.New() | UUID aleatorio |
| CURRENT_DATE | time.Now().Truncate(24*time.Hour) | Fecha sin hora |
| TRUE | true | Boolean true |
| FALSE | false | Boolean false |
| NULL | nil | Valor nulo |

**Código Generado:**
```go
func evalSQLFunction(funcName string) string {
    switch strings.ToLower(funcName) {
    case "now":
        return "time.Now()"
    case "gen_random_uuid":
        return "uuid.New()"
    case "current_date":
        return "time.Now().Truncate(24*time.Hour)"
    default:
        return fmt.Sprintf("/* SQL function: %s */", funcName)
    }
}
```

---

## 4. Estructura de Directorios (Exacta)

### edugo-infrastructure
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/
├── tools/
│   └── mock-generator/
│       ├── cmd/
│       │   └── main.go              # CLI principal
│       ├── pkg/
│       │   ├── parser/
│       │   │   └── sql_parser.go    # Parser SQL
│       │   ├── generator/
│       │   │   ├── dataset_generator.go
│       │   │   ├── table_generator.go
│       │   │   └── loader_generator.go
│       │   └── types/
│       │       └── mappings.go      # Mapeos de tabla→entity
│       ├── go.mod
│       ├── go.sum
│       └── bin/
│           └── mock-generator       # Binario compilado
│
├── postgres/
│   └── migrations/
│       ├── testing/
│       │   ├── 001_demo_users.sql         # 8 usuarios
│       │   ├── 002_demo_schools.sql       # 3 escuelas
│       │   ├── 003_demo_academic_units.sql # 5 unidades
│       │   ├── 004_demo_memberships.sql   # 12 memberships
│       │   └── 005_demo_materials.sql     # 3 materiales
│       └── constraints/
│           ├── 001_create_users.sql       # Schema de users
│           ├── 002_create_schools.sql     # Schema de schools
│           └── ...
│
└── postgres/entities/
    ├── user.go
    ├── school.go
    ├── academic_unit.go
    └── ...
```

### edugo-api-administracion
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/
└── internal/
    └── infrastructure/
        └── persistence/
            └── mock/
                ├── dataset/                # AUTO-GENERADO
                │   ├── database.go
                │   ├── users_table.go
                │   ├── schools_table.go
                │   ├── academic_units_table.go
                │   ├── memberships_table.go
                │   ├── materials_table.go
                │   └── load_data.go
                └── repository/             # MANUAL (simple)
                    ├── user_repository_mock.go
                    ├── school_repository_mock.go
                    └── ...
```

### edugo-api-mobile
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/
└── internal/
    └── infrastructure/
        └── persistence/
            └── mock/
                ├── dataset/                # AUTO-GENERADO (idéntico)
                │   ├── database.go
                │   ├── users_table.go
                │   └── ...
                └── postgres/               # MANUAL (simple)
                    ├── user_repository_mock.go
                    ├── material_repository_mock.go
                    └── ...
```

---

## 5. Variables de Entorno (Estandarizadas)

### Variable Única para Ambas APIs

**Nombre:** `USE_MOCK_REPOSITORIES`  
**Valores:** `true` | `false`  
**Default:** `false`

### Configuración por API

#### api-administracion

**Archivo:** `internal/config/loader.go` (línea ~130)
```go
_ = v.BindEnv("database.use_mock_repositories", "USE_MOCK_REPOSITORIES")
```

**Archivo:** `.zed/debug.json`
```json
{
  "label": "Go: Debug main (MOCK - Sin Docker)",
  "env": {
    "USE_MOCK_REPOSITORIES": "true",
    "APP_ENV": "local"
  }
}
```

#### api-mobile

**Archivo:** `internal/config/config.go` (después de otros BindEnv)
```go
_ = v.BindEnv("development.use_mock_repositories", "USE_MOCK_REPOSITORIES")
```

**Archivo:** `.zed/debug.json`
```json
{
  "label": "Go: Debug main (MOCK - Sin Docker)",
  "env": {
    "USE_MOCK_REPOSITORIES": "true",
    "APP_ENV": "local"
  }
}
```

---

## 6. Datos Mock Disponibles (Exactos)

### Usuarios (8 total)

| ID | Email | Password | Role | Nombre |
|----|-------|----------|------|--------|
| a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11 | admin@edugo.test | edugo2024 | admin | Admin Demo |
| a2eebc99-9c0b-4ef8-bb6d-6bb9bd380a22 | teacher.math@edugo.test | edugo2024 | teacher | María García |
| a3eebc99-9c0b-4ef8-bb6d-6bb9bd380a33 | teacher.science@edugo.test | edugo2024 | teacher | Juan Pérez |
| a4eebc99-9c0b-4ef8-bb6d-6bb9bd380a44 | student1@edugo.test | edugo2024 | student | Carlos Rodríguez |
| a5eebc99-9c0b-4ef8-bb6d-6bb9bd380a55 | student2@edugo.test | edugo2024 | student | Ana Martínez |
| a6eebc99-9c0b-4ef8-bb6d-6bb9bd380a66 | student3@edugo.test | edugo2024 | student | Luis González |
| a7eebc99-9c0b-4ef8-bb6d-6bb9bd380a77 | guardian1@edugo.test | edugo2024 | guardian | Roberto Fernández |
| a8eebc99-9c0b-4ef8-bb6d-6bb9bd380a88 | guardian2@edugo.test | edugo2024 | guardian | Patricia López |

### Escuelas (3 total)

| ID | Nombre | Código | Ciudad |
|----|--------|--------|--------|
| b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11 | Escuela Primaria Demo | SCH_PRI_001 | Buenos Aires |
| b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a22 | Colegio Secundario Demo | SCH_SEC_001 | Buenos Aires |
| b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a33 | Instituto Técnico Demo | SCH_TEC_001 | Córdoba |

### Materiales (3 total)

| ID | Título | Tipo | Escuela |
|----|--------|------|---------|
| 66666666-6666-6666-6666-666666666666 | Introducción a Física Cuántica | PDF | Secundario Demo |
| 77777777-7777-7777-7777-777777777777 | Álgebra Lineal Básica | PDF | Técnico Demo |
| 88888888-8888-8888-8888-888888888888 | Historia Argentina S.XX | VIDEO | Primaria Demo |

---

## 7. Comandos Exactos (Copy-Paste Ready)

### Compilar Parser

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
go mod init github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator
go mod tidy
go build -o bin/mock-generator cmd/main.go
```

### Generar Dataset para api-administracion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset
```

### Generar Dataset para api-mobile

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/infrastructure/persistence/mock/dataset
```

### Probar api-administracion con Mocks

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
make build
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
sleep 3

# Health check
curl http://localhost:8081/health

# Login
curl -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}'

# Limpiar
pkill api-administracion
```

### Probar api-mobile con Mocks

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
make build
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-mobile &
sleep 3

# Health check
curl http://localhost:9091/health

# Materiales (requiere token de api-admin primero)
# ... ver plan de sprints

# Limpiar
pkill api-mobile
```

---

## 8. Archivos a Crear (Template Exacto)

### database.go

```go
// Code generated by mock-generator. DO NOT EDIT.
// Generator version: 1.0.0
// Generated at: {{ .Timestamp }}

package dataset

import "sync"

type MockDatabase struct {
    Users           *UsersTable
    Schools         *SchoolsTable
    AcademicUnits   *AcademicUnitsTable
    Memberships     *MembershipsTable
    Materials       *MaterialsTable
    
    mu sync.RWMutex
}

var DB *MockDatabase

func init() {
    DB = &MockDatabase{
        Users:         NewUsersTable(),
        Schools:       NewSchoolsTable(),
        AcademicUnits: NewAcademicUnitsTable(),
        Memberships:   NewMembershipsTable(),
        Materials:     NewMaterialsTable(),
    }
    LoadAllData()
}
```

### users_table.go

```go
// Code generated by mock-generator. DO NOT EDIT.

package dataset

import (
    "sync"
    "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
    "github.com/google/uuid"
)

type UsersTable struct {
    data map[uuid.UUID]*entities.User
    mu   sync.RWMutex
}

func NewUsersTable() *UsersTable {
    return &UsersTable{
        data: make(map[uuid.UUID]*entities.User),
    }
}

func (t *UsersTable) FindByID(id uuid.UUID) *entities.User {
    t.mu.RLock()
    defer t.mu.RUnlock()
    
    if user, ok := t.data[id]; ok {
        return user
    }
    return nil
}

func (t *UsersTable) List() []*entities.User {
    t.mu.RLock()
    defer t.mu.RUnlock()
    
    users := make([]*entities.User, 0, len(t.data))
    for _, user := range t.data {
        users = append(users, user)
    }
    return users
}
```

---

## 9. Errores Esperados y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| `package dataset not found` | Dataset no generado | Ejecutar `mock-generator` |
| `undefined: uuid` | Import falta | Agregar `"github.com/google/uuid"` |
| `undefined: entities.User` | Import falta | Agregar `"github.com/EduGoGroup/edugo-infrastructure/postgres/entities"` |
| `bind: address already in use` | Puerto ocupado | `pkill api-administracion` o cambiar puerto |
| `failed to connect to postgres` | Variable mal configurada | Verificar `USE_MOCK_REPOSITORIES=true` |

---

## 10. Criterios de Validación (Específicos)

### Parser
- [ ] Archivo `bin/mock-generator` existe y es ejecutable
- [ ] Ejecutar parser muestra: "✅ Parseados 5 archivos SQL"
- [ ] Output muestra: "users: 8 registros"

### Dataset Generado
- [ ] Archivo `dataset/database.go` existe (tamaño ~500 bytes)
- [ ] Archivo `dataset/users_table.go` existe (tamaño ~1.5KB)
- [ ] Archivo `dataset/load_data.go` existe (tamaño ~5KB)
- [ ] Compilación: `go build ./internal/infrastructure/persistence/mock/dataset` → sin errores

### api-administracion
- [ ] `curl http://localhost:8081/health` → status 200
- [ ] Login retorna `{"access_token":"eyJ..."}`
- [ ] Lista escuelas retorna array con `length == 3`

### api-mobile
- [ ] `curl http://localhost:9091/health` → status 200
- [ ] Lista materiales retorna array con `length == 3` (NO vacío)

---

## 11. Versiones de Dependencias

```
Go: 1.21+
github.com/pingcap/tidb/parser: v0.0.0-20231130042310-925c364b3cf3
github.com/spf13/cobra: v1.8.0
github.com/google/uuid: v1.3.0
```

---

**Próximo:** Ver CHECKLIST-EJECUCION.md para pasos de validación.
