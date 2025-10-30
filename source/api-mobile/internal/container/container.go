package container

import (
	"database/sql"

	"github.com/edugo/api-mobile/internal/application/service"
	"github.com/edugo/api-mobile/internal/domain/repository"
	"github.com/edugo/api-mobile/internal/infrastructure/http/handler"
	postgresRepo "github.com/edugo/api-mobile/internal/infrastructure/persistence/postgres/repository"
	"github.com/edugo/shared/pkg/auth"
	"github.com/edugo/shared/pkg/logger"
)

// Container es el contenedor de dependencias de API Mobile
// Implementa el patrón Dependency Injection
type Container struct {
	// Infrastructure
	DB         *sql.DB
	Logger     logger.Logger
	JWTManager *auth.JWTManager

	// Repositories
	UserRepository     repository.UserRepository
	MaterialRepository repository.MaterialRepository

	// Services
	AuthService     service.AuthService
	MaterialService service.MaterialService

	// Handlers
	AuthHandler     *handler.AuthHandler
	MaterialHandler *handler.MaterialHandler
}

// NewContainer crea un nuevo contenedor e inicializa todas las dependencias
func NewContainer(db *sql.DB, jwtSecret string, logger logger.Logger) *Container {
	c := &Container{
		DB:         db,
		Logger:     logger,
		JWTManager: auth.NewJWTManager(jwtSecret, "edugo-mobile"),
	}

	// Inicializar repositories (capa de infraestructura)
	c.UserRepository = postgresRepo.NewPostgresUserRepository(db)
	c.MaterialRepository = postgresRepo.NewPostgresMaterialRepository(db)

	// Inicializar services (capa de aplicación)
	c.AuthService = service.NewAuthService(
		c.UserRepository,
		c.JWTManager,
		logger,
	)
	c.MaterialService = service.NewMaterialService(
		c.MaterialRepository,
		logger,
	)

	// Inicializar handlers (capa de infraestructura HTTP)
	c.AuthHandler = handler.NewAuthHandler(
		c.AuthService,
		logger,
	)
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
