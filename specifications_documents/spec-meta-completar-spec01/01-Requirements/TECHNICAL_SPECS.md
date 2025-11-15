# Especificaciones Técnicas
# Meta-Proyecto: Completar spec-01-evaluaciones

**Versión:** 1.0.0  
**Fecha:** 14 de Noviembre, 2025

---

## 1. STACK TECNOLÓGICO

### Herramientas de Generación
- **Editor:** Claude Code (claude-3.5-sonnet)
- **Formato:** Markdown (GitHub Flavored Markdown)
- **Validación:** Manual + Scripts bash

### Herramientas de Validación
```bash
# Validar sintaxis Markdown
npx markdownlint-cli2 "**/*.md"

# Contar palabras
wc -w archivo.md

# Buscar placeholders
grep -r "TODO\|PLACEHOLDER\|implementar según" .

# Validar JSON
jq . PROGRESS.json

# Validar comandos bash (linting)
shellcheck script.sh
```

---

## 2. ARQUITECTURA DE ARCHIVOS

### Estructura de Directorios
```
AnalisisEstandarizado/spec-01-evaluaciones/
├── 01-Requirements/          # ✅ COMPLETO (4 archivos)
│   ├── PRD.md
│   ├── FUNCTIONAL_SPECS.md
│   ├── TECHNICAL_SPECS.md
│   └── ACCEPTANCE_CRITERIA.md
├── 02-Design/                # ✅ COMPLETO (4 archivos)
│   ├── ARCHITECTURE.md
│   ├── DATA_MODEL.md
│   ├── API_CONTRACTS.md
│   └── SECURITY_DESIGN.md
├── 03-Sprints/               # ⚠️ PARCIAL (1 de 6 sprints)
│   ├── Sprint-01-Schema-BD/  # ✅ COMPLETO (5 archivos)
│   ├── Sprint-02-Dominio/    # ⏳ GENERAR (5 archivos)
│   ├── Sprint-03-Repositorios/
│   ├── Sprint-04-Services-API/
│   ├── Sprint-05-Testing/
│   └── Sprint-06-CI-CD/
├── 04-Testing/               # ⏳ GENERAR (3 archivos)
├── 05-Deployment/            # ⏳ GENERAR (3 archivos)
├── PROGRESS.json             # ⏳ GENERAR
└── TRACKING_SYSTEM.md        # ⏳ GENERAR
```

---

## 3. PATRONES Y CONVENCIONES

### 3.1 Formato de Archivos TASKS.md

#### Template Estándar
```markdown
# Tareas del Sprint XX - [Nombre]

## Objetivo
[Descripción concisa del objetivo del sprint - 1-2 párrafos]

---

## Tareas

### TASK-XX-001: [Nombre Descriptivo]
**Tipo:** feature|fix|refactor|test|docs  
**Prioridad:** HIGH|MEDIUM|LOW  
**Estimación:** Xh  
**Asignado a:** @ai-executor

#### Descripción
[Descripción detallada de QUÉ hacer - mínimo 3 líneas]

#### Pasos de Implementación
1. [Paso 1 con ruta absoluta exacta]
2. Implementar con esta firma:
   \`\`\`go|sql|bash
   [Código exacto con nombres de funciones, parámetros, tipos]
   \`\`\`
3. [Pasos adicionales]

#### Criterios de Aceptación
- [ ] [Criterio medible 1]
- [ ] [Criterio medible 2]
- [ ] [Criterio medible N]

#### Comandos de Validación
\`\`\`bash
# [Comentario explicativo]
comando1 --flag value
comando2 | grep "expected"
\`\`\`

#### Dependencias
- Requiere: [TASK-XX-YYY | Sprint-XX | Herramienta X]
- Usa: [Tecnología/Package específico con versión]

#### Tiempo Estimado
Xh
```

#### Reglas de TASKS.md
1. **Rutas absolutas siempre:**
   - ✅ `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/domain/entities/assessment.go`
   - ❌ `internal/domain/entities/assessment.go`

2. **Código con firmas exactas:**
   - ✅ Incluir nombres de funciones, parámetros, tipos de retorno
   - ❌ "Implementar función de validación"

3. **Comandos ejecutables:**
   - ✅ `go test ./internal/domain/entities -v -run TestAssessment`
   - ❌ "Ejecutar tests apropiados"

