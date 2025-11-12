# Distribución de Responsabilidades - Ecosistema EduGo

**Fecha:** 11 de Noviembre, 2025  
**Autor:** Equipo EduGo + Claude Code  
**Objetivo:** Definir qué proyecto implementa qué funcionalidad/tabla/endpoint

---

## 🎯 PRINCIPIOS DE DISTRIBUCIÓN

### Separación por Frecuencia de Uso

**Criterio Principal:** La división entre `api-mobile` y `api-administracion` se basa en la frecuencia y naturaleza de las peticiones.

| Proyecto | Tipo de Endpoints | Usuarios | Volumen Esperado |
|----------|-------------------|----------|------------------|
| **edugo-api-mobile** | Alto tráfico, operaciones frecuentes | Estudiantes, Profesores, Tutores | **Miles de requests/hora** |
| **edugo-api-administracion** | Bajo tráfico, operaciones administrativas | Administradores, Directivos | **Decenas de requests/hora** |

---

## 📊 PARTE 1: TABLAS POSTGRESQL

### 🟢 edugo-api-mobile (APIs de Alta Frecuencia)

#### Implementadas Actualmente ✅

| # | Tabla | Propósito | Estado |
|---|-------|-----------|--------|
| 1 | `users` | Usuarios del sistema (todos los roles) | ✅ **Implementada** |
| 2 | `materials` | Materiales educativos | ✅ **Implementada** |
| 3 | `material_progress` | Progreso de lectura por estudiante | ✅ **Implementada** |

#### Debe Implementar (Prioridad Alta) 🔴

| # | Tabla Original | Responsabilidad | Justificación |
|---|----------------|-----------------|---------------|
| 4 | `assessment` | Metadatos de evaluaciones | Estudiantes consultan quizzes frecuentemente |
| 5 | `assessment_attempt` | Intentos de quiz | Alto tráfico: cada intento es un registro |
| 6 | `assessment_attempt_answer` | Respuestas individuales | Alto tráfico: múltiples respuestas por intento |
| 7 | `material_summary_link` | Enlace a resúmenes en MongoDB | Estudiantes consultan resúmenes frecuentemente |

**Razón:** Sistema de evaluaciones es operación frecuente de estudiantes.

#### Debe Implementar (Prioridad Media) 🟡

| # | Tabla Original | Decisión | Justificación |
|---|----------------|----------|---------------|
| 8 | `reading_log` | ⚠️ **YA EXISTE** como `material_progress` | Renombrado pero cumple función |
| 9 | `material_version` | **PENDIENTE ANÁLISIS** | ¿Versionado es operación frecuente o administrativa? |
| 10 | `material_unit_link` | **DEPENDE de jerarquía** | Ver sección api-administracion |

---

### 🔵 edugo-api-administracion (APIs Administrativas)

#### Debe Implementar (Prioridad CRÍTICA) ⚠️

| # | Tabla Original | Responsabilidad | Justificación |
|---|----------------|-----------------|---------------|
| 1 | `school` | Gestión de escuelas/instituciones | Operación administrativa poco frecuente |
| 2 | `academic_unit` | Jerarquía académica (años, secciones, clubes) | **CRÍTICO**: Base de organización |
| 3 | `unit_membership` | Asignación usuarios↔unidades | Operación de inscripción/organización |
| 4 | `subject` | Catálogo de materias | Configuración administrativa |

**⚠️ NOTA CRÍTICA DEL USUARIO:**
> "ese faltante de jerarquia es extremadamente importante, si me di cuenta que esa parte faltaba, bueno, ese es importante verlo a quien de los proyecto le tocara agregarse"

**DECISIÓN:** La jerarquía académica (`school`, `academic_unit`, `unit_membership`) **DEBE** ir en `edugo-api-administracion` porque:
- Son operaciones de configuración/administración
- Baja frecuencia de cambio
- Requieren permisos administrativos
- Separa concerns: api-mobile consume, api-admin gestiona

#### Debe Implementar (Prioridad Alta) 🔴

| # | Tabla Original | Responsabilidad | Justificación |
|---|----------------|-----------------|---------------|
| 5 | `teacher_profile` | Datos específicos de docentes | Gestión administrativa de staff |
| 6 | `student_profile` | Datos específicos de estudiantes | Gestión de matrícula |
| 7 | `guardian_profile` | Datos específicos de tutores | Gestión de contactos |
| 8 | `guardian_student_relation` | Relación tutor↔estudiante | Gestión de familias |

**DECISIÓN:** Perfiles especializados van en `api-administracion` porque:
- Se crean/modifican en proceso de inscripción (admin)
- api-mobile solo **consulta** estos datos
- Separación de responsabilidades: crear vs consumir

