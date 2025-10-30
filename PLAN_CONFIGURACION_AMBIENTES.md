# 📋 PLAN: Configuración por Ambientes en Go (3 Proyectos)

**Fecha**: 2025-10-29
**Objetivo**: Implementar configuración por ambientes (dev, qa, prod, local) en api-mobile, api-administracion y worker

---

## 🎯 ENFOQUE

**Librería elegida**: **Viper** (estándar en Go, similar a Spring Boot)
- Soporta múltiples formatos (YAML, JSON, ENV)
- Precedencia de configuración (ENV > Archivo)
- Hot-reload de configuración
- Type-safe configuration

**Patrón**: Similar a Spring Boot profiles
- Archivo base: `config.yaml` (configuración común)
- Archivos por ambiente: `config-dev.yaml`, `config-qa.yaml`, `config-prod.yaml`, `config-local.yaml`
- Variable de ambiente `APP_ENV` define el perfil activo

**Secretos**:
- Desarrollo: Variables de ambiente locales
- Producción: HashiCorp Vault / Kubernetes Secrets (futuro)

---

## 📁 ESTRUCTURA PROPUESTA (por proyecto)

```
api-mobile/
├── config/
│   ├── config.yaml           # Configuración base (común)
│   ├── config-local.yaml     # Local development
│   ├── config-dev.yaml       # Development server
│   ├── config-qa.yaml        # QA/Staging
│   ├── config-prod.yaml      # Production
│   └── README.md             # Documentación de configuración
├── internal/
│   └── config/
│       ├── config.go         # Struct de configuración
│       └── loader.go         # Carga de configuración con Viper
└── cmd/main.go               # Inicializa config al arrancar
```

**Replicar en**: api-administracion, worker

---

## 🔧 CONFIGURACIÓN POR PROYECTO

### API Mobile (Puerto 8080)

```yaml
# config/config.yaml (base)
server:
  port: 8080
  host: "0.0.0.0"
  read_timeout: 30s
  write_timeout: 30s

database:
  postgres:
    host: "${POSTGRES_HOST:localhost}"
    port: 5432
    database: "edugo"
    user: "${POSTGRES_USER:edugo_user}"
    password: "${POSTGRES_PASSWORD}"  # Desde ENV obligatorio
    max_connections: 25

  mongodb:
    uri: "${MONGODB_URI}"  # Desde ENV obligatorio
    database: "edugo"
    timeout: 10s

messaging:
  rabbitmq:
    url: "${RABBITMQ_URL}"  # Desde ENV obligatorio
    queues:
      material_uploaded: "edugo.material.uploaded"
      assessment_attempt: "edugo.assessment.attempt"
    exchanges:
      materials: "edugo.materials"

logging:
  level: "info"
  format: "json"

# config/config-local.yaml
server:
  port: 8080

database:
  postgres:
    host: "localhost"
    password: "local_pass"
  mongodb:
    uri: "mongodb://edugo_admin:edugo_pass@localhost:27017/edugo?authSource=admin"

messaging:
  rabbitmq:
    url: "amqp://edugo_user:edugo_pass@localhost:5672/"

logging:
  level: "debug"
  format: "text"

# config/config-prod.yaml
server:
  read_timeout: 60s
  write_timeout: 60s

database:
  postgres:
    max_connections: 100

logging:
  level: "warn"
  format: "json"
```

### API Administración (Puerto 8081)

Similar a API Mobile pero con:
- `server.port: 8081`
- Sin configuración de RabbitMQ (no publica eventos)

### Worker

Similar pero:
- Sin `server` (no es HTTP)
- Configuración adicional para OpenAI:
  ```yaml
  nlp:
    provider: "openai"
    api_key: "${OPENAI_API_KEY}"  # Desde ENV obligatorio
    model: "gpt-4"
    max_tokens: 4000
  ```

---

## 📦 DEPENDENCIAS A AGREGAR

```bash
# En cada proyecto
go get github.com/spf13/viper
```

---

## 🏗️ IMPLEMENTACIÓN - PASOS DETALLADOS

### FASE 1: Crear Estructura de Configuración (Proyecto 1: api-mobile)

**Tiempo estimado**: 1 hora

