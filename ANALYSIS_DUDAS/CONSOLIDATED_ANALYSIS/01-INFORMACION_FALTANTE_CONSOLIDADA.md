# 📝 Información Faltante Consolidada

**Fecha de Consolidación:** 15 de Noviembre, 2025  
**Fuentes Analizadas:**
- Claude (Análisis Independiente)
- Gemini (Análisis Independiente)  
- Grok (Análisis Independiente)

---

## 📊 Resumen Ejecutivo

### Métricas Consolidadas

| Agente | Items Críticos | Items Importantes | Items Opcionales | Total |
|--------|----------------|-------------------|------------------|-------|
| **Claude** | 27 | 21 | 9 | 57 |
| **Gemini** | 15 | 0 | 0 | 15 |
| **Grok** | 10 | 0 | 0 | 10 |
| **Total Único** | **35** | **24** | **11** | **70** |

### Distribución por Prioridad

| Prioridad | Cantidad | Porcentaje | Acción Recomendada |
|-----------|----------|------------|-------------------|
| 🔴 Crítico | 35 | 50% | Resolver antes de desarrollo |
| 🟡 Importante | 24 | 34% | Resolver durante desarrollo |
| 🟢 Opcional | 11 | 16% | Post-MVP |

**Veredicto:** La documentación tiene grandes vacíos en **contratos de datos** (schemas, eventos, APIs) y **especificaciones de implementación** para 4 de los 5 proyectos. Sin esta información, es imposible iniciar desarrollo de la mayor parte del ecosistema.

---

## 📂 Por Categoría

### 🗄️ Schemas de Base de Datos

#### 🔴 Críticos

- [ ] **Índices de MongoDB documentados** (Claude)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌
  - **Prioridad:** ALTA
  - **Ubicación faltante:** `spec-01/02-Design/DATA_MODEL.md`
  - **Qué falta:** Índices para `material_assessment` y `material_summary`
  - **Impacto:** Performance pobre en queries frecuentes
  - **Solución:**
    ```javascript
    // material_assessment
    db.material_assessment.createIndex({ material_id: 1 }, { unique: true })
    db.material_assessment.createIndex({ "questions.question_id": 1 })
    
    // material_summary
    db.material_summary.createIndex({ material_id: 1 }, { unique: true })
    db.material_summary.createIndex({ created_at: -1 })
    ```

- [ ] **Schema completo de tabla `users`** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** CRÍTICA
  - **Ubicación faltante:** Archivo base compartido o `spec-03/02-Design/DATA_MODEL.md`
  - **Qué falta:** Definición completa de tabla users (mencionada pero no especificada)
  - **Impacto:** api-mobile y api-admin asumen diferentes estructuras
  - **Solución:**
    ```sql
    CREATE TABLE users (
      id UUID PRIMARY KEY DEFAULT gen_uuid_v7(),
      email VARCHAR(255) UNIQUE NOT NULL,
      password_hash VARCHAR(255) NOT NULL,
      full_name VARCHAR(255) NOT NULL,
      role VARCHAR(50) NOT NULL CHECK (role IN ('student', 'teacher', 'school_admin', 'super_admin')),
      school_id UUID REFERENCES schools(id),
      is_active BOOLEAN DEFAULT true,
      email_verified BOOLEAN DEFAULT false,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );
    ```

- [ ] **Schema completo de tabla `materials`** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** CRÍTICA
  - **Ubicación faltante:** Archivo base compartido o `spec-01/02-Design/DATA_MODEL.md`
  - **Qué falta:** Definición completa de materials
  - **Impacto:** Relaciones FK pueden fallar
  - **Solución:**
    ```sql
    CREATE TABLE materials (
      id UUID PRIMARY KEY DEFAULT gen_uuid_v7(),
      title VARCHAR(500) NOT NULL,
      description TEXT,
      file_url VARCHAR(1000) NOT NULL,
      file_size_bytes BIGINT NOT NULL,
      file_type VARCHAR(50) NOT NULL,
      uploaded_by_teacher_id UUID REFERENCES users(id),
      school_id UUID REFERENCES schools(id),
      academic_unit_id UUID REFERENCES academic_units(id),
      is_public BOOLEAN DEFAULT false,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );
    ```

