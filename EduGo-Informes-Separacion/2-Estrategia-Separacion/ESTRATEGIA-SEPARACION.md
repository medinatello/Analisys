# Estrategia de Separación y Manejo de shared/

**Fecha:** 30 de Octubre, 2025
**Proyecto:** EduGo - Transición de Monorepo a Multi-Repo

---

## 1. Opciones para Manejar Código Compartido (shared/)

### Opción 1: Módulo Go Privado en GitHub ⭐ RECOMENDADA

#### Descripción
Publicar `shared/` como un módulo Go privado en GitHub y referenciarlo desde cada proyecto mediante `go get`.

#### Ventajas ✅
- **Versionamiento explícito:** Control total sobre qué versión usa cada servicio
- **Independencia de servicios:** Cada servicio puede actualizar shared/ a su ritmo
- **CI/CD estándar:** Funciona perfectamente en pipelines
- **Go modules nativo:** Aprovecha el ecosistema de Go
- **Rollback sencillo:** Fácil volver a versión anterior si hay problemas

#### Desventajas ❌
- Requiere autenticación para repos privados (fácil de configurar)
- Requiere crear releases/tags para versiones
- Necesita proceso de actualización en cada servicio

#### Configuración Paso a Paso

##### Paso 1: Crear el Repositorio shared en GitHub
```bash
# En tu máquina local
cd /Users/jhoanmedina/source/EduGo

# Crear nuevo directorio para shared
mkdir edugo-shared
cp -r Analisys/shared/* edugo-shared/

cd edugo-shared

# Inicializar git
git init
git add .
git commit -m "Initial commit: shared module v0.1.0"

# Crear repositorio en GitHub (privado)
# Puedes usar gh CLI o crear desde la web
gh repo create edugo/edugo-shared --private --source=. --remote=origin

# Push inicial
git push -u origin main

# Crear primer tag de versión
git tag v0.1.0
git push origin v0.1.0
```

##### Paso 2: Configurar Autenticación en Proyectos

**Opción A: Usando GOPRIVATE (Para desarrollo local)**
```bash
# En tu ~/.bashrc o ~/.zshrc
export GOPRIVATE="github.com/edugo/*"

# Configurar Git para usar HTTPS con token
git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
```

**Opción B: Usando SSH (Recomendado para desarrollo)**
```bash
# Configurar SSH keys (si no lo has hecho)
ssh-keygen -t ed25519 -C "tu-email@ejemplo.com"

# Agregar a GitHub
cat ~/.ssh/id_ed25519.pub
# Copiar y pegar en GitHub Settings > SSH Keys

# Configurar Git para usar SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

##### Paso 3: Actualizar go.mod en cada Proyecto

**Antes:**
```go
// source/api-mobile/go.mod
module github.com/edugo/api-mobile

require (
    github.com/edugo/shared v0.0.0-00010101000000-000000000000
)

replace github.com/edugo/shared => ../../shared
```

**Después:**
```go
// source/api-mobile/go.mod
module github.com/edugo/api-mobile

require (
    github.com/edugo/edugo-shared v0.1.0
)

// Ya no se necesita el replace!
```

##### Paso 4: Actualizar imports en el código

**Buscar y reemplazar en todos los archivos:**
```bash
# En cada proyecto
find . -type f -name "*.go" -exec sed -i '' 's|github.com/edugo/shared|github.com/edugo/edugo-shared|g' {} +
```

##### Paso 5: Actualizar dependencias
```bash
cd source/api-mobile
go mod tidy
go get github.com/edugo/edugo-shared@v0.1.0

cd ../api-administracion
go mod tidy
go get github.com/edugo/edugo-shared@v0.1.0

cd ../worker
go mod tidy
go get github.com/edugo/edugo-shared@v0.1.0
```

##### Paso 6: Configurar CI/CD para acceder a shared privado

**Para GitHub Actions:**
```yaml
# .github/workflows/build.yml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.25.3'

      - name: Configure Git for private modules
        run: |
          git config --global url."https://${{ secrets.GH_ACCESS_TOKEN }}@github.com/".insteadOf "https://github.com/"
        env:
          GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}

      - name: Download dependencies
        run: go mod download

      - name: Build
        run: go build -v ./...

      - name: Test
        run: go test -v ./...
