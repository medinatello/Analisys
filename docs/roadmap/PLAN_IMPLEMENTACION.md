# Plan de Implementación - Ecosistema EduGo

**Fecha:** 11 de Noviembre, 2025  
**Objetivo:** Completar funcionalidades diseñadas que faltan en los 5 proyectos  
**Metodología:** Sprints de 2-3 semanas, priorización MoSCoW

---

## 🎯 OVERVIEW DEL PLAN

### Estado Actual vs Objetivo

```
Completitud Global:  45%  █████████░░░░░░░░░░░
Objetivo Q1 2026:    75%  ███████████████░░░░░
Objetivo Q2 2026:   100%  ████████████████████
```

### Proyectos por Prioridad

| Prioridad | Proyecto | Razón |
|-----------|----------|-------|
| 🔴 **P0** | edugo-api-administracion | Sin jerarquía académica el sistema no es usable |
| 🔴 **P0** | edugo-api-mobile | Completar evaluaciones (core del producto) |
| 🟡 **P1** | edugo-worker | Verificar y completar procesamiento IA |
| 🟡 **P1** | edugo-dev-environment | Actualizar infraestructura |
| 🟢 **P2** | edugo-shared | Migrar utilidades de api-mobile |

---

## 📅 PARTE 1: ROADMAP POR PROYECTO

### 🔵 PROYECTO 1: edugo-api-administracion

**Objetivo:** Convertirla en API administrativa funcional con jerarquía académica.

#### Sprint Admin-1: Fundamentos (2 semanas) - CRÍTICO ⚠️

**Objetivo:** Implementar jerarquía académica completa

**Tareas:**

1. **Configuración inicial**
   - [ ] Migrar estructura de api-mobile (arquitectura clean)
   - [ ] Configurar CI/CD similar a api-mobile
   - [ ] Configurar testcontainers
   - [ ] Dockerfile y Docker Compose

2. **Schema de Base de Datos**
   - [ ] Crear `scripts/postgresql/01_academic_hierarchy.sql`
     - Tabla `school`
     - Tabla `academic_unit`
     - Tabla `unit_membership`
     - Índices y constraints
   - [ ] Crear seeds de datos de prueba

3. **Dominio y Aplicación**
   - [ ] Entities: `School`, `AcademicUnit`, `UnitMembership`
   - [ ] Value Objects: `SchoolID`, `UnitID`, `UnitType`
   - [ ] Repositories interfaces
   - [ ] Services de aplicación

4. **Infraestructura**
   - [ ] Implementar repositorios PostgreSQL
   - [ ] Middleware de autenticación (reutilizar de shared)
   - [ ] Middleware de autorización (solo admins)

5. **Endpoints REST**
   ```
   POST   /v1/schools
   GET    /v1/schools
   GET    /v1/schools/:id
   PUT    /v1/schools/:id
   DELETE /v1/schools/:id
   
   POST   /v1/schools/:schoolId/units
   GET    /v1/schools/:schoolId/units
   GET    /v1/units/:id
   GET    /v1/units/:id/tree         (árbol jerárquico)
   PUT    /v1/units/:id
   DELETE /v1/units/:id
   
   POST   /v1/units/:id/members
   GET    /v1/units/:id/members
   DELETE /v1/units/:id/members/:userId
   ```

6. **Tests**
   - [ ] Tests unitarios de dominio
   - [ ] Tests de integración con PostgreSQL
   - [ ] Tests end-to-end de endpoints

**Entregables:**
- ✅ Jerarquía académica funcional
- ✅ Endpoints CRUD completos
- ✅ Tests con >80% coverage
- ✅ Documentación Swagger

**Esfuerzo:** 🔴 XL (2-3 semanas)

---

#### Sprint Admin-2: Gestión de Usuarios (2 semanas)

**Objetivo:** Perfiles especializados y gestión de tutores

**Tareas:**

1. **Schema de Perfiles**
   - [ ] `scripts/postgresql/02_user_profiles.sql`
     - Tabla `teacher_profile`
     - Tabla `student_profile`
     - Tabla `guardian_profile`
     - Tabla `guardian_student_relation`

2. **Dominio**
   - [ ] Entities: `TeacherProfile`, `StudentProfile`, `GuardianProfile`
   - [ ] Value Objects: `StudentCode`, `Specialization`
   - [ ] Services: `UserProfileService`, `GuardianRelationService`

