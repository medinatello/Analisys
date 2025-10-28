package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

// School - Organizaciones educativas (colegios/academias)
type School struct {
	ID           uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	Name         string         `gorm:"type:varchar(255);not null" json:"name"`
	ExternalCode string         `gorm:"type:varchar(100);uniqueIndex" json:"external_code"`
	Location     string         `gorm:"type:varchar(500)" json:"location"`
	Metadata     datatypes.JSON `gorm:"type:jsonb;default:'{}'" json:"metadata"`
	CreatedAt    time.Time      `gorm:"not null;default:now()" json:"created_at"`

	// Relaciones
	AcademicUnits []AcademicUnit `gorm:"foreignKey:SchoolID" json:"academic_units,omitempty"`
	Subjects      []Subject      `gorm:"foreignKey:SchoolID" json:"subjects,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (s *School) BeforeCreate(tx *gorm.DB) error {
	if s.ID == uuid.Nil {
		s.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (School) TableName() string {
	return "school"
}

// AcademicUnit - Unidades académicas jerárquicas (recursiva)
type AcademicUnit struct {
	ID             uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	SchoolID       uuid.UUID      `gorm:"type:uuid;not null" json:"school_id"`
	ParentUnitID   *uuid.UUID     `gorm:"type:uuid" json:"parent_unit_id"`
	UnitType       string         `gorm:"type:varchar(50);not null;check:unit_type IN ('school','academic_year','section','club','academy_level')" json:"unit_type"`
	Name           string         `gorm:"type:varchar(255);not null" json:"name"`
	Code           string         `gorm:"type:varchar(100)" json:"code"`
	Metadata       datatypes.JSON `gorm:"type:jsonb;default:'{}'" json:"metadata"`
	ValidityPeriod string         `gorm:"type:tstzrange" json:"validity_period"`
	CreatedAt      time.Time      `gorm:"not null;default:now()" json:"created_at"`

	// Relaciones
	School           School           `gorm:"foreignKey:SchoolID;constraint:OnDelete:CASCADE" json:"school,omitempty"`
	ParentUnit       *AcademicUnit    `gorm:"foreignKey:ParentUnitID;constraint:OnDelete:SET NULL" json:"parent_unit,omitempty"`
	ChildUnits       []AcademicUnit   `gorm:"foreignKey:ParentUnitID" json:"child_units,omitempty"`
	UnitMemberships  []UnitMembership `gorm:"foreignKey:UnitID" json:"unit_memberships,omitempty"`
	MaterialUnitLinks []MaterialUnitLink `gorm:"foreignKey:UnitID" json:"material_unit_links,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (a *AcademicUnit) BeforeCreate(tx *gorm.DB) error {
	if a.ID == uuid.Nil {
		a.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (AcademicUnit) TableName() string {
	return "academic_unit"
}

// UnitMembership - Membresías de usuarios en unidades (N:M con roles)
type UnitMembership struct {
	ID         uuid.UUID  `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	UnitID     uuid.UUID  `gorm:"type:uuid;not null" json:"unit_id"`
	UserID     uuid.UUID  `gorm:"type:uuid;not null" json:"user_id"`
	UnitRole   string     `gorm:"type:varchar(50);not null;check:unit_role IN ('owner','teacher','assistant','student','guardian')" json:"unit_role"`
	Status     string     `gorm:"type:varchar(50);not null;default:active" json:"status"`
	AssignedAt time.Time  `gorm:"not null;default:now()" json:"assigned_at"`
	RemovedAt  *time.Time `gorm:"type:timestamptz" json:"removed_at"`

	// Relaciones
	Unit AcademicUnit `gorm:"foreignKey:UnitID;constraint:OnDelete:CASCADE" json:"unit,omitempty"`
	User AppUser      `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (u *UnitMembership) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (UnitMembership) TableName() string {
	return "unit_membership"
}

// Subject - Catálogo de materias
type Subject struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	SchoolID    uuid.UUID `gorm:"type:uuid;not null" json:"school_id"`
	Name        string    `gorm:"type:varchar(255);not null" json:"name"`
	Description string    `gorm:"type:text" json:"description"`
	CreatedAt   time.Time `gorm:"not null;default:now()" json:"created_at"`

	// Relaciones
	School           School            `gorm:"foreignKey:SchoolID;constraint:OnDelete:CASCADE" json:"school,omitempty"`
	LearningMaterials []LearningMaterial `gorm:"foreignKey:SubjectID" json:"learning_materials,omitempty"`
}

// BeforeCreate - Hook para generar UUID
func (s *Subject) BeforeCreate(tx *gorm.DB) error {
	if s.ID == uuid.Nil {
		s.ID = uuid.New()
	}
	return nil
}

// TableName - Nombre explícito de la tabla
func (Subject) TableName() string {
	return "subject"
}
