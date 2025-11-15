# 📋 Plan de Tareas - Sistema de Evaluaciones en edugo-shared

**Repositorio:** edugo-shared  
**Duración Estimada:** 3 días  
**Branch:** `feature/evaluaciones-shared-tipos`  
**Resultado:** Release v0.7.0

---

## ⚠️ PREREQUISITOS

Antes de iniciar, verificar:

```bash
# 1. Repo actualizado
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared
git checkout dev
git pull origin dev

# 2. Tests pasando actualmente
make test

# 3. Verificar versión actual
git describe --tags --abbrev=0
# Debería mostrar v0.6.2 o superior
```

---

## 📅 DÍA 1: ESTRUCTURA Y TIPOS BASE

### TASK-001: Crear estructura del módulo assessment
**Tipo:** feature  
**Estimación:** 30min  
**Archivos:** Nueva estructura de carpetas

**Pasos:**
```bash
# Crear estructura de carpetas
mkdir -p assessment/{domain,repository,dto}
touch assessment/doc.go
```

**Contenido de `assessment/doc.go`:**
```go
// Package assessment provides shared types and interfaces for educational assessments.
// This includes domain entities, value objects, DTOs, and repository interfaces
// that are used across multiple services in the EduGo ecosystem.
package assessment
```

---

### TASK-002: Implementar tipos básicos y value objects
**Tipo:** feature  
**Estimación:** 2h  
**Archivo:** `assessment/domain/types.go`

**Implementación:**
```go
package domain

import (
    "errors"
    "github.com/google/uuid"
)

// AssessmentID represents a unique identifier for an assessment
type AssessmentID struct {
    value uuid.UUID
}

// NewAssessmentID creates a new AssessmentID
func NewAssessmentID() AssessmentID {
    return AssessmentID{value: uuid.New()}
}

// ParseAssessmentID creates an AssessmentID from string
func ParseAssessmentID(s string) (AssessmentID, error) {
    id, err := uuid.Parse(s)
    if err != nil {
        return AssessmentID{}, errors.New("invalid assessment ID")
    }
    return AssessmentID{value: id}, nil
}

// String returns string representation
func (id AssessmentID) String() string {
    return id.value.String()
}

// AttemptID represents a unique identifier for an assessment attempt
type AttemptID struct {
    value uuid.UUID
}

// QuestionID represents a unique identifier for a question
type QuestionID string

// Validate ensures QuestionID is not empty
func (q QuestionID) Validate() error {
    if q == "" {
        return errors.New("question ID cannot be empty")
    }
    return nil
}

// Score represents an assessment score (0-100)
type Score struct {
    value int
}

// NewScore creates a new Score with validation
func NewScore(value int) (Score, error) {
    if value < 0 || value > 100 {
        return Score{}, errors.New("score must be between 0 and 100")
    }
    return Score{value: value}, nil
}

// Value returns the score value
func (s Score) Value() int {
    return s.value
}

// IsPassing checks if score meets passing threshold
func (s Score) IsPassing(threshold int) bool {
    return s.value >= threshold
}

// Difficulty represents assessment difficulty level
type Difficulty string

const (
    DifficultyEasy   Difficulty = "easy"
    DifficultyMedium Difficulty = "medium"
    DifficultyHard   Difficulty = "hard"
)

// Validate ensures difficulty is valid
func (d Difficulty) Validate() error {
    switch d {
    case DifficultyEasy, DifficultyMedium, DifficultyHard:
        return nil
    default:
        return errors.New("invalid difficulty level")
    }
}

// AttemptStatus represents the status of an assessment attempt
type AttemptStatus string

const (
    AttemptStatusInProgress AttemptStatus = "in_progress"
    AttemptStatusCompleted  AttemptStatus = "completed"
    AttemptStatusAbandoned  AttemptStatus = "abandoned"
    AttemptStatusTimeout    AttemptStatus = "timeout"
)

// QuestionType represents the type of assessment question
type QuestionType string

const (
    QuestionTypeMultipleChoice QuestionType = "multiple_choice"
    QuestionTypeTrueFalse      QuestionType = "true_false"
    QuestionTypeShortAnswer    QuestionType = "short_answer"
)
```

---

### TASK-003: Implementar entity Assessment
**Tipo:** feature  
**Estimación:** 1.5h  
**Archivo:** `assessment/domain/assessment.go`

