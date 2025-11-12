# PRD: Modernización y Jerarquía Académica - api-administracion

**Fecha:** 11 de Noviembre, 2025  
**Autor:** Equipo EduGo  
**Tipo:** Product Requirements Document (PRD)  
**Proyecto:** edugo-api-administracion  
**Epic:** Jerarquía Académica + Modernización Arquitectónica

---

## 📋 RESUMEN EJECUTIVO

### Problema
`edugo-api-administracion` está al **10% de completitud** con código del monorepo original sin actualizar. No tiene la jerarquía académica implementada, lo cual es **BLOQUEANTE** para el uso real del sistema en escuelas.

### Solución
Modernizar `edugo-api-administracion` aplicando las mejoras de `edugo-api-mobile` (Clean Architecture, CI/CD, testcontainers) e implementar la jerarquía académica completa (escuelas, unidades académicas, membresías).

### Impacto
- ✅ Sistema usable en escuelas reales
- ✅ Organización de estudiantes por secciones/grupos
- ✅ Asignación de materiales por unidad académica
- ✅ Base sólida para futuros módulos administrativos

---

## 🎯 OBJETIVOS

### Objetivos Primarios
1. **Implementar jerarquía académica completa** (3 tablas + endpoints CRUD)
2. **Modernizar arquitectura** (migrar de código legacy a Clean Architecture)
3. **Migrar mejoras de api-mobile** (bootstrap, container, CI/CD)
4. **Consolidar utilidades en shared** (evitar duplicación)

### Objetivos Secundarios
5. Configurar CI/CD completo (GitHub Actions)
6. Alcanzar >80% code coverage
7. Documentación completa (Swagger, README)

### No Objetivos (Fuera de Scope)
- ❌ Perfiles especializados (Sprint Admin-2)
- ❌ Reportes y analytics (Sprint Admin-4)
- ❌ Gestión de materias (Sprint Admin-3)

---

## 👥 STAKEHOLDERS

| Rol | Nombre/Equipo | Responsabilidad |
|-----|---------------|-----------------|
| **Product Owner** | Equipo EduGo | Aprobar prioridades y requerimientos |
| **Tech Lead** | (TBD) | Arquitectura y revisión de código |
| **Developer** | (TBD) | Implementación |
| **QA** | (TBD) | Tests y validación |
| **DevOps** | (TBD) | CI/CD y despliegues |

---

## 📊 CONTEXTO DEL NEGOCIO

### Caso de Uso Real

**Colegio San José** quiere usar EduGo:
- Tiene **500 estudiantes** organizados en:
  - 6 años académicos (1º a 6º)
  - 3 secciones por año (A, B, C)
  - 5 clubes extracurriculares
- **30 profesores** que enseñan en diferentes secciones
- **Materiales educativos** deben asignarse por sección (ej: "5º A - Matemáticas")
- **Progreso** debe reportarse por sección, no individualmente

**Sin jerarquía académica:**
❌ No hay forma de organizar los 500 estudiantes  
❌ No se pueden asignar materiales a "5º A"  
❌ No se pueden generar reportes por sección  
❌ **Sistema NO es usable**

**Con jerarquía académica:**
✅ Estructura clara: Colegio → Año → Sección → Estudiantes  
✅ Asignación: Material "Pascal" → Unidad "5º A"  
✅ Reportes: Progreso de "5º A" en "Pascal"  
✅ **Sistema LISTO para producción**

---

## 🏗️ ARQUITECTURA ACTUAL vs OBJETIVO

### Estado Actual de api-administracion (10%)

```
edugo-api-administracion/
├── internal/
│   ├── application/     (código monorepo legacy)
│   ├── config/          (básico)
│   ├── container/       (básico)
│   ├── domain/          (legacy)
│   ├── handlers/        (legacy)
│   ├── infrastructure/  (legacy)
│   └── models/          ⚠️ (patrón antiguo, debe eliminarse)
├── .github/
│   └── workflows/       (10 archivos pero desactualizados)
└── Sin: bootstrap/, tests robustos, testcontainers
```

