# 🤝 Guía de Contribución - EduGo

## 🏁 Setup de Entorno

### 1. Clonar y Configurar

```bash
git clone <repo-url>
cd Analisys
cp .env.example .env
# Editar .env con tus credenciales
```

### 2. Instalar Herramientas

```bash
make tools  # Instala swag + golangci-lint en todos los proyectos
```

### 3. Levantar Infraestructura

```bash
make up  # Levanta PostgreSQL, MongoDB, RabbitMQ y las 3 APIs
```

## 🔧 Workflow de Desarrollo

### 1. Crear Branch

```bash
git checkout -b feature/nueva-funcionalidad
```

### 2. Desarrollo

Trabajar en un proyecto específico:

```bash
cd source/api-mobile

# Instalar deps
make deps

# Ejecutar en desarrollo
make run

# O con debugging en VSCode (F5)
```

### 3. Validar Cambios

```bash
# Formatear código
make fmt

# Tests
make test

# Coverage
make test-coverage

# Linter
make lint

# Auditoría completa
make audit

# Regenerar Swagger (si modificaste handlers)
make swagger
```

### 4. Commit

```bash
git add .
git commit -m "feat: descripción del cambio"
```

## 📝 Convenciones

### Commits

Seguir [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - Nueva funcionalidad
- `fix:` - Bug fix
- `docs:` - Documentación
- `chore:` - Tareas de mantenimiento
- `test:` - Tests
- `refactor:` - Refactorización

### Código Go

- Seguir [Effective Go](https://go.dev/doc/effective_go)
- Usar `gofmt` (automático con `make fmt`)
- Pasar `go vet` y `golangci-lint`
- Coverage mínimo: 70% para nuevos features

### Swagger

- Documentar todos los endpoints con comentarios `// @`
- Incluir ejemplos en structs
- Regenerar con `make swagger`

## 🧪 Testing

### Tests Unitarios

```bash
# Ejecutar tests
make test

# Con coverage
make test-coverage

# Test específico
go test -v -run TestMaterialSummaryResponse_JSON ./internal/models/response/
```

### Tests de Integración

```bash
make test-integration
```

## 🐳 Docker

### Desarrollo Local

```bash
# Levantar todo
make up

# Solo un servicio
cd source/api-mobile
make docker-run

# Ver logs
make docker-logs
```

## 📚 Comandos Útiles

```bash
# Desde raíz
make help              # Ver todos los comandos
make build-all         # Compilar los 3 proyectos
make test-all          # Tests en los 3 proyectos
make ci                # Pipeline CI completo

# Desde un proyecto
cd source/api-mobile
make help              # Ver comandos del proyecto
make dev               # Desarrollo completo
make audit             # Auditoría de calidad
```

## ✅ Checklist Pre-PR

Antes de crear un Pull Request:

- [ ] Código formateado (`make fmt`)
- [ ] Tests pasando (`make test`)
- [ ] Coverage adecuado (`make test-coverage`)
- [ ] Sin errores de linter (`make lint`)
- [ ] Swagger actualizado si es necesario (`make swagger`)
- [ ] Documentación actualizada
- [ ] Commits con mensajes descriptivos

## 🤔 ¿Dudas?

Consultar:
- [DEVELOPMENT.md](docs/DEVELOPMENT.md) - Guía de desarrollo
- [DOCKER.md](DOCKER.md) - Guía de Docker
- [README.md](README.md) - Documentación principal

---

**¡Gracias por contribuir a EduGo!** 🎉
