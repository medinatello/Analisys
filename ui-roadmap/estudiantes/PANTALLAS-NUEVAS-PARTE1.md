# Pantallas Nuevas - Parte 1 (Estudiantes)

**Fecha de creación:** 1 de Diciembre, 2025  
**Estado:** Especificación para implementación  
**Plataformas:** iOS 18+, iPadOS 18+, macOS 15+, visionOS 2+  
**API Backend:** api-mobile (puerto 8080)

---

## 📋 Resumen Ejecutivo

Este documento especifica las **primeras 4 pantallas nuevas** para estudiantes en la app Apple de EduGo, enfocadas en el flujo principal de consumo de materiales educativos.

### Pantallas Documentadas

| # | Pantalla | Propósito | Prioridad |
|---|----------|-----------|-----------|
| 1 | **MaterialsListView** | Lista de materiales educativos | 🔴 Alta |
| 2 | **MaterialDetailView** | Detalle de un material | 🔴 Alta |
| 3 | **PDFReaderView** | Lector de PDF con tracking de progreso | 🔴 Alta |
| 4 | **SummaryView** | Ver resumen generado por IA | 🟡 Media |

### Flujo de Navegación

```
TabView (Home Tab)
    ↓
MaterialsListView
    ↓ (tap en material)
MaterialDetailView
    ↓ (tap en "Leer PDF")
PDFReaderView
    ↓ (tap en "Ver Resumen")
SummaryView
```

### Endpoints Disponibles (api-mobile:8080)

Todos los endpoints requieren **autenticación JWT** (validada contra api-admin).

| Endpoint | Método | Propósito |
|----------|--------|-----------|
| `/v1/materials` | GET | Lista de materiales |
| `/v1/materials/:id` | GET | Detalle de un material |
| `/v1/materials/:id/download-url` | GET | URL presignada S3 para descarga |
| `/v1/materials/:id/summary` | GET | Resumen generado por IA |
| `/v1/materials/:id/progress` | PATCH | Actualizar progreso de lectura |
| `/v1/progress` | PUT | UPSERT idempotente de progreso |

---

## 1. MaterialsListView

### Descripción

Pantalla principal que muestra la lista de materiales educativos disponibles para el estudiante autenticado. Permite filtrar, buscar y navegar al detalle de cada material.

**Contexto de navegación:**
- Accesible desde el tab "Home" del TabView principal
- Primera pantalla después de login (para usuarios estudiantes)
- Soporta navegación lateral en iPad/Mac

### Endpoint(s) a Consumir

#### GET /v1/materials

**Request:**
```http
GET /v1/materials HTTP/1.1
Host: localhost:8080
Authorization: Bearer <jwt_token>
```

**Query Parameters (opcionales):**
- `school_id` (UUID) - Filtrar por escuela específica
- `unit_id` (UUID) - Filtrar por unidad académica
- `subject` (string) - Filtrar por materia
- `search` (string) - Búsqueda por título/descripción

**Response esperado (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "title": "Introducción a la Programación",
      "description": "Material de apoyo para aprender fundamentos de programación en Python",
      "file_type": "pdf",
      "file_size": 2048576,
      "upload_date": "2025-11-01T10:00:00Z",
      "uploaded_by": {
        "id": "user-uuid",
        "name": "Prof. Juan Pérez"
      },
      "school_id": "school-uuid",
      "unit_id": "unit-uuid",
      "subject": "Programación",
      "version": 1,
      "has_summary": true,
      "has_assessment": true,
      "progress": {
        "percentage": 45,
        "last_page": 23,
        "total_pages": 50,
        "last_accessed": "2025-11-30T15:30:00Z"
      }
    }
  ],
  "metadata": {
    "total": 1,
    "page": 1,
    "per_page": 20
  }
}
```

**Estados de error:**
- `401 Unauthorized` - Token inválido o expirado
- `403 Forbidden` - Usuario no tiene acceso a materiales de esa escuela
- `500 Internal Server Error` - Error del servidor

---

### Layout por Plataforma

#### iPhone

**Estructura:**
```
┌─────────────────────────────────────┐
│ ← Inicio        Materiales    🔍︎    │ ← NavigationBar (44pt)
├─────────────────────────────────────┤
│                                     │
│  🔽 Matemáticas  ⌕ Buscar...       │ ← Filtros (52pt)
│                                     │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │ 📄 Introducción a Álgebra   │   │ ← MaterialCard (120pt)
│  │ Prof. Ana García            │   │
│  │ ▓▓▓▓░░░░░░ 45%              │   │
│  │ Última vez: Hace 2 horas    │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📄 Geometría Básica         │   │
│  │ Prof. Carlos Ruiz           │   │
│  │ ▓▓░░░░░░░░ 12%              │   │
│  │ Última vez: Hace 1 día      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📄 Trigonometría            │   │
│  │ Prof. Ana García            │   │
│  │ ░░░░░░░░░░ 0%               │   │
│  │ Sin iniciar                 │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
     ↑ ScrollView vertical
```

**Detalles de implementación:**
- NavigationBar con título "Materiales"
- SearchBar integrada en toolbar (activar con tap en 🔍)
- Filtro desplegable por materia (Picker)
- Lista vertical de MaterialCard con spacing de 16pt
- Pull-to-refresh habilitado
- Infinite scroll para paginación
- Touch targets mínimos: 44pt × 44pt

**MaterialCard (Componente):**
- Altura: 120pt
- Padding: 16pt
- Border radius: 12pt
- Background: DSColors.cardBackground
- Shadow: DSElevation.level1
- Tap gesture → Navegar a MaterialDetailView

#### iPad

**Estructura (Landscape):**
```
┌───────────────────────────────────────────────────────────────────┐
│ ← Inicio                Materiales                          🔍︎   │
├───────────┬───────────────────────────────────────────────────────┤
│           │                                                       │
│  Filtros  │  ┌────────────────┐  ┌────────────────┐             │
│           │  │ 📄 Álgebra     │  │ 📄 Geometría   │             │
│ 🔽 Todo   │  │ Prof. García   │  │ Prof. Ruiz     │             │
│           │  │ ▓▓▓▓░ 45%      │  │ ▓░░░░ 12%      │             │
│ Matemática│  └────────────────┘  └────────────────┘             │
│ Física    │                                                       │
│ Química   │  ┌────────────────┐  ┌────────────────┐             │
│ Historia  │  │ 📄 Trigono.    │  │ 📄 Cálculo     │             │
│           │  │ Prof. García   │  │ Prof. López    │             │
│ Estado    │  │ ░░░░░ 0%       │  │ ▓▓░░░ 23%      │             │
│ 🔽 Todos  │  └────────────────┘  └────────────────┘             │
│           │                                                       │
│ Recientes │  Grid 2 columnas con spacing 16pt                   │
│ Favoritos │                                                       │
│           │                                                       │
└───────────┴───────────────────────────────────────────────────────┘
  ↑ Sidebar      ↑ Content area con LazyVGrid
  200pt
