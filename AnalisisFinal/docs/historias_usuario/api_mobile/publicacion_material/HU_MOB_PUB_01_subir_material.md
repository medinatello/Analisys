# HU-MOB-PUB-01: Subir Material Educativo

## Historia de Usuario

**Como** docente
**Quiero** subir un archivo PDF con metadatos educativos
**Para que** mis estudiantes puedan acceder al material y se genere automáticamente un resumen y cuestionario

---

## Actor Principal
**Docente** con rol `teacher` en al menos una unidad académica

---

## Precondiciones

- Docente autenticado con JWT válido
- Docente tiene rol `teacher` o `owner` en al menos una unidad académica
- Archivo PDF ≤ 100 MB
- Materia existe en el catálogo de la escuela

---

## Flujo Principal

1. **Docente accede a "Nuevo Material"** en la app KMP
2. **Docente completa formulario**:
   - Título del material (requerido, 5-200 caracteres)
   - Descripción (opcional, máx 1000 caracteres)
   - Materia (selector desde catálogo)
   - Unidades académicas (selector múltiple)
   - Metadata adicional: nivel, keywords (opcional)
3. **Docente presiona "Crear Material"**
4. **App envía `POST /v1/materials`** con metadatos
5. **API valida permisos** del docente en cada unidad seleccionada
6. **API persiste** metadatos en PostgreSQL (`learning_material`, `material_unit_link`)
7. **API genera URL firmada de S3** para upload (válida 15 min)
8. **API responde 201 Created** con `material_id` y `upload_url`
9. **App muestra pantalla de upload** con barra de progreso
10. **Docente selecciona archivo PDF** desde su dispositivo
11. **App sube archivo directamente a S3** usando `upload_url`
12. **S3 acepta upload** y retorna 200 OK
13. **App notifica completitud** a API: `POST /v1/materials/:id/upload-complete`
14. **API registra versión** en `material_version` con `file_hash`
15. **API verifica deduplicación**: Si `file_hash` ya existe, reutiliza procesamiento
16. **API publica evento `material_uploaded`** a RabbitMQ
17. **API responde 202 Accepted**: "Material en procesamiento, te notificaremos cuando esté listo"
18. **App muestra confirmación**: "Material subido exitosamente. Recibirás una notificación cuando el resumen esté listo."
19. **Worker procesa PDF** (asíncrono, ver HU-WRK-RES-01)
20. **Worker genera resumen y quiz** con IA
21. **Worker notifica docente** via email/push: "Material 'X' listo para usar"

---

## Flujos Alternativos

### FA-1: Docente sin permisos en alguna unidad
**Cuando**: En paso 5, API detecta que docente no tiene rol `teacher` en alguna unidad seleccionada
**Entonces**:
- API responde 403 Forbidden
- Mensaje: "No tienes permisos de docente en las siguientes unidades: [lista]"
- App muestra error con lista de unidades problemáticas
- Docente puede editar selección de unidades y reintentar

### FA-2: Archivo PDF > 100 MB
**Cuando**: Docente selecciona archivo muy grande
**Entonces**:
- App valida tamaño ANTES de subir
- App muestra error: "El archivo supera el tamaño máximo permitido (100 MB). Por favor comprime el PDF o divide el contenido."
- Docente puede seleccionar otro archivo

### FA-3: URL firmada expiró (>15 min)
**Cuando**: Docente selecciona archivo más de 15 min después de crear material
**Entonces**:
- App intenta upload a S3
- S3 responde 403 Forbidden (URL expirada)
- App solicita nueva URL: `GET /v1/materials/:id/upload-url`
- API genera nueva URL firmada
- App reintenta upload con nueva URL

### FA-4: Archivo duplicado detectado (mismo hash)
**Cuando**: En paso 15, API detecta que `file_hash` ya existe en otra versión
**Entonces**:
- API NO publica evento a RabbitMQ (ahorra procesamiento)
- API copia referencias de `material_summary_link` y `assessment` del material original
- API responde 202 Accepted con mensaje: "Material listo (contenido reutilizado)"
- Docente recibe notificación inmediata (no hay espera de procesamiento)

