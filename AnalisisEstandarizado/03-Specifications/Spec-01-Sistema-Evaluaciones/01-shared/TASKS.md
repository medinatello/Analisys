# 📋 Tareas - edugo-shared - Sistema de Evaluaciones

## 📍 Información del Proyecto
- **Repositorio**: edugo-shared
- **Branch**: feature/evaluation-module
- **Versión Target**: v1.3.0
- **Tiempo Estimado**: 3 días (24 horas)
- **Path de trabajo**: `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared`

## ✅ Pre-requisitos
```bash
# Verificar ambiente
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared
git status
go version  # Debe ser >= 1.21

# Crear branch de trabajo
git checkout main
git pull origin main
git checkout -b feature/evaluation-module
```

## 📝 TAREAS DETALLADAS

### TASK-001: Crear estructura del módulo evaluation
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 30min  

#### Pasos de Implementación:
```bash
# 1. Crear estructura de directorios
mkdir -p pkg/evaluation
cd pkg/evaluation

# 2. Crear archivos base
touch models.go interfaces.go repository.go service.go validators.go constants.go
touch evaluation_test.go

# 3. Crear estructura de tests
mkdir -p tests/mocks
touch tests/evaluation_integration_test.go
touch tests/mocks/mock_repository.go
```

#### Criterios de Aceptación:
- [ ] Estructura de carpetas creada
- [ ] Todos los archivos base creados
- [ ] Estructura sigue el patrón de otros módulos

#### Validación:
```bash
ls -la pkg/evaluation/
# Debe mostrar: models.go interfaces.go repository.go service.go validators.go constants.go
```

---

### TASK-002: Implementar modelos de datos (models.go)
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 2h  

#### Implementación:
```go
// pkg/evaluation/models.go
package evaluation

import (
    "time"
    "github.com/lib/pq"
    "gorm.io/gorm"
)

// Evaluation representa una evaluación en el sistema
type Evaluation struct {
    gorm.Model
    Title             string         `gorm:"type:varchar(255);not null" json:"title" validate:"required,min=3,max=255"`
    Description       string         `gorm:"type:text" json:"description"`
    MaterialID        *uint          `json:"material_id" gorm:"index"`
    SubjectID         *uint          `json:"subject_id" gorm:"index"`
    AcademicLevelID   *uint          `json:"academic_level_id" gorm:"index"`
    CreatedBy         uint           `json:"created_by" gorm:"not null;index"`
    DurationMinutes   int            `json:"duration_minutes" gorm:"default:60"`
    PassingScore      float64        `json:"passing_score" gorm:"type:decimal(5,2);default:60.00"`
    MaxAttempts       int            `json:"max_attempts" gorm:"default:1"`
    ShuffleQuestions  bool           `json:"shuffle_questions" gorm:"default:false"`
    ShowResultsImmediately bool      `json:"show_results_immediately" gorm:"default:true"`
    Status            EvaluationStatus `json:"status" gorm:"type:varchar(20);default:'draft'"`
    Questions         []EvaluationQuestion `json:"questions,omitempty" gorm:"foreignKey:EvaluationID"`
    Sessions          []EvaluationSession  `json:"sessions,omitempty" gorm:"foreignKey:EvaluationID"`
}

// EvaluationQuestion representa una pregunta de evaluación
type EvaluationQuestion struct {
    gorm.Model
    EvaluationID  uint         `json:"evaluation_id" gorm:"not null;index"`
    QuestionText  string       `json:"question_text" gorm:"type:text;not null" validate:"required"`
    QuestionType  QuestionType `json:"question_type" gorm:"type:varchar(20);not null" validate:"required,oneof=multiple_choice true_false short_answer essay"`
    Points        float64      `json:"points" gorm:"type:decimal(5,2);default:1.00"`
    OrderIndex    int          `json:"order_index"`
    Required      bool         `json:"required" gorm:"default:true"`
    Explanation   string       `json:"explanation" gorm:"type:text"`
    Options       []QuestionOption `json:"options,omitempty" gorm:"foreignKey:QuestionID"`
}

// QuestionOption representa una opción de respuesta
type QuestionOption struct {
    gorm.Model
    QuestionID  uint   `json:"question_id" gorm:"not null;index"`
    OptionText  string `json:"option_text" gorm:"type:text;not null" validate:"required"`
    IsCorrect   bool   `json:"is_correct" gorm:"default:false"`
    OrderIndex  int    `json:"order_index"`
}

// EvaluationSession representa un intento de evaluación
type EvaluationSession struct {
    gorm.Model
    EvaluationID     uint          `json:"evaluation_id" gorm:"not null;index"`
    StudentID        uint          `json:"student_id" gorm:"not null;index"`
    StartedAt        time.Time     `json:"started_at" gorm:"default:CURRENT_TIMESTAMP"`
    SubmittedAt      *time.Time    `json:"submitted_at"`
    TimeSpentSeconds int           `json:"time_spent_seconds"`
    Status           SessionStatus `json:"status" gorm:"type:varchar(20);default:'in_progress'"`
    AttemptNumber    int           `json:"attempt_number" gorm:"default:1"`
    IPAddress        string        `json:"ip_address" gorm:"type:inet"`
    UserAgent        string        `json:"user_agent" gorm:"type:text"`
    Answers          []StudentAnswer `json:"answers,omitempty" gorm:"foreignKey:SessionID"`
    Result           *EvaluationResult `json:"result,omitempty" gorm:"foreignKey:SessionID"`
}

// StudentAnswer representa la respuesta de un estudiante
type StudentAnswer struct {
    gorm.Model
    SessionID        uint       `json:"session_id" gorm:"not null;index"`
    QuestionID       uint       `json:"question_id" gorm:"not null;index"`
    AnswerText       string     `json:"answer_text" gorm:"type:text"`
    SelectedOptionID *uint      `json:"selected_option_id"`
    IsCorrect        *bool      `json:"is_correct"`
    PointsEarned     float64    `json:"points_earned" gorm:"type:decimal(5,2)"`
    GradedAt         *time.Time `json:"graded_at"`
    AIFeedback       string     `json:"ai_feedback" gorm:"type:text"`
}

// EvaluationResult representa el resultado agregado
type EvaluationResult struct {
    gorm.Model
    SessionID    uint                   `json:"session_id" gorm:"not null;unique;index"`
    TotalScore   float64                `json:"total_score" gorm:"type:decimal(5,2)"`
    Percentage   float64                `json:"percentage" gorm:"type:decimal(5,2)"`
    Passed       bool                   `json:"passed"`
    Ranking      int                    `json:"ranking"`
    Strengths    pq.StringArray         `json:"strengths" gorm:"type:text[]"`
    Weaknesses   pq.StringArray         `json:"weaknesses" gorm:"type:text[]"`
    AIAnalysis   string                 `json:"ai_analysis" gorm:"type:text"`
}

// DTOs para request/response

// CreateEvaluationRequest DTO para crear evaluación
type CreateEvaluationRequest struct {
    Title                  string                    `json:"title" validate:"required,min=3,max=255"`
    Description           string                     `json:"description"`
    MaterialID            *uint                      `json:"material_id"`
    SubjectID             *uint                      `json:"subject_id"`
    AcademicLevelID       *uint                      `json:"academic_level_id"`
    DurationMinutes       int                        `json:"duration_minutes" validate:"min=1,max=480"`
    PassingScore          float64                    `json:"passing_score" validate:"min=0,max=100"`
    MaxAttempts           int                        `json:"max_attempts" validate:"min=1,max=10"`
    ShuffleQuestions      bool                       `json:"shuffle_questions"`
    ShowResultsImmediately bool                      `json:"show_results_immediately"`
    Questions             []CreateQuestionRequest    `json:"questions" validate:"required,min=1,dive"`
}

// CreateQuestionRequest DTO para crear pregunta
type CreateQuestionRequest struct {
    QuestionText string                  `json:"question_text" validate:"required"`
    QuestionType QuestionType            `json:"question_type" validate:"required,oneof=multiple_choice true_false short_answer essay"`
    Points       float64                 `json:"points" validate:"min=0,max=100"`
    Required     bool                    `json:"required"`
    Explanation  string                  `json:"explanation"`
    Options      []CreateOptionRequest   `json:"options" validate:"required_if=QuestionType multiple_choice,dive"`
}

// CreateOptionRequest DTO para crear opción
type CreateOptionRequest struct {
    OptionText string `json:"option_text" validate:"required"`
    IsCorrect  bool   `json:"is_correct"`
}

// SubmitAnswerRequest DTO para enviar respuesta
type SubmitAnswerRequest struct {
    QuestionID       uint   `json:"question_id" validate:"required"`
    AnswerText       string `json:"answer_text"`
    SelectedOptionID *uint  `json:"selected_option_id"`
}

// EvaluationResultResponse DTO para resultado
type EvaluationResultResponse struct {
    SessionID      uint      `json:"session_id"`
    TotalScore     float64   `json:"total_score"`
    Percentage     float64   `json:"percentage"`
    Passed         bool      `json:"passed"`
    Ranking        int       `json:"ranking"`
    Strengths      []string  `json:"strengths"`
    Weaknesses     []string  `json:"weaknesses"`
    AIAnalysis     string    `json:"ai_analysis"`
    CompletedAt    time.Time `json:"completed_at"`
}

// TableName especifica el nombre de las tablas
func (Evaluation) TableName() string { return "evaluations" }
func (EvaluationQuestion) TableName() string { return "evaluation_questions" }
func (QuestionOption) TableName() string { return "question_options" }
func (EvaluationSession) TableName() string { return "evaluation_sessions" }
func (StudentAnswer) TableName() string { return "student_answers" }
func (EvaluationResult) TableName() string { return "evaluation_results" }
```

