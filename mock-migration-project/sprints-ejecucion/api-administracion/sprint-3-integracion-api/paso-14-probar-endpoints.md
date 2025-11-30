# Paso 14: Test de Endpoints Completos

**Duracion estimada:** 20 minutos

## Objetivo
Probar endpoints principales con dataset.

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Levantar API
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
API_PID=$!
sleep 5

# Obtener token
TOKEN=$(curl -s -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}' \
  | jq -r '.access_token')

echo "Token: $TOKEN"

# Listar escuelas
curl http://localhost:8081/v1/schools \
  -H "Authorization: Bearer $TOKEN" \
  | jq .

# Detener
kill $API_PID
```

## Validacion

### Criterio de Exito
- [ ] Lista de escuelas retorna array con 3 elementos
- [ ] Cada escuela tiene id, name, code
- [ ] Sin errores 500

## Siguiente Paso
→ [paso-15-validacion-final.md]
