# 📚 EduGo - Plataforma Educativa

Sistema integral para gestión de materiales educativos con procesamiento automático mediante IA.

---

## 🏗️ Arquitectura

```
EduGo/
├── source/
│   ├── api-mobile/          # API para estudiantes/profesores (Puerto 8080)
│   ├── api-administracion/  # API administrativa (Puerto 8081)
│   ├── worker/              # Procesador de materiales (RabbitMQ)
│   └── scripts/             # Scripts de inicialización de BD
├── docs/                    # Documentación técnica y diagramas
└── Docker files             # Infraestructura containerizada
```

---

## 🚀 Inicio Rápido

### Prerrequisitos
- Docker y Docker Compose
- (Opcional) Go 1.21+ para desarrollo local

### Levantar Stack Completo

```bash
# 1. Configurar variables de entorno
cp .env.example .env
# Editar .env y configurar:
#   - APP_ENV (local, dev, qa, prod)
#   - OPENAI_API_KEY
#   - Otros secretos si es necesario

# 2. Levantar servicios
make up

# O especificar ambiente:
APP_ENV=dev make up
APP_ENV=qa make up
```

### Configuración por Ambientes

Cada servicio usa **Viper** para cargar configuración dinámica:

```bash
# Local (default)
go run source/api-mobile/cmd/main.go

# Development
APP_ENV=dev go run source/api-mobile/cmd/main.go

# QA
APP_ENV=qa go run source/api-mobile/cmd/main.go

# Production
APP_ENV=prod OPENAI_API_KEY=sk-xxx go run source/api-mobile/cmd/main.go
```

**Archivos de configuración**:
- `config/config.yaml` - Base (común)
- `config/config-{env}.yaml` - Específico por ambiente

**Precedencia**: ENV vars > archivo específico > archivo base > defaults

Ver detalles: `source/*/config/README.md`

---

## 🛠️ Scripts de Desarrollo Local

Para desarrollo local sin Docker:

```bash
# Iniciar todos los servicios
./start-all.sh

# Ver estado
./status.sh

# Ver logs en tiempo real
./logs-all.sh

# Detener todos
./stop-all.sh
```

**Ventajas**:
- ✅ Inicio rápido (sin Docker overhead)
- ✅ Logs individuales en `logs/`
- ✅ Fácil debugging y hot-reload
- ✅ Gestión de PIDs automática

Ver guía completa: [SCRIPTS.md](SCRIPTS.md)

### Acceso a Servicios

- **API Mobile Swagger**: http://localhost:8080/swagger/index.html
- **API Admin Swagger**: http://localhost:8081/swagger/index.html
- **RabbitMQ Management**: http://localhost:15672 (edugo_user/edugo_pass)

---

## 📦 Servicios

### API Mobile (Puerto 8080)
Endpoints para consumo de materiales educativos:
- Búsqueda y listado de materiales
- Resúmenes generados por IA
- Quizzes con feedback personalizado
- Tracking de progreso

### API Administración (Puerto 8081)
Endpoints administrativos:
- Gestión de usuarios y roles
- Jerarquía organizacional (escuelas, unidades)
- Gestión de materias
- Estadísticas globales
- **Post-MVP**: Vínculos tutor-estudiante, actualización de materias

### Worker
Procesamiento automático de materiales:
- Generación de resúmenes con OpenAI
- Generación de quizzes
- Procesamiento asíncrono vía RabbitMQ

---

## 🗄️ Bases de Datos

**PostgreSQL** (17 tablas):
- Usuarios, jerarquía organizacional
- Materiales, progreso, evaluaciones

**MongoDB** (3 colecciones):
- `material_summary` - Resúmenes generados
- `material_assessment` - Quizzes
- `material_event` - Eventos de consumo

Ver guía completa: [MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md)

---

## 🐳 Docker Local Persistente

Para desarrollo local con contenedores que NO se destruyen:

```bash
# Iniciar infraestructura + apps (datos persisten)
make local-start-all

# Detener (mantiene datos en volúmenes Docker)
make local-stop-all

# Limpiar todo (requiere confirmación DELETE)
make local-clean
```

**Ventajas**:
- ✅ Contenedores persisten entre reinicios
- ✅ Datos NO se pierden al cerrar terminal
- ✅ Rápido (no recrear cada vez)
- ✅ Validación inteligente de datos

Ver guía: [docker/README.md](docker/README.md)

---

## 🔐 Manejo de Secretos

Sistema profesional con **SOPS** (encriptación) para secretos por ambiente.

### Por Ambiente

| Ambiente | Método | Archivo |
|----------|--------|---------|
| **local** | Valores fijos | config-local.yaml (committed) |
| **dev** | SOPS encriptado | .env.dev.enc (committed) |
| **qa** | SOPS encriptado | .env.qa.enc (committed) |
| **prod** | Kubernetes Secrets | No archivos |

### Setup (Primera Vez)

```bash
# Generar tu clave Age personal
make secrets-setup

# Compartir clave pública con team lead

# Desencriptar secretos
make secrets-decrypt-all

# Usar
APP_ENV=dev make run
```

**Cada developer usa su propia clave** - no necesitan compartir claves privadas.

Ver guía completa: [SECRETS.md](SECRETS.md)

---

## 🛠️ Desarrollo

Ver guía detallada: [DEVELOPMENT.md](docs/DEVELOPMENT.md)

### Comandos Útiles

```bash
make help               # Ver todos los comandos
make build              # Construir imágenes Docker
make up                 # Levantar servicios
make down               # Detener servicios
make logs               # Ver logs
make swagger            # Regenerar Swagger
make test               # Ejecutar tests
```

---

## 📖 Documentación

- [DOCKER.md](DOCKER.md) - Guía de Docker
- [MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md) - Guía de migración de BD
- [CHANGELOG.md](CHANGELOG.md) - Historial de cambios
- [docs/diagramas/](docs/diagramas/) - Diagramas técnicos

---

## 📊 Estado del Proyecto

**Versión**: 1.0.0 (Post-Refactorización)
**Última actualización**: 2025-10-29
**Tests**: 3/3 passing ✓
**Cobertura**: Básica (modelos)

---

**Desarrollado con** 🤖 [Claude Code](https://claude.com/claude-code)
