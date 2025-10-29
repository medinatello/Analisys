# Estructura de Almacenamiento S3 - EduGo

## Descripción
Organización de archivos binarios (PDFs, videos, assets) en S3/MinIO con prefijos jerárquicos para control de acceso y eficiencia.

## Buckets

### Producción

```
Bucket: edugo-materials-prod
Region: us-east-1 (o región según costo/latencia)
Versionado: Habilitado
Encriptación: SSE-S3 (server-side encryption)
```

###

 Desarrollo/Staging

```
Bucket: edugo-materials-dev
Bucket: edugo-materials-staging
```

---

## Estructura de Prefijos

### Jerarquía General

```
s3://edugo-materials-{env}/
└── {school_id}/
    └── {unit_id}/
        └── {material_id}/
            ├── source/
            │   └── {timestamp}_original.{ext}
            ├── processed/
            │   ├── {material_version_id}.pdf
            │   ├── {material_version_id}.json
            │   └── {material_version_id}_optimized.pdf
            └── assets/
                ├── cover_{material_version_id}.png
                ├── thumb_{material_version_id}.jpg
                └── preview_{material_version_id}.png
```

### Ejemplo Completo

```
s3://edugo-materials-prod/
└── school-abc123/
    └── unit-5a-prog/
        └── material-pascal-intro/
            ├── source/
            │   └── 20250115_120000_original.pdf
            ├── processed/
            │   ├── v1_20250115_123000.pdf
            │   ├── v1_20250115_123000.json
            │   └── v1_20250115_123000_optimized.pdf
            └── assets/
                ├── cover_v1.png
                ├── thumb_v1.jpg
                └── preview_v1.png
```

---

## Descripción de Carpetas

### `source/`

**Propósito**: Almacenar archivos originales sin modificar (backup)

**Contenido**:
- PDFs originales subidos por docentes
- Videos sin procesar
- Audios originales

**Naming Convention**:
- Formato: `{timestamp}_{type}.{ext}`
- Ejemplo: `20250115_120000_original.pdf`

**Políticas**:
- **No modificar**: Archivos inmutables
- **Retención**: 1 año en Standard, luego Glacier
- **Acceso**: Restringido a workers (no URLs públicas)

---

### `processed/`

**Propósito**: Archivos procesados listos para consumo

**Contenido**:
- PDFs optimizados (comprimidos)
- Transcripciones de videos/audios
- Metadata extraída (JSON)

**Naming Convention**:
- Formato: `{material_version_id}[_type].{ext}`
- Ejemplos:
  - `v1_20250115_123000.pdf` (PDF procesado)
  - `v1_20250115_123000.json` (metadata extraída)
  - `v1_20250115_123000_optimized.pdf` (PDF comprimido)

**Políticas**:
- **Versionado**: Mantener histórico
- **Acceso**: URLs firmadas (15 min expiración)
- **CDN**: CloudFront para descarga rápida

---

### `assets/`

**Propósito**: Assets derivados (portadas, thumbnails, previews)

**Contenido**:
- Portadas generadas (primera página del PDF)
- Thumbnails (versión pequeña)
- Previews (versión de baja resolución)

**Naming Convention**:
- Formato: `{type}_{material_version_id}.{ext}`
- Ejemplos:
  - `cover_v1.png` (800x600px)
  - `thumb_v1.jpg` (200x150px)
  - `preview_v1.png` (primera página baja res)

**Políticas**:
- **Caché**: Agresivo (CloudFront con TTL 7 días)
- **Acceso**: Público (para previews en listas)

---

## Metadatos en Headers S3

Cada objeto debe incluir metadatos personalizados en headers:

```bash
# Ejemplo de upload con metadata
aws s3 cp original.pdf s3://edugo-materials-prod/school-1/unit-5/material-123/source/20250115_original.pdf \
  --metadata \
    "x-amz-meta-school-id=school-1" \
    "x-amz-meta-unit-id=unit-5" \
    "x-amz-meta-material-id=material-123" \
    "x-amz-meta-author-id=user-456" \
    "x-amz-meta-uploaded-at=2025-01-15T12:00:00Z" \
    "x-amz-meta-content-type=educational-material" \
    "x-amz-meta-subject=programming"
```

**Metadata estándar**:
- `school-id`: ID de la escuela
- `unit-id`: ID de la unidad académica
- `material-id`: ID del material
- `author-id`: ID del docente
- `uploaded-at`: Timestamp de subida
- `content-type`: Tipo de contenido educativo
- `subject`: Materia

---

## URLs Firmadas (Presigned URLs)

### Generación desde API

```go
// Generar URL firmada para descarga (15 min)
presignedURL, err := s3Client.PresignGetObject(ctx, &s3.GetObjectInput{
    Bucket: aws.String(bucket),
    Key:    aws.String(key),
}, func(opts *s3.PresignOptions) {
    opts.Expires = time.Duration(15 * time.Minute)
})

// Generar URL firmada para upload (15 min)
uploadURL, err := s3Client.PresignPutObject(ctx, &s3.PutObjectInput{
    Bucket:      aws.String(bucket),
    Key:         aws.String(key),
    ContentType: aws.String("application/pdf"),
}, func(opts *s3.PresignOptions) {
    opts.Expires = time.Duration(15 * time.Minute)
})
```

