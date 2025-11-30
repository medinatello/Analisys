# Paso 3: Actualizar UserRepository Mock

**Duracion estimada:** 20 minutos
**Prerequisitos:** Paso 2 completado

## Objetivo
Simplificar UserRepository para usar dataset.

## Archivos Involucrados
- Modificar: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/internal/infrastructure/persistence/mock/repository/user_repository_mock.go

## Codigo a Implementar

Reemplazar COMPLETAMENTE el contenido:

```go
package repository

import (
	"context"
	"github.com/EduGoGroup/edugo-api-administracion/internal/domain/repository"
	"github.com/EduGoGroup/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset"
	"github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
	"github.com/EduGoGroup/edugo-shared/common/errors"
	"github.com/google/uuid"
)

type mockUserRepository struct{}

func NewMockUserRepository() repository.UserRepository {
	return &mockUserRepository{}
}

func (r *mockUserRepository) FindByID(ctx context.Context, id uuid.UUID) (*entities.User, error) {
	if user := dataset.DB.Users.FindByID(id); user != nil {
		return user, nil
	}
	return nil, errors.NewNotFoundError("user not found")
}

func (r *mockUserRepository) FindByEmail(ctx context.Context, email string) (*entities.User, error) {
	for _, user := range dataset.DB.Users.List() {
		if user.Email == email {
			return user, nil
		}
	}
	return nil, errors.NewNotFoundError("user not found")
}

func (r *mockUserRepository) List(ctx context.Context) ([]*entities.User, error) {
	return dataset.DB.Users.List(), nil
}

func (r *mockUserRepository) Create(ctx context.Context, user *entities.User) error {
	return errors.NewNotImplementedError("CREATE not supported in mock mode")
}

func (r *mockUserRepository) Update(ctx context.Context, user *entities.User) error {
	return errors.NewNotImplementedError("UPDATE not supported in mock mode")
}

func (r *mockUserRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return errors.NewNotImplementedError("DELETE not supported in mock mode")
}
```

## Validacion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
go build ./internal/infrastructure/persistence/mock/repository
```

## Siguiente Paso
→ [paso-04-actualizar-school-repository.md]