#### Criterios de Aceptación:
- [ ] Todos los modelos definidos con tags GORM
- [ ] Validaciones agregadas con validator tags
- [ ] DTOs para request/response creados
- [ ] TableName methods implementados

#### Validación:
```bash
go build ./pkg/evaluation/
# No debe haber errores de compilación
```

---

### TASK-003: Implementar constantes y enums (constants.go)
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 30min  

#### Implementación:
```go
// pkg/evaluation/constants.go
package evaluation

// EvaluationStatus representa el estado de una evaluación
type EvaluationStatus string

const (
    EvaluationStatusDraft     EvaluationStatus = "draft"
    EvaluationStatusPublished EvaluationStatus = "published"
    EvaluationStatusArchived  EvaluationStatus = "archived"
    EvaluationStatusDeleted   EvaluationStatus = "deleted"
)

// QuestionType representa el tipo de pregunta
type QuestionType string

const (
    QuestionTypeMultipleChoice QuestionType = "multiple_choice"
    QuestionTypeTrueFalse      QuestionType = "true_false"
    QuestionTypeShortAnswer    QuestionType = "short_answer"
    QuestionTypeEssay          QuestionType = "essay"
)

// SessionStatus representa el estado de una sesión
type SessionStatus string

const (
    SessionStatusInProgress SessionStatus = "in_progress"
    SessionStatusSubmitted  SessionStatus = "submitted"
    SessionStatusGraded     SessionStatus = "graded"
    SessionStatusExpired    SessionStatus = "expired"
)

// Event types para RabbitMQ
const (
    EventEvaluationCreated   = "evaluation.created"
    EventEvaluationUpdated   = "evaluation.updated"
    EventEvaluationDeleted   = "evaluation.deleted"
    EventEvaluationStarted   = "evaluation.started"
    EventEvaluationSubmitted = "evaluation.submitted"
    EventEvaluationGraded    = "evaluation.graded"
    EventGenerateWithAI      = "evaluation.generate_ai"
)

// Error messages
const (
    ErrEvaluationNotFound        = "evaluation not found"
    ErrQuestionNotFound          = "question not found"
    ErrSessionNotFound           = "session not found"
    ErrMaxAttemptsReached        = "maximum attempts reached"
    ErrEvaluationExpired         = "evaluation time expired"
    ErrInvalidQuestionType       = "invalid question type"
    ErrNoCorrectOptionProvided   = "at least one correct option is required"
    ErrSessionAlreadySubmitted   = "session already submitted"
    ErrUnauthorizedAccess        = "unauthorized access to evaluation"
)

// Default values
const (
    DefaultDurationMinutes      = 60
    DefaultPassingScore         = 60.0
    DefaultMaxAttempts          = 1
    DefaultPointsPerQuestion    = 1.0
    MaxQuestionTextLength       = 5000
    MaxOptionTextLength         = 1000
    MaxAnswerTextLength         = 10000
)

// Validation rules
const (
    MinTitleLength         = 3
    MaxTitleLength         = 255
    MinQuestions           = 1
    MaxQuestions           = 100
    MinOptions             = 2
    MaxOptions             = 10
    MinDurationMinutes     = 1
    MaxDurationMinutes     = 480
)

// IsValid verifica si el status es válido
func (s EvaluationStatus) IsValid() bool {
    switch s {
    case EvaluationStatusDraft, EvaluationStatusPublished, EvaluationStatusArchived, EvaluationStatusDeleted:
        return true
    }
    return false
}

// IsValid verifica si el tipo de pregunta es válido
func (q QuestionType) IsValid() bool {
    switch q {
    case QuestionTypeMultipleChoice, QuestionTypeTrueFalse, QuestionTypeShortAnswer, QuestionTypeEssay:
        return true
    }
    return false
}

// RequiresOptions indica si el tipo de pregunta requiere opciones
func (q QuestionType) RequiresOptions() bool {
    return q == QuestionTypeMultipleChoice || q == QuestionTypeTrueFalse
}

// IsValid verifica si el estado de sesión es válido
func (s SessionStatus) IsValid() bool {
    switch s {
    case SessionStatusInProgress, SessionStatusSubmitted, SessionStatusGraded, SessionStatusExpired:
        return true
    }
    return false
}

// CanBeGraded indica si la sesión puede ser calificada
func (s SessionStatus) CanBeGraded() bool {
    return s == SessionStatusSubmitted
}
```

#### Criterios de Aceptación:
- [ ] Enums definidos para todos los estados
- [ ] Constantes de eventos para RabbitMQ
- [ ] Mensajes de error estandarizados
- [ ] Valores por defecto definidos
- [ ] Métodos de validación implementados

---

### TASK-004: Implementar interfaces (interfaces.go)
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 1h  

#### Implementación:
```go
// pkg/evaluation/interfaces.go
package evaluation

import (
    "context"
)

// Repository define las operaciones de acceso a datos
type Repository interface {
    // Evaluations
    CreateEvaluation(ctx context.Context, evaluation *Evaluation) error
    GetEvaluationByID(ctx context.Context, id uint) (*Evaluation, error)
    UpdateEvaluation(ctx context.Context, evaluation *Evaluation) error
    DeleteEvaluation(ctx context.Context, id uint) error
    ListEvaluations(ctx context.Context, filters map[string]interface{}, offset, limit int) ([]*Evaluation, int64, error)
    GetEvaluationWithQuestions(ctx context.Context, id uint) (*Evaluation, error)
    
    // Questions
    CreateQuestion(ctx context.Context, question *EvaluationQuestion) error
    UpdateQuestion(ctx context.Context, question *EvaluationQuestion) error
    DeleteQuestion(ctx context.Context, id uint) error
    CreateQuestionOptions(ctx context.Context, options []QuestionOption) error
    
    // Sessions
    CreateSession(ctx context.Context, session *EvaluationSession) error
    GetSessionByID(ctx context.Context, id uint) (*EvaluationSession, error)
    UpdateSession(ctx context.Context, session *EvaluationSession) error
    GetUserSessions(ctx context.Context, userID, evaluationID uint) ([]*EvaluationSession, error)
    CountUserAttempts(ctx context.Context, userID, evaluationID uint) (int, error)
    
    // Answers
    SaveAnswer(ctx context.Context, answer *StudentAnswer) error
    GetSessionAnswers(ctx context.Context, sessionID uint) ([]*StudentAnswer, error)
    BulkSaveAnswers(ctx context.Context, answers []*StudentAnswer) error
    
    // Results
    SaveResult(ctx context.Context, result *EvaluationResult) error
    GetResult(ctx context.Context, sessionID uint) (*EvaluationResult, error)
    GetEvaluationResults(ctx context.Context, evaluationID uint) ([]*EvaluationResult, error)
    GetUserResults(ctx context.Context, userID uint) ([]*EvaluationResult, error)
}

// Service define la lógica de negocio
type Service interface {
    // Evaluation management
    CreateEvaluation(ctx context.Context, req *CreateEvaluationRequest, createdBy uint) (*Evaluation, error)
    GetEvaluation(ctx context.Context, id uint, userID uint, role string) (*Evaluation, error)
    UpdateEvaluation(ctx context.Context, id uint, req *CreateEvaluationRequest, updatedBy uint) error
    DeleteEvaluation(ctx context.Context, id uint, deletedBy uint) error
    ListEvaluations(ctx context.Context, filters map[string]interface{}, page, pageSize int) ([]*Evaluation, int64, error)
    
    // Question management
    AddQuestion(ctx context.Context, evaluationID uint, req *CreateQuestionRequest) (*EvaluationQuestion, error)
    UpdateQuestion(ctx context.Context, questionID uint, req *CreateQuestionRequest) error
    RemoveQuestion(ctx context.Context, questionID uint) error
    
    // Session management
    StartEvaluation(ctx context.Context, evaluationID, studentID uint, ipAddress, userAgent string) (*EvaluationSession, error)
    SubmitAnswer(ctx context.Context, sessionID uint, req *SubmitAnswerRequest) error
    SubmitEvaluation(ctx context.Context, sessionID uint) error
    
    // Results
    GetSessionResult(ctx context.Context, sessionID, userID uint, role string) (*EvaluationResultResponse, error)
    GetEvaluationStatistics(ctx context.Context, evaluationID uint) (map[string]interface{}, error)
    GetUserHistory(ctx context.Context, userID uint) ([]*EvaluationResultResponse, error)
    
    // AI operations
    GenerateQuestionsWithAI(ctx context.Context, materialID uint, count int) ([]*CreateQuestionRequest, error)
    AnalyzeResponsesWithAI(ctx context.Context, sessionID uint) (string, error)
}

// EventPublisher define la interfaz para publicar eventos
type EventPublisher interface {
    PublishEvaluationCreated(ctx context.Context, evaluation *Evaluation) error
    PublishEvaluationStarted(ctx context.Context, session *EvaluationSession) error
    PublishEvaluationSubmitted(ctx context.Context, sessionID uint) error
    PublishEvaluationGraded(ctx context.Context, result *EvaluationResult) error
    PublishGenerateWithAI(ctx context.Context, evaluationID uint, prompt string) error
}

// Validator define las validaciones
type Validator interface {
    ValidateEvaluation(evaluation *CreateEvaluationRequest) error
    ValidateQuestion(question *CreateQuestionRequest) error
    ValidateAnswer(answer *SubmitAnswerRequest, questionType QuestionType) error
    ValidateSessionSubmission(session *EvaluationSession) error
}

// Grader define la interfaz para calificar evaluaciones
type Grader interface {
    GradeMultipleChoice(answer *StudentAnswer, question *EvaluationQuestion) (float64, bool)
    GradeTrueFalse(answer *StudentAnswer, question *EvaluationQuestion) (float64, bool)
    GradeShortAnswer(answer *StudentAnswer, question *EvaluationQuestion, useAI bool) (float64, bool, error)
    GradeEssay(answer *StudentAnswer, question *EvaluationQuestion) (float64, string, error)
    CalculateFinalScore(answers []*StudentAnswer) (float64, float64, bool)
}

// Cache define operaciones de cache
type Cache interface {
    SetSession(ctx context.Context, sessionID uint, session *EvaluationSession) error
    GetSession(ctx context.Context, sessionID uint) (*EvaluationSession, error)
    SetEvaluation(ctx context.Context, evaluationID uint, evaluation *Evaluation) error
    GetEvaluation(ctx context.Context, evaluationID uint) (*Evaluation, error)
    InvalidateEvaluation(ctx context.Context, evaluationID uint) error
}

// AIClient define la interfaz para operaciones con IA
type AIClient interface {
    GenerateQuestions(ctx context.Context, content string, count int, level string) ([]*CreateQuestionRequest, error)
    AnalyzeResponse(ctx context.Context, question, answer string) (feedback string, score float64, error)
    GenerateFeedback(ctx context.Context, answers []*StudentAnswer) (string, []string, []string, error)
}
```