```

**Detalles de implementación:**
- Sidebar persistente (200pt ancho) con filtros agrupados
- Content area con LazyVGrid de 2 columnas
- Columnas adaptativas (min: 300pt, max: 400pt)
- Spacing horizontal y vertical: 16pt
- Soporte para Split View (1/3 - 2/3)
- Apple Pencil: Swipe sobre card para marcar favorito

#### Mac

**Estructura:**
```
┌─────────────────────────────────────────────────────────────────────┐
│  EduGo                                              - □ ×           │
├─────────────────────────────────────────────────────────────────────┤
│  < >  Materiales           ⌕ Buscar materiales...    🔽 Filtros    │
├───────────┬─────────────────────────────────────────────────────────┤
│           │  Nombre ↑          Materia       Progreso   Modificado  │
│ Filtros   ├─────────────────────────────────────────────────────────┤
│           │  📄 Álgebra       Matemáticas    ▓▓▓▓░ 45%  Hace 2h     │
│ Materia   │  📄 Geometría     Matemáticas    ▓░░░░ 12%  Hace 1d     │
│ ☐ Todo    │  📄 Trigonometría Matemáticas    ░░░░░  0%  Hace 3d     │
│ ☑ Matemát.│  📄 Física I      Física         ▓▓▓░░ 67%  Hace 5h     │
│ ☐ Física  │  📄 Química Org.  Química        ▓░░░░ 18%  Hace 2d     │
│ ☐ Química │                                                          │
│           │  [Selección múltiple habilitada con Cmd]                │
│ Estado    │                                                          │
│ ☐ Todos   │                                                          │
│ ☑ Iniciado│                                                          │
│ ☐ Completo│                                                          │
│           │                                                          │
└───────────┴─────────────────────────────────────────────────────────┘
```

**Detalles de implementación:**
- Toolbar con botones de navegación (back/forward)
- SearchField nativo de macOS en toolbar
- Sidebar colapsable (toggle con Cmd+Ctrl+S)
- Content area con Table/List view sorteable
- Right-click context menu:
  - Abrir
  - Ver resumen
  - Marcar como favorito
  - Eliminar (si es owner)
- Keyboard shortcuts:
  - `Cmd+F` - Buscar
  - `Cmd+R` - Refrescar
  - `↑/↓` - Navegar lista
  - `Enter` - Abrir seleccionado
  - `Cmd+Click` - Selección múltiple

---

### Componentes UI (Design System)

#### DSMaterialCard

**Descripción:** Card component reutilizable para mostrar información de un material.

**Props:**
```swift
struct DSMaterialCard: View {
    let material: Material
    let onTap: () -> Void
    
    // Opcional
    var showProgress: Bool = true
    var showMeta: Bool = true
}
```

**Composición interna:**
- `DSCard` (contenedor base)
- `DSText` para título (style: .headline)
- `DSText` para autor (style: .subheadline, color: .secondary)
- `DSProgressBar` para progreso
- `DSBadge` para indicadores (nuevo, completado, etc.)

#### DSFilterPicker

**Descripción:** Picker customizado para filtros de materiales.

**Props:**
```swift
struct DSFilterPicker: View {
    @Binding var selection: String?
    let options: [FilterOption]
    let placeholder: String
}
```

#### DSSearchBar

**Descripción:** Barra de búsqueda con debounce automático.

**Props:**
```swift
struct DSSearchBar: View {
    @Binding var text: String
    let placeholder: String
    var debounceTime: TimeInterval = 0.3
    let onSearch: (String) -> Void
}
```

#### DSProgressBar

**Descripción:** Barra de progreso horizontal con porcentaje.

**Props:**
```swift
struct DSProgressBar: View {
    let progress: Double // 0.0 - 1.0
    var showPercentage: Bool = true
    var height: CGFloat = 8
}
```

**Appearance:**
- Track color: DSColors.progressBackground
- Fill color: DSColors.accent (gradiente verde)
- Border radius: height / 2

---

### Estados

#### Loading (Carga Inicial)

**Indicador:**
- ProgressView centrado en pantalla
- Texto: "Cargando materiales..."
- Skeleton cards (3-4) con animación shimmer

**ViewModel state:**
```swift
@Observable
class MaterialsListViewModel {
    var state: ViewState = .loading
    
    enum ViewState {
        case loading
        case loaded([Material])
        case empty
        case error(AppError)
    }
}
```

#### Empty (Sin Materiales)

**Indicador:**
- Icono: SF Symbol "doc.text.magnifyingglass" (64pt)
- Título: "No hay materiales disponibles"
- Descripción: "Aún no se han agregado materiales para tus cursos"
- Botón (opcional): "Refrescar" → Pull-to-refresh

**Layout:**
```swift
VStack(spacing: DSSpacing.lg) {
    Image(systemName: "doc.text.magnifyingglass")
        .font(.system(size: 64))
        .foregroundStyle(DSColors.textSecondary)
    
    DSText("No hay materiales disponibles", style: .title2)
    DSText("Aún no se han agregado materiales", style: .body)
        .foregroundStyle(DSColors.textSecondary)
    
    DSButton("Refrescar", style: .secondary) {
        viewModel.refresh()
    }
}
```

#### Error

**Tipos de error:**
1. **Network error:** "No se pudo conectar al servidor"
2. **Auth error:** "Sesión expirada, por favor inicia sesión nuevamente"
3. **Permission error:** "No tienes acceso a estos materiales"
4. **Server error:** "Error del servidor, intenta nuevamente"

**Indicador:**
- Alert con mensaje de error
- Botón "Reintentar"
- Botón "Cancelar" (cierra alert)

**Código:**
```swift
.alert("Error", isPresented: $viewModel.showError) {
    Button("Reintentar") {
        Task { await viewModel.loadMaterials() }
    }
    Button("Cancelar", role: .cancel) {}
} message: {
    Text(viewModel.errorMessage)
}
```

#### Success (Loaded)

**Indicador:**
- Lista de materials visible
- Pull-to-refresh disponible
- Infinite scroll al llegar al final

**Refresh indicator:**
- Native iOS: Pull-to-refresh con ProgressView
- macOS: Cmd+R o botón "Refrescar" en toolbar

---

### Interacciones

#### Gestos (iOS/iPadOS)

| Gesto | Acción |
|-------|--------|
| **Tap en card** | Navegar a MaterialDetailView |
| **Pull-to-refresh** | Recargar lista de materiales |
| **Scroll down** | Cargar más materiales (infinite scroll) |
| **Long press en card** (iPad) | Mostrar context menu (Abrir, Favorito, Compartir) |
| **Swipe left en card** (iPhone) | Revelar botones (Favorito, Eliminar) |

#### Navegación

**Push navigation:**
```swift
NavigationStack {
    MaterialsListView()
        .navigationDestination(for: Material.self) { material in
            MaterialDetailView(material: material)
        }
}
```

**Tap handler:**
```swift
DSMaterialCard(material: material) {
    navigationPath.append(material)
}
```

#### Acciones

**Refrescar:**
```swift
.refreshable {
    await viewModel.refresh()
}
```

**Cargar más (pagination):**
```swift
.onAppear {
    if material == viewModel.materials.last {
        Task { await viewModel.loadMoreMaterials() }
    }
}
```

**Buscar:**
```swift
DSSearchBar(text: $searchText) { query in
    Task { await viewModel.search(query: query) }
}
```

---

### Validaciones

#### Pre-carga

- ✅ Verificar que usuario esté autenticado
- ✅ Verificar que token JWT sea válido
- ✅ Verificar que usuario tenga rol `student` o `teacher`

```swift
func loadMaterials() async {
    guard authState.isAuthenticated else {
        state = .error(.authenticationRequired)
        return
    }
    
    state = .loading
    
    let result = await getMaterialsUseCase.execute()
    
    switch result {
    case .success(let materials):
        state = materials.isEmpty ? .empty : .loaded(materials)
    case .failure(let error):
        state = .error(error)
    }
}
```

#### Filtros

- ✅ Validar que `school_id` sea UUID válido si se proporciona
- ✅ Validar que `unit_id` sea UUID válido si se proporciona
- ✅ Search query: Mínimo 3 caracteres (o vacío para limpiar)

#### Paginación

- ✅ No cargar más si ya se alcanzó el final (`metadata.total`)
- ✅ Evitar múltiples requests simultáneos (debounce)

---

### Lógica Semi-Dummy

#### NO Implementar en Primera Fase

1. **Filtros avanzados:**
   - ❌ Filtro por fecha de subida
   - ❌ Filtro por tamaño de archivo
   - ❌ Filtro por tipo de archivo (solo PDF por ahora)

2. **Acciones batch:**
   - ❌ Selección múltiple de materiales
   - ❌ Descargar múltiples PDFs
   - ❌ Marcar múltiples como favoritos

3. **Ordenamiento:**
   - ❌ Ordenar por nombre, fecha, progreso
   - ✅ Usar ordenamiento por defecto del backend (fecha desc)

4. **Favoritos:**
   - ❌ Marcar como favorito (requiere endpoint adicional)
   - ❌ Filtrar por favoritos

5. **Compartir:**
   - ❌ Compartir material con otros estudiantes

#### Implementar Dummy (UI visible, sin funcionalidad)

1. **Botón de favorito:**
   - ✅ Mostrar ícono de estrella en card
   - ❌ No hacer nada al hacer tap (mostrar toast "Próximamente")

2. **Badge "Nuevo":**
   - ✅ Mostrar badge si material tiene menos de 7 días
   - ❌ No marcar como "visto"

---

## 2. MaterialDetailView

### Descripción

Pantalla de detalle que muestra toda la información de un material educativo específico, incluyendo metadatos, opciones de descarga, acceso al resumen IA y evaluaciones.

**Contexto de navegación:**
- Accesible desde MaterialsListView (tap en card)
- Push navigation en NavigationStack
- Soporte para navegación lateral en iPad (Master-Detail)

### Endpoint(s) a Consumir

#### GET /v1/materials/:id

**Request:**
```http
GET /v1/materials/123e4567-e89b-12d3-a456-426614174000 HTTP/1.1
Host: localhost:8080
Authorization: Bearer <jwt_token>
```

**Response esperado (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Introducción a la Programación",
    "description": "Material de apoyo completo para aprender los fundamentos de programación en Python. Incluye ejemplos prácticos, ejercicios y proyectos.",
    "file_type": "pdf",
    "file_size": 2048576,
    "file_name": "intro-programacion-v1.pdf",
    "upload_date": "2025-11-01T10:00:00Z",
    "uploaded_by": {
      "id": "user-uuid",
      "name": "Prof. Juan Pérez",
      "email": "juan.perez@escuela.edu"
    },
    "school": {
      "id": "school-uuid",
      "name": "Colegio San Martín"
    },
    "unit": {
      "id": "unit-uuid",
      "name": "1° Medio A",
      "type": "class"
    },
    "subject": "Programación",
    "version": 1,
    "has_summary": true,
    "has_assessment": true,
    "total_pages": 50,
    "tags": ["python", "programación", "fundamentos"],
    "progress": {
      "percentage": 45,
      "last_page": 23,
      "total_pages": 50,
      "started_at": "2025-11-15T10:00:00Z",
      "last_accessed": "2025-11-30T15:30:00Z"
    },
    "assessment_info": {
      "total_questions": 10,
      "attempts_count": 2,
      "best_score": 80,
      "last_attempt_date": "2025-11-28T14:00:00Z"
    }
  }
}
```

