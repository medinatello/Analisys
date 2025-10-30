# Plan de Separación y CI/CD - EduGo

**Fecha creación:** 30 de Octubre, 2025
**Proyecto:** EduGo - Transición a Multi-Repo con CI/CD
**Estrategia:** GitHub (repos) + GitLab CI/CD + Container Registry

---

## 📊 Resumen Ejecutivo

### Estructura Final (5 repositorios)
```
GitHub Organization: edugo
├── edugo-shared/              (Go module compartido)
├── edugo-api-mobile/          (Backend API Mobile)
├── edugo-api-administracion/  (Backend API Admin)
├── edugo-worker/              (Worker procesador)
└── edugo-dev-environment/     (Docker Compose + Docs + Scripts)
```

### Flujo de Trabajo Final
```
Código → GitHub → GitLab (mirror automático)
                    ↓
              GitLab CI/CD (self-hosted runners)
                    ↓
              Build Docker images
                    ↓
              Push a GitHub Container Registry (ghcr.io)
                    ↓
              Developers: docker pull ghcr.io/edugo/api-mobile:latest
```

### Tiempo Estimado Total
- **FASE 1:** Pre-Separación (5-7 días)
- **FASE 2:** Setup GitHub + GitLab CI/CD (2-3 días)
- **FASE 3:** Separación de Repositorios (3-4 días)
- **FASE 4:** Docker Compose y Ambiente Dev (2-3 días)
- **FASE 5:** Documentación Final (1 día)

**TOTAL:** 13-18 días de trabajo

---

## ✅ FASE 1: Pre-Separación (5-7 días)

### Objetivo
Preparar el proyecto actual para la separación sin romper nada.

---

### 1.1 Documentación y Análisis (Día 1-2)

#### ✓ Documentar dependencias de shared/
- [x] Crear archivo `shared/DEPENDENCIAS.md`
- [x] Listar todos los paquetes en `shared/pkg/`:
  ```
  pkg/auth/        - Autenticación JWT
  pkg/config/      - Configuración
  pkg/database/    - PostgreSQL y MongoDB
  pkg/errors/      - Manejo de errores
  pkg/logger/      - Logging con Zap
  pkg/messaging/   - RabbitMQ
  pkg/types/       - Tipos compartidos
  pkg/validator/   - Validación
  ```
- [x] Documentar qué servicio usa qué paquete:
  ```
  api-mobile usa:
    - auth (JWT tokens)
    - database (PostgreSQL)
    - messaging (publica a RabbitMQ)
    - logger
    - types

  api-administracion usa:
    - auth
    - database
    - logger
    - types

  worker usa:
    - database (PostgreSQL y MongoDB)
    - messaging (consume de RabbitMQ)
    - logger
    - types
  ```

#### ✓ Documentar variables de entorno
- [x] Crear archivo `VARIABLES_ENTORNO.md` en raíz
- [x] Listar todas las variables por servicio:
  ```
  api-mobile:
    - DB_HOST, DB_PORT, DB_USER, DB_PASS, DB_NAME
    - RABBITMQ_HOST, RABBITMQ_PORT, RABBITMQ_USER, RABBITMQ_PASS
    - JWT_SECRET
    - PORT (8081)

  api-administracion:
    - DB_HOST, DB_PORT, DB_USER, DB_PASS, DB_NAME
    - JWT_SECRET
    - PORT (8082)

  worker:
    - DB_HOST, DB_PORT, DB_USER, DB_PASS, DB_NAME
    - MONGO_HOST, MONGO_PORT, MONGO_USER, MONGO_PASS, MONGO_DB
    - RABBITMQ_HOST, RABBITMQ_PORT, RABBITMQ_USER, RABBITMQ_PASS
    - S3_BUCKET, S3_REGION (futuro)
  ```

#### ✓ Documentar flujos críticos
- [x] Crear diagrama de flujo:
  ```
  Usuario → api-mobile → PostgreSQL (guarda evaluación)
                      → RabbitMQ (publica job)

  Worker → RabbitMQ (consume job)
        → Procesa PDF
        → MongoDB (guarda summary)
        → PostgreSQL (actualiza estado)
  ```

---

### 1.2 Tests de Integración (Día 2-3)

#### ✓ Tests para shared/
- [x] Crear `shared/pkg/auth/auth_test.go`
  ```go
  func TestGenerateToken(t *testing.T) {
      // Test generación de JWT
  }

  func TestValidateToken(t *testing.T) {
      // Test validación de JWT
  }
  ```
- [x] Crear `shared/pkg/database/database_test.go`
  ```go
  func TestPostgreSQLConnection(t *testing.T) {
      // Test conexión PostgreSQL
  }

  func TestMongoDBConnection(t *testing.T) {
      // Test conexión MongoDB
  }
  ```
- [x] Crear `shared/pkg/messaging/rabbitmq_test.go`
  ```go
  func TestPublishMessage(t *testing.T) {
      // Test publicar mensaje
  }

  func TestConsumeMessage(t *testing.T) {
      // Test consumir mensaje
  }
  ```
- [x] Ejecutar todos los tests:
  ```bash
  cd shared
  go test -v ./...
  # Objetivo: 100% de los tests pasan
  ```

#### ✓ Tests de integración entre servicios
- [x] Crear `tests/integration/api_to_worker_test.go`
  ```go
  func TestFullWorkflow(t *testing.T) {
      // 1. API mobile crea evaluación
      // 2. Publica mensaje a RabbitMQ
      // 3. Worker lo consume
      // 4. Worker procesa y guarda en MongoDB
      // 5. Verificar resultado
  }
  ```
- [x] Ejecutar test de integración:
  ```bash
  # Levantar servicios con docker-compose
  docker-compose up -d postgres mongodb rabbitmq

  # Ejecutar tests
  go test -v ./tests/integration/...
  ```

---

### 1.3 Dockerización (Día 3-4)

#### ✓ Crear Dockerfiles para cada servicio

**api-mobile:**
- [x] Crear `source/api-mobile/Dockerfile`:
  ```dockerfile
  # Build stage
  FROM golang:1.23-alpine AS builder
  WORKDIR /app

  # Copiar go.mod y go.sum
  COPY go.mod go.sum ./
  RUN go mod download

  # Copiar código fuente
  COPY . .

  # Build
  RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o api-mobile ./cmd/api-mobile

  # Runtime stage
  FROM alpine:latest
  RUN apk --no-cache add ca-certificates
  WORKDIR /app

  COPY --from=builder /app/api-mobile .
  COPY --from=builder /app/config ./config

  EXPOSE 8080
  CMD ["./api-mobile"]
  ```

- [x] Crear `source/api-mobile/.dockerignore`:
  ```
  .git
  .gitignore
  README.md
  *.md
  tests/
  .env
  tmp/
  ```

**api-administracion:**
- [x] Crear `source/api-administracion/Dockerfile` (similar a api-mobile)
- [x] Crear `source/api-administracion/.dockerignore`

**worker:**
- [x] Crear `source/worker/Dockerfile`:
  ```dockerfile
  FROM golang:1.23-alpine AS builder
  WORKDIR /app

  COPY go.mod go.sum ./
  RUN go mod download

  COPY . .
  RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o worker ./cmd/worker

  FROM alpine:latest
  RUN apk --no-cache add ca-certificates
  WORKDIR /app

  COPY --from=builder /app/worker .
  COPY --from=builder /app/config ./config

  CMD ["./worker"]
  ```
- [x] Crear `source/worker/.dockerignore`

#### ✓ Probar builds locales
- [x] Build api-mobile:
  ```bash
  cd source/api-mobile
  docker build -t edugo-api-mobile:dev .
  # Verificar que build es exitoso
  ```
- [x] Build api-administracion:
  ```bash
  cd source/api-administracion
  docker build -t edugo-api-administracion:dev .
  ```
- [x] Build worker:
  ```bash
  cd source/worker
  docker build -t edugo-worker:dev .
  ```

---

### 1.4 Docker Compose Actual (Día 4-5)

