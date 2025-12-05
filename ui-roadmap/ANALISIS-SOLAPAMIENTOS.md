# Análisis de Solapamientos y Duplicaciones - UI Roadmap

> **INFORME DE AUDITORÍA**: Comparación entre spec ui-roadmap vs implementación existente

**Fecha**: 1 de Diciembre, 2025  
**Generado por**: Claude Code (UltraThink Analysis)  
**Solicitado por**: Usuario para validar spec antes de implementación

---

## Resumen Ejecutivo

| Categoría | Estado | Acción Requerida |
|-----------|--------|------------------|
| **PR FASE 1 (5 tablas)** | ✅ Válido | Aprobar y merge |
| **15 Tablas Admin (MIGRACIONES-ADMIN.md)** | 🚫 YAGNI | NO implementar ahora |
| **Duplicación pre-existente (`units`)** | 🔴 Problema en main | Crear issue separado |
| **Problema `subjects` sin school_id** | 🟡 Deuda técnica | Crear issue separado |

---

## 📋 DECISIONES CLARAS

### ✅ PR `feature/fase1-ui-database-infrastructure` - APROBAR

Las **5 tablas** en este PR son **válidas y necesarias** para FASE 1-4:

| Tabla | Necesaria para | Veredicto |
|-------|----------------|-----------|
| `user_active_context` | Selector de escuela en UI | ✅ Correcta |
| `user_favorites` | Funcionalidad favoritos | ✅ Correcta |
| `user_activity_log` | Actividad reciente en Home | ✅ Correcta |
| `feature_flags` | Feature toggles | ✅ Correcta |
| `feature_flag_overrides` | Override por usuario/escuela | ✅ Correcta |

**ACCIÓN**: Aprobar y merge del PR.

---

### 🚫 15 Tablas de MIGRACIONES-ADMIN.md - NO IMPLEMENTAR AHORA