```

**Crear Personal Access Token:**
1. GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Generate new token
3. Scopes necesarios: `repo` (full control)
4. Copiar el token
5. En cada repositorio: Settings > Secrets and variables > Actions > New repository secret
6. Nombre: `GH_ACCESS_TOKEN`, Valor: tu token

---

### Opción 2: Git Submodules

#### Descripción
Usar Git submodules para incluir shared/ en cada proyecto.

#### Ventajas ✅
- No requiere CI/CD especial
- Código siempre disponible localmente

#### Desventajas ❌
- **Complejidad alta:** Git submodules son difíciles de manejar
- **Propenso a errores:** Fácil desincronizar
- **Mala experiencia de desarrollo:** Requiere comandos extra
- **No recomendado por la comunidad Go**

#### ⚠️ NO RECOMENDADA para proyectos Go

---

### Opción 3: Monorepo Tools (Bazel, Nx, etc.)

#### Descripción
Mantener todo en un monorepo pero usar herramientas especializadas.

#### Ventajas ✅
- Shared code siempre sincronizado
- Refactorings atómicos

#### Desventajas ❌
- **Complejidad:** Requiere aprender nuevas herramientas
- **Overhead:** Demasiado para un proyecto de 3 servicios
- **Lock-in:** Dependencia de herramienta específica

#### ⚠️ NO RECOMENDADA para tu caso (proyecto pequeño)

---

### Opción 4: Copiar Código (Duplicación)

#### Descripción
Copiar shared/ en cada proyecto y mantenerlo independiente.

#### Ventajas ✅
- Máxima independencia entre servicios
- No hay dependencias externas

#### Desventajas ❌
- **Mantenimiento pesadilla:** Cambios deben replicarse manualmente
- **Bugs duplicados:** Correcciones deben aplicarse en 3 lugares
- **No escalable**

#### ❌ DEFINITIVAMENTE NO RECOMENDADA

---

## 2. Plan de Implementación Recomendado

### 🎯 Estrategia: Módulo Go Privado + Versionamiento Semántico

---

### FASE 1: Preparación de shared/ (2-3 días)

#### Día 1: Limpieza y Documentación
```bash
# 1. Crear branch para trabajar
cd /Users/jhoanmedina/source/EduGo/Analisys/shared
git checkout -b prepare-shared-module

# 2. Ejecutar tests
go test ./...

# 3. Crear README.md
cat > README.md << 'EOF'
# EduGo Shared

Librería compartida para los servicios de EduGo.

## Paquetes

- `pkg/auth`: Autenticación JWT
- `pkg/config`: Configuración de entorno
- `pkg/database`: Conexiones a PostgreSQL y MongoDB
- `pkg/errors`: Manejo de errores
- `pkg/logger`: Sistema de logging
- `pkg/messaging`: Cliente RabbitMQ
- `pkg/types`: Tipos compartidos y enums
- `pkg/validator`: Validación

## Instalación

```bash
go get github.com/edugo/edugo-shared@v0.1.0
```

## Versionamiento