**Estados de error:**
- `404 Not Found` - Material no existe
- `403 Forbidden` - Usuario no tiene acceso al material
- `401 Unauthorized` - Token inválido

#### GET /v1/materials/:id/download-url

**Request:**
```http
GET /v1/materials/123e4567-e89b-12d3-a456-426614174000/download-url HTTP/1.1
Host: localhost:8080
Authorization: Bearer <jwt_token>
```

**Response esperado (200 OK):**
```json
{
  "success": true,
  "data": {
    "download_url": "https://edugo-bucket.s3.amazonaws.com/materials/intro-prog.pdf?X-Amz-Signature=...",
    "expires_at": "2025-12-01T16:00:00Z",
    "file_name": "intro-programacion-v1.pdf",
    "file_size": 2048576
  }
}
```

**Estados de error:**
- `404 Not Found` - Archivo no existe en S3
- `500 Internal Server Error` - Error generando URL presignada

---

### Layout por Plataforma

#### iPhone

**Estructura:**
```
┌─────────────────────────────────────┐
│ ← Materiales           􀈂             │ ← NavigationBar (botón compartir)
├─────────────────────────────────────┤
│                                     │
│  📄                                 │ ← Ícono grande (80pt)
│                                     │
│  Introducción a la Programación    │ ← Título (DSText.title1)
│  Prof. Juan Pérez                  │ ← Autor (DSText.subheadline)
│                                     │
├─────────────────────────────────────┤
│  ▓▓▓▓▓░░░░░  45% completado         │ ← Progreso (DSProgressBar)
│  Última vez: Hace 2 horas           │
├─────────────────────────────────────┤
│                                     │
│  📱 Leer PDF                        │ ← DSButton.primary (full width)
│                                     │
│  🤖 Ver Resumen IA                  │ ← DSButton.secondary
│                                     │
│  📝 Tomar Quiz (10 preguntas)       │ ← DSButton.secondary
│                                     │
├─────────────────────────────────────┤ ← Divider
│  📋 Detalles                        │
│                                     │
│  Escuela: Colegio San Martín        │
│  Curso: 1° Medio A                  │
│  Materia: Programación              │
│  Páginas: 50                        │
│  Tamaño: 2.0 MB                     │
│  Subido: 1 de Nov, 2025             │
│                                     │
├─────────────────────────────────────┤
│  📊 Tu Progreso                     │
│                                     │
│  Página actual: 23 de 50            │
│  Iniciado: 15 de Nov, 2025          │
│  Mejor score en quiz: 80%           │
│  Intentos de quiz: 2                │
│                                     │
└─────────────────────────────────────┘
     ↑ ScrollView vertical
```

**Detalles de implementación:**
- NavigationBar con botón "Compartir" (trailing)
- Header con ícono, título y autor
- Sección de progreso destacada
- Botones de acción principales (stack vertical, spacing 12pt)
- Secciones colapsables (opcional para iPad/Mac)
- Scroll view completo

#### iPad

**Estructura (Split View):**
```
┌─────────────────┬───────────────────────────────────────────┐
│                 │ ← Materiales              􀈂               │
│ [Lista de      │├───────────────────────────────────────────┤
│  materiales]   ││                                           │
│                 ││  ┌─────────────────────────────────────┐ │
│ 📄 Álgebra     ││  │  📄                                  │ │
│ 📄 Geometría   ││  │  Introducción a la Programación     │ │
│ 📄 Trigono. ◀──┼┤  │  Prof. Juan Pérez                   │ │
│ 📄 Física      ││  │                                      │ │
│                 ││  │  ▓▓▓▓▓░░░░░  45%                    │ │
│                 ││  └─────────────────────────────────────┘ │
│                 ││                                           │
│                 ││  ┌──────────────┐  ┌──────────────┐     │
│                 ││  │ 📱 Leer PDF  │  │ 🤖 Resumen   │     │
│                 ││  └──────────────┘  └──────────────┘     │
│                 ││  ┌──────────────────────────────────┐   │
│                 ││  │ 📝 Tomar Quiz (10 preguntas)     │   │
│                 ││  └──────────────────────────────────┘   │
│                 ││                                           │
│                 ││  📋 Detalles          📊 Tu Progreso     │
│                 ││  [Info en 2 columnas]                    │
│                 ││                                           │
└─────────────────┴───────────────────────────────────────────┘
  ↑ Master (300pt)  ↑ Detail (resto)
```

**Detalles de implementación:**
- Split view con lista de materiales en master
- Detail view con layout de 2 columnas en secciones de info
- Botones de acción en grid horizontal (2 columnas)
- Secciones colapsables con disclosure indicators
- Soporte para Apple Pencil (anotar en PDF)

