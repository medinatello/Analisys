# 🎯 MEGAPROMPT: Continuación Análisis Estandarizado - EduGo
# Sistema de Evaluaciones (spec-01)

**Fecha creación:** 2025-11-14  
**Estado actual:** 75% completado  
**Objetivo:** Completar spec-01-evaluaciones al 100% siguiendo metodología estandarizada

---

## 📍 CONTEXTO DEL PROYECTO

### Qué es Este Proyecto

Este repositorio (`/Users/jhoanmedina/source/EduGo/Analisys`) es el **centro de documentación** del ecosistema EduGo. Estamos ejecutando una **transformación de documentación desordenada a análisis profesional estandarizado** siguiendo el patrón definido en `PROMPT_ANALISIS_ESTANDARIZADO.md`.

### Objetivo Global

Transformar toda la documentación existente en `docs/` a formato estandarizado en `AnalisisEstandarizado/` con estructura:

```
AnalisisEstandarizado/
├── spec-01-evaluaciones/     # Sistema de Evaluaciones (EN PROGRESO - 75%)
├── spec-02-worker/            # Verificación Worker (PENDIENTE)
├── spec-03-shared/            # Consolidación Shared (PENDIENTE)
└── ...
```

### Stack Tecnológico del Proyecto Real

- **Backend:** Go 1.21+ con Gin framework
- **Bases de Datos:** PostgreSQL 15+ (relacional) + MongoDB 7.0+ (documentos)
- **Arquitectura:** Clean Architecture (Hexagonal)
- **Testing:** Testify + Testcontainers
- **Proyecto:** edugo-api-mobile (Puerto 8080)

---

## 📊 ESTADO ACTUAL: spec-01-evaluaciones (75% COMPLETO)

### ✅ YA COMPLETADO (NO TOCAR)

#### 01-Requirements/ - 100% ✅
```
01-Requirements/
├── PRD.md (4,651 palabras)
├── FUNCTIONAL_SPECS.md (5,982 palabras) - 12 especificaciones RF-001 a RF-012
├── TECHNICAL_SPECS.md (6,234 palabras) - Stack, Clean Architecture, ADRs
└── ACCEPTANCE_CRITERIA.md (5,123 palabras) - 47 criterios medibles
```

**Contenido clave:**
- PRD: Visión, 4 objetivos de negocio, stakeholders, KPIs (>60% completitud, >70% puntaje)
- Functional Specs: 6 MUST (MVP), 3 SHOULD, 2 COULD, 1 WON'T
- Technical Specs: Go 1.21+, Gin, GORM, PostgreSQL 15+, MongoDB 7.0+
- Acceptance Criteria: Criterios SMART, tests automatizables

#### 02-Design/ - 100% ✅
```
02-Design/
├── ARCHITECTURE.md (9,847 palabras)
├── DATA_MODEL.md (8,456 palabras)
├── API_CONTRACTS.md (7,123 palabras)
└── SECURITY_DESIGN.md (6,789 palabras)
```

**Contenido clave:**
- Architecture: Diagramas C4, Clean Architecture (Domain/Application/Infrastructure), patrones
- Data Model: 4 tablas PostgreSQL + 1 colección MongoDB, migraciones SQL completas, seeds
- API Contracts: OpenAPI 3.0, 4 endpoints REST, schemas completos
- Security: STRIDE threat model, JWT auth, validación servidor-side, NUNCA exponer respuestas correctas

**Tablas PostgreSQL:**
1. `assessment` - Metadatos de evaluaciones
2. `assessment_attempt` - Intentos de estudiantes (INMUTABLE)
3. `assessment_attempt_answer` - Respuestas individuales
4. `material_summary_link` - Enlaces a MongoDB (opcional)

**Endpoints REST:**
1. `GET /v1/materials/:id/assessment` - Obtener cuestionario (SIN respuestas correctas)
2. `POST /v1/materials/:id/assessment/attempts` - Crear intento y obtener calificación
3. `GET /v1/attempts/:id/results` - Obtener resultados de un intento
4. `GET /v1/users/me/attempts` - Historial del usuario

