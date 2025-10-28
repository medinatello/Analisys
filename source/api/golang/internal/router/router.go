package router

import (
	"github.com/edugo/api/internal/handlers"
	"github.com/edugo/api/internal/middleware"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// SetupRouter configura todas las rutas de la API
func SetupRouter(jwtSecret string) *gin.Engine {
	router := gin.Default()

	// Middleware CORS
	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// Swagger documentation
	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "ok",
			"service": "edugo-api",
		})
	})

	// Inicializar handlers
	authHandler := handlers.NewAuthHandler(jwtSecret)
	usersHandler := handlers.NewUsersHandler()
	unitsHandler := handlers.NewUnitsHandler()
	materialsHandler := handlers.NewMaterialsHandler()

	// Grupo de rutas API v1
	v1 := router.Group("/api/v1")
	{
		// Rutas de autenticación (públicas)
		auth := v1.Group("/auth")
		{
			auth.POST("/login", authHandler.Login)
		}

		// Rutas protegidas (requieren autenticación)
		authMiddleware := middleware.AuthMiddleware(jwtSecret)

		// Usuarios
		users := v1.Group("/users")
		users.Use(authMiddleware)
		{
			// Solo administradores pueden crear usuarios
			users.POST("", middleware.RoleMiddleware("admin"), usersHandler.CreateUser)
		}

		// Unidades académicas
		units := v1.Group("/units")
		units.Use(authMiddleware)
		{
			units.GET("", unitsHandler.ListUnits)
			units.POST("", middleware.RoleMiddleware("admin", "teacher"), unitsHandler.CreateUnit)
			units.PATCH("/:unitId", middleware.RoleMiddleware("admin", "teacher"), unitsHandler.UpdateUnit)
			units.POST("/:unitId/members", middleware.RoleMiddleware("admin", "teacher"), unitsHandler.AddUnitMember)
		}

		// Materiales educativos
		materials := v1.Group("/materials")
		materials.Use(authMiddleware)
		{
			materials.GET("", materialsHandler.ListMaterials)
			materials.POST("", middleware.RoleMiddleware("teacher", "admin"), materialsHandler.CreateMaterial)
			materials.GET("/:materialId", materialsHandler.GetMaterial)
			materials.PATCH("/:materialId", middleware.RoleMiddleware("teacher", "admin"), materialsHandler.UpdateMaterial)
			materials.GET("/:materialId/summary", materialsHandler.GetMaterialSummary)
			materials.GET("/:materialId/assessment", materialsHandler.GetMaterialAssessment)
			materials.POST("/:materialId/assessment/attempts", middleware.RoleMiddleware("student"), materialsHandler.CreateAssessmentAttempt)
		}
	}

	return router
}
