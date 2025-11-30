# Paso 4: Copiar Dataset a API Mobile

**Duración estimada:** 5 minutos
**Prerequisitos:** ✅ Paso 3 completado

## Referencia a api-admin
📚 Similar a: `api-administracion/sprint-3-integracion-api/paso-02-copiar-dataset.md`

## Objetivo
Copiar archivos del dataset generado a api-mobile.

## Ejecución

```bash
# Copiar todos los archivos
cp /tmp/dataset-api-mobile/*.go \
   /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/infrastructure/persistence/mock/dataset/

# Verificar
ls -la /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/infrastructure/persistence/mock/dataset/
```

**Output esperado:**
```
-rw-r--r--  database.go
-rw-r--r--  users_table.go
-rw-r--r--  schools_table.go
-rw-r--r--  academic_units_table.go
-rw-r--r--  memberships_table.go
-rw-r--r--  materials_table.go
-rw-r--r--  load_data.go
```

## Validación
- [ ] 7 archivos copiados
- [ ] Todos tienen extensión .go

## Siguiente Paso
→ [paso-05-ajustar-package.md]
