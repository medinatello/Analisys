# Proceso: Seguimiento de Progreso

## Descripción
Proceso mediante el cual un docente consulta el progreso de sus estudiantes en materiales específicos, obteniendo estadísticas agregadas y detalle individual.

## Actores
- **Docente**: Consulta estadísticas y progreso
- **API Mobile**: Provee datos agregados
- **PostgreSQL**: Almacena progreso, intentos y respuestas

## Diagrama de Flujo

```mermaid
flowchart TD
    Start([Docente abre
        panel de materiales]) --> ViewMyMaterials[App muestra materiales
        creados por docente]

    ViewMyMaterials --> SelectMaterial{Docente selecciona
        material para ver stats}
    SelectMaterial -->|No| End1([Fin])

    SelectMaterial -->|Sí| RequestStats[App llama
        GET /v1/materials/:id/stats]

    RequestStats --> ValidatePerms{API valida
        permisos del docente}
    ValidatePerms -->|No es autor
        ni docente de unidad| ErrorPerms[Error 403]
    ErrorPerms --> End2([Fin])

    ValidatePerms -->|Es autor o docente| QueryProgress[API consulta PostgreSQL:
        progreso + intentos + estudiantes]

    QueryProgress --> AggregateData[API calcula agregados:
        promedio, completados, pendientes]

    AggregateData --> ReturnStats[API retorna
        estadísticas completas]

    ReturnStats --> DisplayOverview[App muestra vista general:
        Cards con métricas clave]

    DisplayOverview --> ViewOptions{Docente elige
        vista}

    ViewOptions -->|Vista General| ShowSummary[Mostrar resumen:
        - Promedio puntaje
        - Tasa completitud
        - Estudiantes activos]
    ShowSummary --> End3([Fin])

    ViewOptions -->|Lista Estudiantes| ShowStudentList[Mostrar tabla:
        Nombre | Progreso | Puntaje | Última actividad]
    ShowStudentList --> SelectStudent{Docente selecciona
        estudiante}

    SelectStudent -->|No| End4([Fin])
    SelectStudent -->|Sí| ShowStudentDetail[Mostrar detalle:
        - Historial de progreso
        - Intentos de quiz
        - Tiempo invertido]

    ShowStudentDetail --> End5([Fin])

    ViewOptions -->|Exportar Reporte| GenerateCSV[Generar CSV
        con todos los datos]
    GenerateCSV --> DownloadCSV[Descargar archivo]
    DownloadCSV --> End6([Fin])

    style Start fill:#e1f5ff
    style End1 fill:#e8f5e9
    style End2 fill:#ffebee
    style End3 fill:#e8f5e9
    style End4 fill:#e8f5e9
    style End5 fill:#e8f5e9
    style End6 fill:#e8f5e9
    style ErrorPerms fill:#ffcdd2
```

## Fases del Proceso

### Fase 1: Solicitud de Estadísticas
**Duración estimada**: 1-3 segundos

#### 1.1 Petición
```http
GET /v1/materials/{material_id}/stats
Authorization: Bearer {jwt_token}
```

#### 1.2 Validación de Permisos
```sql
-- Docente debe ser autor O tener rol teacher/owner en alguna unidad del material
SELECT EXISTS (
    SELECT 1
    FROM learning_material m
    WHERE m.id = $1
    AND (
        m.author_id = $2  -- Es el autor
        OR EXISTS (
            SELECT 1
            FROM material_unit_link mul
            INNER JOIN unit_membership um ON mul.unit_id = um.unit_id
            WHERE mul.material_id = $1
            AND um.user_id = $2
            AND um.role IN ('teacher', 'owner')
        )
    )
) as has_permission;
```

