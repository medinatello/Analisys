# Análisis de Pantallas Existentes - App Apple EduGo

**Fecha de Análisis:** 1 de Diciembre, 2025  
**Ubicación del Código:** `/Users/jhoanmedina/source/EduGo/EduUI/apple-app`  
**Paquete Principal:** `Packages/EduGoFeatures/Sources/EduGoFeatures/`

---

## 📋 Resumen Ejecutivo

### Estado General

La aplicación Apple (iOS/iPadOS/macOS/visionOS) tiene **8 pantallas principales** en diferentes estados de implementación:

| Pantalla | Estado | Implementaciones | Prioridad Mejora |
|----------|--------|------------------|------------------|
| **Splash** | ✅ Completa | iOS/iPad/macOS/visionOS (unificada) | 🟢 Baja |
| **Login** | ✅ Completa | iOS/iPad/macOS/visionOS (unificada) | 🟢 Baja |
| **Home** | 🟡 Semi-dummy | iOS, iPad (fragmentadas), VisionOS | 🔴 Alta |
| **Settings** | 🟡 Semi-completa | iOS, iPad, macOS (fragmentadas) | 🟡 Media |
| **Progress** | 🔴 Placeholder | iOS, iPad, VisionOS (placeholders) | 🔴 Alta |
| **Courses** | 🔴 Placeholder | iOS, iPad, VisionOS (placeholders) | 🔴 Alta |
| **Calendar** | 🔴 Placeholder | iOS, iPad, VisionOS (placeholders) | 🟡 Media |
| **Community** | 🔴 Placeholder | iOS, iPad, VisionOS (placeholders) | 🟡 Media |

### Fragmentación Detectada

- **3 versiones de Home**: `HomeView.swift`, `IPadHomeView.swift`, `VisionOSHomeView.swift`
- **4 versiones de Settings**: `SettingsView.swift`, `IPadSettingsView.swift`, `MacOSSettingsView.swift` (presumible)
- **Código duplicado** entre versiones iOS/iPad/visionOS
- **Falta de unificación** con layout adaptativo

---

## 1️⃣ Pantalla: Splash

### ✅ Estado Actual

**Ubicación:** `Packages/EduGoFeatures/Sources/EduGoFeatures/Splash/`

**Archivos:**
- `SplashView.swift` (vista unificada)
- `SplashViewModel.swift` (lógica)

**Plataformas:** iOS, iPadOS, macOS, visionOS (**UNIFICADA** ✅)

### Implementación Actual

```swift
// Vista unificada para todas las plataformas
public struct SplashView: View {
    @State private var viewModel: SplashViewModel
    @Environment(NavigationCoordinator.self) private var coordinator
    
    // Gradient background + Logo + ProgressView
    // Verifica sesión automáticamente con .task
}
```

**Componentes usados:**
- ✅ `DSColors` (Design System)
- ✅ `DSTypography`
- ✅ `DSSpacing`
- ✅ `.dsGlassEffect()` (efectos visuales)
- ✅ `NavigationCoordinator` (navegación)

### Flujo Actual

1. **Muestra splash** por 1 segundo
2. **Verifica sesión** con `authRepository.hasActiveSession()`
3. **Navega automáticamente:**
   - Si hay sesión válida → **Home**
   - Si no hay sesión → **Login**

### Endpoints Consumidos

- ✅ `authRepository.hasActiveSession()` (local, no API)
- ✅ `authRepository.getCurrentUser()` (validación remota)

### Estados Manejados

- ✅ **Loading:** ProgressView visible
- ❌ **Error:** No maneja error (solo redirige a login)
- ❌ **Empty:** N/A

### 🎯 Mejoras Requeridas

#### Prioridad: 🟢 Baja

1. **Manejo de errores:**
   - Mostrar mensaje si falla verificación de sesión
   - Opción de reintentar

2. **Timeout:**
   - Agregar timeout para evitar splash infinito

3. **Animaciones:**
   - Agregar animación de entrada/salida del logo

### Especificación UI Mejorada

**NO REQUIERE CAMBIOS MAYORES** - La implementación actual es sólida y unificada.

**Posibles mejoras menores:**
- Agregar animación de fade-in del logo
- Mostrar versión de la app en modo DEBUG
- Agregar indicador visual de conexión

---

## 2️⃣ Pantalla: Login

### ✅ Estado Actual

**Ubicación:** `Packages/EduGoFeatures/Sources/EduGoFeatures/Login/`

**Archivos:**
- `LoginView.swift` (vista unificada)
- `LoginViewModel.swift` (lógica)

**Plataformas:** iOS, iPadOS, macOS, visionOS (**UNIFICADA** ✅)

### Implementación Actual

```swift
public struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var viewModel: LoginViewModel
    @Environment(AuthenticationState.self) private var authState
    
    // Usa DSLoginView del Design System
    // Overlay de loading cuando isLoading = true
    // Alert para errores
}
```

**Componentes usados:**
- ✅ `DSLoginView` (componente completo del DS)
- ✅ `DSColors`, `DSTypography`, `DSSpacing`
- ✅ Validación de estados (idle, loading, success, error)

### Flujo Actual

1. **Formulario de login** (email + password)
2. **Opción biométrica** (Face ID / Touch ID) si disponible
3. **Submit:**
   - Ejecuta `loginUseCase.execute()`
   - Muestra loading overlay
4. **Success:**
   - Actualiza `AuthenticationState`
   - NavigationCoordinator redirige a Home
5. **Error:**
   - Muestra alert con mensaje

### Endpoints Consumidos

- ✅ `POST /v1/auth/login` (via LoginUseCase)
- ✅ Biometría local (keychain + Face ID/Touch ID)

### Estados Manejados

- ✅ **Idle:** Formulario en reposo
- ✅ **Loading:** Overlay + ProgressView
- ✅ **Success:** Navegación automática
- ✅ **Error:** Alert con mensaje

### Validaciones

- ❌ **Email:** No valida formato antes de enviar
- ❌ **Password:** No valida longitud mínima
- ❌ **Rate limiting:** No maneja intentos fallidos repetidos

### 🎯 Mejoras Requeridas

#### Prioridad: 🟢 Baja

1. **Validaciones en tiempo real:**
   ```swift
   // Agregar validación de email antes de submit
   var isEmailValid: Bool {
       email.contains("@") && email.contains(".")
   }
   
   // Validar password (min 6 caracteres)
   var isPasswordValid: Bool {
       password.count >= 6
   }
   ```

2. **Manejo de rate limiting:**
   - Deshabilitar botón tras 3 intentos fallidos
   - Mostrar countdown para reintentar

3. **Recordar credenciales:**
   - Checkbox "Recordar email"
   - Guardar email en UserDefaults

4. **Recuperación de contraseña:**
   - Link "¿Olvidaste tu contraseña?"
   - Navegación a pantalla de recuperación

