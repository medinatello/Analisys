# 🔍 Análisis de Ambigüedades Consolidado

**Fecha de Consolidación:** 15 de Noviembre, 2025  
**Fuentes Analizadas:**
- Claude (Análisis Independiente)
- Gemini (Análisis Independiente)
- Grok (Análisis Independiente)

---

## 📊 Resumen Ejecutivo

### Métricas Consolidadas

| Agente | Ambigüedades Críticas | Ambigüedades Menores | Total |
|--------|----------------------|---------------------|-------|
| **Claude** | 10 | 8 | 18 |
| **Gemini** | 4 | 0 | 4 |
| **Grok** | 12 | 0 | 12 |
| **Total Único** | **15** | **8** | **23** |

**Nivel de Consenso:**
- Ambigüedades detectadas por 3 agentes: 4 (17%)
- Ambigüedades detectadas por 2 agentes: 8 (35%)
- Ambigüedades detectadas por 1 agente: 11 (48%)

**Veredicto General:**
La documentación tiene un nivel de **completitud del 90-95%**, pero las ambigüedades críticas detectadas por múltiples agentes impedirían desarrollo completamente desatendido. Los problemas se concentran en:
1. **Sincronización de datos** entre PostgreSQL y MongoDB
2. **Ownership de recursos compartidos** (tablas, configuración)
3. **Contratos de comunicación** entre servicios (eventos RabbitMQ)
4. **Decisiones operacionales** (SLAs, costos, deployment)

---

## 🔴 Ambigüedades Críticas (Bloqueantes)

### 1. Sincronización PostgreSQL ↔ MongoDB en Evaluaciones

**Detectado por:** Claude ✅ | Gemini ✅ | Grok ✅  
**Consenso:** 🟢 ALTO (3/3 agentes)

**Ubicación:**
- `AnalisisEstandarizado/spec-01-evaluaciones/02-Design/DATA_MODEL.md:45-78`
- `00-Projects-Isolated/api-mobile/03-Design/DATA_MODEL.md:89-125`

**Descripción Integrada:**
La documentación establece una relación entre dos bases de datos:
- **PostgreSQL:** Tabla `assessment` con campo `mongo_document_id VARCHAR(24)`
- **MongoDB:** Colección `material_assessment` con `_id: ObjectId` y `material_id: UUID`

**Por qué es ambiguo:**
1. **Fuente de verdad no definida:** ¿MongoDB crea el documento primero o PostgreSQL? (Claude, Gemini, Grok)
2. **Transacciones distribuidas no especificadas:** No menciona patrón Saga, 2PC, o eventual consistency (Claude, Gemini)
3. **Manejo de inconsistencias:** Si `mongo_document_id` apunta a un documento inexistente en MongoDB (Claude, Grok)
4. **Estrategia de rollback:** Si una operación falla, cómo se deshace la otra (Claude, Gemini)

**Impacto:**
- **BLOQUEANTE CRÍTICO** según los 3 agentes
- Riesgo de inconsistencias de datos (PostgreSQL apunta a documentos inexistentes)
- Orphan records (documentos MongoDB sin referencia en PostgreSQL)
- Fallos silenciosos que aparecen en producción

**Información necesaria:**
1. **Orden de creación:** PostgreSQL primero o MongoDB primero
2. **Patrón de consistencia:** Eventual consistency, 2-Phase Commit, o Saga pattern
3. **Estrategia de rollback:** Cómo deshacer operaciones fallidas
4. **Validación de integridad:** Trigger o cronjob que valide referencias
5. **Manejo de errores:** Reintentos, notificaciones, queue de eventos

**Solución Propuesta (Mejor de Claude):**
```markdown
### Sincronización PostgreSQL ↔ MongoDB

**Patrón:** Eventual Consistency con Event Sourcing

**Flujo de creación:**
1. Worker genera assessment en MongoDB (fuente de verdad para preguntas)
2. Publica evento `assessment.created` a RabbitMQ con `{mongo_id, material_id}`
3. api-mobile consume evento y crea registro en PostgreSQL.assessment
4. Si falla PostgreSQL: Retry 3 veces, luego Dead Letter Queue
5. Si falla MongoDB: No se publica evento, api-mobile no crea registro

**Validación de integridad:**
- Cronjob diario: valida que todos los `mongo_document_id` existen en MongoDB
- Si no existe: marca assessment como `invalid` y notifica a equipo

**Manejo de inconsistencias:**
- GET /assessment/:id valida que mongo_document_id existe antes de retornar
- Si no existe: retorna 404 + log de error crítico
```

---

### 2. Autoridad de Autenticación y Gestión de Usuarios

**Detectado por:** Claude ❌ | Gemini ✅ | Grok ✅  
**Consenso:** 🟡 MEDIO (2/3 agentes)

**Ubicación:**
- `AnalisisEstandarizado/00-Overview/PROJECTS_MATRIX.md`
- `spec-01-evaluaciones/02-Design/SECURITY_DESIGN.md`

**Descripción Integrada:**
La documentación menciona roles (student, teacher, admin) y autenticación JWT, pero no especifica qué servicio es la autoridad central para la gestión de usuarios y la emisión de tokens.

**Por qué es ambiguo:**
1. **Servicio de identidad no definido:** ¿Es `api-mobile`? ¿`api-admin`? ¿Un servicio separado? (Gemini, Grok)
2. **Endpoints de autenticación:** Login, registro, refresh de tokens no asignados a servicio específico (Gemini)
3. **Validación de tokens:** Cada servicio valida independientemente o hay autoridad central (Grok)

**Impacto:**
- **BLOQUEANTE CRÍTICO** según Gemini y Grok
- Desarrollo de autenticación bloqueado en todos los servicios
- No se puede implementar middleware de seguridad coherente
- Riesgo de implementaciones inconsistentes

