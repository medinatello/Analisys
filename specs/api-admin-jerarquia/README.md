# Spec: Jerarquía Académica en api-administracion

**Epic:** Modernización + Jerarquía Académica  
**Fecha:** 11 de Noviembre, 2025  
**Estilo:** Amazon-style Technical Specification

---

## 📋 CONTENIDO DE ESTE SPEC

| Documento | Propósito | Audiencia |
|-----------|-----------|-----------|
| **[PRD.md](PRD.md)** | Product Requirements Document | PMs, Stakeholders |
| **[USER_STORIES.md](USER_STORIES.md)** | Historias de usuario con AC | Developers, QA |
| **[DESIGN.md](DESIGN.md)** | Diseño técnico detallado | Arquitectos, Sr Developers |
| **[TASKS.md](TASKS.md)** | Plan de tareas con checkboxes | Todo el equipo |
| **[MEJORAS_SHARED.md](MEJORAS_SHARED.md)** | Migraciones a shared | Developers |

---

## 🎯 OBJETIVO DEL SPEC

Implementar **jerarquía académica completa** en `edugo-api-administracion`, modernizando la arquitectura y consolidando utilidades comunes en `edugo-shared`.

### Alcance

**Incluido:**
- ✅ 3 tablas PostgreSQL (school, academic_unit, unit_membership)
- ✅ 15+ endpoints REST CRUD
- ✅ Clean Architecture completa
- ✅ Tests >80% coverage
- ✅ CI/CD con GitHub Actions
- ✅ Migración de bootstrap a shared

**Excluido (futuros sprints):**
- ❌ Perfiles especializados (Admin-2)
- ❌ Materias (Admin-3)
- ❌ Reportes (Admin-4)

---

## 📊 RESUMEN EJECUTIVO

| Métrica | Valor |
|---------|-------|
| **Duración total** | 24 días (~5 semanas) |
| **Fases** | 8 fases (0-7) |
| **PRs** | 4-5 PRs a rama `dev` |
| **Archivos nuevos** | ~50 archivos |
| **LOC estimado** | ~5,000 líneas |
| **Tests** | ~40 archivos de test |
| **Coverage objetivo** | >80% |

---

## 🚀 ORDEN DE LECTURA RECOMENDADO

### Para Product Managers
1. **PRD.md** - Entender objetivos y alcance
2. **USER_STORIES.md** - Validar casos de uso
3. **TASKS.md** - Revisar cronograma

### Para Developers
1. **TASKS.md** - Ver plan de implementación
2. **DESIGN.md** - Entender arquitectura técnica
3. **USER_STORIES.md** - Criterios de aceptación
4. **MEJORAS_SHARED.md** - Migración de utilidades

### Para Tech Leads
1. **PRD.md** - Overview completo
2. **DESIGN.md** - Decisiones técnicas
3. **TASKS.md** - Validar estimaciones
4. **MEJORAS_SHARED.md** - Impacto en shared

---

## 🗺️ ROADMAP VISUAL

```
┌─────────────┐
│  Semana 1   │  Fase 0: Migrar a shared (3d) + Fase 1: Modernizar (5d) 
│  (8 días)   │  
└──────┬──────┘
       │
       ↓ PR-S1 (shared) + PR-1 (api-admin)
       │
┌──────┴──────┐
│  Semana 2   │  Fase 2: Schema (2d) + Fase 3: Dominio (3d)
│  (5 días)   │
└──────┬──────┘
       │
       ↓ PR-2 (api-admin)
       │
┌──────┴──────┐
│  Semana 3   │  Fase 4: Services (3d) + Fase 5: API (4d)
│  (7 días)   │
└──────┬──────┘
       │
       ↓ PR-3 (api-admin)
       │
┌──────┴──────┐
│  Semana 4   │  Fase 6: Testing (3d) + Fase 7: CI/CD (1d)
│  (4 días)   │
└──────┬──────┘
       │
       ↓ PR-4 (api-admin)
       │
┌──────┴──────┐
│  Semana 5   │  Buffer, docs, deploy a dev
└─────────────┘
```

**Total:** 24 días de trabajo

---

## ✅ CRITERIOS DE ÉXITO

El spec se considera **completado exitosamente** cuando:

- [ ] Todos los checkboxes de `TASKS.md` marcados ✅
- [ ] Todos los PRs mergeados a rama `dev`
- [ ] Todas las historias de usuario cumpliendo AC
- [ ] Coverage >80%
- [ ] CI/CD pasando
- [ ] API desplegada a ambiente dev
- [ ] Validación manual exitosa
- [ ] Documentación actualizada

---

## 🚨 RIESGOS

| Riesgo | Mitigación |
|--------|------------|
| Shared no listo a tiempo | Ejecutar Sprint Shared-1 en paralelo semana 1 |
| Código legacy incompatible | Reescribir en lugar de refactorizar |
| CTE recursivo lento | Agregar índices, cachear si es necesario |
| Tests legacy no funcionan | Crear tests nuevos con testcontainers |

---

## 📞 PRÓXIMOS PASOS

1. **Revisar este spec completo**
2. **Aprobar el plan de trabajo**
3. **Asignar recursos/desarrolladores**
4. **Crear issues en GitHub** (automático, ver abajo)
5. **Iniciar Sprint Shared-1**

---

## 🔗 ISSUES EN GITHUB (Serán Creados)

Ver sección final para lista de issues que se crearán automáticamente.

---

**Última actualización:** 11 de Noviembre, 2025  
**Status:** ✅ Spec completo, listo para ejecución

---

**Generado con** 🤖 Claude Code
