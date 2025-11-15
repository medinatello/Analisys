# 🎯 Dudas Específicas por Proyecto - EduGo

**Fecha:** 15 de Noviembre, 2025  
**Propósito:** Detallar dudas específicas que tendría al implementar cada proyecto

---

## 📦 PROYECTO: edugo-shared

### Contexto
Biblioteca compartida Go que todos los demás proyectos utilizan.

### 🚨 Dudas Críticas

#### 1. Módulo pkg/evaluation - Definición Ambigua

**Lo que dice la documentación:**
```go
// Crear pkg/evaluation/models.go - Modelos base
// Crear pkg/evaluation/interfaces.go - Contratos
```

**Lo que NO está claro:**
```go
// ¿Los modelos deben ser structs GORM?
type Assessment struct {
    gorm.Model  // ¿Incluir esto?
    ID         uuid.UUID `gorm:"type:uuid;default:gen_uuid_v7()"` // ¿O así?
    MaterialID uuid.UUID `json:"material_id"`
    // ¿Qué más campos van aquí?
}

// ¿O deben ser DTOs puros sin GORM?
type Assessment struct {
    ID         string `json:"id"`
    MaterialID string `json:"material_id"`
    // ¿Diferentes a los de BD?
}
```

#### 2. Interfaces No Especificadas

**Necesito saber:**
```go
// ¿Qué métodos debe tener AssessmentRepository?
type AssessmentRepository interface {
    Create(ctx context.Context, assessment *Assessment) error
    GetByID(ctx context.Context, id uuid.UUID) (*Assessment, error)
    GetByMaterialID(ctx context.Context, materialID uuid.UUID) (*Assessment, error)
    // ¿Qué más métodos necesito?
    Update? Delete? List? FindByStudent?
}

// ¿Qué métodos debe tener AssessmentService?
type AssessmentService interface {
    CreateAssessment(???) error
    StartAttempt(???) (*Attempt, error)
    SubmitAnswers(???) (*Result, error)
    // ¿Qué parámetros exactos?
}
```

#### 3. Versionado de Módulos

**Pregunta sin responder:**
- ¿Cada cambio en shared requiere nuevo tag?
- Si cambio solo pkg/evaluation, ¿subo versión de todo shared?
- ¿Cómo manejo breaking changes?

**Ejemplo del problema:**
```bash
# Situación actual hipotética
github.com/EduGoGroup/edugo-shared v1.2.5

# Agrego pkg/evaluation
# ¿Debo crear v1.3.0 o v2.0.0?
# ¿Qué pasa con los proyectos que usan v1.2.5?
```

---

## 📱 PROYECTO: edugo-api-mobile

### Contexto
API REST para aplicación móvil, implementando sistema de evaluaciones.

### 🚨 Dudas Críticas

#### 1. Clean Architecture - Estructura No Clara

**Lo que sugiere la documentación:**
```
internal/
├── domain/
├── application/
├── infrastructure/
└── interfaces/
```

**Lo que no sé:**
```
internal/
├── domain/
│   ├── entities/       # ¿Assessment aquí?
│   ├── value_objects/  # ¿Score, Duration aquí?
│   └── repositories/   # ¿Interfaces aquí o en application?
├── application/
│   ├── services/       # ¿AssessmentService aquí?
│   ├── dto/           # ¿DTOs aquí?
│   └── use_cases/     # ¿O usar use_cases en lugar de services?
├── infrastructure/
│   ├── persistence/   # ¿Implementación de repos aquí?
│   ├── mongodb/      # ¿Cliente MongoDB aquí?
│   └── messaging/    # ¿RabbitMQ aquí?
└── interfaces/
    ├── http/         # ¿Handlers aquí?
    ├── middleware/   # ¿Auth middleware aquí?
    └── routes/       # ¿Definición de rutas aquí?
```

#### 2. MongoDB ObjectId vs UUID

**Problema encontrado:**
```sql
-- En PostgreSQL
mongo_document_id VARCHAR(24) NOT NULL
```

**Duda:**
```go
// ¿Cómo manejo la conversión?
type Assessment struct {
    ID              uuid.UUID  // PostgreSQL
    MongoDocumentID string     // MongoDB ObjectId como string
    // ¿O uso primitive.ObjectID de mongo driver?
    MongoDocumentID primitive.ObjectID
}

// Al buscar en MongoDB:
filter := bson.M{"_id": ??? } // ¿String o ObjectID?
```

#### 3. Endpoints No Completamente Definidos

**Lo que dice:**
- POST /evaluations
- GET /evaluations/:id
- POST /evaluations/:id/submit
- GET /evaluations/:id/results

**Lo que no dice:**

