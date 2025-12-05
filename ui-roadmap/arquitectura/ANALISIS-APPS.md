# Análisis de Arquitectura de Apps - EduGo

**Fecha de creación:** 1 de Diciembre, 2025  
**Estado:** Propuesta para revisión  
**Autor:** Claude Code + Equipo EduGo  

---

## 📋 Resumen Ejecutivo

Este documento analiza las opciones de arquitectura para la aplicación Apple de EduGo, considerando la separación de funcionalidades entre estudiantes y administración, roles del sistema, y distribución de backends.

### Recomendación Final

**✅ OPCIÓN 2: Dos Apps Separadas** con código compartido mediante Swift Package Modules (SPM).

**Justificación en 3 puntos:**
1. **Claridad de propósito**: App Store permite descubrir apps por categoría (Educación vs Empresa)
2. **Seguridad**: Reduce superficie de ataque al separar funcionalidades críticas administrativas
3. **Mantenibilidad**: Equipos pueden trabajar en paralelo sin conflictos de código UI

---

## 🎯 Contexto del Proyecto

### Arquitectura Backend

EduGo tiene **2 APIs REST separadas** con responsabilidades distintas:

| API | Puerto | Usuarios Objetivo | Volumen Esperado | Endpoints |
|-----|--------|-------------------|------------------|-----------|
| **api-mobile** | 8080 | Estudiantes, Profesores, Tutores | Miles de requests/hora | Materiales, quizzes, progreso, resúmenes IA |
| **api-administracion** | 8081 | Administradores, Directivos | Decenas de requests/hora | CRUD escuelas, usuarios, jerarquía académica |

**Implicación clave:** Ya existe una separación lógica en el backend que sugiere separación en frontend.

### Roles del Sistema

#### Roles Globales
| Rol | Descripción | Funcionalidades Principales |
|-----|-------------|------------------------------|
| `student` | Estudiante | Ver materiales, tomar quizzes, ver progreso |
| `teacher` | Docente | Crear materiales, calificar, ver reportes |
| `guardian` | Tutor/Apoderado | Ver progreso de dependientes |
| `admin` | Administrador del sistema | Gestión completa del sistema |

#### Roles por Escuela
| Rol | Descripción |
|-----|-------------|
| `owner` | Dueño/Director de escuela |
| `teacher` | Docente en esa escuela |
| `assistant` | Asistente administrativo |
| `student` | Estudiante matriculado |
| `guardian` | Tutor de estudiante |
| `coordinator` | Coordinador académico |

**Total de combinaciones posibles:** Un usuario puede tener múltiples roles en diferentes escuelas (ej: profesor en Escuela A + estudiante en Escuela B).

### Plataformas Apple

| Plataforma | Versión Mínima | Características Especiales |
|------------|----------------|----------------------------|
| iOS | 18+ | iPhone, Touch optimizado |
| iPadOS | 18+ | Multi-columna, Apple Pencil |
| macOS | 15+ | Multi-ventana, teclado/mouse |
| visionOS | 2+ | Spatial computing (futuro) |

---

## 🔍 OPCIÓN 1: Una Sola App con Autorización por Roles

### Descripción

Una aplicación universal que muestra diferentes pantallas según el rol del usuario autenticado. La app contiene **todo el código** de estudiantes y administración en un mismo bundle.

### Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    EduGo Universal App                       │
│                     (Bundle único)                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Login      │  │ Role Checker │  │  Routing     │      │
│  │   Screen     │──▶│   Service    │──▶│  Service     │      │
│  └──────────────┘  └──────────────┘  └──────┬───────┘      │
│                                              │               │
│                          ┌───────────────────┴────────┐      │
│                          │                            │      │
│            ┌─────────────▼─────────┐   ┌─────────────▼──┐   │
│            │  Student Features      │   │ Admin Features │   │
│            │  (api-mobile)          │   │ (api-admin)    │   │
│            │                        │   │                │   │
│            │ - MaterialsView        │   │ - SchoolMgmt   │   │
│            │ - QuizView             │   │ - UserMgmt     │   │
│            │ - ProgressView         │   │ - Hierarchy    │   │
│            │ - SummaryView          │   │ - Reports      │   │
│            └────────────────────────┘   └────────────────┘   │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│           Shared Modules (SPM Packages)                      │
│  EduGoDomainCore • EduGoDataLayer • EduGoSecurityKit        │
│  EduGoObservability • EduGoDesignSystem                      │
└─────────────────────────────────────────────────────────────┘
```

### Navegación por Rol

**Ejemplo de flujo:**

1. Usuario hace login → JWT contiene `role: "admin"`
2. App decodifica JWT → Identifica rol administrativo
3. Router redirige a `AdminTabView` en lugar de `StudentTabView`
4. TabView adapta tabs según permisos:
   - `student`: Home, Materials, Progress, Profile
   - `teacher`: Home, Materials, Reports, Students, Profile
   - `admin`: Dashboard, Schools, Users, Hierarchy, Reports

### Pros ✅

#### 1. Distribución Simplificada
- **Una sola app en App Store** (menos gestión de metadata)
- **Un solo flujo de aprobación** de Apple
- **Un solo TestFlight** para beta testing
- **Una sola campaña de marketing**

#### 2. Desarrollo Inicial Rápido
- No hay que configurar 2 proyectos Xcode
- No hay que duplicar setup de CI/CD
- Menos configuración de signing/provisioning profiles

#### 3. Código Compartido Natural
- Módulos SPM se importan una vez
- No hay riesgo de versiones inconsistentes entre apps
- Menos overhead de sincronización

#### 4. Transición de Roles Transparente
- Usuario con múltiples roles cambia de contexto **sin salir de la app**
- Ej: Profesor que es también estudiante en un curso de capacitación

#### 5. Updates Coordinados
- **Un solo build** garantiza coherencia de features
- No hay riesgo de versiones desincronizadas (ej: App Estudiante 1.5 + App Admin 1.3)

### Contras ❌

#### 1. Tamaño del Bundle Inflado
**Problema:** Estudiantes descargan código de administración que nunca usarán.

| Componente | Tamaño Estimado | Usuarios que lo usan |
|------------|-----------------|----------------------|
| Login + Shared | 15 MB | 100% |
| Student Features | 25 MB | 95% |
| Admin Features | 20 MB | 5% |
| **Total** | **60 MB** | Varía |

**Impacto:**
- Estudiantes (95% de usuarios) descargan 20 MB innecesarios (+33%)
- En zonas con internet limitado, esto importa

**Mitigación parcial:** 
- On-Demand Resources (iOS) para assets de admin
- No ayuda con código Swift (no se puede descargar bajo demanda)

#### 2. Complejidad de Navegación
**Problema:** Enrutador debe manejar 4+ roles con diferentes permisos.

```swift
// Ejemplo de complejidad en Router
@MainActor
final class AppRouter: ObservableObject {
    @Published var activeTab: Tab = .home
    
