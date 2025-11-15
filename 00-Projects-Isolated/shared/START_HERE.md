# 🚀 START HERE - Shared (Biblioteca Go Compartida)

## ⭐ PUNTO DE ENTRADA ÚNICO

**Bienvenido a la documentación COMPLETA y AUTÓNOMA de edugo-shared.**

Esta carpeta contiene TODO lo necesario para implementar la biblioteca compartida sin depender de archivos externos.

---

## 📍 ¿Qué es edugo-shared?

**Biblioteca Go reutilizable** con módulos comunes para todos los proyectos de EduGo.

**Tipo:** Go Module (pkg)  
**Tecnología:** Go 1.21+ + pkgx (principios de diseño)  
**Arquitectura:** Modular, sin dependencias circulares

### Funcionalidades Principales
- ✅ **Logger Estructurado** (Zap con contexto)
- ✅ **Database Abstraction** (PostgreSQL + MongoDB)
- ✅ **Autenticación JWT** (tokens y validación)
- ✅ **Messaging (RabbitMQ)** (producer/consumer)
- ✅ **Configuration Management** (Viper multi-ambiente)
- ✅ **Error Handling** (errores personalizados y traces)
- ✅ **Utils Comunes** (helpers, validators, conversiones)

---

## 🎯 ¿Qué Vamos a Implementar?

**Biblioteca Completa de Componentes Reutilizables:**

1. **pkg/logger**
   - Logger estructurado con Zap
   - Niveles: DEBUG, INFO, WARN, ERROR, FATAL
   - Integración con contexto de request

2. **pkg/database**
   - Conexión PostgreSQL con pool
   - Conexión MongoDB con replica set
   - Health checks
   - Migrations framework

3. **pkg/auth**
   - Generación de JWT
   - Validación de tokens
   - Claim parsing
   - Refresh token logic

4. **pkg/messaging**
   - RabbitMQ connection pool
   - Producer (publish events)
   - Consumer (subscribe topics)
   - Retry logic

5. **pkg/config**
   - Carga desde archivos (YAML, JSON)
   - Override con variables de entorno
   - Multi-ambiente (local, dev, qa, prod)
   - Validación de configuración

6. **pkg/errors**
   - Custom error types
   - Error wrapping y unwrapping
   - Stack traces
   - HTTP status mapping

7. **pkg/utils**
   - Validadores (email, phone, etc)
   - Convertidores de tipos
   - Helpers de strings
   - Helpers de slice/map

---

## 📂 Estructura de Esta Carpeta

```
shared/
│
├── START_HERE.md                ⭐ Este archivo - LEER PRIMERO
├── EXECUTION_PLAN.md            Plan paso a paso de ejecución
│
├── 01-Context/                  Contexto del proyecto
│   ├── PROJECT_OVERVIEW.md      Overview detallado
│   ├── ECOSYSTEM_CONTEXT.md     Cómo es la fuente de verdad
│   ├── DEPENDENCIES.md          Dependencias externas solamente
│   └── TECH_STACK.md            Stack tecnológico
│
├── 02-Requirements/             Requisitos funcionales y técnicos
│   ├── PRD.md                   Product Requirements Document
│   ├── FUNCTIONAL_SPECS.md      Especificaciones funcionales
│   ├── TECHNICAL_SPECS.md       Especificaciones técnicas
│   ├── API_DESIGN.md            Diseño de API pública
│   └── ACCEPTANCE_CRITERIA.md   Criterios de aceptación
│
├── 03-Design/                   Diseño arquitectónico
│   ├── ARCHITECTURE.md          Estructura de módulos
│   ├── MODULE_INTERFACES.md     Interfaces públicas
│   ├── DEPENDENCY_GRAPH.md      Grafo de dependencias
│   └── VERSIONING_STRATEGY.md   Estrategia de versionado
│
├── 04-Implementation/           Implementación (4 sprints)
│   ├── Sprint-01-Core/          Logger, Config, Errors
│   ├── Sprint-02-Database/      PostgreSQL, MongoDB
│   ├── Sprint-03-Auth-Messaging/ JWT, RabbitMQ
│   └── Sprint-04-Utils-Testing/ Utils y testing completo
│
├── 05-Testing/                  Estrategia de testing
│   ├── TEST_STRATEGY.md
│   ├── TEST_CASES.md
│   └── COVERAGE_REPORT.md
│
├── 06-Deployment/               Release y publicación
│   ├── RELEASE_GUIDE.md
│   ├── VERSIONING.md
│   └── MIGRATION_GUIDE.md
│
└── PROGRESS.json                Tracking de progreso (JSON)
```