- [ ] **Schemas SQL para api-admin** (Gemini, Grok)
  - **Detectado por:** Claude ❌ | Gemini ✅ | Grok ✅
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** CRÍTICA
  - **Ubicación faltante:** `spec-03/02-Design/DATA_MODEL.md` (vacía)
  - **Qué falta:** Tablas `schools`, `academic_units`, `unit_membership`
  - **Impacto:** Imposible implementar api-admin
  - **Solución:** Completar spec-03-api-administracion con schemas completos

- [ ] **Schema de tablas de auditoría del worker** (Gemini)
  - **Detectado por:** Claude ❌ | Gemini ✅ | Grok ❌
  - **Prioridad:** MEDIA
  - **Ubicación faltante:** `spec-02/02-Design/DATA_MODEL.md` (vacía)
  - **Qué falta:** Tablas de auditoría y logging mencionadas en responsabilidades
  - **Impacto:** Worker no puede guardar logs estructurados

- [ ] **Colección `material_event` en MongoDB** (Claude)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌
  - **Prioridad:** MEDIA
  - **Ubicación faltante:** `spec-02/02-Design/DATA_MODEL.md`
  - **Qué falta:** Schema completo de eventos de procesamiento
  - **Solución:**
    ```javascript
    {
      _id: ObjectId,
      material_id: UUID,
      event_type: "uploaded" | "processed" | "summary_generated" | "assessment_generated" | "failed",
      timestamp: ISODate,
      metadata: {
        processor_version: "v1.2.0",
        processing_time_ms: 45000,
        tokens_used: 12000,
        cost_usd: 0.15
      },
      error: {
        code: "OPENAI_RATE_LIMIT",
        message: "...",
        retryable: true
      }
    }
    ```

#### 🟡 Importantes

- [ ] **Triggers de auditoría** (Claude)
  - **Qué falta:** Triggers para actualizar `updated_at` automáticamente
  - **Solución:**
    ```sql
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
      NEW.updated_at = NOW();
      RETURN NEW;
    END;
    $$ language 'plpgsql';
    
    CREATE TRIGGER update_assessment_updated_at BEFORE UPDATE ON assessment
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ```

- [ ] **Seeds de datos completos** (Claude)
  - **Ubicación faltante:** `dev-environment/seeds/`
  - **Qué falta:** Seeds para users, schools, materials, assessments
  - **Impacto:** Desarrollo local requiere crear datos manualmente

- [ ] **Migraciones de rollback** (Claude)
  - **Qué falta:** Solo hay migraciones "up", no "down"
  - **Impacto:** No se puede hacer rollback de schema
  - **Solución:** Crear migraciones `XXXXXX_down.sql` para cada migración

- [ ] **Validación de integridad entre PostgreSQL y MongoDB** (Claude)
  - **Qué falta:** Validación de que `assessment.mongo_document_id` apunta a documento válido
  - **Solución:** Cronjob o validación en capa de aplicación

#### 🟢 Opcionales

- [ ] **Vistas de agregación (Materialized Views)** (Claude)
  - **Ejemplo:** Vista de estadísticas por estudiante
  - **Impacto:** Bajo, se puede hacer en queries

- [ ] **Stored procedures** (Claude)
  - **Ejemplo:** Calcular score de assessment en PL/pgSQL
  - **Impacto:** Bajo, se puede hacer en capa de aplicación

- [ ] **Particionamiento de tabla `assessment_attempt`** (Claude)
  - **Qué falta:** Criterio de cuándo implementar
  - **Solución:** "Implementar cuando tabla supere 10M filas o queries >500ms p95"

---

### 🌐 Contratos de API

#### 🔴 Críticos

- [ ] **Contratos de eventos RabbitMQ completos** (Claude, Gemini, Grok)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ✅
  - **Consenso:** 🟢 ALTO (3/3)
  - **Prioridad:** CRÍTICA
  - **Ubicación faltante:** `spec-02/02-Design/API_CONTRACTS.md` o archivo compartido
  - **Qué falta:** Estructura exacta de payloads de eventos
  - **Impacto:** api-mobile y worker pueden usar formatos incompatibles
  - **Solución:** Ver documento 00-ANALISIS_AMBIGUEDADES_CONSOLIDADO.md #4

- [ ] **OpenAPI 3.0 completo para api-mobile** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** CRÍTICA
  - **Ubicación faltante:** `spec-01/02-Design/API_CONTRACTS.md`
  - **Qué documentado:** Solo endpoints principales
  - **Qué falta:** Schemas completos de request/response, error codes
  - **Impacto:** Frontend no sabe exactamente qué esperar
  - **Solución:** Generar OpenAPI spec completo con ejemplos, usar swaggo annotations

