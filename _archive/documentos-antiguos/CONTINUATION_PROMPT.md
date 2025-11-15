# 🔄 PROMPT DE CONTINUACIÓN - Completar spec-01-evaluaciones

**Fecha creación:** 2025-11-14  
**Sesión anterior:** Tokens usados ~100K/1M  
**Estado:** Fase 0 completada, iniciando Fase 1

---

## ⚡ INICIO RÁPIDO PARA NUEVA SESIÓN

```bash
# 1. Leer este archivo completo primero
# 2. Leer PROGRESS.json para ver estado exacto
cd /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones
cat PROGRESS.json | jq '{current_phase, current_sprint, current_task, files_completed, files_remaining}'

# 3. Continuar desde la fase indicada en PROGRESS.json
```

---

## 📍 CONTEXTO COMPLETO

### ¿Qué Estamos Haciendo?

Completar **spec-01-evaluaciones** del 34% → 100% generando **33 archivos faltantes**.

### Estado Actual (Al Momento de Esta Pausa)

- ✅ **Completado:** Fase 0 (Preparación)
  - Directorios creados
  - PROGRESS.json inicializado
  - Commit realizado: `ebc8c6f`

- 🔄 **En Progreso:** Fase 1 (Sprint-02 Dominio)
  - README.md de Sprint-02 YA generado
  - Pendiente: TASKS.md, DEPENDENCIES.md, QUESTIONS.md, VALIDATION.md

- ⏳ **Pendiente:** Fases 2-9

### Archivos Generados Hasta Ahora

**Total:** 18 archivos (36%)
- 13 archivos pre-existentes de spec-01
- 1 archivo de Sprint-01 (README.md que ya estaba)
- 4 archivos de Sprint-01 completados en sesión previa
- 1 archivo nuevo: PROGRESS.json

---

## 🎯 PLAN DE EJECUCIÓN (Dónde Continuar)

### FASE 1: Sprint-02 Dominio (ACTUAL - CONTINUAR AQUÍ)

**Archivos pendientes de Sprint-02:** 4 archivos

#### TASK-1.2: Generar TASKS.md de Sprint-02 ⏳ SIGUIENTE
**Prioridad:** CRÍTICA  
**Estimación:** 20 minutos  
**Ruta:** `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/03-Sprints/Sprint-02-Dominio/TASKS.md`

**Contenido EXACTO a generar:**

