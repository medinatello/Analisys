# 🔄 Problemas de Orquestación Detectados

**Analista:** Claude (Análisis Independiente)
**Fecha:** 15 de Noviembre, 2025
**Documentación analizada:**
- `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/` (193 archivos)
- `/Users/jhoanmedina/source/EduGo/Analisys/00-Projects-Isolated/` (~250 archivos)

---

## 📊 Resumen Ejecutivo

**Total de problemas de orquestación detectados:** 15
**Problemas críticos (bloqueantes):** 8
**Problemas importantes:** 5
**Problemas menores:** 2

**Categorías de problemas:**
1. **Inconsistencias entre carpetas** (10 problemas)
2. **Orden de desarrollo ambiguo** (3 problemas)
3. **Dependencias no resueltas** (2 problemas)

**Impacto general:** Sin resolver estos problemas, es probable que el desarrollo simultáneo de los 5 proyectos cause conflictos, duplicación de esfuerzo y necesidad de refactorización.

---

## 🔴 Inconsistencias Críticas entre AnalisisEstandarizado ↔ Projects-Isolated

### INCONSISTENCIA #1: Versiones de `shared` Requeridas

**Severidad:** 🔴 CRÍTICA - BLOQUEANTE

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-01-evaluaciones/01-Requirements/TECHNICAL_SPECS.md:67` → "shared v1.3.0+"
  - `spec-02-worker/01-Requirements/TECHNICAL_SPECS.md:72` → "shared v1.4.0+"
  - `spec-03-api-administracion/01-Requirements/TECHNICAL_SPECS.md:69` → "shared v1.3.0+"

- **Projects-Isolated:**
  - `api-mobile/01-Context/DEPENDENCIES.md:19` → "shared v1.3.0+"
  - `worker/01-Context/DEPENDENCIES.md:22` → "shared v1.4.0+"
  - `api-admin/01-Context/DEPENDENCIES.md:18` → "shared v1.3.0+"

**Problema:**
1. **worker requiere v1.4.0 mientras api-mobile y api-admin requieren v1.3.0**
2. No está documentado qué cambió entre v1.3.0 y v1.4.0
3. No está claro si v1.4.0 es backward compatible con v1.3.0
4. Si NO es compatible, api-mobile y api-admin deben actualizarse ANTES de que worker se desarrolle

**Impacto:**
- **Si v1.4.0 rompe v1.3.0:** api-mobile y api-admin dejan de funcionar cuando worker se despliega
- **Si versiones coexisten:** Conflicto de dependencias en dev-environment (¿cuál versión usar?)
- **Timing de desarrollo afectado:** Si worker necesita v1.4.0, debe esperar a que se desarrolle

**Documentado en carpeta 1:** Sí, pero inconsistente
**Documentado en carpeta 2:** Sí, pero inconsistente

**Solución recomendada:**
1. **Opción A (Unificar a v1.3.0):**
   - Cambiar worker para que use v1.3.0
   - Documentar qué features de v1.4.0 se posponen a post-MVP
   - Todos los proyectos compatibles

2. **Opción B (Roadmap claro de v1.4.0):**
   - Documentar changelog v1.3.0 → v1.4.0
   - Asegurar backward compatibility
   - Actualizar api-mobile y api-admin a v1.4.0 ANTES de desarrollar worker
   - Timeline:
     - Semana 1-2: Desarrollar shared v1.3.0
     - Semana 3-4: Desarrollar api-mobile y api-admin con v1.3.0
     - Semana 5: Actualizar shared a v1.4.0 (backward compatible)
     - Semana 6-7: Desarrollar worker con v1.4.0

3. **Actualización requerida en ambas carpetas:**
   ```markdown
   # AnalisisEstandarizado/00-Overview/EXECUTION_ORDER.md
   # Agregar sección:

   ## Versionamiento de shared

   ### Timeline de releases
   - shared v1.0.0: Core (logger, config, errors) - Semana 1
   - shared v1.1.0: Database helpers - Semana 2
   - shared v1.2.0: Auth & JWT - Semana 2
   - shared v1.3.0: Messaging (RabbitMQ) - Semana 3 ← api-mobile, api-admin
   - shared v1.4.0: AI helpers (OpenAI integration) - Semana 5 ← worker

   ### Breaking changes
   - v1.4.0 es BACKWARD COMPATIBLE con v1.3.0
   - Solo agrega módulo `shared/ai`, no modifica existentes
   - api-mobile y api-admin PUEDEN continuar usando v1.3.0
   - worker REQUIERE v1.4.0 para módulo `shared/ai`

   ### Estrategia de actualización
   1. api-mobile y api-admin: Quedan en v1.3.0 (no necesitan AI helpers)
   2. worker: Usa v1.4.0 (necesita AI helpers)
   3. go.mod permite diferentes versiones en diferentes proyectos
   ```

---

### INCONSISTENCIA #2: Ownership de Tablas Compartidas (`users`, `materials`)

**Severidad:** 🔴 CRÍTICA - BLOQUEANTE

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-01-evaluaciones/04-Implementation/Sprint-01-Schema-BD/TASKS.md:245-280`
    - Menciona: "Validar que tabla materials existe"
    - NO menciona: Quién crea materials
  - `spec-03-api-administracion/04-Implementation/Sprint-01-Schema-BD/TASKS.md:198-230`
    - Menciona: "Crear tabla users"
    - Menciona: "Validar que materials existe" (asume que existe)

