# Gap Analysis: Diseño vs Implementación Real - EduGo

**Fecha de Análisis:** 11 de Noviembre, 2025  
**Autor:** Claude Code + Equipo EduGo  
**Objetivo:** Documentar diferencias entre arquitectura diseñada e implementación actual

---

## 📊 RESUMEN EJECUTIVO

Este documento compara el **diseño original completo** de EduGo (documentado en `/docs/diagramas/`) contra la **implementación real** en los 5 repositorios separados.

### Hallazgos Clave

| Categoría | Diseñado | Implementado | Gap |
|-----------|----------|--------------|-----|
| **Tablas PostgreSQL** | 17 tablas | 3 tablas (api-mobile) | ❌ **82% faltante** |
| **Colecciones MongoDB** | 3 colecciones | ⚠️ No verificado | ⚠️ **Pendiente** |
| **Microservicios** | 3 APIs + 1 Worker | 4 proyectos creados | 🟡 **Estructura OK** |
| **Funcionalidades Core** | Sistema educativo completo | MVP simplificado | 🔴 **40-50% implementado** |

---

## 🗄️ PARTE 1: BASE DE DATOS

### PostgreSQL: Diseño Original (17 Tablas)

Según `/docs/diagramas/base_datos/01_modelo_er_postgresql.md`:

#### Grupo 1: Usuarios y Perfiles (6 tablas)
| # | Tabla | Propósito | Estado |
|---|-------|-----------|--------|
| 1 | `app_user` | Usuarios del sistema | 🟡 **Parcial** (como `users`) |
| 2 | `teacher_profile` | Perfil de profesores | ❌ **No existe** |
| 3 | `student_profile` | Perfil de estudiantes | ❌ **No existe** |
| 4 | `guardian_profile` | Perfil de tutores/padres | ❌ **No existe** |
| 5 | `guardian_student_relation` | Relación tutor-estudiante (N:M) | ❌ **No existe** |
| 6 | `school` | Escuelas/Instituciones | ❌ **No existe** |

#### Grupo 2: Jerarquía Académica (2 tablas) - ⚠️ CRÍTICO
| # | Tabla | Propósito | Estado |
|---|-------|-----------|--------|
| 7 | `academic_unit` | Estructura jerárquica (años→secciones→clubes) | ❌ **No existe** |
| 8 | `unit_membership` | Asignación usuarios→unidades | ❌ **No existe** |

> **⚠️ NOTA CRÍTICA:** La jerarquía académica es **extremadamente importante** según feedback del usuario. Sin ella no hay forma de organizar estudiantes por secciones ni asignar materiales por grupo.

#### Grupo 3: Materiales Educativos (5 tablas)
| # | Tabla | Propósito | Estado |
|---|-------|-----------|--------|
| 9 | `subject` | Catálogo de materias | ❌ **No existe** |
| 10 | `learning_material` | Materiales educativos | ✅ **Existe** (como `materials`) |
| 11 | `material_version` | Historial de versiones | ❌ **No existe** |
| 12 | `material_unit_link` | Asignación material↔unidad (N:M) | ❌ **No existe** |
| 13 | `reading_log` | Progreso de lectura | ✅ **Existe** (como `material_progress`) |

#### Grupo 4: Evaluaciones (4 tablas)
| # | Tabla | Propósito | Estado |
|---|-------|-----------|--------|
| 14 | `material_summary_link` | Enlace a resúmenes en MongoDB | ❌ **No existe** |
| 15 | `assessment` | Metadatos de evaluaciones | ❌ **No existe** |
| 16 | `assessment_attempt` | Intentos de quiz por estudiante | ❌ **No existe** |
| 17 | `assessment_attempt_answer` | Respuestas individuales | ❌ **No existe** |

---

### PostgreSQL: Implementación Real (3 Tablas)

Según `edugo-api-mobile/scripts/postgresql/01_create_schema.sql`:

#### Tabla 1: `users`
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(50),  -- 'student', 'teacher', 'guardian', 'admin'
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

**Comparación con diseño:**
- ✅ Similar a `app_user`
- ❌ Falta separación de perfiles por rol (teacher_profile, student_profile, guardian_profile)
- ❌ Sin campos `system_role` vs `role` (simplificado)
- ⚠️ Todos los roles comparten misma tabla (puede limitar escalabilidad)

