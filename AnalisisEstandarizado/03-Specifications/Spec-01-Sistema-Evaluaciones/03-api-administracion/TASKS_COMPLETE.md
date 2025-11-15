# 📋 Tareas - edugo-api-administracion - Sistema de Evaluaciones (COMPLETO)

## 📍 Información del Proyecto
- **Repositorio**: edugo-api-administracion
- **Branch**: feature/evaluation-management
- **Dependencia**: edugo-shared v1.3.0 (DEBE estar publicado primero)
- **Tiempo Estimado**: 3 días (24 horas)
- **Path de trabajo**: `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion`
- **Puerto**: 8081

## ✅ Pre-requisitos
```bash
# Verificar que shared v1.3.0 está disponible
go list -m github.com/EduGoGroup/edugo-shared@v1.3.0
# Si no está disponible, DETENER y esperar a que se publique

# Navegar al proyecto
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Verificar estado
git status
go version  # Debe ser >= 1.21

# Crear branch de trabajo
git checkout main
git pull origin main
git checkout -b feature/evaluation-management
```

---

### TASK-005: Implementar handlers administrativos
**Tipo**: feature  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:

```go
// internal/evaluation/handlers/admin_evaluation_handler.go
package handlers

import (
    "net/http"
    "strconv"
    
    "github.com/gin-gonic/gin"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/dto"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/services"
    "github.com/EduGoGroup/edugo-api-administracion/internal/middleware"
)

// AdminEvaluationHandler maneja endpoints administrativos
type AdminEvaluationHandler struct {
    service *services.AdminEvaluationService
}

// NewAdminEvaluationHandler crea nueva instancia
func NewAdminEvaluationHandler(service *services.AdminEvaluationService) *AdminEvaluationHandler {
    return &AdminEvaluationHandler{
        service: service,
    }
}

// CreateEvaluation godoc
// @Summary Crear nueva evaluación
// @Description Crea una nueva evaluación con preguntas
// @Tags admin-evaluations
// @Accept json
// @Produce json
// @Param body body dto.CreateEvaluationRequest true "Datos de evaluación"
// @Success 201 {object} dto.AdminEvaluationResponse
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Router /admin/evaluations [post]
func (h *AdminEvaluationHandler) CreateEvaluation(c *gin.Context) {
    userID, _ := c.Get("userID")
    createdBy := userID.(uint)
    
    var req dto.CreateEvaluationRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    evaluation, err := h.service.CreateEvaluation(c.Request.Context(), req, createdBy)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusCreated, evaluation)
}

// UpdateEvaluation godoc
// @Summary Actualizar evaluación
// @Description Actualiza una evaluación existente
// @Tags admin-evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de evaluación"
// @Param body body dto.UpdateEvaluationRequest true "Datos a actualizar"
// @Success 200 {object} map[string]string
// @Failure 400 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Router /admin/evaluations/{id} [put]
func (h *AdminEvaluationHandler) UpdateEvaluation(c *gin.Context) {
    userID, _ := c.Get("userID")
    updatedBy := userID.(uint)
    
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID"})
        return
    }
    
    var req dto.UpdateEvaluationRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    if err := h.service.UpdateEvaluation(c.Request.Context(), uint(evaluationID), req, updatedBy); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusOK, gin.H{"message": "evaluation updated successfully"})
}

// DeleteEvaluation godoc
// @Summary Eliminar evaluación
// @Description Elimina una evaluación (soft o hard delete)
// @Tags admin-evaluations
// @Param id path int true "ID de evaluación"
// @Param hard query bool false "Hard delete"
// @Success 200 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Router /admin/evaluations/{id} [delete]
func (h *AdminEvaluationHandler) DeleteEvaluation(c *gin.Context) {
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID"})
        return
    }
    
    hardDelete := c.DefaultQuery("hard", "false") == "true"
    
    if err := h.service.DeleteEvaluation(c.Request.Context(), uint(evaluationID), hardDelete); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusOK, gin.H{"message": "evaluation deleted successfully"})
}

// GetEvaluation godoc
// @Summary Obtener evaluación
// @Description Obtiene detalles completos de una evaluación
// @Tags admin-evaluations
// @Produce json
// @Param id path int true "ID de evaluación"
// @Param include_stats query bool false "Incluir estadísticas"
// @Success 200 {object} dto.AdminEvaluationResponse
// @Failure 404 {object} map[string]string
// @Router /admin/evaluations/{id} [get]
func (h *AdminEvaluationHandler) GetEvaluation(c *gin.Context) {
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID"})
        return
    }
    
    includeStats := c.DefaultQuery("include_stats", "false") == "true"
    
    evaluation, err := h.service.GetEvaluation(c.Request.Context(), uint(evaluationID), includeStats)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "evaluation not found"})
        return
    }
    
    c.JSON(http.StatusOK, evaluation)
}

// ListEvaluations godoc
// @Summary Listar evaluaciones
// @Description Lista evaluaciones con filtros avanzados
// @Tags admin-evaluations
// @Produce json
// @Param subject_id query int false "ID de materia"
// @Param status query string false "Estado"
// @Param search query string false "Búsqueda"
// @Param page query int false "Página" default(1)
// @Param page_size query int false "Tamaño" default(20)
// @Success 200 {object} map[string]interface{}
// @Router /admin/evaluations [get]
func (h *AdminEvaluationHandler) ListEvaluations(c *gin.Context) {
    var req dto.ListEvaluationsRequest
    if err := c.ShouldBindQuery(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    evaluations, total, err := h.service.ListEvaluations(c.Request.Context(), req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    totalPages := (int(total) + req.PageSize - 1) / req.PageSize
    
    c.JSON(http.StatusOK, gin.H{
        "data": evaluations,
        "meta": gin.H{
            "total":       total,
            "page":        req.Page,
            "page_size":   req.PageSize,
            "total_pages": totalPages,
        },
    })
}

// AddQuestions godoc
// @Summary Agregar preguntas
// @Description Agrega preguntas a una evaluación existente
// @Tags admin-evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de evaluación"
// @Param body body dto.BulkCreateQuestionsRequest true "Preguntas"
// @Success 201 {object} map[string]interface{}
// @Router /admin/evaluations/{id}/questions [post]
func (h *AdminEvaluationHandler) AddQuestions(c *gin.Context) {
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID"})
        return
    }
    
    var req dto.BulkCreateQuestionsRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    // TODO: Implementar en servicio
    c.JSON(http.StatusCreated, gin.H{
        "message": "questions added successfully",
        "count":   len(req.Questions),
    })
}

// GetResults godoc
// @Summary Obtener resultados
// @Description Obtiene todos los resultados de una evaluación
// @Tags admin-evaluations
// @Produce json
// @Param id path int true "ID de evaluación"
// @Success 200 {object} dto.EvaluationResultsResponse
// @Router /admin/evaluations/{id}/results [get]
func (h *AdminEvaluationHandler) GetResults(c *gin.Context) {
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID"})
        return
    }
    
    results, err := h.service.GetEvaluationResults(c.Request.Context(), uint(evaluationID))
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusOK, results)
}

// GenerateWithAI godoc
// @Summary Generar con IA
// @Description Genera preguntas usando inteligencia artificial
// @Tags admin-evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de evaluación"
// @Param body body dto.GenerateWithAIRequest true "Parámetros de generación"
// @Success 200 {object} dto.GenerateAIResponse
// @Router /admin/evaluations/{id}/generate-ai [post]
func (h *AdminEvaluationHandler) GenerateWithAI(c *gin.Context) {
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID"})
        return
    }
    
    var req dto.GenerateWithAIRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    response, err := h.service.GenerateWithAI(c.Request.Context(), uint(evaluationID), req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusOK, response)
}

// CloneEvaluation godoc
// @Summary Clonar evaluación
// @Description Duplica una evaluación existente
// @Tags admin-evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de evaluación"
// @Param body body dto.CloneEvaluationRequest true "Parámetros de clonación"
// @Success 201 {object} dto.CloneResponse
// @Router /admin/evaluations/{id}/clone [post]
func (h *AdminEvaluationHandler) CloneEvaluation(c *gin.Context) {
    userID, _ := c.Get("userID")
    createdBy := userID.(uint)
    
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID"})
        return
    }
    
    var req dto.CloneEvaluationRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    response, err := h.service.CloneEvaluation(c.Request.Context(), uint(evaluationID), req, createdBy)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusCreated, response)
}

// PublishEvaluation godoc
// @Summary Publicar evaluación
// @Description Publica una evaluación para estudiantes
// @Tags admin-evaluations
// @Accept json
// @Produce json
// @Param id path int true "ID de evaluación"
// @Param body body dto.PublishEvaluationRequest true "Opciones de publicación"
// @Success 200 {object} map[string]string
// @Router /admin/evaluations/{id}/publish [post]
func (h *AdminEvaluationHandler) PublishEvaluation(c *gin.Context) {
    evaluationID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID"})
        return
    }
    
    var req dto.PublishEvaluationRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    if err := h.service.PublishEvaluation(c.Request.Context(), uint(evaluationID), req); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusOK, gin.H{"message": "evaluation published successfully"})
}

// BatchOperation godoc
// @Summary Operación en lote
// @Description Ejecuta operación en múltiples evaluaciones
// @Tags admin-evaluations
// @Accept json
// @Produce json
// @Param body body dto.BatchUpdateRequest true "Operación en lote"
// @Success 200 {object} dto.BatchOperationResponse
// @Router /admin/evaluations/batch [post]
func (h *AdminEvaluationHandler) BatchOperation(c *gin.Context) {
    var req dto.BatchUpdateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    response, err := h.service.BatchOperation(c.Request.Context(), req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusOK, response)
}
```