#### ✓ Crear docker-compose para desarrollo actual
- [x] Crear `docker-compose.dev.yml` en raíz:
  ```yaml
  version: '3.8'

  services:
    postgres:
      image: postgres:16-alpine
      container_name: edugo-postgres
      environment:
        POSTGRES_DB: edugo
        POSTGRES_USER: edugo
        POSTGRES_PASSWORD: edugo123
      ports:
        - "5432:5432"
      volumes:
        - postgres-data:/var/lib/postgresql/data
      healthcheck:
        test: ["CMD-SHELL", "pg_isready -U edugo"]
        interval: 10s
        timeout: 5s
        retries: 5

    mongodb:
      image: mongo:7.0
      container_name: edugo-mongodb
      environment:
        MONGO_INITDB_ROOT_USERNAME: edugo
        MONGO_INITDB_ROOT_PASSWORD: edugo123
      ports:
        - "27017:27017"
      volumes:
        - mongodb-data:/data/db
      healthcheck:
        test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
        interval: 10s
        timeout: 5s
        retries: 5

    rabbitmq:
      image: rabbitmq:3.12-management-alpine
      container_name: edugo-rabbitmq
      environment:
        RABBITMQ_DEFAULT_USER: edugo
        RABBITMQ_DEFAULT_PASS: edugo123
      ports:
        - "5672:5672"    # AMQP
        - "15672:15672"  # Management UI
      volumes:
        - rabbitmq-data:/var/lib/rabbitmq
      healthcheck:
        test: ["CMD", "rabbitmq-diagnostics", "ping"]
        interval: 10s
        timeout: 5s
        retries: 5

    api-mobile:
      build:
        context: ./source/api-mobile
        dockerfile: Dockerfile
      container_name: edugo-api-mobile
      ports:
        - "8081:8080"
      environment:
        - DB_HOST=postgres
        - DB_PORT=5432
        - DB_USER=edugo
        - DB_PASS=edugo123
        - DB_NAME=edugo
        - RABBITMQ_HOST=rabbitmq
        - RABBITMQ_PORT=5672
        - RABBITMQ_USER=edugo
        - RABBITMQ_PASS=edugo123
        - JWT_SECRET=dev-secret-key-change-in-production
        - PORT=8080
      depends_on:
        postgres:
          condition: service_healthy
        rabbitmq:
          condition: service_healthy
      restart: unless-stopped

    api-administracion:
      build:
        context: ./source/api-administracion
        dockerfile: Dockerfile
      container_name: edugo-api-administracion
      ports:
        - "8082:8080"
      environment:
        - DB_HOST=postgres
        - DB_PORT=5432
        - DB_USER=edugo
        - DB_PASS=edugo123
        - DB_NAME=edugo
        - JWT_SECRET=dev-secret-key-change-in-production
        - PORT=8080
      depends_on:
        postgres:
          condition: service_healthy
      restart: unless-stopped

    worker:
      build:
        context: ./source/worker
        dockerfile: Dockerfile
      container_name: edugo-worker
      environment:
        - DB_HOST=postgres
        - DB_PORT=5432
        - DB_USER=edugo
        - DB_PASS=edugo123
        - DB_NAME=edugo
        - MONGO_HOST=mongodb
        - MONGO_PORT=27017
        - MONGO_USER=edugo
        - MONGO_PASS=edugo123
        - MONGO_DB=edugo
        - RABBITMQ_HOST=rabbitmq
        - RABBITMQ_PORT=5672
        - RABBITMQ_USER=edugo
        - RABBITMQ_PASS=edugo123
      depends_on:
        postgres:
          condition: service_healthy
        mongodb:
          condition: service_healthy
        rabbitmq:
          condition: service_healthy
      restart: unless-stopped

  volumes:
    postgres-data:
    mongodb-data:
    rabbitmq-data:
  ```

#### ✓ Probar docker-compose completo
- [x] Levantar todos los servicios:
  ```bash
  docker-compose -f docker-compose.dev.yml up -d
  ```
- [x] Verificar que todos los contenedores están corriendo:
  ```bash
  docker-compose -f docker-compose.dev.yml ps
  # Todos deben estar "Up"
  ```
- [x] Probar endpoints:
  ```bash
  # API Mobile health check
  curl http://localhost:8081/health

  # API Administración health check
  curl http://localhost:8082/health

  # RabbitMQ Management UI
  open http://localhost:15672
  # user: edugo, pass: edugo123
  ```
- [x] Probar flujo completo (crear evaluación → worker procesa)
- [x] Verificar logs:
  ```bash
  docker-compose -f docker-compose.dev.yml logs -f worker
  ```

---

### 1.5 Preparación de shared/ (Día 5-6)

#### ✓ Documentación de shared/
- [x] Crear `shared/README.md`:
  ```markdown
  # EduGo Shared Module

  Librería compartida para los microservicios de EduGo.

  ## Paquetes

  ### pkg/auth
  Autenticación JWT para usuarios y administradores.

  ### pkg/database
  Conexiones a PostgreSQL y MongoDB con pool de conexiones.

  ### pkg/messaging
  Cliente RabbitMQ para publicación y consumo de mensajes.

  ### pkg/logger
  Sistema de logging estructurado con Zap.

  ### pkg/types
  Tipos compartidos, enums y constantes.

  ### pkg/validator
  Validación de datos de entrada.

  ## Instalación

  ```bash
  go get github.com/edugo/edugo-shared@v0.1.0
  ```

  ## Versionamiento

  Seguimos [Semantic Versioning 2.0.0](https://semver.org/).

  ## Changelog

  Ver [CHANGELOG.md](CHANGELOG.md).
  ```

- [x] Crear `shared/CHANGELOG.md`:
  ```markdown
  # Changelog

  Todos los cambios notables a este proyecto serán documentados aquí.

  ## [Unreleased]

  ## [0.1.0] - 2025-10-30

  ### Añadido
  - Módulo de autenticación JWT
  - Conexiones a PostgreSQL y MongoDB
  - Cliente RabbitMQ (Publisher/Consumer)
  - Sistema de logging con Zap
  - Tipos compartidos y enums
  - Sistema de validación
  - Manejo de errores centralizado
  ```

#### ✓ Verificar go.mod de shared/
- [x] Verificar `shared/go.mod`:
  ```go
  module github.com/edugo/shared

  go 1.23

  require (
      github.com/golang-jwt/jwt/v5 v5.3.0
      github.com/lib/pq v1.10.9
      github.com/spf13/viper v1.21.0
      github.com/streadway/amqp v1.1.0
      go.mongodb.org/mongo-driver v1.17.6
      go.uber.org/zap v1.27.0
      // ... otras dependencias
  )
  ```
- [x] Ejecutar `go mod tidy` en shared/
- [x] Verificar que no hay dependencias circulares

#### ✓ Cobertura de tests en shared/
- [x] Ejecutar tests con cobertura:
  ```bash
  cd shared
  go test -coverprofile=coverage.out ./...
  go tool cover -html=coverage.out -o coverage.html
  open coverage.html
  ```
- [x] Objetivo: Mínimo 70% cobertura
- [x] Si falta cobertura, agregar tests faltantes

---

### 1.6 Backup y Plan de Rollback (Día 6-7)

#### ✓ Crear backup completo
- [x] Hacer backup del monorepo actual:
  ```bash
  cd /Users/jhoanmedina/source/EduGo
  tar -czf edugo-monorepo-backup-$(date +%Y%m%d).tar.gz Analisys/
  # Mover a lugar seguro
  mv edugo-monorepo-backup-*.tar.gz ~/Backups/
  ```
- [x] Crear tag en Git antes de separar:
  ```bash
  cd Analisys
  git tag -a monorepo-final -m "Último commit antes de separación"
  git push origin monorepo-final
  ```

#### ✓ Documentar plan de rollback
- [x] Crear `ROLLBACK_PLAN.md`:
  ```markdown
  # Plan de Rollback

  ## Si algo sale mal durante la separación:

  ### Opción 1: Volver a commit anterior
  ```bash
  git reset --hard monorepo-final
  ```

  ### Opción 2: Restaurar desde backup
  ```bash
  cd ~/Backups
  tar -xzf edugo-monorepo-backup-YYYYMMDD.tar.gz
  ```

  ### Opción 3: Revertir repos separados
  - Eliminar repos nuevos en GitHub
  - Volver a usar monorepo
  - Documentar qué falló para siguiente intento
  ```

---

## ✅ FASE 2: Setup GitHub + GitLab + Container Registry (2-3 días)

### Objetivo
Configurar la infraestructura CI/CD antes de separar repos.

---

### 2.1 Configuración de GitHub (Día 1)