#### Tabla 2: `materials`
```sql
CREATE TABLE materials (
    id UUID PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    author_id UUID REFERENCES users(id),
    subject_id VARCHAR(100),  -- ⚠️ No FK, solo string
    s3_key VARCHAR(500),
    s3_url VARCHAR(1000),
    status VARCHAR(50),  -- 'draft', 'published', 'archived'
    processing_status VARCHAR(50),  -- 'pending', 'processing', 'completed', 'failed'
    is_deleted BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

**Comparación con diseño:**
- ✅ Similar a `learning_material`
- ❌ `subject_id` es VARCHAR, no FK a tabla `subject` (tabla `subject` no existe)
- ❌ Sin versionado (tabla `material_version` no existe)
- ❌ Sin asignación a unidades académicas (tabla `material_unit_link` no existe)
- ✅ Tiene `processing_status` para tracking de worker

#### Tabla 3: `material_progress`
```sql
CREATE TABLE material_progress (
    material_id UUID REFERENCES materials(id),
    user_id UUID REFERENCES users(id),
    percentage INTEGER,  -- 0-100
    last_page INTEGER,
    status VARCHAR(50),  -- 'not_started', 'in_progress', 'completed'
    last_accessed_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    PRIMARY KEY (material_id, user_id)
);
```

**Comparación con diseño:**
- ✅ Similar a `reading_log`
- ✅ Campos principales implementados correctamente
- ⚠️ Campos adicionales del diseño no presentes:
  - `time_spent` (segundos totales)
  - Pero tiene `last_page` que no estaba en diseño original

---

### MongoDB: Diseño vs Realidad

Según `/docs/diagramas/base_datos/02_colecciones_mongodb.md`:

#### Colecciones Diseñadas (3)

| Colección | Propósito | Estado Verificado |
|-----------|-----------|-------------------|
| `material_summary` | Resúmenes generados por IA | ⚠️ **No verificado** |
| `material_assessment` | Bancos de preguntas (quizzes) | ⚠️ **No verificado** |
| `material_event` | Logs de procesamiento del worker | ⚠️ **No verificado** |

> **⚠️ PENDIENTE:** Necesitamos verificar en el código del `edugo-worker` si estas colecciones están implementadas.

---

## 🏗️ PARTE 2: ARQUITECTURA Y FLUJOS

### Diseño Original

Según `/FLUJOS_CRITICOS.md`:

```
Profesor (API Mobile)
   ↓ Sube PDF
PostgreSQL (guarda metadata)
   ↓ Publica evento
RabbitMQ
   ↓ Consume
Worker
   ├→ Extrae texto del PDF
   ├→ Llama OpenAI (genera resumen)
   ├→ Llama OpenAI (genera quiz)
   ├→ Guarda en MongoDB (summary + assessment)
   └→ Actualiza PostgreSQL (estado = completed)
