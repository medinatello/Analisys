# Sprint 1: Checklist de Progreso

## Estado General
- **Sprint:** 1 - Parser SQL
- **Pasos Totales:** 10
- **Completados:** 0
- **Progreso:** 0%

## Pasos

### Paso 1: Crear CLI Principal
- [ ] Archivo cmd/main.go existe
- [ ] Codigo compila
- [ ] Binario se genera
- **Tiempo estimado:** 15 min
- **Archivo:** paso-01-crear-main.md

### Paso 2: Crear Estructura del Parser
- [ ] Archivo pkg/parser/types.go existe
- [ ] Archivo pkg/parser/sql_parser.go existe
- [ ] Package compila
- **Tiempo estimado:** 20 min
- **Archivo:** paso-02-crear-parser-basico.md

### Paso 3: Implementar ParseDirectory
- [ ] Metodo ParseDirectory implementado
- [ ] Lee archivos .sql
- [ ] Parsea statements
- **Tiempo estimado:** 20 min
- **Archivo:** paso-03-implementar-parse-directory.md

### Paso 4: Extraer Datos de INSERT
- [ ] Metodo extractInsertData implementado
- [ ] Extrae nombre de tabla
- [ ] Extrae columnas y valores
- **Tiempo estimado:** 25 min
- **Archivo:** paso-04-extraer-insert-data.md

### Paso 5: Evaluar Expresiones SQL
- [ ] Metodo evalExpr implementado
- [ ] Maneja valores literales
- [ ] Maneja funciones SQL (NOW, UUID)
- **Tiempo estimado:** 20 min
- **Archivo:** paso-05-evaluar-expresiones.md

### Paso 6: Crear Mapeos de Tipos
- [ ] Archivo pkg/types/mappings.go existe
- [ ] Mapa TableToEntity definido
- [ ] Mapa TableToCamel definido
- **Tiempo estimado:** 15 min
- **Archivo:** paso-06-crear-tipos.md

### Paso 7: Integrar Parser con Main
- [ ] Import de pkg/parser en main.go
- [ ] Funcion runGenerator actualizada
- [ ] Muestra estadisticas
- **Tiempo estimado:** 15 min
- **Archivo:** paso-07-implementar-mapeos.md

### Paso 8: Compilar Binario Final
- [ ] Binario bin/mock-generator compilado
- [ ] Binario es ejecutable
- [ ] Help funciona
- **Tiempo estimado:** 5 min
- **Archivo:** paso-08-compilar-binario.md

### Paso 9: Ejecutar y Probar Parser
- [ ] Parser se ejecuta sin errores
- [ ] Detecta 5+ archivos SQL
- [ ] Muestra estadisticas correctas
- **Tiempo estimado:** 10 min
- **Archivo:** paso-09-probar-parser.md

### Paso 10: Validar Datos Extraidos
- [ ] users: 8 registros
- [ ] schools: 3 registros
- [ ] academic_units: 5 registros
- [ ] memberships: 12 registros
- [ ] materials: 3 registros
- **Tiempo estimado:** 15 min
- **Archivo:** paso-10-validar-output.md

## Tiempo Total Estimado
**2 horas 40 minutos**

## Criterios de Aceptacion del Sprint

### Funcionales
- [ ] Parser lee directorio de archivos SQL
- [ ] Extrae datos de INSERT statements
- [ ] Identifica correctamente tablas y columnas
- [ ] Evalua funciones SQL (NOW, UUID)

### Tecnicos
- [ ] Todo el codigo compila sin errores
- [ ] Binario ejecutable generado
- [ ] Sin warnings de Go
- [ ] Codigo formateado con gofmt

### Validacion
- [ ] Script validate.sh pasa todas las pruebas
- [ ] Output muestra 5 tablas
- [ ] Numeros de registros coinciden con SQL

## Siguiente Sprint
Una vez completados todos los criterios:
→ [../sprint-2-generador-dataset/README.md]
