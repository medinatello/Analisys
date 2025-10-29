# Distribución de Procesos entre Componentes

## Descripción

Este documento explica **qué procesos van en cada componente** (API Mobile, API Administración, Worker) y las **razones técnicas y de negocio** para esta distribución.

---

## Criterios de Distribución

### API Mobile (Puerto 8080)

**Criterios**:
- ✅ Alta frecuencia de uso (operaciones diarias)
- ✅ Acceso por docentes y estudiantes
- ✅ Operaciones síncronas (respuesta inmediata)
- ✅ Lecturas frecuentes
- ✅ Escrituras simples (bajo impacto transaccional)

### API Administración (Puerto 8081)

**Criterios**:
- ✅ Baja frecuencia (operaciones ocasionales)
- ✅ Acceso SOLO por administradores
- ✅ Operaciones CRUD sobre entidades maestras
- ✅ Requiere auditoría completa
- ✅ Impacto estructural en el sistema

### Worker (Procesamiento Asíncrono)

**Criterios**:
- ✅ Operaciones de larga duración (> 5 segundos)
- ✅ Requiere reintentos ante fallos
- ✅ No requiere respuesta inmediata al usuario
- ✅ Procesamiento intensivo (CPU/IA)
- ✅ Integraciones con servicios externos

---

## API Mobile - Procesos Asignados

### 1. Autenticación y Sesión

**Endpoints**:
- `POST /v1/auth/login` - Login con email/password
- `POST /v1/auth/refresh` - Renovar token (Post-MVP)
- `POST /v1/auth/logout` - Cerrar sesión (Post-MVP)

**Por qué aquí**:
- **Alta frecuencia**: Cada vez que usuario abre la app
- **Respuesta inmediata**: < 1 segundo
- **Operación crítica**: Afecta todas las demás operaciones

**Volumen estimado**: 10,000+ requests/día

---

### 2. Exploración de Materiales

**Endpoints**:
- `GET /v1/materials` - Listar materiales con filtros (unit_id, subject_id, status)
- `GET /v1/materials/:id` - Obtener detalle de material + URL firmada S3

**Por qué aquí**:
- **Alta frecuencia**: Estudiantes buscan materiales constantemente
- **Operación de lectura**: Solo consultas (no modifica estado)
- **Baja latencia crítica**: < 2 segundos
- **Requiere permisos granulares**: Validar membresía por unidad

**Volumen estimado**: 50,000+ requests/día

**Query característico**:
```sql
SELECT m.*, rl.progress
FROM learning_material m
LEFT JOIN reading_log rl ON m.id = rl.material_id AND rl.student_id = $current_user
WHERE m.id IN (
  SELECT material_id FROM material_unit_link
  WHERE unit_id IN (
    SELECT unit_id FROM unit_membership WHERE user_id = $current_user
  )
)
```

---

### 3. Publicación de Material (Docentes)

**Endpoints**:
- `POST /v1/materials` - Crear material con metadatos
- `POST /v1/materials/:id/upload-complete` - Notificar upload completado

**Por qué aquí (y no en API Admin)**:
- **Frecuencia media-alta**: Docentes suben 2-5 materiales/semana
- **Operación diaria**: Parte del flujo habitual del docente
- **No requiere rol admin**: Cualquier docente puede hacerlo
- **Respuesta rápida**: API solo persiste metadatos (< 1 seg)
- **Procesamiento asíncrono**: Delega a Worker (generación IA)

**Volumen estimado**: 500-1,000 materiales nuevos/semana

**Separación de responsabilidades**:
1. **API Mobile** (síncrono): Validar, persistir metadata, generar URL firmada
2. **Cliente** (directo a S3): Upload de archivo pesado
3. **Worker** (asíncrono): Procesamiento con IA

---

### 4. Consumo de Resúmenes

**Endpoints**:
- `GET /v1/materials/:id/summary` - Obtener resumen generado por IA

**Por qué aquí**:
- **Alta frecuencia**: Estudiantes consultan antes/después de leer PDF
- **Lectura de MongoDB**: Query simple por `material_id`
- **Baja latencia**: < 1 segundo
- **Parte del flujo de estudio**: Complemento al PDF

**Volumen estimado**: 20,000+ requests/día

---

### 5. Evaluaciones (Quiz)

