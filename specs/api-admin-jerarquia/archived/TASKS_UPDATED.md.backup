# Plan de Tareas - api-administracion Jerarquía Académica

**Proyecto:** edugo-api-administracion  
**Epic:** Modernización + Jerarquía Académica  
**Fecha Inicio:** 12 de Noviembre, 2025  
**Duración Estimada:** 26 días (~5.5 semanas)  
**⚠️ ACTUALIZADO:** Plan ajustado con Fase 0.1 (refactorización bootstrap)

---

## 📋 ÍNDICE DE FASES (ACTUALIZADO)

| Fase | Nombre | Duración | Compilable | PR | Status |
|------|--------|----------|------------|-----|--------|
| [Fase 0.1](#fase-01) | **Refactorizar Bootstrap Genérico** | **2 días** | ✅ | **PR-0.1** | 🆕 **NUEVO** |
| [Fase 0.2](#fase-02) | Migrar api-mobile a shared | 1 día | ✅ | PR-0.2 | 🔄 **AJUSTADO** |
| [Fase 1](#fase-1) | Modernizar arquitectura | 5 días | ✅ | PR-1 | ✅ Original |
| [Fase 2](#fase-2) | Schema BD jerarquía | 2 días | ✅ | PR-2 | ✅ Original |
| [Fase 3](#fase-3) | Dominio jerarquía | 3 días | ✅ | PR-2 | ✅ Original |
| [Fase 4](#fase-4) | Services jerarquía | 3 días | ✅ | PR-3 | ✅ Original |
| [Fase 5](#fase-5) | API REST jerarquía | 4 días | ✅ | PR-3 | ✅ Original |
| [Fase 6](#fase-6) | Testing completo | 3 días | ✅ | PR-4 | ✅ Original |
| [Fase 7](#fase-7) | CI/CD | 1 día | ✅ | PR-4 | ✅ Original |

**Total:** 9 fases, 5-6 PRs, **26 días** (+2 días vs plan original)

---

## 🆕 FASE 0.1: Refactorizar Bootstrap Genérico (NUEVA)

**Proyecto:** `edugo-shared`  
**Branch:** `feature/shared-bootstrap-migration`  
**Duración:** 2 días (1.5-2 días)  
**Precedentes:** Ninguno  
**PR:** PR-0.1 → `shared/dev`  
**Documento Detallado:** [FASE_0.1_PLAN.md](./FASE_0.1_PLAN.md)

### 🎯 Contexto

Durante ejecución de Fase 0 original se descubrió que el `bootstrap` de api-mobile tiene **dependencias fuertemente acopladas** (config, database, s3, rabbitmq específicos). No es posible migración simple "copiar y renombrar".

**Solución:** Refactorización completa para crear componentes genéricos reutilizables.

### Objetivo

Crear en `edugo-shared`:
1. ✅ Config base reutilizable (`shared/config/`)
2. ✅ Lifecycle manager genérico (`shared/lifecycle/`)
3. ✅ Interfaces bootstrap (`shared/bootstrap/`)
4. ✅ Testcontainers helpers (`shared/testing/containers/`)
5. ✅ Implementaciones noop (`shared/bootstrap/noop/`)

---

### Etapa 1: Config Base (4 horas)

- [ ] **T0.1.1** Crear `shared/config/base.go` con BaseConfig struct
- [ ] **T0.1.2** Crear `shared/config/loader.go` con Viper loader
- [ ] **T0.1.3** Crear `shared/config/validator.go` con validator
- [ ] **T0.1.4** Crear tests unitarios para config/
- [ ] **T0.1.5** Compilar: `go build ./config/...`
- [ ] **T0.1.6** Tests: `go test ./config/... -v`

**Checkpoint:** Config base compila y tests pasan ✅

---

### Etapa 2: Lifecycle Manager (2 horas)

- [ ] **T0.1.7** Crear `shared/lifecycle/manager.go`
- [ ] **T0.1.8** Implementar Register, Cleanup, Startup
- [ ] **T0.1.9** Crear `shared/lifecycle/manager_test.go`
- [ ] **T0.1.10** Compilar: `go build ./lifecycle/...`
- [ ] **T0.1.11** Tests: `go test ./lifecycle/... -v`

**Checkpoint:** Lifecycle manager funcional ✅

---

### Etapa 3: Factories Genéricos (3 horas)

- [ ] **T0.1.12** Crear `shared/bootstrap/interfaces.go` (LoggerFactory, PostgreSQLFactory, etc.)
- [ ] **T0.1.13** Crear `shared/bootstrap/resources.go` (Resources struct)
- [ ] **T0.1.14** Crear `shared/bootstrap/options.go` (BootstrapOptions, opciones funcionales)
- [ ] **T0.1.15** Compilar: `go build ./bootstrap/...`

**Checkpoint:** Interfaces bootstrap listas ✅

---

### Etapa 4: Testcontainers Helpers (3 horas)

- [ ] **T0.1.16** Crear `shared/testing/containers/postgres.go`
  - NewPostgresContainer, ConnectionString, Cleanup
- [ ] **T0.1.17** Crear `shared/testing/containers/mongodb.go`
  - NewMongoDBContainer, ConnectionString, Cleanup
- [ ] **T0.1.18** Crear `shared/testing/containers/rabbitmq.go`
  - NewRabbitMQContainer, ConnectionString, Cleanup
- [ ] **T0.1.19** Crear tests para cada helper
- [ ] **T0.1.20** Ejecutar tests: `go test ./testing/containers/... -v`

**Checkpoint:** Testcontainers helpers funcionales ✅

---

### Etapa 5: Implementaciones Noop (1 hora)

- [ ] **T0.1.21** Crear `shared/bootstrap/noop/publisher.go`
- [ ] **T0.1.22** Crear `shared/bootstrap/noop/storage.go`
- [ ] **T0.1.23** Compilar: `go build ./bootstrap/noop/...`

**Checkpoint:** Noops listos ✅

---

### Etapa 6: Integración Final (1 hora)

- [ ] **T0.1.24** Actualizar `shared/go.mod` con dependencias:
  ```bash
  go get github.com/spf13/viper@latest
  go get github.com/go-playground/validator/v10@latest
  go get github.com/testcontainers/testcontainers-go@latest
  go mod tidy
  ```
- [ ] **T0.1.25** Compilar todo: `go build ./...`
- [ ] **T0.1.26** Tests completos: `go test ./... -v`
- [ ] **T0.1.27** Linting: `golangci-lint run`
- [ ] **T0.1.28** Coverage: `go test ./... -coverprofile=coverage.out`
- [ ] **T0.1.29** Commit: "feat(shared): add generic bootstrap components"
- [ ] **T0.1.30** Push: `git push origin feature/shared-bootstrap-migration`
- [ ] **T0.1.31** Crear PR-0.1: `feature/shared-bootstrap-migration` → `shared/dev`
- [ ] **T0.1.32** Esperar CI/CD (máx 5 min)
- [ ] **T0.1.33** Resolver comentarios de Copilot si aplica
- [ ] **T0.1.34** Merge PR-0.1

**Entregable Fase 0.1:** Componentes genéricos en shared ✅

**⚠️ BLOQUEANTE:** Fase 0.2 requiere que PR-0.1 esté mergeado.

---

## 🔄 FASE 0.2: Migrar api-mobile a Shared (AJUSTADA)

**Proyecto:** `edugo-api-mobile`  
**Branch:** `feature/mobile-use-shared-bootstrap`  
**Duración:** 1 día  
**Precedentes:** ✅ Fase 0.1 completada (shared con componentes genéricos)  
**PR:** PR-0.2 → `api-mobile/dev`

### Objetivo

Actualizar api-mobile para usar los nuevos componentes de shared.

---

### Día 1: Actualización api-mobile

- [ ] **T0.2.1** Crear rama en api-mobile: `feature/mobile-use-shared-bootstrap`
- [ ] **T0.2.2** Actualizar `go.mod`:
  ```bash
  go get github.com/EduGoGroup/edugo-shared/config@latest
  go get github.com/EduGoGroup/edugo-shared/lifecycle@latest
  go get github.com/EduGoGroup/edugo-shared/bootstrap@latest
  go get github.com/EduGoGroup/edugo-shared/testing@latest
  go mod tidy
  ```
- [ ] **T0.2.3** Refactorizar `internal/bootstrap/bootstrap.go`:
  - Importar `shared/lifecycle` en lugar de lifecycle local
  - Usar `shared/bootstrap` interfaces
- [ ] **T0.2.4** Refactorizar `internal/config/config.go`:
  - Embeber `shared/config.BaseConfig`
  - Agregar campos específicos de api-mobile
- [ ] **T0.2.5** Actualizar factories para implementar interfaces de shared
- [ ] **T0.2.6** Actualizar tests de integración:
  - Usar `shared/testing/containers/` helpers
- [ ] **T0.2.7** Compilar: `make build`
- [ ] **T0.2.8** Tests: `make test`
- [ ] **T0.2.9** Ejecutar localmente: `make run`
- [ ] **T0.2.10** Verificar health check: `curl localhost:8080/health`
- [ ] **T0.2.11** Commit: "refactor: use shared bootstrap components"
- [ ] **T0.2.12** Push y crear PR-0.2
- [ ] **T0.2.13** Esperar CI/CD y merge

**Entregable Fase 0.2:** api-mobile usa shared ✅

**⚠️ BLOQUEANTE:** Fase 1 requiere que PR-0.2 esté mergeado.

---

## 🏗️ FASE 1: Modernizar Arquitectura de api-admin (SIN CAMBIOS)

**Proyecto:** `edugo-api-administracion`  
**Branch:** `feature/admin-modernizacion`  
**Duración:** 5 días  
**Precedentes:** ✅ Fase 0.1 y 0.2 completadas  
**PR:** PR-1 → `api-admin/dev`

### Objetivo

Migrar arquitectura de api-admin desde código legacy a Clean Architecture moderna, usando patrón de api-mobile y componentes de shared.

---

### Día 1: Setup Inicial

- [ ] **T1.1.1** Verificar rama `dev` en api-admin (sino crearla desde main)
- [ ] **T1.1.2** Crear rama `feature/admin-modernizacion` desde `dev`
- [ ] **T1.1.3** Actualizar `go.mod` con nuevas versiones de `shared`
  ```bash
  go get github.com/EduGoGroup/edugo-shared/bootstrap@latest
  go get github.com/EduGoGroup/edugo-shared/config@latest
  go get github.com/EduGoGroup/edugo-shared/lifecycle@latest
  go get github.com/EduGoGroup/edugo-shared/testing@latest
  ```
- [ ] **T1.1.4** Ejecutar `go mod tidy`
- [ ] **T1.1.5** Compilar para verificar: `go build ./...`

**Checkpoint:** Proyecto compila con shared actualizado ✅

_(Resto de Fase 1-7 continúan sin cambios)_

---

## 📊 RESUMEN DE CAMBIOS

### Lo Que Cambió

| Aspecto | Original | Actualizado | Razón |
|---------|----------|-------------|-------|
| **Total Fases** | 8 | 9 | +Fase 0.1 (refactorización) |
| **Duración Total** | 24 días | 26 días | +2 días para refactorización |
| **Fase 0** | 3 días (1 fase) | 3 días (2 fases: 0.1 + 0.2) | Split por complejidad |
| **PRs** | 4-5 | 5-6 | +1 PR para shared refactorizado |

### Lo Que NO Cambió

- ✅ Fases 1-7 mantienen estructura original
- ✅ Arquitectura objetivo sigue siendo la misma
- ✅ Alcance funcional sin cambios
- ✅ Criterios de éxito iguales

---

## 🎯 PRÓXIMA ACCIÓN

**Iniciar Fase 0.1 - Etapa 1: Config Base**

Ver detalles completos en: [FASE_0.1_PLAN.md](./FASE_0.1_PLAN.md)

---

**Última actualización:** 12 de Noviembre, 2025 20:30  
**Generado con:** Claude Code