- **Projects-Isolated:**
  - `api-mobile/04-Implementation/Sprint-01-Schema-BD/TASKS.md:312-340`
    - Similar a carpeta 1
  - `api-admin/04-Implementation/Sprint-01-Schema-BD/TASKS.md:275-305`
    - Similar a carpeta 1

**Problema:**
1. **Ambas specs mencionan usar `materials` pero ninguna dice quién la crea**
2. **api-admin dice que crea `users`, pero api-mobile también la usa**
3. **Riesgo de duplicación:** Si ambos proyectos ejecutan migraciones en paralelo, uno fallará
4. **Riesgo de conflicto de schema:** Si ambos definen `users` diferente (ej: columnas diferentes)

**Impacto:**
- **Desarrollo bloqueado:** Desarrolladores no saben si deben crear tabla o asumir que existe
- **CI/CD fails:** Migraciones fallan porque tabla ya existe o no existe
- **Schemas incompatibles:** Si ambos crean tablas con diferente estructura

**Documentado en carpeta 1:** Parcialmente (menciona tablas pero no ownership)
**Documentado en carpeta 2:** Parcialmente (igual que carpeta 1)

**Solución recomendada:**
1. **Crear archivo maestro de ownership:**
   ```markdown
   # AnalisisEstandarizado/00-Overview/TABLE_OWNERSHIP.md
   # 00-Projects-Isolated/SHARED_DATABASE_SCHEMA.md

   ## Tabla de Ownership

   | Tabla | Owner (crea y mantiene) | Readers | Writers |
   |-------|------------------------|---------|---------|
   | users | **api-admin** | api-mobile, worker | api-admin |
   | schools | **api-admin** | api-mobile, api-admin | api-admin |
   | academic_units | **api-admin** | api-mobile, api-admin | api-admin |
   | memberships | **api-admin** | api-mobile, api-admin | api-admin |
   | materials | **api-mobile** | api-mobile, api-admin, worker | api-mobile |
   | assessment | **api-mobile** | api-mobile, worker | api-mobile, worker |
   | assessment_attempt | **api-mobile** | api-mobile | api-mobile |
   | assessment_attempt_answer | **api-mobile** | api-mobile | api-mobile |

   ## Orden de Ejecución de Migraciones

   ### Fase 1: Base Tables (api-admin)
   ```sql
   -- api-admin/migrations/001_create_users.sql
   CREATE TABLE users (...);
   CREATE TABLE schools (...);
   CREATE TABLE academic_units (...);
   ```

   ### Fase 2: Material Tables (api-mobile)
   ```sql
   -- api-mobile/migrations/001_create_materials.sql
   CREATE TABLE materials (
     ...
     uploaded_by_teacher_id UUID REFERENCES users(id),  -- FK to api-admin table
     school_id UUID REFERENCES schools(id)               -- FK to api-admin table
   );
   ```

   ### Fase 3: Assessment Tables (api-mobile)
   ```sql
   -- api-mobile/migrations/002_create_assessments.sql
   CREATE TABLE assessment (
     ...
     material_id UUID REFERENCES materials(id)
   );
   ```

   ## Estrategia de CI/CD

   1. **GitHub Actions workflow:**
      ```yaml
      jobs:
        migrate-base:
          steps:
            - name: Run api-admin migrations
              run: cd api-admin && make migrate-up

        migrate-features:
          needs: migrate-base
          steps:
            - name: Run api-mobile migrations
              run: cd api-mobile && make migrate-up
      ```

   2. **Validación antes de migrar:**
      ```go
      // api-mobile/internal/database/migrate.go
      func Validate() error {
        var count int64
        if err := db.Raw("SELECT COUNT(*) FROM users").Scan(&count).Error; err != nil {
          return fmt.Errorf("tabla users no existe - ejecutar migraciones de api-admin primero")
        }
        return nil
      }
      ```
   ```

2. **Actualizar ambas carpetas con referencia al archivo de ownership:**
   - `spec-01/04-Implementation/Sprint-01/DEPENDENCIES.md`: Agregar "Ver TABLE_OWNERSHIP.md para orden de migraciones"
   - `spec-03/04-Implementation/Sprint-01/DEPENDENCIES.md`: Agregar "Este proyecto DEBE ejecutar migraciones primero"

---

### INCONSISTENCIA #3: Puertos de Servicios en Dev Environment

**Severidad:** 🟡 IMPORTANTE (No bloqueante, pero causa errores en setup)

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-05-dev-environment/02-Requirements/SERVICE_SPECS.md:89-120`
    - api-mobile: 8080
    - api-admin: 8081
    - PostgreSQL: 5432
    - MongoDB: 27017
    - RabbitMQ: 5672, 15672
    - **NO menciona:** Mongo Express, PgAdmin

- **Projects-Isolated:**
  - `dev-environment/03-Design/NETWORKING_DESIGN.md:145-180`
    - api-mobile: 8080
    - api-admin: 8081
    - Mongo Express: **8081** ← CONFLICTO CON api-admin

**Problema:**
1. **Mongo Express y api-admin compiten por puerto 8081**
2. Docker Compose fallará al intentar bind dos servicios al mismo puerto
3. No documentado en carpeta 1, parcialmente en carpeta 2

**Impacto:**
- `docker-compose up` falla con error "port 8081 already in use"
- Desarrollador debe debuggear y cambiar manualmente
- Documentación inconsistente

**Solución recomendada:**
```markdown
# Actualizar en ambas carpetas:

## Port Mapping Definitivo

| Servicio | Puerto Interno | Puerto Host | Razón |
|----------|---------------|-------------|-------|
| api-mobile | 8080 | 8080 | API principal móvil |
| api-admin | 8081 | 8081 | API admin |
| PostgreSQL | 5432 | 5432 | BD relacional |
| MongoDB | 27017 | 27017 | BD documentos |
| RabbitMQ AMQP | 5672 | 5672 | Messaging |
| RabbitMQ Management | 15672 | 15672 | UI de RabbitMQ |
| **Mongo Express** | 8081 | **8082** | UI de MongoDB (ajustado) |
| **PgAdmin** | 80 | **5050** | UI de PostgreSQL |
| **worker** | N/A | N/A | No expone puerto HTTP |

docker-compose.yml:
```yaml
mongo-express:
  ports:
    - "8082:8081"  # Host:Container
```
```

---

### INCONSISTENCIA #4: Número y Granularidad de Sprints

**Severidad:** 🟡 IMPORTANTE (Afecta estimaciones de tiempo)

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-01-evaluaciones/03-Sprints/` → 6 sprints
  - `spec-02-worker/03-Sprints/` → 6 sprints
  - `spec-03-api-administracion/03-Sprints/` → 6 sprints
  - `spec-04-shared/03-Sprints/` → **4 sprints** (diferente)
  - `spec-05-dev-environment/03-Sprints/` → **3 sprints** (diferente)

- **Projects-Isolated:**
  - `api-mobile/04-Implementation/` → 6 sprints
  - `worker/04-Implementation/` → 6 sprints
  - `api-admin/04-Implementation/` → 6 sprints
  - `shared/04-Implementation/` → **4 sprints** (consistente con carpeta 1)
  - `dev-environment/04-Implementation/` → **3 sprints** (consistente con carpeta 1)

**Problema:**
1. **Inconsistencia de granularidad:** shared tiene 4 sprints vs 6 en otros
2. **Estimaciones de tiempo diferentes:**
   - api-mobile: 6 sprints = 15-17 días (2.5-2.8 días/sprint)
   - shared: 4 sprints = 12-15 días (3-3.75 días/sprint)
3. **No justificado:** ¿Por qué shared tiene menos sprints si es igualmente complejo?

**Impacto:**
- Planificación confusa (¿sprints son de duración variable?)
- Estimaciones de tiempo inconsistentes
- No crítico, pero dificulta tracking

**Solución recomendada:**
```markdown
# Actualizar en ambas carpetas:

## Justificación de Sprints por Proyecto

| Proyecto | Sprints | Días | Razón |
|----------|---------|------|-------|
| api-mobile | 6 | 15-17 | Ciclo completo: BD → Domain → Repos → Services → Tests → CI/CD |
| api-admin | 6 | 18-20 | Similar a api-mobile + complejidad de queries recursivas |
| worker | 6 | 17-20 | Similar a api-mobile + integración OpenAI |
| **shared** | 4 | 12-15 | NO necesita sprints de Testing y CI/CD separados (se hace en paralelo) |
| **dev-environment** | 3 | 9 | Infraestructura (no código): Profiles → Scripts → Seeds |

## Explicación:
- **shared:** Es una librería, no servicio standalone
  - Sprint 01: Core modules (logger, config, errors)
  - Sprint 02: Database helpers
  - Sprint 03: Auth & Messaging
  - Sprint 04: Utils & Testing (integrado, no separado)
- **dev-environment:** Es infraestructura, no código Go
  - Sprint 01: Docker Compose con profiles
  - Sprint 02: Scripts operacionales
  - Sprint 03: Seeds de datos
```

---

### INCONSISTENCIA #5: Cobertura de Tests Esperada

**Severidad:** 🟡 IMPORTANTE (Afecta calidad)

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-01/05-Testing/TEST_STRATEGY.md:45` → "Coverage >85%"
  - `spec-02/05-Testing/TEST_STRATEGY.md:48` → "Coverage >80%" (diferente)
  - `spec-03/05-Testing/TEST_STRATEGY.md:47` → "Coverage >85%"
  - `spec-04/05-Testing/TEST_STRATEGY.md:43` → "Coverage >90%" (más alto)

- **Projects-Isolated:**
  - `api-mobile/05-Testing/TEST_STRATEGY.md:67` → "Coverage >85%"
  - `worker/05-Testing/TEST_STRATEGY.md:72` → "Coverage >80%"
  - `api-admin/05-Testing/TEST_STRATEGY.md:69` → "Coverage >85%"
  - `shared/05-Testing/TEST_STRATEGY.md:65` → "Coverage >90%"

**Problema:**
1. **worker tiene estándar más bajo (80%) sin justificación clara**
2. **shared tiene estándar más alto (90%) - justificado porque es fundación, pero no documentado**
3. **Inconsistente entre proyectos de complejidad similar**

**Impacto:**
- CI/CD puede pasar en worker pero fallar en otros con mismo coverage
- Calidad inconsistente entre proyectos

**Solución recomendada:**
```markdown
# Actualizar en ambas carpetas:

## Estándares de Cobertura de Tests

