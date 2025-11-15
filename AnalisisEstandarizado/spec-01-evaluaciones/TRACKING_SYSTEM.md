# Sistema de Tracking y Ejecución
# spec-01-evaluaciones

**Versión:** 1.0.0  
**Fecha:** 14 de Noviembre, 2025

---

## 1. PROPÓSITO

Este sistema de tracking permite:
- ✅ **Continuar desde interrupciones:** Saber exactamente dónde quedó la última sesión
- ✅ **Ejecución desatendida:** IA puede ejecutar sprints automáticamente
- ✅ **Trazabilidad:** Ver progreso en tiempo real
- ✅ **Auditoría:** Histórico de qué se generó y cuándo

---

## 2. ARCHIVO PROGRESS.json

### Estructura

```json
{
  "project": "spec-01-evaluaciones",
  "total_files": 50,
  "files_completed": 50,
  "files_remaining": 0,
  "current_phase": "Fase-9-Validation",
  "current_sprint": null,
  "sprint_status": {
    "Sprint-01": "completed",
    "Sprint-02": "completed",
    "Sprint-03": "completed",
    "Sprint-04": "completed",
    "Sprint-05": "completed",
    "Sprint-06": "completed"
  },
  "phase_status": {
    "Fase-0-Preparacion": "completed",
    "Fase-1-Sprint02": "completed",
    "Fase-2-Sprint03": "completed",
    "Fase-3-Sprint04": "completed",
    "Fase-4-Sprint05": "completed",
    "Fase-5-Sprint06": "completed",
    "Fase-6-Testing": "completed",
    "Fase-7-Deployment": "completed",
    "Fase-8-Tracking": "completed",
    "Fase-9-Validation": "completed"
  },
  "completed_files": [
    "01-Requirements/PRD.md",
    "01-Requirements/FUNCTIONAL_SPECS.md",
    ...
  ],
  "validation_results": {
    "placeholders_count": 0,
    "executable_commands": true,
    "consistency_score": 100
  }
}
```

### Campos Clave

- **files_completed:** Contador de archivos generados
- **current_phase:** Dónde continuar en próxima sesión
- **sprint_status:** Estado de cada sprint (pending|in_progress|completed)
- **completed_files:** Lista de archivos generados (para auditoría)

---

## 3. REGLAS DE EJECUCIÓN

### Regla 1: Leer PROGRESS.json al Inicio de Cada Sesión

```bash
# Al inicio de nueva sesión
cd /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones

# Leer estado actual
current_phase=$(jq -r '.current_phase' PROGRESS.json)
files_completed=$(jq -r '.files_completed' PROGRESS.json)
files_remaining=$(jq -r '.files_remaining' PROGRESS.json)

echo "Continuar desde: $current_phase"
echo "Progreso: $files_completed/50 archivos ($((files_completed * 100 / 50))%)"
echo "Faltan: $files_remaining archivos"
```

### Regla 2: Actualizar PROGRESS.json Después de Cada Fase

```bash
# Después de completar una fase
jq '.files_completed = 27 | .current_phase = "Fase-3-Sprint04" | .phase_status."Fase-2-Sprint03" = "completed"' PROGRESS.json > tmp.json
mv tmp.json PROGRESS.json
```

### Regla 3: Commit Después de Cada Fase

```bash
git add .
git commit -m "docs: completar Sprint-XX (5 archivos, Fase Y)"
```

### Regla 4: Validar JSON Después de Cada Actualización

```bash
# Verificar que JSON es válido
jq . PROGRESS.json

# Si falla, restaurar desde git
git checkout PROGRESS.json
```

---

## 4. CÓMO CONTINUAR DESDE INTERRUPCIÓN

### Paso 1: Leer Estado Actual

```bash
cd /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones

# Ver estado completo
jq '{current_phase, current_sprint, files_completed, files_remaining, sprint_status}' PROGRESS.json
```

### Paso 2: Identificar Próxima Fase

```bash
# Ver próxima fase pendiente
jq -r '.phase_status | to_entries[] | select(.value == "pending") | .key' PROGRESS.json | head -1
```

### Paso 3: Continuar Ejecución

**Si current_phase = "Fase-3-Sprint04":**
- Ir a `/Users/jhoanmedina/source/EduGo/Analisys/specifications_documents/spec-meta-completar-spec01/02-Design/EXECUTION_PLAN.md`
- Buscar sección "FASE 3: Sprint-04"
- Ejecutar las 5 tareas especificadas

**Si current_phase = "Fase-6-Testing":**
- Generar archivos de 04-Testing/
- Seguir EXECUTION_PLAN.md

---

## 5. MANEJO DE ERRORES

### Si un Archivo Falla al Generarse

