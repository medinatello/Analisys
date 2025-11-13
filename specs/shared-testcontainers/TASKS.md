# Plan de Tareas: Módulo Testing

**Duración Total:** 8 días  
**Complejidad:** Media-Alta  
**Dependencias:** testcontainers-go, Docker

---

## 📋 FASE 1: Módulo shared/testing (3 días)

**Proyecto:** edugo-shared  
**Branch:** feature/testing-module  
**PR:** → shared/dev → shared/main  
**Release:** v0.6.0

### Día 1: Estructura + Manager + PostgreSQL

- [ ] **T1.1** Crear rama `feature/testing-module` desde dev
- [ ] **T1.2** Crear estructura `testing/containers/`
- [ ] **T1.3** Implementar `manager.go`:
  - Manager struct
  - Singleton con sync.Once
  - GetManager()
  - Cleanup()
- [ ] **T1.4** Implementar `options.go`:
  - Config struct
  - ConfigBuilder con métodos With*
  - Defaults sensatos
- [ ] **T1.5** Implementar `postgres.go`:
  - PostgresContainer wrapper
  - createPostgres() con retry
  - ConnectionString()
  - DB() helper
  - Truncate() helper
- [ ] **T1.6** Tests básicos del manager
- [ ] **T1.7** Commit: "feat(testing): add containers manager and PostgreSQL"

**Checkpoint:** PostgreSQL container funcional ✅

### Día 2: MongoDB + RabbitMQ + Helpers

- [ ] **T2.1** Implementar `mongodb.go`:
  - MongoDBContainer wrapper
  - createMongoDB()
  - Database() helper
  - DropCollections() helper
- [ ] **T2.2** Implementar `rabbitmq.go`:
  - RabbitMQContainer wrapper
  - createRabbitMQ()
  - Channel() helper
- [ ] **T2.3** Implementar `helpers.go`:
  - ConnectWithRetry()
  - ExecSQLFile()
  - WaitForHealthy()
- [ ] **T2.4** Tests de MongoDB y RabbitMQ
- [ ] **T2.5** Commit: "feat(testing): add MongoDB and RabbitMQ containers"

**Checkpoint:** Todos los containers funcionales ✅

### Día 3: Tests + Docs + Release

- [ ] **T3.1** Tests completos del módulo:
  - manager_test.go
  - postgres_test.go
  - mongodb_test.go
  - rabbitmq_test.go
- [ ] **T3.2** Verificar coverage >70%
- [ ] **T3.3** Crear README.md del módulo con ejemplos
- [ ] **T3.4** Actualizar go.mod (testcontainers-go dependency)
- [ ] **T3.5** Commit: "test(testing): add comprehensive tests"
- [ ] **T3.6** PR a shared/dev
- [ ] **T3.7** Esperar CI/CD y mergear
- [ ] **T3.8** PR dev → main
- [ ] **T3.9** Mergear a main
- [ ] **T3.10** Release testing/v0.6.0

**Entregable Fase 1:** Módulo shared/testing v0.6.0 ✅

---

## 📋 FASE 2: Migración de Proyectos (3 días)

### Día 4: api-mobile

**Proyecto:** edugo-api-mobile  
**Branch:** feature/use-shared-testing  
**PR:** → dev

- [ ] **T4.1** Crear rama desde dev
- [ ] **T4.2** Actualizar go.mod: `go get github.com/EduGoGroup/edugo-shared/testing@v0.6.0`
- [ ] **T4.3** Refactorizar `test/integration/main_test.go`:
  - Usar shared/testing
  - Eliminar shared_containers.go (~193 LOC)
- [ ] **T4.4** Actualizar tests para usar nuevo API:
  - assessment_flow_test.go
  - auth_flow_test.go
  - material_flow_test.go
  - progress_stats_flow_test.go
- [ ] **T4.5** Ejecutar tests: `go test -tags=integration ./test/integration/`
- [ ] **T4.6** Verificar que todos pasan
- [ ] **T4.7** Commit y PR
- [ ] **T4.8** Mergear a dev

**Checkpoint:** api-mobile usa shared/testing ✅

### Día 5: api-administracion

**Proyecto:** edugo-api-administracion  
**Branch:** feature/use-shared-testing  
**PR:** → dev

- [ ] **T5.1** Crear rama desde dev
- [ ] **T5.2** Actualizar go.mod: shared/testing@v0.6.0
- [ ] **T5.3** Refactorizar `test/integration/setup.go`:
  - Usar shared/testing
  - Solo PostgreSQL
  - Configurar InitScripts para migraciones