**Arquitectura:** Mezcla de legacy + parcialmente modernizado  
**Tests:** 55 archivos Go totales (vs 37 tests en api-mobile)  
**CI/CD:** Workflows existen pero no actualizados

---

### Objetivo Final de api-administracion (100%)

```
edugo-api-administracion/
├── internal/
│   ├── bootstrap/           ⭐ NUEVO (de api-mobile)
│   │   ├── bootstrap.go
│   │   ├── config.go
│   │   ├── factories.go
│   │   ├── lifecycle.go
│   │   └── interfaces.go
│   ├── container/           ⭐ MEJORADO (patrón api-mobile)
│   │   ├── container.go
│   │   ├── handlers.go
│   │   ├── services.go
│   │   ├── repositories.go
│   │   └── infrastructure.go
│   ├── config/              ⭐ MEJORADO (validación robusta)
│   ├── domain/              ⭐ NUEVO (jerarquía académica)
│   │   ├── entity/
│   │   │   ├── school.go
│   │   │   ├── academic_unit.go
│   │   │   └── unit_membership.go
│   │   ├── valueobject/
│   │   │   ├── school_id.go
│   │   │   ├── unit_id.go
│   │   │   ├── unit_type.go
│   │   │   └── membership_role.go
│   │   └── repository/
│   │       ├── school_repository.go
│   │       ├── unit_repository.go
│   │       └── membership_repository.go
│   ├── application/         ⭐ NUEVO (servicios jerarquía)
│   │   ├── dto/
│   │   ├── service/
│   │   │   ├── school_service.go
│   │   │   ├── unit_service.go
│   │   │   └── membership_service.go
│   │   └── mapper/
│   └── infrastructure/      ⭐ MEJORADO
│       ├── http/
│       │   ├── handler/
│       │   ├── middleware/
│       │   └── router/
│       └── persistence/
│           └── postgres/
│               ├── school_repository_impl.go
│               ├── unit_repository_impl.go
│               └── membership_repository_impl.go
├── scripts/
│   └── postgresql/          ⭐ NUEVO
│       ├── 01_academic_hierarchy.sql
│       ├── 02_seeds.sql
│       └── 03_indexes.sql
├── .github/
│   └── workflows/           ⭐ ACTUALIZADO (de api-mobile)
│       ├── pr-to-dev.yml
│       ├── pr-to-main.yml
│       ├── test.yml
│       └── sync-main-to-dev.yml
└── test/                    ⭐ NUEVO
    └── integration/
```

**Arquitectura:** Clean Architecture moderna  
**Tests:** >80% coverage con testcontainers  
**CI/CD:** 4 workflows funcionales

---

## 📊 MEJORAS DE API-MOBILE A MIGRAR

### Análisis Comparativo

| Mejora | api-mobile | api-admin | Acción |
|--------|------------|-----------|--------|
| **Bootstrap System** | ✅ Implementado | ❌ No existe | Migrar completo |
| **DI Container** | ✅ Moderno (5 archivos) | 🟡 Básico (3 archivos) | Actualizar patrón |
| **Testcontainers** | ✅ PostgreSQL, MongoDB, RabbitMQ | ❌ No existe | Migrar |
| **CI/CD Workflows** | ✅ 5 workflows modernos | 🟡 10 workflows legacy | Reemplazar |
| **Config Validation** | ✅ Validator robusto | 🟡 Básico | Migrar |
| **Lifecycle Management** | ✅ Startup/Shutdown | ❌ No existe | Migrar |
| **Integration Tests** | ✅ 37 tests | ⚠️ 55 archivos pero legacy | Modernizar |
| **Makefile** | ✅ 50+ comandos | 🟡 Básico | Actualizar |
| **Dockerfile** | ✅ Multi-stage optimizado | 🟡 Básico | Actualizar |

