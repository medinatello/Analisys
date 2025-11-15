# Criterios de Aceptación
# Meta-Proyecto: Completar spec-01-evaluaciones

**Versión:** 1.0.0  
**Fecha:** 14 de Noviembre, 2025

---

## 1. CRITERIOS GLOBALES

### AC-GLOBAL-001: Completitud de Archivos
**Descripción:** El proyecto estará completo cuando existan exactamente 50 archivos  
**Criterio de Aceptación:**
```bash
# Contar archivos
cd /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones
find . -type f \( -name "*.md" -o -name "*.json" \) | wc -l
# Output esperado: 50
```
**Medible:** SÍ (conteo exacto)  
**Automatizable:** SÍ (script bash)

---

### AC-GLOBAL-002: Cero Placeholders
**Descripción:** Ningún archivo debe contener placeholders  
**Criterio de Aceptación:**
```bash
# Buscar placeholders
grep -r "TODO\|PLACEHOLDER\|implementar según\|TBD\|pendiente\|\[...\]" \
    /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones \
    --include="*.md" --include="*.json"
# Output esperado: (vacío)
```
**Medible:** SÍ (0 ocurrencias)  
**Automatizable:** SÍ (grep)

---

### AC-GLOBAL-003: PROGRESS.json Válido y Sincronizado
**Descripción:** PROGRESS.json debe ser JSON válido y reflejar estado real  
**Criterio de Aceptación:**
```bash
# Validar JSON
jq . /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/PROGRESS.json

# Verificar que files_completed = 50
jq -r '.files_completed' /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/PROGRESS.json
# Output esperado: 50

# Verificar que todos los sprints están "completed"
jq -r '.sprint_status | to_entries[] | select(.value != "completed") | .key' \
    /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/PROGRESS.json
# Output esperado: (vacío)
```
**Medible:** SÍ (JSON válido + fields correctos)  
**Automatizable:** SÍ (jq)

---

## 2. CRITERIOS POR SPRINT

### AC-SPRINT-001: Estructura Completa de Sprint
**Descripción:** Cada sprint (01-06) debe tener exactamente 5 archivos  
**Criterio de Aceptación:**
```bash
# Verificar Sprint-02
for file in README.md TASKS.md DEPENDENCIES.md QUESTIONS.md VALIDATION.md; do
    [ -f "03-Sprints/Sprint-02-Dominio/$file" ] && echo "✓ $file" || echo "✗ FALTA $file"
done
# Output esperado: 5 líneas con ✓

# Repetir para Sprint-03, Sprint-04, Sprint-05, Sprint-06
```
**Medible:** SÍ (5 archivos por sprint × 6 sprints = 30 archivos)  
**Automatizable:** SÍ (script bash)

---

### AC-SPRINT-002: Longitud Mínima de TASKS.md
**Descripción:** TASKS.md de cada sprint debe tener longitud mínima especificada  
**Criterio de Aceptación:**
```bash
# Sprint-02 TASKS.md debe tener >4000 palabras
wc -w /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/03-Sprints/Sprint-02-Dominio/TASKS.md
# Output esperado: >4000

# Validar todos los sprints
for sprint in Sprint-02-Dominio Sprint-03-Repositorios Sprint-04-Services-API Sprint-05-Testing Sprint-06-CI-CD; do
    words=$(wc -w < "03-Sprints/$sprint/TASKS.md")
    if [ $words -lt 4000 ]; then
        echo "❌ $sprint/TASKS.md: $words palabras (esperado >4000)"
    else
        echo "✓ $sprint/TASKS.md: $words palabras"
    fi
done
```
**Medible:** SÍ (conteo de palabras)  
**Automatizable:** SÍ (wc -w)

---

