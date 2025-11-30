# Plan de Sprints: Implementación Dataset + Estandarización

**Duración Total:** 5 sprints (10-12 semanas)  
**Modo:** Ejecución desatendida (sin intervención manual)

---

## Sprint 1: Parser SQL Básico (Semanas 1-2)

### Objetivo
Crear parser que lea archivos SQL de testing y extraiga datos INSERT.

### Ubicación de Trabajo
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/
```

### Entregables

#### 1.1 Estructura de Proyecto
```bash
mkdir -p tools/mock-generator/{cmd,pkg/{parser,types}}
cd tools/mock-generator

# Crear go.mod
cat > go.mod << 'EOF'
module github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator

go 1.21

require (
    github.com/pingcap/tidb/parser v0.0.0-20231130042310-925c364b3cf3
    github.com/spf13/cobra v1.8.0
)
EOF

go mod tidy
```

#### 1.2 Archivo: cmd/main.go
```go
package main

import (
    "fmt"
    "os"
    "github.com/spf13/cobra"
    "github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator/pkg/parser"
)

var rootCmd = &cobra.Command{
    Use:   "mock-generator",
    Short: "Genera código Go desde scripts SQL de testing",
    Run:   runGenerator,
}

var (
    testingDir string
    outputDir  string
)

func init() {
    rootCmd.Flags().StringVar(&testingDir, "testing", "../../postgres/migrations/testing", "Directorio con SQL de testing")
    rootCmd.Flags().StringVar(&outputDir, "output", "../../mock/dataset", "Directorio de salida")
}

func main() {
    if err := rootCmd.Execute(); err != nil {
        fmt.Println(err)
        os.Exit(1)
    }
}

func runGenerator(cmd *cobra.Command, args []string) {
    fmt.Println("🔨 Generando dataset desde migraciones...")
    
    p := parser.NewSQLParser()
    inserts, err := p.ParseDirectory(testingDir)
    if err != nil {
        fmt.Printf("❌ Error: %v\n", err)
        os.Exit(1)
    }
    
    fmt.Printf("✅ Parseados %d archivos SQL\n", len(inserts))
    for table, rows := range inserts {
        fmt.Printf("   - %s: %d registros\n", table, len(rows))
    }
}
```

#### 1.3 Archivo: pkg/parser/sql_parser.go
```go
package parser

import (
    "os"
    "path/filepath"
    "strings"
    "github.com/pingcap/tidb/parser"
    "github.com/pingcap/tidb/parser/ast"
    _ "github.com/pingcap/tidb/parser/test_driver"
)

type SQLParser struct {
    p *parser.Parser
}

type TableData struct {
    Table   string
    Columns []string
    Rows    [][]interface{}
}

func NewSQLParser() *SQLParser {
    return &SQLParser{
        p: parser.New(),
    }
}

func (sp *SQLParser) ParseDirectory(dir string) (map[string]*TableData, error) {
    result := make(map[string]*TableData)
    
    files, _ := filepath.Glob(filepath.Join(dir, "*.sql"))
    
    for _, file := range files {
        content, _ := os.ReadFile(file)
        
        stmts, _, err := sp.p.Parse(string(content), "", "")
        if err != nil {
            continue
        }
        
        for _, stmt := range stmts {
            if insert, ok := stmt.(*ast.InsertStmt); ok {
                data := sp.extractInsertData(insert)
                result[data.Table] = data
            }
        }
    }
    
    return result, nil
}

func (sp *SQLParser) extractInsertData(insert *ast.InsertStmt) *TableData {
    // Extraer nombre de tabla
    tableName := insert.Table.TableRefs.Left.(*ast.TableSource).Source.(*ast.TableName).Name.O
    
    // Extraer columnas
    var columns []string
    for _, col := range insert.Columns {
        columns = append(columns, col.Name.O)
    }
    
    // Extraer valores
    var rows [][]interface{}
    for _, list := range insert.Lists {
        var row []interface{}
        for _, expr := range list {
            val := sp.evalExpr(expr)
            row = append(row, val)
        }
        rows = append(rows, row)
    }
    
    return &TableData{
        Table:   tableName,
        Columns: columns,
        Rows:    rows,
    }
}

