# Errores Encontrados - Análisis Mock API Mobile

**Fecha:** 30 de Noviembre de 2025  
**API:** edugo-api-mobile  
**Ubicación:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile`

---

## Error 1: Repositorios Mock Son Solo Stubs Vacíos

### Descripción del Error
Los repositorios mock (10 de 11) están implementados como stubs que retornan valores vacíos o nil, sin datos de prueba precargados. Esto hace que la API arranque correctamente en modo mock, pero no provea datos útiles para desarrollo frontend.

### Severidad
**CRÍTICA** - Bloquea desarrollo frontend

### Archivos Involucrados

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/infrastructure/persistence/mock/postgres/stubs.go`

**Líneas relevantes (ejemplos):**
```go
// Material Repository Stub (líneas 15-37)
type mockMaterialRepository struct{}

func NewMockMaterialRepository() repository.MaterialRepository { 
    return &mockMaterialRepository{} 
}

func (r *mockMaterialRepository) List(ctx context.Context, filters repository.ListFilters) ([]*pgentities.Material, error) {
    return []*pgentities.Material{}, nil  // ❌ Retorna array vacío
}

func (r *mockMaterialRepository) FindByID(ctx context.Context, id valueobject.MaterialID) (*pgentities.Material, error) {
    return nil, nil  // ❌ Retorna nil
}

// Progress Repository Stub (líneas 45-67)
type mockProgressRepository struct{}

func (r *mockProgressRepository) FindByUser(ctx context.Context, userID valueobject.UserID) ([]*pgentities.Progress, error) {
    return []*pgentities.Progress{}, nil  // ❌ Retorna array vacío
}

// RefreshToken Repository Stub (líneas 73-87)
func (r *mockRefreshTokenRepository) FindByTokenHash(ctx context.Context, tokenHash string) (*repository.RefreshTokenData, error) {
    return nil, nil  // ❌ Retorna nil
}
```