---

## 🔄 RESPONSABILIDADES PARA SHARED

### Código Duplicado Detectado

Estas funcionalidades están en `api-mobile` pero deberían estar en `shared`:

| # | Funcionalidad | Ubicación actual | Ubicación ideal | Razón |
|---|---------------|------------------|-----------------|-------|
| 1 | **Bootstrap System** | api-mobile/internal/bootstrap/ | shared/bootstrap/ | Reutilizable por api-admin, worker |
| 2 | **Container Patterns** | api-mobile/internal/container/ | shared/container/ | Patrón DI común |
| 3 | **Testcontainers Helpers** | api-mobile/internal/bootstrap/noop/ | shared/testing/ | Todos los proyectos usan testcontainers |
| 4 | **Config Validator** | api-mobile/internal/config/validator.go | shared/config/ | Validación estándar |
| 5 | **HTTP Middleware Helpers** | api-mobile/internal/infrastructure/http/middleware/ | shared/middleware/ | Ya existe shared/middleware pero incompleto |

### Análisis de Migración

| Item | Complejidad | Impacto | Prioridad | Sprint |
|------|-------------|---------|-----------|--------|
| Bootstrap System | 🟡 Media | 🔴 Alto | P0 | Shared-1 |
| Testcontainers Helpers | 🟢 Baja | 🔴 Alto | P0 | Shared-1 |
| Config Validator | 🟢 Baja | 🟡 Medio | P1 | Shared-1 |
| Container Patterns | 🟡 Media | 🟡 Medio | P2 | Post-Admin-1 |

**Decisión:**
- ✅ **Migrar Bootstrap + Testcontainers a shared PRIMERO** (Sprint Shared-1)
- ✅ **Luego usarlos en api-admin** (Sprint Admin-1)
- ⚠️ Container patterns pueden esperar (no bloqueantes)

---

## 📐 REQUERIMIENTOS FUNCIONALES

### RF-1: Gestión de Escuelas

| ID | Requerimiento | Prioridad | Criterio de Aceptación |
|----|---------------|-----------|------------------------|
| RF-1.1 | Crear escuela | Must | Admin puede crear escuela con nombre, código, contacto |
| RF-1.2 | Listar escuelas | Must | Admin ve lista paginada de escuelas |
| RF-1.3 | Obtener detalle de escuela | Must | Admin ve datos completos de una escuela |
| RF-1.4 | Actualizar escuela | Must | Admin puede modificar datos de escuela |
| RF-1.5 | Eliminar escuela | Should | Admin puede soft-delete escuela |

---

### RF-2: Jerarquía de Unidades Académicas

| ID | Requerimiento | Prioridad | Criterio de Aceptación |
|----|---------------|-----------|------------------------|
| RF-2.1 | Crear unidad académica | Must | Admin crea año, sección, club dentro de escuela |
| RF-2.2 | Jerarquía de 3 niveles | Must | Soporta: Escuela → Año → Sección/Club |
| RF-2.3 | Listar unidades de escuela | Must | Admin ve todas las unidades de una escuela |
| RF-2.4 | Obtener árbol jerárquico | Must | Admin ve estructura completa en formato árbol |
| RF-2.5 | Actualizar unidad | Must | Admin puede modificar datos de unidad |
| RF-2.6 | Eliminar unidad | Should | Admin puede soft-delete unidad (valida sin hijos) |
| RF-2.7 | Prevenir ciclos | Must | Sistema valida que no haya ciclos en jerarquía |

---

### RF-3: Membresías (Asignación de Usuarios a Unidades)

