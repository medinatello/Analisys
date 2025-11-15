# 🤖 Guía de Ejecución para IA Desatendida - EduGo

## 🎯 Propósito
Esta guía permite a cualquier IA (Claude, GPT-4, GitHub Copilot, etc.) ejecutar de forma autónoma las tareas del proyecto EduGo sin intervención humana.

## 🚀 Quick Start

### Paso 1: Inicialización
```bash
# 1. Leer estado actual
cat /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/TRACKING_SYSTEM.json

# 2. Identificar próxima acción
# Buscar "next_action" en el JSON

# 3. Navegar al proyecto correcto
cd [working_directory del proyecto]

# 4. Verificar estado git
git status
git pull origin main
```

### Paso 2: Continuar Trabajo
```bash
# Si es primera vez en el spec:
git checkout -b [branch_name]

# Si ya existe el branch:
git checkout [branch_name]
git pull origin [branch_name]
```

### Paso 3: Ejecutar Tarea
1. Navegar a la carpeta del spec: `03-Specifications/[Spec-XX]/[proyecto]/`
2. Abrir `TASKS.md`
3. Encontrar la tarea actual según `current_task` en TRACKING_SYSTEM.json
4. Ejecutar los pasos exactamente como están descritos
5. Validar con los criterios de aceptación

## 📋 Flujo de Trabajo Completo

### 1. Al Iniciar Sesión

```python
# Pseudocódigo para IA
def start_session():
    # 1. Leer tracking
    tracking = read_json("TRACKING_SYSTEM.json")
    
    # 2. Obtener estado
    current_spec = tracking["next_action"]["spec"]
    current_project = tracking["next_action"]["project"]
    current_task = tracking["next_action"]["task"]
    
    # 3. Validar dependencias
    if check_dependencies(current_project):
        proceed_with_task()
    else:
        log_error("Dependencies not met")
        find_next_available_task()
    
    # 4. Continuar desde punto exacto
    execute_task(current_spec, current_project, current_task)
```

### 2. Durante Ejecución de Tarea

```python
def execute_task(spec, project, task_id):
    # 1. Leer definición de tarea
    task = read_task_definition(spec, project, task_id)
    
    # 2. Ejecutar pasos
    for step in task["steps"]:
        try:
            result = execute_step(step)
            validate_step(result, step["validation"])
        except Exception as e:
            handle_error(e, step)
    
    # 3. Validar criterios de aceptación
    for criterion in task["acceptance_criteria"]:
        assert validate_criterion(criterion), f"Failed: {criterion}"
    
    # 4. Actualizar tracking
    update_tracking(spec, project, task_id, "completed")
    
    # 5. Commit si está habilitado
    if tracking["configuration"]["auto_commit"]:
        git_commit(task["description"])
```

### 3. Manejo de Errores

```python
def handle_error(error, context):
    retry_count = 0
    max_retries = tracking["configuration"]["max_retries"]
    
    while retry_count < max_retries:
        log_error(f"Attempt {retry_count + 1}: {error}")
        
        # Estrategias de recuperación
        if "connection" in str(error):
            wait(30)  # Esperar 30 segundos
        elif "compilation" in str(error):
            run_command("go mod tidy")
        elif "test failure" in str(error):
            analyze_test_failure()
            fix_test()
        
        try:
            retry_result = execute_step(context)
            if successful(retry_result):
                return retry_result
        except:
            retry_count += 1
    
    # Si falla después de reintentos
    mark_task_as_failed(context)
    find_next_non_dependent_task()
```

### 4. Validación de Tareas

```python
def validate_task(task):
    validations = {
        "compilation": "go build ./...",
        "tests": "go test ./... -cover",
        "linting": "golangci-lint run",
        "documentation": "check_docs_updated()"
    }
    
    for check_name, command in validations.items():
        result = run_command(command)
        if not result.success:
            return False, f"Validation failed: {check_name}"
    
    return True, "All validations passed"
```

## 🔄 Actualización del Tracking

### Después de Cada Tarea

```json
{
  "execution_log": [
    {
      "timestamp": "2025-11-14T10:30:00Z",
      "spec": "Spec-01-Sistema-Evaluaciones",
      "project": "01-shared",
      "task": "TASK-001",
      "status": "completed",
      "duration_seconds": 180,
      "ai_executor": "claude-3.5"
    }
  ]
}
```

### Al Completar un Proyecto

```bash
# 1. Actualizar versión si aplica
git tag v1.3.0
git push origin v1.3.0

# 2. Crear PR si está habilitado
gh pr create \
  --title "feat: complete evaluation module" \
  --body "Auto-generated PR by AI executor" \
  --base main

# 3. Actualizar tracking
# Marcar proyecto como completado
# Desbloquear proyectos dependientes
```

## 📊 Comandos de Monitoreo

### Ver Progreso Global
```bash
# Estado general
jq '.global_progress' TRACKING_SYSTEM.json

# Spec actual
jq '.next_action' TRACKING_SYSTEM.json

# Tareas fallidas
jq '.failed_tasks' TRACKING_SYSTEM.json
```

### Generar Reporte
```bash
# Reporte de progreso
echo "=== PROGRESO EDUGO ===" 
echo "Specs Completados: $(jq '.global_progress.completed_specs' TRACKING_SYSTEM.json)/$(jq '.global_progress.total_specs' TRACKING_SYSTEM.json)"
echo "Porcentaje Global: $(jq '.global_progress.completion_percentage' TRACKING_SYSTEM.json)%"
echo "Spec Actual: $(jq -r '.next_action.spec' TRACKING_SYSTEM.json)"
echo "Próxima Tarea: $(jq -r '.next_action.description' TRACKING_SYSTEM.json)"
```

