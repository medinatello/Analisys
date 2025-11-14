# Contexto del Proyecto para Claude Code

Este documento proporciona contexto esencial para Claude Code sobre el proyecto EduGo.

---

## ⚠️ ANTES DE INICIAR CUALQUIER TAREA

### 📍 Leer SIEMPRE Primero

**[docs/ESTADO_PROYECTO.md](docs/ESTADO_PROYECTO.md)** - Documento pivote que contiene:
- ✅ Proyectos completados con detalles
- 🔄 Proyectos en progreso con % avance y próximos pasos
- ⬜ Proyectos pendientes del plan original
- 🗺️ Navegación rápida a documentación relevante
- 📈 Métricas globales acumuladas

**Este documento es el punto de entrada para ubicarte rápidamente en el estado actual del proyecto.**

---

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
├── docs/
│   ├── ESTADO_PROYECTO.md     # ⭐⭐⭐ DOCUMENTO PIVOTE - LEER PRIMERO
│   ├── DEVELOPMENT.md         # Guía de desarrollo actualizada
│   │
│   ├── specs/                 # Especificaciones de proyectos
│   │   ├── api-admin-jerarquia/        # 🔄 En progreso (44%)
│   │   └── shared-testcontainers/      # ✅ Completado (100%)
│   │
│   ├── analisis/              # Análisis técnico
│   ├── roadmap/               # Planes de trabajo
│   ├── diagramas/             # Arquitectura, BD, flujos
│   ├── historias_usuario/     # User stories por módulo
│   └── historico/             # Documentación histórica
│
├── scripts/                   # Herramientas de automatización
│   ├── gitlab-runner-*.sh
│   ├── push-dual.sh
│   └── secrets/
│
├── FLUJOS_CRITICOS.md
├── VARIABLES_ENTORNO.md
├── CLAUDE.md                  # Este archivo
└── README.md
```

### Archivos Clave para Claude

- **[docs/ESTADO_PROYECTO.md](docs/ESTADO_PROYECTO.md)** - ⭐ Punto de entrada, estado actual
- **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** - Guía de desarrollo
- **[specs/api-admin-jerarquia/RULES.md](specs/api-admin-jerarquia/RULES.md)** - Reglas del proyecto en progreso
- **[docs/roadmap/PLAN_IMPLEMENTACION.md](docs/roadmap/PLAN_IMPLEMENTACION.md)** - Plan maestro
- **[FLUJOS_CRITICOS.md](FLUJOS_CRITICOS.md)** - Flujos del sistema
- **[VARIABLES_ENTORNO.md](VARIABLES_ENTORNO.md)** - Variables de entorno

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

## 🎓 Para Claude Code en Futuras Sesiones

### Workflow de Inicio de Sesión

1. **SIEMPRE leer primero:** [docs/ESTADO_PROYECTO.md](docs/ESTADO_PROYECTO.md)
   - Revisar proyectos completados
   - Identificar proyectos en progreso
   - Ver próximos pasos recomendados

2. **Si continúas un proyecto existente:**
   - Ir a `specs/<nombre-proyecto>/`
   - Leer `RULES.md` (reglas específicas del proyecto)
   - Revisar `TASKS.md` o `TASKS_UPDATED.md` (plan detallado)
   - Consultar `LOGS.md` (última sesión)
   - Continuar desde el punto indicado

3. **Si inicias un proyecto nuevo:**
   - Consultar [docs/roadmap/PLAN_IMPLEMENTACION.md](docs/roadmap/PLAN_IMPLEMENTACION.md)
   - Crear carpeta `specs/<nombre-proyecto>/`
   - Seguir estructura de `specs/api-admin-jerarquia/` como ejemplo
   - Crear: README.md, RULES.md, TASKS.md, LOGS.md, etc.

### Si el Usuario Pregunta por Código de Aplicación

- ✅ Indicar que el código está en repos externos (EduGoGroup)
- ✅ Rutas locales: `/Users/jhoanmedina/source/EduGo/repos-separados/`
- ✅ Este repo solo tiene documentación y análisis
- ✅ Sugerir clonar el repo específico si no está disponible

### Si el Usuario Quiere Continuar un Proyecto

1. Abrir [docs/ESTADO_PROYECTO.md](docs/ESTADO_PROYECTO.md)
2. Buscar el proyecto en sección "🔄 Proyectos En Progreso"
3. Seguir link a `specs/<proyecto>/`
4. Leer RULES.md del proyecto
5. Revisar TASKS.md para próxima fase
6. Consultar LOGS.md para contexto de última sesión

### Si el Usuario Quiere Iniciar Nuevo Proyecto

1. Verificar en [docs/roadmap/PLAN_IMPLEMENTACION.md](docs/roadmap/PLAN_IMPLEMENTACION.md) la prioridad
2. Crear estructura en `specs/<nuevo-proyecto>/`
3. Copiar patrón de `specs/api-admin-jerarquia/`
4. Actualizar [docs/ESTADO_PROYECTO.md](docs/ESTADO_PROYECTO.md) agregando a "En Progreso"

### Si el Usuario Quiere Agregar Documentación

- ✅ Agregar a `docs/` según categoría (analisis/, diagramas/, historias_usuario/)
- ✅ Actualizar [docs/ESTADO_PROYECTO.md](docs/ESTADO_PROYECTO.md) si es relevante
- ✅ Actualizar README.md si impacta navegación general
- ✅ Mantener formato markdown consistente

### Si el Usuario Menciona "source" o "shared" (carpetas)

- ⚠️ Recordar que fueron eliminadas tras separación de repos
- ✅ Código ahora en `/Users/jhoanmedina/source/EduGo/repos-separados/`
- ✅ Repos individuales: edugo-api-*, edugo-worker, edugo-shared
- ✅ Rama backup disponible: `backup/feature-fase1-pre-separacion`

### Reglas Importantes de edugo-shared

**CASO ESPECIAL:** edugo-shared requiere releases por módulos desde **dev** antes de usar en otros proyectos.

Ver `specs/api-admin-jerarquia/RULES.md` para detalles completos sobre:
- Gestión de Contexto y Logs
- Workflow de Ramas y Pull Requests
- Manejo de CI/CD y revisores automáticos

## 📞 Contacto y Recursos

- **Organización GitHub:** https://github.com/EduGoGroup
- **Repositorios:** Ver REPOS_DEFINITIVOS.md
- **Documentación Completa:** docs/
- **Issues/Bugs:** Abrir en el repo correspondiente de EduGoGroup

---

**Última actualización:** 14 de Noviembre, 2025  
**Generado con:** Claude Code

---

**Recuerda:** El documento [docs/ESTADO_PROYECTO.md](docs/ESTADO_PROYECTO.md) es tu guía principal para navegar el proyecto.
