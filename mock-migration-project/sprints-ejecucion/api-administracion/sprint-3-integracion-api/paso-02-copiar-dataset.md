# Paso 2: Verificar Dataset Copiado

**Duracion estimada:** 5 minutos
**Prerequisitos:** Paso 1 completado

## Objetivo
Verificar que todos los archivos del dataset fueron creados correctamente.

## Validacion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset

# Listar archivos
ls -1

# Verificar contenido
for file in *.go; do
  echo "=== $file ==="
  head -5 "$file"
  echo ""
done
```

### Criterio de Exito
- [ ] database.go existe
- [ ] users_table.go existe
- [ ] schools_table.go existe
- [ ] academic_units_table.go existe
- [ ] memberships_table.go existe
- [ ] load_data.go existe

## Siguiente Paso
→ [paso-03-actualizar-user-repository.md]