**Razón**: Principio YAGNI (You Aren't Gonna Need It)

| Tabla Propuesta | Fase Requerida | Estado Actual |
|-----------------|----------------|---------------|
| `academic_cycles` | FASE 5 (Admin) | 🚫 No implementar |
| `academic_periods` | FASE 5 (Admin) | 🚫 No implementar |
| `classrooms` | FASE 5 (Admin) | 🚫 No implementar |
| `schedules` | FASE 5 (Admin) | 🚫 No implementar |
| `schedule_blocks` | FASE 5 (Admin) | 🚫 No implementar |
| `import_jobs` | FASE 5 (Admin) | 🚫 No implementar |
| `school_events` | FASE 5 (Admin) | 🚫 No implementar |
| `event_participants` | FASE 5 (Admin) | 🚫 No implementar |
| `grading_scales` | FASE 5 (Admin) | 🚫 No implementar |
| `grading_scale_ranges` | FASE 5 (Admin) | 🚫 No implementar |
| `custom_roles` | FASE 5 (Admin) | 🚫 No implementar |
| `role_permissions` | FASE 5 (Admin) | 🚫 No implementar |
| `certificates` | FASE 5 (Admin) | 🚫 No implementar |
| `generated_certificates` | FASE 5 (Admin) | 🚫 No implementar |
| `fee_concepts` | FASE 5 (Admin) | 🚫 No implementar |
| `payments` | FASE 5 (Admin) | 🚫 No implementar |

**Razones detalladas** (del análisis de Claude en edugo-infrastructure):

1. **Violación YAGNI**: Son para FASE 5, estamos en FASE 1
2. **Complejidad prematura**: Triggers con lógica de negocio que debería estar en API
3. **Riesgo de cambio**: El diseño puede evolucionar basado en feedback de FASE 2-4
4. **Algunos requieren microservicios**: `payments` debería ser servicio separado

**ACCIÓN**: Mantener `MIGRACIONES-ADMIN.md` como **referencia futura**, NO ejecutar.

---

## 🔴 PROBLEMA PRE-EXISTENTE: Duplicación `units` vs `academic_units`

**IMPORTANTE**: Este problema **NO es parte del PR de FASE 1**. Ya existe en `main`.

### Origen del Problema

```
Commit: 7ed8fe2 "feat: Sprint Entities - Centralizar entities PostgreSQL y MongoDB (#30)"
Archivo: postgres/migrations/014_create_units.up.sql
Estado: Ya mergeado a main
```

### Comparación

| Aspecto | `academic_units` (003) | `units` (014) |
|---------|------------------------|---------------|
| Propósito | "Unidades académicas con jerarquía" | "Unidades organizacionales jerárquicas" |
| school_id | ✅ | ✅ |
| parent_unit_id | ✅ | ✅ |
| type | ✅ (6 tipos) | ❌ |
| level | ✅ | ❌ |
| academic_year | ✅ | ❌ |
| metadata | ✅ JSONB | ❌ |
| Vista recursiva | ✅ v_academic_unit_tree | ❌ |
| Usado por API | ✅ academic_unit_handler.go | ❌ Sin handler |

### Diagnóstico

- `academic_units` es la tabla **canónica** usada por api-admin
- `units` parece ser una versión simplificada creada sin considerar la existente
- **Duplicación clara** que genera confusión

### ACCIÓN REQUERIDA

```
📝 Crear ISSUE en edugo-infrastructure:
   Título: "Resolver duplicación: tabla units vs academic_units"
   Prioridad: Media (no bloquea FASE 1-4)
   Tareas:
   1. Verificar si units tiene datos en algún ambiente
   2. Si no tiene datos: eliminar migración 014
   3. Si tiene datos: migrar a academic_units y luego eliminar
```

---

## 🟡 DEUDA TÉCNICA: `subjects` sin `school_id`

### Problema

```sql
-- Esquema actual (migración 013)
CREATE TABLE subjects (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    metadata JSONB,
    is_active BOOLEAN DEFAULT true
    -- ❌ NO TIENE: school_id
);
```

### Impacto

- Todas las escuelas comparten las mismas materias
- No se puede tener "Álgebra" en una escuela y "Álgebra Avanzada" en otra
- Conflictos de nombres entre escuelas

### ACCIÓN REQUERIDA

```
📝 Crear ISSUE en edugo-infrastructure:
   Título: "Agregar school_id a tabla subjects"
   Prioridad: Media (antes de FASE 5)
   Tareas:
   1. Crear migración para agregar school_id (nullable inicialmente)
   2. Decidir política: ¿materias globales + por escuela?
   3. Actualizar subject_handler.go para filtrar por escuela
```

---

## 🟢 FUNCIONALIDADES YA EXISTENTES (Spec no las consideró)

La spec propone crear algunas funcionalidades que **YA EXISTEN**:

| Funcionalidad | Ya Existe | Dónde |
|---------------|-----------|-------|
| Jerarquía unidades | ✅ | `academic_units.parent_unit_id` + vista + endpoints `/tree` |
| Guardian relations | ✅ | Tabla `guardian_relations` + `guardian_handler.go` |
| Progress tracking | ✅ | Tabla `progress` + endpoints `/progress` |
| Material versions | ✅ | Tabla `material_versions` + endpoint `/versions` |
| Materias | ✅ Parcial | Tabla `subjects` + handler (falta school_id) |

**ACCIÓN**: Actualizar spec para referenciar estas funcionalidades existentes.

---

## Resumen de Acciones

### Inmediatas (Esta semana)

| # | Acción | Responsable | Bloqueante |
|---|--------|-------------|------------|
| 1 | ✅ Aprobar PR `feature/fase1-ui-database-infrastructure` | Reviewer | Sí |
| 2 | ✅ Merge a dev | DevOps | Sí |

### Corto Plazo (Crear Issues)

| # | Issue | Repo | Prioridad |
|---|-------|------|-----------|
| 3 | Resolver duplicación `units` vs `academic_units` | edugo-infrastructure | Media |
| 4 | Agregar `school_id` a `subjects` | edugo-infrastructure | Media |

### NO Hacer Ahora

| # | Qué NO hacer | Razón |
|---|--------------|-------|
| 5 | Implementar 15 tablas de MIGRACIONES-ADMIN.md | YAGNI - son para FASE 5 |
| 6 | Crear nueva jerarquía de unidades | Ya existe |
| 7 | Crear nuevo sistema de progreso | Ya existe |

---

## Apéndice: Endpoints de API

### API-Mobile: Nuevos Endpoints Válidos para FASE 2

| Endpoint | Depende de | Estado |
|----------|------------|--------|
| `GET /v1/users/me` | - | Implementar |
| `GET /v1/users/me/schools` | memberships | Implementar |
| `GET /v1/users/me/active-school` | user_active_context | Implementar |
| `POST /v1/users/me/active-school` | user_active_context | Implementar |
| `GET /v1/users/me/stats` | progress, assessment_attempt | Implementar |
| `GET /v1/users/me/activity` | user_activity_log | Implementar |
| `POST /v1/materials/:id/favorite` | user_favorites | Implementar |
| `DELETE /v1/materials/:id/favorite` | user_favorites | Implementar |
| `GET /v1/users/me/favorites` | user_favorites | Implementar |

**NOTA**: Estos endpoints dependen de las tablas del PR de FASE 1.

### API-Admin: Endpoints Existentes (NO duplicar)

| Endpoint | Estado |
|----------|--------|
| `GET /api/v1/schools` | ✅ Existe |
| `GET /api/v1/schools/:id/units/tree` | ✅ Existe |
| `GET /api/v1/units/:id/hierarchy-path` | ✅ Existe |

---

## Conclusión

El PR de FASE 1 está **bien diseñado** y debe aprobarse. Los problemas encontrados (`units` duplicada, `subjects` sin school_id) son **deuda técnica pre-existente** que debe resolverse en issues separados, sin bloquear el avance de FASE 1.

Las 15 tablas de administración propuestas en la spec son válidas conceptualmente pero deben implementarse **cuando se llegue a FASE 5**, no ahora.

---

**Fin del Informe**

---

*Generado automáticamente por Claude Code*  
*Última actualización: 1 de Diciembre, 2025*
