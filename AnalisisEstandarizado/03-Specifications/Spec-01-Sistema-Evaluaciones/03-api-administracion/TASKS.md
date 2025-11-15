# 📋 Tareas - edugo-api-administracion - Sistema de Evaluaciones

## 📍 Información del Proyecto
- **Repositorio**: edugo-api-administracion
- **Branch**: feature/evaluation-management
- **Dependencia**: edugo-shared v1.3.0 (DEBE estar publicado primero)
- **Tiempo Estimado**: 3 días (24 horas)
- **Path de trabajo**: `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion`
- **Puerto**: 8081

## ✅ Pre-requisitos
```bash
# Verificar que shared v1.3.0 está disponible
go list -m github.com/EduGoGroup/edugo-shared@v1.3.0
# Si no está disponible, DETENER y esperar a que se publique

# Navegar al proyecto
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Verificar estado
git status
go version  # Debe ser >= 1.21

# Crear branch de trabajo
git checkout main
git pull origin main
git checkout -b feature/evaluation-management
```

## 📝 TAREAS DETALLADAS

### TASK-001: Actualizar dependencias y crear estructura
**Tipo**: setup  
**Prioridad**: HIGH  
**Estimación**: 1h  

#### Pasos de Implementación:
```bash
# 1. Actualizar go.mod con shared v1.3.0
go get github.com/EduGoGroup/edugo-shared@v1.3.0
go mod tidy

# 2. Crear estructura de directorios
mkdir -p internal/evaluation/{handlers,services,repositories,dto}
mkdir -p internal/evaluation/validators

# 3. Crear archivos base
touch internal/evaluation/handlers/admin_evaluation_handler.go
touch internal/evaluation/services/admin_evaluation_service.go
touch internal/evaluation/repositories/admin_evaluation_repository.go
touch internal/evaluation/dto/admin_requests.go
touch internal/evaluation/dto/admin_responses.go
touch internal/evaluation/validators/evaluation_validator.go

# 4. Crear estructura de tests
mkdir -p internal/evaluation/tests
touch internal/evaluation/tests/admin_evaluation_test.go
```

#### Criterios de Aceptación:
- [ ] go.mod actualizado con shared v1.3.0
- [ ] Estructura de carpetas creada
- [ ] Archivos base creados
- [ ] go mod tidy sin warnings

#### Validación:
```bash
go list -m all | grep edugo-shared
# Output: github.com/EduGoGroup/edugo-shared v1.3.0
```

---

### TASK-002: Implementar DTOs administrativos
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 2h  

#### Implementación:

```go
// internal/evaluation/dto/admin_requests.go
package dto

import (
    "time"
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
)

// CreateEvaluationRequest DTO para crear evaluación
type CreateEvaluationRequest struct {
    Title                  string                       `json:"title" binding:"required,min=3,max=255"`
    Description            string                       `json:"description"`
    MaterialID             *uint                        `json:"material_id"`
    SubjectID              *uint                        `json:"subject_id"`
    AcademicLevelID        *uint                        `json:"academic_level_id"`
    DurationMinutes        int                          `json:"duration_minutes" binding:"required,min=1,max=480"`
    PassingScore           float64                      `json:"passing_score" binding:"required,min=0,max=100"`
    MaxAttempts            int                          `json:"max_attempts" binding:"required,min=1,max=10"`
    ShuffleQuestions       bool                         `json:"shuffle_questions"`
    ShowResultsImmediately bool                         `json:"show_results_immediately"`
    AutoGrade              bool                         `json:"auto_grade"`
    PublishDate            *time.Time                   `json:"publish_date"`
    ExpirationDate         *time.Time                   `json:"expiration_date"`
    Tags                   []string                     `json:"tags"`
    Questions              []CreateQuestionRequest      `json:"questions,omitempty" binding:"dive"`
}

// UpdateEvaluationRequest DTO para actualizar evaluación
type UpdateEvaluationRequest struct {
    Title                  *string                      `json:"title,omitempty" binding:"omitempty,min=3,max=255"`
    Description            *string                      `json:"description,omitempty"`
    MaterialID             *uint                        `json:"material_id,omitempty"`
    SubjectID              *uint                        `json:"subject_id,omitempty"`
    AcademicLevelID        *uint                        `json:"academic_level_id,omitempty"`
    DurationMinutes        *int                         `json:"duration_minutes,omitempty" binding:"omitempty,min=1,max=480"`
    PassingScore           *float64                     `json:"passing_score,omitempty" binding:"omitempty,min=0,max=100"`
    MaxAttempts            *int                         `json:"max_attempts,omitempty" binding:"omitempty,min=1,max=10"`
    ShuffleQuestions       *bool                        `json:"shuffle_questions,omitempty"`
    ShowResultsImmediately *bool                        `json:"show_results_immediately,omitempty"`
    AutoGrade              *bool                        `json:"auto_grade,omitempty"`
    PublishDate            *time.Time                   `json:"publish_date,omitempty"`
    ExpirationDate         *time.Time                   `json:"expiration_date,omitempty"`
    Tags                   []string                     `json:"tags,omitempty"`
}

// CreateQuestionRequest DTO para crear/actualizar pregunta
type CreateQuestionRequest struct {
    ID              *uint                        `json:"id,omitempty"` // Si tiene ID, es update
    QuestionText    string                       `json:"question_text" binding:"required"`
    QuestionType    evaluation.QuestionType      `json:"question_type" binding:"required,oneof=multiple_choice true_false short_answer essay"`
    Points          float64                      `json:"points" binding:"required,min=0,max=100"`
    OrderIndex      int                          `json:"order_index"`
    Required        bool                         `json:"required"`
    Explanation     string                       `json:"explanation"`
    DifficultyLevel string                       `json:"difficulty_level" binding:"omitempty,oneof=easy medium hard"`
    Tags            []string                     `json:"tags"`
    Options         []CreateOptionRequest        `json:"options,omitempty" binding:"required_if=QuestionType multiple_choice,required_if=QuestionType true_false,dive"`
}

// CreateOptionRequest DTO para opciones
type CreateOptionRequest struct {
    ID         *uint  `json:"id,omitempty"`
    OptionText string `json:"option_text" binding:"required"`
    IsCorrect  bool   `json:"is_correct"`
    Feedback   string `json:"feedback"` // Feedback cuando se selecciona esta opción
}

// BulkCreateQuestionsRequest para agregar múltiples preguntas
type BulkCreateQuestionsRequest struct {
    Questions []CreateQuestionRequest `json:"questions" binding:"required,min=1,dive"`
}

// GenerateWithAIRequest para generar evaluación con IA
type GenerateWithAIRequest struct {
    MaterialID      *uint   `json:"material_id"`
    Content         string  `json:"content"` // Contenido alternativo si no hay material
    QuestionCount   int     `json:"question_count" binding:"required,min=1,max=50"`
    QuestionTypes   []string `json:"question_types"` // multiple_choice, true_false, etc.
    DifficultyLevel string  `json:"difficulty_level" binding:"required,oneof=easy medium hard mixed"`
    Language        string  `json:"language" binding:"omitempty,oneof=es en pt"`
    Instructions    string  `json:"custom_instructions"` // Instrucciones adicionales para la IA
}

// UpdateQuestionOrderRequest para reordenar preguntas
type UpdateQuestionOrderRequest struct {
    QuestionOrders []QuestionOrder `json:"question_orders" binding:"required,dive"`
}

type QuestionOrder struct {
    QuestionID uint `json:"question_id" binding:"required"`
    OrderIndex int  `json:"order_index" binding:"required,min=0"`
}

// CloneEvaluationRequest para duplicar evaluación
type CloneEvaluationRequest struct {
    NewTitle        string     `json:"new_title" binding:"required,min=3,max=255"`
    IncludeResults  bool       `json:"include_results"`
    TargetSubjectID *uint      `json:"target_subject_id"`
    PublishDate     *time.Time `json:"publish_date"`
}

// PublishEvaluationRequest para publicar evaluación
type PublishEvaluationRequest struct {
    PublishNow     bool       `json:"publish_now"`
    PublishDate    *time.Time `json:"publish_date" binding:"required_if=PublishNow false"`
    NotifyStudents bool       `json:"notify_students"`
    Message        string     `json:"message"` // Mensaje opcional para estudiantes
}

// ListEvaluationsRequest query params para admin
type ListEvaluationsRequest struct {
    SubjectID       *uint      `form:"subject_id"`
    AcademicLevelID *uint      `form:"academic_level_id"`
    CreatedBy       *uint      `form:"created_by"`
    Status          string     `form:"status"`
    Search          string     `form:"search"`
    Tags            []string   `form:"tags"`
    DateFrom        *time.Time `form:"date_from"`
    DateTo          *time.Time `form:"date_to"`
    SortBy          string     `form:"sort_by,default=created_at"`
    SortOrder       string     `form:"sort_order,default=desc"`
    Page            int        `form:"page,default=1" binding:"min=1"`
    PageSize        int        `form:"page_size,default=20" binding:"min=1,max=100"`
}

// BatchUpdateRequest para operaciones en lote
type BatchUpdateRequest struct {
    EvaluationIDs []uint                 `json:"evaluation_ids" binding:"required,min=1"`
    Action        string                 `json:"action" binding:"required,oneof=publish unpublish archive delete"`
    Data          map[string]interface{} `json:"data,omitempty"`
}

// ImportQuestionsRequest para importar preguntas
type ImportQuestionsRequest struct {
    Format   string `json:"format" binding:"required,oneof=csv json excel"`
    FileData string `json:"file_data" binding:"required"` // Base64 encoded
}

// ExportEvaluationRequest para exportar evaluación
type ExportEvaluationRequest struct {
    Format          string `json:"format" binding:"required,oneof=pdf docx json"`
    IncludeAnswers  bool   `json:"include_answers"`
    IncludeAnalytics bool  `json:"include_analytics"`
}
```

