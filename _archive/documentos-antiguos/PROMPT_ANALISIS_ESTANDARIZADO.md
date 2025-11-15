# 🎯 Prompt Maestro: Transformación de Análisis a Documentación Profesional Estandarizada

## 📋 Descripción
Este prompt transforma documentación técnica informal en análisis profesional estandarizado siguiendo metodologías modernas (Kiro, GitHub Flow, CI/CD) optimizado para ejecución desatendida por IA.

## 🚀 Prompt de Transformación

```markdown
# Transformación de Análisis a Documentación Profesional con Modo Desatendido

## CONTEXTO DEL PROYECTO
- **Proyecto**: [NOMBRE_DEL_PROYECTO]
- **Tipo**: [TIPO_DE_APLICACION]
- **Arquitectura Base**: [ARQUITECTURA_PREFERIDA]
- **Documentación Existente**: [RUTA_A_DOCUMENTACION_ACTUAL]

## DECISIONES ARQUITECTÓNICAS PREDEFINIDAS
[LISTAR_DECISIONES_YA_TOMADAS]
Ejemplo:
- Base de datos: PostgreSQL 15+
- Cache: Redis condicional según costos
- Cobertura: 80% CI/CD, 85% objetivo desarrollador
- Patrón: Hexagonal Architecture

## INSTRUCCIONES DE TRANSFORMACIÓN

### FASE 1: ANÁLISIS Y ESTRUCTURACIÓN

Analiza la documentación existente en [RUTA_A_DOCUMENTACION_ACTUAL] y genera una estructura profesional estandarizada en la carpeta "AnalisisEstandarizado/" siguiendo estas especificaciones:

#### 1.1 ESTRUCTURA DE CARPETAS REQUERIDA
```
AnalisisEstandarizado/
├── 01-Requirements/
│   ├── PRD.md                    # Product Requirements Document
│   ├── FUNCTIONAL_SPECS.md       # Especificaciones funcionales detalladas
│   ├── TECHNICAL_SPECS.md        # Especificaciones técnicas y arquitectura
│   └── ACCEPTANCE_CRITERIA.md    # Criterios de aceptación medibles
│
├── 02-Design/
│   ├── ARCHITECTURE.md           # Diseño arquitectónico completo
│   ├── DATA_MODEL.md            # Modelo de datos y esquemas
│   ├── API_CONTRACTS.md         # Contratos de API/Interfaces
│   └── SECURITY_DESIGN.md       # Modelo de amenazas y seguridad
│
├── 03-Sprints/
│   ├── Sprint-01-[NOMBRE]/
│   │   ├── README.md            # Overview del sprint
│   │   ├── TASKS.md            # Tareas ejecutables sin ambigüedad
│   │   ├── DEPENDENCIES.md     # Dependencias y prerrequisitos
│   │   ├── QUESTIONS.md        # Preguntas con respuestas por defecto
│   │   └── VALIDATION.md       # Checklist de validación
│   │
│   └── Sprint-NN-[NOMBRE]/
│       └── [MISMA_ESTRUCTURA]
│
├── 04-Testing/
│   ├── TEST_STRATEGY.md        # Estrategia de pruebas
│   ├── TEST_CASES.md          # Casos de prueba detallados
│   └── COVERAGE_REPORT.md     # Reporte de cobertura objetivo
│
├── 05-Deployment/
│   ├── DEPLOYMENT_GUIDE.md    # Guía de despliegue
│   ├── INFRASTRUCTURE.md      # IaC y configuración
│   └── MONITORING.md          # Observabilidad y métricas
│
├── PROGRESS.json              # Estado global del proyecto
└── TRACKING_SYSTEM.md        # Sistema de seguimiento
```

### FASE 2: CONTENIDO DE DOCUMENTOS

#### 2.1 REQUIREMENTS (01-Requirements/)

**PRD.md** debe incluir:
- Visión del producto
- Objetivos de negocio medibles
- Stakeholders y sus necesidades
- Restricciones y supuestos
- Criterios de éxito con KPIs

**FUNCTIONAL_SPECS.md** debe incluir:
- Lista numerada de especificaciones funcionales
- Formato: RF-XXX: [Descripción]
- Prioridad: MUST/SHOULD/COULD/WON'T
- Criterios de aceptación por spec

**TECHNICAL_SPECS.md** debe incluir:
- Stack tecnológico completo con versiones
- Requisitos de performance (latencia, throughput)
- Requisitos de escalabilidad
- SLAs y objetivos de disponibilidad
- Matriz de compatibilidad

**ACCEPTANCE_CRITERIA.md** debe incluir:
- Criterios SMART para cada requisito
- Métricas cuantificables
- Definición de "Done"

#### 2.2 DESIGN (02-Design/)

**ARCHITECTURE.md** debe incluir:
- Diagramas C4 (Context, Container, Component)
- Patrones arquitectónicos aplicados
- Decisiones arquitectónicas (ADRs)
- Flujos de datos principales
- Manejo de estado y concurrencia

**DATA_MODEL.md** debe incluir:
- Esquemas de base de datos en SQL
- Estrategias de indexación
- Políticas de particionamiento
- Estrategia de backups
- Modelo de encriptación

**API_CONTRACTS.md** debe incluir:
- OpenAPI 3.0 specifications
- Modelos de request/response
- Códigos de error estandarizados
- Versionado de API
- Rate limiting y throttling

**SECURITY_DESIGN.md** debe incluir:
- Modelo de amenazas (STRIDE)
- Controles de seguridad por capa
- Compliance requirements (OWASP, GDPR)
- Estrategia de autenticación/autorización
- Manejo de secretos

#### 2.3 SPRINTS (03-Sprints/)

Cada Sprint debe ser AUTO-EJECUTABLE con:

**TASKS.md**:
```markdown
# Sprint XX - [Nombre]