```markdown
# Tareas del Sprint 02 - Capa de Dominio

## Objetivo
Implementar la capa de dominio del Sistema de Evaluaciones con 3 entities (Assessment, Attempt, Answer), 5+ value objects, 3 repository interfaces y tests unitarios con >90% coverage, siguiendo principios de Clean Architecture y Domain-Driven Design.

---

## Tareas

### TASK-02-001: Crear Entity Assessment
**Tipo:** feature  
**Prioridad:** HIGH  
**Estimación:** 3h  
**Asignado a:** @ai-executor

#### Descripción
Crear la entity Assessment que representa una evaluación asociada a un material educativo. Esta entity encapsula las reglas de negocio relacionadas con evaluaciones.

#### Pasos de Implementación

1. Crear archivo en ruta absoluta:
   ```
   /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/domain/entities/assessment.go
   ```

2. Implementar struct con validaciones:
   ```go
   package entities
   
   import (
       "errors"
       "time"
       "github.com/google/uuid"
   )
   
   // Assessment representa una evaluación de un material educativo
   type Assessment struct {
       ID                 uuid.UUID
       MaterialID         uuid.UUID
       MongoDocumentID    string  // ObjectId de MongoDB (24 caracteres hex)
       Title              string
       TotalQuestions     int
       PassThreshold      int // Porcentaje 0-100
       MaxAttempts        *int // nil = ilimitado
       TimeLimitMinutes   *int // nil = sin límite
       CreatedAt          time.Time
       UpdatedAt          time.Time
   }
   
   // NewAssessment crea una nueva evaluación con validaciones
   func NewAssessment(
       materialID uuid.UUID,
       mongoDocID string,
       title string,
       totalQuestions int,
       passThreshold int,
   ) (*Assessment, error) {
       // Validaciones
       if materialID == uuid.Nil {
           return nil, ErrInvalidMaterialID
       }
       
       if len(mongoDocID) != 24 {
           return nil, ErrInvalidMongoDocumentID
       }
       
       if title == "" {
           return nil, ErrEmptyTitle
       }
       
       if totalQuestions < 1 || totalQuestions > 100 {
           return nil, ErrInvalidTotalQuestions
       }
       
       if passThreshold < 0 || passThreshold > 100 {
           return nil, ErrInvalidPassThreshold
       }
       
       now := time.Now()
       return &Assessment{
           ID:                 uuid.New(),
           MaterialID:         materialID,
           MongoDocumentID:    mongoDocID,
           Title:              title,
           TotalQuestions:     totalQuestions,
           PassThreshold:      passThreshold,
           MaxAttempts:        nil,
           TimeLimitMinutes:   nil,
           CreatedAt:          now,
           UpdatedAt:          now,
       }, nil
   }
   
   // Validate verifica que la evaluación sea válida
   func (a *Assessment) Validate() error {
       if a.ID == uuid.Nil {
           return ErrInvalidAssessmentID
       }
       // ... más validaciones
       return nil
   }
   
   // CanAttempt verifica si un estudiante puede hacer un intento
   func (a *Assessment) CanAttempt(attemptCount int) bool {
       if a.MaxAttempts == nil {
           return true // Ilimitado
       }
       return attemptCount < *a.MaxAttempts
   }
   
   // IsTimeLimited indica si la evaluación tiene límite de tiempo
   func (a *Assessment) IsTimeLimited() bool {
       return a.TimeLimitMinutes != nil && *a.TimeLimitMinutes > 0
   }
   
   // SetMaxAttempts establece el máximo de intentos permitidos
   func (a *Assessment) SetMaxAttempts(max int) error {
       if max < 1 {
           return ErrInvalidMaxAttempts
       }
       a.MaxAttempts = &max
       a.UpdatedAt = time.Now()
       return nil
   }
   
   // SetTimeLimit establece el límite de tiempo en minutos
   func (a *Assessment) SetTimeLimit(minutes int) error {
       if minutes < 1 || minutes > 180 {
           return ErrInvalidTimeLimit
       }
       a.TimeLimitMinutes = &minutes
       a.UpdatedAt = time.Now()
       return nil
   }
   ```

3. Crear errores de dominio en `internal/domain/errors/assessment_errors.go`:
   ```go
   package errors
   
   import "errors"
   
   var (
       ErrInvalidAssessmentID      = errors.New("invalid assessment ID")
       ErrInvalidMaterialID        = errors.New("invalid material ID")
       ErrInvalidMongoDocumentID   = errors.New("mongo document ID must be 24 characters")
       ErrEmptyTitle               = errors.New("assessment title cannot be empty")
       ErrInvalidTotalQuestions    = errors.New("total questions must be between 1 and 100")
       ErrInvalidPassThreshold     = errors.New("pass threshold must be between 0 and 100")
       ErrInvalidMaxAttempts       = errors.New("max attempts must be at least 1")
       ErrInvalidTimeLimit         = errors.New("time limit must be between 1 and 180 minutes")
   )
   ```

4. Crear tests unitarios en `internal/domain/entities/assessment_test.go`:
   ```go
   package entities_test
   
   import (
       "testing"
       "github.com/google/uuid"
       "github.com/stretchr/testify/assert"
       "github.com/stretchr/testify/require"
       
       "edugo-api-mobile/internal/domain/entities"
       domainErrors "edugo-api-mobile/internal/domain/errors"
   )
   
   func TestNewAssessment_Success(t *testing.T) {
       materialID := uuid.New()
       mongoDocID := "507f1f77bcf86cd799439011"
       title := "Cuestionario de Pascal"
       totalQuestions := 5
       passThreshold := 70
       
       assessment, err := entities.NewAssessment(
           materialID,
           mongoDocID,
           title,
           totalQuestions,
           passThreshold,
       )
       
       require.NoError(t, err)
       assert.NotNil(t, assessment)
       assert.NotEqual(t, uuid.Nil, assessment.ID)
       assert.Equal(t, materialID, assessment.MaterialID)
       assert.Equal(t, mongoDocID, assessment.MongoDocumentID)
       assert.Equal(t, title, assessment.Title)
       assert.Equal(t, totalQuestions, assessment.TotalQuestions)
       assert.Equal(t, passThreshold, assessment.PassThreshold)
       assert.Nil(t, assessment.MaxAttempts)
       assert.Nil(t, assessment.TimeLimitMinutes)
   }
   
   func TestNewAssessment_InvalidMaterialID(t *testing.T) {
       _, err := entities.NewAssessment(
           uuid.Nil,
           "507f1f77bcf86cd799439011",
           "Title",
           5,
           70,
       )
       
       assert.ErrorIs(t, err, domainErrors.ErrInvalidMaterialID)
   }
   
   func TestNewAssessment_InvalidMongoDocumentID(t *testing.T) {
       _, err := entities.NewAssessment(
           uuid.New(),
           "invalid",
           "Title",
           5,
           70,
       )
       
       assert.ErrorIs(t, err, domainErrors.ErrInvalidMongoDocumentID)
   }
   
   func TestNewAssessment_EmptyTitle(t *testing.T) {
       _, err := entities.NewAssessment(
           uuid.New(),
           "507f1f77bcf86cd799439011",
           "",
           5,
           70,
       )
       
       assert.ErrorIs(t, err, domainErrors.ErrEmptyTitle)
   }
   
   func TestNewAssessment_InvalidTotalQuestions(t *testing.T) {
       testCases := []struct {
           name           string
           totalQuestions int
       }{
           {"zero questions", 0},
           {"negative questions", -1},
           {"too many questions", 101},
       }
       
       for _, tc := range testCases {
           t.Run(tc.name, func(t *testing.T) {
               _, err := entities.NewAssessment(
                   uuid.New(),
                   "507f1f77bcf86cd799439011",
                   "Title",
                   tc.totalQuestions,
                   70,
               )
               
               assert.ErrorIs(t, err, domainErrors.ErrInvalidTotalQuestions)
           })
       }
   }
   
   func TestNewAssessment_InvalidPassThreshold(t *testing.T) {
       testCases := []struct {
           name          string
           passThreshold int
       }{
           {"negative threshold", -1},
           {"above 100", 101},
       }
       
       for _, tc := range testCases {
           t.Run(tc.name, func(t *testing.T) {
               _, err := entities.NewAssessment(
                   uuid.New(),
                   "507f1f77bcf86cd799439011",
                   "Title",
                   5,
                   tc.passThreshold,
               )
               
               assert.ErrorIs(t, err, domainErrors.ErrInvalidPassThreshold)
           })
       }
   }
   
   func TestAssessment_CanAttempt(t *testing.T) {
       assessment, _ := entities.NewAssessment(
           uuid.New(),
           "507f1f77bcf86cd799439011",
           "Title",
           5,
           70,
       )
       
       // Sin límite de intentos
       assert.True(t, assessment.CanAttempt(0))
       assert.True(t, assessment.CanAttempt(100))
       
       // Con límite de 3 intentos
       maxAttempts := 3
       assessment.MaxAttempts = &maxAttempts
       
       assert.True(t, assessment.CanAttempt(0))
       assert.True(t, assessment.CanAttempt(2))
       assert.False(t, assessment.CanAttempt(3))
       assert.False(t, assessment.CanAttempt(4))
   }
   
   func TestAssessment_SetMaxAttempts(t *testing.T) {
       assessment, _ := entities.NewAssessment(
           uuid.New(),
           "507f1f77bcf86cd799439011",
           "Title",
           5,
           70,
       )
       
       // Válido
       err := assessment.SetMaxAttempts(5)
       assert.NoError(t, err)
       assert.NotNil(t, assessment.MaxAttempts)
       assert.Equal(t, 5, *assessment.MaxAttempts)
       
       // Inválido
       err = assessment.SetMaxAttempts(0)
       assert.ErrorIs(t, err, domainErrors.ErrInvalidMaxAttempts)
   }
   
   func TestAssessment_IsTimeLimited(t *testing.T) {
       assessment, _ := entities.NewAssessment(
           uuid.New(),
           "507f1f77bcf86cd799439011",
           "Title",
           5,
           70,
       )
       
       // Sin límite
       assert.False(t, assessment.IsTimeLimited())
       
       // Con límite
       timeLimit := 30
       assessment.TimeLimitMinutes = &timeLimit
       assert.True(t, assessment.IsTimeLimited())
   }
   ```

#### Criterios de Aceptación
- [ ] Archivo creado en `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/domain/entities/assessment.go`
- [ ] Struct Assessment con todos los campos especificados
- [ ] Constructor NewAssessment() con validaciones completas
- [ ] Métodos de negocio: CanAttempt(), IsTimeLimited(), SetMaxAttempts(), SetTimeLimit()
- [ ] Errores de dominio definidos en package separado
- [ ] Tests unitarios con coverage >90%
- [ ] Tests de casos exitosos y fallidos

#### Comandos de Validación
```bash
# Compilar
go build /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/domain/entities

