# Checklist de Ejecución: Implementación Paso a Paso

**Propósito:** Validar cada paso durante ejecución desatendida

---

## Pre-requisitos

### ✅ Verificar Entorno

```bash
# Go instalado
go version  # ≥ 1.21

# Directorios existen
ls /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
ls /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
ls /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Git configurado
git config --global user.name
git config --global user.email
```

**Validación:**
- [ ] Go version ≥ 1.21
- [ ] 3 directorios existen
- [ ] Git configurado

---

## Sprint 1: Parser SQL Básico

### Paso 1.1: Crear Estructura

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
mkdir -p tools/mock-generator/{cmd,pkg/{parser,generator,types}}
```

**Validación:**
- [ ] Carpeta `tools/mock-generator` creada
- [ ] Subcarpetas `cmd`, `pkg/parser`, `pkg/generator`, `pkg/types` existen

### Paso 1.2: Crear go.mod

```bash
cd tools/mock-generator
cat > go.mod << 'EOF'
module github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator

go 1.21

require (
    github.com/pingcap/tidb/parser v0.0.0-20231130042310-925c364b3cf3
    github.com/spf13/cobra v1.8.0
    github.com/google/uuid v1.3.0
)
EOF

go mod tidy
```

**Validación:**
- [ ] Archivo `go.mod` existe
- [ ] Archivo `go.sum` generado
- [ ] Sin errores en `go mod tidy`

### Paso 1.3: Copiar Código del Plan

Copiar código de `02-PLAN-SPRINTS-DETALLADO.md` sección Sprint 1:
- [ ] `cmd/main.go`
- [ ] `pkg/parser/sql_parser.go`
- [ ] `pkg/types/mappings.go`

**Validación:**
- [ ] 3 archivos creados
- [ ] Sin errores de sintaxis (editor)

### Paso 1.4: Compilar Parser

```bash
go build -o bin/mock-generator cmd/main.go
```

**Validación:**
- [ ] Binario `bin/mock-generator` creado
- [ ] Tamaño > 5MB
- [ ] Ejecutable: `./bin/mock-generator --help`

### Paso 1.5: Probar Parser

```bash
./bin/mock-generator --testing ../../postgres/migrations/testing
```

**Salida Esperada:**
```
🔨 Generando dataset desde migraciones...
✅ Parseados 5 archivos SQL
   - users: 8 registros
   - schools: 3 registros
   - academic_units: 5 registros
   - memberships: 12 registros
   - materials: 3 registros
```

**Validación:**
- [ ] Sin errores
- [ ] Muestra 5 archivos parseados
- [ ] users: 8 registros
- [ ] schools: 3 registros

---

## Sprint 2: Generador de Dataset

### Paso 2.1: Agregar Generator

Copiar código de plan Sprint 2:
- [ ] `pkg/generator/dataset_generator.go`
- [ ] `pkg/generator/table_generator.go`
- [ ] `pkg/generator/loader_generator.go`

### Paso 2.2: Actualizar main.go

Agregar lógica de generación (ver plan Sprint 2).

**Validación:**
- [ ] Código compila: `go build -o bin/mock-generator cmd/main.go`

### Paso 2.3: Generar Dataset de Prueba

```bash
./bin/mock-generator \
  --testing ../../postgres/migrations/testing \
  --output /tmp/dataset-test
```

**Validación:**
- [ ] Carpeta `/tmp/dataset-test` creada
- [ ] 6 archivos generados:
  - [ ] database.go
  - [ ] users_table.go
  - [ ] schools_table.go
  - [ ] academic_units_table.go
  - [ ] memberships_table.go
  - [ ] load_data.go

### Paso 2.4: Verificar Código Generado

```bash
cd /tmp/dataset-test
go mod init test
cat > go.mod << 'EOF'
module test
go 1.21
require github.com/EduGoGroup/edugo-infrastructure v0.0.0
require github.com/google/uuid v1.3.0
replace github.com/EduGoGroup/edugo-infrastructure => /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
EOF
go build .
```

**Validación:**
- [ ] Compilación exitosa
- [ ] Sin errores de imports

---

## Sprint 3: api-administracion

### Paso 3.1: Generar Dataset

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator \
  --testing ../../postgres/migrations/testing \
  --output ../../api-administracion/internal/infrastructure/persistence/mock/dataset
```