- [ ] **T5.4** Eliminar código duplicado (~100 LOC)
- [ ] **T5.5** Ejecutar tests
- [ ] **T5.6** Commit y PR
- [ ] **T5.7** Mergear a dev

**Checkpoint:** api-admin usa shared/testing ✅

### Día 6: worker

**Proyecto:** edugo-worker  
**Branch:** feature/integration-tests  
**PR:** → dev

- [ ] **T6.1** Crear rama desde dev
- [ ] **T6.2** Actualizar go.mod: shared/testing@v0.6.0
- [ ] **T6.3** Crear `test/integration/main_test.go`:
  - PostgreSQL + MongoDB + RabbitMQ
  - Setup con shared/testing
- [ ] **T6.4** Crear primer test: `processor_test.go`:
  - Test de procesamiento de eventos
  - Verificar escritura a MongoDB
- [ ] **T6.5** Ejecutar tests
- [ ] **T6.6** Commit y PR
- [ ] **T6.7** Mergear a dev

**Checkpoint:** worker tiene tests de integración ✅

---

## 📋 FASE 3: dev-environment (2 días)

**Proyecto:** edugo-dev-environment  
**Branch:** feature/profiles-and-seeds  
**PR:** → main (no tiene dev)

### Día 7: Docker Profiles + Scripts

- [ ] **T7.1** Crear rama desde main
- [ ] **T7.2** Actualizar `docker/docker-compose.yml`:
  - Agregar profiles a cada servicio
  - Profiles: full, db-only, api-only, mobile-only, admin-only, worker-only
- [ ] **T7.3** Actualizar `scripts/setup.sh`:
  - Aceptar parámetro --profile
  - Aceptar parámetro --seed
  - Logging mejorado
- [ ] **T7.4** Crear `scripts/seed-data.sh`:
  - Cargar seeds en PostgreSQL
  - Cargar seeds en MongoDB
- [ ] **T7.5** Crear `scripts/stop.sh`:
  - Detener por perfil
- [ ] **T7.6** Commit: "feat: add docker-compose profiles and improved scripts"

**Checkpoint:** Profiles funcionales ✅

### Día 8: Seeds + Documentación

- [ ] **T8.1** Crear `seeds/postgresql/`:
  - 01_schools.sql (5 escuelas)
  - 02_users.sql (50 usuarios: 5 admins, 15 teachers, 30 students)
  - 03_academic_units.sql (jerarquía de 3 escuelas)
  - 04_subjects.sql (10 materias)
  - 05_materials.sql (20 materiales)
  - 06_memberships.sql (asignaciones)
- [ ] **T8.2** Crear `seeds/mongodb/`:
  - material_summaries.js (10 resúmenes)
  - assessment_results.js (20 resultados)
- [ ] **T8.3** Actualizar `README.md`:
  - Guía de perfiles
  - Ejemplos de uso
  - Troubleshooting
- [ ] **T8.4** Crear `docs/PROFILES.md`:
  - Descripción de cada perfil
  - Cuándo usar cada uno
  - Recursos consumidos
- [ ] **T8.5** Commit: "feat: add data seeds and documentation"
- [ ] **T8.6** PR a main
- [ ] **T8.7** Mergear

**Entregable Fase 3:** dev-environment con profiles y seeds ✅

---

## 📊 Resumen de Entregas

| Fase | Proyecto | Entregables | LOC |
|------|----------|-------------|-----|
| 1 | shared | Módulo testing | +600 |
| 2 | api-mobile | Migración | -163 |
| 2 | api-admin | Migración | -100 |
| 2 | worker | Tests nuevos | +100 |
| 3 | dev-environment | Profiles + seeds | +400 |

**Neto:** +837 LOC (pero elimina 263 de duplicación)

---

## ⚠️ Dependencias Entre Fases

```
FASE 1 (shared/testing)
    ↓
FASE 2 (migraciones)
    ├── api-mobile
    ├── api-admin
    └── worker
    ↓
FASE 3 (dev-environment)
```

**Bloqueante:** FASE 2 requiere FASE 1 completada

---

## 🎯 Criterios de Aceptación Global

- ✅ Módulo shared/testing publicado en v0.6.0
- ✅ 3 proyectos usando el módulo
- ✅ Tests de integración pasando en todos
- ✅ Reducción de duplicación >80%
- ✅ dev-environment con 6 perfiles
- ✅ Seeds de datos disponibles
- ✅ Documentación completa

---

**Plan de Tareas Completado** ✅  
**Próximo:** RULES.md

