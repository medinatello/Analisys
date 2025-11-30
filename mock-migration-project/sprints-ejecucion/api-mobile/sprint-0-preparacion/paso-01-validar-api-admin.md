# Paso 1: Validar API Admin Completó Sprint 0-3

**Duración estimada:** 5 minutos
**Prerequisitos:** Ninguno (primer paso)

## Referencia a api-admin
Este paso NO tiene equivalente en api-admin. Es específico de api-mobile.

## Objetivo
Verificar que api-administracion completó sus 4 sprints y está funcionando con mocks.

## Pasos de Ejecución

### 1. Verificar tracking de api-admin

```bash
cat /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/tracking-api-admin.md | grep "Sprint 3"
```

**Output esperado:**
```
| Sprint 3 | Integración API | 15 | 15 | 100% | ✅ Completado | ...
```

### 2. Verificar que api-admin levanta con mocks

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Verificar variable de entorno
grep -r "USE_MOCK_REPOSITORIES" .zed/debug.json config/
```

**Output esperado:**
```
.zed/debug.json:      "USE_MOCK_REPOSITORIES": "true"
config/config.go:	UseMockRepositories bool   `mapstructure:"use_mock_repositories"`
```

### 3. Hacer test rápido de api-admin

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Compilar
make build

# Ejecutar con mocks
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion &
API_ADMIN_PID=$!

# Esperar 2 segundos
sleep 2

# Test health
curl http://localhost:8081/health

# Matar proceso
kill $API_ADMIN_PID
```

**Output esperado:**
```json
{"status":"ok","timestamp":"..."}
```

## Validación

- [ ] Tracking muestra Sprint 3 completado al 100%
- [ ] Variable USE_MOCK_REPOSITORIES existe en api-admin
- [ ] Api-admin compila sin errores
- [ ] Health check retorna 200 OK

## Si Falla

**Síntoma:** Sprint 3 no completado al 100%
**Solución:** Completar primero api-admin Sprint 0-3

**Síntoma:** Variable USE_MOCK_REPOSITORIES no existe
**Solución:** Ejecutar api-admin Sprint 3 paso 8 (estandarizar config)

**Síntoma:** Health check falla
**Solución:** Revisar logs de api-admin, validar dataset existe

## Siguiente Paso
→ [paso-02-verificar-generador.md]