#### ✓ Crear organización en GitHub
- [ ] Ir a https://github.com/organizations/new
- [ ] Nombre: `edugo` (o el que prefieras)
- [ ] Plan: Free
- [ ] Crear organización

#### ✓ Configurar GitHub Container Registry (ghcr.io)
- [ ] En tu cuenta personal: Settings > Developer settings > Personal access tokens
- [ ] Generate new token (classic)
- [ ] Scopes necesarios:
  - ✅ `repo` (Full control)
  - ✅ `write:packages`
  - ✅ `read:packages`
  - ✅ `delete:packages`
- [ ] Copiar token (guardar en lugar seguro)
- [ ] Configurar token localmente:
  ```bash
  export GITHUB_TOKEN="ghp_tuTokenAqui"
  echo $GITHUB_TOKEN | docker login ghcr.io -u TU_USUARIO --password-stdin
  ```
- [ ] Verificar login:
  ```bash
  docker info | grep ghcr.io
  ```

#### ✓ Crear repositorios placeholder (temporales)
**NOTA:** Solo para probar, borrarás y recrearás en FASE 3
- [ ] Crear repo `edugo/edugo-shared` (privado)
- [ ] Crear repo `edugo/edugo-api-mobile` (privado)
- [ ] Crear repo `edugo/edugo-api-administracion` (privado)
- [ ] Crear repo `edugo/edugo-worker` (privado)
- [ ] Crear repo `edugo/edugo-dev-environment` (privado)

---

### 2.2 Configuración de GitLab (Día 1-2)

#### ✓ Crear cuenta/organización en GitLab
- [ ] Ir a https://gitlab.com/
- [ ] Crear cuenta si no tienes
- [ ] Crear grupo: `edugo` (equivalente a organización)
  - Visibility: Private
  - Group URL: `https://gitlab.com/edugo`

#### ✓ Instalar GitLab Runner (self-hosted) en tu Mac/PC
- [ ] Instalar GitLab Runner:
  ```bash
  # macOS
  brew install gitlab-runner

  # Verificar instalación
  gitlab-runner --version
  ```

#### ✓ Registrar runner con GitLab
- [ ] Obtener registration token:
  - GitLab: Group edugo > Settings > CI/CD > Runners
  - Expandir "Runners"
  - Copiar "Registration token"

- [ ] Registrar runner:
  ```bash
  gitlab-runner register

  # Responder:
  # GitLab URL: https://gitlab.com/
  # Registration token: [pegar token]
  # Description: mac-local-runner
  # Tags: macos,docker,go,local
  # Executor: docker
  # Default Docker image: golang:1.23-alpine
  ```

- [ ] Iniciar runner:
  ```bash
  # Iniciar servicio
  gitlab-runner install
  gitlab-runner start

  # Verificar que está corriendo
  gitlab-runner status
  # Output: gitlab-runner: Service is running
  ```

- [ ] Verificar en GitLab UI:
  - Group edugo > Settings > CI/CD > Runners
  - Debería aparecer tu runner con punto verde (online)

#### ✓ Configurar mirroring de GitHub a GitLab (harás por cada repo)
**NOTA:** Lo configurarás en FASE 3 cuando crees los repos reales, pero aquí practicas con uno.

- [ ] En GitLab: Crear proyecto `edugo-shared` (ejemplo)
- [ ] Settings > Repository > Mirroring repositories
- [ ] Configurar mirror:
  ```
  Git repository URL: https://github.com/edugo/edugo-shared.git
  Mirror direction: Pull
  Authentication method: Password
  Password: [tu GitHub token]
  Only mirror protected branches: ☐ (desmarcar)
  Keep divergent refs: ☑ (marcar)
  ```
- [ ] Click "Mirror repository"
- [ ] Probar: Push algo a GitHub, esperar 5 min, verificar que aparece en GitLab

---

### 2.3 Probar CI/CD Pipeline Básico (Día 2-3)

#### ✓ Crear pipeline de prueba en uno de los repos
- [ ] En repo temporal `edugo-api-mobile` (GitHub):
- [ ] Crear `.gitlab-ci.yml`:
  ```yaml
  # .gitlab-ci.yml

  stages:
    - test
    - build
    - push

  variables:
    DOCKER_IMAGE: ghcr.io/edugo/api-mobile
    DOCKER_TLS_CERTDIR: "/certs"

  before_script:
    - echo "Pipeline started"

  test:
    stage: test
    image: golang:1.23-alpine
    tags:
      - docker
    script:
      - go version
      - go mod download
      - go test -v ./...
    only:
      - branches

  build:
    stage: build
    image: docker:latest
    services:
      - docker:dind
    tags:
      - docker
    before_script:
      - echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
    script:
      - docker build -t $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA .
      - docker build -t $DOCKER_IMAGE:latest .
      - echo "Build successful"
    only:
      - main
      - develop

  push:
    stage: push
    image: docker:latest
    services:
      - docker:dind
    tags:
      - docker
    before_script:
      - echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
    script:
      - docker build -t $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA .
      - docker push $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA
      - docker build -t $DOCKER_IMAGE:latest .
      - docker push $DOCKER_IMAGE:latest
      - echo "Pushed to ghcr.io/$DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA"
      - echo "Pushed to ghcr.io/$DOCKER_IMAGE:latest"
    only:
      - main
  ```

#### ✓ Configurar variables en GitLab
- [ ] GitLab: Project edugo-shared > Settings > CI/CD > Variables
- [ ] Add variable:
  ```
  Key: GITHUB_TOKEN
  Value: [tu GitHub token]
  Protected: ✅
  Masked: ✅
  ```
- [ ] Add variable:
  ```
  Key: GITHUB_USERNAME
  Value: [tu usuario GitHub]
  Protected: ☐
  Masked: ☐
  ```

#### ✓ Probar pipeline completo
- [ ] Hacer cambio en repo GitHub:
  ```bash
  git commit -m "test: trigger pipeline" --allow-empty
  git push origin main
  ```
- [ ] Esperar que GitLab haga mirror (5-10 min o configurar webhook)
- [ ] Ir a GitLab: Project > CI/CD > Pipelines
- [ ] Verificar que pipeline se ejecuta:
  - ✅ Stage test: pasa
  - ✅ Stage build: pasa
  - ✅ Stage push: pasa
- [ ] Verificar imagen en GitHub Packages:
  - Ir a: github.com/edugo/edugo-api-mobile/packages
  - Debería aparecer imagen Docker

#### ✓ Probar descargar imagen
- [ ] Desde otra terminal:
  ```bash
  docker pull ghcr.io/edugo/api-mobile:latest
  docker run -d --name test-api -p 8081:8080 ghcr.io/edugo/api-mobile:latest
  curl http://localhost:8081/health
  docker stop test-api && docker rm test-api
  ```

---

## ✅ FASE 3: Separación de Repositorios (3-4 días)

### Objetivo
Extraer cada servicio a su propio repositorio en GitHub.

---

### 3.1 Preparar módulo shared/ (Día 1)

#### ✓ Crear repositorio edugo-shared definitivo
- [ ] BORRAR repo temporal `edugo/edugo-shared` en GitHub
- [ ] Crear repositorio nuevo (limpio):
  ```bash
  # En GitHub UI: New repository
  Name: edugo-shared
  Description: Módulo Go compartido para microservicios EduGo
  Private: ✅
  Initialize: ☐ (NO inicializar, lo harás manualmente)
  ```

#### ✓ Extraer y publicar shared/
- [ ] Crear directorio separado:
  ```bash
  cd /Users/jhoanmedina/source/EduGo
  mkdir edugo-shared
  cd edugo-shared
  ```

- [ ] Copiar contenido de shared/:
  ```bash
  cp -r ../Analisys/shared/* .
  cp -r ../Analisys/shared/.* . 2>/dev/null || true
  ```

- [ ] Actualizar go.mod:
  ```bash
  # Editar go.mod
  # Cambiar: module github.com/edugo/shared
  # Por:     module github.com/edugo/edugo-shared

  go mod tidy
  ```

- [ ] Inicializar Git:
  ```bash
  git init
  git add .
  git commit -m "Initial commit: EduGo Shared Module v0.1.0"
  ```

- [ ] Conectar con GitHub:
  ```bash
  git remote add origin git@github.com:edugo/edugo-shared.git
  git branch -M main
  git push -u origin main
  ```