**Implementación:**
```go
package domain

import (
    "errors"
    "time"
)

// Assessment represents an educational evaluation
type Assessment struct {
    ID                AssessmentID
    MaterialID        string
    MongoAssessmentID string
    Difficulty        Difficulty
    QuestionCount     int
    PassingScore      int
    MaxAttemptsPerDay int
    TimeLimitMinutes  int
    IsActive          bool
    CreatedAt         time.Time
    UpdatedAt         time.Time
}

// NewAssessment creates a new Assessment with validation
func NewAssessment(
    materialID string,
    mongoID string,
    difficulty Difficulty,
    questionCount int,
) (*Assessment, error) {
    if materialID == "" {
        return nil, errors.New("material ID is required")
    }
    if mongoID == "" {
        return nil, errors.New("mongo assessment ID is required")
    }
    if err := difficulty.Validate(); err != nil {
        return nil, err
    }
    if questionCount <= 0 {
        return nil, errors.New("question count must be positive")
    }

    now := time.Now()
    return &Assessment{
        ID:                NewAssessmentID(),
        MaterialID:        materialID,
        MongoAssessmentID: mongoID,
        Difficulty:        difficulty,
        QuestionCount:     questionCount,
        PassingScore:      70, // default
        MaxAttemptsPerDay: 3,  // default
        TimeLimitMinutes:  30, // default
        IsActive:          true,
        CreatedAt:         now,
        UpdatedAt:         now,
    }, nil
}

// CanUserAttempt checks if user can take the assessment
func (a *Assessment) CanUserAttempt(todayAttempts int) error {
    if !a.IsActive {
        return errors.New("assessment is not active")
    }
    if todayAttempts >= a.MaxAttemptsPerDay {
        return errors.New("daily attempt limit exceeded")
    }
    return nil
}

// UpdateSettings updates assessment configuration
func (a *Assessment) UpdateSettings(passingScore, maxAttempts, timeLimit int) error {
    if passingScore < 0 || passingScore > 100 {
        return errors.New("passing score must be between 0 and 100")
    }
    if maxAttempts <= 0 {
        return errors.New("max attempts must be positive")
    }
    if timeLimit <= 0 {
        return errors.New("time limit must be positive")
    }

    a.PassingScore = passingScore
    a.MaxAttemptsPerDay = maxAttempts
    a.TimeLimitMinutes = timeLimit
    a.UpdatedAt = time.Now()
    return nil
}

// Deactivate marks the assessment as inactive
func (a *Assessment) Deactivate() {
    a.IsActive = false
    a.UpdatedAt = time.Now()
}
```

---

### TASK-004: Implementar entity Attempt
**Tipo:** feature  
**Estimación:** 1.5h  
**Archivo:** `assessment/domain/attempt.go`

