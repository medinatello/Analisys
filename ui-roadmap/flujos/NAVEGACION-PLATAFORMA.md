# Navegación por Plataforma - EduGo Apple App

**Fecha:** 1 de Diciembre, 2025  
**Plataformas:** iOS, iPadOS, macOS, visionOS  
**Framework:** SwiftUI con adaptación multiplataforma

---

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Sistema de Detección de Plataforma](#sistema-de-detección-de-plataforma)
3. [iPhone - Navegación por Tabs](#iphone---navegación-por-tabs)
4. [iPad - Navegación con Sidebar](#ipad---navegación-con-sidebar)
5. [macOS - Navegación de Escritorio](#macos---navegación-de-escritorio)
6. [visionOS - Navegación Espacial](#visionos---navegación-espacial)
7. [Gestos y Atajos](#gestos-y-atajos)
8. [Persistencia de Estado](#persistencia-de-estado)
9. [Transiciones y Animaciones](#transiciones-y-animaciones)

---

## Descripción General

La app EduGo está diseñada con un enfoque **Platform-First**, aprovechando las capacidades únicas de cada plataforma Apple mientras mantiene una experiencia coherente.

### Principios de Diseño

1. **Nativo por Plataforma:** Cada plataforma utiliza los patrones de navegación esperados
2. **Adaptativo por Contexto:** La UI se adapta dinámicamente al tamaño de pantalla
3. **Coherencia de Marca:** La identidad visual se mantiene consistente
4. **Optimización de Entrada:** Teclado/trackpad en Mac, touch en iOS, gestos en visionOS

### Arquitectura de Navegación

```swift
// Sistema centralizado de detección de plataforma
PlatformCapabilities
├── currentDevice: DeviceType (.iPhone, .iPad, .mac, .vision)
├── recommendedNavigationStyle: NavigationStyle (.tabs, .sidebar, .spatial)
├── screenCapabilities: ScreenCapabilities (tamaño, scale, multi-columna)
├── inputCapabilities: InputCapabilities (teclado, trackpad, pencil, hover)
└── osCapabilities: OSCapabilities (efectos, concurrencia)

// Vista raíz que adapta la navegación
AdaptiveNavigationView
├── AuthenticationState → Controla Login vs Authenticated
└── AuthenticatedApp
    ├── PlatformCapabilities.recommendedNavigationStyle
    │   ├── .tabs → TabView (iPhone)
    │   ├── .sidebar → NavigationSplitView (iPad/Mac)
    │   └── .spatial → WindowGroup (visionOS)
```

---

## Sistema de Detección de Plataforma

### PlatformCapabilities

Ubicación: `/Users/jhoanmedina/source/EduGo/EduUI/apple-app/Packages/EduGoDesignSystem/Sources/EduGoDesignSystem/Platform/PlatformCapabilities.swift`

```swift
public struct PlatformCapabilities {
    // Tipo de dispositivo
    @MainActor
    public static var currentDevice: DeviceType {
        #if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return .iPhone
        case .pad: return .iPad
        case .vision: return .vision
        default: return .unknown
        }
        #elseif os(macOS)
        return .mac
        #elseif os(visionOS)
        return .vision
        #endif
    }
    
    // Estilo de navegación recomendado
    @MainActor
    public static var recommendedNavigationStyle: NavigationStyle {
        switch currentDevice {
        case .iPhone: return .tabs
        case .iPad, .mac: return .sidebar
        case .vision: return .spatial
        case .unknown: return .tabs
        }
    }
    
    // Capacidades de pantalla
    public static var screenCapabilities: ScreenCapabilities {
        // Detecta tamaño, scale, soporte multi-columna
    }
    
    // Capacidades de entrada
    @MainActor
    public static var inputCapabilities: InputCapabilities {
        // hasKeyboard, hasTrackpad, supportsPencil, supportsHover
    }
}
```

### Uso en la App

```swift
// En AdaptiveNavigationView
var body: some View {
    switch PlatformCapabilities.recommendedNavigationStyle {
    case .tabs:
        phoneNavigation
    case .sidebar:
        tabletNavigation
    case .spatial:
        spatialNavigation
    }
}
```

---

## iPhone - Navegación por Tabs

### Características

- **TabBar inferior:** Hasta 5 tabs visibles, resto en "More"
- **Navigation Stack:** Para navegación drill-down
- **Gestos táctiles:** Swipe back, pull-to-refresh
- **Orientación:** Portrait preferida, landscape soportado
- **Tamaño de toque:** 44x44 pt mínimo

### Layout

```
┌────────────────────────────────────┐
│        Navigation Bar              │
│  ← Back         Title          •••  │
├────────────────────────────────────┤
│                                    │
│                                    │
│         Content Area               │
│      (ScrollView / List)           │
│                                    │
│                                    │
│                                    │
│                                    │
│                                    │
├────────────────────────────────────┤
│     [🏠]  [📚]  [📊]  [👥]  [⚙️]    │
│     Home Courses Progress Chat Set │
└────────────────────────────────────┘
```

### Código de Implementación

```swift
private var phoneNavigation: some View {
    TabView(selection: $selectedRoute) {
        // Tab 1: Home
        destination(for: .home)
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }
            .tag(Route.home)
        
        // Tab 2: Courses
        destination(for: .courses)
            .tabItem {
                Label("Cursos", systemImage: "book.fill")
            }
            .tag(Route.courses)
        
        // Tab 3: Calendar
        destination(for: .calendar)
            .tabItem {
                Label("Calendario", systemImage: "calendar")
            }
            .tag(Route.calendar)
        
        // Tab 4: Progress
        destination(for: .progress)
            .tabItem {
                Label("Progreso", systemImage: "chart.bar.fill")
            }
            .tag(Route.progress)
        
        // Tab 5: Community
        destination(for: .community)
            .tabItem {
                Label("Comunidad", systemImage: "person.2.fill")
            }
            .tag(Route.community)
        
        // Tab 6: Settings
        destination(for: .settings)
            .tabItem {
                Label("Ajustes", systemImage: "gear")
            }
            .tag(Route.settings)
    }
    .tint(DSColors.accent)
}

// Cada destination usa NavigationStack interno
@ViewBuilder
private func destination(for route: Route) -> some View {
    NavigationStack {
        switch route {
        case .home:
            HomeView(/* use cases */)
        case .courses:
            CoursesView(/* use cases */)
        // ... más casos
        }
    }
}
```

### Navegación Profunda (Drill-Down)

```swift
// Dentro de CoursesView (ejemplo)
NavigationStack {
    List(courses) { course in
        NavigationLink(value: course) {
            CourseCard(course: course)
        }
    }
    .navigationDestination(for: Course.self) { course in
        CourseDetailView(course: course)
    }
    .navigationDestination(for: Material.self) { material in
        MaterialDetailView(material: material)
    }
}
```

**Resultado:**
```
Courses (root)
  → tap en curso
CourseDetail
  → tap en material
MaterialDetail
  → swipe back
CourseDetail
  → swipe back
Courses
```

### Gestos Soportados

| Gesto | Acción |
|-------|--------|
| **Swipe desde borde izquierdo** | Retroceder (pop) en stack |
| **Pull down desde top** | Pull-to-refresh (si está implementado) |
| **Long press en item** | Menú contextual |
| **Tap en TabBar item activo** | Scroll to top + pop to root |
| **Swipe horizontal en TabBar** | ❌ No soportado (iOS estándar) |

### Adaptaciones por Orientación

**Portrait (preferida):**
- TabBar en bottom
- Navigation bar en top
- Content ocupa espacio central

**Landscape (iPhone pequeños):**
- TabBar permanece en bottom (más estrecho)
- Navigation bar más compacto
- Considera usar `.navigationBarTitleDisplayMode(.inline)`

```swift
.navigationBarTitleDisplayMode(
    UIDevice.current.orientation.isLandscape ? .inline : .large
)
```

### Safe Area

```swift
// Respeta safe areas por defecto
ScrollView {
    content
}
.ignoresSafeArea(.keyboard) // Excepto teclado

// Para fullscreen (ej: splash, video)
.ignoresSafeArea()
```

---

## iPad - Navegación con Sidebar

### Características

- **NavigationSplitView:** 2 o 3 columnas
- **Sidebar colapsable:** Usuario puede ocultar/mostrar
- **Split View multitarea:** Soporta Stage Manager
- **Apple Pencil:** Soporte para anotaciones
- **Hover effects:** Cursor sobre elementos
- **Teclado externo:** Soporte completo

### Layout (Portrait)

```
┌──────────────────────────────────────────────────────┐
│                Navigation Bar                        │
│  [☰] Sidebar         Title                      •••  │
├──────────────────────────────────────────────────────┤
│                                                      │
│                                                      │
│                 Content Area                         │
│             (Detail View principal)                  │
│                                                      │
│                                                      │
│                                                      │
└──────────────────────────────────────────────────────┘

// Sidebar colapsada por defecto en portrait
```

### Layout (Landscape)

```
┌────────────┬─────────────────────────────────────────┐
│  Sidebar   │        Navigation Bar                   │
│            │  Title                              ••• │
│            ├─────────────────────────────────────────┤
│ 🏠 Inicio  │                                         │
│ 📚 Cursos  │                                         │
│ 📅 Calend. │          Content Area                   │
│ 📊 Progr.  │       (Detail View principal)           │
│ 👥 Comun.  │                                         │
│ ⚙️ Ajustes │                                         │
│            │                                         │
│ ─────────  │                                         │
│ Cerrar     │                                         │
│ Sesión     │                                         │
└────────────┴─────────────────────────────────────────┘

// Sidebar visible por defecto en landscape
```

### Código de Implementación

```swift
private var tabletNavigation: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
        // SIDEBAR (columna 1)
        sidebarContent
            .navigationSplitViewColumnWidth(
                min: sidebarMinWidth,
                ideal: sidebarIdealWidth,
                max: sidebarMaxWidth
            )
    } detail: {
        // DETAIL (columna 2)
        destination(for: selectedRoute)
            .navigationTitle(navigationTitle)
            .toolbar {
                #if os(macOS)
                macOSToolbar
                #endif
            }
    }
    .navigationSplitViewStyle(.balanced)
}

// Anchos del sidebar
private var sidebarMinWidth: CGFloat {
    #if os(macOS)
    return 200
    #else
    return 250  // iPad: más ancho para mejor usabilidad táctil
    #endif
}

private var sidebarIdealWidth: CGFloat {
    #if os(macOS)
    return 250
    #else
    return 320  // iPad
    #endif
}

private var sidebarMaxWidth: CGFloat {
    #if os(macOS)
    return 300
    #else
    return 400  // iPad
    #endif
}
```

### Sidebar Content

```swift
private var sidebarContent: some View {
    List {
        Section("Navegación") {
            NavigationLink(value: Route.home) {
                Label("Inicio", systemImage: "house.fill")
            }
            NavigationLink(value: Route.courses) {
                Label("Cursos", systemImage: "book.fill")
            }
            NavigationLink(value: Route.calendar) {
                Label("Calendario", systemImage: "calendar")
            }
            NavigationLink(value: Route.progress) {
                Label("Progreso", systemImage: "chart.bar.fill")
            }
            NavigationLink(value: Route.community) {
                Label("Comunidad", systemImage: "person.2.fill")
            }
            NavigationLink(value: Route.settings) {
                Label("Ajustes", systemImage: "gear")
            }
        }
        
        Section("Cuenta") {
            Button(role: .destructive) {
                Task { await performLogout() }
            } label: {
                Label("Cerrar Sesión", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }
    .navigationTitle("EduGo")
    .listStyle(.insetGrouped)
}
```

### Visibilidad del Sidebar

```swift
@State private var columnVisibility: NavigationSplitViewVisibility = .automatic

// .automatic: Muestra/oculta según orientación y tamaño
// .detailOnly: Oculta sidebar
// .all: Fuerza mostrar sidebar

// Controlar desde botón
Button {
    withAnimation {
        columnVisibility = columnVisibility == .all ? .detailOnly : .all
    }
} label: {
    Image(systemName: "sidebar.left")
}
```

### Navegación desde Sidebar

**Comportamiento:**
- Tap en item del sidebar → Cambia detail view
- NO añade al stack de navegación
- Es una navegación "lateral", no "profunda"

**Navegación profunda desde Detail:**
- Push dentro del detail view SÍ añade al stack
- Back button aparece en detail view

```
[Sidebar]          [Detail View Stack]
  Home    →        HomeView (root)
  Courses →        CoursesView (root)
                     → CourseDetail (push)
                       → MaterialDetail (push)
                         ← Back (pop)
                       ← Back (pop)
  Progress →       ProgressView (root) [cambia detail]
```

### Split View para Detalle (3 columnas)

**Ejemplo:** Lista de cursos + Detalle de curso + Preview de material

```swift
NavigationSplitView {
    // Columna 1: Sidebar principal
    sidebarContent
} content: {
    // Columna 2: Lista de items
    coursesList
} detail: {
    // Columna 3: Detalle del item seleccionado
    courseDetail
}
.navigationSplitViewStyle(.prominentDetail)
```

**Cuándo usar 3 columnas:**
- iPad en landscape con pantalla ≥ 12.9"
- Contenido que se beneficia de preview (ej: email, archivos, cursos)

### Stage Manager (iPadOS 16+)

- **Múltiples ventanas:** Usuario puede tener varias instancias de la app
- **Redimensionamiento:** App se adapta a tamaños arbitrarios
- **Cada ventana mantiene su propio estado de navegación**

```swift
// Cada WindowGroup es una ventana independiente
@main
struct EduGoApp: App {
    var body: some Scene {
        WindowGroup {
            AdaptiveNavigationView()
        }
        
        // Ventana adicional para feature específica (opcional)
        #if os(macOS) || os(iOS)
        WindowGroup(id: "material-reader") {
            MaterialReaderView()
        }
        #endif
    }
}
```

### Gestos Soportados (iPad)

| Gesto | Acción |
|-------|--------|
| **Swipe desde borde izquierdo** | Pop en detail stack |
| **Swipe desde borde izquierdo (extendido)** | Mostrar/ocultar sidebar |
| **3 dedos swipe left/right** | Navegar entre apps (sistema) |
| **Pinch to zoom** | Si está implementado en contenido |
| **Long press** | Menú contextual |
| **Apple Pencil double tap** | Cambiar herramienta (si se soporta) |
| **Hover (cursor/Pencil)** | Highlight de elementos |

---

## macOS - Navegación de Escritorio

### Características

- **Sidebar permanente:** Siempre visible (sin colapsar)
- **Toolbar nativo:** Botones y controles en top
- **Múltiples ventanas:** WindowGroup soporta instancias múltiples
- **Menu Bar:** Comandos globales de la app
- **Keyboard shortcuts:** Navegación completa por teclado
- **Right-click menus:** Menús contextuales ricos

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│ EduGo   File   Edit   View   Window   Help                  │
├─────────────────────────────────────────────────────────────┤
│ [<] [>]  🔍 Search  [☰] [⚙️]                    [-][□][×] │
├─────────┬───────────────────────────────────────────────────┤
│ Sidebar │              Content Area                          │
│         │                                                    │
│ 🏠 Home │                                                    │
│ 📚 Curs.│          Detail View Principal                     │
│ 📅 Cal. │                                                    │
│ 📊 Prog.│                                                    │
│ 👥 Com. │                                                    │
│ ⚙️ Set. │                                                    │
│         │                                                    │
│ ─────── │                                                    │
│ Logout  │                                                    │
└─────────┴───────────────────────────────────────────────────┘
```

### Código de Implementación

```swift
// En AdaptiveNavigationView, el tabletNavigation también sirve para Mac
// pero con customizaciones adicionales

private var tabletNavigation: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
        sidebarContent
    } detail: {
        destination(for: selectedRoute)
            .navigationTitle(navigationTitle)
            #if os(macOS)
            .toolbar {
                macOSToolbar
            }
            #endif
    }
}
```

### Sidebar (macOS)

```swift
private var sidebarContent: some View {
    List {
        Section("Navegación") {
            ForEach(Route.allCases) { route in
                NavigationLink(value: route) {
                    Label(route.displayName, systemImage: route.iconName)
                }
                .tag(route)
            }
        }
        
        Section("Cuenta") {
            Button(role: .destructive) {
                Task { await performLogout() }
            } label: {
                Label("Cerrar Sesión", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }
    .navigationTitle("EduGo")
    .listStyle(.sidebar)  // Estilo específico de macOS
    .frame(minWidth: 200)
}
```

### Toolbar (macOS)

```swift
#if os(macOS)
@ToolbarContentBuilder
private var macOSToolbar: some ToolbarContent {
    // Leading
    ToolbarItemGroup(placement: .navigation) {
        // Botón sidebar toggle
        Button {
            MacOSWindowControls.toggleSidebar()
        } label: {
            Image(systemName: "sidebar.left")
        }
        .help("Mostrar/Ocultar Sidebar")
    }
    
    // Center
    ToolbarItemGroup(placement: .principal) {
        // Búsqueda
        TextField("Buscar...", text: $searchQuery)
            .textFieldStyle(.roundedBorder)
            .frame(width: 300)
    }
    
    // Trailing
    ToolbarItemGroup(placement: .primaryAction) {
        // Refresh
        Button {
            Task { await refreshCurrentView() }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .help("Actualizar (⌘R)")
        
        // Settings
        Button {
            selectedRoute = .settings
        } label: {
            Image(systemName: "gear")
        }
        .help("Configuración (⌘,)")
    }
}
#endif
```

### Menu Bar Commands

```swift
@main
struct EduGoApp: App {
    var body: some Scene {
        WindowGroup {
            AdaptiveNavigationView()
        }
        .commands {
            // File menu
            CommandGroup(replacing: .newItem) {
                Button("Nuevo Material...") {
                    // Acción
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            // Edit menu (estándar)
            // View menu
            CommandMenu("Vista") {
                Button("Inicio") {
                    // Navegar a home
                }
                .keyboardShortcut("1", modifiers: .command)
                
                Button("Cursos") {
                    // Navegar a courses
                }
                .keyboardShortcut("2", modifiers: .command)
                
                Divider()
                
                Button("Actualizar") {
                    // Refresh
                }
                .keyboardShortcut("r", modifiers: .command)
            }
            
            // Window menu (estándar con minimizar, zoom, etc.)
            
            // Help menu
            CommandGroup(replacing: .help) {
                Button("Ayuda de EduGo") {
                    // Abrir ayuda
                }
                Link("Visitar Sitio Web", destination: URL(string: "https://edugo.com")!)
            }
        }
    }
}
```

### Keyboard Shortcuts

| Atajo | Acción |
|-------|--------|
| **⌘1, ⌘2, ..., ⌘6** | Navegar entre secciones (Home, Courses, etc.) |
| **⌘N** | Nuevo (material, curso, etc., según contexto) |
| **⌘R** | Refresh vista actual |
| **⌘F** | Buscar |
| **⌘,** | Abrir Settings |
| **⌘W** | Cerrar ventana |
| **⌘Q** | Salir de la app |
| **⌘[** | Navegar atrás |
| **⌘]** | Navegar adelante |
| **Space** | Quick Look (si aplica) |
| **⌘↑/↓** | Scroll rápido |

```swift
// Implementación de shortcuts
.keyboardShortcut("1", modifiers: .command)
.keyboardShortcut("r", modifiers: .command)

// En SwiftUI
.onKeyPress(.return) {
    // Acción para Enter
    return .handled
}
```

### Múltiples Ventanas

```swift
// Abrir nueva ventana desde menú o código
Button("Nueva Ventana") {
    #if os(macOS)
    NSWorkspace.shared.open(URL(string: "edugo://new-window")!)
    #endif
}

// O usando OpenWindowAction (macOS 13+)
@Environment(\.openWindow) private var openWindow

Button("Abrir Material en Nueva Ventana") {
    openWindow(id: "material-reader", value: materialId)
}
```

### Right-Click Menus

```swift
// En cualquier elemento
.contextMenu {
    Button("Abrir") {
        // Acción
    }
    Button("Abrir en Nueva Ventana") {
        // Acción
    }
    Divider()
    Button("Compartir") {
        // Acción
    }
    Button("Copiar Link") {
        // Acción
    }
}
```

### Preferencias (Settings)

```swift
@main
struct EduGoApp: App {
    var body: some Scene {
        WindowGroup {
            AdaptiveNavigationView()
        }
        
        #if os(macOS)
        Settings {
            MacOSSettingsView()
                .frame(width: 600, height: 400)
        }
        #endif
    }
}

// MacOSSettingsView con TabView para categorías
struct MacOSSettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            AccountSettingsView()
                .tabItem {
                    Label("Cuenta", systemImage: "person.circle")
                }
            
            NotificationsSettingsView()
                .tabItem {
                    Label("Notificaciones", systemImage: "bell")
                }
        }
        .padding()
    }
}
```

### Window Controls

```swift
// Controles específicos de macOS
struct MacOSWindowControls {
    static func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)),
            with: nil
        )
        #endif
    }
    
    static func minimizeWindow() {
        #if os(macOS)
        NSApp.keyWindow?.miniaturize(nil)
        #endif
    }
    
    static func zoomWindow() {
        #if os(macOS)
        NSApp.keyWindow?.zoom(nil)
        #endif
    }
}
```

---

## visionOS - Navegación Espacial

### Características

- **Window Groups:** Ventanas flotantes en el espacio 3D
- **Volúmenes:** Contenido 3D inmersivo
- **Gestos de mirada:** Eye tracking para navegación
- **Hand gestures:** Pinch, tap en el aire
- **Navegación espacial:** Profundidad y posición en el espacio

### Layout Conceptual

```
     ┌─────────────┐
     │   Window 1  │  (Home)
     │   EduGo     │
     │             │
     └─────────────┘
  
          ↗️              ↖️
         
┌─────────────┐      ┌─────────────┐
│   Window 2  │      │   Window 3  │
│   Courses   │      │   Progress  │
│             │      │   Graph 3D  │
└─────────────┘      └─────────────┘
```

### Código de Implementación

```swift
// En AdaptiveNavigationView
#if os(visionOS)
private var spatialNavigation: some View {
    // Similar a iPad pero con consideraciones espaciales
    NavigationSplitView {
        sidebarContent
    } detail: {
        destination(for: selectedRoute)
            .navigationTitle(navigationTitle)
    }
    // visionOS maneja el posicionamiento 3D automáticamente
}
#endif
```

### Window Groups

```swift
@main
struct EduGoApp: App {
    var body: some Scene {
        // Ventana principal
        WindowGroup {
            AdaptiveNavigationView()
        }
        
        #if os(visionOS)
        // Ventana para vista 3D de progreso
        WindowGroup(id: "progress-3d") {
            Progress3DView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 0.6, depth: 0.4, in: .meters)
        
        // Espacio inmersivo para experiencia completa
        ImmersiveSpace(id: "immersive-learning") {
            ImmersiveLearningView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        #endif
    }
}
```

### Navegación entre Ventanas

```swift
@Environment(\.openWindow) private var openWindow
@Environment(\.dismissWindow) private var dismissWindow
@Environment(\.openImmersiveSpace) private var openImmersiveSpace

// Abrir ventana 3D
Button("Ver Progreso en 3D") {
    openWindow(id: "progress-3d")
}

// Abrir espacio inmersivo
Button("Modo Inmersivo") {
    Task {
        await openImmersiveSpace(id: "immersive-learning")
    }
}

// Cerrar ventana
Button("Cerrar") {
    dismissWindow(id: "progress-3d")
}
```

### Gestos Espaciales

| Gesto | Acción |
|-------|--------|
| **Mirada + Pinch** | Seleccionar/tap en elemento |
| **Mirada + Doble Pinch** | Double tap |
| **Pinch y arrastrar** | Scroll |
| **Mano abierta → cerrada** | Grab (si se implementa) |
| **Rotar manos** | Rotar objeto 3D |

### Ornaments (Controles Flotantes)

```swift
.ornament(attachmentAnchor: .scene(.bottom)) {
    HStack {
        Button {
            // Acción
        } label: {
            Image(systemName: "play.fill")
        }
        
        Button {
            // Acción
        } label: {
            Image(systemName: "pause.fill")
        }
    }
    .padding()
    .glassBackgroundEffect()
}
```

### Consideraciones de Diseño

1. **Profundidad:** Usar `.padding3D()` para separación en Z
2. **Glass Material:** `.glassBackgroundEffect()` para ventanas
3. **Tamaños:** Usar unidades físicas (metros) para volúmenes
4. **Accesibilidad:** Siempre soportar control por voz y switch control

---

## Gestos y Atajos

### Tabla Completa de Gestos

| Plataforma | Gesto | Acción |
|------------|-------|--------|
| **iPhone** | Swipe desde borde izquierdo | Back (pop) |
| | Pull down desde top | Refresh |
| | Long press | Menú contextual |
| | Tap en TabBar activo | Scroll to top + pop to root |
| **iPad** | Swipe desde borde izq. | Back (pop) |
| | Swipe borde izq. extendido | Toggle sidebar |
| | 3 dedos swipe left/right | Cambiar app (sistema) |
| | Apple Pencil double tap | Cambiar herramienta |
| | Hover | Highlight |
| **macOS** | Click | Seleccionar |
| | Double click | Abrir |
| | Right click | Menú contextual |
| | CMD+Click | Abrir en nueva ventana |
| | Trackpad gestures | Scroll, zoom, swipe |
| **visionOS** | Mirada + Pinch | Tap |
| | Mirada + Doble Pinch | Double tap |
| | Pinch y arrastrar | Scroll/Drag |

### Keyboard Shortcuts (iPad con teclado + macOS)

```swift
// Navegación principal
CMD + 1 → Home
CMD + 2 → Courses
CMD + 3 → Calendar
CMD + 4 → Progress
CMD + 5 → Community
CMD + 6 → Settings

// Acciones
CMD + N → Nuevo (contexto dependiente)
CMD + R → Refresh
CMD + F → Buscar
CMD + , → Settings
CMD + W → Cerrar ventana (macOS)
CMD + Q → Salir (macOS)

// Navegación en stack
CMD + [ → Back
CMD + ] → Forward

// Edición
CMD + C → Copiar
CMD + V → Pegar
CMD + Z → Deshacer
CMD + Shift + Z → Rehacer

// Otros
Space → Quick Look (macOS)
Esc → Cerrar modal/alert
```

### Implementación de Shortcuts

```swift
// SwiftUI nativo
Button("Actualizar") {
    refresh()
}
.keyboardShortcut("r", modifiers: .command)

// O con onKeyPress (iOS 17+)
.onKeyPress(.return) {
    submitForm()
    return .handled
}

// Detectar modificadores
.onKeyPress(characters: .alphanumerics, phases: .down) { press in
    if press.modifiers.contains(.command) {
        // CMD está presionado
    }
    return .handled
}
```

---

## Persistencia de Estado

### Estado que se Persiste

1. **Tab/Ruta seleccionada:** Usuario regresa donde estaba
2. **Sidebar visible/oculta:** En iPad/Mac
3. **Scroll position:** En listas largas
4. **Filtros y búsqueda:** Durante la sesión
5. **Preferencias de UI:** Tema, tamaño de fuente, etc.

### Implementación

```swift
// Persistir tab seleccionado
@AppStorage("lastSelectedRoute") private var lastRoute: String = "home"

@State private var selectedRoute: Route = .home

.onAppear {
    if let route = Route(rawValue: lastRoute) {
        selectedRoute = route
    }
}

.onChange(of: selectedRoute) { oldValue, newValue in
    lastRoute = newValue.rawValue
}

// Persistir visibilidad de sidebar
@AppStorage("sidebarVisible") private var sidebarVisible: Bool = true

@State private var columnVisibility: NavigationSplitViewVisibility = .automatic

.onAppear {
    columnVisibility = sidebarVisible ? .all : .detailOnly
}

.onChange(of: columnVisibility) { oldValue, newValue in
    sidebarVisible = (newValue == .all)
}

// Persistir scroll position (más complejo)
@State private var scrollPosition: String?

ScrollViewReader { proxy in
    List {
        ForEach(items) { item in
            ItemView(item: item)
                .id(item.id)
        }
    }
    .onAppear {
        if let savedPosition = scrollPosition {
            proxy.scrollTo(savedPosition)
        }
    }
}
```

### SceneStorage (por Ventana)

```swift
// Para estado que debe ser independiente por ventana
@SceneStorage("selectedCourse") private var selectedCourseId: String?

// Cada ventana tendrá su propio valor de selectedCourseId
```

---

## Transiciones y Animaciones

### Transiciones por Plataforma

**iPhone:**
```swift
// Push: Slide from right
.navigationTransition(.slide)

// Modal: Slide from bottom
.sheet(isPresented: $showingSheet) {
    ContentView()
}

// Fullscreen: Slide from bottom sin card
.fullScreenCover(isPresented: $showingFullscreen) {
    ContentView()
}
```

**iPad:**
```swift
// Modal: Form sheet (card centered)
.sheet(isPresented: $showingSheet) {
    ContentView()
        .presentationDetents([.medium, .large])
}

// Popover: Flecha apuntando al origen
.popover(isPresented: $showingPopover) {
    ContentView()
}

// Sidebar change: Fade en detail view
.animation(.easeInOut, value: selectedRoute)
```

**macOS:**
```swift
// Nuevas ventanas: Fade in
.animation(.easeIn(duration: 0.2))

// Modal: Sheet que baja desde título
.sheet(isPresented: $showingSheet) {
    ContentView()
        .frame(width: 600, height: 400)
}

// Sidebar change: Instant (sin animación por defecto)
```

**visionOS:**
```swift
// Nuevas ventanas: Fade + scale
.transition(.scale.combined(with: .opacity))

// Espacios inmersivos: Dissolve
.animation(.easeInOut(duration: 0.5))
```

### Animaciones Personalizadas

```swift
// Spring animation para interacciones naturales
.animation(.spring(response: 0.3, dampingFraction: 0.7))

// Ease in/out para transiciones suaves
.animation(.easeInOut(duration: 0.25))

// Custom timing
.animation(.timingCurve(0.2, 0.8, 0.2, 1.0, duration: 0.4))

// Desactivar animación para cambios específicos
.transaction { transaction in
    transaction.animation = nil
}
```

### Loading States

```swift
// Skeleton views
if isLoading {
    SkeletonView()
        .transition(.opacity)
} else {
    ContentView()
        .transition(.opacity)
}

// Progress view
if isLoading {
    ProgressView()
        .progressViewStyle(CircularProgressViewStyle())
}

// Shimmer effect (custom)
.overlay {
    if isLoading {
        ShimmerView()
    }
}
```

---

## Resumen de Diferencias por Plataforma

| Característica | iPhone | iPad | macOS | visionOS |
|----------------|--------|------|-------|----------|
| **Navegación** | TabView | NavigationSplitView | NavigationSplitView | NavigationSplitView + Spatial |
| **Sidebar** | ❌ No | ✅ Colapsable | ✅ Permanente | ✅ Flotante |
| **Toolbar** | Navigation Bar | Navigation Bar | Native Toolbar | Ornaments |
| **Múltiples ventanas** | ❌ No | ✅ Stage Manager | ✅ Sí | ✅ Spatial |
| **Keyboard shortcuts** | ⚠️ Externo | ✅ Sí | ✅ Sí | ⚠️ Bluetooth |
| **Gestos principales** | Touch | Touch + Pencil | Mouse/Trackpad | Mirada + Manos |
| **Menu bar** | ❌ No | ❌ No | ✅ Sí | ❌ No |
| **Hover effects** | ❌ No | ⚠️ Cursor/Pencil | ✅ Sí | ✅ Mirada |
| **Orientación** | Portrait/Landscape | Todas | Landscape | N/A |
| **Safe areas** | Notch, Home bar | Bordes | Ventana | Ventana 3D |

---

## Próximos Pasos

1. **Handoff entre dispositivos:** Continuar actividad en otro dispositivo
2. **Widgets:** Información rápida en home screen
3. **Live Activities:** Actualizaciones en tiempo real (ej: quiz en progreso)
4. **App Clips:** Mini experiencia sin instalación completa
5. **Siri Shortcuts:** Automatizaciones de usuario
6. **Continuity Camera:** Usar iPhone como cámara en Mac
7. **Universal Control:** Compartir teclado/mouse entre dispositivos

---

**Documentos Relacionados:**
- [FLUJO-ESTUDIANTE.md](./FLUJO-ESTUDIANTE.md)
- [FLUJO-DOCENTE.md](./FLUJO-DOCENTE.md)
- [FLUJO-ADMIN.md](./FLUJO-ADMIN.md)
- [/Users/jhoanmedina/source/EduGo/EduUI/apple-app/docs/guides/architecture-patterns.md](../../../../../../EduUI/apple-app/docs/guides/architecture-patterns.md)