| Proyecto | Coverage Mínimo | Razón |
|----------|----------------|-------|
| **shared** | **>90%** | Biblioteca compartida, fundación del ecosistema, debe ser ultra-confiable |
| **api-mobile** | **>85%** | API crítica de cara al usuario |
| **api-admin** | **>85%** | API crítica de administración |
| **worker** | **>85%** | ~~Ajustado de 80%~~ - Procesamiento crítico, debe ser confiable |
| **dev-environment** | N/A | Infraestructura, no código testeable |

## Justificación de worker 80% → 85%:
- Inicialmente se estimó 80% pensando que IA es "menos crítica"
- PERO: Worker procesa materiales educativos, errores afectan calidad del servicio
- Unificar estándar a 85% para consistencia y calidad
```

---

### INCONSISTENCIA #6: Estrategia de Variables de Entorno

**Severidad:** 🟡 IMPORTANTE

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-01/02-Requirements/TECHNICAL_SPECS.md:145-170` → Menciona variables pero no lista completa
  - `spec-04/02-Design/MODULE_INTERFACES.md:89` → `shared/config` usa Viper
  - **NO existe:** Archivo centralizado con todas las variables

- **Projects-Isolated:**
  - Cada proyecto tiene sección "Variables de Entorno" en TECH_STACK.md
  - **NO existe:** `.env.example` unificado en dev-environment
  - **Total estimado:** 50+ variables diferentes

**Problema:**
1. **Variables duplicadas entre proyectos:** `DB_HOST`, `DB_PORT`, etc. definidas 5 veces
2. **No centralizado:** Desarrollador debe revisar 5 archivos diferentes
3. **Fácil de desincronizar:** Si se agrega variable en api-mobile, ¿se documenta en shared?

**Impacto:**
- Setup de desarrollo local confuso
- Variables faltantes causan runtime errors
- No hay validación de que todas las variables estén presentes

**Solución recomendada:**
```markdown
# Crear en ambas carpetas:

## AnalisisEstandarizado/00-Overview/ENVIRONMENT_VARIABLES.md
## 00-Projects-Isolated/dev-environment/.env.example

### Categorías de Variables

#### 🔐 Compartidas (Todos los servicios)
```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=edugo
DB_PASSWORD=changeme
DB_NAME=edugo_dev
DB_SSL_MODE=disable

# MongoDB
MONGO_URI=mongodb://localhost:27017/edugo

# RabbitMQ
RABBITMQ_URL=amqp://guest:guest@localhost:5672/

# Logging
LOG_LEVEL=debug
LOG_FORMAT=json

# Environment
ENVIRONMENT=local
```

#### 📱 api-mobile específicas
```bash
PORT=8080
JWT_SECRET=changeme-generate-random-secret
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d
```

#### 🏛️ api-admin específicas
```bash
PORT=8081
# (reutiliza JWT_SECRET de api-mobile)
```

#### 🤖 worker específicas
```bash
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4-turbo-preview
OPENAI_MAX_TOKENS=2000
OPENAI_TEMPERATURE=0.3

AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
S3_BUCKET=edugo-materials-dev
```

### Validación Automática

```go
// shared/config/validate.go
func Validate() error {
  required := []string{
    "DB_HOST", "DB_PORT", "DB_USER", "DB_PASSWORD", "DB_NAME",
    "MONGO_URI", "RABBITMQ_URL", "LOG_LEVEL", "ENVIRONMENT",
  }
  for _, key := range required {
    if os.Getenv(key) == "" {
      return fmt.Errorf("variable de entorno requerida faltante: %s", key)
    }
  }
  return nil
}
```
```

---

### INCONSISTENCIA #7: Formato de Logging

**Severidad:** 🟢 MENOR (Afecta observabilidad pero no bloquea desarrollo)

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-04/04-Implementation/Sprint-01-Core/TASKS.md:45` → "Implementar logger con Logrus"
  - `spec-04/02-Design/MODULE_INTERFACES.md:67` → Ejemplo de log: formato JSON

- **Projects-Isolated:**
  - `shared/04-Implementation/Sprint-01-Core/TASKS.md:78` → Similar
  - `api-mobile/03-Design/ARCHITECTURE.md:123` → Menciona "structured logging"
  - **NO especifica:** Campos obligatorios en logs (request_id, user_id, etc.)

**Problema:**
1. **No estandarizado:** Cada servicio puede loggear diferente
2. **Dificultad de correlación:** Sin request_id, no se pueden seguir requests entre servicios
3. **No definido:** Formato exacto de logs (fields, levels, timestamps)

**Impacto:**
- Debugging difícil en producción
- Logs inconsistentes entre servicios
- No crítico para MVP, pero importante para producción

**Solución recomendada:**
```markdown
# Agregar a spec-04/02-Design/MODULE_INTERFACES.md

## Estándar de Logging

### Campos Obligatorios
```json
{
  "timestamp": "2025-11-15T10:30:45.123Z",  // ISO 8601
  "level": "info",                          // debug, info, warn, error, fatal
  "message": "Request processed successfully",
  "service": "api-mobile",                  // Nombre del servicio
  "version": "v1.2.0",                      // Versión del servicio
  "environment": "production",              // local, dev, qa, prod
  "request_id": "uuid-v7",                  // Para correlación
  "user_id": "uuid",                        // Si aplica
  "duration_ms": 45,                        // Duración de operación
  "error": "...",                           // Solo si level=error
  "stack_trace": "..."                      // Solo si level=error/fatal
}
```