**Implementación:**
```go
package domain

import (
    "errors"
    "time"
)

// Attempt represents a user's attempt at an assessment
type Attempt struct {
    ID              AttemptID
    AssessmentID    AssessmentID
    UserID          string
    StartedAt       time.Time
    CompletedAt     *time.Time
    LastActivityAt  time.Time
    Score           *Score
    TotalQuestions  int
    CorrectAnswers  int
    Status          AttemptStatus
    TimeSpentSeconds int
    Answers         []Answer
}

// Answer represents a user's answer to a question
type Answer struct {
    QuestionID       QuestionID
    AnswerValue      string
    IsCorrect        *bool
    TimeSpentSeconds int
    CreatedAt        time.Time
}

// NewAttempt creates a new assessment attempt
func NewAttempt(assessmentID AssessmentID, userID string, totalQuestions int) (*Attempt, error) {
    if userID == "" {
        return nil, errors.New("user ID is required")
    }
    if totalQuestions <= 0 {
        return nil, errors.New("total questions must be positive")
    }

    now := time.Now()
    return &Attempt{
        ID:             AttemptID{value: uuid.New()},
        AssessmentID:   assessmentID,
        UserID:         userID,
        StartedAt:      now,
        LastActivityAt: now,
        TotalQuestions: totalQuestions,
        Status:         AttemptStatusInProgress,
        Answers:        make([]Answer, 0),
    }, nil
}

// AddAnswer adds or updates an answer
func (a *Attempt) AddAnswer(questionID QuestionID, answerValue string, timeSpent int) error {
    if a.Status != AttemptStatusInProgress {
        return errors.New("cannot add answers to completed attempt")
    }
    
    if err := questionID.Validate(); err != nil {
        return err
    }

    // Check if answer already exists
    for i, ans := range a.Answers {
        if ans.QuestionID == questionID {
            a.Answers[i].AnswerValue = answerValue
            a.Answers[i].TimeSpentSeconds = timeSpent
            a.Answers[i].CreatedAt = time.Now()
            a.LastActivityAt = time.Now()
            return nil
        }
    }

    // Add new answer
    a.Answers = append(a.Answers, Answer{
        QuestionID:       questionID,
        AnswerValue:      answerValue,
        TimeSpentSeconds: timeSpent,
        CreatedAt:        time.Now(),
    })
    a.LastActivityAt = time.Now()
    return nil
}

// Complete marks the attempt as completed and calculates score
func (a *Attempt) Complete(correctAnswers map[QuestionID]string) error {
    if a.Status != AttemptStatusInProgress {
        return errors.New("attempt is not in progress")
    }

    correctCount := 0
    totalTime := 0

    // Calculate correct answers
    for i := range a.Answers {
        answer := &a.Answers[i]
        if correct, ok := correctAnswers[answer.QuestionID]; ok {
            isCorrect := answer.AnswerValue == correct
            answer.IsCorrect = &isCorrect
            if isCorrect {
                correctCount++
            }
        }
        totalTime += answer.TimeSpentSeconds
    }

    // Calculate score
    scoreValue := (correctCount * 100) / a.TotalQuestions
    score, err := NewScore(scoreValue)
    if err != nil {
        return err
    }

    now := time.Now()
    a.Score = &score
    a.CorrectAnswers = correctCount
    a.CompletedAt = &now
    a.Status = AttemptStatusCompleted
    a.TimeSpentSeconds = totalTime
    a.LastActivityAt = now

    return nil
}

// Abandon marks the attempt as abandoned
func (a *Attempt) Abandon() error {
    if a.Status != AttemptStatusInProgress {
        return errors.New("can only abandon in-progress attempts")
    }
    
    now := time.Now()
    a.Status = AttemptStatusAbandoned
    a.CompletedAt = &now
    a.LastActivityAt = now
    return nil
}

// CheckTimeout checks if attempt has timed out
func (a *Attempt) CheckTimeout(timeLimitMinutes int) bool {
    if a.Status != AttemptStatusInProgress {
        return false
    }
    
    deadline := a.StartedAt.Add(time.Duration(timeLimitMinutes) * time.Minute)
    if time.Now().After(deadline) {
        a.Status = AttemptStatusTimeout
        now := time.Now()
        a.CompletedAt = &now
        return true
    }
    return false
}
```

---

## 📅 DÍA 2: REPOSITORY INTERFACES Y DTOs

### TASK-005: Crear interfaces de repository
**Tipo:** feature  
**Estimación:** 1h  
**Archivo:** `assessment/repository/interfaces.go`