**Información necesaria:**
1. Definir explícitamente el servicio de identidad (IdP)
2. Especificar endpoints de login, registro, refresh de tokens
3. Documentar flujo de validación de tokens entre servicios

**Solución Propuesta (Gemini):**
```markdown
### Servicio de Identidad

**Autoridad:** api-admin

**Responsabilidades:**
- Registro de usuarios (POST /auth/register)
- Login y emisión de tokens JWT (POST /auth/login)
- Refresh de tokens (POST /auth/refresh)
- Gestión de roles y permisos

**Validación en otros servicios:**
- api-mobile y worker validan tokens emitidos por api-admin
- Usan shared/auth module para validación
- No emiten tokens propios
```

---

### 3. Contenido y Versionado de la Librería `edugo-shared`

**Detectado por:** Claude ✅ | Gemini ✅ | Grok ✅  
**Consenso:** 🟢 ALTO (3/3 agentes)

**Ubicación:**
- `AnalisisEstandarizado/00-Overview/EXECUTION_ORDER.md`
- `spec-04-shared/` (vacía)

**Descripción Integrada:**
El plan de ejecución indica que `api-mobile` y `api-admin` dependen de `edugo-shared v1.3.0`, y `worker` de `v1.4.0`. Sin embargo:
- La especificación `spec-04-shared` está completamente vacía
- No hay documentación del contenido de estas versiones
- No existe CHANGELOG.md que defina qué cambia entre versiones

**Por qué es ambiguo:**
1. **Contenido de versiones no definido:** Imposible saber qué incluye v1.3.0 vs v1.4.0 (Claude, Gemini, Grok)
2. **Dependencia circular:** Plan dice "consolidar código de api-mobile" pero api-mobile aún no existe (Grok)
3. **Interfaces no documentadas:** No se conocen las funciones, structs, módulos que debe proveer (Gemini, Grok)
4. **Backward compatibility:** No se sabe si v1.4.0 es compatible con v1.3.0 (Claude)

**Impacto:**
- **BLOQUEANTE CRÍTICO** según los 3 agentes
- Desarrollo de todos los proyectos bloqueado
- No se pueden importar paquetes ni usar funciones compartidas
- Imposible gestionar dependencias en go.mod

**Información necesaria:**
1. Especificación completa para `spec-04-shared` con módulos a crear
2. CHANGELOG detallado: v1.0.0 → v1.3.0 → v1.4.0
3. Interfaces públicas de cada módulo (logger, database, auth, messaging)
4. Estrategia de backward compatibility

**Solución Propuesta (Consolidada):**
```markdown
### Versionamiento de shared

**Timeline de releases:**
- shared v1.0.0: Core (logger, config, errors) - Semana 1
- shared v1.1.0: Database helpers (PostgreSQL, MongoDB) - Semana 2
- shared v1.2.0: Auth & JWT - Semana 2
- shared v1.3.0: Messaging (RabbitMQ) - Semana 3 ← api-mobile, api-admin
- shared v1.4.0: AI helpers (OpenAI integration) - Semana 5 ← worker

**Breaking changes:**
- v1.4.0 es BACKWARD COMPATIBLE con v1.3.0
- Solo agrega módulo `shared/ai`, no modifica existentes
- api-mobile y api-admin PUEDEN continuar usando v1.3.0
- worker REQUIERE v1.4.0 para módulo `shared/ai`

**Módulos por versión:**

v1.3.0:
- logger (Logrus con structured logging)
- config (Viper multi-ambiente)
- errors (Error types estandarizados)
- database/postgres (GORM client)
- database/mongo (Mongo client)
- auth (JWT generation/validation)
- messaging (RabbitMQ producer/consumer)

v1.4.0 (adicional):
- ai (OpenAI client wrapper)
- ai/prompts (Prompt templates versionados)
```

---

### 4. Contratos de Eventos de Mensajería (RabbitMQ)

**Detectado por:** Claude ✅ | Gemini ✅ | Grok ✅  
**Consenso:** 🟢 ALTO (3/3 agentes)

**Ubicación:**
- `AnalisisEstandarizado/00-Overview/EXECUTION_ORDER.md`
- `PROJECTS_MATRIX.md`

**Descripción Integrada:**
Los servicios se comunican por eventos (ej. `api-mobile` publica `evaluation.submitted` y `worker` lo consume), pero no se define la estructura (schema) de estos eventos.

**Por qué es ambiguo:**
1. **Schema JSON no definido:** Worker no puede implementar consumidor sin conocer estructura exacta (Claude, Gemini, Grok)
2. **Campos obligatorios vs opcionales:** No especificados (Claude, Grok)
3. **Versionamiento de eventos:** Qué hacer cuando schema cambia (Claude, Grok)
4. **Configuración de RabbitMQ:** Exchanges, queues, bindings no documentados (Claude, Gemini)

**Impacto:**
- **BLOQUEANTE CRÍTICO** según los 3 agentes
- Desarrollo del worker bloqueado
- Publicadores en APIs no pueden implementarse correctamente
- Riesgo de incompatibilidades en producción

**Información necesaria:**
1. Schema JSON para cada evento del sistema
2. Versionamiento de schemas (v1.0, v1.1, v2.0)
3. Configuración de exchanges y queues en RabbitMQ
4. Estrategia de backward compatibility

**Solución Propuesta (Consolidada de Claude y Gemini):**
```markdown
### Contratos de Eventos RabbitMQ

**Configuración de RabbitMQ:**
```yaml
exchanges:
  - name: edugo.topic
    type: topic
    durable: true

queues:
  - name: material.processing
    durable: true
    bindings:
      - exchange: edugo.topic
        routing_key: material.uploaded

  - name: assessment.notifications
    durable: true
    bindings:
      - exchange: edugo.topic
        routing_key: assessment.completed

  - name: dlq.failed_processing
    durable: true
    arguments:
      x-message-ttl: 86400000  # 24 hours
