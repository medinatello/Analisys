# Sprint 2: Checklist de Progreso

## Estado General
- **Sprint:** 2 - Generador Dataset
- **Pasos Totales:** 12
- **Completados:** 0
- **Progreso:** 0%

## Pasos

### Paso 1: Crear Estructura Base del Generador
- [ ] Archivo pkg/generator/dataset_generator.go existe
- [ ] Struct DatasetGenerator definida
- [ ] Metodo Generate stub creado
- **Tiempo estimado:** 15 min
- **Archivo:** paso-01-crear-generador-base.md

### Paso 2: Template para database.go
- [ ] Constante databaseTemplate definida
- [ ] Metodo generateDatabase implementado
- [ ] Template genera struct MockDatabase
- **Tiempo estimado:** 20 min
- **Archivo:** paso-02-template-database.md

### Paso 3: Template para Tablas
- [ ] Constante tableTemplate definida
- [ ] Template incluye FindByID
- [ ] Template incluye List
- **Tiempo estimado:** 25 min
- **Archivo:** paso-03-template-table.md

### Paso 4: Template para Loader
- [ ] Constante loaderTemplate definida
- [ ] Template genera LoadAllData
- [ ] Template genera funciones load por tabla
- **Tiempo estimado:** 20 min
- **Archivo:** paso-04-template-loader.md

### Paso 5: Implementar Generacion database.go
- [ ] Metodo generateDatabase integrado en Generate()
- [ ] Codigo compila
- **Tiempo estimado:** 15 min
- **Archivo:** paso-05-generar-database.md

### Paso 6: Implementar Generacion de Tablas
- [ ] Metodo generateTables implementado
- [ ] Metodo generateTable implementado
- [ ] Funcion getEntityName implementada
- **Tiempo estimado:** 25 min
- **Archivo:** paso-06-generar-tables.md

### Paso 7: Implementar Generacion Loader
- [ ] Metodo generateLoader implementado
- [ ] Integrado en Generate()
- **Tiempo estimado:** 20 min
- **Archivo:** paso-07-generar-loader.md

### Paso 8: Formatear Codigo Generado
- [ ] gofmt integrado en Generate()
- [ ] Comando exec.Command configurado
- **Tiempo estimado:** 10 min
- **Archivo:** paso-08-formatear-codigo.md

### Paso 9: Integrar Generador con Main
- [ ] Import de pkg/generator en main.go
- [ ] runGenerator actualizado
- [ ] Flujo completo: parse → generate
- **Tiempo estimado:** 15 min
- **Archivo:** paso-09-integrar-main.md

### Paso 10: Compilar y Ejecutar
- [ ] Binario compila sin errores
- [ ] Generador se ejecuta correctamente
- [ ] Crea archivos en directorio output
- **Tiempo estimado:** 10 min
- **Archivo:** paso-10-compilar-ejecutar.md

### Paso 11: Validar Archivos Generados
- [ ] database.go existe
- [ ] 5+ archivos *_table.go existen
- [ ] load_data.go existe
- [ ] Archivos tienen contenido correcto
- **Tiempo estimado:** 15 min
- **Archivo:** paso-11-validar-generacion.md

### Paso 12: Probar Compilacion
- [ ] Codigo generado compila
- [ ] Sin errores de sintaxis
- [ ] Imports se resuelven
- **Tiempo estimado:** 15 min
- **Archivo:** paso-12-probar-compilacion.md

## Tiempo Total Estimado
**3 horas 25 minutos**

## Criterios de Aceptacion del Sprint

### Funcionales
- [ ] Generador crea database.go con singleton
- [ ] Generador crea *_table.go para cada tabla
- [ ] Generador crea load_data.go con stubs
- [ ] gofmt aplicado a codigo generado

### Tecnicos
- [ ] Todo el generador compila sin errores
- [ ] Templates correctamente definidos
- [ ] Codigo generado es valido Go

### Validacion
- [ ] Al menos 7 archivos generados
- [ ] Codigo generado compila (aunque sin datos)
- [ ] Estructura correcta de tipos y metodos

## Siguiente Sprint
Una vez completados todos los criterios:
→ [../sprint-3-integracion-api/README.md]