#### Criterios de Aceptación:
- [ ] Interfaces para Repository, Service, EventPublisher
- [ ] Interfaces para Validator, Grader, Cache
- [ ] Interface para AIClient
- [ ] Métodos cubren todos los casos de uso

---

### TASK-005: Implementar repository (repository.go)
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:
```go
// pkg/evaluation/repository.go
package evaluation

import (
    "context"
    "errors"
    "fmt"
    "gorm.io/gorm"
)

// GormRepository implementa Repository usando GORM
type GormRepository struct {
    db *gorm.DB
}

// NewGormRepository crea una nueva instancia del repositorio
func NewGormRepository(db *gorm.DB) Repository {
    return &GormRepository{db: db}
}

// CreateEvaluation crea una nueva evaluación
func (r *GormRepository) CreateEvaluation(ctx context.Context, evaluation *Evaluation) error {
    return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
        // Crear la evaluación
        if err := tx.Create(evaluation).Error; err != nil {
            return fmt.Errorf("failed to create evaluation: %w", err)
        }
        
        // Si hay preguntas, crearlas también
        if len(evaluation.Questions) > 0 {
            for i := range evaluation.Questions {
                evaluation.Questions[i].EvaluationID = evaluation.ID
                if err := tx.Create(&evaluation.Questions[i]).Error; err != nil {
                    return fmt.Errorf("failed to create question: %w", err)
                }
                
                // Crear opciones si existen
                if len(evaluation.Questions[i].Options) > 0 {
                    for j := range evaluation.Questions[i].Options {
                        evaluation.Questions[i].Options[j].QuestionID = evaluation.Questions[i].ID
                    }
                    if err := tx.Create(&evaluation.Questions[i].Options).Error; err != nil {
                        return fmt.Errorf("failed to create options: %w", err)
                    }
                }
            }
        }
        
        return nil
    })
}

// GetEvaluationByID obtiene una evaluación por ID
func (r *GormRepository) GetEvaluationByID(ctx context.Context, id uint) (*Evaluation, error) {
    var evaluation Evaluation
    err := r.db.WithContext(ctx).
        Where("id = ? AND status != ?", id, EvaluationStatusDeleted).
        First(&evaluation).Error
    
    if err != nil {
        if errors.Is(err, gorm.ErrRecordNotFound) {
            return nil, fmt.Errorf("%s: %d", ErrEvaluationNotFound, id)
        }
        return nil, fmt.Errorf("failed to get evaluation: %w", err)
    }
    
    return &evaluation, nil
}

// UpdateEvaluation actualiza una evaluación
func (r *GormRepository) UpdateEvaluation(ctx context.Context, evaluation *Evaluation) error {
    result := r.db.WithContext(ctx).
        Model(&Evaluation{}).
        Where("id = ? AND status != ?", evaluation.ID, EvaluationStatusDeleted).
        Updates(evaluation)
    
    if result.Error != nil {
        return fmt.Errorf("failed to update evaluation: %w", result.Error)
    }
    
    if result.RowsAffected == 0 {
        return fmt.Errorf("%s: %d", ErrEvaluationNotFound, evaluation.ID)
    }
    
    return nil
}

// DeleteEvaluation elimina lógicamente una evaluación
func (r *GormRepository) DeleteEvaluation(ctx context.Context, id uint) error {
    result := r.db.WithContext(ctx).
        Model(&Evaluation{}).
        Where("id = ?", id).
        Update("status", EvaluationStatusDeleted)
    
    if result.Error != nil {
        return fmt.Errorf("failed to delete evaluation: %w", result.Error)
    }
    
    if result.RowsAffected == 0 {
        return fmt.Errorf("%s: %d", ErrEvaluationNotFound, id)
    }
    
    return nil
}

// ListEvaluations lista evaluaciones con filtros y paginación
func (r *GormRepository) ListEvaluations(ctx context.Context, filters map[string]interface{}, offset, limit int) ([]*Evaluation, int64, error) {
    var evaluations []*Evaluation
    var total int64
    
    query := r.db.WithContext(ctx).Model(&Evaluation{}).
        Where("status != ?", EvaluationStatusDeleted)
    
    // Aplicar filtros
    for key, value := range filters {
        switch key {
        case "subject_id", "academic_level_id", "created_by":
            query = query.Where(fmt.Sprintf("%s = ?", key), value)
        case "status":
            query = query.Where("status = ?", value)
        case "search":
            searchTerm := fmt.Sprintf("%%%s%%", value)
            query = query.Where("title ILIKE ? OR description ILIKE ?", searchTerm, searchTerm)
        }
    }
    
    // Contar total
    if err := query.Count(&total).Error; err != nil {
        return nil, 0, fmt.Errorf("failed to count evaluations: %w", err)
    }
    
    // Obtener resultados paginados
    err := query.
        Offset(offset).
        Limit(limit).
        Order("created_at DESC").
        Find(&evaluations).Error
    
    if err != nil {
        return nil, 0, fmt.Errorf("failed to list evaluations: %w", err)
    }
    
    return evaluations, total, nil
}

// GetEvaluationWithQuestions obtiene una evaluación con sus preguntas
func (r *GormRepository) GetEvaluationWithQuestions(ctx context.Context, id uint) (*Evaluation, error) {
    var evaluation Evaluation
    err := r.db.WithContext(ctx).
        Preload("Questions", func(db *gorm.DB) *gorm.DB {
            return db.Order("order_index ASC")
        }).
        Preload("Questions.Options", func(db *gorm.DB) *gorm.DB {
            return db.Order("order_index ASC")
        }).
        Where("id = ? AND status != ?", id, EvaluationStatusDeleted).
        First(&evaluation).Error
    
    if err != nil {
        if errors.Is(err, gorm.ErrRecordNotFound) {
            return nil, fmt.Errorf("%s: %d", ErrEvaluationNotFound, id)
        }
        return nil, fmt.Errorf("failed to get evaluation with questions: %w", err)
    }
    
    return &evaluation, nil
}

// CreateQuestion crea una nueva pregunta
func (r *GormRepository) CreateQuestion(ctx context.Context, question *EvaluationQuestion) error {
    return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
        // Obtener el siguiente order_index
        var maxOrder int
        tx.Model(&EvaluationQuestion{}).
            Where("evaluation_id = ?", question.EvaluationID).
            Select("COALESCE(MAX(order_index), 0)").
            Scan(&maxOrder)
        
        question.OrderIndex = maxOrder + 1
        
        // Crear la pregunta
        if err := tx.Create(question).Error; err != nil {
            return fmt.Errorf("failed to create question: %w", err)
        }
        
        // Crear opciones si existen
        if len(question.Options) > 0 {
            for i := range question.Options {
                question.Options[i].QuestionID = question.ID
            }
            if err := tx.Create(&question.Options).Error; err != nil {
                return fmt.Errorf("failed to create options: %w", err)
            }
        }
        
        return nil
    })
}

// UpdateQuestion actualiza una pregunta
func (r *GormRepository) UpdateQuestion(ctx context.Context, question *EvaluationQuestion) error {
    return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
        // Actualizar pregunta
        if err := tx.Updates(question).Error; err != nil {
            return fmt.Errorf("failed to update question: %w", err)
        }
        
        // Si hay opciones, eliminar las antiguas y crear las nuevas
        if len(question.Options) > 0 {
            // Eliminar opciones antiguas
            if err := tx.Where("question_id = ?", question.ID).Delete(&QuestionOption{}).Error; err != nil {
                return fmt.Errorf("failed to delete old options: %w", err)
            }
            
            // Crear nuevas opciones
            for i := range question.Options {
                question.Options[i].QuestionID = question.ID
            }
            if err := tx.Create(&question.Options).Error; err != nil {
                return fmt.Errorf("failed to create new options: %w", err)
            }
        }
        
        return nil
    })
}

// DeleteQuestion elimina una pregunta
func (r *GormRepository) DeleteQuestion(ctx context.Context, id uint) error {
    result := r.db.WithContext(ctx).Delete(&EvaluationQuestion{}, id)
    
    if result.Error != nil {
        return fmt.Errorf("failed to delete question: %w", result.Error)
    }
    
    if result.RowsAffected == 0 {
        return fmt.Errorf("%s: %d", ErrQuestionNotFound, id)
    }
    
    return nil
}

// CreateQuestionOptions crea opciones para una pregunta
func (r *GormRepository) CreateQuestionOptions(ctx context.Context, options []QuestionOption) error {
    if len(options) == 0 {
        return nil
    }
    
    if err := r.db.WithContext(ctx).Create(&options).Error; err != nil {
        return fmt.Errorf("failed to create options: %w", err)
    }
    
    return nil
}

// CreateSession crea una nueva sesión de evaluación
func (r *GormRepository) CreateSession(ctx context.Context, session *EvaluationSession) error {
    if err := r.db.WithContext(ctx).Create(session).Error; err != nil {
        return fmt.Errorf("failed to create session: %w", err)
    }
    return nil
}

// GetSessionByID obtiene una sesión por ID
func (r *GormRepository) GetSessionByID(ctx context.Context, id uint) (*EvaluationSession, error) {
    var session EvaluationSession
    err := r.db.WithContext(ctx).
        Preload("Answers").
        Preload("Result").
        First(&session, id).Error
    
    if err != nil {
        if errors.Is(err, gorm.ErrRecordNotFound) {
            return nil, fmt.Errorf("%s: %d", ErrSessionNotFound, id)
        }
        return nil, fmt.Errorf("failed to get session: %w", err)
    }
    
    return &session, nil
}

// UpdateSession actualiza una sesión
func (r *GormRepository) UpdateSession(ctx context.Context, session *EvaluationSession) error {
    result := r.db.WithContext(ctx).Updates(session)
    
    if result.Error != nil {
        return fmt.Errorf("failed to update session: %w", result.Error)
    }
    
    if result.RowsAffected == 0 {
        return fmt.Errorf("%s: %d", ErrSessionNotFound, session.ID)
    }
    
    return nil
}

// GetUserSessions obtiene las sesiones de un usuario para una evaluación
func (r *GormRepository) GetUserSessions(ctx context.Context, userID, evaluationID uint) ([]*EvaluationSession, error) {
    var sessions []*EvaluationSession
    err := r.db.WithContext(ctx).
        Where("student_id = ? AND evaluation_id = ?", userID, evaluationID).
        Order("created_at DESC").
        Find(&sessions).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get user sessions: %w", err)
    }
    
    return sessions, nil
}

// CountUserAttempts cuenta los intentos de un usuario
func (r *GormRepository) CountUserAttempts(ctx context.Context, userID, evaluationID uint) (int, error) {
    var count int64
    err := r.db.WithContext(ctx).
        Model(&EvaluationSession{}).
        Where("student_id = ? AND evaluation_id = ? AND status != ?", 
            userID, evaluationID, SessionStatusExpired).
        Count(&count).Error
    
    if err != nil {
        return 0, fmt.Errorf("failed to count attempts: %w", err)
    }
    
    return int(count), nil
}

// SaveAnswer guarda una respuesta
func (r *GormRepository) SaveAnswer(ctx context.Context, answer *StudentAnswer) error {
    // Verificar si ya existe una respuesta
    var existing StudentAnswer
    err := r.db.WithContext(ctx).
        Where("session_id = ? AND question_id = ?", answer.SessionID, answer.QuestionID).
        First(&existing).Error
    
    if err == nil {
        // Actualizar respuesta existente
        answer.ID = existing.ID
        return r.db.WithContext(ctx).Save(answer).Error
    }
    
    // Crear nueva respuesta
    return r.db.WithContext(ctx).Create(answer).Error
}

// GetSessionAnswers obtiene las respuestas de una sesión
func (r *GormRepository) GetSessionAnswers(ctx context.Context, sessionID uint) ([]*StudentAnswer, error) {
    var answers []*StudentAnswer
    err := r.db.WithContext(ctx).
        Where("session_id = ?", sessionID).
        Find(&answers).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get answers: %w", err)
    }
    
    return answers, nil
}

// BulkSaveAnswers guarda múltiples respuestas
func (r *GormRepository) BulkSaveAnswers(ctx context.Context, answers []*StudentAnswer) error {
    if len(answers) == 0 {
        return nil
    }
    
    return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
        for _, answer := range answers {
            if err := tx.Save(answer).Error; err != nil {
                return fmt.Errorf("failed to save answer: %w", err)
            }
        }
        return nil
    })
}

// SaveResult guarda el resultado de una evaluación
func (r *GormRepository) SaveResult(ctx context.Context, result *EvaluationResult) error {
    return r.db.WithContext(ctx).Create(result).Error
}

// GetResult obtiene el resultado de una sesión
func (r *GormRepository) GetResult(ctx context.Context, sessionID uint) (*EvaluationResult, error) {
    var result EvaluationResult
    err := r.db.WithContext(ctx).
        Where("session_id = ?", sessionID).
        First(&result).Error
    
    if err != nil {
        if errors.Is(err, gorm.ErrRecordNotFound) {
            return nil, nil // No error, just no result yet
        }
        return nil, fmt.Errorf("failed to get result: %w", err)
    }
    
    return &result, nil
}

// GetEvaluationResults obtiene todos los resultados de una evaluación
func (r *GormRepository) GetEvaluationResults(ctx context.Context, evaluationID uint) ([]*EvaluationResult, error) {
    var results []*EvaluationResult
    err := r.db.WithContext(ctx).
        Joins("JOIN evaluation_sessions ON evaluation_results.session_id = evaluation_sessions.id").
        Where("evaluation_sessions.evaluation_id = ?", evaluationID).
        Order("evaluation_results.percentage DESC").
        Find(&results).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get evaluation results: %w", err)
    }
    
    return results, nil
}

// GetUserResults obtiene los resultados de un usuario
func (r *GormRepository) GetUserResults(ctx context.Context, userID uint) ([]*EvaluationResult, error) {
    var results []*EvaluationResult
    err := r.db.WithContext(ctx).
        Joins("JOIN evaluation_sessions ON evaluation_results.session_id = evaluation_sessions.id").
        Where("evaluation_sessions.student_id = ?", userID).
        Order("evaluation_results.created_at DESC").
        Find(&results).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get user results: %w", err)
    }
    
    return results, nil
}
```