# Ejecutar tests
go test /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/domain/entities -v -run TestAssessment

# Verificar coverage
go test /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/internal/domain/entities -cover -coverprofile=coverage.out
go tool cover -func=coverage.out | grep assessment.go
# Esperado: >90%
```

#### Dependencias
- Requiere: Go 1.21+
- Usa: github.com/google/uuid
- Usa: github.com/stretchr/testify v1.8.4

#### Tiempo Estimado
3 horas

---

### TASK-02-002: Crear Entity Attempt
[CONTINUAR CON MISMO PATRÓN... - Este es solo un EJEMPLO de cómo debe lucir el TASKS.md completo]

[... AQUÍ IRÍAN TASK-02-002 a TASK-02-006 con el mismo nivel de detalle ...]
```

**IMPORTANTE:** El archivo TASKS.md de Sprint-02 debe tener **mínimo 5000 palabras** y cubrir:
- TASK-02-001: Entity Assessment (como arriba)
- TASK-02-002: Entity Attempt
- TASK-02-003: Entity Answer
- TASK-02-004: Value Objects (Score, AssessmentID, QuestionID, TimeSpent)
- TASK-02-005: Repository Interfaces
- TASK-02-006: Tests Unitarios completos

---

#### TASK-1.3: Generar DEPENDENCIES.md de Sprint-02
**Ruta:** `03-Sprints/Sprint-02-Dominio/DEPENDENCIES.md`  
**Contenido:** Ver template en `specifications_documents/spec-meta-completar-spec01/01-Requirements/TECHNICAL_SPECS.md`

