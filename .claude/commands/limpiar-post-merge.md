---
description: Ejecuta limpieza después de un merge exitoso (eliminar rama, sincronizar)
---

# Limpiar Post-Merge

Ejecuta las acciones de limpieza después de que un PR ha sido mergeado.

## Uso

```
/limpiar-post-merge <ruta_proyecto> <rama_feature> <rama_destino>
```

**Ejemplo:**
```
/limpiar-post-merge /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile feature/sprint-1 dev
```

## Qué Hace

Usa el subagente `post-merge-cleanup` para:

1. Verificar que el merge fue exitoso
2. Cambiar a rama destino (dev o main)
3. Sincronizar con remoto (git pull)
4. Eliminar rama local
5. Eliminar rama remota
6. Verificar limpieza completa

## Parámetros

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| ruta_proyecto | Path absoluto al proyecto | `/Users/.../edugo-api-mobile` |
| rama_feature | Rama que fue mergeada | `feature/sprint-1` |
| rama_destino | Rama donde se hizo merge | `dev` o `main` |

## Output Esperado

- Estado de cada acción
- Rama actual después de limpieza
- Commit actual (SHA)
- Errores (si hay)

## Instrucciones para el Agente

Ejecuta el subagente `post-merge-cleanup` con los argumentos: $ARGUMENTS

Formato esperado: `<ruta_proyecto> <rama_feature> <rama_destino>`

**IMPORTANTE:** No ejecutar si el PR no está mergeado.