- [ ] Crear tag de versión:
  ```bash
  git tag -a v0.1.0 -m "Release v0.1.0: Initial stable version"
  git push origin v0.1.0
  ```

- [ ] Verificar en GitHub:
  - github.com/edugo/edugo-shared
  - Releases > v0.1.0 debe aparecer

#### ✓ Configurar mirror en GitLab para shared/
- [ ] GitLab: Create new project > Import project > Repository by URL
  ```
  Git repository URL: https://github.com/edugo/edugo-shared.git
  Project name: edugo-shared
  Visibility: Private
  ```
- [ ] Después de crear, configurar mirror bidireccional:
  - Settings > Repository > Mirroring repositories
  - Add mirror (pull from GitHub)

- [ ] Configurar pipeline `.gitlab-ci.yml`:
  ```yaml
  # .gitlab-ci.yml en edugo-shared

  stages:
    - test
    - release

  test:
    stage: test
    image: golang:1.23-alpine
    script:
      - go mod download
      - go test -v -race -coverprofile=coverage.txt ./...
      - go tool cover -func coverage.txt
    coverage: '/total:.*\d+.\d+%/'
    artifacts:
      reports:
        coverage_report:
          coverage_format: cobertura
          path: coverage.xml
    only:
      - branches
      - merge_requests

  lint:
    stage: test
    image: golang:1.23-alpine
    script:
      - go install honnef.co/go/tools/cmd/staticcheck@latest
      - staticcheck ./...
    only:
      - merge_requests

  # Release solo corre cuando se crea un tag
  release:
    stage: release
    image: alpine:latest
    script:
      - echo "Release $CI_COMMIT_TAG created"
      - echo "Module github.com/edugo/edugo-shared@$CI_COMMIT_TAG"
    only:
      - tags
  ```

- [ ] Push `.gitlab-ci.yml` a GitHub:
  ```bash
  cd edugo-shared
  git add .gitlab-ci.yml
  git commit -m "ci: add GitLab CI pipeline"
  git push origin main
  ```

- [ ] Esperar mirror y verificar pipeline corre en GitLab

---

### 3.2 Migrar api-mobile (Día 1-2)

#### ✓ Crear repositorio edugo-api-mobile
- [ ] GitHub: Create new repository
  ```
  Name: edugo-api-mobile
  Description: Backend API Mobile - EduGo
  Private: ✅
  ```

#### ✓ Extraer proyecto
- [ ] Crear directorio:
  ```bash
  cd /Users/jhoanmedina/source/EduGo
  mkdir edugo-api-mobile
  cd edugo-api-mobile
  ```

- [ ] Copiar contenido:
  ```bash
  cp -r ../Analisys/source/api-mobile/* .
  ```

#### ✓ Actualizar imports y go.mod
- [ ] Buscar y reemplazar imports:
  ```bash
  # Buscar todos los archivos .go
  find . -type f -name "*.go" -exec sed -i '' 's|github.com/edugo/shared|github.com/edugo/edugo-shared|g' {} +
  ```

- [ ] Actualizar go.mod:
  ```go
  // Antes:
  module github.com/edugo/api-mobile
  require (
      github.com/edugo/shared v0.0.0-00010101000000-000000000000
  )
  replace github.com/edugo/shared => ../../shared

  // Después:
  module github.com/edugo/api-mobile
  require (
      github.com/edugo/edugo-shared v0.1.0
  )
  // ¡Ya no hay replace!
  ```

- [ ] Actualizar dependencias:
  ```bash
  go mod tidy
  go get github.com/edugo/edugo-shared@v0.1.0
  ```

#### ✓ Probar compilación
- [ ] Compilar:
  ```bash
  go build -v ./cmd/api-mobile
  ```
- [ ] Si hay errores de imports, corregir manualmente
- [ ] Ejecutar tests:
  ```bash
  go test -v ./...
  ```

#### ✓ Crear pipeline GitLab
- [ ] Crear `.gitlab-ci.yml`:
  ```yaml
  stages:
    - test
    - build
    - push

  variables:
    DOCKER_IMAGE: ghcr.io/edugo/api-mobile
    GOPRIVATE: "github.com/edugo/*"

  before_script:
    # Configurar acceso a edugo-shared (módulo privado)
    - git config --global url."https://oauth2:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

  test:
    stage: test
    image: golang:1.23-alpine
    services:
      - postgres:16-alpine
    variables:
      POSTGRES_DB: edugo_test
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
      DB_HOST: postgres
    before_script:
      - git config --global url."https://oauth2:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
      - apk add --no-cache git
    script:
      - go mod download
      - go test -v -race ./...
    only:
      - branches
      - merge_requests

  build-image:
    stage: build
    image: docker:latest
    services:
      - docker:dind
    before_script:
      - echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
    script:
      - docker build --build-arg GITHUB_TOKEN=$GITHUB_TOKEN -t $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA .
      - docker tag $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA $DOCKER_IMAGE:latest
      - echo "Image built successfully"
    only:
      - main
      - develop

  push-image:
    stage: push
    image: docker:latest
    services:
      - docker:dind
    before_script:
      - echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
    script:
      - docker build --build-arg GITHUB_TOKEN=$GITHUB_TOKEN -t $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA .
      - docker push $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA
      - docker tag $DOCKER_IMAGE:$CI_COMMIT_SHORT_SHA $DOCKER_IMAGE:latest
      - docker push $DOCKER_IMAGE:latest
      - echo "✅ Image pushed to ghcr.io/edugo/api-mobile:latest"
      - echo "✅ Image pushed to ghcr.io/edugo/api-mobile:$CI_COMMIT_SHORT_SHA"
    only:
      - main
  ```

- [ ] Actualizar Dockerfile para usar GitHub token:
  ```dockerfile
  # Build stage
  FROM golang:1.23-alpine AS builder

  # Argumento para GitHub token (módulos privados)
  ARG GITHUB_TOKEN

  WORKDIR /app

  # Configurar git para usar token
  RUN apk add --no-cache git ca-certificates
  RUN git config --global url."https://oauth2:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

  # Copiar go.mod y go.sum
  COPY go.mod go.sum ./

  # Descargar dependencias (incluido edugo-shared privado)
  RUN go mod download

  # Copiar código fuente
  COPY . .

  # Build
  RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o api-mobile ./cmd/api-mobile

  # Runtime stage
  FROM alpine:latest
  RUN apk --no-cache add ca-certificates
  WORKDIR /app

  COPY --from=builder /app/api-mobile .
  COPY --from=builder /app/config ./config

  EXPOSE 8080
  CMD ["./api-mobile"]
  ```

#### ✓ Publicar a GitHub
- [ ] Init git y push:
  ```bash
  git init
  git add .
  git commit -m "Initial commit: EduGo API Mobile v1.0.0"
  git remote add origin git@github.com:edugo/edugo-api-mobile.git
  git branch -M main
  git push -u origin main

  # Tag de versión
  git tag -a v1.0.0 -m "Release v1.0.0: Initial production version"
  git push origin v1.0.0
  ```

#### ✓ Configurar mirror en GitLab
- [ ] GitLab: Import project > Repository by URL
  ```
  URL: https://github.com/edugo/edugo-api-mobile.git
  Name: edugo-api-mobile
  Visibility: Private
  ```
- [ ] Configurar mirror pull

#### ✓ Verificar pipeline
- [ ] Push un cambio pequeño
- [ ] Verificar en GitLab: CI/CD > Pipelines
- [ ] Verificar stages:
  - ✅ test
  - ✅ build-image
  - ✅ push-image (solo en main)
- [ ] Verificar imagen en GitHub Packages

---

### 3.3 Migrar api-administracion (Día 2)

#### ✓ Repetir proceso de api-mobile
- [ ] Crear repo GitHub: `edugo-api-administracion`
- [ ] Extraer código
- [ ] Actualizar imports de shared
- [ ] Actualizar go.mod
- [ ] Probar compilación
- [ ] Crear `.gitlab-ci.yml` (copiar de api-mobile, cambiar nombre imagen)
- [ ] Actualizar Dockerfile
- [ ] Push a GitHub
- [ ] Configurar mirror GitLab
- [ ] Verificar pipeline

**Variables Docker:**
```yaml
DOCKER_IMAGE: ghcr.io/edugo/api-administracion
```

---

### 3.4 Migrar worker (Día 2-3)

