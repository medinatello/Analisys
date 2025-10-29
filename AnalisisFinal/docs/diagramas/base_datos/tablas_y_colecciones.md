# Lista Maestra de Tablas y Colecciones - EduGo

## Descripción
Referencia completa de todas las tablas PostgreSQL, colecciones MongoDB y buckets S3 del sistema EduGo con sus propósitos y relaciones principales.

---

## PostgreSQL - Tablas (17 totales)

### 1. Usuarios y Perfiles (6 tablas)

| # | Tabla | Propósito | Registros Estimados | Relaciones Clave |
|---|-------|-----------|---------------------|------------------|
| 1 | `app_user` | Datos comunes de todos los usuarios | 1,000 - 100,000 | → teacher_profile, student_profile, guardian_profile |
| 2 | `teacher_profile` | Datos específicos de docentes | 100 - 5,000 | ← app_user |
| 3 | `student_profile` | Datos específicos de estudiantes | 800 - 80,000 | ← app_user |
| 4 | `guardian_profile` | Datos específicos de tutores | 100 - 20,000 | ← app_user |
| 5 | `guardian_student_relation` | Vínculo tutor ↔ estudiante (N:M) | 200 - 40,000 | ← app_user (guardian, student) |
| 6 | `school` | Organizaciones educativas | 10 - 500 | → academic_unit, subject |

### 2. Jerarquía Académica (2 tablas)

| # | Tabla | Propósito | Registros Estimados | Relaciones Clave |
|---|-------|-----------|---------------------|------------------|
| 7 | `academic_unit` | Estructura jerárquica (años, secciones, clubes) | 100 - 5,000 | ← school, → academic_unit (recursivo) |
| 8 | `unit_membership` | Asignación usuario ↔ unidad con rol | 2,000 - 200,000 | ← academic_unit, app_user |

### 3. Materiales Educativos (5 tablas)

| # | Tabla | Propósito | Registros Estimados | Relaciones Clave |
|---|-------|-----------|---------------------|------------------|
| 9 | `subject` | Catálogo de materias por escuela | 50 - 1,000 | ← school, → learning_material |
| 10 | `learning_material` | Registro de materiales educativos | 500 - 50,000 | ← subject, app_user (author) |
| 11 | `material_version` | Historial de versiones de materiales | 1,000 - 100,000 | ← learning_material |
| 12 | `material_unit_link` | Asignación material ↔ unidad (N:M) | 2,000 - 200,000 | ← learning_material, academic_unit |
| 13 | `reading_log` | Progreso de lectura por estudiante | 5,000 - 500,000 | ← learning_material, app_user (student) |

### 4. Resúmenes y Evaluaciones (4 tablas)

| # | Tabla | Propósito | Registros Estimados | Relaciones Clave |
|---|-------|-----------|---------------------|------------------|
| 14 | `material_summary_link` | Enlace a resumen en MongoDB | 500 - 50,000 | ← learning_material |
| 15 | `assessment` | Metadatos de evaluaciones (quiz) | 500 - 50,000 | ← learning_material |
| 16 | `assessment_attempt` | Intentos de evaluación por estudiante | 5,000 - 500,000 | ← assessment, app_user (student) |
| 17 | `assessment_attempt_answer` | Respuestas individuales por intento | 25,000 - 2,500,000 | ← assessment_attempt |

### 5. Auditoría (1 tabla - Post-MVP)

| # | Tabla | Propósito | Registros Estimados | Relaciones Clave |
|---|-------|-----------|---------------------|------------------|
| 18 | `audit_log` | Registro de operaciones administrativas | 1,000 - 100,000 | ← app_user (admin) |

---

## MongoDB - Colecciones (5 totales: 3 MVP + 2 Post-MVP)

### MVP (3 colecciones)

| # | Colección | Propósito | Documentos Estimados | Índices Clave |
|---|-----------|-----------|----------------------|---------------|
| 1 | `material_summary` | Resúmenes generados por IA | 500 - 50,000 | material_id (unique), status |
| 2 | `material_assessment` | Bancos de preguntas y evaluaciones | 500 - 50,000 | material_id (unique), questions.id |
| 3 | `material_event` | Logs de procesamiento y métricas | 5,000 - 500,000 | material_id + created_at, event_type |

