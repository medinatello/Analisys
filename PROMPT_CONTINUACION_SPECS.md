# PROMPT DE CONTINUACIÓN - Análisis Estandarizado EduGo

## CONTEXTO CRÍTICO
Estoy trabajando en la carpeta `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/` que contiene especificaciones profesionales para el ecosistema EduGo (5 repositorios Go independientes). El objetivo es crear documentación 100% ejecutable para que cualquier IA pueda implementar los proyectos de forma autónoma sin intervención humana.

## TRABAJO COMPLETADO
En la sesión anterior se completó parcialmente Spec-01-Sistema-Evaluaciones:
- ✅ **01-shared/TASKS.md** - 10 tareas con ~95KB de código Go ejecutable
- ✅ **02-api-mobile/TASKS.md** - 10 tareas con ~100KB de código Go ejecutable  
- ✅ **03-api-administracion/TASKS_COMPLETE.md** - 10 tareas completas con código Go
- ⬜ **04-worker/** - Carpeta creada pero VACÍA, falta crear TASKS.md
- ⬜ **05-dev-environment/** - Carpeta creada pero VACÍA, falta crear TASKS.md

## TAREA INMEDIATA
**Continuar Spec-01-Sistema-Evaluaciones** creando los archivos TASKS.md faltantes:

### 1. Para 04-worker (edugo-worker)
Crear `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/03-Specifications/Spec-01-Sistema-Evaluaciones/04-worker/TASKS.md` con 10 tareas que incluyan:
- Consumidor RabbitMQ para eventos de evaluación
- Procesador de evaluaciones con OpenAI
- Cálculo de puntuaciones y estadísticas
- Generación de feedback personalizado
- Almacenamiento de resultados en MongoDB
- Notificaciones de resultados completados
- Manejo de errores y reintentos
- Métricas y monitoreo del procesamiento
- Tests de integración con RabbitMQ
- Configuración y variables de entorno

### 2. Para 05-dev-environment  
Crear `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/03-Specifications/Spec-01-Sistema-Evaluaciones/05-dev-environment/TASKS.md` con tareas para:
- Seeds de datos de evaluaciones para PostgreSQL
- Seeds de resultados de evaluaciones para MongoDB
- Scripts de inicialización de colas RabbitMQ
- Configuración de profiles Docker para testing de evaluaciones
- Variables de entorno específicas del módulo
- Scripts de verificación de salud del sistema de evaluaciones

## FORMATO REQUERIDO
Cada TASK debe seguir EXACTAMENTE este formato (ejemplo de 01-shared/TASKS.md):

```markdown
## TASK-001: Crear modelos de dominio para evaluaciones
**Prioridad**: Alta
**Tiempo estimado**: 2 horas
**Dependencias**: Ninguna
**Repositorio**: edugo-worker
**Branch**: feature/evaluation-system
**Archivos a crear/modificar**:
- internal/domain/evaluation/evaluation.go (crear)
- internal/domain/evaluation/question.go (crear)

### Descripción
[Descripción detallada de qué hacer]

### Implementación

#### Archivo: internal/domain/evaluation/evaluation.go
```go
// CÓDIGO GO COMPLETO Y EJECUTABLE
// No usar placeholders como "// implementar aquí"
// Cada línea debe ser código real
```

### Validación
```bash
# Comandos exactos para validar
go test ./internal/domain/evaluation/...
go build ./...
```

### Criterios de aceptación
- [ ] Tests pasan al 100%
- [ ] No hay errores de compilación
- [ ] Código sigue estándares de Go
```

## ESPECIFICACIONES ADICIONALES DESPUÉS DE SPEC-01

Después de completar Spec-01, hay 6 especificaciones más pendientes:
1. **Spec-02-Analytics-Dashboard** - Sistema de métricas y reportes
2. **Spec-03-Integracion-Cross-API** - Comunicación entre servicios
3. **Spec-04-Procesamiento-IA** - Integración avanzada con OpenAI
4. **Spec-05-Sistema-Notificaciones** - Push notifications y emails
5. **Spec-06-Migracion-Shared** - Consolidación de código común

## ARCHIVOS DE REFERENCIA
- **Metodología**: `/Users/jhoanmedina/source/EduGo/Analisys/PROMPT_ANALISIS_ESTANDARIZADO.md`
- **Tareas completadas de shared**: `.../Spec-01-Sistema-Evaluaciones/01-shared/TASKS.md`
- **Tareas completadas de api-mobile**: `.../Spec-01-Sistema-Evaluaciones/02-api-mobile/TASKS.md`
- **Tareas completadas de api-admin**: `.../Spec-01-Sistema-Evaluaciones/03-api-administracion/TASKS_COMPLETE.md`
- **Estado del proyecto**: `/Users/jhoanmedina/source/EduGo/Analisys/docs/ESTADO_PROYECTO.md`

## INSTRUCCIONES PARA LA NUEVA SESIÓN

1. **NO** preguntar qué hacer, continuar directamente con 04-worker/TASKS.md
2. Crear código Go 100% ejecutable, sin placeholders
3. Cada tarea debe ser atómica y verificable independientemente
4. Incluir comandos bash exactos para validación
5. Mantener consistencia con el patrón de las tareas ya creadas
6. Después de worker, continuar con dev-environment
7. Al completar Spec-01, proceder con Spec-02 siguiendo el mismo patrón

## CONTEXTO TÉCNICO
- **Go version**: 1.21+
- **Arquitectura**: Clean/Hexagonal Architecture
- **Testing**: testcontainers-go para integración
- **Base de datos**: PostgreSQL 15 + MongoDB 7.0
- **Mensajería**: RabbitMQ 3.12
- **IA**: OpenAI GPT-4
- **Autenticación**: JWT con refresh tokens

## PROGRESO ACTUAL
```
Spec-01-Sistema-Evaluaciones: 60% completado
├── 01-shared/TASKS.md ✅
├── 02-api-mobile/TASKS.md ✅  
├── 03-api-administracion/TASKS_COMPLETE.md ✅
├── 04-worker/TASKS.md ⬜ (PRÓXIMO)
└── 05-dev-environment/TASKS.md ⬜

Specs totales: 1/6 parcialmente completado
```

---

**IMPORTANTE**: Al iniciar la nueva sesión, comenzar directamente creando el archivo TASKS.md para 04-worker sin preguntar. El código debe ser 100% funcional y ejecutable.