#### ✓ Repetir proceso
- [ ] Crear repo GitHub: `edugo-worker`
- [ ] Extraer código
- [ ] Actualizar imports
- [ ] Actualizar go.mod
- [ ] Probar compilación
- [ ] Crear `.gitlab-ci.yml`
- [ ] Actualizar Dockerfile
- [ ] Push a GitHub
- [ ] Configurar mirror GitLab
- [ ] Verificar pipeline

**Variables Docker:**
```yaml
DOCKER_IMAGE: ghcr.io/edugo/worker
```

---

### 3.5 Verificación de Separación (Día 3-4)

#### ✓ Verificar que todos los repos existen
- [ ] GitHub:
  - github.com/edugo/edugo-shared
  - github.com/edugo/edugo-api-mobile
  - github.com/edugo/edugo-api-administracion
  - github.com/edugo/edugo-worker

- [ ] GitLab (mirrors):
  - gitlab.com/edugo/edugo-shared
  - gitlab.com/edugo/edugo-api-mobile
  - gitlab.com/edugo/edugo-api-administracion
  - gitlab.com/edugo/edugo-worker

#### ✓ Verificar imágenes Docker
- [ ] GitHub Packages (ghcr.io):
  - ghcr.io/edugo/api-mobile:latest
  - ghcr.io/edugo/api-administracion:latest
  - ghcr.io/edugo/worker:latest

- [ ] Probar pull de cada imagen:
  ```bash
  docker pull ghcr.io/edugo/api-mobile:latest
  docker pull ghcr.io/edugo/api-administracion:latest
  docker pull ghcr.io/edugo/worker:latest
  ```

#### ✓ Verificar pipelines en GitLab
- [ ] Cada proyecto debe tener pipeline verde (passing)
- [ ] Verificar que se ejecutan en tu runner local (tags: `docker`, `macos`)

---

## ✅ FASE 4: Docker Compose y Ambiente Dev (2-3 días)

### Objetivo
Crear repositorio `edugo-dev-environment` con todo lo necesario para desarrollo local.

---

### 4.1 Crear repositorio edugo-dev-environment (Día 1)

#### ✓ Crear repo en GitHub
- [ ] GitHub: New repository
  ```
  Name: edugo-dev-environment
  Description: Docker Compose y scripts para desarrollo local de EduGo
  Private: ✅
  ```

#### ✓ Crear estructura de proyecto
- [ ] Crear directorio local:
  ```bash
  cd /Users/jhoanmedina/source/EduGo
  mkdir edugo-dev-environment
  cd edugo-dev-environment
  ```

- [ ] Crear estructura:
  ```bash
  mkdir -p {docker,scripts,docs}
  touch README.md
  touch docker/docker-compose.yml
  touch docker/.env.example
  touch scripts/setup.sh
  touch scripts/update-images.sh
  touch scripts/cleanup.sh
  ```

#### ✓ Crear README.md principal
- [ ] Editar `README.md`:
  ```markdown
  # EduGo - Ambiente de Desarrollo Local

  Este repositorio contiene todo lo necesario para ejecutar EduGo localmente usando Docker Compose.

  ## 🚀 Inicio Rápido

  ### Pre-requisitos
  - Docker Desktop instalado
  - Git
  - Acceso a GitHub Container Registry (ghcr.io)

  ### Setup Inicial

  ```bash
  # 1. Clonar este repositorio
  git clone https://github.com/edugo/edugo-dev-environment.git
  cd edugo-dev-environment

  # 2. Ejecutar script de setup
  ./scripts/setup.sh

  # 3. Levantar servicios
  cd docker
  docker-compose up -d

  # 4. Verificar que todo está corriendo
  docker-compose ps
  ```

  ## 📦 Servicios Incluidos

  | Servicio | Puerto | URL |
  |----------|--------|-----|
  | API Mobile | 8081 | http://localhost:8081 |
  | API Administración | 8082 | http://localhost:8082 |
  | Worker | - | (background) |
  | PostgreSQL | 5432 | localhost:5432 |
  | MongoDB | 27017 | localhost:27017 |
  | RabbitMQ | 5672, 15672 | http://localhost:15672 |

  ## 🔄 Actualizar Imágenes

  Para obtener las últimas versiones de las APIs:

  ```bash
  ./scripts/update-images.sh
  ```

  ## 🧹 Limpiar Ambiente

  Para detener y eliminar todos los contenedores, volúmenes y redes:

  ```bash
  ./scripts/cleanup.sh
  ```

  ## 📚 Documentación

  - [Configuración Detallada](docs/SETUP.md)
  - [Variables de Entorno](docs/VARIABLES.md)
  - [Troubleshooting](docs/TROUBLESHOOTING.md)

  ## 🔐 Credenciales por Defecto (Desarrollo)

  ### PostgreSQL
  - User: `edugo`
  - Password: `edugo123`
  - Database: `edugo`

  ### MongoDB
  - User: `edugo`
  - Password: `edugo123`
  - Database: `edugo`

  ### RabbitMQ
  - User: `edugo`
  - Password: `edugo123`
  - Management UI: http://localhost:15672

  ## ⚠️ Notas Importantes

  - Este ambiente es solo para desarrollo local
  - NO usar estas credenciales en producción
  - Las imágenes se descargan de ghcr.io (GitHub Container Registry)
  ```

---

### 4.2 Crear docker-compose.yml (Día 1-2)

#### ✓ Crear docker-compose.yml completo
- [ ] Editar `docker/docker-compose.yml`:
  ```yaml
  version: '3.8'

  services:
    # Base de datos PostgreSQL
    postgres:
      image: postgres:16-alpine
      container_name: edugo-postgres
      environment:
        POSTGRES_DB: ${POSTGRES_DB:-edugo}
        POSTGRES_USER: ${POSTGRES_USER:-edugo}
        POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-edugo123}
      ports:
        - "${POSTGRES_PORT:-5432}:5432"
      volumes:
        - postgres-data:/var/lib/postgresql/data
      healthcheck:
        test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-edugo}"]
        interval: 10s
        timeout: 5s
        retries: 5
      networks:
        - edugo-network

    # Base de datos MongoDB
    mongodb:
      image: mongo:7.0
      container_name: edugo-mongodb
      environment:
        MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER:-edugo}
        MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD:-edugo123}
      ports:
        - "${MONGO_PORT:-27017}:27017"
      volumes:
        - mongodb-data:/data/db
      healthcheck:
        test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
        interval: 10s
        timeout: 5s
        retries: 5
      networks:
        - edugo-network

    # Message Queue RabbitMQ
    rabbitmq:
      image: rabbitmq:3.12-management-alpine
      container_name: edugo-rabbitmq
      environment:
        RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER:-edugo}
        RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD:-edugo123}
      ports:
        - "${RABBITMQ_PORT:-5672}:5672"      # AMQP
        - "${RABBITMQ_MGMT_PORT:-15672}:15672"  # Management UI
      volumes:
        - rabbitmq-data:/var/lib/rabbitmq
      healthcheck:
        test: ["CMD", "rabbitmq-diagnostics", "ping"]
        interval: 10s
        timeout: 5s
        retries: 5
      networks:
        - edugo-network

    # API Mobile
    api-mobile:
      image: ghcr.io/edugo/api-mobile:${API_MOBILE_VERSION:-latest}
      container_name: edugo-api-mobile
      ports:
        - "${API_MOBILE_PORT:-8081}:8080"
      environment:
        - DB_HOST=postgres
        - DB_PORT=5432
        - DB_USER=${POSTGRES_USER:-edugo}
        - DB_PASS=${POSTGRES_PASSWORD:-edugo123}
        - DB_NAME=${POSTGRES_DB:-edugo}
        - RABBITMQ_HOST=rabbitmq
        - RABBITMQ_PORT=5672
        - RABBITMQ_USER=${RABBITMQ_USER:-edugo}
        - RABBITMQ_PASS=${RABBITMQ_PASSWORD:-edugo123}
        - JWT_SECRET=${JWT_SECRET:-dev-secret-key-change-in-production}
        - PORT=8080
        - ENV=development
      depends_on:
        postgres:
          condition: service_healthy
        rabbitmq:
          condition: service_healthy
      restart: unless-stopped
      networks:
        - edugo-network

    # API Administración
    api-administracion:
      image: ghcr.io/edugo/api-administracion:${API_ADMIN_VERSION:-latest}
      container_name: edugo-api-administracion
      ports:
        - "${API_ADMIN_PORT:-8082}:8080"
      environment:
        - DB_HOST=postgres
        - DB_PORT=5432
        - DB_USER=${POSTGRES_USER:-edugo}
        - DB_PASS=${POSTGRES_PASSWORD:-edugo123}
        - DB_NAME=${POSTGRES_DB:-edugo}
        - JWT_SECRET=${JWT_SECRET:-dev-secret-key-change-in-production}
        - PORT=8080
        - ENV=development
      depends_on:
        postgres:
          condition: service_healthy
      restart: unless-stopped
      networks:
        - edugo-network

    # Worker
    worker:
      image: ghcr.io/edugo/worker:${WORKER_VERSION:-latest}
      container_name: edugo-worker
      environment:
        - DB_HOST=postgres
        - DB_PORT=5432
        - DB_USER=${POSTGRES_USER:-edugo}
        - DB_PASS=${POSTGRES_PASSWORD:-edugo123}
        - DB_NAME=${POSTGRES_DB:-edugo}
        - MONGO_HOST=mongodb
        - MONGO_PORT=27017
        - MONGO_USER=${MONGO_USER:-edugo}
        - MONGO_PASS=${MONGO_PASSWORD:-edugo123}
        - MONGO_DB=${MONGO_DB:-edugo}
        - RABBITMQ_HOST=rabbitmq
        - RABBITMQ_PORT=5672
        - RABBITMQ_USER=${RABBITMQ_USER:-edugo}
        - RABBITMQ_PASS=${RABBITMQ_PASSWORD:-edugo123}
        - ENV=development
      depends_on:
        postgres:
          condition: service_healthy
        mongodb:
          condition: service_healthy
        rabbitmq:
          condition: service_healthy
      restart: unless-stopped
      networks:
        - edugo-network

  volumes:
    postgres-data:
    mongodb-data:
    rabbitmq-data:

  networks:
    edugo-network:
      driver: bridge
  ```

