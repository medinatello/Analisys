# Sprint 1: Parser SQL Basico

**Duracion estimada:** 2-3 horas
**Objetivo:** Crear parser que lea archivos SQL de testing y extraiga datos INSERT

## Descripcion General

Este sprint implementa el parser SQL usando pingcap/tidb/parser para extraer datos de los archivos de migraciones de testing. Al finalizar, tendras un CLI funcional que puede parsear archivos SQL y mostrar estadisticas.

## Prerequisitos

- Sprint 0 completado
- Go 1.21+ instalado
- Dependencias descargadas

## Pasos del Sprint

1. **paso-01-crear-main.md** - Crear CLI principal con Cobra
2. **paso-02-crear-parser-basico.md** - Crear estructura del parser
3. **paso-03-implementar-parse-directory.md** - Parsear directorio completo
4. **paso-04-extraer-insert-data.md** - Extraer datos de INSERT statements
5. **paso-05-evaluar-expresiones.md** - Evaluar valores y funciones SQL
6. **paso-06-crear-tipos.md** - Definir estructuras de datos
7. **paso-07-implementar-mapeos.md** - Mapear tablas a entities
8. **paso-08-compilar-binario.md** - Compilar el generador
9. **paso-09-probar-parser.md** - Ejecutar y validar parser
10. **paso-10-validar-output.md** - Verificar datos extraidos

## Resultado Esperado

Al finalizar, tendras:
- Binario `bin/mock-generator` funcional
- Parser que extrae datos de 5 archivos SQL
- Output mostrando estadisticas por tabla

## Siguiente Sprint

→ [Sprint 2: Generador Dataset](../sprint-2-generador-dataset/README.md)
