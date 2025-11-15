# 🎯 Plan de Acción Correctiva - EduGo

**Fecha:** 15 de Noviembre, 2025  
**Objetivo:** Elevar documentación de 84% → 96% de completitud  
**Tiempo total estimado:** 2-4 días (16-32 horas)  
**Priorización:** Basada en consenso de 5 agentes IA

---

## 📊 Resumen Ejecutivo del Plan

Este plan organiza **todas las acciones correctivas** en 3 fases priorizadas por:
1. **Impacto:** Qué tan bloqueante es el problema
2. **Consenso:** Cuántos agentes lo detectaron (5/5 = crítico)
3. **Dependencias:** Qué debe resolverse primero para desbloquear lo demás

**Estructura:**
- **Fase 1:** BLOQUEANTES ABSOLUTOS (debe completarse ANTES de cualquier código)
- **Fase 2:** DECISIONES ARQUITECTÓNICAS (durante Sprints 01-02)
- **Fase 3:** DEPLOYMENT Y CALIDAD (durante Sprints 05-06)

---

## 🚨 FASE 1: Bloqueantes Absolutos (URGENTE)

**Objetivo:** Desbloquear inicio de desarrollo  
**Tiempo:** 2-3 días (16-24 horas)  
**Cuándo ejecutar:** ANTES de escribir cualquier línea de código

---

### P0-1: Especificar edugo-shared Completamente

**Prioridad:** P0 (MÁXIMA - Bloqueante absoluto)  
**Detectado por:** 5/5 agentes (Claude, Gemini, Grok, Opus, Codex)  
**Tiempo estimado:** 6-8 horas

#### Problema que resuelve
- Todos los proyectos dependen de `edugo-shared` pero no está especificado
- Versiones inconsistentes (v1.3.0 vs v1.4.0)
- Módulos mencionados pero no detallados
- Imposible definir `go.mod` sin saber qué exporta shared

#### Archivos a crear/modificar

1. **spec-04-shared/02-Design/MODULE_INTERFACES.md**
   ```markdown
   # Interfaces de Módulos de edugo-shared
   
   ## Módulo: logger
   ```go
   package logger
   
   import "github.com/sirupsen/logrus"
   
   // NewLogger crea logger estructurado con contexto de servicio
   func NewLogger(serviceName, version string) *logrus.Entry
   
   // WithRequestID agrega request_id para correlación
   func WithRequestID(log *logrus.Entry, requestID string) *logrus.Entry
   ```
   
   ## Módulo: config
   ```go
   package config
   
   import "github.com/spf13/viper"
   
   // Config estructura de configuración global
   type Config struct {
       Database DatabaseConfig
       MongoDB  MongoConfig
       RabbitMQ RabbitMQConfig
       JWT      JWTConfig
   }
   
   // Load carga config desde archivo y env vars
   func Load(environment string) (*Config, error)
   
   // Validate valida que variables críticas están presentes
   func (c *Config) Validate() error
   ```
   
   ## Módulo: database
   ```go
   package database
   
   import "gorm.io/gorm"
   
   // NewPostgresConnection crea conexión con pool
   func NewPostgresConnection(config DatabaseConfig) (*gorm.DB, error)
   
   // NewMongoConnection crea cliente MongoDB
   func NewMongoConnection(config MongoConfig) (*mongo.Client, error)
   ```
   
   ## Módulo: auth
   ```go
   package auth
   
   // GenerateAccessToken genera JWT con claims
   func GenerateAccessToken(userID uuid.UUID, role string) (string, error)
   
   // ValidateAccessToken valida y parsea JWT
   func ValidateAccessToken(token string) (*Claims, error)
   ```
   
   ## Módulo: messaging
   ```go
   package messaging
   
   // NewProducer crea productor de RabbitMQ
   func NewProducer(config RabbitMQConfig) (*Producer, error)
   
   // Publish publica mensaje a exchange con routing key
   func (p *Producer) Publish(exchange, routingKey string, payload interface{}) error
   
   // NewConsumer crea consumidor
   func NewConsumer(config RabbitMQConfig, queueName string) (*Consumer, error)
   
   // Consume consume mensajes con handler
   func (c *Consumer) Consume(handler func(Message) error) error
   ```
   ```

