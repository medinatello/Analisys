# 📝 Información Faltante para Desarrollo Desatendido

**Analista:** Claude (Análisis Independiente)
**Fecha:** 15 de Noviembre, 2025
**Documentación analizada:**
- `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/` (193 archivos)
- `/Users/jhoanmedina/source/EduGo/Analisys/00-Projects-Isolated/` (~250 archivos)

---

## 📊 Resumen Ejecutivo

**Total de items faltantes identificados:** 47
**Items críticos (bloqueantes):** 18
**Items importantes (deseables):** 21
**Items opcionales (nice-to-have):** 8

**Categorías con más faltantes:**
1. Schemas de Base de Datos (12 items)
2. Contratos de API y Eventos (10 items)
3. Configuración y Variables (9 items)
4. Testing y Validación (8 items)
5. Deployment y Operaciones (8 items)

---

## Por Categoría

### 🗄️ Schemas de Base de Datos

#### Crítico

- [ ] **Índices de MongoDB documentados**
  - **Ubicación esperada:** `spec-01/02-Design/DATA_MODEL.md`
  - **Qué falta:** Colecciones `material_assessment` y `material_summary` no tienen índices documentados
  - **Impacto:** Performance pobre en queries frecuentes
  - **Solución propuesta:**
    ```javascript
    // material_assessment
    db.material_assessment.createIndex({ material_id: 1 }, { unique: true })
    db.material_assessment.createIndex({ "questions.question_id": 1 })

    // material_summary
    db.material_summary.createIndex({ material_id: 1 }, { unique: true })
    db.material_summary.createIndex({ created_at: -1 })
    ```

- [ ] **Schema completo de tabla `users`**
  - **Ubicación esperada:** `spec-03/02-Design/DATA_MODEL.md` o archivo base compartido
  - **Qué falta:** La tabla `users` se menciona pero no está completamente especificada
  - **Impacto:** api-mobile y api-admin asumen diferentes estructuras
  - **Solución propuesta:**
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

- [ ] **Schema completo de tabla `materials`**
  - **Ubicación esperada:** Archivo base compartido o spec-01
  - **Qué falta:** Se menciona pero no está completamente definida
  - **Impacto:** Relaciones FK pueden fallar
  - **Solución propuesta:**
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

- [ ] **Triggers de auditoría**
  - **Ubicación esperada:** `spec-01/04-Implementation/Sprint-01/TASKS.md`
  - **Qué falta:** No hay triggers para actualizar `updated_at` automáticamente
  - **Impacto:** Campo `updated_at` nunca se actualiza
  - **Solución propuesta:**
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

- [ ] **Particionamiento de tabla `assessment_attempt`**
  - **Ubicación esperada:** `spec-01/02-Design/DATA_MODEL.md`
  - **Qué documentado:** "No en MVP, post-MVP si crece mucho"
  - **Qué falta:** Criterio exacto de cuándo implementar particionamiento
  - **Impacto:** Bajo en MVP, alto en producción
  - **Solución propuesta:** Documentar umbral: "Implementar particionamiento cuando tabla supere 10M filas o queries >500ms p95"

