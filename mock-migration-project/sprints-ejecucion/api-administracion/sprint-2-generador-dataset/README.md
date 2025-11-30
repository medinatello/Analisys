# Sprint 2: Generador de Dataset

**Duracion estimada:** 3-4 horas
**Objetivo:** Generar archivos Go del dataset a partir de datos parseados

## Descripcion General

Este sprint implementa el generador que toma los datos parseados del Sprint 1 y genera codigo Go listo para usar. Incluye templates, generacion de tablas, y metodos de acceso.

## Prerequisitos

- Sprint 0 completado
- Sprint 1 completado
- Parser funcionando correctamente

## Pasos del Sprint

1. **paso-01-crear-generador-base.md** - Estructura basica del generador
2. **paso-02-template-database.md** - Template para database.go
3. **paso-03-template-table.md** - Template para *_table.go
4. **paso-04-template-loader.md** - Template para load_data.go
5. **paso-05-generar-database.md** - Implementar generacion de database.go
6. **paso-06-generar-tables.md** - Implementar generacion de tablas
7. **paso-07-generar-loader.md** - Implementar generacion de loader
8. **paso-08-formatear-codigo.md** - Aplicar gofmt a codigo generado
9. **paso-09-integrar-main.md** - Conectar generador con CLI
10. **paso-10-compilar-ejecutar.md** - Compilar y ejecutar generador
11. **paso-11-validar-generacion.md** - Validar archivos generados
12. **paso-12-probar-compilacion.md** - Verificar que codigo generado compila

## Resultado Esperado

Al finalizar, tendras:
- Generador que crea 6+ archivos Go
- Codigo generado que compila sin errores
- Dataset listo para usar en repositories

## Siguiente Sprint

→ [Sprint 3: Integracion API](../sprint-3-integracion-api/README.md)
