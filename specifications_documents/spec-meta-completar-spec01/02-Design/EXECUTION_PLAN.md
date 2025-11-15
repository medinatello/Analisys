# Plan de Ejecución
# Meta-Proyecto: Completar spec-01-evaluaciones

**Versión:** 1.0.0  
**Fecha:** 14 de Noviembre, 2025  
**Estimación Total:** 4-6 horas (sesión única) o 2-3 sesiones

---

## 1. OVERVIEW DEL PLAN

### Objetivo
Generar 33 archivos faltantes para completar spec-01-evaluaciones al 100%, siguiendo metodología estandarizada.

### Enfoque
**Ejecución controlada por fases**, con validación después de cada fase y capacidad de continuar en múltiples sesiones.

### Estado Actual
- ✅ **Completado:** 17 archivos (34%)
- ⏳ **Pendiente:** 33 archivos (66%)
- 🎯 **Objetivo:** 50 archivos (100%)

---

## 2. FASES DE EJECUCIÓN

```
FASE 0: Preparación (15min)
  └─> Crear estructura de tracking
  └─> Inicializar PROGRESS.json

FASE 1: Sprint-02 Dominio (45min)
  ├─> TASK-1.1: README.md
  ├─> TASK-1.2: TASKS.md (más largo, ~5000 palabras)
  ├─> TASK-1.3: DEPENDENCIES.md
  ├─> TASK-1.4: QUESTIONS.md
  └─> TASK-1.5: VALIDATION.md

FASE 2: Sprint-03 Repositorios (45min)
  ├─> TASK-2.1 a TASK-2.5 (misma estructura)

FASE 3: Sprint-04 Services/API (50min)
  ├─> TASK-3.1 a TASK-3.5 (más complejo)

FASE 4: Sprint-05 Testing (45min)
  ├─> TASK-4.1 a TASK-4.5

FASE 5: Sprint-06 CI/CD (40min)
  ├─> TASK-5.1 a TASK-5.5

FASE 6: Documentación Testing (35min)
  ├─> TASK-6.1: TEST_STRATEGY.md
  ├─> TASK-6.2: TEST_CASES.md
  └─> TASK-6.3: COVERAGE_REPORT.md

FASE 7: Documentación Deployment (35min)
  ├─> TASK-7.1: DEPLOYMENT_GUIDE.md
  ├─> TASK-7.2: INFRASTRUCTURE.md
  └─> TASK-7.3: MONITORING.md

FASE 8: Sistema de Tracking (20min)
  ├─> TASK-8.1: PROGRESS.json (actualización final)
  └─> TASK-8.2: TRACKING_SYSTEM.md

FASE 9: Validación Final (30min)
  ├─> Ejecutar script de validación
  ├─> Review manual de 5 archivos aleatorios
  └─> Generar reporte final
```

---

## 3. FASE 0: PREPARACIÓN

### Duración: 15 minutos

### TASK-0.1: Crear Estructura de Directorios
```bash
# Crear carpetas faltantes
cd /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones

mkdir -p 03-Sprints/Sprint-02-Dominio
mkdir -p 03-Sprints/Sprint-03-Repositorios
mkdir -p 03-Sprints/Sprint-04-Services-API
mkdir -p 03-Sprints/Sprint-05-Testing
mkdir -p 03-Sprints/Sprint-06-CI-CD
mkdir -p 04-Testing
mkdir -p 05-Deployment

echo "✓ Estructura de directorios creada"
```