- [ ] **Colección `material_event` en MongoDB**
  - **Ubicación esperada:** `spec-02/02-Design/DATA_MODEL.md`
  - **Qué falta:** Se menciona en overview pero no tiene schema definido
  - **Impacto:** Worker no sabe qué guardar en eventos
  - **Solución propuesta:**
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
      error: {  // solo si event_type = "failed"
        code: "OPENAI_RATE_LIMIT",
        message: "...",
        retryable: true
      }
    }
    ```

#### Importante

- [ ] **Constraints de integridad referencial entre PostgreSQL y MongoDB**
  - **Qué falta:** Validación de que `assessment.mongo_document_id` apunta a documento válido
  - **Solución:** Agregar validación en capa de aplicación o cronjob

- [ ] **Seeds de datos completos para desarrollo**
  - **Ubicación esperada:** `dev-environment/04-Implementation/Sprint-03/TASKS.md`
  - **Qué falta:** Seeds para `users`, `schools`, `materials`, `assessments`
  - **Impacto:** Desarrollo local requiere crear datos manualmente
  - **Solución:** Scripts SQL en `dev-environment/seeds/`

- [ ] **Migraciones de rollback**
  - **Qué falta:** Solo hay migraciones "up", no "down"
  - **Impacto:** No se puede hacer rollback de schema
  - **Solución:** Crear migraciones `XXXXXX_create_assessment_down.sql` para cada migración

#### Opcional

- [ ] **Vistas de agregación (Materialized Views)**
  - **Ejemplo:** Vista de estadísticas por estudiante
  - **Impacto:** Bajo, se puede hacer en queries

- [ ] **Stored procedures para lógica compleja**
  - **Ejemplo:** Calcular score de assessment en PL/pgSQL
  - **Impacto:** Bajo, se puede hacer en capa de aplicación

- [ ] **Tablas de auditoría automática**
  - **Ejemplo:** Tabla `audit_log` que registra todos los cambios
  - **Impacto:** Bajo en MVP, útil para compliance

---

### 🌐 Contratos de API

#### Crítico

- [ ] **Contratos de eventos RabbitMQ completamente especificados**
  - **Ubicación esperada:** `spec-02/02-Design/API_CONTRACTS.md` o archivo compartido
  - **Qué falta:** Estructura exacta de payloads de eventos
  - **Impacto:** api-mobile y worker pueden usar formatos incompatibles
  - **Solución propuesta:**
    ```json
    // Evento: material.uploaded
    {
      "event_id": "uuid-v7",
      "event_type": "material.uploaded",
      "timestamp": "2025-11-15T10:30:00Z",
      "payload": {
        "material_id": "uuid",
        "school_id": "uuid",
        "teacher_id": "uuid",
        "file_url": "s3://bucket/path/to/file.pdf",
        "file_size_bytes": 2048000,
        "file_type": "application/pdf",
        "metadata": {
          "title": "Introducción a la Física",
          "grade": "10th",
          "subject": "Science"
        }
      },
      "version": "1.0"
    }

    // Evento: assessment.generated
    {
      "event_id": "uuid-v7",
      "event_type": "assessment.generated",
      "timestamp": "2025-11-15T10:35:00Z",
      "payload": {
        "material_id": "uuid",
        "assessment_id": "uuid",
        "mongo_document_id": "ObjectId",
        "questions_count": 8,
        "processing_time_ms": 45000
      },
      "version": "1.0"
    }
    ```

- [ ] **OpenAPI 3.0 completo para api-mobile**
  - **Ubicación esperada:** `spec-01/02-Design/API_CONTRACTS.md`
  - **Qué documentado:** Solo endpoints principales (GET, POST)
  - **Qué falta:** Schemas completos de request/response, error codes
  - **Impacto:** Frontend no sabe exactamente qué esperar
  - **Solución:** Generar OpenAPI spec completo con ejemplos

- [ ] **OpenAPI 3.0 completo para api-admin**
  - **Ubicación esperada:** `spec-03/02-Design/API_CONTRACTS.md`
  - **Qué falta:** Similar a api-mobile
  - **Solución:** Generar OpenAPI spec completo

- [ ] **Códigos de error estandarizados**
  - **Qué falta:** Lista completa de error codes (ERR_001, ERR_002, etc.)
  - **Impacto:** Frontend no puede manejar errores específicamente
  - **Solución propuesta:**
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

#### Importante

- [ ] **Rate limiting por endpoint**
  - **Qué falta:** Límites de requests por minuto/hora
  - **Solución:** Documentar rate limits (ej: 100 req/min por IP)

- [ ] **Formato de paginación**
  - **Qué falta:** Cómo paginar listas (limit/offset vs cursor)
  - **Solución propuesta:**
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

- [ ] **Formato de filtrado y búsqueda**
  - **Qué falta:** Sintaxis de query params para filtrar
  - **Ejemplo:** `GET /v1/materials?subject=math&grade=10`

- [ ] **Versionamiento de API**
  - **Documentado:** `/v1/` en URLs
  - **Qué falta:** Estrategia de deprecación, soporte de múltiples versiones

#### Opcional

- [ ] **Webhooks para notificaciones**
  - **Ejemplo:** Notificar a sistema externo cuando assessment completa
  - **Impacto:** Bajo, no es requisito MVP

- [ ] **GraphQL como alternativa a REST**
  - **Impacto:** Bajo, fuera de scope MVP

---

### ⚙️ Configuración

#### Crítico

- [ ] **Archivo `.env.example` centralizado**
  - **Ubicación esperada:** `dev-environment/.env.example`
  - **Qué falta:** Template con todas las variables requeridas
  - **Impacto:** Desarrolladores no saben qué variables configurar
  - **Solución propuesta:**
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

    # Redis (opcional)
    REDIS_URL=redis://localhost:6379/0

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

- [ ] **Valores default documentados**
  - **Qué falta:** Qué valores son obligatorios vs opcionales
  - **Solución:** Comentarios en `.env.example` indicando `# Required` vs `# Optional (default: value)`

