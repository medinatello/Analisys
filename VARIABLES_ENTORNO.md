# Variables de Entorno - EduGo

**Última actualización:** 30 de Octubre, 2025
**Proyecto:** EduGo - Plataforma de Análisis de Evaluaciones

---

## 📋 Descripción General

Este documento consolida **todas las variables de entorno** utilizadas por los microservicios de EduGo. Las variables se dividen en:

1. **Variables de archivo `.env`** - Secretos y configuración sensible
2. **Variables de configuración YAML** - Configuración por ambiente (local, dev, qa, prod)
3. **Variables específicas de Docker Compose** - Orquestación de contenedores

---

## 🔐 Variables de Archivo .env

Estas variables se definen en el archivo `.env` (copia de `.env.example`).

### Ambiente

| Variable | Valores | Default | Descripción |
|----------|---------|---------|-------------|
| `APP_ENV` | `local`, `dev`, `qa`, `prod` | `local` | Determina qué archivo config se carga (`config-{APP_ENV}.yaml`) |

### Secretos Requeridos

| Variable | Ejemplo | Requerido | Usado por | Descripción |
|----------|---------|-----------|-----------|-------------|
| `POSTGRES_PASSWORD` | `edugo_pass` | ✅ Sí | Todos | Contraseña de PostgreSQL |
| `MONGODB_URI` | `mongodb://user:pass@host:port/db?authSource=admin` | ✅ Sí | api-mobile, worker | URI completa de MongoDB |
| `RABBITMQ_URL` | `amqp://user:pass@host:port/` | ✅ Sí | api-mobile, worker | URL completa de RabbitMQ |
| `OPENAI_API_KEY` | `sk-...` | ✅ Sí | worker | API Key de OpenAI para NLP |

### Configuración de PostgreSQL (Opcional)

| Variable | Default | Usado por | Descripción |
|----------|---------|-----------|-------------|
| `POSTGRES_HOST` | `localhost` | docker-compose | Host de PostgreSQL |
| `POSTGRES_PORT` | `5432` | docker-compose | Puerto de PostgreSQL |
| `POSTGRES_DB` | `edugo` | docker-compose | Nombre de base de datos |
| `POSTGRES_USER` | `edugo_user` | docker-compose | Usuario de PostgreSQL |

**Nota:** Los servicios **NO leen directamente** estas variables. Las leen desde archivos `config-{env}.yaml`.

### Puertos de Servicios (Referencia)

| Variable | Default | Descripción |
|----------|---------|-------------|
| `API_MOBILE_PORT` | `8080` | Puerto de API Mobile (solo referencia, se define en config YAML) |
| `API_ADMIN_PORT` | `8081` | Puerto de API Administración (solo referencia, se define en config YAML) |

---

## 📝 Variables de Configuración YAML

Cada servicio tiene archivos de configuración YAML en `config/`:
- `config.yaml` - Configuración base común
- `config-local.yaml` - Desarrollo local
- `config-dev.yaml` - Ambiente de desarrollo
- `config-qa.yaml` - Ambiente de QA
- `config-prod.yaml` - Producción

### API Mobile (`source/api-mobile/config/`)

#### Server

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `server.port` | `8080` | Puerto del servidor HTTP |
| `server.host` | `0.0.0.0` | Host de bind |
| `server.read_timeout` | `30s` | Timeout de lectura HTTP |
| `server.write_timeout` | `30s` | Timeout de escritura HTTP |

#### Database - PostgreSQL

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `database.postgres.host` | `localhost` | Host de PostgreSQL |
| `database.postgres.port` | `5432` | Puerto de PostgreSQL |
| `database.postgres.database` | `edugo` | Nombre de BD |
| `database.postgres.user` | `edugo_user` | Usuario de PostgreSQL |
| `database.postgres.password` | `(de .env)` | Contraseña (sobrescrita por env) |
| `database.postgres.max_connections` | `25` | Pool máximo de conexiones |
| `database.postgres.ssl_mode` | `disable` | Modo SSL (`disable`, `require`, `verify-full`) |

