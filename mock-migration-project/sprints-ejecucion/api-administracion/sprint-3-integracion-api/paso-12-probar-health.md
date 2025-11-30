# Paso 12: Test Health Check

**Duracion estimada:** 10 minutos

## Objetivo
Verificar que API levanta correctamente con mocks.

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Levantar API con mocks
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
API_PID=$!

# Esperar a que levante
sleep 5

# Probar health
curl http://localhost:8081/health

# Detener API
kill $API_PID
```

## Validacion

### Output Esperado
```json
{"service":"edugo-api-admin","status":"healthy"}
```

## Siguiente Paso
→ [paso-13-probar-login.md]