```

**Schemas de Eventos:**

```json
// Evento: material.uploaded (v1.0)
{
  "event_id": "uuid-v7",
  "event_type": "material.uploaded",
  "event_version": "1.0",
  "timestamp": "2025-11-15T10:30:00Z",
  "payload": {
    "material_id": "uuid",
    "school_id": "uuid",
    "teacher_id": "uuid",
    "file_url": "s3://bucket/path/to/file.pdf",
    "file_size_bytes": 2048000,
    "file_type": "application/pdf",
    "metadata": {
      "title": "Introducción a la Física",
      "grade": "10th",
      "subject": "Science"
    }
  }
}

// Evento: assessment.completed (v1.0)
{
  "event_id": "uuid-v7",
  "event_type": "assessment.completed",
  "event_version": "1.0",
  "timestamp": "2025-11-15T10:35:00Z",
  "payload": {
    "assessment_id": "uuid",
    "student_id": "uuid",
    "material_id": "uuid",
    "score": 85.5,
    "total_questions": 10,
    "correct_answers": 8,
    "time_spent_seconds": 450
  }
}

// Evento: evaluation.submitted (v1.0)
{
  "event_id": "uuid-v7",
  "event_type": "evaluation.submitted",
  "event_version": "1.0",
  "timestamp": "2025-11-15T10:40:00Z",
  "payload": {
    "attempt_id": "uuid",
    "assessment_id": "uuid",
    "student_id": "uuid",
    "answers": [
      {
        "question_id": "uuid",
        "selected_option": "A",
        "is_correct": true
      }
    ]
  }
}
```

**Versionamiento:**
- Campo `event_version` obligatorio en todos los eventos
- Consumers deben soportar múltiples versiones
- Breaking changes requieren nueva versión major (1.0 → 2.0)
```

---

### 5. Ownership de Tablas Compartidas (users, materials)

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌  
**Consenso:** 🔴 BAJO (1/3 agentes)

**Ubicación:**
- `spec-01-evaluaciones/04-Implementation/Sprint-01-Schema-BD/TASKS.md:245-280`
- `spec-03-api-administracion/04-Implementation/Sprint-01-Schema-BD/TASKS.md:198-230`

**Descripción:**
Múltiples specs mencionan usar tablas `users` y `materials`, pero ninguna especifica claramente quién las crea y mantiene.

**Por qué es ambiguo:**
1. Ambas specs mencionan usar `materials` pero ninguna dice quién la crea
2. api-admin menciona crear `users`, pero api-mobile también la usa
3. Riesgo de duplicación si ambos proyectos ejecutan migraciones en paralelo
4. Riesgo de schemas incompatibles entre proyectos

**Impacto:**
- **BLOQUEANTE CRÍTICO** según Claude
- Desarrollo bloqueado: desarrolladores no saben si crear tabla o asumir que existe
- CI/CD fails: migraciones fallan porque tabla ya existe o no existe
- Schemas incompatibles si ambos definen estructura diferente

**Información necesaria:**
1. Tabla de ownership: quién crea y mantiene cada tabla
2. Orden de ejecución de migraciones
3. Estrategia de validación antes de migrar

**Solución Propuesta (Claude):**
```markdown
### Tabla de Ownership

| Tabla | Owner (crea y mantiene) | Readers | Writers |
|-------|------------------------|---------|---------|
| users | **api-admin** | api-mobile, worker | api-admin |
| schools | **api-admin** | api-mobile, api-admin | api-admin |
| academic_units | **api-admin** | api-mobile, api-admin | api-admin |
| memberships | **api-admin** | api-mobile, api-admin | api-admin |
| materials | **api-mobile** | api-mobile, api-admin, worker | api-mobile |
| assessment | **api-mobile** | api-mobile, worker | api-mobile, worker |
| assessment_attempt | **api-mobile** | api-mobile | api-mobile |

### Orden de Ejecución de Migraciones

**Fase 1: Base Tables (api-admin - DÍA 1)**
```sql
CREATE TABLE users (...);
CREATE TABLE schools (...);
CREATE TABLE academic_units (...);
```

**Fase 2: Material Tables (api-mobile - DÍA 2+)**
```sql
CREATE TABLE materials (
  uploaded_by_teacher_id UUID REFERENCES users(id),
  school_id UUID REFERENCES schools(id)
);
```

**Validación en CI/CD:**
```yaml
jobs:
  migrate-base:
    steps:
      - name: Run api-admin migrations
        run: cd api-admin && make migrate-up

  migrate-features:
    needs: migrate-base
    steps:
      - name: Run api-mobile migrations
        run: cd api-mobile && make migrate-up
```
```

---

### 6. SLA de Generación de Resúmenes con OpenAI

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅  
**Consenso:** 🟡 MEDIO (2/3 agentes)

**Ubicación:**
- `spec-02-worker/01-Requirements/PRD.md:123`
- `spec-02-worker/02-Design/ARCHITECTURE.md:89-95`

**Descripción:**
La documentación dice "El worker debe procesar materiales y generar resúmenes en menos de 60 segundos", pero no especifica qué hacer si excede ese tiempo.

**Por qué es ambiguo:**
1. **Comportamiento al exceder SLA:** ¿Se cancela? ¿Se reintenta? ¿Se marca como fallido? (Claude, Grok)
2. **SLA incluye tiempo de cola:** 60 seg desde upload o desde inicio de procesamiento (Claude)
3. **Rate limits de OpenAI:** No hay estrategia documentada (Claude, Grok)
4. **UX esperada:** ¿Sincrónico (esperar) o asíncrono (notificación)? (Claude)

