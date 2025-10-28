# EduGo API - REST API con Swagger

API REST completa para el sistema de gestión académica EduGo, implementada con Go, Gin y Swagger/OpenAPI.

## 🚀 Características

- ✅ API REST completa con 13 endpoints
- ✅ Documentación OpenAPI 3.0 y Swagger UI
- ✅ Autenticación JWT
- ✅ Validación de requests con Gin bindings
- ✅ Responses mock para desarrollo
- ✅ CORS habilitado
- ✅ Health check endpoint
- ✅ Middlewares de autenticación y autorización

## 📁 Estructura del Proyecto

```
api/golang/
├── cmd/
│   └── server/
│       └── main.go              # Punto de entrada principal
├── internal/
│   ├── handlers/               # Handlers de endpoints
│   │   ├── auth.go            # Autenticación
│   │   ├── users.go           # Usuarios
│   │   ├── units.go           # Unidades académicas
│   │   └── materials.go       # Materiales y evaluaciones
│   ├── models/                # Modelos de datos
│   │   ├── request.go         # Request DTOs
│   │   └── response.go        # Response DTOs
│   ├── middleware/            # Middlewares
│   │   └── auth.go            # Auth middleware
│   └── router/                # Configuración de rutas
│       └── router.go
├── docs/                       # Documentación Swagger (generada)
├── go.mod
├── Makefile
└── README.md
```

## 🛠️ Instalación

### Prerrequisitos

- Go 1.21 o superior
- Make (opcional, pero recomendado)

### 1. Instalar dependencias

```bash
make install
# o
go mod download
```

### 2. Instalar Swag (para generar documentación)

```bash
go install github.com/swaggo/swag/cmd/swag@latest
```

## 🏃 Ejecución

### Generar documentación Swagger y ejecutar

```bash
make run
```

O manualmente:

```bash
swag init -g cmd/server/main.go -o docs
go run cmd/server/main.go
```

### Modo desarrollo con hot reload

```bash
make dev
# Requiere air: go install github.com/cosmtrek/air@latest
```

### Compilar binario

```bash
make build
./bin/edugo-api
```

## 📚 Documentación

Una vez que el servidor esté corriendo, accede a:

**Swagger UI**: [http://localhost:8080/swagger/index.html](http://localhost:8080/swagger/index.html)

**Health Check**: [http://localhost:8080/health](http://localhost:8080/health)

## 🔐 Autenticación

### 1. Obtener token

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "docente@edugo.com",
    "password": "password123"
  }'
```

Respuesta:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "...",
    "email": "docente@edugo.com",
    "system_role": "teacher",
    "status": "active"
  },
  "expires_at": "2024-01-20T10:00:00Z"
}
```

### 2. Usar el token en requests

```bash
curl -X GET http://localhost:8080/api/v1/materials \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## 📡 Endpoints Disponibles

### Autenticación
- `POST /api/v1/auth/login` - Iniciar sesión

### Usuarios
- `POST /api/v1/users` - Crear usuario (admin)

### Unidades Académicas
- `GET /api/v1/units` - Listar unidades
- `POST /api/v1/units` - Crear unidad
- `PATCH /api/v1/units/{unitId}` - Actualizar unidad
- `POST /api/v1/units/{unitId}/members` - Asignar miembro

### Materiales
- `GET /api/v1/materials` - Listar materiales
- `POST /api/v1/materials` - Crear material
- `GET /api/v1/materials/{materialId}` - Detalle de material
- `PATCH /api/v1/materials/{materialId}` - Actualizar material
- `GET /api/v1/materials/{materialId}/summary` - Obtener resumen
- `GET /api/v1/materials/{materialId}/assessment` - Obtener evaluación
- `POST /api/v1/materials/{materialId}/assessment/attempts` - Registrar intento

## 🧪 Ejemplos de Uso

### Crear una unidad académica

```bash
curl -X POST http://localhost:8080/api/v1/units \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "school_id": "11111111-1111-1111-1111-111111111111",
    "unit_type": "section",
    "name": "6º A",
    "code": "6A-2024"
  }'
```

### Crear un material educativo

```bash
curl -X POST http://localhost:8080/api/v1/materials \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "subject_id": "s1000001-0000-0000-0000-000000000001",
    "title": "Geometría Básica",
    "description": "Introducción a las figuras geométricas"
  }'
```

### Registrar intento de evaluación

```bash
curl -X POST http://localhost:8080/api/v1/materials/{materialId}/assessment/attempts \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [
      {
        "question_id": "q-001",
        "answer": "A"
      },
      {
        "question_id": "q-002",
        "answer": "B"
      }
    ]
  }'
```

## ⚙️ Configuración

Variables de entorno disponibles:

```bash
# Puerto del servidor (default: 8080)
PORT=8080

# Secret para firmar JWT (cambiar en producción)
JWT_SECRET=edugo-secret-key-change-in-production
```

Ejemplo de uso:

```bash
export PORT=3000
export JWT_SECRET=mi-secreto-super-seguro
make run
```

## 🏗️ Arquitectura

### Capas

1. **Handlers**: Procesan las peticiones HTTP y devuelven respuestas
2. **Models**: Definen la estructura de requests y responses
3. **Middleware**: Validan autenticación y autorización
4. **Router**: Configura las rutas y aplica middlewares

### Roles y Permisos

| Endpoint | Admin | Teacher | Student | Guardian |
|----------|-------|---------|---------|----------|
| POST /users | ✅ | ❌ | ❌ | ❌ |
| POST /units | ✅ | ✅ | ❌ | ❌ |
| POST /materials | ✅ | ✅ | ❌ | ❌ |
| GET /materials | ✅ | ✅ | ✅ | ✅ |
| POST /assessment/attempts | ❌ | ❌ | ✅ | ❌ |

## 🔄 Próximos Pasos

Actualmente todos los endpoints devuelven datos mock. Para conectar con la base de datos real:

1. **Integrar con PostgreSQL/MongoDB**
   - Usar los modelos de `source/golang/separada` o `source/golang/juntos`
   - Conectar handlers con repositories

2. **Implementar lógica de negocio**
   - Validaciones reales
   - Cálculo de scores de evaluaciones
   - Generación de URLs firmadas para S3

3. **Añadir tests**
   - Unit tests para handlers
   - Integration tests con base de datos de prueba

4. **Mejorar seguridad**
   - Rate limiting
   - Validación de inputs más robusta
   - Rotación de secrets JWT

## 📝 Comandos Make Disponibles

```bash
make help       # Ver todos los comandos
make install    # Instalar dependencias
make swag       # Generar documentación Swagger
make run        # Ejecutar servidor
make dev        # Modo desarrollo con hot reload
make build      # Compilar binario
make test       # Ejecutar tests
make clean      # Limpiar archivos generados
```

## 📄 OpenAPI Spec

La especificación OpenAPI 3.0 completa está disponible en:
- **YAML**: `../swagger/openapi.yaml`
- **JSON**: Generado en `docs/swagger.json` después de ejecutar `make swag`

## 🐳 Docker (Opcional)

```bash
# Construir imagen
make docker-build

# Ejecutar contenedor
make docker-run
```

## 📞 Soporte

Para reportar bugs o solicitar features, por favor crea un issue en el repositorio.

---

**Versión**: 1.0.0
**Tecnologías**: Go 1.21, Gin, Swaggo, JWT