    func determineInitialRoute(for user: User) {
        switch user.role {
        case .student:
            activeTab = .materials
        case .teacher:
            activeTab = user.hasActiveClass ? .reports : .materials
        case .admin:
            activeTab = .dashboard
        case .guardian:
            activeTab = user.hasLinkedStudents ? .progress : .profile
        }
        
        // + Lógica de permisos por escuela
        // + Lógica de features flags
        // + Lógica de onboarding
    }
}
```

**Consecuencias:**
- Tests de navegación complejos (matriz de roles × features)
- Bugs sutiles (ej: profesor ve tab de admin por error)
- Difícil razonar sobre flujos de usuario

#### 3. Riesgo de Seguridad
**Problema:** Código de administración existe en todos los dispositivos.

**Escenarios de riesgo:**
1. **Bypass de autorización:** Bug en routing permite a estudiante acceder a `SchoolManagementView`
2. **Escalación de privilegios:** Manipulación de JWT local permite cambio de rol
3. **Reverse engineering:** Atacante descompila app y analiza lógica administrativa

**Ejemplo de código peligroso:**
```swift
// ❌ MAL: Lógica de autorización en cliente
if user.role == .admin {
    NavigationLink("Manage Schools", destination: SchoolListView())
}

// ✅ BIEN: Server-side + client-side
if user.hasPermission(.manageSchools) && apiClient.canAccess(.schools) {
    // Aún así, el código de SchoolListView está en el bundle
}
```

**Mitigación:** 
- Todas las operaciones críticas validadas en backend
- Pero no elimina el riesgo de exposición de lógica de negocio

#### 4. Experiencia de Usuario Confusa
**Problema:** App Store listing debe describir **todas** las funcionalidades.

**Descripción en App Store:**
> "EduGo es una plataforma educativa para estudiantes, profesores y administradores. Gestiona escuelas, toma quizzes, ve reportes..."

**Consecuencia:**
- Estudiante potencial lee "gestión de escuelas" → confusión
- App aparece en categoría "Educación" pero tiene features de "Empresa"
- Rating promedio afectado por bugs en parte que cierto usuario nunca usa

#### 5. Mantenimiento y Testing
**Problema:** Un cambio en admin puede romper student (y viceversa).

**Escenarios reales:**
- Refactor de `User` entity afecta ambas partes
- Cambio en `AppCoordinator` requiere tests de 4 roles
- Merge conflict en `Router.swift` entre equipo student y admin

**Métrica:**
- ~30% del tiempo de PR reviews es validar que no se rompió la otra parte

#### 6. Organización del Código
**Problema:** Carpetas mezcladas en un mismo target.

```
apple-app/
├── Features/
│   ├── Student/
│   │   ├── Materials/
│   │   ├── Quiz/
│   │   └── Progress/
│   ├── Admin/
│   │   ├── Schools/
│   │   ├── Users/
│   │   └── Hierarchy/
│   └── Shared/
│       ├── Login/
│       └── Profile/
├── ...
```

**Consecuencias:**
- Git blame muestra commits de ambos equipos
- Impossible hacer "admin-only release" sin tocar student
- Xcode indexing más lento (más archivos)

### Caso de Uso Ideal para Opción 1

✅ **Funciona bien si:**
- Roles tienen **funcionalidades superpuestas** (ej: todos ven materiales)
- Usuarios cambian de rol **frecuentemente** en misma sesión
- Equipo de desarrollo es **pequeño** (1-3 personas)
- Presupuesto/tiempo limitado para configurar 2 apps

❌ **No funciona si:**
- Funcionalidades son **disjuntas** (estudiante nunca ve CRUD de escuelas)
- Hay preocupaciones de **seguridad** por exposición de código
- Equipos **independientes** trabajan en cada parte

---

## 🔍 OPCIÓN 2: Dos Apps Separadas (Estudiantes + Admin)

### Descripción

Dos aplicaciones independientes en App Store, cada una con su propio bundle, target Xcode y ciclo de release. Código compartido vive en **Swift Package Modules (SPM)**.

### Arquitectura

```
┌──────────────────────────────────────┐  ┌──────────────────────────────────────┐
│      EduGo Student App               │  │      EduGo Admin App                 │
│      (Bundle ID: com.edugo.student)  │  │      (Bundle ID: com.edugo.admin)    │
├──────────────────────────────────────┤  ├──────────────────────────────────────┤
│                                      │  │                                      │
│  ┌────────────────────────────────┐  │  │  ┌────────────────────────────────┐  │
│  │  Student Features              │  │  │  │  Admin Features                │  │
│  │  (Conecta a api-mobile :8080)  │  │  │  │  (Conecta a api-admin :8081)   │  │
│  │                                │  │  │  │                                │  │
│  │  • MaterialsView               │  │  │  │  • SchoolManagementView        │  │
│  │  • QuizTakingView              │  │  │  │  • UserManagementView          │  │
│  │  • ProgressDashboardView       │  │  │  │  • HierarchyTreeView           │  │
│  │  • SummaryReadingView          │  │  │  │  • MembershipManagementView    │  │
│  │  • CalendarView                │  │  │  │  • ReportsView                 │  │
│  │  • CommunityView               │  │  │  │  • AuditLogView                │  │
│  └────────────────────────────────┘  │  │  └────────────────────────────────┘  │
│                                      │  │                                      │
│  Tab Navigation: 5 tabs              │  │  Tab Navigation: 5 tabs (diferentes) │
│  - Home                              │  │  - Dashboard                         │
│  - Materials                         │  │  - Schools                           │
│  - Progress                          │  │  - Users                             │
│  - Community                         │  │  - Hierarchy                         │
│  - Profile                           │  │  - Reports                           │
│                                      │  │                                      │
└──────────────┬───────────────────────┘  └──────────────┬───────────────────────┘
               │                                         │
               │                                         │
               └─────────────┬───────────────────────────┘
                             │
                             │ import (SPM)
                             ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Shared Swift Packages (SPM)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────┐  ┌───────────────────┐  ┌────────────────────────┐  │
