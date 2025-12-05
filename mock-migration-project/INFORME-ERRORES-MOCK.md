# Informe de Errores - Pruebas de Mock Repositories

**Fecha:** 30 de Noviembre, 2025  
**Estado:** ❌ BLOQUEADO - Errores en datos del dataset generado  
**Ejecutado por:** Claude Code  
**Ciclo:** 1

---

## Resumen Ejecutivo

Las pruebas de mock repositories detectaron dos errores críticos:

1. ✅ **CORREGIDO:** Variables de entorno no homologadas (USE_MOCK_REPOSITORIES)
2. ❌ **NUEVO:** Dataset generado no incluye campos obligatorios (IsActive, PasswordHash válido)

---

## Error Corregido en Ciclo 1

### Error #1: Variables de Entorno No Homologadas ✅ RESUELTO

**Solución aplicada:**
- API-Admin: Agregado `BindEnv` para `USE_MOCK_REPOSITORIES` (commit `062919a`)
- API-Mobile: Agregado `BindEnv` para `USE_MOCK_REPOSITORIES` (commit `6f0f507`)

**Verificación:**
```
INFO usando mock repositories  mock_enabled=true postgres_required=false
```

La variable `USE_MOCK_REPOSITORIES=true` ahora funciona correctamente en ambas APIs.

---

## Errores Nuevos Encontrados en Ciclo 1

### Error #2: Dataset Generado sin Campo IsActive ❌ BLOQUEANTE

**Ubicación:** 
- `internal/infrastructure/persistence/mock/dataset/users_loader.go`

**Problema:**
El archivo generado automáticamente NO incluye el campo `IsActive` en los usuarios:

```go
// CÓDIGO ACTUAL (generado) - INCORRECTO
DB.Users.Add(&entities.User{
    ID:           uuid.MustParse("a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"),
    Email:        "admin@edugo.test",
    PasswordHash: "$2a$10$YourHashHere",
    Role:         "admin",
    FirstName:    "Admin",
    LastName:     "Demo",
    CreatedAt:    time.Now(),
    UpdatedAt:    time.Now(),
    // FALTA: IsActive: true,
    // FALTA: EmailVerified: true,
})
```

**Consecuencia:**
- `IsActive` tiene valor por defecto `false` (valor cero de bool en Go)
- El login falla con error `"Usuario inactivo"` (código `USER_INACTIVE`)

**Comparación con datos manuales:**
El archivo manual `mock/data/users.go` SÍ incluye los campos:
```go
// CÓDIGO MANUAL - CORRECTO
AdminUserID: {
    ID:            AdminUserID,
    Email:         "admin@edugo.test",
    IsActive:      true,        // ← EXISTE
    EmailVerified: true,        // ← EXISTE
    ...
}
```

### Error #3: PasswordHash Placeholder ❌ BLOQUEANTE

**Ubicación:** 
- `internal/infrastructure/persistence/mock/dataset/users_loader.go`

**Problema:**
El hash de contraseña es un placeholder inválido:
```go
PasswordHash: "$2a$10$YourHashHere",  // NO ES UN HASH VÁLIDO
```

**Hash correcto esperado:**
```go
// Hash bcrypt válido para "Admin123!"
PasswordHash: "$2a$10$N9qo8uLOickgx2ZMRZoMye...",
```

**Consecuencia:**
Incluso si se corrige `IsActive`, la verificación de contraseña fallará porque el hash no es válido.

---

## Resultados de Pruebas

### Prueba 1: API-Admin con Mock
| Aspecto | Resultado |
|---------|-----------|
| API arranca | ✅ Sí |
| mock_enabled | ✅ true |
| Health check | ✅ OK |
| Login | ❌ FALLA - "Usuario inactivo" |
| GET /schools | ⏭️ No ejecutado (sin token) |

### Pruebas 2, 3, 4: No Ejecutadas
Bloqueadas por error de login en Prueba 1.

---

## Análisis de Causa Raíz