### FA-5: Error en upload a S3
**Cuando**: En paso 11-12, ocurre error de red o S3 temporalmente inaccesible
**Entonces**:
- App detecta error (timeout o respuesta no-200)
- App muestra opción "Reintentar Upload"
- Docente puede:
  - Reintentar (si URL aún válida)
  - Cancelar y eliminar material borrador
  - Solicitar nueva URL (si expiró)

---

## Postcondiciones

### Éxito
- Material registrado en `learning_material` con `status = 'published'`
- Enlaces creados en `material_unit_link` para cada unidad
- Versión registrada en `material_version` con S3 key y hash
- PDF almacenado en S3: `s3://bucket/{school}/{unit}/{material}/source/{timestamp}_original.pdf`
- Evento `material_uploaded` publicado en RabbitMQ (si no es duplicado)
- Docente recibe confirmación visual en app

### Fallo
- Si falla antes de paso 8: Ningún registro en BD
- Si falla después de paso 8: Material queda en estado `draft`, docente puede reintentar upload
- Logs de error registrados para diagnóstico

---

## Criterios de Aceptación

1. **CA-1**: Docente puede crear material con metadatos completos en < 5 segundos
2. **CA-2**: Upload de PDF de 10 MB completa en < 30 segundos con conexión 4G
3. **CA-3**: Barra de progreso muestra % real de upload
4. **CA-4**: Si docente cierra app durante upload, progreso se pierde (no resume - Post-MVP)
5. **CA-5**: Deduplicación funciona: Subir mismo PDF 2 veces solo procesa 1 vez
6. **CA-6**: Docente recibe notificación push/email cuando material está listo (dentro de 5 min)
7. **CA-7**: Material aparece inmediatamente en "Mis Materiales" con estado "Procesando..."
8. **CA-8**: API valida que archivo es PDF válido (Content-Type + headers magic bytes)

---

## Request/Response Ejemplos

### Request: Crear Material
```http
POST /v1/materials
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "title": "Introducción a Pascal",
  "description": "Material base sobre historia y sintaxis del lenguaje Pascal para 5.º año",
  "subject_id": "uuid-subject-programming",
  "unit_ids": ["uuid-5a-programming", "uuid-5b-programming"],
  "metadata": {
    "level": "intermediate",
    "keywords": ["pascal", "compilador", "historia"],
    "estimated_reading_time_minutes": 45
  }
}
```

### Response: Material Creado
```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "status": "created",
  "material_id": "uuid-material-123",
  "upload_url": "https://s3.amazonaws.com/edugo-materials-prod/school-1/unit-5a/material-123/source/20250129_original.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=...",
  "upload_url_expires_at": "2025-01-29T11:15:00Z",
  "max_file_size_bytes": 104857600
}
```

### Request: Notificar Upload Completado
```http
POST /v1/materials/uuid-material-123/upload-complete
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "file_size_bytes": 2048576,
  "file_name": "pascal_intro.pdf"
}
```

### Response: Upload Completado
```http
HTTP/1.1 202 Accepted
Content-Type: application/json

{
  "status": "processing",
  "message": "Material en procesamiento. Te notificaremos cuando el resumen esté listo.",
  "estimated_time_minutes": 3,
  "material": {
    "id": "uuid-material-123",
    "title": "Introducción a Pascal",
    "status": "processing",
    "created_at": "2025-01-29T11:00:00Z"
  }
}
```

---

## Mockups UI (Referencias)

