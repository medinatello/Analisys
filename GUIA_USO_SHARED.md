# GUÍA DE USO DEL MÓDULO SHARED

**Fecha:** 2025-10-29
**Módulo:** github.com/edugo/shared
**Status:** ✅ Completamente implementado y configurado

---

## 📋 CONFIGURACIÓN COMPLETADA

Los 3 proyectos ya están configurados para usar el módulo shared:

```bash
✓ api-administracion - configurado
✓ api-mobile - configurado
✓ worker - configurado
```

**Verificación:**
- Todos compilan sin errores
- Dependencia agregada en go.mod
- Replace configurado correctamente

---

## 📦 PAQUETES DISPONIBLES

### 1. Logger - Logging Estructurado

```go
import "github.com/edugo/shared/pkg/logger"

// Crear logger
log := logger.NewZapLogger("info", "json")
defer log.Sync()

// Usar logger
log.Info("servidor iniciado", "port", 8080, "env", "production")
log.Error("error de conexión", "error", err, "host", "localhost")
log.Debug("query ejecutado", "query", sql, "duration_ms", 150)

// Logger con contexto
requestLogger := log.With("request_id", reqID, "user_id", userID)
requestLogger.Info("procesando request")
requestLogger.Error("request falló", "error", err)
```

**Niveles disponibles:** debug, info, warn, error, fatal
**Formatos:** json (producción), console (desarrollo con colores)

---

### 2. Database - PostgreSQL

```go
import "github.com/edugo/shared/pkg/database/postgres"

// Configurar
cfg := postgres.Config{
    Host:           "localhost",
    Port:           5432,
    Database:       "edugo",
    User:           "edugo_user",
    Password:       "edugo_pass",
    MaxConnections: 25,
    SSLMode:        "disable",
}

// Conectar
db, err := postgres.Connect(cfg)
if err != nil {
    log.Fatal("failed to connect", "error", err)
}
defer postgres.Close(db)

// Health check
if err := postgres.HealthCheck(db); err != nil {
    log.Error("database unhealthy", "error", err)
}

// Transacción automática
err = postgres.WithTransaction(ctx, db, func(tx *sql.Tx) error {
    // Todas las operaciones aquí
    _, err := tx.ExecContext(ctx, "INSERT INTO users ...")
    if err != nil {
        return err // auto-rollback
    }

    _, err = tx.ExecContext(ctx, "UPDATE stats ...")
    return err // auto-commit si nil
})
```

---

### 3. Database - MongoDB

```go
import "github.com/edugo/shared/pkg/database/mongodb"

// Configurar
cfg := mongodb.Config{
    URI:         "mongodb://localhost:27017",
    Database:    "edugo",
    Timeout:     10 * time.Second,
    MaxPoolSize: 100,
}

// Conectar
client, err := mongodb.Connect(cfg)
if err != nil {
    log.Fatal("failed to connect", "error", err)
}
defer mongodb.Close(client)

// Obtener database
db := mongodb.GetDatabase(client, "edugo")

// Usar colecciones
collection := db.Collection("materials")
result, err := collection.InsertOne(ctx, document)
```

---

### 4. Errors - Error Handling

```go
import "github.com/edugo/shared/pkg/errors"

// Crear errores específicos
err := errors.NewNotFoundError("user").
    WithField("user_id", userID).
    WithDetails("user not found in database")

err := errors.NewValidationError("invalid email format").
    WithField("email", email)

err := errors.NewDatabaseError("insert", dbErr).
    WithField("table", "users")

// En HTTP handlers (Gin)
func CreateUser(c *gin.Context) {
    user, err := service.CreateUser(ctx, req)
    if err != nil {
        if appErr, ok := errors.GetAppError(err); ok {
            c.JSON(appErr.StatusCode, gin.H{
                "error": appErr.Message,
                "code":  appErr.Code,
            })
            return
        }
        c.JSON(500, gin.H{"error": "internal error"})
        return
    }

    c.JSON(201, user)
}

// Errores disponibles
errors.NewValidationError(msg)
errors.NewNotFoundError(resource)
errors.NewAlreadyExistsError(resource)
errors.NewUnauthorizedError(msg)
errors.NewForbiddenError(msg)
errors.NewInternalError(msg, err)
errors.NewDatabaseError(operation, err)
errors.NewBusinessRuleError(msg)
errors.NewConflictError(msg)
```

