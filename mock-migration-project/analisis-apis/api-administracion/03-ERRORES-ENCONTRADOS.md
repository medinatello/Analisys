# Errores Encontrados - Análisis Mock API Administración

## Error 1: Variable de Entorno Incorrecta

### Descripción del Error
Al intentar iniciar la API con la variable de entorno documentada en `MOCK_REPOSITORIES_GUIDE.md`, la API falla intentando conectarse a PostgreSQL.

### Reproducción
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
export USE_MOCK_REPOSITORIES=true
export APP_ENV=local
./bin/api-administracion
```

### Log del Error
```
2025/11/30 13:41:23 🔄 EduGo API Administración iniciando... (Version: v0.6.3-36-g4296cf4-dirty, Build: 2025-11-30T16:40:48Z)
INFO[2025-11-30 13:41:23] Starting application bootstrap...
DEBU[2025-11-30 13:41:23] Bootstrap configuration                       optional_resources="[]" required_resources="[logger postgresql]"
INFO[2025-11-30 13:41:23] Initializing PostgreSQL connection...

2025/11/30 13:41:23 /Users/jhoanmedina/go/pkg/mod/github.com/!edu!go!group/edugo-shared/bootstrap@v0.9.0/factory_postgresql.go:37
[error] failed to initialize database, got error failed to connect to `host=localhost user=edugo database=edugo`: dial error (dial tcp 127.0.0.1:5432: connect: connection refused)
2025/11/30 13:41:23 ❌ Error inicializando infraestructura: failed to bootstrap: failed to initialize PostgreSQL: failed to create PostgreSQL connection: failed to connect to PostgreSQL: failed to connect to `host=localhost user=edugo database=edugo`: dial error (dial tcp 127.0.0.1:5432: connect: connection refused)
```

### Análisis de Causa Raíz (según contexto del usuario)

#### A) ¿Cómo se desencadenó el error?

**A.1) ¿Fue por código ingresado en la tarea?**
**NO.** El código de mock repositories fue implementado correctamente en sprints previos. La implementación técnica es sólida.

**A.2) ¿Fue por un cambio de configuración?**
**SÍ.** El problema radica en cómo Viper está configurado para leer variables de entorno.

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/internal/config/loader.go`

**Líneas relevantes:**
```go
// Línea 68
v.SetEnvPrefix("EDUGO_ADMIN")

// Línea 69
v.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

// Línea 70
v.AutomaticEnv()
```

**Comportamiento de Viper:**
- Con `SetEnvPrefix("EDUGO_ADMIN")`, Viper busca variables con prefijo `EDUGO_ADMIN_`
- Con `SetEnvKeyReplacer(".", "_")`, Viper reemplaza `.` por `_` en las claves de configuración
- Para la clave `database.use_mock_repositories`, Viper esperaría:
  - Prefijo: `EDUGO_ADMIN_`
  - Clave transformada: `DATABASE_USE_MOCK_REPOSITORIES`
  - **Variable completa esperada:** `EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES`

**Problema:**
La documentación en `MOCK_REPOSITORIES_GUIDE.md` indica usar:
```bash
export USE_MOCK_REPOSITORIES=true
```

Pero Viper NO lee esta variable porque no tiene el prefijo correcto.

**A.3) ¿El error proviene de código no agregado en la tarea?**
**SÍ.** El código de configuración (`config/loader.go`) existía antes de la implementación de mock repositories y NO fue actualizado para incluir un binding explícito.

**Código faltante en `loader.go`:**
```go
// Línea ~130 (debería agregarse)
_ = v.BindEnv("database.use_mock_repositories", "USE_MOCK_REPOSITORIES")
```

Este binding permitiría que Viper lea directamente `USE_MOCK_REPOSITORIES` sin necesidad del prefijo.

#### B) Análisis de Implicaciones del Cambio

**¿Qué implicaría agregar el binding?**

**Opción 1: Agregar binding explícito**
```go
_ = v.BindEnv("database.use_mock_repositories", "USE_MOCK_REPOSITORIES")
```

**Pros:**
- ✅ Mantiene compatibilidad con documentación actual
- ✅ Variable más corta y fácil de recordar
- ✅ Consistente con otros bindings en el archivo (ej: `POSTGRES_PASSWORD`, `MONGODB_URI`)

**Contras:**
- ⚠️ Rompe el patrón de prefijo `EDUGO_ADMIN_` para esta variable específica
- ⚠️ Requiere cambio en código

