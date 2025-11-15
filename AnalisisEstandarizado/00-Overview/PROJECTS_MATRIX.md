# 📊 Matriz de Proyectos y Dependencias - EduGo

## 🎯 Matriz de Dependencias entre Repositorios

### Leyenda
- ✅ Dependencia fuerte (breaking changes afectan)
- ⚠️ Dependencia media (puede funcionar con versión anterior)
- 📦 Importa como módulo Go
- 🔄 Comunicación por eventos (RabbitMQ)
- 🌐 Comunicación por API REST
- 💾 Comparte base de datos

| Proyecto | Depende de | Tipo de Dependencia | Criticidad | Versión Mínima |
|----------|------------|-------------------|------------|----------------|
| **api-mobile** | shared | 📦 Módulo Go | ✅ Alta | v1.2.0+ |
| **api-mobile** | PostgreSQL | 💾 Base de datos | ✅ Alta | 15.0+ |
| **api-mobile** | RabbitMQ | 🔄 Eventos | ✅ Alta | 3.12+ |
| **api-mobile** | MongoDB | 💾 Lectura | ⚠️ Media | 7.0+ |
| **api-mobile** | Redis | 💾 Cache | ⚠️ Baja | 7.2+ |
| **api-admin** | shared | 📦 Módulo Go | ✅ Alta | v1.2.0+ |
| **api-admin** | PostgreSQL | 💾 Base de datos | ✅ Alta | 15.0+ |
| **api-admin** | RabbitMQ | 🔄 Eventos | ✅ Alta | 3.12+ |
| **api-admin** | MongoDB | 💾 Lectura | ⚠️ Baja | 7.0+ |
| **worker** | shared | 📦 Módulo Go | ✅ Alta | v1.2.0+ |
| **worker** | RabbitMQ | 🔄 Eventos | ✅ Alta | 3.12+ |
| **worker** | PostgreSQL | 💾 Base de datos | ✅ Alta | 15.0+ |
| **worker** | MongoDB | 💾 Escritura | ✅ Alta | 7.0+ |
| **worker** | OpenAI API | 🌐 API Externa | ✅ Alta | gpt-4-turbo |

## 🔄 Matriz de Comunicación entre Servicios

### Comunicación Directa (Síncrona)

| Origen | Destino | Protocolo | Puerto | Endpoints Críticos |
|--------|---------|-----------|--------|-------------------|
| Mobile App | api-mobile | HTTPS | 8080 | `/auth/*`, `/materials/*`, `/evaluations/*` |
| Web Admin | api-admin | HTTPS | 8081 | `/admin/*`, `/reports/*`, `/config/*` |
| api-mobile | PostgreSQL | TCP | 5432 | Queries directas |
| api-admin | PostgreSQL | TCP | 5432 | Queries directas |
| worker | PostgreSQL | TCP | 5432 | Updates de estado |
| worker | MongoDB | TCP | 27017 | Escritura de resultados |
| worker | OpenAI | HTTPS | 443 | API calls |

### Comunicación Asíncrona (Eventos)

| Publisher | Event | Consumer | Exchange | Routing Key | Criticidad |
|-----------|-------|----------|----------|-------------|------------|
| api-mobile | material.created | worker | edugo.topic | material.created | ✅ Alta |
| api-mobile | evaluation.submitted | worker | edugo.topic | evaluation.submitted | ✅ Alta |
| api-admin | user.created | worker | edugo.topic | user.created | ⚠️ Media |
| api-admin | config.updated | api-mobile, worker | edugo.topic | config.updated | ✅ Alta |
| worker | summary.generated | api-mobile | edugo.topic | summary.generated | ⚠️ Media |
| worker | evaluation.completed | api-mobile, api-admin | edugo.topic | evaluation.completed | ✅ Alta |
| worker | notification.send | - | edugo.topic | notification.send | ⚠️ Media |

## 📦 Matriz de Módulos Compartidos (edugo-shared)

### Uso por Proyecto