#### Criterios de Aceptación:
- [ ] Todos los endpoints administrativos implementados
- [ ] Documentación Swagger completa
- [ ] Validación de permisos
- [ ] Manejo de errores apropiado

---

### TASK-006: Configurar rutas administrativas
**Tipo**: config  
**Prioridad**: HIGH  
**Estimación**: 1h  

#### Implementación:

```go
// internal/routes/admin_evaluation_routes.go
package routes

import (
    "github.com/gin-gonic/gin"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/handlers"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/services"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/repositories"
    "github.com/EduGoGroup/edugo-api-administracion/internal/middleware"
    "github.com/EduGoGroup/edugo-shared/pkg/messaging"
)

// SetupAdminEvaluationRoutes configura rutas administrativas
func SetupAdminEvaluationRoutes(router *gin.RouterGroup, publisher messaging.Publisher) {
    // Crear instancias
    repo := repositories.NewAdminEvaluationRepository()
    service := services.NewAdminEvaluationService(repo, publisher)
    handler := handlers.NewAdminEvaluationHandler(service)
    
    // Grupo de rutas admin con autenticación
    admin := router.Group("/admin/evaluations")
    admin.Use(middleware.AuthMiddleware())
    admin.Use(middleware.AdminOnly()) // Solo administradores
    {
        // CRUD principal
        admin.POST("", handler.CreateEvaluation)
        admin.GET("", handler.ListEvaluations)
        admin.GET("/:id", handler.GetEvaluation)
        admin.PUT("/:id", handler.UpdateEvaluation)
        admin.DELETE("/:id", handler.DeleteEvaluation)
        
        // Gestión de preguntas
        admin.POST("/:id/questions", handler.AddQuestions)
        
        // Resultados y estadísticas
        admin.GET("/:id/results", handler.GetResults)
        admin.GET("/:id/statistics", handler.GetStatistics)
        admin.GET("/:id/reports", handler.GenerateReport)
        
        // Operaciones especiales
        admin.POST("/:id/clone", handler.CloneEvaluation)
        admin.POST("/:id/publish", handler.PublishEvaluation)
        admin.POST("/:id/generate-ai", handler.GenerateWithAI)
        
        // Operaciones en lote
        admin.POST("/batch", handler.BatchOperation)
        
        // Import/Export
        admin.POST("/import", handler.ImportQuestions)
        admin.GET("/:id/export", handler.ExportEvaluation)
    }
}
```