#### 03-Sprints/ - 17% ✅
```
03-Sprints/
└── Sprint-01-Schema-BD/
    └── README.md (creado)
```

---

## 🎯 TAREA PRINCIPAL: COMPLETAR spec-01-evaluaciones AL 100%

### Archivos que DEBES GENERAR (33 archivos restantes)

#### A. Completar Sprint-01 (4 archivos)
```
03-Sprints/Sprint-01-Schema-BD/
├── README.md ✅ (ya existe)
├── TASKS.md ⚠️ GENERAR
├── DEPENDENCIES.md ⚠️ GENERAR
├── QUESTIONS.md ⚠️ GENERAR
└── VALIDATION.md ⚠️ GENERAR
```

#### B. Crear Sprint-02 a Sprint-06 (5 sprints × 5 archivos = 25 archivos)
```
03-Sprints/
├── Sprint-02-Dominio/ ⚠️ GENERAR (5 archivos)
├── Sprint-03-Repositorios/ ⚠️ GENERAR (5 archivos)
├── Sprint-04-Services-API/ ⚠️ GENERAR (5 archivos)
├── Sprint-05-Testing/ ⚠️ GENERAR (5 archivos)
└── Sprint-06-CI-CD/ ⚠️ GENERAR (5 archivos)
```

#### C. Testing (3 archivos)
```
04-Testing/
├── TEST_STRATEGY.md ⚠️ GENERAR
├── TEST_CASES.md ⚠️ GENERAR
└── COVERAGE_REPORT.md ⚠️ GENERAR
```

#### D. Deployment (3 archivos)
```
05-Deployment/
├── DEPLOYMENT_GUIDE.md ⚠️ GENERAR
├── INFRASTRUCTURE.md ⚠️ GENERAR
└── MONITORING.md ⚠️ GENERAR
```

#### E. Tracking System (2 archivos)
```
AnalisisEstandarizado/spec-01-evaluaciones/
├── PROGRESS.json ⚠️ GENERAR
└── TRACKING_SYSTEM.md ⚠️ GENERAR
```

---

## 📝 ESPECIFICACIONES DETALLADAS POR ARCHIVO

### SPRINT STRUCTURE (Cada sprint debe tener exactamente esta estructura)

#### TASKS.md - Formato Requerido

```markdown
# Tareas del Sprint XX - [Nombre]

## Objetivo
[Descripción clara y concisa del objetivo del sprint]

## Tareas

### TASK-XX-001: [Nombre de la tarea]
**Tipo:** feature|fix|refactor|test|docs  
**Prioridad:** HIGH|MEDIUM|LOW  
**Estimación:** Xh  
**Asignado a:** @ai-executor

#### Descripción
[Descripción detallada de QUÉ hacer]

#### Pasos de Implementación
1. Crear archivo `ruta/absoluta/al/archivo.ext`
2. Implementar con esta firma exacta:
   ```language
   código exacto con nombres de funciones, parámetros, etc.
   ```
3. Agregar tests unitarios en `ruta/tests/`
4. Actualizar documentación

#### Criterios de Aceptación
- [ ] Archivo creado en ruta especificada
- [ ] Tests pasando con coverage >85%
- [ ] Sin errores de linting
- [ ] Documentación actualizada

#### Comandos de Validación
\`\`\`bash
# Verificar implementación
go test ./ruta/al/package -v

# Verificar coverage
go test ./ruta/al/package -cover

# Verificar linting
golangci-lint run ./ruta/al/package
\`\`\`

#### Dependencias
- Requiere TASK-XX-000 completada
- Usa: edugo-shared v0.6.2

#### Tiempo Estimado
2 horas
```

**IMPORTANTE:**
- Cada tarea debe ser COMPLETAMENTE EJECUTABLE sin ambigüedades
- Incluir rutas EXACTAS a archivos
- Incluir firmas EXACTAS de funciones
- Incluir comandos EXACTOS de validación
- Sin placeholders como "implementar según necesidad"

#### DEPENDENCIES.md - Formato Requerido

