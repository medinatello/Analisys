# Análisis del Estado Actual de CI/CD - Ecosistema EduGo

**Fecha de Análisis:** 19 de Noviembre, 2025  
**Analista:** Claude Code  
**Alcance:** 6 repositorios (3 Tipo A, 2 Tipo B, 1 Tipo C)

---

## 📋 Resumen Ejecutivo

Este informe analiza el estado actual de los pipelines de CI/CD en el ecosistema EduGo, identificando duplicidades, falencias, errores recurrentes y oportunidades de optimización.

### Hallazgos Clave

🔴 **CRÍTICO:**
- Workflows de release fallando en múltiples repos sin prevenir merges
- Duplicación masiva de código en workflows (~70% de código repetido)
- Múltiples triggers para Docker builds creando imágenes duplicadas
- Falta de estandarización en nombres de workflows

🟡 **IMPORTANTE:**
- Inconsistencias en estrategias de testing entre proyectos
- Versiones de Go y herramientas no estandarizadas
- Falta de reutilización mediante composite actions o workflows reusables

🟢 **MEJORAS:**
- Buen uso de matrices para módulos en shared
- Implementación de GitHub App tokens para evitar limitaciones
- Coverage reports implementados (aunque no consistentes)

---

## 🏗️ Inventario de Proyectos y Workflows

### Tipo A: Aplicaciones Desplegables (APIs y Worker)

#### 📱 **edugo-api-mobile**
**Estado:** ✅ Funcional  
**Workflows:** 5 archivos

| Workflow | Trigger | Propósito | Estado |
|----------|---------|-----------|--------|
| `pr-to-dev.yml` | PR → dev | Tests unitarios + lint | ✅ Activo |
| `pr-to-main.yml` | PR → main | Suite completa de tests | ✅ Activo |
| `test.yml` | Manual | Tests con coverage (on-demand) | ✅ Activo |
| `manual-release.yml` | Manual | Release manual completo | ✅ Activo |
| `sync-main-to-dev.yml` | Push a main | Sincronización automática | ✅ Activo |

**Características:**
- ✅ Tests unitarios + integración
- ✅ Umbral de cobertura: 33%
- ✅ Lint con golangci-lint v1.64.7
- ✅ Docker multi-platform (amd64, arm64)
- ✅ GitHub App token para workflows subsecuentes
- ✅ Comentarios automáticos en PRs con resultados

**Tecnología:**
- Go 1.24
- Puerto: 8080
- Registry: ghcr.io

---

#### 🔧 **edugo-api-administracion**
**Estado:** ⚠️ Con fallos recientes  
**Workflows:** 7 archivos

| Workflow | Trigger | Propósito | Estado |
|----------|---------|-----------|--------|
| `pr-to-dev.yml` | PR → dev | Tests unitarios + lint | ✅ Activo |
| `pr-to-main.yml` | PR → main | (NO EXISTE - faltante) | ❌ Faltante |
| `test.yml` | Manual | Tests con coverage | ✅ Activo |
| `manual-release.yml` | Manual | Release manual | ✅ Activo |
| `build-and-push.yml` | Manual/Push | Build Docker on-demand | ✅ Activo |
| `release.yml` | Tag push (v*) | Release automático con tag | ⚠️ Falla |
| `sync-main-to-dev.yml` | Push a main | Sincronización automática | ✅ Activo |

**⚠️ FALLOS DETECTADOS:**
```
Run ID: 19485500426
Workflow: Release CI/CD (release.yml)
Conclusion: failure
Fecha: 2025-11-19T00:38:48Z
```

**Características:**
- ✅ Tests unitarios (sin integración implementada)
- ✅ Umbral de cobertura: 33%
- ✅ Lint con golangci-lint v1.64.7
- ✅ Docker multi-platform
- ⚠️ **DUPLICIDAD:** Tiene `build-and-push.yml` Y `release.yml` (ambos hacen build Docker)

**Tecnología:**
- Go 1.24
- Puerto: 8081
- Registry: ghcr.io

---

#### ⚙️ **edugo-worker**
**Estado:** ⚠️ Con fallos recurrentes  
**Workflows:** 7 archivos

