# Endpoints Backend Requeridos - Consolidado

> **Documento único** con TODOS los endpoints que el backend debe crear o modificar para soportar las apps de UI.

**Fecha**: 1 de Diciembre, 2025  
**Propósito**: Guía para el equipo de backend sobre qué implementar

---

## Resumen Ejecutivo

| Categoría | API | Endpoints Nuevos | Prioridad |
|-----------|-----|------------------|-----------|
| **Selector de Contexto** | api-mobile | 3 | 🔴 Alta (bloquea UI) |
| **Perfil de Usuario** | api-mobile | 2 | 🔴 Alta (bloquea Home) |
| **Favoritos** | api-mobile | 3 | 🟡 Media |
| **Estadísticas Usuario** | api-mobile | 2 | 🟡 Media |
| **Ciclos Académicos** | api-admin | 6 | 🟡 Media |
| **Horarios** | api-admin | 7 | 🟡 Media |
| **Importación Masiva** | api-admin | 4 | 🟡 Media |
| **Aulas/Recursos** | api-admin | 6 | 🟢 Baja |
| **Eventos** | api-admin | 6 | 🟢 Baja |
| **Reportes** | api-admin | 5 | 🟢 Baja |
| **Auditoría** | api-admin | 3 | 🟢 Baja |
| **Otros Admin** | api-admin | ~20 | 🟢 Baja |

**Total aproximado**: ~67 endpoints nuevos

---

## PARTE 1: API-MOBILE (Puerto 8080)

### 🔴 CRÍTICO: Selector de Contexto/Escuela

La app necesita que el usuario pueda cambiar entre escuelas donde tiene roles. **Sin estos endpoints, el SchoolSelectorView no funciona.**

#### 1. GET /v1/users/me/schools

**Propósito**: Obtener lista de escuelas donde el usuario tiene membresía activa.

**Request**:
```http
GET /v1/users/me/schools
Authorization: Bearer {token}
```

**Response (200)**:
```json
{
  "schools": [
    {
      "school_id": "uuid-1",
      "school_name": "Colegio San José",
      "school_code": "CSJ001",
      "school_logo_url": "https://...",
      "roles": ["student"],
      "units": [
        {
          "unit_id": "uuid",
          "unit_name": "3° Grado - Sección A",
          "unit_type": "section"
        }
      ],
      "is_active": true,
      "joined_at": "2025-01-15T00:00:00Z"
    },
    {
      "school_id": "uuid-2",
      "school_name": "Instituto Técnico",
      "school_code": "IT002",
      "roles": ["teacher", "coordinator"],
      "units": [...],
      "is_active": true,
      "joined_at": "2024-09-01T00:00:00Z"
    }
  ],
  "active_school_id": "uuid-1",
  "total_count": 2
}
```

**Lógica**:
- Filtrar por `memberships` donde `user_id` = usuario actual
- Incluir `is_active = true` de membership
- Agrupar roles por escuela
- Incluir unidades académicas donde tiene membresía

---

#### 2. POST /v1/users/me/active-school

**Propósito**: Cambiar la escuela/contexto activo del usuario.

**Request**:
```http
POST /v1/users/me/active-school
Authorization: Bearer {token}
Content-Type: application/json

{
  "school_id": "uuid-2"
}
```

**Response (200)**:
```json
{
  "success": true,
  "active_school": {
    "school_id": "uuid-2",
    "school_name": "Instituto Técnico",
    "roles": ["teacher", "coordinator"],
    "primary_unit": {
      "unit_id": "uuid",
      "unit_name": "Departamento de Matemáticas"
    }
  },
  "switched_at": "2025-12-01T10:30:00Z"
}
```

**Response (403)** - No tiene membresía:
```json
{
  "error": "forbidden",
  "message": "Usuario no tiene membresía activa en esta escuela"
}
```

**Lógica**:
- Validar que el usuario tiene membership activa en esa escuela
- Guardar en tabla nueva `user_active_context` o en `users.metadata`
- Puede ser usado para filtrar datos en otros endpoints

**Modelo sugerido (PostgreSQL)**:
```sql
CREATE TABLE user_active_context (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    school_id UUID NOT NULL REFERENCES schools(id),
    unit_id UUID REFERENCES academic_units(id),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id)
);
```

---

#### 3. GET /v1/users/me/active-school

**Propósito**: Obtener el contexto activo actual.

**Request**:
```http
GET /v1/users/me/active-school
Authorization: Bearer {token}
```