3. **Endpoints REST**
   ```
   POST   /v1/users                    (crear con perfil)
   GET    /v1/users
   GET    /v1/users/:id
   PUT    /v1/users/:id
   DELETE /v1/users/:id
   
   GET    /v1/teachers/:id/profile
   PUT    /v1/teachers/:id/profile
   
   GET    /v1/students/:id/profile
   PUT    /v1/students/:id/profile
   
   GET    /v1/guardians/:id/profile
   PUT    /v1/guardians/:id/profile
   POST   /v1/guardians/:id/students   (vincular estudiante)
   DELETE /v1/guardians/:id/students/:studentId
   ```

4. **Integración con api-mobile**
   - [ ] api-mobile consulta perfiles (read-only)
   - [ ] Documentar contrato de integración

**Entregables:**
- ✅ Perfiles especializados funcionando
- ✅ Sistema de tutores-estudiantes
- ✅ Integración con api-mobile

**Esfuerzo:** 🟡 L (2 semanas)

---

#### Sprint Admin-3: Materias y Asignaciones (1 semana)

**Objetivo:** Catálogo de materias y asignación de materiales a unidades

**Tareas:**

1. **Schema**
   - [ ] `scripts/postgresql/03_subjects_and_assignments.sql`
     - Tabla `subject`
     - Tabla `material_unit_link`

2. **Endpoints REST**
   ```
   POST   /v1/schools/:schoolId/subjects
   GET    /v1/schools/:schoolId/subjects
   PUT    /v1/subjects/:id
   DELETE /v1/subjects/:id
   
   POST   /v1/units/:unitId/materials
   GET    /v1/units/:unitId/materials
   DELETE /v1/units/:unitId/materials/:materialId
   ```

**Entregables:**
- ✅ Gestión de materias
- ✅ Asignación de materiales a unidades

**Esfuerzo:** 🟢 M (1 semana)

---

#### Sprint Admin-4: Reportes (1 semana)

**Objetivo:** Reportes y analytics para administradores

**Tareas:**

1. **Endpoints de Reportes**
   ```
   GET /v1/reports/schools/:id/stats
   GET /v1/reports/units/:id/progress
   GET /v1/reports/materials/:id/analytics
   GET /v1/reports/students/:id/performance
   ```

2. **Queries Complejas**
   - [ ] CTE recursivos para jerarquías
   - [ ] Agregaciones de progreso
   - [ ] Estadísticas de uso

**Entregables:**
- ✅ Reportes administrativos
- ✅ Dashboard de analytics

**Esfuerzo:** 🟢 M (1 semana)

---

### 🟢 PROYECTO 2: edugo-api-mobile

**Objetivo:** Completar sistema de evaluaciones

#### Sprint Mobile-1: Sistema de Evaluaciones (2 semanas)

**Tareas:**

1. **Schema**
   - [ ] `scripts/postgresql/06_assessments.sql`
     - Tabla `assessment`
     - Tabla `assessment_attempt`
     - Tabla `assessment_attempt_answer`
     - Tabla `material_summary_link`

2. **Dominio**
   - [ ] Entities: `Assessment`, `Attempt`, `Answer`
   - [ ] Value Objects: `AssessmentID`, `Score`, `QuestionID`
   - [ ] Services: `AssessmentService`, `AttemptScoringService`

3. **Integración con MongoDB**
   - [ ] Repository para leer `material_assessment` de MongoDB
   - [ ] Adapters para transformar schema de Mongo a dominio

4. **Endpoints REST**
   ```
   GET  /v1/materials/:id/assessment      (obtener quiz de MongoDB)
   POST /v1/assessments/:id/attempts       (iniciar intento)
   POST /v1/attempts/:id/answers           (enviar respuestas)
   GET  /v1/attempts/:id/results           (obtener resultados)
   GET  /v1/users/me/attempts              (historial de intentos)
   ```

5. **Lógica de Calificación**
   - [ ] Validar respuestas contra MongoDB
   - [ ] Calcular score
   - [ ] Guardar en PostgreSQL
   - [ ] Feedback personalizado

**Entregables:**
- ✅ Sistema de evaluaciones completo
- ✅ Integración PostgreSQL + MongoDB
- ✅ Calificación automática

**Esfuerzo:** 🟡 L (2 semanas)

---

#### Sprint Mobile-2: Resúmenes IA (1 semana)

**Tareas:**

1. **Endpoints de Resúmenes**
   ```
   GET /v1/materials/:id/summary
   ```

2. **Integración con MongoDB**
   - [ ] Repository para `material_summary`
   - [ ] Manejo de estados (pending, processing, completed, failed)

**Entregables:**
- ✅ Resúmenes consultables
- ✅ Manejo de estados

**Esfuerzo:** 🟢 S (1 semana)

