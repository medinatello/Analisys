package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title EduGo API Administración
// @version 1.0
// @description API para operaciones CRUD y administrativas en EduGo
// @host localhost:8081
// @BasePath /v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization

func main() {
	r := gin.Default()

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy", "service": "edugo-api-admin"})
	})

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	v1 := r.Group("/v1")
	v1.Use(AdminAuthRequired())
	{
		// Users CRUD
		v1.POST("/users", CreateUser)              // POST /v1/users
		v1.PATCH("/users/:id", UpdateUser)         // PATCH /v1/users/:id
		v1.DELETE("/users/:id", DeleteUser)        // DELETE /v1/users/:id

		// Units (Jerarquía Académica)
		v1.POST("/schools", CreateSchool)          // POST /v1/schools
		v1.POST("/units", CreateUnit)              // POST /v1/units
		v1.PATCH("/units/:id", UpdateUnit)         // PATCH /v1/units/:id
		v1.POST("/units/:id/members", AssignMembership) // POST /v1/units/:id/members

		// Subjects
		v1.POST("/subjects", CreateSubject)        // POST /v1/subjects

		// Materials Admin
		v1.DELETE("/materials/:id", DeleteMaterial) // DELETE /v1/materials/:id

		// Stats
		v1.GET("/stats/global", GetGlobalStats)     // GET /v1/stats/global
	}

	log.Println("🔧 API Administración running on :8081")
	log.Println("📚 Swagger: http://localhost:8081/swagger/index.html")
	r.Run(":8081")
}

// Middleware Admin
func AdminAuthRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		// TODO: Validar JWT y verificar role = admin
		c.Set("admin_id", "admin-mock")
		c.Next()
	}
}

// Mock handlers con Swagger annotations

// CreateUser godoc
// @Summary Crear usuario
// @Description Crear nuevo usuario con rol y perfil
// @Tags Users
// @Accept json
// @Produce json
// @Param body body map[string]interface{} true "Datos del usuario"
// @Security BearerAuth
// @Success 201 {object} map[string]interface{}
// @Router /users [post]
func CreateUser(c *gin.Context) {
	c.JSON(http.StatusCreated, gin.H{"user_id": "mock-uuid", "message": "Usuario creado"})
}

// UpdateUser godoc
// @Summary Actualizar usuario
// @Tags Users
// @Security BearerAuth
// @Router /users/{id} [patch]
func UpdateUser(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "Usuario actualizado"})
}

// DeleteUser godoc
// @Summary Eliminar usuario
// @Tags Users
// @Security BearerAuth
// @Router /users/{id} [delete]
func DeleteUser(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "Usuario eliminado"})
}

// CreateSchool godoc
// @Summary Crear escuela
// @Tags Schools
// @Security BearerAuth
// @Router /schools [post]
func CreateSchool(c *gin.Context) {
	c.JSON(http.StatusCreated, gin.H{"school_id": "mock-uuid"})
}

// CreateUnit godoc
// @Summary Crear unidad académica
// @Tags Units
// @Security BearerAuth
// @Router /units [post]
func CreateUnit(c *gin.Context) {
	c.JSON(http.StatusCreated, gin.H{"unit_id": "mock-uuid"})
}

// UpdateUnit godoc
// @Summary Actualizar unidad
// @Tags Units
// @Security BearerAuth
// @Router /units/{id} [patch]
func UpdateUnit(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "Unidad actualizada"})
}

// AssignMembership godoc
// @Summary Asignar membresía
// @Tags Units
// @Security BearerAuth
// @Router /units/{id}/members [post]
func AssignMembership(c *gin.Context) {
	c.JSON(http.StatusCreated, gin.H{"message": "Membresía asignada"})
}

// CreateSubject godoc
// @Summary Crear materia
// @Tags Subjects
// @Security BearerAuth
// @Router /subjects [post]
func CreateSubject(c *gin.Context) {
	c.JSON(http.StatusCreated, gin.H{"subject_id": "mock-uuid"})
}

// DeleteMaterial godoc
// @Summary Eliminar material
// @Tags Materials
// @Security BearerAuth
// @Router /materials/{id} [delete]
func DeleteMaterial(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "Material eliminado, limpieza en proceso"})
}

// GetGlobalStats godoc
// @Summary Estadísticas globales
// @Tags Stats
// @Security BearerAuth
// @Router /stats/global [get]
func GetGlobalStats(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"total_users": 1250,
		"total_materials": 450,
		"active_users_30d": 980,
	})
}