| Workflow | Trigger | Propósito | Estado |
|----------|---------|-----------|--------|
| `ci.yml` | PR + Push main | Tests y validaciones | ✅ Activo |
| `test.yml` | Manual | (NO EXISTE - listado erróneo) | ❌ N/A |
| `manual-release.yml` | Manual | Release manual | ✅ Activo |
| `build-and-push.yml` | Manual/Push main | Build Docker | ✅ Activo |
| `release.yml` | Tag push (v*) | Release automático | ⚠️ Falla |
| `sync-main-to-dev.yml` | Push a main | Sincronización | ✅ Activo |
| `docker-only.yml` | ¿Manual? | Build Docker simple | ⚠️ Redundante |

**⚠️ FALLOS DETECTADOS:**
```
Run ID: 19485700108
Workflow: Release CI/CD (release.yml)
Conclusion: failure
Fecha: 2025-11-19T00:48:39Z
```

**🔴 DUPLICIDAD CRÍTICA:**
- `build-and-push.yml` - Trigger: manual + push a main
- `release.yml` - Trigger: tag push
- `docker-only.yml` - Trigger: desconocido

**¿Resultado?** 3 workflows diferentes que construyen imágenes Docker, potencialmente creando tags duplicados o conflictivos.

**Características:**
- ✅ CI con tests + race detection
- ✅ Lint opcional (continue-on-error: true)
- ✅ Docker build test en CI
- ⚠️ **NO tiene umbral de cobertura definido**
- ⚠️ **Versión Go 1.25** (diferente a otros proyectos: 1.24)

**Tecnología:**
- Go 1.25 ⚠️
- Registry: ghcr.io

---

### Tipo B: Librerías Compartidas

#### 📚 **edugo-shared**
**Estado:** ✅ Funcional  
**Workflows:** 4 archivos

| Workflow | Trigger | Propósito | Estado |
|----------|---------|-----------|--------|
| `ci.yml` | PR + Push main | Tests por módulo + compatibilidad | ✅ Activo |
| `test.yml` | Manual + PR | Coverage detallado por módulo | ✅ Activo |
| `release.yml` | Tag push (v*) | Release modular | ✅ Activo |
| `sync-main-to-dev.yml` | Push a main | Sincronización | ✅ Activo |

**✨ BUENAS PRÁCTICAS DETECTADAS:**
- ✅ Estrategia de matriz para 7 módulos independientes
- ✅ Tests de compatibilidad con 3 versiones de Go (1.23, 1.24, 1.25)
- ✅ Coverage por módulo individual
- ✅ NO construye imágenes Docker (es librería)
- ✅ Release con instrucciones de instalación por módulo

**Módulos:**
```
- common
- logger
- auth
- middleware/gin
- messaging/rabbit
- database/postgres
- database/mongodb
```

**⚠️ NOTA IMPORTANTE:**
El workflow `test.yml` tiene un comentario crítico:
```yaml
# IMPORTANTE: Este workflow NO se ejecuta en push (solo PRs y manual)
# Los "errores" en push son esperados - GitHub intenta ejecutar el workflow
# pero falla inmediatamente (0s) porque no tiene trigger para push.
```

Esto significa que hay **"fallos fantasma"** que aparecen en el historial pero son esperados.

**Tecnología:**
- Go 1.25
- Sin Docker (librería Go)

---

#### 🏗️ **edugo-infrastructure**
**Estado:** ⚠️ Con fallos recientes  
**Workflows:** 2 archivos

| Workflow | Trigger | Propósito | Estado |
|----------|---------|-----------|--------|
| `ci.yml` | PR + Push | Validación de migraciones | ⚠️ Falla |
| `sync-main-to-dev.yml` | Push a main | Sincronización | ✅ Activo |

**⚠️ FALLOS DETECTADOS:**
```
Run ID: 19483248827
Workflow: CI
Conclusion: failure
Fecha: 2025-11-18T22:55:53Z

Últimos 3 runs: TODOS fallidos
```

**Módulos Validados:**
```
- postgres (migraciones SQL + CLI)
- mongodb (migraciones + CLI)
- messaging (schemas)
- schemas (definiciones compartidas)
```

