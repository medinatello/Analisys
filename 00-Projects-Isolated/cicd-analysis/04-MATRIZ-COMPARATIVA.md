# Matriz Comparativa de Workflows - Ecosistema EduGo

**Fecha:** 19 de Noviembre, 2025

---

## 📊 Comparativa por Proyecto

### Workflows Existentes

| Workflow | api-mobile | api-admin | worker | shared | infrastructure | dev-env |
|----------|------------|-----------|--------|--------|----------------|---------|
| **PR to Dev** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **PR to Main** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **CI Generic** | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ |
| **Tests Manual** | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Manual Release** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Auto Release** | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Build Docker Manual** | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Build Docker Auto** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Sync Main→Dev** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **TOTAL** | **5** | **7** | **7** | **4** | **2** | **0** |

---

## 🔧 Tecnología y Versiones

| Aspecto | api-mobile | api-admin | worker | shared | infrastructure |
|---------|------------|-----------|--------|--------|----------------|
| **Go Version** | 1.24 | 1.24 | **1.25** ⚠️ | 1.25 | 1.24 |
| **actions/checkout** | v4 | v4 | v4 | v4 | **v5** ⚠️ |
| **actions/setup-go** | v5 | v5 | v5 | v5 | **v6** ⚠️ |
| **golangci-lint** | v1.64.7 | v1.64.7 | Dinámico | Dinámico | N/A |
| **Docker Build** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Platforms** | amd64, arm64 | amd64, arm64 | amd64 | N/A | N/A |

**⚠️ INCONSISTENCIAS:**
- Worker usa Go 1.25 mientras apis usan 1.24
- Infrastructure usa actions más recientes

---

## 🧪 Estrategias de Testing

| Característica | api-mobile | api-admin | worker | shared | infrastructure |
|----------------|------------|-----------|--------|--------|----------------|
| **Unit Tests** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Integration Tests** | ✅ Testcontainers | ❌ | ❌ | ❌ | ⚠️ Solo local |
| **Coverage Threshold** | 33% | 33% | ❌ No | ❌ No | ❌ N/A |
| **Coverage Enforced** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Coverage Report** | ✅ PR comment | ✅ PR comment | ⚠️ Opcional | ✅ Por módulo | ❌ |
| **Lint** | ✅ golangci-lint | ✅ golangci-lint | ⚠️ continue-on-error | ⚠️ continue-on-error | ❌ |
| **Security Scan** | ✅ Gosec (PR→main) | ❌ | ❌ | ❌ | ❌ |
| **Race Detection** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Matrix Testing** | ❌ | ❌ | ❌ | ✅ 7 módulos | ✅ 4 módulos |
| **Go Compat Matrix** | ❌ | ❌ | ❌ | ✅ 1.23-1.25 | ❌ |

**✅ MEJOR PRÁCTICA:** api-mobile (más completo)
**⚠️ DEBILIDAD:** worker sin threshold de cobertura

---

## 🐳 Estrategias de Docker

| Aspecto | api-mobile | api-admin | worker |
|---------|------------|-----------|--------|
| **Workflows que construyen** | 1 | **2** ⚠️ | **3** 🔴 |
| **Trigger Manual** | ✅ manual-release | ✅ build-and-push | ✅ build-and-push |
| **Trigger Auto Tag** | ❌ | ✅ release.yml | ✅ release.yml |
| **Trigger Push Main** | ❌ | ❌ | ✅ build-and-push |
| **Trigger Misterioso** | ❌ | ❌ | ✅ docker-only.yml |
| **Multi-platform** | ✅ amd64, arm64 | ✅ amd64, arm64 | ⚠️ Solo release |
| **Registry** | ghcr.io | ghcr.io | ghcr.io |
| **Tags latest** | ✅ | ✅ | ✅ (múltiples) |
| **Tags semver** | ✅ | ✅ | ✅ |
| **Tags SHA** | ❌ | ✅ | ✅ |
| **Tags environment** | ❌ | ✅ | ✅ |
| **Tags branch** | ❌ | ❌ | ✅ |
| **Tags production** | ❌ | ✅ | ❌ |

**🔴 PROBLEMA CRÍTICO:** Worker con 3 workflows creando imágenes Docker
**⚠️ PROBLEMA:** api-admin con 2 workflows (duplicación)
**✅ CORRECTO:** api-mobile con 1 solo workflow

---

## 📦 Estrategias de Release