#### Database - MongoDB

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `database.mongodb.uri` | `(de .env)` | URI completa de MongoDB |
| `database.mongodb.database` | `edugo` | Nombre de base de datos |
| `database.mongodb.timeout` | `10s` | Timeout de conexión |

#### Messaging - RabbitMQ

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `messaging.rabbitmq.url` | `(de .env)` | URL completa de RabbitMQ |
| `messaging.rabbitmq.queues.material_uploaded` | `edugo.material.uploaded` | Nombre de queue para materiales subidos |
| `messaging.rabbitmq.queues.assessment_attempt` | `edugo.assessment.attempt` | Nombre de queue para intentos de evaluación |
| `messaging.rabbitmq.exchanges.materials` | `edugo.materials` | Nombre de exchange |
| `messaging.rabbitmq.prefetch_count` | `10` | Cantidad de mensajes pre-fetch |

#### Logging

| Variable (YAML) | Default (prod) | Default (local) | Descripción |
|-----------------|----------------|-----------------|-------------|
| `logging.level` | `info` | `debug` | Nivel de logging (`debug`, `info`, `warn`, `error`) |
| `logging.format` | `json` | `text` | Formato de logs (`json` para prod, `text` para dev) |

---

### API Administración (`source/api-administracion/config/`)

**Similar a API Mobile, con las siguientes diferencias:**

#### Server

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `server.port` | `8081` | Puerto del servidor HTTP (diferente de api-mobile) |

#### Database

- **PostgreSQL:** Mismas variables que api-mobile
- **MongoDB:** ❌ **NO USA** (api-administracion no usa MongoDB)

#### Messaging

- ❌ **NO USA** RabbitMQ actualmente

#### Logging

- Mismas variables que api-mobile

---

### Worker (`source/worker/config/`)

**El worker NO tiene configuración de servidor HTTP (no es API).**

#### Database - PostgreSQL

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `database.postgres.host` | `localhost` | Host de PostgreSQL |
| `database.postgres.port` | `5432` | Puerto de PostgreSQL |
| `database.postgres.database` | `edugo` | Nombre de BD |
| `database.postgres.user` | `edugo_user` | Usuario de PostgreSQL |
| `database.postgres.password` | `(de .env)` | Contraseña |
| `database.postgres.max_connections` | `10` | Pool de conexiones (menor que APIs) |
| `database.postgres.ssl_mode` | `disable` | Modo SSL |

#### Database - MongoDB

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `database.mongodb.uri` | `(de .env)` | URI completa de MongoDB |
| `database.mongodb.database` | `edugo` | Nombre de base de datos |
| `database.mongodb.timeout` | `10s` | Timeout de conexión |

#### Messaging - RabbitMQ

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `messaging.rabbitmq.url` | `(de .env)` | URL completa de RabbitMQ |
| `messaging.rabbitmq.queues.material_uploaded` | `edugo.material.uploaded` | Queue para materiales |
| `messaging.rabbitmq.queues.assessment_attempt` | `edugo.assessment.attempt` | Queue para evaluaciones |
| `messaging.rabbitmq.exchanges.materials` | `edugo.materials` | Exchange |
| `messaging.rabbitmq.prefetch_count` | `5` | Pre-fetch (menor que api-mobile) |

#### NLP - OpenAI (Específico del Worker)

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `nlp.provider` | `openai` | Proveedor de NLP |
| `nlp.model` | `gpt-4` | Modelo de OpenAI a usar |
| `nlp.max_tokens` | `4000` | Tokens máximos por request |
| `nlp.temperature` | `0.7` | Temperature para generación |

**Nota:** La API Key se lee de la variable de entorno `OPENAI_API_KEY`.

#### Logging

| Variable (YAML) | Default | Descripción |
|-----------------|---------|-------------|
| `logging.level` | `info` | Nivel de logging |
| `logging.format` | `json` | Formato de logs |

---