---

### 5. Types - UUID y Enums

```go
import (
    "github.com/edugo/shared/pkg/types"
    "github.com/edugo/shared/pkg/types/enum"
)

// UUID
id := types.NewUUID()
idStr := id.String()

parsed, err := types.ParseUUID("123e4567-...")
if err != nil {
    // UUID inválido
}

// En structs (JSON + SQL)
type User struct {
    ID    types.UUID      `json:"id" db:"id"`
    Email string          `json:"email"`
    Role  enum.SystemRole `json:"role"`
}

// Enums disponibles
role := enum.SystemRoleTeacher
role.IsValid() // true
role.String()  // "teacher"

status := enum.MaterialStatusPublished
progress := enum.ProgressStatusCompleted
processing := enum.ProcessingStatusPending
assessmentType := enum.AssessmentTypeMultipleChoice
eventType := enum.EventMaterialUploaded
```

---

### 6. Validator - Validaciones

```go
import "github.com/edugo/shared/pkg/validator"

// En un request DTO
func (r *CreateUserRequest) Validate() error {
    v := validator.New()

    v.Required(r.Email, "email")
    v.Email(r.Email, "email")
    v.MinLength(r.Email, 5, "email")
    v.MaxLength(r.Email, 100, "email")

    v.Required(r.Password, "password")
    v.MinLength(r.Password, 8, "password")

    v.Required(r.FirstName, "first_name")
    v.Name(r.FirstName, "first_name")

    v.InSlice(r.Role, []string{"teacher", "student", "admin"}, "role")

    // Retorna AppError con todos los errores
    return v.GetError()
}

// Helpers independientes
if !validator.IsValidEmail(email) {
    return errors.NewValidationError("invalid email")
}

if !validator.IsValidUUID(userID) {
    return errors.NewValidationError("invalid user ID")
}
```

---

### 7. Auth - JWT

```go
import "github.com/edugo/shared/pkg/auth"

// En main.go o config
jwtManager := auth.NewJWTManager(
    os.Getenv("JWT_SECRET"),
    "edugo-api",
)

// Generar token (login)
token, err := jwtManager.GenerateToken(
    user.ID,
    user.Email,
    user.Role,
    24 * time.Hour, // expira en 24h
)

// Validar token (middleware)
func AuthMiddleware(jwtManager *auth.JWTManager) gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" {
            c.AbortWithStatus(401)
            return
        }

        tokenString := strings.TrimPrefix(authHeader, "Bearer ")

        claims, err := jwtManager.ValidateToken(tokenString)
        if err != nil {
            c.AbortWithStatus(401)
            return
        }

        // Agregar claims al contexto
        c.Set("user_id", claims.UserID)
        c.Set("email", claims.Email)
        c.Set("role", claims.Role)

        c.Next()
    }
}

// Usar en handler
func GetProfile(c *gin.Context) {
    userID := c.GetString("user_id")
    role := c.GetString("role")
    // ...
}
```

---

### 8. Messaging - RabbitMQ Publisher

```go
import "github.com/edugo/shared/pkg/messaging"

// Conectar
conn, err := messaging.Connect("amqp://user:pass@localhost:5672/")
if err != nil {
    log.Fatal("rabbitmq connect failed", "error", err)
}
defer conn.Close()

// Declarar exchange
err = conn.DeclareExchange(messaging.ExchangeConfig{
    Name:    "edugo_events",
    Type:    "topic",
    Durable: true,
})

// Crear publisher
publisher := messaging.NewPublisher(conn)

// Publicar evento
event := MaterialUploadedEvent{
    EventType:   "material.uploaded",
    MaterialID:  materialID,
    AuthorID:    userID,
    S3Key:       s3Key,
    Timestamp:   time.Now(),
}

err = publisher.PublishWithPriority(
    ctx,
    "edugo_events",
    "material.uploaded",
    event,
    10, // prioridad alta
)
```

---

