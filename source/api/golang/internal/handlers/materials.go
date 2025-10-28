package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/edugo/api/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// MaterialsHandler maneja las peticiones de materiales educativos
type MaterialsHandler struct{}

// NewMaterialsHandler crea un nuevo MaterialsHandler
func NewMaterialsHandler() *MaterialsHandler {
	return &MaterialsHandler{}
}

// ListMaterials godoc
// @Summary      Listar materiales educativos
// @Description  Obtiene la lista de materiales educativos con paginación
// @Tags         Materiales
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        subject_id query string false "Filtrar por materia"
// @Param        status query string false "Filtrar por estado" Enums(draft, published, archived)
// @Param        page query int false "Número de página" default(1)
// @Param        limit query int false "Elementos por página" default(20)
// @Success      200 {object} models.MaterialsListResponse
// @Failure      401 {object} models.ErrorResponse
// @Router       /v1/materials [get]
func (h *MaterialsHandler) ListMaterials(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	publishedAt := time.Now().AddDate(0, 0, -10)

	// Mock: datos de ejemplo
	mockMaterials := []models.MaterialResponse{
		{
			ID:          uuid.MustParse("m1000001-0000-0000-0000-000000000001"),
			AuthorID:    uuid.MustParse("d0000001-0000-0000-0000-000000000001"),
			SubjectID:   uuid.MustParse("s1000001-0000-0000-0000-000000000001"),
			Title:       "Introducción a las Fracciones",
			Description: "Material sobre fracciones básicas para 5º grado",
			Status:      "published",
			PublishedAt: &publishedAt,
			CreatedAt:   time.Now().AddDate(0, 0, -15),
		},
		{
			ID:          uuid.MustParse("m2000001-0000-0000-0000-000000000001"),
			AuthorID:    uuid.MustParse("d0000003-0000-0000-0000-000000000003"),
			SubjectID:   uuid.MustParse("s2000001-0000-0000-0000-000000000001"),
			Title:       "Fundamentos de Python",
			Description: "Introducción a la programación con Python",
			Status:      "published",
			PublishedAt: &publishedAt,
			CreatedAt:   time.Now().AddDate(0, 0, -20),
		},
	}

	c.JSON(http.StatusOK, models.MaterialsListResponse{
		Data: mockMaterials,
		Pagination: models.Pagination{
			Page:       page,
			Limit:      limit,
			Total:      len(mockMaterials),
			TotalPages: 1,
		},
	})
}

// CreateMaterial godoc
// @Summary      Crear material educativo
// @Description  Crea un nuevo material educativo (solo docentes)
// @Tags         Materiales
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body models.CreateMaterialRequest true "Datos del material"
// @Success      201 {object} models.MaterialResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      403 {object} models.ErrorResponse
// @Router       /v1/materials [post]
func (h *MaterialsHandler) CreateMaterial(c *gin.Context) {
	var req models.CreateMaterialRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "Datos de entrada inválidos",
			Code:  "INVALID_INPUT",
		})
		return
	}

	// Mock: crear material
	materialID := uuid.New()
	authorID := uuid.New() // Normalmente se obtiene del JWT

	c.JSON(http.StatusCreated, models.MaterialResponse{
		ID:          materialID,
		AuthorID:    authorID,
		SubjectID:   req.SubjectID,
		Title:       req.Title,
		Description: req.Description,
		Status:      "draft",
		CreatedAt:   time.Now(),
	})
}

// GetMaterial godoc
// @Summary      Obtener detalle de material
// @Description  Obtiene el detalle completo de un material incluyendo URL firmada para descarga
// @Tags         Materiales
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        materialId path string true "ID del material" format(uuid)
// @Success      200 {object} models.MaterialDetailResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      404 {object} models.ErrorResponse
// @Router       /v1/materials/{materialId} [get]
func (h *MaterialsHandler) GetMaterial(c *gin.Context) {
	materialID := c.Param("materialId")

	parsedID, err := uuid.Parse(materialID)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "ID inválido",
			Code:  "INVALID_UUID",
		})
		return
	}

	publishedAt := time.Now().AddDate(0, 0, -10)

	// Mock: material con URL firmada
	c.JSON(http.StatusOK, models.MaterialDetailResponse{
		MaterialResponse: models.MaterialResponse{
			ID:          parsedID,
			AuthorID:    uuid.MustParse("d0000001-0000-0000-0000-000000000001"),
			SubjectID:   uuid.MustParse("s1000001-0000-0000-0000-000000000001"),
			Title:       "Introducción a las Fracciones",
			Description: "Material sobre fracciones básicas",
			Status:      "published",
			PublishedAt: &publishedAt,
			CreatedAt:   time.Now().AddDate(0, 0, -15),
		},
		SignedURL:    "https://s3.amazonaws.com/edugo-materials/mock-url?signature=abcd1234",
		URLExpiresAt: time.Now().Add(15 * time.Minute),
	})
}

