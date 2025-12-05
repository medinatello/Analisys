# App de Administración EduGo

## Propósito

La **App de Administración EduGo** es una aplicación especializada diseñada para la gestión integral de instituciones educativas. Proporciona herramientas avanzadas para administradores escolares, directores y personal académico para gestionar todos los aspectos operativos y académicos de las escuelas.

## Arquitectura Técnica

### Backend
- **API**: edugo-api-administracion
- **Puerto**: 8081
- **Tecnología**: Go + Gin + GORM
- **Base de Datos**: PostgreSQL 15 + MongoDB 7.0
- **Mensajería**: RabbitMQ 3.12

### Frontend (Multiplataforma)
- **Framework**: React Native / Flutter (por definir)
- **Platforms**: iOS, Android, Web
- **Autenticación**: JWT + Refresh Tokens
- **Estado**: Redux/Zustand (por definir)

## Usuarios Objetivo

### 1. Administrador Global (super_admin)
**Responsabilidades**:
- Gestión de múltiples escuelas
- Configuración global del sistema
- Análisis de estadísticas generales
- Gestión de licencias y facturación
- Acceso completo a todas las funcionalidades

**Necesidades**:
- Dashboard con métricas de todas las escuelas
- CRUD completo de escuelas
- Gestión de usuarios a nivel global
- Reportes consolidados

### 2. Director de Escuela (director_escuela)
**Responsabilidades**:
- Administración completa de su institución
- Gestión de estructura académica (grados, secciones)
- Asignación de personal docente
- Supervisión de progreso académico
- Generación de reportes institucionales

**Necesidades**:
- Vista jerárquica de unidades académicas
- Gestión de usuarios de su escuela
- Dashboard con métricas de su institución
- Herramientas de planificación académica
- Control de accesos y permisos

### 3. Director Académico (director_academico)
**Responsabilidades**:
- Planificación curricular
- Gestión de materias y horarios
- Asignación de docentes a materias
- Supervisión del rendimiento académico
- Configuración de períodos académicos

**Necesidades**:
- Gestión de ciclos y periodos
- Programación de horarios
- Asignación de recursos (aulas, laboratorios)
- Reportes académicos detallados
- Gestión de escalas de calificación

### 4. Coordinador (coordinador)
**Responsabilidades**:
- Gestión operativa de grados/niveles específicos
- Seguimiento de estudiantes asignados
- Coordinación con docentes
- Gestión de eventos y actividades

**Necesidades**:
- Vista filtrada por sus unidades asignadas
- Gestión de membresías de estudiantes
- Calendario de eventos
- Reportes de su área de responsabilidad

## Alcance vs App Principal

### App de Administración (Puerto 8081)
**Enfoque**: Gestión institucional y operativa

**Funcionalidades**:
- ✅ Gestión de escuelas y estructura académica
- ✅ Administración de usuarios y permisos
- ✅ Configuración de unidades académicas
- ✅ Asignación de membresías
- ✅ Gestión de materias
- ✅ Relaciones tutor-estudiante
- ✅ Estadísticas globales
- 🔄 Ciclos y periodos académicos (pendiente)
- 🔄 Horarios y programación (pendiente)
- 🔄 Recursos y aulas (pendiente)
- 🔄 Reportes administrativos (pendiente)
- 🔄 Auditoría y logs (pendiente)

**NO incluye**:
- Consumo de materiales educativos
- Progreso individual de estudiantes
- Generación de quizzes
- Chat con IA
- Notificaciones push personalizadas

### App Principal/Móvil (Puerto 8080)
**Enfoque**: Experiencia educativa y aprendizaje

**Funcionalidades**:
- Consumo de materiales educativos
- Progreso y tracking de aprendizaje
- Quizzes y evaluaciones automáticas
- Resúmenes generados por IA
- Chat educativo con IA
- Notificaciones de progreso
- Dashboard personal de estudiante/tutor

**NO incluye**:
- Gestión administrativa
- Configuración institucional
- Creación de estructura académica
- Asignación masiva de usuarios

## Modelo de Datos Principal

### Entidades Core
```
schools (escuelas)
├── units (unidades académicas: grados, secciones, grupos)
│   ├── memberships (asignaciones usuario-unidad)
│   └── subjects (materias por unidad)
├── users (usuarios de la escuela)
└── guardian_relations (relaciones tutor-estudiante)
```

### Jerarquía Académica Típica
```
Escuela
└── Nivel (e.g., Primaria, Secundaria)
    └── Grado (e.g., 1er Grado, 2do Grado)
        └── Sección (e.g., Sección A, Sección B)
            ├── Estudiantes (memberships)
            ├── Docentes (memberships)
            └── Materias (subjects)
```

## Permisos y Roles

### Matriz de Permisos

