# Arquitectura: Dataset Simple para Frontend

**Objetivo:** Proveer datos mock para desarrollo frontend SIN simular base de datos completa

---

## Principios de Diseño

### 1. Solo Lectura (Read-Only)
```go
// ✅ SÍ - Métodos de lectura
dataset.DB.Users.FindByID(id)
dataset.DB.Users.FindByEmail(email)
dataset.DB.Users.List()

// ❌ NO - Escritura retorna error
dataset.DB.Users.Insert(user)  // → error: "use real API for writes"
dataset.DB.Users.Update(user)  // → error: "use real API for writes"
dataset.DB.Users.Delete(id)    // → error: "use real API for writes"
```

**Razón:** Frontend solo necesita datos para renderizar UI, no para testing de lógica de escritura.

---

### 2. Solo Índice Principal (Primary Key)
```go
type UserTable struct {
    data map[uuid.UUID]*entities.User  // ← SOLO PK
    mu   sync.RWMutex
    // ❌ NO índices secundarios (byEmail, byRole, etc.)
}
```

**Razón:** Simplicidad. Búsquedas secundarias se hacen con scan O(n), pero son pocos registros mock.

---

### 3. Métodos Funcionales Simples
```go
// Búsqueda por PK - O(1)
func (t *UserTable) FindByID(id uuid.UUID) *entities.User

// Búsqueda por campo - O(n) pero simple
func (t *UserTable) FindByEmail(email string) *entities.User {
    for _, u := range t.data {
        if u.Email == email {
            return u
        }
    }
    return nil
}

// Listar todos
func (t *UserTable) List() []*entities.User
```

**Razón:** Código fácil de generar, fácil de entender.

---

### 4. Sin Validaciones Complejas
```go
// ❌ NO validar constraints
// ❌ NO validar foreign keys
// ❌ NO validar UNIQUE
// ❌ NO simular transacciones

// ✅ SÍ - Solo retornar nil si no existe
func (t *UserTable) FindByID(id uuid.UUID) *entities.User {
    if user, ok := t.data[id]; ok {
        return user
    }
    return nil  // ← Simple: no existe
}
```

**Razón:** Validaciones son responsabilidad de la API real.

---

## Estructura de Archivos Generados

```
mock/dataset/
├── database.go           # Singleton global (AUTO-GENERADO)
├── users_table.go        # Tabla users (AUTO-GENERADO)
├── schools_table.go      # Tabla schools (AUTO-GENERADO)
├── memberships_table.go  # Tabla memberships (AUTO-GENERADO)
└── load_data.go          # Carga de datos (AUTO-GENERADO)
```

---

## Código Generado - Ejemplo User

### database.go

```go
package dataset

import "sync"

type MockDatabase struct {
    Users       *UserTable
    Schools     *SchoolTable
    Memberships *MembershipTable
    
    mu sync.RWMutex
}

var DB *MockDatabase

func init() {
    DB = &MockDatabase{
        Users:       NewUserTable(),
        Schools:     NewSchoolTable(),
        Memberships: NewMembershipTable(),
    }
    LoadAllData()
}
```

### users_table.go

```go
package dataset

import (
    "sync"
    "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
    "github.com/google/uuid"
)

type UserTable struct {
    data map[uuid.UUID]*entities.User
    mu   sync.RWMutex
}

func NewUserTable() *UserTable {
    return &UserTable{
        data: make(map[uuid.UUID]*entities.User),
    }
}

// FindByID busca por ID (O(1))
func (t *UserTable) FindByID(id uuid.UUID) *entities.User {
    t.mu.RLock()
    defer t.mu.RUnlock()
    
    if user, ok := t.data[id]; ok {
        return user
    }
    return nil
}

// FindByEmail busca por email (O(n) - acceptable para mocks)
func (t *UserTable) FindByEmail(email string) *entities.User {
    t.mu.RLock()
    defer t.mu.RUnlock()
    
    for _, user := range t.data {
        if user.Email == email {
            return user
        }
    }
    return nil
}

// List retorna todos los usuarios
func (t *UserTable) List() []*entities.User {
    t.mu.RLock()
    defer t.mu.RUnlock()
    
    users := make([]*entities.User, 0, len(t.data))
    for _, user := range t.data {
        users = append(users, user)
    }
    return users
}

// Insert no implementado (usar API real)
func (t *UserTable) Insert(user *entities.User) error {
    return errors.New("INSERT not supported in mock mode - use real API")
}

// Update no implementado (usar API real)
func (t *UserTable) Update(user *entities.User) error {
    return errors.New("UPDATE not supported in mock mode - use real API")
}

// Delete no implementado (usar API real)
func (t *UserTable) Delete(id uuid.UUID) error {
    return errors.New("DELETE not supported in mock mode - use real API")
}
```

### load_data.go

