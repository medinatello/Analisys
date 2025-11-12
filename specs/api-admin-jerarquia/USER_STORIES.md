# Historias de Usuario - Jerarquía Académica

**Epic:** Jerarquía Académica en edugo-api-administracion  
**Stakeholder:** Administradores de Escuelas

---

## 👤 PERSONAS

### Admin de Escuela - María González
- **Rol:** Directora del Colegio San José
- **Objetivo:** Organizar 500 estudiantes en 6 años y 18 secciones
- **Pain Points:** 
  - Sin estructura, no puede asignar materiales por sección
  - No puede generar reportes por grupo
  - Gestión manual y propensa a errores

### Admin de Sistema - Carlos Ramírez
- **Rol:** Administrador TI de la plataforma EduGo
- **Objetivo:** Configurar múltiples escuelas en la plataforma
- **Pain Points:**
  - Código legacy difícil de mantener
  - Sin APIs para gestionar jerarquías

---

## 📖 HISTORIAS DE USUARIO

### Epic 1: Gestión de Escuelas

#### HU-001: Crear Escuela
**Como** administrador de sistema  
**Quiero** crear una nueva escuela en la plataforma  
**Para** poder configurar su estructura académica

**Criterios de Aceptación:**
- [ ] Puedo crear escuela con nombre, código único, dirección y contacto
- [ ] El sistema valida que el código no esté duplicado
- [ ] El sistema valida formato de email
- [ ] Recibo confirmación con ID de la escuela creada
- [ ] La escuela aparece en el listado de escuelas

**Endpoint:** `POST /v1/schools`

**Payload:**
```json
{
  "name": "Colegio San José",
  "code": "CSJ",
  "address": "Av. Principal 123",
  "contact_email": "admin@csj.edu",
  "contact_phone": "+1234567890"
}
```

**Response:**
```json
{
  "id": "uuid",
  "name": "Colegio San José",
  "code": "CSJ",
  "created_at": "2025-11-11T10:00:00Z"
}
```

**Casos de Error:**
- 400: Código duplicado
- 400: Email inválido
- 401: No autenticado
- 403: No es admin

---

#### HU-002: Listar Escuelas
**Como** administrador de sistema  
**Quiero** ver todas las escuelas registradas  
**Para** poder gestionarlas

**Criterios de Aceptación:**
- [ ] Veo lista paginada de escuelas (default 20 por página)
- [ ] Puedo filtrar por nombre o código
- [ ] Cada escuela muestra: id, nombre, código, cantidad de unidades
- [ ] La lista está ordenada por nombre

**Endpoint:** `GET /v1/schools?page=1&limit=20&search=San`

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Colegio San José",
      "code": "CSJ",
      "units_count": 25,
      "students_count": 500
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150
  }
}
```

---

#### HU-003: Actualizar Escuela
**Como** administrador de escuela  
**Quiero** actualizar datos de contacto de mi escuela  
**Para** mantener información actualizada

**Criterios de Aceptación:**
- [ ] Puedo actualizar nombre, dirección, email, teléfono
- [ ] NO puedo cambiar el código (inmutable)
- [ ] El sistema valida email
- [ ] Recibo confirmación de actualización

**Endpoint:** `PUT /v1/schools/:id`

---

### Epic 2: Jerarquía de Unidades Académicas

#### HU-004: Crear Año Académico
**Como** administrador de escuela  
**Quiero** crear años académicos (1º, 2º, 3º, etc.)  
**Para** organizar la estructura de mi escuela

**Criterios de Aceptación:**
- [ ] Puedo crear unidad de tipo "grade" dentro de una escuela
- [ ] El nombre es descriptivo (ej: "Quinto Año")
- [ ] Puedo asignar código corto (ej: "5º")
- [ ] La unidad se crea bajo la escuela correcta

**Endpoint:** `POST /v1/schools/:schoolId/units`

**Payload:**
```json
{
  "type": "grade",
  "display_name": "Quinto Año",
  "code": "5º",
  "description": "Quinto año de primaria"
}
```

**Response:**
```json
{
  "id": "uuid-year-5",
  "school_id": "uuid-school",
  "parent_unit_id": null,
  "type": "grade",
  "display_name": "Quinto Año",
  "code": "5º",
  "created_at": "2025-11-11T10:00:00Z"
}
```

---

#### HU-005: Crear Sección dentro de Año
**Como** administrador de escuela  
**Quiero** crear secciones (A, B, C) dentro de un año académico  
**Para** dividir estudiantes en grupos manejables

**Criterios de Aceptación:**
- [ ] Puedo crear unidad de tipo "section" como hija de un "grade"
- [ ] El sistema valida que el padre sea un año válido
- [ ] Puedo crear múltiples secciones en un año
- [ ] Las secciones se muestran en el árbol jerárquico

**Endpoint:** `POST /v1/schools/:schoolId/units`

**Payload:**
```json
{
  "parent_unit_id": "uuid-year-5",
  "type": "section",
  "display_name": "5º A",
  "code": "5A"
}
```

**Jerarquía Resultante:**
```
Colegio San José
 └── Quinto Año (5º)
      ├── 5º A
      ├── 5º B
      └── 5º C