Agregar middleware de autorización:

```go
// internal/middleware/admin_middleware.go
package middleware

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

// AdminOnly permite acceso solo a administradores
func AdminOnly() gin.HandlerFunc {
    return func(c *gin.Context) {
        role, exists := c.Get("userRole")
        if !exists {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "role not found"})
            c.Abort()
            return
        }
        
        if role != "admin" && role != "super_admin" && role != "school_admin" {
            c.JSON(http.StatusForbidden, gin.H{"error": "admin access required"})
            c.Abort()
            return
        }
        
        c.Next()
    }
}

// SuperAdminOnly permite acceso solo a super administradores
func SuperAdminOnly() gin.HandlerFunc {
    return func(c *gin.Context) {
        role, exists := c.Get("userRole")
        if !exists {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "role not found"})
            c.Abort()
            return
        }
        
        if role != "super_admin" {
            c.JSON(http.StatusForbidden, gin.H{"error": "super admin access required"})
            c.Abort()
            return
        }
        
        c.Next()
    }
}
```

#### Criterios de Aceptación:
- [ ] Todas las rutas configuradas
- [ ] Middleware de autorización aplicado
- [ ] Grupos de rutas organizados
- [ ] Integración con publisher de eventos

---

### TASK-007: Implementar validadores
**Tipo**: feature  
**Prioridad**: MEDIUM  
**Estimación**: 2h  

#### Implementación:

```go
// internal/evaluation/validators/evaluation_validator.go
package validators

import (
    "fmt"
    "strings"
    "time"
    
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/dto"
)

// EvaluationValidator valida evaluaciones
type EvaluationValidator struct{}

// NewEvaluationValidator crea nueva instancia
func NewEvaluationValidator() *EvaluationValidator {
    return &EvaluationValidator{}
}

// ValidateCreateRequest valida creación
func (v *EvaluationValidator) ValidateCreateRequest(req dto.CreateEvaluationRequest) error {
    // Validar título
    if len(req.Title) < 3 || len(req.Title) > 255 {
        return fmt.Errorf("title must be between 3 and 255 characters")
    }
    
    // Validar duración
    if req.DurationMinutes < 1 || req.DurationMinutes > 480 {
        return fmt.Errorf("duration must be between 1 and 480 minutes")
    }
    
    // Validar puntaje de aprobación
    if req.PassingScore < 0 || req.PassingScore > 100 {
        return fmt.Errorf("passing score must be between 0 and 100")
    }
    
    // Validar intentos máximos
    if req.MaxAttempts < 1 || req.MaxAttempts > 10 {
        return fmt.Errorf("max attempts must be between 1 and 10")
    }
    
    // Validar fechas si existen
    if req.PublishDate != nil && req.ExpirationDate != nil {
        if req.PublishDate.After(*req.ExpirationDate) {
            return fmt.Errorf("publish date cannot be after expiration date")
        }
    }
    
    // Validar preguntas
    if len(req.Questions) == 0 {
        return fmt.Errorf("at least one question is required")
    }
    
    totalPoints := 0.0
    for i, q := range req.Questions {
        if err := v.ValidateQuestion(q); err != nil {
            return fmt.Errorf("question %d: %w", i+1, err)
        }
        totalPoints += q.Points
    }
    
    // Validar que el puntaje total permite aprobar
    if totalPoints < req.PassingScore {
        return fmt.Errorf("total points (%.2f) must be >= passing score (%.2f)", 
            totalPoints, req.PassingScore)
    }
    
    return nil
}

// ValidateQuestion valida una pregunta
func (v *EvaluationValidator) ValidateQuestion(question dto.CreateQuestionRequest) error {
    // Validar texto
    question.QuestionText = strings.TrimSpace(question.QuestionText)
    if question.QuestionText == "" {
        return fmt.Errorf("question text is required")
    }
    
    if len(question.QuestionText) > 5000 {
        return fmt.Errorf("question text exceeds 5000 characters")
    }
    
    // Validar tipo
    if !question.QuestionType.IsValid() {
        return fmt.Errorf("invalid question type: %s", question.QuestionType)
    }
    
    // Validar puntos
    if question.Points < 0 || question.Points > 100 {
        return fmt.Errorf("points must be between 0 and 100")
    }
    
    // Validar nivel de dificultad si existe
    if question.DifficultyLevel != "" {
        validLevels := []string{"easy", "medium", "hard"}
        valid := false
        for _, level := range validLevels {
            if question.DifficultyLevel == level {
                valid = true
                break
            }
        }
        if !valid {
            return fmt.Errorf("invalid difficulty level: %s", question.DifficultyLevel)
        }
    }
    
    // Validar opciones según tipo
    if question.QuestionType.RequiresOptions() {
        if len(question.Options) < 2 {
            return fmt.Errorf("question type %s requires at least 2 options", question.QuestionType)
        }
        
        if len(question.Options) > 10 {
            return fmt.Errorf("maximum 10 options allowed")
        }
        
        // Validar que hay al menos una opción correcta
        hasCorrect := false
        for _, opt := range question.Options {
            if opt.OptionText == "" {
                return fmt.Errorf("option text cannot be empty")
            }
            if opt.IsCorrect {
                hasCorrect = true
            }
        }
        
        if !hasCorrect && question.QuestionType == evaluation.QuestionTypeMultipleChoice {
            return fmt.Errorf("at least one correct option is required")
        }
        
        // Para verdadero/falso, validar exactamente 2 opciones
        if question.QuestionType == evaluation.QuestionTypeTrueFalse {
            if len(question.Options) != 2 {
                return fmt.Errorf("true/false questions must have exactly 2 options")
            }
            
            // Validar que una es verdadero y otra falso
            hasTrue := false
            hasFalse := false
            for _, opt := range question.Options {
                optLower := strings.ToLower(opt.OptionText)
                if strings.Contains(optLower, "true") || strings.Contains(optLower, "verdadero") {
                    hasTrue = true
                }
                if strings.Contains(optLower, "false") || strings.Contains(optLower, "falso") {
                    hasFalse = true
                }
            }
            
            if !hasTrue || !hasFalse {
                return fmt.Errorf("true/false question must have true and false options")
            }
        }
    }
    
    return nil
}

// ValidateUpdateRequest valida actualización
func (v *EvaluationValidator) ValidateUpdateRequest(req dto.UpdateEvaluationRequest) error {
    // Validar solo campos presentes
    if req.Title != nil {
        if len(*req.Title) < 3 || len(*req.Title) > 255 {
            return fmt.Errorf("title must be between 3 and 255 characters")
        }
    }
    
    if req.DurationMinutes != nil {
        if *req.DurationMinutes < 1 || *req.DurationMinutes > 480 {
            return fmt.Errorf("duration must be between 1 and 480 minutes")
        }
    }
    
    if req.PassingScore != nil {
        if *req.PassingScore < 0 || *req.PassingScore > 100 {
            return fmt.Errorf("passing score must be between 0 and 100")
        }
    }
    
    if req.MaxAttempts != nil {
        if *req.MaxAttempts < 1 || *req.MaxAttempts > 10 {
            return fmt.Errorf("max attempts must be between 1 and 10")
        }
    }
    
    return nil
}

// ValidateGenerateAIRequest valida request de generación IA
func (v *EvaluationValidator) ValidateGenerateAIRequest(req dto.GenerateWithAIRequest) error {
    // Validar cantidad de preguntas
    if req.QuestionCount < 1 || req.QuestionCount > 50 {
        return fmt.Errorf("question count must be between 1 and 50")
    }
    
    // Validar que hay contenido o material
    if req.MaterialID == nil && req.Content == "" {
        return fmt.Errorf("either material_id or content is required")
    }
    
    // Validar nivel de dificultad
    validLevels := []string{"easy", "medium", "hard", "mixed"}
    valid := false
    for _, level := range validLevels {
        if req.DifficultyLevel == level {
            valid = true
            break
        }
    }
    if !valid {
        return fmt.Errorf("invalid difficulty level: %s", req.DifficultyLevel)
    }
    
    // Validar tipos de pregunta si se especifican
    if len(req.QuestionTypes) > 0 {
        for _, qType := range req.QuestionTypes {
            if !evaluation.QuestionType(qType).IsValid() {
                return fmt.Errorf("invalid question type: %s", qType)
            }
        }
    }
    
    // Validar idioma si se especifica
    if req.Language != "" {
        validLangs := []string{"es", "en", "pt"}
        valid := false
        for _, lang := range validLangs {
            if req.Language == lang {
                valid = true
                break
            }
        }
        if !valid {
            return fmt.Errorf("invalid language: %s", req.Language)
        }
    }
    
    return nil
}

// ValidateBatchOperation valida operación en lote
func (v *EvaluationValidator) ValidateBatchOperation(req dto.BatchUpdateRequest) error {
    if len(req.EvaluationIDs) == 0 {
        return fmt.Errorf("at least one evaluation ID is required")
    }
    
    if len(req.EvaluationIDs) > 100 {
        return fmt.Errorf("maximum 100 evaluations in batch operation")
    }
    
    validActions := []string{"publish", "unpublish", "archive", "delete"}
    valid := false
    for _, action := range validActions {
        if req.Action == action {
            valid = true
            break
        }
    }
    
    if !valid {
        return fmt.Errorf("invalid action: %s", req.Action)
    }
    
    return nil
}

// ValidateImportRequest valida importación
func (v *EvaluationValidator) ValidateImportRequest(req dto.ImportQuestionsRequest) error {
    validFormats := []string{"csv", "json", "excel"}
    valid := false
    for _, format := range validFormats {
        if req.Format == format {
            valid = true
            break
        }
    }
    
    if !valid {
        return fmt.Errorf("invalid format: %s", req.Format)
    }
    
    if req.FileData == "" {
        return fmt.Errorf("file data is required")
    }
    
    // Validar que es base64 válido
    // TODO: Implementar validación base64
    
    return nil
}

// Helper functions

// IsValidStatus verifica si el estado es válido
func IsValidStatus(status string) bool {
    validStatuses := []string{"draft", "published", "archived", "deleted"}
    for _, s := range validStatuses {
        if status == s {
            return true
        }
    }
    return false
}

// IsValidSortField verifica si el campo de ordenamiento es válido
func IsValidSortField(field string) bool {
    validFields := []string{"created_at", "updated_at", "title", "status", "passing_score"}
    for _, f := range validFields {
        if field == f {
            return true
        }
    }
    return false
}

// ValidateDateRange valida rango de fechas
func ValidateDateRange(from, to *time.Time) error {
    if from != nil && to != nil {
        if from.After(*to) {
            return fmt.Errorf("date_from cannot be after date_to")
        }
        
        // Validar que el rango no sea mayor a 1 año
        diff := to.Sub(*from)
        if diff.Hours() > 365*24 {
            return fmt.Errorf("date range cannot exceed 1 year")
        }
    }
    
    return nil
}
```

