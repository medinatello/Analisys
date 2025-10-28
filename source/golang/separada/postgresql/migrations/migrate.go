package migrations

import (
	"fmt"
	"log"

	"github.com/edugo/separada/postgresql/models"
	"gorm.io/gorm"
)

// RunMigrations - Ejecuta las migraciones automáticas de GORM
func RunMigrations(db *gorm.DB) error {
	log.Println("🔄 Iniciando migraciones de base de datos...")

	// Habilitar extensión UUID (requiere permisos de superusuario)
	if err := db.Exec("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"").Error; err != nil {
		return fmt.Errorf("error creando extensión uuid-ossp: %w", err)
	}

	// Auto-migrar todos los modelos
	err := db.AutoMigrate(
		// Usuarios y perfiles
		&models.AppUser{},
		&models.TeacherProfile{},
		&models.StudentProfile{},
		&models.GuardianProfile{},
		&models.GuardianStudentRelation{},

		// Jerarquía académica
		&models.School{},
		&models.AcademicUnit{},
		&models.UnitMembership{},
		&models.Subject{},

		// Materiales y contenidos
		&models.LearningMaterial{},
		&models.MaterialVersion{},
		&models.MaterialUnitLink{},
		&models.ReadingLog{},
		&models.MaterialSummaryLink{},

		// Evaluaciones
		&models.Assessment{},
		&models.AssessmentAttempt{},
		&models.AssessmentAttemptAnswer{},
	)

	if err != nil {
		return fmt.Errorf("error en auto-migración: %w", err)
	}

	log.Println("✅ Migraciones completadas exitosamente")
	return nil
}

// RollbackMigrations - Elimina todas las tablas (usar con precaución)
func RollbackMigrations(db *gorm.DB) error {
	log.Println("⚠️  Eliminando todas las tablas...")

	err := db.Migrator().DropTable(
		&models.AssessmentAttemptAnswer{},
		&models.AssessmentAttempt{},
		&models.Assessment{},
		&models.MaterialSummaryLink{},
		&models.ReadingLog{},
		&models.MaterialUnitLink{},
		&models.MaterialVersion{},
		&models.LearningMaterial{},
		&models.Subject{},
		&models.UnitMembership{},
		&models.AcademicUnit{},
		&models.School{},
		&models.GuardianStudentRelation{},
		&models.GuardianProfile{},
		&models.StudentProfile{},
		&models.TeacherProfile{},
		&models.AppUser{},
	)

	if err != nil {
		return fmt.Errorf("error eliminando tablas: %w", err)
	}

	log.Println("✅ Todas las tablas eliminadas")
	return nil
}
