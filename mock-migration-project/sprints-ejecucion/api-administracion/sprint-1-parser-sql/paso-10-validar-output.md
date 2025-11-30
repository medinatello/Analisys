# Paso 10: Validar Datos Extraidos

**Duracion estimada:** 15 minutos
**Prerequisitos:** Paso 9 completado

## Objetivo
Validar que los datos extraidos son correctos y completos.

## Pasos de Ejecucion

### 1. Validar tabla users
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

# Ejecutar parser con modo verbose (agregar prints en codigo temporalmente)
# O revisar manualmente el archivo SQL vs output
```

### 2. Contar registros en SQL original
```bash
grep -o "INSERT INTO users" \
  /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/001_demo_users.sql \
  | wc -l
# Esperado: 1 (un solo INSERT con multiples VALUES)

# Contar VALUES en el INSERT
grep -o "ROW(" \
  /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/001_demo_users.sql \
  | wc -l
# Esperado: 8 registros
```

### 3. Verificar columnas parseadas
```bash
# Ver primera linea del archivo SQL de users
head -30 /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/001_demo_users.sql
# Debe listar columnas: id, email, password_hash, first_name, last_name, role, is_active, created_at, updated_at, etc
```

### 4. Validar funciones SQL
```bash
# Verificar que NOW() se detecta
grep "NOW()" /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/001_demo_users.sql
# Debe aparecer en created_at y updated_at
```

## Validacion

### Criterio de Exito
- [ ] Numero de registros coincide con SQL original
- [ ] Numero de columnas correcto (users: ~10 columnas)
- [ ] Funciones SQL detectadas (NOW(), UUID)
- [ ] Nombres de tablas correctos

### Tabla de Verificacion

| Tabla | Registros Esperados | Output Parser | OK? |
|-------|---------------------|---------------|-----|
| users | 8 | __ | [ ] |
| schools | 3 | __ | [ ] |
| academic_units | 5 | __ | [ ] |
| memberships | 12 | __ | [ ] |
| materials | 3 | __ | [ ] |

### Comandos de Validacion
```bash
# Script de validacion completa
cat > validate.sh << 'VALIDATE'
#!/bin/bash

echo "Validando parser..."

OUTPUT=$(./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/tmp/mock-test)

echo "$OUTPUT" | grep -q "users.*8 registros" && echo "✓ users: 8 registros OK" || echo "✗ users FALLO"
echo "$OUTPUT" | grep -q "schools.*3 registros" && echo "✓ schools: 3 registros OK" || echo "✗ schools FALLO"
echo "$OUTPUT" | grep -q "academic_units.*5 registros" && echo "✓ academic_units: 5 registros OK" || echo "✗ academic_units FALLO"
echo "$OUTPUT" | grep -q "memberships.*12 registros" && echo "✓ memberships: 12 registros OK" || echo "✗ memberships FALLO"
echo "$OUTPUT" | grep -q "materials.*3 registros" && echo "✓ materials: 3 registros OK" || echo "✗ materials FALLO"

echo ""
echo "Validacion completada"
VALIDATE

chmod +x validate.sh
./validate.sh
```

### Output Esperado
```
Validando parser...
✓ users: 8 registros OK
✓ schools: 3 registros OK
✓ academic_units: 5 registros OK
✓ memberships: 12 registros OK
✓ materials: 3 registros OK

Validacion completada
```

## Troubleshooting

**Problema:** Numeros no coinciden
**Solucion:** Revisar que el parser extrae todos los VALUES de un INSERT multiple

**Problema:** Funciones SQL no detectadas
**Solucion:** Revisar metodo evalExpr

## Sprint Completado

¡Felicitaciones! Has completado el Sprint 1. El parser SQL esta funcional.

## Siguiente Sprint
→ [../sprint-2-generador-dataset/README.md]
