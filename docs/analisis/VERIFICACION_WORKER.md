# Verificación del Worker - edugo-worker

**Fecha:** 11 de Noviembre, 2025  
**Objetivo:** Verificar estado de implementación del procesamiento asíncrono con IA  
**Responsable:** Equipo EduGo

---

## 🎯 PROPÓSITO DE ESTE DOCUMENTO

El `edugo-worker` es el componente **crítico** del sistema que:
1. Procesa PDFs educativos
2. Extrae texto
3. Genera resúmenes con OpenAI
4. Genera evaluaciones (quizzes) con OpenAI
5. Guarda resultados en MongoDB

**Estado Actual:** ⚠️ **DESCONOCIDO** - Requiere inspección de código

Este documento proporciona un **checklist exhaustivo** para verificar cada componente del worker.

---

## 📋 CHECKLIST DE VERIFICACIÓN

### Parte 1: Infraestructura y Configuración

#### 1.1 Estructura del Proyecto

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 1.1.1 | Proyecto existe en `repos-separados/edugo-worker/` | ☐ Sí / ☐ No | | |
| 1.1.2 | Tiene estructura de carpetas: `internal/domain`, `internal/application`, `internal/infrastructure` | ☐ Sí / ☐ No | | |
| 1.1.3 | Tiene `go.mod` con dependencias actualizadas | ☐ Sí / ☐ No | | Versión Go: ___ |
| 1.1.4 | Tiene `Dockerfile` funcional | ☐ Sí / ☐ No | | |
| 1.1.5 | Tiene `Makefile` con comandos útiles | ☐ Sí / ☐ No | | |
| 1.1.6 | Tiene `.env.example` o configuración de ejemplo | ☐ Sí / ☐ No | | |

**Comando de verificación:**
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-worker
ls -la internal/
cat go.mod | grep -E "go 1\.|github.com|openai"
```

---

#### 1.2 Dependencias Clave

| # | Dependencia | Propósito | Estado | Versión |
|---|-------------|-----------|--------|---------|
| 1.2.1 | `github.com/streadway/amqp` o `github.com/rabbitmq/amqp091-go` | Cliente RabbitMQ | ☐ Existe / ☐ No existe | |
| 1.2.2 | `github.com/sashabaranov/go-openai` o similar | Cliente OpenAI | ☐ Existe / ☐ No existe | |
| 1.2.3 | `go.mongodb.org/mongo-driver` | Cliente MongoDB | ☐ Existe / ☐ No existe | |
| 1.2.4 | Librería para procesar PDFs (ej: `github.com/ledongthuc/pdf` o `pdftotext`) | Extracción de texto | ☐ Existe / ☐ No existe | |
| 1.2.5 | `github.com/aws/aws-sdk-go` | Cliente S3 para descargar PDFs | ☐ Existe / ☐ No existe | |
| 1.2.6 | `github.com/spf13/viper` | Gestión de configuración | ☐ Existe / ☐ No existe | |

**Comando de verificación:**
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-worker
cat go.mod | grep -E "rabbitmq|amqp|openai|mongo|pdf|aws-sdk"
```

---

### Parte 2: Conexión a RabbitMQ

#### 2.1 Configuración de Conexión

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 2.1.1 | Existe archivo de configuración con credenciales RabbitMQ | ☐ Sí / ☐ No | | Archivo: ___ |
| 2.1.2 | Variables de entorno definidas: `RABBITMQ_HOST`, `RABBITMQ_PORT`, `RABBITMQ_USER`, `RABBITMQ_PASS` | ☐ Sí / ☐ No | | |
| 2.1.3 | Código de conexión a RabbitMQ existe | ☐ Sí / ☐ No | | Archivo: ___ |
| 2.1.4 | Maneja reconexión automática en caso de fallo | ☐ Sí / ☐ No | | |

**Archivos a revisar:**
```bash
grep -r "amqp://" internal/
grep -r "RabbitMQ\|rabbitmq" internal/ config/
find . -name "*rabbit*" -o -name "*amqp*" -o -name "*messaging*"
```

---

#### 2.2 Consumo de Eventos

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 2.2.1 | Consumer escucha la queue `edugo.material.uploaded` | ☐ Sí / ☐ No | | Queue name: ___ |
| 2.2.2 | Consumer escucha la queue `edugo.material.reprocess` | ☐ Sí / ☐ No | | Queue name: ___ |
| 2.2.3 | Usa prefetch count para limitar concurrencia | ☐ Sí / ☐ No | | Prefetch: ___ |
| 2.2.4 | Hace ACK de mensajes correctamente | ☐ Sí / ☐ No | | |
| 2.2.5 | Usa NACK y requeue en caso de error | ☐ Sí / ☐ No | | |
| 2.2.6 | Implementa Dead Letter Queue (DLQ) para mensajes fallidos | ☐ Sí / ☐ No | | DLQ name: ___ |