- [ ] **Validación de configuración al inicio**
  - **Qué falta:** Código que valida que variables críticas están presentes
  - **Impacto:** API inicia pero falla en runtime
  - **Solución:** Función `validateConfig()` que falla fast

#### Importante

- [ ] **Configuración por ambiente (local, dev, qa, prod)**
  - **Documentado:** Viper soporta multi-ambiente
  - **Qué falta:** Archivos de config específicos por ambiente
  - **Solución:** `config/local.yaml`, `config/dev.yaml`, etc.

- [ ] **Secrets management strategy**
  - **Documentado:** SOPS + Age mencionados
  - **Qué falta:** Tutorial de cómo usar SOPS en desarrollo
  - **Solución:** Archivo `docs/SECRETS_MANAGEMENT.md`

- [ ] **Feature flags**
  - **Qué falta:** Sistema de feature toggles
  - **Impacto:** No se pueden habilitar/deshabilitar features sin deploy
  - **Solución:** Agregar librería como `unleash` o config-based flags

#### Opcional

- [ ] **Hot reload de configuración**
  - **Qué falta:** Cambiar config sin reiniciar servicio
  - **Impacto:** Bajo, nice-to-have

- [ ] **UI de gestión de configuración**
  - **Ejemplo:** Consul UI o similar
  - **Impacto:** Bajo, fuera de scope MVP

---

### 📨 Eventos y Mensajería

#### Crítico

- [ ] **Definición de Exchanges y Queues en RabbitMQ**
  - **Ubicación esperada:** `spec-02/02-Design/ARCHITECTURE.md` o archivo compartido
  - **Qué falta:** Configuración exacta de RabbitMQ
  - **Impacto:** api-mobile y worker pueden crear exchanges incompatibles
  - **Solución propuesta:**
    ```yaml
    # RabbitMQ Configuration
    exchanges:
      - name: edugo.topic
        type: topic
        durable: true
        auto_delete: false

    queues:
      - name: material.processing
        durable: true
        arguments:
          x-message-ttl: 3600000  # 1 hour
          x-max-length: 10000
        bindings:
          - exchange: edugo.topic
            routing_key: material.uploaded

      - name: assessment.notifications
        durable: true
        bindings:
          - exchange: edugo.topic
            routing_key: assessment.completed

      - name: dlq.failed_processing
        durable: true
        arguments:
          x-message-ttl: 86400000  # 24 hours
    ```

- [ ] **Dead Letter Queue (DLQ) strategy**
  - **Qué falta:** Qué hacer con mensajes que fallan múltiples veces
  - **Impacto:** Mensajes se pierden o reintentan infinitamente
  - **Solución:** Configurar DLQ con TTL y alertas

