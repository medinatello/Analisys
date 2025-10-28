package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

// LearningMaterial - Metadatos de materiales educativos
type LearningMaterial struct {
	ID            uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	AuthorID      uuid.UUID      `gorm:"type:uuid;not null" json:"author_id"`
	SubjectID     uuid.UUID      `gorm:"type:uuid;not null" json:"subject_id"`
	Title         string         `gorm:"type:varchar(500);not null" json:"title"`
	Description   string         `gorm:"type:text" json:"description"`
	S3URL         string         `gorm:"type:varchar(1000)" json:"s3_url"`
	ExtraMetadata datatypes.JSON `gorm:"type:jsonb;default:'{}'" json:"extra_metadata"`
	PublishedAt   *time.Time     `gorm:"type:timestamptz" json:"published_at"`
	Status        string         `gorm:"type:varchar(50);not null;default:draft" json:"status"`
	CreatedAt     time.Time      `gorm:"not null;default:now()" json:"created_at"`

	// Relaciones
	Author              AppUser              `gorm:"foreignKey:AuthorID;constraint:OnDelete:CASCADE" json:"author,omitempty"`
	Subject             Subject              `gorm:"foreignKey:SubjectID;constraint:OnDelete:CASCADE" json:"subject,omitempty"`
	MaterialVersions    []MaterialVersion    `gorm:"foreignKey:MaterialID" json:"material_versions,omitempty"`
	MaterialUnitLinks   []MaterialUnitLink   `gorm:"foreignKey:MaterialID" json:"material_unit_links,omitempty"`
	ReadingLogs         []ReadingLog         `gorm:"foreignKey:MaterialID" json:"reading_logs,omitempty"`
	MaterialSummaryLink *MaterialSummaryLink `gorm:"foreignKey:MaterialID" json:"material_summary_link,omitempty"`
	Assessment          *Assessment          `gorm:"foreignKey:MaterialID" json:"assessment,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (l *LearningMaterial) BeforeCreate(tx *gorm.DB) error {
	if l.ID == uuid.Nil {
		l.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (LearningMaterial) TableName() string {
	return "learning_material"
}

// MaterialVersion - Historial de versiones de materiales
type MaterialVersion struct {
	ID            uuid.UUID `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	MaterialID    uuid.UUID `gorm:"type:uuid;not null" json:"material_id"`
	S3VersionURL  string    `gorm:"type:varchar(1000);not null" json:"s3_version_url"`
	FileHash      string    `gorm:"type:varchar(64)" json:"file_hash"`
	GeneratedAt   time.Time `gorm:"not null;default:now()" json:"generated_at"`

	// Relaciones
	Material LearningMaterial `gorm:"foreignKey:MaterialID;constraint:OnDelete:CASCADE" json:"material,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (m *MaterialVersion) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (MaterialVersion) TableName() string {
	return "material_version"
}

// MaterialUnitLink - Asignación de materiales a unidades (N:M)
type MaterialUnitLink struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	MaterialID uuid.UUID `gorm:"type:uuid;not null" json:"material_id"`
	UnitID     uuid.UUID `gorm:"type:uuid;not null" json:"unit_id"`
	Scope      string    `gorm:"type:varchar(100)" json:"scope"`
	Visibility string    `gorm:"type:varchar(50);not null;default:public" json:"visibility"`
	AssignedAt time.Time `gorm:"not null;default:now()" json:"assigned_at"`

	// Relaciones
	Material LearningMaterial `gorm:"foreignKey:MaterialID;constraint:OnDelete:CASCADE" json:"material,omitempty"`
	Unit     AcademicUnit     `gorm:"foreignKey:UnitID;constraint:OnDelete:CASCADE" json:"unit,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (m *MaterialUnitLink) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (MaterialUnitLink) TableName() string {
	return "material_unit_link"
}

