# Paso 2: Verificar Generador Existe y Funciona

**Duración estimada:** 10 minutos
**Prerequisitos:**
- ✅ Paso 1 completado (api-admin validado)

## Referencia a api-admin
📚 Equivalente a api-admin Sprint 0 completo
El generador fue creado en api-admin, ahora solo validamos que existe.

## Objetivo
Verificar que el generador edugo-mock-generator está disponible y funcional.

## Pasos de Ejecución

### 1. Verificar directorio del generador

```bash
ls -la /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/
```

**Output esperado:**
```
drwxr-xr-x   cmd/
drwxr-xr-x   pkg/
drwxr-xr-x   bin/
-rw-r--r--   go.mod
-rw-r--r--   go.sum
-rw-r--r--   README.md
```

### 2. Verificar binario compilado

```bash
ls -la /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/bin/
```

**Output esperado:**
```
-rwxr-xr-x  mock-generator
```

### 3. Probar generador con --help

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator --help
```

**Output esperado:**
```
Mock Dataset Generator for EduGo

Usage:
  mock-generator [flags]

Flags:
      --testing string   Directory with testing SQL files
      --output string    Output directory for generated files
  -h, --help            help for mock-generator
```

### 4. Ejecutar generador (test rápido)

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/tmp/test-dataset-api-mobile
```

**Output esperado:**
```
Parsing SQL files...
Found 5 files
Parsed users table: 8 rows
Parsed schools table: 3 rows
Parsed academic_units table: 5 rows
Parsed memberships table: 12 rows
Parsed materials table: 3 rows
Generating Go files...
✓ Generated database.go
✓ Generated users_table.go
✓ Generated schools_table.go
✓ Generated academic_units_table.go
✓ Generated memberships_table.go
✓ Generated materials_table.go
✓ Generated load_data.go
Done!
```

### 5. Verificar archivos generados

```bash
ls -la /tmp/test-dataset-api-mobile/
```

**Output esperado:**
```
-rw-r--r--  database.go
-rw-r--r--  users_table.go
-rw-r--r--  schools_table.go
-rw-r--r--  academic_units_table.go
-rw-r--r--  memberships_table.go
-rw-r--r--  materials_table.go
-rw-r--r--  load_data.go
```

## Validación

- [ ] Directorio del generador existe
- [ ] Binario mock-generator existe
- [ ] --help muestra ayuda correcta
- [ ] Generador ejecuta sin errores
- [ ] Se crean 7 archivos .go

## Si Falla

**Síntoma:** Directorio no existe
**Solución:** Completar api-admin Sprint 0

**Síntoma:** Binario no existe
**Solución:** Compilar generador con `make build` en tools/mock-generator

**Síntoma:** Error al ejecutar generador
**Solución:** Revisar logs, validar que SQL testing existe

## Siguiente Paso
→ [paso-03-verificar-dataset-admin.md]