| ID | Requerimiento | Prioridad | Criterio de Aceptación |
|----|---------------|-----------|------------------------|
| RF-3.1 | Asignar usuario a unidad | Must | Admin asigna estudiante/profesor a sección con rol |
| RF-3.2 | Roles por unidad | Must | Soporta: owner, teacher, assistant, student, guardian |
| RF-3.3 | Vigencia temporal | Should | Membresía con fecha inicio/fin (año escolar) |
| RF-3.4 | Listar miembros de unidad | Must | Admin ve todos los miembros de una sección |
| RF-3.5 | Quitar miembro de unidad | Must | Admin puede remover asignación |
| RF-3.6 | Prevenir duplicados | Must | Un usuario no puede tener 2 roles en misma unidad |

---

## 📐 REQUERIMIENTOS NO FUNCIONALES

### RNF-1: Performance
- Listar escuelas: < 200ms (p95)
- Listar unidades: < 300ms (p95)
- Obtener árbol jerárquico: < 500ms (p95)
- Crear unidad: < 300ms (p95)

### RNF-2: Escalabilidad
- Soportar hasta 1,000 escuelas
- Soportar hasta 10,000 unidades académicas
- Soportar hasta 100,000 membresías

### RNF-3: Disponibilidad
- Uptime: 99.9%
- Health check endpoint: `/health`
- Graceful shutdown en <10 segundos

### RNF-4: Seguridad
- Solo usuarios con rol `admin` pueden crear/modificar/eliminar
- Autenticación JWT obligatoria
- Validación de entrada en todos los endpoints
- SQL injection prevention (usar prepared statements)

### RNF-5: Calidad de Código
- Code coverage: >80%
- Linting: golangci-lint sin errores
- Tests: unitarios + integración + e2e
- Arquitectura: Clean Architecture (DDD)

---

## 🎨 DISEÑO DE API (Endpoints)

### Módulo: Escuelas

```
POST   /v1/schools
GET    /v1/schools?page=1&limit=20
GET    /v1/schools/:id
PUT    /v1/schools/:id
DELETE /v1/schools/:id
```

### Módulo: Unidades Académicas

```
POST   /v1/schools/:schoolId/units
GET    /v1/schools/:schoolId/units?type=grade|section|club
GET    /v1/units/:id
GET    /v1/units/:id/tree          (árbol jerárquico completo)
GET    /v1/units/:id/ancestors     (path hacia raíz)
GET    /v1/units/:id/children      (hijos directos)
PUT    /v1/units/:id
DELETE /v1/units/:id
```

### Módulo: Membresías

```
POST   /v1/units/:unitId/members
GET    /v1/units/:unitId/members?role=student|teacher
GET    /v1/units/:unitId/members/:userId
DELETE /v1/units/:unitId/members/:userId
```

Ver especificación completa en: `API_SPEC.md`

---

## 🗄️ MODELO DE DATOS

### Tablas a Implementar

