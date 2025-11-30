# Sprint 1: Reutilizar Generador (Copiar Dataset)

**Duración estimada:** 1-2 horas
**Objetivo:** Ejecutar generador de api-admin y copiar dataset.go a api-mobile

## Descripción General

Este sprint **REUTILIZA** el generador ya creado en api-admin. NO creamos un generador nuevo, solo ejecutamos el existente y copiamos el output.

## Prerequisitos

- ✅ Sprint 0 completado
- ✅ Generador edugo-mock-generator funcional
- ✅ SQL testing accesible

## Pasos del Sprint

1. **paso-01-ejecutar-generador.md** - Ejecutar generador con SQL testing
2. **paso-02-verificar-output.md** - Verificar archivos generados
3. **paso-03-crear-directorio-mock.md** - Crear estructura en api-mobile
4. **paso-04-copiar-dataset.md** - Copiar dataset.go a api-mobile
5. **paso-05-ajustar-package.md** - Ajustar package name si necesario
6. **paso-06-validar-compilacion.md** - Validar que compila
7. **paso-07-comparar-con-admin.md** - Comparar con dataset de api-admin
8. **paso-08-probar-imports.md** - Probar imports y dependencias

## Resultado Esperado

Al finalizar, tendrás:
- Dataset.go generado y copiado a api-mobile
- Package "mock" configurado
- Compilación sin errores
- Mismo dataset que api-admin (PostgreSQL)

## Siguiente Sprint

→ [Sprint 2: Implementar Fixtures](../sprint-2-implementar-fixtures/README.md)
