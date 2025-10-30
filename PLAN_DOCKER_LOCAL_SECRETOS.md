# 📋 PLAN: Docker Local Persistente + Manejo Profesional de Secretos

**Objetivo**: Ambiente local con contenedores persistentes + sistema de secretos enterprise-ready

---

## 🎯 PROBLEMAS ACTUALES

### 1. Docker Actual (No Persistente)
❌ `docker-compose up/down` destruye contenedores
❌ Datos se pierden al bajar servicios
❌ No hay validación de datos existentes
❌ Lento (recrear todo cada vez)

### 2. Secretos Actuales (Básico)
⚠️ Valores hardcodeados en config-local.yaml
⚠️ .env.example con valores de ejemplo
⚠️ No hay encriptación de secretos
⚠️ No hay guía clara de manejo por ambiente

---

## 🎯 SOLUCIÓN PROPUESTA

### 1. Docker Compose Local Persistente (Por Proyecto)

**Concepto**: Contenedores que viven más allá del ciclo de la app

```
source/api-mobile/
├── docker-compose.local.yml    # Infraestructura local (postgres, mongo, rabbitmq)
├── scripts/
│   ├── check-db-health.sh      # Valida si BD tiene datos
│   └── init-local-db.sh        # Inicializa BD solo si es necesario
```

**Comportamiento**:
```bash
# Primera vez
docker-compose -f docker-compose.local.yml up -d
→ Crea contenedores
→ Ejecuta scripts de migración
→ Carga datos de prueba
→ Contenedores quedan corriendo

# App termina
→ Contenedores siguen corriendo (NO se destruyen)

# Segunda ejecución (al día siguiente)
docker-compose -f docker-compose.local.yml up -d
→ Detecta contenedores existentes
→ Verifica que tengan datos
→ Si tienen datos: solo conecta
→ Si no tienen datos: ejecuta migración
→ App se conecta
```

### 2. Manejo Profesional de Secretos

**Por Ambiente**:

| Ambiente | Método de Secretos | Archivo | Encriptado |
|----------|-------------------|---------|------------|
| **local** | Valores en config-local.yaml | Sí | ❌ No (OK para local) |
| **dev** | .env.dev (gitignored) | Sí | ✅ SOPS (opcional) |
| **qa** | .env.qa (gitignored) | Sí | ✅ SOPS |
| **prod** | Kubernetes Secrets / Vault | No | ✅ Vault |

**Estructura de Secretos**:
```
/
├── .env.local           # Local (committed, valores de desarrollo)
├── .env.dev             # Dev (gitignored, valores reales)
├── .env.dev.enc         # Dev encriptado con SOPS (committed)
├── .env.qa.enc          # QA encriptado (committed)
├── .env.prod.enc        # Prod encriptado (committed)
├── .sops.yaml           # Configuración SOPS
└── scripts/
    ├── decrypt-secrets.sh    # Desencriptar para uso local
    └── encrypt-secrets.sh    # Encriptar antes de commit
```

---

## 🏗️ ESTRUCTURA PROPUESTA

### Por Proyecto (api-mobile, api-administracion, worker)

```
source/api-mobile/
├── config/
│   ├── config.yaml              # Base
│   ├── config-local.yaml        # Local (valores fijos OK)
│   ├── config-dev.yaml          # Dev (usa .env.dev)
│   ├── config-qa.yaml           # QA (usa .env.qa)
│   └── config-prod.yaml         # Prod (usa secrets manager)
│
├── docker/
│   ├── docker-compose.local.yml    # Infraestructura local persistente
│   ├── .env.local                  # Secretos local (committed)
│   └── README.md                   # Guía de uso
│
├── scripts/
│   ├── dev/
│   │   ├── start-local.sh          # Inicia infraestructura + app
│   │   ├── stop-local.sh           # Detiene app (mantiene contenedores)
│   │   ├── clean-local.sh          # Destruye todo y resetea
│   │   ├── check-db.sh             # Valida estado de BD
│   │   └── init-db.sh              # Inicializa BD si es necesario
│   │
│   └── secrets/
│       ├── decrypt.sh              # Desencripta secretos
│       └── encrypt.sh              # Encripta secretos
```

### Raíz (Orquestador)

