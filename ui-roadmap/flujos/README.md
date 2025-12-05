# Flujos de Navegación - EduGo Apple App

**Fecha:** 1 de Diciembre, 2025  
**Proyecto:** EduGo  
**Plataformas:** iOS, iPadOS, macOS, visionOS

---

## 📚 Descripción

Esta carpeta contiene la documentación completa de los flujos de navegación de la app Apple de EduGo, diseñada con arquitectura multiplataforma usando SwiftUI.

La app soporta **cuatro plataformas** (iPhone, iPad, macOS, visionOS) con navegación adaptativa según el dispositivo y **cuatro roles de usuario** (estudiante, docente, administrador, tutor).

---

## 📑 Documentos

### Por Rol de Usuario

| Documento | Descripción | Tamaño |
|-----------|-------------|--------|
| **[FLUJO-ESTUDIANTE.md](./FLUJO-ESTUDIANTE.md)** | Flujo completo del estudiante: cursos, materiales, quizzes, progreso, comunidad | 21 KB |
| **[FLUJO-DOCENTE.md](./FLUJO-DOCENTE.md)** | Flujo del docente: incluye estudiante + gestión de contenido, seguimiento de alumnos, estadísticas | 26 KB |
| **[FLUJO-ADMIN.md](./FLUJO-ADMIN.md)** | Flujo del administrador: gestión de escuelas, usuarios, árbol académico, membresías | 44 KB |

### Por Plataforma

| Documento | Descripción | Tamaño |
|-----------|-------------|--------|
| **[NAVEGACION-PLATAFORMA.md](./NAVEGACION-PLATAFORMA.md)** | Detalles de navegación por plataforma: iPhone (TabView), iPad (Sidebar), macOS (Toolbar), visionOS (Spatial) | 35 KB |

---

## 🎯 Uso Recomendado

### Para Desarrolladores

1. **Inicio de Proyecto:**
   - Leer [NAVEGACION-PLATAFORMA.md](./NAVEGACION-PLATAFORMA.md) para entender el sistema adaptativo
   - Revisar `PlatformCapabilities` para detección de plataforma

2. **Implementar Navegación:**
   - Usar `AdaptiveNavigationView` como punto de entrada
   - Adaptar según `recommendedNavigationStyle`

3. **Por Rol:**
   - Implementar flujo estudiante → [FLUJO-ESTUDIANTE.md](./FLUJO-ESTUDIANTE.md)
   - Extender para docente → [FLUJO-DOCENTE.md](./FLUJO-DOCENTE.md)
   - Añadir panel admin → [FLUJO-ADMIN.md](./FLUJO-ADMIN.md)

### Para Diseñadores

1. **Comprender Patrones:**
   - iPhone: TabBar + Navigation Stack
   - iPad: Sidebar colapsable + Detail
   - macOS: Sidebar permanente + Toolbar
   - visionOS: Window Groups + Gestos espaciales

2. **Diseñar por Rol:**
   - Cada rol tiene vistas específicas documentadas
   - Estudiante: enfoque en consumo de contenido
   - Docente: enfoque en creación y seguimiento
   - Admin: enfoque en gestión global

### Para Product Managers

1. **Entender Alcance:**
   - 4 plataformas × 4 roles = 16 experiencias diferentes
   - Documentación completa de cada flujo

2. **Priorizar Features:**
   - Core: Flujo estudiante (todos los dispositivos)
   - Extended: Flujo docente
   - Admin: Panel completo de gestión

---

## 🗂️ Estructura de Documentación

Cada documento de flujo incluye:

### ✅ Flujos por Rol (FLUJO-*.md)

- **Diagrama de Flujo Principal:** Visualización ASCII del flujo completo
- **Estados de Navegación:** Rutas, transiciones, estados
- **Pantallas Principales:** Layout y contenido de cada vista
- **Flujos Específicos:** Casos de uso detallados (ej: lectura de material, subida de contenido)
- **Deep Links:** Esquema de URLs para navegación directa
- **Navegación Back:** Gestión del stack de navegación
- **Permisos:** Capacidades por rol

### ✅ Navegación por Plataforma (NAVEGACION-PLATAFORMA.md)