## Objetivo
[Descripción clara del objetivo del sprint]

## Tareas

### TASK-001: [Nombre de la tarea]
**Tipo**: feature|fix|refactor|test|docs
**Prioridad**: HIGH|MEDIUM|LOW
**Estimación**: Xh
**Asignado a**: @ai-executor

#### Descripción
[Descripción detallada de qué hacer]

#### Pasos de Implementación
1. Crear archivo `path/to/file.ext`
2. Implementar función con esta firma exacta:
   ```language
   function signature() {
       // implementation
   }
   ```
3. Agregar tests unitarios
4. Actualizar documentación

#### Criterios de Aceptación
- [ ] Archivo creado en la ruta especificada
- [ ] Tests pasando con cobertura >85%
- [ ] Sin errores de linting
- [ ] Documentación actualizada

#### Comandos de Validación
```bash
# Verificar implementación
go test ./path/to/package -v

# Verificar cobertura
go test ./path/to/package -cover

# Verificar linting
golangci-lint run ./path/to/package
```
```

**DEPENDENCIES.md**:
```markdown
# Dependencias del Sprint

## Dependencias Técnicas
- [ ] PostgreSQL 15+ instalado
- [ ] Go 1.21+ configurado
- [ ] Docker 24+ disponible

## Dependencias de Código
- [ ] Sprint-01 completado
- [ ] Package `domain/entities` creado
- [ ] Tests del sprint anterior pasando

## Herramientas Requeridas
```bash
# Instalar dependencias
go get github.com/stretchr/testify
go get github.com/golang-migrate/migrate/v4
npm install -g @stoplight/spectral-cli
```
```

**QUESTIONS.md**:
```markdown
# Preguntas y Decisiones

## Q001: [Pregunta]
**Contexto**: [Por qué surge esta pregunta]
**Opciones**:
1. Opción A - [Descripción]
2. Opción B - [Descripción]

**Decisión por defecto**: Opción A
**Justificación**: [Por qué esta opción es la mejor]
**Comando si se elige Opción A**:
```bash
# Implementación para Opción A
```
**Comando si se elige Opción B**:
```bash
# Implementación para Opción B
```
```

**VALIDATION.md**:
```markdown
# Validación del Sprint

## Checklist Automatizado

### Pre-validación
```bash
# Verificar estado del proyecto
git status
go mod tidy
```

### Tests Unitarios
```bash
# Ejecutar tests del sprint
go test ./... -tags=sprint01 -v
```

### Cobertura
```bash
# Verificar cobertura mínima 80%
go test ./... -cover -coverprofile=coverage.out
go tool cover -html=coverage.out -o coverage.html
```

### Integración
```bash
# Tests de integración
docker-compose -f test-compose.yml up -d
go test ./... -tags=integration
docker-compose -f test-compose.yml down
```

### Criterios de Éxito
- [ ] Todos los tests unitarios pasando
- [ ] Cobertura >80%
- [ ] Tests de integración exitosos
- [ ] Sin warnings de linter
- [ ] Documentación actualizada
```

### FASE 3: SISTEMA DE TRACKING

**PROGRESS.json**:
```json
{
  "project": "[NOMBRE_DEL_PROYECTO]",
  "total_sprints": 10,
  "total_tasks": 175,
  "current_sprint": 1,
  "current_task": "TASK-001",
  "completed_tasks": [],
  "failed_tasks": [],
  "skipped_tasks": [],
  "sprint_status": {
    "Sprint-01": "pending",
    "Sprint-02": "blocked"
  },
  "last_execution": "2024-12-19T10:00:00Z",
  "execution_mode": "unattended",
  "ai_executor": "claude-3.5",
  "validation_results": {}
}
```

**TRACKING_SYSTEM.md**:
```markdown
# Sistema de Tracking para Ejecución Desatendida

## Reglas de Ejecución

1. **Inicio de Sesión**:
   - Leer PROGRESS.json
   - Identificar current_sprint y current_task
   - Continuar desde el punto exacto de interrupción

