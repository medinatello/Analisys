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
# Editar .env y agregar OPENAI_API_KEY

# 2. Levantar servicios
make up
```

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