#### Mac

**Estructura:**
```
┌───────────────────────────────────────────────────────────────┐
│  EduGo                                          - □ ×         │
├───────────────────────────────────────────────────────────────┤
│  < >  📄 Introducción a la Programación      [Compartir ↗]   │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  📄                Introducción a la Programación       │ │
│  │                    Prof. Juan Pérez                     │ │
│  │                    ▓▓▓▓▓░░░░░  45%                      │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  [Leer PDF]    [Ver Resumen IA]    [Tomar Quiz]             │
│                                                               │
│  ┌─────────────────────┐  ┌────────────────────────────┐    │
│  │ 📋 Detalles         │  │ 📊 Tu Progreso             │    │
│  │                     │  │                            │    │
│  │ Escuela: Colegio..  │  │ Página: 23 de 50           │    │
│  │ Curso: 1° Medio A   │  │ Iniciado: 15 Nov           │    │
│  │ Materia: Program.   │  │ Mejor score: 80%           │    │
│  │ Páginas: 50         │  │ Intentos: 2                │    │
│  │ Tamaño: 2.0 MB      │  │                            │    │
│  └─────────────────────┘  └────────────────────────────┘    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

**Detalles de implementación:**
- Toolbar con navegación y botón compartir
- Layout en columnas para secciones de info
- Botones con íconos y labels claros
- Window puede redimensionarse (min: 600×400)
- Keyboard shortcuts:
  - `Cmd+O` - Abrir PDF
  - `Cmd+S` - Ver resumen
  - `Cmd+Q` - Tomar quiz
  - `Cmd+I` - Mostrar/ocultar inspector

---

### Componentes UI (Design System)

#### DSMaterialHeader

**Descripción:** Header component para mostrar info principal del material.

**Props:**
```swift
struct DSMaterialHeader: View {
    let material: Material
    var showProgress: Bool = true
}
```

**Composición:**
- Ícono de tipo de archivo (SF Symbol grande)
- Título (DSText.title1)
- Autor (DSText.subheadline, secondary)
- Progress bar (opcional)

#### DSActionButton

**Descripción:** Botón de acción con ícono y texto.

**Props:**
```swift
struct DSActionButton: View {
    let title: String
    let icon: String // SF Symbol name
    let style: ButtonStyle = .primary
    let action: () -> Void
}
```

**Variantes:**
- `.primary` - Leer PDF (azul, fill)
- `.secondary` - Ver resumen, Tomar quiz (outline)

#### DSInfoSection

**Descripción:** Sección de información con título y pares key-value.

**Props:**
```swift
struct DSInfoSection: View {
    let title: String
    let items: [InfoItem]
    var isCollapsible: Bool = false
    
    struct InfoItem {
        let label: String
        let value: String
        let icon: String?
    }
}
```

---

### Estados

#### Loading

**Indicador:**
- ProgressView centrado
- Skeleton view con placeholders
- Texto: "Cargando material..."

#### Error

**Tipos de error:**
1. **404 Not Found:** "Este material no existe o fue eliminado"
2. **403 Forbidden:** "No tienes permiso para ver este material"
3. **Network error:** "No se pudo cargar el material"

**Indicador:**
- Alert con mensaje de error
- Botón "Reintentar"
- Botón "Volver a materiales"

#### Success

**Indicador:**
- Información completa del material visible
- Botones de acción habilitados
- Progress bar actualizado

---

### Interacciones

#### Botones de Acción

**Leer PDF:**
```swift
DSActionButton(title: "Leer PDF", icon: "doc.text.fill", style: .primary) {
    Task {
        await viewModel.openPDF()
        navigationPath.append(PDFReaderDestination(material: material))
    }
}
```

**Ver Resumen IA:**
```swift
DSActionButton(title: "Ver Resumen IA", icon: "brain.fill", style: .secondary) {
    guard material.hasSummary else {
        showAlert("Resumen no disponible")
        return
    }
    navigationPath.append(SummaryDestination(material: material))
}
```

**Tomar Quiz:**
```swift
DSActionButton(title: "Tomar Quiz", icon: "pencil.and.list.clipboard", style: .secondary) {
    guard material.hasAssessment else {
        showAlert("Quiz no disponible")
        return
    }
    // TODO: Implementar en Parte 2
    showAlert("Próximamente")
}
```

#### Compartir

**iOS/iPadOS:**
```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        ShareLink(item: shareableContent) {
            Label("Compartir", systemImage: "square.and.arrow.up")
        }
    }
}
```

**Contenido compartible:**
- Título del material
- Autor
- Link al material (deep link si implementado)

---

### Validaciones

#### Pre-carga

- ✅ Verificar que `material.id` sea UUID válido
- ✅ Verificar autenticación antes de cargar
- ✅ Manejar 404 si material no existe

#### Botones de Acción

**Leer PDF:**
- ✅ Verificar que `has_summary` sea true antes de habilitar
- ✅ Verificar conectividad antes de descargar

**Ver Resumen:**
- ✅ Solo habilitar si `has_summary == true`
- ✅ Mostrar badge "Generando..." si resumen está en proceso

**Tomar Quiz:**
- ✅ Solo habilitar si `has_assessment == true`
- ✅ Mostrar info de intentos previos si existen

---

### Lógica Semi-Dummy

#### NO Implementar en Primera Fase

1. **Compartir avanzado:**
   - ❌ Compartir con estudiantes específicos
   - ❌ Compartir por email/WhatsApp
   - ✅ Solo ShareSheet nativo de iOS

2. **Versiones del material:**
   - ❌ Ver historial de versiones
   - ❌ Comparar versiones
   - ✅ Solo mostrar versión actual

3. **Comentarios:**
   - ❌ Agregar comentarios al material
   - ❌ Ver comentarios de otros estudiantes

4. **Descarga offline:**
   - ❌ Descargar PDF para uso offline
   - ✅ Solo streaming/cache temporal

5. **Imprimir:**
   - ❌ Imprimir PDF directamente
   - ✅ Disponible en macOS (nativo)

#### Implementar Dummy

1. **Botón "Tomar Quiz":**
   - ✅ Mostrar botón
   - ❌ No implementar funcionalidad (toast "Próximamente")

2. **Badge "Nuevo":**
   - ✅ Mostrar si material < 7 días
   - ❌ No persistir estado "visto"

---

## 3. PDFReaderView

### Descripción

Pantalla de lectura de PDF con tracking de progreso automático. Permite visualizar el contenido del material educativo, navegar entre páginas y registrar el progreso de lectura.

**Contexto de navegación:**
- Accesible desde MaterialDetailView (botón "Leer PDF")
- Full-screen presentation en iPhone/iPad
- Window separada en macOS (opcional)
- Soporte para modo inmersivo en visionOS

### Endpoint(s) a Consumir

#### GET /v1/materials/:id/download-url

Ya documentado en MaterialDetailView.

#### PATCH /v1/materials/:id/progress

**Request:**
```http
PATCH /v1/materials/123e4567-e89b-12d3-a456-426614174000/progress HTTP/1.1
Host: localhost:8080
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "current_page": 23,
  "total_pages": 50,
  "percentage": 46.0,
  "status": "in_progress"
}
```

**Response esperado (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "progress-uuid",
    "user_id": "user-uuid",
    "material_id": "material-uuid",
    "current_page": 23,
    "total_pages": 50,
    "percentage": 46.0,
    "status": "in_progress",
    "started_at": "2025-11-15T10:00:00Z",
    "last_accessed": "2025-12-01T14:30:00Z"
  }
}
```

**Estados de error:**
- `400 Bad Request` - Datos inválidos (ej: current_page > total_pages)
- `404 Not Found` - Material no existe