### Especificación UI Mejorada

**Layout por Plataforma:** Ya es adaptativo (DSLoginView maneja esto)

**Mejoras menores:**
- Agregar indicador visual de validación en campos
- Animación de shake en error
- Auto-focus en campo de email al aparecer

---

## 3️⃣ Pantalla: Home

### 🟡 Estado Actual: Semi-dummy con Fragmentación

**Ubicación:** `Packages/EduGoFeatures/Sources/EduGoFeatures/Home/`

**Archivos:**
- ✅ `HomeView.swift` - iOS/macOS estándar (465 líneas)
- ✅ `HomeViewModel.swift` - Lógica compartida (135 líneas)
- ⚠️ `IPadHomeView.swift` - **DUPLICADO** optimizado iPad (550+ líneas)
- ⚠️ `VisionOSHomeView.swift` - **DUPLICADO** para visionOS (480+ líneas)

### 🔴 Fragmentación Crítica Detectada

**Problema:** Hay 3 implementaciones casi idénticas de Home, con código duplicado y lógica fragmentada.

#### Comparación de Versiones

| Característica | HomeView | IPadHomeView | VisionOSHomeView |
|---------------|----------|--------------|-------------------|
| **Código compartido** | 60% | 70% (duplica HomeView) | 75% (duplica HomeView) |
| **Layout único** | ScrollView 1 columna | 2 columnas landscape | Spatial layout |
| **ViewModels** | HomeViewModel | HomeViewModel (mismo) | HomeViewModel (mismo) |
| **Componentes DS** | DSCard, DSButton | DSCard custom | DSCard + VisionOS |

**Conclusión:** Las 3 vistas comparten el MISMO ViewModel pero duplican UI → **Candidato ideal para unificación con @Environment(\.horizontalSizeClass)**

### Implementación Actual (HomeView.swift)

**Secciones mostradas:**

1. **Header de Usuario**
   - Avatar con iniciales
   - Saludo personalizado
   - Usa glass effect

2. **Estadísticas (Stats)**
   - 📚 Cursos completados
   - ⏱️ Horas de estudio
   - 🔥 Racha actual
   - ⭐ Puntos totales
   - **Grid 2x2**

3. **Cursos Recientes**
   - Lista de 3 cursos
   - Barra de progreso por curso
   - Icono por categoría

4. **Actividad Reciente**
   - Timeline de actividades
   - Iconos por tipo de actividad
   - Timestamp relativo

5. **Información de Perfil**
   - ID, nombre, rol, email, status verificación
   - Formato de lista con iconos

6. **Acciones**
   - Botón "Cerrar Sesión"

### Componentes Usados

- ✅ `DSCard` con glass effects
- ✅ `DSButton` (tertiary style)
- ✅ `DSEmptyState`
- ✅ `DSColors`, `DSTypography`, `DSSpacing`
- ✅ `Label` con iconos SF Symbols

### Estados Manejados

- ✅ **Idle / Loading:** ProgressView + texto
- ✅ **Loaded:** Todas las secciones visibles
- ✅ **Error:** DSEmptyState con retry
- ⚠️ **Loading parcial:** Stats/Courses/Activity tienen loading individual
- ✅ **Empty states:** Mensaje para listas vacías

### Endpoints que DEBERÍA Consumir

Según `HomeViewModel.swift`:

```swift
// Use Cases disponibles:
- GetCurrentUserUseCase ✅ (implementado)
- GetRecentActivityUseCase ✅ (implementado)
- GetUserStatsUseCase ✅ (implementado)
- GetRecentCoursesUseCase ✅ (implementado)
- LogoutUseCase ✅ (implementado)
```

**Mapeo a API Mobile:**

| UseCase | Endpoint Real | Status |
|---------|---------------|--------|
| GetCurrentUser | `GET /v1/users/me` | ❌ **NO EXISTE en router** |
| GetRecentActivity | `GET /v1/users/me/activity` | ❌ **NO EXISTE** |
| GetUserStats | `GET /v1/users/me/stats` | ❌ **NO EXISTE** |
| GetRecentCourses | `GET /v1/materials?recent=true&limit=3` | ⚠️ **Parcial** |
| Logout | `POST /v1/auth/logout` | ⚠️ **Migrado a api-admin** |

### 🔴 Datos Mostrados vs Datos Reales

#### Datos Mostrados (ViewModel)

```swift
public struct UserStats {
    let coursesCompleted: Int        // Cursos completados
    let studyHoursTotal: Int         // Horas totales
    let currentStreakDays: Int       // Racha de días
    let totalPoints: Int             // Puntos totales
}

public struct Activity {
    let id: String
    let title: String
    let type: ActivityType           // .courseCompleted, .quizPassed, etc.
    let timestamp: Date
}

public struct Course {
    let id: String
    let title: String
    let instructor: String
    let category: CourseCategory
    let progress: Double             // 0.0 a 1.0
}
```

#### Datos Disponibles en API

Según `router.go`:

```go
// ✅ Endpoints REALES disponibles:
GET  /v1/materials                    // Lista materiales
GET  /v1/materials/:id                // Detalle material
GET  /v1/materials/:id/summary        // Resumen IA
GET  /v1/materials/:id/assessment     // Evaluación
GET  /v1/materials/:id/stats          // Stats de material
PATCH /v1/materials/:id/progress      // Actualizar progreso

GET  /v1/users/me/attempts            // Historial intentos
GET  /v1/attempts/:id/results         // Resultado intento

PUT  /v1/progress                     // Upsert progreso
GET  /v1/stats/global                 // Stats globales (admin)
```

### 🚨 Problema Identificado: **Semi-Dummy**

La pantalla Home **NO puede funcionar completamente** porque:

1. ❌ No existe endpoint `GET /v1/users/me` para obtener perfil
2. ❌ No existe endpoint `GET /v1/users/me/stats` para estadísticas
3. ❌ No existe endpoint `GET /v1/users/me/activity` para actividad
4. ❌ No existe endpoint `GET /v1/courses` (solo materials)

**Status:** 🟡 **Semi-dummy** - Tiene lógica de negocio pero sin backend real

### 🎯 Mejoras Requeridas

#### Prioridad: 🔴 Alta

#### 1. Unificación de Vistas (Eliminar fragmentación)

**Problema:** 3 archivos casi idénticos (`HomeView`, `IPadHomeView`, `VisionOSHomeView`)

**Solución:**

```swift
// Unificar en un solo HomeView.swift usando Size Classes
@MainActor
public struct HomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    public var body: some View {
        GeometryReader { geometry in
            if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                // iPad landscape o macOS → 2 columnas
                iPadLayout
            } else {
                // iPhone o iPad portrait → 1 columna
                compactLayout
            }
        }
    }
}
```