#### TASK-1.4: Generar QUESTIONS.md de Sprint-02
**Ruta:** `03-Sprints/Sprint-02-Dominio/QUESTIONS.md`  
**Contenido:** 5+ preguntas con defaults (ver FUNCTIONAL_SPECS.md)

#### TASK-1.5: Generar VALIDATION.md de Sprint-02
**Ruta:** `03-Sprints/Sprint-02-Dominio/VALIDATION.md`  
**Contenido:** Checklist de validación con comandos

---

### FASES 2-9: Por Ejecutar

**Después de completar Fase 1:**

1. **Actualizar PROGRESS.json:**
   ```bash
   jq '.files_completed = 22 | .current_phase = "Fase-2-Sprint03" | .sprint_status."Sprint-02" = "completed"' PROGRESS.json > tmp.json && mv tmp.json PROGRESS.json
   ```

2. **Commit:**
   ```bash
   git add 03-Sprints/Sprint-02-Dominio/ PROGRESS.json
   git commit -m "docs: completar Sprint-02-Dominio (5 archivos generados, Fase 1)"
   ```

3. **Continuar con Fase 2:** Sprint-03 (mismo patrón, 5 archivos)
4. **Continuar con Fase 3:** Sprint-04 (mismo patrón, 5 archivos)
5. **Continuar con Fase 4:** Sprint-05 (mismo patrón, 5 archivos)
6. **Continuar con Fase 5:** Sprint-06 (mismo patrón, 5 archivos)
7. **Continuar con Fase 6:** Testing docs (3 archivos)
8. **Continuar con Fase 7:** Deployment docs (3 archivos)
9. **Continuar con Fase 8:** Tracking system (2 archivos)
10. **Finalizar con Fase 9:** Validación

---

## 📚 DOCUMENTOS DE REFERENCIA

### Leer SIEMPRE Antes de Continuar

1. **PROGRESS.json** - Estado exacto actual
   ```bash
   cat /Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/spec-01-evaluaciones/PROGRESS.json
   ```

