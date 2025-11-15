# 📋 Tareas - edugo-api-mobile - Sistema de Evaluaciones

## 📍 Información del Proyecto
- **Repositorio**: edugo-api-mobile
- **Branch**: feature/evaluation-endpoints
- **Dependencia**: edugo-shared v1.3.0 (DEBE estar publicado primero)
- **Tiempo Estimado**: 4 días (32 horas)
- **Path de trabajo**: `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile`
- **Puerto**: 8080

## ✅ Pre-requisitos
```bash
# Verificar que shared v1.3.0 está disponible
go list -m github.com/EduGoGroup/edugo-shared@v1.3.0
# Si no está disponible, DETENER y esperar a que se publique

# Navegar al proyecto
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Verificar estado
git status
go version  # Debe ser >= 1.21

# Crear branch de trabajo
git checkout main
git pull origin main
git checkout -b feature/evaluation-endpoints
```

## 📝 TAREAS DETALLADAS

### TASK-001: Actualizar dependencias y estructura
**Tipo**: setup  
**Prioridad**: HIGH  
**Estimación**: 1h  

#### Pasos de Implementación:
```bash
# 1. Actualizar go.mod con shared v1.3.0
go get github.com/EduGoGroup/edugo-shared@v1.3.0
go mod tidy

# 2. Crear estructura de directorios para evaluaciones
mkdir -p internal/evaluation/{handlers,services,repositories}
mkdir -p internal/evaluation/dto

# 3. Crear archivos base
touch internal/evaluation/handlers/evaluation_handler.go
touch internal/evaluation/handlers/student_evaluation_handler.go
touch internal/evaluation/services/evaluation_service.go
touch internal/evaluation/repositories/evaluation_repository.go
touch internal/evaluation/dto/requests.go
touch internal/evaluation/dto/responses.go

# 4. Crear tests
mkdir -p internal/evaluation/handlers/tests
mkdir -p internal/evaluation/services/tests
touch internal/evaluation/handlers/tests/evaluation_handler_test.go
touch internal/evaluation/services/tests/evaluation_service_test.go
```

#### Criterios de Aceptación:
- [ ] go.mod actualizado con shared v1.3.0
- [ ] Estructura de carpetas creada
- [ ] Dependencia importable sin errores
- [ ] go mod tidy sin warnings

#### Validación:
```bash
# Verificar que shared se importa correctamente
go list -m all | grep edugo-shared
# Output esperado: github.com/EduGoGroup/edugo-shared v1.3.0
```

---

### TASK-002: Implementar DTOs y mappers
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 2h  

#### Implementación:

```go
// internal/evaluation/dto/requests.go
package dto

import (
    "time"
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
)

// StartEvaluationRequest DTO para iniciar evaluación
type StartEvaluationRequest struct {
    // No body needed, evaluation_id viene del path
}

// SubmitAnswerRequest DTO para enviar una respuesta
type SubmitAnswerRequest struct {
    QuestionID       uint   `json:"question_id" binding:"required"`
    AnswerText       string `json:"answer_text,omitempty"`
    SelectedOptionID *uint  `json:"selected_option_id,omitempty"`
}

// SubmitEvaluationRequest DTO para finalizar evaluación
type SubmitEvaluationRequest struct {
    Answers []SubmitAnswerRequest `json:"answers,omitempty"`
}

// ListEvaluationsRequest query params para listar
type ListEvaluationsRequest struct {
    SubjectID       *uint   `form:"subject_id"`
    AcademicLevelID *uint   `form:"academic_level_id"`
    Status          string  `form:"status"`
    Search          string  `form:"search"`
    Page            int     `form:"page,default=1" binding:"min=1"`
    PageSize        int     `form:"page_size,default=20" binding:"min=1,max=100"`
}

// GetResultsRequest para obtener resultados
type GetResultsRequest struct {
    IncludeDetails bool `form:"include_details,default=false"`
}
```