func (sp *SQLParser) evalExpr(expr ast.ExprNode) interface{} {
    switch e := expr.(type) {
    case *ast.ValueExpr:
        datum := e.GetDatumString()
        return strings.Trim(datum, "'")
    case *ast.FuncCallExpr:
        if strings.ToLower(e.FnName.L) == "now" {
            return "NOW()"
        }
    }
    return ""
}
```

#### 1.4 Test Manual
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

# Compilar
go build -o bin/mock-generator cmd/main.go

# Ejecutar
./bin/mock-generator --testing ../../postgres/migrations/testing

# Salida esperada:
# 🔨 Generando dataset desde migraciones...
# ✅ Parseados 5 archivos SQL
#    - users: 8 registros
#    - schools: 3 registros
#    - academic_units: 5 registros
#    - memberships: 12 registros
#    - materials: 3 registros
```

### Criterios de Éxito Sprint 1
- [ ] Parser compila sin errores
- [ ] Parsea correctamente 001_demo_users.sql
- [ ] Extrae 8 usuarios con todos los campos
- [ ] Parsea NOW() correctamente
- [ ] Parsea UUIDs correctamente

---

## Sprint 2: Generador de Dataset Simple (Semanas 3-4)

### Objetivo
Generar archivos Go del dataset desde datos parseados.

### Entregables

#### 2.1 Archivo: pkg/generator/dataset_generator.go
```go
package generator

import (
    "bytes"
    "fmt"
    "os"
    "os/exec"
    "path/filepath"
    "text/template"
    "github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator/pkg/parser"
    "github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator/pkg/types"
)

type DatasetGenerator struct {
    outputDir string
    tables    map[string]*parser.TableData
}

func NewDatasetGenerator(outputDir string, tables map[string]*parser.TableData) *DatasetGenerator {
    return &DatasetGenerator{
        outputDir: outputDir,
        tables:    tables,
    }
}

func (g *DatasetGenerator) Generate() error {
    // 1. Crear directorio de salida
    os.MkdirAll(g.outputDir, 0755)
    
    // 2. Generar database.go
    if err := g.generateDatabase(); err != nil {
        return err
    }
    
    // 3. Generar *_table.go para cada tabla
    for tableName, data := range g.tables {
        if err := g.generateTable(tableName, data); err != nil {
            return err
        }
    }
    
    // 4. Generar load_data.go
    if err := g.generateLoader(); err != nil {
        return err
    }
    
    // 5. Formatear todo con gofmt
    exec.Command("gofmt", "-w", g.outputDir).Run()
    
    return nil
}

func (g *DatasetGenerator) generateDatabase() error {
    tmpl := template.Must(template.New("database").Parse(databaseTemplate))
    
    data := struct {
        Tables []string
    }{
        Tables: g.getTableNames(),
    }
    
    var buf bytes.Buffer
    tmpl.Execute(&buf, data)
    
    filename := filepath.Join(g.outputDir, "database.go")
    return os.WriteFile(filename, buf.Bytes(), 0644)
}

const databaseTemplate = `// Code generated by mock-generator. DO NOT EDIT.

package dataset

import "sync"

type MockDatabase struct {
    {{- range .Tables }}
    {{ . }} *{{ . }}Table
    {{- end }}
    
    mu sync.RWMutex
}

var DB *MockDatabase

func init() {
    DB = &MockDatabase{
        {{- range .Tables }}
        {{ . }}: New{{ . }}Table(),
        {{- end }}
    }
    LoadAllData()
}
`

// Resto de métodos...
```

#### 2.2 Templates Go (Valores Específicos)

**Template para users_table.go:**
```go
const tableTemplate = `// Code generated by mock-generator. DO NOT EDIT.

package dataset

import (
    "sync"
    "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
    "github.com/google/uuid"
)

type {{ .TableNameCamel }}Table struct {
    data map[uuid.UUID]*entities.{{ .EntityName }}
    mu   sync.RWMutex
}

func New{{ .TableNameCamel }}Table() *{{ .TableNameCamel }}Table {
    return &{{ .TableNameCamel }}Table{
        data: make(map[uuid.UUID]*entities.{{ .EntityName }}),
    }
}