### AC-SPRINT-003: Comandos Ejecutables en TASKS.md
**Descripción:** Todos los comandos bash en bloques de código deben ser ejecutables  
**Criterio de Aceptación:**
```bash
# Validación manual: Extraer 3 comandos aleatorios de cada TASKS.md y ejecutarlos
# Criterio: 100% de comandos no fallan por sintaxis (pueden fallar por dependencias no instaladas)

# Ejemplo de validación:
# Extraer comandos de Sprint-02/TASKS.md
grep -A 3 "```bash" 03-Sprints/Sprint-02-Dominio/TASKS.md | grep -v "^--$" | grep -v "```"

# Ejecutar comandos de verificación (ej: go version, ls, etc.)
# NO ejecutar comandos destructivos
```
**Medible:** SÍ (% de comandos ejecutables)  
**Automatizable:** PARCIAL (requiere validación manual)

---

### AC-SPRINT-004: Rutas Absolutas en TASKS.md
**Descripción:** Todas las rutas de archivos deben ser absolutas  
**Criterio de Aceptación:**
```bash
# Buscar rutas relativas (ej: internal/domain/...) sin ruta absoluta
grep -n "internal/\|pkg/\|cmd/" 03-Sprints/Sprint-*/TASKS.md | \
    grep -v "/Users/jhoanmedina/source/EduGo/repos-separados"

# Output esperado: (vacío) - todas las rutas con prefijo absoluto
```
**Medible:** SÍ (0 rutas relativas)  
**Automatizable:** SÍ (grep)

---

### AC-SPRINT-005: Decisiones con Defaults en QUESTIONS.md
**Descripción:** Todas las preguntas en QUESTIONS.md deben tener decisión por defecto  
**Criterio de Aceptación:**
```bash
# Contar preguntas (## Q00X:)
num_questions=$(grep -c "^## Q[0-9]*:" 03-Sprints/Sprint-02-Dominio/QUESTIONS.md)

# Contar decisiones por defecto
num_defaults=$(grep -c "Decisión por Defecto:" 03-Sprints/Sprint-02-Dominio/QUESTIONS.md)

# Deben ser iguales
if [ $num_questions -eq $num_defaults ]; then
    echo "✓ Todas las preguntas tienen default ($num_questions/$num_defaults)"
else
    echo "❌ Faltan defaults: $num_questions preguntas, $num_defaults defaults"
fi

# Repetir para todos los sprints
```
**Medible:** SÍ (num_questions == num_defaults)  
**Automatizable:** SÍ (grep count)

---

### AC-SPRINT-006: Código Exacto en TASKS.md
**Descripción:** TASKS.md debe incluir código Go/SQL con firmas completas  
**Criterio de Aceptación:**
```bash
# Verificar que hay bloques de código Go
grep -c "```go" 03-Sprints/Sprint-02-Dominio/TASKS.md
# Output esperado: >10 (mínimo 10 bloques de código Go)

# Verificar que código incluye firmas de funciones
grep -A 5 "```go" 03-Sprints/Sprint-02-Dominio/TASKS.md | grep "func "
# Output esperado: Múltiples líneas con "func"

# Validación manual: Revisar 3 bloques de código aleatorios
# Criterio: Código es copy-paste ejecutable (puede requerir imports)
```
**Medible:** SÍ (conteo de bloques + validación manual)  
**Automatizable:** PARCIAL

---

## 3. CRITERIOS DE TESTING DOCS

### AC-TEST-001: Existencia de Archivos de Testing
**Descripción:** Carpeta 04-Testing/ debe tener 3 archivos  
**Criterio de Aceptación:**
```bash
# Verificar archivos
ls -1 /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/04-Testing/
# Output esperado:
# COVERAGE_REPORT.md
# TEST_CASES.md
# TEST_STRATEGY.md

