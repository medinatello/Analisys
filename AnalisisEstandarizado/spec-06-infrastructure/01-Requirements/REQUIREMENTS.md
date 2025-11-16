# 📋 Requisitos - edugo-infrastructure

**Proyecto:** edugo-infrastructure  
**Fecha:** 16 de Noviembre, 2025

---

## 🎯 Objetivo

Proveer infraestructura compartida para todo el ecosistema EduGo.

---

## ✅ Requisitos Funcionales

### RF-01: Migraciones de PostgreSQL

**Descripción:** Proveer migraciones SQL para crear/actualizar schema de PostgreSQL

**Criterios de aceptación:**
- ✅ 8 migraciones SQL creadas (001-008)
- ✅ Cada migración tiene UP y DOWN
- ✅ Orden de ejecución garantizado (001 → 008)
- ✅ Ownership documentado (TABLE_OWNERSHIP.md)
- ⏳ CLI para ejecutar migraciones (migrate.go)

---

### RF-02: Contratos de Eventos RabbitMQ

**Descripción:** Documentar y validar contratos de eventos

**Criterios de aceptación:**
- ✅ 4 eventos documentados en EVENT_CONTRACTS.md
- ✅ 4 JSON Schemas creados
- ✅ Versionamiento explícito (event_version)
- ⏳ Validador Go (validator.go)

---

### RF-03: Docker Compose para Desarrollo

**Descripción:** Proveer configuración Docker para levantar infraestructura local

**Criterios de aceptación:**
- ✅ docker-compose.yml con todos los servicios
- ✅ Profiles para diferentes escenarios
- ✅ Healthchecks configurados
- ✅ Variables en .env.example

---

### RF-04: Scripts de Automatización

**Descripción:** Scripts para setup, seeds y validación

**Criterios de aceptación:**
- ✅ dev-setup.sh (setup completo)
- ✅ seed-data.sh (carga de datos)
- ✅ validate-env.sh (validación)

---

### RF-05: Seeds de Datos de Prueba

**Descripción:** Datos de prueba para desarrollo

**Criterios de aceptación:**
- ✅ Seeds de PostgreSQL (users, schools, materials)
- ✅ Seeds de MongoDB (assessments, summaries)
- ✅ Datos coherentes entre BDs

---

## 📊 Requisitos No Funcionales

### RNF-01: Performance

- Setup completo en < 5 minutos
- Migraciones ejecutan en < 10 segundos
- Seeds cargan en < 5 segundos

---

### RNF-02: Compatibilidad

- Go 1.24+
- Docker 20.10+
- Docker Compose 2.0+
- PostgreSQL 15
- MongoDB 7.0
- RabbitMQ 3.12

---

### RNF-03: Usabilidad

- Makefile con comandos simples
- Documentación clara en cada módulo
- README.md con ejemplos de uso

---

### RNF-04: Mantenibilidad

- Un archivo docker-compose.yml (no múltiples)
- Migraciones versionadas y ordenadas
- Schemas versionados (v1, v2, etc.)

---

## 🔗 Dependencias

### Módulos Go Requeridos

```go
// database/go.mod
github.com/golang-migrate/migrate/v4
github.com/lib/pq

// schemas/go.mod
github.com/xeipuuv/gojsonschema
```

---

## ✅ Criterios de Completitud

**96% completado actualmente:**

- ✅ Migraciones SQL (100%)
- ✅ Docker Compose (100%)
- ✅ JSON Schemas (100%)
- ✅ Scripts (100%)
- ✅ Seeds (100%)
- ✅ Documentación (100%)
- ⏳ migrate.go CLI (0%)
- ⏳ validator.go (0%)

**Para llegar a 100%:**
- Implementar migrate.go
- Implementar validator.go
- Publicar release v0.2.0

---

**Generado:** 16 de Noviembre, 2025
