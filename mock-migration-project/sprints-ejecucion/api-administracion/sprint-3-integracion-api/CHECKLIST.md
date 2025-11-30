# Sprint 3: Checklist de Progreso

## Estado General
- **Sprint:** 3 - Integracion API Administracion
- **Pasos Totales:** 15
- **Completados:** 0
- **Progreso:** 0%

## Pasos

### Paso 1: Generar Dataset
- [ ] Generador ejecutado exitosamente
- [ ] Archivos creados en api-administracion/mock/dataset
- **Tiempo estimado:** 5 min

### Paso 2: Verificar Dataset Copiado
- [ ] database.go existe
- [ ] 5+ archivos *_table.go existen
- [ ] load_data.go existe
- **Tiempo estimado:** 5 min

### Paso 3: Actualizar UserRepository
- [ ] Codigo reemplazado completamente
- [ ] Usa dataset.DB.Users
- [ ] Compila sin errores
- **Tiempo estimado:** 20 min

### Paso 4: Actualizar SchoolRepository
- [ ] Usa dataset.DB.Schools
- [ ] Compila sin errores
- **Tiempo estimado:** 15 min

### Paso 5: Actualizar AcademicUnitRepository
- [ ] Usa dataset.DB.AcademicUnits
- [ ] Compila sin errores
- **Tiempo estimado:** 15 min

### Paso 6: Actualizar MembershipRepository
- [ ] Usa dataset.DB.Memberships
- [ ] Compila sin errores
- **Tiempo estimado:** 15 min

### Paso 7: Verificar Factory
- [ ] Factory usa NewMockXxxRepository
- [ ] Sin cambios necesarios
- **Tiempo estimado:** 5 min

### Paso 8: Estandarizar Config
- [ ] Variable USE_MOCK_REPOSITORIES en loader.go
- [ ] BindEnv agregado
- **Tiempo estimado:** 10 min

### Paso 9: Actualizar Debug JSON
- [ ] .zed/debug.json actualizado
- [ ] Usa USE_MOCK_REPOSITORIES=true
- **Tiempo estimado:** 5 min

### Paso 10: Borrar Archivos Antiguos
- [ ] Directorio mock/data eliminado
- [ ] Sin archivos hardcodeados
- **Tiempo estimado:** 5 min

### Paso 11: Compilar API
- [ ] make build exitoso
- [ ] Binario bin/api-administracion existe
- [ ] Sin errores de compilacion
- **Tiempo estimado:** 10 min

### Paso 12: Test Health Check
- [ ] API levanta correctamente
- [ ] Health endpoint retorna 200
- [ ] Response JSON correcto
- **Tiempo estimado:** 10 min

### Paso 13: Test Login
- [ ] Login exitoso con admin@edugo.test
- [ ] Token generado
- [ ] User data correcta
- **Tiempo estimado:** 15 min

### Paso 14: Test Endpoints
- [ ] Lista escuelas retorna 3
- [ ] Lista usuarios funciona
- [ ] Sin errores 500
- **Tiempo estimado:** 20 min

### Paso 15: Validacion Final
- [ ] Script test-integration.sh pasa
- [ ] Todos los tests OK
- [ ] Sistema completamente funcional
- **Tiempo estimado:** 20 min

## Tiempo Total Estimado
**2 horas 55 minutos**

## Criterios de Aceptacion del Sprint

### Funcionales
- [ ] API levanta con mocks
- [ ] Login funciona con datos del dataset
- [ ] Endpoints retornan datos correctos
- [ ] Todas las pruebas end-to-end pasan

### Tecnicos
- [ ] Todo compila sin errores
- [ ] Sin warnings de Go
- [ ] Codigo formateado
- [ ] Sin archivos antiguos

### Configuracion
- [ ] Variable USE_MOCK_REPOSITORIES estandarizada
- [ ] .zed/debug.json actualizado
- [ ] Factory configurado correctamente

## Siguiente Paso
Una vez completados todos los criterios:
→ [../../tracking-api-admin.md] (ver resumen general)
