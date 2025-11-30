# Paso 1: Ejecutar Generador con SQL Testing

**Duración estimada:** 10 minutos
**Prerequisitos:** ✅ Sprint 0 completado

## Referencia a api-admin
📚 Equivalente a: `api-administracion/sprint-2-generador-dataset/paso-10-compilar-ejecutar.md`

La diferencia es que el generador YA EXISTE, solo lo ejecutamos.

## Objetivo
Ejecutar el generador para crear dataset.go desde archivos SQL de testing.

## Ejecución

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

# Ejecutar generador
./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/tmp/dataset-api-mobile

# Ver resultado
ls -la /tmp/dataset-api-mobile/
```

**Output esperado:**
```
Parsing SQL files...
Found 5 files
Parsed users table: 8 rows
Parsed schools table: 3 rows
Parsed academic_units table: 5 rows
Parsed memberships table: 12 rows
Parsed materials table: 3 rows
Generating Go files...
✓ Generated database.go
✓ Generated users_table.go
✓ Generated schools_table.go
✓ Generated academic_units_table.go
✓ Generated memberships_table.go
✓ Generated materials_table.go
✓ Generated load_data.go
Done!
```

## Validación
- [ ] Generador ejecutó sin errores
- [ ] 7 archivos .go creados en /tmp/dataset-api-mobile/
- [ ] Estadísticas muestran 8 users, 3 schools, etc.

## Siguiente Paso
→ [paso-02-verificar-output.md]