#### Criterios de Aceptación:
- [ ] Todos los métodos de la interfaz Repository implementados
- [ ] Manejo de transacciones donde sea necesario
- [ ] Manejo de errores consistente
- [ ] Soft delete implementado para evaluaciones

---

### TASK-006: Implementar service (service.go)
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:
```go
// pkg/evaluation/service.go
package evaluation

import (
    "context"
    "fmt"
    "time"
)

// ServiceImpl implementa la interfaz Service
type ServiceImpl struct {
    repo      Repository
    validator Validator
    grader    Grader
    publisher EventPublisher
    cache     Cache
    aiClient  AIClient
}

// NewService crea una nueva instancia del servicio
func NewService(
    repo Repository,
    validator Validator,
    grader Grader,
    publisher EventPublisher,
    cache Cache,
    aiClient AIClient,
) Service {
    return &ServiceImpl{
        repo:      repo,
        validator: validator,
        grader:    grader,
        publisher: publisher,
        cache:     cache,
        aiClient:  aiClient,
    }
}

// CreateEvaluation crea una nueva evaluación
func (s *ServiceImpl) CreateEvaluation(ctx context.Context, req *CreateEvaluationRequest, createdBy uint) (*Evaluation, error) {
    // Validar request
    if err := s.validator.ValidateEvaluation(req); err != nil {
        return nil, fmt.Errorf("validation failed: %w", err)
    }
    
    // Construir modelo
    evaluation := &Evaluation{
        Title:                  req.Title,
        Description:           req.Description,
        MaterialID:            req.MaterialID,
        SubjectID:             req.SubjectID,
        AcademicLevelID:       req.AcademicLevelID,
        CreatedBy:             createdBy,
        DurationMinutes:       req.DurationMinutes,
        PassingScore:          req.PassingScore,
        MaxAttempts:           req.MaxAttempts,
        ShuffleQuestions:      req.ShuffleQuestions,
        ShowResultsImmediately: req.ShowResultsImmediately,
        Status:                EvaluationStatusDraft,
    }
    
    // Agregar preguntas
    for i, q := range req.Questions {
        question := EvaluationQuestion{
            QuestionText: q.QuestionText,
            QuestionType: q.QuestionType,
            Points:       q.Points,
            OrderIndex:   i + 1,
            Required:     q.Required,
            Explanation:  q.Explanation,
        }
        
        // Agregar opciones si es necesario
        if q.QuestionType.RequiresOptions() {
            for j, opt := range q.Options {
                question.Options = append(question.Options, QuestionOption{
                    OptionText: opt.OptionText,
                    IsCorrect:  opt.IsCorrect,
                    OrderIndex: j + 1,
                })
            }
        }
        
        evaluation.Questions = append(evaluation.Questions, question)
    }
    
    // Guardar en base de datos
    if err := s.repo.CreateEvaluation(ctx, evaluation); err != nil {
        return nil, fmt.Errorf("failed to create evaluation: %w", err)
    }
    
    // Publicar evento
    if err := s.publisher.PublishEvaluationCreated(ctx, evaluation); err != nil {
        // Log error but don't fail
        fmt.Printf("failed to publish event: %v\n", err)
    }
    
    // Cachear
    if s.cache != nil {
        _ = s.cache.SetEvaluation(ctx, evaluation.ID, evaluation)
    }
    
    return evaluation, nil
}

// GetEvaluation obtiene una evaluación
func (s *ServiceImpl) GetEvaluation(ctx context.Context, id uint, userID uint, role string) (*Evaluation, error) {
    // Intentar obtener de cache
    if s.cache != nil {
        if cached, err := s.cache.GetEvaluation(ctx, id); err == nil && cached != nil {
            return cached, nil
        }
    }
    
    // Obtener de base de datos
    evaluation, err := s.repo.GetEvaluationWithQuestions(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // Verificar permisos
    if role == "student" && evaluation.Status != EvaluationStatusPublished {
        return nil, fmt.Errorf(ErrUnauthorizedAccess)
    }
    
    // Cachear
    if s.cache != nil {
        _ = s.cache.SetEvaluation(ctx, id, evaluation)
    }
    
    return evaluation, nil
}

// UpdateEvaluation actualiza una evaluación
func (s *ServiceImpl) UpdateEvaluation(ctx context.Context, id uint, req *CreateEvaluationRequest, updatedBy uint) error {
    // Validar request
    if err := s.validator.ValidateEvaluation(req); err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }
    
    // Verificar que existe
    existing, err := s.repo.GetEvaluationByID(ctx, id)
    if err != nil {
        return err
    }
    
    // Actualizar campos
    existing.Title = req.Title
    existing.Description = req.Description
    existing.MaterialID = req.MaterialID
    existing.SubjectID = req.SubjectID
    existing.AcademicLevelID = req.AcademicLevelID
    existing.DurationMinutes = req.DurationMinutes
    existing.PassingScore = req.PassingScore
    existing.MaxAttempts = req.MaxAttempts
    existing.ShuffleQuestions = req.ShuffleQuestions
    existing.ShowResultsImmediately = req.ShowResultsImmediately
    
    // Actualizar en base de datos
    if err := s.repo.UpdateEvaluation(ctx, existing); err != nil {
        return fmt.Errorf("failed to update evaluation: %w", err)
    }
    
    // Invalidar cache
    if s.cache != nil {
        _ = s.cache.InvalidateEvaluation(ctx, id)
    }
    
    // Publicar evento
    _ = s.publisher.PublishEvaluationUpdated(ctx, existing)
    
    return nil
}

// DeleteEvaluation elimina una evaluación
func (s *ServiceImpl) DeleteEvaluation(ctx context.Context, id uint, deletedBy uint) error {
    // Verificar que existe
    evaluation, err := s.repo.GetEvaluationByID(ctx, id)
    if err != nil {
        return err
    }
    
    // Verificar permisos (solo el creador o admin puede eliminar)
    if evaluation.CreatedBy != deletedBy {
        // TODO: Verificar si es admin
        return fmt.Errorf(ErrUnauthorizedAccess)
    }
    
    // Eliminar (soft delete)
    if err := s.repo.DeleteEvaluation(ctx, id); err != nil {
        return fmt.Errorf("failed to delete evaluation: %w", err)
    }
    
    // Invalidar cache
    if s.cache != nil {
        _ = s.cache.InvalidateEvaluation(ctx, id)
    }
    
    // Publicar evento
    evaluation.Status = EvaluationStatusDeleted
    _ = s.publisher.PublishEvaluationDeleted(ctx, evaluation)
    
    return nil
}

// ListEvaluations lista evaluaciones
func (s *ServiceImpl) ListEvaluations(ctx context.Context, filters map[string]interface{}, page, pageSize int) ([]*Evaluation, int64, error) {
    offset := (page - 1) * pageSize
    return s.repo.ListEvaluations(ctx, filters, offset, pageSize)
}

// AddQuestion agrega una pregunta a una evaluación
func (s *ServiceImpl) AddQuestion(ctx context.Context, evaluationID uint, req *CreateQuestionRequest) (*EvaluationQuestion, error) {
    // Validar pregunta
    if err := s.validator.ValidateQuestion(req); err != nil {
        return nil, fmt.Errorf("validation failed: %w", err)
    }
    
    // Verificar que la evaluación existe
    _, err := s.repo.GetEvaluationByID(ctx, evaluationID)
    if err != nil {
        return nil, err
    }
    
    // Crear pregunta
    question := &EvaluationQuestion{
        EvaluationID: evaluationID,
        QuestionText: req.QuestionText,
        QuestionType: req.QuestionType,
        Points:       req.Points,
        Required:     req.Required,
        Explanation:  req.Explanation,
    }
    
    // Agregar opciones si es necesario
    if req.QuestionType.RequiresOptions() {
        for i, opt := range req.Options {
            question.Options = append(question.Options, QuestionOption{
                OptionText: opt.OptionText,
                IsCorrect:  opt.IsCorrect,
                OrderIndex: i + 1,
            })
        }
    }
    
    // Guardar
    if err := s.repo.CreateQuestion(ctx, question); err != nil {
        return nil, fmt.Errorf("failed to add question: %w", err)
    }
    
    // Invalidar cache de evaluación
    if s.cache != nil {
        _ = s.cache.InvalidateEvaluation(ctx, evaluationID)
    }
    
    return question, nil
}

// UpdateQuestion actualiza una pregunta
func (s *ServiceImpl) UpdateQuestion(ctx context.Context, questionID uint, req *CreateQuestionRequest) error {
    // Validar pregunta
    if err := s.validator.ValidateQuestion(req); err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }
    
    // Construir modelo actualizado
    question := &EvaluationQuestion{
        QuestionText: req.QuestionText,
        QuestionType: req.QuestionType,
        Points:       req.Points,
        Required:     req.Required,
        Explanation:  req.Explanation,
    }
    question.ID = questionID
    
    // Agregar opciones si es necesario
    if req.QuestionType.RequiresOptions() {
        for i, opt := range req.Options {
            question.Options = append(question.Options, QuestionOption{
                OptionText: opt.OptionText,
                IsCorrect:  opt.IsCorrect,
                OrderIndex: i + 1,
            })
        }
    }
    
    // Actualizar
    return s.repo.UpdateQuestion(ctx, question)
}

// RemoveQuestion elimina una pregunta
func (s *ServiceImpl) RemoveQuestion(ctx context.Context, questionID uint) error {
    return s.repo.DeleteQuestion(ctx, questionID)
}

// StartEvaluation inicia una sesión de evaluación
func (s *ServiceImpl) StartEvaluation(ctx context.Context, evaluationID, studentID uint, ipAddress, userAgent string) (*EvaluationSession, error) {
    // Verificar que la evaluación existe y está publicada
    evaluation, err := s.repo.GetEvaluationByID(ctx, evaluationID)
    if err != nil {
        return nil, err
    }
    
    if evaluation.Status != EvaluationStatusPublished {
        return nil, fmt.Errorf("evaluation is not available")
    }
    
    // Verificar intentos máximos
    attempts, err := s.repo.CountUserAttempts(ctx, studentID, evaluationID)
    if err != nil {
        return nil, err
    }
    
    if attempts >= evaluation.MaxAttempts {
        return nil, fmt.Errorf(ErrMaxAttemptsReached)
    }
    
    // Crear sesión
    session := &EvaluationSession{
        EvaluationID:  evaluationID,
        StudentID:     studentID,
        StartedAt:     time.Now(),
        Status:        SessionStatusInProgress,
        AttemptNumber: attempts + 1,
        IPAddress:     ipAddress,
        UserAgent:     userAgent,
    }
    
    // Guardar
    if err := s.repo.CreateSession(ctx, session); err != nil {
        return nil, fmt.Errorf("failed to start evaluation: %w", err)
    }
    
    // Cachear sesión
    if s.cache != nil {
        _ = s.cache.SetSession(ctx, session.ID, session)
    }
    
    // Publicar evento
    _ = s.publisher.PublishEvaluationStarted(ctx, session)
    
    return session, nil
}

// SubmitAnswer envía una respuesta
func (s *ServiceImpl) SubmitAnswer(ctx context.Context, sessionID uint, req *SubmitAnswerRequest) error {
    // Verificar que la sesión existe y está activa
    session, err := s.repo.GetSessionByID(ctx, sessionID)
    if err != nil {
        return err
    }
    
    if session.Status != SessionStatusInProgress {
        return fmt.Errorf(ErrSessionAlreadySubmitted)
    }
    
    // TODO: Obtener tipo de pregunta para validar
    // Por ahora asumimos que es válida
    
    // Crear respuesta
    answer := &StudentAnswer{
        SessionID:        sessionID,
        QuestionID:       req.QuestionID,
        AnswerText:       req.AnswerText,
        SelectedOptionID: req.SelectedOptionID,
    }
    
    // Guardar
    if err := s.repo.SaveAnswer(ctx, answer); err != nil {
        return fmt.Errorf("failed to save answer: %w", err)
    }
    
    return nil
}

// SubmitEvaluation finaliza una evaluación
func (s *ServiceImpl) SubmitEvaluation(ctx context.Context, sessionID uint) error {
    // Verificar sesión
    session, err := s.repo.GetSessionByID(ctx, sessionID)
    if err != nil {
        return err
    }
    
    if session.Status != SessionStatusInProgress {
        return fmt.Errorf(ErrSessionAlreadySubmitted)
    }
    
    // Validar que la sesión puede ser enviada
    if err := s.validator.ValidateSessionSubmission(session); err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }
    
    // Actualizar estado
    now := time.Now()
    session.SubmittedAt = &now
    session.TimeSpentSeconds = int(now.Sub(session.StartedAt).Seconds())
    session.Status = SessionStatusSubmitted
    
    // Guardar
    if err := s.repo.UpdateSession(ctx, session); err != nil {
        return fmt.Errorf("failed to submit evaluation: %w", err)
    }
    
    // Publicar evento para procesamiento asíncrono
    if err := s.publisher.PublishEvaluationSubmitted(ctx, sessionID); err != nil {
        // Log pero no fallar
        fmt.Printf("failed to publish submit event: %v\n", err)
    }
    
    return nil
}

// GetSessionResult obtiene el resultado de una sesión
func (s *ServiceImpl) GetSessionResult(ctx context.Context, sessionID, userID uint, role string) (*EvaluationResultResponse, error) {
    // Verificar sesión
    session, err := s.repo.GetSessionByID(ctx, sessionID)
    if err != nil {
        return nil, err
    }
    
    // Verificar permisos
    if role == "student" && session.StudentID != userID {
        return nil, fmt.Errorf(ErrUnauthorizedAccess)
    }
    
    // Obtener resultado
    result, err := s.repo.GetResult(ctx, sessionID)
    if err != nil {
        return nil, err
    }
    
    if result == nil {
        return nil, fmt.Errorf("result not available yet")
    }
    
    // Construir response
    response := &EvaluationResultResponse{
        SessionID:   result.SessionID,
        TotalScore:  result.TotalScore,
        Percentage:  result.Percentage,
        Passed:      result.Passed,
        Ranking:     result.Ranking,
        Strengths:   result.Strengths,
        Weaknesses:  result.Weaknesses,
        AIAnalysis:  result.AIAnalysis,
        CompletedAt: result.CreatedAt,
    }
    
    return response, nil
}

// GetEvaluationStatistics obtiene estadísticas de una evaluación
func (s *ServiceImpl) GetEvaluationStatistics(ctx context.Context, evaluationID uint) (map[string]interface{}, error) {
    // Obtener todos los resultados
    results, err := s.repo.GetEvaluationResults(ctx, evaluationID)
    if err != nil {
        return nil, err
    }
    
    if len(results) == 0 {
        return map[string]interface{}{
            "total_attempts": 0,
            "average_score":  0,
            "pass_rate":      0,
        }, nil
    }
    
    // Calcular estadísticas
    var totalScore float64
    var passedCount int
    
    for _, r := range results {
        totalScore += r.Percentage
        if r.Passed {
            passedCount++
        }
    }
    
    stats := map[string]interface{}{
        "total_attempts": len(results),
        "average_score":  totalScore / float64(len(results)),
        "pass_rate":      float64(passedCount) / float64(len(results)) * 100,
        "highest_score":  results[0].Percentage, // Asumiendo orden descendente
    }
    
    return stats, nil
}

// GetUserHistory obtiene el historial de un usuario
func (s *ServiceImpl) GetUserHistory(ctx context.Context, userID uint) ([]*EvaluationResultResponse, error) {
    results, err := s.repo.GetUserResults(ctx, userID)
    if err != nil {
        return nil, err
    }
    
    var responses []*EvaluationResultResponse
    for _, r := range results {
        responses = append(responses, &EvaluationResultResponse{
            SessionID:   r.SessionID,
            TotalScore:  r.TotalScore,
            Percentage:  r.Percentage,
            Passed:      r.Passed,
            Ranking:     r.Ranking,
            Strengths:   r.Strengths,
            Weaknesses:  r.Weaknesses,
            AIAnalysis:  r.AIAnalysis,
            CompletedAt: r.CreatedAt,
        })
    }
    
    return responses, nil
}

// GenerateQuestionsWithAI genera preguntas con IA
func (s *ServiceImpl) GenerateQuestionsWithAI(ctx context.Context, materialID uint, count int) ([]*CreateQuestionRequest, error) {
    // TODO: Obtener contenido del material desde el repo de materials
    content := "Sample content for AI generation"
    
    // Llamar a IA
    questions, err := s.aiClient.GenerateQuestions(ctx, content, count, "intermediate")
    if err != nil {
        return nil, fmt.Errorf("failed to generate questions: %w", err)
    }
    
    return questions, nil
}

// AnalyzeResponsesWithAI analiza respuestas con IA
func (s *ServiceImpl) AnalyzeResponsesWithAI(ctx context.Context, sessionID uint) (string, error) {
    // Obtener respuestas
    answers, err := s.repo.GetSessionAnswers(ctx, sessionID)
    if err != nil {
        return "", err
    }
    
    // Generar feedback con IA
    feedback, strengths, weaknesses, err := s.aiClient.GenerateFeedback(ctx, answers)
    if err != nil {
        return "", fmt.Errorf("failed to analyze responses: %w", err)
    }
    
    // TODO: Guardar análisis en resultado
    _ = strengths
    _ = weaknesses
    
    return feedback, nil
}
```