#### PUT /v1/progress (Alternativa - UPSERT idempotente)

**Request:**
```http
PUT /v1/progress HTTP/1.1
Host: localhost:8080
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "material_id": "123e4567-e89b-12d3-a456-426614174000",
  "current_page": 23,
  "total_pages": 50,
  "percentage": 46.0,
  "status": "in_progress"
}
```

**Response esperado (200 OK):**
Igual que PATCH.

**Nota:** Usar PUT si el backend soporta UPSERT idempotente (recomendado).

---

### Layout por Plataforma

#### iPhone

**Estructura (Full-Screen):**
```
┌─────────────────────────────────────┐
│ ×                           ⋯  📄   │ ← Toolbar (auto-hide)
├─────────────────────────────────────┤
│                                     │
│                                     │
│                                     │
│          [Contenido del PDF]        │
│                                     │
│          Página renderizada         │
│          con PDFKit                 │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  ◀  Página 23 de 50  ▶              │ ← Bottom toolbar (auto-hide)
│  ━━━━━━━━━━●━━━━━━━━━━  46%         │ ← Slider de navegación
└─────────────────────────────────────┘
```

**Detalles de implementación:**
- Full-screen presentation (.fullScreenCover)
- PDFView de PDFKit (iOS nativo)
- Toolbar superior: Cerrar (X), Más opciones (⋯), Compartir (📄)
- Toolbar inferior: Prev/Next, Slider de páginas, Porcentaje
- Auto-hide toolbars después de 3 segundos de inactividad
- Tap en pantalla para mostrar/ocultar toolbars
- Zoom habilitado (pinch gesture)
- Orientación: Portrait y Landscape

**Gestos:**
- Swipe left/right: Cambiar página
- Pinch: Zoom in/out
- Double tap: Zoom automático
- Single tap: Toggle toolbars

#### iPad

**Estructura:**
```
┌───────────────────────────────────────────────────────────────┐
│ ×  Introducción a la Programación         ⋯  🔍  📄          │
├─────────────────────┬─────────────────────────────────────────┤
│                     │                                         │
│  Miniaturas         │                                         │
│                     │                                         │
│  ┌───┐             │      [Contenido del PDF]                │
│  │ 1 │             │                                         │
│  └───┘             │      Página actual renderizada          │
│  ┌───┐             │                                         │
│  │ 2 │             │                                         │
│  └───┘             │                                         │
│  ┌───┐             │                                         │
│  │23 │ ◀ Actual    │                                         │
│  └───┘             │                                         │
│  ┌───┐             │                                         │
│  │24 │             │                                         │
│  └───┘             │                                         │
│                     │                                         │
│                     │                                         │
│                     │                                         │
├─────────────────────┴─────────────────────────────────────────┤
│  ◀  Página 23 de 50  ▶        ━━━━━●━━━━━  46%              │
└───────────────────────────────────────────────────────────────┘
  ↑ Sidebar (150pt)      ↑ PDF Content
```

**Detalles de implementación:**
- Sidebar con miniaturas de páginas (thumbnails)
- Sidebar colapsable (toggle con botón en toolbar)
- PDF content en panel principal
- Toolbar superior siempre visible
- Bottom toolbar con navegación y slider
- Apple Pencil support (anotar, highlight)
- Split screen compatible

#### Mac

**Estructura:**
```
┌───────────────────────────────────────────────────────────────┐
│  📄 Introducción a la Programación           - □ ×            │
├───────────────────────────────────────────────────────────────┤
│  ←  →   🔍︎ +  🔍︎ -   📃 Miniaturas   🖊 Anotar   📄 Exportar  │
├─────────────────────┬─────────────────────────────────────────┤
│                     │                                         │
│  Miniaturas         │                                         │
│  (colapsable)       │      [Contenido del PDF]                │
│                     │                                         │
│  ┌─────┐           │      Renderizado con PDFKit             │
│  │  1  │           │      Full fidelity                      │
│  └─────┘           │                                         │
│  ┌─────┐           │                                         │
│  │  2  │           │                                         │
│  └─────┘           │                                         │
│  ┌─────┐           │                                         │
│  │ 23  │ ◀ Actual  │                                         │
│  └─────┘           │                                         │
│                     │                                         │
├─────────────────────┴─────────────────────────────────────────┤
│  Página 23 de 50                            46% completado    │
└───────────────────────────────────────────────────────────────┘
```

**Detalles de implementación:**
- Window nativa de macOS
- Toolbar con controles nativos
- Sidebar de miniaturas (NSOutlineView)
- PDFView nativo de macOS
- Menu bar integration:
  - File > Export PDF
  - Edit > Find, Copy
  - View > Zoom In/Out, Thumbnails
  - Go > Next/Previous Page
- Keyboard shortcuts:
  - `←/→` - Página anterior/siguiente
  - `Cmd++/-` - Zoom in/out
  - `Cmd+F` - Buscar en PDF
  - `Cmd+W` - Cerrar ventana
  - `Space` - Scroll down (página siguiente si al final)

---

### Componentes UI (Design System)

#### DSPDFViewer

**Descripción:** Wrapper de PDFKit con tracking de progreso automático.

**Props:**
```swift
struct DSPDFViewer: View {
    let pdfDocument: PDFDocument
    @Binding var currentPage: Int
    let totalPages: Int
    let onPageChange: (Int) -> Void
    
    // Opcional
    var autoHideToolbars: Bool = true
    var enableAnnotations: Bool = false
}
```

**Features:**
- Renderizado con PDFKit nativo
- Tracking automático de cambio de página
- Debounce para evitar múltiples llamadas a API
- Cache de páginas visitadas

#### DSPageNavigator

**Descripción:** Control de navegación entre páginas con slider.

**Props:**
```swift
struct DSPageNavigator: View {
    @Binding var currentPage: Int
    let totalPages: Int
    let onPageChange: (Int) -> Void
}
```

**Composición:**
- Botones prev/next
- Slider de páginas
- Label "Página X de Y"
- Porcentaje de progreso

#### DSThumbnailSidebar

**Descripción:** Sidebar con miniaturas de páginas (iPad/Mac).

**Props:**
```swift
struct DSThumbnailSidebar: View {
    let pdfDocument: PDFDocument
    @Binding var selectedPage: Int
    let onPageSelect: (Int) -> Void
}
```

---

### Estados

#### Loading

**Indicador:**
- ProgressView centrado
- Texto: "Descargando PDF..." con porcentaje
- Progress bar lineal en top

**Implementación:**
```swift
@State private var downloadProgress: Double = 0.0

if viewModel.isDownloading {
    VStack {
        ProgressView("Descargando PDF...", value: downloadProgress, total: 1.0)
            .padding()
        
        Text("\(Int(downloadProgress * 100))%")
            .foregroundStyle(DSColors.textSecondary)
    }
}
```

#### Error

**Tipos de error:**
1. **Download failed:** "No se pudo descargar el PDF"
2. **Invalid PDF:** "El archivo PDF está corrupto"
3. **Network error:** "Sin conexión a Internet"

**Indicador:**
- Alert con mensaje de error
- Botón "Reintentar descarga"
- Botón "Cancelar" (volver a detalle)

#### Success

**Indicador:**
- PDF renderizado correctamente
- Navegación habilitada
- Tracking de progreso activo

---

### Interacciones

#### Navegación de Páginas

**Cambio manual:**
```swift
// Botones prev/next
DSButton(icon: "chevron.left") {
    viewModel.previousPage()
}

DSButton(icon: "chevron.right") {
    viewModel.nextPage()
}

// Slider
Slider(value: $currentPageDouble, in: 1...Double(totalPages), step: 1) { _ in
    viewModel.goToPage(Int(currentPageDouble))
}
```