```go
// internal/evaluation/dto/responses.go
package dto

import (
    "time"
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
)

// EvaluationListResponse respuesta para lista de evaluaciones
type EvaluationListResponse struct {
    ID               uint      `json:"id"`
    Title            string    `json:"title"`
    Description      string    `json:"description,omitempty"`
    SubjectName      string    `json:"subject_name,omitempty"`
    DurationMinutes  int       `json:"duration_minutes"`
    QuestionCount    int       `json:"question_count"`
    MaxAttempts      int       `json:"max_attempts"`
    AttemptsUsed     int       `json:"attempts_used"`
    Status           string    `json:"status"`
    CreatedAt        time.Time `json:"created_at"`
}

// EvaluationDetailResponse respuesta detallada de evaluación
type EvaluationDetailResponse struct {
    ID                     uint                    `json:"id"`
    Title                  string                  `json:"title"`
    Description            string                  `json:"description,omitempty"`
    MaterialID             *uint                   `json:"material_id,omitempty"`
    SubjectID              *uint                   `json:"subject_id,omitempty"`
    SubjectName            string                  `json:"subject_name,omitempty"`
    AcademicLevelID        *uint                   `json:"academic_level_id,omitempty"`
    AcademicLevelName      string                  `json:"academic_level_name,omitempty"`
    DurationMinutes        int                     `json:"duration_minutes"`
    PassingScore           float64                 `json:"passing_score"`
    MaxAttempts            int                     `json:"max_attempts"`
    AttemptsUsed           int                     `json:"attempts_used"`
    ShuffleQuestions       bool                    `json:"shuffle_questions"`
    ShowResultsImmediately bool                    `json:"show_results_immediately"`
    Status                 string                  `json:"status"`
    Questions              []QuestionResponse      `json:"questions,omitempty"`
    LastSession            *SessionSummaryResponse `json:"last_session,omitempty"`
    CreatedAt              time.Time               `json:"created_at"`
}

// QuestionResponse respuesta de pregunta
type QuestionResponse struct {
    ID           uint             `json:"id"`
    QuestionText string           `json:"question_text"`
    QuestionType string           `json:"question_type"`
    Points       float64          `json:"points"`
    OrderIndex   int              `json:"order_index"`
    Required     bool             `json:"required"`
    Options      []OptionResponse `json:"options,omitempty"`
}

// OptionResponse respuesta de opción
type OptionResponse struct {
    ID         uint   `json:"id"`
    OptionText string `json:"option_text"`
    OrderIndex int    `json:"order_index"`
    // IsCorrect se omite para estudiantes
}

// SessionStartResponse respuesta al iniciar sesión
type SessionStartResponse struct {
    SessionID       uint      `json:"session_id"`
    EvaluationID    uint      `json:"evaluation_id"`
    StartedAt       time.Time `json:"started_at"`
    ExpiresAt       time.Time `json:"expires_at"`
    AttemptNumber   int       `json:"attempt_number"`
    MaxAttempts     int       `json:"max_attempts"`
}

// SessionSummaryResponse resumen de sesión
type SessionSummaryResponse struct {
    SessionID        uint       `json:"session_id"`
    Status           string     `json:"status"`
    StartedAt        time.Time  `json:"started_at"`
    SubmittedAt      *time.Time `json:"submitted_at,omitempty"`
    TimeSpentSeconds int        `json:"time_spent_seconds,omitempty"`
    Score            *float64   `json:"score,omitempty"`
    Passed           *bool      `json:"passed,omitempty"`
}

// AnswerSavedResponse respuesta al guardar respuesta
type AnswerSavedResponse struct {
    QuestionID uint      `json:"question_id"`
    Saved      bool      `json:"saved"`
    SavedAt    time.Time `json:"saved_at"`
}

// SubmitResponse respuesta al enviar evaluación
type SubmitResponse struct {
    SessionID        uint      `json:"session_id"`
    Status           string    `json:"status"`
    SubmittedAt      time.Time `json:"submitted_at"`
    ProcessingStatus string    `json:"processing_status"`
    Message          string    `json:"message"`
}

// ResultResponse respuesta de resultados
type ResultResponse struct {
    SessionID      uint                 `json:"session_id"`
    EvaluationID   uint                 `json:"evaluation_id"`
    TotalScore     float64              `json:"total_score"`
    MaxScore       float64              `json:"max_score"`
    Percentage     float64              `json:"percentage"`
    Passed         bool                 `json:"passed"`
    PassingScore   float64              `json:"passing_score"`
    Ranking        int                  `json:"ranking,omitempty"`
    Percentile     int                  `json:"percentile,omitempty"`
    TimeSpent      string               `json:"time_spent"`
    Strengths      []string             `json:"strengths,omitempty"`
    Weaknesses     []string             `json:"weaknesses,omitempty"`
    AIFeedback     string               `json:"ai_feedback,omitempty"`
    Answers        []AnswerResultDetail `json:"answers,omitempty"`
    CompletedAt    time.Time            `json:"completed_at"`
}

// AnswerResultDetail detalle de respuesta en resultado
type AnswerResultDetail struct {
    QuestionID    uint    `json:"question_id"`
    QuestionText  string  `json:"question_text"`
    YourAnswer    string  `json:"your_answer"`
    CorrectAnswer string  `json:"correct_answer,omitempty"`
    IsCorrect     bool    `json:"is_correct"`
    PointsEarned  float64 `json:"points_earned"`
    MaxPoints     float64 `json:"max_points"`
    Explanation   string  `json:"explanation,omitempty"`
}

// HistoryResponse historial de evaluaciones
type HistoryResponse struct {
    TotalEvaluations   int                      `json:"total_evaluations"`
    CompletedCount     int                      `json:"completed_count"`
    AverageScore       float64                  `json:"average_score"`
    PassRate           float64                  `json:"pass_rate"`
    RecentEvaluations  []HistoryItemResponse    `json:"recent_evaluations"`
}

// HistoryItemResponse item del historial
type HistoryItemResponse struct {
    EvaluationID    uint       `json:"evaluation_id"`
    EvaluationTitle string     `json:"evaluation_title"`
    SubjectName     string     `json:"subject_name,omitempty"`
    SessionID       uint       `json:"session_id"`
    CompletedAt     time.Time  `json:"completed_at"`
    Score           float64    `json:"score"`
    Percentage      float64    `json:"percentage"`
    Passed          bool       `json:"passed"`
    TimeSpent       string     `json:"time_spent"`
}

// Mapper functions

// MapToEvaluationList convierte modelo a response de lista
func MapToEvaluationList(eval *evaluation.Evaluation, attemptsUsed int) EvaluationListResponse {
    return EvaluationListResponse{
        ID:              eval.ID,
        Title:           eval.Title,
        Description:     eval.Description,
        DurationMinutes: eval.DurationMinutes,
        QuestionCount:   len(eval.Questions),
        MaxAttempts:     eval.MaxAttempts,
        AttemptsUsed:    attemptsUsed,
        Status:          string(eval.Status),
        CreatedAt:       eval.CreatedAt,
    }
}

// MapToEvaluationDetail convierte modelo a response detallado
func MapToEvaluationDetail(eval *evaluation.Evaluation, attemptsUsed int, lastSession *evaluation.EvaluationSession) EvaluationDetailResponse {
    resp := EvaluationDetailResponse{
        ID:                     eval.ID,
        Title:                  eval.Title,
        Description:            eval.Description,
        MaterialID:             eval.MaterialID,
        SubjectID:              eval.SubjectID,
        AcademicLevelID:        eval.AcademicLevelID,
        DurationMinutes:        eval.DurationMinutes,
        PassingScore:           eval.PassingScore,
        MaxAttempts:            eval.MaxAttempts,
        AttemptsUsed:           attemptsUsed,
        ShuffleQuestions:       eval.ShuffleQuestions,
        ShowResultsImmediately: eval.ShowResultsImmediately,
        Status:                 string(eval.Status),
        CreatedAt:              eval.CreatedAt,
    }
    
    // Mapear preguntas
    if len(eval.Questions) > 0 {
        resp.Questions = make([]QuestionResponse, len(eval.Questions))
        for i, q := range eval.Questions {
            resp.Questions[i] = MapToQuestionResponse(q)
        }
    }
    
    // Mapear última sesión si existe
    if lastSession != nil {
        resp.LastSession = MapToSessionSummary(lastSession)
    }
    
    return resp
}

// MapToQuestionResponse convierte pregunta a response
func MapToQuestionResponse(q evaluation.EvaluationQuestion) QuestionResponse {
    resp := QuestionResponse{
        ID:           q.ID,
        QuestionText: q.QuestionText,
        QuestionType: string(q.QuestionType),
        Points:       q.Points,
        OrderIndex:   q.OrderIndex,
        Required:     q.Required,
    }
    
    // Mapear opciones (sin revelar respuesta correcta)
    if len(q.Options) > 0 {
        resp.Options = make([]OptionResponse, len(q.Options))
        for i, opt := range q.Options {
            resp.Options[i] = OptionResponse{
                ID:         opt.ID,
                OptionText: opt.OptionText,
                OrderIndex: opt.OrderIndex,
            }
        }
    }
    
    return resp
}

// MapToSessionSummary convierte sesión a resumen
func MapToSessionSummary(session *evaluation.EvaluationSession) *SessionSummaryResponse {
    summary := &SessionSummaryResponse{
        SessionID:   session.ID,
        Status:      string(session.Status),
        StartedAt:   session.StartedAt,
        SubmittedAt: session.SubmittedAt,
    }
    
    if session.SubmittedAt != nil {
        summary.TimeSpentSeconds = session.TimeSpentSeconds
    }
    
    if session.Result != nil {
        score := session.Result.TotalScore
        passed := session.Result.Passed
        summary.Score = &score
        summary.Passed = &passed
    }
    
    return summary
}
```

#### Criterios de Aceptación:
- [ ] DTOs para todos los endpoints definidos
- [ ] Funciones de mapeo implementadas
- [ ] Validaciones con binding tags
- [ ] Sin dependencias circulares

---

### TASK-003: Implementar repositorio de evaluaciones
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 2h  

#### Implementación:

```go
// internal/evaluation/repositories/evaluation_repository.go
package repositories

import (
    "context"
    "fmt"
    
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
    "github.com/EduGoGroup/edugo-shared/pkg/database"
    "gorm.io/gorm"
)

// EvaluationRepository maneja el acceso a datos de evaluaciones
type EvaluationRepository struct {
    db *gorm.DB
}

// NewEvaluationRepository crea una nueva instancia
func NewEvaluationRepository() *EvaluationRepository {
    return &EvaluationRepository{
        db: database.GetDB(),
    }
}

// GetAvailableEvaluations obtiene evaluaciones disponibles para un estudiante
func (r *EvaluationRepository) GetAvailableEvaluations(ctx context.Context, studentID uint, filters map[string]interface{}, offset, limit int) ([]*evaluation.Evaluation, int64, error) {
    var evaluations []*evaluation.Evaluation
    var total int64
    
    query := r.db.WithContext(ctx).
        Model(&evaluation.Evaluation{}).
        Where("status = ?", evaluation.EvaluationStatusPublished)
    
    // Aplicar filtros
    if subjectID, ok := filters["subject_id"].(uint); ok && subjectID > 0 {
        query = query.Where("subject_id = ?", subjectID)
    }
    
    if levelID, ok := filters["academic_level_id"].(uint); ok && levelID > 0 {
        query = query.Where("academic_level_id = ?", levelID)
    }
    
    if search, ok := filters["search"].(string); ok && search != "" {
        searchPattern := fmt.Sprintf("%%%s%%", search)
        query = query.Where("title ILIKE ? OR description ILIKE ?", searchPattern, searchPattern)
    }
    
    // Contar total
    if err := query.Count(&total).Error; err != nil {
        return nil, 0, fmt.Errorf("failed to count evaluations: %w", err)
    }
    
    // Obtener con paginación
    err := query.
        Offset(offset).
        Limit(limit).
        Order("created_at DESC").
        Find(&evaluations).Error
    
    if err != nil {
        return nil, 0, fmt.Errorf("failed to get evaluations: %w", err)
    }
    
    return evaluations, total, nil
}

// GetEvaluationForStudent obtiene una evaluación con validación de acceso
func (r *EvaluationRepository) GetEvaluationForStudent(ctx context.Context, evaluationID, studentID uint) (*evaluation.Evaluation, error) {
    var eval evaluation.Evaluation
    
    err := r.db.WithContext(ctx).
        Preload("Questions", func(db *gorm.DB) *gorm.DB {
            return db.Order("order_index ASC")
        }).
        Preload("Questions.Options", func(db *gorm.DB) *gorm.DB {
            return db.Order("order_index ASC")
        }).
        Where("id = ? AND status = ?", evaluationID, evaluation.EvaluationStatusPublished).
        First(&eval).Error
    
    if err != nil {
        if err == gorm.ErrRecordNotFound {
            return nil, fmt.Errorf("evaluation not found or not available")
        }
        return nil, fmt.Errorf("failed to get evaluation: %w", err)
    }
    
    return &eval, nil
}

// CountStudentAttempts cuenta los intentos de un estudiante
func (r *EvaluationRepository) CountStudentAttempts(ctx context.Context, evaluationID, studentID uint) (int, error) {
    var count int64
    
    err := r.db.WithContext(ctx).
        Model(&evaluation.EvaluationSession{}).
        Where("evaluation_id = ? AND student_id = ? AND status != ?", 
            evaluationID, studentID, evaluation.SessionStatusExpired).
        Count(&count).Error
    
    if err != nil {
        return 0, fmt.Errorf("failed to count attempts: %w", err)
    }
    
    return int(count), nil
}

// GetStudentSessions obtiene las sesiones de un estudiante
func (r *EvaluationRepository) GetStudentSessions(ctx context.Context, evaluationID, studentID uint) ([]*evaluation.EvaluationSession, error) {
    var sessions []*evaluation.EvaluationSession
    
    err := r.db.WithContext(ctx).
        Preload("Result").
        Where("evaluation_id = ? AND student_id = ?", evaluationID, studentID).
        Order("created_at DESC").
        Find(&sessions).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get sessions: %w", err)
    }
    
    return sessions, nil
}

// GetLastStudentSession obtiene la última sesión de un estudiante
func (r *EvaluationRepository) GetLastStudentSession(ctx context.Context, evaluationID, studentID uint) (*evaluation.EvaluationSession, error) {
    var session evaluation.EvaluationSession
    
    err := r.db.WithContext(ctx).
        Preload("Result").
        Where("evaluation_id = ? AND student_id = ?", evaluationID, studentID).
        Order("created_at DESC").
        First(&session).Error
    
    if err != nil {
        if err == gorm.ErrRecordNotFound {
            return nil, nil // No error, just no session
        }
        return nil, fmt.Errorf("failed to get last session: %w", err)
    }
    
    return &session, nil
}

// CreateSession crea una nueva sesión
func (r *EvaluationRepository) CreateSession(ctx context.Context, session *evaluation.EvaluationSession) error {
    if err := r.db.WithContext(ctx).Create(session).Error; err != nil {
        return fmt.Errorf("failed to create session: %w", err)
    }
    return nil
}

// GetSession obtiene una sesión con validación de pertenencia
func (r *EvaluationRepository) GetSession(ctx context.Context, sessionID, studentID uint) (*evaluation.EvaluationSession, error) {
    var session evaluation.EvaluationSession
    
    err := r.db.WithContext(ctx).
        Preload("Answers").
        Preload("Result").
        Where("id = ? AND student_id = ?", sessionID, studentID).
        First(&session).Error
    
    if err != nil {
        if err == gorm.ErrRecordNotFound {
            return nil, fmt.Errorf("session not found or access denied")
        }
        return nil, fmt.Errorf("failed to get session: %w", err)
    }
    
    return &session, nil
}

// GetSessionWithEvaluation obtiene sesión con su evaluación
func (r *EvaluationRepository) GetSessionWithEvaluation(ctx context.Context, sessionID, studentID uint) (*evaluation.EvaluationSession, *evaluation.Evaluation, error) {
    var session evaluation.EvaluationSession
    
    // Primero obtener la sesión
    err := r.db.WithContext(ctx).
        Preload("Answers").
        Preload("Result").
        Where("id = ? AND student_id = ?", sessionID, studentID).
        First(&session).Error
    
    if err != nil {
        if err == gorm.ErrRecordNotFound {
            return nil, nil, fmt.Errorf("session not found or access denied")
        }
        return nil, nil, fmt.Errorf("failed to get session: %w", err)
    }
    
    // Luego obtener la evaluación
    var eval evaluation.Evaluation
    err = r.db.WithContext(ctx).
        Preload("Questions").
        Preload("Questions.Options").
        First(&eval, session.EvaluationID).Error
    
    if err != nil {
        return nil, nil, fmt.Errorf("failed to get evaluation: %w", err)
    }
    
    return &session, &eval, nil
}

// SaveAnswer guarda o actualiza una respuesta
func (r *EvaluationRepository) SaveAnswer(ctx context.Context, answer *evaluation.StudentAnswer) error {
    // Verificar si ya existe
    var existing evaluation.StudentAnswer
    err := r.db.WithContext(ctx).
        Where("session_id = ? AND question_id = ?", answer.SessionID, answer.QuestionID).
        First(&existing).Error
    
    if err == nil {
        // Actualizar existente
        answer.ID = existing.ID
        return r.db.WithContext(ctx).Save(answer).Error
    }
    
    // Crear nueva
    return r.db.WithContext(ctx).Create(answer).Error
}

// UpdateSessionStatus actualiza el estado de una sesión
func (r *EvaluationRepository) UpdateSessionStatus(ctx context.Context, session *evaluation.EvaluationSession) error {
    return r.db.WithContext(ctx).
        Model(session).
        Updates(map[string]interface{}{
            "status":             session.Status,
            "submitted_at":       session.SubmittedAt,
            "time_spent_seconds": session.TimeSpentSeconds,
        }).Error
}

// GetStudentHistory obtiene el historial de evaluaciones de un estudiante
func (r *EvaluationRepository) GetStudentHistory(ctx context.Context, studentID uint, limit int) ([]*evaluation.EvaluationResult, error) {
    var results []*evaluation.EvaluationResult
    
    err := r.db.WithContext(ctx).
        Joins("JOIN evaluation_sessions ON evaluation_results.session_id = evaluation_sessions.id").
        Joins("JOIN evaluations ON evaluation_sessions.evaluation_id = evaluations.id").
        Where("evaluation_sessions.student_id = ?", studentID).
        Order("evaluation_results.created_at DESC").
        Limit(limit).
        Find(&results).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get history: %w", err)
    }
    
    return results, nil
}

// GetEvaluationStats obtiene estadísticas de un estudiante
func (r *EvaluationRepository) GetEvaluationStats(ctx context.Context, studentID uint) (map[string]interface{}, error) {
    var stats struct {
        TotalEvaluations int     `gorm:"column:total_evaluations"`
        CompletedCount   int     `gorm:"column:completed_count"`
        AverageScore     float64 `gorm:"column:average_score"`
        PassedCount      int     `gorm:"column:passed_count"`
    }
    
    err := r.db.WithContext(ctx).
        Model(&evaluation.EvaluationResult{}).
        Select(`
            COUNT(DISTINCT evaluation_sessions.evaluation_id) as total_evaluations,
            COUNT(*) as completed_count,
            AVG(evaluation_results.percentage) as average_score,
            SUM(CASE WHEN evaluation_results.passed THEN 1 ELSE 0 END) as passed_count
        `).
        Joins("JOIN evaluation_sessions ON evaluation_results.session_id = evaluation_sessions.id").
        Where("evaluation_sessions.student_id = ?", studentID).
        Scan(&stats).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get stats: %w", err)
    }
    
    passRate := 0.0
    if stats.CompletedCount > 0 {
        passRate = float64(stats.PassedCount) / float64(stats.CompletedCount) * 100
    }
    
    return map[string]interface{}{
        "total_evaluations": stats.TotalEvaluations,
        "completed_count":   stats.CompletedCount,
        "average_score":     stats.AverageScore,
        "pass_rate":         passRate,
    }, nil
}

// GetQuestionByID obtiene una pregunta por ID
func (r *EvaluationRepository) GetQuestionByID(ctx context.Context, questionID uint) (*evaluation.EvaluationQuestion, error) {
    var question evaluation.EvaluationQuestion
    
    err := r.db.WithContext(ctx).
        Preload("Options").
        First(&question, questionID).Error
    
    if err != nil {
        return nil, fmt.Errorf("failed to get question: %w", err)
    }
    
    return &question, nil
}

// Transaction ejecuta una función en transacción
func (r *EvaluationRepository) Transaction(ctx context.Context, fn func(*gorm.DB) error) error {
    return r.db.WithContext(ctx).Transaction(fn)
}
```

#### Criterios de Aceptación:
- [ ] Métodos para todas las operaciones de estudiante
- [ ] Validación de acceso incluida
- [ ] Manejo de errores consistente
- [ ] Soporte para transacciones