**Impacto:**
- **BLOQUEANTE CRÍTICO** según Claude y Grok
- Riesgo de bloquear UI por 60 segundos (mala UX)
- O cancelar procesamiento prematuramente (desperdicio de recursos)
- Fallas en producción por rate limits no manejados

**Información necesaria:**
1. Definición exacta del SLA: 60 seg desde upload o desde procesamiento
2. Comportamiento al exceder: timeout y retry, continuar y notificar
3. Manejo de rate limits de OpenAI
4. UX esperada: sincrónico vs asíncrono

**Solución Propuesta (Claude):**
```markdown
### SLA de Procesamiento

**Definición:** 60 segundos desde que worker inicia procesamiento (no incluye tiempo en cola)

**Comportamiento:**
- 0-30 seg: Procesamiento normal
- 30-60 seg: Log de warning, continuar
- 60-120 seg: Log de error, continuar hasta completar
- >120 seg: Timeout, cancelar, mover a DLQ

**Manejo de rate limits OpenAI:**
- Si 429 (rate limit): Backoff exponencial hasta 10 minutos
- Si excede 10 min total: Marcar como "delayed", reintentar en 1 hora
- Notificar a docente: "Resumen en proceso, recibirás email cuando esté listo"

**UX:**
- Procesamiento asíncrono (no bloquea UI)
- Material disponible inmediatamente sin resumen
- Email enviado cuando resumen completa
- Badge en UI: "Resumen generándose..." → "Resumen disponible"
```

---

### 7. Costos Estimados de OpenAI

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅  
**Consenso:** 🟡 MEDIO (2/3 agentes)

**Ubicación:**
- `spec-02-worker/01-Requirements/PRD.md:98-110`

**Descripción:**
Presupuesto global de $29,500 USD mencionado, pero no se especifica cuánto es para API de OpenAI.

**Por qué es ambiguo:**
1. **Costo por material no estimado:** GPT-4 Turbo ~$0.10-$0.50 por material (Claude, Grok)
2. **Límites de uso no definidos:** ¿Cuántos materiales esperados mensualmente? (Claude)
3. **Fallback si excede presupuesto:** ¿Se pausa? ¿Se cobra? ¿Degrada a modelo más barato? (Claude, Grok)

**Impacto:**
- **BLOQUEANTE MEDIO-ALTO** según Claude
- Costos no controlados ($1000+/mes inesperados)
- Necesidad de agregar billing después (refactor costoso)
- Degradación de servicio sin previo aviso

**Información necesaria:**
1. Estimación de volumen de materiales/mes
2. Costo por material calculado
3. Presupuesto específico para OpenAI
4. Límites por tier (free, basic, premium)
5. Estrategia de control de costos

**Solución Propuesta (Claude):**
```markdown
### Estimación de Costos OpenAI

**Modelo:** GPT-4 Turbo Preview
- Input: $0.01 / 1K tokens
- Output: $0.03 / 1K tokens

**Estimación por material:**
- PDF promedio: 20 páginas = 10K tokens input
- Resumen: 1K tokens output
- Quiz: 500 tokens output
- **Costo por material:** ~$0.15

**Volumen esperado:**
- MVP (10 escuelas piloto): 500 materiales/mes
- Año 1: 5,000 materiales/mes
- Año 2: 20,000 materiales/mes

**Presupuesto OpenAI:**
- MVP: $75/mes ($900/año)
- Año 1: $750/mes ($9,000/año)
- Año 2: $3,000/mes ($36,000/año)

**Límites por tier:**
- Free tier: 10 materiales/mes con IA
- Basic ($50/mes): 50 materiales/mes
- Premium ($200/mes): 500 materiales/mes
- Enterprise: Ilimitado

**Control de costos:**
- Rate limit: Máximo 100 procesamientos/hora
- Si excede quota: Material queda en cola hasta próximo mes
- Alertas: Email si gasto mensual > $500
```

---

### 8. Estrategia de Deployment (Blue-Green vs Canary vs Rolling)

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅  
**Consenso:** 🟡 MEDIO (2/3 agentes)

**Ubicación:**
- `spec-01/05-Deployment/DEPLOYMENT_GUIDE.md:89-110`
- `spec-02/05-Deployment/DEPLOYMENT_GUIDE.md:95-115`

**Descripción:**
Documentación dice "Deploy a producción usando CI/CD pipeline con GitHub Actions" pero no especifica estrategia.

**Por qué es ambiguo:**
1. **Estrategia no definida:** ¿Blue-Green? ¿Canary? ¿Rolling update? (Claude, Grok)
2. **Downtime:** ¿Se espera downtime o es zero-downtime? (Claude)
3. **Rollback:** ¿Automático o manual? ¿Triggers? (Claude, Grok)
4. **Migraciones:** Compatibilidad durante rolling update (Claude)

**Impacto:**
- **BLOQUEANTE MEDIO** según Claude
- Deploys que causan downtime no planificado
- Rollbacks complicados que toman horas
- Migraciones que rompen versión vieja

**Información necesaria:**
1. Estrategia de deployment por ambiente
2. SLA de uptime (¿99.9% requiere zero-downtime?)
3. Estrategia de rollback: automático o manual
4. Compatibilidad backward de migraciones

