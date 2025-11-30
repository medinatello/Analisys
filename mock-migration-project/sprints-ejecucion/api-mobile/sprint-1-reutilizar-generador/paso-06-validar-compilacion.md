# Paso 6: Validar Compilación

**Duración estimada:** 15 minutos
**Prerequisitos:** ✅ Paso 5 completado

## Objetivo
Validar que el dataset compila sin errores.

## Ejecución

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Compilar solo el paquete dataset
go build ./internal/infrastructure/persistence/mock/dataset/

# Ver errores de imports si los hay
go list -f '{{.Imports}}' ./internal/infrastructure/persistence/mock/dataset/
```

**Output esperado:**
```
# Sin output = compilación exitosa
```

**Si hay errores de import:**
```bash
# Agregar dependencias faltantes
go get github.com/google/uuid
go get github.com/EduGoGroup/edugo-infrastructure/postgres/entities

# Intentar de nuevo
go build ./internal/infrastructure/persistence/mock/dataset/
```

## Validación
- [ ] Dataset compila sin errores
- [ ] Dependencias instaladas
- [ ] No hay warnings

## Siguiente Paso
→ [paso-07-comparar-con-admin.md]
