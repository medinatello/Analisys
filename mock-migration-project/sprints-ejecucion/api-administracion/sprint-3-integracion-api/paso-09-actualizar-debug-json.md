# Paso 9: Actualizar Debug Configuration

**Duracion estimada:** 5 minutos

## Objetivo
Actualizar .zed/debug.json para usar variable estandarizada.

## Codigo a Implementar

Archivo: .zed/debug.json

Modificar configuracion mock:
```json
{
  "label": "Go: Debug main (MOCK - Sin Docker)",
  "env": {
    "USE_MOCK_REPOSITORIES": "true",
    "APP_ENV": "local"
  }
}
```

## Siguiente Paso
→ [paso-10-borrar-archivos-antiguos.md]