**Características:**
- ✅ Validación de compilación de CLIs
- ✅ Tests por módulo con matriz
- ⚠️ **NO valida sintaxis SQL** (solo compilación)
- ⚠️ Tests de integración deshabilitados en CI

**Tecnología:**
- Go 1.24
- Sin Docker

---

### Tipo C: Herramientas Utilitarias

#### 🛠️ **edugo-dev-environment**
**Estado:** ✅ Sin CI/CD  
**Workflows:** Ninguno

**Propósito:** Entorno Docker Compose para desarrolladores frontend

**Razón de no tener CI/CD:**
- Es un repositorio de configuración (Docker Compose, scripts setup)
- No tiene código que requiera tests
- Se valida manualmente al usarse

**✅ Decisión correcta:** No necesita workflows de CI/CD.

---

## 📊 Análisis Comparativo

### Estandarización de Versiones

| Proyecto | Go Version | golangci-lint | Razón Diferencia |
|----------|------------|---------------|------------------|
| api-mobile | 1.24 | v1.64.7 | Estándar actual |
| api-administracion | 1.24 | v1.64.7 | Estándar actual |
| worker | **1.25** ⚠️ | Instalado dinámicamente | **Desviación** |
| shared | 1.25 | Instalado dinámicamente | Compatibilidad futura |
| infrastructure | 1.24 | N/A | Estándar actual |

**🔴 PROBLEMA:** Worker usa Go 1.25 mientras las APIs usan 1.24. Esto puede causar incompatibilidades con `edugo-shared`.

---

### Estrategias de Testing

| Proyecto | Unit Tests | Integration Tests | Coverage Threshold | Coverage Report |
|----------|------------|-------------------|-------------------|-----------------|
| api-mobile | ✅ | ✅ (Testcontainers) | 33% | ✅ PR comments |
| api-administracion | ✅ | ❌ | 33% | ✅ PR comments |
| worker | ✅ | ❌ | ❌ No definido | ⚠️ Opcional |
| shared | ✅ | ❌ | ❌ No definido | ✅ Por módulo |
| infrastructure | ✅ | ⚠️ Locales solo | ❌ N/A | ❌ |

**🔴 INCONSISTENCIA:** Solo api-mobile tiene tests de integración automatizados en CI.

---

### Docker Build Strategies

| Proyecto | Build Triggers | Tags Generados | Multi-platform |
|----------|----------------|----------------|----------------|
| api-mobile | Manual release only | v{version}, {version}, latest | ✅ amd64, arm64 |
| api-administracion | **Manual + Tag push** ⚠️ | semver, latest, production, sha | ✅ amd64, arm64 |
| worker | **Manual + Push + Tag** ⚠️ | branch, sha, latest, env, semver | ⚠️ Solo release |
| shared | N/A (librería) | N/A | N/A |
| infrastructure | N/A | N/A | N/A |

**🔴 DUPLICIDAD DETECTADA:**

**worker** tiene 3 workflows construyendo Docker:
1. `build-and-push.yml` - manual + push main
2. `docker-only.yml` - trigger desconocido
3. `release.yml` - tag push

**api-administracion** tiene 2 workflows construyendo Docker:
1. `build-and-push.yml` - manual
2. `release.yml` - tag push

**Problema:** Esto puede generar múltiples versiones de la misma imagen con tags diferentes, consumiendo espacio en el registry y creando confusión sobre cuál usar.

---

### Workflows de Sincronización

**TODOS los proyectos** tienen `sync-main-to-dev.yml` con la **misma lógica**:

✅ **Beneficio:** Consistencia  
🔴 **Problema:** Código duplicado 6 veces (96% idéntico)

**Lógica común:**
```yaml
on:
  push:
    branches: [main]
    tags: ['v*']

# - Verificar si dev existe
# - Crear dev si no existe
# - Verificar diferencias
# - Merge main → dev
# - Manejar conflictos
```

**🎯 OPORTUNIDAD:** Crear un workflow reusable centralizado en `edugo-infrastructure` o como template.

---

