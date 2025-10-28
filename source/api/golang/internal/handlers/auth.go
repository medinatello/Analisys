package handlers

import (
	"net/http"
	"time"

	"github.com/edugo/api/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// AuthHandler maneja las peticiones de autenticación
type AuthHandler struct {
	jwtSecret []byte
}

// NewAuthHandler crea un nuevo AuthHandler
func NewAuthHandler(jwtSecret string) *AuthHandler {
	return &AuthHandler{
		jwtSecret: []byte(jwtSecret),
	}
}

// Login godoc
// @Summary      Iniciar sesión
// @Description  Autentica un usuario y devuelve un token JWT
// @Tags         Autenticación
// @Accept       json
// @Produce      json
// @Param        request body models.LoginRequest true "Credenciales de login"
// @Success      200 {object} models.LoginResponse
// @Failure      400 {object} models.ErrorResponse
// @Failure      401 {object} models.ErrorResponse
// @Router       /v1/auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest

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

	// Validación mock - en producción verificar contra base de datos
	if req.Email == "" || req.Password == "" {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Error: "Credenciales inválidas",
			Code:  "INVALID_CREDENTIALS",
		})
		return
	}

	// Generar token JWT mock
	userID := uuid.New()
	expiresAt := time.Now().Add(24 * time.Hour)

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id":     userID.String(),
		"email":       req.Email,
		"system_role": "teacher", // Mock
		"exp":         expiresAt.Unix(),
	})

	tokenString, err := token.SignedString(h.jwtSecret)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Error: "Error generando token",
			Code:  "TOKEN_GENERATION_ERROR",
		})
		return
	}

	// Respuesta mock
	c.JSON(http.StatusOK, models.LoginResponse{
		Token: tokenString,
		User: models.UserResponse{
			ID:         userID,
			Email:      req.Email,
			SystemRole: "teacher",
			Status:     "active",
			CreatedAt:  time.Now(),
		},
		ExpiresAt: expiresAt,
	})
}
