package models

import (
	"time"

	"github.com/google/uuid"
)

// ErrorResponse representa una respuesta de error
type ErrorResponse struct {
	Error   string                 `json:"error" example:"Error al procesar la petición"`
	Code    string                 `json:"code" example:"VALIDATION_ERROR"`
	Details map[string]interface{} `json:"details,omitempty"`
}

// Pagination representa la información de paginación
type Pagination struct {
	Page       int `json:"page" example:"1"`
	Limit      int `json:"limit" example:"20"`
	Total      int `json:"total" example:"100"`
	TotalPages int `json:"total_pages" example:"5"`
}

// UserResponse representa la información de un usuario
type UserResponse struct {
	ID         uuid.UUID `json:"id" example:"d0000001-0000-0000-0000-000000000001"`
	Email      string    `json:"email" example:"docente@edugo.com"`
	SystemRole string    `json:"system_role" example:"teacher"`
	Status     string    `json:"status" example:"active"`
	CreatedAt  time.Time `json:"created_at" example:"2024-01-15T10:00:00Z"`
}

// LoginResponse representa la respuesta del login
type LoginResponse struct {
	Token     string       `json:"token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	User      UserResponse `json:"user"`
	ExpiresAt time.Time    `json:"expires_at" example:"2024-01-16T10:00:00Z"`
}

// UnitResponse representa una unidad académica
type UnitResponse struct {
	ID           uuid.UUID              `json:"id" example:"u1000004-0000-0000-0000-000000000004"`
	SchoolID     uuid.UUID              `json:"school_id" example:"11111111-1111-1111-1111-111111111111"`
	ParentUnitID *uuid.UUID             `json:"parent_unit_id,omitempty" example:"u1000002-0000-0000-0000-000000000002"`
	UnitType     string                 `json:"unit_type" example:"section"`
	Name         string                 `json:"name" example:"5º A"`
	Code         string                 `json:"code" example:"CSJ-5P-A"`
	Metadata     map[string]interface{} `json:"metadata,omitempty"`
	CreatedAt    time.Time              `json:"created_at" example:"2024-01-01T00:00:00Z"`
}

// UnitsListResponse representa una lista paginada de unidades
type UnitsListResponse struct {
	Data       []UnitResponse `json:"data"`
	Pagination Pagination     `json:"pagination"`
}

// MembershipResponse representa una membresía de usuario en unidad
type MembershipResponse struct {
	ID         uuid.UUID `json:"id" example:"mem00001-0000-0000-0000-000000000001"`
	UnitID     uuid.UUID `json:"unit_id" example:"u1000004-0000-0000-0000-000000000004"`
	UserID     uuid.UUID `json:"user_id" example:"e0000001-0000-0000-0000-000000000001"`
	UnitRole   string    `json:"unit_role" example:"student"`
	Status     string    `json:"status" example:"active"`
	AssignedAt time.Time `json:"assigned_at" example:"2024-01-10T10:00:00Z"`
}

// MaterialResponse representa un material educativo
type MaterialResponse struct {
	ID          uuid.UUID  `json:"id" example:"m1000001-0000-0000-0000-000000000001"`
	AuthorID    uuid.UUID  `json:"author_id" example:"d0000001-0000-0000-0000-000000000001"`
	SubjectID   uuid.UUID  `json:"subject_id" example:"s1000001-0000-0000-0000-000000000001"`
	Title       string     `json:"title" example:"Introducción a las Fracciones"`
	Description string     `json:"description" example:"Material sobre fracciones básicas"`
	Status      string     `json:"status" example:"published"`
	PublishedAt *time.Time `json:"published_at,omitempty" example:"2024-01-20T10:00:00Z"`
	CreatedAt   time.Time  `json:"created_at" example:"2024-01-15T10:00:00Z"`
}

// MaterialDetailResponse representa el detalle completo de un material con URL firmada
type MaterialDetailResponse struct {
	MaterialResponse
	SignedURL    string    `json:"signed_url" example:"https://s3.amazonaws.com/edugo-materials/...?signature=..."`
	URLExpiresAt time.Time `json:"url_expires_at" example:"2024-01-20T10:15:00Z"`
}

// MaterialsListResponse representa una lista paginada de materiales
type MaterialsListResponse struct {
	Data       []MaterialResponse `json:"data"`
	Pagination Pagination         `json:"pagination"`
}

// SummarySection representa una sección del resumen
type SummarySection struct {
	Title   string `json:"title" example:"Introducción a las Fracciones"`
	Content string `json:"content" example:"Las fracciones son números que representan partes de un todo..."`
	Level   string `json:"level" example:"basic"`
}

// GlossaryTerm representa un término del glosario
type GlossaryTerm struct {
	Term       string `json:"term" example:"Numerador"`
	Definition string `json:"definition" example:"Número superior de una fracción"`
}

// SummaryResponse representa un resumen generado por IA
type SummaryResponse struct {
	ID                  uuid.UUID        `json:"id" example:"sum00001-0000-0000-0000-000000000001"`
	MaterialID          uuid.UUID        `json:"material_id" example:"m1000001-0000-0000-0000-000000000001"`
	Version             int              `json:"version" example:"1"`
	Sections            []SummarySection `json:"sections"`
	Glossary            []GlossaryTerm   `json:"glossary"`
	ReflectionQuestions []string         `json:"reflection_questions"`
	Status              string           `json:"status" example:"complete"`
	UpdatedAt           time.Time        `json:"updated_at" example:"2024-01-20T10:00:00Z"`
}

// Question representa una pregunta de evaluación
type Question struct {
	ID         uuid.UUID `json:"id" example:"q-frac-001"`
	Text       string    `json:"text" example:"¿Qué representa el numerador en una fracción?"`
	Type       string    `json:"type" example:"multiple_choice"`
	Options    []string  `json:"options,omitempty"`
	Difficulty string    `json:"difficulty" example:"easy"`
}

// AssessmentResponse representa una evaluación
type AssessmentResponse struct {
	ID                       uuid.UUID  `json:"id" example:"a1000001-0000-0000-0000-000000000001"`
	MaterialID               uuid.UUID  `json:"material_id" example:"m1000001-0000-0000-0000-000000000001"`
	Title                    string     `json:"title" example:"Quiz: Fracciones Básicas"`
	Questions                []Question `json:"questions"`
	TotalPoints              float64    `json:"total_points" example:"10"`
	EstimatedDurationMinutes int        `json:"estimated_duration_minutes" example:"15"`
}

// AttemptResponse representa un intento de evaluación
type AttemptResponse struct {
	ID           uuid.UUID  `json:"id" example:"at100001-0000-0000-0000-000000000001"`
	AssessmentID uuid.UUID  `json:"assessment_id" example:"a1000001-0000-0000-0000-000000000001"`
	UserID       uuid.UUID  `json:"user_id" example:"e0000001-0000-0000-0000-000000000001"`
	Score        *float64   `json:"score,omitempty" example:"85.5"`
	CompletedAt  *time.Time `json:"completed_at,omitempty" example:"2024-01-20T11:00:00Z"`
	StartedAt    time.Time  `json:"started_at" example:"2024-01-20T10:40:00Z"`
}
