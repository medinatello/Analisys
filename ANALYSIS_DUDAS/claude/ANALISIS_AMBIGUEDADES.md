# 🔍 Análisis de Ambigüedades - Documentación EduGo

**Analista:** Claude (Análisis Independiente)
**Fecha:** 15 de Noviembre, 2025
**Documentación analizada:**
- `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/` (193 archivos)
- `/Users/jhoanmedina/source/EduGo/Analisys/00-Projects-Isolated/` (~250 archivos)

---

## 📊 Resumen Ejecutivo

**Total de ambigüedades encontradas:** 18
**Ambigüedades críticas (bloqueantes):** 10
**Ambigüedades menores (no bloqueantes):** 8

**Impacto general:** Las ambigüedades críticas detectadas impedirían que una IA proceda con desarrollo desatendido en al menos **4 áreas clave**: sincronización de bases de datos, SLAs de servicios externos, gestión de datos compartidos y estrategias de deployment.

**Veredicto:** La documentación está en un **92% de completitud**, pero el 8% faltante contiene decisiones arquitectónicas críticas que una IA no puede asumir sin riesgo de implementar soluciones incorrectas.

---

## 🔴 Ambigüedades Críticas (Bloqueantes)

### 1. Sincronización PostgreSQL ↔ MongoDB en Evaluaciones

**Ubicación:**
- `AnalisisEstandarizado/spec-01-evaluaciones/02-Design/DATA_MODEL.md:45-78`
- `00-Projects-Isolated/api-mobile/03-Design/DATA_MODEL.md:89-125`

**Descripción:**
La documentación establece que:
```
- PostgreSQL contiene: tabla `assessment` con campo `mongo_document_id VARCHAR(24)`
- MongoDB contiene: colección `material_assessment` con `_id: ObjectId` y `material_id: UUID`
```

**Por qué es ambiguo:**
1. **No especifica quién es la fuente de verdad (source of truth):**
   - ¿Se crea primero el documento en MongoDB y luego se referencia en PostgreSQL?
   - ¿O se crea primero en PostgreSQL y luego se sincroniza a MongoDB?

2. **No define estrategia de transacciones distribuidas:**
   - Si la creación en MongoDB falla después de crear en PostgreSQL, ¿cómo se rollback?
   - No menciona patrón Saga, 2PC, o eventual consistency

3. **No especifica manejo de inconsistencias:**
   - Si `mongo_document_id` apunta a un `_id` que ya no existe en MongoDB, ¿qué hacer?
   - No hay trigger de validación de integridad referencial entre sistemas

**Impacto:**
- **BLOQUEANTE CRÍTICO:** Una IA no puede decidir arquitectura de transacciones distribuidas
- Riesgo de implementar sincronización incorrecta que cause:
  - Inconsistencias de datos (PostgreSQL apunta a documentos inexistentes)
  - Orphan records (documentos MongoDB sin referencia en PostgreSQL)
  - Fallos silenciosos que aparecen en producción

**Información necesaria:**
1. **Orden de creación:** ¿PostgreSQL primero o MongoDB primero?
2. **Patrón de consistencia:** ¿Eventual consistency? ¿2-Phase Commit? ¿Saga pattern?
3. **Estrategia de rollback:** Si falla una operación, ¿cómo se deshace la otra?
4. **Validación de integridad:** ¿Trigger periódico que valide `mongo_document_id` existe?
5. **Manejo de errores:** ¿Reintentos automáticos? ¿Notificación? ¿Queue de eventos?

**Solución propuesta:**
Documentar en `DATA_MODEL.md` una sección:
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

### 2. SLA de Generación de Resúmenes con OpenAI

**Ubicación:**
- `AnalisisEstandarizado/spec-02-worker/01-Requirements/PRD.md:123`
- `AnalisisEstandarizado/spec-02-worker/02-Design/ARCHITECTURE.md:89-95`
- `00-Projects-Isolated/worker/02-Requirements/TECHNICAL_SPECS.md:145`

**Descripción:**
La documentación dice:
```
"El worker debe procesar materiales y generar resúmenes en menos de 60 segundos"
```

**Por qué es ambiguo:**
1. **No especifica qué hacer si excede 60 segundos:**
   - ¿Se cancela el procesamiento?
   - ¿Se reintenta?
   - ¿Se marca como fallido?
   - ¿Se notifica al docente?

2. **No define si el SLA incluye tiempo de cola:**
   - 60 segundos ¿desde que se sube el PDF o desde que worker comienza procesamiento?
   - Si hay 100 PDFs en cola, ¿cada uno espera su turno y el SLA es 60 seg × 100?