### Seguridad

**Limitaciones**:
- Expiración máxima: 15 minutos
- Una sola operación (GET o PUT)
- No reutilizable tras expiración

**Prevención de abuso**:
- Rate limiting en API para generación de URLs
- Logs de acceso para auditoría
- Alertas si mismo archivo descargado > 100 veces/hora

---

## Políticas IAM

### Worker (Procesamiento)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::edugo-materials-prod/*"
      ]
    }
  ]
}
```

### API (Generación de URLs firmadas)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::edugo-materials-prod/*"
      ],
      "Condition": {
        "StringLike": {
          "s3:x-amz-metadata-directive": "COPY"
        }
      }
    }
  ]
}
```

### Usuario Final (Solo via URLs firmadas)

- **Sin credenciales IAM**
- **Acceso temporal** mediante URLs firmadas
- **Logs completos** de accesos

---

## Ciclo de Vida de Objetos

### Reglas de Transición

```xml
<LifecycleConfiguration>
  <Rule>
    <ID>MoveOldVersionsToGlacier</ID>
    <Filter>
      <Prefix>source/</Prefix>
    </Filter>
    <Status>Enabled</Status>
    <Transition>
      <Days>365</Days>
      <StorageClass>GLACIER</StorageClass>
    </Transition>
  </Rule>

  <Rule>
    <ID>DeleteOldProcessedFiles</ID>
    <Filter>
      <Prefix>processed/</Prefix>
    </Filter>
    <Status>Enabled</Status>
    <NoncurrentVersionExpiration>
      <NoncurrentDays>90</NoncurrentDays>
    </NoncurrentVersionExpiration>
  </Rule>

  <Rule>
    <ID>DeleteOldAssets</ID>
    <Filter>
      <Prefix>assets/</Prefix>
    </Filter>
    <Status>Enabled</Status>
    <NoncurrentVersionExpiration>
      <NoncurrentDays>30</NoncurrentDays>
    </NoncurrentVersionExpiration>
  </Rule>
</LifecycleConfiguration>
```

**Resumen**:
- `source/`: 1 año Standard → Glacier (archival permanente)
- `processed/`: Versiones antiguas eliminadas tras 90 días
- `assets/`: Versiones antiguas eliminadas tras 30 días

---

## Deduplicación por Hash

### Proceso

1. **Antes de subir**: Calcular SHA-256 del archivo
2. **Consultar PostgreSQL**: Buscar `material_version.file_hash`
3. **Si existe**:
   - No subir a S3 (ahorro de storage y bandwidth)
   - Copiar referencias de `material_summary_link` y `assessment`
   - Ahorrar costo de procesamiento NLP
4. **Si no existe**:
   - Subir a S3 normalmente
   - Procesar con worker

### Ejemplo

```sql
-- Verificar si hash ya existe
SELECT id, material_id, s3_key
FROM material_version
WHERE file_hash = 'sha256-abc123...'
  AND material_id != $current_material_id
LIMIT 1;

-- Si existe, reutilizar
COPY s3://bucket/old-path s3://bucket/new-path
UPDATE material_version SET material_id = $new WHERE file_hash = 'sha256...';
```

---

## CDN (CloudFront)

### Configuración

**Origen**: `edugo-materials-prod.s3.amazonaws.com`

**Behaviors**:
- `/*/assets/*`: Cache agresivo (TTL 7 días)
- `/*/processed/*`: Cache moderado (TTL 1 hora)
- `/*/source/*`: Sin cache (acceso directo a S3)

**Invalidación**:
```bash
# Invalidar assets de un material específico
aws cloudfront create-invalidation \
  --distribution-id EDFDVBD6EXAMPLE \
  --paths "/school-1/unit-5/material-123/assets/*"
```

---

## Costos Estimados

### Almacenamiento (S3 Standard)

| Tier | Costo por GB/mes | Volumen Estimado | Costo Mensual |
|------|------------------|------------------|---------------|
| Primeros 50 TB | $0.023 | 10 TB | $230 |

### Transferencia (CloudFront)

| Región | Costo por GB | Transferencia Estimada | Costo Mensual |
|--------|--------------|------------------------|---------------|
| América del Norte | $0.085 | 50 TB | $4,250 |

### Requests (S3 GET)

| Operación | Costo por 1,000 | Requests Estimados | Costo Mensual |
|-----------|-----------------|---------------------|---------------|
| GET | $0.0004 | 10M | $4 |

**Costo Total Estimado**: ~$4,500/mes para 10,000 usuarios activos

---

## Migración a MinIO (Alternativa Local)

### Ventajas de MinIO

- **Costos predecibles**: Sin cargos por transferencia
- **Control total**: Infraestructura on-premise
- **API compatible S3**: Mismo código

### Desventajas

- **Gestión de hardware**: Requiere servidores propios
- **Escalabilidad manual**: Añadir nodos manualmente
- **Backups propios**: Configuración de réplicas

### Cuándo Migrar

- Si transferencia mensual > 100 TB
- Si costos S3 > $10,000/mes
- Si regulaciones requieren datos on-premise

---

**Documento**: Estructura de Almacenamiento S3 de EduGo
**Versión**: 1.0
**Fecha**: 2025-01-29
**Autor**: Equipo EduGo