#### 1. school
```sql
CREATE TABLE school (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    address TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### 2. academic_unit
```sql
CREATE TABLE academic_unit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_unit_id UUID REFERENCES academic_unit(id),
    school_id UUID NOT NULL REFERENCES school(id),
    unit_type VARCHAR(50) NOT NULL,  -- 'school', 'grade', 'section', 'club'
    display_name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP,
    CHECK (unit_type IN ('school', 'grade', 'section', 'club', 'department'))
);
```

#### 3. unit_membership
```sql
CREATE TABLE unit_membership (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID NOT NULL REFERENCES academic_unit(id),
    user_id UUID NOT NULL,  -- FK a users (compartido con api-mobile)
    role VARCHAR(50) NOT NULL,
    valid_from DATE,
    valid_until DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(unit_id, user_id),
    CHECK (role IN ('owner', 'teacher', 'assistant', 'student', 'guardian'))
);
```

Ver diseño completo en: `DESIGN.md`

---

## 🧪 ESTRATEGIA DE TESTING

### Niveles de Testing

| Tipo | Cobertura Objetivo | Herramientas |
|------|-------------------|--------------|
| **Unitarios** | >85% | Go testing, testify |
| **Integración** | >75% | Testcontainers (PostgreSQL) |
| **E2E** | Casos críticos | HTTP tests con DB real |

### Testcontainers

Migrar setup de api-mobile:
```go
// Setup PostgreSQL con testcontainers
container := testcontainers.PostgresContainer{
    Image: "postgres:15-alpine",
    Env: map[string]string{
        "POSTGRES_DB": "edugo_test",
    },
}
```

---

## 🚀 PLAN DE IMPLEMENTACIÓN

### Fases del Proyecto

| Fase | Nombre | Duración | Objetivo |
|------|--------|----------|----------|
| **0** | Preparación | 3 días | Migrar utilidades a shared |
| **1** | Modernización | 5 días | Migrar arquitectura de api-mobile |
| **2** | Jerarquía - Schema | 2 días | Implementar 3 tablas |
| **3** | Jerarquía - Dominio | 3 días | Entities, VOs, Repositories |
| **4** | Jerarquía - Aplicación | 3 días | Services, DTOs, Mappers |
| **5** | Jerarquía - API | 4 días | Handlers, Routes, Middleware |
| **6** | Testing | 3 días | Tests unitarios + integración |
| **7** | CI/CD | 1 día | Workflows actualizados |

**TOTAL:** 24 días (~5 semanas)

Cada fase produce **PR independiente** que compila y pasa tests.

Ver plan detallado en: `TASKS.md`

---

## 📅 CRONOGRAMA

### Semana 1: Preparación + Modernización (Fase 0-1)
- Lunes-Martes: Sprint Shared-1 (migrar bootstrap + testcontainers)
- Miércoles-Viernes: Modernizar api-admin (aplicar patrón api-mobile)

### Semana 2: Schema + Dominio (Fase 2-3)
- Lunes-Martes: Implementar 3 tablas SQL + seeds
- Miércoles-Viernes: Implementar capa de dominio

### Semana 3: Aplicación + API (Fase 4-5)
- Lunes-Miércoles: Services y DTOs
- Jueves-Viernes: Handlers y routes

### Semana 4: Testing + CI/CD (Fase 6-7)
- Lunes-Miércoles: Tests completos
- Jueves: CI/CD
- Viernes: Revisión y ajustes

### Semana 5: Buffer y Documentación
- Lunes-Martes: Ajustes finales
- Miércoles: Documentación (Swagger, README)
- Jueves-Viernes: Deploy a dev/staging

---

## ✅ CRITERIOS DE ACEPTACIÓN GLOBAL

### Para Declarar el Sprint Completado

- [ ] 3 tablas creadas y migradas en PostgreSQL
- [ ] Endpoints CRUD completos para escuelas, unidades, membresías
- [ ] Tests >80% coverage
- [ ] CI/CD pasando en todos los workflows
- [ ] Documentación Swagger actualizada
- [ ] Integration tests con testcontainers funcionando
- [ ] Manual de usuario para admins creado
- [ ] README actualizado con nueva arquitectura
- [ ] Deployed a ambiente dev y validado

---

## 📊 MÉTRICAS DE ÉXITO

| Métrica | Valor Actual | Valor Objetivo | Medición |
|---------|--------------|----------------|----------|
| Completitud del proyecto | 10% | 70% | Features implementados |
| Code coverage | ⚠️ Desconocido | >80% | `go test -cover` |
| Tablas implementadas | 0/14 | 3/14 | Schema SQL |
| Endpoints implementados | ~5 | ~15 | Swagger spec |
| CI/CD passing | ❌ No | ✅ Sí | GitHub Actions |

---

## ⚠️ RIESGOS Y MITIGACIONES

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Código legacy incompatible | Alta | Alto | Reescribir en lugar de refactorizar |
| Shared no listo a tiempo | Media | Medio | Sprint Shared-1 en paralelo semana 1 |
| Tests legacy no compatibles | Alta | Bajo | Crear tests nuevos con testcontainers |
| Esquema BD complejo | Media | Alto | Validar con DBA, tests exhaustivos |

---

## 📝 DEPENDENCIAS

### Dependencias Bloqueantes (Deben completarse ANTES)

| Dependencia | Proyecto | Estado | ETA |
|-------------|----------|--------|-----|
| Migrar bootstrap a shared | edugo-shared | ⏳ Pendiente | Semana 1 |
| Migrar testcontainers a shared | edugo-shared | ⏳ Pendiente | Semana 1 |

### Dependencias No Bloqueantes (Pueden ser paralelas)

| Dependencia | Proyecto | Estado |
|-------------|----------|--------|
| Actualizar dev-environment | edugo-dev-environment | ⏳ Puede esperar |
| Completar worker | edugo-worker | ⏳ Puede esperar |

---

## 🔄 ESTRATEGIA DE BRANCHING Y PRS

### Estructura de Branches

```
main (protegida)
 └── dev (base de desarrollo)
      ├── feature/shared-bootstrap-migration       (Fase 0 - shared)
      ├── feature/admin-modernizacion              (Fase 1 - api-admin)
      ├── feature/admin-schema-jerarquia           (Fase 2 - api-admin)
      ├── feature/admin-dominio-jerarquia          (Fase 3 - api-admin)
      ├── feature/admin-services-jerarquia         (Fase 4 - api-admin)
      ├── feature/admin-api-jerarquia              (Fase 5 - api-admin)
      ├── feature/admin-tests                      (Fase 6 - api-admin)
      └── feature/admin-cicd                       (Fase 7 - api-admin)
