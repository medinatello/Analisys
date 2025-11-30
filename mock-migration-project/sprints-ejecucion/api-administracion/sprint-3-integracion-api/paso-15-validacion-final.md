# Paso 15: Validacion Final del Sistema

**Duracion estimada:** 20 minutos

## Objetivo
Validacion completa end-to-end del sistema integrado.

## Script de Validacion Completo

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

cat > test-integration.sh << 'TESTSCRIPT'
#!/bin/bash

echo "=== Test de Integracion Completo ==="

# Levantar API
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
API_PID=$!
sleep 5

# Test 1: Health
echo "Test 1: Health Check"
curl -s http://localhost:8081/health | jq . && echo "OK" || echo "FAIL"

# Test 2: Login
echo "Test 2: Login"
TOKEN=$(curl -s -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}' \
  | jq -r '.access_token')

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
  echo "OK: Token obtenido"
else
  echo "FAIL: Sin token"
  kill $API_PID
  exit 1
fi

# Test 3: Listar escuelas
echo "Test 3: Listar Escuelas"
SCHOOLS=$(curl -s http://localhost:8081/v1/schools \
  -H "Authorization: Bearer $TOKEN" \
  | jq '. | length')

if [ "$SCHOOLS" -eq 3 ]; then
  echo "OK: 3 escuelas"
else
  echo "FAIL: Esperado 3, obtenido $SCHOOLS"
fi

# Test 4: Listar usuarios
echo "Test 4: Listar Usuarios"
USERS=$(curl -s http://localhost:8081/v1/users \
  -H "Authorization: Bearer $TOKEN" \
  | jq '. | length')

if [ "$USERS" -eq 8 ]; then
  echo "OK: 8 usuarios"
else
  echo "FAIL: Esperado 8, obtenido $USERS"
fi

# Cleanup
kill $API_PID

echo "=== Test Completado ==="
TESTSCRIPT

chmod +x test-integration.sh
./test-integration.sh
```

## Validacion

### Checklist Final
- [ ] Health check funciona
- [ ] Login retorna token valido
- [ ] Lista escuelas retorna 3
- [ ] Lista usuarios retorna 8
- [ ] Sin errores en logs

## Sprint Completado

¡Felicitaciones! api-administracion ahora usa dataset generado automaticamente.

## Documentacion Final
→ [../../tracking-api-admin.md]