2. **spec-04-shared/CHANGELOG.md**
   ```markdown
   # Changelog - edugo-shared
   
   ## [v1.4.0] - 2025-11-XX (FUTURO)
   ### Added
   - Módulo `ai`: Helpers para OpenAI API
   - `ai.GenerateSummary()` - Genera resumen educativo
   - `ai.GenerateQuiz()` - Genera preguntas
   
   ### ⚠️ Breaking Changes
   - Ninguno (backward compatible con v1.3.0)
   
   ## [v1.3.0] - 2025-11-XX
   ### Added
   - Módulo `messaging`: RabbitMQ producer/consumer
   - `messaging.NewProducer()` - Publicar eventos
   - `messaging.NewConsumer()` - Consumir eventos
   - Soporte para event versioning (event_version header)
   
   ## [v1.2.0] - 2025-11-XX
   ### Added
   - Módulo `auth`: JWT generation/validation
   - `auth.GenerateAccessToken()` - Crear tokens
   - `auth.ValidateAccessToken()` - Validar tokens
   - Soporte para refresh tokens (7 días)
   
   ## [v1.1.0] - 2025-11-XX
   ### Added
   - Módulo `database`: PostgreSQL + MongoDB helpers
   - `database.NewPostgresConnection()` - Conexión GORM
   - `database.NewMongoConnection()` - Cliente Mongo
   - Pool de conexiones configurables
   
   ## [v1.0.0] - 2025-11-XX
   ### Added
   - Módulo `logger`: Logging estructurado con Logrus
   - Módulo `config`: Gestión config multi-ambiente con Viper
   - Módulo `errors`: Error types estandarizados
   ```

3. **spec-04-shared/01-Context/VERSIONING_STRATEGY.md**
   ```markdown
   # Estrategia de Versionamiento
   
   ## Decisión: Versiones por Proyecto
   
   - **api-mobile:** Usa shared v1.3.0+ (necesita messaging)
   - **api-admin:** Usa shared v1.3.0+ (necesita messaging)
   - **worker:** Usa shared v1.4.0+ (necesita ai + messaging)
   
   ## Backward Compatibility
   - v1.4.0 es TOTALMENTE compatible con v1.3.0
   - Solo agrega módulo `ai`, no modifica existentes
   - api-mobile/admin pueden quedarse en v1.3.0 sin problemas
   
   ## Roadmap de Releases
   - **Sprint 1-2:** Publicar v1.0, v1.1, v1.2 (Core, Database, Auth)
   - **Sprint 3:** Publicar v1.3.0 (Messaging) ← api-mobile/admin
   - **Sprint 6:** Publicar v1.4.0 (AI) ← worker
   ```

#### Impacto esperado
- ✅ Todos los proyectos saben exactamente qué usar
- ✅ `go.mod` puede definirse correctamente
- ✅ No hay conflictos de versiones
- ✅ Desarrollo puede iniciar

---

### P0-2: Documentar Ownership de Tablas

**Prioridad:** P0 (MÁXIMA)  
**Detectado por:** 5/5 agentes  
**Tiempo estimado:** 3-4 horas

#### Problema que resuelve
- Ambigüedad sobre quién crea `users`, `materials`
- Riesgo de fallos de migraciones ("table already exists")
- CI/CD no tiene orden de ejecución

#### Archivos a crear/modificar

1. **AnalisisEstandarizado/00-Overview/TABLE_OWNERSHIP.md**
   ```markdown
   # Ownership de Tablas - EduGo
   
   ## Tabla de Responsabilidades
   
   | Tabla | Owner (crea y mantiene) | Readers | Writers | Migraciones en |
   |-------|------------------------|---------|---------|----------------|
   | **users** | api-admin | todos | api-admin | api-admin/migrations/ |
   | **schools** | api-admin | todos | api-admin | api-admin/migrations/ |
   | **academic_units** | api-admin | api-mobile, api-admin | api-admin | api-admin/migrations/ |
   | **memberships** | api-admin | api-mobile, api-admin | api-admin | api-admin/migrations/ |
   | **materials** | api-mobile | todos | api-mobile | api-mobile/migrations/ |
   | **assessment** | api-mobile | api-mobile, worker | api-mobile, worker | api-mobile/migrations/ |
   | **assessment_attempt** | api-mobile | api-mobile | api-mobile | api-mobile/migrations/ |
   | **assessment_attempt_answer** | api-mobile | api-mobile | api-mobile | api-mobile/migrations/ |
   
   ## Orden de Ejecución de Migraciones
   
   ### Fase 1: BASE (api-admin ejecuta PRIMERO)
   ```sql
   -- api-admin/migrations/001_create_users.sql
   CREATE TABLE users (...);
   CREATE TABLE schools (...);
   CREATE TABLE academic_units (...);
   CREATE TABLE memberships (...);
   ```
   
   ### Fase 2: FEATURES (api-mobile ejecuta DESPUÉS)
   ```sql
   -- api-mobile/migrations/001_create_materials.sql
   CREATE TABLE materials (
     ...
     uploaded_by_teacher_id UUID REFERENCES users(id),  -- FK a tabla de api-admin
     school_id UUID REFERENCES schools(id)              -- FK a tabla de api-admin
   );
   
   -- api-mobile/migrations/002_create_assessments.sql
   CREATE TABLE assessment (
     ...
     material_id UUID REFERENCES materials(id)
   );
   ```
   
   ## Validación en CI/CD
   
   ```yaml
   # .github/workflows/ci.yml
   jobs:
     migrate:
       steps:
         - name: Migrate Base (api-admin)
           run: cd api-admin && make migrate-up
         
         - name: Validate Base Schema
           run: psql -c "SELECT 1 FROM users LIMIT 1"
         
         - name: Migrate Features (api-mobile)
           run: cd api-mobile && make migrate-up
   ```
   
   ## Makefile de Validación
   
   ```makefile
   # api-mobile/Makefile
   migrate-up:
   	@echo "Validando tablas base..."
   	@psql -c "SELECT 1 FROM users LIMIT 1" || \
   	  (echo "ERROR: Tabla users no existe. Ejecutar migraciones de api-admin primero" && exit 1)
   	@echo "Ejecutando migraciones de api-mobile..."
   	@migrate -path migrations -database "$(DATABASE_URL)" up
   ```
   ```