- [ ] **OpenAPI 3.0 completo para api-admin** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** CRÍTICA
  - **Ubicación faltante:** `spec-03/02-Design/API_CONTRACTS.md` (vacía)
  - **Qué falta:** Similar a api-mobile
  - **Solución:** Completar spec-03 con API completa

- [ ] **Códigos de error estandarizados** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** ALTA
  - **Qué falta:** Lista completa de error codes (ERR_001, ERR_002, etc.)
  - **Impacto:** Frontend no puede manejar errores específicamente
  - **Solución:**
    ```json
    {
      "error": {
        "code": "ERR_ASSESSMENT_NOT_FOUND",
        "message": "Assessment with ID {id} not found",
        "details": {
          "assessment_id": "uuid",
          "reason": "deleted_or_never_existed"
        },
        "http_status": 404
      }
    }
    ```

- [ ] **Configuración de RabbitMQ** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** CRÍTICA
  - **Qué falta:** Exchanges, queues, bindings
  - **Impacto:** api-mobile y worker pueden crear exchanges incompatibles
  - **Solución:** Ver documento 00-ANALISIS_AMBIGUEDADES_CONSOLIDADO.md #4

#### 🟡 Importantes

- [ ] **Rate limiting por endpoint** (Claude)
  - **Qué falta:** Límites de requests por minuto/hora
  - **Solución:** Documentar (ej: 100 req/min por IP)

- [ ] **Formato de paginación** (Claude)
  - **Qué falta:** Cómo paginar listas (limit/offset vs cursor)
  - **Solución:**
    ```json
    GET /v1/assessments?limit=20&offset=40
    {
      "data": [...],
      "pagination": {
        "total": 156,
        "limit": 20,
        "offset": 40,
        "has_more": true
      }
    }
    ```

- [ ] **Formato de filtrado y búsqueda** (Claude)
  - **Qué falta:** Sintaxis de query params
  - **Ejemplo:** `GET /v1/materials?subject=math&grade=10`

- [ ] **Versionamiento de API** (Claude)
  - **Documentado:** `/v1/` en URLs
  - **Qué falta:** Estrategia de deprecación, soporte de múltiples versiones

- [ ] **Headers HTTP estándar** (Gemini)
  - **Qué falta:** Headers esperados en requests/responses
  - **Ejemplo:** `X-Request-ID` para trazabilidad

- [ ] **Formatos de Error HTTP** (Gemini)
  - **Qué falta:** Estandarización del formato JSON para errores

#### 🟢 Opcionales

- [ ] **Webhooks para notificaciones** (Claude)
  - **Impacto:** Bajo, no es requisito MVP

- [ ] **GraphQL como alternativa a REST** (Claude)
  - **Impacto:** Bajo, fuera de scope MVP

- [ ] **HATEOAS links en responses** (Claude)
  - **Impacto:** Bajo, nice-to-have

---

### ⚙️ Configuración

#### 🔴 Críticos

- [ ] **Archivo `.env.example` centralizado** (Claude, Gemini, Grok)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ✅
  - **Consenso:** 🟢 ALTO (3/3)
  - **Prioridad:** CRÍTICA
  - **Ubicación faltante:** `dev-environment/.env.example`
  - **Qué falta:** Template con todas las variables requeridas
  - **Impacto:** Desarrolladores no saben qué variables configurar
  - **Solución:**
    ```bash
    # Database
    DB_HOST=localhost
    DB_PORT=5432
    DB_USER=edugo
    DB_PASSWORD=changeme
    DB_NAME=edugo_dev
    
    # MongoDB
    MONGO_URI=mongodb://localhost:27017/edugo
    
    # RabbitMQ
    RABBITMQ_URL=amqp://guest:guest@localhost:5672/
    
    # JWT
    JWT_SECRET=changeme-generate-random-secret
    JWT_ACCESS_EXPIRY=15m
    JWT_REFRESH_EXPIRY=7d
    
    # OpenAI
    OPENAI_API_KEY=sk-...
    OPENAI_MODEL=gpt-4-turbo-preview
    OPENAI_MAX_TOKENS=2000
    
    # AWS S3
    AWS_REGION=us-east-1
    AWS_ACCESS_KEY_ID=...
    AWS_SECRET_ACCESS_KEY=...
    S3_BUCKET=edugo-materials-dev
    
    # Logging
    LOG_LEVEL=debug
    LOG_FORMAT=json
    
    # Environment
    ENVIRONMENT=local
    PORT=8080
    ```

