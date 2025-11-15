# 📝 Información Faltante para Desarrollo Desatendido

## Resumen Ejecutivo
La documentación, aunque detallada en la `spec-01`, presenta grandes vacíos en las demás especificaciones y en la documentación aislada. La información más crítica que falta se refiere a los contratos de datos (schemas de BD, de eventos y de APIs) y a las especificaciones de implementación para 4 de los 5 proyectos. Sin esta información, es imposible iniciar el desarrollo de la mayor parte del ecosistema.

## Por Categoría

### Schemas de Base de Datos
- [❌] **`api-admin`:** No se proporciona el schema SQL para las tablas de jerarquía (`schools`, `academic_units`, `unit_membership`).
- [❌] **`worker`:** No se define el schema para las tablas de auditoría y logging que se mencionan en sus responsabilidades.
- [❌] **`shared`:** No aplica, ya que es una librería sin BD propia.
- [❌] **`dev-environment`:** Faltan los scripts `init.sql` consolidados para crear TODAS las tablas del ecosistema de una sola vez.
- [⚠️] **`api-mobile`:** El schema para `spec-01` está bien definido, pero no se especifica cómo evolucionará para futuras specs.

### Contratos de API
- [❌] **OpenAPI/Swagger Specs:** No se proporciona una especificación formal de OpenAPI para ninguna de las APIs. Los `API_CONTRACTS.md` están mayormente vacíos.
- [❌] **Formatos de Error:** No hay una estandarización del formato JSON para las respuestas de error (ej. `{"error": "code", "message": "description"}`).
- [❌] **Headers HTTP:** No se especifican los headers HTTP esperados en requests y responses (ej. `X-Request-ID` para trazabilidad).
- [❌] **Paginación:** Se menciona la paginación, pero no se define la estructura del response (ej. `{"data": [...], "pagination": {"total": 100, "limit": 10, "offset": 0}}`).

### Configuración
- [❌] **Variables de Entorno:** No existe un archivo `VARIABLES_ENTORNO.md` consolidado. Cada proyecto menciona algunas variables, pero faltan detalles críticos.
- [❌] **Valores por Defecto:** No se especifican valores default para configuraciones como timeouts de conexión, límites de pool, etc.
- [❌] **Manejo de Secretos:** No se define una estrategia para el manejo de secretos (`JWT_SECRET`, `OPENAI_API_KEY`, passwords de BD). ¿Se usan variables de entorno, un vault, o sops?

### Eventos y Mensajería
- [❌] **Schemas de Eventos:** Falta la definición de la estructura JSON para TODOS los eventos de RabbitMQ (`material.created`, `evaluation.submitted`, `config.updated`, etc.).
- [❌] **Configuración de RabbitMQ:** No se especifica la configuración de los exchanges, colas y bindings (ej. tipo de exchange, durabilidad, etc.).
- [❌] **Estrategia de NACK/Reintentos:** No se detalla qué hacer cuando un mensaje falla. ¿Se reencola? ¿Va a una Dead Letter Queue (DLQ)?

## Por Proyecto

### edugo-shared (`spec-04-shared`)
- [❌] **TODO:** La especificación está completamente vacía. Falta definir:
  - API pública de cada módulo (`logger`, `database`, `auth`, `messaging`).
  - Structs de datos compartidos.
  - Estrategia de versionado y publicación del módulo Go.

### edugo-worker (`spec-02-worker`)
- [❌] **TODO:** La especificación está completamente vacía. Falta definir:
  - Lógica de extracción de texto de PDFs.
  - Prompts exactos para la integración con OpenAI.
  - Lógica de negocio para el procesamiento y calificación.
  - Schema de la base de datos de auditoría.
  - Implementación de los consumidores de RabbitMQ.

### edugo-api-administracion (`spec-03-api-administracion`)
- [❌] **TODO:** La especificación está completamente vacía. Falta definir:
  - Schema SQL completo para la jerarquía académica.
  - Implementación de los endpoints CRUD.
  - Lógica para las queries recursivas del árbol jerárquico.
  - Reglas de negocio para la gestión de membresías.

### edugo-dev-environment (`spec-05-dev-environment`)
- [❌] **TODO:** La especificación está completamente vacía. Falta definir:
  - El `docker-compose.yml` completo.
  - Los `Dockerfile` para cada servicio.
  - Los scripts de inicialización (`init.sql`, `seed.js`).
  - La configuración de red entre los contenedores.

### edugo-api-mobile (`spec-01-evaluaciones`)
- [⚠️] **Contratos de Eventos:** Falta el schema de los eventos que debe publicar (ej. `evaluation.submitted`).
- [⚠️] **Especificación OpenAPI:** Falta un archivo `openapi.yaml` formal que defina todos los endpoints, requests y responses.
- [⚠️] **Estructura de Carpetas:** El `EXECUTION_ORDER.md` menciona una estructura de archivos (`pkg/evaluation/models.go`, etc.) que no se refleja en la documentación del proyecto aislado.