### Reproducción
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
export DEVELOPMENT_USE_MOCK_REPOSITORIES=true
make run
```

**Luego hacer request (con token de api-admin):**
```bash
# Obtener token de api-admin primero
TOKEN=$(curl -s -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@edugo.test", "password": "edugo2024"}' | jq -r '.access_token')

# Request a api-mobile
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/v1/materials | jq .
```

### Output Actual
```json
[]  // ❌ Array vacío, sin datos mock
```

### Output Esperado
```json
[
  {
    "id": "mat-001",
    "title": "Introducción a Matemáticas",
    "description": "Material de matemáticas básicas",
    "type": "video",
    "author_id": "22222222-2222-2222-2222-222222222222",
    "status": "published",
    "created_at": "2025-01-01T00:00:00Z"
  },
  ...
]
```

### Análisis de Causa Raíz (según contexto del usuario)

#### A) ¿Cómo se desencadenó el error?

**A.1) ¿Fue por código ingresado en la tarea?**
**SÍ**. La tarea de implementar mock repositories se completó **parcialmente**. Se creó la estructura (stubs) pero no se implementaron los datos mock ni la lógica.

**Evidencia:**
- Se creó el archivo `stubs.go` con todos los métodos requeridos
- Se implementó el factory pattern correctamente
- PERO: Los métodos solo retornan valores vacíos/nil
- Solo UserRepository tiene implementación completa con datos

**A.2) ¿Fue por un cambio de configuración?**
**NO**. La configuración funciona correctamente. El problema es la falta de implementación.

**A.3) ¿El error proviene de código no agregado en la tarea?**
**SÍ**. La tarea requería:
1. ✅ Crear factory pattern
2. ✅ Crear stubs de repositorios
3. ❌ Implementar fixtures con datos mock (NO COMPLETADO)
4. ❌ Implementar lógica real en repositorios (NO COMPLETADO)

#### B) Análisis de Implicaciones

**¿Qué implica agregar fixtures y lógica?**

**Opción 1: Implementar fixtures mínimos (Recomendado)**
```go
// fixtures/materials.go
func GetDefaultMaterials() map[string]*pgentities.Material {
    return map[string]*pgentities.Material{
        "mat-001": {
            ID: uuid.MustParse("mat-001..."),
            Title: "Introducción a Matemáticas",
            AuthorID: fixtures.TeacherID,
            Type: "video",
            Status: "published",
            ...
        },
        // 10-15 materiales más
    }
}
```

**Pros:**
- ✅ Frontend puede probar UI con datos realistas
- ✅ Flujos completos funcionan (crear, editar, listar)
- ✅ Consistente con api-administracion
- ✅ Facilita pruebas de integración

**Contras:**
- ⚠️ Requiere tiempo de implementación (4-8 horas)
- ⚠️ Más código a mantener

**Opción 2: Mantener stubs vacíos**
**NO RECOMENDADO** - No cumple el propósito de mock repositories.

**Opción 3: Usar datos de migración de edugo-infrastructure**
```go
// Cargar datos desde módulo de migración
import "github.com/EduGoGroup/edugo-infrastructure/migrations/data"

func GetDefaultMaterials() map[string]*pgentities.Material {
    return data.LoadMaterials() // Carga desde archivos JSON
}
```

**Pros:**
- ✅ Reutiliza datos existentes
- ✅ Dataset consistente entre proyectos
- ✅ Menos mantenimiento

**Contras:**
- ⚠️ Requiere módulo de migración actualizado
- ⚠️ Dependencia externa

**Recomendación:** **Opción 1** (fixtures mínimos) como solución inmediata, migrar a **Opción 3** en el futuro según plan-final/.

#### C) Intentos de Solución

**Intento 1: Verificar configuración (NO RESOLVIÓ)**
```bash
export DEVELOPMENT_USE_MOCK_REPOSITORIES=true
make run
# LOG: "usando mock repositories" ✅
# Pero endpoints retornan arrays vacíos ❌
```

**Resultado:** Configuración OK, pero repositorios sin datos.

**Intento 2: Revisar UserRepository (FUNCIONA)**
```bash
# UserRepository tiene datos mock
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/v1/users/me
# Retorna datos del usuario ✅
```

**Resultado:** Confirma que UserRepository funciona porque tiene fixtures.

**Intento 3: Comparar con api-administracion (REVELÓ EL PROBLEMA)**
- api-admin: 42 registros en 8 entidades
- api-mobile: 3 registros en 1 entidad
- Todos los demás repositorios: stubs vacíos

**Resultado:** Identificó que falta implementar fixtures.

---

## Error 2: Sin Integración con Módulo de Migraciones

### Descripción del Error
Los mock repositories de api-mobile no utilizan el módulo de migraciones de edugo-infrastructure, a diferencia del plan original que preveía cargar datos automáticamente desde archivos de migración.

### Severidad
**MEDIA** - No bloquea, pero genera duplicación de datos

### Archivos Involucrados

**Actual:**
```
internal/infrastructure/persistence/mock/fixtures/
└─> users.go  (datos hardcodeados)
```

**Esperado (según plan original):**
```
internal/infrastructure/persistence/mock/
├─> loader.go  // Carga datos desde edugo-infrastructure
└─> fixtures/  // Fallback si módulo no disponible
    └─> users.go
```

### Análisis de Causa Raíz

#### A) ¿Cómo se desencadenó?

**A.1) ¿Fue por código ingresado en la tarea?**
**SÍ**. Se optó por hardcodear datos en lugar de integrar con el módulo de migraciones.

**A.2) ¿Fue por un cambio de configuración?**
**NO**.

**A.3) ¿El error proviene de código no agregado en la tarea?**
**SÍ**. La integración con edugo-infrastructure/migrations no se implementó.

**Razón probable:** El módulo de migraciones no estaba listo al momento de implementar mocks, y se usó un approach temporal (hardcodear).

#### B) Implicaciones

**Problemas actuales:**
1. Datos duplicados entre proyectos
2. Inconsistencias entre api-admin y api-mobile
3. Mantenimiento manual de fixtures

**Solución futura:**
Referirse a `/Users/jhoanmedina/source/EduGo/Analisys/plan-final/` para plan de migración a dataset singleton.

---

## Error 3: Inconsistencia en Variable de Entorno vs api-administracion

### Descripción del Error
api-mobile usa `DEVELOPMENT_USE_MOCK_REPOSITORIES` mientras que api-administracion usa `EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES`. Esta inconsistencia dificulta scripts de desarrollo que manejan ambas APIs.

### Severidad
**BAJA** - No bloquea, pero genera confusión

### Comparación

| API | Variable | Prefijo |
|-----|----------|---------|
| api-administracion | EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES | EDUGO_ADMIN_ |
| api-mobile | DEVELOPMENT_USE_MOCK_REPOSITORIES | DEVELOPMENT_ |

### Análisis de Causa Raíz

#### A) ¿Cómo se desencadenó?

**A.3) ¿El error proviene de código no agregado en la tarea?**
**SÍ**. Las APIs se desarrollaron en sprints diferentes sin estandarización de nomenclatura.

#### B) Implicaciones

**Problema actual:**
Scripts de desarrollo deben configurar variables diferentes:
```bash
# Archivo: start-all-mocks.sh
export EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES=true  # api-admin
export DEVELOPMENT_USE_MOCK_REPOSITORIES=true           # api-mobile
make run-all
```

**Solución futura:**
Estandarizar a:
```bash
export USE_MOCK_REPOSITORIES=true  # Ambas APIs (con binding explícito)
```

O mantener prefijos pero con nombre consistente:
```bash
export EDUGO_ADMIN_USE_MOCK_REPOSITORIES=true
export EDUGO_MOBILE_USE_MOCK_REPOSITORIES=true
```

**Recomendación:** Dejar como está por ahora (funciona), estandarizar en refactor futuro.

---

## Error 4: Sin Thread-Safety en Repositorios Stub

### Descripción del Error
Los 10 repositorios implementados como stubs NO tienen protección de concurrencia (sync.RWMutex), a diferencia de UserRepository que sí la tiene.

### Severidad
**MEDIA** - No afecta ahora (stubs vacíos), pero será crítico al agregar datos

### Archivos Involucrados

**Con thread-safety (correcto):**
```go
// user_repository_mock.go
type mockUserRepository struct {
    users map[string]*pgentities.User
    mu    sync.RWMutex  // ✅ Protección de concurrencia
}
```

**Sin thread-safety (incorrecto):**
```go
// stubs.go
type mockMaterialRepository struct{}  // ❌ Sin mutex
```

### Análisis de Causa Raíz

#### A) ¿Cómo se desencadenó?

**A.1) ¿Fue por código ingresado en la tarea?**
**SÍ**. Los stubs se crearon sin considerar concurrencia porque solo retornan valores vacíos.

#### B) Implicaciones

**Riesgo al implementar datos:**
```go
// SIN protección (PELIGRO)
type mockMaterialRepository struct {
    materials map[string]*Material  // ❌ Race condition
}

func (r *mockMaterialRepository) List() []*Material {
    // ❌ Múltiples goroutines pueden leer/escribir simultáneamente
    return values(r.materials)
}
```

**Solución necesaria al agregar fixtures:**
```go
type mockMaterialRepository struct {
    materials map[string]*Material
    mu        sync.RWMutex  // ✅ Agregar protección
}

func (r *mockMaterialRepository) List() []*Material {
    r.mu.RLock()           // ✅ Lock de lectura
    defer r.mu.RUnlock()
    return copyAll(r.materials)
}
```

---

## Resumen de Errores y Soluciones

| # | Error | Severidad | Causa Raíz | Solución Propuesta | Impacto |
|---|-------|-----------|------------|-------------------|---------|
| 1 | Repositorios stubs vacíos | CRÍTICA | Fixtures no implementados | Implementar fixtures para 10 repos | Bloquea desarrollo frontend |
| 2 | Sin integración con migraciones | MEDIA | Módulo no disponible al implementar | Plan futuro en plan-final/ | Genera duplicación |
| 3 | Variable env inconsistente | BAJA | APIs desarrolladas independientemente | Estandarizar en refactor | Genera confusión |
| 4 | Sin thread-safety en stubs | MEDIA | Stubs vacíos no requieren mutex | Agregar mutex al implementar fixtures | Será crítico con datos |

---

## Verificación de las Soluciones

### Verificación Error 1 (Al implementar fixtures)

**Antes (FALLA):**
```bash
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v1/materials
[]  // ❌ Vacío
```

**Después de implementar fixtures (FUNCIONA):**
```bash
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v1/materials
[{"id": "mat-001", "title": "Introducción a Matemáticas", ...}, ...]  // ✅ Con datos
```

### Verificación Error 2 (Plan futuro)

**Actual:**
```go
// fixtures/materials.go (hardcoded)
func GetDefaultMaterials() map[string]*Material {
    return map[string]*Material{
        "mat-001": {...},  // ❌ Hardcoded
    }
}
```

**Futuro (con integración):**
```go
// loader.go
import "github.com/EduGoGroup/edugo-infrastructure/migrations/data"

func GetDefaultMaterials() map[string]*Material {
    return data.LoadMaterials()  // ✅ Desde módulo
}
```

### Verificación Error 4 (Al implementar fixtures)

**Agregar test de concurrencia:**
```go
// material_repository_mock_test.go
func TestMaterialRepository_Concurrent(t *testing.T) {
    repo := NewMockMaterialRepository()
    
    // 100 goroutines leyendo simultáneamente
    var wg sync.WaitGroup
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            _, _ = repo.List(context.Background(), filters)
        }()
    }
    wg.Wait()
    // ✅ No debe tener race conditions
}
```

**Ejecutar test con race detector:**
```bash
go test -race ./internal/infrastructure/persistence/mock/postgres/...
# ✅ Debe pasar sin warnings de race
```

---

## Conclusión

Los errores encontrados son principalmente de **implementación incompleta**, NO de diseño arquitectónico.

**Error crítico #1** (stubs vacíos) bloquea el desarrollo frontend y debe resolverse con prioridad alta.

**Errores #2, #3, #4** son de menor impacto y pueden abordarse en refactors futuros.

**Próximos pasos:**
1. Implementar fixtures para MaterialRepository, ProgressRepository (prioritarios)
2. Agregar thread-safety (sync.RWMutex) al implementar fixtures
3. Planificar migración a dataset singleton según plan-final/
