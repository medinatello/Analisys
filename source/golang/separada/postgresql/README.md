# EduGo - Modelos PostgreSQL con GORM

Este módulo contiene los modelos de Go utilizando GORM para la base de datos PostgreSQL del sistema EduGo.

## Estructura del Proyecto

```
postgresql/
├── models/           # Modelos de datos con GORM
│   ├── user.go      # Usuarios y perfiles
│   ├── academic.go  # Jerarquía académica
│   └── material.go  # Materiales y evaluaciones
├── migrations/      # Migraciones automáticas
│   └── migrate.go   # Auto-migrate de GORM
├── go.mod           # Dependencias del módulo
├── main.go          # Ejemplo de uso
└── README.md        # Esta documentación

```

## Requisitos

- Go 1.21 o superior
- PostgreSQL 14+ con extensión `uuid-ossp`
- Variables de entorno configuradas (ver abajo)

## Instalación

1. Instalar dependencias:

```bash
go mod download
```

2. Configurar variables de entorno:

```bash
export DB_HOST=localhost
export DB_USER=postgres
export DB_PASSWORD=tu_password
export DB_NAME=edugo
export DB_PORT=5432
export DB_SSLMODE=disable
```

3. Ejecutar migraciones:

```bash
go run main.go
```

## Modelos Disponibles

### Usuarios y Perfiles
- `AppUser` - Usuario principal del sistema
- `TeacherProfile` - Perfil de docente
- `StudentProfile` - Perfil de estudiante
- `GuardianProfile` - Perfil de tutor/padre
- `GuardianStudentRelation` - Relación N:M entre tutores y estudiantes

### Jerarquía Académica
- `School` - Colegios/Academias
- `AcademicUnit` - Unidades académicas jerárquicas (recursiva)
- `UnitMembership` - Membresías de usuarios en unidades
- `Subject` - Materias

### Materiales y Evaluaciones
- `LearningMaterial` - Materiales educativos
- `MaterialVersion` - Versiones de materiales
- `MaterialUnitLink` - Asignación N:M de materiales a unidades
- `ReadingLog` - Progreso de lectura
- `MaterialSummaryLink` - Referencias a MongoDB
- `Assessment` - Evaluaciones
- `AssessmentAttempt` - Intentos de evaluación
- `AssessmentAttemptAnswer` - Respuestas individuales

## Uso de los Modelos

### Crear un Usuario

```go
user := models.AppUser{
    Email:          "usuario@example.com",
    CredentialHash: "$2a$10$...",
    SystemRole:     "teacher",
    Status:         "active",
}
db.Create(&user)
```

### Consultar con Relaciones

```go
var materials []models.LearningMaterial
db.Preload("Author").
   Preload("Subject").
   Preload("MaterialVersions").
   Find(&materials)
```

### Buscar por UUID

```go
var school models.School
db.First(&school, "id = ?", uuid.MustParse("..."))
```

## Características de GORM Utilizadas

- ✅ UUIDs como claves primarias
- ✅ Hooks `BeforeCreate` para generar UUIDs
- ✅ Relaciones `HasMany`, `BelongsTo`, `Many2Many`
- ✅ Campos JSONB con `datatypes.JSON`
- ✅ Constraints con tags `check`
- ✅ Índices automáticos con `uniqueIndex`
- ✅ Cascadas con `constraint:OnDelete:CASCADE`

## Migraciones

### Ejecutar Migraciones

```go
import "github.com/edugo/separada/postgresql/migrations"

migrations.RunMigrations(db)
```

### Rollback (Eliminar todas las tablas)

```go
migrations.RollbackMigrations(db) // ⚠️ Usar con precaución
```

## Conexión a la Base de Datos

```go
import (
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

dsn := "host=localhost user=postgres password=postgres dbname=edugo port=5432 sslmode=disable"
db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
```

## Notas Importantes

1. **UUIDs**: Se utiliza UUID v4 por defecto. Asegúrate de tener la extensión `uuid-ossp` habilitada.

2. **JSONB**: Los campos JSONB usan `gorm.io/datatypes` para compatibilidad con PostgreSQL.

3. **Relaciones Recursivas**: `AcademicUnit` tiene una relación recursiva con `parent_unit_id`.

4. **Timestamps**: GORM maneja automáticamente `CreatedAt`, `UpdatedAt` y `DeletedAt` (soft deletes).

5. **Validaciones**: Los checks SQL se definen en los tags `gorm`, pero también debes validar en la lógica de aplicación.

## Scripts SQL Relacionados

Los scripts SQL para crear la base de datos manualmente están en:
- `../../../scripts/postgresql/01_schema.sql`
- `../../../scripts/postgresql/02_indexes.sql`
- `../../../scripts/postgresql/03_mock_data.sql`

## Licencia

Este código es parte del proyecto EduGo.
