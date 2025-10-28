package models

import (
	"time"

	"github.com/google/uuid"
)

// MaterialSummary - Resúmenes generados por IA
type MaterialSummary struct {
	ID                 string              `bson:"_id" json:"id"`
	MaterialID         string              `bson:"material_id" json:"material_id"`
	Version            int                 `bson:"version" json:"version"`
	Sections           []SummarySection    `bson:"sections" json:"sections"`
	Glossary           []GlossaryTerm      `bson:"glossary,omitempty" json:"glossary,omitempty"`
	ReflectionQuestions []string           `bson:"reflection_questions,omitempty" json:"reflection_questions,omitempty"`
	Status             string              `bson:"status" json:"status"` // pending, processing, complete, failed
	UpdatedAt          time.Time           `bson:"updated_at" json:"updated_at"`
}

// SummarySection - Sección de un resumen
type SummarySection struct {
	Title   string `bson:"title" json:"title"`
	Content string `bson:"content" json:"content"`
	Level   string `bson:"level" json:"level"` // basic, intermediate, advanced
}

// GlossaryTerm - Término del glosario
type GlossaryTerm struct {
	Term       string `bson:"term" json:"term"`
	Definition string `bson:"definition" json:"definition"`
}

// MaterialAssessment - Banco de preguntas y evaluaciones
type MaterialAssessment struct {
	ID                       string     `bson:"_id" json:"id"`
	MaterialID               string     `bson:"material_id" json:"material_id"`
	Title                    string     `bson:"title" json:"title"`
	Questions                []Question `bson:"questions" json:"questions"`
	Version                  int        `bson:"version" json:"version"`
	TotalPoints              float64    `bson:"total_points" json:"total_points"`
	EstimatedDurationMinutes int        `bson:"estimated_duration_minutes,omitempty" json:"estimated_duration_minutes,omitempty"`
	CreatedAt                time.Time  `bson:"created_at" json:"created_at"`
}

// Question - Pregunta de evaluación
type Question struct {
	ID         string   `bson:"id" json:"id"`
	Text       string   `bson:"text" json:"text"`
	Type       string   `bson:"type" json:"type"` // multiple_choice, true_false, open_ended
	Options    []string `bson:"options,omitempty" json:"options,omitempty"`
	Answer     *string  `bson:"answer,omitempty" json:"answer,omitempty"`
	Feedback   string   `bson:"feedback,omitempty" json:"feedback,omitempty"`
	Rubric     string   `bson:"rubric,omitempty" json:"rubric,omitempty"`
	Difficulty string   `bson:"difficulty" json:"difficulty"` // easy, medium, hard
	Points     float64  `bson:"points,omitempty" json:"points,omitempty"`
}

// MaterialEvent - Logs y métricas de procesamiento
type MaterialEvent struct {
	ID              string                 `bson:"_id" json:"id"`
	MaterialID      string                 `bson:"material_id" json:"material_id"`
	EventType       string                 `bson:"event_type" json:"event_type"` // processing_started, processing_completed, processing_failed
	WorkerID        string                 `bson:"worker_id,omitempty" json:"worker_id,omitempty"`
	DurationSeconds *float64               `bson:"duration_seconds,omitempty" json:"duration_seconds,omitempty"`
	ErrorMessage    string                 `bson:"error_message,omitempty" json:"error_message,omitempty"`
	Metadata        map[string]interface{} `bson:"metadata,omitempty" json:"metadata,omitempty"`
	CreatedAt       time.Time              `bson:"created_at" json:"created_at"`
}

// UnitSocialFeed - Feeds sociales de unidades académicas (POST-MVP)
type UnitSocialFeed struct {
	ID         string       `bson:"_id" json:"id"`
	UnitID     string       `bson:"unit_id" json:"unit_id"`
	AuthorID   string       `bson:"author_id" json:"author_id"`
	PostType   string       `bson:"post_type" json:"post_type"` // announcement, discussion, resource_share, question
	Content    string       `bson:"content" json:"content"`
	Attachments []Attachment `bson:"attachments,omitempty" json:"attachments,omitempty"`
	LikesCount int          `bson:"likes_count" json:"likes_count"`
	Comments   []Comment    `bson:"comments,omitempty" json:"comments,omitempty"`
	CreatedAt  time.Time    `bson:"created_at" json:"created_at"`
	UpdatedAt  time.Time    `bson:"updated_at" json:"updated_at"`
}

// Attachment - Archivo adjunto en un post
type Attachment struct {
	Type         string `bson:"type" json:"type"` // image, video, document, link
	URL          string `bson:"url" json:"url"`
	ThumbnailURL string `bson:"thumbnail_url,omitempty" json:"thumbnail_url,omitempty"`
}

// Comment - Comentario en un post
type Comment struct {
	AuthorID  string    `bson:"author_id" json:"author_id"`
	Text      string    `bson:"text" json:"text"`
	CreatedAt time.Time `bson:"created_at" json:"created_at"`
}

// UserGraphRelation - Grafos sociales entre usuarios (POST-MVP)
type UserGraphRelation struct {
	ID            string                 `bson:"_id" json:"id"`
	UserID        string                 `bson:"user_id" json:"user_id"`
	RelationType  string                 `bson:"relation_type" json:"relation_type"` // follows, recommends, mentors, blocks
	RelatedUserID string                 `bson:"related_user_id" json:"related_user_id"`
	Metadata      map[string]interface{} `bson:"metadata,omitempty" json:"metadata,omitempty"`
	CreatedAt     time.Time              `bson:"created_at" json:"created_at"`
}

// NewMaterialSummary - Constructor para MaterialSummary
func NewMaterialSummary(materialID string) *MaterialSummary {
	return &MaterialSummary{
		ID:         uuid.New().String(),
		MaterialID: materialID,
		Version:    1,
		Sections:   []SummarySection{},
		Status:     "pending",
		UpdatedAt:  time.Now(),
	}
}

// NewMaterialAssessment - Constructor para MaterialAssessment
func NewMaterialAssessment(materialID, title string) *MaterialAssessment {
	return &MaterialAssessment{
		ID:          uuid.New().String(),
		MaterialID:  materialID,
		Title:       title,
		Questions:   []Question{},
		Version:     1,
		TotalPoints: 0,
		CreatedAt:   time.Now(),
	}
}

// NewMaterialEvent - Constructor para MaterialEvent
func NewMaterialEvent(materialID, eventType string) *MaterialEvent {
	return &MaterialEvent{
		ID:         uuid.New().String(),
		MaterialID: materialID,
		EventType:  eventType,
		Metadata:   make(map[string]interface{}),
		CreatedAt:  time.Now(),
	}
}

// NewUnitSocialFeed - Constructor para UnitSocialFeed
func NewUnitSocialFeed(unitID, authorID, postType, content string) *UnitSocialFeed {
	return &UnitSocialFeed{
		ID:          uuid.New().String(),
		UnitID:      unitID,
		AuthorID:    authorID,
		PostType:    postType,
		Content:     content,
		Attachments: []Attachment{},
		LikesCount:  0,
		Comments:    []Comment{},
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
}

// NewUserGraphRelation - Constructor para UserGraphRelation
func NewUserGraphRelation(userID, relationType, relatedUserID string) *UserGraphRelation {
	return &UserGraphRelation{
		ID:            uuid.New().String(),
		UserID:        userID,
		RelationType:  relationType,
		RelatedUserID: relatedUserID,
		Metadata:      make(map[string]interface{}),
		CreatedAt:     time.Now(),
	}
}