---

#### Sprint Mobile-3: Integración con Jerarquía (1 semana)

**Objetivo:** Consumir jerarquía académica de api-admin

**Tareas:**

1. **Endpoints de Consulta**
   ```
   GET /v1/users/me/units          (mis unidades académicas)
   GET /v1/units/:id/materials     (materiales de mi unidad)
   ```

2. **Cliente HTTP**
   - [ ] Cliente para llamar a api-administracion
   - [ ] Caché de datos de jerarquía
   - [ ] Manejo de errores

**Entregables:**
- ✅ Integración cross-API
- ✅ Materiales filtrados por unidad

**Esfuerzo:** 🟢 S (1 semana)

---

### 🟠 PROYECTO 3: edugo-worker

**Objetivo:** Verificar y completar procesamiento IA

#### Sprint Worker-1: Auditoría y Verificación (1 semana)

**Tareas:**

1. **Inspección de Código**
   - [ ] Revisar conexión a RabbitMQ
   - [ ] Revisar procesamiento de PDFs
   - [ ] Revisar integración OpenAI
   - [ ] Revisar guardado en MongoDB

2. **Crear Documento de Estado**
   - [ ] `/docs/analisis/VERIFICACION_WORKER.md`
   - [ ] Documentar qué funciona y qué falta

3. **Tests**
   - [ ] Agregar tests unitarios
   - [ ] Agregar tests de integración con RabbitMQ
   - [ ] Agregar tests de integración con MongoDB

**Entregables:**
- ✅ Documento de verificación
- ✅ Identificar gaps

**Esfuerzo:** 🟢 S (1 semana)

---

#### Sprint Worker-2: Completar Funcionalidades (1-2 semanas)

**Tareas (depende de resultado de Sprint Worker-1):**

1. **Procesamiento de PDFs**
   - [ ] Extracción de texto
   - [ ] Limpieza y normalización
   - [ ] Manejo de errores

2. **Integración OpenAI**
   - [ ] Generación de resúmenes
   - [ ] Generación de quizzes
   - [ ] Retry logic y rate limiting

3. **Guardado en MongoDB**
   - [ ] Colección `material_summary`
   - [ ] Colección `material_assessment`
   - [ ] Colección `material_event`

**Entregables:**
- ✅ Worker completamente funcional
- ✅ Flujo end-to-end probado

**Esfuerzo:** 🟡 M-L (1-2 semanas, según gaps)

---

### 🟣 PROYECTO 4: edugo-shared

**Objetivo:** Consolidar utilidades comunes

#### Sprint Shared-1: Migración de Utilidades (1 semana)

**Tareas:**

1. **Migrar de api-mobile a shared**
   - [ ] Testcontainers setup helpers
   - [ ] Repository base interfaces
   - [ ] Validators comunes
   - [ ] Error handling patterns
   - [ ] HTTP client helpers

2. **Actualizar api-mobile**
   - [ ] Reemplazar código local con shared
   - [ ] Verificar que tests siguen pasando

3. **Actualizar api-administracion**
   - [ ] Usar nuevos módulos de shared
   - [ ] Beneficiarse de helpers

**Entregables:**
- ✅ Shared con más utilidades
- ✅ DRY entre proyectos

**Esfuerzo:** 🟢 M (1 semana)

---

### 🐳 PROYECTO 5: edugo-dev-environment

**Objetivo:** Actualizar infraestructura de desarrollo

#### Sprint DevEnv-1: Actualización Completa (1 semana)

**Tareas:**

1. **Actualizar Versiones**
   - [ ] Go 1.21+ (verificar versión actual de apis)
   - [ ] PostgreSQL 15+
   - [ ] MongoDB 7.0+
   - [ ] RabbitMQ 3.12+

2. **Consolidar Schemas SQL**
   - [ ] Agregar schemas de api-mobile
   - [ ] Agregar schemas de api-administracion
   - [ ] Script maestro de inicialización

3. **Configurar RabbitMQ**
   - [ ] Exchanges pre-configurados
   - [ ] Queues pre-configuradas
   - [ ] Bindings

4. **Seeds de Datos**
   - [ ] Datos de prueba de todas las tablas
   - [ ] Script automatizado de seed

5. **Documentación**
   - [ ] README actualizado
   - [ ] Guía de troubleshooting
   - [ ] Variables de entorno consolidadas

**Entregables:**
- ✅ Entorno completo y actualizado
- ✅ One-command setup

**Esfuerzo:** 🟢 M (1 semana)

---

## 📊 PARTE 2: CRONOGRAMA GENERAL