**Archivos a revisar:**
```bash
grep -r "Consume\|Consumer\|channel.Qos" internal/
grep -r "edugo.material" internal/ config/
grep -r "Ack\|Nack\|Reject" internal/
```

---

### Parte 3: Procesamiento de PDFs

#### 3.1 Descarga de Archivos

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 3.1.1 | Descarga PDF desde S3 usando `s3_key` del mensaje | ☐ Sí / ☐ No | | |
| 3.1.2 | Valida que el archivo descargado es un PDF válido | ☐ Sí / ☐ No | | |
| 3.1.3 | Maneja errores de descarga (archivo no encontrado, timeout) | ☐ Sí / ☐ No | | |
| 3.1.4 | Limita tamaño máximo de archivo | ☐ Sí / ☐ No | | Max size: ___ MB |

**Archivos a revisar:**
```bash
grep -r "s3\|S3\|GetObject\|DownloadFile" internal/
grep -r "pdf\|PDF" internal/
```

---

#### 3.2 Extracción de Texto

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 3.2.1 | Extrae texto del PDF | ☐ Sí / ☐ No | | Librería usada: ___ |
| 3.2.2 | Limpia texto extraído (elimina caracteres especiales, normaliza espacios) | ☐ Sí / ☐ No | | |
| 3.2.3 | Maneja PDFs escaneados (OCR) | ☐ Sí / ☐ No / ☐ N/A | | |
| 3.2.4 | Valida que el texto extraído no está vacío | ☐ Sí / ☐ No | | |
| 3.2.5 | Limita longitud de texto (para evitar exceder límites de OpenAI) | ☐ Sí / ☐ No | | Max tokens: ___ |

**Archivos a revisar:**
```bash
grep -r "ExtractText\|ParsePDF\|ReadPDF" internal/
grep -r "Clean\|Normalize\|Sanitize" internal/
```

---

### Parte 4: Integración con OpenAI

#### 4.1 Configuración de Cliente OpenAI

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 4.1.1 | API Key de OpenAI configurada | ☐ Sí / ☐ No | | Env var: `OPENAI_API_KEY` |
| 4.1.2 | Modelo configurado (ej: `gpt-4`, `gpt-3.5-turbo`) | ☐ Sí / ☐ No | | Modelo: ___ |
| 4.1.3 | Timeout configurado para llamadas a API | ☐ Sí / ☐ No | | Timeout: ___ segundos |
| 4.1.4 | Rate limiting implementado | ☐ Sí / ☐ No | | Límite: ___ req/min |

**Archivos a revisar:**
```bash
grep -r "OPENAI\|openai\|OpenAI" internal/ config/
grep -r "gpt-4\|gpt-3" internal/
```

---

#### 4.2 Generación de Resúmenes

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 4.2.1 | Prompt para generar resumen existe y está bien definido | ☐ Sí / ☐ No | | Archivo: ___ |
| 4.2.2 | Resumen incluye secciones (título, contenido, dificultad) | ☐ Sí / ☐ No | | |
| 4.2.3 | Resumen incluye glosario de términos | ☐ Sí / ☐ No | | |
| 4.2.4 | Resumen incluye preguntas de reflexión | ☐ Sí / ☐ No | | |
| 4.2.5 | Valida respuesta de OpenAI antes de procesarla | ☐ Sí / ☐ No | | |
| 4.2.6 | Reintentos en caso de error (con backoff exponencial) | ☐ Sí / ☐ No | | Max reintentos: ___ |

**Archivos a revisar:**
```bash
grep -r "summary\|Summary\|Resumen" internal/
grep -r "GenerateSummary\|CreateSummary" internal/
grep -r "retry\|Retry\|backoff" internal/
```

**Prompt esperado (ejemplo):**
```
Genera un resumen educativo conciso de este material.
Identifica los conceptos clave y objetivos de aprendizaje.
Estructura: 
- Secciones por dificultad (básico, medio, avanzado)
- Glosario de términos técnicos
- Preguntas de reflexión

Texto: {texto_extraido}
```

---