**Gestos:**
```swift
// Swipe left/right (iOS/iPad)
.gesture(
    DragGesture()
        .onEnded { value in
            if value.translation.width < -50 {
                viewModel.nextPage()
            } else if value.translation.width > 50 {
                viewModel.previousPage()
            }
        }
)
```

#### Tracking de Progreso

**Automático al cambiar página:**
```swift
func onPageChanged(newPage: Int) {
    currentPage = newPage
    percentage = Double(newPage) / Double(totalPages) * 100
    
    // Debounce: Solo enviar actualización cada 5 segundos o al cerrar
    debounceTimer?.invalidate()
    debounceTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
        Task { await updateProgress() }
    }
}
```

**Al cerrar el viewer:**
```swift
.onDisappear {
    debounceTimer?.invalidate()
    Task { await viewModel.finalizeProgress() }
}
```

#### Toolbar Auto-Hide (iPhone)

```swift
@State private var toolbarsVisible = true
@State private var hideTimer: Timer?

var body: some View {
    ZStack {
        PDFView(...)
            .onTapGesture {
                toggleToolbars()
            }
        
        if toolbarsVisible {
            VStack {
                topToolbar
                Spacer()
                bottomToolbar
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    .onChange(of: toolbarsVisible) { _, newValue in
        if newValue {
            scheduleAutoHide()
        }
    }
}

func scheduleAutoHide() {
    hideTimer?.invalidate()
    hideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
        withAnimation { toolbarsVisible = false }
    }
}
```

---

### Validaciones

#### Pre-carga

- ✅ Verificar que URL presignada sea válida
- ✅ Verificar que URL no haya expirado (`expires_at`)
- ✅ Solicitar nueva URL si está expirada

```swift
func loadPDF() async {
    let urlResult = await getDownloadURLUseCase.execute(materialId: material.id)
    
    guard case .success(let urlData) = urlResult else {
        state = .error(.downloadFailed)
        return
    }
    
    // Verificar expiración
    if urlData.expiresAt < Date() {
        // URL expirada, solicitar nueva
        return await loadPDF()
    }
    
    // Descargar PDF
    await downloadPDF(from: urlData.downloadURL)
}
```

#### Durante Lectura

- ✅ Validar que `current_page` esté en rango [1, total_pages]
- ✅ Validar que `percentage` esté en rango [0, 100]
- ✅ No enviar actualizaciones si página no cambió

#### Progreso

- ✅ Solo actualizar si hay cambio real de página
- ✅ Debounce de 5 segundos entre actualizaciones
- ✅ Enviar actualización final al cerrar viewer

---

### Lógica Semi-Dummy

#### NO Implementar en Primera Fase

1. **Anotaciones:**
   - ❌ Agregar notas/highlights con Apple Pencil (iPad)
   - ❌ Persistir anotaciones en servidor
   - ✅ Solo lectura

2. **Búsqueda en PDF:**
   - ❌ Buscar texto dentro del PDF (Cmd+F en Mac)
   - ✅ Solo navegación por páginas

3. **Exportar/Imprimir:**
   - ❌ Exportar PDF con anotaciones
   - ❌ Imprimir PDF
   - ✅ Solo visualización

4. **Modo nocturno:**
   - ❌ Invertir colores para modo nocturno
   - ✅ Respetar tema del sistema (Dark Mode)

5. **Descarga offline:**
   - ❌ Descargar PDF para uso offline permanente
   - ✅ Solo cache temporal durante sesión

6. **Sincronización cross-device:**
   - ❌ Sincronizar progreso entre dispositivos en tiempo real
   - ✅ Sincronizar al abrir/cerrar viewer

#### Implementar Dummy

1. **Botón "Anotar" (iPad/Mac):**
   - ✅ Mostrar botón en toolbar
   - ❌ Deshabilitar con tooltip "Próximamente"

2. **Botón "Compartir":**
   - ✅ Mostrar botón
   - ✅ Solo compartir link, no PDF completo

---

## 4. SummaryView

### Descripción

Pantalla que muestra el resumen generado por IA (OpenAI) de un material educativo. Permite visualizar puntos clave, conceptos principales y estructura del contenido de forma condensada.

**Contexto de navegación:**
- Accesible desde MaterialDetailView (botón "Ver Resumen IA")
- También accesible desde PDFReaderView (botón en toolbar)
- Sheet presentation en iPhone/iPad
- Window separada en macOS (opcional)

### Endpoint(s) a Consumir

#### GET /v1/materials/:id/summary

**Request:**
```http
GET /v1/materials/123e4567-e89b-12d3-a456-426614174000/summary HTTP/1.1
Host: localhost:8080
Authorization: Bearer <jwt_token>
```

**Response esperado (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "summary-uuid",
    "material_id": "123e4567-e89b-12d3-a456-426614174000",
    "summary": "Este material introduce los fundamentos de la programación usando Python como lenguaje base. Cubre conceptos esenciales como variables, tipos de datos, estructuras de control, funciones y manejo de errores.",
    "key_points": [
      "Variables y tipos de datos básicos (int, float, str, bool)",
      "Estructuras de control: if/else, for, while",
      "Funciones: definición, parámetros, retorno de valores",
      "Manejo de errores con try/except",
      "Buenas prácticas de código limpio"
    ],
    "concepts": [
      {
        "name": "Variables",
        "description": "Contenedores de datos que pueden cambiar durante la ejecución del programa"
      },
      {
        "name": "Funciones",
        "description": "Bloques de código reutilizables que realizan una tarea específica"
      },
      {
        "name": "Bucles",
        "description": "Estructuras que permiten repetir código múltiples veces"
      }
    ],
    "generated_at": "2025-11-01T12:00:00Z",
    "model": "gpt-4-turbo",
    "token_count": 450,
    "confidence_score": 0.92
  }
}
```

**Estados de error:**
- `404 Not Found` - Resumen no existe (aún no generado)
- `202 Accepted` - Resumen en proceso de generación
- `500 Internal Server Error` - Error al obtener resumen

**Response 202 Accepted (En proceso):**
```json
{
  "success": true,
  "data": {
    "status": "processing",
    "message": "El resumen está siendo generado. Por favor intenta nuevamente en unos momentos.",
    "estimated_time_seconds": 30
  }
}
```

---

### Layout por Plataforma

#### iPhone

**Estructura (Sheet):**
```
┌─────────────────────────────────────┐
│ ━━                              ×   │ ← Drag indicator + Botón cerrar
├─────────────────────────────────────┤
│  🤖 Resumen IA                      │ ← Título (DSText.title2)
│                                     │
│  Generado el 1 de Nov, 2025         │ ← Metadata
│  Modelo: GPT-4 Turbo                │
│                                     │
├─────────────────────────────────────┤
│  📝 Resumen                         │ ← Sección
│                                     │
│  Este material introduce los        │
│  fundamentos de la programación     │
│  usando Python como lenguaje base.  │
│  Cubre conceptos esenciales como... │
│                                     │
├─────────────────────────────────────┤
│  ✨ Puntos Clave                    │
│                                     │
│  • Variables y tipos de datos       │
│    básicos (int, float, str, bool)  │
│                                     │
│  • Estructuras de control:          │
│    if/else, for, while              │
│                                     │
│  • Funciones: definición,           │
│    parámetros, retorno de valores   │
│                                     │
│  • Manejo de errores con            │
│    try/except                       │
│                                     │
├─────────────────────────────────────┤
│  💡 Conceptos Principales           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Variables                   │   │
│  │ Contenedores de datos que   │   │
│  │ pueden cambiar durante la   │   │
│  │ ejecución del programa      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Funciones                   │   │
│  │ Bloques de código           │   │
│  │ reutilizables...            │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
     ↑ ScrollView vertical