#### 1.3 Query Complejo de Progreso
```sql
WITH student_list AS (
    -- Obtener todos los estudiantes de las unidades asignadas
    SELECT DISTINCT
        sp.user_id,
        au.name as student_name,
        um.unit_id,
        un.display_name as unit_name
    FROM unit_membership um
    INNER JOIN student_profile sp ON um.user_id = sp.user_id
    INNER JOIN app_user au ON sp.user_id = au.id
    INNER JOIN academic_unit un ON um.unit_id = un.id
    WHERE um.unit_id IN (
        SELECT unit_id
        FROM material_unit_link
        WHERE material_id = $1
    )
    AND um.role = 'student'
),
reading_data AS (
    -- Obtener datos de lectura
    SELECT
        rl.student_id,
        rl.progress,
        rl.time_spent,
        rl.last_access_at
    FROM reading_log rl
    WHERE rl.material_id = $1
),
assessment_data AS (
    -- Obtener mejor intento de cada estudiante
    SELECT DISTINCT ON (aa.student_id)
        aa.student_id,
        aa.score as latest_score,
        aa.completed_at as attempt_date,
        aa.id as attempt_id
    FROM assessment_attempt aa
    INNER JOIN assessment a ON aa.assessment_id = a.id
    WHERE a.material_id = $1
    ORDER BY aa.student_id, aa.score DESC, aa.completed_at DESC
)
SELECT
    sl.user_id,
    sl.student_name,
    sl.unit_name,
    COALESCE(rd.progress, 0) as progress,
    COALESCE(rd.time_spent, 0) as time_spent,
    rd.last_access_at,
    ad.latest_score,
    ad.attempt_date,
    ad.attempt_id,
    CASE
        WHEN rd.progress IS NULL THEN 'not_started'
        WHEN rd.progress = 100 THEN 'completed'
        ELSE 'in_progress'
    END as status
FROM student_list sl
LEFT JOIN reading_data rd ON sl.user_id = rd.student_id
LEFT JOIN assessment_data ad ON sl.user_id = ad.student_id
ORDER BY sl.student_name;
```

#### 1.4 Cálculo de Agregados
```go
type MaterialStats struct {
    Material         MaterialBasicInfo
    TotalStudents    int
    NotStarted       int
    InProgress       int
    Completed        int
    AverageProgress  float64
    AverageScore     float64  // Solo estudiantes que hicieron quiz
    AverageTimeSpent int      // Segundos
    Students         []StudentProgress
}

func calculateAggregates(students []StudentProgress) MaterialStats {
    stats := MaterialStats{
        TotalStudents: len(students),
    }

    var totalProgress float64
    var totalScore float64
    var scoreCount int
    var totalTime int

    for _, student := range students {
        // Contar por estado
        switch student.Status {
        case "not_started":
            stats.NotStarted++
        case "in_progress":
            stats.InProgress++
        case "completed":
            stats.Completed++
        }

        // Sumar progreso
        totalProgress += student.Progress

        // Sumar tiempo
        totalTime += student.TimeSpent

        // Sumar puntaje (solo si hizo quiz)
        if student.LatestScore != nil {
            totalScore += *student.LatestScore
            scoreCount++
        }
    }

    // Promedios
    if len(students) > 0 {
        stats.AverageProgress = totalProgress / float64(len(students))
        stats.AverageTimeSpent = totalTime / len(students)
    }

    if scoreCount > 0 {
        stats.AverageScore = totalScore / float64(scoreCount)
    }

    stats.Students = students
    return stats
}
```

#### 1.5 Respuesta
```json
{
  "material": {
    "id": "uuid",
    "title": "Introducción a Pascal",
    "created_at": "2025-01-15T12:00:00Z"
  },
  "summary": {
    "total_students": 25,
    "not_started": 5,
    "in_progress": 12,
    "completed": 8,
    "average_progress": 62.4,
    "average_score": 75.5,
    "average_time_spent_minutes": 45,
    "completion_rate": 32.0,
    "quiz_taken_rate": 72.0
  },
  "students": [
    {
      "id": "uuid-1",
      "name": "Ana García",
      "unit_name": "5.º A - Programación",
      "progress": 100,
      "time_spent_minutes": 60,
      "last_access": "2025-01-28T15:30:00Z",
      "latest_score": 95,
      "attempt_date": "2025-01-28T16:00:00Z",
      "status": "completed"
    },
    {
      "id": "uuid-2",
      "name": "Carlos López",
      "unit_name": "5.º A - Programación",
      "progress": 45,
      "time_spent_minutes": 30,
      "last_access": "2025-01-29T10:00:00Z",
      "latest_score": null,
      "attempt_date": null,
      "status": "in_progress"
    },
    {
      "id": "uuid-3",
      "name": "Diana Martínez",
      "unit_name": "5.º B - Programación",
      "progress": 0,
      "time_spent_minutes": 0,
      "last_access": null,
      "latest_score": null,
      "attempt_date": null,
      "status": "not_started"
    }
  ]
}
```

