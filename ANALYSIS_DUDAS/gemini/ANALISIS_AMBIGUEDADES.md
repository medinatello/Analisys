# 🔍 Análisis de Ambigüedades - Documentación EduGo

## Resumen Ejecutivo
Se han encontrado **4 ambigüedades críticas (bloqueantes)** que impedirían el desarrollo desatendido por una IA. Estas ambigüedades se centran en la falta de contratos explícitos entre servicios, la ausencia de una fuente de verdad para la autenticación y la especificación incompleta de dependencias críticas. Sin resolver estos puntos, una IA no podría tomar decisiones fundamentales sobre la arquitectura y la implementación.

## Ambigüedades Críticas (Bloqueantes)

### 1. Autoridad de Autenticación y Gestión de Usuarios
**Ubicación:** Múltiples archivos, incluyendo `AnalisisEstandarizado/00-Overview/PROJECTS_MATRIX.md` y `spec-01-evaluaciones/02-Design/SECURITY_DESIGN.md`.
**Descripción:** La documentación menciona roles (student, teacher, admin) y autenticación JWT, pero no especifica qué servicio es la autoridad central para la gestión de usuarios y la emisión de tokens.
**Por qué es ambiguo:** Una IA no puede decidir qué servicio debe manejar el registro, login y la generación de JWTs. ¿Es `api-mobile`? ¿`api-admin`? ¿Un servicio de identidad no documentado? Esto afecta la implementación de la seguridad en todo el ecosistema.
**Impacto:** Desarrollo de la autenticación y autorización bloqueado en todos los servicios. No se puede implementar un middleware de seguridad coherente.
**Información necesaria:** Definir explícitamente el servicio de identidad (IdP). Especificar los endpoints de login, registro y refresh de tokens.
**Solución propuesta:** Designar a `api-admin` como el servicio responsable de la gestión de usuarios y la emisión de tokens JWT. `api-mobile` y otros servicios validarían los tokens emitidos por `api-admin`.

### 2. Contenido y Versionado de la Librería `edugo-shared`
**Ubicación:** `AnalisisEstandarizado/00-Overview/EXECUTION_ORDER.md`.
**Descripción:** El plan de ejecución dicta que `api-mobile` y `api-admin` dependen de `edugo-shared v1.3.0`, y el `worker` de `v1.4.0`. Sin embargo, la especificación `spec-04-shared` está vacía y no hay documentación que defina el contenido (módulos, funciones, structs) de estas versiones.
**Por qué es ambiguo:** Es imposible para una IA comenzar el desarrollo de `api-mobile`, `api-admin` o `worker` sin conocer las interfaces, modelos y utilidades que debe proveer la librería `shared`. No se puede "adivinar" el contenido de un módulo versionado.
**Impacto:** Desarrollo de todos los proyectos bloqueado. No se pueden importar los paquetes necesarios ni utilizar las funciones compartidas.
**Información necesaria:** Una especificación completa para `spec-04-shared` que detalle los módulos a crear (`logger`, `database`, `auth`, `messaging`), sus interfaces públicas, los structs de datos y el plan de versionado.
**Solución propuesta:** Completar la especificación `spec-04-shared` ANTES de iniciar cualquier otro sprint de implementación. Esta spec debe definir el API de cada módulo compartido.

### 3. Contrato de Eventos de Mensajería (RabbitMQ)
**Ubicación:** `AnalisisEstandarizado/00-Overview/EXECUTION_ORDER.md` y `PROJECTS_MATRIX.md`.
**Descripción:** Se menciona que los servicios se comunican por eventos (ej. `api-mobile` publica `evaluation.submitted` y `worker` lo consume), pero no se define la estructura (schema) de estos eventos.
**Por qué es ambiguo:** El `worker` no puede implementar un consumidor si no conoce la estructura exacta del JSON que recibirá. ¿Qué campos contiene el evento `evaluation.submitted`? ¿Qué tipos de datos son? ¿Hay campos opcionales?
**Impacto:** Desarrollo del `worker` y de los publicadores de eventos en las APIs está bloqueado.
**Información necesaria:** Un documento de "Contratos de Eventos" que defina el schema JSON para cada evento del sistema, incluyendo `material.created`, `evaluation.submitted`, `config.updated`, `evaluation.completed`, etc.
**Solución propuesta:** Crear un archivo `02-Design/EVENT_CONTRACTS.md` en `AnalisisEstandarizado` que contenga los schemas JSON para cada evento, versionando los contratos si es necesario.

### 4. Origen y Estructura de los Datos en MongoDB
**Ubicación:** `spec-01-evaluaciones/02-Design/DATA_MODEL.md` y `TECHNICAL_SPECS.md`.
**Descripción:** Se especifica que `api-mobile` lee las preguntas de la colección `material_assessment` en MongoDB, y que el `worker` es quien las genera. Sin embargo, no se detalla el proceso de generación ni se garantiza la consistencia de la estructura.
**Por qué es ambiguo:** La IA que implementa `api-mobile` no tiene garantías sobre la estructura de los datos que encontrará en MongoDB. ¿Qué pasa si el `worker` falla o cambia el formato? ¿Cómo se versionan los schemas de los documentos en MongoDB?
**Impacto:** `api-mobile` podría fallar al intentar leer datos de MongoDB si el formato no es el esperado. La robustez del sistema es baja.
**Información necesaria:** Definir un schema de validación estricto para las colecciones de MongoDB. Documentar el proceso de generación y versionado de estos documentos por parte del `worker`.
**Solución propuesta:** Implementar validación de schema en MongoDB (usando `$jsonSchema`). El `worker` debe adherirse a este schema. `api-mobile` debe tener lógica para manejar documentos que no pasen la validación o que correspondan a una versión antigua del schema.

## Ambigüedades Menores (No bloqueantes)

- **Roles y Permisos:** La matriz de permisos en `PROJECTS_MATRIX.md` es un buen comienzo, pero no es exhaustiva. Por ejemplo, ¿un `teacher` puede ver los intentos de todos los estudiantes de su escuela o solo de sus unidades académicas asignadas? Una IA podría asumir el menor privilegio, pero sería una suposición.
- **Configuración de CI/CD:** Los documentos de los sprints mencionan CI/CD, pero no hay una especificación global sobre la estrategia (ej. triggers para deploy a staging/prod, manejo de secretos en CI).
- **Estrategia de Logging:** Se menciona el uso de un logger compartido, pero no se definen los niveles de log estándar para diferentes tipos de eventos (ej. `INFO` para inicios de request, `DEBUG` para queries, `WARN` para reintentos).
- **Valores de Configuración por Defecto:** Faltan valores por defecto para variables de entorno como timeouts, límites de pool de conexiones, etc.
