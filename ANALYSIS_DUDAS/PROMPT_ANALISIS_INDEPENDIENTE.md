# 📋 Prompt para Análisis Independiente de Documentación - EduGo

## Objetivo Principal

Realizar un análisis exhaustivo e independiente de la documentación técnica del ecosistema EduGo para detectar ambigüedades, información faltante y problemas de orquestación que impedirían el desarrollo desatendido por IA.

## Contexto del Proyecto

EduGo es un ecosistema educativo compuesto por 5 proyectos independientes:
- **edugo-api-mobile**: API REST para aplicación móvil (puerto 8080)
- **edugo-api-administracion**: API REST administrativa (puerto 8081)
- **edugo-worker**: Procesador asíncrono con integración IA
- **edugo-shared**: Biblioteca compartida Go
- **edugo-dev-environment**: Infraestructura Docker para desarrollo

Todos comparten: PostgreSQL 15+, MongoDB 7.0+, RabbitMQ 3.12+

## Ubicaciones de Trabajo

**Base del proyecto:** `/Users/jhoanmedina/source/EduGo/Analisys/`

**Carpetas a analizar:**
1. `/Users/jhoanmedina/source/EduGo/Analisys/AnalisisEstandarizado/`
2. `/Users/jhoanmedina/source/EduGo/Analisys/00-Projects-Isolated/`

**Tu carpeta de output:** `/Users/jhoanmedina/source/EduGo/Analisys/ANALYSIS_DUDAS/[tu-nombre]/`
(Crear carpeta con tu nombre: gemini, copilot, gpt4, claude, etc.)

## Análisis Requerido

### PARTE 1: Análisis de Carpeta AnalisisEstandarizado

Esta carpeta representa la **visión global del ecosistema** donde todos los proyectos se ven como un todo integrado.

#### Qué analizar:

1. **Completitud de la documentación global**
   - ¿Están definidas TODAS las decisiones arquitectónicas?
   - ¿Los contratos entre servicios están especificados?
   - ¿Las dependencias están claramente versionadas?

2. **Ambigüedades técnicas que bloquearían desarrollo**
   
   Ejemplo de ambigüedad crítica:
   ```
   Documentación dice: "Implementar base de datos para persistencia"
   
   Ambigüedad: No especifica qué base de datos
   Impacto: IA no puede proceder sin esta decisión
   Necesario: Especificar "PostgreSQL 15+" o la BD específica
   ```

3. **Información faltante para desarrollo desatendido**
   - Schemas de base de datos completos
   - Estructura de eventos de mensajería
   - Formato de APIs (REST, GraphQL, gRPC?)
   - Modelos de datos exactos
   - Configuraciones requeridas

4. **Orquestación del ecosistema**
   - ¿El orden de desarrollo tiene sentido?
   - ¿Hay dependencias circulares?
   - ¿Se puede desarrollar en paralelo?
   - ¿Qué debe existir antes que qué?

#### Archivos clave a revisar:
- `README.md` - Visión general
- `MASTER_PLAN.md` - Plan de implementación
- `00-Overview/EXECUTION_ORDER.md` - Orden obligatorio
- `00-Overview/PROJECTS_MATRIX.md` - Dependencias
- `spec-*/` - Cada especificación disponible

### PARTE 2: Análisis de Carpeta 00-Projects-Isolated

Esta carpeta contiene la **documentación aislada por proyecto**, donde cada proyecto debe ser completamente autónomo.

#### Qué verificar para CADA proyecto (api-mobile, api-admin, worker, shared, dev-environment):

1. **Autonomía completa**
   - ¿Contiene TODA la información necesaria?
   - ¿Puede desarrollarse sin consultar archivos externos?
   - ¿Las decisiones globales están replicadas aquí?

2. **Consistencia con visión global**
   - ¿La información coincide con AnalisisEstandarizado?
   - ¿Hay contradicciones?
   - ¿Se perdió información en la separación?

3. **Completitud para desarrollo desatendido**
   
   Para cada proyecto debe estar claro:
   ```
   - Tecnología exacta a usar (versiones específicas)
   - Estructura de carpetas esperada
   - Archivos exactos a crear
   - Contenido de cada archivo (o templates)
   - Tests a implementar
   - Configuración requerida
   ```

4. **Información duplicada correctamente**
   
   Ejemplo: Si en carpeta 1 se decide usar PostgreSQL 15+, 
   en carpeta 2 CADA proyecto que use BD debe tener esta información

## Tipos de Problemas a Detectar

### 1. Ambigüedades Críticas (Bloqueantes)

Situaciones donde una IA no puede tomar decisión:
```
Ejemplo:
"Implementar autenticación segura"

Problema: ¿JWT? ¿OAuth? ¿Sessions? ¿API Keys?
Impacto: Desarrollo detenido esperando clarificación
Solución: Especificar "JWT con RS256 y refresh tokens"
```

### 2. Información Faltante

Datos necesarios que no están documentados:
```
Ejemplo:
"Crear endpoint para obtener evaluaciones"

Falta:
- Método HTTP (GET, POST?)
- Ruta exacta (/evaluations? /api/v1/evaluations?)
- Parámetros de entrada
- Formato de respuesta
- Códigos de error
```

### 3. Problemas de Orquestación

Dependencias mal definidas o conflictivas:
```
Ejemplo:
- Proyecto A necesita librería de Proyecto B
- Proyecto B necesita datos de Proyecto A
- Dependencia circular no resuelta
```

### 4. Inconsistencias entre Documentaciones

