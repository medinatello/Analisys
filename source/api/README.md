# EduGo API - Documentación Completa

API REST completa para el sistema de gestión académica EduGo con especificación OpenAPI 3.0 e implementación en Go.

## 📁 Estructura del Proyecto

```
api/
├── swagger/
│   └── openapi.yaml           # Especificación OpenAPI 3.0
└── golang/
    ├── cmd/server/            # Aplicación principal
    ├── internal/              # Código interno de la API
    │   ├── handlers/          # Handlers HTTP
    │   ├── models/            # DTOs y modelos
    │   ├── middleware/        # Middlewares (auth, CORS)
    │   └── router/            # Configuración de rutas
    ├── docs/                  # Documentación Swagger (generada)
    ├── go.mod                 # Dependencias Go
    ├── Makefile              # Comandos útiles
    └── README.md             # Documentación detallada
```

## 🎯 Dos Componentes Principales

### 1. Especificación OpenAPI 3.0 (`swagger/`)

Documentación completa de la API en formato OpenAPI 3.0:

- **Archivo**: `openapi.yaml`
- **13 endpoints documentados** con schemas completos
- Request/Response examples
- Autenticación JWT documentada
- Validaciones y constraints

**Uso**:
- Importar en Postman/Insomnia
- Generar clientes automáticamente
- Documentación de referencia

### 2. Implementación Go (`golang/`)

API REST funcional con datos mock:

- **Framework**: Gin (HTTP router)
- **Documentación**: Swaggo (genera Swagger UI)
- **Autenticación**: JWT
- **Validación**: Gin bindings
- **Respuestas**: Mock data para desarrollo

## 🚀 Inicio Rápido

### Opción 1: Explorar la especificación OpenAPI

```bash
# Ver el archivo YAML
cat swagger/openapi.yaml

# Importar a Postman
# File > Import > swagger/openapi.yaml

# O usar un visualizador online
# https://editor.swagger.io/
```

### Opción 2: Ejecutar la API Go

```bash
cd golang

# Instalar dependencias
make install

# Generar Swagger y ejecutar
make run

# Acceder a Swagger UI
# http://localhost:8080/swagger/index.html
```

## 📡 Endpoints Disponibles

### 🔐 Autenticación
| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| POST | `/v1/auth/login` | Iniciar sesión y obtener JWT | No |

### 👥 Usuarios
| Método | Endpoint | Descripción | Roles |
|--------|----------|-------------|-------|
| POST | `/v1/users` | Crear nuevo usuario | Admin |

### 🏫 Unidades Académicas
| Método | Endpoint | Descripción | Roles |
|--------|----------|-------------|-------|
| GET | `/v1/units` | Listar unidades con paginación | Todos |
| POST | `/v1/units` | Crear unidad académica | Admin, Teacher |
| PATCH | `/v1/units/{unitId}` | Actualizar unidad | Admin, Teacher |
| POST | `/v1/units/{unitId}/members` | Asignar miembro | Admin, Teacher |

### 📚 Materiales Educativos
| Método | Endpoint | Descripción | Roles |
|--------|----------|-------------|-------|
| GET | `/v1/materials` | Listar materiales | Todos |
| POST | `/v1/materials` | Crear material | Teacher, Admin |
| GET | `/v1/materials/{materialId}` | Detalle + URL firmada | Todos |
| PATCH | `/v1/materials/{materialId}` | Actualizar material | Teacher, Admin |
| GET | `/v1/materials/{materialId}/summary` | Resumen IA | Todos |
| GET | `/v1/materials/{materialId}/assessment` | Evaluación | Todos |
| POST | `/v1/materials/{materialId}/assessment/attempts` | Registrar intento | Student |

## 🔑 Autenticación

### 1. Login
```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "docente@edugo.com",
  "password": "password123"
}
```

**Respuesta**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "docente@edugo.com",
    "system_role": "teacher"
  },
  "expires_at": "2024-01-20T10:00:00Z"
}
```

### 2. Usar el token
```bash
GET /api/v1/materials
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 📋 Schemas Principales

### Request Models

- **LoginRequest**: Credenciales de autenticación
- **CreateUserRequest**: Datos para crear usuario
- **CreateUnitRequest**: Datos para crear unidad académica
- **CreateMaterialRequest**: Datos para crear material
- **CreateAttemptRequest**: Respuestas de evaluación

