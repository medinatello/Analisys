package models

import "github.com/google/uuid"

// LoginRequest representa la petición de login
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email" example:"docente@edugo.com"`
	Password string `json:"password" binding:"required,min=8" example:"password123"`
}

// CreateUserRequest representa la petición para crear un usuario
type CreateUserRequest struct {
	Email      string `json:"email" binding:"required,email" example:"nuevo@edugo.com"`
	Password   string `json:"password" binding:"required,min=8" example:"password123"`
	SystemRole string `json:"system_role" binding:"required,oneof=teacher student admin guardian" example:"teacher"`
	FullName   string `json:"full_name,omitempty" example:"Juan Pérez"`
}

// CreateUnitRequest representa la petición para crear una unidad académica
type CreateUnitRequest struct {
	SchoolID     uuid.UUID              `json:"school_id" binding:"required" example:"11111111-1111-1111-1111-111111111111"`
	ParentUnitID *uuid.UUID             `json:"parent_unit_id,omitempty" example:"22222222-2222-2222-2222-222222222222"`
	UnitType     string                 `json:"unit_type" binding:"required,oneof=school academic_year section club academy_level" example:"section"`
	Name         string                 `json:"name" binding:"required" example:"5º A"`
	Code         string                 `json:"code,omitempty" example:"5A-2024"`
	Metadata     map[string]interface{} `json:"metadata,omitempty"`
}

// UpdateUnitRequest representa la petición para actualizar una unidad
type UpdateUnitRequest struct {
	Name     string                 `json:"name,omitempty" example:"5º B"`
	Code     string                 `json:"code,omitempty" example:"5B-2024"`
	Metadata map[string]interface{} `json:"metadata,omitempty"`
}

// AddMemberRequest representa la petición para asignar un miembro a una unidad
type AddMemberRequest struct {
	UserID   uuid.UUID `json:"user_id" binding:"required" example:"e0000001-0000-0000-0000-000000000001"`
	UnitRole string    `json:"unit_role" binding:"required,oneof=owner teacher assistant student guardian" example:"student"`
}

// CreateMaterialRequest representa la petición para crear un material
type CreateMaterialRequest struct {
	SubjectID   uuid.UUID `json:"subject_id" binding:"required" example:"s1000001-0000-0000-0000-000000000001"`
	Title       string    `json:"title" binding:"required" example:"Introducción a las Fracciones"`
	Description string    `json:"description,omitempty" example:"Material educativo sobre fracciones básicas"`
	S3URL       string    `json:"s3_url,omitempty" example:"s3://edugo-materials/..."`
}

// UpdateMaterialRequest representa la petición para actualizar un material
type UpdateMaterialRequest struct {
	Title       string `json:"title,omitempty" example:"Fracciones Avanzadas"`
	Description string `json:"description,omitempty" example:"Material actualizado"`
	Status      string `json:"status,omitempty" binding:"omitempty,oneof=draft published archived" example:"published"`
}

// Answer representa una respuesta individual
type Answer struct {
	QuestionID uuid.UUID `json:"question_id" binding:"required" example:"q-frac-001"`
	Answer     string    `json:"answer" binding:"required" example:"A"`
}

// CreateAttemptRequest representa la petición para registrar un intento de evaluación
type CreateAttemptRequest struct {
	Answers []Answer `json:"answers" binding:"required,min=1"`
}