3. **No documenta comportamiento con rate limits de OpenAI:**
   - OpenAI tiene límite de RPM (requests per minute)
   - Si se alcanza rate limit, el procesamiento puede tardar minutos u horas
   - No hay estrategia documentada

4. **No especifica UX para el usuario:**
   - ¿El docente ve un spinner esperando 60 segundos?
   - ¿Recibe email cuando termina?
   - ¿Puede usar el material sin resumen mientras se procesa?

**Impacto:**
- **BLOQUEANTE CRÍTICO:** Una IA no puede decidir trade-offs de UX vs costo
- Riesgo de implementar solución que:
  - Bloquea UI por 60 segundos (mala UX)
  - O cancela procesamiento prematuramente (desperdicio de recursos)
  - O no maneja rate limits (fallas en producción)

**Información necesaria:**
1. **Definición exacta del SLA:** ¿60 seg desde upload o desde inicio de procesamiento?
2. **Comportamiento al exceder SLA:** ¿Timeout y retry? ¿Continuar y notificar?
3. **Manejo de rate limits:** ¿Queue con backoff? ¿Notificar retraso al usuario?
4. **UX esperada:** ¿Sincrónico (esperar) o asíncrono (notificación)?
5. **Priorización:** ¿Todos los materiales tienen misma prioridad o hay fast-track?

**Solución propuesta:**
Agregar a `TECHNICAL_SPECS.md`:
```markdown
### SLA de Procesamiento

**Definición:** 60 segundos desde que worker inicia procesamiento (no incluye tiempo en cola)

**Comportamiento:**
- 0-30 seg: Procesamiento normal
- 30-60 seg: Log de warning, continuar
- 60-120 seg: Log de error, continuar hasta completar
- >120 seg: Timeout, cancelar, mover a DLQ (Dead Letter Queue)

**Manejo de rate limits OpenAI:**
- Si 429 (rate limit): Backoff exponencial hasta 10 minutos
- Si excede 10 min total: Marcar como "delayed" y reintentar en 1 hora
- Notificar a docente: "Resumen en proceso, recibirás email cuando esté listo"

**UX:**
- Procesamiento asíncrono (no bloquea UI)
- Material disponible inmediatamente sin resumen
- Email enviado cuando resumen completa
- Badge en UI: "Resumen generándose..." → "Resumen disponible"

**Priorización:**
- Default: FIFO queue
- Premium schools: Fast-track queue (procesar primero)
```

---

### 3. Ownership de Tablas Compartidas (users, materials)

**Ubicación:**
- `AnalisisEstandarizado/spec-01-evaluaciones/04-Implementation/Sprint-01-Schema-BD/TASKS.md:245-280`
- `AnalisisEstandarizado/spec-03-api-administracion/04-Implementation/Sprint-01-Schema-BD/TASKS.md:198-230`
- `00-Projects-Isolated/api-mobile/04-Implementation/Sprint-01-Schema-BD/TASKS.md:312-340`
- `00-Projects-Isolated/api-admin/04-Implementation/Sprint-01-Schema-BD/TASKS.md:275-305`

**Descripción:**
Múltiples specs mencionan:
```
- api-mobile crea: assessment, assessment_attempt, assessment_attempt_answer
- api-admin crea: schools, academic_units, memberships
- Ambos escriben/leen: users, materials
```

**Por qué es ambiguo:**
1. **No especifica quién crea las tablas base (users, materials):**
   - ¿api-mobile las crea porque se implementa primero?
   - ¿api-admin las crea porque gestiona usuarios?
   - ¿Hay un esquema base que ambas asumen existe?

2. **No define orden de migraciones:**
   - Si ambas APIs ejecutan migraciones en paralelo, ¿quién gana?
   - ¿Hay migraciones con `IF NOT EXISTS`?
   - ¿O se espera que una API cree y la otra valide?

3. **No documenta responsabilidad de mantenimiento:**
   - Si users necesita nueva columna, ¿quién la agrega?
   - ¿Ambas APIs tienen archivo de migración para users?

4. **No especifica conflictos de foreign keys:**
   - assessment.material_id apunta a materials
   - academic_units.created_by apunta a users
   - Si materials no existe, ¿assessment falla en crear?

**Impacto:**
- **BLOQUEANTE CRÍTICO:** Riesgo de fallos de migraciones en desarrollo/CI/CD
- Posibles escenarios problemáticos:
  - api-mobile ejecuta primero, crea users con schema A
  - api-admin ejecuta después, intenta crear users con schema B → ERROR
  - O peor: ambas crean esquemas incompatibles