## 🐳 Variables de Docker Compose

Estas variables se usan en `docker-compose.yml` / `docker-compose.dev.yml`.

### Servicios de Infraestructura

#### PostgreSQL

```yaml
environment:
  POSTGRES_DB: ${POSTGRES_DB:-edugo}
  POSTGRES_USER: ${POSTGRES_USER:-edugo_user}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?error}  # Requerida de .env
```

| Variable | Default | Descripción |
|----------|---------|-------------|
| `POSTGRES_DB` | `edugo` | Nombre de base de datos |
| `POSTGRES_USER` | `edugo_user` | Usuario administrador |
| `POSTGRES_PASSWORD` | (requerida) | Contraseña |

#### MongoDB

```yaml
environment:
  MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER:-edugo_admin}
  MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD:-edugo_pass}
  MONGO_INITDB_DATABASE: ${MONGO_DB:-edugo}
```

| Variable | Default | Descripción |
|----------|---------|-------------|
| `MONGO_USER` | `edugo_admin` | Usuario root |
| `MONGO_PASSWORD` | `edugo_pass` | Contraseña root |
| `MONGO_DB` | `edugo` | Base de datos inicial |

**Nota:** La URI completa en servicios usa: `mongodb://${MONGO_USER}:${MONGO_PASSWORD}@mongodb:27017/${MONGO_DB}?authSource=admin`

#### RabbitMQ

```yaml
environment:
  RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER:-edugo_user}
  RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASS:-edugo_pass}
```

| Variable | Default | Descripción |
|----------|---------|-------------|
| `RABBITMQ_USER` | `edugo_user` | Usuario |
| `RABBITMQ_PASS` | `edugo_pass` | Contraseña |

**Nota:** La URL completa en servicios usa: `amqp://${RABBITMQ_USER}:${RABBITMQ_PASS}@rabbitmq:5672/`

---

## 📊 Matriz de Uso por Servicio

| Variable | api-mobile | api-administracion | worker | Infraestructura |
|----------|------------|-------------------|--------|-----------------|
| **APP_ENV** | ✅ | ✅ | ✅ | ❌ |
| **POSTGRES_*** | ✅ | ✅ | ✅ | ✅ |
| **MONGODB_URI** | ✅ | ❌ | ✅ | ✅ |
| **RABBITMQ_URL** | ✅ | ❌ | ✅ | ✅ |
| **OPENAI_API_KEY** | ❌ | ❌ | ✅ | ❌ |
| **JWT_SECRET** | ✅ | ✅ | ❌ | ❌ |

---

## 🔧 Ejemplo de Archivo .env Completo

```bash
# ========================================
# AMBIENTE
# ========================================
APP_ENV=local

# ========================================
# SECRETOS (REQUERIDOS EN PRODUCCIÓN)
# ========================================
POSTGRES_PASSWORD=your_secure_password_here
MONGODB_URI=mongodb://edugo_admin:secure_pass@localhost:27017/edugo?authSource=admin
RABBITMQ_URL=amqp://edugo_user:secure_pass@localhost:5672/
OPENAI_API_KEY=sk-your-openai-api-key-here
JWT_SECRET=your_jwt_secret_min_32_chars_here

# ========================================
# CONFIGURACIÓN DE BD (DOCKER COMPOSE)
# ========================================
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=edugo
POSTGRES_USER=edugo_user

MONGO_USER=edugo_admin
MONGO_PASSWORD=edugo_pass
MONGO_DB=edugo

RABBITMQ_USER=edugo_user
RABBITMQ_PASS=edugo_pass

# ========================================
# PUERTOS (REFERENCIA)
# ========================================
API_MOBILE_PORT=8080
API_ADMIN_PORT=8081
```

---

## 🛡️ Seguridad

### Producción

**⚠️ NUNCA commitear archivos `.env` a Git!**