**Beneficios:**
- ✅ Eliminar 800+ líneas de código duplicado
- ✅ Mantenimiento simplificado
- ✅ Consistencia entre plataformas

#### 2. Implementar Endpoints Backend Faltantes

**Backend:** `edugo-api-mobile`

Crear endpoints:

```go
// internal/infrastructure/http/router/router.go

// Grupo de usuario actual
me := protected.Group("/users/me")
{
    me.GET("", c.Handlers.UserHandler.GetCurrentUser)
    me.GET("/stats", c.Handlers.StatsHandler.GetUserStats)
    me.GET("/activity", c.Handlers.ActivityHandler.GetRecentActivity)
    me.GET("/courses/recent", c.Handlers.CourseHandler.GetRecentCourses)
}
```

**Handlers a crear:**

```go
// internal/infrastructure/http/handler/user_handler.go
type UserHandler struct {
    getUserUseCase domain.GetUserUseCase
    logger         logging.Logger
}

func (h *UserHandler) GetCurrentUser(c *gin.Context) {
    // Obtener userID del token JWT
    userID := c.GetString("user_id")
    
    // Ejecutar use case
    user, err := h.getUserUseCase.Execute(userID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusOK, user)
}
```

#### 3. Conectar UseCases con API Real

**Frontend:** Actualizar repositorios

```swift
// Packages/EduGoDataLayer/Sources/EduGoDataLayer/Repositories/

// UserRepository.swift
public final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClient
    
    public func getCurrentUser() async -> Result<User, DomainError> {
        // ✅ Antes: return mock data
        // ✅ Ahora: llamar GET /v1/users/me
        
        return await apiClient.get(
            endpoint: "/users/me",
            responseType: User.self
        )
    }
}

// StatsRepository.swift
public final class StatsRepository: StatsRepositoryProtocol {
    public func getUserStats() async -> Result<UserStats, DomainError> {
        // ✅ Llamar GET /v1/users/me/stats
        return await apiClient.get(
            endpoint: "/users/me/stats",
            responseType: UserStats.self
        )
    }
}
```

#### 4. Agregar Estados Faltantes

```swift
// HomeViewModel.swift - Mejorar estados

// Estado de red
@Published var networkState: NetworkState = .online

// Refresh control
public func refresh() async {
    // Pull-to-refresh
    await loadAllData()
}

// Infinite scroll (si aplica)
public func loadMoreActivity() async {
    // Paginación de actividad
}
```

#### 5. Validaciones y Manejo de Errores

```swift
// Validar datos antes de mostrar
public var isStatsValid: Bool {
    userStats.coursesCompleted >= 0 &&
    userStats.studyHoursTotal >= 0
}

// Retry inteligente
private var retryCount = 0
private let maxRetries = 3

public func loadWithRetry() async {
    guard retryCount < maxRetries else {
        state = .error("Máximo de reintentos alcanzado")
        return
    }
    
    await loadAllData()
    
    if case .error = state {
        retryCount += 1
        try? await Task.sleep(nanoseconds: 1_000_000_000 * UInt64(retryCount))
        await loadWithRetry()
    } else {
        retryCount = 0
    }
}
```

### Especificación UI Mejorada

#### Layout Unificado por Plataforma

**iPhone (Compact Width):**
```
┌─────────────────────┐
│ Avatar + Greeting   │
├─────────────────────┤
│ Stats Grid (2x2)    │
├─────────────────────┤
│ Recent Courses      │
│ - Course 1 [====  ] │
│ - Course 2 [======] │
│ - Course 3 [==    ] │
├─────────────────────┤
│ Recent Activity     │
│ ⏱️ Completed Quiz   │
│ 📚 Started Course   │
├─────────────────────┤
│ Profile Card        │
├─────────────────────┤
│ [Logout Button]     │
└─────────────────────┘
```

**iPad Landscape / macOS (Regular Width + Regular Height):**
```
┌──────────────────────────────────────────────────┐
│ Navigation Bar                                   │
├───────────────────────┬──────────────────────────┤
│ Left Column:          │ Right Column:            │
│                       │                          │
│ Avatar + Greeting     │ Stats Grid (2x2)         │
│                       │ ┌─────┬─────┐            │
│ Profile Card          │ │  📚 │ ⏱️  │            │
│ - ID: 123             │ │  10 │ 45h │            │
│ - Name: John          │ ├─────┼─────┤            │
│ - Role: Student       │ │  🔥 │ ⭐  │            │
│ - Email: john@...     │ │   7 │ 350 │            │
│                       │ └─────┴─────┘            │
│ [Logout Button]       │                          │
│                       │ Recent Courses           │
│                       │ ┌──────────────────────┐ │
│                       │ │ Math 101   [======] │ │
│                       │ │ Physics    [====  ] │ │
│                       │ └──────────────────────┘ │
│                       │                          │
│                       │ Recent Activity          │
│                       │ • Completed Quiz         │
│                       │ • Started Course         │
└───────────────────────┴──────────────────────────┘
```

**visionOS (Spatial Computing):**
```
Spatial Layout con profundidad:

┌─────────────────────────────────────┐
│   Avatar (floating, glass effect)   │ Z: -50
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│   Stats Cards (4 floating cards)    │ Z: 0
│   ┌────┐  ┌────┐  ┌────┐  ┌────┐   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│   Courses (3D carousel)             │ Z: 50
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│   Activity Timeline (vertical)      │ Z: 100
└─────────────────────────────────────┘
```

#### Componentes del Design System a Usar

```swift
// Componentes existentes:
- DSCard (con .prominent, .regular, .subtle)
- DSButton (primary, secondary, tertiary)
- DSEmptyState
- DSColors, DSTypography, DSSpacing
- .dsGlassEffect()
- .dsShadow()

// Componentes a crear:
- DSStatCard (para estadísticas)
- DSCourseCard (para cursos)
- DSActivityRow (para actividad)
- DSProfileSection (para info de perfil)
- DSRefreshControl (pull-to-refresh)
```

#### Interacciones y Gestos

**iPhone:**
- ✅ Pull-to-refresh (SwiftUI `.refreshable`)
- ✅ Tap en curso → navegar a detalle
- ✅ Tap en actividad → navegar a detalle
- ✅ Swipe en curso → opciones (favorito, eliminar)

**iPad:**
- ✅ Todo lo de iPhone +
- ✅ Drag & drop de cursos para reordenar
- ✅ Hover effects en cards
- ✅ Context menu con click derecho

**macOS:**
- ✅ Todo lo de iPad +
- ✅ Keyboard shortcuts (⌘R para refresh)
- ✅ Toolbar con acciones rápidas

**visionOS:**
- ✅ Gaze + pinch para interactuar
- ✅ Cards flotantes con profundidad
- ✅ Hover 3D effects

#### Validaciones UI

