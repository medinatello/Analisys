package container

import (
	"database/sql"

	"github.com/edugo/api-mobile/internal/application/service"
	"github.com/edugo/api-mobile/internal/domain/repository"
	"github.com/edugo/api-mobile/internal/infrastructure/http/handler"
	postgresRepo "github.com/edugo/api-mobile/internal/infrastructure/persistence/postgres/repository"
	"github.com/edugo/shared/pkg/logger"
)

// Container es el contenedor de dependencias de API Mobile
// Implementa el patrón Dependency Injection
type Container struct {
	// Infrastructure
	DB     *sql.DB
	Logger logger.Logger

	// Repositories
	MaterialRepository repository.MaterialRepository
	// TODO: Agregar más repositories según se implementen
	// SummaryRepository repository.SummaryRepository (MongoDB)
	// AssessmentRepository repository.AssessmentRepository (MongoDB)
	// ProgressRepository repository.ProgressRepository (PostgreSQL)

	// Services
	MaterialService service.MaterialService
	// TODO: Agregar más services
	// AuthService service.AuthService
	// ProgressService service.ProgressService
	// AssessmentService service.AssessmentService

	// Handlers
	MaterialHandler *handler.MaterialHandler
	// TODO: Agregar más handlers
	// AuthHandler *handler.AuthHandler
}

// NewContainer crea un nuevo contenedor e inicializa todas las dependencias
func NewContainer(db *sql.DB, logger logger.Logger) *Container {
	c := &Container{
		DB:     db,
		Logger: logger,
	}

	// Inicializar repositories (capa de infraestructura)
	c.MaterialRepository = postgresRepo.NewPostgresMaterialRepository(db)

	// Inicializar services (capa de aplicación)
	c.MaterialService = service.NewMaterialService(
		c.MaterialRepository,
		logger,
	)

	// Inicializar handlers (capa de infraestructura HTTP)
	c.MaterialHandler = handler.NewMaterialHandler(
		c.MaterialService,
		logger,
	)

	return c
}

// Close cierra los recursos del contenedor
func (c *Container) Close() error {
	if c.DB != nil {
		return c.DB.Close()
	}
	return nil
}