En producción:
1. Usar secretos gestionados por plataforma:
   - **Docker:** Docker Secrets
   - **Kubernetes:** Kubernetes Secrets
   - **AWS:** AWS Secrets Manager / Parameter Store
   - **Azure:** Azure Key Vault
   - **GCP:** Google Secret Manager

2. Rotar secretos regularmente:
   - `POSTGRES_PASSWORD` - cada 90 días
   - `MONGODB_URI` - cada 90 días
   - `JWT_SECRET` - cada 180 días
   - `OPENAI_API_KEY` - según política de OpenAI

3. Usar contraseñas fuertes:
   - Mínimo 32 caracteres
   - Combinación de letras, números y símbolos
   - Generadas por herramientas (no manuales)

### Desarrollo Local

- Usar valores simples en `.env.local` (no commitear)
- Documentar valores de desarrollo en `.env.example` (sí commitear)
- Nunca usar secretos de producción en local

---

## 📚 Archivos de Configuración por Ambiente

### Prioridad de Carga

1. **Variables de entorno** (`.env`)
2. **Archivo config específico** (`config-{APP_ENV}.yaml`)
3. **Archivo config base** (`config.yaml`)

### Ejemplo: APP_ENV=local

```bash
# Carga en este orden:
1. config.yaml                 (base)
2. config-local.yaml          (sobrescribe valores)
3. Variables de .env          (sobrescribe secretos)
```

### Ambientes Disponibles

| Ambiente | Archivo | Uso |
|----------|---------|-----|
| `local` | `config-local.yaml` | Desarrollo local en máquina del developer |
| `dev` | `config-dev.yaml` | Ambiente de desarrollo compartido (servidor) |
| `qa` | `config-qa.yaml` | Ambiente de QA/Testing |
| `prod` | `config-prod.yaml` | Producción |

---

## 🚀 Migración Post-Separación

Después de separar los repositorios, cada servicio tendrá su propio `.env`:

```
edugo-api-mobile/
├── .env.example        # Template
├── .env               # Local (no commitear)
└── config/
    ├── config.yaml
    ├── config-local.yaml
    ├── config-dev.yaml
    ├── config-qa.yaml
    └── config-prod.yaml

edugo-api-administracion/
├── .env.example
├── .env
└── config/...

edugo-worker/
├── .env.example
├── .env
└── config/...
```

Cada `.env` solo contendrá las variables necesarias para ese servicio.

---

## 📋 Checklist de Configuración

Al configurar un nuevo ambiente:

- [ ] Copiar `.env.example` → `.env`
- [ ] Configurar `APP_ENV` correcto
- [ ] Generar contraseñas seguras para BD
- [ ] Configurar `OPENAI_API_KEY` válida (solo worker)
- [ ] Generar `JWT_SECRET` de mínimo 32 caracteres
- [ ] Verificar conectividad a PostgreSQL
- [ ] Verificar conectividad a MongoDB
- [ ] Verificar conectividad a RabbitMQ
- [ ] Probar endpoints de health check
- [ ] Verificar logs en formato correcto

---

## 🔍 Troubleshooting

### Error: "missing required environment variable"

**Solución:** Verificar que todas las variables requeridas están en `.env`:
```bash
grep -v "^#" .env | grep -E "PASSWORD|URI|KEY|SECRET"
```

### Error: "connection refused" a PostgreSQL

**Solución:** Verificar configuración en `config-{env}.yaml`:
- `database.postgres.host` apunta a host correcto
- `database.postgres.port` es correcto (default 5432)
- Credenciales coinciden con `.env`

### Error: "authentication failed" en MongoDB

**Solución:** Verificar URI en `.env`:
```bash
# Formato correcto:
mongodb://user:password@host:port/database?authSource=admin

# Verificar que user y password no contienen caracteres especiales sin escapar
```

### Logs no aparecen en formato JSON en producción

**Solución:** Verificar `APP_ENV=prod` y que `config-prod.yaml` tiene:
```yaml
logging:
  format: "json"
```

---

**Última actualización:** 30 de Octubre, 2025
**Mantenedor:** Equipo EduGo