**Endpoints**:
- `GET /v1/materials/:id/assessment` - Obtener preguntas (SIN respuestas)
- `POST /v1/materials/:id/assessment/attempts` - Enviar respuestas, calcular puntaje

**Por qué aquí**:
- **Frecuencia alta**: Estudiantes toman quiz tras leer material
- **Validación en tiempo real**: Calcular puntaje inmediatamente
- **Operación transaccional**: Guardar intento + respuestas atómicamente
- **Feedback inmediato**: Estudiante espera resultado (< 2 seg)

**Volumen estimado**: 5,000+ intentos/semana

**Lógica crítica**:
```go
// API DEBE remover respuestas correctas antes de enviar al cliente
for i := range questions {
    questions[i].CorrectAnswer = ""  // ¡CRÍTICO!
}

// API DEBE validar en servidor (nunca confiar en cliente)
correctCount := 0
for _, answer := range studentAnswers {
    question := getQuestionFromMongoDB(answer.QuestionID)
    if answer.SelectedOption == question.CorrectAnswer {
        correctCount++
    }
}
```

---

### 6. Seguimiento de Progreso

**Endpoints**:
- `PATCH /v1/materials/:id/progress` - Actualizar progreso de lectura
- `GET /v1/materials/:id/stats` - Obtener estadísticas (solo docentes)

**Por qué aquí**:
- **Alta frecuencia (progress)**: Se envía cada 30 segundos durante lectura
- **Frecuencia media (stats)**: Docentes consultan 2-3 veces/semana
- **Operación simple (progress)**: Upsert en `reading_log`
- **Query complejo (stats)**: Agregación de progreso + intentos, pero tolera latencia (2-3 seg)

**Volumen estimado**:
- `PATCH progress`: 100,000+ requests/día
- `GET stats`: 500-1,000 requests/día

---

## API Administración - Procesos Asignados

### 1. Gestión de Usuarios

**Endpoints**:
- `POST /v1/users` - Crear usuario con rol y perfil
- `GET /v1/users` - Listar usuarios con filtros (Post-MVP)
- `PATCH /v1/users/:id` - Actualizar usuario (nombre, rol, estado)
- `DELETE /v1/users/:id` - Eliminar usuario (soft/hard delete)

**Por qué aquí (y no en API Mobile)**:
- **Frecuencia muy baja**: 10-20 usuarios nuevos/mes por escuela
- **Solo administradores**: Requiere rol `admin`
- **Impacto estructural**: Afecta permisos de todo el sistema
- **Requiere auditoría**: Todas las operaciones en `audit_log`
- **Validaciones complejas**: Prevenir quedarse sin admins, verificar dependencias

**Volumen estimado**: 50-100 requests/mes

**Validación crítica**:
```sql
-- No permitir eliminar último admin
SELECT COUNT(*) FROM app_user WHERE system_role = 'admin' AND id != $deleting_id;
-- Si count = 1, rechazar eliminación
```

---

### 2. Gestión de Jerarquía Académica

**Endpoints**:
- `POST /v1/schools` - Crear escuela
- `POST /v1/units` - Crear unidad académica (año, sección, club)
- `PATCH /v1/units/:id` - Actualizar unidad
- `DELETE /v1/units/:id` - Eliminar unidad (Post-MVP)

**Por qué aquí**:
- **Frecuencia muy baja**: 1-2 veces al iniciar año escolar
- **Solo administradores o docentes owner**: Permisos especiales
- **Impacto estructural**: Define organización de toda la escuela
- **Requiere validaciones complejas**: Prevenir jerarquía circular, validar parent_unit

**Volumen estimado**: 20-50 requests/mes

**Validación crítica**:
```sql
-- Trigger previene ciclos
CREATE OR REPLACE FUNCTION prevent_circular_hierarchy() ...
```

---

### 3. Asignación de Membresías

**Endpoints**:
- `POST /v1/units/:id/members` - Asignar usuario a unidad con rol
- `DELETE /v1/units/:id/members/:userId` - Remover usuario de unidad
- `POST /v1/guardian-relations` - Crear vínculo tutor-estudiante

**Por qué aquí**:
- **Frecuencia baja**: Principalmente al inicio de año/semestre
- **Solo administradores**: Requiere permisos especiales
- **Afecta permisos**: Define quién puede ver qué materiales
- **Operación bulk común**: Asignar 30 estudiantes a una sección

**Volumen estimado**: 100-200 requests/mes (picos en inicio de ciclo)

