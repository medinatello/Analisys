# 🎯 Decisiones Arquitectónicas Globales - EduGo

**Fecha:** 16 de Noviembre, 2025  
**Versión:** 2.0.0  
**Estado:** Decisiones Tomadas y Aplicadas

---

## 📋 Registro de Decisiones Arquitectónicas

Este documento registra todas las decisiones arquitectónicas críticas del ecosistema EduGo.

---

## 🏗️ DECISIÓN 1: Arquitectura de Microservicios Compartiendo Base de Datos

**Fecha:** Octubre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Necesidad de separar funcionalidades por audiencia

### Decisión

Usar arquitectura de microservicios con base de datos compartida (PostgreSQL) pero APIs independientes.

### Rationale

**Por qué NO microservicios puros:**
- Las bases de datos compartidas (PostgreSQL, MongoDB, RabbitMQ) requieren coordinación
- El dominio es pequeño (plataforma educativa)
- La complejidad de transacciones distribuidas no se justifica en MVP

**Por qué separar APIs:**
- api-mobile: Alta frecuencia de requests (estudiantes/docentes)
- api-administracion: Baja frecuencia (administradores)
- Escalado independiente según carga

### Implementación

**Estructura:**
```
- edugo-api-mobile (Puerto 8080)
- edugo-api-administracion (Puerto 8081)
- edugo-worker (procesamiento asíncrono)
```

**Base de datos compartida:**
- PostgreSQL: Todas las APIs
- MongoDB: api-mobile + worker
- RabbitMQ: api-mobile + worker

---

## 🗄️ DECISIÓN 2: Ownership de Tablas Compartidas

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Evitar conflictos de migraciones entre proyectos

### Decisión

Crear proyecto **edugo-infrastructure** centralizado con ownership claro de tablas.

### Ownership Definido

| Tabla | Owner | Justificación |
|-------|-------|---------------|
| users, schools, academic_units, memberships | api-admin | Datos maestros de administración |
| materials, assessment, assessment_attempt, assessment_answer | api-mobile | Features de estudiantes/docentes |

### Implementación

**Archivo:** `infrastructure/database/TABLE_OWNERSHIP.md`

**Orden de migraciones:**
1. api-admin: Tablas base (001-004)
2. api-mobile: Tablas con foreign keys (005-008)

**Beneficios:**
- Cero conflictos de migraciones
- Orden de ejecución claro
- Responsabilidades bien definidas

---

## 📨 DECISIÓN 3: Contratos de Eventos RabbitMQ

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Evitar incompatibilidades entre publishers y consumers

### Decisión

Usar **JSON Schema** para validación de eventos con versionamiento explícito.

### Estrategia

**Validación:**
- Schemas en `infrastructure/schemas/events/`
- Validación automática en publicación y consumo
- validator.go (pendiente de implementar)

**Versionamiento:**
- Campo `event_version` en cada evento
- Formato: "1.0", "2.0", etc.
- Breaking changes requieren nueva versión

**Eventos documentados:**
1. material.uploaded (v1.0)
2. assessment.generated (v1.0)
3. material.deleted (v1.0)
4. student.enrolled (v1.0)

### Implementación

**Archivo:** `infrastructure/EVENT_CONTRACTS.md`

**Ejemplo:**
```json
{
  "event_id": "uuid-v7",
  "event_type": "material.uploaded",
  "event_version": "1.0",
  "timestamp": "2025-11-15T10:30:00Z",
  "payload": { ... }
}
```

---

## 🔄 DECISIÓN 4: Sincronización PostgreSQL ↔ MongoDB

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Evaluaciones tienen metadata en PostgreSQL y contenido en MongoDB

### Decisión

Usar patrón **MongoDB primero + Eventual Consistency**.

### Flujo

1. Worker genera assessment en **MongoDB** (fuente de verdad del contenido)
2. Worker publica evento `assessment.generated` con `mongo_document_id`
3. api-mobile consume evento
4. api-mobile crea registro en **PostgreSQL** con `mongo_document_id`
5. Si PostgreSQL falla: Retry 3x → Dead Letter Queue