```swift
// Validar antes de mostrar stats
guard userStats.isValid else {
    return DSEmptyState(
        icon: "exclamationmark.triangle",
        title: "Datos inválidos",
        message: "Las estadísticas no pudieron cargarse",
        style: .warning
    )
}

// Validar cursos vacíos
if recentCourses.isEmpty {
    return DSEmptyState(
        icon: "book.closed",
        title: "Sin cursos",
        message: "Comienza explorando cursos disponibles",
        actionTitle: "Explorar",
        action: { navigateToCourses() },
        style: .informational
    )
}

// Validar actividad vacía
if recentActivity.isEmpty {
    return DSEmptyState(
        icon: "clock.arrow.circlepath",
        title: "Sin actividad reciente",
        message: "Tu actividad aparecerá aquí",
        style: .informational
    )
}
```

---

## 4️⃣ Pantalla: Settings

### 🟡 Estado Actual: Semi-completa con Fragmentación

**Ubicación:** `Packages/EduGoFeatures/Sources/EduGoFeatures/Settings/`

**Archivos:**
- ✅ `SettingsView.swift` - iOS estándar
- ✅ `SettingsViewModel.swift` - Lógica compartida
- ⚠️ `IPadSettingsView.swift` - **DUPLICADO** para iPad
- ⚠️ `MacOSSettingsView.swift` - **DUPLICADO** para macOS

### Implementación Actual

**Secciones mostradas:**

1. **Apariencia (Theme)**
   - Picker: Light / Dark / System
   - Iconos por tema

2. **Idioma (Language)**
   - Picker: Español / English
   - Globe icon

3. **Información de la App**
   - Versión
   - Build number
   - Términos y condiciones
   - Política de privacidad

### Componentes Usados

- ✅ `DSForm` (formulario del DS)
- ✅ `DSFormSection`
- ✅ `DSDetailRow` (para info)
- ✅ `Picker` nativo de SwiftUI

### Estados Manejados

- ✅ **Loading:** Deshabilita pickers mientras carga
- ❌ **Error:** No muestra errores de actualización
- ❌ **Empty:** N/A

### Endpoints que Consume

```swift
// PreferencesRepository (local, no API)
- loadPreferences() // UserDefaults
- updateTheme()     // UserDefaults
- updateLanguage()  // UserDefaults

// No consume API → Todo es local
```

### 🚨 Problema: Sin Persistencia Backend

Las preferencias se guardan **solo localmente** (UserDefaults). Si el usuario cambia de dispositivo, pierde configuración.

### 🎯 Mejoras Requeridas

#### Prioridad: 🟡 Media

#### 1. Unificación de Vistas

**Problema:** 3 implementaciones casi idénticas

**Solución:**

```swift
@MainActor
public struct SettingsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    public var body: some View {
        #if os(macOS)
        macOSLayout  // Usa TabView nativa de macOS
        #else
        if horizontalSizeClass == .regular {
            iPadLayout  // Form con 2 columnas
        } else {
            compactLayout  // Form estándar
        }
        #endif
    }
}
```

#### 2. Sincronización con Backend

**Backend:** Crear endpoint de preferencias

```go
// router.go
me := protected.Group("/users/me")
{
    me.GET("/preferences", c.Handlers.UserHandler.GetPreferences)
    me.PUT("/preferences", c.Handlers.UserHandler.UpdatePreferences)
}
```

**Frontend:**

```swift
public final class PreferencesRepository {
    // Sincronizar local → servidor
    public func syncPreferences() async {
        let local = loadLocalPreferences()
        
        // Subir al servidor
        await apiClient.put("/users/me/preferences", body: local)
        
        // Descargar del servidor (por si hay cambios)
        let remote = await apiClient.get("/users/me/preferences")
        saveLocalPreferences(remote)
    }
}
```

#### 3. Agregar Más Opciones

**Nuevas secciones:**

```swift
// Notificaciones
DSFormSection(title: "Notificaciones") {
    Toggle("Recordatorios de estudio", isOn: $studyReminders)
    Toggle("Nuevos cursos", isOn: $newCoursesNotif)
    Toggle("Logros desbloqueados", isOn: $achievementsNotif)
}

// Privacidad
DSFormSection(title: "Privacidad") {
    Toggle("Perfil público", isOn: $publicProfile)
    Toggle("Mostrar progreso", isOn: $showProgress)
    Toggle("Permitir mensajes", isOn: $allowMessages)
}

// Datos y Almacenamiento
DSFormSection(title: "Almacenamiento") {
    Button("Limpiar caché") { clearCache() }
    Text("Tamaño caché: \(cacheSize) MB")
        .font(.caption)
        .foregroundColor(.secondary)
}

// Cuenta
DSFormSection(title: "Cuenta") {
    NavigationLink("Cambiar contraseña") {
        ChangePasswordView()
    }
    NavigationLink("Editar perfil") {
        EditProfileView()
    }
    Button("Cerrar sesión", role: .destructive) {
        logout()
    }
}
```

#### 4. Estados de Error

```swift
// Mostrar error si falla actualización
@State private var errorMessage: String?

.alert("Error", isPresented: .constant(errorMessage != nil)) {
    Button("OK") { errorMessage = nil }
} message: {
    Text(errorMessage ?? "")
}
```

### Especificación UI Mejorada

#### Layout por Plataforma

**iPhone:**
```
Settings
├── Apariencia
│   └── [Tema: System ▼]
├── Idioma
│   └── [Español ▼]
├── Notificaciones
│   ├── Recordatorios [Toggle]
│   └── Nuevos cursos [Toggle]
├── Privacidad
│   └── Perfil público [Toggle]
├── Almacenamiento
│   └── [Limpiar caché]
├── Información
│   ├── Versión: 1.0.0
│   └── Build: 42
└── Cuenta
    ├── Cambiar contraseña →
    ├── Editar perfil →
    └── [Cerrar sesión]
```

**iPad / macOS:**
```
┌─────────────────────────────────────────┐
│ Settings                                │
├──────────────┬──────────────────────────┤
│ Sidebar:     │ Detail:                  │
│              │                          │
│ Apariencia   │ [Selected: Apariencia]   │
│ Idioma       │                          │
│ Notif.       │ Tema de la aplicación    │
│ Privacidad   │ ○ Light                  │
│ Almacén.     │ ○ Dark                   │
│ Info         │ ● System (auto)          │
│ Cuenta       │                          │
│              │ Vista previa:            │
│              │ ┌────────────────┐       │
│              │ │ [Sample Card]  │       │
│              │ └────────────────┘       │
└──────────────┴──────────────────────────┘
```

---

## 5️⃣ Pantalla: Progress (User Progress)

### 🔴 Estado Actual: **PLACEHOLDER**

**Ubicación:** `Packages/EduGoFeatures/Sources/EduGoFeatures/Progress/`