4. **Sin placeholders:**
   - ❌ "implementar según necesidad"
   - ❌ "TODO: definir campos"
   - ✅ Código completo o defaults explícitos

---

### 3.2 Formato de Archivos DEPENDENCIES.md

#### Template Estándar
```markdown
# Dependencias del Sprint XX - [Nombre]

## Dependencias Técnicas Previas
- [ ] [Herramienta 1] versión X+ instalado
- [ ] [Servicio 1] corriendo
- [ ] [Sprint previo] completado

\`\`\`bash
# Verificar [herramienta]
comando --version
# Output esperado: [versión específica]
\`\`\`

## Dependencias de Código
- [ ] Package X instalado
- [ ] Migración Y ejecutada

\`\`\`bash
# Instalar dependencias
go get package@version
\`\`\`

## Variables de Entorno
\`\`\`bash
export VAR_NAME="value"
\`\`\`

## Verificación de Dependencias
[Script SQL/Bash ejecutable para verificar todo]
```

#### Reglas de DEPENDENCIES.md
1. **Comandos de verificación obligatorios**
2. **Versiones exactas (no "latest")**
3. **Output esperado documentado**

---

### 3.3 Formato de Archivos QUESTIONS.md

#### Template Estándar
```markdown
# Preguntas y Decisiones del Sprint XX

## Q001: [Título de la Pregunta]
**Contexto:** [Por qué surge esta pregunta - 2-3 líneas]

**Opciones:**

### 1. **Opción A:** [Nombre]
- **Pros:**
  - [Pro 1]
  - [Pro 2]
- **Contras:**
  - [Contra 1]
  - [Contra 2]

### 2. **Opción B:** [Nombre]
- **Pros:** [lista]
- **Contras:** [lista]

**Decisión por Defecto:** Opción A

**Justificación:** [Por qué elegimos A - 3-5 líneas]

**Implementación:**
\`\`\`language
[Código exacto para implementar Opción A]
\`\`\`
```

#### Reglas de QUESTIONS.md
1. **100% de preguntas con defaults (no "TBD")**
2. **Mínimo 2 opciones por pregunta**
3. **Código de implementación para opción elegida**
4. **Justificación técnica (no "porque sí")**

---

### 3.4 Formato de Archivos VALIDATION.md

#### Template Estándar
```markdown
# Validación del Sprint XX

## Pre-validación
\`\`\`bash
# Verificar estado
comando1
comando2
\`\`\`

## Checklist de Validación

### 1. [Categoría de Validación]
\`\`\`bash
# [Descripción]
comando_validacion
\`\`\`
**Criterio de éxito:** [Criterio medible]

### 2. [Siguiente categoría]
[...]

## Criterios de Éxito Globales
- [ ] [Criterio global 1]
- [ ] [Criterio global 2]

## Comandos de Rollback
\`\`\`bash
# Si falla, ejecutar:
comando_rollback
\`\`\`
```

#### Reglas de VALIDATION.md
1. **Criterios medibles (no "código de calidad")**
2. **Comandos de verificación ejecutables**
3. **Rollback procedure obligatorio**

---

### 3.5 Formato de Archivos README.md de Sprint

#### Template Estándar
```markdown
# Sprint XX: [Nombre del Sprint]
# Sistema de Evaluaciones - EduGo

**Duración:** X días  
**Objetivo:** [1 párrafo describiendo qué se implementa]

---

## 🎯 Objetivo del Sprint
[2-3 párrafos detallados]

## 📋 Tareas del Sprint
Ver archivo [TASKS.md](./TASKS.md)

**Resumen:**
- [Resumen de tareas principales]

## 🔗 Dependencias
Ver archivo [DEPENDENCIES.md](./DEPENDENCIES.md)

**Críticas:**
- [Dependencias más importantes]

## ❓ Decisiones y Preguntas
Ver archivo [QUESTIONS.md](./QUESTIONS.md)

**Decisiones clave:**
- [3-5 decisiones principales]

## ✅ Validación
Ver archivo [VALIDATION.md](./VALIDATION.md)

**Criterios de éxito:**
- [ ] [Criterio 1]
- [ ] [Criterio 2]

## 📊 Entregables
1. [Archivo 1 con ruta]
2. [Archivo 2 con ruta]

## 🚀 Comandos Rápidos
\`\`\`bash
# [Comando 1]
comando1

# [Comando 2]
comando2
\`\`\`
```