---

### TASK-004: Implementar servicio de evaluaciones
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:

```go
// internal/evaluation/services/evaluation_service.go
package services

import (
    "context"
    "fmt"
    "time"
    
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
    "github.com/EduGoGroup/edugo-shared/pkg/messaging"
    "github.com/EduGoGroup/edugo-api-mobile/internal/evaluation/dto"
    "github.com/EduGoGroup/edugo-api-mobile/internal/evaluation/repositories"
)

// EvaluationService maneja la lógica de negocio de evaluaciones
type EvaluationService struct {
    repo      *repositories.EvaluationRepository
    publisher messaging.Publisher
}

// NewEvaluationService crea una nueva instancia
func NewEvaluationService(repo *repositories.EvaluationRepository, publisher messaging.Publisher) *EvaluationService {
    return &EvaluationService{
        repo:      repo,
        publisher: publisher,
    }
}

// GetAvailableEvaluations obtiene evaluaciones disponibles para un estudiante
func (s *EvaluationService) GetAvailableEvaluations(ctx context.Context, studentID uint, req dto.ListEvaluationsRequest) ([]dto.EvaluationListResponse, int64, error) {
    // Preparar filtros
    filters := make(map[string]interface{})
    if req.SubjectID != nil {
        filters["subject_id"] = *req.SubjectID
    }
    if req.AcademicLevelID != nil {
        filters["academic_level_id"] = *req.AcademicLevelID
    }
    if req.Search != "" {
        filters["search"] = req.Search
    }
    if req.Status != "" {
        filters["status"] = req.Status
    }
    
    // Calcular offset
    offset := (req.Page - 1) * req.PageSize
    
    // Obtener evaluaciones
    evaluations, total, err := s.repo.GetAvailableEvaluations(ctx, studentID, filters, offset, req.PageSize)
    if err != nil {
        return nil, 0, err
    }
    
    // Convertir a DTOs
    responses := make([]dto.EvaluationListResponse, len(evaluations))
    for i, eval := range evaluations {
        // Contar intentos del estudiante
        attempts, _ := s.repo.CountStudentAttempts(ctx, eval.ID, studentID)
        responses[i] = dto.MapToEvaluationList(eval, attempts)
    }
    
    return responses, total, nil
}

// GetEvaluationDetail obtiene el detalle de una evaluación
func (s *EvaluationService) GetEvaluationDetail(ctx context.Context, evaluationID, studentID uint) (*dto.EvaluationDetailResponse, error) {
    // Obtener evaluación
    eval, err := s.repo.GetEvaluationForStudent(ctx, evaluationID, studentID)
    if err != nil {
        return nil, err
    }
    
    // Contar intentos
    attempts, err := s.repo.CountStudentAttempts(ctx, evaluationID, studentID)
    if err != nil {
        return nil, err
    }
    
    // Obtener última sesión si existe
    lastSession, _ := s.repo.GetLastStudentSession(ctx, evaluationID, studentID)
    
    // Convertir a DTO
    response := dto.MapToEvaluationDetail(eval, attempts, lastSession)
    
    // TODO: Obtener nombres de subject y academic_level de sus repos
    
    return &response, nil
}

// StartEvaluation inicia una nueva sesión de evaluación
func (s *EvaluationService) StartEvaluation(ctx context.Context, evaluationID, studentID uint, ipAddress, userAgent string) (*dto.SessionStartResponse, error) {
    // Verificar que la evaluación existe y está disponible
    eval, err := s.repo.GetEvaluationForStudent(ctx, evaluationID, studentID)
    if err != nil {
        return nil, err
    }
    
    // Verificar intentos máximos
    attempts, err := s.repo.CountStudentAttempts(ctx, evaluationID, studentID)
    if err != nil {
        return nil, err
    }
    
    if attempts >= eval.MaxAttempts {
        return nil, fmt.Errorf("maximum attempts reached (%d/%d)", attempts, eval.MaxAttempts)
    }
    
    // Verificar si hay sesión activa
    sessions, err := s.repo.GetStudentSessions(ctx, evaluationID, studentID)
    if err != nil {
        return nil, err
    }
    
    for _, sess := range sessions {
        if sess.Status == evaluation.SessionStatusInProgress {
            // Ya hay sesión activa, retornarla
            expiresAt := sess.StartedAt.Add(time.Duration(eval.DurationMinutes) * time.Minute)
            return &dto.SessionStartResponse{
                SessionID:     sess.ID,
                EvaluationID:  evaluationID,
                StartedAt:     sess.StartedAt,
                ExpiresAt:     expiresAt,
                AttemptNumber: sess.AttemptNumber,
                MaxAttempts:   eval.MaxAttempts,
            }, nil
        }
    }
    
    // Crear nueva sesión
    session := &evaluation.EvaluationSession{
        EvaluationID:  evaluationID,
        StudentID:     studentID,
        StartedAt:     time.Now(),
        Status:        evaluation.SessionStatusInProgress,
        AttemptNumber: attempts + 1,
        IPAddress:     ipAddress,
        UserAgent:     userAgent,
    }
    
    if err := s.repo.CreateSession(ctx, session); err != nil {
        return nil, fmt.Errorf("failed to start evaluation: %w", err)
    }
    
    // Calcular tiempo de expiración
    expiresAt := session.StartedAt.Add(time.Duration(eval.DurationMinutes) * time.Minute)
    
    // Publicar evento
    event := map[string]interface{}{
        "session_id":     session.ID,
        "evaluation_id":  evaluationID,
        "student_id":     studentID,
        "started_at":     session.StartedAt,
        "attempt_number": session.AttemptNumber,
    }
    
    if err := s.publisher.Publish(ctx, evaluation.EventEvaluationStarted, event); err != nil {
        // Log error but don't fail
        fmt.Printf("Failed to publish event: %v\n", err)
    }
    
    return &dto.SessionStartResponse{
        SessionID:     session.ID,
        EvaluationID:  evaluationID,
        StartedAt:     session.StartedAt,
        ExpiresAt:     expiresAt,
        AttemptNumber: session.AttemptNumber,
        MaxAttempts:   eval.MaxAttempts,
    }, nil
}

// SaveAnswer guarda una respuesta del estudiante
func (s *EvaluationService) SaveAnswer(ctx context.Context, sessionID, studentID uint, req dto.SubmitAnswerRequest) (*dto.AnswerSavedResponse, error) {
    // Verificar que la sesión pertenece al estudiante y está activa
    session, err := s.repo.GetSession(ctx, sessionID, studentID)
    if err != nil {
        return nil, err
    }
    
    if session.Status != evaluation.SessionStatusInProgress {
        return nil, fmt.Errorf("session is not active")
    }
    
    // Verificar que no ha expirado
    // TODO: Obtener duración de la evaluación
    // Por ahora asumimos que no ha expirado
    
    // Verificar que la pregunta existe
    question, err := s.repo.GetQuestionByID(ctx, req.QuestionID)
    if err != nil {
        return nil, fmt.Errorf("question not found")
    }
    
    // Crear respuesta
    answer := &evaluation.StudentAnswer{
        SessionID:        sessionID,
        QuestionID:       req.QuestionID,
        AnswerText:       req.AnswerText,
        SelectedOptionID: req.SelectedOptionID,
    }
    
    // Guardar
    if err := s.repo.SaveAnswer(ctx, answer); err != nil {
        return nil, fmt.Errorf("failed to save answer: %w", err)
    }
    
    return &dto.AnswerSavedResponse{
        QuestionID: req.QuestionID,
        Saved:      true,
        SavedAt:    time.Now(),
    }, nil
}

// SubmitEvaluation envía la evaluación para calificación
func (s *EvaluationService) SubmitEvaluation(ctx context.Context, sessionID, studentID uint, req dto.SubmitEvaluationRequest) (*dto.SubmitResponse, error) {
    // Verificar sesión
    session, err := s.repo.GetSession(ctx, sessionID, studentID)
    if err != nil {
        return nil, err
    }
    
    if session.Status != evaluation.SessionStatusInProgress {
        return nil, fmt.Errorf("session already submitted or expired")
    }
    
    // Si hay respuestas finales, guardarlas
    for _, ans := range req.Answers {
        saveReq := dto.SubmitAnswerRequest{
            QuestionID:       ans.QuestionID,
            AnswerText:       ans.AnswerText,
            SelectedOptionID: ans.SelectedOptionID,
        }
        if _, err := s.SaveAnswer(ctx, sessionID, studentID, saveReq); err != nil {
            // Log but continue
            fmt.Printf("Failed to save answer: %v\n", err)
        }
    }
    
    // Actualizar estado de sesión
    now := time.Now()
    session.SubmittedAt = &now
    session.TimeSpentSeconds = int(now.Sub(session.StartedAt).Seconds())
    session.Status = evaluation.SessionStatusSubmitted
    
    if err := s.repo.UpdateSessionStatus(ctx, session); err != nil {
        return nil, fmt.Errorf("failed to submit evaluation: %w", err)
    }
    
    // Publicar evento para procesamiento asíncrono
    event := map[string]interface{}{
        "session_id":    sessionID,
        "evaluation_id": session.EvaluationID,
        "student_id":    studentID,
        "submitted_at":  now,
    }
    
    if err := s.publisher.Publish(ctx, evaluation.EventEvaluationSubmitted, event); err != nil {
        // Log but don't fail
        fmt.Printf("Failed to publish submit event: %v\n", err)
    }
    
    return &dto.SubmitResponse{
        SessionID:        sessionID,
        Status:           string(session.Status),
        SubmittedAt:      now,
        ProcessingStatus: "queued",
        Message:          "Your evaluation has been submitted and is being processed",
    }, nil
}

// GetResults obtiene los resultados de una evaluación
func (s *EvaluationService) GetResults(ctx context.Context, sessionID, studentID uint, includeDetails bool) (*dto.ResultResponse, error) {
    // Obtener sesión con evaluación
    session, eval, err := s.repo.GetSessionWithEvaluation(ctx, sessionID, studentID)
    if err != nil {
        return nil, err
    }
    
    // Verificar que hay resultado
    if session.Result == nil {
        return nil, fmt.Errorf("results not available yet")
    }
    
    result := session.Result
    
    // Construir respuesta
    response := &dto.ResultResponse{
        SessionID:    sessionID,
        EvaluationID: session.EvaluationID,
        TotalScore:   result.TotalScore,
        MaxScore:     s.calculateMaxScore(eval.Questions),
        Percentage:   result.Percentage,
        Passed:       result.Passed,
        PassingScore: eval.PassingScore,
        Ranking:      result.Ranking,
        TimeSpent:    s.formatTimeSpent(session.TimeSpentSeconds),
        Strengths:    result.Strengths,
        Weaknesses:   result.Weaknesses,
        AIFeedback:   result.AIAnalysis,
        CompletedAt:  result.CreatedAt,
    }
    
    // Calcular percentil si hay ranking
    if result.Ranking > 0 {
        // TODO: Calcular percentil basado en total de estudiantes
        response.Percentile = 100 - (result.Ranking * 10) // Placeholder
    }
    
    // Incluir detalles si se solicita
    if includeDetails && len(session.Answers) > 0 {
        response.Answers = s.buildAnswerDetails(session.Answers, eval.Questions)
    }
    
    return response, nil
}

// GetHistory obtiene el historial de evaluaciones de un estudiante
func (s *EvaluationService) GetHistory(ctx context.Context, studentID uint) (*dto.HistoryResponse, error) {
    // Obtener estadísticas
    stats, err := s.repo.GetEvaluationStats(ctx, studentID)
    if err != nil {
        return nil, err
    }
    
    // Obtener evaluaciones recientes
    results, err := s.repo.GetStudentHistory(ctx, studentID, 10)
    if err != nil {
        return nil, err
    }
    
    // Construir items del historial
    items := make([]dto.HistoryItemResponse, len(results))
    for i, r := range results {
        // TODO: Obtener título de evaluación y nombre de materia
        items[i] = dto.HistoryItemResponse{
            SessionID:   r.SessionID,
            CompletedAt: r.CreatedAt,
            Score:       r.TotalScore,
            Percentage:  r.Percentage,
            Passed:      r.Passed,
            TimeSpent:   "N/A", // TODO: Calcular desde sesión
        }
    }
    
    return &dto.HistoryResponse{
        TotalEvaluations:  stats["total_evaluations"].(int),
        CompletedCount:    stats["completed_count"].(int),
        AverageScore:      stats["average_score"].(float64),
        PassRate:          stats["pass_rate"].(float64),
        RecentEvaluations: items,
    }, nil
}

// Helper functions

func (s *EvaluationService) calculateMaxScore(questions []evaluation.EvaluationQuestion) float64 {
    total := 0.0
    for _, q := range questions {
        total += q.Points
    }
    return total
}

func (s *EvaluationService) formatTimeSpent(seconds int) string {
    if seconds < 60 {
        return fmt.Sprintf("%d seconds", seconds)
    } else if seconds < 3600 {
        minutes := seconds / 60
        secs := seconds % 60
        return fmt.Sprintf("%d minutes %d seconds", minutes, secs)
    } else {
        hours := seconds / 3600
        minutes := (seconds % 3600) / 60
        return fmt.Sprintf("%d hours %d minutes", hours, minutes)
    }
}

func (s *EvaluationService) buildAnswerDetails(answers []evaluation.StudentAnswer, questions []evaluation.EvaluationQuestion) []dto.AnswerResultDetail {
    // Crear mapa de preguntas para búsqueda rápida
    questionMap := make(map[uint]evaluation.EvaluationQuestion)
    for _, q := range questions {
        questionMap[q.ID] = q
    }
    
    // Construir detalles
    details := make([]dto.AnswerResultDetail, len(answers))
    for i, ans := range answers {
        q := questionMap[ans.QuestionID]
        
        detail := dto.AnswerResultDetail{
            QuestionID:   ans.QuestionID,
            QuestionText: q.QuestionText,
            PointsEarned: ans.PointsEarned,
            MaxPoints:    q.Points,
            Explanation:  q.Explanation,
        }
        
        // Agregar respuesta del estudiante
        if ans.AnswerText != "" {
            detail.YourAnswer = ans.AnswerText
        } else if ans.SelectedOptionID != nil {
            // Buscar texto de la opción seleccionada
            for _, opt := range q.Options {
                if opt.ID == *ans.SelectedOptionID {
                    detail.YourAnswer = opt.OptionText
                    break
                }
            }
        }
        
        // Agregar respuesta correcta si está mal
        if ans.IsCorrect != nil && !*ans.IsCorrect {
            // Para opción múltiple, mostrar la opción correcta
            if q.QuestionType == evaluation.QuestionTypeMultipleChoice {
                for _, opt := range q.Options {
                    if opt.IsCorrect {
                        detail.CorrectAnswer = opt.OptionText
                        break
                    }
                }
            }
        }
        
        if ans.IsCorrect != nil {
            detail.IsCorrect = *ans.IsCorrect
        }
        
        details[i] = detail
    }
    
    return details
}
```