1.1. Crear carpeta `config/` en api-mobile
1.2. Crear archivos YAML:
   - `config.yaml` (base)
   - `config-local.yaml`
   - `config-dev.yaml`
   - `config-qa.yaml`
   - `config-prod.yaml`
   - `README.md`

1.3. Crear `internal/config/config.go`:
   ```go
   type Config struct {
       Server   ServerConfig   `mapstructure:"server"`
       Database DatabaseConfig `mapstructure:"database"`
       Messaging MessagingConfig `mapstructure:"messaging"`
       Logging  LoggingConfig  `mapstructure:"logging"`
   }

   type ServerConfig struct {
       Port         int           `mapstructure:"port"`
       Host         string        `mapstructure:"host"`
       ReadTimeout  time.Duration `mapstructure:"read_timeout"`
       WriteTimeout time.Duration `mapstructure:"write_timeout"`
   }
   // ... más structs
   ```

1.4. Crear `internal/config/loader.go`:
   ```go
   func Load() (*Config, error) {
       v := viper.New()

       // 1. Defaults
       v.SetDefault("server.port", 8080)

       // 2. Config file
       env := os.Getenv("APP_ENV")
       if env == "" {
           env = "local"
       }

       v.SetConfigName("config")
       v.SetConfigType("yaml")
       v.AddConfigPath("./config")

       // Leer base
       if err := v.ReadInConfig(); err != nil {
           return nil, err
       }

       // Merge environment-specific
       v.SetConfigName(fmt.Sprintf("config-%s", env))
       if err := v.MergeInConfig(); err != nil {
           // Ignorar si no existe
       }

       // 3. Environment variables (highest precedence)
       v.AutomaticEnv()
       v.SetEnvPrefix("EDUGO_MOBILE")
       v.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

       // 4. Unmarshal
       var cfg Config
       if err := v.Unmarshal(&cfg); err != nil {
           return nil, err
       }

       return &cfg, nil
   }
   ```

1.5. Modificar `cmd/main.go`:
   ```go
   func main() {
       // Cargar configuración
       cfg, err := config.Load()
       if err != nil {
           log.Fatal("Error loading config:", err)
       }

       // Usar configuración
       router := gin.Default()
       // ...

       addr := fmt.Sprintf("%s:%d", cfg.Server.Host, cfg.Server.Port)
       router.Run(addr)
   }
   ```

**Commit**: `feat(api-mobile): add Viper-based configuration management`

---

### FASE 2: Replicar en api-administracion

**Tiempo estimado**: 30 minutos

2.1. Copiar estructura de config/ desde api-mobile
2.2. Ajustar valores específicos:
   - Puerto 8081
   - Quitar configuración de RabbitMQ
   - ENV_PREFIX: `EDUGO_ADMIN`

**Commit**: `feat(api-admin): add Viper-based configuration management`

---

### FASE 3: Replicar en worker

**Tiempo estimado**: 40 minutos

3.1. Copiar estructura de config/ desde api-mobile
3.2. Ajustar valores específicos:
   - Sin configuración de servidor HTTP
   - Agregar configuración de OpenAI:
     ```yaml
     nlp:
       provider: "openai"
       api_key: "${OPENAI_API_KEY}"
       model: "gpt-4"
       max_tokens: 4000
       temperature: 0.7
     ```
   - ENV_PREFIX: `EDUGO_WORKER`

**Commit**: `feat(worker): add Viper-based configuration management`

---

### FASE 4: Actualizar Docker Compose

**Tiempo estimado**: 20 minutos

4.1. Modificar `docker-compose.yml` para usar `APP_ENV`:
   ```yaml
   api-mobile:
     environment:
       APP_ENV: ${APP_ENV:-local}
       # Secretos como env vars
       POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
       MONGODB_URI: ${MONGODB_URI}
       RABBITMQ_URL: ${RABBITMQ_URL}
   ```

4.2. Actualizar `.env.example`:
   ```env
   # Environment Profile
   APP_ENV=local  # local | dev | qa | prod

   # Secrets
   POSTGRES_PASSWORD=edugo_pass
   MONGODB_URI=mongodb://edugo_admin:edugo_pass@mongodb:27017/edugo?authSource=admin
   RABBITMQ_URL=amqp://edugo_user:edugo_pass@rabbitmq:5672/
   OPENAI_API_KEY=sk-your-key-here
   ```