```

**Detalles de implementación:**
- Sheet presentation con detent medium/large
- Drag indicator para cerrar
- Botón cerrar (×) en esquina superior derecha
- ScrollView con secciones bien definidas
- DSCard para cada concepto
- Spacing entre secciones: 24pt
- Padding horizontal: 16pt

#### iPad

**Estructura (Sheet más ancha):**
```
┌───────────────────────────────────────────────────────────────┐
│ ━━━━━━━━                                                  ×   │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  🤖 Resumen IA                                               │
│  Generado el 1 de Nov, 2025 • GPT-4 Turbo                   │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────┐  ┌────────────────────────┐    │
│  │ 📝 Resumen              │  │ ✨ Puntos Clave        │    │
│  │                         │  │                        │    │
│  │ Este material intro...  │  │ • Variables y tipos... │    │
│  │                         │  │                        │    │
│  │                         │  │ • Estructuras de...    │    │
│  │                         │  │                        │    │
│  │                         │  │ • Funciones: def...    │    │
│  └─────────────────────────┘  └────────────────────────┘    │
│                                                               │
│  💡 Conceptos Principales                                    │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Variables    │  │ Funciones    │  │ Bucles       │      │
│  │              │  │              │  │              │      │
│  │ Contenedores │  │ Bloques de   │  │ Estructuras  │      │
│  │ de datos...  │  │ código...    │  │ que repiten..│      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

**Detalles de implementación:**
- Sheet con ancho máximo de 700pt (centrada)
- Layout de 2 columnas en secciones superiores
- Grid de 3 columnas para conceptos
- Mejor aprovechamiento del espacio horizontal
- Apple Pencil: Anotar conceptos (dummy, no implementar)

#### Mac

**Estructura (Window):**
```
┌───────────────────────────────────────────────────────────────┐
│  🤖 Resumen IA - Introducción a la Programación  - □ ×        │
├───────────────────────────────────────────────────────────────┤
│  [Copiar Resumen]  [Exportar PDF]  [Compartir]               │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  Generado: 1 de Nov, 2025 • Modelo: GPT-4 Turbo • 92% conf. │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────┐  ┌────────────────────────┐    │
│  │ 📝 Resumen              │  │ ✨ Puntos Clave (5)    │    │
│  │                         │  │                        │    │
│  │ [Texto completo del     │  │ • Punto 1              │    │
│  │  resumen con scroll]    │  │ • Punto 2              │    │
│  │                         │  │ • Punto 3              │    │
│  │                         │  │ • Punto 4              │    │
│  │                         │  │ • Punto 5              │    │
│  └─────────────────────────┘  └────────────────────────┘    │
│                                                               │
│  💡 Conceptos Principales (3)                                │
│                                                               │
│  [Grid de 3 columnas con conceptos]                          │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

**Detalles de implementación:**
- Window separada (NSWindow)
- Toolbar con acciones (Copiar, Exportar, Compartir)
- Layout de 2 columnas
- Selección de texto habilitada
- Keyboard shortcuts:
  - `Cmd+C` - Copiar resumen completo
  - `Cmd+E` - Exportar como PDF
  - `Cmd+S` - Guardar como archivo de texto
  - `Cmd+W` - Cerrar ventana

---

### Componentes UI (Design System)

#### DSSummaryHeader

**Descripción:** Header con título y metadata del resumen.

**Props:**
```swift
struct DSSummaryHeader: View {
    let generatedAt: Date
    let model: String
    let confidenceScore: Double?
}
```

**Composición:**
- Icono de IA (brain.fill)
- Título "Resumen IA"
- Metadata: Fecha, Modelo, Confianza (opcional)

#### DSSummarySection

**Descripción:** Sección genérica para resumen, puntos clave, conceptos.

**Props:**
```swift
struct DSSummarySection: View {
    let title: String
    let icon: String
    let content: Content
    
    // Genérico para soportar diferentes tipos de contenido
    @ViewBuilder var content: () -> Content
}
```

#### DSConceptCard

**Descripción:** Card para mostrar un concepto con nombre y descripción.

**Props:**
```swift
struct DSConceptCard: View {
    let concept: Concept
    
    struct Concept {
        let name: String
        let description: String
    }
}
```

**Composición:**
- DSCard como contenedor
- Título (DSText.headline)
- Descripción (DSText.body, secondary color)
- Padding: 16pt
- Border radius: 12pt

#### DSKeyPointsList

**Descripción:** Lista de puntos clave con bullets.

**Props:**
```swift
struct DSKeyPointsList: View {
    let keyPoints: [String]
}
```

**Composición:**
- VStack con spacing de 12pt
- Cada item con bullet (•) y texto
- Multiline text support

---

### Estados

#### Loading

**Indicador:**
- ProgressView centrado
- Texto: "Cargando resumen..."
- Skeleton view con placeholders

**Implementación:**
```swift
if viewModel.state == .loading {
    VStack(spacing: DSSpacing.lg) {
        ProgressView()
        DSText("Cargando resumen...", style: .body)
            .foregroundStyle(DSColors.textSecondary)
    }
}
```

#### Processing (202 Accepted)

**Indicador:**
- Icono animado (brain con efecto pulse)
- Texto: "Generando resumen con IA..."
- Subtexto: "Esto puede tomar unos segundos"
- ProgressView indeterminado
- Botón "Cancelar" (volver a detalle)

**Auto-refresh:**
- Polling cada 5 segundos hasta que esté listo
- Máximo 6 intentos (30 segundos total)
- Si falla, mostrar error

```swift
func pollForSummary() async {
    for attempt in 1...6 {
        try? await Task.sleep(for: .seconds(5))
        
        let result = await getSummaryUseCase.execute(materialId: material.id)
        
        switch result {
        case .success(let summary):
            state = .loaded(summary)
            return
        case .failure(let error):
            if attempt == 6 {
                state = .error(error)
            }
            // Continuar polling
        }
    }
}
```

#### Empty (404 Not Found)

**Indicador:**
- Icono: brain.fill con signo de interrogación
- Título: "Resumen no disponible"
- Descripción: "Este material aún no tiene un resumen generado"
- Botón: "Generar Resumen" (semi-dummy, mostrar toast "Próximamente")

#### Error

**Tipos de error:**
1. **Network error:** "No se pudo cargar el resumen"
2. **Server error:** "Error al generar el resumen"
3. **Timeout:** "La generación del resumen está tardando más de lo esperado"

**Indicador:**
- Alert con mensaje de error
- Botón "Reintentar"
- Botón "Cancelar"

#### Success

**Indicador:**
- Resumen completo visible
- Secciones con contenido
- Scroll habilitado

---

### Interacciones

#### Copiar Resumen (macOS/iPad)

```swift
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button("Copiar") {
            UIPasteboard.general.string = viewModel.summary.summary
            showToast("Resumen copiado")
        }
    }
}
```

#### Compartir

```swift
ShareLink(item: shareableContent) {
    Label("Compartir", systemImage: "square.and.arrow.up")
}