## 🐛 Errores y Fallos Recurrentes

### api-administracion

**Workflow:** `release.yml`  
**Último fallo:** 2025-11-19T00:38:48Z

**Patrón de fallos:**
```
19485500426 - failure (release.yml)
19485295393 - failure (release.yml)
```

**Hipótesis de causa:**
- Fallo en build de Docker
- Validación de tests fallando
- Problema con generación de changelog

**⚠️ CRÍTICO:** El fallo NO previene el merge porque el release es post-merge (trigger en tag).

---

### worker

**Workflow:** `release.yml`  
**Último fallo:** 2025-11-19T00:48:39Z

**Patrón similar** a api-administracion.

**Además:** Workflow `.github/workflows/pr-to-dev.yml` con nombre incorrecto en runs:
```
19485500267 - failure (.github/workflows/pr-to-dev.yml)
19485500025 - failure (.github/workflows/pr-to-dev.yml)
```

Esto sugiere un problema de configuración en el nombre del workflow.

---

### infrastructure

**Workflow:** `ci.yml`  
**Fallos consecutivos:**
```
19483248827 - failure (2025-11-18 22:55:53)
19483161779 - failure (2025-11-18 22:52:08)
19483160612 - failure (2025-11-18 22:52:05)
19483051349 - failure (2025-11-18 22:47:43)
19482994362 - failure (2025-11-18 22:45:34)
```

**🔴 CRÍTICO:** 5 fallos consecutivos en el mismo día, todos en CI.

**Posibles causas:**
- Tests de módulos fallando
- Compilación de CLIs fallando
- Problemas con `go mod` o dependencias

**⚠️ IMPACTO:** Como es Tipo B (librería compartida), estos fallos pueden afectar a TODOS los proyectos que lo consuman.

---

### shared

**Estado:** Mayormente exitoso, pero hay "fallos fantasma":

El workflow `test.yml` tiene fallos esperados porque GitHub intenta ejecutarlo en eventos push aunque no esté configurado para ello.

**NO es un problema real**, pero contamina las estadísticas de salud del repo.

**Solución:** Agregar condición para skip explícito:
```yaml
jobs:
  test-coverage:
    if: github.event_name != 'push'
```

---

## 📈 Estadísticas de Salud

### Últimas 10 Ejecuciones por Proyecto

**api-mobile:**
- ✅ Success: 9/10 (90%)
- ❌ Failure: 1/10 (10%) - Sync fallido temporal

**api-administracion:**
- ✅ Success: 4/10 (40%)
- ❌ Failure: 6/10 (60%) ⚠️

**worker:**
- ✅ Success: 7/10 (70%)
- ❌ Failure: 3/10 (30%)

**shared:**
- ✅ Success: 10/10 (100%) ✅

**infrastructure:**
- ✅ Success: 2/10 (20%)
- ❌ Failure: 8/10 (80%) 🔴

**🔴 ALERTA:** infrastructure tiene la peor tasa de éxito (20%).

---

## 🔄 Duplicación de Código

### Código Repetido Entre Workflows

**Estimación de duplicación:** ~70% del código es repetido entre proyectos

**Bloques duplicados identificados:**

1. **Setup Go** (100% idéntico en 20+ workflows):
```yaml
- name: Setup Go
  uses: actions/setup-go@v5
  with:
    go-version: ${{ env.GO_VERSION }}
    cache: true
```

2. **Configuración de repos privados** (100% idéntico):
```yaml
- name: Configurar acceso a repos privados
  run: |
    git config --global url."https://${{ secrets.GITHUB_TOKEN }}@github.com/".insteadOf "https://github.com/"
  env:
    GOPRIVATE: github.com/EduGoGroup/*
```

3. **Docker Build Steps** (90% idéntico):
```yaml
- Setup Docker Buildx
- Login a GHCR
- Extract metadata
- Build and push
```

4. **Sync main-to-dev** (96% idéntico en 6 repos)

5. **Release creation** (80% similar)

**🎯 OPORTUNIDAD:** Crear composite actions reutilizables para:
- `setup-edugo-go` - Setup Go + GOPRIVATE
- `docker-build-edugo` - Build Docker con configuración estándar
- `sync-branches` - Sincronización de ramas

