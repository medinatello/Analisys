# Reglas del Proyecto: Módulo Testing

---

## Comunicación
- Español en todos los mensajes
- Resúmenes claros y concisos
- Informar progreso constantemente
- Claridad y rapidez, el usuario pedirá más detalles si es necesario

---

## Gestión de Contexto
- Completar cada fase en sesión continua si es posible
- Si fase >2 horas, evaluar split en sub-fases
- Si contexto >50K tokens, crear checkpoint en LOGS.md y pausar
- Máximo 3 fases consecutivas sin validación del usuario
- Antes de iniciar fase nueva, validar que fase anterior está completamente cerrada (PR mergeado, logs actualizados)
- Al retomar trabajo después de interrupción, leer LOGS.md primero para recuperar contexto
- Si se detecta acumulación excesiva de tareas pendientes, detener y consolidar antes de continuar

---

## Logs
- Documentar en `specs/shared-testcontainers/LOGS.md`
- Incluir hora, duración, estado de cada tarea
- Marcar como completada al terminar
- Sin marca = tarea interrumpida
- Logs permiten saber dónde retomar si el trabajo se interrumpe

---

## Ramas

### edugo-shared (también llamado "shared")
- **NUNCA** trabajar directo en main
- Crear rama feature desde dev
- **VALIDAR dev actualizado** antes de crear rama
- **VALIDAR dev actualizado de main remoto** para evitar conflictos
- Una rama por fase (o agrupar si tiene sentido)
- Evitar ramas con muchas responsabilidades

### api-mobile, api-admin, worker
- Crear rama feature desde dev
- Validar dev actualizado local y remoto
- Una rama por migración
- api-mobile se refiere a edugo-api-mobile
- api-admin se refiere a edugo-api-administracion  
- worker se refiere a edugo-worker

### edugo-dev-environment (también llamado "dev-environment")
- **EXCEPCIÓN:** Solo tiene main, trabajar en feature branch
- PR directo a main
- No tiene rama dev

---

## Pull Requests

### Crear PR
- Título claro y conciso
- Descripción detallada de cambios
- Pasos para probar los cambios
- PRs a dev (excepto dev-environment que va a main)

### Espera de CI/CD
- **Fase de espera escalonada: máximo 5 minutos total**
- Esperar que se ejecute CI/CD completo
- Todos los checks deben pasar (incluso los opcionales)
- Si pasa 5 minutos: detener proceso y notificar al usuario

### Espera de Copilot Review
- Paralelamente al CI/CD, espera review de Copilot
- Esperar que termine completamente su revisión
- Copilot genera comentarios en el PR

---

## Solución de Errores CI/CD

### Cuando CI/CD falla:

1. **Crear carpeta** `CICD_ISSUES/` si no existe en `specs/shared-testcontainers/`

2. **Crear archivo markdown** con formato: `YYYY-MM-DD_PR-{numero}.md`

3. **Documentar cada error en secciones:**
   - **ID único aleatorio** como título de sección
   - Descripción del error y situación en que ocurrió
   - Información valiosa para contexto futuro
   - Posibles soluciones a aplicar
   - Solución aplicada

4. **Buscar errores similares previos:**
   - Antes de aplicar solución, buscar ID de errores similares
   - Incluir información de errores anteriores en el análisis
   - Evitar parches uno a uno, analizar causa raíz
   - Ejemplo: error de versión de Go requiere análisis completo, no parches

5. **Aplicar solución y push:**
   - Documentar qué se aplicó
   - Push y esperar nuevamente CI/CD
   - **Máximo 5 minutos de espera nuevamente**
   - Si no pasa: detener y notificar usuario

---

## Solución de Copilot Review

### Análisis de cada comentario:

1. **Corrección Inmediata (P0):**
   - Clasificar como prioritaria
   - Aplicar inmediatamente

2. **Correcciones de Traducción/Documentación:**
   - Descartar
   - Justificar en PR por qué no se aplica

3. **Correcciones que Aplican (usar Fibonacci):**

   - **≤3 puntos:** Aplicar en este PR
   
   - **4-8 puntos:** 
     - Crear issue en GitHub
     - Documentar en PR que se creó la issue
     - Clasificar para ejecutarse en fase intermedia
     - Ejemplo: Si estamos en tarea 3, crear tarea 3.5 antes de tarea 4
     - La tarea intermedia sigue el mismo estándar (rama, PR, CI/CD, etc.)
   
   - **>8 puntos:**
     - Crear issue en GitHub como deuda técnica
     - Documentar en PR
     - Informar al usuario sobre deuda técnica
     - Dar 3 posibles soluciones
     - Aconsejar cuándo ejecutarlo según plan completo

4. **Sugerencias que no aplican:**
   - Documentar en PR por qué no se aplican
   - Informar al usuario

### Después de aplicar correcciones:
- Esperar CI/CD (máximo 5 minutos)
- Si no pasa: detener y notificar

---

## Al Terminar Revisiones

### Validaciones finales:

1. **Si PR está bloqueado:**
   - Detener y notificar al usuario

2. **Si hay issues creadas (tarea intermedia o deuda técnica):**
   - Notificar al usuario
   - Esperar instrucciones

3. **Si todo está OK:**
   - Hacer merge a dev
   - Continuar a siguiente tarea

---

## Excepciones Especiales

### shared (módulo testing)

**Proceso completo:**
1. PR a dev
2. Mergear a dev
3. **NO crear releases desde dev**
4. PR dev → main
5. Mergear a main
6. **Crear release testing/v0.6.0 desde main**
7. Incluir comentario que es release desde main

**Importante:** shared requiere releases por módulos para poder actualizar en otros proyectos

### Proyectos consumidores (api-mobile, api-admin, worker)
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
- No se aceptan regresiones
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
- **Releases solo desde main, no desde dev**

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

## Timeouts y Límites

### CI/CD
- **Máximo 5 minutos de espera por ejecución**
- Si tarda >5 min: detener y notificar usuario
- No bloquear por tiempo excesivo

### Si Docker no está disponible
- Tests de integración se skipean automáticamente
- CI/CD debe tener Docker
- Localmente es opcional

### Si contexto >50K tokens
- Crear checkpoint en LOGS.md
- Pausar y consolidar
- Validar con usuario antes de continuar

---

**RULES.md v2.0 - Actualizado con políticas de espera** ✅
