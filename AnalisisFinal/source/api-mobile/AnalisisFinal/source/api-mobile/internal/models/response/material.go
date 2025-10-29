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
