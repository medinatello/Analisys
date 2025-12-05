# Flujo de Navegación - Docente

**Fecha:** 1 de Diciembre, 2025  
**Rol:** `teacher`  
**Plataformas:** iOS, iPadOS, macOS, visionOS

---

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Diagrama de Flujo Principal](#diagrama-de-flujo-principal)
3. [Diferencias con Estudiante](#diferencias-con-estudiante)
4. [Pantallas Exclusivas](#pantallas-exclusivas)
5. [Flujos Específicos](#flujos-específicos)
6. [Deep Links](#deep-links)
7. [Permisos y Capacidades](#permisos-y-capacidades)

---

## Descripción General

El flujo de navegación del docente incluye todas las capacidades del estudiante más funcionalidades adicionales para gestión de contenido, seguimiento de estudiantes y administración de cursos.

### Características Principales

- **Todas las funciones de Estudiante:** Acceso completo a materiales, cursos, progreso personal
- **Gestión de Contenido:** Subir, editar y eliminar materiales educativos
- **Seguimiento de Estudiantes:** Ver progreso individual y grupal de sus estudiantes
- **Estadísticas de Curso:** Métricas de rendimiento de cursos
- **Calificaciones:** Revisar y calificar evaluaciones
- **Comunicación:** Mensajería directa con estudiantes

### Capacidades por Rol

```swift
// Permisos del docente (desde UserRole.swift)
- canViewAllContent: true           // Ver todo el contenido de sus cursos
- canEditContent: true              // Crear/editar materiales
- canManageUsers: false             // NO puede gestionar usuarios
- canAccessAdminPanel: false        // NO tiene acceso al panel admin
```

---

## Diagrama de Flujo Principal

```
┌─────────────────────────────────────────────────────────────────┐
│                    NAVEGACIÓN DOCENTE                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │   [HomeView]    │
                    │  (Vista Docente)│
                    └─────────────────┘
                              ↓
    ┌───────────┬──────────┬──────────┬───────────┬──────────┬──────────┐
    ↓           ↓          ↓          ↓           ↓          ↓          ↓
┌────────┐ ┌────────┐ ┌────────┐ ┌─────────┐ ┌─────────┐ ┌────────┐ ┌──────────┐
│  HOME  │ │MY COURS│ │CALENDAR│ │PROGRESS │ │STUDENTS │ │CONTENT │ │ SETTINGS │
│        │ │  ES    │ │        │ │         │ │  NEW!   │ │ MANAGE │ │          │
└────────┘ └────────┘ └────────┘ └─────────┘ └─────────┘ └────────┘ └──────────┘
    ↓           ↓                                  ↓           ↓
    │           │                                  │           │
    │           └──→ [TeacherCourseDetail]         │           │
    │                       ↓                      │           │
    │                ┌──────┴──────┐               │           │
    │                ↓             ↓               │           │
    │         [MaterialsList] [StudentsList]      │           │
    │                ↓             ↓               │           │
    │         [MaterialEdit] [StudentProgress]    │           │
    │                                              │           │
    │                                              │           │
    └──→ [TeacherDashboard]                       │           │
         - Resumen de actividad                   │           │
         - Cursos impartidos                      │           │
         - Estadísticas generales                 │           │
                                                   │           │
                                                   │           │
         ┌─────────────────────────────────────────┘           │
         ↓                                                     │
    [StudentsView]                                            │
         ↓                                                     │
    [Lista de estudiantes de mis cursos]                     │
         ↓                                                     │
    [StudentDetail]                                           │
         - Progreso del estudiante                            │
         - Cursos en común                                    │
         - Calificaciones                                     │
         - Comunicación                                       │
                                                               │
         ┌─────────────────────────────────────────────────────┘
         ↓
    [ContentManageView]
         ↓
    ┌────┴────┐
    ↓         ↓
[UploadMaterial] [EditMaterial]
    ↓         ↓
[MaterialForm]
    - Título
    - Descripción
    - Archivo (PDF/Video)
    - Curso asignado
    - Visibilidad
    ↓
[Confirmación] → Material creado/actualizado
```

---

## Diferencias con Estudiante

### Navegación Ampliada

El docente tiene acceso a **dos tabs adicionales** que no están disponibles para estudiantes:

```swift
// TabView del docente (iPhone)
TabView {
    HomeView()              // ✅ Igual que estudiante
    MyCoursesView()         // ✅ Igual que estudiante
    CalendarView()          // ✅ Igual que estudiante
    ProgressView()          // ✅ Igual que estudiante
    StudentsView()          // ⭐ NUEVO - Exclusivo docente
    ContentManageView()     // ⭐ NUEVO - Exclusivo docente
    SettingsView()          // ✅ Igual que estudiante
}
```

### Vista de Home Diferente

```swift
// Contenido del Home para docente
HomeView (Teacher)
├── Bienvenida Personalizada
├── Mis Cursos Activos (como docente)
│   └── Card con:
│       - Nombre del curso
│       - Número de estudiantes
│       - Última actividad
│       - Acciones rápidas
│
├── Actividad Reciente de Estudiantes
│   └── Timeline con:
│       - Juan completó "Matemáticas - Cap 1"
│       - María tomó quiz "Historia - Examen 1"
│       - Pedro subió tarea "Proyecto Final"
│
├── Estadísticas Generales
│   └── Cards con:
│       - Total estudiantes en mis cursos
│       - Materiales subidos esta semana
│       - Promedio de calificaciones
│       - Engagement rate
│
└── Acciones Rápidas
    └── Botones:
        - Subir nuevo material
        - Ver estadísticas de curso
        - Revisar tareas pendientes
```

### Vista de Curso Ampliada

```
CourseDetail (Teacher)
├── [Tabs superiores]
│   ├── Overview       ← Info general del curso
│   ├── Materials      ← Materiales (con botón "Agregar")
│   ├── Students       ← Lista de estudiantes inscritos
│   ├── Analytics      ← Estadísticas del curso
│   └── Settings       ← Configuración del curso
│
├── Overview Tab
│   ├── Descripción del curso
│   ├── Profesores asignados
│   ├── Nivel educativo
│   ├── Estadísticas rápidas
│   └── Botón "Editar Curso"
│
├── Materials Tab
│   ├── Lista de materiales
│   ├── Filtros (tipo, fecha, visibilidad)
│   ├── Botón "Agregar Material" (floating action button)
│   └── Cada material muestra:
│       - Título
│       - Tipo (PDF, video, etc.)
│       - Fecha de publicación
│       - Vistas/Descargas
│       - Botones: Editar | Eliminar | Estadísticas
│
├── Students Tab
│   ├── Lista de estudiantes inscritos
│   ├── Búsqueda por nombre
│   ├── Cada estudiante muestra:
│       - Nombre y foto
│       - Progreso en el curso (%)
│       - Última actividad
│       - Promedio de quizzes
│       - Tap → StudentDetailView
│   └── Botón "Exportar Calificaciones"
│
├── Analytics Tab
│   ├── Gráficas de engagement
│   ├── Materiales más populares
│   ├── Rendimiento promedio
│   ├── Timeline de actividad
│   └── Comparativa con otros cursos
│
└── Settings Tab
    ├── Visibilidad del curso
    ├── Inscripción (abierta/cerrada)
    ├── Docentes asignados
    └── Botón "Archivar Curso"
```

---

## Pantallas Exclusivas

### 👥 StudentsView (Vista de Estudiantes)

**Ruta:** `.students` (tab exclusivo)

**Contenido:**
- **Lista de Todos los Estudiantes:** De cursos donde soy docente
- **Filtros:**
  - Por curso
  - Por nivel de progreso (alto, medio, bajo)
  - Por último acceso
- **Búsqueda:** Por nombre o email
- **Ordenamiento:** Nombre, progreso, última actividad

**Layout:**

```
StudentsView
├── Search Bar
├── Filters Chips
│   └── [Todos] [Curso A] [Curso B] [Activos] [Inactivos]
│
└── Lista de Estudiantes (LazyVStack)
    └── StudentCard
        ├── Avatar
        ├── Nombre
        ├── Email
        ├── Cursos en común (badge)
        ├── Progreso general (progress bar)
        ├── Última actividad (fecha relativa)
        └── Tap → StudentDetailView
```

**Navegación:**
```
StudentsView
  ↓ (tap en estudiante)
StudentDetailView
  ├── Header
  │   ├── Avatar grande
  │   ├── Nombre completo
  │   ├── Email
  │   └── Botón "Enviar Mensaje"
  │
  ├── Tabs
  │   ├── Overview
  │   │   ├── Cursos inscritos (solo en común conmigo)
  │   │   ├── Progreso general
  │   │   ├── Promedio de calificaciones
  │   │   └── Timeline de actividad reciente
  │   │
  │   ├── Courses Progress
  │   │   └── Por cada curso:
  │   │       ├── Nombre del curso
  │   │       ├── Progreso (%)
  │   │       ├── Materiales completados / total
  │   │       ├── Quizzes promedio
  │   │       └── Tap → Detalles del progreso en ese curso
  │   │
  │   ├── Grades
  │   │   └── Tabla de calificaciones:
  │   │       ├── Material | Quiz | Calificación | Fecha
  │   │       └── Botón "Exportar Calificaciones"
  │   │
  │   └── Activity
  │       └── Timeline completo de actividad
  │           ├── Material leído
  │           ├── Quiz realizado
  │           ├── Comentario en foro
  │           └── etc.
  │
  └── Footer
      └── Botones de acción:
          - Enviar mensaje
          - Programar reunión
          - Generar reporte
```

---

### 📁 ContentManageView (Gestión de Contenido)

**Ruta:** `.contentManage` (tab exclusivo)

**Contenido:**
- **Todos los Materiales:** Que he subido
- **Filtros:**
  - Por curso
  - Por tipo (PDF, video, link, etc.)
  - Por visibilidad (público, privado, programado)
  - Por fecha de publicación
- **Acciones:**
  - Subir nuevo material
  - Editar material existente
  - Eliminar material
  - Ver estadísticas de material

**Layout:**

```
ContentManageView
├── Header
│   └── Botón "Subir Material" (primary action)
│
├── Filters Bar
│   └── [Todos] [PDF] [Video] [Link] [Curso A] [Curso B]
│
├── Lista de Materiales (Grid en iPad/Mac, List en iPhone)
│   └── MaterialCard
│       ├── Thumbnail/Icono
│       ├── Título
│       ├── Tipo
│       ├── Curso
│       ├── Fecha de publicación
│       ├── Estadísticas rápidas
│       │   ├── 👁️ 234 vistas
│       │   ├── ⬇️ 89 descargas
│       │   └── ✅ 67 completados
│       └── Menú contextual
│           ├── Ver
│           ├── Editar
│           ├── Estadísticas
│           ├── Duplicar
│           └── Eliminar
│
└── Empty State
    └── "No has subido materiales aún"
        └── Botón "Subir tu primer material"
```

**Navegación:**
```
ContentManageView
  ↓ (tap en "Subir Material")
UploadMaterialView (Sheet)
  ├── Formulario
  │   ├── Título (TextField)
  │   ├── Descripción (TextEditor)
  │   ├── Tipo (Picker: PDF, Video, Link, Documento)
  │   ├── Archivo (File Picker)
  │   ├── Curso (Picker: mis cursos)
  │   ├── Visibilidad (Picker: Público, Privado)
  │   ├── Fecha de publicación (opcional)
  │   └── Tags (TextField con chips)
  │
  └── Botones
      ├── Cancelar
      └── Subir Material (async)
          ↓
    [Proceso de subida]
          ↓
    ┌─────────────────┐
    │ ¿Tipo == PDF?   │
    └─────────────────┘
      ↙             ↘
    SÍ              NO
      ↓               ↓
  [Genera resumen   [Guarda material]
   con OpenAI]            ↓
      ↓           [Success → Volver a lista]
  [Genera quiz
   con OpenAI]
      ↓
  [Guarda todo]
      ↓
  [Success → Volver a lista]
```

**Edición de Material:**
```
ContentManageView
  ↓ (tap en material → menú → "Editar")
EditMaterialView (Sheet)
  ├── Pre-llena formulario con datos actuales
  ├── Permite cambiar:
  │   ├── Título
  │   ├── Descripción
  │   ├── Visibilidad
  │   ├── Curso asignado
  │   └── Tags
  │
  ├── NO permite cambiar:
  │   ├── Archivo (debe subir nuevo material)
  │   └── Tipo
  │
  └── Botones
      ├── Cancelar
      └── Guardar Cambios
          ↓
    [Actualiza en backend]
          ↓
    [Success → Volver a lista actualizada]
```

---

### 📊 MaterialAnalyticsView (Estadísticas de Material)

**Acceso:** Desde ContentManageView → Tap en material → "Estadísticas"

**Contenido:**
```
MaterialAnalyticsView
├── Header
│   ├── Título del material
│   ├── Tipo
│   └── Fecha de publicación
│
├── Métricas Principales (Cards)
│   ├── Vistas Totales
│   ├── Descargas
│   ├── Completados
│   └── Tiempo Promedio de Lectura
│
├── Gráficas
│   ├── Vistas por día (últimos 30 días)
│   ├── Distribución de calificaciones de quizzes
│   └── Engagement rate
│
├── Top Estudiantes
│   └── Lista de estudiantes que más interactuaron
│       ├── Nombre
│       ├── Tiempo de lectura
│       ├── Calificación de quiz
│       └── Fecha de acceso
│
└── Resumen de Quizzes
    ├── Promedio general
    ├── Preguntas más difíciles
    └── Preguntas más fáciles
```

---

### 📈 CourseAnalyticsView (Estadísticas de Curso)

**Acceso:** Desde TeacherCourseDetail → Tab "Analytics"

**Contenido:**
```
CourseAnalyticsView
├── Resumen General (Cards)
│   ├── Total de estudiantes
│   ├── Promedio de progreso
│   ├── Engagement rate
│   ├── Materiales subidos
│   └── Quizzes realizados
│
├── Gráfica de Progreso
│   └── Bar chart: Distribución de estudiantes por nivel de progreso
│       ├── 0-25%
│       ├── 26-50%
│       ├── 51-75%
│       └── 76-100%
│
├── Timeline de Actividad
│   └── Line chart: Actividad de estudiantes últimos 30 días
│
├── Materiales Más Populares
│   └── Lista ordenada por vistas
│       ├── Título
│       ├── Vistas
│       ├── Descargas
│       └── Promedio de quiz
│
├── Estudiantes Destacados
│   └── Top 10 por progreso
│
└── Estudiantes En Riesgo
    └── Lista de estudiantes con:
        ├── Progreso < 30%
        ├── Sin actividad > 7 días
        └── Promedio de quizzes < 60%
```

---

## Flujos Específicos

### 📤 Flujo Completo de Subida de Material

```
[Inicio]
  ↓
[ContentManageView] → Tap "Subir Material"
  ↓
[UploadMaterialView (Sheet)]
  ↓
[Docente llena formulario]
  - Título: "Introducción a la Programación"
  - Descripción: "Conceptos básicos de programación..."
  - Tipo: PDF
  - Archivo: selecciona "intro-programacion.pdf" (5 MB)
  - Curso: "Fundamentos de Programación"
  - Visibilidad: Público
  - Tags: "programación, introducción, conceptos"
  ↓
[Tap "Subir Material"]
  ↓
[UploadMaterialUseCase]
  ↓
[1. Sube archivo a S3 / Cloud Storage]
  ↓ (muestra progress bar)
[2. Guarda metadata en PostgreSQL]
  ↓
[3. Llama a Worker para procesar]
  ↓ (muestra "Procesando...")
[Worker en background]
  ↓
[4. Worker extrae texto del PDF]
  ↓
[5. Worker llama a OpenAI para generar resumen]
  ↓
[6. Worker guarda resumen en MongoDB]
  ↓
[7. Worker llama a OpenAI para generar quiz]
  ↓
[8. Worker guarda quiz en MongoDB]
  ↓
[9. Worker publica evento "material_processed"]
  ↓
[App recibe notificación push]
  ↓
[Muestra toast: "Material procesado y disponible para estudiantes"]
  ↓
[ContentManageView se actualiza]
  ↓
[Material aparece en lista con badge "Nuevo"]
```

**Persistencia:**
- Archivo PDF → S3/Cloud Storage
- Metadata del material → `materials` (PostgreSQL)
- Resumen generado → `material_summary` (MongoDB)
- Quiz generado → `material_assessment` (MongoDB)
- Evento de procesamiento → `material_event` (MongoDB)

---

### 📋 Flujo de Revisión de Progreso de Estudiante

```
[Inicio]
  ↓
[StudentsView] → Lista de estudiantes
  ↓
[Tap en "Juan Pérez"]
  ↓
[StudentDetailView]
  ↓
[Tab "Courses Progress"]
  ↓
[Lista de cursos en común]
  - Matemáticas I: 85% progreso
  - Física I: 62% progreso
  - Historia: 45% progreso ⚠️
  ↓
[Tap en "Historia" (bajo progreso)]
  ↓
[StudentCourseProgressView]
  ├── Header
  │   ├── Nombre del curso
  │   ├── Progreso general (45%)
  │   └── Última actividad (hace 5 días) ⚠️
  │
  ├── Materiales del Curso
  │   └── Lista con estado:
  │       ✅ Material 1: Completado (quiz: 90%)
  │       ✅ Material 2: Completado (quiz: 75%)
  │       ⏳ Material 3: En progreso
  │       ⬜ Material 4: No iniciado
  │       ⬜ Material 5: No iniciado
  │
  ├── Gráfica de Actividad
  │   └── Timeline de últimas 4 semanas
  │       └── Muestra días sin actividad ⚠️
  │
  └── Acciones del Docente
      ├── Enviar recordatorio
      ├── Programar reunión
      └── Enviar material adicional
  ↓
[Tap "Enviar recordatorio"]
  ↓
[MessageComposeView (Sheet)]
  - Pre-llena mensaje:
    "Hola Juan, noté que no has avanzado en el curso
     de Historia últimamente. ¿Hay algo en lo que pueda
     ayudarte?"
  ↓
[Tap "Enviar"]
  ↓
[Envía notificación push a Juan]
  ↓
[Success toast: "Recordatorio enviado"]
```

---

### 📊 Flujo de Análisis de Material

```
[Inicio]
  ↓
[ContentManageView] → Lista de materiales
  ↓
[Tap en material → Menú → "Estadísticas"]
  ↓
[MaterialAnalyticsView]
  ↓
[Muestra métricas]
  - 234 vistas
  - 89 descargas
  - 67 estudiantes completaron
  - Tiempo promedio de lectura: 15 min
  - Promedio de quiz: 72%
  ↓
[Scroll a "Preguntas más difíciles"]
  ↓
[Pregunta 5: Solo 30% de estudiantes acertaron]
  ↓
[Análisis del docente]
  - "Esta pregunta parece muy difícil"
  - "Quizá debo crear material adicional sobre este tema"
  ↓
[Tap "Volver"]
  ↓
[ContentManageView]
  ↓
[Tap "Subir Material"]
  ↓
[Crea material de refuerzo sobre el tema difícil]
```

---

## Deep Links

### Deep Links Exclusivos del Docente

```
edugo://
├── teacher/
│   ├── dashboard
│   ├── students
│   │   └── {studentId}
│   │       └── progress
│   │           └── {courseId}
│   ├── content
│   │   ├── upload
│   │   └── {materialId}
│   │       ├── edit
│   │       └── analytics
│   └── courses
│       └── {courseId}
│           ├── students
│           ├── analytics
│           └── settings
```

### Ejemplos

```swift
// Ver estudiante específico
edugo://teacher/students/550e8400-e29b-41d4-a716-446655440001

// Ver progreso de estudiante en curso
edugo://teacher/students/550e8400-e29b-41d4-a716-446655440001/progress/123e4567-e89b-12d3-a456-426614174000

// Editar material
edugo://teacher/content/123e4567-e89b-12d3-a456-426614174001/edit

// Ver estadísticas de material
edugo://teacher/content/123e4567-e89b-12d3-a456-426614174001/analytics

// Ver estudiantes de un curso
edugo://teacher/courses/123e4567-e89b-12d3-a456-426614174000/students

// Ver analíticas de un curso
edugo://teacher/courses/123e4567-e89b-12d3-a456-426614174000/analytics
```

---

## Permisos y Capacidades

### Matriz de Permisos

| Acción | Estudiante | Docente | Admin |
|--------|-----------|---------|-------|
| Ver materiales | Solo asignados | Todos sus cursos | Todos |
| Subir materiales | ❌ | ✅ | ✅ |
| Editar materiales | ❌ | Solo propios | Todos |
| Eliminar materiales | ❌ | Solo propios | Todos |
| Ver progreso propio | ✅ | ✅ | ✅ |
| Ver progreso de otros | ❌ | Solo sus estudiantes | Todos |
| Gestionar cursos | ❌ | Solo donde es docente | Todos |
| Crear cursos | ❌ | ❌ | ✅ |
| Gestionar usuarios | ❌ | ❌ | ✅ |
| Ver estadísticas curso | ❌ | Solo sus cursos | Todos |
| Enviar mensajes | Solo a docentes | A sus estudiantes | Todos |

### Validación de Permisos en UI

```swift
// En ContentManageView
var canUploadContent: Bool {
    authState.currentUser?.role == .teacher || 
    authState.currentUser?.role == .admin
}

// En StudentDetailView
var canViewStudentProgress: Bool {
    guard let currentUser = authState.currentUser else { return false }
    
    switch currentUser.role {
    case .teacher:
        // Solo si es docente del estudiante
        return student.courses.contains { course in
            course.teachers.contains { $0.id == currentUser.id }
        }
    case .admin:
        return true
    default:
        return false
    }
}

// En MaterialEditView
var canEditMaterial: Bool {
    guard let currentUser = authState.currentUser else { return false }
    
    switch currentUser.role {
    case .teacher:
        // Solo si es el creador del material
        return material.createdBy == currentUser.id
    case .admin:
        return true
    default:
        return false
    }
}
```

---

## Notificaciones Push Exclusivas

El docente recibe notificaciones adicionales:

```swift
enum TeacherNotification {
    // Material procesado
    case materialProcessed(materialId: UUID, title: String)
    
    // Estudiante completó material
    case studentCompletedMaterial(studentName: String, materialTitle: String)
    
    // Estudiante realizó quiz
    case studentCompletedQuiz(studentName: String, materialTitle: String, score: Int)
    
    // Estudiante en riesgo (sin actividad > 7 días)
    case studentAtRisk(studentName: String, courseName: String, daysInactive: Int)
    
    // Nuevo estudiante inscrito
    case newStudentEnrolled(studentName: String, courseName: String)
    
    // Pregunta en foro sin responder
    case unansweredQuestion(studentName: String, courseName: String, questionPreview: String)
}
```

**Navegación desde Notificación:**
```
Tap en notificación: "Juan completó quiz de Matemáticas (85%)"
  ↓
App abre
  ↓
Deep link: edugo://teacher/students/{juanId}/progress/{matematicasId}
  ↓
Navega a StudentCourseProgressView
  ↓
Muestra detalle del progreso de Juan en Matemáticas
```

---

## Consideraciones de UX

### 1. Feedback Visual para Acciones del Docente

- **Material subido:** Toast con confirmación + badge "Nuevo" en lista
- **Material procesado:** Push notification + badge "Listo"
- **Estudiante en riesgo:** Badge rojo en StudentCard
- **Nuevo comentario en foro:** Badge de notificación

### 2. Indicadores de Estado

- **Material en procesamiento:** Spinner + "Procesando resumen y quiz..."
- **Sincronización:** Icono de sync en toolbar
- **Cambios pendientes:** Badge en Settings

### 3. Acciones Rápidas (iPad/Mac)

**Keyboard Shortcuts:**
```
CMD + N : Nuevo material
CMD + U : Subir archivo
CMD + S : Ver estudiantes
CMD + A : Ver analíticas
CMD + 1/2/3... : Cambiar entre tabs
```

**Right-Click Menu en MaterialCard:**
```
- Ver
- Editar
- Duplicar
- Estadísticas
- Compartir link
- Eliminar
```

---

## Próximos Pasos

1. **Calificaciones Manuales:** Permitir al docente calificar manualmente tareas
2. **Foros de Discusión:** Moderación de foros por el docente
3. **Notificaciones Masivas:** Enviar notificación a todos los estudiantes de un curso
4. **Exportación de Datos:** Exportar calificaciones a Excel/PDF
5. **Integración con LMS:** Sincronización con plataformas existentes (Moodle, Canvas, etc.)

---

**Documentos Relacionados:**
- [FLUJO-ESTUDIANTE.md](./FLUJO-ESTUDIANTE.md)
- [FLUJO-ADMIN.md](./FLUJO-ADMIN.md)
- [NAVEGACION-PLATAFORMA.md](./NAVEGACION-PLATAFORMA.md)
