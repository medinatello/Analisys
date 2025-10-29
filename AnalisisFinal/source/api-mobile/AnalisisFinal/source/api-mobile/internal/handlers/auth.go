package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// LoginRequest representa la petición de login
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email" example:"maria@example.com"`
	Password string `json:"password" binding:"required" example:"password123"`
} // @name LoginRequest

// LoginResponse representa la respuesta de login
type LoginResponse struct {
	Token        string `json:"token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	RefreshToken string `json:"refresh_token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	ExpiresAt    string `json:"expires_at" example:"2025-01-29T12:00:00Z"`
	User         gin.H  `json:"user"`
} // @name LoginResponse

// Login godoc
// @Summary Autenticar usuario
// @Description Genera JWT token tras validar credenciales
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body LoginRequest true "Credenciales de usuario"
// @Success 200 {object} LoginResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 401 {object} response.ErrorResponse "Credenciales inválidas"
// @Router /auth/login [post]
func Login(c *gin.Context) {
	var req LoginRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request", "message": err.Error()})
		return
	}

	// TODO: Validar credenciales en PostgreSQL
	// TODO: Generar JWT token real
	// TODO: Generar refresh token

	// Mock response
	mockToken := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock.token"

	c.JSON(http.StatusOK, LoginResponse{
		Token:        mockToken,
		RefreshToken: mockToken + ".refresh",
		ExpiresAt:    time.Now().Add(15 * time.Minute).Format(time.RFC3339),
		User: gin.H{
			"id":    "user-uuid-123",
			"name":  "María González",
			"email": req.Email,
			"role":  "teacher",
		},
	})
}