#### 4.3 Generación de Evaluaciones (Quizzes)

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 4.3.1 | Prompt para generar quiz existe y está bien definido | ☐ Sí / ☐ No | | Archivo: ___ |
| 4.3.2 | Quiz incluye preguntas de opción múltiple | ☐ Sí / ☐ No | | Cantidad: ___ |
| 4.3.3 | Cada pregunta tiene 4 opciones (A, B, C, D) | ☐ Sí / ☐ No | | |
| 4.3.4 | Cada pregunta tiene respuesta correcta marcada | ☐ Sí / ☐ No | | |
| 4.3.5 | Cada pregunta tiene feedback (correcto e incorrecto) | ☐ Sí / ☐ No | | |
| 4.3.6 | Preguntas tienen nivel de dificultad asignado | ☐ Sí / ☐ No | | |
| 4.3.7 | Valida estructura JSON de respuesta de OpenAI | ☐ Sí / ☐ No | | |

**Archivos a revisar:**
```bash
grep -r "assessment\|Assessment\|quiz\|Quiz" internal/
grep -r "GenerateQuiz\|CreateAssessment\|GenerateQuestions" internal/
```

**Prompt esperado (ejemplo):**
```
Basándote en este resumen, genera 5 preguntas de opción múltiple
para evaluar la comprensión del estudiante.

Formato JSON:
{
  "questions": [
    {
      "id": "q1",
      "text": "¿Pregunta?",
      "options": [
        {"id": "a", "text": "Opción A"},
        {"id": "b", "text": "Opción B"},
        {"id": "c", "text": "Opción C"},
        {"id": "d", "text": "Opción D"}
      ],
      "correct_answer": "b",
      "difficulty": "medium",
      "feedback": {
        "correct": "¡Correcto! Explicación...",
        "incorrect": "Incorrecto. Revisa..."
      }
    }
  ]
}

Resumen: {resumen}
```

---

### Parte 5: Almacenamiento en MongoDB

#### 5.1 Conexión a MongoDB

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 5.1.1 | Conexión a MongoDB configurada | ☐ Sí / ☐ No | | Connection string: ___ |
| 5.1.2 | Base de datos correcta: `edugo` | ☐ Sí / ☐ No | | DB name: ___ |
| 5.1.3 | Maneja reconexión automática | ☐ Sí / ☐ No | | |
| 5.1.4 | Pool de conexiones configurado | ☐ Sí / ☐ No | | Max pool size: ___ |

**Archivos a revisar:**
```bash
grep -r "mongodb\|MongoDB\|mongo.Connect" internal/
grep -r "MONGO_URI\|MONGODB_URL" internal/ config/
```

---

#### 5.2 Guardado de Resúmenes

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 5.2.1 | Guarda en colección `material_summary` | ☐ Sí / ☐ No | | Colección: ___ |
| 5.2.2 | Estructura del documento coincide con diseño | ☐ Sí / ☐ No | | Ver diseño en `02_colecciones_mongodb.md` |
| 5.2.3 | Incluye `material_id` (UUID de PostgreSQL) | ☐ Sí / ☐ No | | |
| 5.2.4 | Incluye `version` incremental | ☐ Sí / ☐ No | | |
| 5.2.5 | Incluye `sections`, `glossary`, `reflection_questions` | ☐ Sí / ☐ No | | |
| 5.2.6 | Incluye `processing_metadata` (modelo, tokens, tiempo) | ☐ Sí / ☐ No | | |
| 5.2.7 | Incluye timestamps: `created_at`, `updated_at` | ☐ Sí / ☐ No | | |

**Comando de verificación:**
```bash
grep -r "material_summary\|InsertOne\|InsertMany" internal/
```

**Estructura esperada:**
```json
{
  "_id": ObjectId("..."),
  "material_id": "uuid-from-postgresql",
  "version": 1,
  "status": "completed",
  "sections": [...],
  "glossary": [...],
  "reflection_questions": [...],
  "processing_metadata": {
    "nlp_provider": "openai",
    "model": "gpt-4",
    "tokens_used": 3500,
    "processing_time_seconds": 45,
    "language": "es"
  },
  "created_at": ISODate("..."),
  "updated_at": ISODate("...")
}
```

---

#### 5.3 Guardado de Evaluaciones

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 5.3.1 | Guarda en colección `material_assessment` | ☐ Sí / ☐ No | | Colección: ___ |
| 5.3.2 | Estructura del documento coincide con diseño | ☐ Sí / ☐ No | | Ver diseño en `02_colecciones_mongodb.md` |
| 5.3.3 | Incluye `material_id` (UUID de PostgreSQL) | ☐ Sí / ☐ No | | |
| 5.3.4 | Incluye `questions` array con estructura completa | ☐ Sí / ☐ No | | |
| 5.3.5 | Cada pregunta tiene `id`, `text`, `options`, `correct_answer`, `feedback` | ☐ Sí / ☐ No | | |
| 5.3.6 | Incluye `total_questions`, `total_points`, `passing_score` | ☐ Sí / ☐ No | | |