// ReadingLog - Registro de progreso de lectura
type ReadingLog struct {
	ID           uuid.UUID `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	MaterialID   uuid.UUID `gorm:"type:uuid;not null" json:"material_id"`
	UserID       uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	Progress     float64   `gorm:"type:decimal(5,4);default:0.0;check:progress >= 0.0 AND progress <= 1.0" json:"progress"`
	LastAccessAt time.Time `gorm:"not null;default:now()" json:"last_access_at"`

	// Relaciones
	Material LearningMaterial `gorm:"foreignKey:MaterialID;constraint:OnDelete:CASCADE" json:"material,omitempty"`
	User     AppUser          `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (r *ReadingLog) BeforeCreate(tx *gorm.DB) error {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (ReadingLog) TableName() string {
	return "reading_log"
}

// MaterialSummaryLink - Enlace a resúmenes en MongoDB
type MaterialSummaryLink struct {
	MaterialID      uuid.UUID `gorm:"type:uuid;primaryKey" json:"material_id"`
	MongoDocumentID uuid.UUID `gorm:"type:uuid;not null" json:"mongo_document_id"`
	UpdatedAt       time.Time `gorm:"not null;default:now()" json:"updated_at"`
	Status          string    `gorm:"type:varchar(50);not null;default:pending" json:"status"`

	// Relación
	Material LearningMaterial `gorm:"foreignKey:MaterialID;constraint:OnDelete:CASCADE" json:"material,omitempty"`
}

// TableName - Nombre explícito de la tabla
func (MaterialSummaryLink) TableName() string {
	return "material_summary_link"
}

// Assessment - Metadatos de evaluaciones
type Assessment struct {
	ID              uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	MaterialID      uuid.UUID      `gorm:"type:uuid;uniqueIndex;not null" json:"material_id"`
	Title           string         `gorm:"type:varchar(500);not null" json:"title"`
	MongoDocumentID uuid.UUID      `gorm:"type:uuid;not null" json:"mongo_document_id"`
	Config          datatypes.JSON `gorm:"type:jsonb;default:'{}'" json:"config"`
	CreatedAt       time.Time      `gorm:"not null;default:now()" json:"created_at"`

	// Relaciones
	Material           LearningMaterial    `gorm:"foreignKey:MaterialID;constraint:OnDelete:CASCADE" json:"material,omitempty"`
	AssessmentAttempts []AssessmentAttempt `gorm:"foreignKey:AssessmentID" json:"assessment_attempts,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (a *Assessment) BeforeCreate(tx *gorm.DB) error {
	if a.ID == uuid.Nil {
		a.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (Assessment) TableName() string {
	return "assessment"
}

// AssessmentAttempt - Intentos de evaluación
type AssessmentAttempt struct {
	ID           uuid.UUID  `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	AssessmentID uuid.UUID  `gorm:"type:uuid;not null" json:"assessment_id"`
	UserID       uuid.UUID  `gorm:"type:uuid;not null" json:"user_id"`
	Score        *float64   `gorm:"type:decimal(5,2)" json:"score"`
	CompletedAt  *time.Time `gorm:"type:timestamptz" json:"completed_at"`
	StartedAt    time.Time  `gorm:"not null;default:now()" json:"started_at"`

	// Relaciones
	Assessment             Assessment               `gorm:"foreignKey:AssessmentID;constraint:OnDelete:CASCADE" json:"assessment,omitempty"`
	User                   AppUser                  `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
	AssessmentAttemptAnswers []AssessmentAttemptAnswer `gorm:"foreignKey:AttemptID" json:"assessment_attempt_answers,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (a *AssessmentAttempt) BeforeCreate(tx *gorm.DB) error {
	if a.ID == uuid.Nil {
		a.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (AssessmentAttempt) TableName() string {
	return "assessment_attempt"
}

// AssessmentAttemptAnswer - Respuestas individuales de intentos
type AssessmentAttemptAnswer struct {
	ID              uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	AttemptID       uuid.UUID      `gorm:"type:uuid;not null" json:"attempt_id"`
	QuestionMongoID uuid.UUID      `gorm:"type:uuid;not null" json:"question_mongo_id"`
	AnswerPayload   datatypes.JSON `gorm:"type:jsonb;not null" json:"answer_payload"`
	IsCorrect       *bool          `gorm:"type:boolean" json:"is_correct"`
	AnsweredAt      time.Time      `gorm:"not null;default:now()" json:"answered_at"`

	// Relación
	Attempt AssessmentAttempt `gorm:"foreignKey:AttemptID;constraint:OnDelete:CASCADE" json:"attempt,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (a *AssessmentAttemptAnswer) BeforeCreate(tx *gorm.DB) error {
	if a.ID == uuid.Nil {
		a.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (AssessmentAttemptAnswer) TableName() string {
	return "assessment_attempt_answer"
}