---

## 4. DECISIONES TÉCNICAS (ADRs)

### ADR-001: Usar Markdown GitHub Flavored
**Decisión:** Todos los docs en Markdown GFM  
**Justificación:** Compatible con GitHub, fácil de leer, soporta código

### ADR-002: Rutas Absolutas en TASKS.md
**Decisión:** Siempre usar rutas absolutas  
**Justificación:** Elimina ambigüedad, ejecutable desde cualquier directorio

### ADR-003: Código Exacto en TASKS.md
**Decisión:** Incluir firmas completas de funciones  
**Justificación:** Permite copy-paste directo, sin interpretación

### ADR-004: Decisiones con Defaults en QUESTIONS.md
**Decisión:** 100% de preguntas con defaults  
**Justificación:** Permite ejecución desatendida, sin bloqueadores

### ADR-005: PROGRESS.json como Fuente de Verdad
**Decisión:** PROGRESS.json actualizado después de cada archivo  
**Justificación:** Permite continuar en múltiples sesiones

---

## 5. VALIDACIÓN TÉCNICA

### 5.1 Script de Validación Global

```bash
#!/bin/bash
# validate_spec01.sh - Valida completitud de spec-01-evaluaciones

set -e

SPEC_DIR="/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones"

echo "=== VALIDACIÓN DE SPEC-01-EVALUACIONES ==="

# 1. Contar archivos totales
total_files=$(find "$SPEC_DIR" -type f -name "*.md" -o -name "*.json" | wc -l)
echo "✓ Archivos encontrados: $total_files (esperados: 50)"

if [ "$total_files" -lt 50 ]; then
    echo "❌ FALTA: Se esperan 50 archivos, encontrados $total_files"
    exit 1
fi

# 2. Buscar placeholders
echo ""
echo "=== BUSCANDO PLACEHOLDERS ==="
placeholders=$(grep -r "TODO\|PLACEHOLDER\|implementar según\|TBD" "$SPEC_DIR" --include="*.md" || true)
if [ -n "$placeholders" ]; then
    echo "❌ PLACEHOLDERS ENCONTRADOS:"
    echo "$placeholders"
    exit 1
else
    echo "✓ Sin placeholders"
fi

# 3. Validar PROGRESS.json
echo ""
echo "=== VALIDANDO PROGRESS.JSON ==="
if [ ! -f "$SPEC_DIR/PROGRESS.json" ]; then
    echo "❌ PROGRESS.json no existe"
    exit 1
fi

jq . "$SPEC_DIR/PROGRESS.json" > /dev/null
echo "✓ PROGRESS.json es JSON válido"

files_completed=$(jq -r '.files_completed' "$SPEC_DIR/PROGRESS.json")
echo "✓ Archivos completados según JSON: $files_completed"

# 4. Validar estructura de sprints
echo ""
echo "=== VALIDANDO ESTRUCTURA DE SPRINTS ==="
for sprint in Sprint-01-Schema-BD Sprint-02-Dominio Sprint-03-Repositorios Sprint-04-Services-API Sprint-05-Testing Sprint-06-CI-CD; do
    sprint_dir="$SPEC_DIR/03-Sprints/$sprint"
    if [ ! -d "$sprint_dir" ]; then
        echo "❌ Falta carpeta: $sprint"
        exit 1
    fi
    
    for file in README.md TASKS.md DEPENDENCIES.md QUESTIONS.md VALIDATION.md; do
        if [ ! -f "$sprint_dir/$file" ]; then
            echo "❌ Falta archivo: $sprint/$file"
            exit 1
        fi
    done
    echo "✓ $sprint completo (5 archivos)"
done

# 5. Validar documentación de testing
echo ""
echo "=== VALIDANDO TESTING DOCS ==="
for file in TEST_STRATEGY.md TEST_CASES.md COVERAGE_REPORT.md; do
    if [ ! -f "$SPEC_DIR/04-Testing/$file" ]; then
        echo "❌ Falta: 04-Testing/$file"
        exit 1
    fi
done
echo "✓ Testing docs completas (3 archivos)"

# 6. Validar documentación de deployment
echo ""
echo "=== VALIDANDO DEPLOYMENT DOCS ==="
for file in DEPLOYMENT_GUIDE.md INFRASTRUCTURE.md MONITORING.md; do
    if [ ! -f "$SPEC_DIR/05-Deployment/$file" ]; then
        echo "❌ Falta: 05-Deployment/$file"
        exit 1
    fi
done
echo "✓ Deployment docs completas (3 archivos)"

echo ""
echo "==================================="
echo "✅ VALIDACIÓN COMPLETADA EXITOSAMENTE"
echo "==================================="
echo "Total archivos: $total_files/50"
echo "Placeholders: 0"
echo "JSON válido: ✓"
echo "Estructura: ✓"
```

