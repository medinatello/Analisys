package handlers

import (
	"net/http"
	"time"

	"github.com/edugo/api/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// UsersHandler maneja las peticiones de usuarios
type UsersHandler struct{}

// NewUsersHandler crea un nuevo UsersHandler
func NewUsersHandler() *UsersHandler {
	return &UsersHandler{}
}

// CreateUser godoc
// @Summary      Crear usuario
// @Description  Crea un nuevo usuario en el sistema (solo administradores)
// @Tags         Usuarios
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body models.CreateUserRequest true "Datos del nuevo usuario"
// @Success      201 {object} models.UserResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      401 {object} models.ErrorResponse
// @Failure      403 {object} models.ErrorResponse
// @Router       /v1/users [post]
func (h *UsersHandler) CreateUser(c *gin.Context) {
	var req models.CreateUserRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error: "Datos de entrada inválidos",
			Code:  "INVALID_INPUT",
			Details: map[string]interface{}{
				"validation_errors": err.Error(),
			},
		})
		return
	}

	// Mock: crear usuario
	userID := uuid.New()

	c.JSON(http.StatusCreated, models.UserResponse{
		ID:         userID,
		Email:      req.Email,
		SystemRole: req.SystemRole,
		Status:     "active",
		CreatedAt:  time.Now(),
	})
}