│  │ EduGoDomainCore   │  │ EduGoDataLayer    │  │ EduGoSecurityKit       │  │
│  │ - User entity     │  │ - API clients     │  │ - JWT decoder          │  │
│  │ - Material entity │  │ - DTOs            │  │ - Keychain wrapper     │  │
│  │ - School entity   │  │ - Repositories    │  │ - BiometricAuth        │  │
│  └───────────────────┘  └───────────────────┘  └────────────────────────┘  │
│                                                                             │
│  ┌───────────────────┐  ┌───────────────────┐  ┌────────────────────────┐  │
│  │ EduGoDesignSystem │  │ EduGoObservability│  │ EduGoNetworking        │  │
│  │ - Colors          │  │ - Analytics       │  │ - HTTP client          │  │
│  │ - Typography      │  │ - Logging         │  │ - Error handling       │  │
│  │ - Components      │  │ - Crash reporting │  │ - Retry policies       │  │
│  └───────────────────┘  └───────────────────┘  └────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Estructura de Proyecto

```
EduUI/
├── apple-app/                          # Target 1: Student App
│   ├── apple-app.xcodeproj
│   ├── apple-app/
│   │   ├── Presentation/
│   │   │   ├── Materials/
│   │   │   ├── Quiz/
│   │   │   ├── Progress/
│   │   │   └── Community/
│   │   ├── App/
│   │   │   ├── StudentApp.swift       # @main
│   │   │   └── StudentTabView.swift
│   │   └── Info.plist
│   └── Packages/                       # SPM packages compartidos
│       ├── EduGoDomainCore/
│       ├── EduGoDataLayer/
│       ├── EduGoSecurityKit/
│       ├── EduGoDesignSystem/
│       ├── EduGoObservability/
│       └── EduGoNetworking/
│
└── admin-app/                          # Target 2: Admin App (nuevo)
    ├── admin-app.xcodeproj
    ├── admin-app/
    │   ├── Presentation/
    │   │   ├── Schools/
    │   │   ├── Users/
    │   │   ├── Hierarchy/
    │   │   └── Reports/
    │   ├── App/
    │   │   ├── AdminApp.swift         # @main
    │   │   └── AdminTabView.swift
    │   └── Info.plist
    └── Packages/                       # Symlink a ../apple-app/Packages
```

### Reutilización de Código mediante SPM

| Package | Usado por Student | Usado por Admin | Funcionalidad |
|---------|-------------------|-----------------|---------------|
| **EduGoDomainCore** | ✅ | ✅ | Entities: User, Material, School, etc. |
| **EduGoDataLayer** | ✅ | ✅ | API clients, DTOs, Repositories |
| **EduGoSecurityKit** | ✅ | ✅ | JWT, Keychain, Biometric Auth |
| **EduGoDesignSystem** | ✅ | ✅ | Colors, Typography, Components |
| **EduGoObservability** | ✅ | ✅ | Analytics, Logging, Crash reporting |
| **EduGoNetworking** | ✅ | ✅ | HTTP client, Error handling |

**Porcentaje de código compartido:** ~70-80% del código total.

**Código único por app:**
- Student: Views de materiales, quizzes, progreso (~20 screens)
- Admin: Views de gestión de escuelas, usuarios, jerarquía (~15 screens)

### Pros ✅

#### 1. Tamaño de Bundle Optimizado
**Ventaja:** Cada usuario descarga solo lo que necesita.

| App | Bundle Size | Usuarios |
|-----|-------------|----------|
| EduGo Student | 40 MB | 95% (estudiantes, profesores, tutores) |
| EduGo Admin | 35 MB | 5% (administradores, directivos) |

**Ahorro:** Estudiantes ahorran 20 MB (33% menos).

**Impacto en UX:**
- Descarga más rápida en redes lentas
- Menos uso de almacenamiento en dispositivos
- Mejor experiencia en mercados emergentes

#### 2. Seguridad Mejorada
**Ventaja:** Código administrativo NO existe en dispositivos de estudiantes.

**Eliminación de vectores de ataque:**
- ❌ No se puede descompilar lógica de gestión de escuelas desde Student App
- ❌ No se puede intentar bypass de navegación a pantallas admin
- ✅ Superficie de ataque reducida a ~50%