### 9. Messaging - RabbitMQ Consumer

```go
import "github.com/edugo/shared/pkg/messaging"

// Conectar
conn, err := messaging.Connect("amqp://user:pass@localhost:5672/")
defer conn.Close()

// Declarar cola
queue, err := conn.DeclareQueue(messaging.QueueConfig{
    Name:    "material_processing",
    Durable: true,
    Args: map[string]interface{}{
        "x-max-priority": 10,
    },
})

// Bind a exchange
err = conn.BindQueue(
    queue.Name,
    "material.uploaded",
    "edugo_events",
)

// Configurar prefetch
conn.SetPrefetchCount(5)

// Crear consumer
consumer := messaging.NewConsumer(conn, messaging.ConsumerConfig{
    Name:    "material_processor",
    AutoAck: false, // manual ack
})

// Consumir mensajes
handler := func(ctx context.Context, body []byte) error {
    var event MaterialUploadedEvent
    if err := messaging.UnmarshalMessage(body, &event); err != nil {
        return err // nack con requeue
    }

    // Procesar evento
    log.Info("processing event", "material_id", event.MaterialID)

    // Si procesa correctamente, retorna nil (ack automático)
    return nil
}

err = consumer.Consume(ctx, queue.Name, handler)
```

---

### 10. Config - Environment Variables

```go
import "github.com/edugo/shared/pkg/config"

// Obtener con default
port := config.GetEnv("PORT", "8080")
dbHost := config.GetEnv("DB_HOST", "localhost")

// Obtener requerido (panic si no existe)
dbPassword := config.GetEnvRequired("DB_PASSWORD")
jwtSecret := config.MustGetEnv("JWT_SECRET")

// Tipos específicos
dbPort := config.GetEnvInt("DB_PORT", 5432)
debugMode := config.GetEnvBool("DEBUG", false)
timeout := config.GetEnvDuration("TIMEOUT", 30*time.Second)

// Helpers de ambiente
env := config.GetEnvironment() // "development", "staging", "production"

if config.IsDevelopment() {
    // Habilitar debug mode
}

if config.IsProduction() {
    // Deshabilitar debug endpoints
}
```

---

## 🎯 EJEMPLO COMPLETO: API Handler

```go
package handler

import (
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/edugo/shared/pkg/errors"
    "github.com/edugo/shared/pkg/logger"
    "github.com/edugo/shared/pkg/validator"
    "github.com/edugo/shared/pkg/types/enum"
)

type UserHandler struct {
    userService UserService
    logger      logger.Logger
}

func NewUserHandler(userService UserService, logger logger.Logger) *UserHandler {
    return &UserHandler{
        userService: userService,
        logger:      logger,
    }
}

// CreateUser godoc
// @Summary Create a new user
// @Tags users
// @Accept json
// @Produce json
// @Param request body CreateUserRequest true "User data"
// @Success 201 {object} UserResponse
// @Failure 400 {object} ErrorResponse
// @Router /v1/users [post]
func (h *UserHandler) CreateUser(c *gin.Context) {
    var req CreateUserRequest

    // Bind JSON
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
        return
    }

    // Validar con shared/validator
    v := validator.New()
    v.Required(req.Email, "email")
    v.Email(req.Email, "email")
    v.Required(req.FirstName, "first_name")
    v.Name(req.FirstName, "first_name")
    v.InSlice(req.Role, []string{"teacher", "student", "admin"}, "role")

    if v.HasErrors() {
        err := v.GetError()
        h.logger.Warn("validation failed", "errors", v.GetErrors())
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Llamar servicio
    user, err := h.userService.CreateUser(c.Request.Context(), req)
    if err != nil {
        // Manejar AppError
        if appErr, ok := errors.GetAppError(err); ok {
            h.logger.Error("create user failed",
                "error", appErr.Message,
                "code", appErr.Code,
            )
            c.JSON(appErr.StatusCode, gin.H{
                "error": appErr.Message,
                "code":  appErr.Code,
            })
            return
        }

        // Error no manejado
        h.logger.Error("unexpected error", "error", err)
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "internal server error",
        })
        return
    }

    h.logger.Info("user created", "user_id", user.ID, "email", user.Email)
    c.JSON(http.StatusCreated, user)
}
```