```

---

#### HU-006: Ver Árbol Jerárquico
**Como** administrador de escuela  
**Quiero** ver la estructura completa de mi escuela en formato árbol  
**Para** entender la organización

**Criterios de Aceptación:**
- [ ] Veo estructura jerárquica completa desde una unidad raíz
- [ ] Cada nivel muestra: id, nombre, tipo, cantidad de hijos
- [ ] El árbol se puede obtener desde cualquier nodo
- [ ] El formato es JSON anidado

**Endpoint:** `GET /v1/units/:id/tree`

**Response:**
```json
{
  "id": "uuid-school",
  "display_name": "Colegio San José",
  "type": "school",
  "children": [
    {
      "id": "uuid-year-5",
      "display_name": "Quinto Año",
      "type": "grade",
      "children": [
        {
          "id": "uuid-section-5a",
          "display_name": "5º A",
          "type": "section",
          "members_count": 30,
          "children": []
        }
      ]
    }
  ]
}
```

---

#### HU-007: Prevenir Ciclos Jerárquicos
**Como** desarrollador del sistema  
**Quiero** que el sistema prevenga ciclos en la jerarquía  
**Para** evitar bugs y corrupción de datos

**Criterios de Aceptación:**
- [ ] Si intento crear unidad A con padre B, y B con padre A, el sistema rechaza
- [ ] Trigger de BD valida ciclos antes de insertar
- [ ] Response 400 con mensaje: "Jerarquía circular detectada"

**Escenario de Error:**
```
1. Crear Año 5º (id: year-5)
2. Crear Sección 5ºA (id: section-5a, parent: year-5)
3. Intentar actualizar Año 5º con parent: section-5a
   → ❌ ERROR: "Jerarquía circular detectada"