```
/
├── docker/
│   ├── docker-compose.local.yml    # Infraestructura compartida
│   └── .env.local                  # Secretos local compartidos
│
├── .env.local                      # Secretos local (committed - OK)
├── .env.dev                        # Secretos dev (gitignored)
├── .env.dev.enc                    # Secretos dev encriptados (committed)
├── .env.qa.enc                     # Secretos QA encriptados (committed)
├── .env.prod.enc                   # Secretos prod encriptados (committed)
│
├── .sops.yaml                      # Configuración SOPS (Age/GPG)
│
└── scripts/
    ├── local-start-all.sh          # Inicia infraestructura + 3 apps
    ├── local-stop-all.sh           # Detiene apps (mantiene infra)
    ├── local-clean-all.sh          # Destruye todo
    └── secrets/
        ├── setup-sops.sh           # Setup inicial SOPS
        ├── decrypt-all.sh          # Desencripta todos los .env.*.enc
        └── encrypt-all.sh          # Encripta todos los .env.*
```

---

## 🔧 IMPLEMENTACIÓN DETALLADA

### PARTE 1: Docker Compose Local Persistente

#### docker-compose.local.yml (por proyecto)

```yaml
# source/api-mobile/docker/docker-compose.local.yml
version: '3.8'

services:
  postgres-local:
    image: postgres:15-alpine
    container_name: edugo-api-mobile-postgres-local
    environment:
      POSTGRES_DB: edugo
      POSTGRES_USER: edugo_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-edugo_pass}
    ports:
      - "5432:5432"
    volumes:
      - api-mobile-postgres-data:/var/lib/postgresql/data  # Persistente
      - ../../scripts/postgresql:/docker-entrypoint-initdb.d:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U edugo_user -d edugo"]
      interval: 5s
      timeout: 3s
      retries: 5
    restart: unless-stopped  # Auto-reinicia si falla
    networks:
      - api-mobile-local

  mongodb-local:
    image: mongo:7.0
    container_name: edugo-api-mobile-mongodb-local
    environment:
      MONGO_INITDB_ROOT_USERNAME: edugo_admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGODB_PASSWORD:-edugo_pass}
      MONGO_INITDB_DATABASE: edugo
    ports:
      - "27017:27017"
    volumes:
      - api-mobile-mongodb-data:/data/db  # Persistente
      - ../../scripts/mongodb:/docker-entrypoint-initdb.d:ro
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/edugo --quiet
      interval: 5s
      timeout: 3s
      retries: 5
    restart: unless-stopped
    networks:
      - api-mobile-local

  rabbitmq-local:
    image: rabbitmq:3.12-management-alpine
    container_name: edugo-api-mobile-rabbitmq-local
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER:-edugo_user}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD:-edugo_pass}
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - api-mobile-rabbitmq-data:/var/lib/rabbitmq  # Persistente
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    restart: unless-stopped
    networks:
      - api-mobile-local

volumes:
  api-mobile-postgres-data:
    name: edugo-api-mobile-postgres-data
  api-mobile-mongodb-data:
    name: edugo-api-mobile-mongodb-data
  api-mobile-rabbitmq-data:
    name: edugo-api-mobile-rabbitmq-data

networks:
  api-mobile-local:
    name: edugo-api-mobile-local
    driver: bridge
```

**Características**:
- ✅ Volúmenes con nombre (persisten datos)
- ✅ `restart: unless-stopped` (auto-reinicia)
- ✅ Health checks rápidos (5s interval)
- ✅ Scripts de init solo se ejecutan en primera creación
- ✅ `.env.local` para sobrescribir valores

#### Scripts de Gestión Local

**scripts/dev/start-local.sh**:
```bash
#!/bin/bash

# Verificar si contenedores existen
if docker ps -a --format '{{.Names}}' | grep -q "edugo-api-mobile-postgres-local"; then
    echo "📦 Contenedores existentes detectados, reutilizando..."
    docker-compose -f docker/docker-compose.local.yml start
    
    # Verificar si BD tiene datos
    ./scripts/dev/check-db.sh
    if [ $? -eq 0 ]; then
        echo "✅ BD tiene datos, conectando..."
    else
        echo "⚠️  BD vacía, ejecutando migración..."
        ./scripts/dev/init-db.sh
    fi
else
    echo "🆕 Primera vez, creando contenedores..."
    docker-compose -f docker/docker-compose.local.yml up -d
    sleep 10
    echo "✅ Contenedores creados y datos cargados"
fi

# Iniciar aplicación
echo "🚀 Iniciando API Mobile..."
make run
```