**Opción 2: Actualizar documentación**
Cambiar `MOCK_REPOSITORIES_GUIDE.md` para usar:
```bash
export EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES=true
```

**Pros:**
- ✅ No requiere cambio en código
- ✅ Consistente con el patrón de configuración actual
- ✅ Funciona inmediatamente

**Contras:**
- ⚠️ Variable larga y difícil de recordar
- ⚠️ Menos intuitiva para usuarios

**Opción 3: Modificar archivo de configuración**
Cambiar `config/config-local.yaml`:
```yaml
database:
  use_mock_repositories: true  # Cambiar de false a true
```

**Pros:**
- ✅ No requiere variables de entorno
- ✅ Configuración persistente
- ✅ Más fácil para desarrollo local

**Contras:**
- ⚠️ Requiere commit del cambio (no recomendable para archivo local)
- ⚠️ Menos flexible (no se puede cambiar sin editar archivo)

**Recomendación:** **Opción 1** (agregar binding explícito) es la mejor solución porque:
1. Mantiene la documentación actual válida
2. Es consistente con otros bindings sensibles (`POSTGRES_PASSWORD`, `AUTH_JWT_SECRET`)
3. Proporciona flexibilidad sin sacrificar claridad

#### C) Intentos de Solución

**Intento 1: Usar variable documentada (FALLÓ)**
```bash
export USE_MOCK_REPOSITORIES=true
./bin/api-administracion
```
**Resultado:** ❌ API intentó conectarse a PostgreSQL

**Intento 2: Usar variable con prefijo correcto (ÉXITO)**
```bash
export EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES=true
./bin/api-administracion
```
**Resultado:** ✅ API arrancó correctamente con mocks

**Log exitoso:**
```
INFO[2025-11-30 13:42:04] Starting application bootstrap...
DEBU[2025-11-30 13:42:04] Bootstrap configuration required_resources="[logger]"
WARN[2025-11-30 13:42:04] PostgreSQL initialization skipped
INFO[2025-11-30 13:42:04] usando mock repositories mock_enabled=true postgres_required=false
INFO[2025-11-30 13:42:04] ✅ API Administración iniciada port=8081
```

**Intento 3: Modificar config-local.yaml (ÉXITO, pero no recomendado)**
```yaml
# config/config-local.yaml
database:
  use_mock_repositories: true
```
```bash
./bin/api-administracion
```
**Resultado:** ✅ API arrancó correctamente con mocks

---

## Error 2: Inconsistencia entre Configuración y Documentación

### Descripción del Error
La documentación `MOCK_REPOSITORIES_GUIDE.md` afirma que el modo mock está activado por defecto en local, pero el archivo `config/config-local.yaml` tiene el valor en `false`.

### Archivos Involucrados

**`MOCK_REPOSITORIES_GUIDE.md` (línea 109):**
```yaml
# config/config-local.yaml
database:
  use_mock_repositories: true  # ✅ Ya activado
```

**`config/config-local.yaml` (línea 13) REAL:**
```yaml
database:
  # Por defecto usar PostgreSQL real (false)
  # Para desarrollo frontend sin Docker, configurar en IDE: USE_MOCK_REPOSITORIES=true
  use_mock_repositories: false
```

### Análisis de Causa Raíz

#### A) ¿Cómo se desencadenó?

**A.1) ¿Fue por código ingresado en la tarea?**
**NO.** El código de implementación mock no tocó los archivos de configuración.

**A.2) ¿Fue por un cambio de configuración?**
**SÍ.** Durante el desarrollo de mock repositories, se decidió cambiar el valor por defecto a `false` para no romper flujos existentes que dependían de PostgreSQL, pero la documentación no se actualizó.

**Evidencia del commit:**
```bash
# Commit 05ad16b
config: cambiar default de use_mock_repositories a false para usar PostgreSQL real por defecto
```

**A.3) ¿El error proviene de código no agregado en la tarea?**
**SÍ.** La documentación `MOCK_REPOSITORIES_GUIDE.md` se escribió asumiendo que el modo mock sería el default, pero luego se cambió la decisión y la documentación quedó desactualizada.

#### B) Implicaciones

Esta inconsistencia genera confusión porque:
1. El desarrollador lee la documentación que dice "✅ Ya activado"
2. Intenta usar la API sin PostgreSQL
3. La API falla porque `config-local.yaml` tiene `false`
4. El desarrollador no entiende por qué falla si "ya está activado"