**Response (200)**:
```json
{
  "school_id": "uuid-2",
  "school_name": "Instituto Técnico",
  "school_code": "IT002",
  "roles": ["teacher", "coordinator"],
  "primary_unit": {
    "unit_id": "uuid",
    "unit_name": "Departamento de Matemáticas",
    "unit_type": "department"
  },
  "set_at": "2025-12-01T10:30:00Z"
}
```

**Response (200)** - Sin contexto definido:
```json
{
  "school_id": null,
  "message": "No hay escuela activa seleccionada"
}
```

**Lógica**:
- Si no hay registro en `user_active_context`, devolver null
- La app mostrará el selector para elegir

---

### 🔴 CRÍTICO: Perfil y Estadísticas de Usuario

Estos endpoints son necesarios para que **HomeView** funcione correctamente. Actualmente Home usa datos mock.

#### 4. GET /v1/users/me

**Propósito**: Obtener perfil completo del usuario autenticado.

**Request**:
```http
GET /v1/users/me
Authorization: Bearer {token}
```

**Response (200)**:
```json
{
  "id": "uuid",
  "email": "student@example.com",
  "first_name": "Juan",
  "last_name": "Pérez",
  "full_name": "Juan Pérez",
  "avatar_url": "https://...",
  "role": "student",
  "is_active": true,
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-12-01T00:00:00Z",
  "metadata": {
    "phone": "+1234567890",
    "birth_date": "2010-05-15"
  }
}
```

**Nota**: Este endpoint probablemente ya existe en api-admin. Verificar si api-mobile lo tiene o debe llamar a api-admin internamente.

---

#### 5. GET /v1/users/me/stats

**Propósito**: Estadísticas del usuario para dashboard.

**Request**:
```http
GET /v1/users/me/stats
Authorization: Bearer {token}
```

**Response (200)**:
```json
{
  "user_id": "uuid",
  "period": "current_month",
  "materials": {
    "total_available": 25,
    "completed": 12,
    "in_progress": 5,
    "not_started": 8
  },
  "quizzes": {
    "total_attempts": 15,
    "passed": 12,
    "failed": 3,
    "average_score": 78.5,
    "best_score": 95.0
  },
  "progress": {
    "overall_percentage": 48.0,
    "hours_studied": 24.5,
    "streak_days": 7
  },
  "last_activity": {
    "material_id": "uuid",
    "material_title": "Cálculo Diferencial",
    "action": "quiz_completed",
    "score": 85.0,
    "timestamp": "2025-12-01T09:30:00Z"
  },
  "generated_at": "2025-12-01T10:00:00Z"
}
```

**Lógica**:
- Calcular desde `progress` table (materiales)
- Calcular desde `assessment_attempt` (quizzes)
- Filtrar por escuela activa si hay contexto
- Cachear resultado por 5 minutos

---

### 🟡 MEDIA: Favoritos

#### 6. POST /v1/materials/:id/favorite

**Propósito**: Marcar material como favorito.

**Request**:
```http
POST /v1/materials/{material_id}/favorite
Authorization: Bearer {token}
```

**Response (201)**:
```json
{
  "success": true,
  "material_id": "uuid",
  "favorited_at": "2025-12-01T10:30:00Z"
}
```

---

#### 7. DELETE /v1/materials/:id/favorite

**Propósito**: Quitar de favoritos.

**Request**:
```http
DELETE /v1/materials/{material_id}/favorite
Authorization: Bearer {token}
```

**Response (204)**: No content

---

#### 8. GET /v1/users/me/favorites

**Propósito**: Listar materiales favoritos.

**Request**:
```http
GET /v1/users/me/favorites?limit=20&offset=0
Authorization: Bearer {token}
```

**Response (200)**:
```json
{
  "favorites": [
    {
      "material_id": "uuid",
      "material_title": "Introducción a Swift",
      "favorited_at": "2025-12-01T10:30:00Z"
    }
  ],
  "total_count": 5,
  "limit": 20,
  "offset": 0
}
```

**Modelo sugerido**:
```sql
CREATE TABLE user_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    material_id UUID NOT NULL REFERENCES materials(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, material_id)
);
```

---

### 🟡 MEDIA: Actividad Reciente

#### 9. GET /v1/users/me/activity

**Propósito**: Historial de actividad reciente para Home.

**Request**:
```http
GET /v1/users/me/activity?limit=10
Authorization: Bearer {token}
```

