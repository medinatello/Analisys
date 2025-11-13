# Spec: Módulo de Testcontainers en shared

**Proyecto:** edugo-shared/testing  
**Epic:** Estandarización de Testing Infrastructure  
**Fecha:** 12 de Noviembre, 2025  
**Estado:** 📋 En Diseño

---

## 🎯 Objetivo

Crear un módulo reutilizable en `edugo-shared/testing` que proporcione testcontainers compartidos y configurables para PostgreSQL, MongoDB, RabbitMQ y S3, eliminando duplicación de código entre proyectos.

---

## 📊 Situación Actual

### Implementaciones Actuales

| Proyecto | Testcontainers | Patrón | LOC | Duplicación |
|----------|----------------|--------|-----|-------------|
| **api-mobile** | ✅ PostgreSQL, MongoDB, RabbitMQ | Singleton compartido | ~193 | Base |
| **api-admin** | ✅ PostgreSQL | Setup simple | ~150 | 60% |
| **worker** | ❌ Sin tests | N/A | 0 | N/A |

**Problema:** Código duplicado y patrones inconsistentes

---

## 🎯 Alcance del Proyecto

### Fase 1: Módulo en shared
- Crear `shared/testing` con API flexible
- Containers opcionales y configurables
- Patrón singleton mejorado
- Helpers de limpieza genéricos

### Fase 2: Migración de Proyectos
- Adaptar api-mobile a usar shared/testing
- Adaptar api-administracion
- Implementar tests en worker

### Fase 3: dev-environment
- Scripts para developers frontend
- docker-compose perfiles (full, db-only, api-only)
- Seeds de datos para desarrollo

---

## 📁 Documentos de la Spec

- [DESIGN.md](DESIGN.md) - Diseño arquitectónico detallado
- [TASKS.md](TASKS.md) - Plan de implementación
- [USER_STORIES.md](USER_STORIES.md) - Historias de usuario
- [RULES.md](RULES.md) - Reglas del proyecto
- [PRD.md](PRD.md) - Product Requirements

---

**Estado:** Spec en creación
**Próximo:** Completar documentos de diseño

