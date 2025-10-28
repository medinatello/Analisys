# EduGo - Scripts y Modelos de Base de Datos

Este directorio contiene todos los scripts SQL, scripts MongoDB y modelos Go para el sistema EduGo, implementando tres enfoques diferentes de persistencia.

## 📁 Estructura del Proyecto

```
source/
├── scripts/                    # Scripts de base de datos
│   ├── postgresql/            # PostgreSQL (enfoque separado)
│   │   ├── 01_schema.sql     # DDL: Crear todas las tablas
│   │   ├── 02_indexes.sql    # Índices y constraints
│   │   └── 03_mock_data.sql  # Datos de prueba
│   ├── mongodb/               # MongoDB (enfoque separado)
│   │   ├── 01_collections.js # Crear colecciones con validación
│   │   └── 02_mock_data.js   # Datos de prueba
│   └── union/                 # Enfoque unificado (todo en PostgreSQL)
│       ├── 01_schema_unified.sql
│       └── 02_mock_data_unified.sql
└── golang/                    # Modelos en Go
    ├── separada/
    │   ├── postgresql/       # Modelos GORM para PostgreSQL
    │   └── mongo/            # Modelos para MongoDB
    └── juntos/               # Enfoque híbrido (PostgreSQL + JSONB)
```

## 🎯 Tres Enfoques de Implementación

### 1️⃣ Enfoque Separado (Políglota)

**PostgreSQL**: Datos transaccionales y relacionales
**MongoDB**: Documentos flexibles (resúmenes, evaluaciones, eventos)

#### Scripts
- `scripts/postgresql/` - Tablas relacionales
- `scripts/mongodb/` - Colecciones documentales

#### Modelos Go
- `golang/separada/postgresql/` - Modelos con GORM
- `golang/separada/mongo/` - Modelos con mongo-driver

**Ventajas:**
- ✅ Usa cada base de datos para lo que mejor hace
- ✅ Máxima flexibilidad
- ✅ Escalabilidad independiente

**Desventajas:**
- ❌ Mayor complejidad operacional
- ❌ Dos bases de datos que mantener
- ❌ Sincronización entre sistemas

### 2️⃣ Enfoque Unificado (Todo PostgreSQL)

**PostgreSQL**: Tablas relacionales + Tablas con campos JSONB

#### Scripts
- `scripts/union/` - Todo en PostgreSQL con JSONB

**Ventajas:**
- ✅ Una sola base de datos
- ✅ Transacciones ACID completas
- ✅ Joins entre datos relacionales y JSON
- ✅ Menor complejidad operacional

**Desventajas:**
- ❌ Menos flexible que MongoDB para documentos muy grandes
- ❌ Queries JSON más complejas que en MongoDB

### 3️⃣ Enfoque Híbrido (Juntos en Go)

**Go con GORM**: Modelos unificados que usan PostgreSQL con JSONB

#### Modelos Go
- `golang/juntos/` - Modelos híbridos con GORM + datatypes.JSON

**Ventajas:**
- ✅ API unificada en Go
- ✅ GORM maneja todo automáticamente
- ✅ Mejor para desarrollo rápido

## 🚀 Uso Rápido

### Opción 1: PostgreSQL Separado

```bash
# 1. Crear base de datos
createdb edugo

# 2. Ejecutar scripts SQL
psql -d edugo -f scripts/postgresql/01_schema.sql
psql -d edugo -f scripts/postgresql/02_indexes.sql
psql -d edugo -f scripts/postgresql/03_mock_data.sql

# 3. Usar modelos Go
cd golang/separada/postgresql
go run main.go
```

### Opción 2: MongoDB Separado

```bash
# 1. Ejecutar scripts MongoDB
mongosh < scripts/mongodb/01_collections.js
mongosh < scripts/mongodb/02_mock_data.js

# 2. Usar modelos Go
cd golang/separada/mongo
export MONGO_URI="mongodb://localhost:27017"
go run main.go
```

### Opción 3: Enfoque Unificado

```bash
# 1. Crear base de datos
createdb edugo_unified

# 2. Ejecutar scripts unificados
psql -d edugo_unified -f scripts/union/01_schema_unified.sql
psql -d edugo_unified -f scripts/union/02_mock_data_unified.sql

# 3. Usar modelos híbridos en Go
cd golang/juntos
go run main.go
```

## 📊 Contenido de la Base de Datos

### Datos Mock Incluidos

- **3 Colegios**: Colegio San José, Academia Tech, Instituto Bilingüe
- **21 Usuarios**: 5 docentes, 10 estudiantes, 5 tutores, 1 admin
- **Jerarquía Académica**: 13 unidades (años, secciones, clubs)
- **8 Materias**: Matemáticas, Programación, Historia, etc.
- **9 Materiales**: PDFs educativos sobre diversos temas
- **Relaciones**: Tutores-estudiantes, membresías, asignaciones
- **Evaluaciones**: 3 quizzes con preguntas variadas
- **Resúmenes IA**: 4 resúmenes generados
- **Eventos**: 8 eventos de procesamiento