```go
// internal/evaluation/dto/admin_responses.go
package dto

import (
    "time"
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
)

// AdminEvaluationResponse respuesta completa de evaluación para admin
type AdminEvaluationResponse struct {
    ID                     uint                         `json:"id"`
    Title                  string                       `json:"title"`
    Description            string                       `json:"description"`
    MaterialID             *uint                        `json:"material_id"`
    MaterialTitle          string                       `json:"material_title,omitempty"`
    SubjectID              *uint                        `json:"subject_id"`
    SubjectName            string                       `json:"subject_name,omitempty"`
    AcademicLevelID        *uint                        `json:"academic_level_id"`
    AcademicLevelName      string                       `json:"academic_level_name,omitempty"`
    CreatedBy              uint                         `json:"created_by"`
    CreatedByName          string                       `json:"created_by_name"`
    DurationMinutes        int                          `json:"duration_minutes"`
    PassingScore           float64                      `json:"passing_score"`
    MaxAttempts            int                          `json:"max_attempts"`
    ShuffleQuestions       bool                         `json:"shuffle_questions"`
    ShowResultsImmediately bool                         `json:"show_results_immediately"`
    AutoGrade              bool                         `json:"auto_grade"`
    Status                 string                       `json:"status"`
    PublishDate            *time.Time                   `json:"publish_date,omitempty"`
    ExpirationDate         *time.Time                   `json:"expiration_date,omitempty"`
    Tags                   []string                     `json:"tags"`
    Questions              []AdminQuestionResponse      `json:"questions,omitempty"`
    Statistics             *EvaluationStatistics        `json:"statistics,omitempty"`
    CreatedAt              time.Time                    `json:"created_at"`
    UpdatedAt              time.Time                    `json:"updated_at"`
}

// AdminQuestionResponse respuesta de pregunta para admin
type AdminQuestionResponse struct {
    ID              uint                     `json:"id"`
    QuestionText    string                   `json:"question_text"`
    QuestionType    string                   `json:"question_type"`
    Points          float64                  `json:"points"`
    OrderIndex      int                      `json:"order_index"`
    Required        bool                     `json:"required"`
    Explanation     string                   `json:"explanation"`
    DifficultyLevel string                   `json:"difficulty_level"`
    Tags            []string                 `json:"tags"`
    Options         []AdminOptionResponse    `json:"options,omitempty"`
    Statistics      *QuestionStatistics      `json:"statistics,omitempty"`
}

// AdminOptionResponse incluye si es correcta
type AdminOptionResponse struct {
    ID           uint    `json:"id"`
    OptionText   string  `json:"option_text"`
    IsCorrect    bool    `json:"is_correct"` // Admin ve respuesta correcta
    OrderIndex   int     `json:"order_index"`
    Feedback     string  `json:"feedback,omitempty"`
    TimesSelected int    `json:"times_selected,omitempty"` // Estadística
}

// EvaluationStatistics estadísticas de evaluación
type EvaluationStatistics struct {
    TotalSessions        int     `json:"total_sessions"`
    CompletedSessions    int     `json:"completed_sessions"`
    AverageScore         float64 `json:"average_score"`
    AverageTimeSpent     int     `json:"average_time_spent_seconds"`
    PassRate             float64 `json:"pass_rate"`
    AbandonRate          float64 `json:"abandon_rate"`
    HighestScore         float64 `json:"highest_score"`
    LowestScore          float64 `json:"lowest_score"`
    MedianScore          float64 `json:"median_score"`
    StandardDeviation    float64 `json:"standard_deviation"`
    LastAttemptDate      *time.Time `json:"last_attempt_date"`
}

// QuestionStatistics estadísticas por pregunta
type QuestionStatistics struct {
    TimesAnswered        int     `json:"times_answered"`
    TimesCorrect         int     `json:"times_correct"`
    CorrectRate          float64 `json:"correct_rate"`
    AverageTimeSpent     int     `json:"average_time_spent_seconds"`
    TimesSkipped         int     `json:"times_skipped"`
}

// EvaluationResultsResponse resultados de evaluación
type EvaluationResultsResponse struct {
    EvaluationID    uint                        `json:"evaluation_id"`
    EvaluationTitle string                      `json:"evaluation_title"`
    TotalResults    int                         `json:"total_results"`
    Results         []StudentResultResponse     `json:"results"`
    Statistics      *EvaluationStatistics       `json:"statistics"`
    QuestionAnalysis []QuestionAnalysis         `json:"question_analysis"`
}

// StudentResultResponse resultado individual de estudiante
type StudentResultResponse struct {
    SessionID        uint       `json:"session_id"`
    StudentID        uint       `json:"student_id"`
    StudentName      string     `json:"student_name"`
    StudentEmail     string     `json:"student_email"`
    AttemptNumber    int        `json:"attempt_number"`
    StartedAt        time.Time  `json:"started_at"`
    SubmittedAt      *time.Time `json:"submitted_at"`
    TimeSpent        string     `json:"time_spent"`
    TotalScore       float64    `json:"total_score"`
    MaxScore         float64    `json:"max_score"`
    Percentage       float64    `json:"percentage"`
    Passed           bool       `json:"passed"`
    Ranking          int        `json:"ranking"`
    Status           string     `json:"status"`
    IPAddress        string     `json:"ip_address"`
    UserAgent        string     `json:"user_agent"`
    Answers          []AnswerDetail `json:"answers,omitempty"`
}

// AnswerDetail detalle de respuesta para admin
type AnswerDetail struct {
    QuestionID       uint     `json:"question_id"`
    QuestionText     string   `json:"question_text"`
    QuestionType     string   `json:"question_type"`
    StudentAnswer    string   `json:"student_answer"`
    CorrectAnswer    string   `json:"correct_answer"`
    IsCorrect        bool     `json:"is_correct"`
    PointsEarned     float64  `json:"points_earned"`
    MaxPoints        float64  `json:"max_points"`
    TimeSpent        int      `json:"time_spent_seconds"`
    AIFeedback       string   `json:"ai_feedback,omitempty"`
}

// QuestionAnalysis análisis por pregunta
type QuestionAnalysis struct {
    QuestionID       uint                 `json:"question_id"`
    QuestionText     string               `json:"question_text"`
    DifficultyLevel  string               `json:"difficulty_level"`
    CorrectRate      float64              `json:"correct_rate"`
    AverageTime      int                  `json:"average_time_seconds"`
    DiscriminationIndex float64           `json:"discrimination_index"` // Qué tan bien discrimina entre buenos y malos estudiantes
    OptionDistribution []OptionDistribution `json:"option_distribution,omitempty"`
}

// OptionDistribution distribución de respuestas por opción
type OptionDistribution struct {
    OptionID     uint    `json:"option_id"`
    OptionText   string  `json:"option_text"`
    IsCorrect    bool    `json:"is_correct"`
    SelectCount  int     `json:"select_count"`
    SelectRate   float64 `json:"select_rate"`
}

// ReportResponse respuesta de reportes
type ReportResponse struct {
    ReportType       string                 `json:"report_type"`
    GeneratedAt      time.Time              `json:"generated_at"`
    DateRange        DateRange              `json:"date_range"`
    Filters          map[string]interface{} `json:"filters"`
    Summary          ReportSummary          `json:"summary"`
    Data             interface{}            `json:"data"` // Depende del tipo de reporte
}

type DateRange struct {
    From time.Time `json:"from"`
    To   time.Time `json:"to"`
}

type ReportSummary struct {
    TotalEvaluations int     `json:"total_evaluations"`
    TotalSessions    int     `json:"total_sessions"`
    TotalStudents    int     `json:"total_students"`
    AverageScore     float64 `json:"average_score"`
    PassRate         float64 `json:"pass_rate"`
}

// GenerateAIResponse respuesta de generación con IA
type GenerateAIResponse struct {
    Success          bool                    `json:"success"`
    GeneratedCount   int                     `json:"generated_count"`
    Questions        []AdminQuestionResponse `json:"questions"`
    ProcessingTime   int                     `json:"processing_time_ms"`
    AIModel          string                  `json:"ai_model"`
    TokensUsed       int                     `json:"tokens_used"`
    EstimatedCost    float64                 `json:"estimated_cost_usd"`
    ValidationErrors []string                `json:"validation_errors,omitempty"`
}

// CloneResponse respuesta de clonación
type CloneResponse struct {
    Success         bool   `json:"success"`
    OriginalID      uint   `json:"original_id"`
    ClonedID        uint   `json:"cloned_id"`
    ClonedTitle     string `json:"cloned_title"`
    QuestionsCloned int    `json:"questions_cloned"`
}

// BatchOperationResponse respuesta de operaciones en lote
type BatchOperationResponse struct {
    Success        bool                    `json:"success"`
    ProcessedCount int                     `json:"processed_count"`
    FailedCount    int                     `json:"failed_count"`
    Results        []BatchOperationResult  `json:"results"`
}

type BatchOperationResult struct {
    EvaluationID uint   `json:"evaluation_id"`
    Success      bool   `json:"success"`
    Error        string `json:"error,omitempty"`
}

// ImportResponse respuesta de importación
type ImportResponse struct {
    Success         bool     `json:"success"`
    ImportedCount   int      `json:"imported_count"`
    FailedCount     int      `json:"failed_count"`
    ValidationErrors []string `json:"validation_errors,omitempty"`
    Questions       []AdminQuestionResponse `json:"questions,omitempty"`
}

// ExportResponse respuesta de exportación
type ExportResponse struct {
    Success      bool   `json:"success"`
    Format       string `json:"format"`
    FileName     string `json:"file_name"`
    FileSize     int64  `json:"file_size_bytes"`
    DownloadURL  string `json:"download_url"`
    ExpiresAt    time.Time `json:"expires_at"`
}

// ActivityLogResponse log de actividades
type ActivityLogResponse struct {
    Activities []ActivityEntry `json:"activities"`
    Total      int            `json:"total"`
}

type ActivityEntry struct {
    ID           uint      `json:"id"`
    Action       string    `json:"action"`
    UserID       uint      `json:"user_id"`
    UserName     string    `json:"user_name"`
    EvaluationID uint      `json:"evaluation_id"`
    Details      string    `json:"details"`
    IPAddress    string    `json:"ip_address"`
    Timestamp    time.Time `json:"timestamp"`
}
```