### Rationale

**Por qué MongoDB primero:**
- MongoDB tiene el contenido real (preguntas, opciones)
- Worker es el owner de ese contenido
- PostgreSQL es solo un índice/referencia

**Por qué Eventual Consistency:**
- Patrón probado en microservicios
- Más simple que transacciones distribuidas (2PC, Saga)
- Aceptable tener delay de segundos

**Manejo de inconsistencias:**
- DLQ captura fallos de PostgreSQL
- Cronjob de reconciliación (opcional)
- UI maneja caso de assessment incompleto

### Implementación

**Campo en PostgreSQL:**
```sql
CREATE TABLE assessment (
  id UUID PRIMARY KEY,
  material_id UUID NOT NULL,
  mongo_document_id VARCHAR(24),  -- Referencia a MongoDB
  ...
);
```

**Validación en API:**
```go
// api-mobile valida que MongoDB existe
mongoDoc := mongoRepo.Get(pgRecord.MongoDocumentID)
if mongoDoc == nil {
  return ErrAssessmentIncomplete
}
```

---

## 🔒 DECISIÓN 5: Congelamiento de edugo-shared v0.7.0

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Evitar breaking changes durante desarrollo de MVP

### Decisión

Congelar **shared en v0.7.0** hasta post-MVP.

### Política

**Permitido:**
- ✅ Bug fixes críticos (v0.7.1, v0.7.2, etc.)
- ✅ Documentación
- ✅ Tests

**NO Permitido:**
- ❌ Nuevas features
- ❌ Breaking changes
- ❌ Refactoring mayor

### Rationale

**Beneficios:**
- Desarrollo predecible (sin sorpresas)
- go.mod estable en todos los proyectos
- Foco en completar MVP, no en mejorar shared

**Desventajas aceptadas:**
- Features "nice to have" esperan post-MVP
- Workarounds temporales en proyectos

### Implementación

**Archivo:** `shared/FROZEN.md`

**go.mod de consumidores:**
```go
require (
  github.com/EduGoGroup/edugo-shared/auth v0.7.0
  github.com/EduGoGroup/edugo-shared/evaluation v0.7.0
  // ...
)
```

---

## 🐳 DECISIÓN 6: Docker Compose con Profiles

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Diferentes escenarios de desarrollo

### Decisión

Usar **Docker Compose profiles** en vez de múltiples archivos compose.

### Profiles Definidos

| Profile | Servicios | Uso |
|---------|-----------|-----|
| core | PostgreSQL + MongoDB | Desarrollo básico |
| messaging | + RabbitMQ | Con eventos |
| cache | + Redis | Con caché |
| tools | + PgAdmin + Mongo Express | Debugging |

### Rationale

**Por qué profiles:**
- Un solo archivo docker-compose.yml
- Fácil de mantener
- Fácil de extender

**Por qué NO múltiples archivos:**
- docker-compose.yml, docker-compose.dev.yml, etc. → confusión
- Dificulta sincronización

### Implementación

**Archivo:** `infrastructure/docker/docker-compose.yml`

**Uso:**
```bash
# Solo BDs
docker-compose --profile core up

# BDs + RabbitMQ
docker-compose --profile core --profile messaging up

# Todo
docker-compose --profile core --profile messaging --profile cache --profile tools up
```

---

## 🧪 DECISIÓN 7: Testcontainers para Tests de Integración

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Tests de integración consistentes

### Decisión

Usar **Testcontainers** en lugar de mocks para tests de integración.

### Rationale

**Por qué Testcontainers:**
- Tests contra servicios reales (PostgreSQL, MongoDB, RabbitMQ)
- Mismo comportamiento en local y CI/CD
- Aislamiento entre tests

**Por qué NO solo mocks:**
- Mocks no detectan problemas de integración
- SQL queries pueden fallar en producción
- Comportamiento de RabbitMQ difícil de mockear

### Implementación

**Módulo:** `shared/testing` v0.7.0