#### Criterios de Aceptación:
- [ ] Todos los métodos de la interfaz Service implementados
- [ ] Lógica de negocio completa
- [ ] Validaciones aplicadas
- [ ] Eventos publicados correctamente
- [ ] Cache utilizado donde sea apropiado

---

### TASK-007: Implementar validators (validators.go)
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 1h  

#### Implementación:
```go
// pkg/evaluation/validators.go
package evaluation

import (
    "fmt"
    "strings"
)

// ValidatorImpl implementa la interfaz Validator
type ValidatorImpl struct{}

// NewValidator crea una nueva instancia del validador
func NewValidator() Validator {
    return &ValidatorImpl{}
}

// ValidateEvaluation valida una evaluación
func (v *ValidatorImpl) ValidateEvaluation(evaluation *CreateEvaluationRequest) error {
    // Validar título
    if len(evaluation.Title) < MinTitleLength || len(evaluation.Title) > MaxTitleLength {
        return fmt.Errorf("title must be between %d and %d characters", MinTitleLength, MaxTitleLength)
    }
    
    // Validar duración
    if evaluation.DurationMinutes < MinDurationMinutes || evaluation.DurationMinutes > MaxDurationMinutes {
        return fmt.Errorf("duration must be between %d and %d minutes", MinDurationMinutes, MaxDurationMinutes)
    }
    
    // Validar passing score
    if evaluation.PassingScore < 0 || evaluation.PassingScore > 100 {
        return fmt.Errorf("passing score must be between 0 and 100")
    }
    
    // Validar intentos máximos
    if evaluation.MaxAttempts < 1 || evaluation.MaxAttempts > 10 {
        return fmt.Errorf("max attempts must be between 1 and 10")
    }
    
    // Validar preguntas
    if len(evaluation.Questions) < MinQuestions || len(evaluation.Questions) > MaxQuestions {
        return fmt.Errorf("evaluation must have between %d and %d questions", MinQuestions, MaxQuestions)
    }
    
    // Validar cada pregunta
    totalPoints := 0.0
    for i, q := range evaluation.Questions {
        if err := v.ValidateQuestion(&q); err != nil {
            return fmt.Errorf("question %d: %w", i+1, err)
        }
        totalPoints += q.Points
    }
    
    // Validar que hay suficientes puntos para pasar
    if totalPoints < evaluation.PassingScore {
        return fmt.Errorf("total points (%.2f) must be >= passing score (%.2f)", 
            totalPoints, evaluation.PassingScore)
    }
    
    return nil
}

// ValidateQuestion valida una pregunta
func (v *ValidatorImpl) ValidateQuestion(question *CreateQuestionRequest) error {
    // Validar texto de la pregunta
    question.QuestionText = strings.TrimSpace(question.QuestionText)
    if question.QuestionText == "" {
        return fmt.Errorf("question text is required")
    }
    
    if len(question.QuestionText) > MaxQuestionTextLength {
        return fmt.Errorf("question text exceeds maximum length of %d characters", MaxQuestionTextLength)
    }
    
    // Validar tipo de pregunta
    if !question.QuestionType.IsValid() {
        return fmt.Errorf(ErrInvalidQuestionType)
    }
    
    // Validar puntos
    if question.Points < 0 || question.Points > 100 {
        return fmt.Errorf("points must be between 0 and 100")
    }
    
    // Validar opciones según el tipo
    if question.QuestionType.RequiresOptions() {
        if len(question.Options) < MinOptions || len(question.Options) > MaxOptions {
            return fmt.Errorf("question type %s requires between %d and %d options", 
                question.QuestionType, MinOptions, MaxOptions)
        }
        
        // Validar que al menos una opción es correcta
        hasCorrect := false
        for _, opt := range question.Options {
            if opt.OptionText == "" {
                return fmt.Errorf("option text cannot be empty")
            }
            if len(opt.OptionText) > MaxOptionTextLength {
                return fmt.Errorf("option text exceeds maximum length of %d", MaxOptionTextLength)
            }
            if opt.IsCorrect {
                hasCorrect = true
            }
        }
        
        if !hasCorrect && question.QuestionType != QuestionTypeTrueFalse {
            return fmt.Errorf(ErrNoCorrectOptionProvided)
        }
        
        // Para true/false, debe haber exactamente 2 opciones
        if question.QuestionType == QuestionTypeTrueFalse && len(question.Options) != 2 {
            return fmt.Errorf("true/false questions must have exactly 2 options")
        }
    }
    
    return nil
}

// ValidateAnswer valida una respuesta
func (v *ValidatorImpl) ValidateAnswer(answer *SubmitAnswerRequest, questionType QuestionType) error {
    // Validar que hay ID de pregunta
    if answer.QuestionID == 0 {
        return fmt.Errorf("question ID is required")
    }
    
    // Validar según el tipo de pregunta
    switch questionType {
    case QuestionTypeMultipleChoice, QuestionTypeTrueFalse:
        if answer.SelectedOptionID == nil {
            return fmt.Errorf("selected option is required for %s questions", questionType)
        }
        
    case QuestionTypeShortAnswer:
        answer.AnswerText = strings.TrimSpace(answer.AnswerText)
        if answer.AnswerText == "" {
            return fmt.Errorf("answer text is required for short answer questions")
        }
        if len(answer.AnswerText) > MaxAnswerTextLength {
            return fmt.Errorf("answer exceeds maximum length of %d characters", MaxAnswerTextLength)
        }
        
    case QuestionTypeEssay:
        answer.AnswerText = strings.TrimSpace(answer.AnswerText)
        if answer.AnswerText == "" {
            return fmt.Errorf("answer text is required for essay questions")
        }
        if len(answer.AnswerText) > MaxAnswerTextLength {
            return fmt.Errorf("answer exceeds maximum length of %d characters", MaxAnswerTextLength)
        }
    }
    
    return nil
}

// ValidateSessionSubmission valida que una sesión puede ser enviada
func (v *ValidatorImpl) ValidateSessionSubmission(session *EvaluationSession) error {
    // Verificar estado
    if session.Status != SessionStatusInProgress {
        return fmt.Errorf(ErrSessionAlreadySubmitted)
    }
    
    // Verificar que no ha expirado
    // TODO: Implementar verificación de tiempo límite
    
    // Verificar que tiene respuestas
    if len(session.Answers) == 0 {
        return fmt.Errorf("no answers provided")
    }
    
    return nil
}

// Additional validation helpers

// ValidatePagination valida parámetros de paginación
func ValidatePagination(page, pageSize int) error {
    if page < 1 {
        return fmt.Errorf("page must be >= 1")
    }
    if pageSize < 1 || pageSize > 100 {
        return fmt.Errorf("page size must be between 1 and 100")
    }
    return nil
}

// ValidateFilters valida filtros de búsqueda
func ValidateFilters(filters map[string]interface{}) error {
    validKeys := map[string]bool{
        "subject_id":       true,
        "academic_level_id": true,
        "created_by":       true,
        "status":           true,
        "search":           true,
    }
    
    for key := range filters {
        if !validKeys[key] {
            return fmt.Errorf("invalid filter key: %s", key)
        }
    }
    
    // Validar status si está presente
    if status, ok := filters["status"].(string); ok {
        if !EvaluationStatus(status).IsValid() {
            return fmt.Errorf("invalid status: %s", status)
        }
    }
    
    return nil
}

// SanitizeInput limpia input de usuario
func SanitizeInput(input string) string {
    // Remover espacios extras
    input = strings.TrimSpace(input)
    
    // Remover caracteres de control
    input = strings.Map(func(r rune) rune {
        if r < 32 && r != '\n' && r != '\t' {
            return -1
        }
        return r
    }, input)
    
    return input
}
```