// UpdateMaterial godoc
// @Summary      Actualizar material
// @Description  Actualiza los metadatos de un material educativo
// @Tags         Materiales
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        materialId path string true "ID del material" format(uuid)
// @Param        request body models.UpdateMaterialRequest true "Datos a actualizar"
// @Success      200 {object} models.MaterialResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      404 {object} models.ErrorResponse
// @Router       /v1/materials/{materialId} [patch]
func (h *MaterialsHandler) UpdateMaterial(c *gin.Context) {
	materialID := c.Param("materialId")
	var req models.UpdateMaterialRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "Datos de entrada inválidos",
			Code:  "INVALID_INPUT",
		})
		return
	}

	parsedID, err := uuid.Parse(materialID)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "ID inválido",
			Code:  "INVALID_UUID",
		})
		return
	}

	status := "draft"
	if req.Status != "" {
		status = req.Status
	}

	c.JSON(http.StatusOK, models.MaterialResponse{
		ID:          parsedID,
		AuthorID:    uuid.MustParse("d0000001-0000-0000-0000-000000000001"),
		SubjectID:   uuid.MustParse("s1000001-0000-0000-0000-000000000001"),
		Title:       req.Title,
		Description: req.Description,
		Status:      status,
		CreatedAt:   time.Now().AddDate(0, 0, -15),
	})
}

// GetMaterialSummary godoc
// @Summary      Obtener resumen del material
// @Description  Obtiene el resumen generado por IA del material
// @Tags         Materiales
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        materialId path string true "ID del material" format(uuid)
// @Success      200 {object} models.SummaryResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      404 {object} models.ErrorResponse
// @Router       /v1/materials/{materialId}/summary [get]
func (h *MaterialsHandler) GetMaterialSummary(c *gin.Context) {
	materialID := c.Param("materialId")

	parsedID, err := uuid.Parse(materialID)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "ID inválido",
			Code:  "INVALID_UUID",
		})
		return
	}

	// Mock: resumen
	c.JSON(http.StatusOK, models.SummaryResponse{
		ID:         uuid.New(),
		MaterialID: parsedID,
		Version:    1,
		Sections: []models.SummarySection{
			{
				Title:   "Introducción a las Fracciones",
				Content: "Las fracciones son números que representan partes de un todo...",
				Level:   "basic",
			},
			{
				Title:   "Tipos de Fracciones",
				Content: "Existen tres tipos principales de fracciones: propias, impropias y mixtas...",
				Level:   "intermediate",
			},
		},
		Glossary: []models.GlossaryTerm{
			{Term: "Numerador", Definition: "Número superior de una fracción"},
			{Term: "Denominador", Definition: "Número inferior de una fracción"},
		},
		ReflectionQuestions: []string{
			"¿Por qué es importante tener un denominador común al sumar fracciones?",
			"¿En qué situaciones de la vida real utilizas fracciones?",
		},
		Status:    "complete",
		UpdatedAt: time.Now(),
	})
}

// GetMaterialAssessment godoc
// @Summary      Obtener evaluación del material
// @Description  Obtiene la evaluación asociada al material
// @Tags         Evaluaciones
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        materialId path string true "ID del material" format(uuid)
// @Success      200 {object} models.AssessmentResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      404 {object} models.ErrorResponse
// @Router       /v1/materials/{materialId}/assessment [get]
func (h *MaterialsHandler) GetMaterialAssessment(c *gin.Context) {
	materialID := c.Param("materialId")

	parsedID, err := uuid.Parse(materialID)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "ID inválido",
			Code:  "INVALID_UUID",
		})
		return
	}

	// Mock: evaluación
	c.JSON(http.StatusOK, models.AssessmentResponse{
		ID:         uuid.New(),
		MaterialID: parsedID,
		Title:      "Quiz: Fracciones Básicas",
		Questions: []models.Question{
			{
				ID:   uuid.MustParse("00000001-0000-0000-0000-000000000001"),
				Text: "¿Qué representa el numerador en una fracción?",
				Type: "multiple_choice",
				Options: []string{
					"A) El número de partes que tenemos",
					"B) El número total de partes",
					"C) El resultado de la división",
				},
				Difficulty: "easy",
			},
			{
				ID:         uuid.MustParse("00000002-0000-0000-0000-000000000002"),
				Text:       "En la fracción 3/4, ¿cuál es el denominador?",
				Type:       "multiple_choice",
				Options:    []string{"A) 3", "B) 4", "C) 7"},
				Difficulty: "easy",
			},
		},
		TotalPoints:              10,
		EstimatedDurationMinutes: 15,
	})
}

// CreateAssessmentAttempt godoc
// @Summary      Registrar intento de evaluación
// @Description  Registra un nuevo intento de evaluación por parte del estudiante
// @Tags         Evaluaciones
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        materialId path string true "ID del material" format(uuid)
// @Param        request body models.CreateAttemptRequest true "Respuestas del estudiante"
// @Success      201 {object} models.AttemptResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      401 {object} models.ErrorResponse
// @Router       /v1/materials/{materialId}/assessment/attempts [post]
func (h *MaterialsHandler) CreateAssessmentAttempt(c *gin.Context) {
	materialID := c.Param("materialId")
	var req models.CreateAttemptRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "Datos de entrada inválidos",
			Code:  "INVALID_INPUT",
		})
		return
	}

	_, err := uuid.Parse(materialID)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "ID de material inválido",
			Code:  "INVALID_UUID",
		})
		return
	}

	// Mock: calcular score aleatorio
	score := 85.5
	completedAt := time.Now()

	c.JSON(http.StatusCreated, models.AttemptResponse{
		ID:           uuid.New(),
		AssessmentID: uuid.New(),
		UserID:       uuid.New(), // Normalmente del JWT
		Score:        &score,
		CompletedAt:  &completedAt,
		StartedAt:    time.Now().Add(-20 * time.Minute),
	})
}
