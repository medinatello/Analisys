package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/edugo/juntos/migrations"
	"github.com/edugo/juntos/models"
	"gorm.io/datatypes"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func main() {
	// Conectar a PostgreSQL
	dsn := getDBConnectionString()
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("❌ Error conectando a PostgreSQL: %v", err)
	}

	log.Println("✅ Conexión a PostgreSQL establecida")
	log.Println("ℹ️  Enfoque Híbrido: PostgreSQL con JSONB para datos documentales")

	// Ejecutar migraciones
	if err := migrations.RunMigrations(db); err != nil {
		log.Fatalf("❌ Error ejecutando migraciones: %v", err)
	}

	// Insertar datos de ejemplo
	if err := seedHybridData(db); err != nil {
		log.Fatalf("❌ Error insertando datos: %v", err)
	}

	// Consultas de ejemplo
	if err := runHybridQueries(db); err != nil {
		log.Fatalf("❌ Error en consultas: %v", err)
	}

	log.Println("✅ Demostración del enfoque híbrido completada")
}

func getDBConnectionString() string {
	host := getEnv("DB_HOST", "localhost")
	user := getEnv("DB_USER", "postgres")
	password := getEnv("DB_PASSWORD", "postgres")
	dbname := getEnv("DB_NAME", "edugo_hybrid")
	port := getEnv("DB_PORT", "5432")
	sslmode := getEnv("DB_SSLMODE", "disable")

	return fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
		host, user, password, dbname, port, sslmode,
	)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func seedHybridData(db *gorm.DB) error {
	log.Println("📝 Insertando datos híbridos de ejemplo...")

	// Verificar si ya existen datos
	var count int64
	db.Model(&models.School{}).Count(&count)
	if count > 0 {
		log.Println("ℹ️  Ya existen datos, omitiendo seed")
		return nil
	}

	// Crear datos tradicionales
	school := models.School{
		Name:         "Colegio Híbrido",
		ExternalCode: "HYBRID-001",
		Location:     "Lima, Perú",
	}
	db.Create(&school)

	subject := models.Subject{
		SchoolID:    school.ID,
		Name:        "Programación",
		Description: "Curso de programación",
	}
	db.Create(&subject)

	teacher := models.AppUser{
		Email:          "profesor@hybrid.com",
		CredentialHash: "$2a$10$hash",
		SystemRole:     "teacher",
		Status:         "active",
	}
	db.Create(&teacher)

	material := models.LearningMaterial{
		AuthorID:    teacher.ID,
		SubjectID:   subject.ID,
		Title:       "Introducción a Go",
		Description: "Aprende Go desde cero",
		Status:      "published",
	}
	db.Create(&material)

	log.Println("✅ Datos tradicionales creados")

	// Crear datos JSONB (ex-MongoDB)

	// Resumen con JSONB
	summaryData := map[string]interface{}{
		"sections": []map[string]interface{}{
			{
				"title":   "¿Qué es Go?",
				"content": "Go es un lenguaje de programación compilado...",
				"level":   "basic",
			},
		},
		"glossary": []map[string]interface{}{
			{
				"term":       "Goroutine",
				"definition": "Hilo ligero gestionado por Go runtime",
			},
		},
		"reflection_questions": []string{
			"¿Por qué Go es eficiente?",
			"¿Qué son las goroutines?",
		},
	}

	summaryJSON, _ := json.Marshal(summaryData)
	summary := models.MaterialSummaryJSON{
		MaterialID:  material.ID,
		Version:     1,
		SummaryData: datatypes.JSON(summaryJSON),
		Status:      "complete",
	}
	db.Create(&summary)
	log.Println("✅ Resumen JSONB creado")

	// Evaluación con JSONB
	assessmentData := map[string]interface{}{
		"questions": []map[string]interface{}{
			{
				"id":         "q1",
				"text":       "¿Qué es una goroutine?",
				"type":       "multiple_choice",
				"options":    []string{"A) Hilo ligero", "B) Función normal"},
				"answer":     "A",
				"difficulty": "medium",
				"points":     5,
			},
		},
	}

	assessmentJSON, _ := json.Marshal(assessmentData)
	assessment := models.MaterialAssessmentJSON{
		MaterialID:     material.ID,
		Title:          "Quiz de Go",
		Version:        1,
		AssessmentData: datatypes.JSON(assessmentJSON),
		TotalPoints:    5.0,
	}
	db.Create(&assessment)
	log.Println("✅ Evaluación JSONB creada")

	// Evento con JSONB
	eventMetadata := map[string]interface{}{
		"nlp_provider": "openai",
		"model":        "gpt-4",
		"tokens_used":  1200,
	}
	eventJSON, _ := json.Marshal(eventMetadata)
	duration := 42.5
	event := models.MaterialEventJSON{
		MaterialID:      material.ID,
		EventType:       "processing_completed",
		WorkerID:        "worker-hybrid-01",
		DurationSeconds: &duration,
		EventMetadata:   datatypes.JSON(eventJSON),
	}
	db.Create(&event)
	log.Println("✅ Evento JSONB creado")

	log.Println("✅ Todos los datos híbridos insertados")
	return nil
}

