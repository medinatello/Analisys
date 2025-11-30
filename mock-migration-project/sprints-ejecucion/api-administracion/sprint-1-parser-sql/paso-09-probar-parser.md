# Paso 9: Ejecutar y Probar Parser

**Duracion estimada:** 10 minutos
**Prerequisitos:** Paso 8 completado

## Objetivo
Ejecutar el parser contra los archivos SQL reales y verificar que funciona.

## Archivos Involucrados
- Ejecutar: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/bin/mock-generator

## Pasos de Ejecucion

### 1. Navegar al directorio
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
```

### 2. Ejecutar parser con rutas absolutas
```bash
./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/tmp/mock-test
```

### 3. Ver output completo
```bash
./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/tmp/mock-test 2>&1 | tee parser-output.log
```

## Validacion

### Criterio de Exito
- [ ] Parser se ejecuta sin errores
- [ ] Muestra "Parseados X archivos SQL"
- [ ] Lista al menos 5 tablas (users, schools, etc)
- [ ] Cada tabla muestra numero de registros

### Output Esperado
```
🔨 Mock Generator v1.0.0
📂 Testing dir: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing
📁 Output dir: /tmp/mock-test

⏳ Parseando archivos SQL...

✅ Parseados 5 archivos SQL

Estadisticas por tabla:
  - users              : 8 registros, 10 columnas
  - schools            : 3 registros, 8 columnas
  - academic_units     : 5 registros, 7 columnas
  - memberships        : 12 registros, 6 columnas
  - materials          : 3 registros, 9 columnas

✨ Analisis completado
```

### Comandos de Validacion
```bash
# Verificar que se ejecuta sin errores
./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/tmp/mock-test
echo "Exit code: $?"
# Esperado: Exit code: 0

# Verificar que detecta tabla users
./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/tmp/mock-test | grep -q "users" && echo "OK: Tabla users detectada"
```

## Troubleshooting

**Problema:** No files found
**Solucion:** Verificar que la ruta al directorio testing es correcta

**Problema:** Parse error
**Solucion:** Verificar que los archivos SQL tienen sintaxis valida

**Problema:** 0 registros en alguna tabla
**Solucion:** Verificar que el archivo SQL correspondiente tiene INSERT statements

## Siguiente Paso
→ [paso-10-validar-output.md]