func (t *{{ .TableNameCamel }}Table) FindByID(id uuid.UUID) *entities.{{ .EntityName }} {
    t.mu.RLock()
    defer t.mu.RUnlock()
    
    if item, ok := t.data[id]; ok {
        return item
    }
    return nil
}

func (t *{{ .TableNameCamel }}Table) List() []*entities.{{ .EntityName }} {
    t.mu.RLock()
    defer t.mu.RUnlock()
    
    items := make([]*entities.{{ .EntityName }}, 0, len(t.data))
    for _, item := range t.data {
        items = append(items, item)
    }
    return items
}
`
```

#### 2.3 Mapeo Tablas → Entities (Sin Ambigüedad)

**Archivo:** pkg/types/mappings.go
```go
package types

// TableToEntity mapea nombre de tabla SQL a nombre de entity Go
var TableToEntity = map[string]string{
    "users":           "User",
    "schools":         "School",
    "academic_units":  "AcademicUnit",
    "memberships":     "Membership",
    "materials":       "Material",
    "subjects":        "Subject",
    "units":           "Unit",
    "guardian_relations": "GuardianRelation",
}

// TableNameToCamel convierte nombre de tabla a CamelCase
func TableNameToCamel(table string) string {
    mapping := map[string]string{
        "users":             "Users",
        "schools":           "Schools",
        "academic_units":    "AcademicUnits",
        "memberships":       "Memberships",
        "materials":         "Materials",
        "subjects":          "Subjects",
        "units":             "Units",
        "guardian_relations": "GuardianRelations",
    }
    
    if camel, ok := mapping[table]; ok {
        return camel
    }
    return table
}
```

### Criterios de Éxito Sprint 2
- [ ] Genera database.go con struct MockDatabase
- [ ] Genera users_table.go con FindByID y List
- [ ] Genera load_data.go con LoadAllData()
- [ ] Todo el código compila sin errores
- [ ] gofmt aplicado a todos los archivos

---

## Sprint 3: Estandarización api-administracion (Semanas 5-7)

### Objetivo
Aplicar dataset generado a api-administracion y estandarizar configuración.

### Ubicación de Trabajo
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/
```

### Entregables

#### 3.1 Generar Dataset
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator \
  --testing ../../postgres/migrations/testing \
  --output ../../api-administracion/internal/infrastructure/persistence/mock/dataset

# Archivos generados:
# - mock/dataset/database.go
# - mock/dataset/users_table.go
# - mock/dataset/schools_table.go
# - mock/dataset/academic_units_table.go
# - mock/dataset/memberships_table.go
# - mock/dataset/load_data.go
```

#### 3.2 Actualizar Repository Mock

**Archivo:** `internal/infrastructure/persistence/mock/repository/user_repository_mock.go`

**Antes (borrar):**
```go
// TODO: Borrar todo el contenido actual
```

**Después (nuevo):**
```go
package repository

import (
    "context"
    "github.com/EduGoGroup/edugo-api-administracion/internal/domain/repository"
    "github.com/EduGoGroup/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset"
    "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
    "github.com/EduGoGroup/edugo-shared/common/errors"
    "github.com/google/uuid"
)

type mockUserRepository struct{}

func NewMockUserRepository() repository.UserRepository {
    return &mockUserRepository{}
}

func (r *mockUserRepository) FindByID(ctx context.Context, id uuid.UUID) (*entities.User, error) {
    if user := dataset.DB.Users.FindByID(id); user != nil {
        return user, nil
    }
    return nil, errors.NewNotFoundError("user not found")
}

func (r *mockUserRepository) FindByEmail(ctx context.Context, email valueobject.Email) (*entities.User, error) {
    // Scan O(n) - acceptable para mock
    for _, user := range dataset.DB.Users.List() {
        if user.Email == email.String() {
            return user, nil
        }
    }
    return nil, errors.NewNotFoundError("user not found")
}

func (r *mockUserRepository) List(ctx context.Context) ([]*entities.User, error) {
    return dataset.DB.Users.List(), nil
}

// Escrituras no soportadas
func (r *mockUserRepository) Create(ctx context.Context, user *entities.User) error {
    return errors.NewNotImplementedError("CREATE not supported in mock mode - use real API")
}

func (r *mockUserRepository) Update(ctx context.Context, user *entities.User) error {
    return errors.NewNotImplementedError("UPDATE not supported in mock mode - use real API")
}

func (r *mockUserRepository) Delete(ctx context.Context, id uuid.UUID) error {
    return errors.NewNotImplementedError("DELETE not supported in mock mode - use real API")
}
```