### Response Models

- **LoginResponse**: Token JWT + datos de usuario
- **UserResponse**: Información de usuario
- **UnitResponse**: Unidad académica
- **MaterialResponse**: Material educativo
- **SummaryResponse**: Resumen generado por IA
- **AssessmentResponse**: Evaluación con preguntas
- **ErrorResponse**: Respuesta de error estándar

## 🎨 Características de la Implementación

### ✅ Implementado

- [x] 13 endpoints funcionales
- [x] Autenticación JWT
- [x] Middleware de autorización por roles
- [x] Validación de requests con bindings
- [x] Documentación Swagger auto-generada
- [x] CORS habilitado
- [x] Health check endpoint
- [x] Respuestas mock realistas
- [x] Paginación en listados
- [x] Códigos de error estándar

### 🚧 Pendiente (Integración futura)

- [ ] Conexión a PostgreSQL/MongoDB
- [ ] Lógica real de negocio
- [ ] Generación de URLs S3 firmadas
- [ ] Cálculo de scores de evaluaciones
- [ ] Rate limiting
- [ ] Tests unitarios e integración
- [ ] Logging estructurado
- [ ] Métricas y observabilidad

## 🛠️ Tecnologías

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Lenguaje | Go | 1.21+ |
| Framework HTTP | Gin | 1.9+ |
| Documentación | Swaggo | 1.16+ |
| Autenticación | JWT | go-jwt/jwt v5 |
| OpenAPI | Spec | 3.0.3 |

## 📦 Dependencias Principales

```go
github.com/gin-gonic/gin           // Framework HTTP
github.com/swaggo/gin-swagger      // Swagger UI
github.com/swaggo/swag            // Generador Swagger
github.com/golang-jwt/jwt/v5      // JSON Web Tokens
github.com/google/uuid            // UUIDs
```

## 🧪 Testing

### Probar con cURL

```bash
# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@edugo.com","password":"password123"}'

# Listar materiales (con token)
curl -X GET http://localhost:8080/api/v1/materials \
  -H "Authorization: Bearer {tu-token}"
```

### Probar con Swagger UI

1. Ejecutar la API: `cd golang && make run`
2. Abrir: http://localhost:8080/swagger/index.html
3. Hacer login en `/v1/auth/login`
4. Copiar el token devuelto
5. Click en "Authorize" 🔒 (arriba a la derecha)
6. Pegar: `Bearer {token}`
7. Probar cualquier endpoint

## 🔄 Flujo de Desarrollo

### 1. Diseño (OpenAPI)
Editar `swagger/openapi.yaml` para definir contratos

### 2. Implementación (Go)
Implementar handlers con anotaciones Swaggo

### 3. Documentación
Generar Swagger: `make swag`

### 4. Testing
Probar en Swagger UI o Postman

## 📚 Recursos Adicionales

### Especificación OpenAPI
- [OpenAPI 3.0 Spec](https://swagger.io/specification/)
- [Editor Online](https://editor.swagger.io/)

### Swaggo
- [Documentación Swaggo](https://github.com/swaggo/swag)
- [Anotaciones disponibles](https://github.com/swaggo/swag#declarative-comments-format)

### Gin
- [Documentación Gin](https://gin-gonic.com/docs/)
- [Validaciones](https://github.com/go-playground/validator)

## 🚀 Próximos Pasos

Para pasar de mock a producción:

1. **Conectar con Base de Datos**
   ```go
   // Usar modelos de source/golang/separada o juntos
   db := setupDatabase()
   handlers := NewHandlers(db)
   ```

2. **Implementar Repositorios**
   ```go
   type MaterialRepository interface {
       List(filters) ([]Material, error)
       Create(material) error
       // ...
   }
   ```

3. **Añadir Servicios de Negocio**
   ```go
   type MaterialService struct {
       repo MaterialRepository
       s3   S3Client
       nlp  NLPService
   }
   ```

4. **Tests**
   ```go
   func TestCreateMaterial(t *testing.T) {
       // ...
   }
   ```

## 📞 Soporte

Para dudas o issues:
- Ver documentación en `golang/README.md`
- Revisar especificación en `swagger/openapi.yaml`
- Explorar Swagger UI en desarrollo

---

**Versión**: 1.0.0
**Estado**: ✅ Mock API funcional, lista para integración