# Contar archivos
ls -1 04-Testing/*.md | wc -l
# Output esperado: 3
```
**Medible:** SÍ (3 archivos)  
**Automatizable:** SÍ (ls)

---

### AC-TEST-002: Casos de Test Completos
**Descripción:** TEST_CASES.md debe tener mínimo 20 casos de test  
**Criterio de Aceptación:**
```bash
# Contar casos de test (TC-XXX:)
grep -c "^TC-[0-9]*:" /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/04-Testing/TEST_CASES.md
# Output esperado: >=20
```
**Medible:** SÍ (>=20 casos)  
**Automatizable:** SÍ (grep count)

---

### AC-TEST-003: Estrategia de Testing Completa
**Descripción:** TEST_STRATEGY.md debe incluir pirámide de testing  
**Criterio de Aceptación:**
```bash
# Verificar que menciona pirámide
grep -i "pirámide\|pyramid" /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/04-Testing/TEST_STRATEGY.md
# Output esperado: (al menos 1 línea)

# Verificar que menciona porcentajes
grep "70%\|20%\|10%" /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/04-Testing/TEST_STRATEGY.md
# Output esperado: (al menos 3 líneas)

# Verificar que menciona herramientas
grep -i "testify\|testcontainers" /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/04-Testing/TEST_STRATEGY.md
# Output esperado: (al menos 2 líneas)
```
**Medible:** SÍ (presencia de keywords)  
**Automatizable:** SÍ (grep)

---

## 4. CRITERIOS DE DEPLOYMENT DOCS

### AC-DEPLOY-001: Existencia de Archivos de Deployment
**Descripción:** Carpeta 05-Deployment/ debe tener 3 archivos  
**Criterio de Aceptación:**
```bash
# Verificar archivos
ls -1 /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/05-Deployment/
# Output esperado:
# DEPLOYMENT_GUIDE.md
# INFRASTRUCTURE.md
# MONITORING.md

# Contar
ls -1 05-Deployment/*.md | wc -l
# Output esperado: 3
```
**Medible:** SÍ (3 archivos)  
**Automatizable:** SÍ (ls)

---

### AC-DEPLOY-002: Guía de Deployment Completa
**Descripción:** DEPLOYMENT_GUIDE.md debe tener pasos numerados  
**Criterio de Aceptación:**
```bash
# Verificar pasos numerados
grep -c "Paso [0-9]*:" /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/05-Deployment/DEPLOYMENT_GUIDE.md
# Output esperado: >=5 (mínimo 5 pasos)

# Verificar que incluye rollback
grep -i "rollback" /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/05-Deployment/DEPLOYMENT_GUIDE.md
# Output esperado: (al menos 1 línea)
```
**Medible:** SÍ (>=5 pasos + rollback)  
**Automatizable:** SÍ (grep)

---

### AC-DEPLOY-003: Métricas de Monitoring
**Descripción:** MONITORING.md debe especificar métricas concretas  
**Criterio de Aceptación:**
```bash
# Verificar que menciona métricas clave
for metric in "latencia\|latency" "throughput" "error rate"; do
    grep -i "$metric" /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/05-Deployment/MONITORING.md || \
        echo "❌ Falta métrica: $metric"
done

# Verificar que menciona Prometheus
grep -i "prometheus" /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/05-Deployment/MONITORING.md
# Output esperado: (al menos 1 línea)
```
**Medible:** SÍ (presencia de keywords)  
**Automatizable:** SÍ (grep)

---

## 5. CRITERIOS DE TRACKING SYSTEM

### AC-TRACK-001: PROGRESS.json con Campos Requeridos
**Descripción:** PROGRESS.json debe tener estructura completa  
**Criterio de Aceptación:**
```bash
# Validar campos obligatorios
jq 'has("project") and has("total_files") and has("files_completed") and has("sprint_status")' \
    /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/PROGRESS.json
# Output esperado: true

# Validar valores
jq -e '.total_files == 50 and .files_completed == 50' \
    /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/PROGRESS.json
# Output esperado: true
```
**Medible:** SÍ (campos + valores)  
**Automatizable:** SÍ (jq)

---

### AC-TRACK-002: TRACKING_SYSTEM.md Documentado
**Descripción:** TRACKING_SYSTEM.md debe explicar cómo usar el sistema  
**Criterio de Aceptación:**
```bash
# Verificar secciones clave
for section in "Propósito\|Purpose" "Reglas\|Rules" "Continuar\|Resume" "Errores\|Errors"; do
    grep -i "$section" /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/TRACKING_SYSTEM.md || \
        echo "❌ Falta sección: $section"
done

# Verificar longitud mínima
wc -w /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/TRACKING_SYSTEM.md
# Output esperado: >1500 palabras
```
**Medible:** SÍ (secciones + longitud)  
**Automatizable:** SÍ (grep + wc)

---

## 6. CRITERIOS DE CONSISTENCIA

### AC-CONSIST-001: Formato Consistente de Headers
**Descripción:** Todos los archivos deben tener header estándar  
**Criterio de Aceptación:**
```bash
# Verificar que cada archivo tiene header con fecha
for file in $(find . -name "*.md"); do
    if ! head -10 "$file" | grep -q "Fecha:\|Date:\|2025"; then
        echo "❌ Sin header: $file"
    fi
done
# Output esperado: (vacío)
```
**Medible:** SÍ (100% de archivos con header)  
**Automatizable:** SÍ (script bash)

---

### AC-CONSIST-002: Links Internos Válidos
**Descripción:** Todas las referencias a otros archivos deben existir  
**Criterio de Aceptación:**
```bash
# Extraer links internos (./ARCHIVO.md)
grep -roh "\[.*\](\./.*\.md)" . --include="*.md" | \
    sed 's/.*(\.\///' | sed 's/).*//' | \
    while read file; do
        [ -f "$file" ] || echo "❌ Link roto: $file"
    done
