# Paso 5: Validar Acceso a Migraciones SQL

**Duracion estimada:** 5 minutos
**Prerequisitos:** Paso 4 completado

## Objetivo
Verificar que podemos acceder a los archivos SQL de testing que seran parseados.

## Archivos Involucrados
- Verificar: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/

## Pasos de Ejecucion

### 1. Listar archivos SQL de testing
```bash
ls -lh /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/*.sql
```

### 2. Verificar contenido de un archivo
```bash
head -20 /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/001_demo_users.sql
```

### 3. Contar registros en cada archivo
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing
for file in *.sql; do
  count=$(grep -c "INSERT INTO" "$file" 2>/dev/null || echo "0")
  echo "$file: $count INSERT statements"
done
```

## Validacion

### Criterio de Exito
- [ ] Se listan al menos 5 archivos SQL
- [ ] 001_demo_users.sql contiene INSERT INTO users
- [ ] Todos los archivos son legibles

### Comandos de Validacion
```bash
test -f /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/001_demo_users.sql && echo "OK: 001_demo_users.sql existe"
test -f /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/002_demo_schools.sql && echo "OK: 002_demo_schools.sql existe"
test -f /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/005_demo_materials.sql && echo "OK: 005_demo_materials.sql existe"
```

### Output Esperado
```
001_demo_users.sql: 1 INSERT statements
002_demo_schools.sql: 1 INSERT statements
003_demo_academic_units.sql: 1 INSERT statements
004_demo_memberships.sql: 1 INSERT statements
005_demo_materials.sql: 1 INSERT statements
```

## Troubleshooting

**Problema:** No such file or directory
**Solucion:** Verificar que el repositorio edugo-infrastructure esta clonado y actualizado

**Problema:** Archivos vacios
**Solucion:** Ejecutar git pull en edugo-infrastructure

## Siguiente Paso
→ [paso-06-crear-gitignore.md]
