# Plan Final: Estandarización de Mock Repositories con Dataset Singleton

## 📋 Índice de Navegación

Este plan completo detalla la implementación de un sistema automatizado de generación de datos mock para desarrollo frontend, usando SQL como fuente única de verdad.

### Documentos del Plan

1. **[01-ARQUITECTURA-DATASET-SIMPLE.md](./01-ARQUITECTURA-DATASET-SIMPLE.md)**
   - 🎯 **Propósito**: Fundamentos arquitectónicos del enfoque simplificado
   - 📖 **Lee esto primero** para entender la visión general del sistema
   - ⏱️ Tiempo de lectura: 10-15 minutos
   - 🔑 **Conceptos clave**: Dataset Singleton, read-only, índice primario único

2. **[02-PLAN-SPRINTS-DETALLADO.md](./02-PLAN-SPRINTS-DETALLADO.md)**
   - 🎯 **Propósito**: Roadmap completo de implementación en 5 sprints
   - 📖 **Lee esto segundo** para ver el cronograma y fases de implementación
   - ⏱️ Tiempo de lectura: 20-30 minutos
   - 🔑 **Conceptos clave**: 10-12 semanas, parser SQL → dataset → api-admin → api-mobile → automatización

3. **[03-ESPECIFICACIONES-TECNICAS.md](./03-ESPECIFICACIONES-TECNICAS.md)**
   - 🎯 **Propósito**: Valores concretos y mapeos específicos sin ambigüedades
   - 📖 **Lee esto tercero** como referencia durante la implementación
   - ⏱️ Tiempo de lectura: 15-20 minutos
   - 🔑 **Conceptos clave**: Mapeos tabla→entidad, SQL→Go, comandos copy-paste

4. **[04-CHECKLIST-EJECUCION.md](./04-CHECKLIST-EJECUCION.md)**
   - 🎯 **Propósito**: Guía paso a paso con validaciones para ejecución desatendida
   - 📖 **Usa esto durante** la implementación real
   - ⏱️ Tiempo de ejecución: 10-12 semanas
   - 🔑 **Conceptos clave**: Checkboxes de validación, outputs esperados, tests automáticos

---

## 🚀 Quick Start

### Para Lectores con Prisa (5 minutos)

Si solo quieres entender de qué trata esto:

```
1. Leer sección "Resumen Ejecutivo" → 01-ARQUITECTURA-DATASET-SIMPLE.md
2. Ver diagrama "Flujo General" → 02-PLAN-SPRINTS-DETALLADO.md
3. Revisar "Tabla de Mapeos" → 03-ESPECIFICACIONES-TECNICAS.md
```

### Para Implementadores (30 minutos)

Si vas a ejecutar el plan:

```
1. Leer completo → 01-ARQUITECTURA-DATASET-SIMPLE.md (entender arquitectura)
2. Leer completo → 02-PLAN-SPRINTS-DETALLADO.md (conocer fases)
3. Tener a mano → 03-ESPECIFICACIONES-TECNICAS.md (referencia constante)
4. Seguir paso a paso → 04-CHECKLIST-EJECUCION.md (ejecución)
```

---

## 🎯 Propósito General del Plan

### Problema que Resuelve

**Actualmente:**
- Mock data hardcodeado manualmente en cada API
- Si agregas un usuario en SQL migrations, debes agregarlo manualmente en Go
- api-administracion tiene 42 registros mock, api-mobile solo 3
- Duplicación de esfuerzo entre proyectos
- Inconsistencias entre datos de testing SQL y datos mock Go

**Con este plan:**
- SQL migrations = fuente única de verdad
- Parser automático lee INSERT statements
- Genera código Go automáticamente
- Ambas APIs (admin + mobile) usan mismo dataset
- Dataset singleton simple y rápido para desarrollo frontend

### Alcance del Plan

**✅ Incluye:**
- Parser de SQL (PostgreSQL INSERT statements)
- Generador de código Go (dataset tables con FindByID/List)
- Estandarización de api-administracion
- Estandarización de api-mobile
- Automatización completa (Makefile)
- Documentación técnica