---

### 4. Gestión de Materias

**Endpoints**:
- `POST /v1/subjects` - Crear materia en catálogo
- `PATCH /v1/subjects/:id` - Actualizar materia
- `DELETE /v1/subjects/:id` - Eliminar materia (Post-MVP)

**Por qué aquí**:
- **Frecuencia muy baja**: 1-2 veces al configurar escuela
- **Solo administradores**: Define catálogo maestro
- **Datos maestros**: Afecta todos los materiales

**Volumen estimado**: 10-20 requests/año

---

### 5. Moderación de Materiales

**Endpoints**:
- `DELETE /v1/materials/:id` - Eliminar material inapropiado
- `GET /v1/materials/reported` - Ver materiales reportados (Post-MVP)

**Por qué aquí**:
- **Frecuencia muy baja**: Solo cuando hay contenido problemático
- **Solo administradores**: Moderación requiere permisos especiales
- **Impacto significativo**: Elimina material para todos los estudiantes
- **Requiere limpieza completa**: S3 + MongoDB + PostgreSQL (via Worker)

**Volumen estimado**: 5-10 requests/mes

**Flujo**:
1. Admin llama `DELETE /v1/materials/:id`
2. API marca como eliminado en PostgreSQL (`deleted_at`, `deleted_by`)
3. API publica evento `material_deleted` a RabbitMQ
4. Worker elimina archivos S3 y documentos MongoDB

---

### 6. Estadísticas Globales

**Endpoints**:
- `GET /v1/stats/global` - Métricas de toda la plataforma
- `GET /v1/stats/school/:id` - Métricas por escuela (Post-MVP)

**Por qué aquí**:
- **Frecuencia baja**: Consulta ocasional por administradores
- **Solo administradores**: Datos sensibles del sistema completo
- **Query pesado**: Agregaciones sobre múltiples tablas
- **No crítico en latencia**: Tolera 3-5 segundos

**Volumen estimado**: 20-50 requests/mes

**Métricas retornadas**:
```json
{
  "platform": {
    "total_users": 1250,
    "active_users_30d": 980,
    "total_schools": 15,
    "total_units": 127
  },
  "materials": {
    "total_published": 450,
    "total_this_month": 35,
    "top_subjects": [...]
  },
  "engagement": {
    "materials_accessed_30d": 380,
    "average_progress": 65.5,
    "quizzes_completed_30d": 1250
  },
  "performance": {
    "average_processing_time_seconds": 85,
    "nlp_success_rate": 97.5
  }
}
```

---

## Worker - Procesos Asignados

### 1. Generación de Resumen y Quiz

**Evento**: `material_uploaded` (routing key: `material.uploaded`)
**Cola**: `material_processing_high` (prioridad 10, FIFO)

**Por qué asíncrono**:
- **Duración larga**: 60-180 segundos (depende de NLP)
- **Puede fallar**: API de NLP puede tener timeout/rate limit
- **Requiere reintentos**: Backoff exponencial (1min, 5min, 15min, 1h, 6h)
- **No bloquea usuario**: Docente recibe 202 Accepted inmediatamente
- **Procesamiento intensivo**: Extracción de texto, llamada IA

**Flujo**:
1. Descarga PDF de S3 (10-30 seg)
2. Extrae texto con OCR si es necesario (5-20 seg)
3. Llama OpenAI GPT-4 para resumen (30-60 seg)
4. Llama OpenAI GPT-4 para quiz (30-60 seg)
5. Persiste en MongoDB (< 1 seg)
6. Actualiza PostgreSQL (< 1 seg)
7. Notifica docente (< 1 seg)

**Volumen estimado**: 500-1,000 eventos/semana

---

### 2. Reprocesamiento de Material

**Evento**: `material_reprocess` (routing key: `material.reprocess`)
**Cola**: `material_processing_medium` (prioridad 5)

**Por qué asíncrono**:
- **Duración larga**: Idéntico al procesamiento inicial
- **Solicitud explícita**: Docente pide regenerar contenido
- **No urgente**: Puede esperar algunos minutos

**Casos de uso**:
- Resumen generado tiene errores o es poco claro
- Se actualiza modelo NLP (mejores resultados)
- Docente sube nueva versión de PDF

**Volumen estimado**: 50-100 eventos/mes

---

### 3. Notificaciones de Evaluación

