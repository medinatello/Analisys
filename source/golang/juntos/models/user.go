package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

// AppUser - Tabla principal de usuarios
type AppUser struct {
	ID             uuid.UUID `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	Email          string    `gorm:"type:varchar(255);uniqueIndex;not null" json:"email"`
	CredentialHash string    `gorm:"type:varchar(255);not null" json:"-"` // Oculto en JSON
	SystemRole     string    `gorm:"type:varchar(50);not null;check:system_role IN ('teacher','student','admin','guardian')" json:"system_role"`
	Status         string    `gorm:"type:varchar(50);not null;default:active" json:"status"`
	CreatedAt      time.Time `gorm:"not null;default:now()" json:"created_at"`

	// Relaciones (uno a uno con perfiles)
	TeacherProfile  *TeacherProfile  `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"teacher_profile,omitempty"`
	StudentProfile  *StudentProfile  `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"student_profile,omitempty"`
	GuardianProfile *GuardianProfile `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"guardian_profile,omitempty"`

	// Relaciones (uno a muchos)
	LearningMaterials []LearningMaterial      `gorm:"foreignKey:AuthorID" json:"learning_materials,omitempty"`
	ReadingLogs       []ReadingLog            `gorm:"foreignKey:UserID" json:"reading_logs,omitempty"`
	AssessmentAttempts []AssessmentAttempt    `gorm:"foreignKey:UserID" json:"assessment_attempts,omitempty"`
	UnitMemberships    []UnitMembership       `gorm:"foreignKey:UserID" json:"unit_memberships,omitempty"`
}

// BeforeCreate - Hook para generar UUID si no existe
func (u *AppUser) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (AppUser) TableName() string {
	return "app_user"
}

// TeacherProfile - Perfil de docentes
type TeacherProfile struct {
	UserID      uuid.UUID      `gorm:"type:uuid;primaryKey" json:"user_id"`
	Specialty   string         `gorm:"type:varchar(255)" json:"specialty"`
	Preferences datatypes.JSON `gorm:"type:jsonb;default:'{}'" json:"preferences"`

	// Relación inversa
	User AppUser `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

// TableName - Nombre explícito de la tabla
func (TeacherProfile) TableName() string {
	return "teacher_profile"
}

// StudentProfile - Perfil de estudiantes
type StudentProfile struct {
	UserID        uuid.UUID  `gorm:"type:uuid;primaryKey" json:"user_id"`
	PrimaryUnitID *uuid.UUID `gorm:"type:uuid" json:"primary_unit_id"`
	CurrentGrade  string     `gorm:"type:varchar(50)" json:"current_grade"`
	StudentCode   string     `gorm:"type:varchar(100)" json:"student_code"`

	// Relaciones
	User        AppUser      `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
	PrimaryUnit *AcademicUnit `gorm:"foreignKey:PrimaryUnitID;constraint:OnDelete:SET NULL" json:"primary_unit,omitempty"`
}

// TableName - Nombre explícito de la tabla
func (StudentProfile) TableName() string {
	return "student_profile"
}

// GuardianProfile - Perfil de tutores/padres
type GuardianProfile struct {
	UserID           uuid.UUID `gorm:"type:uuid;primaryKey" json:"user_id"`
	Occupation       string    `gorm:"type:varchar(255)" json:"occupation"`
	AlternateContact string    `gorm:"type:varchar(255)" json:"alternate_contact"`

	// Relación inversa
	User AppUser `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

// TableName - Nombre explícito de la tabla
func (GuardianProfile) TableName() string {
	return "guardian_profile"
}

// GuardianStudentRelation - Relación tutor-estudiante (N:M)
type GuardianStudentRelation struct {
	ID               uuid.UUID `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	GuardianID       uuid.UUID `gorm:"type:uuid;not null" json:"guardian_id"`
	StudentID        uuid.UUID `gorm:"type:uuid;not null" json:"student_id"`
	RelationshipType string    `gorm:"type:varchar(100);not null" json:"relationship_type"`
	Status           string    `gorm:"type:varchar(50);not null;default:active" json:"status"`
	CreatedAt        time.Time `gorm:"not null;default:now()" json:"created_at"`

	// Relaciones
	Guardian AppUser `gorm:"foreignKey:GuardianID;constraint:OnDelete:CASCADE" json:"guardian,omitempty"`
	Student  AppUser `gorm:"foreignKey:StudentID;constraint:OnDelete:CASCADE" json:"student,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (g *GuardianStudentRelation) BeforeCreate(tx *gorm.DB) error {
	if g.ID == uuid.Nil {
		g.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (GuardianStudentRelation) TableName() string {
	return "guardian_student_relation"
}
