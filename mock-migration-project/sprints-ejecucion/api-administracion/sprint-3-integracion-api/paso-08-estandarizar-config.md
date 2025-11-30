# Paso 8: Estandarizar Configuracion

**Duracion estimada:** 10 minutos

## Objetivo
Estandarizar variable USE_MOCK_REPOSITORIES en config.

## Codigo a Implementar

Archivo: internal/config/loader.go (linea ~130)

Agregar:
```go
_ = v.BindEnv("database.use_mock_repositories", "USE_MOCK_REPOSITORIES")
```

## Validacion

```bash
grep -n "USE_MOCK_REPOSITORIES" internal/config/loader.go
```

## Siguiente Paso
→ [paso-09-actualizar-debug-json.md]
