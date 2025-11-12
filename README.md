# EduGo - Repositorio de Análisis y Documentación

Este repositorio contiene la **documentación, análisis y proceso de separación** del proyecto EduGo en repositorios independientes.

## 📋 Propósito

Este repositorio sirve como:
- **Archivo histórico** del proceso de separación del monorepo
- **Documentación técnica** de decisiones arquitectónicas
- **Scripts de automatización** para gestión de repositorios
- **Entorno de desarrollo** centralizado (edugo-dev-environment)

## 🏗️ Arquitectura Actual

EduGo ha sido **separado en 5 repositorios independientes** alojados en la organización **EduGoGroup** en GitHub:

| Repositorio | Descripción | URL |
|-------------|-------------|-----|
| **edugo-shared** | Biblioteca compartida (logger, db, auth, errors, etc.) | https://github.com/EduGoGroup/edugo-shared |
| **edugo-api-mobile** | API REST para aplicación móvil (puerto 8080) | https://github.com/EduGoGroup/edugo-api-mobile |
| **edugo-api-administracion** | API REST administrativa (puerto 8081) | https://github.com/EduGoGroup/edugo-api-administracion |
| **edugo-worker** | Worker de procesamiento asíncrono (RabbitMQ) | https://github.com/EduGoGroup/edugo-worker |
| **edugo-dev-environment** | Entorno de desarrollo completo (Docker Compose) | https://github.com/EduGoGroup/edugo-dev-environment |

**Estado:** ✅ Todos los repositorios publicados con contenido (266 archivos totales)

## 📂 Contenido de Este Repositorio

```
Analisys/
├── docs/                           # Documentación técnica
│   ├── diagramas/                  # Diagramas de arquitectura y BD
│   ├── historias_usuario/          # Historias de usuario por módulo
│   └── MIGRATION_GUIDE.md          # Guía de migración de BD
├── edugo-dev-environment/          # Entorno Docker para desarrollo local
│   ├── docker/                     # Docker Compose y configuración
│   ├── scripts/                    # Scripts de setup y cleanup
│   └── docs/                       # Documentación del entorno
├── scripts/                        # Scripts de automatización
│   ├── gitlab-runner-start.sh      # Iniciar GitLab Runner local
│   ├── gitlab-runner-status.sh     # Estado del runner
│   ├── push-dual.sh                # Push dual a GitHub + GitLab
│   └── secrets/                    # Scripts para SOPS (secretos)
├── REPOS_DEFINITIVOS.md            # Información de repositorios creados
├── ESTADO_REPOS_GITHUB.md          # Estado actual de repos en GitHub
├── FLUJOS_CRITICOS.md              # Flujos críticos del sistema
├── VARIABLES_ENTORNO.md            # Variables de entorno por proyecto
└── README.md                       # Este archivo
```

## 🚀 Stack Tecnológico

### Backend
- **Lenguaje:** Go 1.21+
- **Framework Web:** Gin (APIs REST)
- **ORM:** GORM
- **Documentación:** Swagger/OpenAPI
- **Config:** Viper (multi-ambiente)

### Bases de Datos
- **PostgreSQL 15:** Datos relacionales (17 tablas)
- **MongoDB 7.0:** Documentos JSON (3 colecciones)

### Mensajería
- **RabbitMQ 3.12:** Cola de mensajes para worker

### DevOps
- **Docker & Docker Compose:** Containerización
- **GitHub Actions:** CI/CD en GitHub
- **GitLab CI/CD:** Pipeline alternativo (dual-repo)
- **SOPS + Age:** Manejo seguro de secretos

## 🛠️ Desarrollo Local

### Opción 1: Usar Entorno Completo (Recomendado)

El repositorio **edugo-dev-environment** incluye todo lo necesario:

```bash
# Clonar el entorno de desarrollo
cd edugo-dev-environment/

# Iniciar todos los servicios (PostgreSQL, MongoDB, RabbitMQ)
./scripts/setup.sh

# Los servicios quedan corriendo en:
# - PostgreSQL: localhost:5432
# - MongoDB: localhost:27017
# - RabbitMQ: localhost:5672 (UI en :15672)
```