```go
// POST /evaluations - ¿Qué body?
type CreateEvaluationRequest struct {
    MaterialID string `json:"material_id"`
    // ¿Qué más? ¿StudentID viene del JWT?
}

// POST /evaluations/:id/submit - ¿Formato de respuestas?
type SubmitAnswersRequest struct {
    Answers []Answer `json:"answers"`
}

type Answer struct {
    QuestionID string `json:"question_id"`
    Answer     string `json:"answer"` // ¿O array para múltiple choice?
    // ¿O es más complejo?
    Answer interface{} `json:"answer"` // ¿String, []string, bool?
}
```

#### 4. Autenticación y Autorización

**No está claro:**
```go
// ¿Cómo obtengo el usuario actual?
func (h *Handler) CreateEvaluation(c *gin.Context) {
    // ¿De dónde saco el StudentID?
    userID := c.GetString("user_id") // ¿Del middleware?
    claims := c.MustGet("claims").(*Claims) // ¿O así?
    
    // ¿Qué permisos verifico?
    // ¿Puede cualquier estudiante crear evaluación?
    // ¿O solo si está enrolled en el material?
}
```

---

## ⚙️ PROYECTO: edugo-worker

### Contexto
Procesador asíncrono de eventos, generación con IA.

### 🚨 Dudas Críticas

#### 1. Estado Actual vs Nuevo

**No está claro qué ya existe:**
```go
// ¿Estos processors ya existen?
processors/
├── summary_processor.go      // ¿Existe? ¿Funciona?
├── quiz_generator.go         // ¿Nuevo? ¿Refactorizar?
├── evaluation_processor.go   // ¿Definitivamente nuevo?
```

#### 2. Estructura de Eventos No Definida

**Necesito el schema exacto:**
```go
// ¿Cómo es el evento evaluation.submitted?
type EvaluationSubmittedEvent struct {
    EventID     string    `json:"event_id"`
    Timestamp   time.Time `json:"timestamp"`
    AttemptID   string    `json:"attempt_id"`
    StudentID   string    `json:"student_id"`
    Answers     []???     `json:"answers"` // ¿Estructura?
    // ¿Qué más incluye?
}

// ¿Cómo publico la respuesta?
type EvaluationCompletedEvent struct {
    // ¿Qué campos?
}
```

#### 3. OpenAI Prompts No Especificados

**¿Cuáles son los prompts exactos?**
```go
// Para generar quiz
promptQuiz := `???` // ¿Qué prompt usar?

// Para evaluar respuestas
promptEvaluate := `???` // ¿Cómo pedirle que califique?

// ¿Uso function calling?
// ¿O solo completions?
// ¿Qué modelo? gpt-3.5-turbo, gpt-4, gpt-4-turbo?
```

#### 4. Manejo de Errores y Reintentos

**No especificado:**
```go
// ¿Qué hacer si OpenAI falla?
// ¿Reintentar cuántas veces?
// ¿Dead letter queue?
// ¿Alertar a alguien?

func processEvaluation(event EvaluationSubmittedEvent) error {
    // Si falla OpenAI
    result, err := openai.Evaluate(...)
    if err != nil {
        // ¿Reintento?
        // ¿Publico evento de error?
        // ¿Guardo en BD para proceso manual?
        return ??? 
    }
}
```

---

## 🏢 PROYECTO: edugo-api-administracion

### Contexto
API administrativa para gestión del sistema.

### 🚨 Dudas Críticas

#### 1. Jerarquía Académica No Definida

**¿Qué es exactamente?**
```sql
-- Se mencionan estas tablas pero no su estructura
CREATE TABLE schools (???);
CREATE TABLE academic_units (???);
CREATE TABLE unit_membership (???);

-- ¿Es algo así?
CREATE TABLE academic_units (
    id UUID PRIMARY KEY,
    parent_id UUID REFERENCES academic_units(id), -- ¿Recursivo?
    school_id UUID REFERENCES schools(id),
    name VARCHAR(255),
    type VARCHAR(50), -- ¿'department', 'grade', 'class'?
    level INTEGER,    -- ¿Profundidad en el árbol?
);
```

#### 2. Permisos y Roles

**No está claro el modelo de permisos:**
```go
// ¿Qué roles existen?
const (
    RoleSuperAdmin = "super_admin"
    RoleSchoolAdmin = "school_admin" 
    RoleTeacher = "teacher"
    RoleTutor = "tutor"
    // ¿Más roles?
)

// ¿Cómo se verifican permisos?
// ¿RBAC? ¿ABAC? ¿Casbin?
```

#### 3. Endpoints de Reportes