---

## 6. CONTROL DE CALIDAD

### Checklist de Calidad por Archivo

**Para cada archivo generado:**
- [ ] Longitud mínima cumplida (según FUNCTIONAL_SPECS)
- [ ] Sin placeholders (grep clean)
- [ ] Comandos ejecutables (validación manual de 3 comandos)
- [ ] Rutas absolutas en paths
- [ ] Código con firmas completas
- [ ] Links internos funcionan
- [ ] Formato Markdown válido

### Métricas de Calidad

| Métrica | Objetivo | Cómo Medir |
|---------|----------|------------|
| Completitud | 50/50 archivos | `find . -name "*.md" | wc -l` |
| Placeholders | 0 ocurrencias | `grep -r "TODO"` |
| Ejecutabilidad | 100% | Validación manual |
| Consistencia | >95% | Review manual |
| JSON válido | 100% | `jq . PROGRESS.json` |

---

## 7. HERRAMIENTAS Y AUTOMATIZACIÓN

### 7.1 Script de Generación Asistida

```bash
#!/bin/bash
# generate_sprint.sh - Genera estructura de un sprint

SPRINT_NUM=$1
SPRINT_NAME=$2

if [ -z "$SPRINT_NUM" ] || [ -z "$SPRINT_NAME" ]; then
    echo "Uso: ./generate_sprint.sh 02 Dominio"
    exit 1
fi

SPRINT_DIR="03-Sprints/Sprint-${SPRINT_NUM}-${SPRINT_NAME}"
mkdir -p "$SPRINT_DIR"

# Crear archivos vacíos con headers
for file in README.md TASKS.md DEPENDENCIES.md QUESTIONS.md VALIDATION.md; do
    cat > "$SPRINT_DIR/$file" << EOF
# [Título pendiente]
# Sprint ${SPRINT_NUM} - ${SPRINT_NAME}

**Fecha:** $(date +%Y-%m-%d)  
**Estado:** En generación

---

[Contenido pendiente]
EOF
done

echo "✓ Estructura de Sprint-${SPRINT_NUM} creada"
```

### 7.2 Actualización de PROGRESS.json

```bash
#!/bin/bash
# update_progress.sh - Actualiza PROGRESS.json después de generar archivo

FILE_PATH=$1
PROGRESS_FILE="PROGRESS.json"

# Agregar archivo a completed_files
jq --arg file "$FILE_PATH" '.completed_files += [$file] | .files_completed = (.completed_files | length)' "$PROGRESS_FILE" > tmp.json
mv tmp.json "$PROGRESS_FILE"

echo "✓ PROGRESS.json actualizado: +1 archivo"
```

---

## 8. CONSIDERACIONES DE PERFORMANCE

### Generación Eficiente
- Generar archivos de un sprint completo antes de pasar al siguiente
- Commit después de cada sprint (no por archivo)
- Reutilizar templates

### Optimización de Tokens
- Evitar regenerar contexto innecesario
- Referencias a archivos existentes (no copiar contenido)
- Templates reutilizables

---

## 9. SEGURIDAD Y RESPALDOS

### Backups
```bash
# Antes de comenzar generación masiva
tar -czf spec-01-backup-$(date +%Y%m%d_%H%M%S).tar.gz AnalisisEstandarizado/spec-01-evaluaciones/

# Guardar en carpeta de backups
mv spec-01-backup-*.tar.gz ~/backups/
```

### Control de Versiones
```bash
# Commit frecuente
git add AnalisisEstandarizado/spec-01-evaluaciones/
git commit -m "docs: completar Sprint-XX (5 archivos generados)"

# Branch de respaldo
git checkout -b backup/spec01-generation-$(date +%Y%m%d)
```

---

**Generado con:** Claude Code  
**Estado:** Especificaciones Técnicas Completas  
**Próximo paso:** Crear ACCEPTANCE_CRITERIA.md y EXECUTION_PLAN.md