**Validación:**
- [ ] 6 archivos en `api-administracion/.../mock/dataset/`

### Paso 3.2: Backup Archivos Antiguos

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Backup
mv internal/infrastructure/persistence/mock/data internal/infrastructure/persistence/mock/data.backup
```

**Validación:**
- [ ] Carpeta `data.backup` existe
- [ ] Carpeta `data` original ya no existe

### Paso 3.3: Actualizar user_repository_mock.go

Reemplazar contenido con código del plan Sprint 3.

**Validación:**
- [ ] Archivo actualizado
- [ ] Imports correctos
- [ ] Usa `dataset.DB.Users`

### Paso 3.4: Actualizar Configuración

**Archivo:** `internal/config/loader.go`

Agregar línea (después de otros BindEnv):
```go
_ = v.BindEnv("database.use_mock_repositories", "USE_MOCK_REPOSITORIES")
```

**Validación:**
- [ ] Línea agregada
- [ ] Sin duplicados

**Archivo:** `.zed/debug.json`

Cambiar variable:
```json
"USE_MOCK_REPOSITORIES": "true"
```

**Validación:**
- [ ] Variable corregida

### Paso 3.5: Compilar api-administracion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
make build
```

**Validación:**
- [ ] Compilación exitosa
- [ ] Binario `bin/api-administracion` existe

### Paso 3.6: Probar con Mocks

```bash
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
API_PID=$!
sleep 3

# Health
curl -s http://localhost:8081/health | jq .

# Login
curl -s -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}' \
  | jq .access_token

# Schools (guardar token primero)
TOKEN="eyJ..."
curl -s http://localhost:8081/v1/schools \
  -H "Authorization: Bearer $TOKEN" \
  | jq '. | length'

# Cleanup
kill $API_PID
```

**Validación:**
- [ ] Health retorna `{"status":"healthy"}`
- [ ] Login retorna access_token
- [ ] Schools retorna `3`

---

## Sprint 4: api-mobile

### Paso 4.1: Generar Dataset

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator \
  --testing ../../postgres/migrations/testing \
  --output ../../api-mobile/internal/infrastructure/persistence/mock/dataset
```

**Validación:**
- [ ] 6 archivos en `api-mobile/.../mock/dataset/`

### Paso 4.2: Borrar Stubs Antiguos

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Backup
mv internal/infrastructure/persistence/mock/fixtures internal/infrastructure/persistence/mock/fixtures.backup
rm -f internal/infrastructure/persistence/mock/postgres/stubs.go
```

**Validación:**
- [ ] `fixtures.backup` existe
- [ ] `stubs.go` eliminado

### Paso 4.3: Actualizar Repositories

Actualizar archivos con código del plan Sprint 4:
- [ ] `user_repository_mock.go`
- [ ] `material_repository_mock.go`

**Validación:**
- [ ] Usan `dataset.DB`
- [ ] Métodos de escritura retornan error

### Paso 4.4: Actualizar Configuración

Similar a api-administracion (paso 3.4).

**Validación:**
- [ ] BindEnv agregado
- [ ] `.zed/debug.json` actualizado

### Paso 4.5: Compilar api-mobile

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
make build
```

**Validación:**
- [ ] Compilación exitosa
- [ ] Binario existe

### Paso 4.6: Probar con Mocks

```bash
# Terminal 1: api-admin
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &

# Terminal 2: api-mobile
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-mobile &
sleep 3

# Obtener token
TOKEN=$(curl -s -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}' \
  | jq -r '.access_token')

# Probar materials
curl -s http://localhost:9091/v1/materials \
  -H "Authorization: Bearer $TOKEN" \
  | jq '. | length'

# Cleanup
pkill api-administracion
pkill api-mobile
```

**Validación:**
- [ ] Materials retorna `3` (NO 0)
- [ ] Health retorna status ok

---

## Sprint 5: Automatización

### Paso 5.1: Crear Makefile Target

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/Makefile`