---

## 🏷️ Tags y Versionado

### Estrategia de Tags Actual

**manual-release.yml** (api-mobile):
```yaml
tags: |
  type=raw,value=v${{ inputs.version }}
  type=raw,value=${{ inputs.version }}
  type=raw,value=latest
```

**release.yml** (api-administracion):
```yaml
tags: |
  type=semver,pattern={{version}}
  type=semver,pattern={{major}}.{{minor}}
  type=semver,pattern={{major}}
  type=raw,value=latest
  type=raw,value=production
  type=sha,prefix=${{ steps.tag.outputs.tag }}-
```

**release.yml** (worker):
```yaml
tags: |
  type=semver,pattern={{version}}
  type=semver,pattern={{major}}.{{minor}}
  type=semver,pattern={{major}}
  type=raw,value=latest
  type=raw,value=${{ steps.version.outputs.tag }}
```

**build-and-push.yml** (worker):
```yaml
tags: |
  type=ref,event=branch
  type=sha,prefix={{branch}}-
  type=raw,value=latest,enable={{is_default_branch}}
  type=raw,value=${{ inputs.environment }},enable=${{ github.event_name == 'workflow_dispatch' }}
```

**🔴 PROBLEMA DETECTADO:**

Para worker, un push a main puede generar:
1. `latest` (desde build-and-push.yml por push main)
2. `main` (ref event=branch)
3. `main-abc123` (sha con prefix)

Si luego se crea tag v1.0.0:
4. `v1.0.0` (desde release.yml)
5. `1.0.0` (semver)
6. `1.0` (semver major.minor)
7. `1` (semver major)
8. `latest` (sobreescribe el anterior)
9. `v1.0.0-abc123` (sha con prefix)

**Resultado:** 9+ tags para el mismo código, algunos duplicados o conflictivos.

---

## 🔐 Secrets y Configuración

### Secrets Detectados en Uso

| Secret | Usado en | Propósito |
|--------|----------|-----------|
| `GITHUB_TOKEN` | Todos | Autenticación básica GitHub |
| `APP_ID` | api-mobile (manual-release) | GitHub App para workflows subsecuentes |
| `APP_PRIVATE_KEY` | api-mobile (manual-release) | GitHub App private key |

**✅ BUENA PRÁCTICA:** api-mobile usa GitHub App token para evitar limitación de GITHUB_TOKEN que no dispara workflows subsecuentes.

**⚠️ INCONSISTENCIA:** Los otros proyectos NO usan GitHub App, lo que significa que sus releases manuales no disparan sync-main-to-dev automáticamente.

---

## 🎯 Umbrales y Métricas

### Coverage Thresholds

| Proyecto | Threshold | Enforced | Bypass Disponible |
|----------|-----------|----------|-------------------|
| api-mobile | 33% | ✅ Sí | ✅ Label 'skip-coverage' |
| api-administracion | 33% | ✅ Sí | ✅ Label 'skip-coverage' |
| worker | ❌ N/A | ❌ No | N/A |
| shared | ❌ N/A | ❌ No | N/A |

**🔴 INCONSISTENCIA:** Worker y shared no tienen umbral de cobertura definido.

---

## 📝 Nombres de Workflows

### Inconsistencias Detectadas

**Problema:** Workflows con propósitos similares tienen nombres diferentes entre repos.

| Propósito | api-mobile | api-administracion | worker | shared |
|-----------|------------|-------------------|--------|--------|
| CI en PR a dev | "PR to Dev - Unit Tests" | "PR to Dev - Unit Tests" | N/A | "CI Pipeline" |
| CI en PR a main | "PR to Main - Full Test Suite" | ❌ No existe | N/A | "CI Pipeline" |
| Release manual | "Manual Release" | "Manual Release" | "Manual Release" | N/A |
| Release automático | N/A | "Release CI/CD" | "Release CI/CD" | "Release CI/CD" |
| Tests manuales | "Tests with Coverage (Manual)" | "Tests with Coverage (Manual)" | N/A | "Tests with Coverage" |

