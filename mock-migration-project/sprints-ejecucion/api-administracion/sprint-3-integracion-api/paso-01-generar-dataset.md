# Paso 1: Generar Dataset para API Admin

**Duracion estimada:** 5 minutos
**Prerequisitos:** Sprint 2 completado

## Objetivo
Ejecutar generador para crear dataset en directorio de api-administracion.

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset
```

## Validacion

```bash
ls -lh /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset/
# Debe listar: database.go, *_table.go, load_data.go
```

## Siguiente Paso
→ [paso-02-copiar-dataset.md]