2. **EXECUTION_PLAN.md** - Plan completo de 9 fases
   ```bash
   cat /Users/jhoanmedina/source/EduGo/Analisys/specifications_documents/spec-meta-completar-spec01/02-Design/EXECUTION_PLAN.md
   ```

3. **FUNCTIONAL_SPECS.md** - Qué debe contener cada archivo
   ```bash
   cat /Users/jhoanmedina/source/EduGo/Analisys/specifications_documents/spec-meta-completar-spec01/01-Requirements/FUNCTIONAL_SPECS.md
   ```

4. **TECHNICAL_SPECS.md** - Formato y templates
   ```bash
   cat /Users/jhoanmedina/source/EduGo/Analisys/specifications_documents/spec-meta-completar-spec01/01-Requirements/TECHNICAL_SPECS.md
   ```

5. **Archivos ya existentes como referencia:**
   - Sprint-01 completo: `03-Sprints/Sprint-01-Schema-BD/TASKS.md`
   - FUNCTIONAL_SPECS.md existente: `01-Requirements/FUNCTIONAL_SPECS.md`

---

## ⚠️ REGLAS CRÍTICAS

### NO HACER:
- ❌ Usar placeholders ("implementar según necesidad", "TODO", "TBD")
- ❌ Rutas relativas (usar SIEMPRE rutas absolutas)
- ❌ Comandos genéricos ("ejecutar tests apropiados")
- ❌ Decisiones sin defaults en QUESTIONS.md

### SIEMPRE HACER:
- ✅ Código Go con firmas EXACTAS (nombres de funciones, parámetros, tipos)
- ✅ Comandos bash copy-paste ejecutables
- ✅ Actualizar PROGRESS.json después de cada fase
- ✅ Commit después de cada fase completada
- ✅ Validar que archivo generado cumple longitud mínima

---

## 🎯 CHECKLIST DE CONTINUACIÓN

Al empezar nueva sesión:
- [ ] Leer este archivo completo (CONTINUATION_PROMPT.md)
- [ ] Leer PROGRESS.json para saber dónde continuar
- [ ] Verificar último commit con `git log -1`
- [ ] Continuar desde la fase indicada en PROGRESS.json
- [ ] Generar archivos según EXECUTION_PLAN.md
- [ ] Actualizar PROGRESS.json después de cada fase
- [ ] Commit después de cada fase
- [ ] Repetir hasta completar todas las fases

---

## 📊 MÉTRICAS DE PROGRESO

### Al Momento de Esta Pausa
- **Archivos completados:** 18/50 (36%)
- **Fases completadas:** 0/9 (Fase 0 de preparación)
- **Sprints completados:** 1/6 (Sprint-01)
- **Commits realizados:** 1 (Fase 0)

### Objetivo Final
- **Archivos totales:** 50/50 (100%)
- **Fases totales:** 9/9
- **Sprints totales:** 6/6
- **Calidad:** 0 placeholders, 100% ejecutable

---

## 🚀 COMANDO DE INICIO PARA NUEVA SESIÓN

```bash
# Copiar y ejecutar esto al inicio de la nueva sesión:

cd /Users/jhoanmedina/source/EduGo/Analisys

echo "=== LEYENDO ESTADO ACTUAL ==="
cat AnalisisEstandarizado/spec-01-evaluaciones/PROGRESS.json | jq '{current_phase, files_completed, files_remaining}'

echo ""
echo "=== PRÓXIMA FASE A EJECUTAR ==="
current_phase=$(cat AnalisisEstandarizado/spec-01-evaluaciones/PROGRESS.json | jq -r '.current_phase')
echo "Continuar desde: $current_phase"

echo ""
echo "=== LEER PLAN DE EJECUCIÓN ==="
echo "Ver: specifications_documents/spec-meta-completar-spec01/02-Design/EXECUTION_PLAN.md"
echo "Buscar sección: $current_phase"
```

---

**Generado con:** Claude Code  
**Sesión:** 1  
**Estado al generar este prompt:** Fase 0 completada, iniciando Fase 1  
**Próxima acción:** Completar Sprint-02 (5 archivos)  
**Usar tokens restantes:** ~900K tokens disponibles en nueva sesión