#### Impacto esperado
- ✅ Cero conflictos de migraciones
- ✅ Orden de desarrollo claro
- ✅ CI/CD garantiza orden correcto

---

### P0-3: Especificar Contratos de Eventos RabbitMQ

**Prioridad:** P0 (MÁXIMA)  
**Detectado por:** 5/5 agentes  
**Tiempo estimado:** 4-5 horas

#### Problema que resuelve
- api-mobile y worker no saben qué estructura JSON usar
- Riesgo de breaking changes sin aviso
- Debugging de eventos imposible

#### Archivos a crear/modificar

1. **AnalisisEstandarizado/00-Overview/EVENT_CONTRACTS.md**
   ```markdown
   # Contratos de Eventos - RabbitMQ
   
   ## Configuración de Infraestructura
   
   ```yaml
   exchanges:
     - name: edugo.topic
       type: topic
       durable: true
       auto_delete: false
   
   queues:
     - name: material.processing
       durable: true
       arguments:
         x-message-ttl: 3600000  # 1 hora
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
         x-message-ttl: 86400000  # 24 horas
   ```
   
   ## Evento: material.uploaded (v1.0)
   
   **Publicado por:** api-mobile  
   **Consumido por:** worker  
   **Routing key:** `material.uploaded`
   
   ```json
   {
     "event_id": "01JA8...",  // UUID v7
     "event_type": "material.uploaded",
     "event_version": "1.0",
     "timestamp": "2025-11-15T10:30:00Z",
     "payload": {
       "material_id": "550e8400-e29b-41d4-a716-446655440000",
       "school_id": "660e8400-e29b-41d4-a716-446655440001",
       "teacher_id": "770e8400-e29b-41d4-a716-446655440002",
       "file_url": "s3://edugo-materials/550e8400.pdf",
       "file_size_bytes": 2048000,
       "file_type": "application/pdf",
       "metadata": {
         "title": "Introducción a la Física",
         "grade": "10th",
         "subject": "Science"
       }
     }
   }
   ```
   
   ## Evento: assessment.generated (v1.0)
   
   **Publicado por:** worker  
   **Consumido por:** api-mobile  
   **Routing key:** `assessment.generated`
   
   ```json
   {
     "event_id": "01JA9...",
     "event_type": "assessment.generated",
     "event_version": "1.0",
     "timestamp": "2025-11-15T10:35:00Z",
     "payload": {
       "material_id": "550e8400-e29b-41d4-a716-446655440000",
       "assessment_id": "880e8400-e29b-41d4-a716-446655440003",
       "mongo_document_id": "507f1f77bcf86cd799439011",
       "questions_count": 8,
       "processing_time_ms": 45000
     }
   }
   ```
   
   ## Versionamiento de Eventos
   
   ### Reglas
   - **Minor version (1.0 → 1.1):** Agregar campos OPCIONALES (backward compatible)
   - **Major version (1.0 → 2.0):** Cambios breaking (restructurar payload)
   
   ### Consumer Handling
   ```go
   func (c *MaterialConsumer) Handle(msg Message) error {
       switch msg.EventVersion {
       case "1.0", "1.1":
           return c.handleV1(msg)
       case "2.0":
           return c.handleV2(msg)
       default:
           return fmt.Errorf("unsupported event version: %s", msg.EventVersion)
       }
   }
   ```
   ```

#### Impacto esperado
- ✅ Integración api-mobile ↔ worker garantizada
- ✅ Versionamiento previene breaking changes
- ✅ Debugging simplificado

---

### P0-4: Crear docker-compose.yml y Scripts