### ¿Por qué el generador no incluye IsActive?

Hay **DOS sistemas de datos mock** en conflicto:

1. **Sistema Manual** (`internal/infrastructure/persistence/mock/data/`)
   - Archivos escritos manualmente
   - Incluye todos los campos necesarios
   - **NO se está usando** actualmente

2. **Sistema Generado** (`internal/infrastructure/persistence/mock/dataset/`)
   - Archivos generados por `tools/generate_dataset/`
   - Generado desde SQL migrations
   - **FALTA** extraer campos como `IsActive`, `EmailVerified`
   - **ES el que se usa** actualmente

El `user_repository_mock.go` importa de `dataset`:
```go
import dataset "github.com/EduGoGroup/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset"

func NewMockUserRepository() repository.UserRepository {
    for _, user := range dataset.DB.Users.List() {  // ← USA dataset generado
        ...
    }
}
```

---

## Soluciones Propuestas

### Opción A: Corregir el Generador (Recomendada)

Modificar `tools/generate_dataset/` para que:
1. Extraiga el campo `is_active` de las SQL migrations
2. Extraiga el campo `email_verified` de las SQL migrations
3. Genere un hash bcrypt válido o use uno predefinido

**Pros:** Solución definitiva, los datos vienen de la fuente real (SQL)
**Cons:** Requiere modificar el generador

### Opción B: Corregir Manualmente users_loader.go

Editar directamente el archivo generado para agregar:
```go
DB.Users.Add(&entities.User{
    ...
    IsActive:      true,
    EmailVerified: true,
    PasswordHash:  "$2a$10$N9qo8uLOickgx2ZMRZoMyeIH1HvBubXwMq/gJpVdXI3.lzf9Kqmvy", // Admin123!
})
```

**Pros:** Rápido de implementar
**Cons:** Se perderá al regenerar el dataset

### Opción C: Usar Sistema Manual en lugar de Generado

Cambiar `user_repository_mock.go` para importar de `data` en lugar de `dataset`:
```go
import data "github.com/EduGoGroup/edugo-api-administracion/internal/infrastructure/persistence/mock/data"
```

**Pros:** Ya funciona, los datos son correctos
**Cons:** No usa el sistema de generación automática

---

## Archivos a Modificar

### Para Opción A (Generador)
| Archivo | Cambio |
|---------|--------|
| `tools/generate_dataset/main.go` | Agregar extracción de is_active, email_verified |
| `tools/generate_dataset/templates/` | Agregar campos en templates |
| Regenerar dataset | `go run tools/generate_dataset/main.go` |

### Para Opción B (Manual)
| Archivo | Cambio |
|---------|--------|
| `internal/infrastructure/persistence/mock/dataset/users_loader.go` | Agregar IsActive, EmailVerified, PasswordHash válido |

### Para Opción C (Usar data/)
| Archivo | Cambio |
|---------|--------|
| `internal/infrastructure/persistence/mock/repository/user_repository_mock.go` | Cambiar import de dataset a data |

---

## Decisión Requerida

Antes de continuar con el siguiente ciclo, se necesita decidir:

1. ¿Qué opción implementar? (A, B o C)
2. ¿Aplicar corrección en esta rama `fix/homologar-mock-config` o crear nueva rama?

---

## Estado de Ramas

| Proyecto | Rama | Commits | Push |
|----------|------|---------|------|
| api-admin | `fix/homologar-mock-config` | `062919a` | ❌ Pendiente |
| api-mobile | `fix/homologar-mock-config` | `6f0f507` | ❌ Pendiente |

---

## Próximo Ciclo

Una vez decidida la solución:
1. Aplicar corrección de IsActive/PasswordHash
2. Re-ejecutar Prueba 1 (API-Admin Mock)
3. Si pasa, continuar con Pruebas 2, 3, 4
4. Reportar resultados

---

**Última actualización:** 30 de Noviembre, 2025  
**Ciclo actual:** 1 de N