Ver documentación completa: [edugo-dev-environment/README.md](edugo-dev-environment/README.md)

### Opción 2: Clonar Repositorios Individuales

```bash
# Clonar cada proyecto
git clone https://github.com/EduGoGroup/edugo-shared.git
git clone https://github.com/EduGoGroup/edugo-api-mobile.git
git clone https://github.com/EduGoGroup/edugo-api-administracion.git
git clone https://github.com/EduGoGroup/edugo-worker.git

# Cada proyecto tiene su propio Makefile
cd edugo-api-mobile/
make help              # Ver comandos disponibles
make build             # Compilar
make run               # Ejecutar localmente
make test              # Tests
make swagger           # Regenerar Swagger
```

## 📖 Documentación Importante

### Guías Técnicas
- **[FLUJOS_CRITICOS.md](FLUJOS_CRITICOS.md)** - Flujos principales del sistema
- **[VARIABLES_ENTORNO.md](VARIABLES_ENTORNO.md)** - Variables de entorno por proyecto
- **[docs/MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md)** - Guía de migración de base de datos
- **[docs/diagramas/](docs/diagramas/)** - Diagramas de arquitectura

### Proceso de Separación (Histórico)
- **[REPOS_DEFINITIVOS.md](REPOS_DEFINITIVOS.md)** - Repositorios creados y proceso
- **[ESTADO_REPOS_GITHUB.md](ESTADO_REPOS_GITHUB.md)** - Estado de publicación

## 🔐 Manejo de Secretos

Los proyectos usan **SOPS + Age** para encriptar secretos:

```bash
# Setup inicial (generar clave Age personal)
./scripts/secrets/setup-sops.sh

# Desencriptar secretos de un ambiente
./scripts/secrets/decrypt.sh dev

# Variables quedan en .env.dev (gitignored)
```

Ver guía completa en cada repositorio: `<repo>/docs/SECRETS.md`

## 🔄 Workflow de Desarrollo

### 1. Desarrollo Local
```bash
# Levantar infraestructura
cd edugo-dev-environment/
./scripts/setup.sh

# En otro terminal, trabajar en tu proyecto
cd ../edugo-api-mobile/
make run
```

### 2. Hacer Cambios
```bash
# Hacer cambios en el código
git add .
git commit -m "feat: nueva funcionalidad"
```

### 3. Push Dual (GitHub + GitLab)
```bash
# Si trabajas con dual-repo
./scripts/push-dual.sh api-mobile "feat: nueva funcionalidad"
```

## 📊 Estado del Proyecto

**Fase Actual:** ✅ **FASE 1 COMPLETADA - Separación de Repositorios**

### Completado ✅
- Separación de monorepo en 5 repositorios independientes
- Publicación de todos los repos en GitHub (privados)
- Entorno de desarrollo Docker completo
- Documentación técnica y guías
- CI/CD básico configurado

### Próximos Pasos ⏭️
- **FASE 2:** Configurar mirroring automático en GitLab
- **FASE 3:** Implementar pipelines CI/CD completos
- **FASE 4:** Configurar ambientes de staging/producción

Ver roadmap completo en: [PLAN-SEPARACION-COMPLETO.md](PLAN-SEPARACION-COMPLETO.md)

## 🤝 Equipo

**Desarrollado con** 🤖 [Claude Code](https://claude.com/claude-code)

## 📝 Notas Importantes

> **⚠️ IMPORTANTE:** Las carpetas `source/`, `shared/` y `templates/` fueron **eliminadas** de este repositorio tras la separación exitosa. El código vive ahora en sus repositorios independientes en GitHub.

> **✅ Rama de respaldo:** Existe una rama `backup/feature-fase1-pre-separacion` con el estado pre-limpieza por si se necesita referencia histórica.

---

**Última actualización:** 11 de Noviembre, 2025