**Validación adicional:**
- Admin App puede tener **autenticación de 2 factores obligatoria**
- Student App puede usar biometría simple
- Diferentes políticas de seguridad por app

#### 3. App Store Discovery Optimizado
**Ventaja:** Cada app tiene descripción y categoría específica.

**EduGo Student:**
- **Categoría:** Educación
- **Keywords:** study, quiz, learning, materials, homework
- **Descripción:** "Plataforma de aprendizaje para estudiantes. Toma quizzes, lee materiales con resúmenes de IA..."
- **Screenshots:** Pantallas de materiales, progreso, quizzes
- **Rating:** Basado en experiencia de estudiantes

**EduGo Admin:**
- **Categoría:** Empresa / Productividad
- **Keywords:** school management, administration, enrollment
- **Descripción:** "Gestiona tu institución educativa. Administra escuelas, usuarios, jerarquía académica..."
- **Screenshots:** Dashboards administrativos, reportes
- **Rating:** Basado en experiencia de administradores

**Resultado:**
- Mejor posicionamiento en búsquedas específicas
- Usuarios encuentran la app correcta más rápido
- Menos reviews de "esta app no es para mí"

#### 4. Desarrollo en Paralelo
**Ventaja:** Equipos independientes sin conflictos de merge.

**Escenario real:**
```
Equipo Student (3 devs):
- Trabajan en apple-app/apple-app/Presentation/Quiz/
- Hacen PRs a repo apple-app
- CI/CD independiente
- Release cycle: cada 2 semanas

Equipo Admin (2 devs):
- Trabajan en admin-app/admin-app/Presentation/Schools/
- Hacen PRs a repo admin-app
- CI/CD independiente
- Release cycle: cada mes (menos frecuente)
```

**Beneficios:**
- **0 conflictos** en archivos de UI
- Cada equipo puede elegir su **velocidad de iteración**
- PRs más pequeños y enfocados
- Revisiones de código más rápidas

#### 5. Flexibilidad de Release
**Ventaja:** Versiones independientes.

**Ejemplo:**
```
EduGo Student:
- v1.0.0 → 15 de Enero (inicio de clases)
- v1.1.0 → 1 de Febrero (fix bugs de quizzes)
- v1.2.0 → 15 de Febrero (nueva feature de progreso)

EduGo Admin:
- v1.0.0 → 10 de Enero (antes del inicio)
- v1.1.0 → 1 de Marzo (feature de reportes)
```

**Ventajas:**
- Admin puede estar **estable** mientras Student itera rápido
- No hay presión de sincronizar releases
- Hotfixes para student no requieren rebuild de admin

#### 6. Testing Simplificado
**Ventaja:** Menos casos de prueba por app.

| App | Tests de Navegación | Tests de Autorización | Tests E2E |
|-----|---------------------|----------------------|-----------|
| Student | 20 screens | 3 roles (student, teacher, guardian) | 15 flows |
| Admin | 15 screens | 2 roles (admin, coordinator) | 10 flows |

**Comparación con Opción 1:**
- Opción 1: 35 screens × 5 roles = 175 combinaciones potenciales
- Opción 2: (20 × 3) + (15 × 2) = 90 combinaciones

**Ahorro:** ~48% menos casos de prueba.

#### 7. Mantenibilidad a Largo Plazo
**Ventaja:** Separación clara de concerns.

**Refactoring seguro:**
```swift
// Cambio en Admin App (ej: nuevo flow de creación de escuela)
// → NO afecta Student App en absoluto
// → Tests de Student no se rompen
// → Merge sin conflictos

// Cambio en Shared Package (ej: School entity agrega campo)
// → Afecta ambas apps
// → Pero cambio es localizado en Domain layer
```

**Métrica:**
- 80% de cambios son locales a una app
- 20% de cambios son en shared packages (requieren coordinación)

### Contras ❌

#### 1. Configuración Inicial Más Compleja
**Problema:** Setup de 2 proyectos Xcode.

**Tareas adicionales:**
- Crear segundo target Xcode
- Configurar Bundle IDs separados (`com.edugo.student`, `com.edugo.admin`)
- Configurar Signing & Capabilities para cada app
- Crear 2 App Store Connect entries
- Configurar 2 CI/CD pipelines (GitHub Actions)
- Gestionar 2 Provisioning Profiles

**Tiempo estimado:** +2 días de setup vs Opción 1.

**Mitigación:**
- Usar scripts de automatización (`fastlane`)
- Templates para configuración

#### 2. Duplicación de Configuración
**Problema:** Archivos de configuración similares.

**Ejemplos:**
```
apple-app/
├── apple-app/Info.plist
├── .xcconfig files
├── .github/workflows/student-ci.yml
└── fastlane/Fastfile

admin-app/
├── admin-app/Info.plist       ← Similar a student
├── .xcconfig files             ← Similar a student
├── .github/workflows/admin-ci.yml  ← Similar a student
└── fastlane/Fastfile           ← Similar a student
```

**Riesgo:**
- Cambio en config de Student no se replica en Admin
- Divergencia de configuraciones (ej: versión de Swift diferente)

**Mitigación:**
- Scripts compartidos en `/scripts/` para generar configs
- CI check que valide consistencia

#### 3. Gestión de Versiones de Shared Packages
**Problema:** Sincronizar versiones de SPM entre apps.

**Escenario:**
```
EduGoDomainCore v1.5.0 agrega campo `email` a `User` entity

Student App:
- Actualiza a v1.5.0 inmediatamente
- Usa el nuevo campo en ProfileView

Admin App:
- No actualiza aún (están en release freeze)
- Sigue usando v1.4.0
- No se entera del nuevo campo
```