**Archivos:**
- ⚠️ `UserProgressView.swift` - **PLACEHOLDER** (52 líneas)
- ⚠️ `IPadProgressView.swift` - **PLACEHOLDER**
- ⚠️ `VisionOSProgressView.swift` - **PLACEHOLDER**

### Implementación Actual

```swift
public struct UserProgressView: View {
    public var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "chart.bar.fill")
                Text("Progreso")
                Text("Próximamente...")
            }
        }
    }
}
```

**Status:** 🔴 **Pantalla placeholder sin funcionalidad**

### Endpoints Disponibles en API

```go
// api-mobile/router.go
PATCH /v1/materials/:id/progress  // Actualizar progreso
PUT   /v1/progress                // Upsert progreso (idempotente)
```

### 🎯 Mejoras Requeridas

#### Prioridad: 🔴 Alta

#### Especificación Completa de Progress

**Objetivo:** Mostrar el progreso del estudiante en cursos, materiales, evaluaciones y logros.

**Secciones a implementar:**

1. **Overview de Progreso**
   - Progreso general (%)
   - Cursos en progreso vs completados
   - Tiempo total de estudio
   - Racha actual

2. **Progreso por Curso**
   - Lista de cursos
   - Barra de progreso por curso
   - Materiales completados / total
   - Última actividad

3. **Evaluaciones**
   - Promedio general
   - Evaluaciones aprobadas / reprobadas
   - Mejor/peor evaluación
   - Historial de intentos

4. **Logros y Badges**
   - Badges desbloqueados
   - Próximos logros
   - Ranking (si aplica)

5. **Estadísticas Detalladas**
   - Gráfica de tiempo de estudio (últimos 7 días)
   - Gráfica de progreso mensual
   - Distribución por categoría

#### Componentes Necesarios

```swift
// Crear nuevos componentes en Design System:

// DSProgressBar.swift
public struct DSProgressBar: View {
    let value: Double  // 0.0 a 1.0
    let color: Color
    let showPercentage: Bool
}

// DSStatCard.swift
public struct DSStatCard: View {
    let icon: String
    let title: String
    let value: String
    let trend: Trend?  // .up, .down, .stable
}

// DSChartView.swift (usando Charts framework)
public struct DSChartView: View {
    let data: [ChartDataPoint]
    let type: ChartType  // .line, .bar, .pie
}

// DSBadgeCard.swift
public struct DSBadgeCard: View {
    let badge: Badge
    let isUnlocked: Bool
}
```

#### Layout Propuesto

**iPhone:**
```
Progress
├── Overview Card
│   ├── Progreso general: 67%
│   ├── Cursos activos: 3/5
│   ├── Tiempo total: 45h
│   └── Racha: 🔥 7 días
├── Gráfica de Progreso
│   └── [Line Chart - Últimos 7 días]
├── Cursos en Progreso
│   ├── Math 101 [========  ] 80%
│   ├── Physics [=====     ] 50%
│   └── Chemistry [==       ] 20%
├── Evaluaciones
│   ├── Promedio: 85%
│   ├── Aprobadas: 15/18
│   └── [Ver historial →]
└── Logros
    ├── 🏆 Primera evaluación
    ├── 🎓 5 cursos completados
    └── [Ver todos →]
```

#### Datos a Mostrar vs Datos Disponibles

**Datos necesarios:**
```swift
struct ProgressOverview {
    let overallProgress: Double      // % general
    let activeCourses: Int           // Cursos activos
    let completedCourses: Int        // Cursos completados
    let totalStudyTime: Int          // Minutos totales
    let currentStreak: Int           // Días consecutivos
}

struct CourseProgress {
    let courseId: String
    let courseName: String
    let progress: Double             // 0.0 a 1.0
    let materialsCompleted: Int
    let materialsTotal: Int
    let lastActivity: Date
}

struct AssessmentStats {
    let averageScore: Double         // Promedio
    let passedCount: Int             // Aprobadas
    let failedCount: Int             // Reprobadas
    let totalAttempts: Int           // Total intentos
}
```

**Endpoints necesarios en backend:**

```go
// CREAR en api-mobile:
GET /v1/users/me/progress/overview
GET /v1/users/me/progress/courses
GET /v1/users/me/progress/assessments
GET /v1/users/me/progress/achievements
GET /v1/users/me/progress/chart?days=7
```

#### Interacciones

- ✅ Pull-to-refresh
- ✅ Tap en curso → Ver detalle de progreso
- ✅ Tap en evaluación → Ver resultados
- ✅ Tap en logro → Ver descripción
- ✅ Swipe en curso → Opciones (marcar favorito)

#### Validaciones

```swift
// Validar progreso válido (0-100%)
guard progress >= 0 && progress <= 1 else {
    return .error("Progreso inválido")
}

// Validar fechas
guard lastActivity <= Date() else {
    return .error("Fecha de actividad inválida")
}

// Manejo de datos vacíos
if courses.isEmpty {
    return DSEmptyState(
        icon: "book.closed",
        title: "Sin cursos",
        message: "Inscríbete en un curso para ver tu progreso",
        actionTitle: "Explorar cursos",
        action: { navigateToCourses() }
    )
}
```

---

## 6️⃣ Pantalla: Courses

### 🔴 Estado Actual: **PLACEHOLDER**

**Ubicación:** `Packages/EduGoFeatures/Sources/EduGoFeatures/Courses/`

**Archivos:**
- ⚠️ `CoursesView.swift` - **PLACEHOLDER**
- ⚠️ `IPadCoursesView.swift` - **PLACEHOLDER**
- ⚠️ `VisionOSCoursesView.swift` - **PLACEHOLDER**

### Implementación Actual

```swift
public struct CoursesView: View {
    public var body: some View {
        VStack {
            Image(systemName: "book.fill")
            Text("Cursos")
            Text("Próximamente...")
        }
    }
}
```

**Status:** 🔴 **Pantalla placeholder sin funcionalidad**

### Endpoints Disponibles en API

```go
// api-mobile/router.go
GET  /v1/materials              // Lista de materiales
GET  /v1/materials/:id          // Detalle material
GET  /v1/materials/:id/summary  // Resumen IA
```

**Problema:** API tiene "materials" no "courses". Necesita adaptación conceptual.

### 🎯 Mejoras Requeridas

#### Prioridad: 🔴 Alta

#### Especificación Completa de Courses

**Objetivo:** Explorar, buscar y matricularse en cursos/materiales educativos.

**Secciones a implementar:**

1. **Buscador**
   - Campo de búsqueda
   - Filtros: categoría, nivel, duración
   - Ordenar por: popularidad, reciente, rating

2. **Categorías**
   - Grid de categorías con iconos
   - Tap → filtrar por categoría

3. **Lista de Cursos**
   - Card por curso con:
     - Imagen/thumbnail
     - Título
     - Instructor
     - Rating (⭐⭐⭐⭐⭐)
     - Duración estimada
     - Nivel (principiante/intermedio/avanzado)
     - Precio (si aplica)
     - Botón "Inscribirse" o "Continuar"