#### Criterios de Aceptación:
- [ ] Validaciones completas para todos los DTOs
- [ ] Validación de lógica de negocio
- [ ] Mensajes de error claros
- [ ] Funciones helper útiles

---

### TASK-008: Implementar tests administrativos
**Tipo**: test  
**Prioridad**: HIGH  
**Estimación**: 3h  

#### Implementación:

```go
// internal/evaluation/tests/admin_evaluation_test.go
package tests

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
    
    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/dto"
    "github.com/EduGoGroup/edugo-api-administracion/internal/evaluation/handlers"
    "github.com/EduGoGroup/edugo-shared/pkg/evaluation"
)

// MockAdminService para tests
type MockAdminService struct {
    mock.Mock
}

func (m *MockAdminService) CreateEvaluation(ctx context.Context, req dto.CreateEvaluationRequest, createdBy uint) (*dto.AdminEvaluationResponse, error) {
    args := m.Called(ctx, req, createdBy)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*dto.AdminEvaluationResponse), args.Error(1)
}

// Implementar todos los métodos del mock...

func TestCreateEvaluation_Success(t *testing.T) {
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockAdminService)
    handler := handlers.NewAdminEvaluationHandler(mockService)
    
    router.POST("/admin/evaluations", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "admin")
        handler.CreateEvaluation(c)
    })
    
    req := dto.CreateEvaluationRequest{
        Title:           "Test Evaluation",
        Description:     "Test Description",
        DurationMinutes: 60,
        PassingScore:    60,
        MaxAttempts:     2,
        Questions: []dto.CreateQuestionRequest{
            {
                QuestionText: "Test Question",
                QuestionType: evaluation.QuestionTypeMultipleChoice,
                Points:       10,
                Options: []dto.CreateOptionRequest{
                    {OptionText: "Option A", IsCorrect: true},
                    {OptionText: "Option B", IsCorrect: false},
                },
            },
        },
    }
    
    expectedResponse := &dto.AdminEvaluationResponse{
        ID:    1,
        Title: "Test Evaluation",
    }
    
    mockService.On("CreateEvaluation", mock.Anything, mock.MatchedBy(func(r dto.CreateEvaluationRequest) bool {
        return r.Title == req.Title
    }), uint(1)).Return(expectedResponse, nil)
    
    body, _ := json.Marshal(req)
    w := httptest.NewRecorder()
    request, _ := http.NewRequest("POST", "/admin/evaluations", bytes.NewBuffer(body))
    request.Header.Set("Content-Type", "application/json")
    router.ServeHTTP(w, request)
    
    assert.Equal(t, http.StatusCreated, w.Code)
    
    var response dto.AdminEvaluationResponse
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.Equal(t, uint(1), response.ID)
    
    mockService.AssertExpectations(t)
}

func TestCreateEvaluation_ValidationError(t *testing.T) {
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockAdminService)
    handler := handlers.NewAdminEvaluationHandler(mockService)
    
    router.POST("/admin/evaluations", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "admin")
        handler.CreateEvaluation(c)
    })
    
    // Request inválido - sin título
    req := dto.CreateEvaluationRequest{
        Title: "", // Título vacío
    }
    
    body, _ := json.Marshal(req)
    w := httptest.NewRecorder()
    request, _ := http.NewRequest("POST", "/admin/evaluations", bytes.NewBuffer(body))
    request.Header.Set("Content-Type", "application/json")
    router.ServeHTTP(w, request)
    
    assert.Equal(t, http.StatusBadRequest, w.Code)
    mockService.AssertNotCalled(t, "CreateEvaluation")
}

func TestGenerateWithAI(t *testing.T) {
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockAdminService)
    handler := handlers.NewAdminEvaluationHandler(mockService)
    
    router.POST("/admin/evaluations/:id/generate-ai", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "admin")
        handler.GenerateWithAI(c)
    })
    
    req := dto.GenerateWithAIRequest{
        QuestionCount:   10,
        DifficultyLevel: "medium",
        Language:        "es",
    }
    
    expectedResponse := &dto.GenerateAIResponse{
        Success:        true,
        GeneratedCount: 10,
        AIModel:        "gpt-4",
    }
    
    mockService.On("GenerateWithAI", mock.Anything, uint(1), mock.MatchedBy(func(r dto.GenerateWithAIRequest) bool {
        return r.QuestionCount == 10
    })).Return(expectedResponse, nil)
    
    body, _ := json.Marshal(req)
    w := httptest.NewRecorder()
    request, _ := http.NewRequest("POST", "/admin/evaluations/1/generate-ai", bytes.NewBuffer(body))
    request.Header.Set("Content-Type", "application/json")
    router.ServeHTTP(w, request)
    
    assert.Equal(t, http.StatusOK, w.Code)
    
    var response dto.GenerateAIResponse
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.True(t, response.Success)
    assert.Equal(t, 10, response.GeneratedCount)
    
    mockService.AssertExpectations(t)
}

func TestBatchOperation(t *testing.T) {
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockAdminService)
    handler := handlers.NewAdminEvaluationHandler(mockService)
    
    router.POST("/admin/evaluations/batch", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "admin")
        handler.BatchOperation(c)
    })
    
    req := dto.BatchUpdateRequest{
        EvaluationIDs: []uint{1, 2, 3},
        Action:        "publish",
    }
    
    expectedResponse := &dto.BatchOperationResponse{
        Success:        true,
        ProcessedCount: 3,
        FailedCount:    0,
    }
    
    mockService.On("BatchOperation", mock.Anything, mock.MatchedBy(func(r dto.BatchUpdateRequest) bool {
        return len(r.EvaluationIDs) == 3 && r.Action == "publish"
    })).Return(expectedResponse, nil)
    
    body, _ := json.Marshal(req)
    w := httptest.NewRecorder()
    request, _ := http.NewRequest("POST", "/admin/evaluations/batch", bytes.NewBuffer(body))
    request.Header.Set("Content-Type", "application/json")
    router.ServeHTTP(w, request)
    
    assert.Equal(t, http.StatusOK, w.Code)
    
    var response dto.BatchOperationResponse
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.True(t, response.Success)
    assert.Equal(t, 3, response.ProcessedCount)
    
    mockService.AssertExpectations(t)
}

// Test de validadores
func TestValidateCreateRequest(t *testing.T) {
    validator := validators.NewEvaluationValidator()
    
    // Test caso válido
    validReq := dto.CreateEvaluationRequest{
        Title:           "Valid Evaluation",
        DurationMinutes: 60,
        PassingScore:    60,
        MaxAttempts:     2,
        Questions: []dto.CreateQuestionRequest{
            {
                QuestionText: "Question",
                QuestionType: evaluation.QuestionTypeMultipleChoice,
                Points:       100,
                Options: []dto.CreateOptionRequest{
                    {OptionText: "A", IsCorrect: true},
                    {OptionText: "B", IsCorrect: false},
                },
            },
        },
    }
    
    err := validator.ValidateCreateRequest(validReq)
    assert.NoError(t, err)
    
    // Test título inválido
    invalidReq := validReq
    invalidReq.Title = "ab" // Muy corto
    err = validator.ValidateCreateRequest(invalidReq)
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "title")
    
    // Test sin preguntas
    noQuestionsReq := validReq
    noQuestionsReq.Questions = []dto.CreateQuestionRequest{}
    err = validator.ValidateCreateRequest(noQuestionsReq)
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "question")
    
    // Test puntaje insuficiente
    lowPointsReq := validReq
    lowPointsReq.PassingScore = 200 // Mayor que puntos totales
    err = validator.ValidateCreateRequest(lowPointsReq)
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "points")
}

// Benchmark
func BenchmarkCreateEvaluation(b *testing.B) {
    gin.SetMode(gin.TestMode)
    router := gin.New()
    
    mockService := new(MockAdminService)
    handler := handlers.NewAdminEvaluationHandler(mockService)
    
    router.POST("/admin/evaluations", func(c *gin.Context) {
        c.Set("userID", uint(1))
        c.Set("userRole", "admin")
        handler.CreateEvaluation(c)
    })
    
    req := dto.CreateEvaluationRequest{
        Title:           "Benchmark",
        DurationMinutes: 60,
        PassingScore:    60,
        MaxAttempts:     1,
        Questions:       []dto.CreateQuestionRequest{},
    }
    
    body, _ := json.Marshal(req)
    
    mockService.On("CreateEvaluation", mock.Anything, mock.Anything, mock.Anything).
        Return(&dto.AdminEvaluationResponse{}, nil)
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        w := httptest.NewRecorder()
        request, _ := http.NewRequest("POST", "/admin/evaluations", bytes.NewBuffer(body))
        request.Header.Set("Content-Type", "application/json")
        router.ServeHTTP(w, request)
    }
}
```