| Característica | api-mobile | api-admin | worker | shared |
|----------------|------------|-----------|--------|--------|
| **Tipo** | Manual | Manual + Auto | Manual + Auto | Auto |
| **Manual desde** | UI (workflow_dispatch) | UI | UI | ❌ |
| **Auto trigger** | ❌ | Tag v* | Tag v* | Tag v* |
| **Actualiza version.txt** | ✅ | ✅ | ❌ | ❌ |
| **Actualiza CHANGELOG** | ✅ | ✅ | ✅ | ✅ |
| **Crea GitHub Release** | ✅ | ✅ | ✅ | ✅ |
| **Build Docker** | ✅ | ✅ | ✅ | ❌ |
| **Sube binarios** | ❌ | ✅ | ❌ | ❌ |
| **Tests pre-release** | ✅ | ✅ | ✅ | ✅ |
| **GitHub App Token** | ✅ | ❌ | ❌ | ❌ |
| **Dispara sync auto** | ✅ | ❌ | ❌ | ❌ |

**✅ MEJOR:** api-mobile (usa GitHub App para trigger subsecuente)
**⚠️ INCONSISTENCIA:** Solo api-mobile dispara sync automáticamente

---

## 🔄 Sincronización de Ramas

| Aspecto | Todos los Proyectos |
|---------|---------------------|
| **Workflow** | sync-main-to-dev.yml |
| **Código** | **96% idéntico** |
| **Trigger** | Push a main, Push tag v* |
| **Verifica existencia dev** | ✅ |
| **Crea dev si falta** | ✅ |
| **Manejo de conflictos** | ⚠️ Abort + fail |
| **GitHub App token** | ❌ (solo en api-mobile release) |

**🎯 OPORTUNIDAD:** Candidato perfecto para workflow reusable

---

## 📝 Comentarios y Documentación

| Proyecto | Comentarios en Workflows | Documentación Externa |
|----------|-------------------------|----------------------|
| api-mobile | ✅ Excelente | ⚠️ README básico |
| api-admin | ⚠️ Mínimos | ⚠️ README básico |
| worker | ⚠️ Mínimos | ❌ Falta |
| shared | ✅ Muy buenos | ✅ README completo |
| infrastructure | ⚠️ Mínimos | ⚠️ En progreso |

**EJEMPLOS DE BUENOS COMENTARIOS:**

**api-mobile - manual-release.yml:**
```yaml
# Usar GitHub App Token en lugar de GITHUB_TOKEN porque:
# - GITHUB_TOKEN NO dispara workflows subsecuentes
# - App Token SÍ dispara sync-main-to-dev.yml automáticamente
```

**shared - test.yml:**
```yaml
# IMPORTANTE: Este workflow NO se ejecuta en push (solo PRs y manual)
# Los "errores" en push son esperados
```

---

## ⏱️ Tiempos de Ejecución (Estimados)

| Workflow | api-mobile | api-admin | worker | shared |
|----------|------------|-----------|--------|--------|
| **PR to Dev** | ~2 min | ~2 min | ~3 min | ~8 min (matriz) |
| **PR to Main** | ~5 min | N/A | N/A | ~8 min |
| **Manual Release** | ~8 min | ~10 min | ~8 min | N/A |
| **Auto Release** | N/A | ~10 min | ~8 min | ~15 min (matriz) |

**Nota:** Tiempos aproximados basados en estructura de workflows.

---

## 🚨 Salud de CI/CD (Últimas 10 Ejecuciones)

| Proyecto | Success Rate | Fallos Recientes | Estado |
|----------|-------------|------------------|--------|
| api-mobile | 90% (9/10) | 1 sync temporal | ✅ Saludable |
| api-admin | 40% (4/10) | 6 release failures | 🔴 Crítico |
| worker | 70% (7/10) | 3 release failures | ⚠️ Atención |
| shared | 100% (10/10) | 0 (falsos positivos) | ✅ Excelente |
| infrastructure | 20% (2/10) | 8 CI failures | 🔴 Crítico |

**🔴 ALERTA:** api-admin e infrastructure requieren atención inmediata

---

## 📈 Métricas de Complejidad

| Proyecto | # Workflows | # Jobs Total | # Steps Total | Líneas Totales |
|----------|-------------|--------------|---------------|----------------|
| api-mobile | 5 | 15 | ~80 | ~800 |
| api-admin | 7 | 20 | ~100 | ~1,000 |
| worker | 7 | 18 | ~90 | ~950 |
| shared | 4 | 30 (matriz) | ~120 | ~900 |
| infrastructure | 2 | 8 | ~40 | ~200 |
| **TOTAL** | **25** | **91** | **~430** | **~3,850** |

**Duplicación estimada:** ~1,300 líneas (34%)

---

## 🎯 Estandarización Recomendada

### Nivel 1: Configuración Base (Todos)

```yaml
env:
  GO_VERSION: "1.25"  # ← Estandarizar
  REGISTRY: ghcr.io
  COVERAGE_THRESHOLD: 33  # Para Tipo A
```