#### ✓ Crear archivo .env.example
- [ ] Editar `docker/.env.example`:
  ```env
  # PostgreSQL
  POSTGRES_DB=edugo
  POSTGRES_USER=edugo
  POSTGRES_PASSWORD=edugo123
  POSTGRES_PORT=5432

  # MongoDB
  MONGO_USER=edugo
  MONGO_PASSWORD=edugo123
  MONGO_DB=edugo
  MONGO_PORT=27017

  # RabbitMQ
  RABBITMQ_USER=edugo
  RABBITMQ_PASSWORD=edugo123
  RABBITMQ_PORT=5672
  RABBITMQ_MGMT_PORT=15672

  # JWT
  JWT_SECRET=dev-secret-key-change-in-production

  # API Ports
  API_MOBILE_PORT=8081
  API_ADMIN_PORT=8082

  # Versiones de imágenes Docker
  API_MOBILE_VERSION=latest
  API_ADMIN_VERSION=latest
  WORKER_VERSION=latest
  ```

---

### 4.3 Crear Scripts de Automatización (Día 2)

#### ✓ Script de setup inicial
- [ ] Editar `scripts/setup.sh`:
  ```bash
  #!/bin/bash

  set -e

  echo "🚀 EduGo - Setup de Ambiente de Desarrollo"
  echo "=========================================="
  echo ""

  # Verificar que Docker está instalado
  if ! command -v docker &> /dev/null; then
      echo "❌ Docker no está instalado. Por favor instala Docker Desktop."
      exit 1
  fi

  echo "✅ Docker está instalado"

  # Verificar que Docker está corriendo
  if ! docker info &> /dev/null; then
      echo "❌ Docker no está corriendo. Por favor inicia Docker Desktop."
      exit 1
  fi

  echo "✅ Docker está corriendo"

  # Crear archivo .env si no existe
  if [ ! -f docker/.env ]; then
      echo "📝 Creando archivo .env desde .env.example..."
      cp docker/.env.example docker/.env
      echo "✅ Archivo .env creado"
      echo ""
      echo "⚠️  IMPORTANTE: Edita docker/.env si necesitas cambiar configuraciones"
  else
      echo "✅ Archivo .env ya existe"
  fi

  # Login a GitHub Container Registry
  echo ""
  echo "🔐 Configurando acceso a GitHub Container Registry..."
  echo "Por favor ingresa tu GitHub Personal Access Token (con scope read:packages):"
  read -s GITHUB_TOKEN

  if [ -z "$GITHUB_TOKEN" ]; then
      echo "❌ Token no puede estar vacío"
      exit 1
  fi

  echo "$GITHUB_TOKEN" | docker login ghcr.io -u $USER --password-stdin

  if [ $? -eq 0 ]; then
      echo "✅ Login exitoso a ghcr.io"
  else
      echo "❌ Error al hacer login. Verifica tu token."
      exit 1
  fi

  # Pull de las imágenes más recientes
  echo ""
  echo "📦 Descargando imágenes Docker más recientes..."
  docker pull ghcr.io/edugo/api-mobile:latest
  docker pull ghcr.io/edugo/api-administracion:latest
  docker pull ghcr.io/edugo/worker:latest

  echo ""
  echo "✅ Setup completado!"
  echo ""
  echo "Para iniciar el ambiente, ejecuta:"
  echo "  cd docker"
  echo "  docker-compose up -d"
  echo ""
  echo "Para ver los logs:"
  echo "  docker-compose logs -f"
  echo ""
  echo "Para detener:"
  echo "  docker-compose down"
  ```

- [ ] Hacer ejecutable:
  ```bash
  chmod +x scripts/setup.sh
  ```

#### ✓ Script para actualizar imágenes
- [ ] Editar `scripts/update-images.sh`:
  ```bash
  #!/bin/bash

  set -e

  echo "🔄 Actualizando imágenes Docker de EduGo..."
  echo "=========================================="
  echo ""

  # Pull de las últimas imágenes
  echo "📦 Descargando imágenes más recientes..."
  docker pull ghcr.io/edugo/api-mobile:latest
  docker pull ghcr.io/edugo/api-administracion:latest
  docker pull ghcr.io/edugo/worker:latest

  echo ""
  echo "✅ Imágenes actualizadas!"
  echo ""
  echo "Para aplicar los cambios, ejecuta:"
  echo "  cd docker"
  echo "  docker-compose down"
  echo "  docker-compose up -d"
  ```

- [ ] Hacer ejecutable:
  ```bash
  chmod +x scripts/update-images.sh
  ```

#### ✓ Script de limpieza
- [ ] Editar `scripts/cleanup.sh`:
  ```bash
  #!/bin/bash

  set -e

  echo "🧹 Limpiando ambiente de desarrollo EduGo..."
  echo "=========================================="
  echo ""

  cd docker

  # Detener y eliminar contenedores
  echo "🛑 Deteniendo contenedores..."
  docker-compose down

  # Preguntar si eliminar volúmenes
  echo ""
  read -p "¿Deseas eliminar los volúmenes (datos de BD)? (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "🗑️  Eliminando volúmenes..."
      docker-compose down -v
      echo "✅ Volúmenes eliminados"
  else
      echo "ℹ️  Volúmenes preservados"
  fi

  # Limpiar imágenes no usadas
  echo ""
  read -p "¿Deseas limpiar imágenes Docker no usadas? (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "🗑️  Limpiando imágenes no usadas..."
      docker image prune -f
      echo "✅ Imágenes limpiadas"
  fi

  echo ""
  echo "✅ Limpieza completada!"
  ```

- [ ] Hacer ejecutable:
  ```bash
  chmod +x scripts/cleanup.sh
  ```

---

### 4.4 Documentación Detallada (Día 2-3)