**❌ No Incluye:**
- Operaciones de escritura (Create/Update/Delete) en mocks
- Validaciones complejas en mocks
- Índices secundarios (solo primary key)
- Testing con base de datos real (solo mocks)

---

## 📊 Estructura del Proyecto

### Nuevo Proyecto: edugo-mock-generator

```
edugo-mock-generator/
├── cmd/
│   └── generator/
│       └── main.go              # CLI para generar dataset
├── pkg/
│   ├── parser/
│   │   └── sql_parser.go        # Parser de SQL → structs Go
│   └── generator/
│       └── dataset_gen.go       # Generador de dataset.go
├── templates/
│   └── dataset.go.tmpl          # Template para código generado
└── go.mod
```

### APIs Estandarizadas

**api-administracion:**
```
internal/infrastructure/database/
├── mock/
│   ├── dataset.go               # GENERADO: dataset singleton
│   └── repositories/            # Repositories delegando a dataset
│       ├── user_mock.go
│       ├── school_mock.go
│       └── ...
```

**api-mobile:**
```
internal/infrastructure/mock/
├── dataset.go                   # GENERADO: mismo dataset
└── repositories/                # Repositories delegando a dataset
    ├── user_repository_mock.go
    ├── material_repository_mock.go
    └── ...
```

---

## ⚙️ Variables de Entorno Estandarizadas

Ambas APIs usarán la misma variable:

```bash
USE_MOCK_REPOSITORIES=true    # Activa mock repositories
```

**Antes:**
- api-admin: `EDUGO_ADMIN_DATABASE_USE_MOCK_REPOSITORIES`
- api-mobile: `DEVELOPMENT_USE_MOCK_REPOSITORIES`

**Después:** Ambas usan `USE_MOCK_REPOSITORIES`

---

## 🔄 Flujo de Trabajo

### Desarrollo Normal con Mocks

```
1. Editar:  /edugo-infrastructure/postgres/migrations/testing/001_demo_users.sql
2. Ejecutar: make generate-mocks (en edugo-mock-generator)
3. Copiar: dataset.go → api-administracion/internal/infrastructure/database/mock/
4. Copiar: dataset.go → api-mobile/internal/infrastructure/mock/
5. Levantar APIs con USE_MOCK_REPOSITORIES=true
6. Frontend consume datos mock sin Docker
```

### Desarrollo con PostgreSQL Real

```
1. Levantar: docker-compose up postgres
2. Ejecutar APIs sin variable USE_MOCK_REPOSITORIES (o =false)
3. APIs conectan a PostgreSQL real en localhost:5432
```

---

## 📦 Datos Mock Disponibles

### Usuarios (8 registros)

Roles disponibles en mock data:
- 1 admin
- 2 teachers (profesor titular + ayudante)
- 3 students (estudiantes activos)
- 2 parents (padres de estudiantes)

Todos con password: `Demo123!`

### Otras Entidades

Ver detalles completos en **03-ESPECIFICACIONES-TECNICAS.md** sección "Datasets Mock Disponibles"

---

## 🛠️ Comandos Principales

### Generación de Mocks

```bash
# En edugo-mock-generator/
make generate-mocks

# Manual
go run cmd/generator/main.go \
  --input ../edugo-infrastructure/postgres/migrations/testing \
  --output ../edugo-api-administracion/internal/infrastructure/database/mock/dataset.go
```

### Ejecución de APIs con Mocks

```bash
# api-administracion
cd edugo-api-administracion
USE_MOCK_REPOSITORIES=true go run cmd/api/main.go

# api-mobile
cd edugo-api-mobile
USE_MOCK_REPOSITORIES=true go run cmd/api/main.go
```

### Validación

```bash
# Test completo automatizado (ver 04-CHECKLIST-EJECUCION.md)
./scripts/test_mock_system.sh
```

---

## 📈 Timeline de Implementación

| Sprint | Duración | Objetivo Principal |
|--------|----------|-------------------|
| Sprint 1 | 2 semanas | Parser SQL básico funcional |
| Sprint 2 | 2 semanas | Generador de dataset completo |
| Sprint 3 | 2-3 semanas | api-administracion estandarizada |
| Sprint 4 | 2-3 semanas | api-mobile estandarizada |
| Sprint 5 | 1-2 semanas | Automatización y documentación |