**Prioridad:** P0 (MÁXIMA)  
**Detectado por:** 4/5 agentes  
**Tiempo estimado:** 4-5 horas

#### Problema que resuelve
- Desarrollo local bloqueado (no hay infraestructura)
- Tests de integración no se pueden ejecutar
- Setup manual es propenso a errores

#### Archivos a crear/modificar

1. **dev-environment/docker-compose.yml**
   ```yaml
   version: '3.8'
   
   services:
     postgres:
       image: postgres:15-alpine
       container_name: edugo-postgres
       environment:
         POSTGRES_DB: edugo_dev
         POSTGRES_USER: edugo
         POSTGRES_PASSWORD: changeme
       ports:
         - "5432:5432"
       volumes:
         - postgres_data:/var/lib/postgresql/data
       healthcheck:
         test: ["CMD", "pg_isready", "-U", "edugo"]
         interval: 10s
         timeout: 5s
         retries: 5
       networks:
         - edugo-network
     
     mongodb:
       image: mongo:7.0
       container_name: edugo-mongodb
       ports:
         - "27017:27017"
       volumes:
         - mongo_data:/data/db
       healthcheck:
         test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
         interval: 10s
         timeout: 5s
         retries: 5
       networks:
         - edugo-network
     
     rabbitmq:
       image: rabbitmq:3.12-management-alpine
       container_name: edugo-rabbitmq
       environment:
         RABBITMQ_DEFAULT_USER: guest
         RABBITMQ_DEFAULT_PASS: guest
       ports:
         - "5672:5672"    # AMQP
         - "15672:15672"  # Management UI
       healthcheck:
         test: ["CMD", "rabbitmq-diagnostics", "ping"]
         interval: 10s
         timeout: 5s
         retries: 5
       networks:
         - edugo-network
     
     mongo-express:
       image: mongo-express
       container_name: edugo-mongo-express
       environment:
         ME_CONFIG_MONGODB_URL: mongodb://mongodb:27017/
       ports:
         - "8082:8081"  # ← Evitar conflicto con api-admin
       depends_on:
         - mongodb
       networks:
         - edugo-network
       profiles: ["full", "tools"]
     
     pgadmin:
       image: dpage/pgadmin4
       container_name: edugo-pgadmin
       environment:
         PGADMIN_DEFAULT_EMAIL: admin@edugo.com
         PGADMIN_DEFAULT_PASSWORD: changeme
       ports:
         - "5050:80"
       depends_on:
         - postgres
       networks:
         - edugo-network
       profiles: ["full", "tools"]
   
   volumes:
     postgres_data:
     mongo_data:
   
   networks:
     edugo-network:
       driver: bridge
   ```

2. **dev-environment/scripts/setup.sh**
   ```bash
   #!/bin/bash
   set -e
   
   echo "🚀 EduGo - Setup de Desarrollo Local"
   
   # 1. Validar Docker
   if ! command -v docker &> /dev/null; then
       echo "❌ Docker no está instalado. Instalar desde https://docker.com"
       exit 1
   fi
   
   # 2. Crear .env desde .env.example
   if [ ! -f .env ]; then
       echo "📝 Creando .env desde .env.example..."
       cp .env.example .env
       echo "⚠️  Revisar y ajustar valores en .env"
   fi
   
   # 3. Levantar servicios
   echo "🐳 Levantando servicios con Docker Compose..."
   docker-compose up -d
   
   # 4. Esperar que servicios estén listos
   echo "⏳ Esperando que servicios estén listos..."
   sleep 10
   
   # 5. Validar conectividad
   echo "✅ Validando servicios..."
   docker-compose ps
   
   # 6. Ejecutar seeds
   echo "🌱 Ejecutando seeds de datos..."
   ./scripts/seed-data.sh
   
   echo "✅ Setup completo!"
   echo "📊 Servicios disponibles:"
   echo "   PostgreSQL: localhost:5432"
   echo "   MongoDB: localhost:27017"
   echo "   RabbitMQ: localhost:5672 (Management: http://localhost:15672)"
   echo "   Mongo Express: http://localhost:8082"
   echo "   PgAdmin: http://localhost:5050"
   ```

3. **dev-environment/scripts/seed-data.sh**
   ```bash
   #!/bin/bash
   set -e
   
   echo "🌱 Insertando datos de prueba..."
   
   # Seeds PostgreSQL
   PGPASSWORD=changeme psql -h localhost -U edugo -d edugo_dev -f seeds/postgres/001_users.sql
   PGPASSWORD=changeme psql -h localhost -U edugo -d edugo_dev -f seeds/postgres/002_schools.sql
   PGPASSWORD=changeme psql -h localhost -U edugo -d edugo_dev -f seeds/postgres/003_materials.sql
   
   # Seeds MongoDB
   mongosh --host localhost:27017 --file seeds/mongodb/material_summary.js
   mongosh --host localhost:27017 --file seeds/mongodb/material_assessment.js
   
   echo "✅ Seeds insertados correctamente"
   ```