4. **Cursos Destacados**
   - Carrusel horizontal
   - 3-5 cursos recomendados

5. **Mis Cursos**
   - Tab separado para cursos inscritos
   - Progreso visible

#### Layout Propuesto

**iPhone:**
```
Courses
├── Search Bar
│   └── [🔍 Buscar cursos...]
├── Filters
│   └── [Categoría ▼] [Nivel ▼] [Ordenar ▼]
├── Featured (Horizontal Scroll)
│   ├── [Course Card 1]
│   ├── [Course Card 2]
│   └── [Course Card 3]
└── All Courses (Vertical List)
    ├── ┌──────────────────────┐
    │  │ [Thumbnail]          │
    │  │ Math 101             │
    │  │ Dr. Smith            │
    │  │ ⭐⭐⭐⭐⭐ 4.8 (120)     │
    │  │ 6 semanas • Básico   │
    │  │ [Inscribirse]        │
    │  └──────────────────────┘
    └── [Load more...]
```

**iPad:**
```
┌────────────────────────────────────────┐
│ Courses                    [Grid] [List]│
├────────────────────────────────────────┤
│ [Search] [Filters...]                  │
├────────────────────────────────────────┤
│ Featured                               │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │
│ │ C1   │ │ C2   │ │ C3   │ │ C4   │   │
│ └──────┘ └──────┘ └──────┘ └──────┘   │
├────────────────────────────────────────┤
│ Grid View (2-3 columnas)               │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐│
│ │ Math 101 │ │ Physics  │ │Chemistry ││
│ │ [Image]  │ │ [Image]  │ │ [Image]  ││
│ │ ⭐ 4.8   │ │ ⭐ 4.5   │ │ ⭐ 4.9   ││
│ └──────────┘ └──────────┘ └──────────┘│
└────────────────────────────────────────┘
```

#### Componentes Necesarios

```swift
// DSCourseCard.swift
public struct DSCourseCard: View {
    let course: Course
    let style: CardStyle  // .compact, .expanded
    let onTap: () -> Void
    let onEnroll: (() -> Void)?
}

// DSSearchBar.swift
public struct DSSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void
}

// DSFilterChip.swift
public struct DSFilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
}

// DSCategoryGrid.swift
public struct DSCategoryGrid: View {
    let categories: [CourseCategory]
    let onSelect: (CourseCategory) -> Void
}
```

#### Datos a Mostrar

```swift
struct Course {
    let id: String
    let title: String
    let description: String
    let instructor: String
    let thumbnailURL: URL?
    let category: CourseCategory
    let level: CourseLevel        // .beginner, .intermediate, .advanced
    let duration: TimeInterval    // Duración estimada
    let rating: Double            // 0.0 a 5.0
    let reviewsCount: Int
    let studentsEnrolled: Int
    let isEnrolled: Bool
    let progress: Double?         // Si está inscrito
}

enum CourseCategory {
    case mathematics
    case science
    case programming
    case languages
    case arts
    
    var iconName: String
    var color: Color
}
```

#### Endpoints Necesarios

**Backend:** Adaptar materials a courses

```go
// api-mobile: Crear CourseHandler o adaptar MaterialHandler
GET  /v1/courses                 // Lista de cursos
GET  /v1/courses/:id             // Detalle curso
POST /v1/courses/:id/enroll      // Inscribirse
DELETE /v1/courses/:id/unenroll  // Desinscribirse
GET  /v1/courses/featured        // Cursos destacados
GET  /v1/courses/my-courses      // Mis cursos
GET  /v1/courses/categories      // Categorías
```

**O mapear materials:**

```swift
// MaterialRepository → CourseRepository
public func listCourses() async -> Result<[Course], DomainError> {
    // Llamar GET /v1/materials
    let materials = await getMaterials()
    
    // Convertir Material → Course
    return materials.map { material in
        Course(
            id: material.id,
            title: material.title,
            description: material.description,
            // ... mapear campos
        )
    }
}
```

#### Interacciones

- ✅ **Search:** Búsqueda en tiempo real (debounce 300ms)
- ✅ **Filtros:** Bottom sheet con opciones
- ✅ **Tap en curso:** Navegar a detalle
- ✅ **Tap en categoría:** Filtrar por categoría
- ✅ **Pull-to-refresh**
- ✅ **Infinite scroll:** Cargar más al llegar al final
- ✅ **Swipe en card:** Favorito / Compartir

#### Validaciones

```swift
// Validar búsqueda
guard searchText.count >= 2 else {
    return  // No buscar con menos de 2 caracteres
}

// Validar rating
guard course.rating >= 0 && course.rating <= 5 else {
    return .error("Rating inválido")
}

// Empty state
if courses.isEmpty && !isLoading {
    return DSEmptyState(
        icon: "magnifyingglass",
        title: "Sin resultados",
        message: "No encontramos cursos con esos criterios",
        actionTitle: "Limpiar filtros",
        action: { clearFilters() }
    )
}
```

---

## 7️⃣ Pantalla: Calendar

### 🔴 Estado Actual: **PLACEHOLDER**

**Ubicación:** `Packages/EduGoFeatures/Sources/EduGoFeatures/Calendar/`

**Archivos:**
- ⚠️ `CalendarView.swift` - **PLACEHOLDER**
- ⚠️ `IPadCalendarView.swift` - **PLACEHOLDER**
- ⚠️ `VisionOSCalendarView.swift` - **PLACEHOLDER**

### Implementación Actual

```swift
public struct CalendarView: View {
    public var body: some View {
        VStack {
            Image(systemName: "calendar")
            Text("Calendario")
            Text("Próximamente...")
        }
    }
}
```

**Status:** 🔴 **Pantalla placeholder sin funcionalidad**

### 🎯 Mejoras Requeridas

#### Prioridad: 🟡 Media

#### Especificación Completa de Calendar

**Objetivo:** Mostrar eventos, deadlines, clases programadas y recordatorios.

**Secciones a implementar:**

1. **Vista de Calendario**
   - Mes actual con días
   - Indicadores en días con eventos
   - Navegación mes anterior/siguiente

2. **Eventos del Día Seleccionado**
   - Lista de eventos del día
   - Hora, título, tipo

3. **Tipos de Eventos**
   - 📚 Clase programada
   - 📝 Examen/evaluación
   - ⏰ Recordatorio de estudio
   - 🎯 Deadline de tarea

4. **Acciones**
   - Agregar evento manual
   - Editar evento
   - Eliminar evento

#### Layout Propuesto

**iPhone:**
```
Calendar
├── Navegación
│   └── [< Noviembre 2025 >]
├── Calendario Mensual
│   └── L  M  M  J  V  S  D
│       1  2  3• 4  5  6  7
│       8  9  10 11•12 13 14
│       ... (• = tiene evento)
├── Eventos del Día
│   ├── 09:00 - Clase de Math
│   ├── 14:00 - Examen Physics
│   └── 18:00 - Recordatorio
└── [+ Agregar evento]
```