**Solución Propuesta (Claude):**
```markdown
### Estrategia de Deployment

**Ambiente de staging:**
- Blue-Green deployment (switch instantáneo)
- Testing manual por 1 hora
- Rollback: Switch back to blue environment

**Ambiente de producción:**
- Canary deployment (gradual rollout)
- Fases:
  1. Deploy a 10% de traffic (10 minutos)
  2. Validar error rate < 1%
  3. Escalar a 50% de traffic (30 minutos)
  4. Validar error rate < 0.5%
  5. Escalar a 100% (full rollout)

**Zero-downtime garantizado:**
- No maintenance windows
- Load balancer distribuye traffic entre versiones
- Health checks: nuevo pod debe pasar antes de recibir traffic

**Rollback strategy:**
- Automático: Si error rate > 5% por 5 minutos → rollback
- Manual: kubectl rollout undo
- Tiempo de rollback: <5 minutos

**Compatibilidad de migraciones:**
- Migraciones backward compatible
- Patrón: Agregar columna NULLABLE → Deploy código → Backfill → Hacer NOT NULL
- Nunca: DROP COLUMN durante rolling update
```

---

### 9. Política de Retención de Datos Históricos

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌  
**Consenso:** 🔴 BAJO (1/3 agentes)

**Ubicación:**
- `spec-01/02-Design/SECURITY_DESIGN.md:78-95`
- `spec-01/02-Design/DATA_MODEL.md:45-78`

**Descripción:**
Tabla `assessment_attempt` es IMMUTABLE (append-only) para auditoría, pero no se especifica por cuánto tiempo.

**Por qué es ambiguo:**
1. **Duración de retención:** ¿Por siempre? ¿X años? ¿Archivado? (Claude)
2. **GDPR Right to be Forgotten:** Tabla immutable vs obligación de borrar (Claude)
3. **Anonimización:** ¿Se anonimizan después de X tiempo? (Claude)
4. **Crecimiento de storage:** No presupuestado (Claude)

**Impacto:**
- **BLOQUEANTE MEDIO** según Claude
- Riesgo de violación de GDPR (multas hasta €20M)
- Crecimiento descontrolado de base de datos
- Costos de storage inesperados

**Información necesaria:**
1. Duración de retención de datos
2. Proceso de borrado para GDPR
3. Estrategia de anonimización
4. Política de archivado a storage frío

**Solución Propuesta (Claude):**
```markdown
### Política de Retención de Datos

**Datos activos (PostgreSQL hot storage):**
- Intentos de evaluación: 2 años desde creación
- Usuarios activos: Mientras cuenta esté activa

**Archivado (storage frío):**
- Después de 2 años: Mover a S3 Glacier
- Formato: JSON comprimido con schema versionado
- Retención en archivo: 5 años adicionales

**Borrado permanente:**
- Después de 7 años totales: Borrado permanente
- Usuarios inactivos >3 años: Borrado automático
- Right to be Forgotten: Borrado inmediato a solicitud

**GDPR Right to be Forgotten:**
1. Usuario solicita borrado
2. Marcar attempts.student_id como NULL
3. Crear registro anonimizado: `student_id = 'DELETED_USER_{hash}'`
4. Mantener metadata para analytics (sin identificar)
5. Borrar completamente después de 30 días
```

---

### 10. Manejo de Rate Limits de OpenAI

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅  
**Consenso:** 🟡 MEDIO (2/3 agentes)

**Ubicación:**
- `spec-02/04-Implementation/Sprint-03-OpenAI-Integration/QUESTIONS.md:28-45`

**Descripción:**
Documentación dice "Retry con backoff exponencial (5 intentos)" pero no especifica timing ni comportamiento después de fallos.

**Por qué es ambiguo:**
1. **Backoff timing:** ¿Cuánto tiempo entre reintentos? (Claude, Grok)
2. **Después de 5 intentos:** ¿Marcar como fallido? ¿DLQ? ¿Reintentar en 1 hora? (Claude)
3. **Cola de espera:** ¿Cómo se priorizan materiales? (Claude)
4. **Notificación a usuario:** ¿Recibe feedback? (Claude, Grok)

**Impacto:**
- **BLOQUEANTE MEDIO** según Claude
- Reintentos demasiado agresivos empeoran rate limit
- Materiales nunca procesados sin notificación
- UX pobre (docente no sabe qué pasó)

**Información necesaria:**
1. Backoff timing: intervalos exactos
2. Comportamiento después de max retries
3. Gestión de cola y priorización
4. Notificaciones al usuario
5. Métricas de observabilidad

**Solución Propuesta (Claude):**
```markdown
### Manejo de Rate Limits OpenAI

**Backoff timing:**
- Intento 1: Inmediato
- Intento 2: 30 segundos después
- Intento 3: 2 minutos después
- Intento 4: 5 minutos después
- Intento 5: 15 minutos después
- Total máximo: 22.5 minutos

**Después de 5 intentos fallidos:**
- Mover a Dead Letter Queue (DLQ)
- Reintentar automáticamente en 1 hora
- Máximo 3 reintentos desde DLQ
- Si falla 3 veces: Marcar como "permanently_failed"

**Notificación a usuario:**
- Después de primer rate limit: No notificar (retry silencioso)
- Después de 3 intentos: Email "Procesamiento retrasado, reintentando"
- Después de permanently_failed: Email "No pudimos procesar, contacta soporte"

**Gestión de cola:**
- Queue principal: FIFO
- Si rate limit detectado: Pausar consumo por 5 minutos
- Permitir procesamiento de otros tipos de eventos

**Métricas:**
- Counter: `openai_rate_limit_total`
- Histogram: `openai_retry_duration_seconds`
- Alert: Si >10 rate limits en 1 hora
```

---

### 11. Validación de Calidad de Resúmenes IA

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌  
**Consenso:** 🔴 BAJO (1/3 agentes)

**Ubicación:**
- `spec-02/04-Implementation/Sprint-03-OpenAI-Integration/TASKS.md:245-270`
- `spec-02/05-Testing/TEST_STRATEGY.md:78-95`

**Descripción:**
Documentación menciona "validar que resúmenes cumplan criterios de calidad" pero no especifica cómo ni qué criterios.

