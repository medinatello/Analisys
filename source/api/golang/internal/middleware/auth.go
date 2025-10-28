package middleware

import (
	"net/http"
	"strings"

	"github.com/edugo/api/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// AuthMiddleware valida el token JWT
func AuthMiddleware(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")

		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, models.ErrorResponse{
				Error: "Token de autenticación requerido",
				Code:  "UNAUTHORIZED",
			})
			c.Abort()
			return
		}

		// Extraer el token del header "Bearer {token}"
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(http.StatusUnauthorized, models.ErrorResponse{
				Error: "Formato de token inválido",
				Code:  "INVALID_TOKEN_FORMAT",
			})
			c.Abort()
			return
		}

		tokenString := parts[1]

		// Validar el token
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			// Verificar el método de firma
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrSignatureInvalid
			}
			return []byte(jwtSecret), nil
		})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, models.ErrorResponse{
				Error: "Token inválido o expirado",
				Code:  "INVALID_TOKEN",
			})
			c.Abort()
			return
		}

		// Extraer claims y guardar en el contexto
		if claims, ok := token.Claims.(jwt.MapClaims); ok {
			c.Set("user_id", claims["user_id"])
			c.Set("email", claims["email"])
			c.Set("system_role", claims["system_role"])
		}

		c.Next()
	}
}

// RoleMiddleware valida que el usuario tenga uno de los roles permitidos
func RoleMiddleware(allowedRoles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := c.Get("system_role")
		if !exists {
			c.JSON(http.StatusForbidden, models.ErrorResponse{
				Error: "No se pudo determinar el rol del usuario",
				Code:  "ROLE_NOT_FOUND",
			})
			c.Abort()
			return
		}

		role := userRole.(string)
		allowed := false
		for _, allowedRole := range allowedRoles {
			if role == allowedRole {
				allowed = true
				break
			}
		}

		if !allowed {
			c.JSON(http.StatusForbidden, models.ErrorResponse{
				Error: "Permisos insuficientes",
				Code:  "FORBIDDEN",
			})
			c.Abort()
			return
		}

		c.Next()
	}
}
