# Análisis Detallado: Migración Bootstrap API-Mobile

**Fecha:** 13 de Noviembre, 2025
**Fase:** 0.2 - Migración de api-mobile a shared/bootstrap
**Objetivo:** Analizar arquitectura actual antes de refactorizar

---

## 📊 Resumen Ejecutivo

### Estado Actual
- **LOC Total Bootstrap Interno:** 1,927 líneas
- **Archivos:** 10 archivos (8 principales + 2 noop)
- **Tests:** 3 archivos de test (~1,083 LOC de tests)
- **Dependencias de Shared Actuales:**
  - `edugo-shared/logger v0.3.3`
  - `edugo-shared/auth v0.3.3`
  - `edugo-shared/common v0.3.3`
  - `edugo-shared/middleware/gin v0.3.3`

### Descubrimiento Clave

⚠️ **DUPLICACIÓN CASI TOTAL**

El bootstrap interno de api-mobile es **casi idéntico conceptualmente** a lo que acabamos de crear en shared/bootstrap v0.1.0:
- Mismas interfaces (LoggerFactory, DatabaseFactory, etc.)
- Mismo patrón de Resources
- Mismo patrón de Options
- Lifecycle similar

**PERO con diferencias de implementación que requieren análisis cuidadoso.**

---

## 🔍 Análisis Archivo por Archivo

### 1. `interfaces.go` (76 LOC)

**Funcionalidad:**
- Define interfaces para factories: LoggerFactory, DatabaseFactory, MessagingFactory, StorageFactory
- Define struct Resources
- Define BootstrapOptions

**Comparación con shared/bootstrap:**
| Aspecto | api-mobile | shared/bootstrap v0.1.0 |
|---------|-----------|------------------------|
| **LoggerFactory** | `Create(level, format)` | `CreateLogger(ctx, env, version)` |
| **DatabaseFactory** | Una interfaz unificada | PostgreSQLFactory y MongoDBFactory separadas |
| **MessagingFactory** | `CreatePublisher()` | RabbitMQFactory completo (conn+channel+queue) |
| **StorageFactory** | `CreateS3Client()` | S3Factory con validación |
| **Resources.Logger** | `logger.Logger` (interfaz de shared) | `*logrus.Logger` (concreto) |
| **Resources.PostgreSQL** | `*sql.DB` (raw) | `*gorm.DB` (ORM) |
| **S3Storage** | Interfaz custom con presigned URLs | Interfaz genérica StorageClient |

**Diferencias Críticas:**
1. ✅ **PostgreSQL:** api-mobile usa `*sql.DB` (raw), shared usa `*gorm.DB` (ORM)
2. ✅ **Logger:** api-mobile usa interfaz `logger.Logger`, shared usa `*logrus.Logger` concreto
3. ⚠️ **S3:** api-mobile tiene métodos específicos de presigned URLs que shared NO tiene implementados

**Recomendación:**
- ✅ **Mantener:** Interfaz S3Storage con presigned URLs (específico de api-mobile)
- 🔄 **Adaptar:** Crear wrapper/adapter para PostgreSQL (sql.DB → gorm.DB)
- 🔄 **Adaptar:** Crear wrapper para Logger (logger.Logger → logrus.Logger)

---

### 2. `config.go` (130 LOC)

**Funcionalidad:**
- Extrae configuración de resources desde `internal/config.Config`
- Funciones helper: `getPostgreSQLConfig()`, `getMongoDBConfig()`, etc.

**Comparación con shared/config:**
| Aspecto | api-mobile | shared/config v0.4.0 |
|---------|-----------|---------------------|
| **Struct Base** | `internal/config.Config` | `config.BaseConfig` |
| **Loader** | Custom con Viper | `config.Loader` con Viper |
| **Validator** | No visible | `config.Validator` |

**Dependencia:**
```go
// api-mobile usa su propio config interno
import "github.com/EduGoGroup/edugo-api-mobile/internal/config"
```

**Análisis de internal/config.Config:**
- ¿Extiende BaseConfig de shared?
- ¿O es completamente custom?
- **PENDIENTE:** Revisar `internal/config/` para ver si ya usa shared/config

**Recomendación:**
- 🔍 **Investigar:** Si `internal/config` ya usa o puede usar `shared/config.BaseConfig`
- 🔄 **Migrar:** Funciones de extracción a shared/bootstrap (implementar TODOs)

---

### 3. `factories.go` (57 LOC)

**Funcionalidad:**
- Implementaciones concretas de las factories
- `DefaultLoggerFactory`, `DefaultDatabaseFactory`, etc.