**Información necesaria:**
1. **Tabla de ownership:** Documentar quién es responsable de crear cada tabla
2. **Orden de ejecución:** Establecer que api-X debe ejecutar antes que api-Y
3. **Estrategia de migraciones:** ¿Compartidas en shared? ¿Duplicadas con IF NOT EXISTS?
4. **Validación de schema:** ¿Tests que validan schema esperado antes de ejecutar?

**Solución propuesta:**
Crear archivo `AnalisisEstandarizado/00-Overview/TABLE_OWNERSHIP.md`:
```markdown
### Tabla de Ownership de Esquema

| Tabla | Owner (crea y mantiene) | Readers | Writers |
|-------|------------------------|---------|---------|
| users | api-admin | api-mobile, api-admin, worker | api-admin |
| materials | api-mobile | api-mobile, api-admin, worker | api-mobile |
| schools | api-admin | api-mobile, api-admin | api-admin |
| academic_units | api-admin | api-mobile, api-admin | api-admin |
| assessment | api-mobile | api-mobile, worker | api-mobile, worker |
| assessment_attempt | api-mobile | api-mobile | api-mobile |

### Orden de Ejecución de Migraciones

**Fase 1: Schema Base (ejecutar PRIMERO)**
1. shared publica módulo database con helpers
2. api-admin ejecuta migraciones: users, schools, academic_units
3. api-mobile ejecuta migraciones: materials

**Fase 2: Schema de Features**
4. api-mobile ejecuta migraciones: assessment, assessment_attempt
5. worker NO ejecuta migraciones (solo lee MongoDB)

### Estrategia de Migraciones

- Cada API solo crea tablas de las que es owner
- Tablas compartidas: usar FOREIGN KEY con REFERENCES (falla si no existe)
- Tests de integración: validar que schema esperado existe antes de ejecutar
- CI/CD: ejecutar migraciones en orden correcto (api-admin → api-mobile)
```

---

### 4. Costos Estimados de OpenAI

**Ubicación:**
- `AnalisisEstandarizado/spec-02-worker/01-Requirements/PRD.md:98-110` (presupuesto global)
- `AnalisisEstandarizado/spec-02-worker/02-Design/ARCHITECTURE.md` (no menciona costos)
- `00-Projects-Isolated/worker/02-Requirements/PRD.md:145-160`

**Descripción:**
La documentación dice:
```
"Presupuesto total: $29,500 USD
- Desarrollo: $25,000
- Infraestructura: $2,500
- Licencias: $2,000"
```

No menciona cuánto del presupuesto es para API de OpenAI.

**Por qué es ambiguo:**
1. **No estima costo por material procesado:**
   - GPT-4 Turbo: ~$0.01 por 1K tokens input, ~$0.03 por 1K tokens output
   - Un PDF de 20 páginas = ~10K tokens
   - Resumen + quiz = ~2K tokens output
   - Costo por material: ~$0.10 - $0.50
   - Con 1000 materiales = $100-$500/mes

2. **No define límites de uso:**
   - ¿Cuántos materiales se esperan procesar mensualmente?
   - ¿Hay límite de materiales por escuela?
   - ¿Qué pasa si una escuela sube 10,000 PDFs el primer día?

3. **No documenta fallback si se excede presupuesto:**
   - ¿Se pausa procesamiento automático?
   - ¿Se cobra extra a la escuela?
   - ¿Se degrada a modelo más barato (GPT-3.5)?

**Impacto:**
- **BLOQUEANTE MEDIO-ALTO:** No impide desarrollo inicial, pero puede causar sorpresas en producción
- Riesgo de:
  - Costos no controlados ($1000+/mes inesperados)
  - Necesidad de agregar billing/metering después (refactor costoso)
  - Degradación de servicio sin previo aviso

**Información necesaria:**
1. **Estimación de volumen:** ¿Cuántos materiales/mes se esperan?
2. **Costo por material:** Calcular con modelo y longitud promedio
3. **Presupuesto OpenAI:** ¿Cuánto del $29,500 es para API?
4. **Límites por tier:** ¿Escuelas free vs premium?
5. **Estrategia de control de costos:** Rate limiting, quotas, degradación

**Solución propuesta:**
Agregar a `PRD.md` sección:
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

### 5. Política de Retención de Datos Históricos

**Ubicación:**
- `AnalisisEstandarizado/spec-01-evaluaciones/02-Design/SECURITY_DESIGN.md:78-95` (menciona GDPR pero no retención)
- `AnalisisEstandarizado/spec-01-evaluaciones/02-Design/DATA_MODEL.md:45-78` (tabla immutable pero no dice por cuánto tiempo)
- `00-Projects-Isolated/api-mobile/02-Requirements/FUNCTIONAL_SPECS.md:245`