### Fase 1: Fundamentos (Q1 2026 - 8 semanas)

| Semana | Sprint | Proyecto | Entregable |
|--------|--------|----------|------------|
| 1-2 | Admin-1 | api-administracion | Jerarquía académica |
| 3-4 | Mobile-1 | api-mobile | Sistema de evaluaciones |
| 5 | Worker-1 | worker | Verificación y auditoría |
| 6-7 | Admin-2 | api-administracion | Perfiles especializados |
| 8 | DevEnv-1 | dev-environment | Actualización completa |

**Objetivo:** Completar funcionalidades críticas bloqueantes.

---

### Fase 2: Integración (Q2 2026 - 6 semanas)

| Semana | Sprint | Proyecto | Entregable |
|--------|--------|----------|------------|
| 9 | Mobile-2 | api-mobile | Resúmenes IA |
| 10 | Mobile-3 | api-mobile | Integración con jerarquía |
| 11 | Admin-3 | api-administracion | Materias y asignaciones |
| 12-13 | Worker-2 | worker | Completar funcionalidades |
| 14 | Shared-1 | shared | Consolidar utilidades |

**Objetivo:** Integrar todos los sistemas.

---

### Fase 3: Pulido (Q2 2026 - 2 semanas)

| Semana | Sprint | Proyecto | Entregable |
|--------|--------|----------|------------|
| 15 | Admin-4 | api-administracion | Reportes y analytics |
| 16 | Testing | Todos | Tests end-to-end del ecosistema |

**Objetivo:** Completar funcionalidades secundarias y testing completo.

---

## 🎯 PARTE 3: PRIORIZACIÓN MoSCoW

### Must Have (Bloqueantes)
- ✅ Jerarquía académica (api-admin)
- ✅ Sistema de evaluaciones (api-mobile)
- ✅ Verificar worker funcional

### Should Have (Alta prioridad)
- ✅ Perfiles especializados (api-admin)
- ✅ Resúmenes IA (api-mobile)
- ✅ Actualizar dev-environment

### Could Have (Deseable)
- ✅ Reportes avanzados (api-admin)
- ✅ Consolidar shared

### Won't Have (Fuera de scope)
- Versionado de materiales (postponer a Q3)
- Red social educativa (colecciones post-MVP de MongoDB)
- Grafos de relaciones

---

## 📈 PARTE 4: MÉTRICAS DE ÉXITO

### Por Fase

| Fase | Completitud Objetivo | Funcionalidades |
|------|----------------------|-----------------|
| **Actual** | 45% | MVP básico funcionando |
| **Fin Q1 2026** | 75% | Funcionalidades críticas completas |
| **Fin Q2 2026** | 100% | Diseño completo implementado |

### Por Proyecto

| Proyecto | Actual | Fin Q1 | Fin Q2 |
|----------|--------|--------|--------|
| api-mobile | 60% | 85% | 100% |
| api-administracion | 10% | 70% | 100% |
| worker | 30%? | 80% | 100% |
| shared | 80% | 90% | 100% |
| dev-environment | 40% | 100% | 100% |

---

## 🚀 PARTE 5: RECOMENDACIONES DE EJECUCIÓN

### Orden Sugerido

1. **Empezar con Admin-1 (Jerarquía)** ⚠️
   - Es bloqueante para el resto
   - Sin esto, el sistema no es usable

2. **Paralelo: Mobile-1 (Evaluaciones)**
   - Core del producto educativo
   - Puede desarrollarse en paralelo a Admin-1

3. **Worker-1 (Verificación)**
   - Entender estado actual antes de invertir tiempo

4. **Resto según cronograma**

### Recursos Sugeridos

- **1 desarrollador senior Go:** Admin-1 + Admin-2 (4 semanas)
- **1 desarrollador mid-level Go:** Mobile-1 + Mobile-2 (3 semanas)
- **1 desarrollador junior:** DevEnv-1, Shared-1, documentación (2 semanas)

---

## 📝 PARTE 6: PRÓXIMOS PASOS INMEDIATOS

### Esta Semana
1. ✅ Aprobar este roadmap
2. ✅ Asignar recursos/desarrolladores
3. ✅ Crear issues/tickets en GitHub para Sprint Admin-1

### Próxima Semana
1. Iniciar Sprint Admin-1 (jerarquía académica)
2. Iniciar Sprint Mobile-1 (evaluaciones) en paralelo
3. Daily standups para tracking

---

**Última actualización:** 11 de Noviembre, 2025  
**Próxima revisión:** Fin de Sprint Admin-1

---

**Generado con** 🤖 Claude Code