```

---

### Epic 3: Membresías (Asignación de Usuarios)

#### HU-008: Asignar Estudiante a Sección
**Como** administrador de escuela  
**Quiero** asignar un estudiante a una sección específica  
**Para** que pueda acceder a los materiales de su sección

**Criterios de Aceptación:**
- [ ] Puedo asignar estudiante por su user_id
- [ ] Puedo especificar rol "student"
- [ ] Puedo especificar vigencia (inicio y fin de año escolar)
- [ ] El sistema valida que el usuario existe
- [ ] El sistema previene asignar el mismo usuario dos veces a la misma unidad

**Endpoint:** `POST /v1/units/:unitId/members`

**Payload:**
```json
{
  "user_id": "uuid-student",
  "role": "student",
  "valid_from": "2025-03-01",
  "valid_until": "2025-12-15"
}
```

**Response:**
```json
{
  "id": "uuid-membership",
  "unit_id": "uuid-section-5a",
  "user_id": "uuid-student",
  "role": "student",
  "valid_from": "2025-03-01",
  "valid_until": "2025-12-15"
}
```

---

#### HU-009: Asignar Profesor a Sección (Owner)
**Como** administrador de escuela  
**Quiero** asignar un profesor como "owner" de una sección  
**Para** que pueda gestionar materiales y ver progreso de sus estudiantes

**Criterios de Aceptación:**
- [ ] Puedo asignar profesor con rol "owner"
- [ ] Un profesor puede ser owner de múltiples secciones
- [ ] Una sección puede tener múltiples teachers pero solo 1 owner
- [ ] El owner tiene permisos especiales

**Endpoint:** `POST /v1/units/:unitId/members`

**Payload:**
```json
{
  "user_id": "uuid-teacher",
  "role": "owner"
}
```

---

#### HU-010: Listar Miembros de una Unidad
**Como** administrador de escuela  
**Quiero** ver todos los miembros de una sección  
**Para** validar inscripciones y asignaciones

**Criterios de Aceptación:**
- [ ] Veo lista de todos los miembros con nombre, rol, vigencia
- [ ] Puedo filtrar por rol (ej: solo students)
- [ ] Veo si la membresía está activa o expirada
- [ ] Puedo paginar resultados

**Endpoint:** `GET /v1/units/:unitId/members?role=student`

**Response:**
```json
{
  "data": [
    {
      "membership_id": "uuid",
      "user": {
        "id": "uuid-student",
        "name": "Juan Pérez",
        "email": "juan@example.com"
      },
      "role": "student",
      "valid_from": "2025-03-01",
      "valid_until": "2025-12-15",
      "is_active": true
    }
  ],
  "pagination": { "total": 30 }
}
```

---

#### HU-011: Quitar Estudiante de Sección
**Como** administrador de escuela  
**Quiero** quitar un estudiante de una sección  
**Para** gestionar cambios de grupo

**Criterios de Aceptación:**
- [ ] Puedo remover la asignación especificando unit_id + user_id
- [ ] El estudiante pierde acceso a materiales de esa sección
- [ ] La operación es suave (no borra progreso existente)
- [ ] Recibo confirmación de eliminación

**Endpoint:** `DELETE /v1/units/:unitId/members/:userId`

**Response:**
```json
{
  "message": "Membership removed successfully"
}
```

---

## 🎯 ACCEPTANCE CRITERIA MASTER

### Escenario Completo: Setup de Colegio San José

**Given:** Soy administrador con token JWT válido

**When:** Ejecuto la siguiente secuencia:

```bash
# 1. Crear escuela
POST /v1/schools
→ Colegio San José (CSJ)

# 2. Crear años académicos
POST /v1/schools/{csj-id}/units → Quinto Año (5º)
POST /v1/schools/{csj-id}/units → Sexto Año (6º)

# 3. Crear secciones en 5º
POST /v1/schools/{csj-id}/units → 5º A (parent: Quinto Año)
POST /v1/schools/{csj-id}/units → 5º B (parent: Quinto Año)
POST /v1/schools/{csj-id}/units → 5º C (parent: Quinto Año)

# 4. Ver árbol completo
GET /v1/units/{csj-id}/tree
→ Devuelve estructura completa anidada

# 5. Asignar profesor como owner de 5º A
POST /v1/units/{5a-id}/members
{user_id: teacher-1, role: "owner"}

# 6. Asignar 30 estudiantes a 5º A
POST /v1/units/{5a-id}/members × 30
{user_id: student-X, role: "student"}

# 7. Listar miembros
GET /v1/units/{5a-id}/members?role=student
→ Devuelve 30 estudiantes

# 8. Ver jerarquía con counts
GET /v1/units/{quinto-año-id}/tree
→ Muestra 3 secciones con counts de miembros
```

**Then:** 
- ✅ Estructura jerárquica completa creada
- ✅ Todos los endpoints responden correctamente
- ✅ Datos persistidos en PostgreSQL
- ✅ Constraints validados (sin duplicados, sin ciclos)

---

## 🧪 CASOS DE PRUEBA ESPECÍFICOS

### Caso de Prueba 1: Validación de Ciclos

```
SETUP:
- Crear Año A (id: year-a)
- Crear Sección B (id: section-b, parent: year-a)

TEST:
PUT /v1/units/year-a
{
  "parent_unit_id": "section-b"  // Intentar ciclo
}

