# Contexto del Proyecto para Claude Code

Este documento proporciona contexto esencial para Claude Code sobre el proyecto EduGo.

## 🎯 Propósito del Repositorio

Este es un **repositorio de documentación y análisis**, NO contiene código de aplicación.

**Historia:**
- Originalmente fue un monorepo que contenía 3 aplicaciones Go (api-mobile, api-administracion, worker) y una librería compartida (shared)
- En Octubre-Noviembre 2025 se ejecutó un proceso de **separación en repositorios independientes**
- El código fue movido a 5 repos en la organización **EduGoGroup** en GitHub
- Este repo mantiene **documentación histórica** del proceso y **herramientas de gestión**

## 📦 Repositorios Externos (El Código Real)

| Repositorio | Descripción | Tecnología |
|-------------|-------------|------------|
| **edugo-shared** | Biblioteca compartida Go (logger, db, auth, messaging, etc.) | Go 1.21+ |
| **edugo-api-mobile** | API REST para app móvil - Puerto 8080 | Go + Gin + GORM + Swagger |
| **edugo-api-administracion** | API REST administrativa - Puerto 8081 | Go + Gin + GORM + Swagger |
| **edugo-worker** | Worker de procesamiento asíncrono | Go + RabbitMQ + OpenAI |
| **edugo-dev-environment** | Entorno Docker completo para desarrollo | Docker Compose |

**URLs:** Todos bajo `https://github.com/EduGoGroup/<nombre-repo>` (privados)

## 🗂️ Estructura de Este Repositorio

```
Analisys/
├── docs/                      # Documentación técnica completa
│   ├── diagramas/             # Arquitectura, BD, flujos
│   └── historias_usuario/     # User stories por módulo
├── edugo-dev-environment/     # Copia local del entorno Docker
├── scripts/                   # Herramientas de automatización
│   ├── gitlab-runner-*.sh     # GitLab Runner local
│   ├── push-dual.sh           # Push a GitHub + GitLab
│   └── secrets/               # SOPS para secretos
├── *.md                       # Documentación del proceso
└── README.md                  # Documentación principal
```

### Archivos Importantes

- **REPOS_DEFINITIVOS.md** - Lista de repos creados y proceso de separación
- **ESTADO_REPOS_GITHUB.md** - Estado actual de publicación en GitHub
- **FLUJOS_CRITICOS.md** - Flujos principales del sistema EduGo
- **VARIABLES_ENTORNO.md** - Variables de entorno de cada proyecto
- **docs/MIGRATION_GUIDE.md** - Guía de migraciones de base de datos

## 🚫 Lo Que YA NO Está Aquí

Las siguientes carpetas fueron **eliminadas** tras la separación exitosa:

- ❌ `source/` (contenía api-mobile, api-administracion, worker)
- ❌ `shared/` (biblioteca compartida Go)
- ❌ `templates/` (templates de CI/CD)
- ❌ `EduGo-Informes-Separacion/` (informes de sesión)
- ❌ Archivos: `Makefile`, `docker-compose.yml`, `start-all.sh`, etc.

**Motivo:** El código migró a repos independientes. Mantener duplicados creaba confusión.

**Respaldo:** Existe rama `backup/feature-fase1-pre-separacion` con estado pre-limpieza.

## 🏗️ Arquitectura de EduGo

### Stack Tecnológico
- **Backend:** Go 1.21+ con Gin framework
- **Bases de Datos:** PostgreSQL 15 (relacional) + MongoDB 7.0 (documentos)
- **Mensajería:** RabbitMQ 3.12
- **Contenedores:** Docker + Docker Compose
- **CI/CD:** GitHub Actions + GitLab CI (dual-repo)
- **Secrets:** SOPS + Age (encriptación)
- **Config:** Viper (multi-ambiente: local, dev, qa, prod)

### Flujo de Datos Principal
1. **API Mobile/Admin** recibe peticiones HTTP
2. Valida y procesa en capas (handler → service → repository)
3. Persiste en **PostgreSQL** (datos relacionales)
4. Publica eventos a **RabbitMQ** para procesamiento asíncrono
5. **Worker** consume eventos y procesa:
   - Genera resúmenes con OpenAI
   - Crea quizzes automáticos
   - Guarda resultados en **MongoDB**

### Base de Datos
- **PostgreSQL:** 17 tablas (usuarios, escuelas, materiales, progreso, etc.)
- **MongoDB:** 3 colecciones (material_summary, material_assessment, material_event)

## 🔧 Comandos Útiles