**iPad:**
```
┌────────────────────────────────────────┐
│ [< Noviembre 2025 >]       [Week] [Day]│
├──────────────────┬─────────────────────┤
│ Calendar:        │ Events:             │
│ L M M J V S D    │                     │
│ 1 2 3•4 5 6 7    │ Selected: 3 Nov     │
│ 8 9 ...          │                     │
│                  │ 09:00 📚 Math       │
│ [Month view]     │ 14:00 📝 Exam       │
│                  │ 18:00 ⏰ Study      │
│                  │                     │
│                  │ [+ Add event]       │
└──────────────────┴─────────────────────┘
```

#### Componentes Necesarios

```swift
// DSCalendarView.swift (usando SwiftUI Calendar)
public struct DSCalendarView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
}

// DSEventRow.swift
public struct DSEventRow: View {
    let event: CalendarEvent
    let onTap: () -> Void
    let onDelete: () -> Void
}

// DSEventEditor.swift
public struct DSEventEditor: View {
    @Binding var event: CalendarEvent
    let onSave: () -> Void
}
```

#### Datos a Mostrar

```swift
struct CalendarEvent {
    let id: String
    let title: String
    let description: String?
    let startTime: Date
    let endTime: Date
    let type: EventType
    let courseId: String?
    let isAllDay: Bool
}

enum EventType {
    case scheduledClass
    case exam
    case studyReminder
    case deadline
    
    var icon: String
    var color: Color
}
```

#### Endpoints Necesarios

```go
// api-mobile: Crear EventHandler
GET  /v1/events?from=2025-11-01&to=2025-11-30  // Eventos del mes
POST /v1/events                                // Crear evento
PUT  /v1/events/:id                            // Actualizar evento
DELETE /v1/events/:id                          // Eliminar evento
GET  /v1/events/:id                            // Detalle evento
```

#### Interacciones

- ✅ Tap en día → Ver eventos del día
- ✅ Tap en evento → Ver detalle
- ✅ Swipe en evento → Editar / Eliminar
- ✅ Drag evento → Cambiar fecha/hora
- ✅ Pull-to-refresh
- ✅ Agregar a Calendario del sistema (EventKit)

---

## 8️⃣ Pantalla: Community

### 🔴 Estado Actual: **PLACEHOLDER**

**Ubicación:** `Packages/EduGoFeatures/Sources/EduGoFeatures/Community/`

**Archivos:**
- ⚠️ `CommunityView.swift` - **PLACEHOLDER**
- ⚠️ `IPadCommunityView.swift` - **PLACEHOLDER**
- ⚠️ `VisionOSCommunityView.swift` - **PLACEHOLDER**

### Implementación Actual

```swift
public struct CommunityView: View {
    public var body: some View {
        VStack {
            Image(systemName: "person.2.fill")
            Text("Comunidad")
            Text("Próximamente...")
        }
    }
}
```

**Status:** 🔴 **Pantalla placeholder sin funcionalidad**

### 🎯 Mejoras Requeridas

#### Prioridad: 🟡 Media

#### Especificación Completa de Community

**Objetivo:** Conectar estudiantes, foros de discusión, preguntas y respuestas.

**Secciones a implementar:**

1. **Feed de Actividad**
   - Posts de estudiantes
   - Preguntas destacadas
   - Logros de compañeros

2. **Foros por Curso**
   - Lista de foros
   - Tap → Ver discusiones del curso

3. **Preguntas y Respuestas**
   - Q&A estilo Stack Overflow
   - Votar respuestas
   - Marcar respuesta aceptada

4. **Perfil de Estudiantes**
   - Ver perfil de otros
   - Estadísticas públicas
   - Seguir/dejar de seguir

5. **Leaderboard (Opcional)**
   - Ranking por puntos
   - Badges desbloqueados

#### Layout Propuesto

**iPhone:**
```
Community
├── Tabs
│   ├── Feed
│   ├── Forums
│   └── Leaderboard
├── Feed Tab
│   ├── ┌────────────────────┐
│   │  │ @john_smith         │
│   │  │ Completé Math 101! 🎉│
│   │  │ ❤️ 12  💬 3         │
│   │  └────────────────────┘
│   └── [Load more...]
└── Forums Tab
    ├── 📚 Math 101 (45 posts)
    ├── 🧪 Physics (23 posts)
    └── 💻 Programming (67 posts)
```

**iPad:**
```
┌────────────────────────────────────────┐
│ Community                   [Feed] [Q&A]│
├──────────────────┬─────────────────────┤
│ Sidebar:         │ Feed:               │
│                  │                     │
│ Feed             │ ┌─────────────────┐ │
│ Forums           │ │ @user Post...   │ │
│ Q&A              │ │ ❤️ 12  💬 3     │ │
│ Leaderboard      │ └─────────────────┘ │
│                  │                     │
│ My Activity      │ ┌─────────────────┐ │
│ Bookmarks        │ │ @user2 Question?│ │
│                  │ └─────────────────┘ │
└──────────────────┴─────────────────────┘
```

#### Componentes Necesarios

```swift
// DSPostCard.swift
public struct DSPostCard: View {
    let post: CommunityPost
    let onLike: () -> Void
    let onComment: () -> Void
}

// DSForumRow.swift
public struct DSForumRow: View {
    let forum: Forum
    let onTap: () -> Void
}

// DSQuestionCard.swift
public struct DSQuestionCard: View {
    let question: Question
    let onUpvote: () -> Void
    let onAnswer: () -> Void
}
```

#### Datos a Mostrar

```swift
struct CommunityPost {
    let id: String
    let author: User
    let content: String
    let images: [URL]
    let likes: Int
    let comments: [Comment]
    let createdAt: Date
}

struct Forum {
    let id: String
    let courseId: String
    let courseName: String
    let postsCount: Int
    let lastActivity: Date
}

struct Question {
    let id: String
    let author: User
    let title: String
    let content: String
    let tags: [String]
    let upvotes: Int
    let answers: [Answer]
    let isAnswered: Bool
}
```

#### Endpoints Necesarios

```go
// api-mobile: Crear CommunityHandler
GET  /v1/community/feed             // Feed de posts
POST /v1/community/posts            // Crear post
GET  /v1/community/posts/:id        // Detalle post
POST /v1/community/posts/:id/like   // Like a post
POST /v1/community/posts/:id/comment // Comentar

GET  /v1/community/forums           // Lista de foros
GET  /v1/community/forums/:id/posts // Posts del foro

GET  /v1/community/questions        // Lista de Q&A
POST /v1/community/questions        // Hacer pregunta
POST /v1/community/questions/:id/answers // Responder
POST /v1/community/answers/:id/upvote    // Votar respuesta
```