## 🔧 Modelos de Datos

### PostgreSQL (18 tablas MVP)

1. `app_user` - Usuarios del sistema
2. `teacher_profile` - Perfiles de docentes
3. `student_profile` - Perfiles de estudiantes
4. `guardian_profile` - Perfiles de tutores
5. `guardian_student_relation` - Relaciones familiares
6. `school` - Colegios/Academias
7. `academic_unit` - Jerarquía académica recursiva
8. `unit_membership` - Membresías con roles
9. `subject` - Catálogo de materias
10. `learning_material` - Materiales educativos
11. `material_version` - Versionado de archivos
12. `material_unit_link` - Asignación N:M
13. `reading_log` - Progreso de lectura
14. `material_summary_link` - Referencias a MongoDB
15. `assessment` - Metadatos de evaluaciones
16. `assessment_attempt` - Intentos
17. `assessment_attempt_answer` - Respuestas
18. + Tablas audit (post-MVP)

### MongoDB (5 colecciones)

1. `material_summary` - Resúmenes generados por IA
2. `material_assessment` - Bancos de preguntas
3. `material_event` - Logs de procesamiento
4. `unit_social_feed` - Feeds sociales (POST-MVP)
5. `user_graph_relation` - Grafos sociales (POST-MVP)

### Enfoque Unificado (Tablas adicionales)

- `material_summary_json` - Resúmenes como JSONB
- `material_assessment_json` - Evaluaciones como JSONB
- `material_event_json` - Eventos como JSONB
- `unit_social_feed_json` - Feeds como JSONB (POST-MVP)
- `user_graph_relation_json` - Grafos como JSONB (POST-MVP)

## 🛠️ Tecnologías

- **PostgreSQL** 14+ con `uuid-ossp`
- **MongoDB** 5+
- **Go** 1.21+
- **GORM** v1.25+ (ORM para PostgreSQL)
- **mongo-driver** v1.13+ (Driver oficial de MongoDB)

## 📚 Documentación Adicional

- [Análisis Completo](../AnalisisDetallado/BaseDeDatos/README.md)
- [Estrategia de Persistencia](../AnalisisDetallado/BaseDeDatos/01_Estrategia_Persistencia.md)
- [Unidades Académicas](../AnalisisDetallado/BaseDeDatos/02_Unidades_Academicas.md)
- [Detalle Persistencia Híbrida](../AnalisisDetallado/BaseDeDatos/Detalle_Persistencia_Hibrida/)

## 🎓 Características Implementadas

### Scripts SQL
✅ DDL completo con constraints, FKs y checks
✅ Índices optimizados (B-tree, GIN para JSONB)
✅ Triggers para validación de jerarquías
✅ Vistas útiles para consultas comunes
✅ Funciones PL/pgSQL para validaciones
✅ Datos mock realistas y variados

### Scripts MongoDB
✅ Validación de esquemas con `$jsonSchema`
✅ Índices compuestos y únicos
✅ TTL index para eventos (90 días)
✅ Documentos con estructuras complejas
✅ Datos de ejemplo con todos los tipos de preguntas

### Modelos Go
✅ UUIDs como claves primarias
✅ Relaciones HasMany, BelongsTo, Many2Many
✅ Hooks BeforeCreate para UUIDs
✅ Tags GORM completos
✅ Campos JSONB con datatypes.JSON
✅ Constructores para modelos MongoDB
✅ Migraciones automáticas
✅ Ejemplos de uso completos

## 📝 Variables de Entorno

### PostgreSQL
```bash
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=tu_password
DB_NAME=edugo
DB_PORT=5432
DB_SSLMODE=disable
```

### MongoDB
```bash
MONGO_URI=mongodb://localhost:27017
MONGO_DB=edugo
```

## 🔍 Próximos Pasos

1. **Fase 2 - Post-MVP**:
   - Implementar tablas de auditoría
   - Activar funcionalidades sociales
   - Añadir búsqueda full-text

2. **Optimizaciones**:
   - Añadir extensión ltree para jerarquías
   - Implementar particionado de tablas grandes
   - Configurar replicación

3. **Integración**:
   - API REST con Gin/Echo
   - GraphQL con gqlgen
   - Workers asíncronos para procesamiento IA

## 📄 Licencia

Este código es parte del proyecto EduGo - Sistema de Gestión Académica.

---

**Autor**: Claude (Anthropic)
**Fecha**: 2024
**Versión**: 1.0.0