### Nivel 2: Acciones Comunes (Todos)

```yaml
- uses: actions/checkout@v4
- uses: actions/setup-go@v5
- uses: docker/setup-buildx-action@v3
- uses: docker/login-action@v3
- uses: docker/build-push-action@v5
```

### Nivel 3: Workflows (Por Tipo)

**Tipo A (APIs, Worker):**
```
✅ Mantener: pr-to-dev.yml, pr-to-main.yml
✅ Mantener: manual-release.yml
❌ Eliminar: build-and-push.yml duplicados
❌ Eliminar: release.yml auto (o manual, elegir UNO)
✅ Mantener: sync-main-to-dev.yml (migrar a reusable)
```

**Tipo B (Shared, Infrastructure):**
```
✅ Mantener: ci.yml
✅ Mantener: test.yml (opcional)
✅ Mantener: release.yml (si aplica)
✅ Mantener: sync-main-to-dev.yml (migrar a reusable)
```

---

## 🏆 Ranking de Calidad

### 1. 🥇 shared (Excelente)
- ✅ Estrategia modular bien implementada
- ✅ 100% success rate
- ✅ Buenos comentarios
- ✅ Matrix testing para compatibilidad
- ⚠️ Mejorar: Agregar coverage thresholds

### 2. 🥈 api-mobile (Muy Bueno)
- ✅ Workflows completos y bien estructurados
- ✅ GitHub App token implementado
- ✅ Tests de integración
- ✅ Security scan
- ⚠️ Mejorar: Usar workflows reusables

### 3. 🥉 api-admin (Regular)
- ⚠️ Workflows duplicados (2 para Docker)
- 🔴 40% failure rate (crítico)
- ⚠️ Falta PR to main
- ✅ Tiene tests y coverage
- 🔴 Mejorar: Resolver fallos urgente

### 4. worker (Regular)
- 🔴 3 workflows Docker (crítico)
- ⚠️ 70% success rate
- ⚠️ Go 1.25 (desviación)
- ⚠️ Sin coverage threshold
- 🔴 Mejorar: Consolidar Docker builds

### 5. infrastructure (Crítico)
- 🔴 20% success rate (crítico)
- 🔴 Fallos consecutivos sin resolver
- ⚠️ Tests integración solo locales
- ⚠️ Versiones de actions desviadas
- 🔴 Mejorar: Resolver fallos URGENTE

---

## 📋 Recomendaciones por Proyecto

### api-mobile
1. ✅ Migrar a workflows reusables (piloto)
2. ✅ Documentar estrategia de release
3. ⚠️ Considerar matrix para Go versions

### api-administracion
1. 🔴 **URGENTE:** Investigar y resolver fallos en release.yml
2. 🔴 Eliminar build-and-push.yml duplicado
3. ✅ Agregar pr-to-main.yml
4. ✅ Implementar GitHub App token

### worker
1. 🔴 **URGENTE:** Consolidar 3 workflows Docker en 1
2. 🔴 Decidir: Go 1.25 o volver a 1.24
3. ✅ Agregar coverage threshold
4. ✅ Mejorar documentación de workflows
5. ✅ Implementar GitHub App token

### shared
1. ✅ Agregar coverage thresholds por módulo
2. ✅ Resolver "fallos fantasma" en test.yml
3. ✅ Considerar ser el hogar de workflows reusables

### infrastructure
1. 🔴 **CRÍTICO:** Resolver fallos en CI (prioridad máxima)
2. ✅ Estandarizar versions de actions con otros proyectos
3. ✅ Crear workflows reusables centralizados
4. ✅ Agregar validación sintaxis SQL

---

## 🔮 Estado Deseado

### Workflows por Proyecto (Propuesto)

| Workflow | api-mobile | api-admin | worker | shared | infrastructure |
|----------|------------|-----------|--------|--------|----------------|
| **CI - PR to Dev** | ✅ Reusable | ✅ Reusable | ✅ Reusable | ✅ Custom | ✅ Custom |
| **CI - PR to Main** | ✅ Reusable | ✅ Reusable | ✅ Reusable | ✅ Custom | ❌ |
| **Release** | ✅ Manual | ✅ Manual | ✅ Manual | ✅ Auto | ❌ |
| **Sync** | ✅ Reusable | ✅ Reusable | ✅ Reusable | ✅ Reusable | ✅ Reusable |
| **TOTAL** | **4** | **4** | **4** | **4** | **2** |

**Reducción:** De 25 workflows a 18 workflows + 5 reusables = 23 total (vs 25 actual)
**Beneficio:** Código duplicado de ~1,300 líneas a ~200 líneas

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025
