# Paso 4: Actualizar SchoolRepository Mock

**Duracion estimada:** 15 minutos
**Prerequisitos:** Paso 3 completado

## Codigo a Implementar

Archivo: school_repository_mock.go

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

type mockSchoolRepository struct{}

func NewMockSchoolRepository() repository.SchoolRepository {
	return &mockSchoolRepository{}
}

func (r *mockSchoolRepository) FindByID(ctx context.Context, id uuid.UUID) (*entities.School, error) {
	if school := dataset.DB.Schools.FindByID(id); school != nil {
		return school, nil
	}
	return nil, errors.NewNotFoundError("school not found")
}

func (r *mockSchoolRepository) List(ctx context.Context) ([]*entities.School, error) {
	return dataset.DB.Schools.List(), nil
}

func (r *mockSchoolRepository) Create(ctx context.Context, school *entities.School) error {
	return errors.NewNotImplementedError("CREATE not supported in mock mode")
}

func (r *mockSchoolRepository) Update(ctx context.Context, school *entities.School) error {
	return errors.NewNotImplementedError("UPDATE not supported in mock mode")
}

func (r *mockSchoolRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return errors.NewNotImplementedError("DELETE not supported in mock mode")
}
```

## Siguiente Paso
→ [paso-05-actualizar-academic-unit-repository.md]