**Implementación:**
```go
package repository

import (
    "context"
    "time"
    
    "github.com/EduGoGroup/edugo-shared/assessment/domain"
)

// AssessmentRepository defines the interface for assessment persistence
type AssessmentRepository interface {
    // Create creates a new assessment
    Create(ctx context.Context, assessment *domain.Assessment) error
    
    // GetByID retrieves an assessment by ID
    GetByID(ctx context.Context, id domain.AssessmentID) (*domain.Assessment, error)
    
    // GetByMaterialID retrieves an assessment by material ID
    GetByMaterialID(ctx context.Context, materialID string) (*domain.Assessment, error)
    
    // Update updates an existing assessment
    Update(ctx context.Context, assessment *domain.Assessment) error
    
    // Delete soft deletes an assessment
    Delete(ctx context.Context, id domain.AssessmentID) error
    
    // ListActive lists all active assessments with pagination
    ListActive(ctx context.Context, offset, limit int) ([]*domain.Assessment, error)
}

// AttemptRepository defines the interface for attempt persistence
type AttemptRepository interface {
    // Create creates a new attempt
    Create(ctx context.Context, attempt *domain.Attempt) error
    
    // GetByID retrieves an attempt by ID
    GetByID(ctx context.Context, id domain.AttemptID) (*domain.Attempt, error)
    
    // GetActiveByUser gets active attempt for a user
    GetActiveByUser(ctx context.Context, userID string) (*domain.Attempt, error)
    
    // Update updates an existing attempt
    Update(ctx context.Context, attempt *domain.Attempt) error
    
    // CountTodayAttempts counts attempts made today by user for assessment
    CountTodayAttempts(ctx context.Context, userID string, assessmentID domain.AssessmentID) (int, error)
    
    // ListByUser lists attempts by user with pagination
    ListByUser(ctx context.Context, userID string, offset, limit int) ([]*domain.Attempt, error)
    
    // GetStatsByAssessment gets statistics for an assessment
    GetStatsByAssessment(ctx context.Context, assessmentID domain.AssessmentID) (*AssessmentStats, error)
}

// AssessmentStats represents aggregated statistics
type AssessmentStats struct {
    TotalAttempts   int
    UniqueUsers     int
    AverageScore    float64
    MedianScore     float64
    PassRate        float64
    AverageTimeMin  float64
    LastAttemptDate time.Time
}

// QuizRepository defines interface for MongoDB quiz access
type QuizRepository interface {
    // GetQuiz retrieves quiz content from MongoDB
    GetQuiz(ctx context.Context, mongoAssessmentID string) (*Quiz, error)
    
    // GetCorrectAnswers retrieves only correct answers for grading
    GetCorrectAnswers(ctx context.Context, mongoAssessmentID string) (map[domain.QuestionID]string, error)
}

// Quiz represents quiz content from MongoDB
type Quiz struct {
    ID        string
    Questions []Question
    Metadata  QuizMetadata
}

// Question represents a quiz question
type Question struct {
    ID      domain.QuestionID
    Type    domain.QuestionType
    Text    string
    Options []Option
    Points  int
}

// Option represents a question option
type Option struct {
    ID   string
    Text string
}

// QuizMetadata contains quiz metadata
type QuizMetadata struct {
    Difficulty      domain.Difficulty
    Topics          []string
    EstimatedMinutes int
    Instructions    string
}
```

---

### TASK-006: Implementar DTOs de request
**Tipo:** feature  
**Estimación:** 1.5h  
**Archivo:** `assessment/dto/request.go`

**Implementación:**
```go
package dto

import (
    "errors"
    "github.com/EduGoGroup/edugo-shared/assessment/domain"
)

// CreateAssessmentRequest represents request to create assessment
type CreateAssessmentRequest struct {
    MaterialID        string `json:"material_id" binding:"required,uuid"`
    MongoAssessmentID string `json:"mongo_assessment_id" binding:"required"`
    Difficulty        string `json:"difficulty" binding:"required,oneof=easy medium hard"`
    QuestionCount     int    `json:"question_count" binding:"required,min=1"`
    PassingScore      int    `json:"passing_score" binding:"min=0,max=100"`
    MaxAttemptsPerDay int    `json:"max_attempts_per_day" binding:"min=1"`
    TimeLimitMinutes  int    `json:"time_limit_minutes" binding:"min=1"`
}

// Validate validates the request
func (r CreateAssessmentRequest) Validate() error {
    if r.PassingScore == 0 {
        r.PassingScore = 70 // default
    }
    if r.MaxAttemptsPerDay == 0 {
        r.MaxAttemptsPerDay = 3 // default
    }
    if r.TimeLimitMinutes == 0 {
        r.TimeLimitMinutes = 30 // default
    }
    return nil
}

// ToDomain converts to domain entity
func (r CreateAssessmentRequest) ToDomain() (*domain.Assessment, error) {
    return domain.NewAssessment(
        r.MaterialID,
        r.MongoAssessmentID,
        domain.Difficulty(r.Difficulty),
        r.QuestionCount,
    )
}

// StartAttemptRequest represents request to start an attempt
type StartAttemptRequest struct {
    AssessmentID string                 `json:"assessment_id" binding:"required,uuid"`
    Metadata     map[string]interface{} `json:"metadata"`
}

// SubmitAnswersRequest represents request to submit answers
type SubmitAnswersRequest struct {
    Answers []AnswerDTO `json:"answers" binding:"required,min=1,dive"`
    Action  string      `json:"action" binding:"required,oneof=save submit"`
}

// AnswerDTO represents an answer in request
type AnswerDTO struct {
    QuestionID       string `json:"question_id" binding:"required"`
    AnswerValue      string `json:"answer_value" binding:"required"`
    TimeSpentSeconds int    `json:"time_spent_seconds" binding:"min=0"`
}

// Validate validates answer DTO
func (a AnswerDTO) Validate() error {
    if a.QuestionID == "" {
        return errors.New("question ID is required")
    }
    if a.AnswerValue == "" {
        return errors.New("answer value is required")
    }
    return nil
}

// GetAttemptsQuery represents query parameters for listing attempts
type GetAttemptsQuery struct {
    Page       int    `form:"page,default=1" binding:"min=1"`
    Limit      int    `form:"limit,default=20" binding:"min=1,max=100"`
    Status     string `form:"status" binding:"omitempty,oneof=in_progress completed abandoned all"`
    From       string `form:"from" binding:"omitempty,datetime=2006-01-02"`
    To         string `form:"to" binding:"omitempty,datetime=2006-01-02"`
    MaterialID string `form:"material_id" binding:"omitempty,uuid"`
    Passed     *bool  `form:"passed" binding:"omitempty"`
}

// GetOffset calculates offset for pagination
func (q GetAttemptsQuery) GetOffset() int {
    return (q.Page - 1) * q.Limit
}
```