**Comparación con shared/bootstrap:**
| Factory | api-mobile | shared/bootstrap |
|---------|-----------|------------------|
| **Logger** | Crea `shared/logger.Logger` | Crea `*logrus.Logger` |
| **PostgreSQL** | Usa `database/sql` + `pq` driver | Usa `gorm` + `postgres` driver |
| **MongoDB** | Usa `mongo-driver` | Usa `mongo-driver` ✅ |
| **RabbitMQ** | Crea `rabbitmq.Publisher` (custom) | Crea `amqp.Connection + Channel` |
| **S3** | Crea `S3Storage` (custom) | Crea `*s3.Client` |

**Diferencias de Implementación:**
1. **Logger:** api-mobile crea interfaz, shared crea concreto
2. **PostgreSQL:** api-mobile raw SQL, shared GORM
3. **RabbitMQ:** api-mobile abstracción de Publisher, shared conexión raw
4. **S3:** api-mobile interfaz custom, shared cliente AWS directo

**Recomendación:**
- ✅ **Mantener:** Factories de api-mobile como wrappers sobre shared
- 🎯 **Estrategia:** Composición en vez de reemplazo total

---

### 4. `lifecycle.go` (155 LOC)

**Funcionalidad:**
- Gestión LIFO de recursos
- Registro de cleanup functions
- Startup/Shutdown ordenado

**Comparación con shared/lifecycle:**
| Aspecto | api-mobile | shared/lifecycle v0.4.0 |
|---------|-----------|------------------------|
| **Pattern** | LIFO stack | LIFO stack ✅ |
| **Thread-safe** | Mutex | Mutex ✅ |
| **Startup** | Secuencial | Secuencial ✅ |
| **Cleanup** | Continúa en error | Continúa en error ✅ |
| **LOC** | 155 | 190 |

**Conclusión:** ✅ **IDÉNTICO EN CONCEPTO**

**Recomendación:**
- 🗑️ **ELIMINAR:** `lifecycle.go` de api-mobile
- ✅ **REEMPLAZAR:** Con `shared/lifecycle.Manager`

---

### 5. `bootstrap.go` (348 LOC)

**Funcionalidad Principal:**
```go
func (b *Bootstrap) InitializeInfrastructure(ctx context.Context) (*Resources, func() error, error)
```

**Responsabilidades:**
1. Inicializar Logger
2. Inicializar PostgreSQL
3. Inicializar MongoDB
4. Inicializar RabbitMQ Publisher
5. Inicializar S3 Client
6. Registrar cleanups
7. Retornar Resources + cleanup function

**Comparación con shared/bootstrap:**
| Aspecto | api-mobile | shared/bootstrap |
|---------|-----------|------------------|
| **Entry Point** | `InitializeInfrastructure()` | `Bootstrap()` |
| **Return Type** | `(Resources, cleanup func, error)` | `(*Resources, error)` |
| **Cleanup** | Función retornada | Integrado con lifecycle |
| **Options** | `BootstrapOptions` | `BootstrapOption` (functional) |
| **Config Source** | `internal/config.Config` | `interface{}` + extractors |

**Diferencias Clave:**
1. api-mobile retorna función de cleanup, shared usa lifecycle.Manager
2. api-mobile recibe config tipado, shared recibe interface{}
3. api-mobile crea recursos concretos específicos, shared más genérico

**Recomendación:**
- 🔄 **REFACTORIZAR:** Usar shared/bootstrap.Bootstrap() como base
- ✅ **ADAPTAR:** Crear capa de adaptación para tipos específicos de api-mobile
- 📦 **MANTENER:** Lógica de orchestration específica si es necesaria

---

### 6. `noop/publisher.go` y `noop/storage.go` (78 LOC total)

**Funcionalidad:**
- Implementaciones no-op (vacías) para testing
- NoopPublisher implementa `rabbitmq.Publisher`
- NoopStorage implementa `S3Storage`

**Comparación con shared/bootstrap:**
- shared/bootstrap tiene `MockFactories` en tests
- shared/bootstrap NO tiene implementaciones noop standalone

**Recomendación:**
- ✅ **MANTENER:** Como están (útiles para testing)
- 🔄 **MOVER:** A `internal/bootstrap/testutil/` para mejor organización
- 📝 **DOCUMENTAR:** Cuándo usar noop vs mocks

---

### 7. Tests (1,083 LOC total)