#### Debe Implementar (Prioridad Media) 🟡

| # | Tabla Original | Responsabilidad | Justificación |
|---|----------------|-----------------|---------------|
| 9 | `material_unit_link` | Asignación material↔unidad | Operación administrativa (profesor/admin asigna material a sección) |
| 10 | `audit_log` | Registro de operaciones administrativas | Auditoría de acciones de admins |

---

### 🟣 edugo-shared (Biblioteca Compartida)

**NO gestiona tablas directamente**, pero provee:

| Módulo | Funcionalidad | Usado Por |
|--------|---------------|-----------|
| `database/postgres` | Conexión a PostgreSQL | Todos los proyectos |
| `database/mongodb` | Conexión a MongoDB | api-mobile, worker |
| `auth/` | JWT, tokens, validación | api-mobile, api-admin |
| `logger/` | Logging estructurado | Todos |
| `middleware/` | Middlewares HTTP | api-mobile, api-admin |
| `messaging/` | Cliente RabbitMQ | api-mobile, worker |

**Oportunidad de Mejora:** Migrar helpers de api-mobile a shared:
- Testcontainers setup
- Repositorios base (interfaces genéricas)
- Validadores comunes

---

## 🔄 PARTE 2: COLECCIONES MONGODB

### Colecciones Diseñadas

| # | Colección | Responsable Lectura | Responsable Escritura | Estado |
|---|-----------|---------------------|----------------------|--------|
| 1 | `material_summary` | **api-mobile** | **worker** | ⚠️ No verificado |
| 2 | `material_assessment` | **api-mobile** | **worker** | ⚠️ No verificado |
| 3 | `material_event` | **api-admin** (reportes) | **worker** | ⚠️ No verificado |

**Patrón:**
- **Worker** es el único que **ESCRIBE** en MongoDB (procesamiento asíncrono)
- **APIs** solo **LEEN** de MongoDB (consultas rápidas)

---

## 🚀 PARTE 3: ENDPOINTS REST

### 🟢 edugo-api-mobile (Puerto 8080)

#### Módulo: Autenticación
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `/v1/auth/login` | POST | Login con JWT | ✅ Implementado |
| `/v1/auth/refresh` | POST | Renovar token | ⚠️ Verificar |
| `/v1/auth/logout` | POST | Cerrar sesión | ⚠️ Verificar |

#### Módulo: Materiales (Estudiante)
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `GET /v1/materials` | GET | Listar materiales disponibles | ✅ Implementado |
| `GET /v1/materials/:id` | GET | Detalle de un material | ✅ Implementado |
| `GET /v1/materials/:id/summary` | GET | Obtener resumen (MongoDB) | ⚠️ Verificar |
| `POST /v1/materials/:id/progress` | POST | Actualizar progreso de lectura | ✅ Implementado |
| `GET /v1/materials/:id/progress` | GET | Obtener mi progreso | ✅ Implementado |

#### Módulo: Materiales (Profesor)
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `POST /v1/materials` | POST | Subir nuevo material | ✅ Implementado |
| `PUT /v1/materials/:id` | PUT | Actualizar material | ⚠️ Verificar |
| `DELETE /v1/materials/:id` | DELETE | Eliminar material (soft delete) | ⚠️ Verificar |

#### Módulo: Evaluaciones (PENDIENTE) ❌
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `GET /v1/materials/:id/assessment` | GET | Obtener quiz (MongoDB) | ❌ No existe |
| `POST /v1/assessments/:id/attempts` | POST | Crear intento de quiz | ❌ No existe |
| `POST /v1/attempts/:id/answers` | POST | Enviar respuestas | ❌ No existe |
| `GET /v1/attempts/:id/results` | GET | Obtener resultados | ❌ No existe |

#### Módulo: Perfil de Usuario
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `GET /v1/users/me` | GET | Obtener mi perfil | ⚠️ Verificar |
| `PUT /v1/users/me` | PUT | Actualizar mi perfil | ⚠️ Verificar |

---

### 🔵 edugo-api-administracion (Puerto 8081)

#### Módulo: Gestión de Escuelas (CRÍTICO) ⚠️
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `POST /v1/schools` | POST | Crear escuela | ❌ No existe |
| `GET /v1/schools` | GET | Listar escuelas | ❌ No existe |
| `GET /v1/schools/:id` | GET | Detalle de escuela | ❌ No existe |
| `PUT /v1/schools/:id` | PUT | Actualizar escuela | ❌ No existe |