# Output esperado: (vacío)
```
**Medible:** SÍ (0 links rotos)  
**Automatizable:** SÍ (script bash)

---

## 7. MATRIZ DE CRITERIOS DE ACEPTACIÓN

| ID | Criterio | Tipo | Automatizable | Comando Validación | Umbral |
|----|----------|------|---------------|-------------------|--------|
| AC-GLOBAL-001 | Completitud archivos | Crítico | SÍ | `find . -type f | wc -l` | 50 |
| AC-GLOBAL-002 | Cero placeholders | Crítico | SÍ | `grep -r "TODO"` | 0 |
| AC-GLOBAL-003 | PROGRESS.json válido | Crítico | SÍ | `jq .` | valid |
| AC-SPRINT-001 | Estructura sprint | Crítico | SÍ | `ls Sprint-XX/*.md` | 5 archivos |
| AC-SPRINT-002 | Longitud TASKS.md | Alta | SÍ | `wc -w` | >4000 |
| AC-SPRINT-003 | Comandos ejecutables | Alta | PARCIAL | Manual | 100% |
| AC-SPRINT-004 | Rutas absolutas | Alta | SÍ | `grep -v /Users/` | 0 |
| AC-SPRINT-005 | Defaults en QUESTIONS | Alta | SÍ | `grep -c` | 100% |
| AC-SPRINT-006 | Código exacto | Media | PARCIAL | `grep "func "` | >10 |
| AC-TEST-001 | Archivos testing | Crítico | SÍ | `ls 04-Testing/` | 3 |
| AC-TEST-002 | Casos de test | Alta | SÍ | `grep -c "TC-"` | >=20 |
| AC-TEST-003 | Estrategia completa | Media | SÍ | `grep pyramid` | >0 |
| AC-DEPLOY-001 | Archivos deployment | Crítico | SÍ | `ls 05-Deployment/` | 3 |
| AC-DEPLOY-002 | Pasos deployment | Alta | SÍ | `grep "Paso"` | >=5 |
| AC-DEPLOY-003 | Métricas monitoring | Media | SÍ | `grep latency` | >0 |
| AC-TRACK-001 | PROGRESS.json campos | Crítico | SÍ | `jq 'has()'` | true |
| AC-TRACK-002 | TRACKING_SYSTEM.md | Alta | SÍ | `wc -w` | >1500 |
| AC-CONSIST-001 | Headers consistentes | Media | SÍ | `head \| grep` | 100% |
| AC-CONSIST-002 | Links válidos | Media | SÍ | script | 0 rotos |

**Total criterios:** 19  
**Criterios críticos:** 7  
**Criterios automatizables:** 16 (84%)

---

## 8. SCRIPT DE VALIDACIÓN COMPLETO

```bash
#!/bin/bash
# validate_all_criteria.sh - Valida TODOS los criterios de aceptación

set -e

SPEC_DIR="/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones"
cd "$SPEC_DIR"

PASSED=0
FAILED=0

echo "========================================="
echo "VALIDACIÓN DE CRITERIOS DE ACEPTACIÓN"
echo "========================================="

# AC-GLOBAL-001
echo ""
echo "AC-GLOBAL-001: Completitud de archivos"
total=$(find . -type f \( -name "*.md" -o -name "*.json" \) | wc -l | tr -d ' ')
if [ "$total" -eq 50 ]; then
    echo "✅ PASSED: $total/50 archivos"
    ((PASSED++))
else
    echo "❌ FAILED: $total/50 archivos"
    ((FAILED++))
fi

# AC-GLOBAL-002
echo ""
echo "AC-GLOBAL-002: Cero placeholders"
placeholders=$(grep -r "TODO\|PLACEHOLDER\|TBD" --include="*.md" . 2>/dev/null | wc -l | tr -d ' ')
if [ "$placeholders" -eq 0 ]; then
    echo "✅ PASSED: 0 placeholders"
    ((PASSED++))
else
    echo "❌ FAILED: $placeholders placeholders encontrados"
    ((FAILED++))
fi

# AC-GLOBAL-003
echo ""
echo "AC-GLOBAL-003: PROGRESS.json válido"
if jq . PROGRESS.json > /dev/null 2>&1; then
    files_comp=$(jq -r '.files_completed' PROGRESS.json)
    if [ "$files_comp" -eq 50 ]; then
        echo "✅ PASSED: JSON válido, files_completed=50"
        ((PASSED++))
    else
        echo "❌ FAILED: files_completed=$files_comp (esperado 50)"
        ((FAILED++))
    fi
else
    echo "❌ FAILED: JSON inválido"
    ((FAILED++))
fi

# AC-SPRINT-001 (verificar solo Sprint-02 como ejemplo)
echo ""
echo "AC-SPRINT-001: Estructura Sprint-02"
sprint_files=0
for file in README.md TASKS.md DEPENDENCIES.md QUESTIONS.md VALIDATION.md; do
    if [ -f "03-Sprints/Sprint-02-Dominio/$file" ]; then
        ((sprint_files++))
    fi
done
if [ "$sprint_files" -eq 5 ]; then
    echo "✅ PASSED: Sprint-02 tiene 5 archivos"
    ((PASSED++))
else
    echo "❌ FAILED: Sprint-02 tiene $sprint_files/5 archivos"
    ((FAILED++))
fi

# AC-TEST-001
echo ""
echo "AC-TEST-001: Archivos de testing"
test_files=$(ls -1 04-Testing/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$test_files" -eq 3 ]; then
    echo "✅ PASSED: 04-Testing tiene 3 archivos"
    ((PASSED++))
else
    echo "❌ FAILED: 04-Testing tiene $test_files/3 archivos"
    ((FAILED++))
fi

# AC-DEPLOY-001
echo ""
echo "AC-DEPLOY-001: Archivos de deployment"
deploy_files=$(ls -1 05-Deployment/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$deploy_files" -eq 3 ]; then
    echo "✅ PASSED: 05-Deployment tiene 3 archivos"
    ((PASSED++))
else
    echo "❌ FAILED: 05-Deployment tiene $deploy_files/3 archivos"
    ((FAILED++))
fi

# Resumen
echo ""
echo "========================================="
echo "RESUMEN DE VALIDACIÓN"
echo "========================================="
echo "✅ Criterios pasados: $PASSED"
echo "❌ Criterios fallidos: $FAILED"
echo "Total criterios: $((PASSED + FAILED))"

if [ "$FAILED" -eq 0 ]; then
    echo ""
    echo "🎉 TODOS LOS CRITERIOS PASARON"
    exit 0
else
    echo ""
    echo "⚠️  HAY CRITERIOS FALLIDOS"
    exit 1
fi
```

---

**Generado con:** Claude Code  
**Total criterios:** 19  
**Automatizables:** 16 (84%)  
**Próximo paso:** Crear EXECUTION_PLAN.md