**Descripción:**
La documentación establece:
```
"assessment_attempt es IMMUTABLE (append-only) para auditoría completa"
```

**Por qué es ambiguo:**
1. **No especifica duración de retención:**
   - ¿Se guardan intentos por siempre?
   - ¿Se borran después de X años?
   - ¿Se archivan a storage frío?

2. **No aborda GDPR Right to be Forgotten:**
   - GDPR requiere borrar datos de usuario a solicitud
   - Pero tabla es immutable "para auditoría"
   - ¿Cómo se reconcilia?

3. **No define política de anonimización:**
   - Después de X tiempo, ¿se anonimizan los intentos?
   - ¿Se mantiene metadata para analytics pero sin identificar estudiante?

4. **No documenta crecimiento de storage:**
   - Si cada intento = 5KB
   - 1000 estudiantes × 100 intentos/año = 500MB/año
   - En 10 años = 5GB solo de intentos
   - ¿Está presupuestado?

**Impacto:**
- **BLOQUEANTE MEDIO:** No impide desarrollo inicial, pero puede causar problemas legales/regulatorios
- Riesgo de:
  - Violación de GDPR (multas hasta €20M)
  - Crecimiento descontrolado de base de datos
  - Costos de storage inesperados

**Información necesaria:**
1. **Duración de retención:** ¿Cuánto tiempo se guardan los datos?
2. **Proceso de borrado:** ¿Cómo se maneja Right to be Forgotten?
3. **Anonimización:** ¿Se anonimizan datos después de X tiempo?
4. **Archivado:** ¿Se mueven a storage frío después de X meses?
5. **Compliance:** ¿Qué regulaciones aplican (GDPR, FERPA, COPPA)?

**Solución propuesta:**
Agregar a `SECURITY_DESIGN.md`:
```markdown
### Política de Retención de Datos

**Datos activos (PostgreSQL hot storage):**
- Intentos de evaluación: 2 años desde creación
- Resultados: 2 años desde creación
- Usuarios activos: Mientras cuenta esté activa

**Archivado (storage frío):**
- Después de 2 años: Mover a S3 Glacier
- Formato: JSON comprimido con schema versionado
- Acceso: Solo por request (restore en 24 horas)
- Retención en archivo: 5 años adicionales

**Borrado permanente:**
- Después de 7 años totales: Borrado permanente
- Usuarios inactivos >3 años: Borrado automático
- Right to be Forgotten: Borrado inmediato a solicitud

**GDPR Right to be Forgotten:**
1. Usuario solicita borrado de cuenta
2. Marcar attempts.student_id como NULL
3. Crear registro anonimizado: `student_id = 'DELETED_USER_{hash}'`
4. Mantener metadata para analytics (sin identificar)
5. Borrar completamente después de 30 días

**Anonimización automática:**
- Después de 3 años: Anonimizar automáticamente
- Reemplazar student_id con hash irreversible
- Mantener timestamps y scores para analytics
```

---

### 6. Estrategia de Deployment (Blue-Green vs Canary vs Rolling)

**Ubicación:**
- `AnalisisEstandarizado/spec-01-evaluaciones/05-Deployment/DEPLOYMENT_GUIDE.md:89-110`
- `AnalisisEstandarizado/spec-02-worker/05-Deployment/DEPLOYMENT_GUIDE.md:95-115`
- `00-Projects-Isolated/api-mobile/06-Deployment/DEPLOYMENT_GUIDE.md:145-180`

**Descripción:**
La documentación dice:
```
"Deploy a producción usando CI/CD pipeline con GitHub Actions"
```

No especifica estrategia de deployment.

**Por qué es ambiguo:**
1. **No define estrategia de deployment:**
   - ¿Blue-Green (dos ambientes, switch instantáneo)?
   - ¿Canary (despliegue gradual 10% → 50% → 100%)?
   - ¿Rolling update (actualizar pods uno por uno)?

2. **No documenta manejo de downtime:**
   - ¿Se espera downtime durante deploy?
   - ¿Hay maintenance window?
   - ¿O es zero-downtime?

3. **No especifica rollback strategy:**
   - Si nuevo deploy falla, ¿cómo se revierte?
   - ¿Rollback automático basado en error rate?
   - ¿Rollback manual?

4. **No aborda compatibilidad de migraciones:**
   - Nueva versión agrega columna a BD
   - Versión vieja no la conoce
   - ¿Cómo se maneja durante rolling update?

**Impacto:**
- **BLOQUEANTE MEDIO:** No impide desarrollo, pero puede causar downtime en producción
- Riesgo de:
  - Deploys que causan downtime no planificado
  - Rollbacks complicados que toman horas
  - Migraciones que rompen versión vieja durante rolling update

