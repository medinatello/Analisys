package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

// ==============================================
// MODELOS TRADICIONALES (heredados de postgresql)
// Los mismos modelos AppUser, School, AcademicUnit, etc.
// están en user.go, academic.go, material.go
// ==============================================

// ==============================================
// MODELOS HÍBRIDOS (MongoDB convertido a JSONB)
// ==============================================

// MaterialSummaryJSON - Resúmenes con JSONB (reemplaza colección MongoDB)
type MaterialSummaryJSON struct {
	ID          uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	MaterialID  uuid.UUID      `gorm:"type:uuid;uniqueIndex;not null" json:"material_id"`
	Version     int            `gorm:"not null;default:1" json:"version"`
	SummaryData datatypes.JSON `gorm:"type:jsonb;not null" json:"summary_data"`
	Status      string         `gorm:"type:varchar(50);not null;default:pending" json:"status"`
	UpdatedAt   time.Time      `gorm:"not null;default:now()" json:"updated_at"`

	// Relación
	Material LearningMaterial `gorm:"foreignKey:MaterialID;constraint:OnDelete:CASCADE" json:"material,omitempty"`
}

func (m *MaterialSummaryJSON) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	return nil
}

func (MaterialSummaryJSON) TableName() string {
	return "material_summary_json"
}

// MaterialAssessmentJSON - Evaluaciones con JSONB (reemplaza colección MongoDB)
type MaterialAssessmentJSON struct {
	ID                       uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	MaterialID               uuid.UUID      `gorm:"type:uuid;uniqueIndex;not null" json:"material_id"`
	Title                    string         `gorm:"type:varchar(500);not null" json:"title"`
	Version                  int            `gorm:"not null;default:1" json:"version"`
	AssessmentData           datatypes.JSON `gorm:"type:jsonb;not null" json:"assessment_data"`
	TotalPoints              float64        `gorm:"type:decimal(5,2);not null" json:"total_points"`
	EstimatedDurationMinutes *int           `gorm:"type:int" json:"estimated_duration_minutes"`
	CreatedAt                time.Time      `gorm:"not null;default:now()" json:"created_at"`

	// Relaciones
	Material           LearningMaterial    `gorm:"foreignKey:MaterialID;constraint:OnDelete:CASCADE" json:"material,omitempty"`
	AssessmentAttempts []AssessmentAttempt `gorm:"foreignKey:AssessmentID" json:"assessment_attempts,omitempty"`
}

func (m *MaterialAssessmentJSON) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	return nil
}

func (MaterialAssessmentJSON) TableName() string {
	return "material_assessment_json"
}

// MaterialEventJSON - Eventos de procesamiento con JSONB
type MaterialEventJSON struct {
	ID              uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	MaterialID      uuid.UUID      `gorm:"type:uuid;not null" json:"material_id"`
	EventType       string         `gorm:"type:varchar(100);not null" json:"event_type"`
	WorkerID        string         `gorm:"type:varchar(255)" json:"worker_id"`
	DurationSeconds *float64       `gorm:"type:decimal(10,2)" json:"duration_seconds"`
	ErrorMessage    string         `gorm:"type:text" json:"error_message"`
	EventMetadata   datatypes.JSON `gorm:"type:jsonb;default:'{}'" json:"event_metadata"`
	CreatedAt       time.Time      `gorm:"not null;default:now()" json:"created_at"`

	// Relación
	Material LearningMaterial `gorm:"foreignKey:MaterialID;constraint:OnDelete:CASCADE" json:"material,omitempty"`
}

func (m *MaterialEventJSON) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	return nil
}

func (MaterialEventJSON) TableName() string {
	return "material_event_json"
}

// UnitSocialFeedJSON - Feed social con JSONB (POST-MVP)
type UnitSocialFeedJSON struct {
	ID         uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	UnitID     uuid.UUID      `gorm:"type:uuid;not null" json:"unit_id"`
	AuthorID   uuid.UUID      `gorm:"type:uuid;not null" json:"author_id"`
	PostType   string         `gorm:"type:varchar(50);not null" json:"post_type"`
	Content    string         `gorm:"type:text;not null" json:"content"`
	PostData   datatypes.JSON `gorm:"type:jsonb;default:'{}'" json:"post_data"`
	LikesCount int            `gorm:"type:int;default:0" json:"likes_count"`
	CreatedAt  time.Time      `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt  time.Time      `gorm:"not null;default:now()" json:"updated_at"`

	// Relaciones
	Unit   AcademicUnit `gorm:"foreignKey:UnitID;constraint:OnDelete:CASCADE" json:"unit,omitempty"`
	Author AppUser      `gorm:"foreignKey:AuthorID;constraint:OnDelete:CASCADE" json:"author,omitempty"`
}

func (u *UnitSocialFeedJSON) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}

func (UnitSocialFeedJSON) TableName() string {
	return "unit_social_feed_json"
}

// UserGraphRelationJSON - Relaciones sociales con JSONB (POST-MVP)
type UserGraphRelationJSON struct {
	ID               uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	UserID           uuid.UUID      `gorm:"type:uuid;not null" json:"user_id"`
	RelatedUserID    uuid.UUID      `gorm:"type:uuid;not null" json:"related_user_id"`
	RelationType     string         `gorm:"type:varchar(50);not null" json:"relation_type"`
	RelationMetadata datatypes.JSON `gorm:"type:jsonb;default:'{}'" json:"relation_metadata"`
	CreatedAt        time.Time      `gorm:"not null;default:now()" json:"created_at"`

	// Relaciones
	User        AppUser `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
	RelatedUser AppUser `gorm:"foreignKey:RelatedUserID;constraint:OnDelete:CASCADE" json:"related_user,omitempty"`
}

func (u *UserGraphRelationJSON) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}

func (UserGraphRelationJSON) TableName() string {
	return "user_graph_relation_json"
}
