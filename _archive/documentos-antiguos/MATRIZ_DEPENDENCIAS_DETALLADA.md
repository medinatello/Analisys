# MATRIZ DETALLADA DE DEPENDENCIAS INTER-REPOSITORIO

**Generado:** 14 de Noviembre, 2025  
**Propósito:** Documento técnico de dependencias para coordinación de implementación  
**Audiencia:** Arquitectos, Tech Leads, Project Managers

---

## 📊 OVERVIEW VISUAL

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    ECOSISTEMA EDUGO - FLUJOS DE DATOS                   │
└──────────────────────────────────────────────────────────────────────────┘

ESCRITORES:
  Mobile:  users, materials, material_progress, assessment_attempt*
  Admin:   school, academic_unit, unit_membership, subject*
  Worker:  material_summary, material_assessment, material_event

LECTORES:
  Mobile:  school, academic_unit, unit_membership, material_summary*, material_assessment*
  Admin:   users, materials, material_event (para reportes)
  Worker:  materials (para procesar)

COMUNICACIÓN:
  Mobile  ─publish──→ RabbitMQ ──consume→ Worker
  Admin   ─publish──→ RabbitMQ ──consume→ Worker (futura)
  Mobile  ←──import──  Shared
  Admin   ←──import──  Shared
  Worker  ←──import──  Shared

DATOS EXTERNOS:
  Worker  ──call──→ OpenAI
  Mobile  ←──read── MongoDB (summaries, assessments)
  All     ←──read── PostgreSQL (shared data)
```

---

## 📋 TABLA 1: DEPENDENCIAS POR TABLA PostgreSQL

### Tabla: `users`

```
Propietario:     api-mobile
Escritores:      api-mobile, api-administracion
Lectores:        api-mobile, api-administracion, worker (logs)
Criticidad:      🔴 CRÍTICA
Impacto de cambios: ALTO
```

**Cambios en schema de users:**

| Cambio | Impacto | Coordinación Necesaria |
|--------|---------|------------------------|
| Agregar columna | ✅ Retro-compatible | Simple migration |
| Eliminar columna | ❌ BREAKING | Coordinar con mobile y admin |
| Renombrar columna | ❌ BREAKING | Migración cuidadosa |
| Cambiar tipo datos | ❌ BREAKING | Retro-compatibilidad necesaria |
| Agregar constraints | ⚠️ Depende | Verificar datos existentes |

**Flujo de cambio propuesto:**

```
1. Crear PR en mobile/admin con cambio
2. Crear migration en dev-environment
3. Agregar field a entity en mobile/admin
4. Ejecutar migration (con rollback plan)
5. Merge PR
6. Deploy versiones nuevas
```

---

### Tabla: `materials`

```
Propietario:     api-mobile
Escritores:      api-mobile, worker (processing_status)
Lectores:        api-mobile, api-administracion, worker
Criticidad:      🔴 CRÍTICA
Campos críticos: s3_key (S3), processing_status (worker)
```

**Columnas y responsabilidades:**

| Columna | Escritor | Lector | Notas |
|---------|----------|--------|-------|
| id | mobile | all | UUID, generado por mobile |
| title | mobile | all | Ingresado por profesor |
| description | mobile | admin | Mostrado en admin |
| author_id | mobile | mobile, admin | FK a users |
| subject_id | mobile | mobile, admin | Pendiente FK a subject |
| s3_key | mobile | mobile, worker | Ruta en S3 |
| s3_url | mobile | mobile | URL públicamente accesible |
| status | mobile | mobile, admin | draft, published, archived |
| processing_status | worker | mobile, admin | pending, processing, completed, failed |
| is_deleted | mobile | all | Soft delete |
| created_at | mobile | all | Timestamp |
| updated_at | mobile, worker | all | Timestamp |

**Flujo crítico:**

```
Mobile:
  1. INSERT materials (status=published, processing_status=pending)
  2. PUBLISH evento a RabbitMQ
     ↓
Worker:
  3. CONSUME evento
  4. UPDATE materials SET processing_status='processing'
  5. Procesar...
  6. UPDATE materials SET processing_status='completed'
     ↓