Información contradictoria:
```
Carpeta 1: "Worker procesa eventos cada 5 segundos"
Carpeta 2: "Worker procesa eventos en tiempo real"
```

## Estructura de Output Requerida

Crear los siguientes archivos en tu carpeta asignada:

### 1. ANALISIS_AMBIGUEDADES.md

```markdown
# 🔍 Análisis de Ambigüedades - Documentación EduGo

## Resumen Ejecutivo
[Cantidad de ambigüedades encontradas, impacto general]

## Ambigüedades Críticas (Bloqueantes)

### 1. [Nombre de la ambigüedad]
**Ubicación:** [Archivo y línea donde se encontró]
**Descripción:** [Qué dice la documentación]
**Por qué es ambiguo:** [Qué falta o no está claro]
**Impacto:** [Cómo afecta el desarrollo]
**Información necesaria:** [Qué se necesita especificar]
**Solución propuesta:** [Cómo resolverlo]

[Repetir para cada ambigüedad crítica]

## Ambigüedades Menores (No bloqueantes)
[Lista de ambigüedades que se pueden resolver con defaults razonables]
```

### 2. INFORMACION_FALTANTE.md

```markdown
# 📝 Información Faltante para Desarrollo Desatendido

## Por Categoría

### Schemas de Base de Datos
- [ ] [Tabla/Colección faltante]
- [ ] [Índices no definidos]
- [ ] [Relaciones no especificadas]

### Contratos de API
- [ ] [Endpoint sin especificación completa]
- [ ] [Formato de request/response faltante]

### Configuración
- [ ] [Variables de entorno no documentadas]
- [ ] [Valores default no especificados]

### Eventos y Mensajería
- [ ] [Estructura de eventos no definida]
- [ ] [Colas/Exchanges no especificados]

## Por Proyecto

### edugo-shared
[Lista específica de qué falta]

### api-mobile
[Lista específica de qué falta]

[Continuar para cada proyecto]
```

### 3. PROBLEMAS_ORQUESTACION.md

```markdown
# 🔄 Problemas de Orquestación Detectados

## Orden de Desarrollo

### Problemas Encontrados
1. [Descripción del problema de orden]
   - Documentado: [Qué dice la documentación]
   - Problema: [Por qué no funciona]
   - Solución: [Orden correcto propuesto]

## Dependencias

### Dependencias No Resueltas
[Lista de dependencias que no están claras]

### Dependencias Circulares
[Si existen, listarlas con explicación]

## Desarrollo en Paralelo

### Qué SÍ se puede desarrollar en paralelo
[Lista de proyectos/módulos]

### Qué NO se puede desarrollar en paralelo
[Lista con explicación de por qué]
```

### 4. ANALISIS_POR_PROYECTO.md

```markdown
# 📦 Análisis Detallado por Proyecto

## edugo-shared
### Estado de documentación
- Completitud: [X%]
- Ambigüedades encontradas: [N]
- Información faltante crítica: [Lista]
### Puede desarrollarse autónomamente: [SÍ/NO]
### Razón: [Explicación]

## api-mobile
[Mismo formato]

## api-admin
[Mismo formato]

## worker
[Mismo formato]

## dev-environment
[Mismo formato]
```

### 5. RESUMEN_EJECUTIVO.md

```markdown
# 📊 Resumen Ejecutivo del Análisis

## Veredicto General
[¿La documentación permite desarrollo desatendido? SÍ/NO/PARCIAL]

## Métricas
- Ambigüedades críticas: [N]
- Información faltante: [N items]
- Problemas de orquestación: [N]
- Proyectos listos para desarrollo: [N/5]

## Top 5 - Problemas Más Críticos
1. [Problema más importante]
2. [Segundo más importante]
[etc.]

## Recomendaciones Prioritarias
1. [Acción más urgente]
2. [Segunda acción]
[etc.]

## Tiempo Estimado para Resolver
- Para hacer desarrollo viable: [X horas/días]
- Para documentación ideal: [X días]
```

## Criterios de Evaluación

### ¿Cuándo una documentación es "suficiente" para desarrollo desatendido?

✅ **Suficiente cuando:**
- Todas las decisiones técnicas están tomadas
- Tecnologías y versiones especificadas
- Estructuras de datos definidas
- Flujos y algoritmos claros
- Configuración documentada

❌ **Insuficiente cuando:**
- Hay decisiones pendientes que una IA no puede tomar
- Faltan especificaciones técnicas
- Ambigüedades en requisitos
- Dependencias no claras

## Instrucciones Finales

1. **NO consultes análisis previos** - Tu análisis debe ser 100% independiente
2. **Sé exhaustivo** - Es mejor encontrar falsos positivos que dejar pasar problemas reales
3. **Prioriza por impacto** - Enfócate primero en lo que detendría el desarrollo
4. **Sé específico** - Indica exactamente qué archivo, qué línea, qué falta
5. **Propón soluciones** - No solo identifiques problemas, sugiere cómo resolverlos
6. **Guarda todo en tu carpeta** - Crea subcarpeta con tu nombre en ANALYSIS_DUDAS/

## Pregunta Clave a Responder

> "Si fueras una IA encargada de implementar este ecosistema desde cero, ¿podrías hacerlo con la documentación actual sin necesidad de hacer preguntas? Si no, ¿qué específicamente necesitarías que se aclare?"

---

**Nota:** Este análisis es fundamental para garantizar que el desarrollo pueda proceder sin interrupciones. Un problema no detectado ahora puede causar días de retraso después.