#### ✓ Crear docs/SETUP.md
- [ ] Crear documentación paso a paso:
  ```markdown
  # Guía de Configuración Detallada

  ## Pre-requisitos

  ### 1. Instalar Docker Desktop
  - macOS: https://docs.docker.com/desktop/install/mac-install/
  - Verificar instalación: `docker --version`

  ### 2. Obtener GitHub Personal Access Token
  1. Ir a: https://github.com/settings/tokens
  2. Generate new token (classic)
  3. Scopes: `read:packages`
  4. Copiar token (guardar en lugar seguro)

  ## Setup Paso a Paso

  ### 1. Clonar repositorio
  ```bash
  git clone https://github.com/edugo/edugo-dev-environment.git
  cd edugo-dev-environment
  ```

  ### 2. Ejecutar setup
  ```bash
  ./scripts/setup.sh
  ```

  Cuando pida token, pegar el GitHub token.

  ### 3. Personalizar configuración (opcional)
  ```bash
  # Editar variables de entorno
  nano docker/.env

  # Cambiar puertos, credenciales, etc.
  ```

  ### 4. Levantar servicios
  ```bash
  cd docker
  docker-compose up -d
  ```

  ### 5. Verificar servicios
  ```bash
  docker-compose ps

  # Todos deben estar "Up"
  ```

  ### 6. Verificar endpoints
  ```bash
  # API Mobile
  curl http://localhost:8081/health

  # API Administración
  curl http://localhost:8082/health

  # RabbitMQ Management
  open http://localhost:15672
  # user: edugo, pass: edugo123
  ```

  ## Comandos Útiles

  ### Ver logs de todos los servicios
  ```bash
  cd docker
  docker-compose logs -f
  ```

  ### Ver logs de un servicio específico
  ```bash
  docker-compose logs -f api-mobile
  docker-compose logs -f worker
  ```

  ### Reiniciar un servicio
  ```bash
  docker-compose restart api-mobile
  ```

  ### Detener servicios
  ```bash
  docker-compose stop
  ```

  ### Detener y eliminar contenedores
  ```bash
  docker-compose down
  ```

  ### Actualizar a última versión
  ```bash
  cd ..
  ./scripts/update-images.sh
  cd docker
  docker-compose down
  docker-compose up -d
  ```
  ```

#### ✓ Crear docs/VARIABLES.md
- [ ] Documentar todas las variables:
  ```markdown
  # Variables de Entorno

  ## PostgreSQL
  | Variable | Default | Descripción |
  |----------|---------|-------------|
  | POSTGRES_DB | edugo | Nombre de la base de datos |
  | POSTGRES_USER | edugo | Usuario de PostgreSQL |
  | POSTGRES_PASSWORD | edugo123 | Contraseña |
  | POSTGRES_PORT | 5432 | Puerto expuesto |

  ## MongoDB
  | Variable | Default | Descripción |
  |----------|---------|-------------|
  | MONGO_USER | edugo | Usuario de MongoDB |
  | MONGO_PASSWORD | edugo123 | Contraseña |
  | MONGO_DB | edugo | Base de datos |
  | MONGO_PORT | 27017 | Puerto expuesto |

  ## RabbitMQ
  | Variable | Default | Descripción |
  |----------|---------|-------------|
  | RABBITMQ_USER | edugo | Usuario |
  | RABBITMQ_PASSWORD | edugo123 | Contraseña |
  | RABBITMQ_PORT | 5672 | Puerto AMQP |
  | RABBITMQ_MGMT_PORT | 15672 | Puerto Management UI |

  ## JWT
  | Variable | Default | Descripción |
  |----------|---------|-------------|
  | JWT_SECRET | dev-secret-key... | Secret para firma de tokens |

  ## APIs
  | Variable | Default | Descripción |
  |----------|---------|-------------|
  | API_MOBILE_PORT | 8081 | Puerto API Mobile |
  | API_ADMIN_PORT | 8082 | Puerto API Admin |

  ## Versiones Docker
  | Variable | Default | Descripción |
  |----------|---------|-------------|
  | API_MOBILE_VERSION | latest | Tag de imagen Docker |
  | API_ADMIN_VERSION | latest | Tag de imagen Docker |
  | WORKER_VERSION | latest | Tag de imagen Docker |
  ```

#### ✓ Crear docs/TROUBLESHOOTING.md
- [ ] Agregar soluciones a problemas comunes:
  ```markdown
  # Troubleshooting

  ## Problema: Error "Cannot connect to Docker daemon"

  **Solución:**
  1. Verificar que Docker Desktop está corriendo
  2. Reiniciar Docker Desktop

  ## Problema: Error "pull access denied for ghcr.io/edugo/api-mobile"

  **Solución:**
  ```bash
  # Login nuevamente con tu GitHub token
  echo "TU_GITHUB_TOKEN" | docker login ghcr.io -u TU_USUARIO --password-stdin
  ```

  ## Problema: Puerto 5432 ya está en uso

  **Solución:**
  ```bash
  # Opción 1: Detener PostgreSQL local
  brew services stop postgresql

  # Opción 2: Cambiar puerto en docker/.env
  POSTGRES_PORT=5433
  ```

  ## Problema: Servicios no arrancan (health check failed)

  **Solución:**
  ```bash
  # Ver logs del servicio
  docker-compose logs postgres
  docker-compose logs mongodb
  docker-compose logs rabbitmq

  # Verificar si hay error de permisos en volúmenes
  docker-compose down -v  # Elimina volúmenes
  docker-compose up -d    # Recrea todo
  ```

  ## Problema: Worker no procesa mensajes

  **Solución:**
  1. Verificar que RabbitMQ está corriendo:
     ```bash
     docker-compose ps rabbitmq
     ```
  2. Ver logs del worker:
     ```bash
     docker-compose logs -f worker
     ```
  3. Verificar conexión a RabbitMQ Management UI:
     - http://localhost:15672
     - Verificar que hay queue "evaluaciones"
     - Verificar que hay mensajes

  ## Problema: Imágenes desactualizadas

  **Solución:**
  ```bash
  ./scripts/update-images.sh
  cd docker
  docker-compose down
  docker-compose up -d
  ```
  ```

---

### 4.5 Publicar edugo-dev-environment (Día 3)

#### ✓ Commit y push a GitHub
- [ ] Init git:
  ```bash
  cd /Users/jhoanmedina/source/EduGo/edugo-dev-environment
  git init
  git add .
  git commit -m "Initial commit: ambiente de desarrollo Docker Compose"
  git remote add origin git@github.com:edugo/edugo-dev-environment.git
  git branch -M main
  git push -u origin main

  # Tag
  git tag -a v1.0.0 -m "Release v1.0.0: Ambiente desarrollo completo"
  git push origin v1.0.0
  ```

#### ✓ Configurar mirror GitLab (opcional para este repo)
- [ ] GitLab: Import project > Repository by URL
- [ ] Configurar mirror pull (solo para backup)

---

## ✅ FASE 5: Documentación Final y Validación (1 día)

### Objetivo
Crear documentación final consolidada y validar todo.

---

### 5.1 Documento de Arquitectura Final

#### ✓ Crear ARQUITECTURA.md en edugo-dev-environment
- [ ] Documentar arquitectura completa:
  ```markdown
  # Arquitectura EduGo - Post-Separación

  ## Repositorios

  ### GitHub (código fuente)
  ```
  github.com/edugo/
  ├── edugo-shared              (Go module)
  ├── edugo-api-mobile          (Backend API)
  ├── edugo-api-administracion  (Backend API)
  ├── edugo-worker              (Worker)
  └── edugo-dev-environment     (Docker Compose + Docs)
  ```

  ### GitLab (CI/CD)
  ```
  gitlab.com/edugo/
  ├── edugo-shared              (mirror)
  ├── edugo-api-mobile          (mirror + pipeline)
  ├── edugo-api-administracion  (mirror + pipeline)
  └── edugo-worker              (mirror + pipeline)
  ```

  ### GitHub Container Registry (imágenes Docker)
  ```
  ghcr.io/edugo/
  ├── api-mobile:latest
  ├── api-administracion:latest
  └── worker:latest
  ```

  ## Flujo de Desarrollo

  1. Developer hace cambio en código
  2. Commit y push a GitHub
  3. GitHub webhook notifica a GitLab
  4. GitLab hace mirror automático (pull)
  5. GitLab runner ejecuta pipeline:
     - Tests
     - Build imagen Docker
     - Push a ghcr.io
  6. Developers locales ejecutan:
     ```bash
     ./scripts/update-images.sh
     cd docker && docker-compose up -d
     ```

  ## Dependencias entre Repos

  ```
  edugo-shared (base)
      ↓
  ┌───┴────┬────────┐
  ↓        ↓        ↓
  api-    api-    worker
  mobile  admin
  ```

  Todos los servicios dependen de `edugo-shared v0.x.x`
  ```

---

### 5.2 Testing End-to-End