#### Criterios de Aceptación:
- [ ] Lógica de negocio completa
- [ ] Validaciones de negocio implementadas
- [ ] Publicación de eventos a RabbitMQ
- [ ] Manejo de errores robusto
- [ ] Helpers para formateo de datos

---

### TASK-005: Implementar handlers REST
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:

```go
// internal/evaluation/handlers/evaluation_handler.go
package handlers

import (
    "net/http"
    "strconv"
    
    "github.com/gin-gonic/gin"
    "github.com/EduGoGroup/edugo-api-mobile/internal/evaluation/dto"
    "github.com/EduGoGroup/edugo-api-mobile/internal/evaluation/services"
    "github.com/EduGoGroup/edugo-api-mobile/internal/middleware"
)

// EvaluationHandler maneja los endpoints de evaluaciones
type EvaluationHandler struct {
    service *services.EvaluationService
}

// NewEvaluationHandler crea una nueva instancia
func NewEvaluationHandler(service *services.EvaluationService) *EvaluationHandler {
    return &EvaluationHandler{
        service: service,
    }
}

// ListEvaluations godoc
// @Summary Lista evaluaciones disponibles
// @Description Obtiene lista de evaluaciones disponibles para el estudiante
// @Tags evaluations
// @Accept json
// @Produce json
// @Param subject_id query int false "ID de la materia"
// @Param academic_level_id query int false "ID del nivel académico"
// @Param search query string false "Término de búsqueda"
// @Param page query int false "Número de página" default(1)
// @Param page_size query int false "Tamaño de página" default(20)
// @Success 200 {object} map[string]interface{} "Lista de evaluaciones"
// @Failure 400 {object} map[string]string "Bad request"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Router /evaluations [get]
func (h *EvaluationHandler) ListEvaluations(c *gin.Context) {
    // Obtener usuario del contexto
    userID, exists := c.Get("userID")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "user not authenticated"})
        return
    }
    
    studentID := userID.(uint)
    
    // Parsear query params
    var req dto.ListEvaluationsRequest
    if err := c.ShouldBindQuery(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    // Obtener evaluaciones
    evaluations, total, err := h.service.GetAvailableEvaluations(c.Request.Context(), studentID, req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get evaluations"})
        return
    }
    
    // Calcular metadata de paginación
    totalPages := (int(total) + req.PageSize - 1) / req.PageSize
    
    c.JSON(http.StatusOK, gin.H{
        "data": evaluations,
        "meta": gin.H{
            "total":       total,
            "page":        req.Page,
            "page_size":   req.PageSize,
            "total_pages": totalPages,
        },
    })
}

// GetEvaluation godoc
// @Summary Obtiene detalle de evaluación
// @Description Obtiene información detallada de una evaluación específica
// @Tags evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de la evaluación"
// @Success 200 {object} dto.EvaluationDetailResponse "Detalle de evaluación"
// @Failure 400 {object} map[string]string "Bad request"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Failure 404 {object} map[string]string "Not found"
// @Router /evaluations/{id} [get]
func (h *EvaluationHandler) GetEvaluation(c *gin.Context) {
    // Obtener usuario del contexto
    userID, exists := c.Get("userID")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "user not authenticated"})
        return
    }
    
    studentID := userID.(uint)
    
    // Obtener ID de la evaluación
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid evaluation ID"})
        return
    }
    
    // Obtener evaluación
    evaluation, err := h.service.GetEvaluationDetail(c.Request.Context(), uint(evaluationID), studentID)
    if err != nil {
        if err.Error() == "evaluation not found or not available" {
            c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
        } else {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get evaluation"})
        }
        return
    }
    
    c.JSON(http.StatusOK, evaluation)
}

// StartEvaluation godoc
// @Summary Inicia una evaluación
// @Description Crea una nueva sesión para tomar la evaluación
// @Tags evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de la evaluación"
// @Success 200 {object} dto.SessionStartResponse "Sesión iniciada"
// @Failure 400 {object} map[string]string "Bad request"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Failure 403 {object} map[string]string "Forbidden"
// @Router /evaluations/{id}/start [post]
func (h *EvaluationHandler) StartEvaluation(c *gin.Context) {
    // Obtener usuario del contexto
    userID, exists := c.Get("userID")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "user not authenticated"})
        return
    }
    
    studentID := userID.(uint)
    
    // Obtener ID de la evaluación
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid evaluation ID"})
        return
    }
    
    // Obtener IP y User Agent
    ipAddress := c.ClientIP()
    userAgent := c.Request.UserAgent()
    
    // Iniciar evaluación
    session, err := h.service.StartEvaluation(c.Request.Context(), uint(evaluationID), studentID, ipAddress, userAgent)
    if err != nil {
        if err.Error() == "maximum attempts reached" {
            c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
        } else {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to start evaluation"})
        }
        return
    }
    
    c.JSON(http.StatusOK, session)
}

// SubmitAnswer godoc
// @Summary Guarda una respuesta
// @Description Guarda la respuesta de una pregunta durante la evaluación
// @Tags evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de la evaluación"
// @Param session_id path int true "ID de la sesión"
// @Param body body dto.SubmitAnswerRequest true "Respuesta"
// @Success 200 {object} dto.AnswerSavedResponse "Respuesta guardada"
// @Failure 400 {object} map[string]string "Bad request"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Router /evaluations/{id}/sessions/{session_id}/answer [post]
func (h *EvaluationHandler) SubmitAnswer(c *gin.Context) {
    // Obtener usuario del contexto
    userID, exists := c.Get("userID")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "user not authenticated"})
        return
    }
    
    studentID := userID.(uint)
    
    // Obtener IDs
    sessionID, err := strconv.ParseUint(c.Param("session_id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid session ID"})
        return
    }
    
    // Parsear body
    var req dto.SubmitAnswerRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    // Guardar respuesta
    response, err := h.service.SaveAnswer(c.Request.Context(), uint(sessionID), studentID, req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save answer"})
        return
    }
    
    c.JSON(http.StatusOK, response)
}

// SubmitEvaluation godoc
// @Summary Envía evaluación para calificación
// @Description Finaliza la evaluación y la envía para procesamiento
// @Tags evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de la evaluación"
// @Param session_id path int true "ID de la sesión"
// @Param body body dto.SubmitEvaluationRequest false "Respuestas finales opcionales"
// @Success 200 {object} dto.SubmitResponse "Evaluación enviada"
// @Failure 400 {object} map[string]string "Bad request"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Router /evaluations/{id}/sessions/{session_id}/submit [post]
func (h *EvaluationHandler) SubmitEvaluation(c *gin.Context) {
    // Obtener usuario del contexto
    userID, exists := c.Get("userID")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "user not authenticated"})
        return
    }
    
    studentID := userID.(uint)
    
    // Obtener IDs
    sessionID, err := strconv.ParseUint(c.Param("session_id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid session ID"})
        return
    }
    
    // Parsear body (opcional)
    var req dto.SubmitEvaluationRequest
    _ = c.ShouldBindJSON(&req) // Ignorar error, body es opcional
    
    // Enviar evaluación
    response, err := h.service.SubmitEvaluation(c.Request.Context(), uint(sessionID), studentID, req)
    if err != nil {
        if err.Error() == "session already submitted or expired" {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        } else {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to submit evaluation"})
        }
        return
    }
    
    c.JSON(http.StatusOK, response)
}

// GetResults godoc
// @Summary Obtiene resultados de evaluación
// @Description Obtiene los resultados de una evaluación completada
// @Tags evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de la evaluación"
// @Param session_id path int true "ID de la sesión"
// @Param include_details query bool false "Incluir detalles de respuestas"
// @Success 200 {object} dto.ResultResponse "Resultados"
// @Failure 400 {object} map[string]string "Bad request"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Failure 404 {object} map[string]string "Not found"
// @Router /evaluations/{id}/sessions/{session_id}/results [get]
func (h *EvaluationHandler) GetResults(c *gin.Context) {
    // Obtener usuario del contexto
    userID, exists := c.Get("userID")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "user not authenticated"})
        return
    }
    
    studentID := userID.(uint)
    
    // Obtener IDs
    sessionID, err := strconv.ParseUint(c.Param("session_id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid session ID"})
        return
    }
    
    // Obtener query params
    includeDetails := c.DefaultQuery("include_details", "false") == "true"
    
    // Obtener resultados
    results, err := h.service.GetResults(c.Request.Context(), uint(sessionID), studentID, includeDetails)
    if err != nil {
        if err.Error() == "results not available yet" {
            c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
        } else {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get results"})
        }
        return
    }
    
    c.JSON(http.StatusOK, results)
}

// GetHistory godoc
// @Summary Obtiene historial de evaluaciones
// @Description Obtiene el historial de evaluaciones del estudiante
// @Tags evaluations
// @Accept json
// @Produce json
// @Success 200 {object} dto.HistoryResponse "Historial"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Router /evaluations/history [get]
func (h *EvaluationHandler) GetHistory(c *gin.Context) {
    // Obtener usuario del contexto
    userID, exists := c.Get("userID")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "user not authenticated"})
        return
    }
    
    studentID := userID.(uint)
    
    // Obtener historial
    history, err := h.service.GetHistory(c.Request.Context(), studentID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get history"})
        return
    }
    
    c.JSON(http.StatusOK, history)
}
```