```go
package dataset

import (
    "time"
    "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
    "github.com/google/uuid"
)

func LoadAllData() {
    loadUsers()
    loadSchools()
    loadMemberships()
}

func loadUsers() {
    now := time.Now()
    
    // Datos desde postgres/migrations/testing/001_demo_users.sql
    users := []*entities.User{
        {
            ID:           uuid.MustParse("a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"),
            Email:        "admin@edugo.test",
            PasswordHash: "$2a$10$x0lpvYBLh8dCiMYskYzD1.y2TfeXcQh7QbBXIO5Xepi3SIgC2FtY6",
            FirstName:    "Admin",
            LastName:     "Demo",
            Role:         "admin",
            IsActive:     true,
            CreatedAt:    now,
            UpdatedAt:    now,
        },
        // ... más usuarios
    }
    
    for _, user := range users {
        DB.Users.data[user.ID] = user
    }
}
```

---

## Repository Mock Simplificado

```go
// user_repository_mock.go - MANUAL (simple)

package repository

import (
    "context"
    "github.com/EduGoGroup/edugo-api-administracion/internal/domain/repository"
    "github.com/EduGoGroup/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset"
    "github.com/EduGoGroup/edugo-infrastructure/postgres/entities"
    "github.com/google/uuid"
)

type mockUserRepository struct{}

func NewMockUserRepository() repository.UserRepository {
    return &mockUserRepository{}
}

func (r *mockUserRepository) FindByID(ctx context.Context, id uuid.UUID) (*entities.User, error) {
    if user := dataset.DB.Users.FindByID(id); user != nil {
        return user, nil
    }
    return nil, errors.NewNotFoundError("user not found")
}

func (r *mockUserRepository) FindByEmail(ctx context.Context, email string) (*entities.User, error) {
    if user := dataset.DB.Users.FindByEmail(email); user != nil {
        return user, nil
    }
    return nil, errors.NewNotFoundError("user not found")
}

func (r *mockUserRepository) List(ctx context.Context) ([]*entities.User, error) {
    return dataset.DB.Users.List(), nil
}

// Escrituras - No soportadas en modo mock
func (r *mockUserRepository) Create(ctx context.Context, user *entities.User) error {
    return errors.NewNotImplementedError("CREATE not supported in mock mode - use real API")
}

func (r *mockUserRepository) Update(ctx context.Context, user *entities.User) error {
    return errors.NewNotImplementedError("UPDATE not supported in mock mode - use real API")
}

func (r *mockUserRepository) Delete(ctx context.Context, id uuid.UUID) error {
    return errors.NewNotImplementedError("DELETE not supported in mock mode - use real API")
}
```

---

## Comparación: Antes vs Después

### Antes (Hardcoded Manual)

```
mock/data/
├── users.go          ← Hardcoded MANUAL
├── schools.go        ← Hardcoded MANUAL
└── memberships.go    ← Hardcoded MANUAL

repository/
├── user_repository_mock.go    ← Mucha lógica
├── school_repository_mock.go  ← Mucha lógica
└── membership_repository_mock.go  ← Mucha lógica
```

**Problemas:**
- ❌ Datos duplicados en cada API
- ❌ Lógica de búsqueda en cada repository
- ❌ Mantenimiento manual

---

### Después (Dataset Auto-generado)

```
mock/dataset/
├── database.go           ← AUTO-GENERADO
├── users_table.go        ← AUTO-GENERADO (métodos de búsqueda)
├── schools_table.go      ← AUTO-GENERADO
├── memberships_table.go  ← AUTO-GENERADO
└── load_data.go          ← AUTO-GENERADO (desde SQL)

repository/
├── user_repository_mock.go    ← SIMPLE (solo proxy)
├── school_repository_mock.go  ← SIMPLE (solo proxy)
└── membership_repository_mock.go  ← SIMPLE (solo proxy)
```

**Beneficios:**
- ✅ Datos en SQL (single source of truth)
- ✅ Lógica de búsqueda en dataset (reutilizable)
- ✅ Repository solo delega
- ✅ Mantenimiento automático

---

## Ventajas del Approach Simplificado

### 1. Generación Rápida
Sin índices complejos, el generator es más simple:
- Parser SQL → Extraer datos
- Generar tabla con map[PK]Entity
- Generar métodos Find + List
- Done

### 2. Menos Código
```
Approach completo (con índices):  ~500 líneas por tabla
Approach simple:                  ~150 líneas por tabla
```

### 3. Fácil Debugging
Sin complejidad de índices, es obvio qué hace cada método.

### 4. Performance Aceptable
Con ~10-20 registros mock por tabla, O(n) scan es instantáneo.

### 5. Enfoque Claro
"Dataset para proveer datos a frontend, NO para testear lógica de negocio"

---

## Limitaciones Aceptadas

1. ❌ Escrituras no soportadas → Usar API real
2. ❌ Búsquedas secundarias O(n) → Aceptable para pocos registros
3. ❌ Sin validaciones → Responsabilidad de API real
4. ❌ Sin transacciones → No necesarias para solo lectura

**Conclusión:** Estas limitaciones son ACEPTABLES porque el objetivo es solo proveer datos para diseño de UI.

---

## Próximo Paso

Ver PLAN-SPRINTS.md para la implementación detallada.
