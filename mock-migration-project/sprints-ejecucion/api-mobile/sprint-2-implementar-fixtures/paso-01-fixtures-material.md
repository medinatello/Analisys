# Paso 1: Crear Material Fixtures

**Duración:** 20 min | **Prerequisitos:** ✅ Sprint 1 completado

## Referencia
UserRepository en `mock/postgres/user_repository_mock.go` como guía.

## Objetivo
Crear fixtures de Material que complementen el dataset PostgreSQL.

## Ejecución

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

cat > internal/infrastructure/persistence/mock/fixtures/materials.go << 'MATEOF'
package fixtures

import (
    "time"
    "github.com/google/uuid"
    pgentities "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
    "github.com/EduGoGroup/edugo-shared/common/types/enum"
)

func GetDefaultMaterials() map[uuid.UUID]*pgentities.Material {
    teacherID := uuid.MustParse("22222222-2222-2222-2222-222222222222")
    
    materials := make(map[uuid.UUID]*pgentities.Material)
    
    // Material 1: Video Matemáticas
    mat1 := uuid.MustParse("10000000-0000-0000-0000-000000000001")
    materials[mat1] = &pgentities.Material{
        ID:               mat1,
        Title:            "Introducción al Álgebra",
        Description:      "Video tutorial de álgebra básica",
        AuthorID:         teacherID,
        Type:             enum.MaterialTypeVideo,
        Status:           enum.MaterialStatusPublished,
        ProcessingStatus: enum.ProcessingStatusCompleted,
        FileURL:          "https://storage.edugo.com/videos/algebra-intro.mp4",
        ThumbnailURL:     "https://storage.edugo.com/thumbs/algebra-intro.jpg",
        Duration:         1800, // 30 minutos
        CreatedAt:        time.Now().Add(-30 * 24 * time.Hour),
        UpdatedAt:        time.Now().Add(-30 * 24 * time.Hour),
    }
    
    // Material 2: PDF Ciencias
    mat2 := uuid.MustParse("10000000-0000-0000-0000-000000000002")
    materials[mat2] = &pgentities.Material{
        ID:               mat2,
        Title:            "Ecosistemas y Biodiversidad",
        Description:      "Documento PDF sobre ecosistemas",
        AuthorID:         teacherID,
        Type:             enum.MaterialTypePDF,
        Status:           enum.MaterialStatusPublished,
        ProcessingStatus: enum.ProcessingStatusCompleted,
        FileURL:          "https://storage.edugo.com/pdfs/ecosistemas.pdf",
        CreatedAt:        time.Now().Add(-25 * 24 * time.Hour),
        UpdatedAt:        time.Now().Add(-25 * 24 * time.Hour),
    }
    
    // ... (agregar 8 más hasta tener 10)
    
    return materials
}
MATEOF

# Compilar para validar
go build ./internal/infrastructure/persistence/mock/fixtures/
```

## Validación
- [ ] 10 materiales definidos
- [ ] UUIDs únicos y predecibles
- [ ] Relacionados con teacher del dataset
- [ ] Compila sin errores

## Siguiente Paso
→ [paso-02-fixtures-progress.md]
