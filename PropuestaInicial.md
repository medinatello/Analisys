# Plan de MVP, Fases y Backlog de la Plataforma Educativa

## Objetivo del MVP

El producto mínimo viable (MVP) debe validar que la plataforma permite a los docentes asignar material previo y a los alumnos acceder a dicho material desde sus dispositivos, prepararse mediante resúmenes y actividades y mostrar al docente un resumen del progreso. Este MVP sentará las bases técnicas para escalar a un ecosistema educativo y social.

## Fases de desarrollo

### Fase 1 – Producto mínimo viable (MVP)

Funcionalidades principales:

1. Gestión de usuarios y autenticación: Registro/inicio de sesión para docentes, alumnos y administradores; definición de roles y permisos.
1. Carga de material por el docente: Subir archivos PDF con metadatos (materia, fecha de uso, descripción) y almacenamiento en el servicio de documentos.
1. Generación y visualización de resúmenes: Integración con un servicio de resumen automático (puede ser un modelo local o externo) y presentación de resúmenes al alumno en la app.
1. Actividades de preparación: Cuestionarios de opción múltiple o verdadero/falso relacionados con el contenido; cálculo de puntuación y retroalimentación inmediata.
1. Seguimiento de progreso: Panel para docentes con estadísticas de lectura y resultados de las actividades (quién abrió el material, puntuaciones promedio, etc.).
1. Infraestructura básica de monitorización: Registro de eventos, métricas de uso y rendimiento para detectar fallos tempranamente.

### Fase 2 – Ampliación funcional

- Gamificación y motivación: Sistema de puntos, insignias y niveles por participación; tablas de clasificación por clase.
- Comunicación en clase: Foros de preguntas y chat moderado entre alumnos y docentes.
- Material complementario: Permitir enlaces externos, vídeos o audios; integrar un sistema de recomendaciones que sugiera material adicional según desempeño.
- Panel de administrador de colegio: Estadísticas a nivel institución, gestión de docentes y grupos.

### Fase 3 – Ecosistema social

- Interacción entre colegios: Competencias u olimpiadas académicas; comparativa de estadísticas (p. ej., retos de lectura).
- Perfiles públicos: Muro de logros y portafolio académico del alumno, configurable según políticas de privacidad.
- APIs abiertas: Permitir a terceros (editoriales, instituciones) publicar contenido educativo.

## Historias de usuario del MVP

Cada historia incluye criterios de aceptación y tareas técnicas; estas historias se ampliarán y detallarán en cada sprint.

### 3.1 Como docente, quiero subir un PDF para que mis alumnos lo estudien antes de clase

Criterios de aceptación:

1. Puedo seleccionar un archivo PDF de mi dispositivo.
1. Debo asignar título, materia y fecha de uso.
1. Tras subirlo, el sistema confirma la creación y queda disponible para los alumnos del grupo.

Tareas técnicas:

- Crear API POST /materials en Go que reciba metadatos y archivo; almacenar documento en MongoDB/S3; guardar registro en la base SQL.
- Implementar en KMP una pantalla con formulario de carga y validación.
- Añadir pruebas unitarias para subida de archivos y validación de campos.
- Validar autenticación y rol docente.
- Dependencias: Definición del modelo de datos (SQL y NoSQL); configuración de almacenamiento.

### 3.2 Como alumno, quiero ver un resumen del material asignado para prepararme rápidamente

Criterios de aceptación:

1. Al entrar en la app, veo la lista de tareas asignadas a mi grupo.
1. Al seleccionar una tarea, puedo leer un resumen de 1–2 párrafos generado automáticamente.
1. Puedo marcar la tarea como “leída” o navegar al PDF completo.

Tareas técnicas:

- Endpoint GET /materials/{id}/summary que devuelva el resumen generado; si no existe, desencadena la generación usando un servicio de NLP.
- Implementar en KMP la visualización de la lista de tareas y detalle con resumen.
- Guardar en base SQL un registro de lectura por alumno.
- Dependencias: Motor de resumido (puede ser un servicio independiente); autorización del alumno.

### 3.3 Como alumno, quiero realizar un cuestionario para demostrar que comprendí el material

Criterios de aceptación:

1. Puedo iniciar una actividad asociada al material.
1. Las preguntas se muestran de una en una y tengo retroalimentación inmediata tras responder.
1. Al finalizar, obtengo una puntuación y la app registra mi resultado.

Tareas técnicas:

- API GET /materials/{id}/quiz para obtener preguntas.
- Componente de UI en KMP para presentar preguntas y registrar respuestas.
- API POST /materials/{id}/quiz/answer para almacenar respuestas y calcular puntuación.
- Almacenar resultados en la base SQL.

### 3.4 Como docente, quiero ver quién realizó las tareas y sus puntuaciones

Criterios de aceptación:

1. Accedo a un panel con la lista de tareas que he asignado.
1. Para cada tarea veo qué alumnos la abrieron, su estado (leída/no leída) y su puntuación promedio.
1. Puedo descargar un reporte (CSV) con el detalle por alumno.

Tareas técnicas:

- API GET /materials/{id}/stats que agregue datos de lectura y puntuaciones.
- Pantalla en KMP que presente tablas y gráficos simples.
- Función para exportar el reporte en CSV.

## Plan de sprints sugerido

Se propone iniciar con sprints de dos semanas; cada sprint incluye tareas de backend, frontend, QA y pruebas de integración.