- [ ] **Valores default documentados** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** ALTA
  - **Qué falta:** Qué valores son obligatorios vs opcionales
  - **Solución:** Comentarios en `.env.example`: `# Required` vs `# Optional (default: value)`

- [ ] **Validación de configuración al inicio** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** ALTA
  - **Qué falta:** Código que valida variables críticas presentes
  - **Impacto:** API inicia pero falla en runtime
  - **Solución:** Función `validateConfig()` que falla fast

- [ ] **Manejo de secretos (SOPS)** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** ALTA
  - **Documentado:** SOPS + Age mencionados
  - **Qué falta:** Tutorial de cómo usar SOPS en desarrollo
  - **Solución:** Crear `docs/SECRETS_MANAGEMENT.md`

#### 🟡 Importantes

- [ ] **Configuración por ambiente** (Claude, Grok)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅
  - **Documentado:** Viper soporta multi-ambiente
  - **Qué falta:** Archivos específicos por ambiente
  - **Solución:** `config/local.yaml`, `config/dev.yaml`, etc.

- [ ] **Feature flags** (Claude)
  - **Qué falta:** Sistema de feature toggles
  - **Impacto:** No se pueden habilitar/deshabilitar features sin deploy
  - **Solución:** Librería como `unleash` o config-based flags

#### 🟢 Opcionales

- [ ] **Hot reload de configuración** (Claude)
  - **Impacto:** Bajo, nice-to-have

- [ ] **Profiles de configuración** (Claude)
  - **Qué falta:** Profiles para distintos setups
  - **Impacto:** Bajo en MVP

---

### 📨 Eventos y Mensajería

#### 🔴 Críticos

- [ ] **Dead Letter Queue (DLQ) strategy** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** CRÍTICA
  - **Qué falta:** Qué hacer con mensajes que fallan múltiples veces
  - **Impacto:** Mensajes se pierden o reintentan infinitamente
  - **Solución:** Configurar DLQ con TTL y alertas

- [ ] **Orden de mensajes garantizado** (Claude)
  - **Qué falta:** ¿RabbitMQ garantiza orden FIFO o puede desordenarse?
  - **Impacto:** Eventos pueden procesarse fuera de orden
  - **Solución:** Documentar si orden importa y cómo garantizarlo

- [ ] **Message versioning** (Claude, Grok)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Qué falta:** Qué hacer cuando producer y consumer tienen versiones diferentes
  - **Solución:** Campo `event_version` en todos los eventos

#### 🟡 Importantes

- [ ] **Idempotencia de procesamiento** (Claude)
  - **Qué falta:** Cómo evitar procesar mismo mensaje dos veces
  - **Solución:** Usar `message_id` único y registrar en tabla `processed_events`

- [ ] **Reintentos automáticos con backoff** (Claude)
  - **Documentado:** "Retry con backoff exponencial"
  - **Qué falta:** Configuración exacta en RabbitMQ
  - **Solución:** Usar `x-retry-count` header y DLQ

- [ ] **Monitoring de queue depth** (Claude)
  - **Qué falta:** Métricas de profundidad de cola, throughput
  - **Solución:** Integrar con Prometheus

---

### 🧪 Testing

#### 🔴 Críticos

- [ ] **Fixtures de tests compartidos** (Claude)
  - **Ubicación faltante:** `shared/testing/fixtures/`
  - **Qué falta:** Datos de prueba reutilizables
  - **Impacto:** Cada test crea fixtures manualmente (código duplicado)
  - **Solución:**
    ```go
    // shared/testing/fixtures/user.go
    func CreateTestUser(t *testing.T, db *gorm.DB, opts ...UserOption) *models.User {
      user := &models.User{
        ID: uuid.New(),
        Email: "test@example.com",
        Role: "student",
      }
      for _, opt := range opts {
        opt(user)
      }
      require.NoError(t, db.Create(user).Error)
      return user
    }
    ```

- [ ] **Tests de integración entre servicios** (Claude)
  - **Qué falta:** Tests que validan api-mobile → RabbitMQ → worker flow completo
  - **Impacto:** Integración puede fallar en producción
  - **Solución:** Tests E2E que levanten todos los servicios

- [ ] **Cobertura de tests de casos edge** (Claude)
  - **Documentado:** >85% coverage
  - **Qué falta:** Lista de casos edge (ej: student intenta múltiples veces mismo assessment simultáneamente)
  - **Solución:** Documento de test cases críticos