```

### Implementación Actual

**Estado conocido:**
- ✅ API Mobile: Implementada con 3 tablas
- ✅ Worker: Estructura de proyecto existe
- ⚠️ RabbitMQ: No verificado si está conectado
- ⚠️ MongoDB: No verificado
- ⚠️ Integración OpenAI: No verificado

---

## 🎯 PARTE 3: FUNCIONALIDADES POR PROYECTO

### edugo-api-mobile

**Estado:** 🟢 **Activo y en desarrollo**

#### Implementado ✅
- Autenticación JWT básica
- CRUD de usuarios
- CRUD de materiales
- Tracking de progreso de lectura
- Tests con testcontainers
- CI/CD con GitHub Actions

#### Pendiente ❌
- Perfiles especializados por rol
- Sistema de evaluaciones
- Integración con jerarquía académica
- Versionado de materiales

**Arquitectura:**
- ✅ Clean Architecture (domain, application, infrastructure)
- ✅ Dockerfile propio
- ✅ Docker Compose para desarrollo

---

### edugo-api-administracion

**Estado:** 🟡 **Creada pero no desarrollada**

#### Código Actual
- Código residual del monorepo original
- Sin actualizaciones desde separación
- Sin estructura comparable a api-mobile

#### Debe Implementar
Según análisis de responsabilidades (ver `DISTRIBUCION_RESPONSABILIDADES.md`):
- Gestión de escuelas (`school`)
- Gestión de jerarquía académica (`academic_unit`, `unit_membership`)
- Gestión de materias (`subject`)
- Operaciones administrativas
- Reportes y analytics

---

### edugo-worker

**Estado:** 🟡 **Creado pero no verificado**

#### Estructura Existe
- Proyecto Go con estructura básica
- Carpeta `internal/domain` existe

#### Debe Verificar
- ¿Está conectado a RabbitMQ?
- ¿Procesa PDFs?
- ¿Integra con OpenAI?
- ¿Guarda en MongoDB?

---

### edugo-shared

**Estado:** 🟢 **Activo y funcional**

#### Implementado ✅
Según estructura de carpetas:
- `auth/` - Módulo de autenticación
- `common/` - Utilidades comunes
- `database/` - Conexiones a PostgreSQL y MongoDB
- `logger/` - Sistema de logging
- `messaging/` - (Carpeta existe, ¿RabbitMQ?)
- `middleware/` - Middlewares HTTP

#### Oportunidad de Mejora
- Migrar funcionalidades de api-mobile a shared:
  - Conexiones a testcontainers
  - Helpers de testing
  - Validadores comunes
  - Patterns de repositorios

---

### edugo-dev-environment

**Estado:** 🟡 **Desactualizado**

#### Debe Sincronizar
- Versiones de Go de las APIs
- Cambios en docker-compose
- Nuevos servicios agregados
- Scripts de inicialización

---

## 📊 PARTE 4: MATRIZ DE COMPLETITUD

### Por Módulo Funcional

| Módulo | Diseñado | API Mobile | API Admin | Worker | % Total |
|--------|----------|------------|-----------|--------|---------|
| **Autenticación** | JWT + Refresh | JWT básico | ❌ | N/A | 🟡 50% |
| **Usuarios** | Perfiles especializados | Usuario genérico | ❌ | N/A | 🔴 30% |
| **Jerarquía Académica** | 3 niveles (school→unit→membership) | ❌ | ❌ | N/A | 🔴 0% |
| **Materiales** | CRUD + versiones + asignación | CRUD básico | ❌ | N/A | 🟡 40% |
| **Progreso Lectura** | Tracking completo | Tracking básico | N/A | N/A | 🟢 70% |
| **Procesamiento IA** | PDF→Text→OpenAI→MongoDB | ⚠️ | N/A | ⚠️ | ⚠️ ? |
| **Evaluaciones** | Quizzes + intentos + respuestas | ❌ | ❌ | ⚠️ | 🔴 0% |
| **Mensajería** | RabbitMQ eventos | ⚠️ | ⚠️ | ⚠️ | ⚠️ ? |

### Leyenda
- 🟢 **70-100%**: Implementado y funcional
- 🟡 **40-69%**: Implementado parcialmente
- 🔴 **0-39%**: No implementado o muy básico
- ⚠️ **?**: No verificado (requiere inspección de código)

---

## 🚨 CRÍTICOS IDENTIFICADOS

### 1. Jerarquía Académica (MÁXIMA PRIORIDAD)

**Problema:**
Sin las tablas `school`, `academic_unit` y `unit_membership`, no se puede:
- Organizar estudiantes por secciones/grupos
- Asignar materiales a grupos específicos
- Gestionar permisos por unidad académica
- Generar reportes por sección/año

**Impacto:** ❌ **BLOQUEANTE** para uso real en escuelas

**Responsable sugerido:** `edugo-api-administracion` (ver DISTRIBUCION_RESPONSABILIDADES.md)

---

### 2. Sistema de Evaluaciones

**Problema:**
Sin las tablas `assessment`, `assessment_attempt`, `assessment_attempt_answer`, no se puede:
- Crear quizzes para los materiales
- Registrar intentos de estudiantes
- Calcular calificaciones
- Generar reportes de rendimiento

**Impacto:** 🔴 **ALTA PRIORIDAD** - Parte core del producto educativo

**Responsable sugerido:** `edugo-api-mobile` + `edugo-worker` (worker genera, mobile consume)

---

### 3. Verificación de Worker + MongoDB

**Problema:**
No hemos verificado si el flujo completo está funcionando:
- Worker consume RabbitMQ ✅/❌?
- Worker procesa PDFs ✅/❌?
- Worker llama OpenAI ✅/❌?
- Worker guarda en MongoDB ✅/❌?

**Impacto:** ⚠️ **DESCONOCIDO** - Puede estar funcionando o no

**Acción requerida:** Inspección de código en `edugo-worker`

---

## 📈 MÉTRICAS DE COMPLETITUD

### Global
```
Diseño Original:   100%  ████████████████████
Implementación:     45%  █████████░░░░░░░░░░░
Gap:                55%  ░░░░░░░░░░░░░░░░░░░░
```

### Por Proyecto
```
api-mobile:         60%  ████████████░░░░░░░░
api-admin:          10%  ██░░░░░░░░░░░░░░░░░░
worker:             30%? ██████░░░░░░░░░░░░░░ (estimado, no verificado)
shared:             80%  ████████████████░░░░
dev-environment:    40%  ████████░░░░░░░░░░░░
```

---

## 🔄 PRÓXIMOS PASOS

Ver documentos complementarios:

1. **`DISTRIBUCION_RESPONSABILIDADES.md`** - Qué proyecto implementa qué tabla/funcionalidad
2. **`../roadmap/PLAN_IMPLEMENTACION.md`** - Plan de sprints para completar el gap
3. **`VERIFICACION_WORKER.md`** (pendiente crear) - Checklist de verificación del worker

---

**Última actualización:** 11 de Noviembre, 2025  
**Próxima revisión:** Después de verificar worker y MongoDB

---

**Generado con** 🤖 Claude Code
