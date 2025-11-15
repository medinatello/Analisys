# 📜 REGLAS DEL PROYECTO: Sistema de Evaluaciones

**IMPORTANTE:** Este documento contiene reglas OBLIGATORIAS que DEBEN seguirse durante toda la implementación del sistema de evaluaciones. Cualquier desviación requiere aprobación explícita del usuario.

---

## 🎯 REGLAS FUNDAMENTALES

### 1. ORDEN DE EJECUCIÓN ESTRICTO ⚠️

**NUNCA** alterar el orden de implementación:

```
1. edugo-shared (BLOQUEANTE)
   ↓ Release v0.7.0
2. edugo-dev-environment (paralelo con 1)
   ↓ 
3. edugo-api-mobile (requiere shared v0.7.0)
   ↓
4. edugo-api-administracion (puede ser paralelo con 3)
```

**Consecuencias de violar el orden:**
- ❌ Dependencias rotas
- ❌ Código que no compila
- ❌ Tests fallando
- ❌ Retrabajos costosos

### 2. GESTIÓN DE CONTEXTO Y LOGS

#### 2.1 Al Iniciar Sesión
```bash
# SIEMPRE ejecutar primero:
1. Leer specs/sistema-evaluaciones/README.md
2. Revisar PROGRESS.json para estado actual
3. Identificar siguiente tarea en TASKS.md del repo actual
4. Leer LOGS.md del repo para contexto previo
```

#### 2.2 Durante la Sesión
```bash
# Actualizar LOGS.md cada 30 minutos con:
- Tareas completadas
- Decisiones tomadas
- Problemas encontrados
- Próximos pasos
```

#### 2.3 Al Finalizar Sesión
```bash
# OBLIGATORIO antes de terminar:
1. Actualizar PROGRESS.json
2. Commitear con mensaje descriptivo
3. Actualizar LOGS.md con resumen final
4. Documentar cualquier bloqueador
```

### 3. WORKFLOW DE RAMAS Y PULL REQUESTS

#### 3.1 Nomenclatura de Branches
```bash
# Formato ESTRICTO:
feature/evaluaciones-[repo]-[fase]

# Ejemplos:
feature/evaluaciones-shared-tipos       # Para edugo-shared
feature/evaluaciones-mobile-core        # Para api-mobile fase core
feature/evaluaciones-mobile-integration # Para api-mobile integración
feature/evaluaciones-admin-reportes     # Para api-admin
```

#### 3.2 Flujo de PRs
```bash
# SIEMPRE:
1. Branch desde 'dev', NO desde 'main'
2. PR hacia 'dev' primero
3. Título: "feat(evaluaciones): [descripción]"
4. Body DEBE incluir:
   - Link a esta spec
   - Checklist de validación
   - Tests agregados
   - Coverage actual
```

#### 3.3 Merge Requirements
- ✅ Todos los tests pasando
- ✅ Coverage >80% (>85% ideal)
- ✅ Linter sin errores
- ✅ Al menos 1 review (si hay reviewers)
- ✅ CI/CD verde

### 4. RELEASES DE SHARED (CASO ESPECIAL)

**edugo-shared tiene reglas ÚNICAS:**

```bash
# Releases DESDE dev, no desde main:
1. Completar módulo en dev
2. Todos los tests pasando
3. git tag v0.7.0 en dev (NO en main)
4. git push origin v0.7.0
5. GitHub Action crea el release

# NUNCA:
- No esperar merge a main para release
- No crear tags en main para módulos
```

### 5. GESTIÓN DE DEPENDENCIAS

#### 5.1 Actualización de go.mod
```bash
# Al consumir nuevo release de shared:
cd edugo-api-mobile
go get github.com/EduGoGroup/edugo-shared/assessment@v0.7.0
go mod tidy
go test ./...  # VERIFICAR que nada se rompió
```

#### 5.2 Versionado Semántico Estricto
```
MAJOR.MINOR.PATCH

v0.7.0 → Nueva feature (assessment module)
v0.7.1 → Bugfix en assessment
v0.8.0 → Siguiente feature diferente
```

### 6. TESTING REQUIREMENTS

#### 6.1 Cobertura Mínima por Capa
```
Domain:         90% (crítico)
Application:    85% (importante)
Infrastructure: 80% (mínimo CI/CD)
Handlers:       75% (aceptable)
```

#### 6.2 Tipos de Tests Obligatorios
```go
// Por cada entity:
- Constructor tests
- Validation tests
- Business logic tests

// Por cada service:
- Happy path tests
- Error cases tests
- Integration tests

// Por cada handler:
- Request validation tests
- Response format tests
- Error handling tests
```

### 7. INTEGRACIÓN MongoDB-PostgreSQL

#### 7.1 Fuente de Verdad
```
MongoDB: Fuente de verdad para contenido de quizzes
PostgreSQL: Fuente de verdad para intentos y resultados
```

#### 7.2 Sincronización
```go
// NUNCA duplicar data
// SIEMPRE usar referencias:
type Assessment struct {
    ID               uuid.UUID  // PostgreSQL
    MaterialID       uuid.UUID  // PostgreSQL
    MongoAssessmentID string    // Referencia a MongoDB
}
```

### 8. MANEJO DE ERRORES

