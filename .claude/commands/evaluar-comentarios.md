---
description: Evalúa comentarios de code review y clasifica según puntos Fibonacci
---

# Evaluar Comentarios de Code Review

Evalúa comentarios de Copilot/reviewers y los clasifica según la matriz de REGLAS-SPRINT-PR.md.

## Uso

```
/evaluar-comentarios <owner> <repo> <pr_number>
```

**Ejemplo:**
```
/evaluar-comentarios EduGoGroup edugo-api-administracion 15
```

## Qué Hace

Usa el subagente `copilot-comment-evaluator` para:

1. Obtener todos los comentarios del PR
2. Clasificar cada uno por puntos Fibonacci
3. Determinar acción para cada comentario

## Matriz de Clasificación

| Puntos | Acción |
|--------|--------|
| 0 | IGNORAR (traducción, estilo) |
| 1-3 | APLICAR_AHORA |
| 5-8 | SIGUIENTE_SPRINT |
| 13+ | DEUDA_TÉCNICA |

## Output Esperado

- Total de comentarios
- Clasificación por categoría
- Para cada comentario:
  - Ubicación (archivo, línea)
  - Puntos asignados
  - Acción recomendada
- Resumen: cuántos aplicar, diferir, ignorar
- Indicador de bloqueantes

## Instrucciones para el Agente

Ejecuta el subagente `copilot-comment-evaluator` con los argumentos: $ARGUMENTS

Formato esperado: `<owner> <repo> <pr_number>`

Si hay comentarios clasificados como DEUDA_TÉCNICA, indicar que se debe crear documento según REGLAS-SPRINT-PR.md.