#### Criterios de Aceptación:
- [ ] Tests para todos los handlers
- [ ] Tests de validación
- [ ] Tests de casos de error
- [ ] Coverage >80%
- [ ] Benchmarks incluidos

#### Validación:
```bash
go test ./internal/evaluation/... -v -cover
# Coverage debe ser >80%
```

---

### TASK-009: Documentación Swagger y API
**Tipo**: docs  
**Prioridad**: MEDIUM  
**Estimación**: 1h  

#### Implementación:

Actualizar documentación Swagger:

```bash
# Instalar swag si no está instalado
go get -u github.com/swaggo/swag/cmd/swag

# Generar documentación
swag init -g cmd/main.go --parseDependency --parseInternal

# Verificar archivos generados
ls -la docs/
```

Agregar anotaciones en main.go:

```go
// @title EduGo Admin API
// @version 1.0
// @description API administrativa para el sistema EduGo
// @description Gestión de evaluaciones, usuarios y contenido educativo

// @contact.name API Support
// @contact.email admin@edugo.com

// @host localhost:8081
// @BasePath /api/v1

// @securityDefinitions.apikey Bearer
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

// @tag.name admin-evaluations
// @tag.description Gestión administrativa de evaluaciones
```

Crear documentación de API:

```markdown
# API Documentation - Admin Evaluations

## Base URL
```
http://localhost:8081/api/v1
```

## Authentication
All endpoints require JWT Bearer token in Authorization header:
```
Authorization: Bearer <token>
```

## Endpoints

### Create Evaluation
```http
POST /admin/evaluations
Content-Type: application/json