#### Módulo: Jerarquía Académica (CRÍTICO) ⚠️
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `POST /v1/schools/:id/units` | POST | Crear unidad académica (año, sección, club) | ❌ No existe |
| `GET /v1/schools/:id/units` | GET | Listar unidades de una escuela | ❌ No existe |
| `GET /v1/units/:id` | GET | Detalle de unidad | ❌ No existe |
| `PUT /v1/units/:id` | PUT | Actualizar unidad | ❌ No existe |
| `DELETE /v1/units/:id` | DELETE | Eliminar unidad | ❌ No existe |

#### Módulo: Membresías (Asignación de Usuarios a Unidades) ⚠️
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `POST /v1/units/:id/members` | POST | Asignar usuario a unidad | ❌ No existe |
| `GET /v1/units/:id/members` | GET | Listar miembros de unidad | ❌ No existe |
| `DELETE /v1/units/:id/members/:userId` | DELETE | Quitar usuario de unidad | ❌ No existe |

#### Módulo: Gestión de Usuarios
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `POST /v1/users` | POST | Crear usuario (admin, profesor, estudiante, tutor) | ⚠️ Verificar |
| `GET /v1/users` | GET | Listar usuarios (paginado, filtros) | ⚠️ Verificar |
| `GET /v1/users/:id` | GET | Detalle de usuario | ⚠️ Verificar |
| `PUT /v1/users/:id` | PUT | Actualizar usuario | ⚠️ Verificar |
| `DELETE /v1/users/:id` | DELETE | Desactivar usuario | ⚠️ Verificar |

#### Módulo: Gestión de Materias
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `POST /v1/schools/:id/subjects` | POST | Crear materia | ❌ No existe |
| `GET /v1/schools/:id/subjects` | GET | Listar materias | ❌ No existe |
| `PUT /v1/subjects/:id` | PUT | Actualizar materia | ❌ No existe |

#### Módulo: Asignación de Materiales a Unidades
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `POST /v1/units/:id/materials` | POST | Asignar material a unidad | ❌ No existe |
| `GET /v1/units/:id/materials` | GET | Listar materiales de unidad | ❌ No existe |
| `DELETE /v1/units/:id/materials/:materialId` | DELETE | Quitar material de unidad | ❌ No existe |

#### Módulo: Reportes y Analytics
| Endpoint | Método | Propósito | Estado |
|----------|--------|-----------|--------|
| `GET /v1/reports/school/:id/progress` | GET | Reporte de progreso por escuela | ❌ No existe |
| `GET /v1/reports/unit/:id/progress` | GET | Reporte de progreso por unidad | ❌ No existe |
| `GET /v1/reports/material/:id/stats` | GET | Estadísticas de un material | ❌ No existe |

---

## ⚙️ PARTE 4: PROCESAMIENTO ASÍNCRONO (Worker)

### 🟠 edugo-worker

**Responsabilidad Única:** Procesamiento asíncrono de materiales con IA.

#### Flujo de Trabajo

```
1. Consume evento de RabbitMQ
   Queue: edugo.material.uploaded
   
2. Descarga PDF desde S3
   (usando s3_key de tabla materials)
   
3. Extrae texto del PDF
   (librería pdftotext o similar)
   
4. Genera resumen con OpenAI
   Model: gpt-4
   Prompt: "Resume este material educativo..."
   
5. Genera quiz con OpenAI
   Model: gpt-4
   Prompt: "Crea 5 preguntas de opción múltiple..."
   
6. Guarda en MongoDB
   - Colección: material_summary
   - Colección: material_assessment
   - Colección: material_event (logs)
   
7. Actualiza PostgreSQL
   UPDATE materials SET processing_status = 'completed'
```

#### Eventos que Consume

| Evento | Queue | Acción |
|--------|-------|--------|
| `MATERIAL_UPLOADED` | `edugo.material.uploaded` | Procesar nuevo material |
| `MATERIAL_REPROCESS` | `edugo.material.reprocess` | Reprocesar material existente |

#### Estado de Implementación

⚠️ **NO VERIFICADO**

Necesitamos inspeccionar código para confirmar:
- ✅/❌ ¿Conexión a RabbitMQ funcional?
- ✅/❌ ¿Procesamiento de PDFs implementado?
- ✅/❌ ¿Integración con OpenAI?
- ✅/❌ ¿Guardado en MongoDB?

---

## 🌐 PARTE 5: DEPENDENCIAS COMPARTIDAS

### 🐘 PostgreSQL
**Instancia Única Compartida**

Todos los proyectos **comparten la misma instancia** de PostgreSQL:
- api-mobile: Lee/escribe `users`, `materials`, `material_progress`
- api-administracion: Lee/escribe `school`, `academic_unit`, `unit_membership`, etc.
- worker: Actualiza `materials.processing_status`