#### 3.3 Estandarizar Configuración

**Archivo:** `internal/config/loader.go`

Agregar DESPUÉS de línea 130 (donde están otros BindEnv):
```go
// Binding para variable de mock repositories
_ = v.BindEnv("database.use_mock_repositories", "USE_MOCK_REPOSITORIES")
```

**Archivo:** `.zed/debug.json`

Reemplazar variable en configuración mock:
```json
{
  "label": "Go: Debug main (MOCK - Sin Docker)",
  "env": {
    "USE_MOCK_REPOSITORIES": "true",
    "APP_ENV": "local"
  }
}
```

#### 3.4 Borrar Archivos Antiguos (Hardcoded)

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Borrar datos hardcodeados antiguos
rm -rf internal/infrastructure/persistence/mock/data/

# Ya no se usan, ahora todo está en dataset/
```

#### 3.5 Actualizar Factory

**Archivo:** `internal/container/factory.go`

No requiere cambios (ya usa NewMockUserRepository correctamente).

### Pruebas Sprint 3

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# 1. Compilar
make build

# 2. Ejecutar con mocks
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
API_PID=$!
sleep 3

# 3. Probar health
curl http://localhost:8081/health

# Esperado:
# {"service":"edugo-api-admin","status":"healthy"}

# 4. Probar login
curl -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}'

# Esperado: access_token generado

# 5. Probar listar escuelas
TOKEN="..." # del paso anterior
curl http://localhost:8081/v1/schools \
  -H "Authorization: Bearer $TOKEN"

# Esperado: Array con 3 escuelas

# 6. Detener API
kill $API_PID
```

### Criterios de Éxito Sprint 3
- [ ] Compilación exitosa sin errores
- [ ] Health check retorna 200
- [ ] Login funciona con datos de testing
- [ ] Lista escuelas retorna 3 items
- [ ] Variable USE_MOCK_REPOSITORIES funciona
- [ ] Sin archivos hardcodeados antiguos

---

## Sprint 4: Estandarización api-mobile (Semanas 8-10)

### Objetivo
Aplicar mismo approach a api-mobile.

### Ubicación de Trabajo
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/
```

### Entregables

#### 4.1 Generar Dataset
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator \
  --testing ../../postgres/migrations/testing \
  --output ../../api-mobile/internal/infrastructure/persistence/mock/dataset
```

#### 4.2 Actualizar Repository Mock

**Archivo:** `internal/infrastructure/persistence/mock/postgres/user_repository_mock.go`

```go
package postgres

import (
    "context"
    "github.com/EduGoGroup/edugo-api-mobile/internal/domain/repository"
    "github.com/EduGoGroup/edugo-api-mobile/internal/infrastructure/persistence/mock/dataset"
    "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
    "github.com/EduGoGroup/edugo-shared/common/errors"
    "github.com/google/uuid"
)

type mockUserRepository struct{}

func NewMockUserRepository() repository.UserRepository {
    return &mockUserRepository{}
}

func (r *mockUserRepository) FindByID(ctx context.Context, id valueobject.UserID) (*entities.User, error) {
    if user := dataset.DB.Users.FindByID(id.UUID()); user != nil {
        return user, nil
    }
    return nil, errors.NewNotFoundError("user not found")
}

// Similar a api-administracion...
```

#### 4.3 Implementar MaterialRepository Mock (NUEVO)

**Archivo:** `internal/infrastructure/persistence/mock/postgres/material_repository_mock.go`

**Antes:** Stub vacío

