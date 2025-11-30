---
description: Iniciar trabajo en un sprint del proyecto mock-migration
---

# Iniciar Sprint - Mock Migration Project

Prepara el entorno y contexto para trabajar en un sprint específico del proyecto de migración de mocks.

## Archivos a Leer (en orden)

1. **Reglas de Sprint y PR:**
   ```
   /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/REGLAS-SPRINT-PR.md
   ```

2. **Tracking Maestro (estado global):**
   ```
   /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/TRACKING-MAESTRO.md
   ```

3. **README del Proyecto:**
   ```
   /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/README.md
   ```

## Proyectos Involucrados

| Proyecto | Ruta Local |
|----------|------------|
| edugo-api-administracion | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion` |
| edugo-api-mobile | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile` |
| edugo-shared | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared` |
| edugo-infrastructure | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure` |

## Instrucciones de Ejecución

### Paso 1: Leer Documentación Base
Lee los 3 archivos listados arriba en orden para entender:
- Las reglas de gestión de sprints y PRs
- El estado actual del proyecto
- La estructura general

### Paso 2: Identificar Sprint Actual
Basándote en el TRACKING-MAESTRO.md:
- Determinar qué fase está activa (API-ADMIN o API-MOBILE)
- Identificar el sprint actual a ejecutar
- Verificar prerrequisitos completados

### Paso 3: Evaluar Estado de Rama
Ir al proyecto correspondiente y ejecutar la evaluación según REGLAS-SPRINT-PR.md:
- Verificar rama actual
- Evaluar código sin commitear
- Verificar PRs abiertos o mergeados

### Paso 4: Cargar Contexto del Sprint
Una vez identificado el sprint:
- Leer el README.md del sprint
- Leer el CHECKLIST.md del sprint
- Identificar el primer paso pendiente

### Paso 5: Confirmar con Usuario
Presentar al usuario:
- Sprint identificado
- Estado actual
- Próximo paso a ejecutar
- Solicitar confirmación antes de continuar

## Estructura de Sprints

### API-Administración
```
sprints-ejecucion/api-administracion/
├── sprint-0-preparacion/
├── sprint-1-parser-sql/
├── sprint-2-generador-dataset/
└── sprint-3-integracion-api/
```

### API-Mobile
```
sprints-ejecucion/api-mobile/
├── sprint-0-preparacion/
├── sprint-1-reutilizar-generador/
├── sprint-2-implementar-fixtures/
└── sprint-3-integracion-api/
```

## Tracking por API

- **API Admin:** `sprints-ejecucion/tracking-api-admin.md`
- **API Mobile:** `sprints-ejecucion/tracking-api-mobile.md`

## Notas Importantes

- Fase 1 (API-Admin) debe completarse antes de Fase 2 (API-Mobile)
- Cada paso del sprint tiene criterios de validación
- No saltar pasos; cada uno valida el anterior
- Actualizar CHECKLIST.md al completar cada paso

---

**Comando:** `/iniciar-sprint`