```

### PRS Propuestos (Atómicos)

| PR # | Título | Fases | Base | Target | Compilable |
|------|--------|-------|------|--------|------------|
| PR-1 | Migrar bootstrap y testcontainers a shared | Fase 0 | dev | dev | ✅ |
| PR-2 | Modernizar arquitectura api-admin | Fase 1 | dev | dev | ✅ |
| PR-3 | Implementar schema jerarquía + dominio | Fase 2-3 | dev | dev | ✅ |
| PR-4 | Implementar services + API jerarquía | Fase 4-5 | dev | dev | ✅ |
| PR-5 | Agregar tests + CI/CD | Fase 6-7 | dev | dev | ✅ |

**Cada PR:**
- ✅ Compila sin errores
- ✅ Tests pasan
- ✅ Linting sin errores
- ✅ Revisable independientemente

---

## 📚 DOCUMENTOS DEL SPEC

Este PRD es parte de un conjunto de documentos:

| Documento | Propósito |
|-----------|-----------|
| **PRD.md** (este) | Product Requirements Document |
| **USER_STORIES.md** | Historias de usuario con criterios de aceptación |
| **DESIGN.md** | Diseño técnico detallado (arquitectura, clases, flujos) |
| **API_SPEC.md** | Especificación completa de endpoints REST |
| **TASKS.md** | Plan de tareas con fases atómicas y checkboxes |
| **MEJORAS_SHARED.md** | Plan de migración de código a shared |
| **DEV_ENV_UPDATES.md** | Actualizaciones necesarias en dev-environment |

---

## 🎯 DEFINICIÓN DE DONE

Un sprint se considera **DONE** cuando:
- [ ] Todos los checkboxes de `TASKS.md` están ✅
- [ ] Todos los PRs mergeados a `dev`
- [ ] Todos los criterios de aceptación cumplidos
- [ ] Tests >80% coverage
- [ ] CI/CD pasando
- [ ] Documentación actualizada
- [ ] Code review completado
- [ ] Deployed a dev y validado manualmente

---

## 📞 COMUNICACIÓN

### Daily Standups (Sugerido)
- ¿Qué hice ayer?
- ¿Qué haré hoy?
- ¿Tengo bloqueadores?

### Revisión de PRs
- Reviewer: Tech Lead
- Tiempo máximo de review: 24 horas
- Aprobar: 1 aprobación mínima

---

**Próximo paso:** Revisar documentos complementarios del spec

---

**Generado con** 🤖 Claude Code
