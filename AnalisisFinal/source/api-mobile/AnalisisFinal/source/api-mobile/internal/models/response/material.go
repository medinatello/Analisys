package response

import "time"

// MaterialListResponse representa la lista de materiales
type MaterialListResponse struct {
	Materials []MaterialSummary `json:"materials"`
	Total     int               `json:"total"`
	Page      int               `json:"page"`
} // @name MaterialListResponse

// MaterialSummary representa un resumen de material en la lista
type MaterialSummary struct {
	ID           string    `json:"id" example:"uuid-1"`
	Title        string    `json:"title" example:"Introducción a Pascal"`
	SubjectName  string    `json:"subject_name" example:"Programación"`
	UnitName     string    `json:"unit_name" example:"5.º A - Programación"`
	Status       string    `json:"status" example:"new" enums:"new,in_progress,completed"`
	Progress     float64   `json:"progress" example:"0"`
	HasSummary   bool      `json:"has_summary" example:"true"`
	HasQuiz      bool      `json:"has_quiz" example:"true"`
	PublishedAt  time.Time `json:"published_at" example:"2025-01-15T12:00:00Z"`
} // @name MaterialSummary

// MaterialDetailResponse representa el detalle completo de un material
type MaterialDetailResponse struct {
	Material          MaterialDetail `json:"material"`
	PDFURL            string         `json:"pdf_url" example:"https://s3.../presigned-url"`
	PDFURLExpiresAt   time.Time      `json:"pdf_url_expires_at" example:"2025-01-29T11:15:00Z"`
	HasSummary        bool           `json:"has_summary" example:"true"`
	HasQuiz           bool           `json:"has_quiz" example:"true"`
} // @name MaterialDetailResponse

// MaterialDetail contiene información detallada del material
type MaterialDetail struct {
	ID          string    `json:"id" example:"uuid-1"`
	Title       string    `json:"title" example:"Introducción a Pascal"`
	Description string    `json:"description" example:"Material base sobre Pascal"`
	AuthorName  string    `json:"author_name" example:"Prof. García"`
	SubjectName string    `json:"subject_name" example:"Programación"`
	FileSize    int64     `json:"file_size" example:"2048576"`
	MyProgress  float64   `json:"my_progress" example:"0"`
	CreatedAt   time.Time `json:"created_at" example:"2025-01-15T12:00:00Z"`
} // @name MaterialDetail

// ErrorResponse representa una respuesta de error
type ErrorResponse struct {
	Error   string `json:"error" example:"Invalid request"`
	Message string `json:"message,omitempty" example:"Field 'title' is required"`
} // @name ErrorResponse

// CreateMaterialResponse representa la respuesta al crear un material
type CreateMaterialResponse struct {
	Status              string    `json:"status" example:"created"`
	MaterialID          string    `json:"material_id" example:"uuid-123"`
	UploadURL           string    `json:"upload_url" example:"https://s3.amazonaws.com/edugo-materials-prod/upload-url-mock"`
	UploadURLExpiresAt  time.Time `json:"upload_url_expires_at" example:"2025-01-29T12:15:00Z"`
	MaxFileSizeBytes    int64     `json:"max_file_size_bytes" example:"104857600"`
} // @name CreateMaterialResponse

// UploadCompleteResponse representa la respuesta al completar un upload
type UploadCompleteResponse struct {
	Status     string `json:"status" example:"processing"`
	MaterialID string `json:"material_id" example:"uuid-123"`
	Message    string `json:"message" example:"Material queued for processing"`
} // @name UploadCompleteResponse

// MaterialSummaryResponse representa la respuesta con el resumen del material
type MaterialSummaryResponse struct {
	Summary string `json:"summary" example:"Este material introduce los conceptos básicos de Pascal..."`
} // @name MaterialSummaryResponse

// AssessmentResponse representa la respuesta con el quiz del material
type AssessmentResponse struct {
	Questions []Question `json:"questions"`
} // @name AssessmentResponse

// Question representa una pregunta del quiz
type Question struct {
	ID       string   `json:"id" example:"q-uuid-1"`
	Question string   `json:"question" example:"¿Qué es Pascal?"`
	Type     string   `json:"type" example:"multiple_choice"`
	Options  []string `json:"options" example:"option_a,option_b,option_c,option_d"`
} // @name Question

// AttemptResultResponse representa la respuesta al registrar un intento
type AttemptResultResponse struct {
	Score       float64  `json:"score" example:"85.5"`
	TotalPoints float64  `json:"total_points" example:"100"`
	Passed      bool     `json:"passed" example:"true"`
	Feedback    []string `json:"feedback" example:"Pregunta 1: Correcta,Pregunta 2: Incorrecta"`
} // @name AttemptResultResponse

// SuccessResponse representa una respuesta genérica de éxito
type SuccessResponse struct {
	Status  string `json:"status" example:"success"`
	Message string `json:"message,omitempty" example:"Operation completed successfully"`
} // @name SuccessResponse

// MaterialStatsResponse representa las estadísticas de un material
type MaterialStatsResponse struct {
	TotalViews      int     `json:"total_views" example:"150"`
	TotalCompleted  int     `json:"total_completed" example:"45"`
	AverageProgress float64 `json:"average_progress" example:"65.5"`
	AverageScore    float64 `json:"average_score" example:"82.3"`
} // @name MaterialStatsResponse