**Comando de verificación:**
```bash
grep -r "material_assessment\|assessment.*Insert" internal/
```

---

#### 5.4 Guardado de Logs de Procesamiento

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 5.4.1 | Guarda eventos en colección `material_event` | ☐ Sí / ☐ No | | Colección: ___ |
| 5.4.2 | Registra evento `processing_started` | ☐ Sí / ☐ No | | |
| 5.4.3 | Registra evento `processing_completed` o `processing_failed` | ☐ Sí / ☐ No | | |
| 5.4.4 | Incluye `duration_seconds`, `error_message`, `retry_count` | ☐ Sí / ☐ No | | |
| 5.4.5 | Incluye metadata: tokens usados, costo estimado | ☐ Sí / ☐ No | | |

**Comando de verificación:**
```bash
grep -r "material_event\|event.*Insert" internal/
```

---

### Parte 6: Actualización de PostgreSQL

#### 6.1 Actualización de Estados

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 6.1.1 | Actualiza `materials.processing_status` a `processing` al iniciar | ☐ Sí / ☐ No | | |
| 6.1.2 | Actualiza `materials.processing_status` a `completed` al finalizar exitosamente | ☐ Sí / ☐ No | | |
| 6.1.3 | Actualiza `materials.processing_status` a `failed` en caso de error | ☐ Sí / ☐ No | | |
| 6.1.4 | Crea registro en `material_summary_link` con `mongo_document_id` | ☐ Sí / ☐ No | | Tabla existe? ___ |
| 6.1.5 | Crea registro en `assessment` con metadata del quiz | ☐ Sí / ☐ No | | Tabla existe? ___ |

**Comando de verificación:**
```bash
grep -r "UPDATE materials\|processing_status" internal/
grep -r "material_summary_link\|assessment.*INSERT" internal/
```

---

### Parte 7: Manejo de Errores

#### 7.1 Estrategias de Reintentos

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 7.1.1 | Reintentos con backoff exponencial para OpenAI | ☐ Sí / ☐ No | | Max reintentos: ___ |
| 7.1.2 | Reintentos con backoff exponencial para MongoDB | ☐ Sí / ☐ No | | Max reintentos: ___ |
| 7.1.3 | Reintentos con backoff exponencial para PostgreSQL | ☐ Sí / ☐ No | | Max reintentos: ___ |
| 7.1.4 | Mensaje vuelve a queue en caso de error transitorio | ☐ Sí / ☐ No | | |
| 7.1.5 | Mensaje va a DLQ después de X reintentos fallidos | ☐ Sí / ☐ No | | X = ___ |

---

#### 7.2 Logging

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 7.2.1 | Logs estructurados (JSON) | ☐ Sí / ☐ No | | Librería: ___ |
| 7.2.2 | Log de inicio de procesamiento | ☐ Sí / ☐ No | | |
| 7.2.3 | Log de cada etapa (descarga, extracción, IA, guardado) | ☐ Sí / ☐ No | | |
| 7.2.4 | Log de errores con stack trace | ☐ Sí / ☐ No | | |
| 7.2.5 | Log de completado con métricas (tiempo, tokens, costo) | ☐ Sí / ☐ No | | |
| 7.2.6 | Integración con shared/logger | ☐ Sí / ☐ No | | |

**Comando de verificación:**
```bash
grep -r "log\.\|logger\.\|Logger" internal/
```

---

### Parte 8: Tests

#### 8.1 Tests Unitarios

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 8.1.1 | Tests de extracción de texto de PDF | ☐ Sí / ☐ No | | Coverage: ___% |
| 8.1.2 | Tests de limpieza de texto | ☐ Sí / ☐ No | | Coverage: ___% |
| 8.1.3 | Tests de parsing de respuestas de OpenAI | ☐ Sí / ☐ No | | Coverage: ___% |
| 8.1.4 | Tests de transformación a schemas de MongoDB | ☐ Sí / ☐ No | | Coverage: ___% |

**Comando de verificación:**
```bash
find . -name "*_test.go" | wc -l
go test ./... -cover
```

---

#### 8.2 Tests de Integración

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 8.2.1 | Test de consumo de RabbitMQ con testcontainers | ☐ Sí / ☐ No | | |
| 8.2.2 | Test de guardado en MongoDB con testcontainers | ☐ Sí / ☐ No | | |
| 8.2.3 | Test de actualización de PostgreSQL con testcontainers | ☐ Sí / ☐ No | | |
| 8.2.4 | Test end-to-end completo (mock de OpenAI) | ☐ Sí / ☐ No | | |