4. **dev-environment/.env.example**
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
   
   # JWT
   JWT_SECRET=changeme-generate-random-secret-at-least-32-chars
   JWT_ACCESS_EXPIRY=15m
   JWT_REFRESH_EXPIRY=7d
   
   # OpenAI (worker)
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
   ```

#### Impacto esperado
- ✅ Desarrollo local funciona en 5 minutos
- ✅ Tests de integración pueden ejecutarse
- ✅ Setup automatizado y reproducible

---

### P0-5: Centralizar Variables de Entorno

**Prioridad:** P0  
**Detectado por:** 3/5 agentes  
**Tiempo estimado:** 2-3 horas  
**Ver:** P0-4 ya incluye `.env.example`

---

## 🔧 FASE 2: Decisiones Arquitectónicas (IMPORTANTE)

**Objetivo:** Aclarar decisiones técnicas críticas  
**Tiempo:** 1-2 días (8-12 horas)  
**Cuándo ejecutar:** Durante Sprints 01-02

---

### P1-1: Especificar Sincronización PostgreSQL ↔ MongoDB

**Prioridad:** P1 (Alta)  
**Detectado por:** 4/5 agentes  
**Tiempo estimado:** 3-4 horas

#### Problema que resuelve
- No está claro orden de creación (¿PostgreSQL primero o MongoDB?)
- Riesgo de inconsistencias (orphan records, referencias rotas)
- IA no puede decidir patrón de consistencia

#### Archivos a crear/modificar

**spec-01/02-Design/DATA_MODEL.md** (agregar sección)

```markdown
## Sincronización PostgreSQL ↔ MongoDB

### Patrón: Eventual Consistency con Event Sourcing

**Fundamento:**
- MongoDB es fuente de verdad para preguntas/quizzes (generadas por IA)
- PostgreSQL es fuente de verdad para metadata y relaciones
- Sincronización vía eventos de RabbitMQ

### Flujo de Creación de Assessment

```
1. Worker genera assessment en MongoDB
   ├─ Colección: material_assessment
   ├─ _id: ObjectId("507f1f77bcf86cd799439011")
   └─ Contiene: questions[], answers[], metadata

2. Worker publica evento assessment.generated
   ├─ Exchange: edugo.topic
   ├─ Routing key: assessment.generated
   └─ Payload: {material_id, mongo_document_id}

3. api-mobile consume evento
   ├─ Crea registro en PostgreSQL.assessment
   ├─ Guarda mongo_document_id = "507f1f77bcf86cd799439011"
   └─ material_id referencia a materials

4. Si falla PostgreSQL:
   ├─ Retry automático (3 intentos, backoff exponencial)
   ├─ Después 3 fallos → Dead Letter Queue
   └─ Alerta a equipo de operaciones
```

### Manejo de Inconsistencias

**Validación de Integridad (Cronjob diario):**
```sql
-- Encuentra assessments con mongo_document_id inválido
SELECT a.id, a.mongo_document_id
FROM assessment a
WHERE NOT EXISTS (
  SELECT 1 FROM mongodb.material_assessment
  WHERE _id = a.mongo_document_id
);
```

**API GET /assessment/:id:**
```go
func (s *AssessmentService) GetAssessment(ctx context.Context, id uuid.UUID) (*Assessment, error) {
    // 1. Obtener de PostgreSQL
    pgAssessment, err := s.repo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // 2. Validar que MongoDB existe
    mongoDoc, err := s.mongoRepo.GetByID(ctx, pgAssessment.MongoDocumentID)
    if err != nil {
        // MongoDB doc no existe - marcar como inválido
        s.logger.Error("assessment references non-existent mongo doc", 
            "assessment_id", id, 
            "mongo_id", pgAssessment.MongoDocumentID)
        return nil, ErrAssessmentInvalid
    }
    
    // 3. Combinar datos
    return s.merge(pgAssessment, mongoDoc), nil
}
```

### Rollback y Recuperación

**Si MongoDB falla después de publicar evento:**
- PostgreSQL NO crea registro (evento no se consume)
- Material queda sin assessment
- Retry automático cuando MongoDB vuelve

**Si PostgreSQL falla después de MongoDB:**
- MongoDB tiene documento "huérfano"
- Evento en DLQ
- Operaciones puede reintentar manualmente
- Alternativa: Cronjob de reconciliación
```

#### Impacto esperado
- ✅ Arquitectura de consistencia clara
- ✅ Manejo de fallos definido
- ✅ Zero ambigüedad para implementación

---

### P1-2: Estimar Costos de OpenAI

**Prioridad:** P1 (Alta)  
**Detectado por:** 3/5 agentes  
**Tiempo estimado:** 2-3 horas

#### Archivos a crear/modificar

**spec-02/01-Requirements/COST_ESTIMATION.md** (crear nuevo)

```markdown
# Estimación de Costos - OpenAI API

