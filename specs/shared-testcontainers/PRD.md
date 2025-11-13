# PRD: Módulo Testing en edugo-shared

**Product:** edugo-shared/testing  
**Version:** 1.0  
**Fecha:** 12 de Noviembre, 2025  
**Owner:** Tech Lead

---

## 🎯 Objetivo del Producto

Proporcionar una biblioteca reutilizable de testcontainers que simplifique y estandarice la creación de ambientes de testing en todos los proyectos del ecosistema EduGo.

---

## 📊 Problema a Resolver

### Situación Actual

**Duplicación de Código:**
- api-mobile: 193 LOC de testcontainers
- api-administracion: 150 LOC similar
- worker: Sin tests (barrera de entrada alta)

**Inconsistencia:**
- Cada proyecto con su propio patrón
- Configuraciones hardcodeadas diferentes
- Mantenimiento en múltiples lugares

**Barreras:**
- Setup complejo desalienta escribir tests
- Nuevo developer tarda en entender cada setup
- Cambiar versión de PostgreSQL requiere tocar 3 repos

### Impacto

❌ **60% de código duplicado** entre proyectos  
❌ **Alta barrera** para escribir tests de integración  
❌ **Mantenimiento costoso** (3x el esfuerzo)  
❌ **worker sin tests** de integración  

---

## 🎯 Solución Propuesta

### Módulo shared/testing

Un módulo que:

✅ **Elimina duplicación:** Código en un solo lugar  
✅ **API simple:** Builder pattern intuitivo  
✅ **Flexible:** Containers opcionales por necesidad  
✅ **Performante:** Singleton con cleanup rápido  
✅ **Extensible:** Fácil agregar nuevos servicios  

### Componentes

1. **Containers Manager**
   - Singleton pattern
   - Lazy initialization
   - Cleanup automático

2. **Container Wrappers**
   - PostgreSQL
   - MongoDB
   - RabbitMQ
   - S3/MinIO

3. **Helpers**
   - Connection retry
   - Cleanup utilities
   - SQL script execution

---

## 👥 Usuarios y Casos de Uso

### Developer Backend (api-mobile)

**Necesidad:** Tests con PostgreSQL + MongoDB + RabbitMQ

```go
config := containers.NewConfig().
    WithPostgreSQL(nil).
    WithMongoDB(nil).
    WithRabbitMQ(nil).
    Build()
```

**Beneficio:** De 193 LOC a 30 LOC

### Developer Backend (api-admin)

**Necesidad:** Tests solo con PostgreSQL

```go
config := containers.NewConfig().
    WithPostgreSQL(&containers.PostgresConfig{
        InitScripts: []string{"migrations.sql"},
    }).
    Build()
```

**Beneficio:** Setup simplificado, scripts SQL automáticos

### Developer Backend (worker)

**Necesidad:** Crear tests por primera vez

```go
config := containers.NewConfig().
    WithPostgreSQL(nil).
    WithMongoDB(nil).
    WithRabbitMQ(nil).
    Build()
```

**Beneficio:** Barrera baja para empezar a testear

### QA/Tester

**Necesidad:** Ejecutar tests de todos los proyectos

```bash
# Mismo comando en todos
go test -tags=integration ./test/integration/
```

**Beneficio:** Consistencia, no aprender 3 setups diferentes

---

## ✅ Criterios de Éxito

### Métricas

| Métrica | Objetivo |
|---------|----------|
| Reducción de código duplicado | >80% |
| LOC del módulo | <600 |
| Tiempo de setup (primera vez) | <60s |
| Tiempo de cleanup entre tests | <2s |
| Proyectos usando el módulo | 3/3 |
| Coverage del módulo | >70% |

### Funcionalidades Mínimas (MVP)

- ✅ PostgreSQL container configurable
- ✅ MongoDB container configurable
- ✅ RabbitMQ container configurable
- ✅ Singleton pattern
- ✅ Builder para config
- ✅ Cleanup helpers
- ✅ Documentación completa

### Funcionalidades Futuras (Post-MVP)

- ⏳ S3/MinIO container
- ⏳ Redis container
- ⏳ Elasticsearch container
- ⏳ Fixtures/Seeds genéricos
- ⏳ Parallel container startup
- ⏳ Health checks automáticos

---

## 📅 Timeline

### Fase 1: Desarrollo del Módulo (3 días)
- Día 1: Estructura + Manager + PostgreSQL
- Día 2: MongoDB + RabbitMQ + Helpers
- Día 3: Tests + Documentación + Release v0.6.0

### Fase 2: Migración (3 días)
- Día 4: api-mobile migrado
- Día 5: api-administracion migrado
- Día 6: worker tests creados

### Fase 3: dev-environment (2 días)
- Día 7: Docker profiles + scripts
- Día 8: Seeds + documentación

**Total:** 8 días

---

## 🚨 Riesgos y Mitigaciones

### Riesgo 1: Breaking Changes en Testcontainers Library

**Probabilidad:** Media  
**Impacto:** Alto

**Mitigación:**
- Pin versiones específicas en go.mod
- Tests del módulo detectan cambios
- Documentar versión mínima requerida

### Riesgo 2: Performance Degradation

**Probabilidad:** Baja  
**Impacto:** Medio

**Mitigación:**
- Mantener singleton pattern
- Benchmark en CI/CD
- Opción de disable cleanup para debug

### Riesgo 3: Adopción Lenta

**Probabilidad:** Media  
**Impacto:** Bajo

**Mitigación:**
- Documentación excelente con ejemplos
- Migración gradual (no breaking)
- Soporte en shared v0.6.0

---

## 📊 ROI Estimado

### Tiempo de Desarrollo

**Inversión:** 8 días (1 dev)

**Ahorro:**
- Eliminación duplicación: 300 LOC
- Futuras features: 2-3 días menos por proyecto
- Onboarding developers: 1-2 horas menos

**Break-even:** Después de 2-3 nuevas features que requieran tests

### Calidad

✅ **Más tests** - Barrera baja incentiva testing  
✅ **Consistencia** - Mismo patrón en todos lados  
✅ **Mantenibilidad** - Cambios en un solo lugar  

---

## 🔗 Dependencias

### Upstream
- testcontainers-go v0.27+ (library)
- Docker Engine 20.10+

### Downstream
- api-mobile (consumidor)
- api-administracion (consumidor)
- worker (consumidor)

---

## 📝 Decisiones Pendientes

### 1. Versionado del Módulo

**Opción A:** v0.6.0 (continuar numeración de shared)  
**Opción B:** v0.1.0 (nuevo módulo independiente)

**Recomendación:** v0.6.0 (mantener consistencia)

### 2. Ubicación de Seeds

**Opción A:** En shared/testing/fixtures/  
**Opción B:** En cada proyecto  
**Opción C:** En dev-environment

**Recomendación:** Opción C (dev-environment es para eso)

### 3. Soporte para S3

**Opción A:** Incluir desde MVP  
**Opción B:** Post-MVP (v0.7.0)

**Recomendación:** Post-MVP (solo api-mobile lo usa)

---

## 🎊 Valor Agregado

### Para Developers
- ✅ Setup de tests en <5 líneas de código
- ✅ No pensar en Docker/Testcontainers
- ✅ Misma experiencia en todos los proyectos

### Para el Proyecto
- ✅ Cobertura de tests aumenta
- ✅ Código más mantenible
- ✅ Onboarding más rápido

### Para el Negocio
- ✅ Menos bugs (más tests)
- ✅ Confianza en deploys
- ✅ Velocidad de desarrollo

---

**PRD Aprobado para Diseño** ✅