### Post-MVP (2 colecciones)

| # | Colección | Propósito | Documentos Estimados | Índices Clave |
|---|-----------|-----------|----------------------|---------------|
| 4 | `unit_social_feed` | Publicaciones y comentarios por unidad | 10,000 - 1,000,000 | unit_id + created_at, author_id |
| 5 | `user_graph_relation` | Grafos de relaciones sociales | 20,000 - 2,000,000 | user_id + relation_type, target_user_id |

---

## S3 - Buckets y Estructura

### Buckets

| Bucket | Propósito | Objetos Estimados | Tamaño Estimado |
|--------|-----------|-------------------|-----------------|
| `edugo-materials-prod` | Archivos en producción | 50,000 - 500,000 | 1 TB - 100 TB |
| `edugo-materials-dev` | Archivos en desarrollo | 1,000 - 10,000 | 10 GB - 1 TB |
| `edugo-materials-staging` | Archivos en staging | 5,000 - 50,000 | 100 GB - 10 TB |

### Estructura de Prefijos

```
{school_id}/{unit_id}/{material_id}/
├── source/          (PDFs originales, inmutables)
├── processed/       (PDFs optimizados, metadata JSON)
└── assets/          (Portadas, thumbnails, previews)
```

### Tipos de Archivos

| Tipo | Extensiones | Ubicación | Tamaño Promedio |
|------|-------------|-----------|-----------------|
| PDF Original | `.pdf` | `source/` | 2 MB - 10 MB |
| PDF Procesado | `.pdf` | `processed/` | 1 MB - 5 MB |
| Metadata | `.json` | `processed/` | 5 KB - 50 KB |
| Portada | `.png` | `assets/` | 100 KB - 500 KB |
| Thumbnail | `.jpg` | `assets/` | 10 KB - 50 KB |
| Preview | `.png` | `assets/` | 200 KB - 1 MB |

---

## Mapa de Relaciones Principales

### Usuario → Material

```
app_user (author_id)
  └─→ learning_material
        ├─→ material_version (versiones)
        ├─→ material_unit_link → academic_unit (asignación)
        ├─→ material_summary_link → MongoDB: material_summary
        └─→ assessment → MongoDB: material_assessment
```

### Usuario → Progreso

```
app_user (student_id)
  ├─→ reading_log (progreso lectura)
  └─→ assessment_attempt (intentos quiz)
        └─→ assessment_attempt_answer (respuestas)
```

### Jerarquía Académica

```
school
  ├─→ subject (catálogo materias)
  └─→ academic_unit (recursivo: año → sección → club)
        └─→ unit_membership (usuarios en unidad)
              ├─→ app_user (rol: owner, teacher, student)
              └─→ material_unit_link (materiales asignados)
```

### Procesamiento Asíncrono

```
learning_material
  └─→ material_version
        └─→ S3: source/{timestamp}_original.pdf
              └─→ Worker (descarga, extrae, procesa)
                    ├─→ NLP API (genera resumen + quiz)
                    ├─→ MongoDB: material_summary
                    ├─→ MongoDB: material_assessment
                    ├─→ MongoDB: material_event (logs)
                    ├─→ PostgreSQL: material_summary_link (actualiza)
                    └─→ PostgreSQL: assessment (actualiza)
```

---

## Tamaño de Datos Estimado por Escala

### Escuela Pequeña (200 usuarios, 50 materiales)

| Storage | Tamaño |
|---------|--------|
| PostgreSQL | 50 MB |
| MongoDB | 20 MB |
| S3 | 500 MB - 2 GB |
| **Total** | **~2.5 GB** |

### Escuela Mediana (1,000 usuarios, 300 materiales)

| Storage | Tamaño |
|---------|--------|
| PostgreSQL | 500 MB |
| MongoDB | 150 MB |
| S3 | 3 GB - 10 GB |
| **Total** | **~11 GB** |

### Plataforma Grande (10,000 usuarios, 5,000 materiales)

| Storage | Tamaño |
|---------|--------|
| PostgreSQL | 5 GB |
| MongoDB | 2 GB |
| S3 | 50 GB - 200 GB |
| **Total** | **~210 GB** |

### Plataforma Masiva (100,000 usuarios, 50,000 materiales)