**scripts/dev/check-db.sh**:
```bash
#!/bin/bash

# Verificar que PostgreSQL tenga datos
docker exec edugo-api-mobile-postgres-local psql -U edugo_user -d edugo -c \
  "SELECT COUNT(*) FROM app_user;" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ PostgreSQL tiene datos"
    exit 0
else
    echo "❌ PostgreSQL sin datos"
    exit 1
fi
```

**scripts/dev/clean-local.sh**:
```bash
#!/bin/bash

echo "⚠️  ADVERTENCIA: Esto eliminará TODOS los datos locales"
read -p "¿Estás seguro? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    docker-compose -f docker/docker-compose.local.yml down -v
    echo "✅ Contenedores y volúmenes eliminados"
else
    echo "Cancelado"
fi
```

---

### PARTE 2: Manejo Profesional de Secretos

#### Estrategia por Ambiente

**LOCAL** (desarrollo en laptop):
```yaml
# config-local.yaml (puede estar en git)
database:
  postgres:
    password: "edugo_pass"  # Valor fijo OK
  mongodb:
    uri: "mongodb://edugo_admin:edugo_pass@localhost:27017/edugo"
```

**DEV/QA** (servidores compartidos):
```yaml
# config-dev.yaml (en git, sin secretos)
database:
  postgres:
    host: "dev-postgres.company.com"
    # password se lee de ENV: POSTGRES_PASSWORD

# .env.dev (gitignored, valores reales)
POSTGRES_PASSWORD=dev_real_password_123
MONGODB_URI=mongodb://user:realpass@dev-mongo:27017/edugo
OPENAI_API_KEY=sk-dev-real-key

# .env.dev.enc (committed, encriptado con SOPS)
# Mismo contenido pero encriptado
```

**PROD** (Kubernetes/Cloud):
```yaml
# config-prod.yaml (en git, sin secretos)
database:
  postgres:
    host: "prod-postgres.rds.aws.com"
    # password desde Kubernetes Secret o Vault

# Kubernetes Secret o AWS Secrets Manager
# NO usar archivos .env
```

#### Configuración SOPS (Opcional pero Recomendado)

**Instalar SOPS**:
```bash
# macOS
brew install sops age

# Generar clave Age
age-keygen -o ~/.config/sops/age/keys.txt
# Guardar clave pública en .sops.yaml
```

**.sops.yaml**:
```yaml
creation_rules:
  - path_regex: \.env\.(dev|qa)\.enc$
    age: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
  
  - path_regex: \.env\.prod\.enc$
    age: age1production_key_here
```

**Workflow**:
```bash
# Editar secretos dev
vim .env.dev

# Encriptar
sops -e .env.dev > .env.dev.enc

# Commitear encriptado
git add .env.dev.enc
git commit -m "chore: update dev secrets"

# Otro developer desencripta
sops -d .env.dev.enc > .env.dev

# Usar en app
APP_ENV=dev go run cmd/main.go  # Lee .env.dev
```

---

## 📁 ESTRUCTURA DETALLADA

### Por Proyecto

```
source/api-mobile/
├── config/
│   ├── config.yaml              # Base (sin secretos)
│   ├── config-local.yaml        # Local (valores fijos OK)
│   ├── config-dev.yaml          # Dev (referencias a ENV)
│   ├── config-qa.yaml           # QA (referencias a ENV)
│   └── config-prod.yaml         # Prod (referencias a ENV)
│
├── docker/
│   ├── docker-compose.local.yml    # Infraestructura local persistente
│   ├── .env.local                  # Secretos local (committed)
│   └── README.md
│
├── scripts/
│   └── dev/
│       ├── start-local.sh          # Inicia infra + app
│       ├── stop-app.sh             # Detiene solo app
│       ├── stop-infra.sh           # Detiene contenedores (mantiene datos)
│       ├── clean-all.sh            # Destruye todo (con confirmación)
│       ├── check-db.sh             # Valida datos en BD
│       └── init-db.sh              # Inicializa BD
│
├── .env.dev                        # Gitignored (valores reales)
├── .env.dev.enc                    # Committed (encriptado SOPS)
├── .env.qa.enc                     # Committed (encriptado SOPS)
└── .env.prod.enc                   # Committed (encriptado SOPS)
```