Seguimos [Semantic Versioning 2.0.0](https://semver.org/):
- MAJOR: Breaking changes
- MINOR: Nuevas funcionalidades (backward compatible)
- PATCH: Bug fixes (backward compatible)

## Changelog

Ver [CHANGELOG.md](CHANGELOG.md)
EOF

# 4. Crear CHANGELOG.md
cat > CHANGELOG.md << 'EOF'
# Changelog

## [0.1.0] - 2025-10-30

### Añadido
- Módulo de autenticación JWT
- Conexiones a PostgreSQL y MongoDB
- Cliente RabbitMQ (Publisher/Consumer)
- Sistema de logging con Zap
- Tipos compartidos y enums
- Sistema de validación
- Manejo de errores centralizado
EOF

# 5. Verificar que go.mod esté correcto
cat > go.mod << 'EOF'
module github.com/edugo/edugo-shared

go 1.25.3

require (
    github.com/golang-jwt/jwt/v5 v5.3.0
    github.com/lib/pq v1.10.9
    github.com/spf13/viper v1.21.0
    github.com/streadway/amqp v1.1.0
    go.mongodb.org/mongo-driver v1.17.6
    go.uber.org/zap v1.27.0
)
EOF

go mod tidy
```

#### Día 2-3: Tests y Validación
```bash
# 1. Crear tests para cada paquete
# Objetivo: 80% cobertura mínimo

# 2. Ejecutar tests con cobertura
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html

# 3. Validar que compile correctamente
go build ./...

# 4. Commit de cambios
git add .
git commit -m "docs: prepare shared module for extraction"
```

---

### FASE 2: Extracción y Publicación de shared/ (1 día)

```bash
# 1. Crear directorio separado
cd /Users/jhoanmedina/source/EduGo
mkdir edugo-shared
cd edugo-shared

# 2. Copiar contenido de shared/
cp -r ../Analisys/shared/* .

# 3. Inicializar git
git init
git add .
git commit -m "Initial commit: EduGo Shared Module v0.1.0"

# 4. Crear repositorio en GitHub (privado)
gh repo create edugo/edugo-shared --private --source=. --remote=origin --push

# 5. Crear tag de versión
git tag -a v0.1.0 -m "Release v0.1.0: Initial stable version"
git push origin v0.1.0

# 6. Verificar que el tag esté publicado
gh release list
```

---

### FASE 3: Migración de Proyectos (1 día por proyecto)

#### Para api-mobile:

```bash
cd /Users/jhoanmedina/source/EduGo/Analisys/source/api-mobile

# 1. Crear branch
git checkout -b migrate-to-shared-module

# 2. Actualizar imports
find . -type f -name "*.go" -exec sed -i '' 's|github.com/edugo/shared|github.com/edugo/edugo-shared|g' {} +

# 3. Actualizar go.mod
# Eliminar la línea: replace github.com/edugo/shared => ../../shared
# Cambiar: github.com/edugo/shared por github.com/edugo/edugo-shared v0.1.0

# 4. Actualizar dependencias
go mod tidy
go get github.com/edugo/edugo-shared@v0.1.0

# 5. Compilar y probar
go build ./...
go test ./...

# 6. Si todo funciona, commit
git add .
git commit -m "refactor: migrate to edugo-shared module v0.1.0"
git push origin migrate-to-shared-module

# 7. Crear PR y mergear
```

**Repetir para api-administracion y worker.**

---

### FASE 4: Crear Repositorios Separados (1 día)

#### Paso 1: Crear repositorios en GitHub

```bash
# Opción A: Usando gh CLI
gh repo create edugo/edugo-api-mobile --private
gh repo create edugo/edugo-api-administracion --private
gh repo create edugo/edugo-worker --private

# Opción B: Desde la web de GitHub
# https://github.com/new
```

#### Paso 2: Extraer cada proyecto

**Para api-mobile:**
```bash
cd /Users/jhoanmedina/source/EduGo
mkdir edugo-api-mobile
cd edugo-api-mobile

# Copiar contenido
cp -r ../Analisys/source/api-mobile/* .

# Inicializar git
git init
git add .
git commit -m "Initial commit: EduGo API Mobile v1.0.0"

# Conectar con GitHub
git remote add origin git@github.com:edugo/edugo-api-mobile.git
git branch -M main
git push -u origin main

# Crear tag de versión
git tag -a v1.0.0 -m "Release v1.0.0: Initial production version"
git push origin v1.0.0
```

**Repetir para api-administracion y worker.**

---

## 3. Workflow de Desarrollo Futuro

### 3.1 Haciendo Cambios en shared/

#### Escenario: Necesitas agregar una nueva función a shared/

```bash
# 1. En el repo de edugo-shared
cd /ruta/a/edugo-shared

# 2. Crear branch
git checkout -b feature/add-new-validator

# 3. Hacer cambios
# ... editar archivos ...

# 4. Tests
go test ./...

# 5. Commit
git add .
git commit -m "feat: add new email validator"

# 6. Push y crear PR
git push origin feature/add-new-validator
gh pr create --title "Add new email validator" --body "Adds validator for email format"

# 7. Después del merge, crear nueva versión
git checkout main
git pull
git tag -a v0.2.0 -m "Release v0.2.0: Add email validator"
git push origin v0.2.0
```

#### Actualizar en los servicios:

```bash
# En api-mobile
cd /ruta/a/edugo-api-mobile
go get github.com/edugo/edugo-shared@v0.2.0
go mod tidy
go test ./...
git add go.mod go.sum
git commit -m "chore: update edugo-shared to v0.2.0"
git push
```

---

### 3.2 Breaking Changes en shared/

Si el cambio es breaking (ej: cambiar firma de función):

#### En shared/:
```bash
# 1. Hacer cambios
# ... editar archivos ...

# 2. Actualizar CHANGELOG.md
## [1.0.0] - 2025-11-15

### BREAKING CHANGES
- JWT signature changed from HMAC to RSA
- `GenerateToken()` now requires `*rsa.PrivateKey` instead of `string`

### Migration Guide
...

# 3. Crear release MAJOR
git tag -a v1.0.0 -m "Release v1.0.0: BREAKING - Change JWT to RSA"
git push origin v1.0.0
```

#### En cada servicio:
```bash
# 1. Crear branch para migración
git checkout -b upgrade-shared-v1

# 2. Actualizar código para compatibilidad
# ... hacer cambios necesarios ...

# 3. Actualizar dependencia
go get github.com/edugo/edugo-shared@v1.0.0
go mod tidy

# 4. Tests
go test ./...

# 5. PR con descripción detallada
gh pr create --title "Migrate to edugo-shared v1.0.0" \
             --body "Migrates to new RSA-based JWT authentication"
```

---

### 3.3 Cambios que Afectan Múltiples Servicios

#### Ejemplo: Agregar nuevo campo a un enum

```bash
# 1. Actualizar shared/ y lanzar v0.3.0

# 2. Crear matriz de compatibilidad
## Compatibility Matrix
| Service | Current Version | Target Version | Status |
|---------|----------------|----------------|--------|
| api-mobile | v1.2.0 | v1.3.0 | ⏳ Pending |
| api-administracion | v1.1.0 | v1.2.0 | ⏳ Pending |
| worker | v0.5.0 | v0.6.0 | ⏳ Pending |

# 3. Actualizar servicios uno por uno
# 4. Hacer deploy en orden (basados en dependencias)
# 5. Marcar como ✅ Done en la matriz
```

---

## 4. Ambiente de Desarrollo Recomendado

### 4.1 Estructura de Carpetas en tu Máquina

```
~/source/EduGo/
├── edugo-shared/              # Repo independiente
├── edugo-api-mobile/          # Repo independiente
├── edugo-api-administracion/  # Repo independiente
├── edugo-worker/              # Repo independiente
└── edugo-monorepo-legacy/     # Backup del monorepo original (opcional)
```

### 4.2 Abrir en VS Code

**Opción A: Multi-root workspace (RECOMENDADA)**

Crear `edugo-workspace.code-workspace`:
```json
{
  "folders": [
    {
      "name": "shared",
      "path": "./edugo-shared"
    },
    {
      "name": "api-mobile",
      "path": "./edugo-api-mobile"
    },
    {
      "name": "api-administracion",
      "path": "./edugo-api-administracion"
    },
    {
      "name": "worker",
      "path": "./edugo-worker"
    }
  ],
  "settings": {
    "go.inferGopath": false
  }
}
```

Abrir: `code edugo-workspace.code-workspace`

**Opción B: Abrir cada proyecto en ventana separada**
```bash
code ~/source/EduGo/edugo-shared
code ~/source/EduGo/edugo-api-mobile
# etc...
```

---

### 4.3 Docker Compose para Desarrollo Local

Crear `docker-compose.dev.yml` en una carpeta separada:

```yaml
# ~/source/EduGo/edugo-dev-environment/docker-compose.dev.yml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: edugo
      POSTGRES_USER: edugo
      POSTGRES_PASSWORD: edugo123
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

  mongodb:
    image: mongo:7.0
    environment:
      MONGO_INITDB_ROOT_USERNAME: edugo
      MONGO_INITDB_ROOT_PASSWORD: edugo123
    ports:
      - "27017:27017"
    volumes:
      - mongodb-data:/data/db

  rabbitmq:
    image: rabbitmq:3.12-management-alpine
    environment:
      RABBITMQ_DEFAULT_USER: edugo
      RABBITMQ_DEFAULT_PASS: edugo123
    ports:
      - "5672:5672"    # AMQP
      - "15672:15672"  # Management UI
    volumes:
      - rabbitmq-data:/var/lib/rabbitmq

  api-mobile:
    build:
      context: ../edugo-api-mobile
      dockerfile: Dockerfile.dev
    ports:
      - "8081:8080"
    environment:
      - DB_HOST=postgres
      - MONGO_HOST=mongodb
      - RABBITMQ_HOST=rabbitmq
    depends_on:
      - postgres
      - mongodb
      - rabbitmq
    volumes:
      - ../edugo-api-mobile:/app

  api-administracion:
    build:
      context: ../edugo-api-administracion
      dockerfile: Dockerfile.dev
    ports:
      - "8082:8080"
    environment:
      - DB_HOST=postgres
      - RABBITMQ_HOST=rabbitmq
    depends_on:
      - postgres
      - rabbitmq
    volumes:
      - ../edugo-api-administracion:/app

  worker:
    build:
      context: ../edugo-worker
      dockerfile: Dockerfile.dev
    environment:
      - DB_HOST=postgres
      - MONGO_HOST=mongodb
      - RABBITMQ_HOST=rabbitmq
    depends_on:
      - postgres
      - mongodb
      - rabbitmq
    volumes:
      - ../edugo-worker:/app

volumes:
  postgres-data:
  mongodb-data:
  rabbitmq-data:
```

**Uso:**
```bash
cd ~/source/EduGo/edugo-dev-environment
docker-compose -f docker-compose.dev.yml up -d
```

---

## 5. CI/CD con GitHub Actions

### 5.1 Template para shared/

```yaml
# .github/workflows/ci.yml en edugo-shared
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.25.3'

      - name: Download dependencies
        run: go mod download

      - name: Run tests
        run: go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.txt

      - name: Check code quality
        run: |
          go vet ./...
          go fmt ./...
          git diff --exit-code

  release:
    needs: test
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          draft: false
          prerelease: false
```

### 5.2 Template para servicios

```yaml
# .github/workflows/ci-cd.yml en api-mobile
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: edugo_test
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3

      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.25.3'

      - name: Configure Git for private modules
        run: |
          git config --global url."https://${{ secrets.GH_ACCESS_TOKEN }}@github.com/".insteadOf "https://github.com/"

      - name: Download dependencies
        run: go mod download

      - name: Run tests
        run: go test -v ./...
        env:
          DB_HOST: localhost
          DB_PORT: 5432
          DB_NAME: edugo_test
          DB_USER: test
          DB_PASS: test

      - name: Build
        run: go build -v ./cmd/api-mobile

  build-image:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ghcr.io/edugo/api-mobile:latest
```

---

## 6. Checklist de Migración

### Pre-Migración ✓
- [ ] Todos los tests pasan en el monorepo
- [ ] Documentación de shared/ completa
- [ ] README.md y CHANGELOG.md creados
- [ ] Cobertura de tests > 80% en shared/

### Migración de shared/ ✓
- [ ] Repositorio edugo-shared creado en GitHub
- [ ] Código extraído y publicado
- [ ] Tag v0.1.0 creado
- [ ] CI/CD configurado

### Migración de Servicios ✓
- [ ] api-mobile migrado y funcionando
- [ ] api-administracion migrado y funcionando
- [ ] worker migrado y funcionando
- [ ] Todos los tests pasan en cada servicio
- [ ] Docker builds exitosos

### Post-Migración ✓
- [ ] Docker Compose funcional para desarrollo
- [ ] Documentación de workflows actualizada
- [ ] Equipo capacitado en nuevo flujo
- [ ] Backup del monorepo guardado

---

## 7. Soporte y Troubleshooting

### Problema: "cannot find module github.com/edugo/edugo-shared"

**Solución:**
```bash
# Verificar que GOPRIVATE esté configurado
go env GOPRIVATE
# Debe mostrar: github.com/edugo/*

# Si no está configurado
go env -w GOPRIVATE=github.com/edugo/*

# Verificar autenticación Git
git config --global --get url."https://github.com/".insteadOf
```

### Problema: "Permission denied (publickey)"

**Solución:**
```bash
# Verificar SSH key
ssh -T git@github.com

# Si falla, agregar SSH key a GitHub
cat ~/.ssh/id_ed25519.pub
# Copiar y agregar en GitHub Settings > SSH Keys
```

### Problema: "Version v0.1.0 not found"

**Solución:**
```bash
# Limpiar cache de Go
go clean -modcache

# Re-descargar
GOPRIVATE=github.com/edugo/* go get github.com/edugo/edugo-shared@v0.1.0
```

---

## 8. Siguiente Paso

Ver **Informe 3: Comparativa de Nubes y CI/CD** para decidir dónde desplegar tu infraestructura.

---

**Última actualización:** 30 de Octubre, 2025