### TASK-0.2: Inicializar PROGRESS.json
```bash
# Crear PROGRESS.json inicial
cat > /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/PROGRESS.json << 'EOF'
{
  "project": "spec-01-evaluaciones",
  "project_name": "Sistema de Evaluaciones - EduGo",
  "version": "1.0.0",
  "total_sprints": 6,
  "total_files": 50,
  "files_completed": 17,
  "files_remaining": 33,
  "current_phase": "Fase-0-Preparacion",
  "current_sprint": null,
  "current_task": "TASK-0.1",
  "completed_sprints": ["Sprint-01"],
  "completed_files": [
    "01-Requirements/PRD.md",
    "01-Requirements/FUNCTIONAL_SPECS.md",
    "01-Requirements/TECHNICAL_SPECS.md",
    "01-Requirements/ACCEPTANCE_CRITERIA.md",
    "02-Design/ARCHITECTURE.md",
    "02-Design/DATA_MODEL.md",
    "02-Design/API_CONTRACTS.md",
    "02-Design/SECURITY_DESIGN.md",
    "03-Sprints/Sprint-01-Schema-BD/README.md",
    "03-Sprints/Sprint-01-Schema-BD/TASKS.md",
    "03-Sprints/Sprint-01-Schema-BD/DEPENDENCIES.md",
    "03-Sprints/Sprint-01-Schema-BD/QUESTIONS.md",
    "03-Sprints/Sprint-01-Schema-BD/VALIDATION.md"
  ],
  "sprint_status": {
    "Sprint-01": "completed",
    "Sprint-02": "pending",
    "Sprint-03": "pending",
    "Sprint-04": "pending",
    "Sprint-05": "pending",
    "Sprint-06": "pending"
  },
  "phase_status": {
    "Fase-0-Preparacion": "in_progress",
    "Fase-1-Sprint02": "pending",
    "Fase-2-Sprint03": "pending",
    "Fase-3-Sprint04": "pending",
    "Fase-4-Sprint05": "pending",
    "Fase-5-Sprint06": "pending",
    "Fase-6-Testing": "pending",
    "Fase-7-Deployment": "pending",
    "Fase-8-Tracking": "pending",
    "Fase-9-Validation": "pending"
  },
  "execution_mode": "controlled",
  "ai_executor": "claude-3.5-sonnet",
  "last_execution": null,
  "started_at": "2025-11-14T00:00:00Z",
  "estimated_completion": null,
  "validation_results": {},
  "metadata": {
    "repository": "edugo-api-mobile",
    "technology_stack": "Go 1.21+, Gin, GORM, PostgreSQL, MongoDB",
    "architecture": "Clean Architecture",
    "priority": "P0 - CRITICAL"
  }
}
EOF

echo "✓ PROGRESS.json inicializado"
```

### Criterios de Éxito Fase 0
- [ ] Directorios creados (6 carpetas de sprints + 2 de docs)
- [ ] PROGRESS.json existe y es JSON válido
- [ ] Commit realizado

```bash
# Validar
jq . PROGRESS.json
git add .
git commit -m "docs: inicializar estructura para completar spec-01 (Fase 0)"
```

---

## 4. FASE 1: SPRINT-02 DOMINIO

### Duración: 45 minutos  
### Archivos a generar: 5

### TASK-1.1: Generar README.md de Sprint-02
**Estimación:** 5 minutos  
**Ruta:** `03-Sprints/Sprint-02-Dominio/README.md`  
**Contenido:**
- Objetivo del sprint (capa de dominio)
- Resumen de tareas (3 entities, 5 value objects, 3 repos interfaces)
- Comandos rápidos de Go (go test, go run, etc.)
- Referencias a otros archivos del sprint

**Validación:**
```bash
wc -w 03-Sprints/Sprint-02-Dominio/README.md
# Esperado: >500 palabras
```

### TASK-1.2: Generar TASKS.md de Sprint-02
**Estimación:** 20 minutos (archivo más largo)  
**Ruta:** `03-Sprints/Sprint-02-Dominio/TASKS.md`  
**Contenido:**
- TASK-02-001: Crear Entity Assessment
  - Código Go exacto con struct, campos, métodos
  - Ruta absoluta: `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/domain/entities/assessment.go`
  - Validaciones: NewAssessment(), Validate(), CanAttempt()
- TASK-02-002: Crear Entity Attempt
- TASK-02-003: Crear Entity Answer
- TASK-02-004: Crear Value Objects (Score, AssessmentID, etc.)
- TASK-02-005: Crear Repository Interfaces
- TASK-02-006: Tests Unitarios >90% coverage