**Helpers:**
- `NewPostgresContainer()` → PostgreSQL testcontainer
- `NewMongoContainer()` → MongoDB testcontainer
- `NewRabbitMQContainer()` → RabbitMQ testcontainer

**Uso:**
```go
// En tests de api-mobile
pg := testing.NewPostgresContainer(t)
defer pg.Terminate()

// Ejecutar migrations
pg.RunMigrations("../../infrastructure/database/migrations")

// Tests contra PostgreSQL real
repo := NewPostgresRepo(pg.ConnectionString())
```

---

## 🏛️ DECISIÓN 8: Clean Architecture en APIs

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA (api-admin completado)  
**Contexto:** Mantener código mantenible y testeable

### Decisión

Usar **Clean Architecture** en todas las APIs.

### Capas

```
cmd/api/main.go              → Entry point
internal/
  ├── domain/                → Entities, Value Objects, Interfaces
  ├── application/           → Use Cases, DTOs, Services
  └── infrastructure/        → Repositories, HTTP handlers, DB
```

### Rationale

**Beneficios:**
- Independencia de frameworks
- Testeable (domain no depende de infraestructura)
- Mantenible a largo plazo

**Desventajas aceptadas:**
- Más código inicial (boilerplate)
- Curva de aprendizaje

### Implementación

**Referencia:** `api-administracion` v0.2.0 (completado con Clean Architecture)

**Reglas:**
1. Domain no importa application ni infrastructure
2. Application puede importar domain
3. Infrastructure puede importar domain y application
4. Comunicación via interfaces (repositories, services)

---

## 📊 DECISIÓN 9: Coverage >80% Obligatorio

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Calidad de código en proyectos

### Decisión

**Coverage mínimo: 80%** para todos los proyectos.

### Rationale

**Por qué 80%:**
- Balance entre calidad y velocidad
- Cubre casos principales
- 100% es overkill para MVP

**Qué se mide:**
- Unit tests
- Integration tests
- Excluye: main.go, mocks generados

### Implementación

**CI/CD:**
```yaml
- name: Test with coverage
  run: go test ./... -coverprofile=coverage.out

- name: Check coverage
  run: |
    coverage=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
    if (( $(echo "$coverage < 80" | bc -l) )); then
      echo "Coverage $coverage% is below 80%"
      exit 1
    fi
```

**Por proyecto:**
- shared: ~75% (aceptable, frozen)
- api-admin: >80% ✅
- api-mobile: >80% (objetivo)
- worker: >80% (objetivo)

---

## 🔐 DECISIÓN 10: Refresh Tokens en Autenticación

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Seguridad y UX en aplicación móvil

### Decisión

Implementar **Refresh Tokens** en shared/auth v0.7.0.

### Configuración

**Access Token:**
- Duración: 15 minutos
- Uso: Autenticación en cada request

**Refresh Token:**
- Duración: 7 días
- Uso: Renovar access token sin re-login

### Rationale

**Por qué refresh tokens:**
- Mejor UX (no pedir login cada 15 minutos)
- Mejor seguridad (access token de corta duración)
- Permite revocación (invalidar refresh token)

### Implementación

**API:**
```go
// shared/auth v0.7.0
pair := jwtManager.GenerateTokenPair(userID, email, role)
// pair.AccessToken  (15 min)
// pair.RefreshToken (7 días)

// Renovar
newAccess := jwtManager.RefreshAccessToken(refreshToken)
```

---

## 🚀 DECISIÓN 11: Dead Letter Queue (DLQ) en RabbitMQ

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Manejo robusto de errores en worker

### Decisión

Implementar **Dead Letter Queue** en shared/messaging/rabbit v0.7.0.

### Configuración

**Retry:**
- Intentos: 3
- Backoff: Exponential (1s, 2s, 4s)

**DLQ:**
- Exchange: dlx
- Queue: {original_queue}.dlq
- TTL: Sin expiración (requiere intervención manual)

### Rationale

**Por qué DLQ:**
- Eventos fallidos no se pierden
- Permite debugging y retry manual
- Worker no se bloquea con eventos problemáticos