```markdown
# Dependencias del Sprint XX

## Dependencias Técnicas Previas
- [ ] PostgreSQL 15+ instalado y configurado
- [ ] Go 1.21+ instalado
- [ ] edugo-shared v0.6.2 disponible
- [ ] Docker 24+ para testcontainers

## Dependencias de Código
- [ ] Sprint-XX completado (si aplica)
- [ ] Package `ruta/package` creado
- [ ] Tabla `nombre_tabla` existe en PostgreSQL

## Herramientas Requeridas
\`\`\`bash
# Instalar dependencias exactas
go get github.com/stretchr/testify@v1.8.4
go get gorm.io/gorm@v1.25.5
\`\`\`

## Variables de Entorno
\`\`\`bash
export DATABASE_URL="postgres://user:pass@localhost:5432/edugo"
export JWT_SECRET_KEY="secret-key-here"
\`\`\`

## Verificación de Dependencias
\`\`\`bash
# Verificar PostgreSQL
psql -U postgres -c "SELECT version();"

# Verificar Go
go version

# Verificar dependencias Go
go mod verify
\`\`\`
```

#### QUESTIONS.md - Formato Requerido

```markdown
# Preguntas y Decisiones del Sprint XX

## Q001: [Título de la pregunta]
**Contexto:** [Por qué surge esta pregunta]

**Opciones:**
1. **Opción A:** [Descripción detallada]
   - Pros: [Lista]
   - Contras: [Lista]
   
2. **Opción B:** [Descripción detallada]
   - Pros: [Lista]
   - Contras: [Lista]

**Decisión por Defecto:** Opción A

**Justificación:** [Por qué elegimos esta opción como default]

**Implementación si Opción A:**
\`\`\`bash
# Comandos exactos para Opción A
comando1
comando2
\`\`\`

**Implementación si Opción B:**
\`\`\`bash
# Comandos exactos para Opción B
comando_alternativo
\`\`\`

---

## Q002: [Siguiente pregunta]
[Mismo formato]
```

**IMPORTANTE:**
- TODAS las preguntas deben tener una decisión por defecto
- TODAS las decisiones deben tener comandos ejecutables
- Sin ambigüedades, todo debe ser ejecutable automáticamente

#### VALIDATION.md - Formato Requerido

```markdown
# Validación del Sprint XX

## Pre-validación
\`\`\`bash
# Verificar estado del proyecto
git status
go mod tidy
\`\`\`

## Checklist de Validación

### 1. Tests Unitarios
\`\`\`bash
# Ejecutar tests del sprint
go test ./internal/domain/... -v
go test ./internal/application/... -v
\`\`\`
**Criterio de éxito:** Todos los tests pasan sin errores

### 2. Coverage
\`\`\`bash
# Verificar cobertura mínima 80%
go test ./... -cover -coverprofile=coverage.out
go tool cover -func=coverage.out | grep total
\`\`\`
**Criterio de éxito:** Coverage total >80%

### 3. Linting
\`\`\`bash
# Sin warnings
golangci-lint run ./...
\`\`\`
**Criterio de éxito:** 0 errores, 0 warnings

### 4. Integración
\`\`\`bash
# Tests de integración con testcontainers
go test ./tests/integration/... -v
\`\`\`
**Criterio de éxito:** Todos los tests de integración pasan

### 5. Build
\`\`\`bash
# Compilación exitosa
go build -o bin/api-mobile ./cmd/api/
\`\`\`
**Criterio de éxito:** Build sin errores

## Criterios de Éxito Globales
- [ ] Todos los tests unitarios pasando
- [ ] Coverage >80%
- [ ] Tests de integración exitosos
- [ ] Sin warnings de linter
- [ ] Build exitoso
- [ ] Documentación actualizada
- [ ] Commits con mensajes descriptivos

## Comandos de Rollback
\`\`\`bash
# Si algo falla, rollback
git checkout main
git branch -D feature/sprint-XX
\`\`\`
```

---

### CONTENIDO ESPECÍFICO DE CADA SPRINT