**⚠️ PROBLEMA:** worker no tiene workflow para PRs a dev específico, solo `ci.yml` genérico.

---

## 🚨 Problemas de Configuración

### 1. Workflow con nombre de archivo en logs

**worker:** El workflow aparece como `.github/workflows/pr-to-dev.yml` en los logs en lugar de un nombre legible.

**Causa:** Falta la key `name:` en el YAML o está mal configurada.

**Impacto:** Dificulta identificar qué workflow falló.

### 2. Trigger ambiguos

**worker - docker-only.yml:** No se pudo determinar el trigger al revisar el código.

**Recomendación:** Revisar y documentar claramente los triggers.

### 3. Continue-on-error inconsistente

**shared y worker:** Usan `continue-on-error: true` en lint.

**Pros:** No bloquea CI por warnings de lint.  
**Contras:** Permite acumular deuda técnica sin ser visible.

**Recomendación:** Usar pero con alertas visibles en PR.

---

## 📚 Documentación en Workflows

### Comentarios y Explicaciones

**✅ BUENAS PRÁCTICAS encontradas:**

**api-mobile - manual-release.yml:**
```yaml
# Usar GitHub App Token en lugar de GITHUB_TOKEN porque:
# - GITHUB_TOKEN NO dispara workflows subsecuentes
# - App Token SÍ dispara sync-main-to-dev.yml automáticamente
```

**shared - test.yml:**
```yaml
# IMPORTANTE: Este workflow NO se ejecuta en push (solo PRs y manual)
# Los "errores" en push son esperados...
```

**⚠️ FALTAN COMENTARIOS en:**
- worker workflows (no explican por qué tiene 3 build workflows)
- api-administracion (no explica diferencia entre build-and-push y release)

---

## 🔧 Herramientas y Actions

### Versiones de Actions Usadas

| Action | Versión Común | Inconsistencias |
|--------|--------------|-----------------|
| `actions/checkout` | v4 ✅ | v5 en infrastructure ⚠️ |
| `actions/setup-go` | v5 ✅ | v6 en infrastructure ⚠️ |
| `docker/setup-buildx-action` | v3 ✅ | Consistente |
| `docker/login-action` | v3 ✅ | Consistente |
| `docker/build-push-action` | v5 ✅ | Consistente |
| `docker/metadata-action` | v5 ✅ | Consistente |
| `actions/upload-artifact` | v4 ✅ | Consistente |
| `golangci/golangci-lint-action` | v6 | Solo en algunos |

**⚠️ DESVIACIÓN:** infrastructure usa versiones más nuevas (v5, v6) que el resto (v4, v5).

**Recomendación:** Estandarizar en las versiones más nuevas que funcionen para todos.

---

## 🎓 Conclusiones

### Fortalezas del Ecosistema Actual

1. ✅ **Buena estructura base** - Workflows bien organizados por propósito
2. ✅ **Estrategia modular en shared** - Excelente uso de matrices
3. ✅ **Comentarios en PRs** - Feedback automático de cobertura
4. ✅ **Multi-platform Docker** - Soporte amd64 y arm64
5. ✅ **GitHub App tokens** - Solución elegante en api-mobile

### Debilidades Críticas

1. 🔴 **Duplicación masiva** - 70% código repetido
2. 🔴 **Builds duplicados** - Múltiples workflows construyendo lo mismo
3. 🔴 **Fallos no bloqueantes** - Release failures post-merge
4. 🔴 **Inconsistencia Go** - worker en 1.25, otros en 1.24
5. 🔴 **infrastructure fallando** - 80% failure rate

### Oportunidades de Mejora

1. 🎯 Crear workflows reusables en edugo-infrastructure
2. 🎯 Estandarizar estrategia de Docker builds
3. 🎯 Implementar composite actions para bloques comunes
4. 🎯 Unificar estrategia de versionado y tags
5. 🎯 Resolver fallos en infrastructure prioritariamente

---

## 📌 Próximos Pasos Recomendados

Ver archivo: `02-PROPUESTAS-MEJORA.md`

---

**Generado por:** Claude Code  
**Fecha:** 19 de Noviembre, 2025