**Archivos:**
- `bootstrap_test.go` (223 LOC) - Tests unitarios
- `lifecycle_test.go` (269 LOC) - Tests de lifecycle
- `bootstrap_integration_test.go` (591 LOC) - Tests de integración

**Cobertura:**
- Tests de inicialización completa
- Tests de error handling
- Tests de cleanup
- Tests de recursos opcionales
- **Tests de integración con infraestructura real** 🎯

**Comparación con shared/bootstrap:**
- shared tiene 414 LOC de tests (solo unitarios con mocks)
- api-mobile tiene 591 LOC de tests de integración (con Docker)

**Recomendación:**
- ✅ **MANTENER:** Tests de integración de api-mobile (valiosos)
- 🔄 **ADAPTAR:** Tests unitarios para usar shared/bootstrap
- 📦 **CONSERVAR:** Setup de Docker para integration tests

---

## 📊 Tabla Comparativa Completa

| Componente | api-mobile LOC | shared LOC | ¿Duplicado? | Acción |
|------------|----------------|------------|-------------|--------|
| **Interfaces** | 76 | 229 | ⚠️ Parcial | Adaptar |
| **Config Extraction** | 130 | TODOs | ⚠️ Implementar | Migrar |
| **Factories** | 57 | 495 | ⚠️ Diferente | Wrapper |
| **Lifecycle** | 155 | 190 | ✅ Idéntico | Eliminar |
| **Bootstrap Core** | 348 | 469 | ⚠️ Similar | Refactor |
| **Noop Implementations** | 78 | 0 | ➖ Único | Mantener |
| **Tests Unitarios** | 492 | 414 | ⚠️ Similar | Adaptar |
| **Tests Integración** | 591 | 0 | ➖ Único | Mantener |
| **TOTAL** | 1,927 | 1,797 | - | - |

---

## 🎯 Estrategia de Migración

### Opción A: Reemplazo Total (❌ NO RECOMENDADO)
Eliminar todo `internal/bootstrap` y usar solo shared/bootstrap.

**Riesgos:**
- Pérdida de lógica específica de api-mobile
- Ruptura de tests de integración
- Incompatibilidades de tipos (sql.DB vs gorm.DB)
- Falta de presigned URLs en shared

### Opción B: Adaptación por Capas (✅ RECOMENDADO)

**Capa 1: shared/bootstrap (Base)**
- Maneja inicialización genérica
- Factories base
- Lifecycle management

**Capa 2: internal/bootstrap (Adapter)**
- Wrappers sobre shared para tipos específicos
- Lógica de presigned URLs
- Integración con internal/config
- Noop implementations

**Capa 3: main.go (Orchestration)**
- Llama a shared/bootstrap
- Aplica adapters específicos
- Retorna Resources con tipos de api-mobile

**Beneficios:**
- ✅ Reutiliza shared/bootstrap
- ✅ Mantiene compatibilidad con código existente
- ✅ Preserva tests de integración
- ✅ Permite evolución independiente

---

## 📋 Plan de Migración Detallado

### ETAPA 1: Preparación (1-2 horas)
**Sin cambios de código, solo análisis**

- [ ] **T1.1:** Revisar `internal/config` completo
  - ¿Usa shared/config.BaseConfig?
  - ¿Necesita migrar a BaseConfig?
  - Documentar campos custom

- [ ] **T1.2:** Mapear dependencias de Resources
  - ¿Qué paquetes usan `bootstrap.Resources`?
  - ¿Cuántos lugares referencian `Resources.PostgreSQL`?
  - Evaluar impacto de cambiar tipos

- [ ] **T1.3:** Revisar tests de integración
  - ¿Qué requieren para funcionar?
  - Docker compose usado
  - Fixtures necesarios

**Entregable:** Documento `FASE_0.2_DEPENDENCIAS.md`

### ETAPA 2: Crear Adapters (2-3 horas)

- [ ] **T2.1:** Crear `internal/bootstrap/adapter/logger.go`
  ```go
  // Adapter: logrus.Logger → logger.Logger (interfaz)
  type LoggerAdapter struct { *logrus.Logger }
  func (a *LoggerAdapter) Info(...) { ... }
  ```

- [ ] **T2.2:** Crear `internal/bootstrap/adapter/database.go`
  ```go
  // Adapter: gorm.DB → sql.DB
  func GormToSQL(gormDB *gorm.DB) *sql.DB
  ```

