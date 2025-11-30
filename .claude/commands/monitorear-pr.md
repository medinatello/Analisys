---
description: Monitorea estado de un PR (pipelines, code review)
---

# Monitorear PR

Monitorea el estado de un Pull Request abierto, incluyendo pipelines y comentarios de Copilot.

## Uso

```
/monitorear-pr <owner> <repo> <pr_number>
```

**Ejemplo:**
```
/monitorear-pr EduGoGroup edugo-api-mobile 42
```

## Qué Hace

Usa el subagente `pr-monitor` para verificar:

1. Estado del PR (open/closed/merged)
2. Estado de todos los pipelines/checks
3. Comentarios de code review de Copilot
4. Si está listo para merge

## Reglas de Monitoreo

- **Intervalo:** 1 minuto entre verificaciones
- **Timeout:** 10 minutos máximo
- Si excede timeout, reporta estado actual

## Output Esperado

- Estado actual del PR
- Pipelines: exitosos/fallidos/pendientes
- Comentarios de Copilot (si hay)
- Indicador: ¿Listo para merge?
- Bloqueantes (si hay)

## Criterios para Merge

- ✅ Todos los pipelines exitosos
- ✅ Sin comentarios bloqueantes
- ✅ Estado mergeable = true

## Instrucciones para el Agente

Ejecuta el subagente `pr-monitor` con los argumentos: $ARGUMENTS

Formato esperado: `<owner> <repo> <pr_number>`
Si faltan argumentos, solicitar al usuario los datos necesarios.