---

### TASK-007: Implementar DTOs de response
**Tipo:** feature  
**Estimación:** 1.5h  
**Archivo:** `assessment/dto/response.go`

**Implementación:**
```go
package dto

import (
    "time"
    "github.com/EduGoGroup/edugo-shared/assessment/domain"
)

// AssessmentResponse represents assessment in API responses
type AssessmentResponse struct {
    ID                string    `json:"assessment_id"`
    MaterialID        string    `json:"material_id"`
    Title             string    `json:"title,omitempty"`
    Description       string    `json:"description,omitempty"`
    Difficulty        string    `json:"difficulty"`
    QuestionCount     int       `json:"question_count"`
    PassingScore      int       `json:"passing_score"`
    TimeLimitMinutes  int       `json:"time_limit_minutes"`
    MaxAttemptsPerDay int       `json:"max_attempts_per_day"`
    AttemptsToday     int       `json:"attempts_today,omitempty"`
    CanTake           bool      `json:"can_take"`
    Questions         []QuestionResponse `json:"questions,omitempty"`
    Metadata          MetadataResponse   `json:"metadata,omitempty"`
    CreatedAt         time.Time `json:"created_at,omitempty"`
}

// QuestionResponse represents a question in responses
type QuestionResponse struct {
    ID      string           `json:"id"`
    Type    string           `json:"type"`
    Text    string           `json:"text"`
    Options []OptionResponse `json:"options,omitempty"`
    Points  int              `json:"points"`
}

// OptionResponse represents question option
type OptionResponse struct {
    ID   string `json:"id"`
    Text string `json:"text"`
}

// MetadataResponse represents assessment metadata
type MetadataResponse struct {
    Topics               []string `json:"topics,omitempty"`
    EstimatedTimeMinutes int      `json:"estimated_time_minutes,omitempty"`
    Instructions         string   `json:"instructions,omitempty"`
}

// AttemptResponse represents attempt in API responses
type AttemptResponse struct {
    AttemptID        string     `json:"attempt_id"`
    AssessmentID     string     `json:"assessment_id"`
    UserID           string     `json:"user_id,omitempty"`
    Status           string     `json:"status"`
    StartedAt        time.Time  `json:"started_at"`
    CompletedAt      *time.Time `json:"completed_at,omitempty"`
    ExpiresAt        time.Time  `json:"expires_at,omitempty"`
    QuestionsOrder   []string   `json:"questions_order,omitempty"`
    TotalQuestions   int        `json:"total_questions"`
    AnsweredCount    int        `json:"answered_count,omitempty"`
    Score            *int       `json:"score,omitempty"`
    Passed           *bool      `json:"passed,omitempty"`
    TimeSpentSeconds int        `json:"time_spent_seconds,omitempty"`
}

// FromDomainAttempt creates response from domain attempt
func FromDomainAttempt(attempt *domain.Attempt, passingScore int) AttemptResponse {
    resp := AttemptResponse{
        AttemptID:        attempt.ID.String(),
        AssessmentID:     attempt.AssessmentID.String(),
        UserID:           attempt.UserID,
        Status:           string(attempt.Status),
        StartedAt:        attempt.StartedAt,
        CompletedAt:      attempt.CompletedAt,
        TotalQuestions:   attempt.TotalQuestions,
        AnsweredCount:    len(attempt.Answers),
        TimeSpentSeconds: attempt.TimeSpentSeconds,
    }

    if attempt.Score != nil {
        score := attempt.Score.Value()
        resp.Score = &score
        passed := attempt.Score.IsPassing(passingScore)
        resp.Passed = &passed
    }

    if attempt.Status == domain.AttemptStatusInProgress {
        // Calculate expiry (30 minutes from start)
        resp.ExpiresAt = attempt.StartedAt.Add(30 * time.Minute)
    }

    return resp
}

// ResultsResponse represents attempt results
type ResultsResponse struct {
    AttemptID       string                 `json:"attempt_id"`
    Assessment      AssessmentSummary      `json:"assessment"`
    Score           int                    `json:"score"`
    Passed          bool                   `json:"passed"`
    PassingScore    int                    `json:"passing_score"`
    CorrectAnswers  int                    `json:"correct_answers"`
    TotalQuestions  int                    `json:"total_questions"`
    StartedAt       time.Time              `json:"started_at"`
    CompletedAt     time.Time              `json:"completed_at"`
    TimeSpent       string                 `json:"time_spent"`
    Percentile      int                    `json:"percentile,omitempty"`
    QuestionResults []QuestionResultResponse `json:"question_results,omitempty"`
    Analysis        *AnalysisResponse      `json:"analysis,omitempty"`
    Feedback        *FeedbackResponse      `json:"feedback,omitempty"`
}

// AssessmentSummary represents assessment summary in results
type AssessmentSummary struct {
    Title      string `json:"title"`
    MaterialID string `json:"material_id"`
}

// QuestionResultResponse represents individual question result
type QuestionResultResponse struct {
    QuestionID      string `json:"question_id"`
    QuestionText    string `json:"question_text,omitempty"`
    IsCorrect       bool   `json:"is_correct"`
    YourAnswer      string `json:"your_answer"`
    CorrectAnswer   string `json:"correct_answer,omitempty"`
    Explanation     string `json:"explanation,omitempty"`
    PointsEarned    int    `json:"points_earned"`
    PointsPossible  int    `json:"points_possible"`
}

// AnalysisResponse represents performance analysis
type AnalysisResponse struct {
    ByTopic      []TopicScore     `json:"by_topic,omitempty"`
    ByDifficulty []DifficultyScore `json:"by_difficulty,omitempty"`
}

// TopicScore represents score by topic
type TopicScore struct {
    Topic string `json:"topic"`
    Score int    `json:"score"`
}

// DifficultyScore represents score by difficulty
type DifficultyScore struct {
    Level string `json:"level"`
    Score int    `json:"score"`
}

// FeedbackResponse represents personalized feedback
type FeedbackResponse struct {
    Summary      string   `json:"summary"`
    Strengths    []string `json:"strengths,omitempty"`
    Improvements []string `json:"improvements,omitempty"`
}

// PaginationResponse represents pagination metadata
type PaginationResponse struct {
    Page       int  `json:"page"`
    Limit      int  `json:"limit"`
    Total      int  `json:"total"`
    TotalPages int  `json:"total_pages"`
    HasNext    bool `json:"has_next"`
    HasPrev    bool `json:"has_prev"`
}
```