| Funcionalidad | super_admin | director_escuela | director_academico | coordinador | docente |
|--------------|-------------|------------------|-------------------|-------------|---------|
| CRUD Escuelas | ✅ | ❌ | ❌ | ❌ | ❌ |
| Editar mi escuela | ✅ | ✅ | ❌ | ❌ | ❌ |
| CRUD Unidades | ✅ | ✅ | ✅ | Limitado* | ❌ |
| CRUD Usuarios | ✅ | ✅ | ✅ | Limitado* | ❌ |
| CRUD Materias | ✅ | ✅ | ✅ | Limitado* | ❌ |
| CRUD Membresías | ✅ | ✅ | ✅ | Limitado* | Limitado** |
| Ver estadísticas globales | ✅ | Ver solo su escuela | Ver solo su área | Ver solo su área | ❌ |
| Gestión de tutores | ✅ | ✅ | ✅ | Limitado* | ❌ |
| Reportes completos | ✅ | ✅ | ✅ | Limitado* | Limitado** |
| Auditoría | ✅ | Ver solo su escuela | ❌ | ❌ | ❌ |

*Limitado: Solo en unidades asignadas como coordinador  
**Limitado: Solo lectura de sus asignaciones

## Flujos Principales

### 1. Configuración Inicial de Escuela
```
1. super_admin crea escuela → POST /v1/schools
2. director_escuela crea estructura académica → POST /v1/units (niveles, grados, secciones)
3. director_academico crea materias → POST /v1/subjects
4. Asignación de docentes → POST /v1/memberships
5. Importación/creación de estudiantes → POST /v1/users (batch)
6. Asignación de estudiantes a secciones → POST /v1/memberships
```

### 2. Gestión de Ciclo Académico (Futuro)
```
1. director_academico crea periodo académico → POST /v1/cycles
2. Configura horarios por sección → POST /v1/schedules
3. Asigna aulas y recursos → POST /v1/classrooms
4. Configura escala de calificaciones → POST /v1/grading-scales
5. Inicia periodo → PATCH /v1/cycles/:id (status: active)
```

### 3. Gestión de Usuarios
```
1. Crear usuario → POST /v1/users
2. Asignar a unidad(es) → POST /v1/memberships
3. Configurar relación tutor (si es estudiante) → POST /v1/guardian-relations
4. Configurar permisos adicionales → PATCH /v1/users/:id/permissions
```

### 4. Reportes y Auditoría (Futuro)
```
1. Seleccionar tipo de reporte → GET /v1/reports/types
2. Configurar filtros y parámetros
3. Generar reporte → POST /v1/reports/generate
4. Descargar/exportar → GET /v1/reports/:id/export
```

## Métricas y KPIs

### Dashboard Administrativo
- Total de escuelas (super_admin)
- Total de usuarios por rol
- Estudiantes activos
- Docentes activos
- Unidades académicas creadas
- Materias configuradas
- Tasa de ocupación de secciones
- Tasa de uso del sistema

### Métricas Académicas
- Promedio de estudiantes por sección
- Promedio de materias por grado
- Distribución de docentes por materia
- Relación docente-estudiante
- Períodos académicos configurados

## Seguridad y Compliance

### Autenticación
- JWT con tiempo de expiración corto (15 min)
- Refresh tokens con rotación
- Multi-factor authentication (futuro)

### Autorización
- RBAC (Role-Based Access Control)
- Validación de permisos a nivel de endpoint
- Validación de ownership (escuela, unidad)

### Auditoría
- Log de todas las operaciones CRUD
- Registro de cambios en datos sensibles
- Trazabilidad de acciones administrativas

### Privacidad
- Encriptación de datos sensibles
- Cumplimiento GDPR/LOPD
- Gestión de consentimientos (tutores)

## Roadmap

### Fase 1 (Actual) - Funcionalidad Básica ✅
- CRUD de escuelas
- CRUD de unidades académicas
- CRUD de usuarios
- CRUD de membresías
- CRUD de materias
- Relaciones tutor-estudiante
- Estadísticas globales
- Árbol jerárquico

### Fase 2 (Q1 2026) - Planificación Académica 🔄
- Ciclos y periodos académicos
- Horarios y programación
- Aulas y recursos
- Escalas de calificación
- Importación masiva de datos

### Fase 3 (Q2 2026) - Reportes y Análisis 📊
- Reportes administrativos
- Reportes académicos
- Exportación de datos (Excel, PDF)
- Dashboard avanzado con gráficas
- Alertas y notificaciones administrativas

### Fase 4 (Q3 2026) - Funcionalidades Avanzadas 🚀
- Módulo de pagos/finanzas
- Gestión de eventos escolares
- Certificados y documentos
- Auditoría completa
- Roles y permisos granulares
- API pública para integraciones

## Integraciones Futuras

### Sistemas de Pago
- Stripe
- PayPal
- Transferencias bancarias locales

### Comunicación
- Twilio (SMS)
- SendGrid (Email)
- Push notifications (Firebase)

### Almacenamiento
- AWS S3 (documentos, certificados)
- Cloudinary (imágenes)

### Analytics
- Google Analytics
- Mixpanel
- Custom analytics dashboard

## Documentos Relacionados

- [PANTALLAS.md](PANTALLAS.md) - Especificación detallada de todas las pantallas
- [ENDPOINTS-FALTANTES.md](ENDPOINTS-FALTANTES.md) - API endpoints pendientes de implementar
- [/docs/ESTADO_PROYECTO.md](/docs/ESTADO_PROYECTO.md) - Estado general del proyecto
- [/docs/DEVELOPMENT.md](/docs/DEVELOPMENT.md) - Guía de desarrollo

---

**Última actualización**: 1 de Diciembre, 2025  
**Versión**: 1.0.0  
**Estado**: En desarrollo activo