- [ ] **T2.3:** Crear `internal/bootstrap/adapter/s3.go`
  ```go
  // Wrapper: s3.Client → S3Storage (con presigned)
  type S3StorageAdapter struct { client *s3.Client }
  func (a *S3StorageAdapter) GeneratePresignedUploadURL(...) { ... }
  ```

**Entregable:** Paquete `internal/bootstrap/adapter/` con tests

### ETAPA 3: Refactorizar bootstrap.go (2-3 horas)

- [ ] **T3.1:** Crear nuevo `InitializeInfrastructure()` que:
  1. Llama `shared/bootstrap.Bootstrap()`
  2. Aplica adapters
  3. Retorna Resources compatibles

- [ ] **T3.2:** Mantener firma actual para backward compatibility:
  ```go
  func (b *Bootstrap) InitializeInfrastructure(ctx) (*Resources, func() error, error)
  ```

- [ ] **T3.3:** Implementar config extractors (TODOs de shared)

**Entregable:** `bootstrap.go` refactorizado, tests pasando

### ETAPA 4: Actualizar main.go (1 hora)

- [ ] **T4.1:** Simplificar main.go
- [ ] **T4.2:** Validar que todo funciona igual
- [ ] **T4.3:** Ejecutar tests de integración

**Entregable:** main.go limpio, app funcional

### ETAPA 5: Limpieza (1-2 horas)

- [ ] **T5.1:** Eliminar `lifecycle.go` (usar shared/lifecycle)
- [ ] **T5.2:** Reorganizar noop a `testutil/`
- [ ] **T5.3:** Actualizar imports en todo el proyecto
- [ ] **T5.4:** Ejecutar todos los tests

**Entregable:** Código limpio, sin duplicación

### ETAPA 6: Testing y Documentación (1-2 horas)

- [ ] **T6.1:** Tests unitarios completos
- [ ] **T6.2:** Tests de integración pasando
- [ ] **T6.3:** Documentar cambios en CHANGELOG
- [ ] **T6.4:** Actualizar README si es necesario

**Entregable:** Tests al 100%, documentación actualizada

---

## ⏱️ Estimación Revisada

| Etapa | Tiempo Estimado | Complejidad |
|-------|----------------|-------------|
| 1. Preparación | 1-2 horas | Baja |
| 2. Adapters | 2-3 horas | Media |
| 3. Refactor bootstrap | 2-3 horas | Alta |
| 4. Main.go | 1 hora | Baja |
| 5. Limpieza | 1-2 horas | Media |
| 6. Testing | 1-2 horas | Media |
| **TOTAL** | **8-13 horas** | **Media-Alta** |

**Recomendación:** Dividir en 2-3 sesiones de trabajo.

---

## ⚠️ Riesgos Identificados

### Riesgo 1: Incompatibilidad de Tipos
**Problema:** PostgreSQL usa `sql.DB` en api-mobile, `gorm.DB` en shared.  
**Mitigación:** Crear adapter bidireccional, mantener ambos si es necesario.

### Riesgo 2: Tests de Integración Rotos
**Problema:** Cambios pueden romper setup de Docker.  
**Mitigación:** Ejecutar tests de integración después de CADA cambio.

### Riesgo 3: Regresiones en Producción
**Problema:** Bootstrap es crítico, cambios pueden afectar startup.  
**Mitigación:** Testing exhaustivo, deployment gradual.

### Riesgo 4: Conflicto de Interfaces
**Problema:** `logger.Logger` (interfaz) vs `logrus.Logger` (concreto).  
**Mitigación:** Usar adapter pattern, mantener compatibilidad.

---

## 💡 Decisiones Clave a Validar

1. **¿Mantener sql.DB o migrar a gorm.DB?**
   - ✅ Mantener sql.DB (menos disruptivo)
   - ❌ Migrar a gorm.DB (más cambios)

2. **¿Eliminar lifecycle.go interno?**
   - ✅ Sí, usar shared/lifecycle (elimina 155 LOC)

3. **¿Qué hacer con noop implementations?**
   - ✅ Mover a testutil/ (mejor organización)

4. **¿Strategy pattern para adapters?**
   - ✅ Sí, permite flexibilidad futura

---

## 📝 Próximos Pasos

1. **Validar este análisis** con el equipo
2. **Decidir** sobre tipos (sql.DB vs gorm.DB)
3. **Crear** FASE_0.2_PLAN.md con plan aprobado
4. **Iniciar** ETAPA 1 en nueva sesión

---

**Documento creado:** 13 de Noviembre, 2025  
**Autor:** Claude Code + Jhoan Medina  
**Estado:** 🟡 Pendiente de revisión y aprobación
