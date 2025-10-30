# 🛠️ GUÍA DE DESARROLLO - EduGo

## 🏁 Setup Inicial

### 1. Clonar Repositorio
```bash
git clone <repo-url>
cd Analisys
```

### 2. Instalar Dependencias

```bash
# Instalar swag para Swagger
go install github.com/swaggo/swag/cmd/swag@latest

# Descargar dependencias de cada servicio
cd source/api-mobile && go mod download
cd ../api-administracion && go mod download
cd ../worker && go mod download
```

### 3. Configurar Variables de Ambiente

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar .env y configurar:
# - APP_ENV=local (o dev, qa, prod)
# - OPENAI_API_KEY=sk-your-key
# - Otros secretos si es necesario
```

### 4. Configurar Bases de Datos

```bash
# Opción A: Con Docker (recomendado)
make up

# Opción B: Manual
# Levantar PostgreSQL y MongoDB manualmente
# Ejecutar scripts en source/scripts/
```

---

## ⚙️ Configuración por Ambientes

### Sistema de Configuración

Cada servicio usa **Viper** para gestionar configuración por ambientes (similar a Spring Boot profiles).

**Estructura**:
```
source/{servicio}/config/
├── config.yaml         # Configuración base (común)
├── config-local.yaml   # Local development
├── config-dev.yaml     # Development server
├── config-qa.yaml      # QA/Staging
├── config-prod.yaml    # Production
└── README.md           # Documentación
```

### Cambiar Entre Ambientes

```bash
# Local (default)
APP_ENV=local go run source/api-mobile/cmd/main.go

# Development
APP_ENV=dev go run source/api-mobile/cmd/main.go

# QA
APP_ENV=qa go run source/api-mobile/cmd/main.go

# Production
APP_ENV=prod OPENAI_API_KEY=sk-xxx go run source/api-mobile/cmd/main.go
```

### Precedencia de Configuración

1. **Variables de ambiente** (ej: `EDUGO_MOBILE_SERVER_PORT=9090`)
2. **Archivo específico** (ej: `config-dev.yaml`)
3. **Archivo base** (`config.yaml`)
4. **Defaults** (valores por defecto en código)

### Variables de Ambiente por Servicio

**Prefijos**:
- API Mobile: `EDUGO_MOBILE_`
- API Administración: `EDUGO_ADMIN_`
- Worker: `EDUGO_WORKER_`

**Ejemplos**:
```bash
# Cambiar puerto de API Mobile
EDUGO_MOBILE_SERVER_PORT=9090 go run source/api-mobile/cmd/main.go

# Cambiar log level
EDUGO_MOBILE_LOGGING_LEVEL=debug go run source/api-mobile/cmd/main.go
```

### Secretos Requeridos

Todos los ambientes (excepto local) requieren estas variables:

```bash
export POSTGRES_PASSWORD=your-password
export MONGODB_URI=mongodb://user:pass@host:27017/edugo
export RABBITMQ_URL=amqp://user:pass@host:5672/
export OPENAI_API_KEY=sk-your-key
```

**IMPORTANTE**: Nunca commitear secretos en archivos YAML.

### Agregar Nueva Configuración

1. Editar `internal/config/config.go` (agregar campo al struct)
2. Agregar valor en `config/config.yaml` (base)
3. Sobrescribir en archivos específicos si es necesario
4. Usar en código: `cfg.NuevoCampo`
5. Regenerar si es necesario

Ver ejemplos completos en `source/*/config/README.md`

---

## 📝 Agregar Nuevos Endpoints

### 1. Crear Modelos

**Request** (`internal/models/request/`):
```go
type MyRequest struct {
    Field string `json:"field" binding:"required"`
}
```

**Response** (`internal/models/response/`):
```go
type MyResponse struct {
    Data string `json:"data" example:"example"`
} // @name MyResponse
```

### 2. Crear Handler

En `internal/handlers/`:
```go
// MyHandler godoc
// @Summary Descripción breve
// @Description Descripción detallada
// @Tags TagName
// @Accept json
// @Produce json
// @Param body body request.MyRequest true "Descripción"
// @Success 200 {object} response.MyResponse
// @Security BearerAuth
// @Router /my-endpoint [post]
func MyHandler(c *gin.Context) {
    // Implementación
}
```

### 3. Regenerar Swagger

```bash
cd source/api-mobile
swag init -g cmd/main.go -o docs
```

### 4. Ejecutar Tests

```bash
go test ./...
```

---

## 🧪 Ejecutar Tests

### Tests Unitarios
```bash
# Todos los tests
cd source/api-mobile && go test ./...

# Tests específicos
go test ./internal/models/response/... -v

# Con cobertura
go test ./... -cover
```

---

## 🔄 Workflow de Desarrollo

### 1. Crear Branch
```bash
git checkout -b feature/nueva-funcionalidad
```

### 2. Desarrollar
- Escribir tests primero (TDD)
- Implementar funcionalidad
- Regenerar Swagger si es necesario

### 3. Verificar
```bash
gofmt -w .                    # Formatear código
go vet ./...                  # Linter
go test ./...                 # Tests
swag init -g cmd/main.go -o docs  # Swagger
```

### 4. Commit
```bash
git add .
git commit -m "feat: descripción del cambio"
```

---

## 📚 Convenciones de Código

### Nombres
- **Handlers**: PascalCase (`GetMaterials`, `CreateUser`)
- **Structs**: PascalCase (`MaterialSummaryResponse`)
- **Campos**: PascalCase (`TotalPoints`)
- **Paquetes**: lowercase (`handlers`, `models`)

### Comentarios Swagger
- Siempre incluir `// @name` para structs de respuesta
- Usar `example:` para ejemplos en Swagger
- Usar `enums:` para valores permitidos

### Estructura de Archivos
```
internal/
├── handlers/       # Handlers HTTP
├── middleware/     # Middleware (auth, etc.)
├── models/
│   ├── request/    # Request DTOs
│   ├── response/   # Response DTOs
│   ├── mongodb/    # MongoDB documents
│   └── enum/       # Enumeraciones
└── services/       # Lógica de negocio (futuro)
```

---

## 🐛 Debugging

### Ver Logs
```bash
make logs                # Todos los servicios
make logs-api-mobile     # Solo API Mobile
make logs-api-admin      # Solo API Admin
make logs-worker         # Solo Worker
```

### Conectar a Bases de Datos
```bash
# PostgreSQL
docker exec -it edugo-postgres psql -U edugo_user -d edugo

# MongoDB
docker exec -it edugo-mongodb mongosh -u edugo_admin -p edugo_pass edugo
```

---

## 🔧 Troubleshooting

### Error: "no Go files"
```bash
# Asegúrate de estar en el directorio correcto
cd source/api-mobile
swag init -g cmd/main.go -o docs
```

### Error: Dependencias
```bash
go mod tidy
go mod download
```

### Limpiar y Reconstruir
```bash
make clean
make build
make up
```

---

## 📊 Próximos Pasos

1. **Conectar handlers a BD real** (actualmente usan mocks)
2. **Implementar autenticación JWT real**
3. **Implementar Worker con OpenAI**
4. **Agregar más tests** (coverage > 80%)
5. **CI/CD** (GitHub Actions)

Ver roadmap completo en [PLAN_REFACTORIZACION.md](../PLAN_REFACTORIZACION.md)

---

**Última actualización**: 2025-10-29