#### Sprint-01: Schema de Base de Datos (2 días)
**Objetivo:** Crear 4 tablas PostgreSQL con migraciones e índices

**Tareas clave:**
- TASK-01-001: Crear migración `06_assessments.sql` con 4 tablas
- TASK-01-002: Crear índices optimizados (15+ índices)
- TASK-01-003: Crear seeds de datos de prueba
- TASK-01-004: Crear script de rollback
- TASK-01-005: Tests de integridad referencial

**Entregables:**
- `scripts/postgresql/06_assessments.sql`
- `scripts/postgresql/06_assessments_rollback.sql`
- `scripts/postgresql/seeds/assessment_seeds.sql`

#### Sprint-02: Dominio (3 días)
**Objetivo:** Implementar capa de dominio (entities, value objects, interfaces)

**Tareas clave:**
- TASK-02-001: Crear entity `Assessment` en `internal/domain/entities/assessment.go`
- TASK-02-002: Crear entity `Attempt` en `internal/domain/entities/attempt.go`
- TASK-02-003: Crear entity `Answer` en `internal/domain/entities/answer.go`
- TASK-02-004: Crear value objects (Score, AssessmentID, etc.)
- TASK-02-005: Crear interfaces de repositorios
- TASK-02-006: Tests unitarios de dominio (>90% coverage)

**Entregables:**
- 3 entities con business rules
- 4+ value objects
- 3 repository interfaces
- Tests unitarios completos

#### Sprint-03: Repositorios (3 días)
**Objetivo:** Implementar repositorios PostgreSQL y MongoDB

**Tareas clave:**
- TASK-03-001: Implementar `PostgresAssessmentRepository`
- TASK-03-002: Implementar `PostgresAttemptRepository` con transacciones ACID
- TASK-03-003: Implementar `MongoQuestionRepository`
- TASK-03-004: Tests de integración con testcontainers
- TASK-03-005: Configurar pool de conexiones

**Entregables:**
- 2 repositorios PostgreSQL
- 1 repositorio MongoDB
- Tests de integración >70% coverage

#### Sprint-04: Services y API REST (4 días)
**Objetivo:** Implementar services, handlers y endpoints REST

**Tareas clave:**
- TASK-04-001: Implementar `AssessmentService`
- TASK-04-002: Implementar `ScoringService` con validación servidor-side
- TASK-04-003: Implementar `AssessmentHandler` con 4 endpoints
- TASK-04-004: Configurar rutas y middleware
- TASK-04-005: Swagger annotations
- TASK-04-006: Tests E2E del flujo completo

**Entregables:**
- 2 services de aplicación
- 4 endpoints REST funcionales
- Swagger UI funcionando
- Tests E2E completos

#### Sprint-05: Testing Completo (2 días)
**Objetivo:** Suite completa de tests (unitarios, integración, E2E)

**Tareas clave:**
- TASK-05-001: Tests unitarios de dominio (>90%)
- TASK-05-002: Tests de integración con testcontainers
- TASK-05-003: Tests E2E de flujos completos
- TASK-05-004: Tests de seguridad (sanitización, validación)
- TASK-05-005: Tests de performance (<2 seg p95)

**Entregables:**
- Coverage global >80%
- Suite de tests completa
- Reporte de coverage

#### Sprint-06: CI/CD y Documentación (2 días)
**Objetivo:** Pipeline CI/CD completo y documentación final

**Tareas clave:**
- TASK-06-001: GitHub Actions workflow
- TASK-06-002: Linting automático
- TASK-06-003: Tests automáticos en CI
- TASK-06-004: Build y publish de imagen Docker
- TASK-06-005: Documentación README actualizada

**Entregables:**
- `.github/workflows/ci.yml`
- Pipeline verde
- Documentación completa

---

### TESTING DOCUMENTATION

#### TEST_STRATEGY.md
**Contenido requerido:**
- Pirámide de testing (70% unit, 20% integration, 10% E2E)
- Estrategia de coverage (>80% global)
- Herramientas (Testify, Testcontainers)
- Tipos de tests por capa
- CI/CD integration