---

### Parte 9: CI/CD

#### 9.1 GitHub Actions

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 9.1.1 | Workflow de CI existe (`.github/workflows/`) | ☐ Sí / ☐ No | | Archivo: ___ |
| 9.1.2 | Pipeline ejecuta tests | ☐ Sí / ☐ No | | |
| 9.1.3 | Pipeline verifica linting (golangci-lint) | ☐ Sí / ☐ No | | |
| 9.1.4 | Pipeline verifica coverage mínimo | ☐ Sí / ☐ No | | Min: ___% |
| 9.1.5 | Pipeline construye Docker image | ☐ Sí / ☐ No | | |

---

### Parte 10: Documentación

#### 10.1 Documentación Interna

| # | Item | Verificar | Estado | Notas |
|---|------|-----------|--------|-------|
| 10.1.1 | README.md con instrucciones de setup | ☐ Sí / ☐ No | | |
| 10.1.2 | Documentación de variables de entorno | ☐ Sí / ☐ No | | |
| 10.1.3 | Documentación de prompts de OpenAI | ☐ Sí / ☐ No | | |
| 10.1.4 | Diagramas de flujo del worker | ☐ Sí / ☐ No | | |

---

## 📊 RESUMEN DE VERIFICACIÓN

### Template de Reporte

```
FECHA DE VERIFICACIÓN: [___________]
VERIFICADO POR: [___________]

PUNTUACIÓN GENERAL:
- Infraestructura: ___/6 puntos
- RabbitMQ: ___/12 puntos
- Procesamiento PDF: ___/9 puntos
- OpenAI: ___/13 puntos
- MongoDB: ___/18 puntos
- PostgreSQL: ___/5 puntos
- Errores: ___/11 puntos
- Tests: ___/8 puntos
- CI/CD: ___/5 puntos
- Documentación: ___/4 puntos

TOTAL: ___/91 puntos (___%)

ESTADO GENERAL:
☐ 90-100%: Worker completamente funcional ✅
☐ 70-89%: Worker funcional con mejoras pendientes 🟡
☐ 50-69%: Worker parcialmente funcional ⚠️
☐ 0-49%: Worker requiere implementación significativa ❌

HALLAZGOS CRÍTICOS:
1. [Describir...]
2. [Describir...]
3. [Describir...]

RECOMENDACIONES INMEDIATAS:
1. [Acción...]
2. [Acción...]
3. [Acción...]

ESTIMACIÓN DE ESFUERZO PARA COMPLETAR:
☐ 1 semana (S)
☐ 2-3 semanas (M)
☐ 4-6 semanas (L)
☐ 6+ semanas (XL)
```

---

## 🚀 PRÓXIMOS PASOS SEGÚN RESULTADO

### Si Worker está al 90-100% ✅
1. Documentar en `GAP_ANALYSIS.md` que worker está completo
2. Actualizar roadmap (quitar Sprint Worker-2)
3. Enfocarse en api-administracion y api-mobile

### Si Worker está al 70-89% 🟡
1. Identificar funcionalidades faltantes específicas
2. Crear issues en GitHub para cada gap
3. Estimar Sprint Worker-2 (1-2 semanas)

### Si Worker está al 50-69% ⚠️
1. Revisar si conviene refactorizar vs continuar
2. Comparar con arquitectura de api-mobile (más madura)
3. Estimar Sprint Worker-2 (2-4 semanas)

### Si Worker está al 0-49% ❌
1. Considerar reescribir usando api-mobile como template
2. Estimar Sprint Worker-1 + Worker-2 (4-6 semanas)
3. Priorizar según criticidad vs jerarquía académica

---

## 📝 COMANDOS ÚTILES PARA VERIFICACIÓN

### Clonar y Explorar Worker
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-worker

# Ver estructura
find . -type f -name "*.go" | head -20

# Ver dependencias
cat go.mod

# Buscar palabras clave
grep -r "RabbitMQ\|OpenAI\|MongoDB\|ProcessPDF" internal/

# Ver configuración
cat .env.example
find . -name "*.yaml" -o -name "*.yml"
```

### Ejecutar Tests
```bash
go test ./... -v
go test ./... -cover
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out
```

### Ejecutar Localmente
```bash
make build
make run

# O con Docker
docker build -t edugo-worker .
docker run --env-file .env edugo-worker
```

---

**Última actualización:** 11 de Noviembre, 2025  
**Próxima revisión:** Después de completar verificación

---

**Generado con** 🤖 Claude Code