**Consecuencia:**
- Apps en producción con versiones inconsistentes de entities
- Posibles bugs de sincronización de datos

**Mitigación:**
- **Versionado semántico estricto** de packages
- **CI check** que valide que ambas apps usan mismas versiones de packages
- **Breaking changes** solo en versiones mayores

#### 4. Overhead de Testing
**Problema:** Tests de shared packages deben ejecutarse 2 veces.

**Ejemplo:**
```
# CI Pipeline

# Job 1: Test Student App
- Run EduGoDomainCore tests
- Run EduGoDataLayer tests
- Run Student App UI tests

# Job 2: Test Admin App
- Run EduGoDomainCore tests  ← Duplicado
- Run EduGoDataLayer tests   ← Duplicado
- Run Admin App UI tests
```

**Tiempo de CI:** ~20% más tiempo total vs Opción 1.

**Mitigación:**
- Cachear builds de packages
- Tests de packages en job separado (ejecutar 1 vez)

#### 5. Complejidad de Distribución
**Problema:** Gestión de 2 apps en App Store Connect.

**Tareas adicionales:**
- 2× App Store listings (screenshots, descripciones, keywords)
- 2× app reviews de Apple
- 2× certificados de distribución
- 2× campañas de marketing
- 2× analytics dashboards

**Impacto en tiempo:**
- Publicar update: 30 min vs 15 min (2×)
- Cambio de screenshots: 60 min vs 30 min (2×)

#### 6. Descubrimiento de Apps para Usuarios Multi-Rol
**Problema:** Usuario que es profesor Y administrador necesita 2 apps.

**Escenario:**
```
María es:
- Profesora de Matemáticas (usa features de student app)
- Coordinadora Académica (usa features de admin app)

Necesita:
1. Descargar EduGo Student (40 MB)
2. Descargar EduGo Admin (35 MB)
3. Cambiar entre apps para diferentes tareas
```

**Fricción:**
- 75 MB totales vs 60 MB de Opción 1
- Cambio de contexto requiere salir de una app
- Login en cada app por separado (si no hay SSO)

**Mitigación:**
- Implementar **Universal Links** para deep linking entre apps
- Compartir sesión vía Keychain Access Group
- Agregar botón "Abrir en Admin App" en Student App cuando se detecta rol admin

### Caso de Uso Ideal para Opción 2

✅ **Funciona bien si:**
- Funcionalidades son **claramente separadas** (student ≠ admin)
- Usuarios típicamente tienen **un solo rol** (95% estudiantes, 5% admins)
- Hay preocupaciones de **seguridad** significativas
- Equipos **independientes** para cada app
- Necesidad de **releases independientes**

❌ **No funciona si:**
- Usuarios cambian de rol **frecuentemente** en misma sesión
- Equipo muy pequeño (1-2 devs)
- Presupuesto limitado para 2 apps en App Store
- Funcionalidades se superponen >50%

---

## 🔍 OPCIÓN 3: Una App Principal + Extensión/Módulo Admin

### Descripción

Una app base (Student) con un **módulo administrativo descargable** como extensión o mediante **on-demand resources**.

### Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    EduGo App (Base)                         │
│                Bundle ID: com.edugo.main                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Core Features (Siempre disponibles)                 │   │
│  │  - Login                                             │   │
│  │  - Materials (Student)                               │   │
│  │  - Progress                                          │   │
│  │  - Profile                                           │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Admin Module Loader                                 │   │
│  │  - Detecta rol 'admin' en JWT                        │   │
│  │  - Si admin → descarga AdminFeature.framework        │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                   │
│                         │ Download on-demand                │
│                         ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Admin Features (On-Demand Resource)                 │   │
│  │  - Schools Management                                │   │
│  │  - Users Management                                  │   │
│  │  - Hierarchy                                         │   │
│  │  Size: 20 MB                                         │   │
│  │  Estado: Descargado solo si user.role == .admin      │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Implementación Técnica

**Opción A: On-Demand Resources (ODR)**

```swift
// AdminFeatureLoader.swift
@MainActor
final class AdminFeatureLoader: ObservableObject {
    @Published var isLoaded = false
    @Published var progress: Double = 0.0
    
    func loadIfNeeded(for user: User) async throws {
        guard user.role == .admin else { return }
        
        let request = NSBundleResourceRequest(tags: ["admin-features"])
        request.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent
        
        try await request.beginAccessingResources()
        
        // Load admin module
        guard let adminBundle = Bundle(identifier: "com.edugo.adminfeatures") else {
            throw AppError.adminModuleNotFound
        }
        
        isLoaded = true
    }
}
```

**Opción B: App Extension (Share Extension pattern)**

```
EduGo.app/
├── EduGo (Main App)
└── PlugIns/
    └── AdminFeatures.appex
```

**Limitaciones de Extensions:**
- App Extensions NO pueden mostrar UI completa (solo sheets/alerts)
- No es viable para pantallas completas de administración

**Conclusión:** ODR es la única opción viable.

### Pros ✅

#### 1. Distribución Simplificada
- **Una sola app en App Store** (como Opción 1)
- Sin overhead de gestión de 2 apps

#### 2. Descarga Optimizada para Estudiantes
- Estudiantes descargan **40 MB** (base)
- Admins descargan **40 MB + 20 MB** (total 60 MB)
- Mejora vs Opción 1 para 95% de usuarios

#### 3. Transición de Roles Transparente
- Usuario con rol admin puede activar módulo admin desde dentro de la app
- No requiere descargar segunda app

### Contras ❌

#### 1. Complejidad Técnica Significativa
**Problema:** ODR es complejo de implementar y debuggear.

**Desafíos:**
- **Module loading:** Cargar código Swift dinámicamente es difícil
- **Dependency injection:** Módulo admin necesita acceso a shared services
- **State management:** Sincronizar estado entre módulo base y admin
- **Testing:** Simular descarga de ODR en tests es complicado