**Por qué es ambiguo:**
1. **Criterios de calidad:** ¿Longitud? ¿Estructura? ¿Legibilidad? (Claude)
2. **Proceso de validación:** ¿Automático? ¿Manual? ¿Feedback de usuarios? (Claude)
3. **Si falla validación:** ¿Reintentar? ¿Aceptar y marcar? ¿Rechazar? (Claude)

**Impacto:**
- **BLOQUEANTE MEDIO-BAJO** según Claude
- Resúmenes de calidad inconsistente
- No hay feedback loop para mejorar
- NPS bajo sin saber por qué

**Información necesaria:**
1. Criterios de calidad medibles
2. Proceso de validación
3. Manejo de fallos
4. Mejora continua y versionamiento de prompts

**Solución Propuesta (Claude):**
```markdown
### Validación de Calidad de Resúmenes IA

**Criterios automáticos:**
1. Longitud: 500-2000 caracteres
2. Estructura: Al menos 2 secciones (### headers)
3. Idioma: Coincide con material
4. Completitud: Sin placeholders "[TODO]"
5. Formato: Markdown válido

**Si falla validación:**
- Log warning
- Reintentar una vez con prompt ajustado
- Si falla segunda vez: Aceptar y marcar `quality_check = 'warning'`

**Feedback de usuarios:**
1. Relevancia: ¿Captura puntos clave? (1-5)
2. Claridad: ¿Fácil de entender? (1-5)
3. Utilidad: ¿Ayuda al aprendizaje? (1-5)

**Mejora continua:**
- Botón "👍 Útil" / "👎 No útil"
- Si >20% thumbs down: Review de prompt
- A/B testing de prompts
- Versionamiento: prompts en Git (v1.0, v1.1, v2.0)
```

---

### 12. Formato de Archivos Soportados por Worker

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ✅  
**Consenso:** 🟡 MEDIO (2/3 agentes)

**Ubicación:**
- `spec-02/01-Requirements/PRD.md:45-60`
- `spec-02/04-Implementation/Sprint-02-PDF-Processing/TASKS.md:15-30`

**Descripción:**
Documentación dice "Worker procesa PDFs" pero no especifica si solo PDFs o también otros formatos.

**Por qué es ambiguo:**
1. **Formatos soportados:** ¿Solo PDF? ¿DOCX? ¿PPTX? ¿Videos? (Claude, Grok)
2. **Requisitos de PDFs:** ¿Nativos? ¿Escaneados con OCR? ¿Protegidos? (Claude)
3. **Manejo de no soportados:** ¿Rechazar? ¿Convertir? ¿Notificar? (Claude, Grok)

**Impacto:**
- **BLOQUEANTE BAJO** según Claude
- Docentes frustrados que no pueden subir DOCX
- Necesidad de agregar soporte después (feature request)
- UX inconsistente

**Información necesaria:**
1. Lista completa de formatos soportados
2. Requisitos de PDFs (nativo, OCR, tamaño)
3. Manejo de formatos no soportados
4. Roadmap de formatos futuros

**Solución Propuesta (Claude):**
```markdown
### Formatos de Archivo Soportados

**MVP (Fase 1):**
- ✅ PDF nativo (con texto seleccionable)
- ✅ PDF escaneado (con OCR usando Tesseract)
- ❌ DOCX, PPTX, TXT (Post-MVP)
- ❌ Videos, Links web (Post-MVP)

**Requisitos de PDFs:**
- Tamaño máximo: 50MB
- Páginas máximas: 500 páginas
- Protección: No soportado (rechazar con error)
- Idiomas OCR: Español, inglés, portugués

**Manejo de formatos no soportados:**
1. Validar extensión en upload (api-mobile)
2. Rechazar con error 400: "Formato no soportado. Solo PDF."
3. UI muestra formatos aceptados en upload dialog

**Roadmap (Post-MVP):**
- Fase 2 (Q2 2026): DOCX, PPTX (convertir a PDF con LibreOffice)
- Fase 3 (Q3 2026): Videos (transcribir con Whisper API)
- Fase 4 (Q4 2026): Links web (scrape con Puppeteer)
```

---

### 13. Compartir Assessments entre Docentes

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌  
**Consenso:** 🔴 BAJO (1/3 agentes)

**Ubicación:**
- `spec-01/01-Requirements/FUNCTIONAL_SPECS.md:89-105`
- `spec-01/02-Design/API_CONTRACTS.md:145-170`

**Descripción:**
Documentación dice "Teachers pueden crear assessments" pero no menciona si se pueden compartir entre docentes.

**Por qué es ambiguo:**
1. **Ownership:** ¿Assessments son privados o públicos? (Claude)
2. **Permisos de edición:** ¿Otros docentes pueden editar? ¿O solo copiar? (Claude)
3. **Flujo de compartir:** ¿Explícito o implícito? (Claude)

**Impacto:**
- **BLOQUEANTE BAJO** según Claude
- API funciona para uso individual, pero colaboración limitada
- Feature request inmediata de usuarios
- Refactor de permisos después (caro)

**Información necesaria:**
1. Niveles de visibilidad (privado, escuela, público)
2. Permisos de edición (CRUD granular)
3. Flujo de compartir
4. Versionamiento de assessments compartidos

**Solución Propuesta (Claude):**
```markdown
### Compartir Assessments entre Docentes

**MVP (Fase 1):**
- Assessments son privados del docente creador
- No se pueden compartir entre docentes
- Cada docente crea sus propios assessments

**Post-MVP (Fase 2 - Q2 2026):**
- Niveles de visibilidad:
  - `private`: Solo creador
  - `school`: Todos los docentes de la escuela pueden ver y copiar
  - `public`: Biblioteca pública (futuro marketplace)

**Flujo de compartir:**
- Docente A marca assessment como `school` visibility
- Docente B ve en "Biblioteca de Assessments" de su escuela
- Docente B puede "Usar" (readonly) o "Copiar y Editar" (fork)

**Permisos:**
- Creador: Full CRUD
- Otros docentes: Read + Copy (no editar original)

**Schema cambios:**
```sql
ALTER TABLE assessment ADD COLUMN visibility VARCHAR(20) DEFAULT 'private';
ALTER TABLE assessment ADD COLUMN created_by_teacher_id UUID;
CREATE INDEX idx_assessment_visibility ON assessment(visibility, school_id);
```
```