**Validación:**
```bash
wc -w 03-Sprints/Sprint-02-Dominio/TASKS.md
# Esperado: >5000 palabras

grep -c "TASK-02-" 03-Sprints/Sprint-02-Dominio/TASKS.md
# Esperado: 6 tareas

grep -c "```go" 03-Sprints/Sprint-02-Dominio/TASKS.md
# Esperado: >15 bloques de código Go
```

### TASK-1.3: Generar DEPENDENCIES.md de Sprint-02
**Estimación:** 7 minutos  
**Ruta:** `03-Sprints/Sprint-02-Dominio/DEPENDENCIES.md`  
**Contenido:**
- Go 1.21+ instalado
- Sprint-01 completado (schema PostgreSQL)
- Packages: testify v1.8.4
- Comandos de instalación exactos
- Script de verificación de dependencias

**Validación:**
```bash
grep -c "go get" 03-Sprints/Sprint-02-Dominio/DEPENDENCIES.md
# Esperado: >3 comandos go get
```

### TASK-1.4: Generar QUESTIONS.md de Sprint-02
**Estimación:** 10 minutos  
**Ruta:** `03-Sprints/Sprint-02-Dominio/QUESTIONS.md`  
**Contenido:**
- Q001: ¿Pointers o valores en entities? → Default: Pointers
- Q002: ¿Business rules en entities o services? → Default: Entities (DDD)
- Q003: ¿time.Time o int64? → Default: time.Time
- Q004: ¿Validar en constructor? → Default: Sí (fail-fast)
- Q005: ¿Errors custom? → Default: Sí (ErrInvalidScore, etc.)

**Validación:**
```bash
num_q=$(grep -c "^## Q[0-9]*:" 03-Sprints/Sprint-02-Dominio/QUESTIONS.md)
num_d=$(grep -c "Decisión por Defecto:" 03-Sprints/Sprint-02-Dominio/QUESTIONS.md)
if [ $num_q -eq $num_d ]; then echo "✓ OK"; else echo "✗ FAIL"; fi
```

### TASK-1.5: Generar VALIDATION.md de Sprint-02
**Estimación:** 8 minutos  
**Ruta:** `03-Sprints/Sprint-02-Dominio/VALIDATION.md`  
**Contenido:**
- Pre-validación (go mod tidy, git status)
- Tests unitarios (go test ./internal/domain/... -v)
- Coverage (>90%)
- Linting (golangci-lint run)
- Build (go build)
- Criterios de éxito globales
- Rollback (git checkout, git branch -D)

**Validación:**
```bash
grep -c "```bash" 03-Sprints/Sprint-02-Dominio/VALIDATION.md
# Esperado: >10 bloques bash
```

### Criterios de Éxito Fase 1
- [ ] 5 archivos generados en Sprint-02-Dominio/
- [ ] TASKS.md >5000 palabras
- [ ] QUESTIONS.md con 5+ preguntas con defaults
- [ ] 0 placeholders en ningún archivo
- [ ] PROGRESS.json actualizado

```bash
# Actualizar PROGRESS.json
jq '.files_completed = 22 | .current_phase = "Fase-2-Sprint03" | .sprint_status."Sprint-02" = "completed" | .phase_status."Fase-1-Sprint02" = "completed"' PROGRESS.json > tmp.json
mv tmp.json PROGRESS.json

