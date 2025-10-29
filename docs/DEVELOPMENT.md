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

### 3. Configurar Bases de Datos

```bash
# Opción A: Con Docker (recomendado)
make up

# Opción B: Manual
# Levantar PostgreSQL y MongoDB manualmente
# Ejecutar scripts en source/scripts/
```

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