#### Criterios de Aceptación:
- [ ] Validaciones completas para evaluaciones
- [ ] Validaciones para preguntas y opciones
- [ ] Validaciones para respuestas
- [ ] Helpers de validación adicionales

---

### TASK-008: Crear tests unitarios
**Tipo**: test  
**Prioridad**: HIGH  
**Estimación**: 2h  

#### Implementación:
```go
// pkg/evaluation/evaluation_test.go
package evaluation

import (
    "context"
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

// Mock Repository para tests
type MockRepository struct {
    mock.Mock
}

func (m *MockRepository) CreateEvaluation(ctx context.Context, evaluation *Evaluation) error {
    args := m.Called(ctx, evaluation)
    return args.Error(0)
}

func (m *MockRepository) GetEvaluationByID(ctx context.Context, id uint) (*Evaluation, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*Evaluation), args.Error(1)
}

// Implementar todos los demás métodos del mock...

// Tests

func TestCreateEvaluation_Success(t *testing.T) {
    // Arrange
    ctx := context.Background()
    mockRepo := new(MockRepository)
    mockValidator := NewValidator()
    service := NewService(mockRepo, mockValidator, nil, nil, nil, nil)
    
    request := &CreateEvaluationRequest{
        Title: "Test Evaluation",
        Description: "Test Description",
        DurationMinutes: 60,
        PassingScore: 60,
        MaxAttempts: 2,
        Questions: []CreateQuestionRequest{
            {
                QuestionText: "What is 2+2?",
                QuestionType: QuestionTypeMultipleChoice,
                Points: 10,
                Options: []CreateOptionRequest{
                    {OptionText: "3", IsCorrect: false},
                    {OptionText: "4", IsCorrect: true},
                    {OptionText: "5", IsCorrect: false},
                },
            },
        },
    }
    
    mockRepo.On("CreateEvaluation", ctx, mock.AnythingOfType("*evaluation.Evaluation")).
        Return(nil)
    
    // Act
    evaluation, err := service.CreateEvaluation(ctx, request, 1)
    
    // Assert
    assert.NoError(t, err)
    assert.NotNil(t, evaluation)
    assert.Equal(t, "Test Evaluation", evaluation.Title)
    assert.Len(t, evaluation.Questions, 1)
    mockRepo.AssertExpectations(t)
}

func TestCreateEvaluation_ValidationFail(t *testing.T) {
    // Arrange
    ctx := context.Background()
    mockRepo := new(MockRepository)
    mockValidator := NewValidator()
    service := NewService(mockRepo, mockValidator, nil, nil, nil, nil)
    
    request := &CreateEvaluationRequest{
        Title: "Te", // Too short
        Questions: []CreateQuestionRequest{},  // No questions
    }
    
    // Act
    evaluation, err := service.CreateEvaluation(ctx, request, 1)
    
    // Assert
    assert.Error(t, err)
    assert.Nil(t, evaluation)
    assert.Contains(t, err.Error(), "title must be between")
    mockRepo.AssertNotCalled(t, "CreateEvaluation")
}

func TestValidateQuestion_MultipleChoice_Success(t *testing.T) {
    // Arrange
    validator := NewValidator()
    question := &CreateQuestionRequest{
        QuestionText: "What is the capital of France?",
        QuestionType: QuestionTypeMultipleChoice,
        Points: 5,
        Options: []CreateOptionRequest{
            {OptionText: "London", IsCorrect: false},
            {OptionText: "Paris", IsCorrect: true},
            {OptionText: "Berlin", IsCorrect: false},
            {OptionText: "Madrid", IsCorrect: false},
        },
    }
    
    // Act
    err := validator.ValidateQuestion(question)
    
    // Assert
    assert.NoError(t, err)
}

func TestValidateQuestion_NoCorrectOption_Fail(t *testing.T) {
    // Arrange
    validator := NewValidator()
    question := &CreateQuestionRequest{
        QuestionText: "What is 2+2?",
        QuestionType: QuestionTypeMultipleChoice,
        Points: 5,
        Options: []CreateOptionRequest{
            {OptionText: "3", IsCorrect: false},
            {OptionText: "5", IsCorrect: false},
        },
    }
    
    // Act
    err := validator.ValidateQuestion(question)
    
    // Assert
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "at least one correct option")
}

func TestConstants_QuestionTypeValidation(t *testing.T) {
    // Test valid question types
    assert.True(t, QuestionTypeMultipleChoice.IsValid())
    assert.True(t, QuestionTypeTrueFalse.IsValid())
    assert.True(t, QuestionTypeShortAnswer.IsValid())
    assert.True(t, QuestionTypeEssay.IsValid())
    
    // Test invalid question type
    invalidType := QuestionType("invalid")
    assert.False(t, invalidType.IsValid())
    
    // Test RequiresOptions
    assert.True(t, QuestionTypeMultipleChoice.RequiresOptions())
    assert.True(t, QuestionTypeTrueFalse.RequiresOptions())
    assert.False(t, QuestionTypeShortAnswer.RequiresOptions())
    assert.False(t, QuestionTypeEssay.RequiresOptions())
}

func TestSessionStatus_Validation(t *testing.T) {
    // Test valid statuses
    assert.True(t, SessionStatusInProgress.IsValid())
    assert.True(t, SessionStatusSubmitted.IsValid())
    assert.True(t, SessionStatusGraded.IsValid())
    assert.True(t, SessionStatusExpired.IsValid())
    
    // Test CanBeGraded
    assert.False(t, SessionStatusInProgress.CanBeGraded())
    assert.True(t, SessionStatusSubmitted.CanBeGraded())
    assert.False(t, SessionStatusGraded.CanBeGraded())
}

// Benchmark tests

func BenchmarkCreateEvaluation(b *testing.B) {
    ctx := context.Background()
    mockRepo := new(MockRepository)
    mockValidator := NewValidator()
    service := NewService(mockRepo, mockValidator, nil, nil, nil, nil)
    
    request := &CreateEvaluationRequest{
        Title: "Benchmark Test",
        DurationMinutes: 60,
        PassingScore: 60,
        MaxAttempts: 1,
        Questions: []CreateQuestionRequest{
            {
                QuestionText: "Question",
                QuestionType: QuestionTypeShortAnswer,
                Points: 10,
            },
        },
    }
    
    mockRepo.On("CreateEvaluation", ctx, mock.Anything).Return(nil)
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _, _ = service.CreateEvaluation(ctx, request, 1)
    }
}
```

