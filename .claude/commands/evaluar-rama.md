---
description: Evalúa el estado de la rama actual en un proyecto EduGo
---

# Evaluar Estado de Rama

Evalúa el estado de la rama Git actual en un proyecto del ecosistema EduGo.

## Uso

```
/evaluar-rama <ruta_proyecto>
```

**Ejemplo:**
```
/evaluar-rama /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
```

## Qué Hace

Usa el subagente `branch-evaluator` para:

1. Identificar la rama actual
2. Verificar cambios sin commitear
3. Verificar sincronización con remoto
4. Detectar PRs abiertos o mergeados
5. Recomendar acciones según REGLAS-SPRINT-PR.md

## Output Esperado

- Estado de la rama
- Cambios pendientes (si hay)
- Estado de PRs
- Acción recomendada
- Comandos sugeridos

## Instrucciones para el Agente

Ejecuta el subagente `branch-evaluator` con la ruta del proyecto proporcionada por el usuario como argumento: $ARGUMENTS

Si no se proporciona ruta, solicitar al usuario que especifique el proyecto.

Proyectos válidos:
- `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile`
- `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion`
- `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared`
- `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure`
- `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-worker`
- `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-dev-environment`