#### Criterios de Aceptación:
- [ ] Todos los endpoints implementados
- [ ] Documentación Swagger completa
- [ ] Validación de autenticación
- [ ] Manejo de errores HTTP apropiado
- [ ] Respuestas consistentes

---

### TASK-006: Configurar rutas y middleware
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 1h  

#### Implementación:

```go
// internal/routes/evaluation_routes.go
package routes

import (
    "github.com/gin-gonic/gin"
    "github.com/EduGoGroup/edugo-api-mobile/internal/evaluation/handlers"
    "github.com/EduGoGroup/edugo-api-mobile/internal/evaluation/services"
    "github.com/EduGoGroup/edugo-api-mobile/internal/evaluation/repositories"
    "github.com/EduGoGroup/edugo-api-mobile/internal/middleware"
    "github.com/EduGoGroup/edugo-shared/pkg/messaging"
)

// SetupEvaluationRoutes configura las rutas de evaluaciones
func SetupEvaluationRoutes(router *gin.RouterGroup, publisher messaging.Publisher) {
    // Crear instancias
    repo := repositories.NewEvaluationRepository()
    service := services.NewEvaluationService(repo, publisher)
    handler := handlers.NewEvaluationHandler(service)
    
    // Grupo de rutas con autenticación
    evaluations := router.Group("/evaluations")
    evaluations.Use(middleware.AuthMiddleware())
    evaluations.Use(middleware.StudentOnly()) // Solo estudiantes pueden acceder
    {
        // Endpoints principales
        evaluations.GET("", handler.ListEvaluations)
        evaluations.GET("/:id", handler.GetEvaluation)
        evaluations.POST("/:id/start", handler.StartEvaluation)
        evaluations.GET("/history", handler.GetHistory)
        
        // Endpoints de sesión
        sessions := evaluations.Group("/:id/sessions/:session_id")
        {
            sessions.POST("/answer", handler.SubmitAnswer)
            sessions.POST("/submit", handler.SubmitEvaluation)
            sessions.GET("/results", handler.GetResults)
        }
    }
}
```