{
  "title": "Math Final Exam",
  "description": "Final examination for Math 101",
  "duration_minutes": 120,
  "passing_score": 60,
  "max_attempts": 2,
  "questions": [...]
}
```

### List Evaluations
```http
GET /admin/evaluations?page=1&page_size=20&status=published
```

### Get Evaluation Details
```http
GET /admin/evaluations/{id}?include_stats=true
```

### Update Evaluation
```http
PUT /admin/evaluations/{id}
Content-Type: application/json

{
  "title": "Updated Title",
  "duration_minutes": 90
}
```

### Generate Questions with AI
```http
POST /admin/evaluations/{id}/generate-ai
Content-Type: application/json

{
  "question_count": 10,
  "difficulty_level": "medium",
  "language": "es"
}
```

### Batch Operations
```http
POST /admin/evaluations/batch
Content-Type: application/json

{
  "evaluation_ids": [1, 2, 3],
  "action": "publish"
}
```

## Response Codes
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Internal Server Error

## Error Response Format
```json
{
  "error": "Description of the error",
  "details": "Additional details if available"
}
```
```

#### Criterios de Aceptación:
- [ ] Swagger generado y actualizado
- [ ] Documentación de todos los endpoints
- [ ] Ejemplos de request/response
- [ ] Códigos de error documentados
- [ ] Markdown de documentación creado

