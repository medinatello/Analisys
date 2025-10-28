package migrations

import (
	"fmt"
	"log"

	"github.com/edugo/juntos/models"
	"gorm.io/gorm"
)

// RunMigrations - Ejecuta migraciones del enfoque híbrido (PostgreSQL + JSONB)
func RunMigrations(db *gorm.DB) error {
	log.Println("🔄 Iniciando migraciones híbridas (PostgreSQL + JSONB)...")

	// Habilitar extensión UUID
	if err := db.Exec("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"").Error; err != nil {
		return fmt.Errorf("error creando extensión uuid-ossp: %w", err)
	}

	// Migrar todos los modelos (tradicionales + híbridos)
	err := db.AutoMigrate(
		// Usuarios y perfiles (tradicional)
		&models.AppUser{},
		&models.TeacherProfile{},
		&models.StudentProfile{},
		&models.GuardianProfile{},
		&models.GuardianStudentRelation{},

		// Jerarquía académica (tradicional)
		&models.School{},
		&models.AcademicUnit{},
		&models.UnitMembership{},
		&models.Subject{},

		// Materiales (tradicional)
		&models.LearningMaterial{},
		&models.MaterialVersion{},
		&models.MaterialUnitLink{},
		&models.ReadingLog{},

		// Evaluaciones híbridas
		&models.MaterialAssessmentJSON{},
		&models.AssessmentAttempt{},
		&models.AssessmentAttemptAnswer{},

		// Modelos JSONB (reemplazan MongoDB)
		&models.MaterialSummaryJSON{},
		&models.MaterialEventJSON{},
		&models.UnitSocialFeedJSON{},
		&models.UserGraphRelationJSON{},
	)

	if err != nil {
		return fmt.Errorf("error en auto-migración: %w", err)
	}

	log.Println("✅ Migraciones híbridas completadas exitosamente")
	log.Println("ℹ️  Tablas tradicionales + Tablas JSONB creadas")
	return nil
}