**Response (200)**:
```json
{
  "activities": [
    {
      "id": "uuid",
      "type": "quiz_completed",
      "material_id": "uuid",
      "material_title": "Cálculo Diferencial",
      "details": {
        "score": 85.0,
        "passed": true
      },
      "timestamp": "2025-12-01T09:30:00Z"
    },
    {
      "id": "uuid",
      "type": "material_progress",
      "material_id": "uuid",
      "material_title": "Álgebra Lineal",
      "details": {
        "progress_percentage": 75,
        "pages_read": 45
      },
      "timestamp": "2025-12-01T08:15:00Z"
    },
    {
      "id": "uuid",
      "type": "summary_viewed",
      "material_id": "uuid",
      "material_title": "Historia Universal",
      "timestamp": "2025-11-30T14:00:00Z"
    }
  ],
  "total_count": 50
}
```

**Tipos de actividad**:
- `material_started` - Comenzó a leer material
- `material_progress` - Actualizó progreso
- `material_completed` - Completó lectura (100%)
- `summary_viewed` - Vio resumen IA
- `quiz_started` - Inició quiz
- `quiz_completed` - Completó quiz
- `quiz_passed` - Aprobó quiz
- `quiz_failed` - Reprobó quiz

---

## PARTE 2: API-ADMIN (Puerto 8081)

> Los detalles completos de estos endpoints están en [ENDPOINTS-FALTANTES.md](./administracion/ENDPOINTS-FALTANTES.md)

### 🟡 MEDIA PRIORIDAD

#### Ciclos Académicos (6 endpoints)
```
GET    /v1/schools/:id/cycles          # Listar ciclos de una escuela
POST   /v1/schools/:id/cycles          # Crear ciclo (ej: 2025-2026)
GET    /v1/cycles/:id                  # Detalle de ciclo
PATCH  /v1/cycles/:id                  # Actualizar ciclo
DELETE /v1/cycles/:id                  # Eliminar ciclo
POST   /v1/cycles/:id/periods          # Generar períodos automáticamente
```

#### Horarios (7 endpoints)
```
GET    /v1/units/:id/schedules         # Horario de una unidad
POST   /v1/units/:id/schedules         # Crear bloque horario
GET    /v1/schedules/:id               # Detalle de bloque
PUT    /v1/schedules/:id               # Actualizar bloque
DELETE /v1/schedules/:id               # Eliminar bloque
GET    /v1/teachers/:id/schedules      # Horario de un docente
POST   /v1/schedules/validate          # Validar conflictos antes de guardar
```

#### Importación Masiva (4 endpoints)
```
GET    /v1/import/templates/:entity    # Descargar template CSV/Excel
POST   /v1/import/validate             # Validar archivo sin ejecutar
POST   /v1/import/execute              # Ejecutar importación
GET    /v1/import/:id/status           # Estado de importación (async)
```

### 🟢 BAJA PRIORIDAD

#### Aulas/Recursos (6 endpoints)
```
GET    /v1/schools/:id/classrooms
POST   /v1/schools/:id/classrooms
GET    /v1/classrooms/:id
PUT    /v1/classrooms/:id
DELETE /v1/classrooms/:id
GET    /v1/classrooms/:id/availability
```

#### Eventos Escolares (6 endpoints)
```
GET    /v1/schools/:id/events
POST   /v1/schools/:id/events
GET    /v1/events/:id
PUT    /v1/events/:id
DELETE /v1/events/:id
PATCH  /v1/events/:id/cancel
```

#### Reportes (5 endpoints)
```
GET    /v1/reports/types
POST   /v1/reports/generate            # Async
GET    /v1/reports/:id/status
GET    /v1/reports/:id/download
GET    /v1/reports/history
```

#### Auditoría (3 endpoints)
```
GET    /v1/audit-logs
GET    /v1/audit-logs/:id
GET    /v1/users/:id/audit-logs
```

#### Escalas de Calificación (2 endpoints)
```
GET    /v1/schools/:id/grading-scales
POST   /v1/schools/:id/grading-scales
```

#### Roles y Permisos (4 endpoints)
```
GET    /v1/roles
POST   /v1/roles
GET    /v1/roles/:id/permissions
PUT    /v1/roles/:id/permissions
```

#### Certificados (4 endpoints)
```
GET    /v1/certificate-templates
POST   /v1/students/:id/certificates
GET    /v1/certificates/:id
GET    /v1/certificates/:id/download
```