# Commit
git add 03-Sprints/Sprint-02-Dominio/
git add PROGRESS.json
git commit -m "docs: completar Sprint-02-Dominio (5 archivos generados, Fase 1)"
```

---

## 5. FASE 2-5: SPRINTS 03-06

### Patrón de Ejecución (Repetir para cada sprint)

Cada sprint sigue el mismo patrón de 5 tareas:

**Para Sprint-03 (Repositorios):**
- TASK-2.1: README.md (5min)
- TASK-2.2: TASKS.md (20min) - Tareas: PostgresAssessmentRepository, PostgresAttemptRepository, MongoQuestionRepository, Tests integración con testcontainers
- TASK-2.3: DEPENDENCIES.md (7min) - GORM, MongoDB driver, testcontainers
- TASK-2.4: QUESTIONS.md (10min) - ¿GORM o SQL puro?, ¿Transacciones?, ¿Testcontainers o mocks?
- TASK-2.5: VALIDATION.md (8min) - Tests de integración

**Para Sprint-04 (Services/API):**
- TASK-3.1: README.md (5min)
- TASK-3.2: TASKS.md (25min) - AssessmentService, ScoringService, AssessmentHandler (4 endpoints), Middleware, Swagger, Tests E2E
- TASK-3.3: DEPENDENCIES.md (7min) - Gin, validator, swag
- TASK-3.4: QUESTIONS.md (12min) - ¿DTOs o entities?, ¿Validación con tags?, ¿Error handling?
- TASK-3.5: VALIDATION.md (8min) - Tests E2E

**Para Sprint-05 (Testing):**
- TASK-4.1: README.md (5min)
- TASK-4.2: TASKS.md (20min) - Tests unitarios >90%, integración, E2E, seguridad, performance
- TASK-4.3: DEPENDENCIES.md (7min) - Herramientas de testing
- TASK-4.4: QUESTIONS.md (10min) - ¿Cobertura?, ¿Mocks o stubs?
- TASK-4.5: VALIDATION.md (8min) - Coverage >80%

**Para Sprint-06 (CI/CD):**
- TASK-5.1: README.md (5min)
- TASK-5.2: TASKS.md (18min) - GitHub Actions, Linting, Tests en CI, Docker build
- TASK-5.3: DEPENDENCIES.md (7min) - GitHub Actions, Docker
- TASK-5.4: QUESTIONS.md (8min) - ¿Deployment strategy?, ¿Docker registry?
- TASK-5.5: VALIDATION.md (8min) - Pipeline verde

### Comando de Generación por Sprint
```bash
# Después de generar cada sprint, actualizar PROGRESS y commit
# Ejemplo para Sprint-03:
jq '.files_completed = 27 | .sprint_status."Sprint-03" = "completed" | .phase_status."Fase-2-Sprint03" = "completed"' PROGRESS.json > tmp.json
mv tmp.json PROGRESS.json

git add 03-Sprints/Sprint-03-Repositorios/
git add PROGRESS.json
git commit -m "docs: completar Sprint-03-Repositorios (5 archivos generados, Fase 2)"
```

---

## 6. FASE 6: DOCUMENTACIÓN DE TESTING

### Duración: 35 minutos  
### Archivos a generar: 3

### TASK-6.1: Generar TEST_STRATEGY.md
**Estimación:** 15 minutos  
**Ruta:** `04-Testing/TEST_STRATEGY.md`  
**Contenido:**
- Pirámide de testing (diagrama ASCII, 70% unit, 20% integration, 10% E2E)
- Estrategia de coverage (>80% global, >90% dominio)
- Herramientas (Testify, Testcontainers, go test)
- Tipos de tests por capa
- CI/CD integration

**Validación:**
```bash
wc -w 04-Testing/TEST_STRATEGY.md
# Esperado: >3000 palabras

grep -i "pyramid\|pirámide" 04-Testing/TEST_STRATEGY.md
# Esperado: >0 líneas
```

### TASK-6.2: Generar TEST_CASES.md
**Estimación:** 15 minutos  
**Ruta:** `04-Testing/TEST_CASES.md`  
**Contenido:**
- Casos por endpoint (GET /assessment, POST /attempt, etc.)
- Mínimo 5 casos por endpoint (20+ casos totales)
- Tests de seguridad (respuestas correctas nunca expuestas)
- Tests de performance (<2s p95)
- Input/output esperado para cada caso

**Validación:**
```bash
grep -c "^TC-[0-9]*:" 04-Testing/TEST_CASES.md
# Esperado: >=20 casos de test
```

### TASK-6.3: Generar COVERAGE_REPORT.md
**Estimación:** 10 minutos  
**Ruta:** `04-Testing/COVERAGE_REPORT.md`  
**Contenido:**
- Template de reporte (tabla coverage por package)
- Coverage por capa (Domain, Application, Infrastructure)
- Gaps de coverage
- Plan de mejora
- Comandos (go test -cover, HTML report)

**Validación:**
```bash
wc -w 04-Testing/COVERAGE_REPORT.md
# Esperado: >1500 palabras
```

### Criterios de Éxito Fase 6
- [ ] 3 archivos generados en 04-Testing/
- [ ] TEST_CASES.md con >=20 casos de test
- [ ] 0 placeholders
- [ ] PROGRESS.json actualizado

```bash
jq '.files_completed = 45 | .phase_status."Fase-6-Testing" = "completed"' PROGRESS.json > tmp.json
mv tmp.json PROGRESS.json