| Storage | Tamaño |
|---------|--------|
| PostgreSQL | 50 GB |
| MongoDB | 20 GB |
| S3 | 500 GB - 2 TB |
| **Total** | **~2 TB** |

---

## Estrategias de Particionamiento

### PostgreSQL - Particionamiento por Fecha

**Tablas candidatas**:
- `reading_log` (por `last_access_at`)
- `assessment_attempt` (por `completed_at`)
- `material_event` (en MongoDB con TTL)

**Ejemplo**:
```sql
CREATE TABLE reading_log (
    id UUID PRIMARY KEY,
    material_id UUID,
    student_id UUID,
    progress DECIMAL,
    last_access_at TIMESTAMPTZ
) PARTITION BY RANGE (last_access_at);

CREATE TABLE reading_log_2025_01 PARTITION OF reading_log
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE reading_log_2025_02 PARTITION OF reading_log
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
```

### MongoDB - Sharding por material_id

```javascript
sh.enableSharding("edugo");
sh.shardCollection("edugo.material_summary", { material_id: 1 });
sh.shardCollection("edugo.material_assessment", { material_id: 1 });
```

---

## Backup y Recuperación

### PostgreSQL

| Tipo | Frecuencia | Retención | Método |
|------|-----------|-----------|--------|
| Full Backup | Diario | 7 días | pg_dump |
| Incremental | Cada hora | 24 horas | WAL archiving |
| Point-in-time | Continuo | 7 días | WAL + pg_basebackup |

### MongoDB

| Tipo | Frecuencia | Retención | Método |
|------|-----------|-----------|--------|
| Snapshot | Diario | 7 días | MongoDB Atlas automated |
| Incremental | Cada hora | 24 horas | Oplog |
| Point-in-time | Continuo | 7 días | Continuous backup |

### S3

| Tipo | Frecuencia | Retención | Método |
|------|-----------|-----------|--------|
| Versionado | Automático | Configurable | S3 Versioning |
| Cross-region | Continuo | Permanente | S3 Replication |
| Glacier | Tras 1 año | Permanente | Lifecycle Policy |

---

## Consultas de Diagnóstico

### PostgreSQL - Tamaño de Tablas

```sql
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### MongoDB - Tamaño de Colecciones

```javascript
db.getCollectionNames().forEach(function(collection) {
    var stats = db.getCollection(collection).stats();
    print(collection + ": " + (stats.size / 1024 / 1024).toFixed(2) + " MB");
});
```

### S3 - Uso por Bucket

```bash
aws s3api list-buckets --query "Buckets[].Name" --output text | \
while read bucket; do
    echo "$bucket: $(aws s3 ls s3://$bucket --recursive --summarize | grep 'Total Size' | awk '{print $3}')"
done
```

---

## Métricas de Rendimiento

### PostgreSQL

| Métrica | Valor Objetivo | Query |
|---------|----------------|-------|
| Conexiones activas | < 50 | `SELECT count(*) FROM pg_stat_activity;` |
| Queries lentas (>1s) | < 5% | `SELECT count(*) FROM pg_stat_statements WHERE mean_time > 1000;` |
| Cache hit ratio | > 99% | `SELECT sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) FROM pg_statio_user_tables;` |

### MongoDB

| Métrica | Valor Objetivo | Query |
|---------|----------------|-------|
| Operaciones/seg | < 10,000 | `db.serverStatus().opcounters` |
| Queries lentas (>100ms) | < 1% | `db.system.profile.find({ millis: { $gt: 100 } })` |
| Índice usage | > 95% | `db.collection.aggregate([{ $indexStats: {} }])` |

### S3

| Métrica | Valor Objetivo | Monitoreo |
|---------|----------------|-----------|
| GET latency | < 100ms | CloudWatch Metrics |
| PUT latency | < 200ms | CloudWatch Metrics |
| 4xx errors | < 0.1% | CloudWatch Metrics |

---

**Documento**: Lista Maestra de Tablas y Colecciones EduGo
**Versión**: 1.0
**Fecha**: 2025-01-29
**Autor**: Equipo EduGo

**Resumen**:
- PostgreSQL: 17 tablas + 1 auditoría (Post-MVP)
- MongoDB: 3 colecciones MVP + 2 Post-MVP
- S3: 3 buckets (prod, dev, staging)