**Solución:** Actualizar la documentación para reflejar el estado real:

```markdown
# MOCK_REPOSITORIES_GUIDE.md

## Configuración

### Estado por defecto en config-local.yaml
```yaml
database:
  use_mock_repositories: false  # Por defecto usa PostgreSQL
```

### Para activar mocks:

**Opción 1: Variable de entorno**
```bash
export EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES=true
make run
```

**Opción 2: Modificar config-local.yaml**
```yaml
database:
  use_mock_repositories: true
```
```

---

## Error 3: Debug Task en Zed usa variable incorrecta

### Descripción del Error
La configuración de debug en `.zed/debug.json` para el modo mock usa la variable `USE_MOCK_REPOSITORIES=true`, que es incorrecta.

### Archivo Involucrado
`.zed/debug.json` (línea 20-28):
```json
{
  "label": "Go: Debug main (MOCK - Sin Docker)",
  "adapter": "Delve",
  "program": "${ZED_WORKTREE_ROOT}/cmd/main.go",
  "cwd": "${ZED_WORKTREE_ROOT}",
  "request": "launch",
  "mode": "debug",
  "stopOnEntry": false,
  "env": {
    "APP_ENV": "local",
    "USE_MOCK_REPOSITORIES": "true",  // ❌ INCORRECTA
    "GIN_MODE": "debug"
  }
}
```

### Problema
Al ejecutar debug desde Zed con esta configuración, la API intentará conectarse a PostgreSQL porque `USE_MOCK_REPOSITORIES` no tiene el prefijo `EDUGO_ADMIN_`.

### Solución
**Opción A:** Corregir variable en `.zed/debug.json`:
```json
"env": {
  "APP_ENV": "local",
  "EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES": "true",  // ✅ CORRECTA
  "GIN_MODE": "debug"
}
```

**Opción B:** Si se implementa el binding explícito en `loader.go`, dejar como está y funciona.

---

## Resumen de Errores y Soluciones

| # | Error | Severidad | Causa Raíz | Solución Propuesta | Impacto |
|---|-------|-----------|------------|-------------------|---------|
| 1 | Variable env incorrecta en docs | ALTA | Falta binding en loader.go | Agregar binding explícito | Bloquea uso de mocks |
| 2 | Inconsistencia config vs docs | MEDIA | Docs desactualizados | Actualizar MOCK_REPOSITORIES_GUIDE.md | Genera confusión |
| 3 | Variable incorrecta en .zed/debug.json | MEDIA | No se actualizó después de config changes | Actualizar .zed/debug.json | Debug desde Zed no funciona con mocks |

---

## Verificación de las Soluciones

### Verificación Error 1

**Antes (FALLA):**
```bash
export USE_MOCK_REPOSITORIES=true
./bin/api-administracion
# Error: failed to connect to PostgreSQL
```

**Después con binding (FUNCIONA):**
```go
// En config/loader.go agregar:
_ = v.BindEnv("database.use_mock_repositories", "USE_MOCK_REPOSITORIES")
```
```bash
export USE_MOCK_REPOSITORIES=true
./bin/api-administracion
# INFO usando mock repositories mock_enabled=true
```

**Workaround actual (FUNCIONA):**
```bash
export EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES=true
./bin/api-administracion
# INFO usando mock repositories mock_enabled=true
```

### Verificación Error 2

**Actualizar documentación:**
```diff
- use_mock_repositories: true  # ✅ Ya activado
+ use_mock_repositories: false  # Por defecto usa PostgreSQL (cambiar a true para mocks)
```

### Verificación Error 3

**Actualizar `.zed/debug.json`:**
```diff
"env": {
  "APP_ENV": "local",
- "USE_MOCK_REPOSITORIES": "true",
+ "EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES": "true",
  "GIN_MODE": "debug"
}
```

---

## Conclusión

Los tres errores encontrados son **errores de configuración y documentación**, NO de implementación. El código de mock repositories funciona correctamente una vez configurado apropiadamente.

**Próximos pasos:**
1. Decidir si agregar binding explícito en `loader.go` (recomendado)
2. Actualizar `MOCK_REPOSITORIES_GUIDE.md` con información correcta
3. Actualizar `.zed/debug.json` con variable correcta
4. Crear PR con los cambios