#### Interacciones

- ✅ Pull-to-refresh en feed
- ✅ Infinite scroll
- ✅ Tap en post → Ver detalle + comentarios
- ✅ Doble tap → Like
- ✅ Swipe → Opciones (reportar, compartir)
- ✅ Tap en avatar → Ver perfil

---

## 📊 Resumen de Prioridades

### 🔴 Alta Prioridad (Crítico)

1. **Home - Unificación**
   - Eliminar duplicación de `HomeView`, `IPadHomeView`, `VisionOSHomeView`
   - Usar size classes y GeometryReader
   - **Estimado:** 2-3 días

2. **Home - Backend**
   - Crear endpoints faltantes: `/users/me`, `/users/me/stats`, `/users/me/activity`
   - Conectar UseCases con API real
   - **Estimado:** 3-5 días

3. **Progress - Implementación Completa**
   - Reemplazar placeholder por pantalla funcional
   - Crear componentes (DSProgressBar, DSChartView)
   - Crear endpoints backend
   - **Estimado:** 5-7 días

4. **Courses - Implementación Completa**
   - Reemplazar placeholder por pantalla funcional
   - Adaptar materials → courses
   - Crear componentes (DSCourseCard, DSSearchBar)
   - **Estimado:** 5-7 días

### 🟡 Media Prioridad

5. **Settings - Unificación y Sync**
   - Unificar vistas de Settings
   - Implementar sincronización con backend
   - Agregar más opciones (notificaciones, privacidad)
   - **Estimado:** 2-3 días

6. **Calendar - Implementación Completa**
   - Pantalla funcional de calendario
   - Integración con EventKit
   - **Estimado:** 4-5 días

7. **Community - Implementación Completa**
   - Feed social básico
   - Foros por curso
   - **Estimado:** 5-7 días

### 🟢 Baja Prioridad

8. **Splash - Mejoras menores**
   - Animaciones
   - Manejo de errores mejorado
   - **Estimado:** 1 día

9. **Login - Validaciones**
   - Validación en tiempo real
   - Rate limiting
   - **Estimado:** 1-2 días

---

## 🛠️ Componentes del Design System Requeridos

### Componentes Existentes ✅

- `DSButton`
- `DSCard`
- `DSTextField`
- `DSFloatingActionButton`
- `DSColors`, `DSTypography`, `DSSpacing`, `DSCornerRadius`
- `.dsGlassEffect()`
- `.dsShadow()`

### Componentes a Crear 🔨

#### Alta Prioridad

1. **DSProgressBar**
   - Para pantalla Progress
   - Mostrar progreso 0-100%
   - Variantes: circular, linear

2. **DSChartView**
   - Usar Swift Charts
   - Tipos: line, bar, pie
   - Para estadísticas

3. **DSEmptyState** (revisar si existe)
   - Estado vacío con icono + mensaje + acción
   - Variantes: informational, error, warning

4. **DSStatCard**
   - Card de estadística con icono + valor + label
   - Opcional: trend indicator

5. **DSCourseCard**
   - Card de curso con imagen, título, rating, etc.
   - Variantes: compact, expanded

6. **DSSearchBar**
   - Barra de búsqueda con debounce
   - Botón clear
   - Placeholder animado

#### Media Prioridad

7. **DSFilterChip**
   - Chip de filtro seleccionable
   - Pill shape con check

8. **DSEventRow**
   - Row de evento de calendario
   - Hora + título + icono tipo

9. **DSPostCard**
   - Card de post social
   - Avatar + contenido + likes + comments

10. **DSQuestionCard**
    - Card de Q&A
    - Título + tags + upvotes + respuestas

---

## 🔗 Endpoints Backend Requeridos

### edugo-api-mobile

#### Usuario (Alta Prioridad)

```go
GET  /v1/users/me                    // Perfil actual
GET  /v1/users/me/stats              // Estadísticas usuario
GET  /v1/users/me/activity           // Actividad reciente
GET  /v1/users/me/preferences        // Preferencias
PUT  /v1/users/me/preferences        // Actualizar preferencias
```

#### Progreso (Alta Prioridad)

```go
GET  /v1/users/me/progress/overview     // Overview de progreso
GET  /v1/users/me/progress/courses      // Progreso por curso
GET  /v1/users/me/progress/assessments  // Stats de evaluaciones
GET  /v1/users/me/progress/achievements // Logros
GET  /v1/users/me/progress/chart?days=7 // Gráfica
```

#### Cursos (Alta Prioridad)

```go
GET  /v1/courses                     // Lista cursos
GET  /v1/courses/:id                 // Detalle curso
POST /v1/courses/:id/enroll          // Inscribirse
DELETE /v1/courses/:id/unenroll      // Desinscribirse
GET  /v1/courses/featured            // Destacados
GET  /v1/courses/my-courses          // Mis cursos
```

#### Calendario (Media Prioridad)

```go
GET    /v1/events?from=X&to=Y        // Eventos rango
POST   /v1/events                    // Crear evento
PUT    /v1/events/:id                // Actualizar
DELETE /v1/events/:id                // Eliminar
```

#### Comunidad (Media Prioridad)

```go
GET  /v1/community/feed              // Feed posts
POST /v1/community/posts             // Crear post
POST /v1/community/posts/:id/like    // Like
POST /v1/community/posts/:id/comment // Comentar

GET  /v1/community/forums            // Foros
GET  /v1/community/questions         // Q&A
POST /v1/community/questions         // Preguntar
POST /v1/community/answers/:id/upvote // Votar
```

---

## 📝 Notas Finales

### Arquitectura Actual

La app sigue **Clean Architecture** con:

- ✅ **Domain:** Entities, UseCases, Repositories (protocols)
- ✅ **Data:** Repositories (implementations), API clients
- ✅ **Presentation:** Views, ViewModels (MVVM)
- ✅ **Design System:** Componentes reutilizables

### Modularización

El código está organizado en **Swift Package Manager**:

- `EduGoDomainCore` - Lógica de negocio
- `EduGoDataLayer` - Capa de datos
- `EduGoFeatures` - Pantallas y features
- `EduGoDesignSystem` - Componentes UI
- `EduGoFoundation` - Utilidades
- `EduGoSecurityKit` - Seguridad
- `EduGoObservability` - Logging y analytics

### Testing

Cada pantalla debería tener:

- ✅ Unit tests para ViewModels
- ✅ Snapshot tests para Views
- ✅ Integration tests para flujos completos

### Accesibilidad

Todas las pantallas deben cumplir:

- ✅ VoiceOver labels
- ✅ Dynamic Type
- ✅ High Contrast
- ✅ Reduce Motion

---

**Generado con:** Claude Code  
**Fecha:** 1 de Diciembre, 2025  
**Versión:** 1.0
