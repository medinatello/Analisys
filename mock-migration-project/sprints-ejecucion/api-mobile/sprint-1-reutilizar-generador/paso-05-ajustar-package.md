# Paso 5: Ajustar Package Name

**Duración estimada:** 10 minutos
**Prerequisitos:** ✅ Paso 4 completado

## Objetivo
Ajustar package name de "mock" a "dataset" si es necesario.

## Ejecución

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Ver package actual
grep "^package" internal/infrastructure/persistence/mock/dataset/*.go | head -1

# Si es "package mock", cambiarlo a "package dataset"
# Opción 1: sed (macOS)
find internal/infrastructure/persistence/mock/dataset -name "*.go" -exec sed -i '' 's/^package mock$/package dataset/' {} \;

# Opción 2: Manual (si sed falla)
# Editar cada archivo y cambiar primera línea a: package dataset

# Verificar cambio
grep "^package" internal/infrastructure/persistence/mock/dataset/*.go | uniq
```

**Output esperado:**
```
package dataset
```

## Validación
- [ ] Todos los archivos tienen package dataset
- [ ] No hay errores de sintaxis

## Siguiente Paso
→ [paso-06-validar-compilacion.md]