| Módulo | api-mobile | api-admin | worker | Funcionalidad |
|--------|------------|-----------|--------|---------------|
| `pkg/config` | ✅ | ✅ | ✅ | Configuración multi-ambiente |
| `pkg/database` | ✅ | ✅ | ✅ | Conexiones y modelos GORM |
| `pkg/auth` | ✅ | ✅ | ❌ | JWT y autenticación |
| `pkg/messaging` | ✅ | ✅ | ✅ | RabbitMQ pub/sub |
| `pkg/logger` | ✅ | ✅ | ✅ | Logging estructurado |
| `pkg/validation` | ✅ | ✅ | ⚠️ | Validación de datos |
| `pkg/errors` | ✅ | ✅ | ✅ | Manejo de errores |
| `pkg/testing` | ✅ | ✅ | ✅ | Utilidades de test |
| `pkg/evaluation` | ✅ | ✅ | ✅ | Sistema de evaluaciones (PENDIENTE) |
| `pkg/notifications` | ✅ | ⚠️ | ✅ | Notificaciones (PENDIENTE) |

## 💾 Matriz de Acceso a Datos

### PostgreSQL - Tablas por Servicio

| Tabla | api-mobile | api-admin | worker | Operaciones |
|-------|------------|-----------|--------|-------------|
| users | R | CRUD | RU | Gestión usuarios |
| schools | R | CRUD | R | Gestión escuelas |
| academic_levels | R | CRUD | R | Niveles académicos |
| subjects | R | CRUD | R | Materias |
| materials | CRUD | CRUD | RU | Contenido educativo |
| evaluations | CRUD | CRUD | RU | Evaluaciones |
| evaluation_questions | CRUD | CRUD | RU | Preguntas |
| evaluation_answers | CRU | R | RU | Respuestas |
| evaluation_results | CR | R | CRU | Resultados |
| student_progress | CRU | R | CRU | Progreso |
| notifications | CR | CR | CRU | Notificaciones |
| audit_logs | C | CR | C | Auditoría |

**Leyenda**: C=Create, R=Read, U=Update, D=Delete

### MongoDB - Colecciones por Servicio

| Colección | api-mobile | api-admin | worker | Operaciones |
|-----------|------------|-----------|--------|-------------|
| material_summaries | R | R | CRU | Resúmenes IA |
| material_assessments | R | R | CRU | Evaluaciones IA |
| material_events | - | R | C | Eventos |
| analytics_data | R | R | CRU | Analytics |
| ai_processing_logs | - | R | C | Logs IA |

## 🔐 Matriz de Permisos y Roles

### Endpoints por Rol

| Servicio | Endpoint Pattern | super_admin | school_admin | teacher | student |
|----------|-----------------|-------------|--------------|---------|---------|
| api-mobile | `/auth/*` | ✅ | ✅ | ✅ | ✅ |
| api-mobile | `/materials/*` | ✅ | ✅ | CRU | R |
| api-mobile | `/evaluations/*` | ✅ | ✅ | CRUD | CR |
| api-mobile | `/progress/*` | ✅ | R | R | R |
| api-admin | `/admin/users/*` | ✅ | CRU | - | - |
| api-admin | `/admin/schools/*` | ✅ | RU | - | - |
| api-admin | `/admin/reports/*` | ✅ | R | R | - |
| api-admin | `/admin/config/*` | ✅ | RU | - | - |

## 🚀 Matriz de Deployment

### Requisitos por Servicio

| Servicio | CPU | RAM | Storage | Replicas Min | Replicas Max |
|----------|-----|-----|---------|--------------|--------------|
| api-mobile | 2 cores | 2GB | 10GB | 2 | 10 |
| api-admin | 1 core | 1GB | 5GB | 1 | 3 |
| worker | 2 cores | 4GB | 20GB | 2 | 5 |
| PostgreSQL | 4 cores | 8GB | 100GB | 1 (HA) | 1 |
| MongoDB | 2 cores | 4GB | 50GB | 1 | 3 (replica set) |
| RabbitMQ | 2 cores | 2GB | 10GB | 1 | 3 (cluster) |
| Redis | 1 core | 2GB | 5GB | 1 | 1 |

### Variables de Entorno Compartidas

| Variable | api-mobile | api-admin | worker | Descripción |
|----------|------------|-----------|--------|-------------|
| DATABASE_URL | ✅ | ✅ | ✅ | PostgreSQL connection |
| MONGO_URI | ✅ | ✅ | ✅ | MongoDB connection |
| RABBITMQ_URL | ✅ | ✅ | ✅ | RabbitMQ connection |
| REDIS_URL | ✅ | ⚠️ | ❌ | Redis connection |
| JWT_SECRET | ✅ | ✅ | ❌ | JWT signing key |
| OPENAI_API_KEY | ❌ | ❌ | ✅ | OpenAI API key |
| LOG_LEVEL | ✅ | ✅ | ✅ | Logging level |
| ENVIRONMENT | ✅ | ✅ | ✅ | local/dev/qa/prod |