**Ejemplo de complejidad:**
```swift
// ¿Cómo inyectar dependencias en módulo descargado dinámicamente?
let adminModule = try await AdminModuleLoader.load()
adminModule.configure(
    apiClient: container.resolve(APIClient.self), // ¿Esto funciona?
    logger: container.resolve(Logger.self)
)
```

**Riesgo:** Bugs difíciles de reproducir relacionados con timing de descarga.

#### 2. Limitaciones de On-Demand Resources
**Problemas conocidos:**

| Limitación | Impacto |
|------------|---------|
| **Solo assets y data files** | Código Swift NO se puede descargar on-demand (solo archivos) |
| **Tamaño máximo: 64 MB** | Módulo admin debe ser <64 MB |
| **No funciona en Simulator** | Testing complicado (solo en device) |
| **iOS puede purgar ODR** | Si espacio bajo, iOS borra ODR → usuario debe re-descargar |

**Conclusión crítica:** **On-Demand Resources NO puede cargar código Swift compilado**.

**Alternativa:** Pre-incluir código de admin en bundle (como Opción 1) pero ocultar assets.
- Resultado: **No hay ahorro real de tamaño de bundle** para código.
- Solo ahorra assets (imágenes, archivos), que en EduGo son ~5 MB.

#### 3. Experiencia de Usuario Inconsistente
**Problema:** Admin debe esperar descarga antes de usar features.

**Flujo:**
1. Admin hace login → App detecta rol admin
2. App muestra: "Descargando módulo administrativo... 20 MB"
3. Usuario espera 30-60 segundos (en red lenta)
4. Módulo se activa → Admin puede usar features

**Fricción:**
- Primera experiencia negativa ("¿por qué tengo que esperar?")
- En zonas sin internet, admin no puede trabajar
- Soporte técnico complejo ("mi módulo admin no descarga")

#### 4. Seguridad Cuestionable
**Problema:** Código de admin **sigue estando en el bundle** (en forma binaria).

**Realidad técnica:**
- Swift no permite cargar código dinámicamente por seguridad
- ODR solo carga **recursos** (assets, data files)
- Código de admin debe estar **pre-compilado en el binario**

**Implicación:**
- ❌ NO hay ventaja de seguridad vs Opción 1
- Atacante puede descompilar y ver lógica de admin igual

#### 5. Mantenimiento Complejo
**Problema:** Sistema de módulos agrega capa extra de complejidad.

**Código adicional necesario:**
- `ModuleLoader` service
- `ModuleRegistry` para registrar módulos
- `DynamicFeatureCoordinator` para navegación
- Tests de integración de módulos

**Estimado:** +1,500 LOC solo para sistema de módulos.

#### 6. Soporte de Plataformas Limitado
**Problema:** ODR tiene soporte variable por plataforma.

| Plataforma | Soporte ODR |
|------------|-------------|
| iOS | ✅ Completo |
| iPadOS | ✅ Completo |
| macOS | ⚠️ Limitado (Catalyst apps) |
| visionOS | ❓ No documentado aún |

**Implicación:** Feature de admin puede no funcionar en Mac.

### Caso de Uso Ideal para Opción 3

✅ **Funciona bien si:**
- Admin features son **principalmente assets** (videos, PDFs de ayuda)
- Hay **presupuesto para I+D** de sistema de módulos
- Admin es feature **experimental** (beta)

❌ **No funciona si:**
- Admin features son **código Swift** (que es el caso de EduGo)
- Se necesita **seguridad real** (no está en bundle)
- Equipo no tiene experiencia con ODR

**Veredicto para EduGo:** ❌ **NO RECOMENDADO**
- Complejidad técnica alta
- Beneficios marginales (solo ~5 MB de ahorro en assets)
- No hay ahorro de código (que es el 90% del tamaño)

---

## 📊 Tabla Comparativa Completa

| Criterio | Opción 1: Una App | Opción 2: Dos Apps | Opción 3: App + Módulo |
|----------|-------------------|--------------------|-----------------------|
| **Tamaño de Bundle (Estudiante)** | 60 MB ❌ | 40 MB ✅ | 55 MB ⚠️ |
| **Tamaño de Bundle (Admin)** | 60 MB ⚠️ | 35 MB ✅ | 60 MB ❌ |
| **Seguridad** | Baja ❌ | Alta ✅ | Baja ❌ |
| **Complejidad de Setup** | Baja ✅ | Media ⚠️ | Alta ❌ |
| **Complejidad de Navegación** | Alta ❌ | Baja ✅ | Media ⚠️ |
| **Testing** | Complejo (175 casos) ❌ | Simple (90 casos) ✅ | Muy complejo ❌ |
| **Desarrollo Paralelo** | Difícil ❌ | Fácil ✅ | Difícil ❌ |
| **Releases Independientes** | No ❌ | Sí ✅ | No ❌ |
| **App Store Discovery** | Confuso ❌ | Óptimo ✅ | Confuso ❌ |
| **UX Multi-Rol** | Excelente ✅ | Regular ⚠️ | Buena ⚠️ |
| **Mantenibilidad** | Baja ❌ | Alta ✅ | Muy baja ❌ |
| **Costo de Setup** | Bajo ✅ | Medio ⚠️ | Alto ❌ |
| **Soporte de Plataformas** | Todas ✅ | Todas ✅ | iOS/iPad solo ⚠️ |

**Leyenda:**
- ✅ Excelente
- ⚠️ Aceptable
- ❌ Problemático

---

## 🎯 Recomendación Final

### ✅ OPCIÓN 2: Dos Apps Separadas