#### Criterios de Aceptación:
- [ ] DTOs para todas las operaciones admin
- [ ] Validaciones con binding tags
- [ ] Estructuras para estadísticas
- [ ] Respuestas para reportes

---

### TASK-003: Implementar repositorio administrativo
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:

```go
// internal/evaluation/repositories/admin_evaluation_repository.go
package repositories

import (
    "context"
    "fmt"
    "time"
    
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
    "github.com/EduGoGroup/edugo-shared/pkg/database"
    "gorm.io/gorm"
)

// AdminEvaluationRepository maneja acceso a datos para administradores
type AdminEvaluationRepository struct {
    db *gorm.DB
}

// NewAdminEvaluationRepository crea nueva instancia
func NewAdminEvaluationRepository() *AdminEvaluationRepository {
    return &AdminEvaluationRepository{
        db: database.GetDB(),
    }
}

// CreateEvaluation crea una nueva evaluación completa
func (r *AdminEvaluationRepository) CreateEvaluation(ctx context.Context, eval *evaluation.Evaluation) error {
    return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
        // Crear evaluación
        if err := tx.Create(eval).Error; err != nil {
            return fmt.Errorf("failed to create evaluation: %w", err)
        }
        
        // Crear preguntas si existen
        for i := range eval.Questions {
            eval.Questions[i].EvaluationID = eval.ID
            eval.Questions[i].OrderIndex = i + 1
            
            if err := tx.Create(&eval.Questions[i]).Error; err != nil {
                return fmt.Errorf("failed to create question %d: %w", i+1, err)
            }
            
            // Crear opciones
            for j := range eval.Questions[i].Options {
                eval.Questions[i].Options[j].QuestionID = eval.Questions[i].ID
                eval.Questions[i].Options[j].OrderIndex = j + 1
            }
            
            if len(eval.Questions[i].Options) > 0 {
                if err := tx.Create(&eval.Questions[i].Options).Error; err != nil {
                    return fmt.Errorf("failed to create options: %w", err)
                }
            }
        }
        
        return nil
    })
}

// UpdateEvaluation actualiza evaluación existente
func (r *AdminEvaluationRepository) UpdateEvaluation(ctx context.Context, eval *evaluation.Evaluation) error {
    return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
        // Actualizar evaluación
        if err := tx.Model(eval).Updates(eval).Error; err != nil {
            return fmt.Errorf("failed to update evaluation: %w", err)
        }
        
        // Si hay preguntas, manejar actualización compleja
        if len(eval.Questions) > 0 {
            // Obtener IDs de preguntas existentes
            var existingIDs []uint
            tx.Model(&evaluation.EvaluationQuestion{}).
                Where("evaluation_id = ?", eval.ID).
                Pluck("id", &existingIDs)
            
            // Crear mapa para tracking
            keepIDs := make(map[uint]bool)
            
            for i, q := range eval.Questions {
                q.EvaluationID = eval.ID
                q.OrderIndex = i + 1
                
                if q.ID > 0 {
                    // Actualizar existente
                    keepIDs[q.ID] = true
                    if err := tx.Save(&q).Error; err != nil {
                        return fmt.Errorf("failed to update question: %w", err)
                    }
                    
                    // Actualizar opciones
                    if err := r.updateQuestionOptions(tx, &q); err != nil {
                        return err
                    }
                } else {
                    // Crear nueva
                    if err := tx.Create(&q).Error; err != nil {
                        return fmt.Errorf("failed to create question: %w", err)
                    }
                    eval.Questions[i].ID = q.ID
                    
                    // Crear opciones
                    for j := range q.Options {
                        q.Options[j].QuestionID = q.ID
                    }
                    if len(q.Options) > 0 {
                        if err := tx.Create(&q.Options).Error; err != nil {
                            return fmt.Errorf("failed to create options: %w", err)
                        }
                    }
                }
            }
            
            // Eliminar preguntas que no están en keepIDs
            for _, id := range existingIDs {
                if !keepIDs[id] {
                    if err := tx.Delete(&evaluation.EvaluationQuestion{}, id).Error; err != nil {
                        return fmt.Errorf("failed to delete question: %w", err)
                    }
                }
            }
        }
        
        return nil
    })
}

func (r *AdminEvaluationRepository) updateQuestionOptions(tx *gorm.DB, question *evaluation.EvaluationQuestion) error {
    // Eliminar opciones existentes
    if err := tx.Where("question_id = ?", question.ID).Delete(&evaluation.QuestionOption{}).Error; err != nil {
        return fmt.Errorf("failed to delete old options: %w", err)
    }
    
    // Crear nuevas opciones
    for i := range question.Options {
        question.Options[i].QuestionID = question.ID
        question.Options[i].OrderIndex = i + 1
    }
    
    if len(question.Options) > 0 {
        if err := tx.Create(&question.Options).Error; err != nil {
            return fmt.Errorf("failed to create new options: %w", err)
        }
    }
    
    return nil
}

// DeleteEvaluation elimina evaluación (soft o hard delete)
func (r *AdminEvaluationRepository) DeleteEvaluation(ctx context.Context, id uint, hardDelete bool) error {
    if hardDelete {
        // Eliminar permanentemente (cascada con preguntas y opciones)
        return r.db.WithContext(ctx).Delete(&evaluation.Evaluation{}, id).Error
    }
    
    // Soft delete - cambiar estado
    return r.db.WithContext(ctx).
        Model(&evaluation.Evaluation{}).
        Where("id = ?", id).
        Update("status", evaluation.EvaluationStatusDeleted).Error
}

// GetEvaluationByID obtiene evaluación completa para admin
func (r *AdminEvaluationRepository) GetEvaluationByID(ctx context.Context, id uint) (*evaluation.Evaluation, error) {
    var eval evaluation.Evaluation
    
    err := r.db.WithContext(ctx).
        Preload("Questions", func(db *gorm.DB) *gorm.DB {
            return db.Order("order_index ASC")
        }).
        Preload("Questions.Options", func(db *gorm.DB) *gorm.DB {
            return db.Order("order_index ASC")
        }).
        First(&eval, id).Error
    
    if err != nil {
        return nil, fmt.Errorf("evaluation not found: %w", err)
    }
    
    return &eval, nil
}

// ListEvaluations lista evaluaciones con filtros avanzados
func (r *AdminEvaluationRepository) ListEvaluations(ctx context.Context, filters map[string]interface{}, offset, limit int) ([]*evaluation.Evaluation, int64, error) {
    var evaluations []*evaluation.Evaluation
    var total int64
    
    query := r.db.WithContext(ctx).Model(&evaluation.Evaluation{})
    
    // Aplicar filtros
    if subjectID, ok := filters["subject_id"].(uint); ok && subjectID > 0 {
        query = query.Where("subject_id = ?", subjectID)
    }
    
    if levelID, ok := filters["academic_level_id"].(uint); ok && levelID > 0 {
        query = query.Where("academic_level_id = ?", levelID)
    }
    
    if createdBy, ok := filters["created_by"].(uint); ok && createdBy > 0 {
        query = query.Where("created_by = ?", createdBy)
    }
    
    if status, ok := filters["status"].(string); ok && status != "" {
        query = query.Where("status = ?", status)
    }
    
    if search, ok := filters["search"].(string); ok && search != "" {
        searchPattern := fmt.Sprintf("%%%s%%", search)
        query = query.Where("title ILIKE ? OR description ILIKE ?", searchPattern, searchPattern)
    }
    
    // Filtros de fecha
    if dateFrom, ok := filters["date_from"].(*time.Time); ok && dateFrom != nil {
        query = query.Where("created_at >= ?", dateFrom)
    }
    
    if dateTo, ok := filters["date_to"].(*time.Time); ok && dateTo != nil {
        query = query.Where("created_at <= ?", dateTo)
    }
    
    // Tags (si implementamos campo JSONB)
    if tags, ok := filters["tags"].([]string); ok && len(tags) > 0 {
        // query = query.Where("tags @> ?", pq.Array(tags))
    }
    
    // Contar total
    if err := query.Count(&total).Error; err != nil {
        return nil, 0, fmt.Errorf("failed to count: %w", err)
    }
    
    // Ordenamiento
    sortBy := "created_at"
    if sb, ok := filters["sort_by"].(string); ok && sb != "" {
        sortBy = sb
    }
    
    sortOrder := "DESC"
    if so, ok := filters["sort_order"].(string); ok && so != "" {
        sortOrder = so
    }
    
    // Obtener resultados
    err := query.
        Offset(offset).
        Limit(limit).
        Order(fmt.Sprintf("%s %s", sortBy, sortOrder)).
        Find(&evaluations).Error
    
    if err != nil {
        return nil, 0, fmt.Errorf("failed to list: %w", err)
    }
    
    return evaluations, total, nil
}

// GetEvaluationStatistics obtiene estadísticas de una evaluación
func (r *AdminEvaluationRepository) GetEvaluationStatistics(ctx context.Context, evaluationID uint) (map[string]interface{}, error) {
    var stats struct {
        TotalSessions     int     `gorm:"column:total_sessions"`
        CompletedSessions int     `gorm:"column:completed_sessions"`
        AverageScore      float64 `gorm:"column:average_score"`
        AverageTime       int     `gorm:"column:average_time"`
        PassedCount       int     `gorm:"column:passed_count"`
        HighestScore      float64 `gorm:"column:highest_score"`
        LowestScore       float64 `gorm:"column:lowest_score"`
    }
    
    err := r.db.WithContext(ctx).
        Table("evaluation_sessions").
        Select(`
            COUNT(*) as total_sessions,
            COUNT(CASE WHEN status = 'graded' THEN 1 END) as completed_sessions,
            AVG(CASE WHEN r.percentage IS NOT NULL THEN r.percentage END) as average_score,
            AVG(time_spent_seconds) as average_time,
            COUNT(CASE WHEN r.passed = true THEN 1 END) as passed_count,
            MAX(r.percentage) as highest_score,
            MIN(r.percentage) as lowest_score
        `).
        Joins("LEFT JOIN evaluation_results r ON r.session_id = evaluation_sessions.id").
        Where("evaluation_sessions.evaluation_id = ?", evaluationID).
        Scan(&stats).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get statistics: %w", err)
    }
    
    passRate := 0.0
    if stats.CompletedSessions > 0 {
        passRate = float64(stats.PassedCount) / float64(stats.CompletedSessions) * 100
    }
    
    abandonRate := 0.0
    if stats.TotalSessions > 0 {
        abandonRate = float64(stats.TotalSessions-stats.CompletedSessions) / float64(stats.TotalSessions) * 100
    }
    
    return map[string]interface{}{
        "total_sessions":      stats.TotalSessions,
        "completed_sessions":  stats.CompletedSessions,
        "average_score":       stats.AverageScore,
        "average_time_spent":  stats.AverageTime,
        "pass_rate":           passRate,
        "abandon_rate":        abandonRate,
        "highest_score":       stats.HighestScore,
        "lowest_score":        stats.LowestScore,
    }, nil
}

// GetEvaluationResults obtiene todos los resultados de una evaluación
func (r *AdminEvaluationRepository) GetEvaluationResults(ctx context.Context, evaluationID uint, filters map[string]interface{}) ([]*evaluation.EvaluationResult, error) {
    var results []*evaluation.EvaluationResult
    
    query := r.db.WithContext(ctx).
        Joins("JOIN evaluation_sessions ON evaluation_results.session_id = evaluation_sessions.id").
        Where("evaluation_sessions.evaluation_id = ?", evaluationID)
    
    // Filtros opcionales
    if passed, ok := filters["passed"].(bool); ok {
        query = query.Where("evaluation_results.passed = ?", passed)
    }
    
    if minScore, ok := filters["min_score"].(float64); ok {
        query = query.Where("evaluation_results.percentage >= ?", minScore)
    }
    
    err := query.
        Order("evaluation_results.percentage DESC").
        Find(&results).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get results: %w", err)
    }
    
    return results, nil
}

// GetQuestionStatistics obtiene estadísticas por pregunta
func (r *AdminEvaluationRepository) GetQuestionStatistics(ctx context.Context, evaluationID uint) ([]map[string]interface{}, error) {
    var stats []struct {
        QuestionID   uint    `gorm:"column:question_id"`
        TimesAnswered int    `gorm:"column:times_answered"`
        TimesCorrect  int    `gorm:"column:times_correct"`
        AverageTime   int    `gorm:"column:average_time"`
        TimesSkipped  int    `gorm:"column:times_skipped"`
    }
    
    err := r.db.WithContext(ctx).
        Table("evaluation_questions q").
        Select(`
            q.id as question_id,
            COUNT(a.id) as times_answered,
            COUNT(CASE WHEN a.is_correct = true THEN 1 END) as times_correct,
            AVG(EXTRACT(EPOCH FROM (a.created_at - s.started_at))) as average_time,
            COUNT(CASE WHEN a.answer_text = '' AND a.selected_option_id IS NULL THEN 1 END) as times_skipped
        `).
        Joins("LEFT JOIN student_answers a ON a.question_id = q.id").
        Joins("LEFT JOIN evaluation_sessions s ON s.id = a.session_id").
        Where("q.evaluation_id = ?", evaluationID).
        Group("q.id").
        Scan(&stats).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get question stats: %w", err)
    }
    
    // Convertir a formato de respuesta
    results := make([]map[string]interface{}, len(stats))
    for i, s := range stats {
        correctRate := 0.0
        if s.TimesAnswered > 0 {
            correctRate = float64(s.TimesCorrect) / float64(s.TimesAnswered) * 100
        }
        
        results[i] = map[string]interface{}{
            "question_id":    s.QuestionID,
            "times_answered": s.TimesAnswered,
            "times_correct":  s.TimesCorrect,
            "correct_rate":   correctRate,
            "average_time":   s.AverageTime,
            "times_skipped":  s.TimesSkipped,
        }
    }
    
    return results, nil
}

// CloneEvaluation duplica una evaluación
func (r *AdminEvaluationRepository) CloneEvaluation(ctx context.Context, sourceID uint, newTitle string, createdBy uint) (*evaluation.Evaluation, error) {
    // Obtener evaluación original con preguntas
    source, err := r.GetEvaluationByID(ctx, sourceID)
    if err != nil {
        return nil, err
    }
    
    // Crear copia
    clone := &evaluation.Evaluation{
        Title:                  newTitle,
        Description:            source.Description,
        MaterialID:             source.MaterialID,
        SubjectID:              source.SubjectID,
        AcademicLevelID:        source.AcademicLevelID,
        CreatedBy:              createdBy,
        DurationMinutes:        source.DurationMinutes,
        PassingScore:           source.PassingScore,
        MaxAttempts:            source.MaxAttempts,
        ShuffleQuestions:       source.ShuffleQuestions,
        ShowResultsImmediately: source.ShowResultsImmediately,
        Status:                 evaluation.EvaluationStatusDraft,
    }
    
    // Copiar preguntas
    for _, q := range source.Questions {
        newQuestion := evaluation.EvaluationQuestion{
            QuestionText: q.QuestionText,
            QuestionType: q.QuestionType,
            Points:       q.Points,
            OrderIndex:   q.OrderIndex,
            Required:     q.Required,
            Explanation:  q.Explanation,
        }
        
        // Copiar opciones
        for _, opt := range q.Options {
            newQuestion.Options = append(newQuestion.Options, evaluation.QuestionOption{
                OptionText: opt.OptionText,
                IsCorrect:  opt.IsCorrect,
                OrderIndex: opt.OrderIndex,
            })
        }
        
        clone.Questions = append(clone.Questions, newQuestion)
    }
    
    // Guardar clon
    if err := r.CreateEvaluation(ctx, clone); err != nil {
        return nil, fmt.Errorf("failed to clone: %w", err)
    }
    
    return clone, nil
}

// BulkUpdateStatus actualiza estado de múltiples evaluaciones
func (r *AdminEvaluationRepository) BulkUpdateStatus(ctx context.Context, ids []uint, status evaluation.EvaluationStatus) error {
    return r.db.WithContext(ctx).
        Model(&evaluation.Evaluation{}).
        Where("id IN ?", ids).
        Update("status", status).Error
}

// GetActivityLog obtiene log de actividades
func (r *AdminEvaluationRepository) GetActivityLog(ctx context.Context, evaluationID uint, limit int) ([]map[string]interface{}, error) {
    // Esta funcionalidad requeriría una tabla de auditoría
    // Por ahora retornamos placeholder
    return []map[string]interface{}{}, nil
}
```