EXPECTED:
❌ 400 Bad Request
{
  "error": "Jerarquía circular detectada"
}
```

---

### Caso de Prueba 2: Validación de Duplicados

```
SETUP:
- Crear Unidad A (id: unit-a)
- Crear membresía: user-1 en unit-a con rol "student"

TEST:
POST /v1/units/unit-a/members
{
  "user_id": "user-1",
  "role": "teacher"  // Intentar duplicar con diferente rol
}

EXPECTED:
❌ 409 Conflict
{
  "error": "User already member of this unit"
}
```

---

### Caso de Prueba 3: Jerarquía Profunda (3 niveles)

```
TEST:
1. Crear Escuela (nivel 0)
2. Crear Año (nivel 1, parent: Escuela)
3. Crear Sección (nivel 2, parent: Año)
4. Crear Club (nivel 3, parent: Sección)
5. GET /v1/units/{escuela-id}/tree

EXPECTED:
✅ 200 OK con 4 niveles anidados correctamente
```

---

### Caso de Prueba 4: Eliminar Unidad con Hijos

```
SETUP:
- Crear Año con 3 Secciones hijas

TEST:
DELETE /v1/units/{año-id}

EXPECTED:
❌ 400 Bad Request
{
  "error": "Cannot delete unit with children. Delete children first."
}
```

---

### Caso de Prueba 5: Membresía Expirada

```
SETUP:
- Crear membresía con valid_until = "2024-12-31" (pasado)

TEST:
GET /v1/units/{unit-id}/members

EXPECTED:
✅ 200 OK
{
  "data": [
    {
      "user_id": "uuid",
      "is_active": false,  // ⚠️ Membresía expirada
      "valid_until": "2024-12-31"
    }
  ]
}
```

---

## 📊 MÉTRICAS DE ÉXITO

### Para Declarar HU como DONE

Cada historia se considera completada cuando:
- [ ] Endpoint implementado y funcional
- [ ] Todos los criterios de aceptación cumplidos
- [ ] Tests e2e del caso de uso pasan
- [ ] Documentación Swagger actualizada
- [ ] Code review completado

### Métricas Cuantitativas

- **Cobertura de tests:** >80%
- **Performance:** p95 < 500ms
- **Errores:** <1% en producción
- **Disponibilidad:** 99.9%

---

## 🚀 INTEGRACIÓN CON OTROS SISTEMAS

### api-mobile Consumirá Estos Datos

**Escenario:** Estudiante ve materiales de su sección

```
1. api-mobile: GET /v1/users/me
   → Devuelve user_id del estudiante

2. api-mobile llama a api-admin:
   GET /v1/users/{user-id}/units
   → Devuelve unidades del estudiante: ["5º A"]

3. api-mobile llama a api-admin:
   GET /v1/units/{5a-id}/materials
   → Devuelve materiales asignados a 5º A

4. api-mobile filtra y muestra solo esos materiales
```

**⚠️ Requiere:** Endpoint adicional `GET /v1/users/:userId/units` (puede ser Fase 8)

---

## 📝 DEFINICIÓN DE DONE POR HU

| HU | Endpoint | Tests | Swagger | Status |
|----|----------|-------|---------|--------|
| HU-001 | POST /v1/schools | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |
| HU-002 | GET /v1/schools | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |
| HU-003 | PUT /v1/schools/:id | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |
| HU-004 | POST /v1/schools/:id/units | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |
| HU-005 | POST /v1/schools/:id/units | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |
| HU-006 | GET /v1/units/:id/tree | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |
| HU-007 | Trigger BD | ☐ Unit ☐ Integration | ☐ | ☐ |
| HU-008 | POST /v1/units/:id/members | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |
| HU-009 | POST /v1/units/:id/members | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |
| HU-010 | GET /v1/units/:id/members | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |
| HU-011 | DELETE /v1/units/:id/members/:userId | ☐ Unit ☐ Integration ☐ E2E | ☐ | ☐ |

---

**Todas las HU done = Sprint completado ✅**

---

**Generado con** 🤖 Claude Code
