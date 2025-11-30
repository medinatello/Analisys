# Paso 10: Compilar y Ejecutar Generador

**Duracion estimada:** 10 minutos
**Prerequisitos:** Paso 9 completado

## Objetivo
Compilar y ejecutar generador completo.

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

# Compilar
go build -o bin/mock-generator cmd/main.go

# Ejecutar
./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/tmp/dataset-test
```

## Validacion

### Output Esperado
```
🔨 Mock Generator v1.0.0
📂 Testing dir: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing
📁 Output dir: /tmp/dataset-test

⏳ Parseando archivos SQL...
✅ Parseados 5 archivos SQL

⏳ Generando dataset...
✅ Dataset generado exitosamente
📁 Archivos en: /tmp/dataset-test
```

### Comandos de Validacion
```bash
ls /tmp/dataset-test/
# Esperado: database.go, users_table.go, schools_table.go, etc.
```

## Siguiente Paso
→ [paso-11-validar-generacion.md]