#### Criterios de Aceptación:
- [ ] CRUD completo de evaluaciones
- [ ] Estadísticas implementadas
- [ ] Clonación funcional
- [ ] Operaciones en lote
- [ ] Manejo de transacciones

---

### TASK-004: Implementar servicio administrativo
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:

```go
// internal/evaluation/services/admin_evaluation_service.go
package services

import (
    "context"
    "encoding/base64"
    "fmt"
    "time"
    
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
    "github.com/EduGoGroup/edugo-shared/pkg/messaging"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/dto"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/repositories"
)

// AdminEvaluationService servicio para administración de evaluaciones
type AdminEvaluationService struct {
    repo      *repositories.AdminEvaluationRepository
    publisher messaging.Publisher
}

// NewAdminEvaluationService crea nueva instancia
func NewAdminEvaluationService(repo *repositories.AdminEvaluationRepository, publisher messaging.Publisher) *AdminEvaluationService {
    return &AdminEvaluationService{
        repo:      repo,
        publisher: publisher,
    }
}

// CreateEvaluation crea nueva evaluación con preguntas
func (s *AdminEvaluationService) CreateEvaluation(ctx context.Context, req dto.CreateEvaluationRequest, createdBy uint) (*dto.AdminEvaluationResponse, error) {
    // Validar request
    if err := s.validateCreateRequest(req); err != nil {
        return nil, fmt.Errorf("validation failed: %w", err)
    }
    
    // Construir modelo
    eval := &evaluation.Evaluation{
        Title:                  req.Title,
        Description:            req.Description,
        MaterialID:             req.MaterialID,
        SubjectID:              req.SubjectID,
        AcademicLevelID:        req.AcademicLevelID,
        CreatedBy:              createdBy,
        DurationMinutes:        req.DurationMinutes,
        PassingScore:           req.PassingScore,
        MaxAttempts:            req.MaxAttempts,
        ShuffleQuestions:       req.ShuffleQuestions,
        ShowResultsImmediately: req.ShowResultsImmediately,
        Status:                 evaluation.EvaluationStatusDraft,
    }
    
    // Agregar preguntas
    for i, q := range req.Questions {
        question := evaluation.EvaluationQuestion{
            QuestionText: q.QuestionText,
            QuestionType: q.QuestionType,
            Points:       q.Points,
            OrderIndex:   i + 1,
            Required:     q.Required,
            Explanation:  q.Explanation,
        }
        
        // Agregar opciones
        if q.QuestionType.RequiresOptions() {
            for j, opt := range q.Options {
                question.Options = append(question.Options, evaluation.QuestionOption{
                    OptionText: opt.OptionText,
                    IsCorrect:  opt.IsCorrect,
                    OrderIndex: j + 1,
                })
            }
        }
        
        eval.Questions = append(eval.Questions, question)
    }
    
    // Guardar en base de datos
    if err := s.repo.CreateEvaluation(ctx, eval); err != nil {
        return nil, fmt.Errorf("failed to create: %w", err)
    }
    
    // Publicar evento
    event := map[string]interface{}{
        "evaluation_id": eval.ID,
        "created_by":    createdBy,
        "title":         eval.Title,
    }
    
    _ = s.publisher.Publish(ctx, evaluation.EventEvaluationCreated, event)
    
    // Construir respuesta
    return s.buildEvaluationResponse(eval), nil
}

// UpdateEvaluation actualiza evaluación existente
func (s *AdminEvaluationService) UpdateEvaluation(ctx context.Context, id uint, req dto.UpdateEvaluationRequest, updatedBy uint) error {
    // Obtener evaluación existente
    existing, err := s.repo.GetEvaluationByID(ctx, id)
    if err != nil {
        return err
    }
    
    // Aplicar actualizaciones
    if req.Title != nil {
        existing.Title = *req.Title
    }
    if req.Description != nil {
        existing.Description = *req.Description
    }
    if req.DurationMinutes != nil {
        existing.DurationMinutes = *req.DurationMinutes
    }
    if req.PassingScore != nil {
        existing.PassingScore = *req.PassingScore
    }
    if req.MaxAttempts != nil {
        existing.MaxAttempts = *req.MaxAttempts
    }
    if req.ShuffleQuestions != nil {
        existing.ShuffleQuestions = *req.ShuffleQuestions
    }
    if req.ShowResultsImmediately != nil {
        existing.ShowResultsImmediately = *req.ShowResultsImmediately
    }
    
    // Actualizar
    if err := s.repo.UpdateEvaluation(ctx, existing); err != nil {
        return fmt.Errorf("failed to update: %w", err)
    }
    
    // Publicar evento
    _ = s.publisher.Publish(ctx, evaluation.EventEvaluationUpdated, map[string]interface{}{
        "evaluation_id": id,
        "updated_by":    updatedBy,
    })
    
    return nil
}

// DeleteEvaluation elimina evaluación
func (s *AdminEvaluationService) DeleteEvaluation(ctx context.Context, id uint, hardDelete bool) error {
    // Verificar que no tiene sesiones activas
    stats, err := s.repo.GetEvaluationStatistics(ctx, id)
    if err != nil {
        return err
    }
    
    if totalSessions, ok := stats["total_sessions"].(int); ok && totalSessions > 0 && hardDelete {
        return fmt.Errorf("cannot hard delete evaluation with sessions")
    }
    
    // Eliminar
    if err := s.repo.DeleteEvaluation(ctx, id, hardDelete); err != nil {
        return fmt.Errorf("failed to delete: %w", err)
    }
    
    // Publicar evento
    _ = s.publisher.Publish(ctx, evaluation.EventEvaluationDeleted, map[string]interface{}{
        "evaluation_id": id,
        "hard_delete":   hardDelete,
    })
    
    return nil
}

// GetEvaluation obtiene evaluación con estadísticas
func (s *AdminEvaluationService) GetEvaluation(ctx context.Context, id uint, includeStats bool) (*dto.AdminEvaluationResponse, error) {
    // Obtener evaluación
    eval, err := s.repo.GetEvaluationByID(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // Construir respuesta
    response := s.buildEvaluationResponse(eval)
    
    // Agregar estadísticas si se solicita
    if includeStats {
        stats, err := s.repo.GetEvaluationStatistics(ctx, id)
        if err == nil {
            response.Statistics = s.buildStatistics(stats)
        }
    }
    
    return response, nil
}

// ListEvaluations lista evaluaciones con filtros
func (s *AdminEvaluationService) ListEvaluations(ctx context.Context, req dto.ListEvaluationsRequest) ([]*dto.AdminEvaluationResponse, int64, error) {
    // Preparar filtros
    filters := s.buildFilters(req)
    
    // Calcular offset
    offset := (req.Page - 1) * req.PageSize
    
    // Obtener evaluaciones
    evaluations, total, err := s.repo.ListEvaluations(ctx, filters, offset, req.PageSize)
    if err != nil {
        return nil, 0, err
    }
    
    // Construir respuestas
    responses := make([]*dto.AdminEvaluationResponse, len(evaluations))
    for i, eval := range evaluations {
        responses[i] = s.buildEvaluationResponse(eval)
    }
    
    return responses, total, nil
}

// GetEvaluationResults obtiene todos los resultados
func (s *AdminEvaluationService) GetEvaluationResults(ctx context.Context, evaluationID uint) (*dto.EvaluationResultsResponse, error) {
    // Obtener evaluación
    eval, err := s.repo.GetEvaluationByID(ctx, evaluationID)
    if err != nil {
        return nil, err
    }
    
    // Obtener resultados
    results, err := s.repo.GetEvaluationResults(ctx, evaluationID, nil)
    if err != nil {
        return nil, err
    }
    
    // Obtener estadísticas
    stats, _ := s.repo.GetEvaluationStatistics(ctx, evaluationID)
    
    // Obtener análisis por pregunta
    questionStats, _ := s.repo.GetQuestionStatistics(ctx, evaluationID)
    
    // Construir respuesta
    response := &dto.EvaluationResultsResponse{
        EvaluationID:    evaluationID,
        EvaluationTitle: eval.Title,
        TotalResults:    len(results),
        Results:         s.buildStudentResults(results),
        Statistics:      s.buildStatistics(stats),
        QuestionAnalysis: s.buildQuestionAnalysis(questionStats),
    }
    
    return response, nil
}

// GenerateWithAI genera preguntas con IA
func (s *AdminEvaluationService) GenerateWithAI(ctx context.Context, evaluationID uint, req dto.GenerateWithAIRequest) (*dto.GenerateAIResponse, error) {
    startTime := time.Now()
    
    // Preparar prompt para IA
    prompt := s.buildAIPrompt(req)
    
    // Publicar evento para worker
    event := map[string]interface{}{
        "evaluation_id":    evaluationID,
        "prompt":           prompt,
        "question_count":   req.QuestionCount,
        "question_types":   req.QuestionTypes,
        "difficulty_level": req.DifficultyLevel,
        "language":         req.Language,
    }
    
    if err := s.publisher.Publish(ctx, evaluation.EventGenerateWithAI, event); err != nil {
        return nil, fmt.Errorf("failed to request AI generation: %w", err)
    }
    
    // Por ahora retornamos respuesta mock
    // En producción, esto sería asíncrono y consultaría el estado
    return &dto.GenerateAIResponse{
        Success:        true,
        GeneratedCount: req.QuestionCount,
        Questions:      []dto.AdminQuestionResponse{},
        ProcessingTime: int(time.Since(startTime).Milliseconds()),
        AIModel:        "gpt-4-turbo",
        TokensUsed:     1500,
        EstimatedCost:  0.05,
    }, nil
}

// CloneEvaluation duplica una evaluación
func (s *AdminEvaluationService) CloneEvaluation(ctx context.Context, sourceID uint, req dto.CloneEvaluationRequest, createdBy uint) (*dto.CloneResponse, error) {
    // Clonar
    clone, err := s.repo.CloneEvaluation(ctx, sourceID, req.NewTitle, createdBy)
    if err != nil {
        return nil, err
    }
    
    // Aplicar modificaciones opcionales
    if req.TargetSubjectID != nil {
        clone.SubjectID = req.TargetSubjectID
        _ = s.repo.UpdateEvaluation(ctx, clone)
    }
    
    return &dto.CloneResponse{
        Success:         true,
        OriginalID:      sourceID,
        ClonedID:        clone.ID,
        ClonedTitle:     clone.Title,
        QuestionsCloned: len(clone.Questions),
    }, nil
}

// PublishEvaluation publica evaluación para estudiantes
func (s *AdminEvaluationService) PublishEvaluation(ctx context.Context, id uint, req dto.PublishEvaluationRequest) error {
    // Obtener evaluación
    eval, err := s.repo.GetEvaluationByID(ctx, id)
    if err != nil {
        return err
    }
    
    // Validar que tiene preguntas
    if len(eval.Questions) == 0 {
        return fmt.Errorf("cannot publish evaluation without questions")
    }
    
    // Cambiar estado
    eval.Status = evaluation.EvaluationStatusPublished
    
    // Actualizar
    if err := s.repo.UpdateEvaluation(ctx, eval); err != nil {
        return fmt.Errorf("failed to publish: %w", err)
    }
    
    // Publicar evento
    event := map[string]interface{}{
        "evaluation_id":   id,
        "notify_students": req.NotifyStudents,
        "message":         req.Message,
    }
    
    _ = s.publisher.Publish(ctx, "evaluation.published", event)
    
    return nil
}

// BatchOperation ejecuta operación en lote
func (s *AdminEvaluationService) BatchOperation(ctx context.Context, req dto.BatchUpdateRequest) (*dto.BatchOperationResponse, error) {
    response := &dto.BatchOperationResponse{
        Success: true,
        Results: make([]dto.BatchOperationResult, len(req.EvaluationIDs)),
    }
    
    for i, id := range req.EvaluationIDs {
        result := dto.BatchOperationResult{
            EvaluationID: id,
            Success:      true,
        }
        
        var err error
        switch req.Action {
        case "publish":
            eval, _ := s.repo.GetEvaluationByID(ctx, id)
            eval.Status = evaluation.EvaluationStatusPublished
            err = s.repo.UpdateEvaluation(ctx, eval)
            
        case "unpublish":
            eval, _ := s.repo.GetEvaluationByID(ctx, id)
            eval.Status = evaluation.EvaluationStatusDraft
            err = s.repo.UpdateEvaluation(ctx, eval)
            
        case "archive":
            eval, _ := s.repo.GetEvaluationByID(ctx, id)
            eval.Status = evaluation.EvaluationStatusArchived
            err = s.repo.UpdateEvaluation(ctx, eval)
            
        case "delete":
            err = s.repo.DeleteEvaluation(ctx, id, false)
        }
        
        if err != nil {
            result.Success = false
            result.Error = err.Error()
            response.FailedCount++
        } else {
            response.ProcessedCount++
        }
        
        response.Results[i] = result
    }
    
    return response, nil
}

// Helper functions

func (s *AdminEvaluationService) validateCreateRequest(req dto.CreateEvaluationRequest) error {
    // Validar que hay al menos una pregunta
    if len(req.Questions) == 0 {
        return fmt.Errorf("at least one question is required")
    }
    
    // Validar cada pregunta
    totalPoints := 0.0
    for _, q := range req.Questions {
        totalPoints += q.Points
        
        // Validar opciones para preguntas que las requieren
        if q.QuestionType.RequiresOptions() && len(q.Options) < 2 {
            return fmt.Errorf("question requires at least 2 options")
        }
        
        // Validar que hay al menos una opción correcta
        if q.QuestionType == evaluation.QuestionTypeMultipleChoice {
            hasCorrect := false
            for _, opt := range q.Options {
                if opt.IsCorrect {
                    hasCorrect = true
                    break
                }
            }
            if !hasCorrect {
                return fmt.Errorf("multiple choice question must have at least one correct option")
            }
        }
    }
    
    // Validar que el puntaje total permite aprobar
    if totalPoints < req.PassingScore {
        return fmt.Errorf("total points (%.2f) must be >= passing score (%.2f)", totalPoints, req.PassingScore)
    }
    
    return nil
}

func (s *AdminEvaluationService) buildEvaluationResponse(eval *evaluation.Evaluation) *dto.AdminEvaluationResponse {
    response := &dto.AdminEvaluationResponse{
        ID:                     eval.ID,
        Title:                  eval.Title,
        Description:            eval.Description,
        MaterialID:             eval.MaterialID,
        SubjectID:              eval.SubjectID,
        AcademicLevelID:        eval.AcademicLevelID,
        CreatedBy:              eval.CreatedBy,
        DurationMinutes:        eval.DurationMinutes,
        PassingScore:           eval.PassingScore,
        MaxAttempts:            eval.MaxAttempts,
        ShuffleQuestions:       eval.ShuffleQuestions,
        ShowResultsImmediately: eval.ShowResultsImmediately,
        Status:                 string(eval.Status),
        CreatedAt:              eval.CreatedAt,
        UpdatedAt:              eval.UpdatedAt,
    }
    
    // TODO: Obtener nombres de relaciones (material, subject, user)
    
    // Mapear preguntas
    if len(eval.Questions) > 0 {
        response.Questions = make([]dto.AdminQuestionResponse, len(eval.Questions))
        for i, q := range eval.Questions {
            response.Questions[i] = s.buildQuestionResponse(q)
        }
    }
    
    return response
}

func (s *AdminEvaluationService) buildQuestionResponse(q evaluation.EvaluationQuestion) dto.AdminQuestionResponse {
    response := dto.AdminQuestionResponse{
        ID:           q.ID,
        QuestionText: q.QuestionText,
        QuestionType: string(q.QuestionType),
        Points:       q.Points,
        OrderIndex:   q.OrderIndex,
        Required:     q.Required,
        Explanation:  q.Explanation,
    }
    
    // Mapear opciones
    if len(q.Options) > 0 {
        response.Options = make([]dto.AdminOptionResponse, len(q.Options))
        for i, opt := range q.Options {
            response.Options[i] = dto.AdminOptionResponse{
                ID:         opt.ID,
                OptionText: opt.OptionText,
                IsCorrect:  opt.IsCorrect,
                OrderIndex: opt.OrderIndex,
            }
        }
    }
    
    return response
}

func (s *AdminEvaluationService) buildStatistics(stats map[string]interface{}) *dto.EvaluationStatistics {
    return &dto.EvaluationStatistics{
        TotalSessions:     stats["total_sessions"].(int),
        CompletedSessions: stats["completed_sessions"].(int),
        AverageScore:      stats["average_score"].(float64),
        AverageTimeSpent:  stats["average_time_spent"].(int),
        PassRate:          stats["pass_rate"].(float64),
        AbandonRate:       stats["abandon_rate"].(float64),
        HighestScore:      stats["highest_score"].(float64),
        LowestScore:       stats["lowest_score"].(float64),
    }
}

func (s *AdminEvaluationService) buildStudentResults(results []*evaluation.EvaluationResult) []dto.StudentResultResponse {
    // TODO: Implementar mapeo completo con información del estudiante
    return []dto.StudentResultResponse{}
}

func (s *AdminEvaluationService) buildQuestionAnalysis(stats []map[string]interface{}) []dto.QuestionAnalysis {
    analyses := make([]dto.QuestionAnalysis, len(stats))
    for i, stat := range stats {
        analyses[i] = dto.QuestionAnalysis{
            QuestionID:  stat["question_id"].(uint),
            CorrectRate: stat["correct_rate"].(float64),
            AverageTime: stat["average_time"].(int),
        }
    }
    return analyses
}

func (s *AdminEvaluationService) buildFilters(req dto.ListEvaluationsRequest) map[string]interface{} {
    filters := make(map[string]interface{})
    
    if req.SubjectID != nil {
        filters["subject_id"] = *req.SubjectID
    }
    if req.AcademicLevelID != nil {
        filters["academic_level_id"] = *req.AcademicLevelID
    }
    if req.CreatedBy != nil {
        filters["created_by"] = *req.CreatedBy
    }
    if req.Status != "" {
        filters["status"] = req.Status
    }
    if req.Search != "" {
        filters["search"] = req.Search
    }
    if req.DateFrom != nil {
        filters["date_from"] = req.DateFrom
    }
    if req.DateTo != nil {
        filters["date_to"] = req.DateTo
    }
    if len(req.Tags) > 0 {
        filters["tags"] = req.Tags
    }
    
    filters["sort_by"] = req.SortBy
    filters["sort_order"] = req.SortOrder
    
    return filters
}

func (s *AdminEvaluationService) buildAIPrompt(req dto.GenerateWithAIRequest) string {
    prompt := fmt.Sprintf(`Generate %d questions for an educational evaluation.
Difficulty Level: %s
Question Types: %v
Language: %s

Additional Instructions: %s

Format each question as JSON with: question_text, question_type, points, options (if applicable), correct_answer, explanation.`,
        req.QuestionCount,
        req.DifficultyLevel,
        req.QuestionTypes,
        req.Language,
        req.Instructions,
    )
    
    if req.Content != "" {
        prompt = fmt.Sprintf("Based on the following content:\n%s\n\n%s", req.Content, prompt)
    }
    
    return prompt
}
```

#### Criterios de Aceptación:
- [ ] Lógica completa de administración
- [ ] Validaciones de negocio
- [ ] Publicación de eventos
- [ ] Generación con IA integrada
- [ ] Operaciones en lote

---

Continúo con las siguientes tareas... [El documento es muy largo, ¿quieres que continúe con las tareas 5-10 de api-administracion?]

### TASK-005: Implementar handlers administrativos
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:
