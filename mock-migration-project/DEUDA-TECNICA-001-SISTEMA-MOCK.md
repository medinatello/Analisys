# Deuda Técnica #001: Unificar Sistema de Datos Mock

**Fecha Detección:** 30 de Noviembre, 2025  
**Prioridad:** 🔴 ALTA (resolver inmediatamente después de validar pruebas)  
**Proyecto Afectado:** edugo-api-administracion  
**Sprint Objetivo:** Posterior a validación de mock-migration

---

## Descripción del Problema

Existen **DOS sistemas de datos mock** en el proyecto, creando inconsistencia y confusión:

### Sistema 1: `data/` (DEPRECADO - A ELIMINAR)
**Ubicación:** `internal/infrastructure/persistence/mock/data/`

```
data/
├── academic_units.go
├── guardian_relations.go
├── materials.go
├── memberships.go
├── schools.go
├── subjects.go
├── units.go
└── users.go
```

- Archivos escritos manualmente
- Datos hardcodeados con todos los campos correctos
- **YA NO DEBERÍA USARSE** - Es código legacy del proceso anterior

### Sistema 2: `dataset/` (ACTUAL - A MANTENER)
**Ubicación:** `internal/infrastructure/persistence/mock/dataset/`

```
dataset/
├── database.go
├── helpers.go
├── load_all.go
├── academic_units_loader.go + academic_units_table.go
├── materials_loader.go + materials_table.go
├── memberships_loader.go + memberships_table.go
├── schools_loader.go + schools_table.go
└── users_loader.go + users_table.go
```

- Archivos generados automáticamente por `tools/generate_dataset/`
- Datos extraídos de SQL migrations
- **ES EL SISTEMA OFICIAL** del proyecto mock-migration

---

## Estado Actual de Repositories

| Repository | Importa | Estado |
|------------|---------|--------|
| `user_repository_mock.go` | `dataset/` | ✅ Correcto |
| `school_repository_mock.go` | `dataset/` | ✅ Correcto |
| `academic_unit_repository_mock.go` | `dataset/` | ✅ Correcto |
| `unit_membership_repository_mock.go` | `dataset/` | ✅ Correcto |
| `material_repository_mock.go` | `dataset/` | ✅ Correcto |
| `subject_repository_mock.go` | `data/` | ❌ DEPRECADO |
| `unit_repository_mock.go` | `data/` | ❌ DEPRECADO |
| `stats_repository_mock.go` | `data/` | ❌ DEPRECADO |
| `guardian_repository_mock.go` | `data/` | ❌ DEPRECADO |

---

## Acciones Requeridas

### Fase 1: Completar Dataset Generado

El generador `tools/generate_dataset/` debe generar loaders para:

- [ ] `subjects_loader.go` + `subjects_table.go`
- [ ] `units_loader.go` + `units_table.go` (nota: diferente de academic_units)
- [ ] `guardian_relations_loader.go` + `guardian_relations_table.go`

### Fase 2: Corregir Generador de Users

El `users_loader.go` generado debe incluir:

- [ ] Campo `IsActive: true`
- [ ] Campo `EmailVerified: true`
- [ ] Campo `PasswordHash` con hash bcrypt válido (no placeholder)

**Archivo a modificar:** `tools/generate_dataset/main.go` o templates asociados.

### Fase 3: Migrar Repositories a Dataset

Actualizar los 4 repositories que aún usan `data/`:

```go
// ANTES (deprecado)
import mockData "github.com/EduGoGroup/edugo-api-administracion/internal/infrastructure/persistence/mock/data"

// DESPUÉS (correcto)
import "github.com/EduGoGroup/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset"
```

**Archivos a modificar:**
- [ ] `subject_repository_mock.go`
- [ ] `unit_repository_mock.go`
- [ ] `stats_repository_mock.go`
- [ ] `guardian_repository_mock.go`

### Fase 4: Validar Tests de Integración

**⚠️ IMPORTANTE:** Antes de eliminar el código deprecado, verificar que los tests de integración no lo utilicen.

```bash
# Buscar referencias en tests de integración
grep -rn "mock/data" --include="*_test.go" .
grep -rn "mock/data" tests/ test/ integration/ e2e/ 2>/dev/null || true

# Buscar imports del paquete deprecado en cualquier test
grep -rn "persistence/mock/data" --include="*.go" . | grep -v "_mock.go"
```

**Acciones si se encuentran referencias en tests:**
1. Identificar qué entidades usan los tests
2. Verificar que `dataset/` tenga esos loaders generados
3. Actualizar imports en los tests
4. Ejecutar tests para confirmar funcionamiento

**Checklist de validación:**
- [ ] `grep` no retorna resultados en archivos `*_test.go`
- [ ] Tests de integración ejecutan sin errores: `go test ./... -tags=integration`
- [ ] No hay imports de `mock/data` fuera de los 4 repositories ya identificados

### Fase 5: Eliminar Sistema Deprecado

Una vez que:
1. ✅ Todos los repositories usen `dataset/`
2. ✅ Tests de integración validados (Fase 4)

Proceder a eliminar:

```bash
rm -rf internal/infrastructure/persistence/mock/data/
```

**Archivos a eliminar:**
- [ ] `data/academic_units.go`
- [ ] `data/guardian_relations.go`
- [ ] `data/materials.go`
- [ ] `data/memberships.go`
- [ ] `data/schools.go`
- [ ] `data/subjects.go`
- [ ] `data/units.go`
- [ ] `data/users.go`

### Fase 6: Verificar No Hay Referencias

```bash
grep -rn "mock/data" --include="*.go" .
# Debe retornar vacío (excepto comentarios o generate_dataset)
```

---

## Criterios de Aceptación

1. ✅ Carpeta `data/` eliminada completamente
2. ✅ Todos los repositories importan de `dataset/`
3. ✅ `go build ./...` compila sin errores
4. ✅ Las 4 pruebas de mock pasan correctamente
5. ✅ El generador produce datos completos (IsActive, EmailVerified, PasswordHash)
6. ✅ Tests de integración no referencian código deprecado
7. ✅ `go test ./... -tags=integration` ejecuta sin errores

---

## Notas Técnicas

### ¿Por qué existían dos sistemas?

El sistema `data/` fue creado manualmente durante el desarrollo inicial. Luego se creó el sistema `dataset/` con generación automática desde SQL migrations para tener una fuente única de verdad.

La migración quedó incompleta, dejando algunos repositories usando el sistema antiguo.

### ¿Por qué no se detectó antes?

Los repositories que usan `data/` (subject, unit, stats, guardian) probablemente no se probaron exhaustivamente, o funcionaban con los datos manuales que sí tenían todos los campos.

El problema se manifestó con `user_repository_mock.go` porque:
1. Ya usa `dataset/`
2. El `users_loader.go` generado no tiene `IsActive`
3. El flujo de login valida `IsActive`

---

## Relación con mock-migration-project

Esta deuda técnica está directamente relacionada con el proyecto de migración de mocks. 

**Recomendación:** Resolver esta deuda como parte del Sprint 0 de api-administracion, antes de continuar con los sprints de implementación.

---

**Creado por:** Claude Code  
**Fecha límite sugerida:** Inmediatamente después de validar pruebas actuales