## Modelo y Pricing

**Modelo:** GPT-4 Turbo Preview  
**Pricing (Noviembre 2025):**
- Input: $0.01 / 1K tokens
- Output: $0.03 / 1K tokens

## Estimación por Material

**PDF promedio:** 20 páginas = ~10,000 tokens input  
**Resumen generado:** ~1,000 tokens output  
**Quiz generado:** ~500 tokens output

**Total por material:**
- Input: 10K tokens × $0.01 = $0.10
- Output: 1.5K tokens × $0.03 = $0.045
- **Costo por material: ~$0.15**

## Proyección de Volumen

| Escenario | Materiales/mes | Costo/mes | Costo/año |
|-----------|---------------|-----------|-----------|
| **MVP (10 escuelas piloto)** | 500 | $75 | $900 |
| **Año 1 (100 escuelas)** | 5,000 | $750 | $9,000 |
| **Año 2 (500 escuelas)** | 20,000 | $3,000 | $36,000 |

## Límites por Tier

| Tier | Precio/mes | Materiales incluidos | Costo adicional |
|------|-----------|---------------------|-----------------|
| **Free** | $0 | 10 | N/A |
| **Basic** | $50 | 50 | $2/material |
| **Premium** | $200 | 500 | $1/material |
| **Enterprise** | Custom | Ilimitado | $0.15/material |

## Control de Costos

### Rate Limiting
```go
// Máximo 100 procesamientos/hora por escuela
const MaxProcessingPerHour = 100

// Si excede: Encolar para siguiente hora
if count >= MaxProcessingPerHour {
    return ErrRateLimitExceeded
}
```

### Alertas
```yaml
alerts:
  - name: OpenAICostHigh
    condition: monthly_cost > $500
    action: Email a finanzas
  
  - name: OpenAICostCritical
    condition: monthly_cost > $1000
    action: Pausar procesamiento + Email urgente
```

### Degradación Graceful
```go
// Si se alcanza límite mensual:
// 1. Pausar procesamiento automático
// 2. Permitir procesamiento manual (admin aprueba)
// 3. Notificar a escuelas: "Cuota mensual alcanzada"
```
```

#### Impacto esperado
- ✅ Presupuesto claro y proyectado
- ✅ Control de costos implementado
- ✅ Sin sorpresas en facturación

---

### P1-3: Definir SLA de OpenAI

**Prioridad:** P1 (Alta)  
**Detectado por:** 4/5 agentes  
**Tiempo estimado:** 2-3 horas

#### Archivos a crear/modificar

**spec-02/01-Requirements/SLA_DEFINITION.md** (crear nuevo)

```markdown
# SLA de Procesamiento - Worker

## Definición de SLA

**SLA:** 60 segundos desde inicio de procesamiento (no incluye tiempo en cola)

**Medición:**
```go
startTime := time.Now()
// Procesamiento...
duration := time.Since(startTime)

if duration > 60*time.Second {
    logger.Warn("SLA exceeded", "duration_ms", duration.Milliseconds())
}
```

## Comportamiento por Tiempo

| Tiempo | Estado | Acción |
|--------|--------|--------|
| 0-30 seg | Normal | Procesamiento continúa |
| 30-60 seg | Warning | Log de advertencia, continuar |
| 60-120 seg | Error | Log de error, continuar hasta completar |
| >120 seg | Timeout | Cancelar, mover a DLQ |

## Manejo de Rate Limits de OpenAI

**Error 429 (rate limit):**
```go
func (p *Processor) handleRateLimit(ctx context.Context, material Material) error {
    for attempt := 1; attempt <= 5; attempt++ {
        err := p.processWithOpenAI(ctx, material)
        
        if err == nil {
            return nil
        }
        
        if isRateLimitError(err) {
            backoff := calculateBackoff(attempt) // 30s, 2min, 5min, 15min, 30min
            logger.Info("rate limit hit, backing off", "attempt", attempt, "backoff", backoff)
            time.Sleep(backoff)
            continue
        }
        
        return err // Otro error, no reintentar
    }
    
    // Después de 5 intentos (total ~52 minutos)
    return p.moveToDLQ(material, "max_retries_exceeded")
}
```

## UX y Notificaciones

