---
description: Ejecuta validaciones (compile, lint, tests) antes de crear un PR
---

# Validar Pre-PR

Ejecuta todas las validaciones necesarias antes de crear un Pull Request.

## Uso

```
/validar-pre-pr <ruta_proyecto>
```

**Ejemplo:**
```
/validar-pre-pr /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
```

## Qué Hace

Usa el subagente `pre-pr-validator` para ejecutar:

1. **Compilación** (`go build ./...`)
2. **Linter** (`golangci-lint run`)
3. **Tests Unitarios** (`go test -short ./...`)
4. **Tests de Integración** (si existen)

Los pasos 1-3 se ejecutan en paralelo para optimizar tiempo.

## Output Esperado

- Estado de cada validación
- Lista de errores (si hay)
- Lista de warnings de lint
- Tests fallidos (si hay)
- Indicador: ¿Listo para PR?

## Criterios de Éxito

Para `listo_para_pr: true`:
- ✅ Compilación exitosa
- ✅ Sin errores de lint (warnings OK)
- ✅ Todos los tests pasando

## Instrucciones para el Agente

Ejecuta el subagente `pre-pr-validator` con la ruta del proyecto: $ARGUMENTS

Si no se proporciona ruta, solicitar al usuario que especifique el proyecto.
