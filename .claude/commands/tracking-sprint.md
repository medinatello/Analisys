---
description: Sincroniza tracking del sprint comparando plan vs código generado
---

# Tracking de Sprint

Compara el plan del sprint con el código generado y actualiza el tracking.

## Uso

```
/tracking-sprint <api> <sprint>
```

**Ejemplo:**
```
/tracking-sprint api-administracion sprint-1-parser-sql
```

## Qué Hace

Usa el subagente `sprint-tracker` para:

1. Leer el plan del sprint (README.md, CHECKLIST.md)
2. Listar todos los pasos (paso-*.md)
3. Verificar qué existe en el código
4. Comparar con tracking existente
5. Generar actualización del tracking

## Parámetros

| Parámetro | Valores Válidos |
|-----------|-----------------|
| api | `api-administracion`, `api-mobile` |
| sprint | `sprint-0-preparacion`, `sprint-1-*`, `sprint-2-*`, `sprint-3-*` |

## Rutas Relacionadas

**Documentación:**
```
/Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/<api>/<sprint>/
```

**Código (API Admin):**
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/
```

**Código (API Mobile):**
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/
```

## Output Esperado

- Estado de cada paso (completado/parcial/pendiente)
- Porcentaje de avance
- Siguiente paso a ejecutar
- Markdown para actualizar tracking

## Instrucciones para el Agente

Ejecuta el subagente `sprint-tracker` con los argumentos: $ARGUMENTS

Formato esperado: `<api> <sprint>`

Si faltan argumentos, mostrar los sprints disponibles según TRACKING-MAESTRO.md.