func runHybridQueries(db *gorm.DB) error {
	log.Println("\n📊 Ejecutando consultas híbridas...")

	// Consulta 1: Materiales con su resumen JSONB
	var materials []models.LearningMaterial
	db.Preload("Author").
		Preload("Subject").
		Find(&materials)

	log.Printf("📚 Materiales: %d", len(materials))
	for _, m := range materials {
		log.Printf("  - %s (por %s)", m.Title, m.Author.Email)

		// Buscar resumen JSONB
		var summary models.MaterialSummaryJSON
		if err := db.Where("material_id = ?", m.ID).First(&summary).Error; err == nil {
			log.Printf("    Resumen: Versión %d, Estado: %s", summary.Version, summary.Status)

			// Parsear JSONB
			var data map[string]interface{}
			json.Unmarshal(summary.SummaryData, &data)
			if sections, ok := data["sections"].([]interface{}); ok {
				log.Printf("    Secciones: %d", len(sections))
			}
		}
	}

	// Consulta 2: Evaluaciones JSONB
	var assessments []models.MaterialAssessmentJSON
	db.Preload("Material").Find(&assessments)

	log.Printf("\n📝 Evaluaciones JSONB: %d", len(assessments))
	for _, a := range assessments {
		log.Printf("  - %s (%.0f puntos)", a.Title, a.TotalPoints)

		// Parsear preguntas del JSONB
		var data map[string]interface{}
		json.Unmarshal(a.AssessmentData, &data)
		if questions, ok := data["questions"].([]interface{}); ok {
			log.Printf("    Preguntas: %d", len(questions))
		}
	}

	// Consulta 3: Eventos JSONB
	var events []models.MaterialEventJSON
	db.Order("created_at DESC").Limit(5).Find(&events)

	log.Printf("\n📅 Eventos recientes: %d", len(events))
	for _, e := range events {
		log.Printf("  - %s por %s", e.EventType, e.WorkerID)
		if e.DurationSeconds != nil {
			log.Printf("    Duración: %.1f segundos", *e.DurationSeconds)
		}
	}

	// Consulta 4: Query JSON con GORM
	log.Println("\n🔍 Consulta JSON: Resúmenes con estado 'complete'")
	var completeSummaries []models.MaterialSummaryJSON
	db.Where("status = ?", "complete").Find(&completeSummaries)
	log.Printf("    Encontrados: %d", len(completeSummaries))

	log.Println("\n✅ Consultas híbridas completadas")
	log.Println("ℹ️  Este enfoque combina lo mejor de ambos mundos:")
	log.Println("   - Relaciones y constraints de PostgreSQL")
	log.Println("   - Flexibilidad de documentos JSON")
	return nil
}