**Evento**: `assessment_attempt_recorded` (routing key: `assessment.attempt_recorded`)
**Cola**: `material_processing_medium` (prioridad 5)

**Por qué asíncrono**:
- **No afecta experiencia del estudiante**: Estudiante ya tiene sus resultados
- **Latencia tolerable**: Docente puede recibir notificación en 1-5 minutos
- **Puede fallar**: Servicio de email/push puede estar caído
- **Procesamiento batch**: Agrupar notificaciones si hay múltiples intentos

**Flujo**:
1. Consulta PostgreSQL: Datos del intento + estudiante
2. Identifica docentes de la unidad
3. Construye mensaje personalizado
4. Envía email + push notification
5. Registra notificación enviada

**Volumen estimado**: 5,000+ eventos/semana

---

### 4. Limpieza de Material Eliminado

**Evento**: `material_deleted` (routing key: `material.deleted`)
**Cola**: `material_processing_low` (prioridad 1)

**Por qué asíncrono**:
- **No urgente**: Admin ya recibió confirmación de eliminación en PostgreSQL
- **Operación lenta**: Eliminar múltiples archivos en S3 (puede tomar minutos)
- **Puede fallar**: S3 puede estar temporalmente inaccesible
- **Limpieza eventual**: Aceptable que tome 10-30 minutos

**Flujo**:
1. Lista todos los archivos S3 con prefijo `{school}/{unit}/{material}/`
2. Elimina archivos uno por uno (source/, processed/, assets/)
3. Elimina documentos MongoDB (`material_summary`, `material_assessment`, `material_event`)
4. Registra evento de limpieza completada

**Volumen estimado**: 10-20 eventos/mes

---

### 5. Bienvenida a Nuevos Estudiantes

**Evento**: `student_enrolled` (routing key: `student.enrolled`)
**Cola**: `material_processing_low` (prioridad 1)

**Por qué asíncrono**:
- **No urgente**: Bienvenida puede llegar en 5-10 minutos
- **Operación simple**: Solo enviar email/push
- **Mejora la experiencia**: No afecta funcionalidad crítica

**Flujo**:
1. Obtiene datos del estudiante y unidad
2. Construye email de bienvenida personalizado
3. Incluye primeros pasos, materiales disponibles
4. Envía notificación

**Volumen estimado**: 100-200 eventos/mes

---

## Comparación de Características

| Característica | API Mobile | API Admin | Worker |
|----------------|------------|-----------|--------|
| **Frecuencia de Uso** | Alta (1000s/día) | Baja (10s/día) | Media (100s/día) |
| **Actores** | Docentes, Estudiantes, Tutores | Solo Administradores | Sistema |
| **Latencia Objetivo** | < 1 seg | < 2 seg | Minutos (asíncrono) |
| **Tipo de Operaciones** | Lecturas + Escrituras simples | CRUD maestro | Procesamiento IA |
| **Requiere Reintentos** | No (síncronas) | Raramente | Sí (IA puede fallar) |
| **Escalado** | Horizontal (N instancias) | Vertical (1-2 instancias) | Horizontal (N workers) |
| **Auditoría** | Logs normales | Completa (audit_log) | Eventos registrados |

---

## Procesos que NO van en API Mobile

### ❌ Crear Usuarios Manualmente
**Por qué**:
- Frecuencia muy baja
- Requiere rol admin
- Va en **API Admin**: `POST /v1/users`

### ❌ Crear Unidades Académicas (Excepto Docentes Owner)
**Por qué**:
- Frecuencia muy baja
- Impacto estructural
- Va en **API Admin**: `POST /v1/units`

**Excepción**: Docente owner puede crear sub-unidades (ej: club dentro de su sección)

### ❌ Generar Resumen de Material
**Por qué**:
- Procesamiento largo (60-180 seg)
- Requiere IA externa
- Puede fallar y necesita reintentos
- Va en **Worker**: Evento `material_uploaded`

---

## Procesos que NO van en API Admin

### ❌ Buscar y Leer Materiales
**Por qué**:
- Alta frecuencia
- Operación de estudiantes/docentes (no admin)
- Va en **API Mobile**: `GET /v1/materials`

### ❌ Realizar Evaluaciones
**Por qué**:
- Alta frecuencia
- Operación de estudiantes
- Va en **API Mobile**: `POST /v1/materials/:id/assessment/attempts`

