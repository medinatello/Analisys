package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/edugo/separada/mongo/migrations"
	"github.com/edugo/separada/mongo/models"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
	// Conectar a MongoDB
	mongoURI := getEnv("MONGO_URI", "mongodb://localhost:27017")
	dbName := getEnv("MONGO_DB", "edugo")

	client, err := mongo.Connect(context.Background(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatalf("❌ Error conectando a MongoDB: %v", err)
	}
	defer client.Disconnect(context.Background())

	// Verificar conexión
	if err := client.Ping(context.Background(), nil); err != nil {
		log.Fatalf("❌ Error verificando conexión: %v", err)
	}
	log.Println("✅ Conexión a MongoDB establecida")

	db := client.Database(dbName)

	// Ejecutar migraciones (crear índices)
	if err := migrations.RunMigrations(db); err != nil {
		log.Fatalf("❌ Error ejecutando migraciones: %v", err)
	}

	// Insertar datos de ejemplo
	if err := seedExampleData(db); err != nil {
		log.Fatalf("❌ Error insertando datos: %v", err)
	}

	// Ejecutar consultas de ejemplo
	if err := runExampleQueries(db); err != nil {
		log.Fatalf("❌ Error en consultas: %v", err)
	}

	log.Println("✅ Programa completado exitosamente")
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func seedExampleData(db *mongo.Database) error {
	log.Println("📝 Insertando datos de ejemplo...")
	ctx := context.Background()

	// Verificar si ya existen datos
	count, _ := db.Collection("material_summary").CountDocuments(ctx, bson.M{})
	if count > 0 {
		log.Println("ℹ️  Ya existen datos, omitiendo seed")
		return nil
	}

	materialID := "m1000001-0000-0000-0000-000000000001"

	// Crear resumen
	summary := models.NewMaterialSummary(materialID)
	summary.Sections = []models.SummarySection{
		{Title: "Introducción", Content: "Contenido introductorio...", Level: "basic"},
	}
	summary.Glossary = []models.GlossaryTerm{
		{Term: "Término 1", Definition: "Definición..."},
	}
	summary.Status = "complete"

	_, err := db.Collection("material_summary").InsertOne(ctx, summary)
	if err != nil {
		return fmt.Errorf("error insertando resumen: %w", err)
	}
	log.Printf("✅ Resumen creado para material: %s", materialID)

	// Crear evaluación
	assessment := models.NewMaterialAssessment(materialID, "Quiz de Prueba")
	assessment.Questions = []models.Question{
		{
			ID:         "q1",
			Text:       "¿Pregunta de prueba?",
			Type:       "multiple_choice",
			Options:    []string{"A) Opción 1", "B) Opción 2"},
			Difficulty: "easy",
			Points:     5,
		},
	}
	assessment.TotalPoints = 5

	_, err = db.Collection("material_assessment").InsertOne(ctx, assessment)
	if err != nil {
		return fmt.Errorf("error insertando evaluación: %w", err)
	}
	log.Printf("✅ Evaluación creada: %s", assessment.Title)

	// Crear evento
	event := models.NewMaterialEvent(materialID, "processing_completed")
	event.WorkerID = "worker-01"
	duration := 45.3
	event.DurationSeconds = &duration
	event.Metadata = map[string]interface{}{
		"nlp_provider": "openai",
		"tokens_used":  1500,
	}

	_, err = db.Collection("material_event").InsertOne(ctx, event)
	if err != nil {
		return fmt.Errorf("error insertando evento: %w", err)
	}
	log.Println("✅ Evento creado")

	return nil
}

func runExampleQueries(db *mongo.Database) error {
	log.Println("\n📊 Ejecutando consultas de ejemplo...")
	ctx := context.Background()

	// Buscar todos los resúmenes completos
	cursor, err := db.Collection("material_summary").Find(ctx, bson.M{"status": "complete"})
	if err != nil {
		return err
	}
	defer cursor.Close(ctx)

	var summaries []models.MaterialSummary
	if err := cursor.All(ctx, &summaries); err != nil {
		return err
	}
	log.Printf("📚 Resúmenes completos: %d", len(summaries))
	for _, summary := range summaries {
		log.Printf("  - Material ID: %s, Versión: %d, Secciones: %d",
			summary.MaterialID, summary.Version, len(summary.Sections))
	}

	// Buscar evaluaciones
	cursor, err = db.Collection("material_assessment").Find(ctx, bson.M{})
	if err != nil {
		return err
	}
	defer cursor.Close(ctx)

	var assessments []models.MaterialAssessment
	if err := cursor.All(ctx, &assessments); err != nil {
		return err
	}
	log.Printf("\n📝 Evaluaciones: %d", len(assessments))
	for _, assessment := range assessments {
		log.Printf("  - %s (Preguntas: %d, Puntos: %.0f)",
			assessment.Title, len(assessment.Questions), assessment.TotalPoints)
	}

	// Buscar eventos recientes
	opts := options.Find().SetLimit(5).SetSort(bson.D{{Key: "created_at", Value: -1}})
	cursor, err = db.Collection("material_event").Find(ctx, bson.M{}, opts)
	if err != nil {
		return err
	}
	defer cursor.Close(ctx)

	var events []models.MaterialEvent
	if err := cursor.All(ctx, &events); err != nil {
		return err
	}
	log.Printf("\n📅 Eventos recientes: %d", len(events))
	for _, event := range events {
		log.Printf("  - %s: %s", event.EventType, event.MaterialID)
	}

	return nil
}