Mobile:
  7. GET /v1/materials/:id → verifica processing_status
  8. Si completed → muestra resumen/quiz
  9. Si pending/processing → muestra "en procesamiento"
  10. Si failed → muestra error
```

**Reglas de cambio:**

```
✅ SEGURO:
- Agregar processing_status_detail (texto descriptivo)
- Agregar retry_count (contador de reintentos del worker)
- Agregar last_processed_at (timestamp)

❌ PELIGROSO:
- Cambiar el rango de valores de processing_status
- Eliminar processing_status
- Cambiar el tipo de s3_key
```

---

### Tabla: `material_progress`

```
Propietario:     api-mobile
Escritores:      api-mobile
Lectores:        api-mobile, worker (futuro - para estadísticas)
Criticidad:      🟡 MEDIA
```

**Cambios esperados:**

```
Agregar (no eliminar):
  - time_spent_seconds (int)
  - last_page_number (int)
  - current_chapter (string)

Mantener:
  - material_id (FK)
  - user_id (FK)
  - percentage (0-100)
  - status (not_started, in_progress, completed)
```

---

### Tabla: `school`

```
Propietario:     api-administracion
Escritores:      api-administracion
Lectores:        api-administracion, api-mobile (cross-api)
Criticidad:      🔴 CRÍTICA
```

**Dependencia de api-mobile:**

```
Flujo futuro (Mobile-3):
  1. Estudiante login a mobile
  2. Mobile obtiene user de PostgreSQL
  3. Mobile consulta GET /v1/schools/:id (desde api-admin)
  4. Mobile consulta GET /v1/units/:id (desde api-admin)
  5. Mobile filtra materials por unit_id
```

**Regla:** Mobile solo LECTURA, nunca modificar schools

---

### Tabla: `academic_unit`

```
Propietario:     api-administracion
Escritores:      api-administracion
Lectores:        api-administracion, api-mobile (cross-api)
Criticidad:      🔴 CRÍTICA
Relación:        Recursiva (parent_unit_id → academic_unit)
```

**Constraints de integridad:**

```sql
-- Prevenir ciclos
CHECK (parent_unit_id != id)

-- FK a school
FOREIGN KEY (school_id) REFERENCES school(id)

-- FK recursivo
FOREIGN KEY (parent_unit_id) REFERENCES academic_unit(id)
```

**Operaciones críticas:**

```
CREATE:  Admin crea unidad hijo → requiere padre válido
UPDATE:  Admin cambia parent_unit_id → validar no crea ciclo
DELETE:  Admin elimina unidad → ¿huérfanos? → soft delete recomendado
QUERY:   Mobile obtiene árbol → índices en parent_unit_id y school_id
```

---

### Tabla: `unit_membership`

```
Propietario:     api-administracion
Escritores:      api-administracion
Lectores:        api-administracion, api-mobile (cross-api)
Criticidad:      🔴 CRÍTICA
Composite Key:   (unit_id, user_id)
```

**Operaciones:**

| Operación | Origen | Impacto |
|-----------|--------|--------|
| Agregar usuario a unidad | Admin | Mobile puede verlo en esa unidad |
| Quitar usuario de unidad | Admin | Mobile no lo ve más en unidad |
| Cambiar rol en unidad | Admin | Mobile interpreta permisos según rol |

**Regla de sincronización:**

```
Cuando Mobile necesita saber:
  "¿En qué unidades estoy?"
  
Debe consultar api-admin:
  GET /v1/users/me/units  (requiere integración en Mobile-3)
  
Respuesta:
  [
    {
      unit_id: "uuid",
      unit_name: "5.º Año",
      role: "member"  // o "owner"
    }
  ]