#### ✓ Probar flujo completo (nuevo developer)
- [ ] Simular que eres un developer nuevo:
  ```bash
  # 1. Clonar edugo-dev-environment
  cd ~/Desktop
  git clone https://github.com/edugo/edugo-dev-environment.git
  cd edugo-dev-environment

  # 2. Ejecutar setup
  ./scripts/setup.sh
  # Ingresar GitHub token cuando pida

  # 3. Levantar ambiente
  cd docker
  docker-compose up -d

  # 4. Verificar que todo funciona
  docker-compose ps
  curl http://localhost:8081/health
  curl http://localhost:8082/health

  # 5. Ver logs
  docker-compose logs -f
  ```

- [ ] Verificar que:
  - ✅ Todos los servicios arrancan correctamente
  - ✅ APIs responden
  - ✅ Worker se conecta a RabbitMQ
  - ✅ Bases de datos están accesibles

#### ✓ Probar flujo de actualización
- [ ] Hacer un cambio pequeño en api-mobile
- [ ] Push a GitHub
- [ ] Esperar que GitLab haga mirror y ejecute pipeline
- [ ] Verificar que imagen nueva está en ghcr.io
- [ ] Como developer, ejecutar:
  ```bash
  ./scripts/update-images.sh
  cd docker
  docker-compose down
  docker-compose up -d
  ```
- [ ] Verificar que cambio se refleja

---

### 5.3 Documentación para el Equipo

#### ✓ Crear ONBOARDING.md en edugo-dev-environment
- [ ] Guía para nuevos developers:
  ```markdown
  # Onboarding - Nuevos Developers

  ## Bienvenido al equipo EduGo! 🎉

  Esta guía te ayudará a configurar tu ambiente de desarrollo local.

  ## Día 1: Setup Inicial

  ### 1. Accesos necesarios
  - [ ] Acceso a organización GitHub `edugo`
  - [ ] GitHub Personal Access Token con scope `read:packages`
  - [ ] Acceso a grupo GitLab `edugo` (opcional, solo para CI/CD)

  ### 2. Instalar herramientas
  - [ ] Docker Desktop
  - [ ] Git
  - [ ] Go 1.23+
  - [ ] VS Code (o tu editor favorito)

  ### 3. Clonar repositorio de desarrollo
  ```bash
  git clone https://github.com/edugo/edugo-dev-environment.git
  cd edugo-dev-environment
  ./scripts/setup.sh
  ```

  ### 4. Levantar ambiente
  ```bash
  cd docker
  docker-compose up -d
  ```

  ### 5. Verificar que todo funciona
  - API Mobile: http://localhost:8081/health
  - API Admin: http://localhost:8082/health
  - RabbitMQ UI: http://localhost:15672 (user: edugo, pass: edugo123)

  ## Día 2: Desarrollo

  ### Clonar repo en el que trabajarás

  Ejemplo: si trabajas en API Mobile:
  ```bash
  git clone https://github.com/edugo/edugo-api-mobile.git
  cd edugo-api-mobile

  # Instalar dependencias
  go mod download

  # Ejecutar tests
  go test ./...

  # Ejecutar localmente (sin Docker)
  go run ./cmd/api-mobile
  ```

  ### Workflow de desarrollo

  1. Crear branch desde `develop`:
     ```bash
     git checkout develop
     git pull
     git checkout -b feature/mi-nueva-feature
     ```

  2. Hacer cambios y commit:
     ```bash
     git add .
     git commit -m "feat: descripción de mi feature"
     ```

  3. Ejecutar tests:
     ```bash
     go test ./...
     ```

  4. Push a GitHub:
     ```bash
     git push origin feature/mi-nueva-feature
     ```

  5. Crear Pull Request en GitHub

  6. Esperar review y aprobación

  7. Merge a `develop`

  8. GitLab automáticamente:
     - Ejecuta tests
     - Build imagen Docker
     - Push a ghcr.io

  ## Recursos

  - [Arquitectura](ARQUITECTURA.md)
  - [Troubleshooting](docs/TROUBLESHOOTING.md)
  - [Variables de Entorno](docs/VARIABLES.md)
  ```

---

### 5.4 Checklist Final de Validación

#### ✓ Repos GitHub
- [ ] github.com/edugo/edugo-shared existe y tiene v0.1.0
- [ ] github.com/edugo/edugo-api-mobile existe y tiene v1.0.0
- [ ] github.com/edugo/edugo-api-administracion existe y tiene v1.0.0
- [ ] github.com/edugo/edugo-worker existe y tiene v1.0.0
- [ ] github.com/edugo/edugo-dev-environment existe y tiene v1.0.0

#### ✓ Repos GitLab (mirrors)
- [ ] gitlab.com/edugo/edugo-shared existe
- [ ] gitlab.com/edugo/edugo-api-mobile existe
- [ ] gitlab.com/edugo/edugo-api-administracion existe
- [ ] gitlab.com/edugo/edugo-worker existe

#### ✓ Pipelines GitLab
- [ ] Pipeline de edugo-shared: ✅ passing
- [ ] Pipeline de edugo-api-mobile: ✅ passing
- [ ] Pipeline de edugo-api-administracion: ✅ passing
- [ ] Pipeline de edugo-worker: ✅ passing

#### ✓ Container Registry
- [ ] ghcr.io/edugo/api-mobile:latest existe
- [ ] ghcr.io/edugo/api-administracion:latest existe
- [ ] ghcr.io/edugo/worker:latest existe

#### ✓ Docker Compose
- [ ] docker-compose.yml funciona correctamente
- [ ] Todos los servicios arrancan
- [ ] Health checks pasan
- [ ] Flujo completo funciona (crear evaluación → worker procesa)

#### ✓ Documentación
- [ ] README.md en edugo-dev-environment está completo
- [ ] SETUP.md está completo
- [ ] TROUBLESHOOTING.md está completo
- [ ] ONBOARDING.md está completo
- [ ] ARQUITECTURA.md está completo

#### ✓ Scripts
- [ ] setup.sh funciona correctamente
- [ ] update-images.sh funciona correctamente
- [ ] cleanup.sh funciona correctamente

---

## 📊 Resumen Final

### Repositorios Creados (5 total)
1. ✅ `edugo-shared` - Módulo Go compartido
2. ✅ `edugo-api-mobile` - Backend API Mobile
3. ✅ `edugo-api-administracion` - Backend API Admin
4. ✅ `edugo-worker` - Worker procesador
5. ✅ `edugo-dev-environment` - Docker Compose + Docs

### Infraestructura Configurada
- ✅ GitHub Organization `edugo`
- ✅ GitLab Group `edugo`
- ✅ GitHub Container Registry (ghcr.io)
- ✅ GitLab CI/CD con self-hosted runner
- ✅ Mirrors automáticos GitHub → GitLab

### Documentación Creada
- ✅ README.md principal
- ✅ SETUP.md (guía detallada)
- ✅ TROUBLESHOOTING.md (problemas comunes)
- ✅ VARIABLES.md (todas las variables)
- ✅ ONBOARDING.md (nuevos developers)
- ✅ ARQUITECTURA.md (arquitectura completa)

### Tiempo Total Invertido
- FASE 1: 5-7 días
- FASE 2: 2-3 días
- FASE 3: 3-4 días
- FASE 4: 2-3 días
- FASE 5: 1 día

**TOTAL: 13-18 días de trabajo** ✅

---

## 🎉 ¡Felicitaciones!

Has completado exitosamente:
- ✅ Separación de monorepo a multi-repo
- ✅ Setup de CI/CD con GitHub + GitLab
- ✅ Container Registry funcional
- ✅ Ambiente de desarrollo completo con Docker Compose
- ✅ Documentación exhaustiva

### Próximos Pasos (Futuro)

1. **Agregar proyectos móviles (Kotlin KMP y Swift)**
   - Crear repos separados
   - Configurar pipelines (con runner macOS cuando sea necesario)

2. **Setup de ambientes cloud (cuando estés listo para producción)**
   - AWS/Azure/GCP
   - Deploy automático desde GitLab CI

3. **Monitoreo y Logging**
   - Sentry para errores
   - Prometheus + Grafana para métricas

4. **Documentación adicional**
   - API documentation (Swagger/OpenAPI)
   - Arquitectural Decision Records (ADRs)

---

**Última actualización:** 30 de Octubre, 2025
**Autor:** Claude Code con asistencia humana
**Versión:** 1.0
