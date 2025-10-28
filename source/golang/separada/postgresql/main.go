package main

import (
	"fmt"
	"log"
	"os"

	"github.com/edugo/separada/postgresql/migrations"
	"github.com/edugo/separada/postgresql/models"
	"github.com/google/uuid"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func main() {
	// Configuración de la base de datos
	dsn := getDBConnectionString()

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("❌ Error conectando a la base de datos: %v", err)
	}

	log.Println("✅ Conexión a PostgreSQL establecida")

	// Ejecutar migraciones
	if err := migrations.RunMigrations(db); err != nil {
		log.Fatalf("❌ Error ejecutando migraciones: %v", err)
	}

	// Ejemplo de uso: Crear datos de prueba
	if err := seedExampleData(db); err != nil {
		log.Fatalf("❌ Error insertando datos de ejemplo: %v", err)
	}

	// Ejemplo de consultas
	if err := runExampleQueries(db); err != nil {
		log.Fatalf("❌ Error ejecutando consultas de ejemplo: %v", err)
	}

	log.Println("✅ Programa completado exitosamente")
}

// getDBConnectionString - Obtiene la cadena de conexión desde variables de entorno
func getDBConnectionString() string {
	host := getEnv("DB_HOST", "localhost")
	user := getEnv("DB_USER", "postgres")
	password := getEnv("DB_PASSWORD", "postgres")
	dbname := getEnv("DB_NAME", "edugo")
	port := getEnv("DB_PORT", "5432")
	sslmode := getEnv("DB_SSLMODE", "disable")

	return fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
		host, user, password, dbname, port, sslmode,
	)
}

// getEnv - Obtiene variable de entorno con valor por defecto
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// seedExampleData - Inserta datos de ejemplo en la base de datos
func seedExampleData(db *gorm.DB) error {
	log.Println("📝 Insertando datos de ejemplo...")

	// Verificar si ya existen datos
	var count int64
	db.Model(&models.School{}).Count(&count)
	if count > 0 {
		log.Println("ℹ️  Ya existen datos en la base de datos, omitiendo seed")
		return nil
	}

	// Crear un colegio
	school := models.School{
		Name:         "Colegio de Prueba",
		ExternalCode: "TEST-001",
		Location:     "Lima, Perú",
	}
	if err := db.Create(&school).Error; err != nil {
		return fmt.Errorf("error creando colegio: %w", err)
	}
	log.Printf("✅ Colegio creado: %s (ID: %s)", school.Name, school.ID)

	// Crear materia
	subject := models.Subject{
		SchoolID:    school.ID,
		Name:        "Matemáticas",
		Description: "Matemáticas básicas",
	}
	if err := db.Create(&subject).Error; err != nil {
		return fmt.Errorf("error creando materia: %w", err)
	}
	log.Printf("✅ Materia creada: %s (ID: %s)", subject.Name, subject.ID)

	// Crear usuario docente
	teacher := models.AppUser{
		Email:          "docente@test.com",
		CredentialHash: "$2a$10$hashedpassword",
		SystemRole:     "teacher",
		Status:         "active",
	}
	if err := db.Create(&teacher).Error; err != nil {
		return fmt.Errorf("error creando docente: %w", err)
	}
	log.Printf("✅ Docente creado: %s (ID: %s)", teacher.Email, teacher.ID)

	// Crear perfil de docente
	teacherProfile := models.TeacherProfile{
		UserID:    teacher.ID,
		Specialty: "Matemáticas",
	}
	if err := db.Create(&teacherProfile).Error; err != nil {
		return fmt.Errorf("error creando perfil de docente: %w", err)
	}
	log.Println("✅ Perfil de docente creado")

	// Crear unidad académica
	academicUnit := models.AcademicUnit{
		SchoolID: school.ID,
		UnitType: "section",
		Name:     "5º A",
		Code:     "5A-2024",
	}
	if err := db.Create(&academicUnit).Error; err != nil {
		return fmt.Errorf("error creando unidad académica: %w", err)
	}
	log.Printf("✅ Unidad académica creada: %s (ID: %s)", academicUnit.Name, academicUnit.ID)

	// Crear material de aprendizaje
	material := models.LearningMaterial{
		AuthorID:    teacher.ID,
		SubjectID:   subject.ID,
		Title:       "Introducción a las Fracciones",
		Description: "Material educativo sobre fracciones",
		Status:      "published",
	}
	if err := db.Create(&material).Error; err != nil {
		return fmt.Errorf("error creando material: %w", err)
	}
	log.Printf("✅ Material creado: %s (ID: %s)", material.Title, material.ID)

	// Crear estudiante
	student := models.AppUser{
		Email:          "estudiante@test.com",
		CredentialHash: "$2a$10$hashedpassword",
		SystemRole:     "student",
		Status:         "active",
	}
	if err := db.Create(&student).Error; err != nil {
		return fmt.Errorf("error creando estudiante: %w", err)
	}
	log.Printf("✅ Estudiante creado: %s (ID: %s)", student.Email, student.ID)

	// Crear perfil de estudiante
	studentProfile := models.StudentProfile{
		UserID:        student.ID,
		PrimaryUnitID: &academicUnit.ID,
		CurrentGrade:  "5º Primaria",
		StudentCode:   "TEST-2024-001",
	}
	if err := db.Create(&studentProfile).Error; err != nil {
		return fmt.Errorf("error creando perfil de estudiante: %w", err)
	}
	log.Println("✅ Perfil de estudiante creado")

	// Crear registro de lectura
	readingLog := models.ReadingLog{
		MaterialID: material.ID,
		UserID:     student.ID,
		Progress:   0.75, // 75% completado
	}
	if err := db.Create(&readingLog).Error; err != nil {
		return fmt.Errorf("error creando registro de lectura: %w", err)
	}
	log.Println("✅ Registro de lectura creado")

	log.Println("✅ Datos de ejemplo insertados correctamente")
	return nil
}

