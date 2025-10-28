package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/edugo/api/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// UnitsHandler maneja las peticiones de unidades académicas
type UnitsHandler struct{}

// NewUnitsHandler crea un nuevo UnitsHandler
func NewUnitsHandler() *UnitsHandler {
	return &UnitsHandler{}
}

// ListUnits godoc
// @Summary      Listar unidades académicas
// @Description  Obtiene la jerarquía de unidades académicas con paginación
// @Tags         Unidades Académicas
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        school_id query string false "Filtrar por ID de colegio"
// @Param        type query string false "Filtrar por tipo de unidad" Enums(school, academic_year, section, club, academy_level)
// @Param        page query int false "Número de página" default(1)
// @Param        limit query int false "Elementos por página" default(20)
// @Success      200 {object} models.UnitsListResponse
// @Failure      401 {object} models.ErrorResponse
// @Router       /v1/units [get]
func (h *UnitsHandler) ListUnits(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	// Mock: datos de ejemplo
	mockUnits := []models.UnitResponse{
		{
			ID:       uuid.MustParse("u1000004-0000-0000-0000-000000000004"),
			SchoolID: uuid.MustParse("11111111-1111-1111-1111-111111111111"),
			UnitType: "section",
			Name:     "5º A",
			Code:     "CSJ-5P-A",
			Metadata: map[string]interface{}{
				"capacity": 30,
			},
			CreatedAt: time.Now().AddDate(0, -1, 0),
		},
		{
			ID:       uuid.MustParse("u1000005-0000-0000-0000-000000000005"),
			SchoolID: uuid.MustParse("11111111-1111-1111-1111-111111111111"),
			UnitType: "section",
			Name:     "5º B",
			Code:     "CSJ-5P-B",
			CreatedAt: time.Now().AddDate(0, -1, 0),
		},
	}

	c.JSON(http.StatusOK, models.UnitsListResponse{
		Data: mockUnits,
		Pagination: models.Pagination{
			Page:       page,
			Limit:      limit,
			Total:      len(mockUnits),
			TotalPages: 1,
		},
	})
}

// CreateUnit godoc
// @Summary      Crear unidad académica
// @Description  Crea una nueva unidad académica (admin o docente owner)
// @Tags         Unidades Académicas
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body models.CreateUnitRequest true "Datos de la unidad"
// @Success      201 {object} models.UnitResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      403 {object} models.ErrorResponse
// @Router       /v1/units [post]
func (h *UnitsHandler) CreateUnit(c *gin.Context) {
	var req models.CreateUnitRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "Datos de entrada inválidos",
			Code:  "INVALID_INPUT",
		})
		return
	}

	// Mock: crear unidad
	unitID := uuid.New()

	c.JSON(http.StatusCreated, models.UnitResponse{
		ID:           unitID,
		SchoolID:     req.SchoolID,
		ParentUnitID: req.ParentUnitID,
		UnitType:     req.UnitType,
		Name:         req.Name,
		Code:         req.Code,
		Metadata:     req.Metadata,
		CreatedAt:    time.Now(),
	})
}

// UpdateUnit godoc
// @Summary      Actualizar unidad académica
// @Description  Actualiza los datos de una unidad académica
// @Tags         Unidades Académicas
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        unitId path string true "ID de la unidad" format(uuid)
// @Param        request body models.UpdateUnitRequest true "Datos a actualizar"
// @Success      200 {object} models.UnitResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      404 {object} models.ErrorResponse
// @Router       /v1/units/{unitId} [patch]
func (h *UnitsHandler) UpdateUnit(c *gin.Context) {
	unitID := c.Param("unitId")
	var req models.UpdateUnitRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "Datos de entrada inválidos",
			Code:  "INVALID_INPUT",
		})
		return
	}

	parsedID, err := uuid.Parse(unitID)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "ID inválido",
			Code:  "INVALID_UUID",
		})
		return
	}

	// Mock: actualizar unidad
	c.JSON(http.StatusOK, models.UnitResponse{
		ID:        parsedID,
		SchoolID:  uuid.MustParse("11111111-1111-1111-1111-111111111111"),
		UnitType:  "section",
		Name:      req.Name,
		Code:      req.Code,
		Metadata:  req.Metadata,
		CreatedAt: time.Now().AddDate(0, -1, 0),
	})
}

// AddUnitMember godoc
// @Summary      Asignar miembro a unidad
// @Description  Asigna un usuario a una unidad académica con un rol específico
// @Tags         Unidades Académicas
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        unitId path string true "ID de la unidad" format(uuid)
// @Param        request body models.AddMemberRequest true "Datos del miembro"
// @Success      201 {object} models.MembershipResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      404 {object} models.ErrorResponse
// @Router       /v1/units/{unitId}/members [post]
func (h *UnitsHandler) AddUnitMember(c *gin.Context) {
	unitID := c.Param("unitId")
	var req models.AddMemberRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "Datos de entrada inválidos",
			Code:  "INVALID_INPUT",
		})
		return
	}

	parsedUnitID, err := uuid.Parse(unitID)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "ID de unidad inválido",
			Code:  "INVALID_UUID",
		})
		return
	}

	// Mock: crear membresía
	membershipID := uuid.New()

	c.JSON(http.StatusCreated, models.MembershipResponse{
		ID:         membershipID,
		UnitID:     parsedUnitID,
		UserID:     req.UserID,
		UnitRole:   req.UnitRole,
		Status:     "active",
		AssignedAt: time.Now(),
	})
}