#### 🟡 Importantes

- [ ] **Performance tests / Load tests** (Claude, Grok)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅
  - **Qué falta:** Tests de carga que validen throughput
  - **Solución:** k6 o Locust scripts

- [ ] **Chaos engineering** (Claude)
  - **Qué falta:** Tests que simulan fallos (DB down, RabbitMQ unavailable)
  - **Solución:** Tests que matan servicios y validan recuperación

#### 🟢 Opcionales

- [ ] **Mutation testing** (Claude)
  - **Impacto:** Bajo, nice-to-have

---

### 🚀 Deployment y Operaciones

#### 🔴 Críticos

- [ ] **Kubernetes manifests** (Claude, Grok)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** CRÍTICA
  - **Ubicación faltante:** `spec-*/06-Deployment/k8s/`
  - **Qué falta:** Deployments, Services, Ingress, ConfigMaps
  - **Impacto:** No se puede deployar a Kubernetes
  - **Solución:** Ver ejemplo en documento de Claude

- [ ] **CI/CD pipelines completos** (Claude, Grok)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** CRÍTICA
  - **Documentado:** GitHub Actions mencionado
  - **Qué falta:** Archivos `.github/workflows/` completos
  - **Solución:** Crear workflows para test, build, deploy

- [ ] **Runbooks para incidentes** (Claude)
  - **Prioridad:** CRÍTICA
  - **Qué falta:** Documentación de qué hacer si servicio X falla
  - **Impacto:** Downtime prolongado en incidentes
  - **Solución:**
    ```markdown
    ## Runbook: API Mobile Down
    
    ### Síntomas
    - Endpoint /health retorna 500
    - Logs muestran "connection refused to database"
    
    ### Diagnóstico
    1. Verificar PostgreSQL: `kubectl get pods -l app=postgresql`
    2. Verificar logs: `kubectl logs -l app=api-mobile --tail=100`
    
    ### Solución
    1. Si DB down: Reiniciar: `kubectl rollout restart deployment/postgresql`
    2. Si API crashloop: Rollback: `kubectl rollout undo deployment/api-mobile`
    3. Notificar a #incidents en Slack
    ```

- [ ] **Helm charts** (Claude)
  - **Qué falta:** Helm charts para instalar stack completo
  - **Impacto:** Deploy manual es complejo
  - **Solución:** Crear Helm chart `edugo` con subcharts

#### 🟡 Importantes

- [ ] **Monitoring y alerting** (Claude, Grok)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅
  - **Documentado:** "Prometheus + Grafana"
  - **Qué falta:** Dashboards específicos y alertas configuradas
  - **Solución:** Crear dashboards en JSON, alertmanager rules

- [ ] **Backup y restore procedures** (Claude)
  - **Qué falta:** Scripts de backup de PostgreSQL y MongoDB
  - **Solución:** Cronjobs que hacen dump a S3, procedimiento de restore

- [ ] **Disaster recovery plan** (Claude, Grok)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅
  - **Qué falta:** Plan completo de recuperación ante desastre
  - **Solución:** Documento con RTO y RPO

#### 🟢 Opcionales

- [ ] **Multi-region deployment** (Claude)
  - **Impacto:** Bajo, fuera de scope MVP

---

## 📦 Por Proyecto

### 📚 edugo-shared

#### 🔴 Críticos

- [ ] **Especificación completa de módulos** (Claude, Gemini, Grok)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ✅
  - **Consenso:** 🟢 ALTO (3/3)
  - **Prioridad:** BLOQUEANTE
  - **Ubicación faltante:** `spec-04-shared/` (completamente vacía)
  - **Qué falta:** API pública de cada módulo, structs, versionado
  - **Impacto:** Imposible desarrollar ningún otro proyecto
  - **Solución:** Completar spec-04 con:
    - Módulos: logger, config, errors, database, auth, messaging
    - Interfaces públicas de cada módulo
    - Structs de datos compartidos
    - CHANGELOG.md con v1.0.0 → v1.3.0 → v1.4.0

- [ ] **Módulo `shared/database` - Helpers de migraciones** (Claude)
  - **Ubicación:** `shared/database/migrations.go`
  - **Qué falta:** Helper para ejecutar migraciones desde Go
  - **Solución:** `func RunMigrations(db *gorm.DB, migrationsPath string) error`