---

### 14. Versiones de Dependencias Externas

**Detectado por:** Claude ❌ | Gemini ❌ | Grok ✅  
**Consenso:** 🔴 BAJO (1/3 agentes)

**Ubicación:**
- Múltiples archivos (START_HERE.md, DEPENDENCIES.md)

**Descripción:**
Versiones mínimas especificadas como "PostgreSQL 15+", "MongoDB 7.0+", pero sin límites superiores.

**Por qué es ambiguo:**
1. **Límites superiores no definidos:** ¿Compatible con versiones futuras? (Grok)
2. **Matriz de compatibilidad:** No documentada (Grok)
3. **Política de actualización:** No especificada (Grok)

**Impacto:**
- **MEDIO** según Grok
- Riesgo de incompatibilidades con versiones nuevas
- Desarrolladores no saben qué versión instalar

**Información necesaria:**
1. Matriz de compatibilidad versionada
2. Política de actualización de dependencias
3. Tests de compatibilidad

**Solución Propuesta (Grok):**
```markdown
### Matriz de Compatibilidad

| Dependencia | Versión Mínima | Versión Máxima Probada | Notas |
|-------------|---------------|----------------------|-------|
| PostgreSQL | 15.0 | 15.5 | No usar 16.x (breaking changes) |
| MongoDB | 7.0 | 7.0.4 | Compatible con 7.x |
| Go | 1.21 | 1.22 | Probar con 1.22 antes de upgrade |
| RabbitMQ | 3.12 | 3.12.10 | Compatible con 3.x |
```

---

### 15. Alcance Exacto del MVP

**Detectado por:** Claude ❌ | Gemini ❌ | Grok ✅  
**Consenso:** 🔴 BAJO (1/3 agentes)

**Ubicación:**
- ARCHITECTURE.md (menciones a "Post-MVP")

**Descripción:**
Features mencionadas como "Post-MVP" sin definición clara de qué es crítico para lanzamiento.

**Por qué es ambiguo:**
1. **Features críticas vs mejoras:** No diferenciadas claramente (Grok)
2. **Criterios de MVP:** No medibles (Grok)

**Impacto:**
- **MEDIO** según Grok
- Desarrollo puede implementar features no prioritarias
- O omitir críticas

**Información necesaria:**
1. Definición de MVP con criterios medibles
2. Features numeradas por prioridad

**Solución Propuesta (Grok):**
```markdown
### MVP Definition

**Criterios de aceptación:**
1. Usuario puede subir PDF
2. IA genera resumen en <60 seg
3. Usuario puede responder quiz
4. Sistema califica automáticamente
5. Coverage >85% en tests

**Post-MVP:**
- Caching de resúmenes
- Circuit breaker
- Idempotency keys
- Multi-región deployment
```

---

## 🟡 Ambigüedades Menores (No Bloqueantes)

### 16. Idiomas Soportados para Resúmenes IA

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌

**Ubicación:** `spec-02/02-Design/ARCHITECTURE.md`

**Ambigüedad:** No especifica qué idiomas soporta OpenAI para resúmenes.

**Impacto:** Bajo - Se puede asumir español, inglés, portugués (LATAM).

**Solución:** Documentar idiomas soportados: español, inglés, portugués. Validar idioma del material antes de procesar.

---

### 17. Tamaño Máximo de PDF a Procesar

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌

**Ubicación:** `spec-02/01-Requirements/TECHNICAL_SPECS.md`

**Ambigüedad:** No especifica límite de tamaño o número de páginas.

**Impacto:** Bajo - Puede causar timeouts con PDFs muy grandes.

**Solución:** Establecer límite de 50MB, 500 páginas máximo.

---

### 18. Profundidad Máxima de Jerarquía Académica

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌

**Ubicación:** `spec-03/02-Design/ARCHITECTURE.md:145`

**Documentado como:** "5 niveles máximo"

**Ambigüedad:** No especifica qué hacer si se intenta crear nivel 6.

**Impacto:** Bajo - Validación faltante.

**Solución:** Agregar validación que rechace parent_id si profundidad > 5.

---

### 19. Tiempo de Expiración de Tokens JWT

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌

**Ubicación:** `00-Overview/ECOSYSTEM_OVERVIEW.md:78`

**Documentado como:** "15 minutos access token, 7 días refresh token"

**Ambigüedad:** No especifica si tiempos son configurables o hardcoded.

**Impacto:** Bajo - Puede necesitar ajuste después.

**Solución:** Hacer configurable vía variable de entorno `JWT_ACCESS_EXPIRY=15m`.

---

### 20. Puertos de Servicios - Conflicto Mongo Express

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌

**Ubicación:** `dev-environment/03-Design/NETWORKING_DESIGN.md`

**Ambigüedad:** Mongo Express usa 8081, conflicto con api-admin.

**Impacto:** Bajo - Docker Compose fallará si no se ajusta.

**Solución:** Mapear Mongo Express a puerto 8082.

---

### 21. Estrategia de Logging en Producción

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌

**Ubicación:** `spec-04/04-Implementation/Sprint-01-Core/TASKS.md:45`

**Documentado como:** "Implementar logger con Logrus"

**Ambigüedad:** No especifica dónde se almacenan logs en producción.

**Impacto:** Bajo - Se puede usar stdout y capturar con Kubernetes.

