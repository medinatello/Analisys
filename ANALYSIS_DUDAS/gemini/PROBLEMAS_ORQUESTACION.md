# 🔄 Problemas de Orquestación Detectados

## Resumen Ejecutivo
El principal problema de orquestación es una **dependencia circular implícita** entre la librería `edugo-shared` y los servicios que la consumen. El plan de implementación sugiere que `shared` debe existir primero, pero su contenido se define a partir de la consolidación de código que aún no se ha escrito en otros proyectos. Esto crea un punto muerto que impediría a una IA iniciar el desarrollo de forma lógica.

## Orden de Desarrollo

### Problemas Encontrados

#### 1. Dependencia Circular en la Creación de `edugo-shared`
**Ubicación:** `AnalisisEstandarizado/MASTER_PLAN.md` y `AnalisisEstandarizado/00-Overview/EXECUTION_ORDER.md`.
**Documentado:**
- `EXECUTION_ORDER.md` establece que `api-mobile` y `api-admin` dependen de `edugo-shared v1.3.0` y que `shared` debe implementarse primero.
- `MASTER_PLAN.md` establece que el alcance de `spec-04-shared` es "Consolidar logger, database, auth de api-mobile".
**Problema:** Esto crea una dependencia circular. No se puede "consolidar" código de `api-mobile` si `api-mobile` aún no se ha desarrollado. Y `api-mobile` no se puede desarrollar porque espera que `shared` ya exista. Una IA quedaría atrapada en este bucle lógico.
**Solución Propuesta:**
1.  **Redefinir el alcance de `spec-04-shared`:** En lugar de "consolidar" código existente, la spec debe **definir desde cero** las interfaces y structs para los módulos compartidos (`logger`, `database`, `auth`, etc.).
2.  **Implementar `spec-04-shared` primero:** Desarrollar y publicar la primera versión de `edugo-shared` como un proyecto independiente, sin ninguna dependencia de otros servicios del ecosistema.
3.  **Actualizar `spec-01`, `spec-02`, `spec-03`:** Estos specs deben **importar y utilizar** los módulos de la librería `shared` ya publicada, en lugar de definir sus propias implementaciones locales.

## Dependencias

### Dependencias No Resueltas

#### 1. Versiones de `edugo-shared` no especificadas
**Problema:** El `EXECUTION_ORDER.md` menciona `v1.3.0` y `v1.4.0` de `shared`, pero no se especifica qué funcionalidades o cambios contiene cada versión. Una IA no puede saber qué versión usar o qué esperar de ella.
**Impacto:** Imposible gestionar las dependencias de Go correctamente. `go get` fallaría o traería una versión incorrecta del módulo.
**Solución:** Crear un `CHANGELOG.md` o un plan de releases para `edugo-shared` que detalle el contenido de cada versión semántica. Por ejemplo:
- **v1.3.0:** Incluye módulos `logger` y `database`.
- **v1.4.0:** Agrega el módulo `ai` con el cliente de OpenAI.

#### 2. Contratos de Eventos Asíncronos
**Problema:** La comunicación entre `api-mobile` y `worker` se basa en eventos de RabbitMQ, pero los schemas de estos eventos no están definidos. Esto es una dependencia de contrato no resuelta.
**Impacto:** El `worker` (consumidor) y `api-mobile` (productor) no pueden desarrollarse de forma independiente porque no hay un acuerdo sobre cómo se verán los datos que intercambian.
**Solución:** Crear un documento `EVENT_CONTRACTS.md` que sirva como la "fuente de la verdad" para todos los schemas de eventos.

### Dependencias Circulares
- **Crítica:** Se detectó una dependencia circular implícita en el plan de desarrollo de `edugo-shared` (ver sección "Orden de Desarrollo").
- **Estado:** No existen dependencias circulares a nivel de código (ya que el código no está escrito), pero el plan de implementación actual las generaría si se sigue al pie de la letra.

## Desarrollo en Paralelo

### Qué SÍ se puede desarrollar en paralelo
Una vez que `edugo-shared` (con sus interfaces y modelos base) esté definido y publicado:
- ✅ `api-mobile` (spec-01)
- ✅ `api-admin` (spec-03)
- ✅ `worker` (spec-02)

Estos tres servicios podrían ser desarrollados en paralelo por equipos (o IAs) diferentes, **siempre y cuando** los contratos entre ellos (APIs REST y eventos asíncronos) estén completamente definidos de antemano.

### Qué NO se puede desarrollar en paralelo
- ❌ **`edugo-shared` y cualquier otro servicio:** La librería compartida es una dependencia fundamental y debe existir antes que cualquier otro servicio pueda empezar su desarrollo.
- ❌ **`worker` y `api-mobile` sin contratos de eventos:** El `worker` no puede empezar a implementar sus consumidores hasta que `api-mobile` haya definido los eventos que va a publicar.
- ❌ **`dev-environment` y el resto:** El entorno de desarrollo depende de que existan las imágenes Docker de todos los demás servicios, por lo que debe ser el último en consolidarse.