---

## 🎯 EJEMPLO COMPLETO: Worker Processor

```go
package processor

import (
    "context"

    "github.com/edugo/shared/pkg/database/postgres"
    "github.com/edugo/shared/pkg/database/mongodb"
    "github.com/edugo/shared/pkg/errors"
    "github.com/edugo/shared/pkg/logger"
    "github.com/edugo/shared/pkg/messaging"
)

type MaterialProcessor struct {
    db         *sql.DB
    mongoClient *mongo.Client
    logger     logger.Logger
}

func NewMaterialProcessor(
    db *sql.DB,
    mongoClient *mongo.Client,
    logger logger.Logger,
) *MaterialProcessor {
    return &MaterialProcessor{
        db:         db,
        mongoClient: mongoClient,
        logger:     logger,
    }
}

func (p *MaterialProcessor) ProcessMaterialUploaded(ctx context.Context, body []byte) error {
    var event MaterialUploadedEvent

    // Unmarshal usando shared
    if err := messaging.UnmarshalMessage(body, &event); err != nil {
        p.logger.Error("failed to unmarshal event", "error", err)
        return err
    }

    p.logger.Info("processing material",
        "material_id", event.MaterialID,
        "author_id", event.AuthorID,
    )

    // Usar transacción de shared
    err := postgres.WithTransaction(ctx, p.db, func(tx *sql.Tx) error {
        // 1. Actualizar estado en PostgreSQL
        _, err := tx.ExecContext(ctx,
            "UPDATE materials SET status = $1 WHERE id = $2",
            "processing", event.MaterialID,
        )
        if err != nil {
            return errors.NewDatabaseError("update material status", err)
        }

        // 2. Más operaciones dentro de la transacción
        // ...

        return nil // auto-commit
    })

    if err != nil {
        p.logger.Error("transaction failed", "error", err)
        return err // requeue message
    }

    // 3. Guardar en MongoDB (fuera de la transacción SQL)
    mongoDB := mongodb.GetDatabase(p.mongoClient, "edugo")
    collection := mongoDB.Collection("material_summaries")

    _, err = collection.InsertOne(ctx, bson.M{
        "material_id": event.MaterialID,
        "summary":     "AI generated summary here",
        "created_at":  time.Now(),
    })

    if err != nil {
        p.logger.Error("mongodb insert failed", "error", err)
        return errors.NewDatabaseError("insert summary", err)
    }

    p.logger.Info("material processed successfully",
        "material_id", event.MaterialID,
    )

    return nil // ack message
}
```

---

## 📚 PRÓXIMOS PASOS

### Para API Administración:
1. Refactorizar handlers para usar `shared/errors`
2. Reemplazar logger actual con `shared/logger`
3. Usar `shared/validator` en requests
4. Implementar middleware JWT con `shared/auth`

### Para API Mobile:
1. Mismo que API Administración
2. Usar `shared/messaging` para publicar eventos
3. Integrar `shared/database/mongodb` para summaries

### Para Worker:
1. Refactorizar consumers con `shared/messaging`
2. Usar `shared/logger` en todo el worker
3. Implementar procesadores con `shared/database`
4. Manejar errores con `shared/errors`

---

## ✅ VERIFICACIÓN

Para verificar que shared funciona correctamente en cualquier proyecto:

```bash
# Verificar que compile
cd source/api-administracion  # o api-mobile, o worker
go build ./...

# Verificar dependencias
go mod graph | grep shared

# Salida esperada:
# github.com/edugo/api-administracion github.com/edugo/shared@v0.0.0-00010101000000-000000000000
```

---

## 🎉 BENEFICIOS

✅ **DRY** - No duplicar código entre proyectos
✅ **Consistencia** - Mismo logger, errores, validaciones
✅ **Mantenibilidad** - Cambios en shared afectan a todos
✅ **Testing** - Interfaces facilitan mocking
✅ **Profesionalismo** - Código production-ready

---

**FIN DE LA GUÍA**

*Última actualización: 2025-10-29*
*Módulo shared v1.0.0 - Completamente implementado*