**Después:**
```go
package postgres

import (
    "context"
    "github.com/EduGoGroup/edugo-api-mobile/internal/domain/repository"
    "github.com/EduGoGroup/edugo-api-mobile/internal/infrastructure/persistence/mock/dataset"
    "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
    "github.com/EduGoGroup/edugo-shared/common/errors"
    "github.com/google/uuid"
)

type mockMaterialRepository struct{}

func NewMockMaterialRepository() repository.MaterialRepository {
    return &mockMaterialRepository{}
}

func (r *mockMaterialRepository) FindByID(ctx context.Context, id valueobject.MaterialID) (*entities.Material, error) {
    if material := dataset.DB.Materials.FindByID(id.UUID()); material != nil {
        return material, nil
    }
    return nil, errors.NewNotFoundError("material not found")
}

func (r *mockMaterialRepository) List(ctx context.Context, filters repository.ListFilters) ([]*entities.Material, error) {
    return dataset.DB.Materials.List(), nil
}

// Escrituras no soportadas
func (r *mockMaterialRepository) Create(ctx context.Context, material *entities.Material) error {
    return errors.NewNotImplementedError("CREATE not supported in mock mode")
}

// ... más métodos
```

#### 4.4 Estandarizar Configuración

**Archivo:** `internal/config/config.go`

Agregar binding (si no existe):
```go
_ = v.BindEnv("development.use_mock_repositories", "USE_MOCK_REPOSITORIES")
```

**Archivo:** `.zed/debug.json`

Cambiar variable:
```json
{
  "label": "Go: Debug main (MOCK - Sin Docker)",
  "env": {
    "USE_MOCK_REPOSITORIES": "true",
    "APP_ENV": "local"
  }
}
```

#### 4.5 Borrar Stubs Antiguos

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Borrar stubs vacíos
rm -f internal/infrastructure/persistence/mock/postgres/stubs.go

# Borrar fixtures antiguas
rm -rf internal/infrastructure/persistence/mock/fixtures/
```

### Pruebas Sprint 4

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# 1. Compilar
make build

# 2. Levantar api-admin primero (para obtener token)
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
ADMIN_PID=$!
sleep 3

# 3. Levantar api-mobile
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-mobile &
MOBILE_PID=$!
sleep 3

# 4. Obtener token
TOKEN=$(curl -s -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}' \
  | jq -r '.access_token')

# 5. Probar health api-mobile
curl http://localhost:9091/health

# 6. Probar listar materiales (antes retornaba [])
curl http://localhost:9091/v1/materials \
  -H "Authorization: Bearer $TOKEN"

# Esperado: Array con 3 materiales (de 005_demo_materials.sql)

# 7. Detener APIs
kill $ADMIN_PID $MOBILE_PID
```

### Criterios de Éxito Sprint 4
- [ ] api-mobile compila sin errores
- [ ] Health check retorna 200
- [ ] Lista materiales retorna datos (NO array vacío)
- [ ] Variable USE_MOCK_REPOSITORIES funciona
- [ ] Sin stubs.go antiguo

---

## Sprint 5: Automatización y Documentación (Semanas 11-12)

### Objetivo
Automatizar generación y documentar sistema completo.

### Entregables

#### 5.1 Makefile para Generación

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/Makefile`

Agregar target:
```makefile
.PHONY: generate-mocks
generate-mocks:
	@echo "🔨 Generando datos mock desde migraciones..."
	cd tools/mock-generator && \
	go build -o bin/mock-generator cmd/main.go && \
	./bin/mock-generator \
	  --testing ../../postgres/migrations/testing \
	  --output-admin ../../api-administracion/internal/infrastructure/persistence/mock/dataset \
	  --output-mobile ../../api-mobile/internal/infrastructure/persistence/mock/dataset
	@echo "✅ Mocks generados en ambas APIs"
```

#### 5.2 GitHub Actions (CI/CD)

**Archivo:** `.github/workflows/generate-mocks.yml`

```yaml
name: Generate Mock Data

on:
  push:
    paths:
      - 'postgres/migrations/testing/*.sql'

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      
      - name: Generate mocks
        run: make generate-mocks
      
      - name: Commit generated code
        run: |
          git config user.name "Mock Generator Bot"
          git config user.email "bot@edugo.com"
          git add api-administracion/internal/infrastructure/persistence/mock/dataset/
          git add api-mobile/internal/infrastructure/persistence/mock/dataset/
          git diff --quiet && git diff --staged --quiet || git commit -m "chore: regenerate mock data"
          git push
