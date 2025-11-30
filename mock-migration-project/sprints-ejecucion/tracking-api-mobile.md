# Tracking: Migración Mock Repositories - API Mobile

**Fecha de Inicio:** 30 Noviembre 2025
**Proyecto:** Migración de mock repositories stubs a dataset generado automáticamente
**API:** edugo-api-mobile

---

## ⚠️ PREREQUISITO CRÍTICO

✅ **api-administracion DEBE completar Sprints 0-3 ANTES de comenzar api-mobile**

**Validar:** Ver `/Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/tracking-api-admin.md`

**Dependencias:**
- ✅ Generador edugo-mock-generator creado y funcional
- ✅ Dataset.go generado desde SQL testing
- ✅ Variable USE_MOCK_REPOSITORIES estandarizada en api-admin
- ✅ Api-admin funcionando con mocks completos

---

## Resumen Ejecutivo

Este documento rastrea el progreso de la migración de mock repositories en api-mobile, **REUTILIZANDO** el generador ya creado en api-administracion y **AGREGANDO** fixtures para entidades específicas de mobile (MongoDB).

### Contexto Específico de API Mobile

**Estado Actual:**
- ✅ 1/11 repositorios implementado (UserRepository)
- ❌ 10/11 repositorios son stubs vacíos
- Variable actual: DEVELOPMENT_USE_MOCK_REPOSITORIES
- Archivos mock: internal/infrastructure/persistence/mock/postgres/stubs.go
- Archivos mock: internal/infrastructure/persistence/mock/mongodb/stubs.go

**Repositorios a Implementar:**
1. UserRepository (ya funcional)
2. MaterialRepository (stub → implementación con dataset)
3. ProgressRepository (stub → implementación con dataset)
4. RefreshTokenRepository (stub → implementación con dataset)
5. LoginAttemptRepository (stub → implementación con dataset)
6. AssessmentRepository (stub → implementación con dataset + MongoDB)
7. AttemptRepository (stub → implementación con dataset)
8. AnswerRepository (stub → implementación con dataset)
9. SummaryRepository (stub → implementación con MongoDB)
10. LegacyAssessmentRepository (stub → implementación con MongoDB)
11. AssessmentDocumentRepository (stub → implementación con MongoDB)

### Diferencias Clave vs API Admin

| Aspecto | API Admin | API Mobile |
|---------|-----------|------------|
| **Generador** | CREAR | REUTILIZAR |
| **Dataset.go** | Generar primero | Copiar ya generado |
| **PostgreSQL** | 4 repos | 8 repos |
| **MongoDB** | No usa | 3 repos |
| **Fixtures Nuevos** | Solo PostgreSQL | PostgreSQL + MongoDB |
| **Variable** | Migrar a USE_MOCK_REPOSITORIES | De DEVELOPMENT_USE_MOCK |
| **Complejidad** | Media | Alta (MongoDB + más repos) |

---

## Tabla de Progreso General

| Sprint | Descripción | Pasos | Completados | % | Estado | Tiempo |
|--------|-------------|-------|-------------|---|--------|---------|
| Sprint 0 | Preparación | 7 | 0 | 0% | ⏳ Pendiente | 40min |
| Sprint 1 | Reutilizar Generador | 8 | 0 | 0% | 🔒 Bloqueado | 1h30 |
| Sprint 2 | Implementar Fixtures | 18 | 0 | 0% | 🔒 Bloqueado | 5h30 |
| Sprint 3 | Integración API | 15 | 0 | 0% | 🔒 Bloqueado | 3h15 |
| **TOTAL** | **4 sprints** | **48** | **0** | **0%** | **⏳ No Iniciado** | **10h55** |

---

**Primer Paso (cuando api-admin termine):**
→ `/Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-mobile/sprint-0-preparacion/paso-01-validar-api-admin.md`
