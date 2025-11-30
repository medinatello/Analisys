# Guía Rápida: Sprint 2 - Implementar Fixtures

**NOTA:** Este archivo consolida los 18 pasos del Sprint 2 en una guía práctica.

## Resumen de Pasos

### Parte 1: Fixtures PostgreSQL (Pasos 1-7)

Todos siguen el mismo patrón:

```bash
# Ubicación: internal/infrastructure/persistence/mock/fixtures/

# Paso 1: materials.go (10 materiales)
# Paso 2: progress.go (15 registros de progreso)
# Paso 3: refresh_tokens.go (5 tokens activos)
# Paso 4: login_attempts.go (20 intentos históricos)
# Paso 5: assessments.go (5 evaluaciones)
# Paso 6: attempts.go (25 intentos de evaluación)
# Paso 7: answers.go (200 respuestas)
```

**Patrón de cada fixture:**

```go
package fixtures

import (
    "github.com/google/uuid"
    pgentities "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
)

func GetDefault<Entities>() map[uuid.UUID]*pgentities.<Entity> {
    entities := make(map[uuid.UUID]*pgentities.<Entity>)
    
    // Crear 10-20 entidades con UUIDs predecibles
    // Relacionar con users del dataset
    
    return entities
}
```

### Parte 2: Mock Repositories PostgreSQL (Pasos 8-14)

Todos siguen el patrón de UserRepository:

```go
package postgres

import (
    "context"
    "sync"
    "github.com/EduGoGroup/edugo-api-mobile/internal/domain/repository"
    "github.com/EduGoGroup/edugo-api-mobile/internal/infrastructure/persistence/mock/fixtures"
)

type mock<Entity>Repository struct {
    entities map[uuid.UUID]*pgentities.<Entity>
    mu       sync.RWMutex
}

func NewMock<Entity>Repository() repository.<Entity>Repository {
    return &mock<Entity>Repository{
        entities: fixtures.GetDefault<Entities>(),
    }
}

// Implementar métodos de la interfaz
```

### Parte 3: Fixtures MongoDB (Paso 15)

```bash
# Ubicación: internal/infrastructure/persistence/mock/fixtures/mongodb/

# summary_fixtures.go - 10 summaries
# assessment_fixtures.go - 5 assessments
# assessment_document_fixtures.go - 5 documents
```

**Patrón MongoDB:**

```go
package mongodb

import (
    "github.com/google/uuid"
    "github.com/EduGoGroup/edugo-api-mobile/internal/domain/repository"
)

func GetDefaultSummaries() map[uuid.UUID]*repository.MaterialSummary {
    summaries := make(map[uuid.UUID]*repository.MaterialSummary)
    
    // Relacionar con Material IDs del dataset PostgreSQL
    
    return summaries
}
```

### Parte 4: Mock Repositories MongoDB (Pasos 16-18)

```go
package mongodb

import (
    "context"
    "github.com/EduGoGroup/edugo-api-mobile/internal/domain/repository"
    "github.com/EduGoGroup/edugo-api-mobile/internal/infrastructure/persistence/mock/fixtures/mongodb"
)

type mock<Entity>Repository struct {
    entities map[uuid.UUID]*repository.<Entity>
}

func NewMock<Entity>Repository() repository.<Entity>Repository {
    return &mock<Entity>Repository{
        entities: mongodb.GetDefault<Entities>(),
    }
}

// Implementar métodos de la interfaz
```

## Checklist Rápido

### Fixtures PostgreSQL
- [ ] materials.go (10 materiales)
- [ ] progress.go (15 progresos)
- [ ] refresh_tokens.go (5 tokens)
- [ ] login_attempts.go (20 intentos)
- [ ] assessments.go (5 evaluaciones)
- [ ] attempts.go (25 intentos)
- [ ] answers.go (200 respuestas)

### Mocks PostgreSQL
- [ ] MaterialRepositoryMock
- [ ] ProgressRepositoryMock
- [ ] RefreshTokenRepositoryMock
- [ ] LoginAttemptRepositoryMock
- [ ] AssessmentRepositoryMock
- [ ] AttemptRepositoryMock
- [ ] AnswerRepositoryMock

### Fixtures MongoDB
- [ ] summary_fixtures.go
- [ ] assessment_fixtures.go
- [ ] assessment_document_fixtures.go

### Mocks MongoDB
- [ ] SummaryRepositoryMock
- [ ] LegacyAssessmentRepositoryMock
- [ ] AssessmentDocumentRepositoryMock

## Comandos de Validación

```bash
# Compilar todos los fixtures
go build ./internal/infrastructure/persistence/mock/fixtures/
go build ./internal/infrastructure/persistence/mock/fixtures/mongodb/

# Compilar todos los mocks
go build ./internal/infrastructure/persistence/mock/postgres/
go build ./internal/infrastructure/persistence/mock/mongodb/

# Test rápido
go test ./internal/infrastructure/persistence/mock/... -v
```

## Siguiente Sprint
→ [../sprint-3-integracion-api/README.md]