### Raíz (Compartido)

```
/
├── docker/
│   ├── docker-compose.local.yml    # Infraestructura compartida (3 proyectos)
│   └── README.md
│
├── scripts/
│   ├── local/
│   │   ├── start-all-local.sh      # Inicia infra + 3 apps
│   │   ├── stop-apps.sh            # Detiene apps (mantiene infra)
│   │   ├── stop-all.sh             # Detiene todo (mantiene datos)
│   │   ├── clean-all.sh            # Destruye todo (confirmación)
│   │   └── status.sh               # Estado de contenedores
│   │
│   └── secrets/
│       ├── setup-sops.sh           # Setup inicial SOPS
│       ├── decrypt-all.sh          # Desencripta .env.*.enc → .env.*
│       ├── encrypt-all.sh          # Encripta .env.* → .env.*.enc
│       └── README.md               # Guía de secretos
│
├── .env.local                      # Local (committed - valores desarrollo)
├── .env.dev                        # Gitignored (valores reales dev)
├── .env.dev.enc                    # Committed (encriptado)
├── .env.qa.enc                     # Committed (encriptado)
├── .env.prod.enc                   # Committed (encriptado)
│
├── .sops.yaml                      # Configuración SOPS
└── .gitignore                      # Actualizado con .env.dev, .env.qa, .env.prod
```

---

## 🔐 MANEJO DE SECRETOS POR AMBIENTE

### LOCAL (Laptop del Developer)

**Archivo**: `config-local.yaml` + `docker/.env.local`

```yaml
# config-local.yaml (puede commitarse)
database:
  postgres:
    host: "localhost"
    password: "edugo_pass"  # Valor fijo OK
```

```env
# docker/.env.local (puede commitarse)
POSTGRES_PASSWORD=edugo_pass
MONGODB_PASSWORD=edugo_pass
RABBITMQ_PASSWORD=edugo_pass
OPENAI_API_KEY=sk-test-key-local
```

**Uso**:
```bash
./scripts/local/start-all-local.sh
# Lee docker/.env.local automáticamente
# Contenedores se crean/reusan
# App se conecta
```

### DEV/QA (Servidores Compartidos)

**Archivo**: `.env.dev` (gitignored) o `.env.dev.enc` (committed)

```env
# .env.dev (NO commitear, valores reales)
POSTGRES_PASSWORD=dev_secure_password_XYZ123
MONGODB_URI=mongodb://admin:dev_mongo_pass@dev-mongo.company.com:27017/edugo
RABBITMQ_URL=amqp://user:dev_rabbit_pass@dev-rabbit.company.com:5672/
OPENAI_API_KEY=sk-proj-dev-real-key-abc123xyz
```

**Encriptar con SOPS**:
```bash
# Encriptar
sops -e .env.dev > .env.dev.enc

# Commitear encriptado
git add .env.dev.enc
git commit -m "chore: update dev secrets"
git push

# Otro developer desencripta
sops -d .env.dev.enc > .env.dev

# Usar
APP_ENV=dev go run cmd/main.go
```

**Sin SOPS (alternativa)**:
```bash
# Cada developer crea su propio .env.dev (gitignored)
cp .env.dev.template .env.dev
# Pedir secretos al team lead
vim .env.dev  # Agregar valores reales

# Usar
APP_ENV=dev go run cmd/main.go
```

### PROD (Kubernetes/Cloud)

**NO usar archivos .env**

**Opción 1: Kubernetes Secrets**
```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: edugo-api-mobile-secrets
type: Opaque
data:
  POSTGRES_PASSWORD: <base64>
  MONGODB_URI: <base64>
  OPENAI_API_KEY: <base64>
```

**Opción 2: HashiCorp Vault**
```bash
# Leer secretos de Vault en runtime
vault kv get secret/edugo/prod/api-mobile
```

**Opción 3: AWS Secrets Manager**
```go
// Leer secretos de AWS en código
import "github.com/aws/aws-sdk-go/service/secretsmanager"
```

---

## 📋 FASES DE IMPLEMENTACIÓN

### FASE 1: Docker Compose Local Persistente (1.5 horas)