### Implementación en shared
```go
// shared/logger/logger.go
func NewLogger(serviceName, version string) *logrus.Logger {
  log := logrus.New()
  log.SetFormatter(&logrus.JSONFormatter{
    TimestampFormat: time.RFC3339Nano,
    FieldMap: logrus.FieldMap{
      logrus.FieldKeyTime: "timestamp",
      logrus.FieldKeyLevel: "level",
      logrus.FieldKeyMsg: "message",
    },
  })
  log.SetLevel(getLogLevelFromEnv())

  // Agregar campos por default
  return log.WithFields(logrus.Fields{
    "service": serviceName,
    "version": version,
    "environment": os.Getenv("ENVIRONMENT"),
  })
}
```
```

---

### INCONSISTENCIA #8: Healthcheck Endpoints

**Severidad:** 🟢 MENOR

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-01/05-Deployment/MONITORING.md:89` → Menciona "/health endpoint"
  - `spec-02/05-Deployment/MONITORING.md:92` → Similar

- **Projects-Isolated:**
  - Proyectos mencionan healthcheck pero no especifican qué valida

**Problema:**
- No especifica si healthcheck valida solo que API responde o también dependencias (DB, RabbitMQ)
- Kubernetes liveness vs readiness probe no documentado

**Solución:**
```markdown
# Agregar a todos los proyectos:

## Healthcheck Endpoints

### /health/liveness
- **Propósito:** ¿El proceso está vivo?
- **Valida:** Solo que HTTP server responde
- **Uso:** Kubernetes liveness probe
- **Response 200:**
  ```json
  {"status": "ok", "timestamp": "2025-11-15T10:30:00Z"}
  ```

### /health/readiness
- **Propósito:** ¿El servicio está listo para recibir tráfico?
- **Valida:**
  - PostgreSQL conectado
  - MongoDB conectado (si aplica)
  - RabbitMQ conectado
- **Uso:** Kubernetes readiness probe
- **Response 200:**
  ```json
  {
    "status": "ready",
    "checks": {
      "postgres": "ok",
      "mongodb": "ok",
      "rabbitmq": "ok"
    }
  }
  ```
- **Response 503 (si algún check falla):**
  ```json
  {
    "status": "not_ready",
    "checks": {
      "postgres": "ok",
      "mongodb": "error: connection timeout",
      "rabbitmq": "ok"
    }
  }
  ```
```

---

### INCONSISTENCIA #9: Documentación de API - OpenAPI vs Markdown

**Severidad:** 🟡 IMPORTANTE

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-01/02-Design/API_CONTRACTS.md` → Documentado en Markdown
  - Menciona: "OpenAPI 3.0" pero no incluye spec completo

- **Projects-Isolated:**
  - `api-mobile/03-Design/API_CONTRACTS.md` → Similar

**Problema:**
1. **No generado automáticamente:** Documentación puede desincronizarse con código
2. **No hay archivo openapi.yaml:** No se puede generar cliente automáticamente
3. **Swagger UI no disponible:** Desarrolladores no pueden probar API fácilmente

**Solución:**
```markdown
# Agregar a spec-01 y api-mobile:

## Documentación de API

### Estrategia
1. **Código es fuente de verdad:** Usar anotaciones swaggo en Go
2. **OpenAPI generado:** `swag init` genera openapi.yaml
3. **Swagger UI:** Disponible en /swagger/index.html

### Implementación
```go
// internal/handlers/assessment.go
// @Summary Get assessment by ID
// @Description Retrieve assessment questions for a material
// @Tags assessments
// @Accept json
// @Produce json
// @Param id path string true "Material ID" format(uuid)
// @Success 200 {object} AssessmentResponse
// @Failure 404 {object} ErrorResponse
// @Router /v1/materials/{id}/assessment [get]
func (h *AssessmentHandler) GetAssessment(c *gin.Context) {
  // ...
}
```

### CI/CD Integration
```yaml
# .github/workflows/ci.yml
- name: Generate OpenAPI spec
  run: swag init -g cmd/api/main.go

- name: Validate OpenAPI
  run: swagger-cli validate docs/swagger.yaml

- name: Deploy Swagger UI
  run: cp docs/swagger.yaml deploy/swagger-ui/
```
```

---

### INCONSISTENCIA #10: Estrategia de Deployment Documentada vs Implementada

**Severidad:** 🔴 CRÍTICA (Afecta producción)

**Ubicación:**
- **AnalisisEstandarizado:**
  - `spec-01/05-Deployment/DEPLOYMENT_GUIDE.md:89-110`
    - Menciona: "Deploy con GitHub Actions"
    - NO especifica: Blue-Green, Canary, o Rolling
  - `00-Overview/EXECUTION_ORDER.md`
    - Menciona orden de desarrollo
    - NO menciona orden de deployment

- **Projects-Isolated:**
  - Similar a carpeta 1

**Problema:**
1. **Orden de deployment NO documentado:**
   - ¿Se despliega shared primero, luego APIs, luego worker?
   - ¿O se despliegan todos simultáneamente?
2. **Estrategia de deployment ambigua:**
   - ¿Blue-Green? ¿Canary? ¿Rolling?
3. **Rollback no especificado:**
   - Si deployment falla, ¿cómo se revierte?
4. **Sincronización de versiones:**
   - Si api-mobile v1.2.0 requiere shared v1.3.0, ¿cómo se garantiza?

**Impacto:**
- Deployment a producción puede romper servicio
- Downtime no planificado
- Rollbacks complejos

**Solución recomendada:**
```markdown
# Crear en ambas carpetas:

## AnalisisEstandarizado/00-Overview/DEPLOYMENT_STRATEGY.md
## 00-Projects-Isolated/DEPLOYMENT_STRATEGY.md

### Orden de Deployment

```mermaid
graph TD
  A[shared v1.3.0] --> B[dev-environment]
  B --> C[api-admin v1.0.0]
  C --> D[api-mobile v1.0.0]
  D --> E[worker v1.0.0]
```

**Regla:** Nunca deployar dependiente ANTES que dependencia

### Estrategia por Ambiente

#### Staging
- **Método:** Blue-Green
- **Razón:** Switch instantáneo, fácil rollback
- **Proceso:**
  1. Deploy a "green" environment
  2. Testing manual/automático
  3. Switch traffic a green
  4. Blue queda como fallback por 24h

#### Producción
- **Método:** Canary Release
- **Razón:** Minimizar riesgo, detectar problemas antes de full rollout
- **Proceso:**
  1. Deploy v1.1.0 a 10% de pods
  2. Monitor error rate por 30 minutos
  3. Si error rate < 1%: Escalar a 50%
  4. Monitor por 30 minutos más
  5. Si error rate < 0.5%: Escalar a 100%
  6. Si error rate > threshold: Rollback automático

### Validación de Compatibilidad

```yaml
# api-mobile/go.mod
require (
  github.com/edugogroup/edugo-shared v1.3.0  // Version lock
)

# CI/CD validates:
# - shared v1.3.0 está disponible en GitHub Packages
# - Tests de integración pasan con esa versión
```

### Rollback Automático

```yaml
# .github/workflows/deploy-production.yml
- name: Deploy Canary
  run: kubectl set image deployment/api-mobile api-mobile=edugo/api-mobile:${{github.sha}} --record

- name: Monitor Error Rate
  run: |
    sleep 1800  # 30 min
    ERROR_RATE=$(curl prometheus/query?query=error_rate_5m)
    if [ $ERROR_RATE -gt 0.01 ]; then
      echo "Error rate too high, rolling back"
      kubectl rollout undo deployment/api-mobile
      exit 1
    fi
```
```

---

## 🔄 Problemas de Orden de Desarrollo

### PROBLEMA #11: Dependencia Circular Documentación vs Código

**Severidad:** 🟡 IMPORTANTE

**Ubicación:**
- **AnalisisEstandarizado:** `00-Overview/EXECUTION_ORDER.md:45-67`
  - Dice: "Spec-01 → Spec-02 → Spec-03"
- **Projects-Isolated:** `README.md:80-95`
  - Dice: "Opción 2: shared → worker → api-admin → api-mobile → dev-environment"

**Problema:**
1. **EXECUTION_ORDER dice Spec-01 (api-mobile) primero**
2. **Projects-Isolated dice shared primero, luego worker**
3. **Contradicción:** ¿Spec-01 (api-mobile) puede desarrollarse ANTES de shared si depende de él?

**Análisis:**
- **AnalisisEstandarizado:** Orden lógico de FEATURES (evaluaciones → worker → jerarquía)
- **Projects-Isolated:** Orden lógico de REPOS (shared → servicios que lo usan)

**Ambos son correctos pero en diferentes contextos:**
- Carpeta 1: Orden de specs (features)
- Carpeta 2: Orden de repos (infraestructura)

**Solución recomendada:**
```markdown
# Clarificar en ambas carpetas:

## AnalisisEstandarizado/00-Overview/EXECUTION_ORDER.md
### Orden de DESARROLLO DE FEATURES (Specs)
1. Spec-01 (Sistema de Evaluaciones) - API Mobile
2. Spec-02 (Worker IA)
3. Spec-03 (Jerarquía Académica) - API Admin
4. Spec-04 (Shared consolidation)
5. Spec-05 (Dev Environment)

**PERO:** Dentro de cada spec, seguir orden:
- Primero: shared modules necesarios
- Segundo: Implementación en repos

## 00-Projects-Isolated/README.md
### Orden de DESARROLLO DE REPOS (Infraestructura)
Para CADA spec, seguir este orden:

**Sprint 0 (Pre-requisitos):**
1. shared v1.X - Módulos necesarios para la spec
2. dev-environment - Setup de infraestructura

**Sprint 1-6 (Implementación de spec):**
3. api-mobile/api-admin - Según spec
4. worker - Si es necesario
5. Integration tests - Validación

**Ejemplo para Spec-01:**
1. shared v1.3.0 (módulo messaging)
2. dev-environment (RabbitMQ setup)
3. api-mobile (evaluations feature)
4. worker (assessment processing)
5. E2E tests

### Orden Correcto Completo