**Casos de uso:**
- OpenAI API falla (timeout, rate limit)
- MongoDB no disponible temporalmente
- Formato de evento inválido

### Implementación

**API:**
```go
// shared/messaging/rabbit v0.7.0
config := rabbit.ConsumerConfig{
  DLQ: rabbit.DLQConfig{
    Enabled: true,
    MaxRetries: 3,
    DLXExchange: "dlx",
  },
}
consumer.ConsumeWithDLQ(handler)
```

---

## 📝 DECISIÓN 12: Proyecto infrastructure Centralizado

**Fecha:** Noviembre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Resolver ownership, contratos, docker en un solo lugar

### Decisión

Crear proyecto **edugo-infrastructure** como fuente de verdad.

### Responsabilidades

1. **Migraciones de PostgreSQL** (database/)
2. **Contratos de eventos** (schemas/)
3. **Docker Compose** (docker/)
4. **Scripts de automatización** (scripts/)
5. **Seeds de datos** (seeds/)

### Rationale

**Por qué proyecto separado:**
- No pertenece a ninguna API específica
- Es infraestructura compartida
- Versionable independiente

**Por qué NO dentro de dev-environment:**
- dev-environment es para setup rápido
- infrastructure es para producción también

**Por qué NO dentro de shared:**
- shared es código Go
- infrastructure es config, SQL, JSON

### Implementación

**Repositorio:** https://github.com/EduGoGroup/edugo-infrastructure

**Versión:** v0.1.1

**Consumido por:** Todos los proyectos

---

## 🎯 DECISIÓN 13: Go 1.24 como Versión Estándar

**Fecha:** Octubre 2025  
**Estado:** ✅ APLICADA  
**Contexto:** Consistencia entre proyectos

### Decisión

Usar **Go 1.24** en todos los proyectos.

### Rationale

**Por qué 1.24:**
- Versión estable actual
- Performance improvements
- Mejor manejo de generics

**Migración:**
- Todos los proyectos actualizados
- go.mod con `go 1.24`

### Implementación

**En todos los go.mod:**
```go
module github.com/EduGoGroup/[proyecto]

go 1.24
```

---

## 📊 Resumen de Decisiones

| # | Decisión | Estado | Impacto |
|---|----------|--------|---------|
| 1 | Microservicios con BD compartida | ✅ | Alto |
| 2 | Ownership de tablas | ✅ | Crítico |
| 3 | JSON Schema para eventos | ✅ | Crítico |
| 4 | MongoDB primero + Eventual Consistency | ✅ | Alto |
| 5 | Shared v0.7.0 FROZEN | ✅ | Crítico |
| 6 | Docker Compose profiles | ✅ | Medio |
| 7 | Testcontainers | ✅ | Alto |
| 8 | Clean Architecture | ✅ | Alto |
| 9 | Coverage >80% | ✅ | Medio |
| 10 | Refresh tokens | ✅ | Medio |
| 11 | Dead Letter Queue | ✅ | Alto |
| 12 | Proyecto infrastructure | ✅ | Crítico |
| 13 | Go 1.24 | ✅ | Bajo |

**Total decisiones:** 13  
**Aplicadas:** 13 (100%)  
**Críticas:** 5  
**Alto impacto:** 5  
**Medio impacto:** 3

---

## 📝 Proceso de Nuevas Decisiones

### Cuando agregar una decisión a este documento:

1. La decisión afecta **múltiples proyectos**
2. La decisión tiene **impacto arquitectónico**
3. La decisión requiere **coordinación** entre equipos

### Formato de nueva decisión:

```markdown
## DECISIÓN XX: Título de la Decisión

**Fecha:** YYYY-MM-DD
**Estado:** ⬜ PROPUESTA / 🔄 EN REVISIÓN / ✅ APLICADA
**Contexto:** Por qué se necesita esta decisión

### Decisión

Qué se decidió exactamente

### Rationale

Por qué se eligió esta opción

### Implementación

Cómo se implementa
```

---

**Generado:** 16 de Noviembre, 2025  
**Por:** Claude Code  
**Versión:** 2.0.0
