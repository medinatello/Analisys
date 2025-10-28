package main

import (
	"log"
	"os"

	_ "github.com/edugo/api/docs" // Importar documentación generada por swag
	"github.com/edugo/api/internal/router"
)

// @title           EduGo API
// @version         1.0
// @description     API REST para el sistema de gestión académica EduGo
// @description
// @description     ## Autenticación
// @description     La mayoría de los endpoints requieren autenticación mediante JWT.
// @description
// @description     Para autenticarte:
// @description     1. Llama a `POST /api/v1/auth/login` con tu email y contraseña
// @description     2. Usa el token devuelto en el header `Authorization: Bearer {token}`
// @description
// @description     ## Roles
// @description     - **admin**: Acceso completo al sistema
// @description     - **teacher**: Gestión de materiales y unidades
// @description     - **student**: Lectura de materiales y realización de evaluaciones
// @description     - **guardian**: Visualización del progreso de estudiantes

// @contact.name   EduGo API Support
// @contact.email  api@edugo.com

// @license.name  MIT
// @license.url   https://opensource.org/licenses/MIT

// @host      localhost:8080
// @BasePath  /api

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Token JWT. Formato: "Bearer {token}"

func main() {
	// Configuración
	jwtSecret := getEnv("JWT_SECRET", "edugo-secret-key-change-in-production")
	port := getEnv("PORT", "8080")

	log.Println("🚀 Iniciando servidor EduGo API...")
	log.Printf("📝 Documentación Swagger disponible en: http://localhost:%s/swagger/index.html", port)

	// Configurar router
	r := router.SetupRouter(jwtSecret)

	// Iniciar servidor
	log.Printf("🌐 Servidor escuchando en puerto %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("❌ Error iniciando servidor: %v", err)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
