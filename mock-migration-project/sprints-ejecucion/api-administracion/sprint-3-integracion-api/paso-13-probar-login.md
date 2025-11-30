# Paso 13: Test de Autenticacion

**Duracion estimada:** 15 minutos

## Objetivo
Verificar login con datos del dataset.

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Levantar API
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
API_PID=$!
sleep 5

# Login
curl -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}' \
  | jq .

# Detener
kill $API_PID
```

## Validacion

### Output Esperado
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": {
    "id": "a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "email": "admin@edugo.test",
    "role": "admin"
  }
}
```

## Siguiente Paso
→ [paso-14-probar-endpoints.md]