- [ ] **Módulo `shared/testing` - Testcontainers helpers** (Claude)
  - **Ubicación:** `shared/testing/containers.go`
  - **Qué falta:** Funciones para levantar servicios en tests
  - **Solución:**
    ```go
    func StartPostgresContainer(t *testing.T) (*gorm.DB, func())
    func StartMongoContainer(t *testing.T) (*mongo.Client, func())
    func StartRabbitMQContainer(t *testing.T) (*amqp.Connection, func())
    ```

- [ ] **Módulo `shared/auth` - JWT helpers** (Claude)
  - **Qué falta:** Funciones de generación y validación de tokens
  - **Solución:**
    ```go
    func GenerateAccessToken(userID uuid.UUID) (string, error)
    func ValidateAccessToken(token string) (*Claims, error)
    ```

#### 🟡 Importantes

- [ ] **Módulo `shared/errors` - Error types** (Claude)
  - **Qué falta:** Tipos de errores comunes (NotFoundError, ValidationError, etc.)

- [ ] **Módulo `shared/middleware` - Middleware reutilizable** (Claude)
  - **Qué falta:** Middleware de autenticación, logging, CORS

- [ ] **GoDoc documentation** (Claude, Grok)
  - **Qué falta:** Comentarios completos de funciones públicas

- [ ] **Version compatibility matrix** (Claude, Grok)
  - **Qué falta:** Matriz de compatibilidad con otros proyectos

#### 🟢 Opcionales

- [ ] **Módulo `shared/cache` - Redis client** (Claude)
  - **Impacto:** Bajo, caching no es MVP

---

### 📱 api-mobile

#### 🔴 Críticos

- [ ] **Handlers con validación de input** (Claude)
  - **Ubicación:** `api-mobile/internal/handlers/`
  - **Qué falta:** Validación de request bodies con `validator` library

- [ ] **Middleware de autorización por rol** (Claude)
  - **Qué falta:** Verificar que solo `teacher` puede crear assessments
  - **Solución:** `func RequireRole(allowedRoles ...string) gin.HandlerFunc`

- [ ] **Tests de integración con Testcontainers** (Claude)
  - **Qué falta:** Tests que levanten PostgreSQL + MongoDB reales

#### 🟡 Importantes

- [ ] **Swagger documentation generada** (Claude)
  - **Qué falta:** Anotaciones swaggo en handlers
  - **Solución:** Agregar comentarios `// @Summary`, `// @Param`

- [ ] **Logging estructurado en handlers** (Claude)
  - **Qué falta:** Logs con contexto (user_id, request_id)

#### 🟢 Opcionales

- [ ] **Rate limiting per user** (Claude)
  - **Impacto:** Bajo, puede usar API gateway

---

### 🏛️ api-admin

#### 🔴 Críticos

- [ ] **Especificación completa** (Gemini, Grok)
  - **Detectado por:** Claude ❌ | Gemini ✅ | Grok ✅
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** BLOQUEANTE
  - **Ubicación faltante:** `spec-03-api-administracion/` (completamente vacía)
  - **Qué falta:** Schemas, endpoints, lógica de negocio
  - **Impacto:** Imposible implementar api-admin
  - **Solución:** Completar spec-03 con toda la documentación

- [ ] **Implementación de queries recursivas** (Claude)
  - **Ubicación:** `api-admin/internal/repositories/`
  - **Qué falta:** Código Go que ejecuta CTEs recursivas
  - **Solución:**
    ```go
    func (r *UnitRepository) GetTree(ctx context.Context, rootID uuid.UUID) ([]*models.AcademicUnit, error) {
      query := `
        WITH RECURSIVE unit_tree AS (
          SELECT * FROM academic_units WHERE id = ?
          UNION ALL
          SELECT au.* FROM academic_units au
          JOIN unit_tree ut ON au.parent_id = ut.id
        )
        SELECT * FROM unit_tree
      `
      // ...
    }
    ```

- [ ] **Validación de ciclos en jerarquía** (Claude)
  - **Qué falta:** Código que detecta ciclos antes de crear unidad
  - **Solución:** Función `detectCycle()` que recorre ancestros

#### 🟡 Importantes

- [ ] **Endpoints de bulk operations** (Claude, Grok)
  - **Ejemplo:** Crear múltiples unidades de una vez
  - **Impacto:** Medio, puede hacerse una por una

- [ ] **Audit logging** (Claude)
  - **Qué falta:** Logging de cambios administrativos

#### 🟢 Opcionales

- [ ] **Export de jerarquía a CSV/Excel** (Claude)
  - **Impacto:** Bajo, nice-to-have