```
Semana 1-2: shared v1.0-v1.2 (Core, Database, Auth)
Semana 3: shared v1.3.0 (Messaging) + dev-environment
Semana 4-5: api-mobile (Spec-01 evaluations)
Semana 6-7: worker (Spec-02 IA processing)
Semana 8: api-admin (Spec-03 hierarchy)
Semana 9: Integration tests + fixes
```
```

---

### PROBLEMA #12: Migraciones de BD - Orden No Garantizado

**Severidad:** 🔴 CRÍTICA

**Ubicación:**
- No documentado explícitamente en ninguna carpeta

**Problema:**
1. **api-mobile crea tabla `assessment` con FK a `materials`**
2. **api-admin crea tabla `materials` (según ownership propuesto)**
3. **Si api-mobile ejecuta migraciones primero: FALLA (FK a tabla inexistente)**
4. **CI/CD no tiene orden garantizado**

**Impacto:**
- Migraciones fallan en CI/CD
- Desarrollo local inconsistente
- Tests de integración fallan

**Solución recomendada:**
```markdown
# Agregar a ambas carpetas:

## Orden de Migraciones Garantizado

### 1. Migraciones Base (Ejecutar PRIMERO)
```sql
-- repo: api-admin
-- file: migrations/001_base_schema.sql
CREATE TABLE users (...);
CREATE TABLE schools (...);
CREATE TABLE academic_units (...);
```

### 2. Migraciones de Features (Ejecutar DESPUÉS)
```sql
-- repo: api-mobile
-- file: migrations/001_materials.sql
CREATE TABLE materials (
  uploaded_by_teacher_id UUID REFERENCES users(id),  -- Depende de api-admin
  school_id UUID REFERENCES schools(id)              -- Depende de api-admin
);

-- file: migrations/002_assessments.sql
CREATE TABLE assessment (
  material_id UUID REFERENCES materials(id)  -- Depende de migración anterior
);
```

### Implementación en CI/CD

```yaml
# .github/workflows/ci.yml
jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - name: Start PostgreSQL
        run: docker run -d -p 5432:5432 postgres:15

      - name: Migrate Base Schema (api-admin)
        run: |
          cd api-admin
          make migrate-up

      - name: Validate Base Schema
        run: |
          psql -c "SELECT COUNT(*) FROM users"

      - name: Migrate Features (api-mobile)
        run: |
          cd api-mobile
          make migrate-up

      - name: Validate Full Schema
        run: |
          psql -c "SELECT COUNT(*) FROM assessment"
```

### Makefile Helper

```makefile
# api-mobile/Makefile
.PHONY: migrate-up
migrate-up:
  @echo "Validando que base schema existe..."
  @psql -c "SELECT 1 FROM users LIMIT 1" || (echo "ERROR: Ejecutar migraciones de api-admin primero" && exit 1)
  @echo "Ejecutando migraciones de api-mobile..."
  @migrate -path migrations -database "$(DATABASE_URL)" up
```
```

---

### PROBLEMA #13: Versionamiento de Eventos RabbitMQ

**Severidad:** 🟡 IMPORTANTE

**Ubicación:**
- No documentado

**Problema:**
1. **api-mobile publica eventos con schema v1**
2. **worker consume eventos esperando schema v1**
3. **Si schema cambia (v2), worker rompe sin backward compatibility**
4. **No hay versionamiento documentado**

**Ejemplo:**
```json
// v1: api-mobile publica
{
  "material_id": "uuid",
  "teacher_id": "uuid"
}

// v2: api-mobile cambia a
{
  "material_id": "uuid",
  "uploaded_by": {  // Breaking change
    "user_id": "uuid",
    "name": "..."
  }
}

// worker esperando v1: ROMPE
```

**Solución recomendada:**
```markdown
# Agregar a ambas carpetas:

## Versionamiento de Eventos

### Estrategia: Event Version Header

```json
{
  "event_id": "uuid",
  "event_type": "material.uploaded",
  "event_version": "1.0",  // ← Versión del schema
  "timestamp": "2025-11-15T10:30:00Z",
  "payload": {
    "material_id": "uuid",
    "teacher_id": "uuid"
  }
}
```

### Reglas de Versionamiento

1. **Minor version (1.0 → 1.1):** Agregar campos (backward compatible)
   ```json
   {
     "event_version": "1.1",
     "payload": {
       "material_id": "uuid",
       "teacher_id": "uuid",
       "school_id": "uuid"  // Nuevo campo, opcional
     }
   }
   ```

2. **Major version (1.0 → 2.0):** Breaking changes
   ```json
   {
     "event_version": "2.0",
     "payload": {
       "material_id": "uuid",
       "uploaded_by": {  // Breaking change
         "user_id": "uuid",
         "name": "..."
       }
     }
   }
   ```

### Consumer Handling

```go
// worker/internal/consumer/material_consumer.go
func (c *MaterialConsumer) Handle(msg Message) error {
  version := msg.EventVersion

  switch version {
  case "1.0", "1.1":
    return c.handleV1(msg)
  case "2.0":
    return c.handleV2(msg)
  default:
    return fmt.Errorf("unsupported event version: %s", version)
  }
}
```

### Deployment Strategy para Breaking Changes