---

### TASK-008: Implementar errores específicos del dominio
**Tipo:** feature  
**Estimación:** 1h  
**Archivo:** `assessment/errors.go`

**Implementación:**
```go
package assessment

import "fmt"

// DomainError represents a domain-specific error
type DomainError struct {
    Code    string
    Message string
    Details map[string]interface{}
}

// Error implements error interface
func (e DomainError) Error() string {
    return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

// Common domain errors
var (
    ErrAssessmentNotFound = DomainError{
        Code:    "ASSESSMENT_NOT_FOUND",
        Message: "Assessment not found",
    }
    
    ErrAttemptNotFound = DomainError{
        Code:    "ATTEMPT_NOT_FOUND",
        Message: "Attempt not found",
    }
    
    ErrDailyLimitExceeded = DomainError{
        Code:    "DAILY_LIMIT_EXCEEDED",
        Message: "Daily attempt limit exceeded",
    }
    
    ErrAttemptInProgress = DomainError{
        Code:    "ATTEMPT_IN_PROGRESS",
        Message: "An attempt is already in progress",
    }
    
    ErrAttemptExpired = DomainError{
        Code:    "ATTEMPT_EXPIRED",
        Message: "Attempt has expired",
    }
    
    ErrInvalidScore = DomainError{
        Code:    "INVALID_SCORE",
        Message: "Invalid score value",
    }
    
    ErrInvalidAnswers = DomainError{
        Code:    "INVALID_ANSWERS",
        Message: "Invalid answers provided",
    }
    
    ErrAssessmentInactive = DomainError{
        Code:    "ASSESSMENT_INACTIVE",
        Message: "Assessment is not active",
    }
)

// NewDomainError creates a custom domain error
func NewDomainError(code, message string, details map[string]interface{}) DomainError {
    return DomainError{
        Code:    code,
        Message: message,
        Details: details,
    }
}
```