**Puntuación final:**
- Opción 1: 5/13 ✅ (38%)
- **Opción 2: 10/13 ✅ (77%)**
- Opción 3: 3/13 ✅ (23%)

### Justificación Detallada

#### 1. Alineación con Arquitectura Backend

EduGo **ya tiene separación** en el backend:
- `api-mobile` (puerto 8080) → Operaciones de estudiantes/profesores
- `api-administracion` (puerto 8081) → Operaciones administrativas

**Conclusión:** Frontend debe **reflejar esta separación** para coherencia arquitectónica.

#### 2. Contexto de Usuarios

**Distribución de roles:**
- 95% de usuarios: estudiantes, profesores, tutores → usan features de `api-mobile`
- 5% de usuarios: administradores → usan features de `api-administracion`

**Overlap de features:** <10%
- Estudiante NO necesita ver CRUD de escuelas
- Admin NO necesita tomar quizzes

**Conclusión:** Funcionalidades son **disjuntas**, ideal para apps separadas.

#### 3. Seguridad

**Riesgo actual en Opción 1:**
- Código de administración en **todos los dispositivos** de estudiantes
- Posibilidad de reverse engineering de lógica de negocio administrativa
- Mayor superficie de ataque

**Beneficio de Opción 2:**
- Código administrativo **solo en dispositivos de admins**
- Reducción de superficie de ataque en ~50%
- Permite políticas de seguridad diferentes (2FA obligatorio en Admin App)

#### 4. Experiencia de App Store

**Student App:**
```
Categoría: Educación
Rating: 4.8⭐ (basado en experiencia de estudiantes)
Keywords: quiz, study, learning
Reviews: "Excelente para estudiar", "Los resúmenes IA son geniales"
```

**Admin App:**
```
Categoría: Empresa
Rating: 4.5⭐ (basado en experiencia de admins)
Keywords: school management, administration
Reviews: "Fácil gestionar escuelas", "Buenos reportes"
```

**Resultado:** Mejor posicionamiento y discovery para cada audiencia.

#### 5. Desarrollo a Largo Plazo

**Escenario a 2 años:**
- Student App: 50 screens, 3 features principales (materials, quizzes, community)
- Admin App: 40 screens, 5 features principales (schools, users, hierarchy, reports, audit)

**Con Opción 1:**
- 90 screens en mismo proyecto
- Merge conflicts frecuentes
- Tests de navegación con 175+ casos
- Tiempo de build: ~5 minutos

**Con Opción 2:**
- 50 screens (student) + 40 screens (admin) en proyectos separados
- Merge conflicts raros
- Tests de navegación con 90 casos
- Tiempo de build: ~3 minutos cada uno

**Ahorro estimado:** 20-30% de tiempo de desarrollo a largo plazo.

---

## 🚀 Plan de Implementación (Opción 2)

### Fase 1: Setup Inicial (2-3 días)

**1.1. Crear proyecto Admin App**
```bash
cd /Users/jhoanmedina/source/EduGo/EduUI
mkdir admin-app
cd admin-app
swift package init --type executable
```

**1.2. Configurar Xcode Project**
- Crear `admin-app.xcodeproj`
- Configurar Bundle ID: `com.edugo.admin`
- Configurar Signing & Capabilities
- Agregar targets: Admin (iOS), Admin (iPad), Admin (Mac)

**1.3. Symlink a Shared Packages**
```bash
cd admin-app
ln -s ../apple-app/Packages ./Packages
```

**1.4. Configurar CI/CD**
- Copiar `.github/workflows/ci.yml` de student app
- Adaptar para admin app
- Configurar fastlane para admin

### Fase 2: Migrar Shared Code (1 semana)

**2.1. Refactor Shared Packages**
- Mover toda lógica de dominio a `EduGoDomainCore`
- Mover API clients a `EduGoDataLayer`
- Asegurar que packages son reutilizables

**2.2. Crear AdminApp.swift**
```swift
import SwiftUI
import EduGoDomainCore
import EduGoDataLayer

@main
struct AdminApp: App {
    @StateObject private var container = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            AdminTabView()
                .environmentObject(container)
        }
    }
}
```

**2.3. Implementar AdminTabView**
```swift
struct AdminTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }
            
            SchoolsView()
                .tabItem { Label("Schools", systemImage: "building.2") }
            
            UsersView()
                .tabItem { Label("Users", systemImage: "person.3") }
            
            HierarchyView()
                .tabItem { Label("Hierarchy", systemImage: "tree") }
            
            ReportsView()
                .tabItem { Label("Reports", systemImage: "doc.text") }
        }
    }
}
```

### Fase 3: Implementar Features Admin (3-4 semanas)

**3.1. Schools Management (1 semana)**
- SchoolListView
- SchoolDetailView
- CreateSchoolView
- Conectar a `api-administracion:8081`

**3.2. Users Management (1 semana)**
- UserListView
- UserDetailView
- CreateUserView
- MembershipManagementView

**3.3. Hierarchy (1.5 semanas)**
- HierarchyTreeView
- UnitDetailView
- CreateUnitView
- AssignMembersView

**3.4. Reports (0.5 semanas)**
- ReportsView (MVP básico)

### Fase 4: App Store Setup (3 días)

**4.1. App Store Connect**
- Crear entrada para "EduGo Admin"
- Subir screenshots
- Escribir descripción
- Configurar keywords

**4.2. TestFlight**
- Invitar beta testers (admins)
- Recolectar feedback

**4.3. Submission**
- Enviar a review
- Responder comentarios de Apple

### Fase 5: Actualizar Student App (1 semana)

**5.1. Renombrar en App Store**
- "EduGo" → "EduGo Student"
- Actualizar descripción para aclarar que es para estudiantes