- **Sistema de Detección:** `PlatformCapabilities`
- **iPhone:** TabView, gestos táctiles, orientaciones
- **iPad:** NavigationSplitView, sidebar colapsable, Apple Pencil, Stage Manager
- **macOS:** Toolbar, keyboard shortcuts, múltiples ventanas, menu bar
- **visionOS:** Window groups, gestos espaciales, ornaments
- **Gestos y Atajos:** Tabla completa por plataforma
- **Persistencia de Estado:** Qué se guarda y cómo
- **Transiciones:** Animaciones por plataforma

---

## 🔑 Conceptos Clave

### Arquitectura de Navegación

```
AdaptiveNavigationView (Root)
├── AuthenticationState
│   ├── unauthenticated → LoginView
│   └── authenticated → AuthenticatedApp
│
└── AuthenticatedApp
    ├── PlatformCapabilities.recommendedNavigationStyle
    │   ├── .tabs → TabView (iPhone)
    │   ├── .sidebar → NavigationSplitView (iPad/Mac)
    │   └── .spatial → WindowGroup (visionOS)
    │
    └── NavigationCoordinator
        └── NavigationPath (stack de navegación)
```

### Roles de Usuario

```swift
enum UserRole: String, Codable {
    case student    // Consumidor de contenido
    case teacher    // Creador de contenido + seguimiento
    case admin      // Gestión global del sistema
    case parent     // Supervisor de estudiantes (futuro)
}
```

### Rutas de Navegación

```swift
enum Route: Hashable, Sendable {
    case login
    case home
    case courses
    case calendar
    case progress
    case community
    case settings
    
    // Exclusivos docente:
    case students
    case contentManage
    
    // Exclusivos admin:
    case schools
    case users
    case academicTree
    case memberships
    case reports
}
```

---

## 📊 Estadísticas de Documentación

| Métrica | Valor |
|---------|-------|
| **Total de documentos** | 4 |
| **Tamaño total** | ~126 KB |
| **Diagramas ASCII** | 15+ |
| **Flujos documentados** | 25+ |
| **Deep links** | 50+ |
| **Gestos documentados** | 30+ |
| **Keyboard shortcuts** | 20+ |

---

## 🚀 Próximos Pasos

### Implementación

1. **Fase 1: Core Navigation (iPhone)**
   - [ ] Implementar TabView
   - [ ] Rutas básicas (home, courses, settings)
   - [ ] Navigation Stack
   - [ ] Flujo estudiante básico

2. **Fase 2: iPad Support**
   - [ ] NavigationSplitView
   - [ ] Sidebar colapsable
   - [ ] Adaptación de vistas para pantalla grande
   - [ ] Apple Pencil support

3. **Fase 3: macOS Support**
   - [ ] Toolbar nativo
   - [ ] Keyboard shortcuts
   - [ ] Menu bar commands
   - [ ] Múltiples ventanas

4. **Fase 4: Roles Extendidos**
   - [ ] Flujo docente
   - [ ] Flujo admin
   - [ ] Gestión de permisos

5. **Fase 5: visionOS (Futuro)**
   - [ ] Window groups
   - [ ] Gestos espaciales
   - [ ] Experiencias 3D

### Documentación

- [ ] Guía de implementación paso a paso
- [ ] Diagramas de arquitectura (Mermaid o PlantUML)
- [ ] Screenshots de referencia
- [ ] Videos de demostración de flujos
- [ ] Guía de testing de navegación

---

## 📖 Referencias

### Código de Referencia

- **Navegación adaptativa:** `/Users/jhoanmedina/source/EduGo/EduUI/apple-app/apple-app/Presentation/Navigation/AdaptiveNavigationView.swift`
- **Detección de plataforma:** `/Users/jhoanmedina/source/EduGo/EduUI/apple-app/Packages/EduGoDesignSystem/Sources/EduGoDesignSystem/Platform/PlatformCapabilities.swift`
- **Rutas:** `/Users/jhoanmedina/source/EduGo/EduUI/apple-app/apple-app/Presentation/Navigation/Route.swift`
- **Estado de autenticación:** `/Users/jhoanmedina/source/EduGo/EduUI/apple-app/apple-app/Presentation/Navigation/AuthenticationState.swift`

### Documentación Externa

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)
- [visionOS Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/designing-for-visionos)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 🤝 Contribución

Para actualizar esta documentación:

1. Mantener coherencia con el formato existente
2. Incluir diagramas ASCII para flujos
3. Documentar casos edge
4. Actualizar este README si se agregan documentos

---

**Última actualización:** 1 de Diciembre, 2025  
**Mantenido por:** Equipo de Desarrollo EduGo  
**Contacto:** dev@edugo.com