#### Criterios de Aceptación:
- [ ] Tests para casos de éxito
- [ ] Tests para casos de error
- [ ] Tests de validación
- [ ] Mocks implementados
- [ ] Coverage >85%

#### Validación:
```bash
go test ./pkg/evaluation -v -cover
# Coverage debe ser >85%
```

---

### TASK-009: Actualizar go.mod y publicar módulo
**Tipo**: chore  
**Prioridad**: HIGH  
**Estimación**: 30min  

#### Pasos de Implementación:
```bash
# 1. Actualizar go.mod con nuevas dependencias
go get github.com/lib/pq
go get github.com/stretchr/testify
go mod tidy

# 2. Ejecutar todos los tests
go test ./pkg/evaluation -v -cover

# 3. Verificar que todo compila
go build ./...

# 4. Crear tag de versión
git add .
git commit -m "feat: add evaluation module v1.3.0

- Complete evaluation system implementation
- Models, interfaces, repository, service, validators
- Unit tests with >85% coverage
- Ready for integration with APIs and worker

Breaking changes: None
New features: Complete evaluation module"

git tag v1.3.0
git push origin feature/evaluation-module
git push origin v1.3.0

# 5. Verificar que el módulo es accesible
go list -m github.com/EduGoGroup/edugo-shared@v1.3.0
```