---

### Fase 2: Visualización de Estadísticas
**Duración estimada**: Variable (docente explora)

#### 2.1 Vista General (Dashboard)

**Cards de métricas clave**:

1. **Participación**:
   ```
   ┌─────────────────────────┐
   │  👥 Participación       │
   │                         │
   │  20 de 25 estudiantes   │
   │  80% iniciaron          │
   │                         │
   │  ██████████████░░░░░   │
   └─────────────────────────┘
   ```

2. **Completitud**:
   ```
   ┌─────────────────────────┐
   │  ✓ Completitud          │
   │                         │
   │  8 de 25 completaron    │
   │  32% terminaron         │
   │                         │
   │  ████░░░░░░░░░░░░░░░░░ │
   └─────────────────────────┘
   ```

3. **Rendimiento**:
   ```
   ┌─────────────────────────┐
   │  📊 Rendimiento         │
   │                         │
   │  Promedio: 75.5 / 100   │
   │  18 hicieron quiz       │
   │                         │
   │  ███████████████░░░░░  │
   └─────────────────────────┘
   ```

4. **Tiempo Invertido**:
   ```
   ┌─────────────────────────┐
   │  ⏱️  Tiempo Promedio    │
   │                         │
   │  45 minutos             │
   │  por estudiante         │
   │                         │
   └─────────────────────────┘
   ```

**Gráficos**:

1. **Distribución de Progreso** (Histograma):
   - Eje X: Rangos de progreso (0-20%, 21-40%, 41-60%, 61-80%, 81-100%)
   - Eje Y: Número de estudiantes

2. **Distribución de Puntajes** (Histograma):
   - Eje X: Rangos de puntaje (0-49, 50-69, 70-84, 85-100)
   - Eje Y: Número de estudiantes

3. **Actividad en el Tiempo** (Línea):
   - Eje X: Días desde publicación
   - Eje Y: Número de accesos / quiz completados

#### 2.2 Vista de Lista de Estudiantes

**Tabla interactiva**:

| Estudiante | Unidad | Progreso | Última Actividad | Puntaje | Estado |
|------------|--------|----------|------------------|---------|--------|
| Ana García | 5.º A | ████████████ 100% | 28 Ene, 15:30 | 95 / 100 | ✓ Completado |
| Carlos López | 5.º A | ███████░░░░░ 45% | 29 Ene, 10:00 | - | 📖 En progreso |
| Diana Martínez | 5.º B | ░░░░░░░░░░░░ 0% | - | - | ⏸️  No iniciado |

**Funcionalidades**:
- Ordenar por cualquier columna
- Filtrar por estado (completado, en progreso, no iniciado)
- Filtrar por unidad
- Buscar por nombre
- Exportar a CSV

#### 2.3 Detalle Individual de Estudiante

Al hacer clic en un estudiante:

**Información general**:
- Nombre completo
- Unidad académica
- Email (opcional)

**Progreso de lectura**:
- Barra de progreso visual
- Tiempo total invertido
- Última página leída
- Historial de sesiones (Post-MVP):
  ```
  28 Ene 15:00 - 15:45: 45 min (página 1-10, 50% progreso)
  29 Ene 10:00 - 10:30: 30 min (página 11-20, 100% progreso)
  ```

**Resultados de quiz**:
- Historial de todos los intentos:
  ```
  Intento 1: 28 Ene 16:00 - 60 / 100 (3 de 5 correctas)
  Intento 2: 29 Ene 11:00 - 95 / 100 (5 de 5 correctas) ✓ Mejor
  ```
- Detalle de respuestas (Post-MVP):
  - Qué preguntas respondió correctamente
  - Qué preguntas falló
  - Tiempo por pregunta

**Acciones**:
- Enviar mensaje al estudiante (Post-MVP)
- Ver otros materiales del estudiante
- Generar reporte individual

---

### Fase 3: Exportación de Reporte (Post-MVP)
**Duración estimada**: 1-2 segundos

#### 3.1 Generación de CSV
```http
GET /v1/materials/{material_id}/stats/export?format=csv
Authorization: Bearer {jwt_token}
```

