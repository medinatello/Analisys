package migrations

import (
	"context"
	"fmt"
	"log"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// RunMigrations - Crea índices y validaciones de esquema
func RunMigrations(db *mongo.Database) error {
	log.Println("🔄 Iniciando migraciones de MongoDB...")
	ctx := context.Background()

	// material_summary
	if err := createMaterialSummaryIndexes(ctx, db); err != nil {
		return err
	}

	// material_assessment
	if err := createMaterialAssessmentIndexes(ctx, db); err != nil {
		return err
	}

	// material_event
	if err := createMaterialEventIndexes(ctx, db); err != nil {
		return err
	}

	// unit_social_feed
	if err := createUnitSocialFeedIndexes(ctx, db); err != nil {
		return err
	}

	// user_graph_relation
	if err := createUserGraphRelationIndexes(ctx, db); err != nil {
		return err
	}

	log.Println("✅ Migraciones de MongoDB completadas")
	return nil
}

func createMaterialSummaryIndexes(ctx context.Context, db *mongo.Database) error {
	collection := db.Collection("material_summary")

	indexes := []mongo.IndexModel{
		{Keys: bson.D{{Key: "material_id", Value: 1}}, Options: options.Index().SetUnique(true)},
		{Keys: bson.D{{Key: "status", Value: 1}}},
		{Keys: bson.D{{Key: "updated_at", Value: -1}}},
	}

	_, err := collection.Indexes().CreateMany(ctx, indexes)
	if err != nil {
		return fmt.Errorf("error creando índices en material_summary: %w", err)
	}
	log.Println("✅ Índices creados: material_summary")
	return nil
}

func createMaterialAssessmentIndexes(ctx context.Context, db *mongo.Database) error {
	collection := db.Collection("material_assessment")

	indexes := []mongo.IndexModel{
		{Keys: bson.D{{Key: "material_id", Value: 1}}, Options: options.Index().SetUnique(true)},
		{Keys: bson.D{{Key: "questions.id", Value: 1}}},
		{Keys: bson.D{{Key: "created_at", Value: -1}}},
	}

	_, err := collection.Indexes().CreateMany(ctx, indexes)
	if err != nil {
		return fmt.Errorf("error creando índices en material_assessment: %w", err)
	}
	log.Println("✅ Índices creados: material_assessment")
	return nil
}

func createMaterialEventIndexes(ctx context.Context, db *mongo.Database) error {
	collection := db.Collection("material_event")

	indexes := []mongo.IndexModel{
		{Keys: bson.D{{Key: "material_id", Value: 1}, {Key: "created_at", Value: -1}}},
		{Keys: bson.D{{Key: "event_type", Value: 1}}},
		{Keys: bson.D{{Key: "worker_id", Value: 1}}},
		{Keys: bson.D{{Key: "created_at", Value: 1}}, Options: options.Index().SetExpireAfterSeconds(7776000)}, // TTL 90 días
	}

	_, err := collection.Indexes().CreateMany(ctx, indexes)
	if err != nil {
		return fmt.Errorf("error creando índices en material_event: %w", err)
	}
	log.Println("✅ Índices creados: material_event (con TTL de 90 días)")
	return nil
}

func createUnitSocialFeedIndexes(ctx context.Context, db *mongo.Database) error {
	collection := db.Collection("unit_social_feed")

	indexes := []mongo.IndexModel{
		{Keys: bson.D{{Key: "unit_id", Value: 1}, {Key: "created_at", Value: -1}}},
		{Keys: bson.D{{Key: "author_id", Value: 1}}},
		{Keys: bson.D{{Key: "post_type", Value: 1}}},
	}

	_, err := collection.Indexes().CreateMany(ctx, indexes)
	if err != nil {
		return fmt.Errorf("error creando índices en unit_social_feed: %w", err)
	}
	log.Println("✅ Índices creados: unit_social_feed")
	return nil
}

func createUserGraphRelationIndexes(ctx context.Context, db *mongo.Database) error {
	collection := db.Collection("user_graph_relation")

	indexes := []mongo.IndexModel{
		{Keys: bson.D{{Key: "user_id", Value: 1}, {Key: "relation_type", Value: 1}}},
		{Keys: bson.D{{Key: "related_user_id", Value: 1}}},
		{Keys: bson.D{{Key: "user_id", Value: 1}, {Key: "related_user_id", Value: 1}, {Key: "relation_type", Value: 1}}, Options: options.Index().SetUnique(true)},
	}

	_, err := collection.Indexes().CreateMany(ctx, indexes)
	if err != nil {
		return fmt.Errorf("error creando índices en user_graph_relation: %w", err)
	}
	log.Println("✅ Índices creados: user_graph_relation")
	return nil
}