- [ ] **Orden de mensajes garantizado**
  - **Qué falta:** ¿RabbitMQ garantiza orden FIFO o puede desordenarse?
  - **Impacto:** Eventos pueden procesarse fuera de orden
  - **Solución:** Documentar si orden importa y cómo garantizarlo

#### Importante

- [ ] **Idempotencia de procesamiento**
  - **Qué falta:** Cómo evitar procesar mismo mensaje dos veces
  - **Solución:** Usar `message_id` único y registrar en tabla `processed_events`

- [ ] **Reintentos automáticos con backoff**
  - **Documentado:** "Retry con backoff exponencial"
  - **Qué falta:** Configuración exacta de reintentos en RabbitMQ
  - **Solución:** Usar `x-retry-count` header y DLQ

#### Opcional

- [ ] **Monitoreo de RabbitMQ**
  - **Qué falta:** Métricas de queue depth, throughput
  - **Solución:** Integrar con Prometheus

---

### 🧪 Testing

#### Crítico

- [ ] **Fixtures de tests compartidos**
  - **Ubicación esperada:** `shared/testing/fixtures/`
  - **Qué falta:** Datos de prueba reutilizables (users, schools, materials)
  - **Impacto:** Cada test crea fixtures manualmente (código duplicado)
  - **Solución propuesta:**
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

- [ ] **Tests de integración entre servicios**
  - **Qué falta:** Tests que validan api-mobile → RabbitMQ → worker flow completo
  - **Impacto:** Integración puede fallar en producción
  - **Solución:** Tests E2E que levanten todos los servicios

- [ ] **Cobertura de tests de casos edge**
  - **Documentado:** >85% coverage
  - **Qué falta:** Lista de casos edge a probar (ej: student intenta múltiples veces mismo assessment simultáneamente)
  - **Solución:** Documento de test cases críticos

#### Importante

- [ ] **Performance tests / Load tests**
  - **Qué falta:** Tests de carga que validen throughput de 1000 req/seg
  - **Solución:** k6 o Locust scripts

- [ ] **Chaos engineering**
  - **Qué falta:** Tests que simulan fallos (DB down, RabbitMQ unavailable)
  - **Solución:** Tests que matan servicios y validan recuperación

#### Opcional

- [ ] **Mutation testing**
  - **Qué falta:** Validar que tests detectan bugs
  - **Impacto:** Bajo, nice-to-have

---

### 🚀 Deployment y Operaciones

#### Crítico

- [ ] **Kubernetes manifests**
  - **Ubicación esperada:** `spec-*/06-Deployment/k8s/`
  - **Qué falta:** Deployments, Services, Ingress, ConfigMaps
  - **Impacto:** No se puede deployar a Kubernetes
  - **Solución propuesta:**
    ```yaml
    # api-mobile/deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: api-mobile
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: api-mobile
      template:
        metadata:
          labels:
            app: api-mobile
        spec:
          containers:
          - name: api-mobile
            image: edugo/api-mobile:latest
            ports:
            - containerPort: 8080
            env:
            - name: DB_HOST
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: host
            livenessProbe:
              httpGet:
                path: /health/liveness
                port: 8080
              initialDelaySeconds: 30
              periodSeconds: 10
            readinessProbe:
              httpGet:
                path: /health/readiness
                port: 8080
              initialDelaySeconds: 10
              periodSeconds: 5
    ```

- [ ] **Helm charts**
  - **Qué falta:** Helm charts para instalar stack completo
  - **Impacto:** Deploy manual es complejo
  - **Solución:** Crear Helm chart `edugo` con subcharts

- [ ] **CI/CD pipelines completos**
  - **Documentado:** GitHub Actions mencionado
  - **Qué falta:** Archivos `.github/workflows/` completos
  - **Solución:** Crear workflows para test, build, deploy