#### Notificaciones Config (4 endpoints)
```
GET    /v1/notification-settings
PUT    /v1/notification-settings
GET    /v1/notification-templates
POST   /v1/notification-templates
```

#### Pagos/Finanzas (6 endpoints)
```
GET    /v1/schools/:id/fee-concepts
POST   /v1/schools/:id/fee-concepts
GET    /v1/students/:id/fees
POST   /v1/payments
GET    /v1/payments/:id
GET    /v1/payments/:id/receipt
```

---

## PARTE 3: Modificaciones a Endpoints Existentes

### En API-MOBILE

#### GET /v1/materials
**Modificación**: Agregar filtro por escuela activa.

```http
GET /v1/materials?school_id={uuid}&subject=mathematics
```

**Cambio**: Si el usuario tiene contexto activo, filtrar automáticamente por esa escuela.

---

#### GET /v1/users/me/attempts
**Ya existe** ✅ - No requiere cambios.

---

#### GET /v1/materials/:id/assessment
**Ya existe** ✅ - No requiere cambios.

---

### En API-ADMIN

#### GET /v1/users/:id
**Modificación**: Incluir membresías y escuelas del usuario.

**Response actual**: Solo datos básicos del usuario.

**Response propuesto**:
```json
{
  "id": "uuid",
  "email": "...",
  "first_name": "...",
  "last_name": "...",
  "role": "student",
  "memberships": [
    {
      "school_id": "uuid",
      "school_name": "Colegio San José",
      "unit_id": "uuid",
      "unit_name": "3° Grado A",
      "role": "student",
      "is_active": true
    }
  ],
  "guardian_relations": [...],
  "created_at": "...",
  "updated_at": "..."
}
```

---

## Plan de Implementación Sugerido

### Sprint 1 (Semana 1-2): Críticos para UI
1. `GET /v1/users/me/schools` - 4h
2. `POST /v1/users/me/active-school` - 3h
3. `GET /v1/users/me/active-school` - 2h
4. `GET /v1/users/me` (si no existe en mobile) - 2h
5. `GET /v1/users/me/stats` - 6h
6. Tabla `user_active_context` - 1h

**Total Sprint 1**: ~18h de backend

### Sprint 2 (Semana 3-4): Mejoras Home
1. `GET /v1/users/me/activity` - 4h
2. `POST/DELETE /v1/materials/:id/favorite` - 3h
3. `GET /v1/users/me/favorites` - 2h
4. Tabla `user_favorites` - 1h
5. Modificar `GET /v1/materials` para filtro por escuela - 2h

**Total Sprint 2**: ~12h de backend

### Sprint 3+ (Futuro): Admin
- Ciclos académicos: ~16h
- Horarios: ~24h
- Importación: ~20h
- Resto: ~60h

---

## Validaciones Comunes

### Para todos los endpoints nuevos:

1. **Autenticación**: JWT válido requerido
2. **Autorización**: 
   - `/users/me/*` → Solo el usuario autenticado
   - `/schools/:id/*` → Usuario con membresía en esa escuela
   - `/admin/*` → Roles: admin, director_escuela
3. **Rate Limiting**: 100 req/min por usuario
4. **Logging**: Registrar en audit_logs (MongoDB)

### Formato de errores estándar:
```json
{
  "error": "error_code",
  "message": "Descripción legible",
  "details": { ... },
  "timestamp": "2025-12-01T10:30:00Z"
}
```

---

## Referencias

- [PANTALLAS-NUEVAS-PARTE1.md](./estudiantes/PANTALLAS-NUEVAS-PARTE1.md) - Consume endpoints de materiales
- [PANTALLAS-NUEVAS-PARTE2.md](./estudiantes/PANTALLAS-NUEVAS-PARTE2.md) - Consume endpoints de quiz y contexto
- [PANTALLAS-EXISTENTES.md](./estudiantes/PANTALLAS-EXISTENTES.md) - Requiere endpoints de stats
- [ENDPOINTS-FALTANTES.md](./administracion/ENDPOINTS-FALTANTES.md) - Detalle completo de admin
- [SPEC-OFFLINE.md](./specs-nuevos/SPEC-OFFLINE.md) - No requiere endpoints nuevos
- [SPEC-SYNC.md](./specs-nuevos/SPEC-SYNC.md) - Posibles endpoints de sync futuros

---

**Generado por**: Claude Code  
**Fecha**: 1 de Diciembre, 2025