#### TEST_CASES.md
**Contenido requerido:**
- Tests casos por endpoint (mínimo 5 casos por endpoint)
- Tests de validación de inputs
- Tests de seguridad (respuestas correctas nunca expuestas)
- Tests de performance
- Tests de failure scenarios

#### COVERAGE_REPORT.md
**Contenido requerido:**
- Coverage por paquete
- Coverage por capa (Domain, Application, Infrastructure)
- Gaps de coverage identificados
- Plan de mejora

---

### DEPLOYMENT DOCUMENTATION

#### DEPLOYMENT_GUIDE.md
**Contenido requerido:**
- Pasos de deployment paso a paso
- Migraciones de BD
- Variables de entorno
- Health checks
- Rollback procedure

#### INFRASTRUCTURE.md
**Contenido requerido:**
- Arquitectura de infraestructura
- Docker Compose setup
- Kubernetes manifests (Post-MVP)
- Escalado horizontal
- Backups y disaster recovery

#### MONITORING.md
**Contenido requerido:**
- Métricas clave (latencia, throughput, error rate)
- Prometheus metrics
- Alertas críticas
- Logs estructurados
- Dashboards

---

### TRACKING SYSTEM

#### PROGRESS.json
**Formato exacto:**
```json
{
  "project": "spec-01-evaluaciones",
  "project_name": "Sistema de Evaluaciones - EduGo",
  "version": "1.0.0",
  "total_sprints": 6,
  "total_tasks": 35,
  "current_sprint": 1,
  "current_task": "TASK-01-001",
  "completed_tasks": [],
  "failed_tasks": [],
  "skipped_tasks": [],
  "sprint_status": {
    "Sprint-01": "pending",
    "Sprint-02": "blocked",
    "Sprint-03": "blocked",
    "Sprint-04": "blocked",
    "Sprint-05": "blocked",
    "Sprint-06": "blocked"
  },
  "execution_mode": "unattended",
  "ai_executor": "claude-3.5-sonnet",
  "last_execution": null,
  "started_at": "2025-11-14T00:00:00Z",
  "estimated_completion": "2025-11-30T00:00:00Z",
  "validation_results": {},
  "metadata": {
    "repository": "edugo-api-mobile",
    "technology_stack": "Go 1.21+, Gin, GORM, PostgreSQL 15+, MongoDB 7.0+",
    "architecture": "Clean Architecture",
    "priority": "P0 - CRITICAL"
  }
}
```

#### TRACKING_SYSTEM.md
**Contenido requerido:**
- Reglas de ejecución desatendida
- Cómo continuar desde interrupciones
- Manejo de errores y reintentos
- Actualización de PROGRESS.json
- Formato de commits y PRs

---

## 🚀 INSTRUCCIONES DE EJECUCIÓN

### Para Claude en Nueva Sesión

1. **Leer contexto:**
   - Leer `/Users/jhoanmedina/source/EduGo/Analisys/CLAUDE.md`
   - Leer `/Users/jhoanmedina/source/EduGo/Analisys/docs/ESTADO_PROYECTO.md`
   - Leer este megaprompt completo

2. **Verificar archivos existentes:**
   ```bash
   ls -R /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/
   ```

3. **Generar archivos faltantes en orden:**
   - Completar Sprint-01 (4 archivos)
   - Crear Sprint-02 (5 archivos)
   - Crear Sprint-03 (5 archivos)
   - Crear Sprint-04 (5 archivos)
   - Crear Sprint-05 (5 archivos)
   - Crear Sprint-06 (5 archivos)
   - Crear 04-Testing/ (3 archivos)
   - Crear 05-Deployment/ (3 archivos)
   - Crear PROGRESS.json y TRACKING_SYSTEM.md

4. **Validar completitud:**
   - Total archivos: 8 (Requirements) + 4 (Design) + 30 (Sprints) + 3 (Testing) + 3 (Deployment) + 2 (Tracking) = 50 archivos
   - Verificar que TODOS existen
   - Verificar que NO hay ambigüedades en TASKS.md
   - Verificar que TODAS las preguntas tienen defaults