2. **Ejecución de Tareas**:
   - Seguir orden secuencial estricto
   - No saltar tareas a menos que estén en skipped_tasks
   - Actualizar PROGRESS.json después de cada tarea

3. **Manejo de Errores**:
   - Reintentar 3 veces antes de marcar como failed
   - Documentar error en failed_tasks con timestamp
   - Continuar con siguiente tarea no dependiente

4. **Validación**:
   - Ejecutar VALIDATION.md al final de cada sprint
   - No proceder al siguiente sprint sin validación exitosa
   - Generar reporte de validación

5. **Commits y PRs**:
   - Un commit por tarea completada
   - Un PR por sprint completado
   - Formato: "feat(sprint-XX): complete TASK-XXX - [description]"
```

### FASE 4: CRITERIOS DE CALIDAD

Todos los documentos deben cumplir:

1. **Sin Ambigüedades**:
   - Cada instrucción debe ser ejecutable sin interpretación
   - Todos los paths deben ser absolutos o relativos a la raíz
   - Todas las versiones deben ser exactas

2. **Defaults Explícitos**:
   - Cada decisión debe tener una opción por defecto
   - Los defaults deben estar justificados
   - Debe incluir comando exacto para implementar el default

3. **Validación Automatizable**:
   - Cada tarea debe tener comandos de validación
   - Los criterios de éxito deben ser medibles
   - Debe incluir scripts de validación

4. **Trazabilidad**:
   - Cada tarea debe referenciar requisitos
   - Cada commit debe referenciar tareas
   - Cada PR debe referenciar sprints

5. **Idempotencia**:
   - Las tareas deben ser re-ejecutables sin efectos secundarios
   - Los scripts deben verificar estado antes de ejecutar
   - Debe soportar recuperación de errores

## ENTREGABLES ESPERADOS

1. Estructura completa AnalisisEstandarizado/
2. Mínimo 10 sprints con 15-20 tareas cada uno
3. Cobertura de tareas >95% de requisitos
4. Sistema de tracking funcional
5. Scripts de validación ejecutables
6. Documentación sin ambigüedades
7. Defaults para todas las decisiones

## MODO DE EJECUCIÓN DESATENDIDA

El sistema debe permitir que cualquier IA pueda:
1. Clonar el repositorio
2. Leer PROGRESS.json
3. Ejecutar tareas secuencialmente
4. Validar cada sprint
5. Crear commits y PRs automáticamente
6. Continuar desde interrupciones
7. Reportar progreso sin intervención humana

---

Genera la documentación completa siguiendo estas especificaciones. Comienza con la estructura de carpetas y luego genera cada documento con el nivel de detalle especificado.
```

## 📝 Instrucciones de Uso

### 1. Preparación
1. **Identifica tu proyecto**: Nombre, tipo, arquitectura base
2. **Localiza tu documentación actual**: Ruta a análisis existente
3. **Define decisiones arquitectónicas**: Base de datos, cache, frameworks

### 2. Personalización del Prompt
Reemplaza los siguientes placeholders:
- `[NOMBRE_DEL_PROYECTO]`: Ej: "Baileys-Go"
- `[TIPO_DE_APLICACION]`: Ej: "WhatsApp Web Client Worker"
- `[ARQUITECTURA_PREFERIDA]`: Ej: "Hexagonal/Clean Architecture"
- `[RUTA_A_DOCUMENTACION_ACTUAL]`: Ej: "./AnalisisReal/"
- `[LISTAR_DECISIONES_YA_TOMADAS]`: Lista tus decisiones predefinidas

### 3. Ejecución
1. Copia el prompt personalizado
2. Pégalo en tu IA preferida (Claude, GPT-4, etc.)
3. La IA generará la estructura completa en `AnalisisEstandarizado/`
4. Revisa y ajusta según necesidades específicas

### 4. Validación
- Verifica que todos los sprints tengan tareas ejecutables
- Confirma que QUESTIONS.md tiene defaults para todo
- Asegura que VALIDATION.md es automatizable
- Prueba TRACKING_SYSTEM.md con una tarea

## 🎯 Resultado Esperado
- Documentación profesional estandarizada
- Sistema de ejecución desatendida por IA
- Cero ambigüedades en instrucciones
- Trazabilidad completa de requisitos a código
- Capacidad de recuperación ante interrupciones

## 📚 Ejemplos de Uso
- Transformación de análisis técnico informal
- Estandarización de documentación legacy
- Preparación de proyectos para AI-assisted development
- Implementación de CI/CD con ejecución automática

## 🔄 Versionado
- **Versión**: 1.0.0
- **Fecha**: 2024-12-19
- **Autor**: Sistema de Análisis Estandarizado
- **Proyecto Original**: Baileys-Go

## 📄 Licencia
Este template es de uso libre para transformación de documentación técnica.