---

## 📅 DÍA 3: TESTS Y RELEASE

### TASK-009: Crear tests unitarios para domain
**Tipo:** test  
**Estimación:** 2h  
**Archivo:** `assessment/domain/assessment_test.go`, `assessment/domain/attempt_test.go`

**Tests de Assessment:**
```go
package domain_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "github.com/EduGoGroup/edugo-shared/assessment/domain"
)

func TestNewAssessment(t *testing.T) {
    tests := []struct {
        name          string
        materialID    string
        mongoID       string
        difficulty    domain.Difficulty
        questionCount int
        wantErr       bool
        errMsg        string
    }{
        {
            name:          "valid assessment",
            materialID:    "mat-123",
            mongoID:       "mongo-456",
            difficulty:    domain.DifficultyMedium,
            questionCount: 20,
            wantErr:       false,
        },
        {
            name:          "empty material ID",
            materialID:    "",
            mongoID:       "mongo-456",
            difficulty:    domain.DifficultyMedium,
            questionCount: 20,
            wantErr:       true,
            errMsg:        "material ID is required",
        },
        {
            name:          "invalid question count",
            materialID:    "mat-123",
            mongoID:       "mongo-456",
            difficulty:    domain.DifficultyMedium,
            questionCount: 0,
            wantErr:       true,
            errMsg:        "question count must be positive",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            assessment, err := domain.NewAssessment(
                tt.materialID,
                tt.mongoID,
                tt.difficulty,
                tt.questionCount,
            )

            if tt.wantErr {
                assert.Error(t, err)
                assert.Contains(t, err.Error(), tt.errMsg)
                assert.Nil(t, assessment)
            } else {
                require.NoError(t, err)
                require.NotNil(t, assessment)
                assert.Equal(t, tt.materialID, assessment.MaterialID)
                assert.Equal(t, tt.mongoID, assessment.MongoAssessmentID)
                assert.Equal(t, tt.difficulty, assessment.Difficulty)
                assert.Equal(t, tt.questionCount, assessment.QuestionCount)
                assert.Equal(t, 70, assessment.PassingScore)
                assert.Equal(t, 3, assessment.MaxAttemptsPerDay)
                assert.True(t, assessment.IsActive)
            }
        })
    }
}

func TestAssessment_CanUserAttempt(t *testing.T) {
    assessment, _ := domain.NewAssessment(
        "mat-123",
        "mongo-456",
        domain.DifficultyMedium,
        20,
    )

    tests := []struct {
        name          string
        isActive      bool
        todayAttempts int
        maxAttempts   int
        wantErr       bool
    }{
        {
            name:          "can attempt",
            isActive:      true,
            todayAttempts: 1,
            maxAttempts:   3,
            wantErr:       false,
        },
        {
            name:          "limit exceeded",
            isActive:      true,
            todayAttempts: 3,
            maxAttempts:   3,
            wantErr:       true,
        },
        {
            name:          "inactive assessment",
            isActive:      false,
            todayAttempts: 0,
            maxAttempts:   3,
            wantErr:       true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            assessment.IsActive = tt.isActive
            assessment.MaxAttemptsPerDay = tt.maxAttempts
            
            err := assessment.CanUserAttempt(tt.todayAttempts)
            
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
            }
        })
    }
}
```

---

### TASK-010: Crear tests de integración
**Tipo:** test  
**Estimación:** 1.5h  
**Archivo:** `assessment/integration_test.go`