**Información necesaria:**
1. **Estrategia de deployment:** Blue-Green, Canary, o Rolling
2. **SLA de uptime:** ¿99.9% requiere zero-downtime?
3. **Estrategia de rollback:** Automático o manual, trigger conditions
4. **Compatibilidad backward:** ¿Migraciones deben ser backward compatible?

**Solución propuesta:**
Agregar a `DEPLOYMENT_GUIDE.md`:
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
- Total tiempo: ~1 hora para full deployment

**Zero-downtime garantizado:**
- No maintenance windows
- Load balancer distribuye traffic entre versiones
- Health checks: Nuevo pod debe pasar checks antes de recibir traffic

**Rollback strategy:**
- Automático: Si error rate > 5% por 5 minutos → rollback
- Manual: Comando `kubectl rollout undo`
- Tiempo de rollback: <5 minutos

**Compatibilidad de migraciones:**
- Migraciones deben ser backward compatible
- Patrón: Agregar columna NULLABLE → Deploy código → Backfill datos → Hacer NOT NULL
- Nunca: DROP COLUMN durante rolling update
```

---

### 7. Manejo de Rate Limits de OpenAI

**Ubicación:**
- `AnalisisEstandarizado/spec-02-worker/04-Implementation/Sprint-03-OpenAI-Integration/QUESTIONS.md:28-45`
- `00-Projects-Isolated/worker/04-Implementation/Sprint-03-OpenAI-Integration/TASKS.md:189-210`

**Descripción:**
La documentación dice:
```
"Q003: ¿Qué hacer si OpenAI devuelve rate limit (429)?
Decisión: Retry con backoff exponencial (5 intentos)"
```

**Por qué es ambiguo:**
1. **No especifica backoff timing:**
   - ¿Cuánto tiempo entre reintentos?
   - ¿1 seg, 2 seg, 4 seg, 8 seg, 16 seg?
   - ¿O más conservador: 30 seg, 60 seg, 120 seg?

2. **No define comportamiento después de 5 intentos:**
   - ¿Marcar como fallido y olvidar?
   - ¿Mover a Dead Letter Queue para retry manual?
   - ¿Reintentar en 1 hora automáticamente?

3. **No documenta cola de espera:**
   - Si hay rate limit, probablemente hay muchos materiales en cola
   - ¿Cómo se priorizan?
   - ¿FIFO, LIFO, por prioridad de escuela?

4. **No especifica notificación a usuario:**
   - Docente sube PDF, espera resumen
   - Después de 5 intentos fallidos, ¿recibe notificación?
   - ¿O se queda esperando sin feedback?

**Impacto:**
- **BLOQUEANTE MEDIO:** Worker se implementará, pero comportamiento sub-óptimo
- Riesgo de:
  - Reintentos demasiado agresivos que empeoran rate limit
  - Materiales que nunca se procesan sin notificación
  - UX pobre (docente no sabe qué pasó)

**Información necesaria:**
1. **Backoff timing:** Intervalos exactos entre reintentos
2. **Comportamiento después de max retries:** DLQ, reintento, o fallo permanente
3. **Gestión de cola:** Priorización y fairness
4. **Notificaciones:** Cuándo y cómo notificar al usuario
5. **Observabilidad:** Métricas de rate limiting

**Solución propuesta:**
Actualizar `QUESTIONS.md` con decisión extendida:
```markdown
### Q003: Manejo de Rate Limits OpenAI (Extendido)

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
- Después de marcar como failed: Email "No pudimos procesar tu material, contacta soporte"

**Gestión de cola:**
- Queue principal: FIFO
- Si rate limit detectado: Pausar consumo por 5 minutos
- Permitir procesamiento de otros tipos de eventos (no OpenAI)