## 🛠️ Herramientas Útiles

### Script de Continuación Automática
```bash
#!/bin/bash
# continue_work.sh

# Leer próxima acción
SPEC=$(jq -r '.next_action.spec' TRACKING_SYSTEM.json)
PROJECT=$(jq -r '.next_action.project' TRACKING_SYSTEM.json)
TASK=$(jq -r '.next_action.task' TRACKING_SYSTEM.json)

# Navegar al proyecto
cd $(jq -r ".configuration.working_directories.\"${PROJECT#*-}\"" TRACKING_SYSTEM.json)

# Mostrar información
echo "Continuando con:"
echo "  Spec: $SPEC"
echo "  Project: $PROJECT"
echo "  Task: $TASK"

# Abrir documentación de tareas
cat AnalisisEstandarizado/03-Specifications/$SPEC/$PROJECT/TASKS.md | grep -A 20 "$TASK:"
```

### Validación Pre-Commit
```bash
#!/bin/bash
# pre_commit_check.sh

echo "Ejecutando validaciones pre-commit..."

# 1. Tests
go test ./... -cover || exit 1

# 2. Linting
golangci-lint run || exit 1

# 3. Build
go build ./... || exit 1

# 4. Documentación
if [ -z "$(git diff --name-only | grep -E '\.(md|MD)$')" ]; then
    echo "⚠️ No hay cambios en documentación"
fi

echo "✅ Todas las validaciones pasaron"
```

## 🔐 Variables de Entorno Requeridas

```bash
# GitHub
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
export GITHUB_ORG="EduGoGroup"

# OpenAI (para worker)
export OPENAI_API_KEY="sk-xxxxxxxxxxxx"

# Database URLs (para tests de integración)
export DATABASE_URL="postgresql://user:pass@localhost:5432/edugo"
export MONGO_URI="mongodb://localhost:27017/edugo"
export RABBITMQ_URL="amqp://guest:guest@localhost:5672/"
```

## 📋 Checklist de IA

Antes de marcar cualquier tarea como completada:

### Para Tareas de Código
- [ ] Código compila sin errores
- [ ] Tests unitarios creados y pasando
- [ ] Coverage >85%
- [ ] Sin warnings de linter
- [ ] Documentación inline agregada

### Para Tareas de Integración
- [ ] Tests de integración pasando
- [ ] Endpoints documentados en Swagger
- [ ] Eventos publicados correctamente
- [ ] Sin breaking changes no documentados

### Para Publicación de Módulos
- [ ] Versión actualizada en go.mod
- [ ] Tag creado y pusheado
- [ ] Módulo accesible públicamente
- [ ] CHANGELOG actualizado
- [ ] README actualizado

## 🚨 Situaciones Especiales

### Si Encuentras Conflictos de Git
```bash
# Preferir versión remota para archivos generados
git checkout --theirs [file]

# Preferir versión local para código manual
git checkout --ours [file]

# Si no estás seguro, crear backup
cp [file] [file].backup
git stash
git pull --rebase
```

### Si un Test Falla Consistentemente
1. Verificar si es un test flaky
2. Revisar logs detallados
3. Si es problema de ambiente, documentar en `failed_tasks`
4. Continuar con siguiente tarea no dependiente

### Si una Dependencia No Está Lista
1. Verificar estado real del módulo dependiente
2. Si está publicado pero no actualizado en tracking, proceder
3. Si no está listo, buscar siguiente tarea sin esa dependencia
4. Actualizar `blocked_reason` en tracking

## 🎯 Métricas de Éxito

Tu ejecución será exitosa si:
1. **Velocidad**: Completas ≥5 tareas por hora
2. **Calidad**: 0 errores en producción por tu código
3. **Cobertura**: Todos los tests >85%
4. **Documentación**: 100% de funciones públicas documentadas
5. **Tracking**: TRACKING_SYSTEM.json siempre actualizado

## 📞 Escalación

Si encuentras un problema que no puedes resolver:

1. Documentar en `failed_tasks` con:
   - Descripción detallada del error
   - Pasos para reproducir
   - Logs relevantes
   - Intentos de solución

2. Marcar tarea como `blocked` en tracking

3. Continuar con siguiente tarea disponible

4. El problema será revisado por humanos en la próxima sesión

---

## 🔄 Loop Principal de Ejecución

```python
# main_execution_loop.py
while has_pending_tasks():
    # 1. Leer estado
    tracking = load_tracking()
    
    # 2. Obtener próxima tarea
    task = get_next_task(tracking)
    
    # 3. Validar dependencias
    if not dependencies_met(task):
        task = find_alternative_task()
    
    # 4. Ejecutar
    try:
        execute_task(task)
        mark_completed(task)
        commit_changes(task)
    except Exception as e:
        handle_failure(task, e)
    
    # 5. Actualizar tracking
    save_tracking(tracking)
    
    # 6. Reportar progreso
    print_progress()
    
    # 7. Verificar tiempo límite
    if execution_time() > MAX_SESSION_TIME:
        graceful_shutdown()
        break
```

---

**Recuerda**: 
- Sigue SIEMPRE el orden definido en `EXECUTION_ORDER.md`
- Actualiza tracking después de CADA tarea
- Commitea frecuentemente con mensajes descriptivos
- Si dudas, es mejor documentar y continuar que bloquearse

**¡Éxito en tu ejecución autónoma!** 🚀