var shareableContent: String {
    """
    📝 Resumen IA - \(material.title)
    
    \(summary.summary)
    
    ✨ Puntos Clave:
    \(summary.keyPoints.map { "• \($0)" }.joined(separator: "\n"))
    
    Generado por EduGo con \(summary.model)
    """
}
```

#### Exportar (macOS)

```swift
Button("Exportar PDF") {
    let pdf = generatePDFFromSummary(summary)
    saveFilePicker(pdf)
}
```

#### Cerrar

**iPhone/iPad (Sheet):**
```swift
.toolbar {
    ToolbarItem(placement: .cancellationAction) {
        Button("Cerrar") {
            dismiss()
        }
    }
}
```

**macOS (Window):**
- Botón cerrar nativo de la ventana (×)
- Cmd+W

---

### Validaciones

#### Pre-carga

- ✅ Verificar que `material.hasSummary == true`
- ✅ Manejar 404 si resumen no existe
- ✅ Manejar 202 si resumen está en proceso

#### Durante Visualización

- ✅ Validar que arrays no estén vacíos antes de renderizar
- ✅ Truncar texto muy largo (max 5000 caracteres)
- ✅ Sanitizar HTML si viene del backend (no esperado)

#### Compartir/Exportar

- ✅ Validar que haya contenido antes de compartir
- ✅ Formatear correctamente para diferentes destinos (texto plano, PDF)

---

### Lógica Semi-Dummy

#### NO Implementar en Primera Fase

1. **Regenerar resumen:**
   - ❌ Botón "Regenerar con más detalle"
   - ❌ Opciones de personalización (longitud, enfoque)
   - ✅ Solo mostrar resumen existente

2. **Traducir resumen:**
   - ❌ Traducir a otros idiomas
   - ✅ Solo idioma original (español)

3. **Chat con IA sobre el resumen:**
   - ❌ Hacer preguntas sobre el contenido
   - ❌ Profundizar en conceptos
   - ✅ Solo resumen estático

4. **Anotaciones en resumen:**
   - ❌ Agregar notas personales
   - ❌ Highlight de secciones importantes
   - ✅ Solo lectura

5. **Comparar con otros materiales:**
   - ❌ Ver resúmenes relacionados
   - ❌ Comparar conceptos entre materiales

#### Implementar Dummy

1. **Botón "Generar Resumen"** (si 404):
   - ✅ Mostrar botón
   - ❌ No implementar generación (toast "Esta función estará disponible próximamente")

2. **Badge de confianza:**
   - ✅ Mostrar `confidence_score` si está disponible
   - ❌ No mostrar si < 0.7 (no confiar en resúmenes de baja calidad)

3. **Indicador "Generado por IA":**
   - ✅ Mostrar siempre para transparencia
   - ✅ Incluir modelo usado (GPT-4, etc.)

---

## 📊 Resumen de Implementación

### Checklist de Desarrollo

#### MaterialsListView
- [ ] Crear ViewModel con estados (loading, loaded, empty, error)
- [ ] Implementar GetMaterialsUseCase
- [ ] Crear DSMaterialCard component
- [ ] Crear DSFilterPicker component
- [ ] Crear DSSearchBar component
- [ ] Implementar pull-to-refresh
- [ ] Implementar infinite scroll
- [ ] Layouts por plataforma (iPhone, iPad, Mac)
- [ ] Tests unitarios de ViewModel
- [ ] Tests de UI (snapshot tests)

#### MaterialDetailView
- [ ] Crear ViewModel con estados
- [ ] Implementar GetMaterialUseCase
- [ ] Implementar GetDownloadURLUseCase
- [ ] Crear DSMaterialHeader component
- [ ] Crear DSActionButton component
- [ ] Crear DSInfoSection component
- [ ] Implementar navegación a PDFReaderView
- [ ] Implementar navegación a SummaryView
- [ ] Layouts por plataforma
- [ ] Tests unitarios y de UI

#### PDFReaderView
- [ ] Crear ViewModel con estados
- [ ] Implementar PDFKit integration
- [ ] Crear DSPDFViewer component
- [ ] Crear DSPageNavigator component
- [ ] Crear DSThumbnailSidebar (iPad/Mac)
- [ ] Implementar tracking de progreso
- [ ] Implementar UpdateProgressUseCase
- [ ] Implementar auto-hide toolbars (iPhone)
- [ ] Implementar gestos (swipe, zoom, tap)
- [ ] Layouts por plataforma
- [ ] Tests de tracking de progreso

#### SummaryView
- [ ] Crear ViewModel con estados (+ processing state)
- [ ] Implementar GetSummaryUseCase
- [ ] Implementar polling para estado 202
- [ ] Crear DSSummaryHeader component
- [ ] Crear DSSummarySection component
- [ ] Crear DSConceptCard component
- [ ] Crear DSKeyPointsList component
- [ ] Implementar compartir/exportar
- [ ] Layouts por plataforma
- [ ] Tests unitarios y de UI

---

## 🔗 Dependencias entre Pantallas

```
MaterialsListView (Raíz)
    ↓ Navigation Push
MaterialDetailView
    ↓ Full Screen Cover (iPhone/iPad) / Window (Mac)
PDFReaderView
    ↓ Sheet (iPhone/iPad) / Window (Mac)
SummaryView
```

**Alternativa desde DetailView:**
```
MaterialDetailView
    ↓ Sheet (todos)
SummaryView
```

---

## 📱 Navegación entre Pantallas

### NavigationStack Setup

```swift
NavigationStack(path: $navigationPath) {
    MaterialsListView()
        .navigationDestination(for: MaterialDestination.self) { destination in
            switch destination {
            case .detail(let material):
                MaterialDetailView(material: material)
            case .summary(let material):
                SummaryView(material: material)
            }
        }
}
.fullScreenCover(item: $presentedPDF) { material in
    PDFReaderView(material: material)
}
```

### Deep Linking (Futuro)

```
edugo://materials -> MaterialsListView
edugo://materials/:id -> MaterialDetailView
edugo://materials/:id/pdf -> PDFReaderView
edugo://materials/:id/summary -> SummaryView
```

---

## 🎨 Tokens de Design System Usados

### Colores
- `DSColors.cardBackground`
- `DSColors.accent` (verde para progreso)
- `DSColors.textPrimary`
- `DSColors.textSecondary`
- `DSColors.progressBackground`

### Espaciado
- `DSSpacing.xs` (4pt)
- `DSSpacing.sm` (8pt)
- `DSSpacing.md` (16pt)
- `DSSpacing.lg` (24pt)
- `DSSpacing.xl` (32pt)

### Tipografía
- `DSText.title1` (34pt, bold)
- `DSText.title2` (28pt, bold)
- `DSText.headline` (17pt, semibold)
- `DSText.subheadline` (15pt, regular)
- `DSText.body` (17pt, regular)

### Elevación
- `DSElevation.level1` (shadow para cards)

---

## 📝 Notas para el Desarrollador

1. **Usar Clean Architecture:**
   - ViewModels → Use Cases → Repositories
   - Domain entities independientes de UI
   - Result<T, AppError> para manejo de errores

2. **Concurrency:**
   - ViewModels con `@Observable` y `@MainActor`
   - Use Cases con `async/await`
   - No usar `nonisolated(unsafe)`

3. **Testing:**
   - Tests unitarios para Use Cases
   - Tests de ViewModel (mock use cases)
   - Snapshot tests para UI components
   - Tests de integración para flujos completos

4. **Accesibilidad:**
   - Labels para VoiceOver en todos los botones
   - Traits adecuados (`.button`, `.header`, etc.)
   - Dynamic Type support
   - Contraste de colores según WCAG 2.1

5. **Performance:**
   - LazyVGrid para listas grandes
   - Image caching para íconos/thumbnails
   - Debounce para búsqueda y tracking
   - Pagination para listas

6. **Errores:**
   - Nunca crashear, siempre mostrar error gracefully
   - Logs con contexto (logger.error con metadata)
   - Retry logic para network errors
   - Timeouts razonables (30s para requests)

---

**Generado por:** Claude Code  
**Fecha:** 1 de Diciembre, 2025  
**Próxima parte:** PANTALLAS-NUEVAS-PARTE2.md (QuizView, ResultsView, etc.)