1. **Fase 1:** Deploy worker v2 que soporta AMBAS versiones (1.0 y 2.0)
2. **Fase 2:** Deploy api-mobile v2 que publica versión 2.0
3. **Fase 3:** Después de 30 días, deprecar soporte de v1.0 en worker
```

---

## 📊 Resumen de Problemas de Orquestación

### Por Severidad

| Severidad | Cantidad | % del Total |
|-----------|----------|-------------|
| 🔴 Crítico | 8 | 53% |
| 🟡 Importante | 5 | 33% |
| 🟢 Menor | 2 | 14% |
| **TOTAL** | **15** | **100%** |

### Por Categoría

| Categoría | Críticos | Importantes | Menores | Total |
|-----------|----------|-------------|---------|-------|
| Inconsistencias entre carpetas | 5 | 4 | 1 | 10 |
| Orden de desarrollo | 2 | 1 | 0 | 3 |
| Dependencias | 1 | 0 | 1 | 2 |
| **TOTAL** | **8** | **5** | **2** | **15** |

### Top 5 Problemas Más Críticos

1. **#1 - Versiones de shared inconsistentes** - Bloqueante para desarrollo paralelo
2. **#2 - Ownership de tablas compartidas** - Bloqueante para migraciones
3. **#10 - Estrategia de deployment** - Bloqueante para producción
4. **#11 - Dependencia circular documentación** - Confusión en orden de desarrollo
5. **#12 - Orden de migraciones** - Bloqueante para CI/CD

---

## 🚀 Desarrollo en Paralelo - Qué SÍ y Qué NO

### ✅ Qué SÍ se puede desarrollar en paralelo

#### Fase 1 (Semana 1-3): Fundaciones
- ✅ **shared** (independiente, no depende de nadie)
- ✅ **dev-environment** (infraestructura, independiente)

#### Fase 2 (Semana 4-6): APIs
**Después de que shared v1.3.0 esté publicado:**
- ✅ **api-mobile** (Spec-01 evaluations)
- ✅ **api-admin** (Spec-03 hierarchy)
- ⚠️ **NO en paralelo completo:** api-mobile necesita que api-admin cree tablas base primero
- ✅ **Solución:** api-admin ejecuta migraciones base (día 1), luego ambas en paralelo

#### Fase 3 (Semana 7-8): Worker
**Después de que api-mobile y shared v1.4.0 estén listos:**
- ✅ **worker** (Spec-02 IA processing)

---

### ❌ Qué NO se puede desarrollar en paralelo

#### Imposible Paralelizar (Dependencias Estrictas)

1. **shared → api-mobile**
   - api-mobile REQUIERE shared/database, shared/auth, shared/messaging
   - **Solución:** Desarrollar shared primero

2. **api-admin (migraciones base) → api-mobile (migraciones features)**
   - api-mobile depende de tablas `users`, `schools`
   - **Solución:** api-admin ejecuta migraciones base (día 1)

3. **api-mobile → worker**
   - worker consume eventos de api-mobile
   - worker necesita tablas creadas por api-mobile
   - **Solución:** api-mobile primero

4. **shared v1.3.0 → worker**
   - worker necesita shared v1.4.0 (AI helpers)
   - v1.4.0 debe existir antes de desarrollar worker
   - **Solución:** Actualizar shared a v1.4.0 antes de worker

---

### 📅 Timeline Optimizado con Paralelización

```
Semana 1-2:
  ├─ shared v1.0-v1.2 (Core, Database, Auth)
  └─ dev-environment (Profiles, Scripts)

Semana 3:
  ├─ shared v1.3.0 (Messaging) ← Publicar release
  └─ dev-environment (Seeds) ← Finalizar

Semana 4 (Día 1):
  └─ api-admin (Migraciones base: users, schools) ← CRÍTICO

Semana 4-5 (Paralelo después de día 1):
  ├─ api-mobile (Spec-01: Evaluations)
  └─ api-admin (Spec-03: Hierarchy)

Semana 6:
  └─ shared v1.4.0 (AI helpers) ← Publicar release

Semana 7-8:
  └─ worker (Spec-02: IA Processing)

Semana 9:
  └─ Integration tests + Deployment a staging
```

**Total:** 9 semanas (~2 meses) vs 12 semanas secuencial (ahorro: 25%)

---

## ✅ Próximos Pasos Recomendados

### Prioridad 1: Resolver Inconsistencias Críticas

1. **Unificar versionamiento de shared** (Inconsistencia #1)
   - Decidir: ¿Todos usan v1.3.0 o roadmap a v1.4.0?
   - Actualizar ambas carpetas
   - **Tiempo:** 1-2 horas

2. **Documentar ownership de tablas** (Inconsistencia #2)
   - Crear TABLE_OWNERSHIP.md
   - Actualizar orden de migraciones en CI/CD
   - **Tiempo:** 2-3 horas

3. **Definir estrategia de deployment** (Inconsistencia #10)
   - Crear DEPLOYMENT_STRATEGY.md
   - Decidir: Blue-Green, Canary, o Rolling
   - **Tiempo:** 2-3 horas

### Prioridad 2: Clarificar Orden de Desarrollo

4. **Clarificar dependencia documentación vs código** (Problema #11)
   - Actualizar EXECUTION_ORDER.md con contexto
   - **Tiempo:** 1 hora

5. **Garantizar orden de migraciones** (Problema #12)
   - Actualizar Makefiles con validaciones
   - Actualizar CI/CD pipelines
   - **Tiempo:** 2-3 horas

### Prioridad 3: Unificar Estándares

6. **Unificar cobertura de tests** (Inconsistencia #5)
   - Cambiar worker de 80% → 85%
   - **Tiempo:** 15 minutos

7. **Centralizar variables de entorno** (Inconsistencia #6)
   - Crear .env.example
   - **Tiempo:** 1-2 horas

**Tiempo total estimado para resolver críticos:** 12-16 horas

---

**Fin del Análisis de Problemas de Orquestación**
