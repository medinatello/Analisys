# Pantallas de la App de Administración EduGo

## Índice

### Pantallas Implementadas (con endpoints existentes)
1. [DashboardAdminView](#1-dashboardadminview)
2. [SchoolsListView](#2-schoolslistview)
3. [SchoolDetailView](#3-schooldetailview)
4. [AcademicTreeView](#4-academictreeview)
5. [UnitDetailView](#5-unitdetailview)
6. [MembershipsView](#6-membershipsview)
7. [UsersListView](#7-userslistview)
8. [UserDetailView](#8-userdetailview)
9. [GuardiansView](#9-guardiansview)
10. [SubjectsView](#10-subjectsview)

### Pantallas Futuras (sin endpoints)
11. [CyclesView](#11-cyclesview-futuro)
12. [SchedulesView](#12-schedulesview-futuro)
13. [ClassroomsView](#13-classroomsview-futuro)
14. [ReportsView](#14-reportsview-futuro)
15. [AuditLogView](#15-auditlogview-futuro)
16. [EventsView](#16-eventsview-futuro)
17. [PaymentsView](#17-paymentsview-futuro)
18. [ImportView](#18-importview-futuro)

---

## Pantallas Implementadas

## 1. DashboardAdminView

### Descripción
Dashboard principal con estadísticas y métricas globales del sistema o de la escuela (según rol del usuario).

### Endpoint Principal
```
GET /v1/stats/global
```

**Response**:
```json
{
  "total_schools": 15,
  "total_users": 1250,
  "users_by_role": {
    "student": 1000,
    "teacher": 150,
    "parent": 800,
    "director_escuela": 15,
    "director_academico": 20
  },
  "total_units": 75,
  "total_subjects": 450,
  "active_students": 980,
  "active_teachers": 145
}
```

### Layout por Plataforma

#### Web (Desktop)
```
┌─────────────────────────────────────────────────────┐
│ Header: Logo | Notificaciones | Usuario            │
├─────────────────────────────────────────────────────┤
│ Sidebar │ Estadísticas Globales                     │
│         ├───────────────────────────────────────────┤
│ - Dashboard│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │
│ - Escuelas │ │Escue-│ │Usua- │ │Estu- │ │Docen-│  │
│ - Usuarios │ │ las  │ │rios  │ │dian- │ │tes   │  │
│ - Unidades │ │  15  │ │ 1250 │ │tes   │ │ 145  │  │
│ - Materias │ │      │ │      │ │ 1000 │ │      │  │
│ - Reportes │ └──────┘ └──────┘ └──────┘ └──────┘  │
│            │                                        │
│            │ Distribución por Rol                  │
│            │ ┌────────────────────────────────┐    │
│            │ │ [Gráfica de barras]            │    │
│            │ │ Estudiantes: ████████ 80%      │    │
│            │ │ Docentes:    ██ 12%            │    │
│            │ │ Tutores:     █ 6%              │    │
│            │ │ Admins:      ▌ 2%              │    │
│            │ └────────────────────────────────┘    │
│            │                                        │
│            │ Actividad Reciente                    │
│            │ ┌────────────────────────────────┐    │
│            │ │ • Nueva escuela creada...      │    │
│            │ │ • 15 estudiantes registrados...│    │
│            │ │ • Materia asignada...          │    │
│            │ └────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

#### Mobile (iOS/Android)
```
┌──────────────────────┐
│ ☰  Dashboard    🔔 👤│
├──────────────────────┤
│ Estadísticas         │
│                      │
│ ┌─────────┐┌────────┐│
│ │Escuelas ││Usuarios││
│ │   15    ││  1250  ││
│ └─────────┘└────────┘│
│                      │
│ ┌─────────┐┌────────┐│
│ │Estudian-││Docentes││
│ │tes 1000 ││  145   ││
│ └─────────┘└────────┘│
│                      │
│ Distribución         │
│ ┌──────────────────┐ │
│ │ [Gráfica pie]    │ │
│ └──────────────────┘ │
│                      │
│ Actividad Reciente   │
│ ┌──────────────────┐ │
│ │ • Nueva escuela  │ │
│ │ • 15 estudiantes │ │
│ │ • Materia asign. │ │
│ └──────────────────┘ │
│        [Ver más]     │
└──────────────────────┘
```

### Componentes UI

#### Componentes Principales
1. **StatsCard**: Tarjeta con métrica numérica
   - Props: `title`, `value`, `icon`, `trend`, `color`
   - Variantes: default, success, warning, danger

2. **ChartWidget**: Contenedor para gráficas
   - Props: `title`, `chartType`, `data`, `options`
   - Tipos soportados: bar, pie, line, doughnut

3. **ActivityFeed**: Lista de actividades recientes
   - Props: `activities`, `limit`, `onLoadMore`
   - Formato: icon, descripción, timestamp

4. **FilterBar**: Barra de filtros
   - Props: `filters`, `onFilterChange`
   - Filtros: fecha, escuela (super_admin), tipo de métrica

#### Componentes de Interacción
- **RefreshButton**: Actualizar estadísticas
- **ExportButton**: Exportar datos (CSV, PDF)
- **DateRangePicker**: Selección de rango de fechas

### CRUD Operations

#### Read (R)
- **GET** `/v1/stats/global` - Obtener estadísticas globales
- **GET** `/v1/stats/global?school_id={id}` - Estadísticas de escuela específica
- **GET** `/v1/stats/global?from={date}&to={date}` - Estadísticas por rango

No hay operaciones Create, Update o Delete en esta pantalla.

### Validaciones

#### Permisos
- `super_admin`: Ve estadísticas de todas las escuelas
- `director_escuela`: Solo ve estadísticas de su escuela
- `director_academico`: Ve estadísticas académicas de su escuela
- `coordinador`: Ve estadísticas de sus unidades asignadas

#### Filtros
- Validar formato de fechas (ISO 8601)
- Validar que `to_date >= from_date`
- Limitar rango máximo a 1 año

### Permisos Requeridos
- Mínimo: `authenticated_user`
- Acceso filtrado automáticamente según rol

---

## 2. SchoolsListView

### Descripción
Lista paginada de todas las escuelas del sistema (solo para super_admin) o vista de escuela única (otros roles).

### Endpoint Principal
```
GET /v1/schools
GET /v1/schools?page=1&limit=20&search=nombre
```

**Response**:
```json
{
  "schools": [
    {
      "id": "uuid-1",
      "name": "Escuela Primaria San Martín",
      "code": "ESP-001",
      "address": "Av. Principal 123",
      "city": "Madrid",
      "country": "España",
      "email": "contacto@sanmartin.edu",
      "phone": "+34 912345678",
      "active": true,
      "created_at": "2024-01-15T10:00:00Z",
      "stats": {
        "total_students": 350,
        "total_teachers": 25,
        "total_units": 12
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "total_pages": 3
  }
}
```

### Layout por Plataforma

#### Web (Desktop)
```
┌─────────────────────────────────────────────────────┐
│ Escuelas                        [+ Nueva Escuela]   │
├─────────────────────────────────────────────────────┤
│ 🔍 Buscar...          📊 Filtros  ⚙️ Ordenar       │
├─────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────┐ │
│ │ [Logo] Escuela Primaria San Martín              │ │
│ │        ESP-001                                   │ │
│ │        Madrid, España                           │ │
│ │        📧 contacto@sanmartin.edu               │ │
│ │        👨‍🎓 350 estudiantes | 👨‍🏫 25 docentes   │ │
│ │                          [Ver] [Editar] [...]   │ │
│ └─────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────┐ │
│ │ [Logo] Colegio Secundario Bolívar               │ │
│ │        CSB-002                                   │ │
│ │        Barcelona, España                        │ │
│ │        📧 info@bolivar.edu                      │ │
│ │        👨‍🎓 520 estudiantes | 👨‍🏫 42 docentes   │ │
│ │                          [Ver] [Editar] [...]   │ │
│ └─────────────────────────────────────────────────┘ │
│                                                      │
│              [◀ Anterior]  1 2 3  [Siguiente ▶]     │
└─────────────────────────────────────────────────────┘
```

#### Mobile
```
┌──────────────────────┐
│ ☰  Escuelas    🔔 👤 │
│ [+ Nueva]            │
├──────────────────────┤
│ 🔍 Buscar...         │
├──────────────────────┤
│ ┌──────────────────┐ │
│ │ 🏫 San Martín    │ │
│ │ ESP-001          │ │
│ │ 👨‍🎓 350  👨‍🏫 25  │ │
│ │ Madrid           │ │
│ │      [Ver][Editar]│ │
│ └──────────────────┘ │
│                      │
│ ┌──────────────────┐ │
│ │ 🏫 Bolívar       │ │
│ │ CSB-002          │ │
│ │ 👨‍🎓 520  👨‍🏫 42  │ │
│ │ Barcelona        │ │
│ │      [Ver][Editar]│ │
│ └──────────────────┘ │
│                      │
│ [Cargar más...]      │
└──────────────────────┘
```

### Componentes UI

#### Componentes de Lista
1. **SchoolCard**: Tarjeta de escuela
   - Props: `school`, `onView`, `onEdit`, `onDelete`
   - Estados: active, inactive, archived

2. **SearchBar**: Barra de búsqueda
   - Props: `placeholder`, `onSearch`, `debounceMs`
   - Búsqueda por: nombre, código, ciudad

3. **FilterPanel**: Panel de filtros
   - Filtros: activo/inactivo, ciudad, país
   - Props: `filters`, `onFilterChange`

4. **SortDropdown**: Selector de ordenamiento
   - Opciones: nombre A-Z, nombre Z-A, fecha creación, estudiantes

#### Componentes de Paginación
- **Pagination**: Paginador
  - Props: `page`, `totalPages`, `onPageChange`

### CRUD Operations

#### Create (C)
```
POST /v1/schools
```

**Request Body**:
```json
{
  "name": "Nueva Escuela",
  "code": "NE-001",
  "address": "Calle 123",
  "city": "Madrid",
  "country": "España",
  "email": "contacto@nuevaescuela.edu",
  "phone": "+34 912345678",
  "active": true
}
```

**Validaciones**:
- `name`: requerido, 3-200 caracteres
- `code`: requerido, único, 3-50 caracteres
- `email`: formato email válido
- `phone`: formato internacional válido

#### Read (R)
```
GET /v1/schools?page={page}&limit={limit}&search={query}&active={bool}
```

**Parámetros**:
- `page`: número de página (default: 1)
- `limit`: elementos por página (default: 20, max: 100)
- `search`: búsqueda por nombre o código
- `active`: filtrar por estado (true/false)

#### Update (U)
Ver [SchoolDetailView](#3-schooldetailview)

#### Delete (D)
```
DELETE /v1/schools/:id
```

**Confirmación**: Modal de confirmación antes de eliminar
**Soft Delete**: Marca como inactiva, no elimina físicamente

### Validaciones

#### Campos Requeridos
- Nombre de escuela
- Código único
- País
- Email de contacto

#### Formatos
- Email: formato RFC 5322
- Teléfono: E.164 (ej: +34912345678)
- Código: alfanumérico, sin espacios

### Permisos Requeridos
- **super_admin**: CRUD completo en todas las escuelas
- **director_escuela**: Solo lectura de su escuela
- **Otros roles**: Sin acceso a esta vista

---

## 3. SchoolDetailView

### Descripción
Vista detallada y edición de una escuela específica.

### Endpoints
```
GET /v1/schools/:id
PUT /v1/schools/:id
DELETE /v1/schools/:id
```

**Response GET**:
```json
{
  "id": "uuid-1",
  "name": "Escuela Primaria San Martín",
  "code": "ESP-001",
  "address": "Av. Principal 123",
  "city": "Madrid",
  "state": "Comunidad de Madrid",
  "country": "España",
  "postal_code": "28001",
  "email": "contacto@sanmartin.edu",
  "phone": "+34 912345678",
  "website": "https://sanmartin.edu",
  "logo_url": "https://cdn.edugo.com/logos/esp001.png",
  "active": true,
  "settings": {
    "timezone": "Europe/Madrid",
    "language": "es",
    "currency": "EUR"
  },
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-11-20T15:30:00Z"
}
```

### Layout por Plataforma

#### Web (Desktop) - Modo Vista
```
┌─────────────────────────────────────────────────────┐
│ ← Volver a Escuelas                    [Editar]     │
├─────────────────────────────────────────────────────┤
│ ┌───────┐  Escuela Primaria San Martín             │
│ │ [Logo]│  ESP-001                                  │
│ └───────┘  ✅ Activa                                │
├─────────────────────────────────────────────────────┤
│ Información General          │ Estadísticas         │
│ ────────────────────────────│──────────────────────│
│ 📍 Dirección:                │ 👨‍🎓 Estudiantes: 350│
│    Av. Principal 123         │ 👨‍🏫 Docentes: 25   │
│    28001 Madrid              │ 📚 Unidades: 12     │
│    Comunidad de Madrid       │ 📖 Materias: 45     │
│    España                    │                      │
│                              │ Actividad            │
│ 📧 Email:                    │ ────────────────────│
│    contacto@sanmartin.edu    │ Última actividad:   │
│                              │ Hace 2 horas        │
│ 📞 Teléfono:                 │                      │
│    +34 912345678             │ Creada:             │
│                              │ 15 Ene 2024         │
│ 🌐 Web:                      │                      │
│    sanmartin.edu             │ Actualizada:        │
│                              │ 20 Nov 2024         │
├─────────────────────────────────────────────────────┤
│ Configuración                                        │
│ ────────────────────────────────────────────────────│
│ 🌍 Zona Horaria: Europe/Madrid                      │
│ 🗣️ Idioma: Español                                  │
│ 💰 Moneda: EUR                                       │
├─────────────────────────────────────────────────────┤
│ Acciones                                             │
│ ────────────────────────────────────────────────────│
│ [Ver Estructura Académica] [Gestionar Usuarios]     │
│ [Configurar Periodos] [Ver Reportes]                │
│                                                      │
│                       [Desactivar Escuela]           │
└─────────────────────────────────────────────────────┘
```

#### Web (Desktop) - Modo Edición
```
┌─────────────────────────────────────────────────────┐
│ ← Cancelar                     [Guardar Cambios]    │
├─────────────────────────────────────────────────────┤
│ Editar Escuela: ESP-001                             │
├─────────────────────────────────────────────────────┤
│ Información Básica                                   │
│ ────────────────────────────────────────────────────│
│ Nombre *                                             │
│ ┌────────────────────────────────────────────────┐  │
│ │ Escuela Primaria San Martín                    │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Código Único *                                       │
│ ┌────────────────────────────────────────────────┐  │
│ │ ESP-001                                        │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Dirección                                            │
│ ────────────────────────────────────────────────────│
│ Calle y Número *                                     │
│ ┌────────────────────────────────────────────────┐  │
│ │ Av. Principal 123                              │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Ciudad *            │ Código Postal │ Estado/Región │
│ ┌─────────────────┐ │ ┌──────────┐ │ ┌────────────┐│
│ │ Madrid          │ │ │ 28001    │ │ │ Com. Madrid││
│ └─────────────────┘ │ └──────────┘ │ └────────────┘│
│                                                      │
│ País *                                               │
│ ┌────────────────────────────────────────────────┐  │
│ │ España                              ▼          │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Contacto                                             │
│ ────────────────────────────────────────────────────│
│ Email *                                              │
│ ┌────────────────────────────────────────────────┐  │
│ │ contacto@sanmartin.edu                         │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Teléfono *                                           │
│ ┌────────────────────────────────────────────────┐  │
│ │ +34 912345678                                  │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Sitio Web                                            │
│ ┌────────────────────────────────────────────────┐  │
│ │ https://sanmartin.edu                          │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Logo                                                 │
│ ┌────────────────────────────────────────────────┐  │
│ │ [Cargar imagen] [Vista previa]                 │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Configuración Regional                               │
│ ────────────────────────────────────────────────────│
│ Zona Horaria *      │ Idioma *      │ Moneda *      │
│ ┌─────────────────┐ │ ┌──────────┐ │ ┌───────────┐ │
│ │ Europe/Madrid ▼ │ │ │ Español▼ │ │ │ EUR     ▼ │ │
│ └─────────────────┘ │ └──────────┘ │ └───────────┘ │
│                                                      │
│ Estado                                               │
│ ┌─┐ Activa                                           │
│ │✓│ Permitir nuevos registros                       │
│ └─┘                                                  │
│                                                      │
│              [Cancelar]  [Guardar Cambios]          │
└─────────────────────────────────────────────────────┘
```

### Componentes UI

#### Modo Vista
1. **SchoolHeader**: Cabecera con logo y nombre
2. **InfoSection**: Sección de información
3. **StatsPanel**: Panel de estadísticas
4. **ActionBar**: Barra de acciones rápidas

#### Modo Edición
1. **FormField**: Campo de formulario genérico
2. **AddressForm**: Formulario de dirección
3. **ContactForm**: Formulario de contacto
4. **SettingsForm**: Configuración regional
5. **ImageUploader**: Cargador de logo

### CRUD Operations

#### Read (R)
```
GET /v1/schools/:id
```

#### Update (U)
```
PUT /v1/schools/:id
```

**Request Body**:
```json
{
  "name": "Escuela Primaria San Martín Actualizada",
  "address": "Nueva Dirección 456",
  "phone": "+34 987654321",
  "active": true,
  "settings": {
    "timezone": "Europe/Madrid",
    "language": "es",
    "currency": "EUR"
  }
}
```

#### Delete (D)
```
DELETE /v1/schools/:id
```

**Comportamiento**:
- Soft delete (marca como inactiva)
- Requiere confirmación con contraseña
- Impacto: Desactiva acceso para todos los usuarios de la escuela

### Validaciones

#### Campos Obligatorios
- Nombre (3-200 caracteres)
- Código único (3-50 caracteres)
- País
- Email de contacto (formato válido)
- Teléfono (formato E.164)

#### Campos Opcionales
- Dirección completa
- Código postal
- Estado/Región
- Sitio web (URL válida)
- Logo (imagen PNG/JPG, max 2MB)

#### Validaciones de Negocio
- Código debe ser único en el sistema
- Email debe ser único
- No permitir desactivar si tiene estudiantes activos (warning)

### Permisos Requeridos
- **super_admin**: CRUD completo
- **director_escuela**: Solo lectura de su escuela, edición limitada (contacto, logo)
- **Otros roles**: Sin acceso

---

## 4. AcademicTreeView

### Descripción
Visualización jerárquica de la estructura académica de una escuela (niveles, grados, secciones, grupos).

### Endpoint Principal
```
GET /v1/schools/:school_id/units/tree
```

**Response**:
```json
{
  "school_id": "uuid-school",
  "school_name": "Escuela Primaria San Martín",
  "tree": [
    {
      "id": "uuid-nivel-1",
      "name": "Educación Primaria",
      "type": "nivel",
      "parent_id": null,
      "students_count": 350,
      "teachers_count": 15,
      "children": [
        {
          "id": "uuid-grado-1",
          "name": "1er Grado",
          "type": "grado",
          "parent_id": "uuid-nivel-1",
          "students_count": 60,
          "teachers_count": 3,
          "children": [
            {
              "id": "uuid-seccion-1a",
              "name": "Sección A",
              "type": "seccion",
              "parent_id": "uuid-grado-1",
              "students_count": 30,
              "teachers_count": 1,
              "subjects_count": 5,
              "children": []
            },
            {
              "id": "uuid-seccion-1b",
              "name": "Sección B",
              "type": "seccion",
              "parent_id": "uuid-grado-1",
              "students_count": 30,
              "teachers_count": 1,
              "subjects_count": 5,
              "children": []
            }
          ]
        },
        {
          "id": "uuid-grado-2",
          "name": "2do Grado",
          "type": "grado",
          "parent_id": "uuid-nivel-1",
          "students_count": 58,
          "teachers_count": 2,
          "children": [...]
        }
      ]
    }
  ]
}
```

### Layout por Plataforma

#### Web (Desktop)
```
┌─────────────────────────────────────────────────────┐
│ Estructura Académica - Escuela San Martín           │
│                              [+ Añadir Unidad]      │
├─────────────────────────────────────────────────────┤
│ 🔍 Buscar unidad...          📊 Expandir todo       │
├─────────────────────────────────────────────────────┤
│                                                      │
│ 📚 Educación Primaria (350 estudiantes, 15 docentes)│
│   └─ 📖 1er Grado (60 est., 3 doc.)          [+][-]│
│       ├─ 🏫 Sección A (30 est., 1 doc., 5 mat.) [⚙]│
│       └─ 🏫 Sección B (30 est., 1 doc., 5 mat.) [⚙]│
│   └─ 📖 2do Grado (58 est., 2 doc.)          [+][-]│
│       ├─ 🏫 Sección A (29 est., 1 doc., 5 mat.) [⚙]│
│       └─ 🏫 Sección B (29 est., 1 doc., 5 mat.) [⚙]│
│   └─ 📖 3er Grado (62 est., 2 doc.)          [+][-]│
│       ├─ 🏫 Sección A (31 est., 1 doc., 6 mat.) [⚙]│
│       └─ 🏫 Sección B (31 est., 1 doc., 6 mat.) [⚙]│
│                                                      │
│ 📚 Educación Secundaria (290 est., 18 doc.)         │
│   └─ 📖 1er Año (95 est., 6 doc.)            [+][-]│
│       ├─ 🏫 Sección A (32 est., 2 doc., 8 mat.) [⚙]│
│       ├─ 🏫 Sección B (31 est., 2 doc., 8 mat.) [⚙]│
│       └─ 🏫 Sección C (32 est., 2 doc., 8 mat.) [⚙]│
│                                                      │
│ [+] = Añadir hijo | [-] = Eliminar | [⚙] = Editar  │
└─────────────────────────────────────────────────────┘
```

#### Mobile
```
┌──────────────────────┐
│ ☰ Estructura    🔔 👤│
│ Escuela San Martín   │
│ [+ Nueva Unidad]     │
├──────────────────────┤
│ 🔍 Buscar...         │
├──────────────────────┤
│ ▼ 📚 Ed. Primaria    │
│   350 👨‍🎓 | 15 👨‍🏫  │
│                      │
│   ▼ 📖 1er Grado     │
│     60 👨‍🎓 | 3 👨‍🏫  │
│                      │
│     ▶ 🏫 Sección A   │
│       30👨‍🎓|1👨‍🏫|5📖│
│       [⚙️]           │
│                      │
│     ▶ 🏫 Sección B   │
│       30👨‍🎓|1👨‍��|5📖│
│       [⚙️]           │
│                      │
│   ▶ 📖 2do Grado     │
│     58 👨‍🎓 | 2 👨‍🏫  │
│                      │
│ ▶ 📚 Ed. Secundaria  │
│   290 👨‍🎓 | 18 👨‍🏫 │
│                      │
└──────────────────────┘
```

### Componentes UI

#### Componentes de Árbol
1. **TreeView**: Componente principal de árbol
   - Props: `data`, `expanded`, `onExpand`, `onSelect`
   - Soporta drag & drop para reordenar

2. **TreeNode**: Nodo individual
   - Props: `unit`, `level`, `hasChildren`, `expanded`
   - Variantes por tipo: nivel, grado, seccion, grupo

3. **UnitCard**: Tarjeta de unidad en el árbol
   - Props: `unit`, `stats`, `actions`
   - Muestra: nombre, tipo, contadores, acciones

#### Componentes de Acción
1. **AddUnitButton**: Botón para añadir unidad
   - Context-aware: sugiere tipo según nivel padre
   
2. **UnitActions**: Menú de acciones
   - Opciones: editar, eliminar, añadir hijo, ver detalles

3. **SearchBar**: Búsqueda en árbol
   - Filtra y expande automáticamente

### CRUD Operations

#### Read (R)
```
GET /v1/schools/:school_id/units/tree
```

**Nota**: La creación, edición y eliminación de unidades se hace desde [UnitDetailView](#5-unitdetailview) o mediante endpoints directos de units.

### Validaciones

#### Permisos
- `super_admin`: Ve y edita todo
- `director_escuela`: Ve y edita toda su escuela
- `director_academico`: Ve y edita toda su escuela
- `coordinador`: Solo ve y edita unidades asignadas
- `docente`: Solo visualización de unidades donde tiene membresía

#### Reglas de Negocio
- No permitir eliminar unidad con estudiantes asignados
- Validar jerarquía: nivel → grado → sección → grupo
- Límite de niveles de profundidad: 5

### Permisos Requeridos
- Mínimo: `authenticated_user` con membresía en la escuela
- Edición: `director_escuela`, `director_academico`, `super_admin`

---

## 5. UnitDetailView

### Descripción
Vista detallada y edición de una unidad académica (nivel, grado, sección, grupo).

### Endpoints
```
GET /v1/units/:id
PUT /v1/units/:id
DELETE /v1/units/:id
POST /v1/units
```

**Response GET**:
```json
{
  "id": "uuid-unit",
  "school_id": "uuid-school",
  "name": "Sección A",
  "type": "seccion",
  "parent_id": "uuid-grado-1",
  "order": 1,
  "active": true,
  "capacity": 35,
  "description": "Sección A del primer grado",
  "settings": {
    "allows_auto_enrollment": false,
    "requires_approval": true
  },
  "stats": {
    "students_count": 30,
    "teachers_count": 1,
    "subjects_count": 5
  },
  "parent": {
    "id": "uuid-grado-1",
    "name": "1er Grado"
  },
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-11-20T15:30:00Z"
}
```

### Layout por Plataforma

#### Web (Desktop) - Modo Vista
```
┌─────────────────────────────────────────────────────┐
│ ← Volver a Estructura                  [Editar]     │
├─────────────────────────────────────────────────────┤
│ 🏫 Sección A - 1er Grado                            │
│    Educación Primaria > 1er Grado > Sección A       │
│    ✅ Activa                                         │
├─────────────────────────────────────────────────────┤
│ Información General          │ Estadísticas         │
│ ────────────────────────────│──────────────────────│
│ Tipo: Sección                │ 👨‍🎓 Estudiantes: 30 │
│                              │ 📚 Capacidad: 35     │
│ Padre: 1er Grado             │ 📊 Ocupación: 85.7% │
│                              │                      │
│ Orden: 1                     │ 👨‍🏫 Docentes: 1    │
│                              │ 📖 Materias: 5      │
│ Descripción:                 │                      │
│ Sección A del primer grado   │                      │
├─────────────────────────────────────────────────────┤
│ Configuración                                        │
│ ────────────────────────────────────────────────────│
│ ❌ Auto-inscripción deshabilitada                   │
│ ✅ Requiere aprobación para unirse                  │
├─────────────────────────────────────────────────────┤
│ Acciones Rápidas                                     │
│ ────────────────────────────────────────────────────│
│ [Ver Estudiantes] [Gestionar Materias]              │
│ [Asignar Docente] [Ver Horarios]                    │
│                                                      │
│                       [Desactivar Unidad]            │
└─────────────────────────────────────────────────────┘
```

#### Web (Desktop) - Modo Edición/Creación
```
┌─────────────────────────────────────────────────────┐
│ ← Cancelar                     [Guardar Cambios]    │
├─────────────────────────────────────────────────────┤
│ Editar Unidad: Sección A                            │
├─────────────────────────────────────────────────────┤
│ Información Básica                                   │
│ ────────────────────────────────────────────────────│
│ Nombre *                                             │
│ ┌────────────────────────────────────────────────┐  │
│ │ Sección A                                      │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Tipo *                                               │
│ ┌────────────────────────────────────────────────┐  │
│ │ Sección                             ▼          │  │
│ └────────────────────────────────────────────────┘  │
│ Opciones: Nivel, Grado, Sección, Grupo              │
│                                                      │
│ Unidad Padre *                                       │
│ ┌────────────────────────────────────────────────┐  │
│ │ 1er Grado (Ed. Primaria)            ▼          │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Orden                      │ Capacidad               │
│ ┌─────────────────────────┐│┌──────────────────────┐│
│ │ 1                       │││ 35                   ││
│ └─────────────────────────┘│└──────────────────────┘│
│                                                      │
│ Descripción                                          │
│ ┌────────────────────────────────────────────────┐  │
│ │ Sección A del primer grado de educación        │  │
│ │ primaria.                                      │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Configuración                                        │
│ ────────────────────────────────────────────────────│
│ ┌─┐ Permitir auto-inscripción                       │
│ │ │                                                  │
│ └─┘                                                  │
│                                                      │
│ ┌─┐ Requiere aprobación para unirse                 │
│ │✓│                                                  │
│ └─┘                                                  │
│                                                      │
│ Estado                                               │
│ ┌─┐ Activa                                           │
│ │✓│                                                  │
│ └─┘                                                  │
│                                                      │
│              [Cancelar]  [Guardar Cambios]          │
└─────────────────────────────────────────────────────┘
```

### Componentes UI

#### Modo Vista
1. **UnitHeader**: Cabecera con breadcrumb jerárquico
2. **UnitInfoPanel**: Panel de información general
3. **UnitStatsPanel**: Estadísticas de la unidad
4. **QuickActionsBar**: Acciones rápidas contextuales

#### Modo Edición
1. **UnitForm**: Formulario completo de unidad
2. **ParentSelector**: Selector de unidad padre (tree dropdown)
3. **CapacityInput**: Input numérico con validación
4. **SettingsToggles**: Checkboxes de configuración

### CRUD Operations

#### Create (C)
```
POST /v1/units
```

**Request Body**:
```json
{
  "school_id": "uuid-school",
  "name": "Sección C",
  "type": "seccion",
  "parent_id": "uuid-grado-1",
  "order": 3,
  "capacity": 30,
  "description": "Nueva sección",
  "active": true,
  "settings": {
    "allows_auto_enrollment": false,
    "requires_approval": true
  }
}
```

**Validaciones**:
- `school_id`: requerido, debe existir
- `name`: requerido, 2-100 caracteres
- `type`: enum (nivel, grado, seccion, grupo)
- `parent_id`: opcional, debe ser unidad válida de la misma escuela
- `capacity`: opcional, entero > 0

#### Read (R)
```
GET /v1/units/:id
```

#### Update (U)
```
PUT /v1/units/:id
```

**Request Body**: Misma estructura que POST

**Restricciones**:
- No permitir cambiar `type` si tiene unidades hijas
- No permitir cambiar `parent_id` si rompe jerarquía válida
- No reducir `capacity` por debajo del número de estudiantes actuales

#### Delete (D)
```
DELETE /v1/units/:id
```

**Validaciones**:
- No permitir si tiene estudiantes asignados
- No permitir si tiene unidades hijas
- Requiere confirmación

### Validaciones

#### Campos Obligatorios
- Nombre (2-100 caracteres)
- Tipo (nivel, grado, seccion, grupo)
- Escuela (school_id)

#### Campos Opcionales
- Unidad padre (parent_id)
- Orden (default: 0)
- Capacidad (default: null = sin límite)
- Descripción
- Configuración

#### Reglas de Jerarquía
1. `nivel` puede tener parent_id = null
2. `grado` debe tener parent tipo `nivel`
3. `seccion` debe tener parent tipo `grado`
4. `grupo` debe tener parent tipo `seccion`

#### Validaciones de Negocio
- Nombre único por escuela y nivel jerárquico
- Capacidad >= estudiantes actuales
- No ciclos en jerarquía (parent no puede ser descendiente)

### Permisos Requeridos
- **super_admin**: CRUD completo
- **director_escuela**: CRUD en su escuela
- **director_academico**: CRUD en su escuela
- **coordinador**: Solo editar unidades asignadas
- **Otros roles**: Solo lectura

---

## 6. MembershipsView

### Descripción
Gestión de membresías (asignaciones de usuarios a unidades académicas).

### Endpoints
```
GET /v1/memberships?unit_id={id}&user_id={id}&role={role}
POST /v1/memberships
PUT /v1/memberships/:id
DELETE /v1/memberships/:id
```

**Response GET**:
```json
{
  "memberships": [
    {
      "id": "uuid-membership",
      "user_id": "uuid-user",
      "unit_id": "uuid-unit",
      "role": "student",
      "status": "active",
      "enrolled_at": "2024-09-01T08:00:00Z",
      "expires_at": "2025-06-30T23:59:59Z",
      "user": {
        "id": "uuid-user",
        "name": "Juan Pérez",
        "email": "juan.perez@ejemplo.com"
      },
      "unit": {
        "id": "uuid-unit",
        "name": "Sección A",
        "type": "seccion",
        "school_id": "uuid-school"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 150
  }
}
```

### Layout por Plataforma

#### Web (Desktop)
```
┌─────────────────────────────────────────────────────┐
│ Membresías - Sección A (1er Grado)                  │
│                              [+ Añadir Miembro]     │
├─────────────────────────────────────────────────────┤
│ Filtros:                                             │
│ 🔍 Buscar usuario...  [Rol: Todos ▼] [Estado ▼]    │
├─────────────────────────────────────────────────────┤
│ Estudiantes (30)                    [Expandir] [▼]  │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 👨‍🎓 Juan Pérez                                  │ │
│ │    juan.perez@ejemplo.com                       │ │
│ │    Inscrito: 01 Sep 2024 | Expira: 30 Jun 2025 │ │
│ │    Estado: ✅ Activo                            │ │
│ │                          [Editar] [Remover]     │ │
│ ├─────────────────────────────────────────────────┤ │
│ │ 👧 María García                                 │ │
│ │    maria.garcia@ejemplo.com                     │ │
│ │    Inscrito: 01 Sep 2024 | Expira: 30 Jun 2025 │ │
│ │    Estado: ✅ Activo                            │ │
│ │                          [Editar] [Remover]     │ │
│ └─────────────────────────────────────────────────┘ │
│                                                      │
│ Docentes (1)                        [Expandir] [▼]  │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 👨‍🏫 Prof. Roberto Sánchez                      │ │
│ │    roberto.sanchez@sanmartin.edu               │ │
│ │    Asignado: 01 Sep 2024                       │ │
│ │    Estado: ✅ Activo                            │ │
│ │                          [Editar] [Remover]     │ │
│ └─────────────────────────────────────────────────┘ │
│                                                      │
│              [◀ Anterior]  1 2 3  [Siguiente ▶]     │
└─────────────────────────────────────────────────────┘
```

#### Mobile
```
┌──────────────────────┐
│ ☰  Membresías   🔔 👤│
│ Sección A - 1er Grado│
│ [+ Añadir]           │
├──────────────────────┤
│ 🔍 Buscar...         │
│ [Filtros: Rol▼ Estado▼]│
├──────────────────────┤
│ ▼ Estudiantes (30)   │
│                      │
│ ┌──────────────────┐ │
│ │ 👨‍🎓 Juan Pérez  │ │
│ │ juan.perez@...   │ │
│ │ 01/09/24-30/06/25│ │
│ │ ✅ Activo        │ │
│ │   [✏️] [🗑️]     │ │
│ └──────────────────┘ │
│                      │
│ ┌──────────────────┐ │
│ │ 👧 María García  │ │
│ │ maria.g@...      │ │
│ │ 01/09/24-30/06/25│ │
│ │ ✅ Activo        │ │
│ │   [✏️] [🗑️]     │ │
│ └──────────────────┘ │
│                      │
│ ▶ Docentes (1)       │
│                      │
│ [Cargar más...]      │
└──────────────────────┘
```

### Componentes UI

#### Componentes de Lista
1. **MembershipsList**: Lista agrupada por rol
   - Props: `memberships`, `groupBy`, `onEdit`, `onDelete`
   - Grupos expandibles/colapsables

2. **MembershipCard**: Tarjeta de membresía individual
   - Props: `membership`, `actions`
   - Muestra: usuario, fechas, estado, acciones

3. **AddMembershipModal**: Modal para añadir membresía
   - UserSelector: Autocompletado de usuarios
   - RoleSelector: Selección de rol
   - DateRangePicker: Fechas de vigencia

#### Componentes de Filtrado
1. **RoleFilter**: Filtro por rol
   - Opciones: Todos, Estudiante, Docente, Coordinador

2. **StatusFilter**: Filtro por estado
   - Opciones: Todos, Activo, Inactivo, Expirado, Pendiente

3. **SearchBar**: Búsqueda por nombre o email

### CRUD Operations

#### Create (C)
```
POST /v1/memberships
```

**Request Body**:
```json
{
  "user_id": "uuid-user",
  "unit_id": "uuid-unit",
  "role": "student",
  "enrolled_at": "2024-09-01T08:00:00Z",
  "expires_at": "2025-06-30T23:59:59Z"
}
```

**Validaciones**:
- `user_id`: requerido, debe existir
- `unit_id`: requerido, debe existir
- `role`: enum (student, teacher, coordinator, observer)
- `enrolled_at`: fecha ISO 8601 (default: now)
- `expires_at`: opcional, debe ser > enrolled_at

#### Read (R)
```
GET /v1/memberships?unit_id={id}
GET /v1/memberships?user_id={id}
GET /v1/memberships?unit_id={id}&role=student&status=active
```

**Parámetros**:
- `unit_id`: filtrar por unidad
- `user_id`: filtrar por usuario
- `role`: filtrar por rol
- `status`: filtrar por estado (active, inactive, expired, pending)
- `page`, `limit`: paginación

#### Update (U)
```
PUT /v1/memberships/:id
```

**Request Body**:
```json
{
  "status": "inactive",
  "expires_at": "2025-12-31T23:59:59Z"
}
```

**Campos editables**:
- `status`: cambiar estado
- `expires_at`: extender o acortar vigencia
- `role`: cambiar rol (con validaciones)

#### Delete (D)
```
DELETE /v1/memberships/:id
```

**Comportamiento**:
- Elimina la relación usuario-unidad
- Requiere confirmación
- Impacto: Usuario pierde acceso a recursos de la unidad

### Validaciones

#### Reglas de Negocio
1. Un usuario no puede tener múltiples membresías activas del mismo rol en la misma unidad
2. Un estudiante debe tener al menos una membresía activa
3. Capacidad: No exceder capacidad de la unidad (si está definida)
4. Fechas: `expires_at` debe ser posterior a `enrolled_at`
5. Roles compatibles: Validar que el rol del usuario sea compatible con el tipo de unidad

#### Validaciones de Permisos
- Solo usuarios con rol apropiado pueden ser asignados
- Estudiantes requieren relación con tutor activa

### Permisos Requeridos
- **super_admin**: CRUD completo
- **director_escuela**: CRUD en su escuela
- **director_academico**: CRUD en su escuela
- **coordinador**: CRUD en unidades asignadas
- **Otros roles**: Solo lectura de sus propias membresías

---

## 7. UsersListView

### Descripción
Lista paginada y filtrable de usuarios del sistema (o de una escuela específica).

### Endpoints
```
GET /v1/users?page=1&limit=20&role={role}&school_id={id}&search={query}
POST /v1/users
```

**Response GET**:
```json
{
  "users": [
    {
      "id": "uuid-user",
      "name": "Juan Pérez",
      "email": "juan.perez@ejemplo.com",
      "role": "student",
      "phone": "+34 612345678",
      "active": true,
      "email_verified": true,
      "avatar_url": "https://cdn.edugo.com/avatars/user123.jpg",
      "school_id": "uuid-school",
      "school_name": "Escuela San Martín",
      "memberships_count": 1,
      "created_at": "2024-08-15T10:00:00Z",
      "last_login": "2024-11-28T09:15:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1250,
    "total_pages": 63
  }
}
```

### Layout por Plataforma

#### Web (Desktop)
```
┌─────────────────────────────────────────────────────┐
│ Usuarios                        [+ Nuevo Usuario]   │
├─────────────────────────────────────────────────────┤
│ 🔍 Buscar...    [Rol: Todos ▼] [Escuela ▼] [Estado]│
│ [Exportar CSV] [Importar Masivo]                    │
├─────────────────────────────────────────────────────┤
│ Nombre          │ Email         │ Rol      │ Estado │
│─────────────────┼───────────────┼──────────┼────────│
│ 👨‍🎓 Juan Pérez │ juan.p@...    │Estudiante│ ✅    │
│ Escuela: San M. │ Última: 28/11 │          │[Ver][✏️]│
│─────────────────┼───────────────┼──────────┼────────│
│ 👧 María García│ maria.g@...   │Estudiante│ ✅    │
│ Escuela: San M. │ Última: 27/11 │          │[Ver][✏️]│
│─────────────────┼───────────────┼──────────┼────────│
│ 👨‍🏫 R. Sánchez│ roberto.s@... │Docente   │ ✅    │
│ Escuela: San M. │ Última: 28/11 │          │[Ver][✏️]│
│─────────────────┼───────────────┼──────────┼────────│
│ 👨‍💼 Ana López │ ana.l@...     │Director  │ ✅    │
│ Escuela: San M. │ Última: 28/11 │          │[Ver][✏️]│
│─────────────────┼───────────────┼──────────┼────────│
│                                                      │
│              [◀ Anterior]  1 2 3  [Siguiente ▶]     │
│              Mostrando 1-20 de 1250                 │
└─────────────────────────────────────────────────────┘
```

#### Mobile
```
┌──────────────────────┐
│ ☰  Usuarios     🔔 👤│
│ [+ Nuevo]            │
├──────────────────────┤
│ 🔍 Buscar...         │
│ [Filtros: Rol▼ Estado▼]│
├──────────────────────┤
│ ┌──────────────────┐ │
│ │ 👨‍🎓 Juan Pérez  │ │
│ │ Estudiante       │ │
│ │ juan.p@...       │ │
│ │ San Martín       │ │
│ │ ✅ Activo        │ │
│ │      [Ver] [✏️]  │ │
│ └──────────────────┘ │
│                      │
│ ┌──────────────────┐ │
│ │ 👧 María García  │ │
│ │ Estudiante       │ │
│ │ maria.g@...      │ │
│ │ San Martín       │ │
│ │ ✅ Activo        │ │
│ │      [Ver] [✏️]  │ │
│ └──────────────────┘ │
│                      │
│ [Cargar más...]      │
└──────────────────────┘
```

### Componentes UI

#### Componentes de Lista
1. **UsersTable**: Tabla de usuarios (desktop)
   - Props: `users`, `columns`, `sortable`, `actions`
   - Soporta ordenamiento por columnas

2. **UserCard**: Tarjeta de usuario (mobile)
   - Props: `user`, `actions`, `compact`
   - Variantes por rol (student, teacher, admin)

3. **UserAvatar**: Avatar con fallback a iniciales
   - Props: `user`, `size`, `status`
   - Indicador de estado online/offline

#### Componentes de Filtrado y Búsqueda
1. **SearchBar**: Búsqueda por nombre, email
   - Debounce 300ms
   - Highlight de resultados

2. **RoleFilter**: Filtro por rol
   - Multi-select
   - Opciones: student, teacher, parent, director_escuela, director_academico, coordinador, super_admin

3. **SchoolFilter**: Filtro por escuela (super_admin)
   - Autocompletado
   - Solo si `super_admin`

4. **StatusFilter**: Filtro por estado
   - Opciones: activo, inactivo, email verificado, sin verificar

#### Componentes de Acción
1. **CreateUserButton**: Botón crear usuario
2. **ExportButton**: Exportar CSV/Excel
3. **ImportButton**: Importación masiva
4. **BulkActionsBar**: Acciones masivas (desactivar, activar, eliminar)

### CRUD Operations

#### Create (C)
```
POST /v1/users
```

**Request Body**:
```json
{
  "name": "Juan Pérez",
  "email": "juan.perez@ejemplo.com",
  "password": "SecurePass123!",
  "role": "student",
  "phone": "+34 612345678",
  "school_id": "uuid-school",
  "active": true,
  "metadata": {
    "grade": "1er Grado",
    "section": "A"
  }
}
```

**Validaciones**:
- `name`: requerido, 2-100 caracteres
- `email`: requerido, único, formato válido
- `password`: requerido, mínimo 8 caracteres, al menos 1 mayúscula, 1 número
- `role`: enum válido
- `school_id`: requerido (excepto super_admin)
- `phone`: formato E.164

#### Read (R)
```
GET /v1/users?page=1&limit=20&role=student&school_id={id}&search=Juan&active=true&sort=name:asc
```

**Parámetros**:
- `page`, `limit`: paginación
- `role`: filtrar por rol
- `school_id`: filtrar por escuela
- `search`: búsqueda por nombre o email (LIKE)
- `active`: filtrar por estado (true/false)
- `sort`: ordenar por campo (name, created_at, last_login) + dirección (asc/desc)

#### Update (U)
Ver [UserDetailView](#8-userdetailview)

#### Delete (D)
```
DELETE /v1/users/:id
```

**Comportamiento**:
- Soft delete (marca como inactivo)
- Requiere confirmación
- Impacto: Usuario pierde acceso al sistema

### Validaciones

#### Campos Requeridos
- Nombre
- Email único
- Password (solo en creación)
- Rol
- Escuela (excepto super_admin)

#### Validaciones de Negocio
- Email único en el sistema
- No permitir cambiar rol a super_admin (excepto desde super_admin)
- Estudiantes deben tener tutor asignado
- Docentes deben tener al menos una membresía

### Permisos Requeridos
- **super_admin**: CRUD completo en todos los usuarios
- **director_escuela**: CRUD en usuarios de su escuela
- **director_academico**: CRUD en usuarios de su escuela
- **coordinador**: Solo lectura
- **Otros roles**: Sin acceso

---

## 8. UserDetailView

### Descripción
Vista detallada y edición de un usuario específico.

### Endpoints
```
GET /v1/users/:id
PATCH /v1/users/:id
DELETE /v1/users/:id
```

**Response GET**:
```json
{
  "id": "uuid-user",
  "name": "Juan Pérez García",
  "email": "juan.perez@ejemplo.com",
  "role": "student",
  "phone": "+34 612345678",
  "date_of_birth": "2010-03-15",
  "avatar_url": "https://cdn.edugo.com/avatars/user123.jpg",
  "active": true,
  "email_verified": true,
  "phone_verified": false,
  "school_id": "uuid-school",
  "school_name": "Escuela Primaria San Martín",
  "address": {
    "street": "Calle Ejemplo 123",
    "city": "Madrid",
    "postal_code": "28001",
    "country": "España"
  },
  "metadata": {
    "student_id": "EST-2024-001",
    "allergies": "Ninguna",
    "emergency_contact": "+34 687654321"
  },
  "memberships": [
    {
      "id": "uuid-membership",
      "unit_id": "uuid-unit",
      "unit_name": "Sección A - 1er Grado",
      "role": "student",
      "status": "active"
    }
  ],
  "guardians": [
    {
      "id": "uuid-relation",
      "guardian_id": "uuid-guardian",
      "guardian_name": "María García",
      "relationship": "madre",
      "primary": true
    }
  ],
  "created_at": "2024-08-15T10:00:00Z",
  "updated_at": "2024-11-20T15:30:00Z",
  "last_login": "2024-11-28T09:15:00Z"
}
```

### Layout por Plataforma

#### Web (Desktop) - Modo Vista
```
┌─────────────────────────────────────────────────────┐
│ ← Volver a Usuarios                    [Editar]     │
├─────────────────────────────────────────────────────┤
│ ┌────────┐  Juan Pérez García                       │
│ │ Avatar │  Estudiante                              │
│ └────────┘  ✅ Activo | ✉️ Email verificado         │
│             Escuela Primaria San Martín             │
├─────────────────────────────────────────────────────┤
│ Información Personal     │ Membresías               │
│ ────────────────────────│──────────────────────────│
│ 📧 Email:                │ 🏫 Sección A - 1er Grado│
│    juan.perez@ejemplo.com│    Rol: Estudiante      │
│                          │    Estado: ✅ Activo    │
│ 📞 Teléfono:             │                          │
│    +34 612345678         │ [Ver todas (1)]         │
│                          │                          │
│ 🎂 Fecha de Nacimiento:  │ Tutores                 │
│    15 Marzo 2010 (14 años)│ ────────────────────────│
│                          │ 👤 María García (madre) │
│ 📍 Dirección:            │    Tutor principal      │
│    Calle Ejemplo 123     │                          │
│    28001 Madrid          │ [Ver todos (1)]         │
│    España                │                          │
│                          │                          │
│ 🆔 ID Estudiante:        │ Actividad               │
│    EST-2024-001          │ ────────────────────────│
│                          │ Último acceso:          │
│ ⚕️ Alergias:             │ 28 Nov 2024, 09:15      │
│    Ninguna               │                          │
│                          │ Creado:                 │
│ 🚨 Contacto Emergencia:  │ 15 Ago 2024             │
│    +34 687654321         │                          │
├─────────────────────────────────────────────────────┤
│ Acciones                                             │
│ ────────────────────────────────────────────────────│
│ [Ver Progreso] [Gestionar Membresías] [Tutores]    │
│ [Restablecer Contraseña] [Enviar Email Verificación]│
│                                                      │
│                       [Desactivar Usuario]           │
└─────────────────────────────────────────────────────┘
```

#### Web (Desktop) - Modo Edición
```
┌─────────────────────────────────────────────────────┐
│ ← Cancelar                     [Guardar Cambios]    │
├─────────────────────────────────────────────────────┤
│ Editar Usuario: Juan Pérez García                   │
├─────────────────────────────────────────────────────┤
│ Avatar                                               │
│ ┌──────────┐                                         │
│ │  [Foto]  │  [Cambiar Avatar] [Eliminar]           │
│ └──────────┘                                         │
│                                                      │
│ Información Personal                                 │
│ ────────────────────────────────────────────────────│
│ Nombre Completo *                                    │
│ ┌────────────────────────────────────────────────┐  │
│ │ Juan Pérez García                              │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Email *                                              │
│ ┌────────────────────────────────────────────────┐  │
│ │ juan.perez@ejemplo.com                         │  │
│ └────────────────────────────────────────────────┘  │
│ ✅ Email verificado                                 │
│                                                      │
│ Teléfono                                             │
│ ┌────────────────────────────────────────────────┐  │
│ │ +34 612345678                                  │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Fecha de Nacimiento                                  │
│ ┌────────────────────────────────────────────────┐  │
│ │ 15/03/2010                          📅         │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Rol *                                                │
│ ┌────────────────────────────────────────────────┐  │
│ │ Estudiante                          ▼          │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Escuela *                                            │
│ ┌────────────────────────────────────────────────┐  │
│ │ Escuela Primaria San Martín         ▼          │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Dirección                                            │
│ ────────────────────────────────────────────────────│
│ Calle y Número                                       │
│ ┌────────────────────────────────────────────────┐  │
│ │ Calle Ejemplo 123                              │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Ciudad          │ Código Postal │ País              │
│ ┌──────────────┐│┌─────────────┐│┌────────────────┐│
│ │ Madrid       │││ 28001       │││ España       ▼ ││
│ └──────────────┘│└─────────────┘│└────────────────┘│
│                                                      │
│ Información Adicional (Estudiantes)                  │
│ ────────────────────────────────────────────────────│
│ ID Estudiante                                        │
│ ┌────────────────────────────────────────────────┐  │
│ │ EST-2024-001                                   │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Alergias                                             │
│ ┌────────────────────────────────────────────────┐  │
│ │ Ninguna                                        │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Contacto de Emergencia                               │
│ ┌────────────────────────────────────────────────┐  │
│ │ +34 687654321                                  │  │
│ └────────────────────────────────────────────────┘  │
│                                                      │
│ Estado                                               │
│ ┌─┐ Usuario Activo                                   │
│ │✓│                                                  │
│ └─┘                                                  │
│                                                      │
│              [Cancelar]  [Guardar Cambios]          │
└─────────────────────────────────────────────────────┘
```

### Componentes UI

#### Modo Vista
1. **UserHeader**: Cabecera con avatar y datos principales
2. **UserInfoPanel**: Panel de información personal
3. **MembershipsPanel**: Panel de membresías del usuario
4. **GuardiansPanel**: Panel de tutores (si es estudiante)
5. **ActivityPanel**: Panel de actividad reciente

#### Modo Edición
1. **UserForm**: Formulario completo de usuario
2. **AvatarUploader**: Cargador de avatar
3. **AddressForm**: Formulario de dirección
4. **MetadataForm**: Formulario de metadatos (varía según rol)

### CRUD Operations

#### Read (R)
```
GET /v1/users/:id
```

#### Update (U)
```
PATCH /v1/users/:id
```

**Request Body**:
```json
{
  "name": "Juan Pérez García Actualizado",
  "phone": "+34 600000000",
  "date_of_birth": "2010-03-15",
  "active": true,
  "address": {
    "street": "Nueva Calle 456",
    "city": "Madrid",
    "postal_code": "28002",
    "country": "España"
  },
  "metadata": {
    "allergies": "Polen",
    "emergency_contact": "+34 611111111"
  }
}
```

**Campos editables**:
- Información personal (nombre, teléfono, fecha nacimiento, dirección)
- Metadata (según rol)
- Estado (active)

**Campos NO editables** (requieren endpoints especiales):
- Email (requiere verificación)
- Password (requiere `PATCH /v1/users/:id/password`)
- Rol (requiere `PATCH /v1/users/:id/role` con permisos especiales)

#### Delete (D)
```
DELETE /v1/users/:id
```

**Comportamiento**:
- Soft delete (marca como inactivo)
- Requiere confirmación con password de admin
- Impacto: Elimina membresías, relaciones, acceso

### Validaciones

#### Campos Obligatorios
- Nombre (2-100 caracteres)
- Email único (formato válido)
- Rol
- Escuela (excepto super_admin)

#### Campos Opcionales
- Teléfono (formato E.164)
- Fecha de nacimiento (debe ser pasada)
- Dirección completa
- Avatar (imagen, max 5MB)
- Metadata (JSON válido)

#### Validaciones de Negocio
- No permitir cambiar email sin verificación
- No permitir cambiar rol a super_admin (solo super_admin puede hacerlo)
- Estudiantes menores de edad requieren tutor
- No permitir desactivar si tiene membresías activas (warning)

### Permisos Requeridos
- **super_admin**: CRUD completo
- **director_escuela**: CRUD en usuarios de su escuela
- **director_academico**: CRUD en usuarios de su escuela
- **coordinador**: Solo lectura
- **usuario**: Solo editar su propio perfil (campos limitados)

---

## 9. GuardiansView

### Descripción
Gestión de relaciones tutor-estudiante.

### Endpoints
```
GET /v1/guardian-relations?student_id={id}&guardian_id={id}
POST /v1/guardian-relations
```

**Response GET**:
```json
{
  "relations": [
    {
      "id": "uuid-relation",
      "student_id": "uuid-student",
      "guardian_id": "uuid-guardian",
      "relationship": "madre",
      "primary": true,
      "can_pickup": true,
      "can_authorize_medical": true,
      "created_at": "2024-08-15T10:00:00Z",
      "student": {
        "id": "uuid-student",
        "name": "Juan Pérez",
        "email": "juan.perez@ejemplo.com"
      },
      "guardian": {
        "id": "uuid-guardian",
        "name": "María García",
        "email": "maria.garcia@ejemplo.com",
        "phone": "+34 612345678"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 150
  }
}
```

### Layout por Plataforma

#### Web (Desktop)
```
┌─────────────────────────────────────────────────────┐
│ Relaciones Tutor-Estudiante    [+ Nueva Relación]  │
├─────────────────────────────────────────────────────┤
│ Filtros:                                             │
│ 🔍 Buscar estudiante o tutor...  [Relación ▼]      │
├─────────────────────────────────────────────────────┤
│ Estudiante         │ Tutor           │ Relación     │
│────────────────────┼─────────────────┼──────────────│
│ 👨‍🎓 Juan Pérez    │ 👤 María García │ Madre       │
│ juan.p@...         │ maria.g@...     │ ⭐ Principal│
│ 1er Grado - Secc A │ +34 612345678   │ ✅ Recoger  │
│                    │                 │ ✅ Médico   │
│                    │          [Ver] [Editar] [🗑️]  │
│────────────────────┼─────────────────┼──────────────│
│ 👨‍🎓 Juan Pérez    │ 👤 Carlos Pérez │ Padre       │
│ juan.p@...         │ carlos.p@...    │              │
│ 1er Grado - Secc A │ +34 687654321   │ ✅ Recoger  │
│                    │                 │ ✅ Médico   │
│                    │          [Ver] [Editar] [🗑️]  │
│────────────────────┼─────────────────┼──────────────│
│ 👧 Ana López       │ 👤 Luis López   │ Padre       │
│ ana.l@...          │ luis.l@...      │ ⭐ Principal│
│ 2do Grado - Secc B │ +34 611111111   │ ✅ Recoger  │
│                    │                 │ ❌ Médico   │
│                    │          [Ver] [Editar] [🗑️]  │
│────────────────────┼─────────────────┼──────────────│
│                                                      │
│              [◀ Anterior]  1 2 3  [Siguiente ▶]     │
└─────────────────────────────────────────────────────┘
```

#### Mobile
```
┌──────────────────────┐
│ ☰  Tutores      🔔 👤│
│ [+ Nueva Relación]   │
├──────────────────────┤
│ 🔍 Buscar...         │
│ [Filtro: Relación ▼] │
├──────────────────────┤
│ ┌──────────────────┐ │
│ │ 👨‍🎓 Juan Pérez  │ │
│ │ 1° Grado - Sec A │ │
│ │                  │ │
│ │ 👤 María García  │ │
│ │ Madre ⭐         │ │
│ │ maria.g@...      │ │
│ │ +34 612345678    │ │
│ │ ✅Recoger ✅Médico│ │
│ │   [Ver][✏️][🗑️] │ │
│ └──────────────────┘ │
│                      │
│ ┌──────────────────┐ │
│ │ 👨‍🎓 Juan Pérez  │ │
│ │ 1° Grado - Sec A │ │
│ │                  │ │
│ │ 👤 Carlos Pérez  │ │
│ │ Padre            │ │
│ │ carlos.p@...     │ │
│ │ +34 687654321    │ │
│ │ ✅Recoger ✅Médico│ │
│ │   [Ver][✏️][🗑️] │ │
│ └──────────────────┘ │
│                      │
│ [Cargar más...]      │
└──────────────────────┘
```

### Componentes UI

#### Componentes de Lista
1. **GuardianRelationsList**: Lista de relaciones
   - Props: `relations`, `onEdit`, `onDelete`
   - Agrupable por estudiante o por tutor

2. **RelationCard**: Tarjeta de relación
   - Props: `relation`, `actions`, `viewMode`
   - Modos: `student-centric`, `guardian-centric`

3. **AddRelationModal**: Modal para crear relación
   - StudentSelector: Autocompletado de estudiantes
   - GuardianSelector: Autocompletado de tutores (o crear nuevo)
   - RelationshipSelector: Tipo de relación
   - PermissionsToggles: Permisos (pickup, medical)

#### Componentes de Filtrado
1. **RelationshipFilter**: Filtro por tipo de relación
   - Opciones: padre, madre, abuelo/a, tío/a, tutor legal, otro

2. **PrimaryFilter**: Filtro por tutor principal
   - Toggle: Solo principales

3. **SearchBar**: Búsqueda por nombre de estudiante o tutor

### CRUD Operations

#### Create (C)
```
POST /v1/guardian-relations
```

**Request Body**:
```json
{
  "student_id": "uuid-student",
  "guardian_id": "uuid-guardian",
  "relationship": "madre",
  "primary": true,
  "can_pickup": true,
  "can_authorize_medical": true
}
```

**Validaciones**:
- `student_id`: requerido, debe existir, role = student
- `guardian_id`: requerido, debe existir, role = parent
- `relationship`: enum (padre, madre, abuelo, abuela, tio, tia, tutor_legal, otro)
- `primary`: boolean (solo puede haber uno por estudiante)
- `can_pickup`: boolean
- `can_authorize_medical`: boolean

#### Read (R)
```
GET /v1/guardian-relations?student_id={id}
GET /v1/guardian-relations?guardian_id={id}
GET /v1/guardian-relations?student_id={id}&primary=true
```

**Parámetros**:
- `student_id`: filtrar por estudiante
- `guardian_id`: filtrar por tutor
- `primary`: filtrar solo tutores principales
- `page`, `limit`: paginación

#### Update (U)
*Actualmente no hay endpoint PATCH, solo crear/eliminar*

**Futuro**:
```
PATCH /v1/guardian-relations/:id
```

Para actualizar permisos o cambiar tutor principal.

#### Delete (D)
*Actualmente no documentado, pero debe existir*

```
DELETE /v1/guardian-relations/:id
```

**Validaciones**:
- No permitir eliminar si es el único tutor del estudiante
- Si era `primary`, promover otro tutor a principal

### Validaciones

#### Reglas de Negocio
1. Un estudiante debe tener al menos un tutor
2. Solo puede haber un tutor `primary=true` por estudiante
3. El `guardian_id` debe ser un usuario con rol `parent`
4. El `student_id` debe ser un usuario con rol `student`
5. No duplicar relación estudiante-tutor (unique constraint)

#### Validaciones de Permisos
- Solo usuarios autorizados pueden crear/eliminar relaciones
- Los tutores solo pueden ver sus propias relaciones
- Admin puede ver/editar todas las relaciones de su escuela

### Permisos Requeridos
- **super_admin**: CRUD completo
- **director_escuela**: CRUD en su escuela
- **director_academico**: CRUD en su escuela
- **coordinador**: CRUD en unidades asignadas
- **parent**: Solo lectura de sus relaciones
- **Otros roles**: Sin acceso

---

## 10. SubjectsView

### Descripción
Gestión de materias (asignaturas) por unidad académica.

### Endpoints
```
GET /v1/subjects?unit_id={id}
POST /v1/subjects
PATCH /v1/subjects/:id
```

**Response GET**:
```json
{
  "subjects": [
    {
      "id": "uuid-subject",
      "name": "Matemáticas",
      "code": "MAT-101",
      "description": "Matemáticas básicas para primer grado",
      "unit_id": "uuid-unit",
      "unit_name": "Sección A - 1er Grado",
      "teacher_id": "uuid-teacher",
      "teacher_name": "Prof. Roberto Sánchez",
      "hours_per_week": 5,
      "active": true,
      "created_at": "2024-08-01T10:00:00Z",
      "updated_at": "2024-09-15T14:20:00Z"
    },
    {
      "id": "uuid-subject-2",
      "name": "Lenguaje",
      "code": "LEN-101",
      "description": "Lenguaje y comunicación",
      "unit_id": "uuid-unit",
      "unit_name": "Sección A - 1er Grado",
      "teacher_id": "uuid-teacher-2",
      "teacher_name": "Prof. Ana Martínez",
      "hours_per_week": 6,
      "active": true,
      "created_at": "2024-08-01T10:00:00Z",
      "updated_at": "2024-09-15T14:20:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 45
  }
}
```

### Layout por Plataforma

#### Web (Desktop)
```
┌─────────────────────────────────────────────────────┐
│ Materias - Sección A (1er Grado)   [+ Nueva Materia]│
├─────────────────────────────────────────────────────┤
│ 🔍 Buscar materia...              [Estado: Activas] │
├─────────────────────────────────────────────────────┤
│ Materia         │ Código  │ Docente      │ Hrs/Sem │
│─────────────────┼─────────┼──────────────┼─────────│
│ 📐 Matemáticas  │MAT-101  │ R. Sánchez   │ 5 hrs   │
│ Matemáticas...  │         │ roberto.s@...│         │
│                 │              [Ver] [Editar] [🗑️] │
│─────────────────┼─────────┼──────────────┼─────────│
│ 📝 Lenguaje     │LEN-101  │ A. Martínez  │ 6 hrs   │
│ Lenguaje y...   │         │ ana.m@...    │         │
│                 │              [Ver] [Editar] [🗑️] │
│─────────────────┼─────────┼──────────────┼─────────│
│ 🔬 Ciencias     │CIE-101  │ R. Sánchez   │ 4 hrs   │
│ Ciencias...     │         │ roberto.s@...│         │
│                 │              [Ver] [Editar] [🗑️] │
│─────────────────┼─────────┼──────────────┼─────────│
│ 🌍 Sociales     │SOC-101  │ M. López     │ 3 hrs   │
│ Estudios...     │         │ maria.l@...  │         │
│                 │              [Ver] [Editar] [🗑️] │
│─────────────────┼─────────┼──────────────┼─────────│
│ 🎨 Arte         │ART-101  │ P. Torres    │ 2 hrs   │
│ Artes...        │         │ pedro.t@...  │         │
│                 │              [Ver] [Editar] [🗑️] │
│─────────────────┼─────────┼──────────────┼─────────│
│                                                      │
│              Total: 5 materias | 20 horas/semana    │
└─────────────────────────────────────────────────────┘
```

#### Mobile
```
┌──────────────────────┐
│ ☰  Materias     🔔 👤│
│ Sección A - 1° Grado │
│ [+ Nueva Materia]    │
├──────────────────────┤
│ 🔍 Buscar...         │
│ [Estado: Activas ▼]  │
├──────────────────────┤
│ ┌──────────────────┐ │
│ │ 📐 Matemáticas   │ │
│ │ MAT-101          │ │
│ │ R. Sánchez       │ │
│ │ 5 hrs/semana     │ │
│ │ ✅ Activa        │ │
│ │   [Ver][✏️][🗑️] │ │
│ └──────────────────┘ │
│                      │
│ ┌──────────────────┐ │
│ │ 📝 Lenguaje      │ │
│ │ LEN-101          │ │
│ │ A. Martínez      │ │
│ │ 6 hrs/semana     │ │
│ │ ✅ Activa        │ │
│ │   [Ver][✏️][🗑️] │ │
│ └──────────────────┘ │
│                      │
│ Total: 5 mat | 20 hrs│
└──────────────────────┘
```

### Componentes UI

#### Componentes de Lista
1. **SubjectsTable**: Tabla de materias (desktop)
   - Props: `subjects`, `unit`, `actions`
   - Muestra totales al pie

2. **SubjectCard**: Tarjeta de materia (mobile)
   - Props: `subject`, `actions`, `compact`
   - Icono según categoría de materia

3. **AddSubjectModal**: Modal para crear materia
   - Fields: nombre, código, descripción, docente, horas
   - TeacherSelector: Autocompletado de docentes

#### Componentes de Filtrado
1. **SearchBar**: Búsqueda por nombre o código
2. **StatusFilter**: Filtro por estado (activa/inactiva)
3. **TeacherFilter**: Filtro por docente asignado

### CRUD Operations

#### Create (C)
```
POST /v1/subjects
```

**Request Body**:
```json
{
  "name": "Matemáticas",
  "code": "MAT-101",
  "description": "Matemáticas básicas para primer grado",
  "unit_id": "uuid-unit",
  "teacher_id": "uuid-teacher",
  "hours_per_week": 5,
  "active": true
}
```

**Validaciones**:
- `name`: requerido, 2-100 caracteres
- `code`: requerido, único por escuela, formato alfanumérico
- `unit_id`: requerido, debe existir
- `teacher_id`: opcional, debe ser usuario con rol teacher
- `hours_per_week`: opcional, entero > 0

#### Read (R)
```
GET /v1/subjects?unit_id={id}&teacher_id={id}&active=true
```

**Parámetros**:
- `unit_id`: filtrar por unidad (requerido usualmente)
- `teacher_id`: filtrar por docente
- `active`: filtrar por estado
- `page`, `limit`: paginación

#### Update (U)
```
PATCH /v1/subjects/:id
```

**Request Body**:
```json
{
  "name": "Matemáticas Avanzadas",
  "teacher_id": "uuid-new-teacher",
  "hours_per_week": 6,
  "active": false
}
```

**Campos editables**:
- Nombre
- Descripción
- Docente asignado
- Horas por semana
- Estado activo/inactivo

**Campos NO editables**:
- Código (requiere creación nueva)
- Unidad (requiere creación nueva)

#### Delete (D)
```
DELETE /v1/subjects/:id
```

**Comportamiento**:
- Soft delete (marca como inactiva)
- Requiere confirmación
- Impacto: Estudiantes pierden acceso a materiales de la materia

### Validaciones

#### Campos Obligatorios
- Nombre (2-100 caracteres)
- Código único por escuela (3-20 caracteres, alfanumérico)
- Unidad académica

#### Campos Opcionales
- Descripción (hasta 500 caracteres)
- Docente asignado
- Horas por semana

#### Reglas de Negocio
1. Código único por escuela (no global)
2. `teacher_id` debe ser usuario con rol `teacher` y membresía en la unidad
3. `hours_per_week` debe ser razonable (1-20 hrs)
4. Una unidad no puede superar límite total de horas (ej: 40 hrs/sem)

### Permisos Requeridos
- **super_admin**: CRUD completo
- **director_escuela**: CRUD en su escuela
- **director_academico**: CRUD en su escuela
- **coordinador**: CRUD en unidades asignadas
- **teacher**: Solo lectura de sus materias
- **Otros roles**: Solo lectura

---

## Pantallas Futuras (Sin Endpoints)

## 11. CyclesView (Futuro)

### Descripción
Gestión de ciclos y periodos académicos (semestres, trimestres, bimestres).

### Endpoints Sugeridos
```
GET /v1/cycles?school_id={id}&active=true
POST /v1/cycles
PATCH /v1/cycles/:id
DELETE /v1/cycles/:id
```

### Funcionalidad Esperada
- Crear periodos académicos (ej: "Ciclo 2024-2025")
- Definir fechas de inicio y fin
- Configurar subdivisiones (trimestres, bimestres)
- Activar/desactivar periodos
- Asociar periodos a calificaciones y progreso

### Impacto en UI
**Pantallas que lo usarían**:
- DashboardAdminView (mostrar periodo activo)
- SchedulesView (horarios por periodo)
- ReportsView (reportes por periodo)
- GradingView (calificaciones por periodo)

**Ver detalles en**: [ENDPOINTS-FALTANTES.md](#ciclos-y-periodos-académicos)

---

## 12. SchedulesView (Futuro)

### Descripción
Programación de horarios por unidad académica (materias, docentes, aulas, días/horas).

### Endpoints Sugeridos
```
GET /v1/schedules?unit_id={id}&teacher_id={id}&cycle_id={id}
POST /v1/schedules
PUT /v1/schedules/:id
DELETE /v1/schedules/:id
```

### Funcionalidad Esperada
- Crear bloques horarios (ej: Lunes 8:00-9:00, Matemáticas, Aula 201)
- Asignar docente y materia
- Asignar aula/recurso
- Detectar conflictos (docente ocupado, aula ocupada)
- Vista de calendario semanal

### Impacto en UI
**Pantallas que lo usarían**:
- AcademicTreeView (ver horario de sección)
- ClassroomsView (ocupación de aulas)
- UserDetailView (horario de docente)
- ReportsView (reportes de carga horaria)

**Ver detalles en**: [ENDPOINTS-FALTANTES.md](#horarios-y-programación)

---

## 13. ClassroomsView (Futuro)

### Descripción
Gestión de aulas, laboratorios y recursos físicos.

### Endpoints Sugeridos
```
GET /v1/classrooms?school_id={id}&type={type}&available=true
POST /v1/classrooms
PUT /v1/classrooms/:id
DELETE /v1/classrooms/:id
```

### Funcionalidad Esperada
- CRUD de aulas (nombre, capacidad, tipo, equipamiento)
- Asignación a horarios
- Disponibilidad en tiempo real
- Reservas de recursos

### Impacto en UI
**Pantallas que lo usarían**:
- SchedulesView (asignar aula a horario)
- SchoolDetailView (lista de recursos de escuela)
- EventsView (reservar aula para evento)

**Ver detalles en**: [ENDPOINTS-FALTANTES.md](#aulas-y-recursos)

---

## 14. ReportsView (Futuro)

### Descripción
Generación y descarga de reportes administrativos y académicos.

### Endpoints Sugeridos
```
GET /v1/reports/types
POST /v1/reports/generate
GET /v1/reports/:id
GET /v1/reports/:id/export?format=pdf|csv|xlsx
```

### Funcionalidad Esperada
- Catálogo de tipos de reportes (académicos, administrativos, financieros)
- Configuración de filtros (periodo, unidad, usuario)
- Generación asíncrona (job queue)
- Descarga en múltiples formatos (PDF, Excel, CSV)

### Tipos de Reportes
1. **Académicos**:
   - Calificaciones por periodo
   - Progreso de estudiantes
   - Asistencia
   - Estadísticas de materias

2. **Administrativos**:
   - Lista de estudiantes
   - Lista de docentes
   - Ocupación de secciones
   - Carga horaria de docentes

3. **Financieros** (futuro):
   - Estado de pagos
   - Deudas pendientes
   - Ingresos por periodo

### Impacto en UI
**Pantallas que lo usarían**:
- DashboardAdminView (reportes rápidos)
- Todas las vistas de gestión (exportar datos)

**Ver detalles en**: [ENDPOINTS-FALTANTES.md](#reportes-administrativos)

---

## 15. AuditLogView (Futuro)

### Descripción
Visualización de logs de auditoría (quién hizo qué y cuándo).

### Endpoints Sugeridos
```
GET /v1/audit-logs?user_id={id}&action={action}&entity={entity}&from={date}&to={date}
GET /v1/audit-logs/:id
```

### Funcionalidad Esperada
- Registro de todas las acciones CRUD
- Filtros por usuario, acción, entidad, fecha
- Detalles de cambios (diff antes/después)
- Solo lectura (inmutable)

### Eventos Auditables
- Creación/edición/eliminación de usuarios
- Cambios en estructura académica
- Asignación de membresías
- Cambios en configuración de escuela
- Acceso a datos sensibles

### Impacto en UI
**Pantallas que lo usarían**:
- DashboardAdminView (actividad reciente)
- UserDetailView (historial de cambios del usuario)
- SchoolDetailView (historial de cambios de escuela)

**Ver detalles en**: [ENDPOINTS-FALTANTES.md](#auditoría-y-logs)

---

## 16. EventsView (Futuro)

### Descripción
Gestión de eventos escolares (reuniones, exámenes, festividades, actividades).

### Endpoints Sugeridos
```
GET /v1/events?school_id={id}&from={date}&to={date}&type={type}
POST /v1/events
PUT /v1/events/:id
DELETE /v1/events/:id
```

### Funcionalidad Esperada
- CRUD de eventos
- Calendario visual (mensual, semanal)
- Notificaciones a participantes
- Adjuntar recursos (documentos, ubicación)
- Gestión de asistencia

### Tipos de Eventos
- Exámenes/evaluaciones
- Reuniones de padres
- Festividades/ceremonias
- Actividades extracurriculares
- Capacitaciones docentes

### Impacto en UI
**Pantallas que lo usarían**:
- DashboardAdminView (próximos eventos)
- ClassroomsView (eventos en aulas)
- UserDetailView (eventos del usuario)
- App Principal (calendario de estudiantes/tutores)

**Ver detalles en**: [ENDPOINTS-FALTANTES.md](#eventos-escolares)

---

## 17. PaymentsView (Futuro)

### Descripción
Módulo de gestión de pagos y finanzas (matrículas, mensualidades, servicios adicionales).

### Endpoints Sugeridos
```
GET /v1/payments?student_id={id}&status={status}&from={date}&to={date}
POST /v1/payments
PATCH /v1/payments/:id
GET /v1/payments/summary?school_id={id}&period={period}
```

### Funcionalidad Esperada
- CRUD de conceptos de pago (matrícula, mensualidad, uniforme, etc.)
- Generación de recibos/facturas
- Registro de pagos (efectivo, transferencia, tarjeta)
- Estados: pendiente, pagado, vencido, anulado
- Recordatorios de pago
- Reportes financieros

### Impacto en UI
**Pantallas que lo usarían**:
- DashboardAdminView (resumen financiero)
- UserDetailView (estudiante - estado de pagos)
- ReportsView (reportes financieros)
- App Principal (tutores - pagar mensualidad)

**Ver detalles en**: [ENDPOINTS-FALTANTES.md](#pagos-y-finanzas)

---

## 18. ImportView (Futuro)

### Descripción
Importación masiva de datos desde archivos Excel/CSV.

### Endpoints Sugeridos
```
POST /v1/import/validate
POST /v1/import/execute
GET /v1/import/jobs/:id
GET /v1/import/templates/{entity}
```

### Funcionalidad Esperada
- Descarga de plantillas (Excel/CSV)
- Validación de archivo antes de importar
- Importación asíncrona (job queue)
- Reporte de errores por fila
- Rollback en caso de error crítico

### Entidades Importables
1. **Usuarios**:
   - Estudiantes (con tutores)
   - Docentes
   - Padres/tutores

2. **Estructura Académica**:
   - Unidades (niveles, grados, secciones)
   - Materias

3. **Membresías**:
   - Asignaciones estudiante-sección
   - Asignaciones docente-materia

### Impacto en UI
**Pantallas que lo usarían**:
- UsersListView (importar usuarios)
- AcademicTreeView (importar estructura)
- MembershipsView (importar asignaciones)

**Ver detalles en**: [ENDPOINTS-FALTANTES.md](#importación-masiva)

---

## Navegación y Flujos

### Menú Principal (Sidebar Desktop)

```
📊 Dashboard
   └─ Estadísticas globales

🏫 Escuelas (solo super_admin)
   ├─ Lista de escuelas
   └─ Crear escuela

👥 Usuarios
   ├─ Lista de usuarios
   ├─ Crear usuario
   └─ Importar usuarios

🏛️ Estructura Académica
   ├─ Árbol jerárquico
   ├─ Gestionar unidades
   └─ Membresías

📚 Académico
   ├─ Materias
   ├─ Horarios (futuro)
   ├─ Ciclos académicos (futuro)
   └─ Aulas (futuro)

👨‍👩‍👧‍👦 Tutores
   └─ Relaciones tutor-estudiante

📊 Reportes (futuro)
   ├─ Académicos
   ├─ Administrativos
   └─ Financieros

💰 Finanzas (futuro)
   ├─ Pagos
   ├─ Facturas
   └─ Reportes financieros

📅 Eventos (futuro)
   ├─ Calendario
   └─ Gestionar eventos

📝 Auditoría (futuro)
   └─ Logs del sistema

⚙️ Configuración
   ├─ Mi perfil
   ├─ Preferencias
   └─ Ayuda
```

### Menú Mobile (Bottom Navigation)

```
┌────────┬────────┬────────┬────────┬────────┐
│   🏠   │   👥   │   🏛️   │   📊   │   ⚙️   │
│  Inicio│Usuarios│Estruct.│Reportes│  Más   │
└────────┴────────┴────────┴────────┴────────┘
```

---

**Última actualización**: 1 de Diciembre, 2025  
**Versión**: 1.0.0  
**Estado**: Documentación inicial