#### 8.1 Jerarquía de Errores
```go
// Domain errors (no retry)
ErrInvalidScore
ErrAssessmentNotFound
ErrAttemptAlreadyCompleted

// Infrastructure errors (retry posible)
ErrDatabaseConnection
ErrMongoTimeout
ErrRedisUnavailable
```

#### 8.2 Logging Obligatorio
```go
// SIEMPRE loguear con contexto:
logger.WithFields(log.Fields{
    "user_id":       userID,
    "assessment_id": assessmentID,
    "attempt_id":    attemptID,
    "error":         err,
}).Error("Failed to submit answers")
```

### 9. DOCUMENTACIÓN EN CÓDIGO

#### 9.1 Comentarios Obligatorios
```go
// Package assessment provides domain logic for educational assessments.
// It handles quiz attempts, automatic grading, and progress tracking.
package assessment

// Assessment represents an educational evaluation linked to learning material.
// It maintains a reference to the actual quiz content stored in MongoDB
// while tracking attempts and results in PostgreSQL.
type Assessment struct {
    // ...
}
```

#### 9.2 Swagger Annotations
```go
// SubmitAnswers godoc
// @Summary Submit answers for an assessment attempt
// @Description Submit user's answers for an active assessment attempt
// @Tags Assessments
// @Accept json
// @Produce json
// @Param attemptId path string true "Attempt ID"
// @Param answers body []AnswerDTO true "User answers"
// @Success 200 {object} AttemptResultDTO
// @Failure 400 {object} ErrorResponse "Invalid answers"
// @Failure 404 {object} ErrorResponse "Attempt not found"
// @Router /v1/attempts/{attemptId}/answers [post]
```

### 10. VALIDACIONES CRÍTICAS

#### 10.1 Antes de Cada PR
```bash
# Checklist OBLIGATORIO:
□ make test (100% pass)
□ make lint (0 issues)
□ make coverage (>80%)
□ go mod tidy ejecutado
□ Swagger regenerado si hay nuevos endpoints
□ README actualizado si hay cambios importantes
□ CHANGELOG.md actualizado
```

#### 10.2 Antes de Release (shared)
```bash
# Extra para shared:
□ Versión bumpeada en version.go
□ Todos los módulos dependientes probados
□ Backward compatibility verificada
□ Migration guide si hay breaking changes
```

---

## ⚠️ ANTI-PATTERNS A EVITAR

### ❌ NUNCA HACER:

1. **Commits directos a main o dev sin PR**
2. **Releases desde main en shared**
3. **Saltar tests "temporalmente"**
4. **Hardcodear valores de configuración**
5. **Ignorar errores con `_ = err`**
6. **Duplicar lógica entre repos**
7. **Crear dependencias circulares**
8. **Mezclar concerns (domain con infra)**
9. **SQL queries sin prepared statements**
10. **Loguear información sensible**

### ✅ SIEMPRE HACER:

1. **PRs pequeños y enfocados (<500 LOC)**
2. **Tests antes que código (TDD)**
3. **Code review aunque seas único dev**
4. **Documentar decisiones no obvias**
5. **Usar transacciones para operaciones múltiples**
6. **Validar input en TODAS las capas**
7. **Manejar graceful shutdown**
8. **Implementar circuit breakers**
9. **Usar context para timeouts**
10. **Mantener LOGS.md actualizado**

---

## 📊 MÉTRICAS DE CALIDAD

### Umbrales NO Negociables

| Métrica | Mínimo | Objetivo | 
|---------|--------|----------|
| Test Coverage | 80% | 85% |
| Cyclomatic Complexity | <10 | <7 |
| Duplicación | <3% | <2% |
| Technical Debt | <2d | <1d |
| Code Smells | 0 Critical | 0 Total |

### Herramientas de Validación

```bash
# Ejecutar ANTES de cada commit:
make quality-check

# Que internamente ejecuta:
- go test -race -cover ./...
- golangci-lint run
- go mod tidy
- go vet ./...
- ineffassign ./...
- staticcheck ./...
```

---

## 🚨 PROCEDIMIENTO DE EMERGENCIA

### Si Algo Sale Mal:

1. **STOP** - No intentar arreglar a ciegas
2. **ANALYZE** - Entender la causa raíz
3. **DOCUMENT** - Escribir en LOGS.md
4. **ROLLBACK** - Si es necesario
5. **COMMUNICATE** - Informar al usuario
6. **FIX** - Con plan claro
7. **TEST** - Verificar solución
8. **POSTMORTEM** - Documentar lecciones

### Contactos de Emergencia:

- **Revisar:** specs/sistema-evaluaciones/LOGS.md
- **Contexto:** specs/sistema-evaluaciones/README.md
- **Estado:** specs/sistema-evaluaciones/PROGRESS.json

---

## 📝 REGISTRO DE CAMBIOS A ESTAS REGLAS

| Fecha | Cambio | Razón |
|-------|--------|-------|
| 2025-11-14 | Documento inicial | Establecer reglas base |

---

**⚠️ IMPORTANTE:** Estas reglas son OBLIGATORIAS. Cualquier excepción requiere:
1. Justificación documentada
2. Aprobación explícita del usuario
3. Actualización de este documento

**Última actualización:** 14 de Noviembre, 2025  
**Válido para:** Sistema de Evaluaciones v1.0