---

### 🤖 worker

#### 🔴 Críticos

- [ ] **Especificación completa** (Gemini, Grok)
  - **Detectado por:** Claude ❌ | Gemini ✅ | Grok ✅
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** BLOQUEANTE
  - **Ubicación faltante:** `spec-02-worker/` (completamente vacía)
  - **Qué falta:** Lógica de procesamiento, prompts, schemas
  - **Impacto:** Imposible implementar worker
  - **Solución:** Completar spec-02 con toda la documentación

- [ ] **Implementación de PDF processing** (Claude, Gemini)
  - **Ubicación:** `worker/internal/processors/pdf.go`
  - **Qué falta:** Código que extrae texto de PDF
  - **Solución:** Usar `pdftotext` o librería Go como `unidoc`

- [ ] **Prompts de OpenAI versionados** (Claude, Grok)
  - **Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅
  - **Ubicación:** `worker/internal/prompts/`
  - **Qué falta:** Archivos de prompts separados del código
  - **Solución:**
    ```markdown
    # prompts/summary_v1.md
    Eres un asistente educativo experto...
    [prompt completo]
    ```

- [ ] **Retry logic con DLQ** (Claude)
  - **Qué falta:** Código que maneja reintentos y mueve a DLQ
  - **Solución:**
    ```go
    func (p *Processor) ProcessWithRetry(ctx context.Context, msg Message) error {
      for i := 0; i < maxRetries; i++ {
        if err := p.process(ctx, msg); err == nil {
          return nil
        }
        time.Sleep(backoff(i))
      }
      return p.moveToDLQ(msg)
    }
    ```

#### 🟡 Importantes

- [ ] **Métricas de costos de OpenAI** (Claude)
  - **Qué falta:** Tracking de tokens usados y costo estimado
  - **Solución:** Guardar en MongoDB en cada procesamiento

- [ ] **Validación de calidad de resúmenes** (Claude)
  - **Qué falta:** Código que valida longitud, estructura, idioma

- [ ] **Processing timeouts** (Claude)
  - **Qué falta:** Timeouts por tipo de contenido

#### 🟢 Opcionales

- [ ] **OCR fallback para PDFs escaneados** (Claude)
  - **Impacto:** Medio, puede implementarse post-MVP

---

### 🐳 dev-environment

#### 🔴 Críticos

- [ ] **Especificación completa** (Gemini, Grok)
  - **Detectado por:** Claude ❌ | Gemini ✅ | Grok ✅
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Prioridad:** BLOQUEANTE
  - **Ubicación faltante:** `spec-05-dev-environment/` (completamente vacía)
  - **Qué falta:** Docker Compose, scripts, seeds
  - **Impacto:** No se puede desarrollar localmente
  - **Solución:** Completar spec-05 con toda la documentación

- [ ] **docker-compose.yml completo** (Claude, Gemini, Grok)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ✅
  - **Consenso:** 🟢 ALTO (3/3)
  - **Prioridad:** BLOQUEANTE
  - **Ubicación:** `dev-environment/docker-compose.yml`
  - **Qué falta:** Archivo completo con todos los servicios
  - **Impacto:** No se puede levantar infraestructura local

- [ ] **Scripts automatizados** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Ubicación:** `dev-environment/scripts/`
  - **Qué falta:** setup.sh, seed-data.sh, stop.sh, clean.sh
  - **Impacto:** Setup manual es complejo

- [ ] **Seeds de datos** (Claude, Gemini)
  - **Detectado por:** Claude ✅ | Gemini ✅ | Grok ❌
  - **Consenso:** 🟡 MEDIO (2/3)
  - **Ubicación:** `dev-environment/seeds/`
  - **Qué falta:** Scripts SQL para PostgreSQL, JS para MongoDB
  - **Impacto:** Desarrollo local requiere crear datos manualmente

- [ ] **Scripts init.sql consolidados** (Gemini)
  - **Qué falta:** Scripts que crean TODAS las tablas del ecosistema
  - **Impacto:** No se puede inicializar BD completa de una vez

#### 🟡 Importantes

- [ ] **Profiles de docker-compose** (Claude)
  - **Qué falta:** Configuración de profiles (full, db-only, etc.)
  - **Solución:**
    ```yaml
    services:
      api-mobile:
        profiles: ["full", "api"]
      postgres:
        profiles: ["full", "db-only"]
    ```