```

---

### Tabla: `assessment` (PENDIENTE)

```
Propietario:     api-mobile (por implementarse)
Escritores:      api-mobile (Mobile-1)
Lectores:        api-mobile, worker (futuro)
Criticidad:      🔴 CRÍTICA
Próximo Sprint:  Mobile-1
```

**Diseño propuesto:**

```sql
CREATE TABLE assessment (
  id UUID PRIMARY KEY,
  material_id UUID NOT NULL REFERENCES materials(id),
  total_questions INT,
  total_points INT,
  passing_score INT,  -- 70 de 100, ej.
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Índices críticos
CREATE INDEX idx_assessment_material ON assessment(material_id);
```

**Relación con MongoDB:**

```
PostgreSQL assessment:    Metadatos, puntuación, umbral
MongoDB material_assessment: Preguntas reales, opciones, respuestas
```

---

### Tabla: `assessment_attempt` (PENDIENTE)

```
Propietario:     api-mobile (por implementarse)
Escritores:      api-mobile (estudiante intenta quiz)
Lectores:        api-mobile (ver historial), admin (reportes)
Criticidad:      🔴 CRÍTICA
Próximo Sprint:  Mobile-1
```

**Diseño propuesto:**

```sql
CREATE TABLE assessment_attempt (
  id UUID PRIMARY KEY,
  assessment_id UUID NOT NULL REFERENCES assessment(id),
  student_id UUID NOT NULL REFERENCES users(id),
  score INT,
  total_points INT,
  passed BOOLEAN,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  duration_seconds INT
);
```

---

## 📋 TABLA 2: DEPENDENCIAS POR COLECCIÓN MongoDB

### Colección: `material_summary`

```
Propietario:     worker
Escritor:        worker (generador de contenido)
Lectores:        api-mobile (consultas), admin (reportes futuros)
Criticidad:      🔴 CRÍTICA
Generado por:    Worker procesando PDF + OpenAI
```

**Ciclo de vida:**

```
Worker publica evento MATERIAL_UPLOADED
  ↓
Worker descarga PDF
  ↓
Worker extrae texto
  ↓
Worker llama OpenAI
  ↓
Worker INSERTA en material_summary con status='processing'
  ↓
Worker completa contenido
  ↓
Worker ACTUALIZA status='completed'
  ↓
Mobile consulta y obtiene documento
```

**Dependencia crítica:**

```
Si Worker crea documento incompleto:
  → Mobile obtiene datos parciales
  → Estudiante ve resumen "cortado"
  
Si Worker falla:
  → Documento queda con status='failed'
  → Mobile muestra "Error procesando material"
  
Si Worker cambia estructura:
  → Mobile no puede parsear
  → BREAKING CHANGE - coordinar con Mobile-3
```

**Cambios seguros:**

```
✅ Agregar campo nuevo con valor default
✅ Agregar subcampo en nested document
❌ Eliminar campo que Mobile usa
❌ Cambiar tipo de dato
❌ Cambiar nombre de campo
```

---

### Colección: `material_assessment`

```
Propietario:     worker
Escritor:        worker (generador de quizzes)
Lectores:        api-mobile (lectura de preguntas)
Criticidad:      🔴 CRÍTICA
Generado por:    Worker con OpenAI
```

**Estructura esperada:**

```javascript
{
  _id: ObjectId,
  material_id: "uuid",  // CRÍTICA: Mobile filtra por esto
  total_questions: 5,
  total_points: 100,
  passing_score: 70,
  
  questions: [
    {
      id: "q1",  // CRÍTICA: Mobile referencia por esto
      text: "¿Pregunta?",
      options: [
        { id: "a", text: "Opción A" },
        { id: "b", text: "Opción B" },
        { id: "c", text: "Opción C" },
        { id: "d", text: "Opción D" }
      ],
      correct_answer: "b",  // CRÍTICA: Worker valida respuestas
      difficulty: "medium",
      points: 20,
      feedback: {
        correct: "¡Correcto! Porque...",
        incorrect: "Incorrecto. Deberías..."
      }
    }
  ],
  
  created_at: ISODate,
  updated_at: ISODate
}
```

**Reglas de cambio:**

```
❌ NO CAMBIAR:
- Estructura de questions array
- Campo correct_answer (worker lo usa)
- Campo id en questions (mobile lo referencia)

✅ SEGURO CAMBIAR:
- Agregar metadata al documento raíz
- Agregar campos en feedback
- Agregar rubric (rúbrica de evaluación)
```

---

### Colección: `material_event` (Log)

```
Propietario:     worker
Escritor:        worker (logs de procesamiento)
Lectores:        admin (reportes), monitoring
Criticidad:      🟡 MEDIA
TTL Policy:      90 días (auto-eliminación)
```

**No hay dependencias críticas - solo auditoria**

---

## 📋 TABLA 3: DEPENDENCIAS POR EVENTO RabbitMQ

### Evento: `MATERIAL_UPLOADED`

```
Publicador:      api-mobile
Consumidor:      worker
Criticidad:      🔴 CRÍTICA
Queue:           edugo.material.uploaded
Exchange:        edugo.materials
Routing Key:     material.uploaded
```

**Payload actual:**

```json
{
  "type": "MATERIAL_UPLOADED",
  "material_id": "uuid",
  "file_path": "/uploads/...",
  "teacher_id": "uuid",
  "subject_id": "uuid",
  "timestamp": "2025-11-14T10:30:00Z"
}
```

**Contrato:**

```
Campos OBLIGATORIOS (Worker depende):
  ✅ type
  ✅ material_id  (Worker lo usa para UPDATE materials)
  ✅ file_path    (Worker lo usa para descargar)

Campos OPCIONALES:
  ✅ teacher_id   (Worker puede loguear)
  ✅ timestamp    (Worker puede monitorear latencia)
```

**Evolución segura:**

```
✅ Agregar campo nuevo (Worker lo ignora si usa ignore_unknown)
❌ Eliminar campo obligatorio
❌ Cambiar nombre de campo
❌ Cambiar tipo de material_id (UUID vs string)
```

**Versioning strategy:**

```
Si cambios NO-compatibles:
  Incrementar version: v2
  Publicar a nueva queue: edugo.material.uploaded.v2
  Mantener v1 por 2 semanas (período de transición)
  Worker consume ambas versiones temporalmente
```

---

### Evento: `ASSESSMENT_CREATED` (Pendiente)

```
Publicador:      api-mobile (Mobile-1)
Consumidor:      worker (futuro - para logs), admin (logs)
Criticidad:      🟡 MEDIA
Queue:           edugo.assessment.created
```

**Payload propuesto:**

```json
{
  "type": "ASSESSMENT_CREATED",
  "assessment_id": "uuid",
  "material_id": "uuid",
  "total_questions": 5,
  "created_by": "uuid",  // Teacher
  "timestamp": "2025-11-14T10:30:00Z"
}
```

---

## 📋 TABLA 4: DEPENDENCIAS POR ENDPOINT HTTP CROSS-API

### Endpoints que Mobile necesita de Admin

```
GET /v1/schools/:id
  Retorna: { id, name, code, address, metadata }
  Uso:     Mobile cachea para mostrar nombre escuela
  Timing:  Una vez al login

GET /v1/schools/:schoolId/units
  Retorna: [{ id, name, parent_id, type }]
  Uso:     Mobile filtra materiales por unidad
  Timing:  Una vez al login + refresh en background

GET /v1/units/:id/tree
  Retorna: { id, name, children: [...] }  (recursivo)
  Uso:     Mobile muestra árbol jerárquico
  Timing:  On-demand por UI
  Criticidad: 🔴 Necesario para Mobile-3

GET /v1/units/:id/members
  Retorna: [{ user_id, user_name, role }]
  Uso:     Mobile valida que usuario está en unidad
  Timing:  Una vez al login
  Criticidad: 🟡 Soporte

GET /v1/users/me/units
  Retorna: [{ unit_id, unit_name, role }]
  Uso:     Mobile muestra mis unidades
  Timing:  Una vez al login
  Criticidad: 🔴 Core (Mobile-3)
```

### Endpoints que Admin necesita de Mobile

```
GET /v1/materials?unit_id=uuid
  Retorna: [{ id, title, author, status }]
  Uso:     Admin ve materiales por unidad
  Timing:  On-demand
  Criticidad: 🟡 Reportes (Admin-4)

GET /v1/materials/:id/analytics
  Retorna: { views, average_score, completion_rate }
  Uso:     Admin ve estadísticas
  Timing:  Dashboard refresh
  Criticidad: 🟡 Reportes (Admin-4)
```

---

## 📋 TABLA 5: MATRIZ DE COORDINACIÓN REQUERIDA

### Al hacer cambios en shared

| Cambio | Mobile | Admin | Worker | Acción |
|--------|--------|-------|--------|--------|
| Actualizar go.mod | ✅ Pull | ✅ Pull | ✅ Pull | Simple: go get |
| Agregar nuevo módulo | ✅ Import | ✅ Import | ✅ Import | Necesita PRs |
| Cambiar API de módulo | ❌ BREAKING | ❌ BREAKING | ❌ BREAKING | Coordinar release |
| Cambiar config keys | ⚠️ Depende | ⚠️ Depende | ⚠️ Depende | Actualizar .env |

---

### Al hacer cambios en PostgreSQL (api-mobile)

| Tabla | Cambio | Requiere Coordinación |
|-------|--------|----------------------|
| users | agregar campo | ✅ Admin, Worker |
| users | eliminar campo | ✅ Admin, Worker |
| materials | agregar columna | ✅ Admin |
| materials | cambiar processing_status | ✅ Admin, Worker |
| material_progress | agregar campo | ✅ Admin |

**Proceso:**

```
1. Crear migration en dev-environment
2. Crear PR en mobile
3. Notificar cambio a admin, worker
4. Admin/Worker actualizan queries (si es breaking)
5. Merge PR en mobile
6. Release mobile
7. Deploy migration en dev-environment
```

---

### Al hacer cambios en MongoDB (Worker)

| Colección | Cambio | Requiere Coordinación |
|-----------|--------|----------------------|
| material_summary | agregar campo | ✅ Mobile (Mobile-3) |
| material_summary | eliminar campo | ❌ BREAKING - Mobile |
| material_assessment | cambiar estructura questions | ❌ BREAKING - Mobile |
| material_event | cualquier cambio | Solo logging |

**Regla:** Worker puede escribir, Mobile solo lee → Mobile es frágil

---

## 📊 TIMELINE DE ACTIVACIÓN DE DEPENDENCIAS

### Fases Futuras

```
AHORA (Nov 2025):
  ✅ shared.testing publicado
  ✅ api-administracion (jerarquía) completado
  ✅ dev-environment actualizado
  
DICIEMBRE 2025 - ENERO 2026 (Mobile-1):
  🔜 api-mobile.assessment (nueva tabla)
  🔜 api-mobile.assessment_attempt (nueva tabla)
  → DEPENDENCIA CREADA: Mobile requiere evaluation logic
  
ENERO - FEBRERO 2026 (Worker-2):
  🔜 worker.pdf processing
  🔜 worker.openai integration
  → DEPENDENCIA CRÍTICA: MongoDB schemas nuevos
  → IMPACTO: Mobile debe poder leer material_summary/assessment
  
FEBRERO 2026 (Mobile-3):
  🔜 api-mobile integración jerarquía
  → DEPENDENCIA CRÍTICA: Client HTTP a api-admin
  → IMPACTO: Requiere que Admin-2 esté completado
  
FEBRERO 2026 (Admin-2):
  🔜 api-administracion perfiles
  🔜 api-administracion materias
  → DEPENDENCIA: Mobile debe poder consultar perfiles
  → IMPACTO: Requiere cross-API integration
  
MARZO 2026 (Admin-3, Admin-4):
  🔜 Reportes y analytics
  → DEPENDENCIA: Requiere que Mobile-1 esté completo
  → IMPACTO: Analytics queries contra assessment_attempt
```

---

## 🚨 PUNTOS DE RIESGO CRÍTICOS

### Riesgo 1: Cambios en MongoDB sin versioning

**Escenario:** Worker cambia estructura de material_summary

```
Antes:
  { _id, material_id, summary: "texto", sections: [] }
  
Después:
  { _id, material_id, summary_text: "texto", chapters: [] }
```

**Impacto:** Mobile falla al parsear documento

**Mitigación:**
```
✅ Mantener ambos campos por transición (30 días)
✅ Publicar changelog
✅ Coordinar con Mobile antes de cambio
❌ NO cambiar sin aviso
```

---

### Riesgo 2: Cambio en event RabbitMQ

**Escenario:** Worker cambia fields en MATERIAL_UPLOADED

```
Antes:  { type, material_id, file_path }
Después: { type, material_id, file_url }
```

**Impacto:** Worker falla consumiendo eventos

**Mitigación:**
```
✅ Usar versioning de eventos
✅ Mantener ambos campos por retrocompatibilidad
✅ Consumer ignora campos unknown
❌ NO cambiar sin plan de migración
```

---

### Riesgo 3: Migración de datos sin rollback

**Escenario:** Admin crea columna obligatoria sin default

```
ALTER TABLE schools ADD COLUMN region VARCHAR(100) NOT NULL;
```

**Impacto:** Datos existentes fallan inserción

**Mitigación:**
```
✅ Siempre usar default en nuevas columnas
✅ Hacer NOT NULL en 2 fases:
   1. Agregar con DEFAULT
   2. Después de llenar datos, cambiar a NOT NULL
✅ Tener rollback plan
```

---

## 📋 CHECKLIST DE COORDINACIÓN POR SPRINT

### Antes de iniciar cada Sprint

```
COORDINACIÓN REQUERIDA:

Mobile-1 (evaluaciones):
  [ ] Revisar schema propuesto con Admin, Worker
  [ ] Revisar eventos RabbitMQ propuestos
  [ ] Asegurar que MongoDB schema está listo (Worker-2?)
  
Worker-2 (PDFs + OpenAI):
  [ ] Revisar MongoDB schemas con Mobile
  [ ] Revisar eventos RabbitMQ con Mobile
  [ ] Asegurar retro-compatibilidad de datos
  
Admin-2 (perfiles):
  [ ] Revisar schema con Mobile
  [ ] Asegurar que Mobile puede consultar (cross-API)
  
Admin-3 (materias):
  [ ] Coordinar con Mobile qué campos necesita
  [ ] Asegurar índices en PostgreSQL

Mobile-3 (integración jerarquía):
  [ ] Asegurar que Admin-1 y Admin-2 están completos
  [ ] Revisar APIs necesarias en Admin
  [ ] Planificar caché de datos
```

---

## 🔄 PROCESO DE CAMBIO EN DEPENDENCIAS COMPARTIDAS

### Cambio Seguro (Compatible hacia atrás)

```
EJEMPLO: Agregar columna nueva a users

PASO 1: Crear PR en mobile
  - Agregar migration: ALTER TABLE users ADD COLUMN new_field TYPE DEFAULT value
  - El DEFAULT hace compatible con código antiguo
  - Crear el campo en entity
  
PASO 2: Merge en mobile
  
PASO 3: Deploy migration
  
PASO 4: Otros repos pueden ahora usar el campo (sin urgencia)
```

### Cambio Incompatible (Breaking Change)

```
EJEMPLO: Cambiar rango de processing_status

PASO 1: Crear PR en mobile
  - Agregar nuevo status: "retry"
  - Código debe manejar statuses nuevos
  
PASO 2: Notificar a Admin, Worker, Dev-Team
  
PASO 3: Crear timeline:
  - Hoy: Mobile PR abierto
  - +1 semana: Merge en mobile (versión X.1)
  - +2 semanas: Admin, Worker actualizan
  - +3 semanas: Deploy versiones nuevas coordinadas
  
PASO 4: Si es REALMENTE crítico (eliminar status):
  - Marcar status como deprecated
  - Mantener por 2-3 sprints
  - Luego eliminar
```

---

**Última revisión:** 14 de Noviembre, 2025  
**Próxima revisión:** Fin de Mobile-1 (Enero 2026)

---

_Documento de referencia técnica para evitar integraciones rotas entre repositorios_
