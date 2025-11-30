# Paso 7: Comparar con Dataset de API Admin

**Duración estimada:** 20 minutos
**Prerequisitos:** ✅ Paso 6 completado

## Objetivo
Validar que el dataset de api-mobile es idéntico al de api-admin (PostgreSQL).

## Ejecución

```bash
# Comparar estructura de database.go
diff \
  /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset/database.go \
  /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/infrastructure/persistence/mock/dataset/database.go

# Comparar users_table.go
diff \
  /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset/users_table.go \
  /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/infrastructure/persistence/mock/dataset/users_table.go
```

**Output esperado:**
```
# Diferencias SOLO en package name
< package dataset
---
> package mock

# El resto debe ser IDÉNTICO
```

## Validación
- [ ] Mismo número de users (8)
- [ ] Mismo número de schools (3)
- [ ] Mismos UUIDs
- [ ] Mismos passwords (bcrypt hash idéntico)
- [ ] Única diferencia: package name

## Siguiente Paso
→ [paso-08-probar-imports.md]