git add 04-Testing/
git add PROGRESS.json
git commit -m "docs: completar documentación de Testing (3 archivos generados, Fase 6)"
```

---

## 7. FASE 7: DOCUMENTACIÓN DE DEPLOYMENT

### Duración: 35 minutos  
### Archivos a generar: 3

### TASK-7.1: Generar DEPLOYMENT_GUIDE.md
**Estimación:** 15 minutos  
**Ruta:** `05-Deployment/DEPLOYMENT_GUIDE.md`  
**Contenido:**
- Pre-requisitos (PostgreSQL 15+, MongoDB 7.0+)
- Pasos de deployment (migraciones, build, deploy, health checks)
- Migraciones de BD (ejecutar 06_assessments.sql)
- Health checks (endpoint /health)
- Rollback procedure

**Validación:**
```bash
grep -c "Paso [0-9]*:" 05-Deployment/DEPLOYMENT_GUIDE.md
# Esperado: >=5 pasos
```

### TASK-7.2: Generar INFRASTRUCTURE.md
**Estimación:** 12 minutos  
**Ruta:** `05-Deployment/INFRASTRUCTURE.md`  
**Contenido:**
- Arquitectura de infraestructura (diagrama ASCII)
- Docker Compose setup (PostgreSQL, MongoDB, API)
- Escalado horizontal (Post-MVP)
- Backups (pg_dump, mongodump)

**Validación:**
```bash
grep -i "docker-compose\|docker compose" 05-Deployment/INFRASTRUCTURE.md
# Esperado: >0 líneas
```

### TASK-7.3: Generar MONITORING.md
**Estimación:** 12 minutos  
**Ruta:** `05-Deployment/MONITORING.md`  
**Contenido:**
- Métricas clave (latencia p95, throughput, error rate)
- Prometheus metrics (exponer /metrics)
- Alertas críticas (error rate >5%, latencia >2s)
- Logs estructurados (JSON, niveles DEBUG/INFO/WARN/ERROR)
- Dashboards (Grafana)

**Validación:**
```bash
for metric in "latency\|latencia" "throughput" "error rate"; do
    grep -qi "$metric" 05-Deployment/MONITORING.md && echo "✓ $metric" || echo "✗ $metric"
done
```

### Criterios de Éxito Fase 7
- [ ] 3 archivos generados en 05-Deployment/
- [ ] DEPLOYMENT_GUIDE.md con >=5 pasos
- [ ] MONITORING.md con métricas clave
- [ ] 0 placeholders
- [ ] PROGRESS.json actualizado

```bash
jq '.files_completed = 48 | .phase_status."Fase-7-Deployment" = "completed"' PROGRESS.json > tmp.json
mv tmp.json PROGRESS.json

git add 05-Deployment/
git add PROGRESS.json
git commit -m "docs: completar documentación de Deployment (3 archivos generados, Fase 7)"
```

---

## 8. FASE 8: SISTEMA DE TRACKING

### Duración: 20 minutos  
### Archivos a generar: 2

### TASK-8.1: Actualizar PROGRESS.json (Final)
**Estimación:** 5 minutos  
**Ruta:** `PROGRESS.json`  
**Contenido:**
- Actualizar files_completed = 50
- Actualizar todos los sprint_status = "completed"
- Agregar todos los archivos a completed_files
- Actualizar phase_status."Fase-8-Tracking" = "completed"
- Agregar timestamp de completion

**Validación:**
```bash
jq -e '.files_completed == 50 and .files_remaining == 0' PROGRESS.json
# Esperado: true
```

### TASK-8.2: Generar TRACKING_SYSTEM.md
**Estimación:** 15 minutos  
**Ruta:** `TRACKING_SYSTEM.md`  
**Contenido:**
- Propósito del sistema de tracking
- Reglas de ejecución (leer PROGRESS.json al inicio, actualizar después de cada archivo)
- Cómo continuar desde interrupción (leer current_phase, current_task)
- Manejo de errores (marcar archivos fallidos)
- Formato de commits (mensajes descriptivos)

**Validación:**
```bash
wc -w TRACKING_SYSTEM.md
# Esperado: >2000 palabras

