# Paso 10: Borrar Archivos Antiguos

**Duracion estimada:** 5 minutos

## Objetivo
Eliminar archivos hardcodeados antiguos.

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Borrar directorio de datos antiguos
rm -rf internal/infrastructure/persistence/mock/data/

# Verificar que no existen
test ! -d internal/infrastructure/persistence/mock/data && echo "OK: Directorio data eliminado"
```

## Siguiente Paso
→ [paso-11-compilar-api.md]