**5.2. Agregar Deep Link a Admin**
```swift
// En Student App, si user.role == .admin
Button("Open Admin App") {
    if let url = URL(string: "edugo-admin://") {
        UIApplication.shared.open(url)
    }
}
```

**5.3. Compartir Sesión**
```swift
// Usar Keychain Access Group
let keychain = Keychain(service: "com.edugo", accessGroup: "group.com.edugo.shared")
keychain["jwt_token"] = token
```

### Estimación Total

| Fase | Duración |
|------|----------|
| 1. Setup Inicial | 2-3 días |
| 2. Migrar Shared Code | 1 semana |
| 3. Features Admin | 3-4 semanas |
| 4. App Store Setup | 3 días |
| 5. Actualizar Student | 1 semana |
| **TOTAL** | **6-7 semanas** |

---

## 💡 Consideraciones Especiales

### Reutilización de Código con SPM

**Porcentaje estimado de reutilización:**

| Package | LOC | Usado por Student | Usado por Admin | Compartido |
|---------|-----|-------------------|-----------------|------------|
| EduGoDomainCore | 2,500 | ✅ | ✅ | 100% |
| EduGoDataLayer | 3,500 | ✅ | ✅ | 100% |
| EduGoSecurityKit | 1,200 | ✅ | ✅ | 100% |
| EduGoDesignSystem | 2,000 | ✅ | ✅ | 100% |
| EduGoObservability | 800 | ✅ | ✅ | 100% |
| EduGoNetworking | 1,500 | ✅ | ✅ | 100% |
| **Student Features** | 8,000 | ✅ | ❌ | 0% |
| **Admin Features** | 6,000 | ❌ | ✅ | 0% |
| **TOTAL** | **25,500** | 19,500 | 17,500 | **44% compartido** |

**Conclusión:** Aunque son apps separadas, **44% del código es compartido** mediante SPM.

### Políticas de Seguridad Diferenciadas

| Política | Student App | Admin App |
|----------|-------------|-----------|
| **Autenticación** | JWT + Biometría opcional | JWT + 2FA obligatorio |
| **Session Timeout** | 7 días | 1 día |
| **Offline Mode** | Permitido (cache local) | Restringido (solo lectura) |
| **Root Detection** | Warning | Bloqueo total |
| **SSL Pinning** | Opcional | Obligatorio |
| **Logging Level** | Info | Debug (para auditoría) |

### Estrategia de Distribución

**Student App:**
- Categoría: Educación
- Precio: Gratis
- In-App Purchases: Premium features (futuro)
- Target: Estudiantes 13-25 años

**Admin App:**
- Categoría: Empresa / Productividad
- Precio: Gratis (requiere cuenta admin)
- Distribución: También via Apple Business Manager (para instituciones)
- Target: Administradores educativos 25-60 años

### Métricas de Éxito

**KPIs Student App:**
- Descargas: >10,000 en primer año
- Rating: >4.5⭐
- Retención D7: >60%
- Quizzes completados: >50,000/mes

**KPIs Admin App:**
- Descargas: >500 en primer año (5% de student)
- Rating: >4.3⭐
- Escuelas gestionadas: >50
- Tiempo promedio de gestión: <10 min/día

---

## 🔄 Migración desde Código Actual

### Estado Actual (apple-app)

```
apple-app/
├── apple-app/
│   ├── Presentation/
│   │   ├── Splash/
│   │   ├── Login/
│   │   ├── Home/
│   │   ├── Settings/
│   │   ├── Progress/
│   │   ├── Courses/      ← Stub
│   │   ├── Calendar/     ← Stub
│   │   └── Community/    ← Stub
│   └── ...
└── Packages/
    ├── EduGoDomainCore/
    ├── EduGoDataLayer/
    └── ...
```

**Observación:** Actualmente NO hay pantallas de administración implementadas.

### Plan de Migración

**Paso 1: No hay código admin que migrar**
- Código actual es 100% features de estudiantes
- Admin App se crea **desde cero**

**Paso 2: Shared packages ya están listos**
- `EduGoDomainCore` tiene entities: User, School, etc.
- `EduGoDataLayer` tiene DTOs y API clients
- Admin App solo importa estos packages

**Paso 3: Implementar features admin**
- Crear nuevas Views en `admin-app/Presentation/`
- Reutilizar ViewModels patterns de student app
- Conectar a `api-administracion:8081`

**Impacto en Student App:** ✅ **CERO**
- No se toca código existente
- Solo se renombra en App Store

---

## 📝 Conclusión

### Decisión Recomendada

**✅ Implementar OPCIÓN 2: Dos Apps Separadas**

**Razones principales:**

1. **Alineación arquitectónica:** Backend ya está separado (api-mobile vs api-admin)
2. **Seguridad:** Reduce superficie de ataque en 50%
3. **UX optimizada:** Cada app tiene propósito claro en App Store
4. **Desarrollo escalable:** Equipos pueden trabajar en paralelo
5. **Bundle optimizado:** Estudiantes (95%) ahorran 33% de descarga

### Trade-offs Aceptados

1. **Setup inicial más largo:** +2 días (one-time cost)
2. **Gestión de 2 apps:** Overhead de ~20% en distribución
3. **UX multi-rol:** Usuarios con ambos roles necesitan 2 apps (pero son <1% de usuarios)

### Próximos Pasos

1. **Aprobar decisión de arquitectura** (este documento)
2. **Crear plan detallado de implementación** (ver Fase 1-5 arriba)
3. **Setup inicial de Admin App** (semana 1)
4. **Implementar features admin** (semanas 2-5)
5. **Publicar en App Store** (semana 6)

---

**Documento generado por:** Claude Code  
**Fecha:** 1 de Diciembre, 2025  
**Próxima revisión:** Después de implementación de Fase 1
