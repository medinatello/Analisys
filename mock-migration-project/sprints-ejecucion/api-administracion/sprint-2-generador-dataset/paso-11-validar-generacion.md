# Paso 11: Validar Archivos Generados

**Duracion estimada:** 15 minutos
**Prerequisitos:** Paso 10 completado

## Objetivo
Verificar que los archivos generados existen y tienen contenido correcto.

## Pasos de Validacion

```bash
cd /tmp/dataset-test

# Listar archivos
ls -lh

# Verificar database.go
cat database.go | head -20

# Verificar users_table.go
cat users_table.go | head -30

# Verificar load_data.go
cat load_data.go | head -20
```

## Validacion

### Criterio de Exito
- [ ] Archivo database.go existe
- [ ] Archivo users_table.go existe
- [ ] Archivo schools_table.go existe
- [ ] Archivo academic_units_table.go existe
- [ ] Archivo memberships_table.go existe
- [ ] Archivo materials_table.go existe
- [ ] Archivo load_data.go existe

### Comandos de Validacion
```bash
for file in database.go users_table.go schools_table.go load_data.go; do
  test -f /tmp/dataset-test/$file && echo "OK: $file" || echo "FALTA: $file"
done
```

### Verificar Contenido
```bash
# database.go debe tener struct MockDatabase
grep -q "type MockDatabase struct" /tmp/dataset-test/database.go && echo "OK: MockDatabase"

# users_table.go debe tener FindByID
grep -q "func.*FindByID" /tmp/dataset-test/users_table.go && echo "OK: FindByID"

# load_data.go debe tener LoadAllData
grep -q "func LoadAllData" /tmp/dataset-test/load_data.go && echo "OK: LoadAllData"
```

## Siguiente Paso
→ [paso-12-probar-compilacion.md]