#### Criterios de Aceptación:
- [ ] go.mod actualizado
- [ ] Tests pasando
- [ ] Tag v1.3.0 creado
- [ ] Branch pushed
- [ ] Módulo accesible públicamente

---

### TASK-010: Documentación y merge
**Tipo**: docs  
**Prioridad**: MEDIUM  
**Estimación**: 1h  

#### Implementación:
```markdown
# Crear pkg/evaluation/README.md
# Evaluation Module

## Overview
Complete evaluation system for EduGo platform.

## Features
- Create and manage evaluations
- Multiple question types (multiple choice, true/false, short answer, essay)
- Session management with attempt tracking
- Automatic grading
- AI integration for question generation
- Result analytics

## Usage

### Basic Example
```go
import (
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
    "gorm.io/gorm"
)

// Initialize
db := // your gorm db
repo := evaluation.NewGormRepository(db)
validator := evaluation.NewValidator()
service := evaluation.NewService(repo, validator, nil, nil, nil, nil)

// Create evaluation
req := &evaluation.CreateEvaluationRequest{
    Title: "Math Quiz",
    Questions: []evaluation.CreateQuestionRequest{
        // your questions
    },
}
evaluation, err := service.CreateEvaluation(ctx, req, userID)
```

## API Reference
See interfaces.go for complete API documentation.

## Testing
```bash
go test ./pkg/evaluation -v -cover
```
```

#### Pull Request:
```markdown
# Title: feat: add evaluation module v1.3.0

## Description
Complete implementation of evaluation system module for EduGo platform.

## Changes
- ✅ Models for evaluations, questions, sessions, results
- ✅ Repository pattern with GORM implementation
- ✅ Service layer with business logic
- ✅ Validators for all entities
- ✅ Constants and enums
- ✅ Comprehensive unit tests (>85% coverage)

## Testing
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Manual testing completed

## Checklist
- [x] Code follows project standards
- [x] Tests added
- [x] Documentation updated
- [x] No breaking changes
- [x] Ready for review

## Related Issues
Closes #XXX - Implement evaluation system
```

#### Criterios de Aceptación:
- [ ] README.md creado
- [ ] CHANGELOG.md actualizado
- [ ] Pull request creado
- [ ] Code review solicitado
- [ ] Merge aprobado

---

## 📊 Resumen de Tareas

| Task | Descripción | Tiempo | Estado |
|------|-------------|--------|--------|
| 001 | Estructura del módulo | 30min | ⬜ |
| 002 | Modelos de datos | 2h | ⬜ |
| 003 | Constantes y enums | 30min | ⬜ |
| 004 | Interfaces | 1h | ⬜ |
| 005 | Repository | 3h | ⬜ |
| 006 | Service | 3h | ⬜ |
| 007 | Validators | 1h | ⬜ |
| 008 | Tests unitarios | 2h | ⬜ |
| 009 | Publicar módulo | 30min | ⬜ |
| 010 | Documentación | 1h | ⬜ |

**Total estimado**: 15 horas (2 días laborables)

## ✅ Checklist Final

Antes de marcar como completo:
- [ ] Todos los archivos creados
- [ ] Tests con cobertura >85%
- [ ] go mod tidy ejecutado
- [ ] Documentación completa
- [ ] Módulo publicado como v1.3.0
- [ ] PR aprobado y mergeado
- [ ] Sin errores de linting
- [ ] Compatible con Go 1.21+

## 🚀 Siguiente Paso

Una vez completadas todas las tareas:
1. Notificar a equipos de api-mobile y api-admin
2. Actualizar tracking en TRACKING_SYSTEM.json
3. Proceder con implementación en APIs
4. Documentar cualquier issue encontrado

---

**Documento generado para**: Ejecución desatendida por IA  
**Puede ser ejecutado por**: Claude, GPT-4, GitHub Copilot, etc.  
**Requisito**: Acceso a repositorio GitHub EduGoGroup/edugo-shared