**¿Qué reportes específicamente?**
```go
// GET /admin/evaluations/reports
// ¿Qué tipo de reportes?

type ReportType string
const (
    ReportTypePerformance    ReportType = "performance"
    ReportTypeParticipation  ReportType = "participation"
    ReportTypeProgress       ReportType = "progress"
    // ¿Cuáles más?
)

// ¿Qué filtros acepta?
// ¿Por escuela? ¿Por período? ¿Por estudiante?
```

---

## 🐳 PROYECTO: edugo-dev-environment

### Contexto
Entorno Docker para desarrollo.

### 🚨 Dudas Críticas

#### 1. Docker Compose Profiles

**¿Cuáles son los profiles?**
```yaml
# docker-compose.yml
services:
  postgres:
    profiles: ["db", "full"]  # ¿Estos?
  
  mongodb:
    profiles: ["db", "full"]
  
  rabbitmq:
    profiles: ["messaging", "full"]
  
  # ¿Hay más profiles?
  # ¿"dev", "test", "minimal"?
```

#### 2. Seeds de Datos

**¿Qué datos de prueba?**
```sql
-- ¿Cuántos usuarios de prueba?
-- ¿Estructura de escuelas de prueba?
-- ¿Materiales con assessments ya generados?
-- ¿Intentos de evaluación históricos?
```

#### 3. Configuración de Servicios

**¿Qué configuración para cada servicio?**
```yaml
# ¿Límites de recursos?
postgres:
  mem_limit: ???
  cpus: ???

# ¿Configuración de RabbitMQ?
rabbitmq:
  environment:
    RABBITMQ_DEFAULT_VHOST: ???
    # ¿Exchanges y queues pre-creados?
```

---

## 🔄 DUDAS DE INTEGRACIÓN

### Entre api-mobile y worker

1. **¿Cómo garantizo que el evento llegó?**
```go
// api-mobile publica
err := publisher.Publish("evaluation.submitted", event)
// ¿Cómo sé que worker lo recibió?
// ¿Necesito acknowledgment?
```

2. **¿Qué pasa si MongoDB está vacío?**
```go
// api-mobile intenta leer assessment
assessment, err := mongoClient.FindAssessment(materialID)
if err == mongo.ErrNoDocuments {
    // ¿Devuelvo error?
    // ¿Trigger generación?
    // ¿Mensaje user-friendly?
}
```

### Entre shared y todos

3. **¿Cómo manejo actualizaciones de shared?**
```bash
# Si actualizo shared a v1.4.0
# ¿Debo actualizar TODOS los proyectos a la vez?
# ¿Puedo tener api-mobile en v1.3.0 y worker en v1.4.0?
```

### Entre todos y dev-environment

4. **¿Cómo sincronizo versiones?**
```yaml
# En dev-environment docker-compose
services:
  api-mobile:
    image: edugo/api-mobile:??? # ¿Qué versión?
    # ¿O build local?
    build: ???
```

---

## 📋 CHECKLIST DE INFORMACIÓN NECESARIA

Para poder implementar sin ambigüedades, necesito:

### ✅ Para empezar cualquier proyecto:

- [ ] Estado actual de cada repositorio (git log --oneline -10)
- [ ] Versión actual de edugo-shared publicada
- [ ] Lista de features ya implementadas vs pendientes
- [ ] Estructura de carpetas actual de cada repo
- [ ] .env.example de cada proyecto

### ✅ Para edugo-shared:

- [ ] Decisión sobre estructura de pkg/evaluation
- [ ] Interfaces exactas requeridas
- [ ] Estrategia de versionado
- [ ] Ejemplo de cómo se usa desde otros proyectos

### ✅ Para api-mobile:

- [ ] Estructura exacta de Clean Architecture a usar
- [ ] Schemas de request/response para cada endpoint
- [ ] Estrategia de autenticación (cómo obtener user actual)
- [ ] Formato de errores estándar

### ✅ Para worker:

- [ ] Lista de processors existentes vs nuevos
- [ ] Schema de cada evento (entrada y salida)
- [ ] Prompts de OpenAI a usar
- [ ] Estrategia de manejo de errores

### ✅ Para api-admin:

- [ ] Modelo completo de jerarquía académica
- [ ] Sistema de permisos/roles
- [ ] Tipos de reportes requeridos

### ✅ Para dev-environment:

- [ ] Profiles disponibles y su uso
- [ ] Scripts de seeds con datos
- [ ] Configuración de cada servicio

---

## 🎯 CONCLUSIÓN

**Sin esta información, tendría que tomar demasiadas decisiones arquitectónicas** que podrían no alinearse con la visión del proyecto.

**Recomendación:** Crear un documento `TECHNICAL_DECISIONS.md` con todas estas definiciones antes de proceder con la implementación.

---

**Generado por:** Claude Code  
**Fecha:** 15 de Noviembre, 2025