for keyword in "Propósito\|Purpose" "Reglas\|Rules" "Continuar\|Resume"; do
    grep -qi "$keyword" TRACKING_SYSTEM.md && echo "✓ $keyword" || echo "✗ $keyword"
done
```

### Criterios de Éxito Fase 8
- [ ] PROGRESS.json con files_completed = 50
- [ ] TRACKING_SYSTEM.md >2000 palabras
- [ ] 0 placeholders
- [ ] Commit final

```bash
jq '.files_completed = 50 | .files_remaining = 0 | .phase_status."Fase-8-Tracking" = "completed"' PROGRESS.json > tmp.json
mv tmp.json PROGRESS.json

git add PROGRESS.json TRACKING_SYSTEM.md
git commit -m "docs: completar sistema de tracking (2 archivos generados, Fase 8)"
```

---

## 9. FASE 9: VALIDACIÓN FINAL

### Duración: 30 minutos  
### Objetivo: Verificar completitud al 100%

### TASK-9.1: Ejecutar Script de Validación
**Estimación:** 10 minutos

```bash
# Ejecutar script de validación completo (de ACCEPTANCE_CRITERIA.md)
cd /Users/jhoanmedina/source/EduGo/Analisys/specifications_documents/spec-meta-completar-spec01/01-Requirements

# Copiar script a spec-01
cp validate_all_criteria.sh /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/

cd /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones

# Ejecutar
bash validate_all_criteria.sh
```

**Criterios de éxito:**
- Todos los tests del script pasan
- Output: "✅ PASSED" para todos los criterios críticos

### TASK-9.2: Review Manual de Archivos
**Estimación:** 15 minutos

Revisar manualmente 5 archivos aleatorios:
```bash
# Seleccionar 5 archivos aleatorios
find . -name "*.md" -type f | shuf -n 5

# Para cada archivo:
# 1. Verificar que no tiene placeholders
# 2. Verificar que comandos son ejecutables (copy-paste 3 comandos)
# 3. Verificar formato consistente
```

### TASK-9.3: Generar Reporte Final
**Estimación:** 5 minutos

```bash
# Crear reporte final
cat > /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/COMPLETION_REPORT.md << 'EOF'
# Reporte de Completitud - spec-01-evaluaciones

**Fecha:** $(date +%Y-%m-%d)  
**Ejecutor:** Claude Code

## Resultados

- ✅ Archivos generados: 50/50 (100%)
- ✅ Placeholders: 0
- ✅ PROGRESS.json válido: Sí
- ✅ Todos los sprints completados: 6/6

## Métricas

- **Total archivos:** 50
- **Total palabras:** ~85,000
- **Tiempo total:** [registrar tiempo real]
- **Commits:** [contar commits]

## Validación

- ✅ Script de validación: PASSED
- ✅ Review manual: PASSED (5/5 archivos)

## Estado Final

**spec-01-evaluaciones: 100% COMPLETO ✅**
EOF

echo "✓ Reporte final generado"
```

### Criterios de Éxito Fase 9
- [ ] Script de validación completo ejecutado exitosamente
- [ ] Review manual de 5 archivos aprobada
- [ ] Reporte final generado
- [ ] PROGRESS.json marca fase-9 como completed
- [ ] Commit final

```bash
jq '.phase_status."Fase-9-Validation" = "completed" | .estimated_completion = now | .completion_percentage = 100' PROGRESS.json > tmp.json
mv tmp.json PROGRESS.json

git add .
git commit -m "docs: validación final completada - spec-01 al 100% (Fase 9)"
```

---

## 10. PUNTOS DE CONTROL Y CONTINUACIÓN

### Cómo Continuar en Múltiples Sesiones

Si la sesión se interrumpe, **SIEMPRE** leer PROGRESS.json al inicio:

```bash
# Leer estado actual
cd /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones

current_phase=$(jq -r '.current_phase' PROGRESS.json)
files_completed=$(jq -r '.files_completed' PROGRESS.json)

echo "Estado actual:"
echo "  Fase: $current_phase"
echo "  Archivos completados: $files_completed/50"

# Determinar próxima tarea
next_phase=$(jq -r '.phase_status | to_entries[] | select(.value == "pending") | .key' PROGRESS.json | head -1)

echo "Próxima fase a ejecutar: $next_phase"
```

### Checkpoints de Commit

Hacer commit **después de cada fase completa**:

- ✅ Fase 0 → Commit "Preparación"
- ✅ Fase 1 → Commit "Sprint-02 completo"
- ✅ Fase 2 → Commit "Sprint-03 completo"
- ✅ Fase 3 → Commit "Sprint-04 completo"
- ✅ Fase 4 → Commit "Sprint-05 completo"
- ✅ Fase 5 → Commit "Sprint-06 completo"
- ✅ Fase 6 → Commit "Testing docs completas"
- ✅ Fase 7 → Commit "Deployment docs completas"
- ✅ Fase 8 → Commit "Tracking system completo"
- ✅ Fase 9 → Commit "Validación final"

---

## 11. ESTIMACIONES Y CRONOGRAMA

### Estimación por Fase

| Fase | Duración | Archivos | Palabras | Dificultad |
|------|----------|----------|----------|------------|
| 0 - Preparación | 15min | 1 | 500 | Baja |
| 1 - Sprint-02 | 45min | 5 | ~12,000 | Media |
| 2 - Sprint-03 | 45min | 5 | ~12,000 | Media |
| 3 - Sprint-04 | 50min | 5 | ~13,000 | Alta |
| 4 - Sprint-05 | 45min | 5 | ~12,000 | Media |
| 5 - Sprint-06 | 40min | 5 | ~10,000 | Media |
| 6 - Testing | 35min | 3 | ~8,500 | Media |
| 7 - Deployment | 35min | 3 | ~7,500 | Media |
| 8 - Tracking | 20min | 2 | ~2,500 | Baja |
| 9 - Validación | 30min | 1 | ~1,000 | Media |
| **TOTAL** | **5h 20min** | **35** | **~79,000** | **Media-Alta** |

### Cronograma en Sesión Única (Optimista)
```
09:00 - 09:15  Fase 0 (Preparación)
09:15 - 10:00  Fase 1 (Sprint-02)
10:00 - 10:45  Fase 2 (Sprint-03)
10:45 - 11:00  BREAK
11:00 - 11:50  Fase 3 (Sprint-04)
11:50 - 12:35  Fase 4 (Sprint-05)
12:35 - 13:00  LUNCH BREAK
13:00 - 13:40  Fase 5 (Sprint-06)
13:40 - 14:15  Fase 6 (Testing)
14:15 - 14:50  Fase 7 (Deployment)
14:50 - 15:10  Fase 8 (Tracking)
15:10 - 15:40  Fase 9 (Validación)
15:40 - 16:00  Buffer/Revisión
```

### Cronograma en Múltiples Sesiones (Realista)

**Sesión 1 (2h):** Fase 0-2 (Prep + Sprint-02 + Sprint-03)  
**Sesión 2 (2h):** Fase 3-5 (Sprint-04 + Sprint-05 + Sprint-06)  
**Sesión 3 (1.5h):** Fase 6-9 (Testing + Deployment + Tracking + Validación)

---

## 12. RESUMEN EJECUTIVO

### Input
- **Archivos existentes:** 17
- **Archivos faltantes:** 33
- **Total objetivo:** 50

### Proceso
- **9 fases secuenciales**
- **35 tareas atómicas**
- **Commits frecuentes** (cada fase)
- **Validación continua** (PROGRESS.json)

### Output
- **50 archivos completos**
- **0 placeholders**
- **100% decisiones con defaults**
- **Todos los comandos ejecutables**
- **PROGRESS.json al 100%**

### Siguiente Paso
**Ejecutar Fase 0** y continuar secuencialmente hasta Fase 9.

---

**Generado con:** Claude Code  
**Estado:** Plan de Ejecución Completo  
**Listo para:** Iniciar ejecución controlada