**Commit**: `chore: update Docker Compose for environment-based configuration`

---

### FASE 5: Documentación y Validación

**Tiempo estimado**: 30 minutos

5.1. Actualizar `docs/DEVELOPMENT.md`:
   - Agregar sección "Configuración por Ambientes"
   - Documentar cómo cambiar entre ambientes
   - Documentar variables de ambiente requeridas

5.2. Actualizar `README.md`:
   - Agregar sección de configuración
   - Ejemplos de uso

5.3. Crear `config/README.md` en cada proyecto explicando:
   - Cómo funciona la precedencia
   - Qué variables están disponibles
   - Cómo agregar nuevas configuraciones

5.4. Validar que todo funcione:
   ```bash
   # Local
   APP_ENV=local make up

   # Dev
   APP_ENV=dev make up

   # Prod (simulado)
   APP_ENV=prod make up
   ```

**Commit**: `docs: add configuration management documentation`

---

## 📊 VARIABLES DE CONFIGURACIÓN

### Comunes (3 proyectos)

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| `APP_ENV` | string | local | Perfil activo (local, dev, qa, prod) |
| `POSTGRES_HOST` | string | localhost | Host PostgreSQL |
| `POSTGRES_PORT` | int | 5432 | Puerto PostgreSQL |
| `POSTGRES_DB` | string | edugo | Base de datos |
| `POSTGRES_USER` | string | edugo_user | Usuario |
| `POSTGRES_PASSWORD` | **secret** | - | Password (obligatorio desde ENV) |
| `MONGODB_URI` | **secret** | - | URI completa MongoDB (obligatorio) |
| `RABBITMQ_URL` | **secret** | - | URL RabbitMQ (obligatorio api-mobile, worker) |

### API Mobile / API Admin específicas

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| `SERVER_PORT` | int | 8080/8081 | Puerto del servidor |
| `SERVER_HOST` | string | 0.0.0.0 | Host del servidor |
| `SERVER_READ_TIMEOUT` | duration | 30s | Read timeout |
| `SERVER_WRITE_TIMEOUT` | duration | 30s | Write timeout |

### Worker específicas

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| `OPENAI_API_KEY` | **secret** | - | API Key OpenAI (obligatorio) |
| `NLP_MODEL` | string | gpt-4 | Modelo a usar |
| `NLP_MAX_TOKENS` | int | 4000 | Tokens máximos |
| `NLP_TEMPERATURE` | float | 0.7 | Temperature |

### RabbitMQ (api-mobile, worker)

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| `RABBITMQ_QUEUE_MATERIAL_UPLOADED` | string | edugo.material.uploaded | Cola de materiales |
| `RABBITMQ_QUEUE_ASSESSMENT_ATTEMPT` | string | edugo.assessment.attempt | Cola de intentos |
| `RABBITMQ_EXCHANGE_MATERIALS` | string | edugo.materials | Exchange de materiales |

---

## 🔐 ESTRATEGIA DE SECRETOS

### Desarrollo Local
```bash
# .env
POSTGRES_PASSWORD=local_pass
MONGODB_URI=mongodb://localhost:27017/edugo
RABBITMQ_URL=amqp://localhost:5672/
OPENAI_API_KEY=sk-dev-key
```

### Dev/QA/Prod
- **Opción 1** (Inicial): Variables de ambiente en servidor
- **Opción 2** (Futuro): HashiCorp Vault
- **Opción 3** (Kubernetes): Kubernetes Secrets + External Secrets Operator

**NUNCA** commitear secretos en archivos YAML

---

## ✅ PRECEDENCIA DE CONFIGURACIÓN

Viper usa esta precedencia (mayor a menor):

1. **viper.Set()** - Valores explícitos en código
2. **Environment Variables** - `EDUGO_MOBILE_SERVER_PORT=8080`
3. **Archivo específico** - `config-dev.yaml`
4. **Archivo base** - `config.yaml`
5. **Defaults** - `viper.SetDefault()`

Esto permite:
- Desarrollo local: usar `config-local.yaml`
- CI/CD: sobrescribir con ENV vars
- Producción: ENV vars + Vault

---

## 📝 EJEMPLO DE USO

```bash
# Local (por defecto)
go run cmd/main.go

# Development
APP_ENV=dev go run cmd/main.go

# QA
APP_ENV=qa go run cmd/main.go

# Production
APP_ENV=prod \
  POSTGRES_PASSWORD=secret123 \
  MONGODB_URI=mongodb://prod-host/edugo \
  OPENAI_API_KEY=sk-prod-key \
  go run cmd/main.go

# Docker
APP_ENV=dev docker-compose up
```

---

## 🎯 VENTAJAS

1. ✅ **Configuración centralizada** (igual que Spring Boot)
2. ✅ **Type-safe** (structs en lugar de strings)
3. ✅ **Ambiente dinámico** (cambiar con APP_ENV)
4. ✅ **Secretos seguros** (nunca en código)
5. ✅ **Hot-reload** (opcional, con WatchConfig)
6. ✅ **Validación** (tipos, required fields)
7. ✅ **Fácil testing** (mockear configuración)

---

## ⚠️ CONSIDERACIONES DE SEGURIDAD

1. **NO commitear secretos**: Agregar `config/*-prod.yaml` a .gitignore (excepto template)
2. **Environment variables**: Preferir para secretos
3. **Validación**: Validar que secretos obligatorios estén presentes al inicio
4. **Logs**: NO loggear passwords/api keys
5. **Producción**: Usar Vault o Kubernetes Secrets (futuro)

---

## 📋 CHECKLIST DE IMPLEMENTACIÓN

### Por Proyecto (api-mobile, api-administracion, worker)

- [ ] Crear carpeta `config/`
- [ ] Crear archivos YAML (5 archivos + README)
- [ ] Crear `internal/config/config.go` (structs)
- [ ] Crear `internal/config/loader.go` (Viper logic)
- [ ] Modificar `cmd/main.go` (usar config)
- [ ] Agregar dependencia Viper (`go get`)
- [ ] Actualizar `.gitignore` (secretos)
- [ ] Ejecutar `go mod tidy`
- [ ] Probar con diferentes APP_ENV
- [ ] Commit atómico

### Global

- [ ] Actualizar `docker-compose.yml`
- [ ] Actualizar `.env.example`
- [ ] Actualizar `docs/DEVELOPMENT.md`
- [ ] Actualizar `README.md`
- [ ] Commit final

---

## 🚀 ORDEN DE EJECUCIÓN

1. **api-mobile** (primero - más complejo, tiene todo)
2. **api-administracion** (copiar y ajustar)
3. **worker** (copiar y agregar NLP config)
4. **Global** (Docker + docs)

---

## ⏱️ ESTIMACIÓN TOTAL

| Fase | Proyecto | Tiempo |
|------|----------|--------|
| 1 | api-mobile | 1h |
| 2 | api-administracion | 30min |
| 3 | worker | 40min |
| 4 | Docker Compose | 20min |
| 5 | Documentación | 30min |
| **TOTAL** | **3 proyectos** | **3 horas** |

---

## 📦 ARCHIVOS A CREAR/MODIFICAR

**Por proyecto** (~10 archivos):
- `config/config.yaml`
- `config/config-local.yaml`
- `config/config-dev.yaml`
- `config/config-qa.yaml`
- `config/config-prod.yaml`
- `config/README.md`
- `internal/config/config.go`
- `internal/config/loader.go`
- `cmd/main.go` (modificar)
- `go.mod` (agregar Viper)

**Global** (3 archivos):
- `docker-compose.yml` (modificar)
- `.env.example` (modificar)
- Documentación

**Total**: ~33 archivos (30 nuevos + 3 modificados)

---

## 🎉 RESULTADO ESPERADO

Al finalizar:

```bash
# Cambiar entre ambientes fácilmente
APP_ENV=local go run cmd/main.go   # Lee config-local.yaml
APP_ENV=dev go run cmd/main.go     # Lee config-dev.yaml
APP_ENV=prod go run cmd/main.go    # Lee config-prod.yaml

# Sobrescribir con ENV vars
APP_ENV=dev SERVER_PORT=9090 go run cmd/main.go

# Docker
APP_ENV=qa make up
```

**Código limpio, configuración centralizada, secretos seguros** ✅

---

**¿Apruebas este plan para empezar la implementación?**