- [ ] **Healthchecks en docker-compose** (Claude)
  - **Qué falta:** Healthchecks para saber cuándo servicios están listos

#### 🟢 Opcionales

- [ ] **Makefile con comandos comunes** (Claude)
  - **Ejemplo:** `make setup`, `make test`, `make clean`
  - **Impacto:** Bajo, nice-to-have

---

## 📊 Matriz de Prioridad

### Por Proyecto y Criticidad

| Proyecto | Críticos | Importantes | Opcionales | Total |
|----------|----------|-------------|-----------|-------|
| **Transversal** (DB, API, Config) | 15 | 14 | 5 | 34 |
| **shared** | 4 | 4 | 1 | 9 |
| **api-mobile** | 3 | 2 | 1 | 6 |
| **api-admin** | 3 | 2 | 1 | 6 |
| **worker** | 4 | 3 | 1 | 8 |
| **dev-environment** | 6 | 2 | 1 | 9 |
| **TOTAL** | **35** | **27** | **10** | **72** |

### Top 10 - Información Faltante Más Crítica

1. **Especificación completa de edugo-shared** - 🟢 ALTO consenso (3/3)
2. **Contratos de eventos RabbitMQ** - 🟢 ALTO consenso (3/3)
3. **docker-compose.yml completo** - 🟢 ALTO consenso (3/3)
4. **Archivo `.env.example` centralizado** - 🟢 ALTO consenso (3/3)
5. **Especificaciones completas de api-admin y worker** - 🟡 MEDIO consenso (2/3)
6. **Schema completo de tablas `users` y `materials`** - 🟡 MEDIO consenso (2/3)
7. **OpenAPI 3.0 completo para APIs** - 🟡 MEDIO consenso (2/3)
8. **Scripts automatizados de dev-environment** - 🟡 MEDIO consenso (2/3)
9. **Kubernetes manifests** - 🟡 MEDIO consenso (2/3)
10. **CI/CD pipelines completos** - 🟡 MEDIO consenso (2/3)

---

## ✅ Plan de Acción Recomendado

### Fase 1: Fundamentos (ANTES de iniciar desarrollo) - 12-16 horas

1. ✅ **Completar spec-04-shared**
   - Módulos: logger, config, errors, database, auth, messaging
   - Interfaces públicas
   - CHANGELOG.md (v1.0.0 → v1.3.0 → v1.4.0)
   - Tiempo: 4-6 horas

2. ✅ **Crear contratos de eventos RabbitMQ**
   - Schemas JSON para todos los eventos
   - Configuración de exchanges y queues
   - Versionamiento de eventos
   - Tiempo: 3-4 horas

3. ✅ **Crear `.env.example` centralizado**
   - Todas las variables de los 5 proyectos
   - Documentar obligatorias vs opcionales
   - Valores default
   - Tiempo: 2-3 horas

4. ✅ **Crear docker-compose.yml completo**
   - 6+ servicios configurados
   - Profiles (full, db-only, api-only)
   - Healthchecks
   - Tiempo: 3-4 horas

### Fase 2: Especificaciones (Durante desarrollo) - 24-32 horas

5. ✅ **Completar spec-02-worker**
   - Lógica de procesamiento
   - Prompts de OpenAI
   - Schemas MongoDB
   - Tiempo: 8-10 horas

6. ✅ **Completar spec-03-api-administracion**
   - Schemas SQL de jerarquía
   - Endpoints CRUD
   - Queries recursivas
   - Tiempo: 8-10 horas

7. ✅ **Completar spec-05-dev-environment**
   - Scripts automatizados
   - Seeds de datos
   - Documentación operacional
   - Tiempo: 6-8 horas

8. ✅ **Documentar schemas de `users` y `materials`**
   - Tablas compartidas completas
   - Ownership definido
   - Tiempo: 2-3 horas

### Fase 3: Infraestructura (Durante Sprint 06) - 16-20 horas

9. ✅ **Crear Kubernetes manifests**
   - Deployments, Services, Ingress
   - ConfigMaps, Secrets
   - Tiempo: 6-8 horas

10. ✅ **Crear CI/CD pipelines completos**
    - GitHub Actions workflows
    - Test, build, deploy
    - Tiempo: 6-8 horas

11. ✅ **Documentar runbooks**
    - Incidentes comunes
    - Procedimientos de solución
    - Tiempo: 4-5 horas

**Tiempo total estimado:** 52-68 horas (~1.5-2 semanas)

---

**Fin del Documento de Información Faltante Consolidada**