### ❌ Ver Progreso de Estudiantes (Docentes)
**Por qué**:
- Frecuencia media
- Operación de docentes (no solo admin)
- Va en **API Mobile**: `GET /v1/materials/:id/stats`

---

## Procesos que NO van en Worker

### ❌ Validación de Respuestas de Quiz
**Por qué**:
- Requiere respuesta inmediata (< 2 seg)
- Estudiante espera resultado en pantalla
- Operación simple (comparar respuestas)
- Va en **API Mobile**: `POST /v1/materials/:id/assessment/attempts`

### ❌ Actualización de Progreso de Lectura
**Por qué**:
- Alta frecuencia (cada 30 seg)
- Operación muy simple (upsert en tabla)
- Latencia crítica (< 500ms)
- Va en **API Mobile**: `PATCH /v1/materials/:id/progress`

### ❌ Generación de URLs Firmadas S3
**Por qué**:
- Respuesta inmediata al usuario
- Operación simple (firma criptográfica)
- No requiere procesamiento externo
- Va en **API Mobile**: `GET /v1/materials/:id` (incluye URL)

---

## Casos Especiales y Excepciones

### Caso 1: Docente ve estadísticas de su material

**Decisión**: API Mobile
**Razón**: Aunque es operación compleja, es parte del flujo diario del docente (no requiere ser admin)

### Caso 2: Docente crea unidad "Club de Programación"

**Decisión**: Podría ir en ambas
**Opción A**: API Admin (centralizar CRUD de jerarquía)
**Opción B**: API Mobile (si docente es owner de unidad padre)
**Recomendación MVP**: API Admin (simplicidad)
**Post-MVP**: Permitir en API Mobile para docentes owner

### Caso 3: Regenerar resumen de un material

**Decisión**: Endpoint en API Mobile + Procesamiento en Worker
**Flujo**:
1. Docente llama `POST /v1/materials/:id/reprocess` (API Mobile)
2. API valida permisos (autor o admin)
3. API publica evento `material_reprocess`
4. Worker procesa (idéntico a procesamiento inicial)

---

## Escalado por Componente

### API Mobile

**Escenario**: 10,000 usuarios activos

- **Instancias**: 3-5 detrás de load balancer
- **Conexiones PostgreSQL**: Pool de 25 por instancia
- **Caché**: Redis para materiales frecuentes
- **Costo estimado**: $200-500/mes (EC2 t3.medium)

### API Admin

**Escenario**: 10,000 usuarios activos

- **Instancias**: 1-2 (alta disponibilidad)
- **Conexiones PostgreSQL**: Pool de 10 por instancia
- **Costo estimado**: $50-100/mes (EC2 t3.small)

### Worker

**Escenario**: 500 materiales nuevos/semana

- **Instancias**: 2-4 workers paralelos
- **Cola**: RabbitMQ con 3 colas de prioridades
- **Throughput**: 30-40 materiales/hora
- **Costo estimado**: $300-600/mes (EC2 t3.medium + NLP API)

---

## Resumen de Decisiones

| Proceso | Componente | Razón Principal |
|---------|-----------|-----------------|
| Login | API Mobile | Alta frecuencia, respuesta inmediata |
| Buscar materiales | API Mobile | Alta frecuencia, lectura simple |
| Subir material | API Mobile | Uso diario de docentes |
| Leer resumen | API Mobile | Alta frecuencia, lectura MongoDB |
| Realizar quiz | API Mobile | Alta frecuencia, validación inmediata |
| Ver progreso | API Mobile | Uso frecuente de docentes |
| Crear usuarios | API Admin | Baja frecuencia, solo admins |
| Gestionar jerarquía | API Admin | Baja frecuencia, impacto estructural |
| Moderar contenidos | API Admin | Baja frecuencia, solo admins |
| Stats globales | API Admin | Baja frecuencia, solo admins |
| Generar resumen | Worker | Procesamiento largo, puede fallar |
| Reprocesar material | Worker | Procesamiento largo |
| Notificar evaluación | Worker | No urgente, puede fallar |
| Limpiar S3/MongoDB | Worker | Operación lenta, no urgente |
| Bienvenida estudiante | Worker | No urgente, mejora UX |

---

**Documento**: Distribución de Procesos entre Componentes
**Versión**: 1.0
**Fecha**: 2025-01-29
**Autor**: Equipo EduGo
