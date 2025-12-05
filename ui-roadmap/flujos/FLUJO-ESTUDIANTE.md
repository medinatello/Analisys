# Flujo de Navegación - Estudiante

**Fecha:** 1 de Diciembre, 2025  
**Rol:** `student`  
**Plataformas:** iOS, iPadOS, macOS, visionOS

---

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Diagrama de Flujo Principal](#diagrama-de-flujo-principal)
3. [Estados de Navegación](#estados-de-navegación)
4. [Pantallas Principales](#pantallas-principales)
5. [Flujos Específicos](#flujos-específicos)
6. [Deep Links](#deep-links)
7. [Navegación Back](#navegación-back)
8. [Gestión de Estado](#gestión-de-estado)

---

## Descripción General

El flujo de navegación del estudiante está diseñado para facilitar el acceso rápido a materiales de estudio, seguimiento de progreso y participación en la comunidad educativa.

### Características Principales

- **Acceso a Cursos:** Visualización de cursos inscritos y disponibles
- **Materiales de Estudio:** Lectura de PDFs, resúmenes generados por IA
- **Evaluaciones:** Quizzes automáticos generados a partir de materiales
- **Progreso Personal:** Estadísticas de avance y rendimiento
- **Calendario:** Planificación de actividades académicas
- **Comunidad:** Interacción con compañeros y profesores

### Capacidades por Rol

```swift
// Permisos del estudiante (desde UserRole.swift)
- canViewAllContent: false          // Solo contenido asignado
- canEditContent: false             // Sin permisos de edición
- canManageUsers: false             // Sin gestión de usuarios
- canAccessAdminPanel: false        // Sin panel administrativo
```

---

## Diagrama de Flujo Principal

```
┌─────────────────────────────────────────────────────────────────┐
│                      INICIO DE SESIÓN                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │  [SplashScreen] │
                    │  Verifica sesión │
                    └─────────────────┘
                              ↓
                    ┌─────────────────┐
                    │   ¿Autenticado? │
                    └─────────────────┘
                      ↙               ↘
              NO ↙                       ↘ SÍ
                ↙                           ↘
    ┌─────────────────┐           ┌──────────────────┐
    │   [LoginView]   │           │   [HomeView]     │
    │  (Fullscreen)   │           │  (TabView/Split) │
    └─────────────────┘           └──────────────────┘
              ↓                              ↓
        [Autenticación]            ┌─────────────────┐
              ↓                    │  NAVEGACIÓN      │
              └──────────────────→ │  PRINCIPAL       │
                                   └─────────────────┘
                                            ↓
    ┌───────────┬──────────┬──────────┬───────────┬──────────┐
    ↓           ↓          ↓          ↓           ↓          ↓
┌────────┐ ┌────────┐ ┌────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐
│  HOME  │ │COURSES │ │CALENDAR│ │PROGRESS │ │COMMUNITY│ │ SETTINGS │
└────────┘ └────────┘ └────────┘ └─────────┘ └─────────┘ └──────────┘
    ↓           ↓
    │           └──→ [CourseDetail]
    │                       ↓
    │                [MaterialsList]
    │                       ↓
    │                [MaterialDetail]
    │                       ↓
    │              ┌────────┴────────┐
    │              ↓                 ↓
    │        [PDFReader]      [VideoPlayer]
    │              ↓                 ↓
    │        [AISummary]       [Notes]
    │              ↓
    │        [QuizView]
    │              ↓
    │        [QuizResults]
    │              ↓
    └──────→ [Progress Update]
```

---

## Estados de Navegación

### 1. Estado de Autenticación

```swift
@Observable
class AuthenticationState {
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }
    
    // Transiciones:
    // unauthenticated → authenticated (login success)
    // authenticated → unauthenticated (logout/token expired)
}
```

**Estados:**
- `unauthenticated`: Muestra `LoginView` (fullscreen, sin sidebar)
- `checkingSession`: Muestra `SplashScreen` (verificando token guardado)
- `authenticated`: Muestra `AuthenticatedApp` (navegación completa)

### 2. Estado de Navegación Principal

```swift
enum Route: Hashable, Sendable {
    case login      // Login (no autenticado)
    case home       // Inicio (dashboard)
    case courses    // Mis cursos
    case calendar   // Calendario académico
    case progress   // Mi progreso
    case community  // Comunidad
    case settings   // Configuración
}
```

### 3. Estado de Navegación Profunda

```
Route.courses
  → CourseDetail(courseId: UUID)
    → MaterialsList
      → MaterialDetail(materialId: UUID)
        → PDFReaderView(url: URL)
          → SummaryView(materialId: UUID)
            → QuizView(materialId: UUID)
              → QuizResultsView(score: Int, total: Int)
```

---

## Pantallas Principales

### 🏠 Home

**Ruta:** `.home`  
**Layout:** Diferenciado por plataforma (HomeView / IPadHomeView / VisionOSHomeView)

**Contenido:**
- **Bienvenida:** Saludo personalizado con nombre del usuario
- **Actividad Reciente:** Últimos materiales accedidos
- **Estadísticas Rápidas:** Cursos activos, materiales completados, tiempo de estudio
- **Cursos Recientes:** Cards de últimos 3-5 cursos accedidos
- **Acciones Rápidas:** Botones de acceso directo

**Casos de Uso:**
```swift
GetCurrentUserUseCase          // Obtener datos del usuario
GetRecentActivityUseCase       // Actividad reciente
GetUserStatsUseCase            // Estadísticas generales
GetRecentCoursesUseCase        // Cursos recientes
```

**Navegación Desde Home:**
```
Home → Course Detail (tap en curso reciente)
Home → Material Detail (tap en material reciente)
Home → Progress (tap en estadística)
```

---

### 📚 Courses (Cursos)

**Ruta:** `.courses`  
**Layout:** CoursesView / IPadCoursesView / VisionOSCoursesView

**Contenido:**
- **Lista de Cursos:** Cursos en los que está inscrito el estudiante
- **Filtros:** Por materia, nivel, progreso
- **Búsqueda:** Buscar cursos por nombre
- **Vista de Card:** Imagen, título, profesor, progreso

**Navegación:**
```
Courses
  ↓ (tap en curso)
CourseDetail
  - Información del curso
  - Lista de materiales
  - Profesores
  - Estadísticas del curso
  ↓ (tap en material)
MaterialDetail
  - Título y descripción
  - Tipo de material (PDF, video, etc.)
  - Acciones: Ver, Descargar, Compartir
  ↓ (tap en "Ver Material")
┌──────────────────────┐
│  Si tipo == PDF      │ → PDFReaderView
│  Si tipo == Video    │ → VideoPlayerView
│  Si tipo == Link     │ → WebView
└──────────────────────┘
```

**Flujo de Lectura de Material:**

```
PDFReaderView
  - Visor de PDF nativo
  - Controles: zoom, página, bookmark
  - Botón "Ver Resumen" (si está disponible)
  ↓ (tap en "Ver Resumen")
SummaryView
  - Resumen generado por IA (MongoDB)
  - Puntos clave
  - Botón "Tomar Quiz"
  ↓ (tap en "Tomar Quiz")
QuizView
  - Preguntas generadas por IA
  - Respuestas múltiples
  - Timer (opcional)
  - Progreso (pregunta 1/10)
  ↓ (submit quiz)
QuizResultsView
  - Puntaje obtenido
  - Respuestas correctas/incorrectas
  - Feedback por pregunta
  - Botón "Ver Resumen de Nuevo"
  - Botón "Volver al Material"
```

---

### 📅 Calendar (Calendario)

**Ruta:** `.calendar`  
**Layout:** CalendarView / IPadCalendarView / VisionOSCalendarView

**Contenido:**
- **Vista de Calendario:** Mes, semana, día
- **Eventos Académicos:** Clases, exámenes, entregas
- **Recordatorios:** Notificaciones de próximas actividades
- **Integración:** Sincronización con calendario del sistema

**Navegación:**
```
Calendar
  ↓ (tap en evento)
EventDetail
  - Título del evento
  - Fecha y hora
  - Descripción
  - Curso relacionado
  - Material relacionado
  ↓ (tap en material relacionado)
MaterialDetail
```

---

### 📊 Progress (Progreso)

**Ruta:** `.progress`  
**Layout:** UserProgressView / IPadProgressView / VisionOSProgressView

**Contenido:**
- **Resumen General:** Total de cursos, materiales completados, quizzes realizados
- **Gráficas de Progreso:** Por curso, por materia, por semana
- **Historial de Actividad:** Timeline de acciones recientes
- **Logros:** Badges y metas alcanzadas
- **Comparativa:** Rendimiento vs promedio de clase (opcional)

**Navegación:**
```
Progress
  ↓ (tap en curso en gráfica)
CourseProgressDetail
  - Progreso específico del curso
  - Materiales completados vs pendientes
  - Promedio de quizzes
  ↓ (tap en material)
MaterialDetail
```

---

### 👥 Community (Comunidad)

**Ruta:** `.community`  
**Layout:** CommunityView / IPadCommunityView / VisionOSCommunityView

**Contenido:**
- **Feed Social:** Publicaciones de compañeros y profesores
- **Grupos de Estudio:** Grupos por curso o materia
- **Mensajería:** Chat con compañeros
- **Foros de Discusión:** Preguntas y respuestas

**Navegación:**
```
Community
  ↓ (tap en publicación)
PostDetail
  - Contenido completo
  - Comentarios
  - Likes
  ↓ (tap en usuario)
UserProfile
  - Información del usuario
  - Cursos en común
```

---

### ⚙️ Settings (Configuración)

**Ruta:** `.settings`

**Contenido:**
- **Perfil:** Editar nombre, foto, email
- **Notificaciones:** Preferencias de notificaciones
- **Privacidad:** Configuración de privacidad
- **Tema:** Claro, oscuro, automático
- **Idioma:** Selección de idioma
- **Acerca de:** Versión de la app, términos, privacidad
- **Cerrar Sesión:** Logout

**Navegación:**
```
Settings
  ↓ (tap en "Editar Perfil")
ProfileEdit
  - Formulario de edición
  ↓ (tap en "Cerrar Sesión")
Logout → LoginView
```

---

## Flujos Específicos

### 📖 Flujo Completo de Estudio

```
[Inicio]
  ↓
[Home] → Ver "Materiales Recientes"
  ↓
[MaterialDetail] → Tap "Abrir Material"
  ↓
[PDFReaderView]
  - Usuario lee el PDF
  - Hace zoom, navega páginas
  - Marca como leído (al finalizar)
  ↓
[PDFReaderView] → Tap "Ver Resumen IA"
  ↓
[SummaryView]
  - Muestra resumen generado por OpenAI
  - Puntos clave del material
  ↓
[SummaryView] → Tap "Tomar Quiz"
  ↓
[QuizView]
  - 10 preguntas generadas por IA
  - Usuario responde cada pregunta
  - Timer de 30 segundos por pregunta (opcional)
  ↓
[QuizView] → Tap "Finalizar Quiz"
  ↓
[QuizResultsView]
  - Puntaje: 8/10 (80%)
  - Muestra respuestas correctas/incorrectas
  - Feedback por pregunta
  ↓
[QuizResultsView] → Guarda resultado en PostgreSQL
  ↓
[Progress] → Actualiza automáticamente
  - Incrementa "Materiales Completados"
  - Actualiza promedio de quizzes
  - Añade actividad al timeline
```

**Persistencia de Estado:**
- Material leído → `material_progress` (PostgreSQL)
- Resultado de quiz → `quiz_results` (PostgreSQL)
- Resumen generado → `material_summary` (MongoDB)
- Evento de actividad → `material_event` (MongoDB)

---

### 🔎 Flujo de Búsqueda

```
[Cualquier Pantalla]
  ↓
[Tap en Search Bar / CMD+F (macOS)]
  ↓
[SearchView]
  - Buscar cursos
  - Buscar materiales
  - Buscar usuarios
  ↓
[Resultados de Búsqueda]
  ↓ (tap en resultado)
┌──────────────────────┐
│ Si es Curso          │ → CourseDetail
│ Si es Material       │ → MaterialDetail
│ Si es Usuario        │ → UserProfile
└──────────────────────┘
```

---

### 📥 Flujo de Descarga Offline

```
[MaterialDetail]
  ↓
[Tap en "Descargar para Offline"]
  ↓
[DownloadManager]
  - Descarga el PDF
  - Descarga el resumen (si existe)
  - Descarga el quiz (si existe)
  - Guarda en local storage
  ↓
[MaterialDetail] → Muestra ícono "Descargado"
  ↓
[Sin Internet]
  ↓
[PDFReaderView] → Carga desde local
[SummaryView] → Carga desde local
[QuizView] → Carga desde local
  ↓
[Resultados se sincronizan cuando hay internet]
```

---

## Deep Links

La app soporta deep links para navegación directa desde notificaciones, emails, etc.

### Esquema de Deep Links

```
edugo://
├── login
├── home
├── courses
│   └── {courseId}
│       └── materials
│           └── {materialId}
│               ├── pdf
│               ├── summary
│               └── quiz
├── calendar
│   └── event/{eventId}
├── progress
├── community
│   ├── post/{postId}
│   └── user/{userId}
└── settings
    └── profile
```

### Ejemplos de Deep Links

```swift
// Abrir curso específico
edugo://courses/550e8400-e29b-41d4-a716-446655440000

// Abrir material y mostrar PDF
edugo://courses/550e8400-e29b-41d4-a716-446655440000/materials/123e4567-e89b-12d3-a456-426614174000/pdf

// Abrir resumen de un material
edugo://courses/550e8400-e29b-41d4-a716-446655440000/materials/123e4567-e89b-12d3-a456-426614174000/summary

// Abrir quiz de un material
edugo://courses/550e8400-e29b-41d4-a716-446655440000/materials/123e4567-e89b-12d3-a456-426614174000/quiz

// Ver perfil de usuario
edugo://community/user/550e8400-e29b-41d4-a716-446655440001
```

### Manejo de Deep Links

```swift
// En AdaptiveNavigationView o NavigationCoordinator
func handleDeepLink(_ url: URL) {
    guard url.scheme == "edugo" else { return }
    
    let path = url.pathComponents
    
    switch path {
    case ["courses", let courseId]:
        navigateToCourse(id: UUID(uuidString: courseId))
    
    case ["courses", let courseId, "materials", let materialId, "pdf"]:
        navigateToMaterial(courseId: courseId, materialId: materialId, view: .pdf)
    
    case ["courses", let courseId, "materials", let materialId, "summary"]:
        navigateToMaterial(courseId: courseId, materialId: materialId, view: .summary)
    
    // ... más casos
    }
}
```

---

## Navegación Back

### Gestos y Controles

**iPhone:**
- **Swipe desde borde izquierdo:** Retrocede una pantalla
- **Botón Back (<):** En navigation bar
- **TabBar:** Cambio directo entre tabs (resetea stack del tab)

**iPad:**
- **Swipe desde borde izquierdo:** Retrocede en detail view
- **Botón Back (<):** En navigation bar
- **Sidebar:** Navegación directa (no agrega al stack)
- **Split View:** Mantiene contexto en sidebar

**macOS:**
- **Botón Back (<):** En navigation bar
- **CMD+[ o CMD+]:** Navegar atrás/adelante
- **Sidebar:** Navegación directa
- **Múltiples Ventanas:** Cada ventana tiene su propio stack

**visionOS:**
- **Gesto de retroceso:** Gesto espacial hacia atrás
- **Botón Back:** En controles de ventana

### Stack de Navegación

```swift
// NavigationCoordinator gestiona el stack
@Observable
class NavigationCoordinator {
    var path = NavigationPath()
    
    func push<T: Hashable>(_ value: T) {
        path.append(value)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}
```

**Comportamiento:**
```
Home (root)
  → push(CourseDetail)
    → push(MaterialDetail)
      → push(PDFReader)
        → Back → MaterialDetail
        → Back → CourseDetail
        → Back → Home

TabBar tap → popToRoot() del tab actual
```

---

## Gestión de Estado

### Estado Global de Autenticación

```swift
@Observable
@MainActor
final class AuthenticationState {
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }
    
    func authenticate(user: User) {
        currentUser = user
    }
    
    func logout() {
        currentUser = nil
    }
}
```

**Flujo de Verificación de Sesión:**
```
App Launch
  ↓
AdaptiveNavigationView.onAppear
  ↓
checkInitialSession()
  ↓
AuthRepository.hasActiveSession()
  ↓
┌──────────────────────┐
│ ¿Hay token guardado? │
└──────────────────────┘
  ↙               ↘
NO                   SÍ
  ↓                   ↓
Logout          getCurrentUser()
  ↓                   ↓
LoginView       ┌────────────┐
                │ ¿Válido?   │
                └────────────┘
                  ↙       ↘
               SÍ          NO
                ↓           ↓
         authenticate()  logout()
                ↓           ↓
         AuthenticatedApp  LoginView
```

### Estado de Navegación

```swift
// En AuthenticatedApp
@State private var selectedRoute: Route = .home
@State private var columnVisibility: NavigationSplitViewVisibility = .automatic

// Persistencia de ruta seleccionada (opcional)
@AppStorage("lastSelectedRoute") private var lastRoute: String = "home"
```

### Estado de Sincronización

```swift
// Para indicar sincronización con backend
@Observable
class SyncState {
    var isSyncing: Bool = false
    var lastSyncDate: Date?
    var pendingChanges: Int = 0
}
```

---

## Transiciones y Animaciones

### Transiciones Estándar

```swift
// Push/Pop con animación slide
.navigationTransition(.slide)

// Modal presentation
.sheet(isPresented: $showingMaterial) {
    MaterialDetailView(material: material)
}

// Full screen cover (para login, onboarding)
.fullScreenCover(isPresented: $showingLogin) {
    LoginView()
}
```

### Animaciones por Plataforma

**iOS:**
- Tab change: Fade + slight scale
- Push: Slide from right
- Pop: Slide to right
- Modal: Slide from bottom

**iPadOS:**
- Sidebar selection: Fade detail view
- Push: Slide from right (en detail)
- Modal: Form sheet o full screen

**macOS:**
- Sidebar selection: Immediate change
- Push: Instant (sin animación slide)
- Window open: Fade in

**visionOS:**
- Window groups: Fade + depth
- Spatial navigation: 3D transitions

---

## Consideraciones de UX

### 1. Indicadores de Estado

- **Loading:** Skeleton views mientras carga contenido
- **Empty State:** Mensajes claros cuando no hay datos
- **Error State:** Mensajes de error con acción de retry
- **Offline Mode:** Indicador visual de modo offline

### 2. Feedback Visual

- **Tap:** Reducción de opacidad al tocar
- **Swipe:** Seguimiento del dedo en gestos
- **Pull to Refresh:** Indicador de recarga
- **Toast/Snackbar:** Confirmaciones de acciones

### 3. Accesibilidad

- **VoiceOver:** Etiquetas descriptivas en todos los elementos
- **Dynamic Type:** Soporte para tamaños de fuente personalizados
- **Color Contrast:** Cumple WCAG AA
- **Keyboard Navigation:** Soporte completo en macOS

### 4. Persistencia

- **Tab seleccionado:** Se mantiene entre sesiones
- **Scroll position:** Se restaura al volver a una pantalla
- **Filtros y búsquedas:** Se mantienen durante la sesión
- **Progreso de lectura:** Se guarda automáticamente

---

## Casos Edge

### 1. Sesión Expirada durante Navegación

```
Usuario en MaterialDetail
  ↓
Token expira
  ↓
Próxima llamada API → 401 Unauthorized
  ↓
AuthRepository detecta token expirado
  ↓
authState.logout()
  ↓
App muestra LoginView (fullscreen)
  ↓
Usuario hace login de nuevo
  ↓
App muestra Home (NO restaura navegación previa)
```

### 2. Sin Internet durante Lectura

```
Usuario abre PDFReaderView
  ↓
PDF ya descargado → Carga desde local
  ↓
Tap "Ver Resumen"
  ↓
Resumen ya descargado → Carga desde local
  ↓
Tap "Tomar Quiz"
  ↓
Quiz cargado desde local
  ↓
Finaliza quiz → Guarda resultado en local
  ↓
[Cuando vuelve internet]
  ↓
NetworkSyncCoordinator.sync()
  ↓
Envía resultado al backend
```

### 3. Deep Link con Usuario No Autenticado

```
Tap en deep link: edugo://courses/123/materials/456
  ↓
App abre
  ↓
AuthenticationState.isAuthenticated == false
  ↓
Muestra LoginView
  ↓
Guarda deep link pendiente
  ↓
Usuario hace login
  ↓
Navega automáticamente al deep link guardado
```

---

## Próximos Pasos

1. **Implementar Deep Links:** Sistema completo de URL routing
2. **Offline Mode:** Sincronización automática de materiales
3. **Push Notifications:** Navegación desde notificaciones
4. **Widgets:** Acceso rápido desde home screen
5. **Shortcuts:** Siri Shortcuts para acciones comunes

---

**Documentos Relacionados:**
- [FLUJO-DOCENTE.md](./FLUJO-DOCENTE.md)
- [FLUJO-ADMIN.md](./FLUJO-ADMIN.md)
- [NAVEGACION-PLATAFORMA.md](./NAVEGACION-PLATAFORMA.md)
- [/Users/jhoanmedina/source/EduGo/EduUI/apple-app/docs/guides/architecture-patterns.md](../../../../../../EduUI/apple-app/docs/guides/architecture-patterns.md)