1. **Registrar en PROGRESS.json:**
   ```bash
   jq '.failed_files += ["03-Sprints/Sprint-04/TASKS.md"]' PROGRESS.json > tmp.json
   mv tmp.json PROGRESS.json
   ```

2. **Intentar regenerar (hasta 3 veces)**

3. **Si falla 3 veces, marcar para revisión manual:**
   ```bash
   jq '.manual_review_required += ["Sprint-04/TASKS.md"]' PROGRESS.json > tmp.json
   mv tmp.json PROGRESS.json
   ```

4. **Continuar con siguiente archivo** (no bloquear todo el proceso)

---

## 6. FORMATO DE COMMITS

### Convención

```
docs: completar <Sprint-XX> (<N> archivos, Fase Y)

<Descripción de archivos generados>

PROGRESS: X/50 archivos (XX%)
```

**Ejemplos:**
```
docs: completar Sprint-02-Dominio (5 archivos, Fase 1)

- README.md: Resumen del sprint
- TASKS.md: 6 tareas con código Go exacto
- DEPENDENCIES.md: Go 1.21+, testify
- QUESTIONS.md: 6 decisiones con defaults
- VALIDATION.md: Checklist de validación

PROGRESS: 22/50 archivos (44%)
```

---

## 7. COMANDOS ÚTILES

### Ver Progreso Actual
```bash
cd /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones

# Resumen
jq '{files_completed, files_remaining, current_phase}' PROGRESS.json

# Sprints completados
jq -r '.sprint_status | to_entries[] | select(.value == "completed") | .key' PROGRESS.json

# Sprints pendientes
jq -r '.sprint_status | to_entries[] | select(.value == "pending") | .key' PROGRESS.json
```

### Contar Archivos Reales
```bash
# Contar archivos en disco
find . -type f \( -name "*.md" -o -name "*.json" \) | wc -l

# Comparar con PROGRESS.json
expected=$(jq -r '.files_completed' PROGRESS.json)
actual=$(find . -type f \( -name "*.md" -o -name "*.json" \) | wc -l)

if [ "$actual" -eq "$expected" ]; then
    echo "✅ Sincronizado: $actual archivos"
else
    echo "⚠️  Desincronizado: $actual real vs $expected esperado"
fi
```

### Validar Completitud
```bash
# Debe retornar 50
find . -type f \( -name "*.md" -o -name "*.json" \) | wc -l

# Verificar que PROGRESS.json dice 50
jq -r '.files_completed' PROGRESS.json
```

---

## 8. WORKFLOW COMPLETO

### Nueva Sesión

```bash
# 1. Navegar al proyecto
cd /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones

# 2. Leer PROGRESS.json
cat PROGRESS.json | jq .

# 3. Ver último commit
git log -1 --oneline

# 4. Identificar próxima fase
next_phase=$(jq -r '.current_phase' PROGRESS.json)
echo "Continuar desde: $next_phase"

# 5. Abrir EXECUTION_PLAN.md
cat /Users/jhoanmedina/source/EduGo/Analisys/specifications_documents/spec-meta-completar-spec01/02-Design/EXECUTION_PLAN.md | grep -A 20 "$next_phase"

# 6. Ejecutar fase
# [Seguir instrucciones del plan]

# 7. Actualizar PROGRESS.json
jq '.files_completed += 5 | .current_phase = "Fase-X-Next"' PROGRESS.json > tmp.json
mv tmp.json PROGRESS.json

# 8. Commit
git add .
git commit -m "docs: completar Fase-X"

# 9. Repetir hasta files_completed = 50
```

---

## 9. VALIDACIÓN FINAL

Cuando `files_completed = 50`:

```bash
# Ejecutar validación completa
bash /Users/jhoanmedina/source/EduGo/Analisys/specifications_documents/spec-meta-completar-spec01/01-Requirements/validate_all_criteria.sh

# Verificar que no hay placeholders
grep -r "TODO\|PLACEHOLDER\|TBD" . --include="*.md"
# Esperado: (vacío)

# Generar reporte final
# Ver Fase 9 en EXECUTION_PLAN.md
```

---

## 10. TROUBLESHOOTING

### PROGRESS.json Corrupto
```bash
# Restaurar desde último commit
git checkout HEAD -- PROGRESS.json

# O reconstruir manualmente
# Contar archivos reales y actualizar
```

### Archivos Faltantes
```bash
# Comparar PROGRESS.json vs archivos reales
comm -23 <(jq -r '.completed_files[]' PROGRESS.json | sort) <(find . -name "*.md" -o -name "*.json" | sed 's|./||' | sort)
```

---

**Generado con:** Claude Code  
**Estado:** Sistema de Tracking Documentado  
**Uso:** Leer al inicio de cada sesión