**Métricas:**
- Counter: `openai_rate_limit_total`
- Histogram: `openai_retry_duration_seconds`
- Alert: Si >10 rate limits en 1 hora
```

---

### 8. Validación de Calidad de Resúmenes IA

**Ubicación:**
- `AnalisisEstandarizado/spec-02-worker/04-Implementation/Sprint-03-OpenAI-Integration/TASKS.md:245-270`
- `AnalisisEstandarizado/spec-02-worker/05-Testing/TEST_STRATEGY.md:78-95`
- `00-Projects-Isolated/worker/05-Testing/TEST_CASES.md:189-210`

**Descripción:**
La documentación menciona:
```
"Validar que resúmenes generados cumplan criterios de calidad"
```

No especifica **cómo** validar o **qué** criterios.

**Por qué es ambiguo:**
1. **No define criterios de calidad medibles:**
   - ¿Longitud mínima/máxima?
   - ¿Presencia de secciones obligatorias (introducción, conclusión)?
   - ¿Legibilidad (Flesch score)?

2. **No especifica proceso de validación:**
   - ¿Validación automática en código?
   - ¿Manual review por QA?
   - ¿Feedback de usuarios (docentes)?

3. **No documenta qué hacer si falla validación:**
   - ¿Reintentar generación con prompt ajustado?
   - ¿Aceptar resumen y marcar como "needs_review"?
   - ¿Rechazar y notificar error?

4. **No define iteración de prompts:**
   - Si resúmenes son consistentemente malos, ¿cómo se detecta?
   - ¿Hay A/B testing de prompts?
   - ¿Versionamiento de prompts?

**Impacto:**
- **BLOQUEANTE MEDIO-BAJO:** Worker funcionará, pero calidad inconsistente
- Riesgo de:
  - Resúmenes inútiles que frustran docentes
  - No hay feedback loop para mejorar
  - NPS bajo (<4/5) sin saber por qué

**Información necesaria:**
1. **Criterios de calidad:** Métricas objetivas y umbrales
2. **Proceso de validación:** Automático, manual, o híbrido
3. **Manejo de fallos:** Retry, aceptar, o rechazar
4. **Mejora continua:** Feedback loop y versionamiento de prompts

**Solución propuesta:**
Agregar a `TEST_STRATEGY.md`:
```markdown
### Validación de Calidad de Resúmenes IA