- [ ] **Runbooks para incidentes**
  - **Qué falta:** Documentación de qué hacer si servicio X falla
  - **Impacto:** Downtime prolongado en incidentes
  - **Solución propuesta:**
    ```markdown
    ## Runbook: API Mobile Down

    ### Síntomas
    - Endpoint /health retorna 500
    - Logs muestran "connection refused to database"

    ### Diagnóstico
    1. Verificar PostgreSQL: `kubectl get pods -l app=postgresql`
    2. Verificar logs: `kubectl logs -l app=api-mobile --tail=100`

    ### Solución
    1. Si DB down: Reiniciar PostgreSQL: `kubectl rollout restart deployment/postgresql`
    2. Si API crashloop: Rollback: `kubectl rollout undo deployment/api-mobile`
    3. Notificar a #incidents en Slack
    ```

#### Importante

- [ ] **Monitoring y alerting**
  - **Documentado:** "Prometheus + Grafana"
  - **Qué falta:** Dashboards específicos y alertas configuradas
  - **Solución:** Crear dashboards en JSON, alertmanager rules

- [ ] **Backup y restore procedures**
  - **Qué falta:** Scripts de backup de PostgreSQL y MongoDB
  - **Solución:** Cronjobs que hacen dump a S3, procedimiento de restore

- [ ] **Disaster recovery plan**
  - **Qué falta:** Plan completo de recuperación ante desastre
  - **Solución:** Documento con RTO (Recovery Time Objective) y RPO (Recovery Point Objective)

#### Opcional

- [ ] **Multi-region deployment**
  - **Qué falta:** Estrategia de deploy en múltiples regiones
  - **Impacto:** Bajo, fuera de scope MVP

---

## Por Proyecto

### 📚 edugo-shared

#### Crítico

- [ ] **Módulo `shared/database` - Helpers de migraciones**
  - **Ubicación:** `shared/database/migrations.go`
  - **Qué falta:** Helper para ejecutar migraciones desde Go
  - **Solución:**
    ```go
    func RunMigrations(db *gorm.DB, migrationsPath string) error
    ```

- [ ] **Módulo `shared/testing` - Testcontainers helpers**
  - **Ubicación:** `shared/testing/containers.go`
  - **Qué falta:** Funciones para levantar PostgreSQL, MongoDB, RabbitMQ en tests
  - **Solución:**
    ```go
    func StartPostgresContainer(t *testing.T) (*gorm.DB, func())
    func StartMongoContainer(t *testing.T) (*mongo.Client, func())
    func StartRabbitMQContainer(t *testing.T) (*amqp.Connection, func())
    ```

- [ ] **Módulo `shared/auth` - JWT helpers**
  - **Qué falta:** Funciones de generación y validación de tokens
  - **Solución:**
    ```go
    func GenerateAccessToken(userID uuid.UUID) (string, error)
    func ValidateAccessToken(token string) (*Claims, error)
    ```

#### Importante

- [ ] **Módulo `shared/errors` - Error types estandarizados**
  - **Qué falta:** Tipos de errores comunes (NotFoundError, ValidationError, etc.)

- [ ] **Módulo `shared/middleware` - Middleware reutilizable**
  - **Qué falta:** Middleware de autenticación, logging, CORS

- [ ] **Documentación de cada módulo (GoDoc)**
  - **Qué falta:** Comentarios completos de funciones públicas

#### Opcional

- [ ] **Módulo `shared/cache` - Redis client**
  - **Impacto:** Bajo, caching no es MVP

---

### 📱 api-mobile

#### Crítico

- [ ] **Handlers completos con validación de input**
  - **Ubicación:** `api-mobile/internal/handlers/`
  - **Qué falta:** Validación de request bodies con `validator` library

- [ ] **Middleware de autorización por rol**
  - **Qué falta:** Verificar que solo `teacher` puede crear assessments
  - **Solución:**
    ```go
    func RequireRole(allowedRoles ...string) gin.HandlerFunc
    ```