Actualizar el archivo principal de rutas:

```go
// internal/routes/routes.go (actualizar método existente)
func SetupRoutes(engine *gin.Engine) {
    // ... código existente ...
    
    v1 := engine.Group("/api/v1")
    {
        // ... otras rutas ...
        
        // Agregar rutas de evaluaciones
        publisher := messaging.GetPublisher() // Obtener instancia del publisher
        SetupEvaluationRoutes(v1, publisher)
    }
}
```

Crear middleware para validar rol de estudiante:

```go
// internal/middleware/role_middleware.go
package middleware

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

// StudentOnly permite acceso solo a estudiantes
func StudentOnly() gin.HandlerFunc {
    return func(c *gin.Context) {
        role, exists := c.Get("userRole")
        if !exists {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "role not found"})
            c.Abort()
            return
        }
        
        if role != "student" {
            c.JSON(http.StatusForbidden, gin.H{"error": "students only"})
            c.Abort()
            return
        }
        
        c.Next()
    }
}

// TeacherOrAdmin permite acceso a profesores y administradores
func TeacherOrAdmin() gin.HandlerFunc {
    return func(c *gin.Context) {
        role, exists := c.Get("userRole")
        if !exists {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "role not found"})
            c.Abort()
            return
        }
        
        if role != "teacher" && role != "admin" && role != "super_admin" {
            c.JSON(http.StatusForbidden, gin.H{"error": "insufficient permissions"})
            c.Abort()
            return
        }
        
        c.Next()
    }
}
```

#### Criterios de Aceptación:
- [ ] Rutas configuradas correctamente
- [ ] Middleware de autenticación aplicado
- [ ] Middleware de rol aplicado
- [ ] Integración con sistema existente

---

### TASK-007: Implementar tests de integración
**Tipo**: test  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:

```go
// internal/evaluation/handlers/tests/evaluation_handler_test.go
package tests

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
    
    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "github.com/EduGoGroup/edugo-api-mobile/internal/evaluation/dto"
    "github.com/EduGoGroup/edugo-api-mobile/internal/evaluation/handlers"
)

// MockEvaluationService para tests
type MockEvaluationService struct {
    mock.Mock
}

func (m *MockEvaluationService) GetAvailableEvaluations(ctx context.Context, studentID uint, req dto.ListEvaluationsRequest) ([]dto.EvaluationListResponse, int64, error) {
    args := m.Called(ctx, studentID, req)
    return args.Get(0).([]dto.EvaluationListResponse), args.Get(1).(int64), args.Error(2)
}

// Implementar todos los demás métodos del mock...

func TestListEvaluations(t *testing.T) {
    // Setup
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockEvaluationService)
    handler := handlers.NewEvaluationHandler(mockService)
    
    // Configurar ruta con contexto de usuario simulado
    router.GET("/evaluations", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "student")
        handler.ListEvaluations(c)
    })
    
    // Mock response
    expectedEvaluations := []dto.EvaluationListResponse{
        {
            ID:              1,
            Title:           "Math Quiz",
            DurationMinutes: 60,
            QuestionCount:   10,
            MaxAttempts:     2,
            AttemptsUsed:    0,
            Status:          "published",
        },
    }
    
    req := dto.ListEvaluationsRequest{
        Page:     1,
        PageSize: 20,
    }
    
    mockService.On("GetAvailableEvaluations", mock.Anything, uint(1), mock.MatchedBy(func(r dto.ListEvaluationsRequest) bool {
        return r.Page == req.Page && r.PageSize == req.PageSize
    })).Return(expectedEvaluations, int64(1), nil)
    
    // Execute
    w := httptest.NewRecorder()
    request, _ := http.NewRequest("GET", "/evaluations?page=1&page_size=20", nil)
    router.ServeHTTP(w, request)
    
    // Assert
    assert.Equal(t, http.StatusOK, w.Code)
    
    var response map[string]interface{}
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    
    assert.Contains(t, response, "data")
    assert.Contains(t, response, "meta")
    
    mockService.AssertExpectations(t)
}

func TestStartEvaluation_Success(t *testing.T) {
    // Setup
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockEvaluationService)
    handler := handlers.NewEvaluationHandler(mockService)
    
    router.POST("/evaluations/:id/start", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "student")
        handler.StartEvaluation(c)
    })
    
    // Mock response
    expectedSession := &dto.SessionStartResponse{
        SessionID:     1,
        EvaluationID:  1,
        AttemptNumber: 1,
        MaxAttempts:   2,
    }
    
    mockService.On("StartEvaluation", mock.Anything, uint(1), uint(1), mock.Anything, mock.Anything).
        Return(expectedSession, nil)
    
    // Execute
    w := httptest.NewRecorder()
    request, _ := http.NewRequest("POST", "/evaluations/1/start", nil)
    router.ServeHTTP(w, request)
    
    // Assert
    assert.Equal(t, http.StatusOK, w.Code)
    
    var response dto.SessionStartResponse
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.Equal(t, uint(1), response.SessionID)
    assert.Equal(t, 1, response.AttemptNumber)
    
    mockService.AssertExpectations(t)
}

func TestSubmitAnswer(t *testing.T) {
    // Setup
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockEvaluationService)
    handler := handlers.NewEvaluationHandler(mockService)
    
    router.POST("/evaluations/:id/sessions/:session_id/answer", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "student")
        handler.SubmitAnswer(c)
    })
    
    // Request body
    reqBody := dto.SubmitAnswerRequest{
        QuestionID:       1,
        SelectedOptionID: &[]uint{2}[0],
    }
    
    // Mock response
    expectedResponse := &dto.AnswerSavedResponse{
        QuestionID: 1,
        Saved:      true,
    }
    
    mockService.On("SaveAnswer", mock.Anything, uint(1), uint(1), mock.MatchedBy(func(r dto.SubmitAnswerRequest) bool {
        return r.QuestionID == reqBody.QuestionID
    })).Return(expectedResponse, nil)
    
    // Execute
    body, _ := json.Marshal(reqBody)
    w := httptest.NewRecorder()
    request, _ := http.NewRequest("POST", "/evaluations/1/sessions/1/answer", bytes.NewBuffer(body))
    request.Header.Set("Content-Type", "application/json")
    router.ServeHTTP(w, request)
    
    // Assert
    assert.Equal(t, http.StatusOK, w.Code)
    
    var response dto.AnswerSavedResponse
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.True(t, response.Saved)
    
    mockService.AssertExpectations(t)
}

func TestSubmitEvaluation(t *testing.T) {
    // Similar test structure...
}

func TestGetResults_NotReady(t *testing.T) {
    // Setup
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockEvaluationService)
    handler := handlers.NewEvaluationHandler(mockService)
    
    router.GET("/evaluations/:id/sessions/:session_id/results", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "student")
        handler.GetResults(c)
    })
    
    // Mock error
    mockService.On("GetResults", mock.Anything, uint(1), uint(1), false).
        Return(nil, errors.New("results not available yet"))
    
    // Execute
    w := httptest.NewRecorder()
    request, _ := http.NewRequest("GET", "/evaluations/1/sessions/1/results", nil)
    router.ServeHTTP(w, request)
    
    // Assert
    assert.Equal(t, http.StatusNotFound, w.Code)
    
    var response map[string]string
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.Contains(t, response["error"], "not available")
    
    mockService.AssertExpectations(t)
}

// Benchmark test
func BenchmarkListEvaluations(b *testing.B) {
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockEvaluationService)
    handler := handlers.NewEvaluationHandler(mockService)
    
    router.GET("/evaluations", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "student")
        handler.ListEvaluations(c)
    })
    
    mockService.On("GetAvailableEvaluations", mock.Anything, mock.Anything, mock.Anything).
        Return([]dto.EvaluationListResponse{}, int64(0), nil)
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        w := httptest.NewRecorder()
        request, _ := http.NewRequest("GET", "/evaluations", nil)
        router.ServeHTTP(w, request)
    }
}
```