**1.1. Crear estructura docker/ en cada proyecto** (20min)
- `docker/docker-compose.local.yml` en api-mobile
- `docker/docker-compose.local.yml` en api-administracion  
- `docker/docker-compose.local.yml` en worker
- Volúmenes nombrados para persistencia
- `restart: unless-stopped`

**1.2. Crear docker/ compartido en raíz** (15min)
- `docker/docker-compose.local.yml` (infraestructura compartida)
- Red compartida entre los 3 proyectos

**1.3. Scripts de gestión por proyecto** (30min)
- `scripts/dev/start-local.sh` (detecta contenedores existentes)
- `scripts/dev/stop-app.sh` (solo app)
- `scripts/dev/stop-infra.sh` (contenedores sin eliminar datos)
- `scripts/dev/clean-all.sh` (destruye todo con confirmación)
- `scripts/dev/check-db.sh` (valida datos)
- `scripts/dev/init-db.sh` (migración si es necesario)

**1.4. Scripts raíz (orquestador)** (15min)
- `scripts/local/start-all-local.sh`
- `scripts/local/stop-apps.sh`
- `scripts/local/stop-all.sh`
- `scripts/local/clean-all.sh`
- `scripts/local/status.sh`

**1.5. Actualizar Makefiles** (10min)
- `make local-up` - Inicia infraestructura
- `make local-down` - Detiene sin eliminar datos
- `make local-clean` - Destruye todo
- `make local-status` - Ver estado

**Commit 1**: `feat: add persistent Docker Compose for local development (per project)`
**Commit 2**: `feat: add local development scripts with data validation`

---

### FASE 2: Sistema de Secretos (1 hora)

**2.1. Crear archivos .env por ambiente** (15min)
- `.env.local` (committed - valores desarrollo)
- `.env.dev.template` (template para dev)
- `.env.qa.template` (template para qa)
- `.env.prod.template` (template para prod)
- Actualizar `.gitignore` (ignore .env.dev, .env.qa, .env.prod)

**2.2. Setup SOPS (opcional)** (20min)
- Instalar SOPS + Age
- Crear `.sops.yaml`
- `scripts/secrets/setup-sops.sh`
- Documentar setup de claves

**2.3. Scripts de encriptación** (15min)
- `scripts/secrets/encrypt.sh` (encripta .env.* → .env.*.enc)
- `scripts/secrets/decrypt.sh` (desencripta .env.*.enc → .env.*)
- `scripts/secrets/encrypt-all.sh`
- `scripts/secrets/decrypt-all.sh`

**2.4. Actualizar loader.go para leer .env** (10min)
- Modificar `internal/config/loader.go`
- Cargar `.env.{APP_ENV}` antes de YAML
- Precedencia: ENV runtime > .env.{env} > config-{env}.yaml > config.yaml

**Commit 1**: `feat: add environment-specific .env files structure`
**Commit 2**: `feat: add SOPS encryption for secrets (optional)`
**Commit 3**: `chore: update config loader to support .env files`

---

### FASE 3: Documentación de Secretos (30min)

**3.1. Crear SECRETS.md** (20min)
- Guía completa de manejo de secretos
- Workflow por ambiente
- Setup de SOPS (opcional)
- Troubleshooting

**3.2. Actualizar DEVELOPMENT.md** (10min)
- Sección "Manejo de Secretos"
- Ejemplos por ambiente
- Best practices

**Commit**: `docs: add comprehensive secrets management guide`

---

## ⏱️ ESTIMACIÓN TOTAL

| Fase | Tiempo | Commits |
|------|--------|---------|
| 1. Docker Local Persistente | 1.5h | 2 |
| 2. Sistema de Secretos | 1h | 3 |
| 3. Documentación | 30min | 1 |
| **TOTAL** | **3 horas** | **6 commits** |

---

## 🎯 RESULTADO ESPERADO

### Workflow LOCAL

```bash
# Primera vez
cd source/api-mobile
./scripts/dev/start-local.sh
→ Crea contenedores (postgres, mongo, rabbitmq)
→ Ejecuta scripts de migración
→ Inicia API Mobile
→ ✅ Ready en http://localhost:8080

# Termino de trabajar (cerrar terminal)
→ Contenedores quedan corriendo (NO se destruyen)

# Al día siguiente
./scripts/dev/start-local.sh
→ Detecta contenedores existentes ✓
→ Verifica que tengan datos ✓
→ Solo inicia la app ✓
→ ✅ Rápido (sin recrear contenedores)

# Resetear todo
./scripts/dev/clean-all.sh
→ Confirma antes de destruir
→ Elimina contenedores y volúmenes
```

### Workflow DEV/QA

```bash
# Developer recibe el proyecto
git clone repo
cd source/api-mobile

# Desencriptar secretos
../../scripts/secrets/decrypt.sh dev
→ Crea .env.dev desde .env.dev.enc

# Ejecutar
APP_ENV=dev make run
→ Lee .env.dev
→ Conecta a servidor dev remoto
```

### Workflow PROD

```bash
# NO usar archivos .env
# Secretos desde Kubernetes Secrets o Vault

# Deploy
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/deployment.yaml
→ App lee secretos desde Kubernetes
```

---

## 🔐 VENTAJAS DEL SISTEMA DE SECRETOS

1. ✅ **Local**: Valores fijos, fácil setup
2. ✅ **Dev/QA**: Encriptados en git (SOPS), seguros
3. ✅ **Prod**: Vault/K8s Secrets (enterprise-grade)
4. ✅ **Gitignore**: .env.dev/qa/prod nunca en git
5. ✅ **Audit**: Cambios en .env.*.enc trackeados en git
6. ✅ **Team**: Todos usan mismos secretos (encriptados)
7. ✅ **Rotation**: Fácil rotar (re-encriptar)

---

## 📝 ARCHIVOS A CREAR

### Por Proyecto (×3)
- `docker/docker-compose.local.yml`
- `docker/.env.local`
- `docker/README.md`
- `scripts/dev/start-local.sh`
- `scripts/dev/stop-app.sh`
- `scripts/dev/stop-infra.sh`
- `scripts/dev/clean-all.sh`
- `scripts/dev/check-db.sh`
- `scripts/dev/init-db.sh`
- `.env.dev.template`
- `.env.qa.template`

**Subtotal**: 11 archivos × 3 = 33 archivos

### Raíz
- `docker/docker-compose.local.yml`
- `scripts/local/start-all-local.sh`
- `scripts/local/stop-apps.sh`
- `scripts/local/stop-all.sh`
- `scripts/local/clean-all.sh`
- `scripts/local/status.sh`
- `scripts/secrets/setup-sops.sh`
- `scripts/secrets/encrypt.sh`
- `scripts/secrets/decrypt.sh`
- `scripts/secrets/encrypt-all.sh`
- `scripts/secrets/decrypt-all.sh`
- `scripts/secrets/README.md`
- `.env.local`
- `.env.dev.template`
- `.env.qa.template`
- `.env.prod.template`
- `.sops.yaml`
- `SECRETS.md`

**Total raíz**: 18 archivos

**GRAN TOTAL**: ~51 archivos nuevos

---

## 🎯 ALTERNATIVA SIMPLIFICADA (Sin SOPS)

Si no quieres usar SOPS (encriptación):

**Workflow**:
1. Tener `.env.{env}.template` en git (sin valores reales)
2. Cada developer crea su `.env.dev` local (gitignored)
3. Team lead comparte secretos por canal seguro (Slack privado, 1Password, etc.)

**Ventaja**: Más simple
**Desventaja**: Menos seguro, secretos no versionados

---

## ❓ PREGUNTAS PARA DECIDIR

1. **¿Quieres implementar SOPS** (encriptación de secretos)?
   - Sí: Más seguro, enterprise-grade
   - No: Usar templates + gitignore (más simple)

2. **¿Docker local por proyecto o compartido**?
   - Por proyecto: Cada uno tiene sus contenedores (aislado)
   - Compartido: Un solo PostgreSQL/MongoDB para los 3 (menos recursos)

3. **¿Implementar TODO ahora** o solo Docker persistente primero?
   - Todo: 3 horas completas
   - Solo Docker: 1.5 horas

---

**Plan guardado en**: `PLAN_DOCKER_LOCAL_SECRETOS.md`

**¿Qué enfoque prefieres?**

A) Implementar TODO (Docker persistente + SOPS + scripts)
B) Solo Docker persistente (sin SOPS)
C) Crear un plan más simple

**Y sobre Docker**: ¿Compartido o por proyecto?