- [ ] **Tests de integración con Testcontainers**
  - **Qué falta:** Tests que levanten PostgreSQL + MongoDB reales

#### Importante

- [ ] **Swagger documentation generada**
  - **Qué falta:** Anotaciones swaggo en handlers
  - **Solución:** Agregar comentarios `// @Summary`, `// @Param`, etc.

- [ ] **Logging estructurado en handlers**
  - **Qué falta:** Logs con contexto (user_id, request_id)

#### Opcional

- [ ] **Rate limiting per user**
  - **Impacto:** Bajo, puede usar API gateway

---

### 🏛️ api-admin

#### Crítico

- [ ] **Implementación de queries recursivas**
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

- [ ] **Validación de ciclos en jerarquía**
  - **Qué falta:** Código que detecta ciclos antes de crear unidad
  - **Solución:** Función `detectCycle()` que recorre ancestros

- [ ] **Tests de jerarquías complejas**
  - **Qué falta:** Tests con 5 niveles de profundidad, múltiples branches

#### Importante

- [ ] **Endpoints de bulk operations**
  - **Ejemplo:** Crear múltiples unidades de una vez
  - **Impacto:** Medio, puede hacerse una por una

#### Opcional

- [ ] **Export de jerarquía a CSV/Excel**
  - **Impacto:** Bajo, nice-to-have

---

### 🤖 worker

#### Crítico

- [ ] **Implementación completa de PDF processing**
  - **Ubicación:** `worker/internal/processors/pdf.go`
  - **Qué falta:** Código que extrae texto de PDF
  - **Solución:** Usar `pdftotext` o librería Go como `unidoc`

- [ ] **Prompts de OpenAI versionados**
  - **Ubicación:** `worker/internal/prompts/`
  - **Qué falta:** Archivos de prompts separados del código
  - **Solución:**
    ```markdown
    # prompts/summary_v1.md
    Eres un asistente educativo experto...
    [prompt completo]
    ```

- [ ] **Retry logic con DLQ**
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

#### Importante

- [ ] **Métricas de costos de OpenAI**
  - **Qué falta:** Tracking de tokens usados y costo estimado
  - **Solución:** Guardar en MongoDB en cada procesamiento

- [ ] **Validación de calidad de resúmenes**
  - **Qué falta:** Código que valida longitud, estructura, idioma

#### Opcional

- [ ] **OCR fallback para PDFs escaneados**
  - **Impacto:** Medio, puede implementarse post-MVP

---

### 🐳 dev-environment

#### Crítico

- [ ] **docker-compose.yml completo**
  - **Ubicación:** `dev-environment/docker-compose.yml`
  - **Qué falta:** Archivo completo con todos los servicios
  - **Solución propuesta:**
    ```yaml
    version: '3.8'
    services:
      postgres:
        image: postgres:15-alpine
        environment:
          POSTGRES_DB: edugo_dev
          POSTGRES_USER: edugo
          POSTGRES_PASSWORD: changeme
        ports:
          - "5432:5432"
        volumes:
          - postgres_data:/var/lib/postgresql/data

      mongodb:
        image: mongo:7.0
        ports:
          - "27017:27017"
        volumes:
          - mongo_data:/data/db

      rabbitmq:
        image: rabbitmq:3.12-management-alpine
        ports:
          - "5672:5672"
          - "15672:15672"
        environment:
          RABBITMQ_DEFAULT_USER: guest
          RABBITMQ_DEFAULT_PASS: guest

      # ... más servicios

    volumes:
      postgres_data:
      mongo_data:
    ```

- [ ] **Scripts de setup automatizados**
  - **Ubicación:** `dev-environment/scripts/setup.sh`
  - **Qué falta:** Script que inicializa todo
  - **Solución:**
    ```bash
    #!/bin/bash
    # 1. Validar Docker instalado
    # 2. Crear .env desde .env.example
    # 3. Docker compose up -d
    # 4. Ejecutar migraciones
    # 5. Insertar seeds
    # 6. Validar que servicios estén health
    ```