### Procesamiento Asíncrono
```
1. Docente sube PDF
   └─ Respuesta inmediata: "Material subido, procesando..."

2. Material disponible SIN resumen
   └─ Badge en UI: "📊 Generando resumen..."

3. Worker procesa (puede tardar 60-120 seg)

4. Cuando completa:
   └─ Email: "✅ Resumen de 'Física' listo!"
   └─ Notificación push (opcional)
   └─ Badge en UI: "✅ Resumen disponible"
```

### Si Falla
```
1. Después de 5 reintentos:
   └─ Email: "⚠️ No pudimos procesar 'Física', contactar soporte"

2. Docente puede:
   └─ Usar material sin resumen
   └─ Crear resumen manualmente
   └─ Solicitar reprocesamiento (admin)
```

## Monitoreo

### Métricas
```prometheus
# Histogram de duración de procesamiento
worker_processing_duration_seconds{}

# Counter de timeouts
worker_processing_timeouts_total{}

# Counter de rate limits
worker_openai_rate_limits_total{}
```

### Alertas
```yaml
- alert: ProcessingSlowMedian
  expr: histogram_quantile(0.50, worker_processing_duration_seconds) > 45
  annotations:
    summary: "50% de procesamientos tardan >45seg"

- alert: ProcessingTimeout
  expr: rate(worker_processing_timeouts_total[5m]) > 0.05
  annotations:
    summary: ">5% de procesamientos llegan a timeout"
```
```

#### Impacto esperado
- ✅ UX clara y no frustrante
- ✅ Manejo de rate limits robusto
- ✅ Observabilidad completa

---

### P1-4: Validar Orden de Migraciones en CI/CD

**Prioridad:** P1  
**Detectado por:** 3/5 agentes  
**Tiempo:** 2-3 horas  
**Ver:** P0-2 ya incluye validación en Makefile y CI/CD

---

## 🚀 FASE 3: Deployment y Calidad (MEJORAS)

**Objetivo:** Preparar para producción  
**Tiempo:** 1-2 días (8-12 horas)  
**Cuándo ejecutar:** Durante Sprints 05-06

---

### P2-1: Definir Estrategia de Deployment

**Prioridad:** P2 (Media-Alta)  
**Detectado por:** 4/5 agentes  
**Tiempo estimado:** 3-4 horas

#### Archivos a crear/modificar

**AnalisisEstandarizado/00-Overview/DEPLOYMENT_STRATEGY.md** (crear nuevo)

```markdown
# Estrategia de Deployment - EduGo

## Ambientes

| Ambiente | Propósito | Deployment Strategy | SLA Uptime |
|----------|-----------|---------------------|------------|
| **local** | Desarrollo | Manual (docker-compose) | N/A |
| **staging** | QA + Pre-prod | Blue-Green | 95% |
| **production** | Usuarios reales | Canary Release | 99.9% |

## Orden de Deployment entre Servicios

```mermaid
graph TD
  A[shared v1.3.0] --> B[dev-environment setup]
  B --> C[api-admin v1.0.0]
  C --> D[api-mobile v1.0.0]
  D --> E[worker v1.0.0]
```

**Regla:** Nunca deployar dependiente ANTES que dependencia

## Estrategia por Ambiente

### Staging: Blue-Green
**Razón:** Switch instantáneo, testing manual sin presión

```
1. Deploy v1.1.0 a "green" environment
2. Testing manual (1 hora)
3. Tests automatizados E2E
4. Switch traffic: blue → green
5. Blue queda como fallback (24h)
6. Si todo OK: Eliminar blue
```

### Producción: Canary Release
**Razón:** Minimizar riesgo, detectar problemas antes de full rollout

```
1. Deploy v1.1.0 a 10% de pods (canary)
2. Monitor error rate por 30 minutos
   └─ Si error rate < 1%: Continuar
   └─ Si error rate > 1%: Rollback automático

3. Escalar a 50% de pods
4. Monitor por 30 minutos
   └─ Si error rate < 0.5%: Continuar
   └─ Si error rate > 0.5%: Rollback

5. Escalar a 100% (full deployment)
```

## Rollback

### Automático
```yaml
# Trigger de rollback automático
conditions:
  - error_rate_5m > 5%
  - p95_latency > 2000ms
  - health_check_failures > 10

action:
  - kubectl rollout undo deployment/api-mobile
  - Notify #incidents en Slack
  - Page on-call engineer
```

### Manual
```bash
# Ver historial de deployments
kubectl rollout history deployment/api-mobile

# Rollback a versión anterior
kubectl rollout undo deployment/api-mobile

# Rollback a versión específica
kubectl rollout undo deployment/api-mobile --to-revision=3
```

## Validación de Compatibilidad