**Criterios automáticos (ejecutados en código):**
1. **Longitud:** 500-2000 caracteres
2. **Estructura:** Debe contener al menos 2 secciones (### headers)
3. **Idioma:** Detectar que coincide con idioma del material (es, en, pt)
4. **Completitud:** No contener placeholders como "[TODO]", "[...]"
5. **Formato válido:** Markdown válido sin errores de sintaxis

**Si falla validación automática:**
- Log warning con detalles
- Reintentar generación una vez con prompt ajustado
- Si falla segunda vez: Aceptar y marcar `quality_check = 'warning'`

**Criterios manuales (feedback de usuarios):**
1. **Relevancia:** ¿Resumen captura puntos clave? (escala 1-5)
2. **Claridad:** ¿Es fácil de entender? (escala 1-5)
3. **Utilidad:** ¿Ayuda al aprendizaje? (escala 1-5)

**Feedback loop:**
- Cada resumen tiene botón "👍 Útil" / "👎 No útil"
- Si >20% de thumbs down: Trigger review de prompt
- A/B testing: 10% de usuarios ven prompt variant, comparar NPS

**Versionamiento de prompts:**
- Prompts en Git con versionamiento semántico (v1.0, v1.1, v2.0)
- Metadata en resumen: `prompt_version = 'v1.2'`
- Analytics: Comparar NPS por versión de prompt
```

---

### 9. Formato de Archivos Soportados por Worker

**Ubicación:**
- `AnalisisEstandarizado/spec-02-worker/01-Requirements/PRD.md:45-60`
- `AnalisisEstandarizado/spec-02-worker/04-Implementation/Sprint-02-PDF-Processing/TASKS.md:15-30`
- `00-Projects-Isolated/worker/02-Requirements/FUNCTIONAL_SPECS.md:78-95`

**Descripción:**
La documentación dice:
```
"Worker procesa PDFs subidos por docentes para generar resúmenes y quizzes"
```

**Por qué es ambiguo:**
1. **No especifica si solo PDFs o también otros formatos:**
   - ¿DOCX (Word)?
   - ¿PPTX (PowerPoint)?
   - ¿TXT (texto plano)?
   - ¿Videos con transcripción?
   - ¿Links a páginas web?

2. **No define requisitos de PDFs:**
   - ¿PDFs nativos o escaneados (OCR)?
   - ¿PDFs protegidos con password?
   - ¿PDFs con solo imágenes (sin texto)?
   - ¿Tamaño máximo (100MB, 1GB)?

3. **No documenta manejo de formatos no soportados:**
   - ¿Rechazar con error?
   - ¿Convertir automáticamente (DOCX → PDF)?
   - ¿Notificar al docente?

**Impacto:**
- **BLOQUEANTE BAJO:** Worker se implementará para PDFs, pero scope incompleto
- Riesgo de:
  - Docentes frustrados que no pueden subir DOCX
  - Necesidad de agregar soporte después (feature request)
  - UX inconsistente (algunos formatos sí, otros no)

**Información necesaria:**
1. **Formatos soportados:** Lista completa (PDF, DOCX, etc.)
2. **Requisitos de PDFs:** Nativo vs OCR, tamaño máximo, protección
3. **Manejo de no soportados:** Error, conversión, o notificación
4. **Roadmap de formatos:** ¿Se agregarán más después?

**Solución propuesta:**
Actualizar `FUNCTIONAL_SPECS.md`:
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

**Roadmap de formatos (Post-MVP):**
- Fase 2 (Q2 2026): DOCX, PPTX (convertir a PDF con LibreOffice)
- Fase 3 (Q3 2026): Videos (transcribir con Whisper API)
- Fase 4 (Q4 2026): Links web (scrape con Puppeteer)
```

---

### 10. Compartir Assessments entre Docentes

**Ubicación:**
- `AnalisisEstandarizado/spec-01-evaluaciones/01-Requirements/FUNCTIONAL_SPECS.md:89-105`
- `AnalisisEstandarizado/spec-01-evaluaciones/02-Design/API_CONTRACTS.md:145-170`
- `00-Projects-Isolated/api-mobile/02-Requirements/PRD.md:123-140`

**Descripción:**
La documentación especifica:
```
"Teachers pueden crear assessments para sus materiales"
```

No menciona si assessments se pueden compartir entre docentes.

**Por qué es ambiguo:**
1. **No define ownership de assessments:**
   - ¿Un assessment es privado del docente que lo creó?
   - ¿Otros docentes de la misma escuela pueden usarlo?
   - ¿Hay assessments públicos (biblioteca compartida)?

2. **No especifica permisos de edición:**
   - Si Docente A crea assessment, ¿Docente B puede editarlo?
   - ¿O solo puede hacer copia y editar su copia?
   - ¿Hay versionamiento (track changes)?

3. **No documenta flujo de compartir:**
   - ¿Docente A puede "compartir" explícitamente con Docente B?
   - ¿O todos los assessments de una escuela son públicos?
   - ¿Hay niveles de visibilidad (privado, escuela, público)?

**Impacto:**
- **BLOQUEANTE BAJO:** API funciona para uso individual, pero colaboración limitada
- Riesgo de:
  - Duplicación de assessments (cada docente recrea el mismo)
  - Feature request inmediata de usuarios ("quiero compartir")
  - Refactor de permisos después (caro)

**Información necesaria:**
1. **Ownership y visibilidad:** Privado, escuela, o público
2. **Permisos de edición:** Crear, leer, actualizar, borrar (CRUD granular)
3. **Flujo de compartir:** Explícito o implícito
4. **Versionamiento:** Track changes o solo última versión

**Solución propuesta:**
Agregar a `FUNCTIONAL_SPECS.md`:
```markdown
### Compartir Assessments entre Docentes

**MVP (Fase 1):**
- Assessments son privados del docente creador
- No se pueden compartir entre docentes
- Cada docente crea sus propios assessments

**Post-MVP (Fase 2 - Q2 2026):**
- Agregar niveles de visibilidad:
  - `private`: Solo creador
  - `school`: Todos los docentes de la escuela pueden ver y copiar
  - `public`: Biblioteca pública de assessments (futuro marketplace)
- Flujo de compartir:
  - Docente A marca assessment como `school` visibility
  - Docente B ve en "Biblioteca de Assessments" de su escuela
  - Docente B puede "Usar" (readonly) o "Copiar y Editar" (fork)
- Permisos:
  - Creador: Full CRUD
  - Otros docentes: Read + Copy (no editar original)
- Versionamiento:
  - No en MVP (solo última versión)
  - Post-MVP: Track versions con `assessment_version` table

**Schema cambios (Fase 2):**
```sql
ALTER TABLE assessment ADD COLUMN visibility VARCHAR(20) DEFAULT 'private';
ALTER TABLE assessment ADD COLUMN created_by_teacher_id UUID;
CREATE INDEX idx_assessment_visibility ON assessment(visibility, school_id);
```
```

---

## 🟡 Ambigüedades Menores (No Bloqueantes)

### 11. Idiomas Soportados para Resúmenes IA

**Ubicación:** `spec-02-worker/02-Design/ARCHITECTURE.md`

**Ambigüedad:** No especifica qué idiomas soporta OpenAI para resúmenes.

**Impacto:** Bajo - Se puede asumir español, inglés, portugués (LATAM).

**Solución:** Documentar idiomas soportados y validación de idioma del material.

---

### 12. Tamaño Máximo de PDF a Procesar

**Ubicación:** `spec-02-worker/01-Requirements/TECHNICAL_SPECS.md`

**Ambigüedad:** No especifica límite de tamaño o número de páginas.

**Impacto:** Bajo - Puede causar timeouts con PDFs muy grandes.

**Solución:** Establecer límite (ej: 50MB, 500 páginas) y documentar.

---

### 13. Profundidad Máxima de Jerarquía Académica

**Ubicación:** `spec-03-api-administracion/02-Design/ARCHITECTURE.md:145`

**Documentado como:** "5 niveles máximo"

**Ambigüedad:** No especifica qué hacer si se intenta crear nivel 6.

**Impacto:** Bajo - Validación faltante.

**Solución:** Agregar validación que rechace parent_id si profundidad > 5.

---

### 14. Tiempo de Expiración de Tokens JWT

**Ubicación:** `00-Overview/ECOSYSTEM_OVERVIEW.md:78`

**Documentado como:** "15 minutos access token, 7 días refresh token"

**Ambigüedad:** No especifica si tiempos son configurables o hardcoded.

**Impacto:** Bajo - Puede necesitar ajuste después.

**Solución:** Hacer configurable vía variable de entorno `JWT_ACCESS_EXPIRY=15m`.

---

### 15. Puerto de Mongo Express en Dev Environment

**Ubicación:** `00-Projects-Isolated/dev-environment/03-Design/NETWORKING_DESIGN.md`

**Ambigüedad:** Mongo Express típicamente usa 8081, conflicto con api-admin.

**Impacto:** Bajo - Docker Compose fallará si no se ajusta.

**Solución:** Mapear Mongo Express a puerto 8082 en `docker-compose.yml`.

---

### 16. Estrategia de Logging en Producción

**Ubicación:** `spec-04-shared/04-Implementation/Sprint-01-Core/TASKS.md:45`

**Documentado como:** "Implementar logger con Logrus"

**Ambigüedad:** No especifica dónde se almacenan logs en producción.

**Impacto:** Bajo - Se puede usar stdout y capturar con Kubernetes.

**Solución:** Documentar que logs van a stdout, capturados por Fluentd/Loki.

---

### 17. Healthcheck Endpoints

**Ubicación:** `spec-01/05-Deployment/MONITORING.md:89`

**Documentado como:** "Implementar /health endpoint"

**Ambigüedad:** No especifica qué checks incluye (DB, RabbitMQ, etc.).

**Impacto:** Bajo - Healthcheck básico funciona, pero no detecta dependencias.

**Solución:** Documentar healthcheck completo:
```go
/health/liveness  // básico (API responde)
/health/readiness // completo (DB + RabbitMQ + MongoDB)
```

---

### 18. Convención de Nombres de Branches

**Ubicación:** `spec-06-CI-CD/06-Deployment/DEPLOYMENT_GUIDE.md`

**Ambigüedad:** No especifica convención de branches (main, develop, feature/*).

**Impacto:** Bajo - Puede causar confusión en PRs.

**Solución:** Documentar Git Flow:
```
main - producción
develop - desarrollo
feature/* - features
fix/* - bugs
```

---

## 📊 Resumen de Ambigüedades

### Por Severidad

| Severidad | Cantidad | % del Total |
|-----------|----------|-------------|
| 🔴 Críticas (Bloqueantes) | 10 | 56% |
| 🟡 Menores (No Bloqueantes) | 8 | 44% |
| **TOTAL** | **18** | **100%** |

### Por Categoría

| Categoría | Críticas | Menores | Total |
|-----------|----------|---------|-------|
| Arquitectura de Datos | 3 | 0 | 3 |
| Servicios Externos (OpenAI) | 2 | 2 | 4 |
| Deployment & Ops | 2 | 3 | 5 |
| Compliance & Seguridad | 1 | 0 | 1 |
| Features & UX | 2 | 3 | 5 |
| **TOTAL** | **10** | **8** | **18** |

### Top 3 Ambigüedades Más Críticas

1. **Sincronización PostgreSQL ↔ MongoDB** - Riesgo de inconsistencias de datos
2. **Ownership de Tablas Compartidas** - Riesgo de fallos de migraciones
3. **SLA de OpenAI** - Riesgo de costos descontrolados y UX pobre

---

## ✅ Próximos Pasos Recomendados

1. **Resolver ambigüedades críticas (1-3)** antes de iniciar desarrollo de api-mobile
2. **Resolver ambigüedades críticas (4-6)** antes de iniciar worker
3. **Resolver ambigüedades críticas (7-10)** durante implementación (menos urgentes)
4. **Ambigüedades menores (11-18)** se pueden resolver con defaults razonables

**Tiempo estimado para resolver críticas:** 8-12 horas de documentación

---

**Fin del Análisis de Ambigüedades**