---

### TASK-010: Integración final y deployment
**Tipo**: deployment  
**Prioridad**: HIGH  
**Estimación**: 1h  

#### Pasos de Implementación:
```bash
# 1. Ejecutar todos los tests
go test ./internal/evaluation/... -v -cover
# Verificar coverage >80%

# 2. Ejecutar linting
golangci-lint run ./internal/evaluation/...

# 3. Verificar build
go build -o bin/api-admin cmd/main.go

# 4. Actualizar Swagger
swag init -g cmd/main.go

# 5. Probar con Docker
docker build -t edugo-api-admin:evaluation .
docker run -p 8081:8081 \
  -e DATABASE_URL=$DATABASE_URL \
  -e RABBITMQ_URL=$RABBITMQ_URL \
  edugo-api-admin:evaluation

# 6. Verificar endpoints con curl
# Crear evaluación
curl -X POST http://localhost:8081/api/v1/admin/evaluations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Evaluation",
    "duration_minutes": 60,
    "passing_score": 60,
    "max_attempts": 2,
    "questions": []
  }'

# Listar evaluaciones
curl http://localhost:8081/api/v1/admin/evaluations \
  -H "Authorization: Bearer $TOKEN"

# 7. Crear commit
git add .
git commit -m "feat: implement admin evaluation management

- Complete admin CRUD for evaluations
- AI generation integration
- Batch operations support
- Statistics and reporting
- Tests with >80% coverage

Depends on: edugo-shared v1.3.0
Closes #XXX"

# 8. Push branch
git push origin feature/evaluation-management

# 9. Crear PR
gh pr create \
  --title "feat: admin evaluation management system" \
  --body "Complete implementation of evaluation management for administrators" \
  --base main
```

#### Criterios de Aceptación:
- [ ] Todos los tests pasando
- [ ] Sin errores de linting
- [ ] Documentación actualizada
- [ ] Docker image construido
- [ ] Endpoints verificados
- [ ] PR creado y listo para review

---

## 📊 Resumen de Tareas

| Task | Descripción | Tiempo | Estado |
|------|-------------|--------|--------|
| 001 | Actualizar dependencias | 1h | ⬜ |
| 002 | DTOs administrativos | 2h | ⬜ |
| 003 | Repositorio admin | 3h | ⬜ |
| 004 | Servicio admin | 3h | ⬜ |
| 005 | Handlers admin | 3h | ⬜ |
| 006 | Configurar rutas | 1h | ⬜ |
| 007 | Validadores | 2h | ⬜ |
| 008 | Tests admin | 3h | ⬜ |
| 009 | Documentación | 1h | ⬜ |
| 010 | Deployment | 1h | ⬜ |

**Total estimado**: 20 horas (2.5 días laborables)

## ✅ Checklist Final

Antes de marcar como completo:
- [ ] Dependencia shared v1.3.0 integrada
- [ ] 14 endpoints administrativos funcionando
- [ ] Generación con IA implementada
- [ ] Operaciones en lote funcionando
- [ ] Tests con cobertura >80%
- [ ] Documentación Swagger completa
- [ ] Sin errores de linting
- [ ] PR aprobado y mergeado

## 🚀 Siguiente Paso

Una vez completadas todas las tareas:
1. Notificar a equipo de worker
2. Actualizar tracking en TRACKING_SYSTEM.json
3. Worker puede comenzar con processors
4. Coordinar testing end-to-end

## ⚠️ Dependencias Críticas

**IMPORTANTE**: Este proyecto DEPENDE de que:
1. edugo-shared v1.3.0 esté publicado
2. api-mobile haya definido los eventos en RabbitMQ

Si no están listos:
1. DETENER trabajo
2. Esperar dependencias
3. Verificar con comandos de validación

---

**Documento generado para**: Ejecución desatendida por IA  
**Puede ser ejecutado por**: Claude, GPT-4, GitHub Copilot, etc.  
**Requisito crítico**: edugo-shared v1.3.0 DEBE estar publicado