### Pre-deployment Checks
```yaml
# .github/workflows/deploy-production.yml
pre_deploy_checks:
  - name: Validate shared version
    run: |
      REQUIRED_VERSION=$(grep 'github.com/edugogroup/edugo-shared' go.mod | awk '{print $2}')
      if ! gh release view $REQUIRED_VERSION -R edugogroup/edugo-shared; then
        echo "ERROR: shared $REQUIRED_VERSION no existe en GitHub"
        exit 1
      fi
  
  - name: Validate migrations
    run: |
      # Ejecutar migraciones en staging primero
      kubectl exec -n staging deployment/api-admin -- make migrate-up
      kubectl exec -n staging deployment/api-mobile -- make migrate-up
```

## Zero-Downtime Garantizado

### Kubernetes Configuration
```yaml
# api-mobile/k8s/deployment.yaml
spec:
  replicas: 3  # Mínimo 3 para rolling update
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1  # Máximo 1 pod down a la vez
      maxSurge: 1        # Máximo 1 pod extra durante update
  
  containers:
    - name: api-mobile
      readinessProbe:
        httpGet:
          path: /health/readiness
          port: 8080
        initialDelaySeconds: 10
        periodSeconds: 5
      livenessProbe:
        httpGet:
          path: /health/liveness
          port: 8080
        initialDelaySeconds: 30
        periodSeconds: 10
```
```

#### Impacto esperado
- ✅ Deployments sin downtime
- ✅ Rollback en <5 minutos
- ✅ 99.9% uptime garantizado

---

### P2-2 a P2-5: Otros Items de Fase 3

**P2-2:** Crear Kubernetes manifests (3-4h)  
**P2-3:** CI/CD pipelines completos (2-4h)  
**P2-4:** Runbooks de incidentes (2-3h)  
**P2-5:** Índices de MongoDB (1-2h)

---

## 📊 Resumen del Plan Completo

### Tiempo Total por Fase

| Fase | Items | Horas | Días | Bloqueantes Resueltos |
|------|-------|-------|------|---------------------|
| **Fase 1** | 5 | 16-24h | 2-3d | 5 críticos P0 |
| **Fase 2** | 4 | 8-12h | 1-2d | 4 importantes P1 |
| **Fase 3** | 5 | 8-12h | 1-2d | 5 mejoras P2 |
| **TOTAL** | **14** | **32-48h** | **4-7d** | **14 problemas** |

### Priorización de Ejecución

```
URGENTE (ANTES de código):
└─ Fase 1 completa (2-3 días)

IMPORTANTE (Sprint 01-02):
└─ Fase 2 completa (1-2 días)

RECOMENDADO (Sprint 05-06):
└─ Fase 3 completa (1-2 días)
```

### Criterios de Éxito

**Después de Fase 1:**
- ✅ Cualquier desarrollador puede clonar repos y levantar infraestructura en 5 minutos
- ✅ edugo-shared está completamente especificado con interfaces claras
- ✅ Ownership de tablas es inequívoco
- ✅ Contratos de eventos están documentados
- ✅ Desarrollo puede iniciar

**Después de Fase 2:**
- ✅ Arquitectura de consistencia PostgreSQL ↔ MongoDB clara
- ✅ Costos de OpenAI proyectados y controlados
- ✅ SLA de procesamiento definido con UX asíncrono
- ✅ Tests de integración pueden ejecutarse

**Después de Fase 3:**
- ✅ Deployment a producción sin downtime
- ✅ Rollback automático en caso de fallos
- ✅ Observabilidad completa con métricas y alertas
- ✅ Runbooks para incidentes comunes

---

## 🎯 Siguientes Pasos Inmediatos

### Día 1 (8 horas)
- [ ] 08:00-11:00: P0-1 edugo-shared (MODULE_INTERFACES.md + CHANGELOG.md)
- [ ] 11:00-14:00: P0-2 TABLE_OWNERSHIP.md + validación Makefile
- [ ] 14:00-18:00: P0-3 EVENT_CONTRACTS.md

### Día 2 (8 horas)
- [ ] 08:00-12:00: P0-4 docker-compose.yml + scripts
- [ ] 12:00-15:00: P1-1 Sincronización PostgreSQL ↔ MongoDB
- [ ] 15:00-18:00: P1-2 Costos OpenAI + P1-3 SLA OpenAI

### Día 3 (Opcional - Fase 3)
- [ ] 08:00-12:00: P2-1 DEPLOYMENT_STRATEGY.md
- [ ] 12:00-16:00: P2-2 Kubernetes manifests
- [ ] 16:00-18:00: P2-3 CI/CD pipelines

---

**Este plan fue generado consolidando hallazgos de 5 agentes IA independientes, priorizando por consenso e impacto en desarrollo.**

**Fecha de creación:** 15 de Noviembre, 2025  
**Última actualización:** 15 de Noviembre, 2025  
**Autor:** Claude Code (Consolidación de 5 análisis)