// runExampleQueries - Ejecuta consultas de ejemplo
func runExampleQueries(db *gorm.DB) error {
	log.Println("\n📊 Ejecutando consultas de ejemplo...")

	// 1. Listar todos los colegios
	var schools []models.School
	if err := db.Find(&schools).Error; err != nil {
		return fmt.Errorf("error consultando colegios: %w", err)
	}
	log.Printf("📚 Total de colegios: %d", len(schools))
	for _, school := range schools {
		log.Printf("  - %s (%s)", school.Name, school.ExternalCode)
	}

	// 2. Obtener docentes con su perfil
	var teachers []models.AppUser
	if err := db.Where("system_role = ?", "teacher").
		Preload("TeacherProfile").
		Find(&teachers).Error; err != nil {
		return fmt.Errorf("error consultando docentes: %w", err)
	}
	log.Printf("\n👨‍🏫 Total de docentes: %d", len(teachers))
	for _, teacher := range teachers {
		specialty := "N/A"
		if teacher.TeacherProfile != nil {
			specialty = teacher.TeacherProfile.Specialty
		}
		log.Printf("  - %s (Especialidad: %s)", teacher.Email, specialty)
	}

	// 3. Materiales con autor y materia
	var materials []models.LearningMaterial
	if err := db.Preload("Author").
		Preload("Subject").
		Find(&materials).Error; err != nil {
		return fmt.Errorf("error consultando materiales: %w", err)
	}
	log.Printf("\n📖 Total de materiales: %d", len(materials))
	for _, material := range materials {
		log.Printf("  - %s", material.Title)
		log.Printf("    Autor: %s", material.Author.Email)
		log.Printf("    Materia: %s", material.Subject.Name)
		log.Printf("    Estado: %s", material.Status)
	}

	// 4. Progreso de lectura de estudiantes
	var readingLogs []models.ReadingLog
	if err := db.Preload("User").
		Preload("Material").
		Find(&readingLogs).Error; err != nil {
		return fmt.Errorf("error consultando progreso: %w", err)
	}
	log.Printf("\n📊 Registros de lectura: %d", len(readingLogs))
	for _, log := range readingLogs {
		progress := log.Progress * 100
		log.Printf("  - %s está al %.0f%% en '%s'",
			log.User.Email, progress, log.Material.Title)
	}

	// 5. Ejemplo de búsqueda por UUID
	if len(schools) > 0 {
		var school models.School
		if err := db.First(&school, "id = ?", schools[0].ID).Error; err != nil {
			return fmt.Errorf("error buscando colegio por UUID: %w", err)
		}
		log.Printf("\n🔍 Búsqueda por UUID: %s encontrado", school.Name)
	}

	log.Println("\n✅ Consultas de ejemplo completadas")
	return nil
}
