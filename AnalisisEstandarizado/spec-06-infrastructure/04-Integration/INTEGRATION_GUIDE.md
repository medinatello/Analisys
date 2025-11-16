# 🔗 Guía de Integración - edugo-infrastructure

**Fecha:** 16 de Noviembre, 2025  
**Versión:** v0.1.1

---

## 🎯 Cómo Integrar infrastructure en tu Proyecto

---

## 📦 Paso 1: Agregar Dependencia

### En go.mod

```go
module github.com/EduGoGroup/edugo-api-mobile

go 1.24

require (
    // Infrastructure modules
    github.com/EduGoGroup/edugo-infrastructure/database v0.1.1
    github.com/EduGoGroup/edugo-infrastructure/schemas v0.1.1
    
    // Shared modules
    github.com/EduGoGroup/edugo-shared/auth v0.7.0
    // ... otros módulos
)
```

### Instalar

```bash
go get github.com/EduGoGroup/edugo-infrastructure/database@v0.1.1
go get github.com/EduGoGroup/edugo-infrastructure/schemas@v0.1.1
go mod tidy
```

---

## 🗄️ Paso 2: Usar Migraciones

### Si eres Owner de Tablas (api-admin)

**Ya NO necesitas crear migraciones locales.**

Las migraciones están en `infrastructure/database/migrations/`.

**Setup local:**
```bash
# Opción 1: Usando infrastructure
cd /path/to/edugo-infrastructure
make dev-setup

# Opción 2: Manualmente
cd /path/to/edugo-infrastructure/database/migrations
psql -h localhost -U edugo -d edugo_dev -f 001_create_users.up.sql
psql -h localhost -U edugo -d edugo_dev -f 002_create_schools.up.sql
# ... hasta 008
```

**CI/CD:**
```yaml
# .github/workflows/ci.yml
- name: Run migrations
  run: |
    git clone https://github.com/EduGoGroup/edugo-infrastructure
    cd edugo-infrastructure/database/migrations
    # Ejecutar migraciones (cuando migrate.go esté listo)
```

---

### Si eres Consumer de Tablas (api-mobile)

**Solo necesitas que las migraciones se ejecuten ANTES.**

**Setup local:**
```bash
# Igual que api-admin
cd /path/to/edugo-infrastructure
make dev-setup
```

**Validación:**
```go
// En tu código, validar que tablas existen
func (r *Repository) init() error {
    var count int
    err := r.db.Raw("SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'materials'").Scan(&count).Error
    if err != nil || count == 0 {
        return fmt.Errorf("table materials does not exist - run migrations first")
    }
    return nil
}
```

---

## 📨 Paso 3: Validar Eventos con Schemas

### En Publisher (api-mobile)

```go
import "github.com/EduGoGroup/edugo-infrastructure/schemas"

func (p *Publisher) PublishMaterialUploaded(material *Material) error {
    event := Event{
        EventID:      generateUUIDv7(),
        EventType:    "material.uploaded",
        EventVersion: "1.0",
        Timestamp:    time.Now(),
        Payload: map[string]interface{}{
            "material_id": material.ID,
            "file_url":    material.FileURL,
            "school_id":   material.SchoolID,
            "teacher_id":  material.TeacherID,
        },
    }

    // Validar contra schema (cuando validator.go esté listo)
    if err := schemas.Validate(event, "material-uploaded-v1"); err != nil {
        return fmt.Errorf("invalid event: %w", err)
    }

    // Publicar
    return p.rabbit.Publish("material.uploaded", event)
}
```

---

### En Consumer (worker)

```go
import "github.com/EduGoGroup/edugo-infrastructure/schemas"

func (c *Consumer) handleMaterialUploaded(msg []byte) error {
    var event Event
    if err := json.Unmarshal(msg, &event); err != nil {
        return err
    }

    // Validar contra schema (cuando validator.go esté listo)
    if err := schemas.Validate(event, "material-uploaded-v1"); err != nil {
        logger.Error("invalid event received", err)
        // No reintentar (enviar a DLQ directamente)
        return nil
    }

    // Procesar
    return c.processMaterial(event.Payload)
}
```

---

## 🐳 Paso 4: Usar Docker Compose

### Desarrollo Local

```bash
# Opción 1: Usar infrastructure directamente
cd /path/to/edugo-infrastructure
make dev-up-core

# Opción 2: Usar dev-environment con referencia
cd /path/to/edugo-dev-environment
./scripts/setup.sh --profile db-only
```

### En CI/CD

```yaml
# .github/workflows/integration-tests.yml
services:
  postgres:
    image: postgres:15-alpine
    env:
      POSTGRES_DB: edugo_test
      POSTGRES_USER: edugo
      POSTGRES_PASSWORD: test
    ports:
      - 5432:5432

  mongodb:
    image: mongo:7.0
    ports:
      - 27017:27017

steps:
  - name: Run integration tests
    run: |
      # Ejecutar migraciones
      cd edugo-infrastructure/database/migrations
      # ... ejecutar SQLs
      
      # Ejecutar tests
      go test ./... -tags=integration
```

---

## 📊 Paso 5: Consultar Documentación

### Ownership de Tablas

**Pregunta:** ¿Quién crea la tabla `users`?

**Respuesta:**
```bash
cat /path/to/edugo-infrastructure/database/TABLE_OWNERSHIP.md
# → api-admin es owner de users
```

---

### Contratos de Eventos

**Pregunta:** ¿Qué estructura tiene `material.uploaded`?

**Respuesta:**
```bash
cat /path/to/edugo-infrastructure/EVENT_CONTRACTS.md
# → Ver sección "material.uploaded (v1.0)"

# O ver JSON Schema directamente
cat /path/to/edugo-infrastructure/schemas/events/material-uploaded-v1.schema.json
```

---

## ✅ Checklist de Integración

### Para api-administracion

- [ ] Agregar infrastructure/database a go.mod
- [ ] Referenciar TABLE_OWNERSHIP.md en documentación
- [ ] CI/CD ejecuta migraciones antes de tests
- [ ] Publicar eventos student.enrolled (futuro)

### Para api-mobile

- [ ] Agregar infrastructure/database a go.mod
- [ ] Agregar infrastructure/schemas a go.mod
- [ ] Validar eventos antes de publicar
- [ ] Validar eventos al consumir
- [ ] CI/CD ejecuta migraciones después de api-admin

### Para worker

- [ ] Agregar infrastructure/schemas a go.mod
- [ ] Validar eventos al consumir
- [ ] Validar eventos antes de publicar
- [ ] MongoDB seeds sincronizados con infrastructure

---

## 🚀 Quick Start

```bash
# 1. Clonar infrastructure
git clone https://github.com/EduGoGroup/edugo-infrastructure
cd edugo-infrastructure

# 2. Setup completo
make dev-setup

# 3. Validar
make status

# 4. Usar en tu proyecto
cd ../tu-proyecto
# Agregar a go.mod
# Importar módulos necesarios
```

---

**Generado:** 16 de Noviembre, 2025