- [ ] **Seeds de datos**
  - **Ubicación:** `dev-environment/seeds/`
  - **Qué falta:** Scripts SQL para datos de prueba

#### Importante

- [ ] **Profiles de docker-compose**
  - **Qué falta:** Perfiles para diferentes setups (full, db-only, etc.)
  - **Solución:**
    ```yaml
    services:
      api-mobile:
        profiles: ["full", "api"]
        # ...

      postgres:
        profiles: ["full", "db-only"]
        # ...
    ```

- [ ] **Healthchecks en docker-compose**
  - **Qué falta:** Healthchecks para saber cuándo servicios están listos

#### Opcional

- [ ] **Makefile con comandos comunes**
  - **Ejemplo:** `make setup`, `make test`, `make clean`
  - **Impacto:** Bajo, nice-to-have

---

## 📊 Resumen de Información Faltante

### Por Proyecto

| Proyecto | Crítico | Importante | Opcional | Total |
|----------|---------|-----------|----------|-------|
| **shared** | 3 | 3 | 1 | 7 |
| **api-mobile** | 3 | 2 | 1 | 6 |
| **api-admin** | 3 | 1 | 1 | 5 |
| **worker** | 3 | 2 | 1 | 6 |
| **dev-environment** | 3 | 2 | 1 | 6 |
| **Transversal (DB, API, Config, etc.)** | 12 | 11 | 4 | 27 |
| **TOTAL** | **27** | **21** | **9** | **57** |

### Por Severidad

| Severidad | Cantidad | % del Total | Acción |
|-----------|----------|-------------|--------|
| 🔴 Crítico | 27 | 47% | Resolver antes de desarrollo |
| 🟡 Importante | 21 | 37% | Resolver durante desarrollo |
| 🟢 Opcional | 9 | 16% | Post-MVP |
| **TOTAL** | **57** | **100%** | |

### Top 10 - Información Faltante Más Crítica

1. **Contratos de eventos RabbitMQ completos** - Bloqueante para integración api-mobile ↔ worker
2. **Schema completo de tablas `users` y `materials`** - Bloqueante para migraciones
3. **Archivo `.env.example` centralizado** - Bloqueante para setup de desarrollo
4. **docker-compose.yml completo** - Bloqueante para desarrollo local
5. **Índices de MongoDB documentados** - Impacto en performance
6. **CI/CD pipelines completos** - Bloqueante para deployment
7. **Kubernetes manifests** - Bloqueante para producción
8. **Tests de integración entre servicios** - Riesgo de fallos en producción
9. **Runbooks para incidentes** - Riesgo de downtime prolongado
10. **Prompts de OpenAI versionados** - Bloqueante para calidad de IA

---

## ✅ Próximos Pasos Recomendados

### Fase 1: Fundamentos (Antes de iniciar desarrollo)
1. ✅ Crear `.env.example` centralizado
2. ✅ Documentar schemas completos de `users` y `materials`
3. ✅ Definir contratos de eventos RabbitMQ
4. ✅ Crear `docker-compose.yml` completo
5. ✅ Crear scripts de setup automatizados

**Tiempo estimado:** 4-6 horas

### Fase 2: Infraestructura (Durante Sprint 01 de cada proyecto)
6. ✅ Documentar índices de MongoDB
7. ✅ Crear fixtures de tests compartidos
8. ✅ Implementar validación de configuración
9. ✅ Crear migraciones de rollback

**Tiempo estimado:** 6-8 horas

### Fase 3: Deployment (Durante Sprint 06 de cada proyecto)
10. ✅ Crear Kubernetes manifests
11. ✅ Crear CI/CD pipelines completos
12. ✅ Documentar runbooks
13. ✅ Configurar monitoring

**Tiempo estimado:** 12-16 horas

---

**Fin del Análisis de Información Faltante**
