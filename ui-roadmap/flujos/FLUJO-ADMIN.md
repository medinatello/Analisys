# Flujo de Navegación - Administrador

**Fecha:** 1 de Diciembre, 2025  
**Rol:** `admin`  
**Plataformas:** iOS, iPadOS, macOS, visionOS

---

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Diagrama de Flujo Principal](#diagrama-de-flujo-principal)
3. [Panel Administrativo](#panel-administrativo)
4. [Gestión de Escuelas](#gestión-de-escuelas)
5. [Gestión de Usuarios](#gestión-de-usuarios)
6. [Árbol de Unidades Académicas](#árbol-de-unidades-académicas)
7. [Gestión de Membresías](#gestión-de-membresías)
8. [Flujos Específicos](#flujos-específicos)
9. [Deep Links](#deep-links)
10. [Permisos y Seguridad](#permisos-y-seguridad)

---

## Descripción General

El flujo de navegación del administrador incluye **todas las capacidades de estudiante y docente**, más funcionalidades exclusivas para la gestión global del sistema EduGo.

### Características Principales

- **Todas las funciones de Estudiante y Docente:** Acceso completo sin restricciones
- **Gestión de Escuelas:** Crear, editar, desactivar escuelas
- **Gestión de Usuarios:** CRUD completo de usuarios (estudiantes, docentes, admins)
- **Árbol Académico:** Gestión de unidades académicas (facultades, departamentos, programas)
- **Gestión de Cursos:** Crear, editar, asignar docentes
- **Gestión de Membresías:** Planes, suscripciones, facturación
- **Reportes Globales:** Estadísticas de toda la plataforma
- **Configuración del Sistema:** Parámetros globales

### Capacidades por Rol

```swift
// Permisos del admin (desde UserRole.swift)
- canViewAllContent: true           // Ver TODO el contenido
- canEditContent: true              // Editar TODO el contenido
- canManageUsers: true              // Gestionar TODOS los usuarios
- canAccessAdminPanel: true         // Acceso completo al panel admin
```

---

## Diagrama de Flujo Principal

```
┌─────────────────────────────────────────────────────────────────┐
│                  NAVEGACIÓN ADMINISTRADOR                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │ [AdminHomeView] │
                    │  (Dashboard)    │
                    └─────────────────┘
                              ↓
    ┌──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
    ↓          ↓          ↓          ↓          ↓          ↓          ↓          ↓
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│  HOME  │ │SCHOOLS │ │ USERS  │ │ACADEMIC│ │COURSES │ │MEMBERS │ │REPORTS │ │SETTINGS│
│        │ │  NEW!  │ │  NEW!  │ │ TREE   │ │        │ │  NEW!  │ │  NEW!  │ │        │
│        │ │        │ │        │ │  NEW!  │ │        │ │        │ │        │ │        │
└────────┘ └────────┘ └────────┘ └────────┘ └────────┘ └────────┘ └────────┘ └────────┘
              ↓           ↓           ↓           ↓           ↓          ↓
              │           │           │           │           │          │
    ┌─────────┘           │           │           │           │          │
    ↓                     │           │           │           │          │
[SchoolsListView]        │           │           │           │          │
    ↓                     │           │           │           │          │
[SchoolCard] (Grid)      │           │           │           │          │
    - Logo                │           │           │           │          │
    - Nombre              │           │           │           │          │
    - # Usuarios          │           │           │           │          │
    - Plan                │           │           │           │          │
    - Estado              │           │           │           │          │
    ↓                     │           │           │           │          │
[Tap en escuela]         │           │           │           │          │
    ↓                     │           │           │           │          │
[SchoolDetailView]       │           │           │           │          │
    - Info general        │           │           │           │          │
    - Usuarios            │           │           │           │          │
    - Árbol académico     │           │           │           │          │
    - Membresía           │           │           │           │          │
    - Configuración       │           │           │           │          │
                          │           │           │           │          │
    ┌─────────────────────┘           │           │           │          │
    ↓                                  │           │           │          │
[UsersListView]                       │           │           │          │
    ↓                                  │           │           │          │
[Filtros]                             │           │           │          │
    - Por rol (student/teacher/admin) │           │           │          │
    - Por escuela                     │           │           │          │
    - Por estado (activo/inactivo)    │           │           │          │
    ↓                                  │           │           │          │
[UserCard] (List)                     │           │           │          │
    - Avatar                           │           │           │          │
    - Nombre                           │           │           │          │
    - Email                            │           │           │          │
    - Rol                              │           │           │          │
    - Escuela                          │           │           │          │
    - Estado                           │           │           │          │
    ↓                                  │           │           │          │
[Tap en usuario]                      │           │           │          │
    ↓                                  │           │           │          │
[UserDetailView]                      │           │           │          │
    - Editar info                      │           │           │          │
    - Cambiar rol                      │           │           │          │
    - Cambiar contraseña               │           │           │          │
    - Desactivar/Activar               │           │           │          │
    - Eliminar                         │           │           │          │
                                       │           │           │          │
    ┌──────────────────────────────────┘           │           │          │
    ↓                                               │           │          │
[AcademicTreeView]                                 │           │          │
    ↓                                               │           │          │
[Árbol Jerárquico]                                │           │          │
    Escuela                                        │           │          │
    ├── Facultad A                                │           │          │
    │   ├── Departamento 1                        │           │          │
    │   │   ├── Programa X                        │           │          │
    │   │   └── Programa Y                        │           │          │
    │   └── Departamento 2                        │           │          │
    │       └── Programa Z                        │           │          │
    └── Facultad B                                │           │          │
        └── Departamento 3                        │           │          │
            └── Programa W                        │           │          │
    ↓                                               │           │          │
[Acciones en cada nodo]                           │           │          │
    - Agregar hijo                                 │           │          │
    - Editar                                       │           │          │
    - Eliminar (si no tiene dependencias)         │           │          │
                                                   │           │          │
    ┌──────────────────────────────────────────────┘           │          │
    ↓                                                           │          │
[CoursesAdminView]                                            │          │
    - Ver TODOS los cursos                                     │          │
    - Crear cursos                                             │          │
    - Asignar docentes                                         │          │
    - Asignar estudiantes                                      │          │
    - Archivar/Eliminar cursos                                │          │
                                                               │          │
    ┌──────────────────────────────────────────────────────────┘          │
    ↓                                                                      │
[MembershipsView]                                                         │
    ↓                                                                      │
[Lista de Escuelas con Membresías]                                       │
    - Escuela                                                              │
    - Plan (Free, Basic, Premium, Enterprise)                             │
    - Estado (Activo, Vencido, Suspendido)                                │
    - Fecha de inicio                                                      │
    - Fecha de vencimiento                                                 │
    - # Usuarios activos / límite                                          │
    ↓                                                                      │
[Tap en membresía]                                                        │
    ↓                                                                      │
[MembershipDetailView]                                                    │
    - Cambiar plan                                                         │
    - Renovar                                                              │
    - Suspender                                                            │
    - Historial de pagos                                                   │
    - Facturas                                                             │
                                                                           │
    ┌──────────────────────────────────────────────────────────────────────┘
    ↓
[ReportsView]
    ↓
[Dashboards y Métricas]
    - Usuarios totales
    - Usuarios activos (últimos 30 días)
    - Escuelas activas
    - Cursos activos
    - Materiales subidos (últimos 30 días)
    - Engagement rate
    - Revenue (MRR, ARR)
    ↓
[Gráficas]
    - Crecimiento de usuarios
    - Uso de la plataforma
    - Revenue trends
    - Churn rate
```

---

## Panel Administrativo

### 🏠 AdminHomeView (Dashboard)

**Ruta:** `.home`

**Contenido:**

```
AdminHomeView
├── Header
│   ├── Bienvenida: "Hola, Admin"
│   └── Fecha actual
│
├── KPIs Principales (Cards en Grid)
│   ├── Total Escuelas
│   │   ├── Número: 45
│   │   └── Cambio: +3 este mes
│   │
│   ├── Total Usuarios
│   │   ├── Número: 12,345
│   │   └── Cambio: +234 este mes
│   │
│   ├── Usuarios Activos (30 días)
│   │   ├── Número: 8,901
│   │   └── % del total: 72%
│   │
│   ├── Cursos Activos
│   │   ├── Número: 567
│   │   └── Cambio: +12 este mes
│   │
│   ├── Materiales Subidos (30 días)
│   │   ├── Número: 1,234
│   │   └── Promedio por día: 41
│   │
│   └── Revenue (MRR)
│       ├── Monto: $45,678
│       └── Cambio: +5.2%
│
├── Gráficas
│   ├── Usuarios Activos (últimos 30 días)
│   │   └── Line chart
│   │
│   └── Revenue (últimos 12 meses)
│       └── Bar chart
│
├── Actividad Reciente
│   └── Timeline de eventos importantes:
│       - Nueva escuela registrada: "Universidad X"
│       - Nuevo admin agregado: "Juan Pérez"
│       - Membresía renovada: "Colegio Y"
│       - 50 nuevos usuarios registrados hoy
│
├── Alertas y Notificaciones
│   ├── 🔴 3 membresías vencen en 7 días
│   ├── 🟡 5 escuelas cerca del límite de usuarios
│   └── 🟢 Sistema funcionando correctamente
│
└── Acciones Rápidas
    ├── Botón "Crear Escuela"
    ├── Botón "Agregar Usuario"
    ├── Botón "Ver Reportes"
    └── Botón "Configuración"
```

---

## Gestión de Escuelas

### 🏫 SchoolsListView

**Ruta:** `.schools` (tab exclusivo admin)

**Layout:**

```
SchoolsListView
├── Header
│   ├── Título: "Escuelas"
│   └── Botón "Crear Escuela" (primary action)
│
├── Filtros
│   └── Chips:
│       - [Todas] [Activas] [Inactivas] [Free] [Premium]
│
├── Búsqueda
│   └── Search bar con filtro por nombre
│
└── Grid de Escuelas (iPad/Mac) o Lista (iPhone)
    └── SchoolCard
        ├── Logo (imagen o iniciales)
        ├── Nombre
        ├── Plan (badge: Free, Basic, Premium, Enterprise)
        ├── Estado (badge: Activo, Inactivo, Suspendido)
        ├── # Usuarios activos
        ├── Fecha de creación
        └── Menú contextual
            ├── Ver detalles
            ├── Editar
            ├── Gestionar membresía
            ├── Ver usuarios
            └── Desactivar/Activar
```

### 📋 SchoolDetailView

**Navegación:** SchoolsListView → Tap en escuela

**Layout:**

```
SchoolDetailView
├── Header
│   ├── Logo grande
│   ├── Nombre de la escuela
│   ├── Plan (badge)
│   ├── Estado (badge)
│   └── Botón "Editar"
│
├── Tabs
│   ├── Overview
│   │   ├── Información General
│   │   │   ├── Nombre oficial
│   │   │   ├── Dirección
│   │   │   ├── Teléfono
│   │   │   ├── Email de contacto
│   │   │   └── Sitio web
│   │   │
│   │   ├── Estadísticas
│   │   │   ├── Total usuarios: 234
│   │   │   │   ├── Estudiantes: 200
│   │   │   │   ├── Docentes: 30
│   │   │   │   └── Admins: 4
│   │   │   ├── Cursos activos: 45
│   │   │   ├── Materiales subidos: 567
│   │   │   └── Usuarios activos (30 días): 89%
│   │   │
│   │   └── Gráfica de Actividad
│   │       └── Line chart de usuarios activos últimos 30 días
│   │
│   ├── Users
│   │   ├── Filtros por rol
│   │   ├── Search bar
│   │   └── Lista de usuarios
│   │       └── UserCard (mini)
│   │           ├── Avatar
│   │           ├── Nombre
│   │           ├── Email
│   │           ├── Rol (badge)
│   │           └── Tap → UserDetailView
│   │
│   ├── Academic Tree
│   │   └── Árbol académico de la escuela
│   │       └── Ver sección "Árbol de Unidades Académicas"
│   │
│   ├── Membership
│   │   ├── Plan actual (card)
│   │   │   ├── Nombre del plan
│   │   │   ├── Precio
│   │   │   ├── Fecha de inicio
│   │   │   ├── Fecha de vencimiento
│   │   │   └── Días restantes
│   │   │
│   │   ├── Límites
│   │   │   ├── Usuarios: 200/250 (80%)
│   │   │   ├── Cursos: 45/∞
│   │   │   └── Storage: 12 GB / 50 GB (24%)
│   │   │
│   │   ├── Historial de Pagos
│   │   │   └── Lista de facturas
│   │   │       ├── Fecha
│   │   │       ├── Monto
│   │   │       ├── Estado (Pagado, Pendiente)
│   │   │       └── Descargar PDF
│   │   │
│   │   └── Acciones
│   │       ├── Cambiar Plan
│   │       ├── Renovar
│   │       └── Suspender
│   │
│   └── Settings
│       ├── Configuración de Escuela
│       │   ├── Logo
│       │   ├── Colores de marca
│       │   ├── Tema por defecto
│       │   └── Configuración de emails
│       │
│       ├── Permisos
│       │   ├── Permitir auto-registro de estudiantes
│       │   ├── Requerir aprobación para nuevos usuarios
│       │   └── Permitir a docentes crear cursos
│       │
│       └── Zona de Peligro
│           ├── Suspender escuela
│           └── Eliminar escuela (si no tiene dependencias)
```

### ➕ CreateSchoolView

**Navegación:** SchoolsListView → "Crear Escuela"

**Layout:**

```
CreateSchoolView (Sheet o Navegación)
├── Formulario (Wizard multi-paso)
│   │
│   ├── Paso 1: Información Básica
│   │   ├── Nombre oficial (TextField)
│   │   ├── Nombre corto (TextField)
│   │   ├── Logo (Image Picker)
│   │   ├── Dirección (TextField)
│   │   ├── Teléfono (TextField)
│   │   ├── Email de contacto (TextField)
│   │   └── Sitio web (TextField)
│   │
│   ├── Paso 2: Administrador Inicial
│   │   ├── Nombre del admin (TextField)
│   │   ├── Email del admin (TextField)
│   │   ├── Contraseña temporal (TextField)
│   │   └── Enviar email de bienvenida (Toggle)
│   │
│   ├── Paso 3: Membresía
│   │   ├── Plan (Picker: Free, Basic, Premium, Enterprise)
│   │   ├── Fecha de inicio (DatePicker)
│   │   ├── Duración (Picker: Mensual, Anual)
│   │   └── Límite de usuarios (TextField, según plan)
│   │
│   └── Paso 4: Confirmación
│       ├── Resumen de la información
│       └── Botones:
│           ├── Volver
│           ├── Cancelar
│           └── Crear Escuela
│
└── Proceso de Creación
    ├── 1. Crear escuela en BD
    ├── 2. Crear admin inicial
    ├── 3. Crear membresía
    ├── 4. Enviar email de bienvenida
    └── 5. Redireccionar a SchoolDetailView
```

---

## Gestión de Usuarios

### 👥 UsersListView

**Ruta:** `.users` (tab exclusivo admin)

**Layout:**

```
UsersListView
├── Header
│   ├── Título: "Usuarios"
│   └── Botón "Agregar Usuario" (primary action)
│
├── Filtros
│   ├── Por Rol
│   │   └── Chips: [Todos] [Estudiantes] [Docentes] [Admins] [Padres]
│   ├── Por Escuela
│   │   └── Dropdown con lista de escuelas
│   ├── Por Estado
│   │   └── Chips: [Todos] [Activos] [Inactivos]
│   └── Por Fecha de Registro
│       └── DatePicker: Desde - Hasta
│
├── Búsqueda
│   └── Search bar (busca por nombre, email)
│
├── Estadísticas Rápidas (Cards)
│   ├── Total: 12,345
│   ├── Activos: 8,901 (72%)
│   ├── Nuevos (7 días): 234
│   └── Inactivos: 3,444
│
└── Lista de Usuarios (Table en iPad/Mac)
    └── UserRow
        ├── Avatar
        ├── Nombre
        ├── Email
        ├── Rol (badge)
        ├── Escuela
        ├── Estado (badge)
        ├── Fecha de registro
        ├── Última actividad
        └── Menú contextual
            ├── Ver detalles
            ├── Editar
            ├── Cambiar rol
            ├── Resetear contraseña
            ├── Desactivar/Activar
            └── Eliminar
```

**Paginación:**
- 50 usuarios por página
- Infinite scroll o botón "Cargar más"

### 📋 UserDetailView

**Navegación:** UsersListView → Tap en usuario

**Layout:**

```
UserDetailView
├── Header
│   ├── Avatar grande
│   ├── Nombre completo
│   ├── Email
│   ├── Rol (badge, editable)
│   ├── Escuela (badge, editable)
│   ├── Estado (badge)
│   └── Botón "Editar"
│
├── Tabs
│   ├── Overview
│   │   ├── Información Personal
│   │   │   ├── Nombre
│   │   │   ├── Email
│   │   │   ├── Teléfono
│   │   │   ├── Fecha de nacimiento
│   │   │   └── Dirección
│   │   │
│   │   ├── Información Académica
│   │   │   ├── Rol
│   │   │   ├── Escuela
│   │   │   ├── Unidad académica
│   │   │   └── Fecha de registro
│   │   │
│   │   └── Actividad
│   │       ├── Última sesión
│   │       ├── Días de actividad (últimos 30)
│   │       └── Total de sesiones
│   │
│   ├── Courses
│   │   └── Si es Estudiante:
│   │       └── Cursos inscritos
│   │   └── Si es Docente:
│   │       └── Cursos que imparte
│   │   └── Para cada curso:
│   │       ├── Nombre
│   │       ├── Progreso (si es estudiante)
│   │       ├── # Estudiantes (si es docente)
│   │       └── Tap → CourseDetailView
│   │
│   ├── Activity Log
│   │   └── Timeline de actividad del usuario:
│   │       ├── Login
│   │       ├── Material leído
│   │       ├── Quiz realizado
│   │       ├── Comentario en foro
│   │       ├── Material subido (si es docente)
│   │       └── etc.
│   │
│   └── Settings
│       ├── Cambiar Información
│       │   └── Formulario de edición
│       │
│       ├── Cambiar Rol
│       │   └── Picker: Student, Teacher, Admin, Parent
│       │   └── ⚠️ Confirmación con advertencia
│       │
│       ├── Cambiar Escuela
│       │   └── Picker de escuelas
│       │
│       ├── Resetear Contraseña
│       │   └── Envía email con link de reset
│       │
│       ├── Estado
│       │   └── Toggle: Activo / Inactivo
│       │
│       └── Zona de Peligro
│           └── Eliminar Usuario
│               └── ⚠️ Confirmación + validación
│               └── No permite eliminar si tiene dependencias activas
```

### ➕ CreateUserView

**Navegación:** UsersListView → "Agregar Usuario"

**Layout:**

```
CreateUserView (Sheet)
├── Formulario
│   ├── Información Personal
│   │   ├── Nombre (TextField)
│   │   ├── Email (TextField)
│   │   ├── Teléfono (TextField, opcional)
│   │   └── Fecha de nacimiento (DatePicker, opcional)
│   │
│   ├── Información Académica
│   │   ├── Rol (Picker: Student, Teacher, Admin, Parent)
│   │   ├── Escuela (Picker de escuelas)
│   │   └── Unidad académica (Picker, depende de escuela)
│   │
│   ├── Credenciales
│   │   ├── Email (auto-llenado de arriba)
│   │   ├── Contraseña temporal (generada o manual)
│   │   └── Requiere cambio de contraseña (Toggle, default: true)
│   │
│   └── Notificación
│       └── Enviar email de bienvenida (Toggle, default: true)
│
└── Botones
    ├── Cancelar
    └── Crear Usuario
        ↓
  [Validaciones]
        ↓
  [Crear en BD]
        ↓
  [Enviar email]
        ↓
  [Success → Volver a lista]
```

---

## Árbol de Unidades Académicas

### 🌳 AcademicTreeView

**Ruta:** `.academicTree` (tab exclusivo admin)

**Concepto:** Jerarquía de unidades académicas por escuela.

**Estructura Jerárquica:**

```
Escuela (nivel 0)
└── Facultad / División (nivel 1)
    └── Departamento (nivel 2)
        └── Programa / Carrera (nivel 3)
            └── Curso (nivel 4, opcional)
```

**Ejemplo Real:**

```
Universidad Nacional
├── Facultad de Ingeniería
│   ├── Departamento de Sistemas
│   │   ├── Ingeniería de Sistemas
│   │   │   ├── Fundamentos de Programación
│   │   │   ├── Estructuras de Datos
│   │   │   └── Algoritmos
│   │   └── Ingeniería de Software
│   │       ├── Desarrollo Web
│   │       └── Bases de Datos
│   └── Departamento de Electrónica
│       └── Ingeniería Electrónica
│           ├── Circuitos
│           └── Sistemas Digitales
│
└── Facultad de Ciencias
    └── Departamento de Matemáticas
        └── Licenciatura en Matemáticas
            ├── Cálculo I
            ├── Álgebra Lineal
            └── Matemáticas Discretas
```

**Layout:**

```
AcademicTreeView
├── Header
│   ├── Selector de Escuela (Picker)
│   └── Botón "Agregar Nodo"
│
├── Árbol Interactivo (Outline o Tree View)
│   └── Cada Nodo muestra:
│       ├── Icono según nivel
│       ├── Nombre
│       ├── Tipo (badge: Facultad, Departamento, Programa)
│       ├── # Hijos (si tiene)
│       └── Menú contextual
│           ├── Ver detalles
│           ├── Agregar hijo
│           ├── Editar
│           ├── Mover
│           └── Eliminar (si no tiene dependencias)
│
└── Panel de Detalles (en Split View iPad/Mac)
    └── Al seleccionar un nodo:
        ├── Nombre
        ├── Tipo
        ├── Descripción
        ├── Nivel en jerarquía
        ├── Padre
        ├── # Hijos directos
        ├── # Usuarios asignados
        └── Botón "Editar"
```

**Interacción:**

```
- Tap en nodo → Expand/Collapse hijos
- Tap en "+" del nodo → Agregar hijo
- Long press / Right click → Menú contextual
- Drag & Drop (iPad/Mac) → Mover nodo a otro padre
```

### ➕ CreateAcademicUnitView

**Navegación:** AcademicTreeView → "Agregar Nodo" o menú contextual → "Agregar hijo"

**Layout:**

```
CreateAcademicUnitView (Sheet)
├── Formulario
│   ├── Nombre (TextField)
│   ├── Tipo (Picker: Facultad, Departamento, Programa, Curso)
│   │   └── Auto-sugerido según nivel del padre
│   ├── Descripción (TextEditor, opcional)
│   ├── Código (TextField, opcional)
│   │   └── Ej: "FAC-ING", "DEPT-SIS", "PROG-INGSYS"
│   └── Padre (Picker, pre-seleccionado si viene de menú contextual)
│
└── Botones
    ├── Cancelar
    └── Crear Unidad
        ↓
  [Validaciones]
        ↓
  [Crear en BD]
        ↓
  [Actualizar árbol]
```

---

## Gestión de Membresías

### 💳 MembershipsView

**Ruta:** `.memberships` (tab exclusivo admin)

**Layout:**

```
MembershipsView
├── Header
│   ├── Título: "Membresías"
│   └── Botón "Crear Membresía" (si hay escuelas sin membresía)
│
├── Filtros
│   └── Chips: [Todas] [Activas] [Vencidas] [Suspendidas]
│
├── Resumen (Cards)
│   ├── Revenue Mensual (MRR)
│   ├── Revenue Anual (ARR)
│   ├── Membresías Activas
│   └── Próximas a Vencer (7 días)
│
└── Lista de Membresías (Table)
    └── MembershipRow
        ├── Logo de escuela
        ├── Nombre de escuela
        ├── Plan (badge)
        ├── Estado (badge)
        ├── Fecha de inicio
        ├── Fecha de vencimiento
        ├── # Usuarios (actual / límite)
        ├── Revenue mensual
        └── Menú contextual
            ├── Ver detalles
            ├── Cambiar plan
            ├── Renovar
            ├── Suspender
            └── Ver facturas
```

### 📋 MembershipDetailView

**Navegación:** MembershipsView → Tap en membresía

**Layout:**

```
MembershipDetailView
├── Header
│   ├── Logo de escuela
│   ├── Nombre de escuela
│   ├── Plan (badge)
│   ├── Estado (badge)
│   └── Botón "Editar Plan"
│
├── Tabs
│   ├── Overview
│   │   ├── Información del Plan
│   │   │   ├── Nombre del plan
│   │   │   ├── Precio mensual
│   │   │   ├── Precio anual (si aplica)
│   │   │   ├── Fecha de inicio
│   │   │   ├── Fecha de vencimiento
│   │   │   └── Días restantes (si activo)
│   │   │
│   │   ├── Límites y Uso
│   │   │   ├── Usuarios
│   │   │   │   ├── Actual: 234
│   │   │   │   ├── Límite: 250
│   │   │   │   └── Progress bar (93%)
│   │   │   ├── Cursos
│   │   │   │   ├── Actual: 45
│   │   │   │   └── Límite: ∞ (ilimitado)
│   │   │   └── Storage
│   │   │       ├── Actual: 12 GB
│   │   │       ├── Límite: 50 GB
│   │   │       └── Progress bar (24%)
│   │   │
│   │   └── Features Incluidos
│   │       └── Lista de features del plan:
│   │           ✅ Usuarios ilimitados
│   │           ✅ 50 GB de storage
│   │           ✅ Soporte prioritario
│   │           ✅ Reportes avanzados
│   │           ❌ API access
│   │
│   ├── Billing
│   │   ├── Método de Pago
│   │   │   ├── Tipo (Tarjeta, Transferencia, etc.)
│   │   │   ├── Últimos 4 dígitos (si es tarjeta)
│   │   │   └── Botón "Cambiar método"
│   │   │
│   │   ├── Próximo Pago
│   │   │   ├── Fecha
│   │   │   ├── Monto
│   │   │   └── Auto-renovación (Toggle)
│   │   │
│   │   └── Historial de Pagos
│   │       └── Lista de facturas:
│   │           ├── Fecha
│   │           ├── Monto
│   │           ├── Estado (badge: Pagado, Pendiente, Fallido)
│   │           ├── Método
│   │           └── Botón "Descargar PDF"
│   │
│   └── Actions
│       ├── Cambiar Plan
│       │   └── Modal con picker de planes
│       │   └── Muestra diferencia de precio
│       │   └── Confirmación
│       │
│       ├── Renovar Ahora
│       │   └── Extiende la fecha de vencimiento
│       │
│       ├── Suspender
│       │   └── ⚠️ Confirmación
│       │   └── Bloquea acceso de usuarios de la escuela
│       │
│       └── Cancelar Membresía
│           └── ⚠️ Confirmación
│           └── Programa cancelación al fin del periodo
```

### 📊 Plans (Planes Disponibles)

**Configuración de Planes:**

```swift
enum MembershipPlan {
    case free
    case basic
    case premium
    case enterprise
    
    var price: Decimal {
        switch self {
        case .free: return 0
        case .basic: return 29.99
        case .premium: return 99.99
        case .enterprise: return 299.99
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "Hasta 50 usuarios",
                "5 GB storage",
                "Soporte por email"
            ]
        case .basic:
            return [
                "Hasta 250 usuarios",
                "25 GB storage",
                "Soporte por email",
                "Reportes básicos"
            ]
        case .premium:
            return [
                "Hasta 1000 usuarios",
                "100 GB storage",
                "Soporte prioritario",
                "Reportes avanzados",
                "API access básico"
            ]
        case .enterprise:
            return [
                "Usuarios ilimitados",
                "Storage ilimitado",
                "Soporte 24/7",
                "Reportes personalizados",
                "API access completo",
                "SSO (Single Sign-On)",
                "Auditoría y compliance"
            ]
        }
    }
}
```

---

## Flujos Específicos

### 🏫 Flujo Completo de Creación de Escuela

```
[Inicio]
  ↓
[AdminHomeView] → Tap "Crear Escuela"
  ↓
[CreateSchoolView]
  ↓
[Paso 1: Información Básica]
  - Nombre: "Universidad del Norte"
  - Logo: (sube imagen)
  - Dirección: "Calle 123, Ciudad"
  - Email: "contacto@uninorte.edu"
  ↓ (Next)
[Paso 2: Admin Inicial]
  - Nombre: "Carlos Martínez"
  - Email: "carlos@uninorte.edu"
  - Contraseña: (generada automáticamente)
  - Enviar email: ✅
  ↓ (Next)
[Paso 3: Membresía]
  - Plan: Premium
  - Fecha inicio: Hoy
  - Duración: Anual
  - Límite usuarios: 1000
  ↓ (Next)
[Paso 4: Confirmación]
  - Muestra resumen
  ↓ (Crear Escuela)
[CreateSchoolUseCase]
  ↓
[1. Crea escuela en PostgreSQL]
  ↓
[2. Crea admin inicial]
  ↓
[3. Crea membresía]
  ↓
[4. Genera contraseña temporal]
  ↓
[5. Envía email de bienvenida a Carlos]
  ↓
[Success toast: "Escuela creada exitosamente"]
  ↓
[Navega a SchoolDetailView]
  ↓
[Carlos recibe email]
  ↓
[Carlos hace login]
  ↓
[Sistema solicita cambio de contraseña]
  ↓
[Carlos accede al panel de su escuela]
```

---

### 👤 Flujo de Cambio de Rol de Usuario

```
[Inicio]
  ↓
[UsersListView] → Buscar "María González"
  ↓
[Tap en María]
  ↓
[UserDetailView]
  - Rol actual: Student
  ↓
[Tab "Settings" → "Cambiar Rol"]
  ↓
[Picker de Roles]
  - Student (actual)
  - Teacher ← Seleccionar
  - Admin
  - Parent
  ↓
[Alert de Confirmación]
  ⚠️ "¿Estás seguro de cambiar el rol de María de 'Student' a 'Teacher'?
      Esta acción le otorgará permisos adicionales."
  [Cancelar] [Confirmar]
  ↓ (Confirmar)
[UpdateUserRoleUseCase]
  ↓
[1. Actualiza rol en PostgreSQL]
  ↓
[2. Invalida tokens activos]
  ↓
[3. Envía notificación a María]
  ↓
[Success toast: "Rol actualizado"]
  ↓
[UserDetailView se actualiza]
  - Rol actual: Teacher (badge)
  ↓
[María recibe notificación push]
  "Tu rol ha sido actualizado a Teacher. Por favor, vuelve a iniciar sesión."
  ↓
[María cierra sesión automáticamente]
  ↓
[María inicia sesión de nuevo]
  ↓
[App muestra interfaz de Teacher]
  - Tabs adicionales: Students, ContentManage
```

---

### 🌳 Flujo de Creación de Árbol Académico

```
[Inicio]
  ↓
[AcademicTreeView]
  - Seleccionar escuela: "Universidad del Norte"
  - Árbol vacío (escuela recién creada)
  ↓
[Tap "Agregar Nodo" en raíz]
  ↓
[CreateAcademicUnitView]
  - Nombre: "Facultad de Ingeniería"
  - Tipo: Facultad (auto-sugerido nivel 1)
  - Código: "FAC-ING"
  ↓ (Crear)
[Árbol actualizado]
  Universidad del Norte
  └── Facultad de Ingeniería
  ↓
[Tap en "Facultad de Ingeniería" → Menú → "Agregar hijo"]
  ↓
[CreateAcademicUnitView]
  - Nombre: "Departamento de Sistemas"
  - Tipo: Departamento (auto-sugerido nivel 2)
  - Código: "DEPT-SIS"
  - Padre: Facultad de Ingeniería (pre-seleccionado)
  ↓ (Crear)
[Árbol actualizado]
  Universidad del Norte
  └── Facultad de Ingeniería
      └── Departamento de Sistemas
  ↓
[Tap en "Departamento de Sistemas" → Menú → "Agregar hijo"]
  ↓
[CreateAcademicUnitView]
  - Nombre: "Ingeniería de Sistemas"
  - Tipo: Programa (auto-sugerido nivel 3)
  - Código: "PROG-INGSYS"
  - Padre: Departamento de Sistemas
  ↓ (Crear)
[Árbol completo]
  Universidad del Norte
  └── Facultad de Ingeniería
      └── Departamento de Sistemas
          └── Ingeniería de Sistemas
  ↓
[Repetir para otras unidades...]
```

---

### 💳 Flujo de Cambio de Plan de Membresía

```
[Inicio]
  ↓
[MembershipsView] → Lista de membresías
  ↓
[Tap en "Universidad del Norte"]
  ↓
[MembershipDetailView]
  - Plan actual: Basic ($29.99/mes)
  - Usuarios: 234/250 (93%) ⚠️ Cerca del límite
  ↓
[Tab "Actions" → "Cambiar Plan"]
  ↓
[ChangePlanView (Modal)]
  ├── Plan actual: Basic
  │   - 250 usuarios
  │   - 25 GB storage
  │   - $29.99/mes
  │
  └── Planes disponibles:
      ├── Free ($0) - Downgrade ⚠️
      ├── Basic ($29.99) - Actual
      ├── Premium ($99.99) - Upgrade ✨ ← Seleccionar
      └── Enterprise ($299.99) - Upgrade
  ↓ (Seleccionar Premium)
[Muestra comparación]
  Cambio de Basic → Premium
  ├── Usuarios: 250 → 1000
  ├── Storage: 25 GB → 100 GB
  ├── Nuevas features:
  │   ✅ Soporte prioritario
  │   ✅ Reportes avanzados
  │   ✅ API access básico
  └── Precio: $29.99 → $99.99 (+$70/mes)
  
  Próximo cobro: Hoy (pro-rated)
  Monto a cobrar hoy: $56.67 (pro-rata del mes actual)
  ↓
[Botones]
  [Cancelar] [Confirmar Upgrade]
  ↓ (Confirmar)
[UpdateMembershipUseCase]
  ↓
[1. Actualiza plan en BD]
  ↓
[2. Calcula pro-rata]
  ↓
[3. Genera factura]
  ↓
[4. Procesa pago]
  ↓
[5. Envía confirmación por email]
  ↓
[Success toast: "Plan actualizado a Premium"]
  ↓
[MembershipDetailView se actualiza]
  - Plan: Premium
  - Usuarios: 234/1000 (23%)
  ↓
[Admin de escuela recibe email]
  "Tu plan ha sido actualizado a Premium. Los nuevos límites ya están activos."
```

---

## Deep Links

### Deep Links Exclusivos del Admin

```
edugo://
├── admin/
│   ├── dashboard
│   ├── schools
│   │   ├── create
│   │   └── {schoolId}
│   │       ├── users
│   │       ├── tree
│   │       ├── membership
│   │       └── settings
│   ├── users
│   │   ├── create
│   │   └── {userId}
│   │       ├── edit
│   │       └── activity
│   ├── academic-tree
│   │   └── {schoolId}
│   │       └── {unitId}
│   ├── memberships
│   │   └── {schoolId}
│   │       ├── change-plan
│   │       └── billing
│   └── reports
│       ├── users
│       ├── revenue
│       └── engagement
```

### Ejemplos

```swift
// Dashboard admin
edugo://admin/dashboard

// Crear escuela
edugo://admin/schools/create

// Ver escuela específica
edugo://admin/schools/550e8400-e29b-41d4-a716-446655440000

// Ver usuarios de una escuela
edugo://admin/schools/550e8400-e29b-41d4-a716-446655440000/users

// Ver árbol académico de escuela
edugo://admin/academic-tree/550e8400-e29b-41d4-a716-446655440000

// Editar usuario específico
edugo://admin/users/123e4567-e89b-12d3-a456-426614174000/edit

// Cambiar plan de membresía
edugo://admin/memberships/550e8400-e29b-41d4-a716-446655440000/change-plan

// Ver reportes de revenue
edugo://admin/reports/revenue
```

---

## Permisos y Seguridad

### Validación de Permisos

```swift
// Solo admins pueden acceder al panel admin
var canAccessAdminPanel: Bool {
    authState.currentUser?.role == .admin
}

// Validación en cada vista admin
struct SchoolsListView: View {
    @Environment(AuthenticationState.self) private var authState
    
    var body: some View {
        if authState.currentUser?.role == .admin {
            // Contenido de la vista
        } else {
            // Mensaje de "No autorizado"
            UnauthorizedView()
        }
    }
}
```

### Auditoría de Acciones

**Todas las acciones del admin se registran:**

```swift
enum AdminAction {
    case createSchool(schoolId: UUID)
    case updateSchool(schoolId: UUID)
    case deleteSchool(schoolId: UUID)
    case createUser(userId: UUID)
    case updateUser(userId: UUID, changes: [String: Any])
    case deleteUser(userId: UUID)
    case changeUserRole(userId: UUID, from: UserRole, to: UserRole)
    case createMembership(schoolId: UUID)
    case changePlan(schoolId: UUID, from: Plan, to: Plan)
    case suspendMembership(schoolId: UUID)
    // ... más acciones
}

// Se guarda en tabla de auditoría
struct AuditLog {
    let id: UUID
    let adminId: UUID
    let action: AdminAction
    let timestamp: Date
    let ipAddress: String
    let userAgent: String
}
```

---

## Consideraciones de UX

### 1. Confirmaciones para Acciones Destructivas

**Siempre confirmar:**
- Eliminar escuela
- Eliminar usuario
- Cambiar rol de usuario
- Suspender membresía
- Eliminar unidad académica con dependencias

**Alert de Confirmación:**
```swift
.alert("¿Estás seguro?", isPresented: $showingDeleteConfirmation) {
    Button("Cancelar", role: .cancel) { }
    Button("Eliminar", role: .destructive) {
        performDelete()
    }
} message: {
    Text("Esta acción no se puede deshacer. Se eliminarán todos los datos asociados.")
}
```

### 2. Feedback Visual

- **Acciones exitosas:** Toast verde con mensaje
- **Acciones fallidas:** Toast rojo con error
- **Acciones en progreso:** Spinner + mensaje descriptivo
- **Alertas importantes:** Badge rojo en tab o card

### 3. Búsqueda y Filtros

- **Búsqueda en tiempo real:** Debounce de 300ms
- **Filtros persistentes:** Guardar en UserDefaults
- **Resultados paginados:** Infinite scroll o load more

### 4. Exportación de Datos

- **Exportar a CSV:** Lista de usuarios, escuelas, facturación
- **Exportar a PDF:** Facturas, reportes
- **Compartir:** Share sheet nativo

---

## Próximos Pasos

1. **Dashboard de Reportes:** Métricas avanzadas con gráficas interactivas
2. **Notificaciones Admin:** Alertas de eventos importantes (membresías vencidas, límites alcanzados)
3. **Logs de Auditoría:** Vista de todas las acciones de admins
4. **Gestión de Permisos Granulares:** Roles personalizados con permisos específicos
5. **Importación Masiva:** Importar usuarios desde CSV/Excel
6. **Integración de Pagos:** Stripe, PayPal para gestión automática de suscripciones
7. **Soporte Multiidioma:** Gestión de traducciones en el sistema

---

**Documentos Relacionados:**
- [FLUJO-ESTUDIANTE.md](./FLUJO-ESTUDIANTE.md)
- [FLUJO-DOCENTE.md](./FLUJO-DOCENTE.md)
- [NAVEGACION-PLATAFORMA.md](./NAVEGACION-PLATAFORMA.md)
