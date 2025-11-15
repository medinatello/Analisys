# Análisis carpeta `AnalisisEstandarizado`

## Contexto
El README principal (`AnalisisEstandarizado/README.md`) promete una estructura completa con overview, requirements, design, testing y deployment globales para habilitar trabajo cross-repo sin ambigüedad. Al revisar la carpeta real hay huecos importantes que impedirían arrancar tareas sin pedir más información.

## Dudas y bloqueos detectados

1. **Estructura global prometida pero incompleta**  
   - En `AnalisisEstandarizado/README.md:24-74` se listan archivos como `FUNCTIONAL_SPECS.md`, `TECHNICAL_SPECS.md`, `ARCHITECTURE.md`, etc.  
   - En la carpeta real `01-Requirements/` solo existe `PRD.md`; `02-Design/`, `04-Testing/` y `05-Deployment/` están completamente vacíos.  
   - **Duda:** ¿Dónde están las especificaciones funcionales/técnicas, los modelos de datos y las guías de testing/deployment globales que necesito para orquestar los cinco repositorios?

2. **Archivos globales referenciados pero inexistentes**  
   - El mismo README (líneas 76-77) indica que en la raíz debería haber `TRACKING_SYSTEM.json` y `EXECUTION_GUIDE.md`. Ninguno está presente (solo existe `MASTER_PROGRESS.json`).  
   - **Duda:** ¿Qué archivo debo usar como fuente de verdad para tracking global y para la guía de ejecución por IA?

3. **`03-Specifications/` solo contiene Spec-01**  
   - El README (`AnalisisEstandarizado/README.md:60-64`) afirma que existen `Spec-02-Procesamiento-IA`, `Spec-03-Integracion`, etc., pero `AnalisisEstandarizado/03-Specifications/` únicamente contiene `Spec-01-Sistema-Evaluaciones`.  
   - **Duda:** ¿Dónde están las especificaciones 02-05 dentro del modelo cross? Sin ellas no puedo preparar tareas coordinadas para worker, shared, etc.

4. **Doble fuente de especificaciones sin criterio de sincronización**  
   - Además de `03-Specifications/Spec-01-...` hay carpetas paralelas en la raíz (`spec-01-evaluaciones`, `spec-02-worker`, `spec-03-api-administracion`, `spec-04-shared`, `spec-05-dev-environment`).  
   - No hay documentación que explique cuál de las dos estructuras es la fuente canónica ni cómo mantenerlas sincronizadas.  
   - **Duda:** ¿Con qué carpeta debo trabajar cuando una tarea hace referencia a "Spec-01"? ¿Cuál debo actualizar para que el resto del ecosistema quede alineado?

5. **Carpetas por proyecto dentro de Spec-01 carecen de REQUIREMENTS/DESIGN/VALIDATION**  
   - El README promete que cada proyecto en `03-Specifications/Spec-01...` tendrá `REQUIREMENTS.md`, `DESIGN.md`, `TASKS.md` y `VALIDATION.md` (`AnalisisEstandarizado/README.md:42-58`).  
   - En la práctica, directorios como `AnalisisEstandarizado/03-Specifications/Spec-01-Sistema-Evaluaciones/01-shared` o `02-api-mobile` solo incluyen `TASKS.md` (en `03-api-administracion` incluso aparece solo `TASKS.md` y `TASKS_COMPLETE.md`).  
   - **Duda:** ¿Dónde están los requisitos detallados, el diseño y los criterios de validación por repo para Spec-01? Sin ellos no puedo garantizar cero ambigüedad.

6. **Dependencia de versión inconsistente para `edugo-shared`**  
   - En `AnalisisEstandarizado/03-Specifications/Spec-01-Sistema-Evaluaciones/README.md:404` se marca como prerequisito "edugo-shared v1.2.0 disponible".  
   - El mismo documento (línea 425) y `01-shared/TASKS.md:6` trabajan sobre publicar `v1.3.0`.  
   - **Duda:** ¿Cuál es la versión objetivo que deben consumir las APIs y el worker? Esta inconsistencia bloquea la planificación de dependencias (`go.mod`, eventos, etc.).

## Riesgo
Hasta que estas dudas no se resuelvan, cualquier IA/contribuidor que intente ejecutar el plan cross no tiene la guía detallada ni el tracking global prometido, lo que contradice el principio de "cero ambigüedad".