**Gestión:**
- Schemas SQL viven en cada repo según responsabilidad
- Migraciones coordinadas (documentar en dev-environment)

---

### 🍃 MongoDB
**Instancia Única Compartida**

- **Escritura:** Solo `worker`
- **Lectura:** `api-mobile`, `api-administracion`

**Gestión:**
- Schemas/validators definidos por `worker`
- APIs solo consultan (read-only)

---

### 🐰 RabbitMQ
**Instancia Única Compartida**

**Publishers:**
- `api-mobile` publica: `MATERIAL_UPLOADED`

**Consumers:**
- `worker` consume: `MATERIAL_UPLOADED`, `MATERIAL_REPROCESS`

**Gestión:**
- Definiciones de queues/exchanges en `dev-environment`
- Cliente compartido en `edugo-shared/messaging`

---

## 📦 PARTE 6: GESTIÓN DE INFRAESTRUCTURA

### 🐳 edugo-dev-environment

**Responsabilidad:** Proveer infraestructura completa para desarrollo local.

#### Debe Incluir

| Servicio | Versión | Configuración |
|----------|---------|---------------|
| PostgreSQL | 15+ | Esquemas iniciales de TODOS los proyectos |
| MongoDB | 7.0+ | Bases de datos y colecciones |
| RabbitMQ | 3.12+ | Exchanges y queues pre-configurados |
| S3 (MinIO) | latest | Buckets para materiales |

#### Debe Sincronizar

- ✅ Versión de Go (actualmente: 1.21+)
- ✅ Schemas SQL consolidados
- ✅ Scripts de seed data
- ✅ Variables de entorno de cada proyecto
- ✅ Docker Compose actualizado

**Estado Actual:** 🟡 **Desactualizado** (usuario confirmó que no lo ha tocado)

---

## 🎯 PARTE 7: MATRIZ DE DECISIÓN

### ¿Dónde va cada nueva funcionalidad?

| Pregunta | api-mobile | api-admin | worker | shared |
|----------|-----------|-----------|--------|--------|
| ¿Endpoint consultado por estudiantes frecuentemente? | ✅ | ❌ | ❌ | ❌ |
| ¿Endpoint de configuración/administración? | ❌ | ✅ | ❌ | ❌ |
| ¿Procesa algo asíncronamente? | ❌ | ❌ | ✅ | ❌ |
| ¿Es utilidad reutilizable? | ❌ | ❌ | ❌ | ✅ |
| ¿Crea/modifica jerarquía académica? | ❌ | ✅ | ❌ | ❌ |
| ¿Consulta datos de jerarquía? | ✅ | ✅ | ❌ | ❌ |
| ¿Genera contenido con IA? | ❌ | ❌ | ✅ | ❌ |

---

## 📋 RESUMEN EJECUTIVO

### Responsabilidades Clave

| Proyecto | Responsabilidad Principal | Tablas Propias | Estado |
|----------|---------------------------|----------------|--------|
| **api-mobile** | Endpoints de alta frecuencia (estudiantes, profesores) | `materials`, `material_progress`, `assessment*` | 🟡 **40% completo** |
| **api-administracion** | Endpoints administrativos, jerarquía académica | `school`, `academic_unit`, `unit_membership`, `subject`, perfiles especializados | 🔴 **10% completo** |
| **worker** | Procesamiento asíncrono con IA | Ninguna (solo actualiza) | ⚠️ **No verificado** |
| **shared** | Bibliotecas comunes reutilizables | Ninguna | 🟢 **80% completo** |
| **dev-environment** | Infraestructura de desarrollo | Ninguna (orquesta servicios) | 🟡 **40% actualizado** |

---

## 🚨 PRIORIDADES INMEDIATAS

### 1. api-administracion: Jerarquía Académica (CRÍTICO)
Implementar:
- `school`
- `academic_unit`
- `unit_membership`
- Endpoints CRUD completos

**Sin esto, el sistema no es funcional para escuelas reales.**

### 2. api-mobile: Sistema de Evaluaciones (ALTO)
Implementar:
- `assessment`
- `assessment_attempt`
- `assessment_attempt_answer`
- Endpoints CRUD completos

**Sin esto, falta componente core del producto educativo.**

### 3. Verificar Worker (MEDIO)
Confirmar que el flujo completo funciona:
- RabbitMQ ✅/❌
- Procesamiento PDF ✅/❌
- OpenAI ✅/❌
- MongoDB ✅/❌

---

**Última actualización:** 11 de Noviembre, 2025  
**Próximo paso:** Crear roadmap de implementación por proyecto

---

**Generado con** 🤖 Claude Code