### Para Desarrollo Local
```bash
# Levantar infraestructura (PostgreSQL, MongoDB, RabbitMQ)
cd edugo-dev-environment/
./scripts/setup.sh

# Ver estado de servicios
docker-compose -f docker/docker-compose.yml ps

# Logs de servicios
docker-compose -f docker/docker-compose.yml logs -f
```

### Para Gestión de Repos
```bash
# Push dual a GitHub + GitLab (desde este repo)
./scripts/push-dual.sh <repo-name> "mensaje commit"
# Ejemplo: ./scripts/push-dual.sh api-mobile "fix: corregir bug"

# GitLab Runner local
./scripts/gitlab-runner-start.sh    # Iniciar runner
./scripts/gitlab-runner-status.sh   # Ver estado
```

## 📋 Convenciones del Proyecto

### Commits
- **Formato:** `tipo: descripción`
- **Tipos:** feat, fix, docs, chore, refactor, test, perf
- **Ejemplo:** `feat: agregar endpoint de búsqueda de materiales`
- **Incluir:** Siempre agregar footer con Claude Code attribution

### Branches
- `main` - Rama principal (protegida)
- `feature/*` - Nuevas funcionalidades
- `fix/*` - Correcciones de bugs
- `docs/*` - Cambios de documentación
- `backup/*` - Ramas de respaldo (no tocar)

### Variables de Entorno
- Por ambiente: local, dev, qa, prod
- Encriptadas con SOPS (excepto local)
- Nunca commitear `.env` sin encriptar
- Ver `VARIABLES_ENTORNO.md` para lista completa

## ⚠️ Consideraciones Importantes

### Al Trabajar con Este Repo
1. **NO hay código de aplicación aquí** - Solo documentación
2. **NO crear carpetas `source/` o `shared/`** - Ya fueron separadas
3. **Mantener docs/ sincronizado** con cambios en repos externos
4. **Scripts en scripts/** son herramientas auxiliares, no parte del producto

### Al Referenciar Repositorios
- Siempre usar URLs completas de GitHub: `https://github.com/EduGoGroup/<repo>`
- Los repos son **privados** - requieren autenticación
- Para clonar: usar SSH o token de GitHub

### Al Hacer Cambios
1. Analizar si el cambio corresponde a este repo o a uno externo
2. Si es documentación técnica → Este repo
3. Si es código de aplicación → Repo correspondiente en EduGoGroup
4. Si afecta múltiples repos → Considerar abrir issues en cada uno

## 🔄 Workflow de Separación (Histórico)

**Proceso ejecutado:** Octubre-Noviembre 2025

### Fase 1: Separación ✅ COMPLETADA
1. Crear 5 repos vacíos en GitHub (EduGoGroup org)
2. Extraer código de cada proyecto
3. Publicar en repos individuales
4. Configurar CI/CD básico
5. Limpiar monorepo (este repo)

### Fase 2: CI/CD ⏳ EN PROGRESO
1. Configurar mirroring en GitLab
2. Implementar pipelines completos
3. Configurar ambientes de staging/producción

## ⚠️ IMPORTANTE: Leer RULES.md SIEMPRE

**ANTES DE INICIAR CUALQUIER TAREA, LEER:**
- `specs/api-admin-jerarquia/RULES.md` - Reglas del proyecto (workflow, git, PR, CI/CD)

Este archivo contiene:
- Gestión de Contexto y Logs
- Workflow de Ramas y Pull Requests
- Manejo de CI/CD y revisores automáticos
- **CASO ESPECIAL:** edugo-shared requiere releases por módulos desde dev antes de usar en otros proyectos

## 🎓 Para Claude Code en Futuras Sesiones

### Si el usuario pregunta por código de aplicación:
- Indicar que el código está en repos externos (EduGoGroup)
- Sugerir clonar el repo específico
- Este repo solo tiene documentación

### Si el usuario quiere agregar documentación:
- Agregar a `docs/` según categoría
- Actualizar README.md si es necesario
- Mantener formato markdown consistente

### Si el usuario quiere modificar scripts:
- Scripts en `scripts/` son herramientas auxiliares
- Probar localmente antes de commitear
- Documentar cambios en comentarios del script

### Si el usuario menciona "source" o "shared":
- Recordar que fueron eliminadas tras separación
- Código ahora en repos: edugo-api-*, edugo-worker, edugo-shared
- Rama backup disponible si se necesita referencia histórica

## 📞 Contacto y Recursos

- **Organización GitHub:** https://github.com/EduGoGroup
- **Repositorios:** Ver REPOS_DEFINITIVOS.md
- **Documentación Completa:** docs/
- **Issues/Bugs:** Abrir en el repo correspondiente de EduGoGroup

---

**Última actualización:** 11 de Noviembre, 2025
**Generado con:** Claude Code