```

#### 5.3 Documentación

**Archivo:** `MOCK_SYSTEM_GUIDE.md`

```markdown
# Guía: Sistema de Datos Mock

## Para Desarrolladores Frontend

### Uso Básico

1. Levantar API con mocks:
   ```bash
   USE_MOCK_REPOSITORIES=true make run
   ```

2. Datos disponibles:
   - 8 usuarios (admin@edugo.test, password: edugo2024)
   - 3 escuelas
   - 5 unidades académicas
   - 12 memberships
   - 3 materiales

3. Todas las passwords: `edugo2024`

### Agregar Nuevos Datos

1. Editar SQL:
   ```bash
   vim postgres/migrations/testing/001_demo_users.sql
   # Agregar: ('new-uuid', 'new@edugo.test', ...)
   ```

2. Regenerar mocks:
   ```bash
   make generate-mocks
   ```

3. Recompilar API:
   ```bash
   make build
   ```

4. ¡Nuevo usuario disponible!

## Para Desarrolladores Backend

### Agregar Nuevo Repository Mock

1. El dataset ya tiene los datos (generado automáticamente)

2. Crear repository mock:
   ```go
   func NewMockXxxRepository() repository.XxxRepository {
       return &mockXxxRepository{}
   }
   
   func (r *mockXxxRepository) FindByID(id) (*entities.Xxx, error) {
       return dataset.DB.Xxxs.FindByID(id), nil
   }
   ```

3. Done. El dataset hace el trabajo pesado.

## Limitaciones

- Solo READ operations
- WRITE operations retornan error "use real API"
- Performance O(n) en búsquedas secundarias (acceptable con ~10 registros)

## Troubleshooting

**Problema:** Compilación falla con "dataset not found"
**Solución:** Ejecuta `make generate-mocks`

**Problema:** Datos desactualizados
**Solución:** Recompila la API (`make build`)

**Problema:** Login falla
**Solución:** Verifica que estés usando password "edugo2024"
```

### Criterios de Éxito Sprint 5
- [ ] `make generate-mocks` funciona
- [ ] GitHub Actions genera mocks automáticamente
- [ ] Documentación completa y clara
- [ ] Tests de integración pasan

---

## Checklist de Validación Final

### ✅ Validaciones Técnicas

- [ ] Parser compila y ejecuta sin errores
- [ ] Genera 5 archivos *_table.go
- [ ] Genera database.go con singleton
- [ ] Genera load_data.go con todos los datos

### ✅ Validaciones api-administracion

- [ ] Compilación exitosa
- [ ] Variable USE_MOCK_REPOSITORIES=true funciona
- [ ] Login retorna token
- [ ] Lista escuelas retorna 3 items
- [ ] Sin archivos hardcodeados antiguos

### ✅ Validaciones api-mobile

- [ ] Compilación exitosa
- [ ] Variable USE_MOCK_REPOSITORIES=true funciona
- [ ] Lista materiales retorna 3 items (NO vacío)
- [ ] Sin stubs.go antiguo

### ✅ Validaciones de Estandarización

- [ ] Ambas APIs usan misma variable: USE_MOCK_REPOSITORIES
- [ ] Ambas APIs usan mismo dataset generado
- [ ] Estructura de carpetas idéntica
- [ ] Documentación unificada

---

## Resumen de Comandos (Ejecución Desatendida)

```bash
# Sprint 1: Parser
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
go build -o bin/mock-generator cmd/main.go
./bin/mock-generator --testing ../../postgres/migrations/testing

# Sprint 2: Generador
# (agregado al parser en Sprint 1)

# Sprint 3: api-administracion
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
make generate-mocks
cd ../edugo-api-administracion
make build
USE_MOCK_REPOSITORIES=true make run

# Sprint 4: api-mobile
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
make build
USE_MOCK_REPOSITORIES=true make run

# Sprint 5: Automatización
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
make generate-mocks
git add .
git commit -m "feat: implementar sistema de dataset mock"
git push
```

---

**Próximo Documento:** Ver ESPECIFICACIONES-TECNICAS.md para detalles de implementación.
