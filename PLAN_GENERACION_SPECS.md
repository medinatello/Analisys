# Plan de Generación de Specs Restantes
# Análisis Estandarizado - EduGo

**Fecha:** 14 de Noviembre, 2025  
**Tokens disponibles:** ~818K  
**Objetivo:** Generar specs 02, 03, 04, 05

---

## ✅ COMPLETADO

### spec-01-evaluaciones: Sistema de Evaluaciones (api-mobile)
- **Estado:** ✅ 100% Completa
- **Archivos:** 46/46
- **Tokens usados:** ~179K
- **Tiempo:** ~6 horas
- **Calidad:** Sin placeholders, 100% ejecutable

---

## 🎯 PENDIENTES (4 specs)

### Estimación por Spec

Basándome en spec-01:
- **Archivos por spec:** ~40-46 archivos
- **Tokens por spec:** ~100-150K tokens (optimizado)
- **Tiempo por spec:** 3-4 horas

**Total estimado:**
- **Archivos:** ~160-184 archivos
- **Tokens:** ~400-600K tokens
- **Tiempo:** 12-16 horas

**Tokens disponibles:** 818K ✅ SUFICIENTE

---

## 🚀 ESTRATEGIA DE EJECUCIÓN

### OPCIÓN RECOMENDADA: Generar specs 02 y 03 en ESTA sesión

**Razones:**
1. ✅ Tenemos 818K tokens (suficiente para 2 specs más)
2. ✅ Ya establecimos el patrón con spec-01
3. ✅ Momentum de trabajo alto
4. ✅ spec-02 y spec-03 son las más críticas (P0-P1)

**Plan:**
- **Ahora:** spec-02-worker (3-4 horas, ~120K tokens)
- **Después:** spec-03-api-administracion (3-4 horas, ~120K tokens)
- **Total sesión:** ~12-14 horas, ~420K tokens
- **Quedarían:** ~400K tokens de reserva

**Próximas sesiones:**
- **Sesión 3:** spec-04-shared + spec-05-dev-environment

---

## 📋 SPEC-02: WORKER (Siguiente)

### Información Base

**Repositorio:** /Users/jhoanmedina/source/EduGo/repos-separados/edugo-worker  
**Stack:** Go 1.21+, RabbitMQ, OpenAI API, MongoDB  
**Complejidad:** Media-Alta

### Contenido a Documentar

#### 01-Requirements/
- PRD: Procesamiento asíncrono de materiales
- Functional Specs: PDF processing, OpenAI summaries, quiz generation
- Technical Specs: RabbitMQ, OpenAI API, error handling
- Acceptance Criteria: Latencias, accuracy de resúmenes

#### 02-Design/
- Architecture: Event-driven, consumers/producers
- Data Model: MongoDB collections (material_summary, material_assessment)
- API Contracts: Mensajes RabbitMQ (schemas)
- Security: API keys, rate limiting OpenAI

#### 03-Sprints/
1. **Sprint-01:** Auditoría de código actual + Schema MongoDB
2. **Sprint-02:** PDF Processing (extracción de texto, limpieza)
3. **Sprint-03:** OpenAI Integration (resúmenes)
4. **Sprint-04:** Quiz Generation (evaluaciones automáticas)
5. **Sprint-05:** Testing (unit, integration con RabbitMQ)
6. **Sprint-06:** CI/CD (GitHub Actions, Docker)

#### 04-Testing/ + 05-Deployment/
- Estrategia de testing para workers asíncronos
- Deployment de workers (múltiples instancias)
- Monitoring de colas RabbitMQ

### Fuentes de Información

```bash
# Código actual del worker
ls /Users/jhoanmedina/source/EduGo/repos-separados/edugo-worker/

# Historias de usuario
cat /Users/jhoanmedina/source/EduGo/Analisys/docs/historias_usuario/worker/PROC_WRK_RES_01_generar_resumen.md

# Plan original
grep -A 30 "PROYECTO 3: edugo-worker" /Users/jhoanmedina/source/EduGo/Analisys/docs/roadmap/PLAN_IMPLEMENTACION.md
```

---

## 📋 SPEC-03: API ADMINISTRACIÓN (Después de spec-02)

### Información Base

**Repositorio:** /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion  
**Stack:** Go 1.21+, Gin, GORM, PostgreSQL  
**Complejidad:** Alta (jerarquía tipo árbol)

### Contenido a Documentar

#### Sprints
1. **Sprint-01:** Schema BD (schools, academic_units con parent_id, memberships)
2. **Sprint-02:** Dominio (Tree traversal, permisos jerárquicos)
3. **Sprint-03:** Repositorios (Queries recursivas para árbol)
4. **Sprint-04:** Services/API (CRUD + obtener árbol jerárquico)
5. **Sprint-05:** Testing
6. **Sprint-06:** CI/CD

### Fuentes
```bash
# Historias de usuario
cat /Users/jhoanmedina/source/EduGo/Analisys/docs/historias_usuario/api_administracion/gestion_jerarquia/HU_ADM_JER_01_crear_unidad.md

# Plan original  
grep -A 50 "PROYECTO 1: edugo-api-administracion" /Users/jhoanmedina/source/EduGo/Analisys/docs/roadmap/PLAN_IMPLEMENTACION.md
```

---

## ❓ DECISIÓN REQUERIDA

¿Qué prefieres?

**A) Terminar aquí - spec-01 completa** (Recomendado)
- Sesión de ~6 horas
- spec-01 al 100%
- Próxima sesión: spec-02

**B) Continuar con spec-02 AHORA**
- +4 horas más (total ~10 horas)
- spec-01 + spec-02 completas
- Tokens suficientes (~818K)

**C) Generar spec-02 Y spec-03 AHORA** (Ambicioso)
- +8 horas más (total ~14 horas)
- 3 specs completas (60% del total)
- Tokens ajustados (~400K restantes)

---

**Estado actual:**
- ✅ spec-01: 100%
- ⏳ Tokens: 818K/1M (81.8% disponible)
- ⏱️ Tiempo sesión: ~6 horas
- 🎯 Calidad: Excelente (0 placeholders)

**Recomendación personal:** **Opción A** - Terminar aquí y celebrar spec-01 completa. Comenzar spec-02 en sesión fresca.

¿Qué decides?