**Total: 10-12 semanas**

Ver cronograma detallado en **02-PLAN-SPRINTS-DETALLADO.md**

---

## ✅ Criterios de Éxito

### Sprint 1
- [ ] Parser lee 001_demo_users.sql sin errores
- [ ] Extrae 8 usuarios con todos los campos correctos
- [ ] Tests unitarios pasan al 100%

### Sprint 2
- [ ] Genera dataset.go con UserTable completo
- [ ] Código compila sin errores
- [ ] FindByID y List funcionan correctamente

### Sprint 3
- [ ] api-administracion corre con USE_MOCK_REPOSITORIES=true
- [ ] Login exitoso con admin@edugo.test
- [ ] Endpoints GET retornan datos mock correctamente

### Sprint 4
- [ ] api-mobile corre con USE_MOCK_REPOSITORIES=true
- [ ] MaterialRepository retorna datos (no arrays vacíos)
- [ ] ProgressRepository funciona con mocks

### Sprint 5
- [ ] `make generate-mocks` funciona en ambas APIs
- [ ] Documentación completa en README
- [ ] Script de validación automático pasa

Ver checklist completo en **04-CHECKLIST-EJECUCION.md**

---

## 🔍 Preguntas Frecuentes

### ¿Por qué no usar migraciones directamente en runtime?

**Respuesta:** Este sistema es para desarrollo frontend sin Docker. Generar código Go permite:
- No necesitar PostgreSQL corriendo
- Datos inmediatos sin latencia de DB
- Type-safety en Go
- Velocidad de desarrollo frontend

### ¿Por qué no soportar Create/Update/Delete en mocks?

**Respuesta:** Principio de simplicidad. Los mocks son para:
- Desarrollo de interfaces (frontend necesita data)
- Testing de lectura

Para operaciones de escritura, usar API real con PostgreSQL.

### ¿Qué pasa si necesito más datos mock?

**Respuesta:**
1. Editar `/edugo-infrastructure/postgres/migrations/testing/*.sql`
2. Ejecutar `make generate-mocks`
3. Datos actualizados automáticamente

### ¿Puedo usar mocks en producción?

**Respuesta:** ❌ NO. Mocks son solo para:
- Desarrollo local sin Docker
- Testing de interfaces frontend
- CI/CD en ambientes sin DB

Producción siempre usa PostgreSQL real.

---

## 📞 Soporte y Contacto

Para dudas durante la implementación:
1. Revisar **03-ESPECIFICACIONES-TECNICAS.md** para valores concretos
2. Consultar **04-CHECKLIST-EJECUCION.md** para pasos específicos
3. Verificar que estés en el sprint correcto según **02-PLAN-SPRINTS-DETALLADO.md**

---

## 📝 Historial de Cambios

| Fecha | Versión | Cambios |
|-------|---------|---------|
| 2025-11-30 | 1.0.0 | Creación del plan completo |

---

## 🎓 Glosario

- **Dataset Singleton**: Estructura global en memoria que simula una base de datos con todas las tablas
- **Mock Repository**: Implementación de Repository Interface que retorna datos hardcodeados (o del dataset)
- **Source of Truth**: Fuente única de verdad, en este caso los archivos SQL de migrations/testing
- **Read-Only Mocks**: Mocks que solo soportan operaciones de lectura (Find, List), no escritura
- **Primary Key Index**: Índice por clave primaria usando map[uuid.UUID] en Go

---

## 🚦 Estado Actual

```
✅ Arquitectura definida
✅ Plan de sprints detallado
✅ Especificaciones técnicas sin ambigüedades
✅ Checklist de ejecución completo
⏳ Pendiente: Ejecución de sprints

Listo para comenzar implementación desatendida.
```

---

**Última actualización:** 30 de Noviembre, 2025  
**Versión del plan:** 1.0.0  
**Estado:** ✅ Completo y listo para ejecución