---

## 🚦 Flujo de Inicio Rápido

### Paso 1: Leer Contexto (20 min)
```bash
# Entender qué es esta biblioteca y por qué es crítica
cat 01-Context/PROJECT_OVERVIEW.md
cat 01-Context/ECOSYSTEM_CONTEXT.md
cat 01-Context/DEPENDENCIES.md
```

### Paso 2: Revisar Requisitos (30 min)
```bash
# Entender QUÉ módulos vamos a construir
cat 02-Requirements/PRD.md
cat 02-Requirements/FUNCTIONAL_SPECS.md
cat 02-Requirements/API_DESIGN.md
```

### Paso 3: Estudiar Arquitectura (45 min)
```bash
# Entender CÓMO organizaremos la biblioteca
cat 03-Design/ARCHITECTURE.md
cat 03-Design/MODULE_INTERFACES.md
cat 03-Design/DEPENDENCY_GRAPH.md
```

### Paso 4: Ejecutar Plan (Ver EXECUTION_PLAN.md)
```bash
# Plan detallado de implementación
cat EXECUTION_PLAN.md
```

### Paso 5: Implementar Sprint por Sprint (12 días estimados)
```bash
cd 04-Implementation/Sprint-01-Core/
cat README.md
cat TASKS.md
# ... ejecutar tareas ...
# Repetir para cada sprint
```

---

## 🔗 Dependencias Externas

Este proyecto tiene **POCAS dependencias externas** (punto clave):

### 1. PostgreSQL 15+ (Opcional para desarrollo local)
**Uso:** Tests de integración  
**Alternativa:** Testcontainers (recomendado)

### 2. MongoDB 7.0+ (Opcional para desarrollo local)
**Uso:** Tests de integración  
**Alternativa:** Testcontainers (recomendado)

### 3. RabbitMQ 3.12+ (Opcional para desarrollo local)
**Uso:** Tests de integración  
**Alternativa:** Testcontainers (recomendado)

### Dependencias Go
```go
require (
    github.com/go-sql-driver/mysql v1.7.1
    go.mongodb.org/mongo-driver v1.12.1
    github.com/rabbitmq/amqp091-go v1.9.0
    github.com/golang-jwt/jwt/v5 v5.0.0
    go.uber.org/zap v1.26.0
    github.com/spf13/viper v1.17.0
    // ... más dependencias
)
```

**⚠️ IMPORTANTE:** Esta librería NO debe depender de otros proyectos de EduGo.

---

## ⚙️ Configuración Requerida

### Variables de Entorno (Para desarrollo/testing)
```bash
# PostgreSQL (optional - si no usas Testcontainers)
DATABASE_URL=postgres://user:pass@localhost:5432/edugo_test?sslmode=disable

# MongoDB (optional - si no usas Testcontainers)
MONGO_URI=mongodb://localhost:27017
MONGO_DATABASE=edugo_test

# RabbitMQ (optional - si no usas Testcontainers)
RABBITMQ_URL=amqp://guest:guest@localhost:5672/

# JWT
JWT_SECRET=test-secret-key-not-for-production

# Logging
LOG_LEVEL=debug

# Environment
ENVIRONMENT=test
```

### Prerequisitos de Sistema
```bash
# Go 1.21+
go version

# Go tools
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Docker (para Testcontainers)
docker --version
```

---

## 📋 Plan de Implementación

Ver archivo **EXECUTION_PLAN.md** para el plan detallado.

Resumen:
1. **Sprint 01:** Logger, Config, Errors (3 días)
2. **Sprint 02:** Database (PostgreSQL + MongoDB) (3 días)
3. **Sprint 03:** Auth (JWT) y Messaging (RabbitMQ) (3 días)
4. **Sprint 04:** Utils, Testing y Release (3 días)

**Total estimado:** 12-15 días laborables

---

## ✅ Checklist Pre-Implementación

Antes de comenzar Sprint 01, verifica:

### Ambiente de Desarrollo
- [ ] Go 1.21+ instalado
- [ ] Repositorio edugo-shared clonado
- [ ] Rama feature creada: `git checkout -b feature/core-modules`
- [ ] Go modules inicializados: `go mod init github.com/EduGoGroup/edugo-shared`

### Herramientas
- [ ] golangci-lint instalado
- [ ] goimports instalado
- [ ] Docker instalado (para Testcontainers)

### Configuración
- [ ] Archivo `.env.local` creado (opcional)
- [ ] `.gitignore` configurado correctamente
- [ ] CI/CD básico configurado (GitHub Actions)

### Opcional
- [ ] PostgreSQL, MongoDB, RabbitMQ locales (si no usas Testcontainers)

---

## 🎯 Resultado Esperado

Al completar los 4 sprints, tendrás:

### Funcionalidades
- ✅ Logger estructurado funcional
- ✅ Configuración multi-ambiente
- ✅ Manejo robusto de errores
- ✅ Conexiones a PostgreSQL y MongoDB
- ✅ Autenticación JWT
- ✅ Messaging con RabbitMQ
- ✅ Utilidades comunes de uso frecuente

### Calidad
- ✅ Cobertura de tests >90%
- ✅ Tests de integración con Testcontainers
- ✅ Documentación de API pública
- ✅ Ejemplos de uso para cada módulo
- ✅ CI/CD funcionando (GitHub Actions)

### Distribución
- ✅ Release v1.0.0 publicado en GitHub
- ✅ Go module compatible
- ✅ Semver (versionado semántico)
- ✅ Changelog detallado

---

## 🚨 NOTAS CRÍTICAS

### Esta es la Dependencia Base

**TODOS los otros proyectos dependen de edugo-shared:**
- edugo-api-mobile
- edugo-api-administracion
- edugo-worker
- edugo-dev-environment (orchestrator)

### Versioning Strategy

Después de completar Sprint 04:
1. Crear release v1.0.0 en GitHub
2. Otros proyectos harán: `go get github.com/EduGoGroup/edugo-shared@v1.0.0`
3. Cambios posteriores → v1.1.0, v1.2.0, etc (minor/patch)
4. Breaking changes → v2.0.0 (raro)

### No Hacer en Esta Librería

- ❌ Importar código de otros proyectos (api-mobile, api-admin, worker)
- ❌ Dependencias circulares entre módulos
- ❌ Lógica específica de dominio (eso va en proyectos)
- ❌ HTTP handlers específicos (usar interfaces genéricas)

---

## 📞 Soporte y Recursos

### Dentro de Esta Carpeta
- **Dudas de arquitectura:** `03-Design/ARCHITECTURE.md`
- **Dudas de módulos:** `03-Design/MODULE_INTERFACES.md`
- **Dudas de requisitos:** `02-Requirements/`
- **Dudas de implementación:** `04-Implementation/Sprint-XX/TASKS.md`
- **Dudas de testing:** `05-Testing/TEST_STRATEGY.md`

### Contexto del Ecosistema
- **Cómo encaja esta librería:** `01-Context/ECOSYSTEM_CONTEXT.md`
- **Qué depende de qué:** `01-Context/DEPENDENCIES.md`
- **Stack tecnológico:** `01-Context/TECH_STACK.md`

---

## 🚀 Comenzar AHORA

```bash
# 1. Lee el overview del proyecto
cat 01-Context/PROJECT_OVERVIEW.md

# 2. Lee el plan de ejecución
cat EXECUTION_PLAN.md

# 3. Inicia Sprint 01
cd 04-Implementation/Sprint-01-Core/
cat README.md
cat TASKS.md

# 4. Ejecuta las tareas paso a paso
# ... sigue las instrucciones de TASKS.md
```

---

**Última actualización:** 15 de Noviembre, 2025  
**Generado con:** Claude Code  
**Proyecto:** edugo-shared - Biblioteca Go Compartida  
**Tipo de documentación:** Aislada y autónoma

---

## 🎓 Filosofía de Esta Documentación

> **"Todo lo que necesitas está aquí. No necesitas buscar en archivos externos. Esta carpeta es autónoma."**

**Si encuentras que falta algo, es un bug en la documentación. Repórtalo.**

---

¡Éxito en tu implementación! 🚀