#### 3.2 Contenido del CSV
```csv
Estudiante,Unidad,Progreso (%),Tiempo (min),Última Actividad,Puntaje,Intentos,Estado
Ana García,5.º A - Programación,100,60,2025-01-28 15:30:00,95,2,Completado
Carlos López,5.º A - Programación,45,30,2025-01-29 10:00:00,,,En progreso
Diana Martínez,5.º B - Programación,0,0,,,0,No iniciado
```

#### 3.3 Descarga
- Nombre de archivo: `progreso-{material_slug}-{fecha}.csv`
- Content-Type: `text/csv; charset=utf-8`
- Content-Disposition: `attachment; filename="..."`

---

## Casos de Uso Específicos

### Caso 1: Identificar Estudiantes Rezagados
**Objetivo**: Docente quiere contactar estudiantes que no han iniciado

**Flujo**:
1. Abrir estadísticas del material
2. Filtrar por estado "No iniciado"
3. Ver lista de 5 estudiantes
4. Enviar recordatorio (Post-MVP)

### Caso 2: Analizar Desempeño Grupal
**Objetivo**: Comparar rendimiento entre secciones

**Flujo**:
1. Abrir estadísticas
2. Observar que 5.º A tiene promedio de 80% y 5.º B tiene 65%
3. Decidir reforzar conceptos en 5.º B
4. Revisar qué preguntas fallaron más en 5.º B (Post-MVP)

### Caso 3: Validar Dificultad del Material
**Objetivo**: Verificar si material es apropiado para el nivel

**Indicadores**:
- Si **< 30% completan**: Material muy difícil o largo
- Si **promedio quiz < 60%**: Conceptos poco claros
- Si **tiempo promedio > esperado**: Material extenso

**Acción**: Ajustar material o crear versión simplificada

---

## Funcionalidades Post-MVP

### Estadísticas Avanzadas
1. **Análisis por pregunta**:
   - Qué preguntas tienen menor tasa de acierto
   - Identificar conceptos que causan confusión

2. **Correlaciones**:
   - Relación entre tiempo de lectura y puntaje de quiz
   - Relación entre número de intentos y mejora

3. **Comparativas**:
   - Comparar este material con otros del mismo docente
   - Benchmarking con materiales similares de otros docentes

### Alertas Automáticas
- Notificar docente si > 50% de estudiantes no inicia en 7 días
- Alertar si promedio de quiz < 60%
- Recordar estudiantes en riesgo (progreso estancado)

### Reportes Programados
- Envío semanal automático por email con resumen
- Dashboard de métricas de todos los materiales del docente

---

## Indicadores de Éxito (KPIs)

1. **Uso de Estadísticas por Docentes**
   - Objetivo: > 70% de docentes consultan stats al menos 1 vez por semana
   - Medición: Logs de acceso a endpoint `/stats`

2. **Tiempo de Respuesta del Query**
   - Objetivo: < 2 segundos para materiales con < 100 estudiantes
   - Medición: Monitoreo de latencia en API

3. **Acciones Tomadas**
   - Objetivo: > 40% de docentes toman acción (contactar, ajustar material)
   - Medición: Eventos posteriores a consulta de stats

---

## Optimizaciones de Rendimiento

### Índices PostgreSQL
```sql
-- Índice compuesto para query principal
CREATE INDEX idx_reading_log_material_student ON reading_log(material_id, student_id);

-- Índice para assessment_attempt con ordenamiento
CREATE INDEX idx_assessment_attempt_score ON assessment_attempt(student_id, assessment_id, score DESC, completed_at DESC);

-- Índice parcial para estudiantes activos
CREATE INDEX idx_unit_membership_students ON unit_membership(unit_id, user_id) WHERE role = 'student';
```

### Caché (Post-MVP)
- Redis con TTL de 5 minutos
- Key: `stats:{material_id}`
- Invalidar al registrar nuevo progreso o intento

### Paginación
- Para materiales con > 50 estudiantes, paginar tabla
- Cargar primeros 20, lazy load resto

---

**Documento**: Proceso de Seguimiento de Progreso
**Versión**: 1.0
**Fecha**: 2025-01-29
**Autor**: Equipo EduGo