#### Criterios de Aceptación:
- [ ] Tests para todos los endpoints
- [ ] Casos de éxito y error
- [ ] Mocks implementados
- [ ] Coverage >80%
- [ ] Tests de benchmark

#### Validación:
```bash
go test ./internal/evaluation/... -v -cover
# Coverage debe ser >80%
```

---

### TASK-008: Actualizar documentación Swagger
**Tipo**: docs  
**Prioridad**: MEDIUM  
**Estimación**: 1h  

#### Implementación:

Actualizar el archivo principal de Swagger:

```go
// docs/swagger.go (o main.go con anotaciones)

// @title EduGo API Mobile
// @version 1.0
// @description API para la aplicación móvil de EduGo

// @contact.name API Support
// @contact.email support@edugo.com

// @host localhost:8080
// @BasePath /api/v1

// @securityDefinitions.apikey Bearer
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.
```

Regenerar documentación:
```bash
# Instalar swag si no está instalado
go get -u github.com/swaggo/swag/cmd/swag

# Generar documentación
swag init -g cmd/main.go

# Verificar que se generó
ls -la docs/
# Debe mostrar: docs.go, swagger.json, swagger.yaml
```

#### Criterios de Aceptación:
- [ ] Todos los endpoints documentados
- [ ] Ejemplos de request/response
- [ ] Códigos de error documentados
- [ ] Swagger UI accesible en /swagger/index.html

---

### TASK-009: Integración con eventos RabbitMQ
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 2h  

#### Implementación:

```go
// internal/messaging/evaluation_events.go
package messaging

import (
    "context"
    "encoding/json"
    
    "github.com/EduGoGroup/edugo-shared/pkg/messaging"
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
)

// EvaluationEventPublisher publica eventos de evaluaciones
type EvaluationEventPublisher struct {
    publisher messaging.Publisher
}

// NewEvaluationEventPublisher crea una nueva instancia
func NewEvaluationEventPublisher(publisher messaging.Publisher) *EvaluationEventPublisher {
    return &EvaluationEventPublisher{
        publisher: publisher,
    }
}

// PublishEvaluationStarted publica evento de inicio de evaluación
func (p *EvaluationEventPublisher) PublishEvaluationStarted(ctx context.Context, event map[string]interface{}) error {
    return p.publisher.Publish(ctx, evaluation.EventEvaluationStarted, event)
}

// PublishEvaluationSubmitted publica evento de envío de evaluación
func (p *EvaluationEventPublisher) PublishEvaluationSubmitted(ctx context.Context, event map[string]interface{}) error {
    return p.publisher.Publish(ctx, evaluation.EventEvaluationSubmitted, event)
}

// PublishAnswerSaved publica evento de respuesta guardada (opcional)
func (p *EvaluationEventPublisher) PublishAnswerSaved(ctx context.Context, event map[string]interface{}) error {
    return p.publisher.Publish(ctx, "evaluation.answer.saved", event)
}
```

Configurar el publisher en el servicio:
```go
// cmd/main.go o internal/config/dependencies.go

import (
    "github.com/EduGoGroup/edugo-shared/pkg/messaging"
)

func setupMessaging() messaging.Publisher {
    config := messaging.Config{
        URL:      os.Getenv("RABBITMQ_URL"),
        Exchange: "edugo.topic",
    }
    
    publisher, err := messaging.NewPublisher(config)
    if err != nil {
        log.Fatal("Failed to connect to RabbitMQ:", err)
    }
    
    return publisher
}
```

#### Criterios de Aceptación:
- [ ] Publisher configurado
- [ ] Eventos publicados correctamente
- [ ] Formato de eventos consistente
- [ ] Manejo de errores de conexión

---

### TASK-010: Deployment y validación final
**Tipo**: deployment  
**Prioridad**: HIGH  
**Estimación**: 1h  

#### Pasos de Implementación:
```bash
# 1. Ejecutar todos los tests
go test ./internal/evaluation/... -v -cover

# 2. Verificar que compila
go build ./...

# 3. Ejecutar linting
golangci-lint run ./internal/evaluation/...

# 4. Actualizar documentación Swagger
swag init -g cmd/main.go

# 5. Probar localmente con docker
docker build -t edugo-api-mobile:evaluation .
docker run -p 8080:8080 edugo-api-mobile:evaluation

# 6. Verificar endpoints con curl
# Listar evaluaciones
curl http://localhost:8080/api/v1/evaluations \
  -H "Authorization: Bearer $TOKEN"

# 7. Crear PR
git add .
git commit -m "feat: implement evaluation endpoints

- Complete evaluation system for students
- 8 REST endpoints for evaluation flow
- Integration with shared v1.3.0
- RabbitMQ event publishing
- Tests with >80% coverage

Depends on: edugo-shared v1.3.0
Closes #XXX"

git push origin feature/evaluation-endpoints

# 8. Crear PR en GitHub
gh pr create \
  --title "feat: evaluation system for mobile API" \
  --body "Implementation of complete evaluation system for students" \
  --base main
```

#### Criterios de Aceptación:
- [ ] Todos los tests pasando
- [ ] Sin errores de linting
- [ ] Documentación actualizada
- [ ] PR creado y listo para review
- [ ] Sin breaking changes en endpoints existentes

---

## 📊 Resumen de Tareas

| Task | Descripción | Tiempo | Estado |
|------|-------------|--------|--------|
| 001 | Actualizar dependencias | 1h | ⬜ |
| 002 | Implementar DTOs | 2h | ⬜ |
| 003 | Implementar repositorio | 2h | ⬜ |
| 004 | Implementar servicio | 3h | ⬜ |
| 005 | Implementar handlers | 3h | ⬜ |
| 006 | Configurar rutas | 1h | ⬜ |
| 007 | Tests de integración | 3h | ⬜ |
| 008 | Documentación Swagger | 1h | ⬜ |
| 009 | Integración RabbitMQ | 2h | ⬜ |
| 010 | Deployment | 1h | ⬜ |

**Total estimado**: 19 horas (2.5 días laborables)

## ✅ Checklist Final

Antes de marcar como completo:
- [ ] Dependencia shared v1.3.0 integrada
- [ ] 8 endpoints funcionando correctamente
- [ ] Tests con cobertura >80%
- [ ] Eventos publicados a RabbitMQ
- [ ] Documentación Swagger actualizada
- [ ] Sin errores de linting
- [ ] Compatible con autenticación existente
- [ ] PR aprobado y mergeado

## 🚀 Siguiente Paso

Una vez completadas todas las tareas:
1. Notificar a equipo de api-administracion
2. Actualizar tracking en TRACKING_SYSTEM.json
3. Proceder con implementación en api-administracion
4. Preparar para integración con worker

## ⚠️ Dependencias Críticas

**IMPORTANTE**: Este proyecto DEPENDE de que edugo-shared v1.3.0 esté publicado. Si no está disponible:
1. DETENER trabajo en este proyecto
2. Esperar a que shared complete sus tareas
3. Verificar con: `go list -m github.com/EduGoGroup/edugo-shared@v1.3.0`

---

**Documento generado para**: Ejecución desatendida por IA  
**Puede ser ejecutado por**: Claude, GPT-4, GitHub Copilot, etc.  
**Requisito**: edugo-shared v1.3.0 DEBE estar publicado primero