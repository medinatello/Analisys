# Reglas del Proyecto: Módulo Testing

---

## Comunicación
- Español en todos los mensajes
- Resúmenes claros y concisos
- Informar progreso constantemente

---

## Gestión de Contexto
- Completar cada fase en sesión continua si es posible
- Si fase >2 horas, evaluar split
- Si contexto >50K tokens, crear checkpoint en LOGS.md
- Máximo 3 fases consecutivas sin validación
- Validar fase anterior cerrada antes de nueva fase

---

## Logs
- Documentar en `specs/shared-testcontainers/LOGS.md`
- Incluir hora, duración, estado de cada tarea
- Marcar como completada al terminar
- Sin marca = tarea interrumpida

---

## Ramas

### edugo-shared
- **NUNCA** trabajar directo en main
- Crear rama feature desde dev
- Validar dev actualizado antes de crear rama
- Una rama por fase

### api-mobile, api-admin, worker
- Crear rama feature desde dev
- Validar dev actualizado
- Una rama por migración

### edugo-dev-environment
- **EXCEPCIÓN:** Solo tiene main, trabajar en feature branch
- PR directo a main

---

## Pull Requests

### Todos los PRs
- Título claro y conciso
- Descripción detallada
- PRs a dev (excepto dev-environment)
- Esperar CI/CD máximo 5 minutos
- Esperar review de Copilot

### Solución de CI/CD
- Todos los checks deben pasar
- Si falla:
  - Crear documento en CICD_ISSUES/ (si no existe)
  - Documentar error con ID único
  - Buscar errores similares previos
  - Documentar solución aplicada
  - Push y esperar nuevamente (máximo 5 min)

### Solución de Copilot
- Analizar cada comentario:
  - **Corrección inmediata:** Aplicar si es <3 puntos Fibonacci
  - **3-8 puntos:** Crear issue para siguiente fase
  - **>8 puntos:** Crear issue como deuda técnica
  - **No aplica:** Justificar en PR

### Al Terminar Revisiones
- Si bloqueado: notificar usuario
- Si hay issues creadas: notificar y esperar
- Si todo OK: mergear y continuar

---

## Excepciones

### shared (módulo testing)
- PR a dev primero
- Mergear a dev
- **NO** crear releases desde dev
- PR dev → main
- Mergear a main
- Crear release testing/v0.6.0 desde main

### Proyectos consumidores
- Actualizar go.mod con testing@v0.6.0
- PR a dev
- Mergear
- NO necesitan release inmediato

---

## Testing

### Módulo shared/testing
- Coverage >70% obligatorio
- Tests unitarios de cada container
- Tests de integración del manager
- Tests con Docker en CI/CD

### Proyectos migrados
- Todos los tests previos deben seguir pasando
- No se aceptan regresiOnes
- Tiempo de ejecución no debe aumentar >10%

---

## Commits

**Formato:** `tipo(scope): descripción`

**Tipos:**
- feat: Nueva funcionalidad
- fix: Corrección de bug
- refactor: Refactorización
- test: Tests
- docs: Documentación
- chore: Mantenimiento

**Ejemplos:**
```
feat(testing): add PostgreSQL container wrapper
test(testing): add manager integration tests
refactor(mobile): migrate to shared/testing
docs(dev-env): add profiles documentation
```

---

## Performance

### Objetivos
- Setup inicial: <60s (con todos los containers)
- Setup PostgreSQL solo: <30s
- Cleanup entre tests: <2s
- Memoria: <1GB con todos los containers

### Monitoreo
- Benchmark en CI/CD
- Alertar si supera objetivos +20%

---

## Versionado

### shared/testing
- Primer release: v0.6.0 (continúa numeración de shared)
- Siguientes: v0.7.0, v0.8.0, etc.
- Breaking changes: major version

### Proyectos consumidores
- Actualizar shared/testing en go.mod
- Pin versión específica (no use latest)
- Actualizar cuando sea estable

---

## Prioridades

### P0 (Crítico)
- Manager funcional
- PostgreSQL container
- Tests del módulo pasando

### P1 (Alto)
- MongoDB container
- RabbitMQ container
- Migración de api-mobile

### P2 (Medio)
- Migración de api-admin
- Tests en worker
- dev-environment profiles

### P3 (Bajo)
- S3 container
- Seeds genéricos
- Parallel startup

---

## Decisiones Técnicas

### Singleton vs Factory
**Decisión:** Singleton  
**Razón:** Performance (crear containers es costoso)

### Configuración
**Decisión:** Builder pattern  
**Razón:** API clara, defaults sensatos, extensible

### Cleanup
**Decisión:** Truncate entre tests, Terminate al final  
**Razón:** Balance entre aislamiento y performance

### Versionado de Imágenes
**Decisión:** Match con producción  
**Razón:** Detectar incompatibilidades temprano

---

## Excepciones Especiales

### Si CI/CD tarda >10 minutos
- Notificar al usuario
- No bloquear por tiempo excesivo
- Validar compilación local

### Si Docker no está disponible
- Tests de integración se skipean automáticamente
- CI/CD debe tener Docker
- Localmente es opcional

---

**RULES.md Completado** ✅