**Solución:** Documentar que logs van a stdout, capturados por Fluentd/Loki.

---

### 22. Healthcheck Endpoints - Qué Validan

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌

**Ubicación:** `spec-01/05-Deployment/MONITORING.md:89`

**Documentado como:** "Implementar /health endpoint"

**Ambigüedad:** No especifica qué checks incluye (DB, RabbitMQ, etc.).

**Impacto:** Bajo - Healthcheck básico funciona, pero no detecta dependencias.

**Solución:**
```markdown
/health/liveness  # básico (API responde)
/health/readiness # completo (DB + RabbitMQ + MongoDB)
```

---

### 23. Convención de Nombres de Branches

**Detectado por:** Claude ✅ | Gemini ❌ | Grok ❌

**Ubicación:** `spec-06-CI-CD/06-Deployment/DEPLOYMENT_GUIDE.md`

**Ambigüedad:** No especifica convención de branches.

**Impacto:** Bajo - Puede causar confusión en PRs.

**Solución:** Documentar Git Flow: main, develop, feature/*, fix/*.

---

## 📈 Análisis de Consenso

### Ambigüedades por Nivel de Detección

| Ambigüedad | Claude | Gemini | Grok | Consenso |
|------------|--------|--------|------|----------|
| 1. Sincronización PostgreSQL ↔ MongoDB | ✅ | ✅ | ✅ | 🟢 ALTO (3/3) |
| 2. Autoridad de Autenticación | ❌ | ✅ | ✅ | 🟡 MEDIO (2/3) |
| 3. Contenido edugo-shared | ✅ | ✅ | ✅ | 🟢 ALTO (3/3) |
| 4. Contratos de Eventos RabbitMQ | ✅ | ✅ | ✅ | 🟢 ALTO (3/3) |
| 5. Ownership de Tablas | ✅ | ❌ | ❌ | 🔴 BAJO (1/3) |
| 6. SLA de OpenAI | ✅ | ❌ | ✅ | 🟡 MEDIO (2/3) |
| 7. Costos de OpenAI | ✅ | ❌ | ✅ | 🟡 MEDIO (2/3) |
| 8. Estrategia de Deployment | ✅ | ❌ | ✅ | 🟡 MEDIO (2/3) |
| 9. Retención de Datos | ✅ | ❌ | ❌ | 🔴 BAJO (1/3) |
| 10. Rate Limits OpenAI | ✅ | ❌ | ✅ | 🟡 MEDIO (2/3) |
| 11. Validación Calidad Resúmenes | ✅ | ❌ | ❌ | 🔴 BAJO (1/3) |
| 12. Formatos de Archivo | ✅ | ❌ | ✅ | 🟡 MEDIO (2/3) |
| 13. Compartir Assessments | ✅ | ❌ | ❌ | 🔴 BAJO (1/3) |
| 14. Versiones Dependencias | ❌ | ❌ | ✅ | 🔴 BAJO (1/3) |
| 15. Alcance MVP | ❌ | ❌ | ✅ | 🔴 BAJO (1/3) |

### Distribución de Consenso

| Nivel de Consenso | Cantidad | Porcentaje |
|------------------|----------|------------|
| 🟢 ALTO (3/3 agentes) | 4 | 27% |
| 🟡 MEDIO (2/3 agentes) | 6 | 40% |
| 🔴 BAJO (1/3 agentes) | 5 | 33% |

### Top 5 Ambigüedades Más Críticas (por Consenso)

1. **Sincronización PostgreSQL ↔ MongoDB** - 🟢 ALTO (3/3)
2. **Contenido de edugo-shared** - 🟢 ALTO (3/3)
3. **Contratos de Eventos RabbitMQ** - 🟢 ALTO (3/3)
4. **Autoridad de Autenticación** - 🟡 MEDIO (2/3)
5. **SLA de OpenAI** - 🟡 MEDIO (2/3)

---

## ✅ Recomendaciones Prioritarias

### Prioridad 1: Resolver Ambigüedades con Alto Consenso (3/3)

Estas fueron detectadas por los 3 agentes, lo que indica que son evidentes y críticas:

1. **Sincronización PostgreSQL ↔ MongoDB**
   - Tiempo estimado: 2-3 horas
   - Crear sección en DATA_MODEL.md con flujo, validación, manejo de errores

2. **Contenido de edugo-shared**
   - Tiempo estimado: 4-6 horas
   - Completar spec-04-shared con módulos, interfaces, CHANGELOG

3. **Contratos de Eventos RabbitMQ**
   - Tiempo estimado: 3-4 horas
   - Crear EVENT_CONTRACTS.md con schemas JSON, configuración RabbitMQ

4. **Autoridad de Autenticación**
   - Tiempo estimado: 1-2 horas
   - Documentar que api-admin es IdP, endpoints de auth

### Prioridad 2: Resolver Ambigüedades con Medio Consenso (2/3)

5. **SLA de OpenAI**
   - Tiempo estimado: 1-2 horas
   - Documentar comportamiento al exceder 60 seg, UX asíncrona

6. **Costos de OpenAI**
   - Tiempo estimado: 2-3 horas
   - Crear estimaciones por material, presupuesto, límites por tier

7. **Estrategia de Deployment**
   - Tiempo estimado: 2-3 horas
   - Documentar Canary deployment, zero-downtime, rollback automático

### Prioridad 3: Considerar Ambigüedades con Bajo Consenso (1/3)

Estas fueron detectadas por un solo agente, por lo que pueden ser menos críticas o más opinables:

8. **Ownership de Tablas** (Claude)
9. **Retención de Datos** (Claude)
10. **Formatos de Archivo** (Claude + Grok)

**Tiempo total estimado para resolver críticos:** 16-24 horas

---

**Fin del Análisis Consolidado de Ambigüedades**