## 📈 Matriz de Versionado y Releases

### Estrategia de Versionado

| Proyecto | Versión Actual | Próxima Minor | Próxima Major | Frecuencia Release |
|----------|---------------|---------------|---------------|-------------------|
| shared | v1.2.0 | v1.3.0 (evaluations) | v2.0.0 (Q3 2026) | Cada 2 semanas |
| api-mobile | v0.6.0 | v0.7.0 (evaluations) | v1.0.0 (Q2 2026) | Cada 3 semanas |
| api-admin | v1.0.0 | v1.1.0 (reports) | - | Mensual |
| worker | v0.4.8 | v0.5.0 (AI complete) | v1.0.0 (Q2 2026) | Cada 3 semanas |
| dev-env | v0.4.0 | v0.5.0 (update deps) | v1.0.0 (Q2 2026) | Mensual |

### Compatibilidad de Versiones

| shared Version | Compatible api-mobile | Compatible api-admin | Compatible worker |
|---------------|---------------------|--------------------|--------------------|
| v1.2.x | v0.6.x | v1.0.x | v0.4.x |
| v1.3.x | v0.7.x+ | v1.1.x+ | v0.5.x+ |
| v2.0.x | v1.0.x+ | v1.5.x+ | v1.0.x+ |

## 🔄 Orden de Actualización para Breaking Changes

Cuando hay breaking changes en shared, seguir este orden:

1. **Fase 1**: Preparación
   - Crear branch `feature/breaking-change` en shared
   - Implementar cambios con backward compatibility si es posible
   - Crear release candidate `v1.3.0-rc.1`

2. **Fase 2**: Testing
   - Actualizar dev-environment con RC
   - Crear branches en api-mobile, api-admin, worker
   - Actualizar go.mod para usar RC
   - Ejecutar tests de integración

3. **Fase 3**: Release Coordinado
   ```
   Orden obligatorio:
   1. shared → v1.3.0 (publicar módulo)
   2. worker → Actualizar y testear (crítico para eventos)
   3. api-admin → Actualizar y testear
   4. api-mobile → Actualizar y testear (último, más usuarios)
   5. dev-environment → Actualizar docker-compose
   ```

4. **Fase 4**: Rollback Plan
   - Si falla: revertir en orden inverso
   - Mantener versión anterior 48 horas
   - Feature flags para cambios críticos

## ⚠️ Puntos de Falla Críticos

### Single Points of Failure

| Componente | Impacto si falla | Mitigación | Prioridad |
|------------|-----------------|------------|-----------|
| PostgreSQL | 🔴 Sistema completo down | HA con replica | CRÍTICA |
| RabbitMQ | 🟡 No procesamiento async | Cluster mode | ALTA |
| shared/auth | 🔴 No login posible | Cache tokens | CRÍTICA |
| OpenAI API | 🟡 No generación IA | Cache + fallback | MEDIA |
| MongoDB | 🟡 No analytics | Replica set | MEDIA |

### Dependencias Circulares

❌ **NO EXISTEN** dependencias circulares en el diseño actual

✅ **Flujo unidireccional**:
- APIs → shared (nunca al revés)
- APIs → RabbitMQ → Worker (nunca retorno directo)
- Worker → Databases (nunca expone APIs)

## 📋 Checklist de Coordinación Multi-Repo

Antes de implementar cualquier feature que afecte múltiples repos:

### Pre-Implementación
- [ ] Identificar todos los repos afectados
- [ ] Verificar versiones de dependencias
- [ ] Crear issues en cada repo
- [ ] Definir orden de implementación
- [ ] Identificar breaking changes

### Durante Implementación
- [ ] Crear branch con mismo nombre en todos los repos
- [ ] Mantener compatibilidad hacia atrás si es posible
- [ ] Actualizar tests de integración
- [ ] Documentar cambios en CHANGELOG
- [ ] Actualizar OpenAPI specs si aplica

### Post-Implementación
- [ ] Ejecutar tests E2E completos
- [ ] Verificar logs sin errores
- [ ] Actualizar documentación
- [ ] Crear PRs coordinados
- [ ] Plan de rollback documentado

---

**Última actualización**: 2025-11-14  
**Uso**: Referencia para coordinación multi-repositorio  
**Criticidad**: ALTA - Consultar antes de cualquier cambio cross-repo