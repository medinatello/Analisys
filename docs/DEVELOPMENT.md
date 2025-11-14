# 🛠️ GUÍA DE DESARROLLO - EduGo

**Actualizado:** 14 de Noviembre, 2025

---

## ⚠️ IMPORTANTE: CAMBIO DE ARQUITECTURA

Este repositorio (`Analisys`) **YA NO contiene código de aplicación**. Es un repositorio de **documentación y análisis**.

El código de las aplicaciones ahora reside en **repositorios independientes** bajo la organización **EduGoGroup** en GitHub:

- [edugo-shared](https://github.com/EduGoGroup/edugo-shared)
- [edugo-api-mobile](https://github.com/EduGoGroup/edugo-api-mobile)
- [edugo-api-administracion](https://github.com/EduGoGroup/edugo-api-administracion)
- [edugo-worker](https://github.com/EduGoGroup/edugo-worker)
- [edugo-dev-environment](https://github.com/EduGoGroup/edugo-dev-environment)

**Rutas locales (con acceso de Claude Code):**
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-*
```

---

## 📊 Estado Actual del Proyecto

**Antes de empezar a desarrollar, leer:**

🎯 **[ESTADO_PROYECTO.md](ESTADO_PROYECTO.md)** - Punto de entrada principal

Este documento contiene:
- ✅ Proyectos completados
- 🔄 Proyectos en progreso con % avance
- ⬜ Proyectos pendientes
- 🗺️ Navegación rápida a documentación relevante

---

## 🏁 Setup para Desarrollo

### 1. Clonar Repositorios

```bash
# Crear carpeta de trabajo
mkdir -p ~/source/EduGo/repos-separados
cd ~/source/EduGo/repos-separados

# Clonar repositorios individuales
git clone git@github.com:EduGoGroup/edugo-shared.git
git clone git@github.com:EduGoGroup/edugo-api-mobile.git
git clone git@github.com:EduGoGroup/edugo-api-administracion.git
git clone git@github.com:EduGoGroup/edugo-worker.git
git clone git@github.com:EduGoGroup/edugo-dev-environment.git
```

### 2. Setup del Entorno de Desarrollo

```bash
cd edugo-dev-environment

# Instalar dependencias de desarrollo
./scripts/setup.sh --profile full

# O solo bases de datos (más rápido)
./scripts/setup.sh --profile db-only

# Con datos de prueba (recomendado)
./scripts/setup.sh --profile full --seed
```

Ver documentación completa: `/repos-separados/edugo-dev-environment/README.md`

### 3. Instalar Herramientas Go

```bash
# Swagger
go install github.com/swaggo/swag/cmd/swag@latest

# Linter (opcional)
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

---

## ⚙️ Sistema de Configuración

### Arquitectura Multi-Ambiente

Todos los proyectos usan **Viper** para gestión de configuración por ambientes:

```
{proyecto}/config/
├── config.yaml         # Base (común a todos)
├── config-local.yaml   # Local development (default)
├── config-dev.yaml     # Development server
├── config-qa.yaml      # QA/Staging
└── config-prod.yaml    # Production
```

### Cambiar Entre Ambientes

```bash
# Local (default) - Usa Docker local
cd repos-separados/edugo-api-mobile
APP_ENV=local go run cmd/main.go

# Development - Apunta a servidores dev
APP_ENV=dev go run cmd/main.go

# QA
APP_ENV=qa go run cmd/main.go

# Production (requiere todas las credenciales)
APP_ENV=prod OPENAI_API_KEY=sk-xxx go run cmd/main.go
```

### Variables de Ambiente

**Prefijos por proyecto:**
- API Mobile: `EDUGO_MOBILE_*`
- API Admin: `EDUGO_ADMIN_*`
- Worker: `EDUGO_WORKER_*`

**Ejemplos:**
```bash
# Cambiar puerto
EDUGO_MOBILE_SERVER_PORT=9090 go run cmd/main.go

# Cambiar nivel de logs
EDUGO_MOBILE_LOGGING_LEVEL=debug go run cmd/main.go

# Cambiar base de datos
EDUGO_MOBILE_POSTGRES_HOST=localhost go run cmd/main.go
```

### Secretos Requeridos (ambientes remotos)

```bash
export POSTGRES_PASSWORD=xxx
export MONGODB_URI=mongodb://user:pass@host/db
export RABBITMQ_URL=amqp://user:pass@host/
export OPENAI_API_KEY=sk-xxx
```

**⚠️ NUNCA commitear secretos** en archivos YAML o .env sin encriptar.

---

## 📝 Workflow de Desarrollo

### Crear Nueva Funcionalidad

1. **Leer documentación del proyecto:**
   - Si es nuevo: `specs/<proyecto>/RULES.md`
   - Si continúas: `specs/<proyecto>/TASKS.md`

2. **Crear branch:**
   ```bash
   cd repos-separados/edugo-<proyecto>
   git checkout dev
   git pull origin dev
   git checkout -b feature/descripcion-corta
   ```

3. **Desarrollar siguiendo Clean Architecture:**
   ```
   internal/
   ├── domain/          # Entities, Value Objects, Repository interfaces
   ├── application/     # Use Cases, DTOs, Services
   ├── infrastructure/  # DB, HTTP, External services
   └── bootstrap/       # Inicialización y DI
   ```

4. **Escribir tests:**
   ```bash
   # Tests unitarios
   go test ./internal/domain/...
   
   # Tests de integración (usa shared/testing)
   go test -tags=integration ./test/integration/...
   ```

5. **Regenerar Swagger (si hay cambios en API):**
   ```bash
   make swagger
   # O manualmente:
   swag init -g cmd/main.go -o docs
   ```

6. **Verificar calidad:**
   ```bash
   make lint    # Linter
   make test    # Tests
   make build   # Compilar
   ```

7. **Commit y PR:**
   ```bash
   git add .
   git commit -m "feat: descripción del cambio"
   git push origin feature/descripcion-corta
   
   # Crear PR en GitHub: feature/x → dev
   ```

### Convenciones de Commits

Formato: `tipo(scope): descripción`

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `refactor`: Refactorización sin cambio funcional
- `test`: Agregar/modificar tests
- `docs`: Cambios en documentación
- `chore`: Tareas de mantenimiento
- `ci`: Cambios en CI/CD

**Ejemplos:**
```bash
feat(domain): agregar entity School con validaciones
fix(handler): corregir validación de email en CreateUser
refactor(repository): simplificar query de GetTree
test(integration): agregar tests de flujo de evaluaciones
docs(readme): actualizar guía de instalación
```

---

## 🧪 Testing

### Estructura de Tests

```
{proyecto}/
├── internal/           # Tests unitarios junto al código
│   └── domain/
│       ├── entity/
│       │   ├── school.go
│       │   └── school_test.go
│       └── ...
└── test/
    └── integration/    # Tests de integración
        ├── main_test.go           # Setup con testcontainers
        └── school_flow_test.go    # Tests de flujos
```

### Tests Unitarios

```bash
cd repos-separados/edugo-api-mobile

# Todos los tests unitarios
go test ./internal/...

# Con verbosidad
go test ./internal/domain/... -v

# Con cobertura
go test ./internal/... -cover
```

### Tests de Integración

Usan **shared/testing** con testcontainers (PostgreSQL, MongoDB, RabbitMQ):

```bash
# Ejecutar tests de integración
go test -tags=integration ./test/integration/... -v

# Con cobertura
go test -tags=integration ./test/integration/... -cover
```

**Nota:** Los tests de integración requieren Docker corriendo.

---

## 🐛 Debugging

### Logs de Servicios

Si usas `edugo-dev-environment`:

```bash
cd repos-separados/edugo-dev-environment

# Ver logs de todos los servicios
docker-compose -f docker/docker-compose.yml logs -f

# Logs específicos
docker-compose -f docker/docker-compose.yml logs -f postgres
docker-compose -f docker/docker-compose.yml logs -f mongodb
docker-compose -f docker/docker-compose.yml logs -f rabbitmq
```

### Conectar a Bases de Datos

```bash
# PostgreSQL
docker exec -it edugo-postgres psql -U edugo_user -d edugo

# MongoDB
docker exec -it edugo-mongodb mongosh -u edugo_admin -p edugo_pass edugo

# RabbitMQ Management UI
open http://localhost:15672
# User: guest / Password: guest
```

### Debugging en VS Code / GoLand

Crear configuración de debug apuntando a `cmd/main.go` con variables de ambiente:

```json
{
  "type": "go",
  "request": "launch",
  "name": "Launch API Mobile",
  "program": "${workspaceFolder}/repos-separados/edugo-api-mobile",
  "env": {
    "APP_ENV": "local",
    "EDUGO_MOBILE_LOGGING_LEVEL": "debug"
  }
}
```

---

## 📚 Documentación por Proyecto

### Compartido (shared)

**Ubicación:** `/repos-separados/edugo-shared`

**Módulos:**
- `bootstrap`: Sistema de inicialización y DI
- `config`: Gestión de configuración multi-ambiente
- `lifecycle`: Manejo de ciclo de vida de aplicación
- `logger`: Logger estructurado
- `testing`: Testcontainers helpers

**Releases:** Por módulo (ej: `testing/v0.6.2`, `bootstrap/v0.1.0`)

### API Mobile

**Ubicación:** `/repos-separados/edugo-api-mobile`  
**Puerto:** 8080  
**Swagger:** http://localhost:8080/swagger/index.html

**Funcionalidades:**
- Gestión de materiales educativos
- Sistema de progreso de estudiantes
- Evaluaciones y quizzes
- Autenticación y autorización

### API Administración

**Ubicación:** `/repos-separados/edugo-api-administracion`  
**Puerto:** 8081  
**Estado:** 🔄 En desarrollo (jerarquía académica)

**Funcionalidades planeadas:**
- Gestión de escuelas y unidades académicas
- Perfiles especializados (teachers, students)
- Asignación de materiales a unidades
- Reportes administrativos

**Ver progreso:** [specs/api-admin-jerarquia/](../specs/api-admin-jerarquia/)

### Worker

**Ubicación:** `/repos-separados/edugo-worker`  
**Puerto:** N/A (procesamiento asíncrono)

**Funcionalidades:**
- Procesamiento de PDFs
- Generación de resúmenes con OpenAI
- Generación de quizzes automáticos
- Eventos de RabbitMQ

### Dev Environment

**Ubicación:** `/repos-separados/edugo-dev-environment`

**Servicios:**
- PostgreSQL 15
- MongoDB 7.0
- RabbitMQ 3.12

**Profiles disponibles:**
- `full`: Todos los servicios
- `db-only`: Solo bases de datos
- `api-only`: APIs sin worker
- `mobile-only`, `admin-only`, `worker-only`: Servicios individuales

---

## 🔧 Troubleshooting

### Error: "Cannot connect to database"

```bash
# Verificar que Docker esté corriendo
docker ps

# Verificar contenedores del proyecto
cd repos-separados/edugo-dev-environment
docker-compose -f docker/docker-compose.yml ps

# Reiniciar si es necesario
./scripts/stop.sh
./scripts/setup.sh --profile db-only
```

### Error: "Port already in use"

```bash
# Ver qué proceso usa el puerto (ej: 8080)
lsof -i :8080

# Matar proceso si es necesario
kill -9 <PID>

# O cambiar puerto de la aplicación
EDUGO_MOBILE_SERVER_PORT=9090 go run cmd/main.go
```

### Error: "Go module not found"

```bash
cd repos-separados/edugo-<proyecto>
go mod tidy
go mod download
```

### Error en Tests de Integración

```bash
# Verificar que Docker esté corriendo
docker ps

# Limpiar contenedores de testcontainers
docker ps -a | grep testcontainers | awk '{print $1}' | xargs docker rm -f

# Ejecutar tests nuevamente
go test -tags=integration ./test/integration/... -v
```

---

## 📖 Recursos Adicionales

### Documentación del Proyecto
- **[ESTADO_PROYECTO.md](ESTADO_PROYECTO.md)** - 🎯 Estado actual y navegación
- **[PLAN_IMPLEMENTACION.md](roadmap/PLAN_IMPLEMENTACION.md)** - Roadmap completo
- **[CLAUDE.md](../CLAUDE.md)** - Contexto para Claude Code
- **[specs/](../specs/)** - Especificaciones de proyectos

### Análisis Técnico
- [GAP_ANALYSIS.md](analisis/GAP_ANALYSIS.md) - Análisis de gaps
- [VERIFICACION_WORKER.md](analisis/VERIFICACION_WORKER.md) - Estado del worker
- [DISTRIBUCION_RESPONSABILIDADES.md](analisis/DISTRIBUCION_RESPONSABILIDADES.md) - Arquitectura

### Diagramas
- [diagramas/](diagramas/) - Diagramas de arquitectura, BD, flujos

---

## 🚀 Siguientes Pasos

Para saber qué hacer a continuación, consulta:

1. **[ESTADO_PROYECTO.md](ESTADO_PROYECTO.md)** - Ver proyectos en progreso y pendientes
2. **[specs/api-admin-jerarquia/](../specs/api-admin-jerarquia/)** - Continuar proyecto actual
3. **[PLAN_IMPLEMENTACION.md](roadmap/PLAN_IMPLEMENTACION.md)** - Planificar nuevo sprint

---

**Última actualización:** 14 de Noviembre, 2025  
**Mantenedores:** Ver CLAUDE.md para contacto

---

_Este documento refleja la arquitectura actual de repositorios separados. Para historia del proyecto, ver docs/historico/_