### Pantalla 1: Formulario de Creación
```
┌─────────────────────────────────┐
│ ← Nuevo Material                │
├─────────────────────────────────┤
│ Título *                        │
│ [Introducción a Pascal      ]   │
│                                 │
│ Descripción                     │
│ [Material base sobre...     ]   │
│ [                           ]   │
│                                 │
│ Materia *                       │
│ [▼ Programación             ]   │
│                                 │
│ Unidades Académicas *           │
│ ☑ 5.º A - Programación          │
│ ☑ 5.º B - Programación          │
│ ☐ Club de Robótica              │
│                                 │
│ Nivel                           │
│ ○ Básico ● Intermedio ○ Avanzado│
│                                 │
│         [Crear Material]        │
└─────────────────────────────────┘
```

### Pantalla 2: Upload de Archivo
```
┌─────────────────────────────────┐
│ ← Subir PDF                     │
├─────────────────────────────────┤
│ Material: Introducción a Pascal │
│                                 │
│ ┌───────────────────────────┐   │
│ │    📄 Seleccionar PDF     │   │
│ └───────────────────────────┘   │
│                                 │
│ O arrastrar archivo aquí        │
│                                 │
│ Archivo seleccionado:           │
│ pascal_intro.pdf (2.0 MB)       │
│                                 │
│ Subiendo...                     │
│ ████████████████░░░░░░ 75%      │
│                                 │
│ 1.5 MB / 2.0 MB                 │
└─────────────────────────────────┘
```

### Pantalla 3: Confirmación
```
┌─────────────────────────────────┐
│      ✓ Material Subido          │
├─────────────────────────────────┤
│                                 │
│   📄 Introducción a Pascal      │
│                                 │
│ El material se está procesando. │
│ Recibirás una notificación      │
│ cuando el resumen esté listo.   │
│                                 │
│ Tiempo estimado: 3 minutos      │
│                                 │
│         [Ver Material]          │
│         [Subir Otro]            │
│                                 │
└─────────────────────────────────┘
```

---

## Tareas Técnicas

### Frontend (KMP)
- [ ] Implementar formulario de creación con validaciones
- [ ] Integrar selector de archivos multiplataforma (Android/iOS/Desktop)
- [ ] Implementar upload con progreso real (no simulado)
- [ ] Manejar expiración de URL firmada
- [ ] Implementar retry logic para fallos de red
- [ ] Mostrar notificaciones push cuando material esté listo

### Backend (API Mobile - Go)
- [ ] Endpoint `POST /v1/materials` con validación de permisos
- [ ] Generación de URLs firmadas de S3 con expiración 15 min
- [ ] Endpoint `POST /v1/materials/:id/upload-complete`
- [ ] Cálculo de `file_hash` (SHA-256) del PDF
- [ ] Lógica de deduplicación por hash
- [ ] Publicación de evento `material_uploaded` a RabbitMQ
- [ ] Endpoint `GET /v1/materials/:id/upload-url` (regenerar URL)

### Worker
- [ ] Consumer de evento `material_uploaded`
- [ ] Descarga de PDF desde S3
- [ ] Extracción de texto (pdftotext + OCR)
- [ ] Llamada a NLP API (OpenAI GPT-4)
- [ ] Persistencia en MongoDB (`material_summary`, `material_assessment`)
- [ ] Actualización de PostgreSQL (`material_summary_link`, `assessment`)
- [ ] Notificación al docente (email/push)

---

## Métricas de Éxito

| Métrica | Objetivo | Medición |
|---------|----------|----------|
| Tiempo creación material | < 5 seg | Latencia API `POST /v1/materials` |
| Tiempo upload PDF 10MB | < 30 seg | Logs del cliente |
| Tasa de éxito upload | > 98% | `COUNT(upload_complete) / COUNT(material_created)` |
| Tiempo procesamiento IA | < 3 min | `material_event.duration_seconds` |
| Satisfacción docente | > 4.5/5 | Encuesta post-upload |

---

**Historia de Usuario**: HU-MOB-PUB-01
**Prioridad**: Alta (MVP Crítico)
**Estimación**: 8 puntos
**Sprint**: 1-2
**Dependencias**: Infraestructura S3, Worker NLP, RabbitMQ