Agregar al final:
```makefile
.PHONY: generate-mocks
generate-mocks:
	@echo "🔨 Generando mocks..."
	cd tools/mock-generator && \
	./bin/mock-generator \
	  --testing ../../postgres/migrations/testing \
	  --output ../../api-administracion/internal/infrastructure/persistence/mock/dataset
	cd tools/mock-generator && \
	./bin/mock-generator \
	  --testing ../../postgres/migrations/testing \
	  --output ../../api-mobile/internal/infrastructure/persistence/mock/dataset
	@echo "✅ Mocks generados"
```

**Validación:**
- [ ] Target agregado
- [ ] `make generate-mocks` funciona

### Paso 5.2: Crear Documentación

Copiar `MOCK_SYSTEM_GUIDE.md` del plan.

**Validación:**
- [ ] Archivo creado
- [ ] Ejemplos claros

### Paso 5.3: Commit Final

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
git add tools/mock-generator
git add Makefile
git commit -m "feat: implementar generador de dataset mock"
git push

cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
git add internal/infrastructure/persistence/mock/dataset
git add internal/config/loader.go
git add .zed/debug.json
git commit -m "feat: migrar a dataset mock generado"
git push

cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
git add internal/infrastructure/persistence/mock/dataset
git commit -m "feat: migrar a dataset mock generado"
git push
```

**Validación:**
- [ ] 3 commits realizados
- [ ] 3 push exitosos

---

## Validación Final Completa

### Tests de Integración

```bash
# Script de test completo
cat > /tmp/test-mocks.sh << 'TESTEOF'
#!/bin/bash
set -e

echo "1. Compilar api-admin..."
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
make build

echo "2. Compilar api-mobile..."
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
make build

echo "3. Levantar api-admin..."
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
ADMIN_PID=$!
sleep 3

echo "4. Levantar api-mobile..."
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-mobile &
MOBILE_PID=$!
sleep 3

echo "5. Test health api-admin..."
curl -f http://localhost:8081/health

echo "6. Test health api-mobile..."
curl -f http://localhost:9091/health

echo "7. Test login..."
TOKEN=$(curl -s -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}' \
  | jq -r '.access_token')

echo "8. Test schools..."
SCHOOLS=$(curl -s http://localhost:8081/v1/schools \
  -H "Authorization: Bearer $TOKEN" \
  | jq '. | length')
[ "$SCHOOLS" == "3" ] || (echo "ERROR: Expected 3 schools, got $SCHOOLS" && exit 1)

echo "9. Test materials..."
MATERIALS=$(curl -s http://localhost:9091/v1/materials \
  -H "Authorization: Bearer $TOKEN" \
  | jq '. | length')
[ "$MATERIALS" == "3" ] || (echo "ERROR: Expected 3 materials, got $MATERIALS" && exit 1)

echo "10. Cleanup..."
kill $ADMIN_PID $MOBILE_PID

echo "✅ ALL TESTS PASSED"
TESTEOF

chmod +x /tmp/test-mocks.sh
/tmp/test-mocks.sh
```

**Validación Final:**
- [ ] Script ejecuta sin errores
- [ ] Mensaje "✅ ALL TESTS PASSED"

---

## Checklist de Estado Final

### Archivos Generados
- [ ] `edugo-infrastructure/tools/mock-generator/bin/mock-generator`
- [ ] `api-administracion/.../mock/dataset/database.go`
- [ ] `api-administracion/.../mock/dataset/users_table.go`
- [ ] `api-mobile/.../mock/dataset/database.go`
- [ ] `api-mobile/.../mock/dataset/users_table.go`

### Configuración
- [ ] api-admin usa `USE_MOCK_REPOSITORIES`
- [ ] api-mobile usa `USE_MOCK_REPOSITORIES`
- [ ] `.zed/debug.json` actualizado en ambas

### Funcionalidad
- [ ] Login funciona con datos mock
- [ ] Lista de escuelas retorna 3 items
- [ ] Lista de materiales retorna 3 items (NO vacío)

### Limpieza
- [ ] Sin archivos hardcodeados antiguos
- [ ] Sin stubs vacíos
- [ ] Código formateado (gofmt)

---

**Todo completado:** Sistema de dataset mock implementado y funcionando en ambas APIs.
