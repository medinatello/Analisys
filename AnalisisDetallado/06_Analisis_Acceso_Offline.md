# Análisis de Requisitos de Acceso sin Conexión (Offline)

[Volver al Índice](./README.md)

## 1. Pregunta Original

Se espera que los alumnos accedan al material desde sus dispositivos. ¿Es un requisito del MVP que puedan consultar los resúmenes o el material completo sin conexión a internet?

## 2. Análisis de Viabilidad e Impacto

Implementar funcionalidades offline añade una capa significativa de complejidad al desarrollo de la aplicación móvil (KMP). Requiere gestionar una base de datos local, sincronización de datos y resolución de conflictos.

### Escenarios de Uso Offline

1.  **Alumno sin acceso a WiFi/datos en casa:** Un caso de uso muy importante para la equidad educativa. El alumno podría sincronizar el material en el colegio para estudiarlo en casa.
2.  **Estudio durante desplazamientos:** En transporte público donde la conexión es intermitente.
3.  **Ahorro de datos móviles:** Descargar el material una sola vez con WiFi.

### Impacto Técnico

Para implementar el acceso offline, se necesitaría:

*   **Base de Datos Local:** Integrar una base de datos en la aplicación KMP, como **SQLDelight**, que funciona en Android y iOS.
*   **Caché de Archivos:** Almacenar los PDFs descargados en el sistema de archivos del dispositivo.
*   **Lógica de Sincronización:**
    *   **Descarga:** Cuando el alumno abre un material con conexión, la app debe guardarlo en la base de datos local y descargar el PDF.
    *   **Detección de Conexión:** La app debe saber si está online u offline para decidir si busca datos en la API o en la base de datos local.
    *   **Actualización en Segundo Plano:** (Opcional, más complejo) Un servicio que descargue nuevo material automáticamente cuando haya conexión.
*   **Gestión de Estado:** La UI debe reflejar claramente qué material está disponible offline y el estado de la sincronización.
*   **Sincronización de Progreso:** Si el alumno completa una actividad offline, el resultado debe guardarse localmente y enviarse al servidor cuando se recupere la conexión. Esto introduce complejidad para evitar la pérdida de datos.

## 3. Propuesta para el MVP

Dada la complejidad, se proponen dos enfoques:

### Enfoque 1: MVP sin Capacidad Offline (Recomendado)

*   **Descripción:** La aplicación requiere una conexión a internet para todas sus funciones. No se implementa base de datos local ni sincronización.
*   **Ventajas:**
    *   **Desarrollo mucho más rápido:** Permite centrarse en las funcionalidades clave y validar la propuesta de valor principal.
    *   **Menor complejidad y menos bugs:** La gestión de estado online/offline es una fuente común de errores.
*   **Desventajas:**
    *   Excluye a los alumnos sin conexión fiable, lo que puede ser un problema crítico dependiendo del público objetivo.
*   **Justificación:** El objetivo del MVP es **validar la hipótesis principal** (¿es útil la preparación asíncrona?). La funcionalidad offline, aunque importante, puede considerarse una mejora sobre esa base.

### Enfoque 2: MVP con Offline Mínimo Viable

*   **Descripción:** Implementar una capacidad de "solo lectura" offline.
    *   El alumno puede marcar explícitamente un material para "Guardar offline".
    *   La app descarga el PDF y el texto del resumen/cuestionario.
    *   El alumno puede leer el material y el resumen sin conexión.
    *   **Importante:** Para realizar el cuestionario y enviar los resultados, **se requerirá conexión**. No se sincronizarán los resultados.
*   **Ventajas:**
    *   Resuelve el caso de uso principal de "estudiar sin conexión".
    *   Evita la complejidad de la sincronización de datos de escritura (resultados de cuestionarios).
*   **Desventajas:**
    *   Añade un tiempo de desarrollo considerable al MVP (estimación: 2-3 semanas adicionales de trabajo en la app móvil).

## 4. Recomendación Final

Se recomienda proceder con el **Enfoque 1 (Sin capacidad offline para el MVP)**.

**Plan de Acción:**
1.  Lanzar el MVP lo más rápido posible para validar la aceptación de la herramienta por parte de docentes y alumnos en un entorno con conectividad.
2.  Recopilar feedback de los usuarios. Si la falta de acceso offline es identificada como el principal bloqueador para la adopción, su desarrollo deberá ser la **máxima prioridad para la Fase 2**.
3.  La arquitectura (con repositorios, etc.) debe diseñarse desde el principio pensando en que en el futuro se añadirá una fuente de datos local, facilitando la transición.

Esta estrategia equilibra la velocidad de entrega del MVP con la importancia reconocida de la funcionalidad offline a medio plazo.