```go
package assessment_test

import (
    "testing"
    "github.com/stretchr/testify/suite"
    // Import other packages
)

type AssessmentIntegrationSuite struct {
    suite.Suite
}

func TestAssessmentIntegrationSuite(t *testing.T) {
    suite.Run(t, new(AssessmentIntegrationSuite))
}

func (s *AssessmentIntegrationSuite) TestCompleteFlow() {
    // Test creating assessment, starting attempt, submitting answers, completing
}
```

---

### TASK-011: Verificar coverage y calidad
**Tipo:** validation  
**Estimación:** 30min  

**Comandos:**
```bash
# Run tests with coverage
go test -v -race -cover ./assessment/...

# Generate coverage report
go test -coverprofile=coverage.out ./assessment/...
go tool cover -html=coverage.out -o coverage.html

# Verify coverage is >85%
go tool cover -func=coverage.out | grep total

# Run linters
golangci-lint run ./assessment/...

# Check for ineffectual assignments
ineffassign ./assessment/...

# Static analysis
staticcheck ./assessment/...
```

---

### TASK-012: Preparar y crear release v0.7.0
**Tipo:** release  
**Estimación:** 1h  

**Pasos:**

1. **Actualizar version.go:**
```go
package shared

const Version = "v0.7.0"
```

2. **Actualizar CHANGELOG.md:**
```markdown
## [v0.7.0] - 2025-11-14

### Added
- New `assessment` module with complete domain entities
- Assessment and Attempt entities with business logic
- Repository interfaces for assessment persistence
- DTOs for API request/response handling
- Domain-specific errors
- Comprehensive test coverage (>85%)

### Dependencies
- No breaking changes to existing modules
```

3. **Commit y push:**
```bash
git add .
git commit -m "feat(assessment): add assessment module v0.7.0

- Complete domain entities for assessments and attempts
- Repository interfaces for persistence layer
- Request/Response DTOs for API communication
- Domain-specific error handling
- Test coverage >85%

This module provides shared types and interfaces for the educational
assessment system across all EduGo services."

git push origin feature/evaluaciones-shared-tipos
```

4. **Crear PR a dev:**
- Título: "feat(assessment): Assessment module v0.7.0"
- Body: Incluir link a esta spec y checklist

5. **Después del merge, crear release:**
```bash
git checkout dev
git pull origin dev

# Tag the release
git tag -a v0.7.0 -m "Release v0.7.0: Assessment module

Features:
- Complete assessment domain model
- Attempt management with business rules
- Repository interfaces
- DTOs for API contracts
- Domain error handling"

# Push tag
git push origin v0.7.0
```

---

## ✅ CHECKLIST DE VALIDACIÓN

Antes de considerar completado:

- [ ] **Estructura creada:** Todos los archivos en su lugar
- [ ] **Domain completo:** Assessment, Attempt, Value Objects
- [ ] **Repository interfaces:** Definidas y documentadas
- [ ] **DTOs completos:** Request y Response para todos los casos
- [ ] **Errores definidos:** Todos los errores de dominio
- [ ] **Tests unitarios:** >85% coverage
- [ ] **Tests de integración:** Flow completo probado
- [ ] **Linters pasando:** golangci-lint, staticcheck, ineffassign
- [ ] **go mod tidy:** Ejecutado y limpio
- [ ] **Documentación:** Comentarios en todas las funciones públicas
- [ ] **CHANGELOG:** Actualizado con cambios
- [ ] **PR aprobado:** Merged a dev
- [ ] **Release v0.7.0:** Tag creado y pushed
- [ ] **GitHub Actions:** Release automático exitoso

---

## 🚨 TROUBLESHOOTING

### Si los tests fallan:
```bash
# Ver detalles específicos
go test -v ./assessment/domain/...

# Correr test específico
go test -run TestNewAssessment ./assessment/domain/
```

### Si el coverage es <85%:
```bash
# Identificar líneas no cubiertas
go test -coverprofile=coverage.out ./assessment/...
go tool cover -html=coverage.out
# Agregar tests para las áreas faltantes
```

### Si el PR no se puede mergear:
```bash
# Actualizar desde dev
git fetch origin dev
git rebase origin/dev
# Resolver conflictos si hay
git push --force-with-lease origin feature/evaluaciones-shared-tipos
```

---

**⚠️ IMPORTANTE:** Este módulo es BLOQUEANTE para api-mobile y api-administracion. El release v0.7.0 DEBE estar disponible antes de continuar con los siguientes repos.

**Última actualización:** 14 de Noviembre, 2025