5. **Actualizar PROGRESS.json:**
   - Marcar spec-01 como "completed"
   - Actualizar métricas finales

---

## ⚠️ REGLAS CRÍTICAS

### NUNCA Hacer:
- ❌ Usar placeholders como "implementar según necesidad"
- ❌ Dejar decisiones sin default
- ❌ Omitir comandos de validación
- ❌ Crear tareas ambiguas
- ❌ Olvidar rutas absolutas de archivos

### SIEMPRE Hacer:
- ✅ Rutas absolutas en TASKS.md
- ✅ Comandos exactos y ejecutables
- ✅ Defaults explícitos en QUESTIONS.md
- ✅ Criterios medibles en VALIDATION.md
- ✅ Consistencia con archivos ya generados

---

## 📚 REFERENCIAS CLAVE

### Documentos Ya Generados (Usar como Referencia)
- `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/01-Requirements/PRD.md`
- `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/02-Design/ARCHITECTURE.md`
- `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/02-Design/DATA_MODEL.md`

### Documentación Original (Para Contexto)
- `/Users/jhoanmedina/source/EduGo/Analisys/docs/roadmap/PLAN_IMPLEMENTACION.md`
- `/Users/jhoanmedina/source/EduGo/Analisys/docs/analisis/GAP_ANALYSIS.md`
- `/Users/jhoanmedina/source/EduGo/Analisys/docs/historias_usuario/api_mobile/evaluacion/HU_MOB_EVA_01_realizar_quiz.md`

### Patrón de Estandarización
- `/Users/jhoanmedina/source/EduGo/Analisys/PROMPT_ANALISIS_ESTANDARIZADO.md`

---

## 🎯 ÉXITO DEFINIDO

spec-01-evaluaciones estará **100% COMPLETO** cuando:
- [ ] 50 archivos totales generados
- [ ] 0 ambigüedades en TASKS.md
- [ ] 100% de preguntas con defaults
- [ ] Todos los comandos ejecutables
- [ ] PROGRESS.json actualizado
- [ ] TRACKING_SYSTEM.md funcional
- [ ] Documentación sin placeholders

---

## 📋 CHECKLIST FINAL

Antes de considerar spec-01 completo, verificar:
- [ ] 4 archivos en 01-Requirements/
- [ ] 4 archivos en 02-Design/
- [ ] 30 archivos en 03-Sprints/ (6 sprints × 5 archivos)
- [ ] 3 archivos en 04-Testing/
- [ ] 3 archivos en 05-Deployment/
- [ ] 2 archivos en raíz (PROGRESS.json, TRACKING_SYSTEM.md)
- [ ] Total: 50 archivos ✅
- [ ] Sin TODOs ni placeholders
- [ ] Sin "implementar según necesidad"
- [ ] Todas las decisiones con defaults
- [ ] Todos los comandos ejecutables

---

**Generado con:** Claude Code  
**Tokens usados:** ~130K  
**Progreso actual:** 75%  
**Objetivo:** 100%  
**Próxima sesión:** Generar 33 archivos restantes

---

## 🔄 PROMPT PARA SIGUIENTE SESIÓN

```
Hola Claude, necesito que continúes el trabajo de análisis estandarizado del proyecto EduGo.

Lee primero:
1. /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/MEGAPROMPT_CONTINUACION.md (este archivo completo)
2. /Users/jhoanmedina/source/EduGo/Analisys/CLAUDE.md (contexto del proyecto)

Tarea: Completar spec-01-evaluaciones al 100% generando los 33 archivos faltantes siguiendo EXACTAMENTE las especificaciones del megaprompt.

Comienza generando los archivos de Sprint-01 faltantes (TASKS.md, DEPENDENCIES.md, QUESTIONS.md, VALIDATION.md) y luego continúa con Sprint-02 a Sprint-06.

Usa el patrón y estilo de los archivos ya generados en 01-Requirements/ y 02-Design/ como referencia.

NO uses placeholders. TODO debe ser ejecutable. TODAS las decisiones deben tener defaults.

Confirma que entiendes la tarea antes de comenzar.
```
