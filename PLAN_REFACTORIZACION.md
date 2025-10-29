# 📋 PLAN DE TRABAJO DETALLADO - REFACTORIZACIÓN COMPLETA EDUGO

## 🎯 OBJETIVO
Implementar versión completa de esquemas MongoDB, corregir inconsistencias documentales, reestructurar carpetas, agregar endpoints faltantes y sincronizar código con documentación.

---

## 📊 FASE 1: PREPARACIÓN Y AUDITORÍA INICIAL

### 1.1 Auditoría de Estado Actual
- [ ] Verificar que no haya cambios sin commitear importantes
- [ ] Crear backup de carpeta completa (opcional pero recomendado)
- [ ] Documentar estructura actual de carpetas en archivo temporal
- [ ] Listar todos los endpoints actuales en ambas APIs
- [ ] Verificar que tests existentes (si los hay) pasen antes de empezar

**Salida esperada:** Snapshot del estado actual del proyecto

---

## 📁 FASE 2: REESTRUCTURACIÓN DE CARPETAS

### 2.1 Planificar Nueva Estructura
- [ ] Definir estructura objetivo (eliminar nested AnalisisFinal/)
- [ ] Crear diagrama de migración de carpetas
- [ ] Identificar archivos que se moverán
- [ ] Identificar archivos que se eliminarán

**Estructura Objetivo:**
```
/Users/jhoanmedina/source/EduGo/Analisys/
├── docs/                          # Documentación (ya existe)
│   ├── diagramas/
│   └── historias_usuario/
├── source/                        # Productos (reestructurado)
│   ├── api-mobile/               # API Mobile (puerto 8080)
│   ├── api-administracion/       # API Admin (puerto 8081)
│   ├── worker/                   # Worker procesamiento
│   └── scripts/                  # Scripts DB compartidos
│       ├── postgresql/
│       └── mongodb/
└── README.md
```

### 2.2 Ejecutar Reestructuración
- [ ] Mover `AnalisisFinal/docs/` → `/docs/` (raíz)
- [ ] Mover `AnalisisFinal/source/api-mobile/AnalisisFinal/source/api-mobile/` → `/source/api-mobile/`
- [ ] Mover `AnalisisFinal/source/api-mobile/AnalisisFinal/source/api-administracion/` → `/source/api-administracion/`
- [ ] Mover `AnalisisFinal/source/api-mobile/AnalisisFinal/source/worker/` → `/source/worker/`
- [ ] Mover `AnalisisFinal/source/scripts/` → `/source/scripts/` (versión completa)
- [ ] Eliminar carpeta `/source/api-mobile/` intermedia (la vieja)
- [ ] Eliminar todas las carpetas `AnalisisFinal/` ahora vacías

### 2.3 Verificar Reestructuración
- [ ] Verificar que `source/scripts/mongodb/` sea la versión completa (341 líneas en 01_collections.js)
- [ ] Verificar que no queden carpetas duplicadas
- [ ] Actualizar referencias de paths en README.md si existen
- [ ] Verificar que `docs/` esté en raíz con todos los diagramas

**Salida esperada:** Estructura limpia y plana

---

## 📝 FASE 3: CORRECCIONES DOCUMENTALES

### 3.1 Corregir Documento DISTRIBUCION_PROCESOS.md
- [ ] Abrir `/docs/diagramas/DISTRIBUCION_PROCESOS.md`
- [ ] Línea 232: Agregar sufijo **(Post-MVP - No implementado)** a `POST /v1/guardian-relations`
- [ ] Línea 248: Agregar sufijo **(Post-MVP - No implementado)** a `PATCH /v1/subjects/:id`
- [ ] Verificar que no haya otras referencias a endpoints no implementados
- [ ] Guardar cambios

### 3.2 Verificar Consistencia de Otros Diagramas
- [ ] Revisar `/docs/diagramas/arquitectura/arquitectura_completa.md` (no debe requerir cambios)
- [ ] Revisar `/docs/diagramas/base_datos/modelo_completo.md` (no debe requerir cambios)
- [ ] Verificar que todos los diagramas referencien estructura nueva de carpetas

### 3.3 Commitear Cambios Documentales
- [ ] `git add docs/diagramas/DISTRIBUCION_PROCESOS.md`
- [ ] `git add docs/diagramas/arquitectura/arquitectura_completa.md`
- [ ] `git add docs/diagramas/base_datos/modelo_completo.md`
- [ ] `git commit -m "docs: agregar documentación de arquitectura completa y marcar endpoints Post-MVP"`

**Salida esperada:** Documentos sincronizados y commiteados

---

## 🗄️ FASE 4: ACTUALIZACIÓN DE SCRIPTS DE BASE DE DATOS

### 4.1 Verificar Scripts PostgreSQL
- [ ] Confirmar que `/source/scripts/postgresql/01_schema.sql` tiene 17 tablas
- [ ] Verificar que tabla `guardian_student_relation` exista
- [ ] Verificar que tabla `subject` exista
- [ ] Confirmar que índices en `02_indexes.sql` estén completos
- [ ] Revisar `03_mock_data.sql` para datos de prueba

### 4.2 Verificar Scripts MongoDB (Versión Completa)
- [ ] Confirmar que `/source/scripts/mongodb/01_collections.js` tenga 341 líneas
- [ ] Verificar schema de `material_summary` incluya:
  - [ ] `sections[].estimated_time_minutes`
  - [ ] `glossary[]` (term, definition, order)
  - [ ] `reflection_questions[]`
  - [ ] `processing_metadata` completo
  - [ ] `updated_at`
- [ ] Verificar schema de `material_assessment` incluya:
  - [ ] `description`
  - [ ] `questions[].difficulty`
  - [ ] `questions[].points`
  - [ ] `questions[].order`
  - [ ] `questions[].feedback`
  - [ ] `total_questions`, `total_points`, `passing_score`, `time_limit_minutes`
  - [ ] `processing_metadata`
  - [ ] `updated_at`
- [ ] Verificar schema de `material_event` incluya validación completa
- [ ] Confirmar índices en `02_indexes.js` (126 líneas)
- [ ] Revisar `03_mock_data.js` con datos completos

### 4.3 Documentar Cambios de DB
- [ ] Crear archivo `/docs/MIGRATION_GUIDE.md` documentando:
  - [ ] Cambios en esquemas MongoDB
  - [ ] Campos nuevos agregados
  - [ ] Impacto en endpoints existentes

**Salida esperada:** Scripts DB completos y documentados

---

## 🏗️ FASE 5: ACTUALIZACIÓN DE MODELOS GO

### 5.1 API Mobile - Modelos de Respuesta

#### 5.1.1 Crear Modelos para Resumen Completo
- [ ] Abrir `/source/api-mobile/internal/models/response/material.go`
- [ ] Crear struct `SummarySection`:
  ```go
  type SummarySection struct {
      Title                string `json:"title" example:"Contexto Histórico"`
      Content              string `json:"content" example:"Pascal fue desarrollado..."`
      Difficulty           string `json:"difficulty" example:"basic" enums:"basic,medium,advanced"`
      EstimatedTimeMinutes int    `json:"estimated_time_minutes,omitempty" example:"5"`
      Order                int    `json:"order" example:"1"`
  }
  ```
- [ ] Crear struct `GlossaryTerm`:
  ```go
  type GlossaryTerm struct {
      Term       string `json:"term" example:"Compilador"`
      Definition string `json:"definition" example:"Programa que traduce código..."`
      Order      int    `json:"order" example:"1"`
  }
  ```
- [ ] Crear struct `ProcessingMetadata`:
  ```go
  type ProcessingMetadata struct {
      NLPProvider           string `json:"nlp_provider,omitempty" example:"openai"`
      Model                 string `json:"model,omitempty" example:"gpt-4"`
      TokensUsed            int    `json:"tokens_used,omitempty" example:"3500"`
      ProcessingTimeSeconds int    `json:"processing_time_seconds,omitempty" example:"45"`
      Language              string `json:"language,omitempty" example:"es"`
      PromptVersion         string `json:"prompt_version,omitempty" example:"v1.2"`
  }
  ```
- [ ] Actualizar `MaterialSummaryResponse`:
  ```go
  type MaterialSummaryResponse struct {
      Sections            []SummarySection   `json:"sections"`
      Glossary            []GlossaryTerm     `json:"glossary,omitempty"`
      ReflectionQuestions []string           `json:"reflection_questions,omitempty"`
      ProcessingMetadata  ProcessingMetadata `json:"processing_metadata,omitempty"`
  }
  ```

#### 5.1.2 Crear Modelos para Quiz Completo
- [ ] Crear struct `QuestionOption`:
  ```go
  type QuestionOption struct {
      ID   string `json:"id" example:"a"`
      Text string `json:"text" example:"Un programa que traduce código"`
  }
  ```
- [ ] Actualizar struct `Question`:
  ```go
  type Question struct {
      ID         string            `json:"id" example:"q1"`
      Text       string            `json:"text" example:"¿Qué es un compilador?"`
      Type       string            `json:"type" example:"multiple_choice" enums:"multiple_choice,true_false,short_answer"`
      Difficulty string            `json:"difficulty,omitempty" example:"basic" enums:"basic,medium,advanced"`
      Points     int               `json:"points" example:"20"`
      Order      int               `json:"order" example:"1"`
      Options    []QuestionOption  `json:"options"`
  }
  ```
- [ ] Actualizar struct `AssessmentResponse`:
  ```go
  type AssessmentResponse struct {
      Title            string     `json:"title" example:"Cuestionario: Introducción a Pascal"`
      Description      string     `json:"description,omitempty" example:"Evaluación de conceptos básicos"`
      Questions        []Question `json:"questions"`
      TotalQuestions   int        `json:"total_questions" example:"5"`
      TotalPoints      int        `json:"total_points" example:"100"`
      PassingScore     int        `json:"passing_score" example:"70"`
      TimeLimitMinutes int        `json:"time_limit_minutes,omitempty" example:"15"`
  }
  ```

#### 5.1.3 Actualizar Modelo de Resultado de Intento
- [ ] Crear struct `QuestionFeedback`:
  ```go
  type QuestionFeedback struct {
      QuestionID      string `json:"question_id" example:"q1"`
      IsCorrect       bool   `json:"is_correct" example:"true"`
      YourAnswer      string `json:"your_answer" example:"a"`
      FeedbackMessage string `json:"feedback_message" example:"¡Correcto! Un compilador..."`
  }
  ```
- [ ] Actualizar `AttemptResultResponse`:
  ```go
  type AttemptResultResponse struct {
      Score            float64            `json:"score" example:"85.5"`
      TotalPoints      float64            `json:"total_points" example:"100"`
      Passed           bool               `json:"passed" example:"true"`
      DetailedFeedback []QuestionFeedback `json:"detailed_feedback"`
  }
  ```

### 5.2 API Mobile - Modelos MongoDB (internos)
- [ ] Crear archivo `/source/api-mobile/internal/models/mongodb/material.go`
- [ ] Crear struct `MaterialSummaryDocument` (refleja MongoDB):
  ```go
  type MaterialSummaryDocument struct {
      MaterialID         string               `bson:"material_id"`
      Version            int                  `bson:"version"`
      Status             string               `bson:"status"`
      Sections           []SummarySection     `bson:"sections"`
      Glossary           []GlossaryTerm       `bson:"glossary,omitempty"`
      ReflectionQuestions []string            `bson:"reflection_questions,omitempty"`
      ProcessingMetadata ProcessingMetadata   `bson:"processing_metadata,omitempty"`
      CreatedAt          time.Time            `bson:"created_at"`
      UpdatedAt          time.Time            `bson:"updated_at,omitempty"`
  }
  ```
- [ ] Crear struct `MaterialAssessmentDocument`:
  ```go
  type MaterialAssessmentDocument struct {
      MaterialID         string               `bson:"material_id"`
      Title              string               `bson:"title"`
      Description        string               `bson:"description,omitempty"`
      Questions          []QuestionDocument   `bson:"questions"`
      TotalQuestions     int                  `bson:"total_questions"`
      TotalPoints        int                  `bson:"total_points"`
      PassingScore       int                  `bson:"passing_score"`
      TimeLimitMinutes   int                  `bson:"time_limit_minutes,omitempty"`
      Version            int                  `bson:"version"`
      ProcessingMetadata ProcessingMetadata   `bson:"processing_metadata,omitempty"`
      CreatedAt          time.Time            `bson:"created_at"`
      UpdatedAt          time.Time            `bson:"updated_at,omitempty"`
  }

  type QuestionDocument struct {
      ID             string           `bson:"id"`
      Text           string           `bson:"text"`
      Type           string           `bson:"type"`
      Difficulty     string           `bson:"difficulty,omitempty"`
      Points         int              `bson:"points"`
      Order          int              `bson:"order"`
      Options        []QuestionOption `bson:"options"`
      CorrectAnswer  string           `bson:"correct_answer"`
      Feedback       QuestionFeedbackDoc `bson:"feedback,omitempty"`
  }

  type QuestionFeedbackDoc struct {
      Correct   string `bson:"correct"`
      Incorrect string `bson:"incorrect"`
  }
  ```

### 5.3 API Administración - Nuevos Modelos
- [ ] Crear archivo `/source/api-administracion/internal/models/request/admin.go` si no existe
- [ ] Crear struct `CreateGuardianRelationRequest`:
  ```go
  type CreateGuardianRelationRequest struct {
      GuardianID       string `json:"guardian_id" binding:"required"`
      StudentID        string `json:"student_id" binding:"required"`
      RelationshipType string `json:"relationship_type" binding:"required" enums:"father,mother,guardian,other"`
  }
  ```
- [ ] Crear struct `UpdateSubjectRequest`:
  ```go
  type UpdateSubjectRequest struct {
      Name        string `json:"name"`
      Description string `json:"description"`
      Metadata    map[string]interface{} `json:"metadata,omitempty"`
  }
  ```

**Salida esperada:** Modelos Go completos y tipados

---

## 🔌 FASE 6: IMPLEMENTACIÓN DE HANDLERS

### 6.1 API Mobile - Actualizar Handlers Existentes

#### 6.1.1 Handler GetSummary
- [ ] Abrir `/source/api-mobile/internal/handlers/materials.go`
- [ ] Localizar función `GetSummary`
- [ ] Implementar lógica real (reemplazar mock):
  ```go
  // 1. Obtener material_id desde PostgreSQL
  // 2. Consultar MongoDB: db.material_summary.findOne({ material_id: id })
  // 3. Mapear MaterialSummaryDocument → MaterialSummaryResponse
  // 4. Retornar JSON
  ```
- [ ] Agregar manejo de errores:
  - [ ] 404 si material no existe
  - [ ] 404 si resumen aún no está generado (status != "completed")
  - [ ] 500 si error de MongoDB
- [ ] Actualizar comentario godoc con nuevos campos

#### 6.1.2 Handler GetAssessment
- [ ] Localizar función `GetAssessment`
- [ ] Implementar lógica real:
  ```go
  // 1. Consultar MongoDB con proyección
  // 2. CRITICAL: Excluir correct_answer y feedback
  // 3. Mapear a AssessmentResponse
  ```
- [ ] Implementar proyección MongoDB:
  ```go
  projection := bson.M{
      "questions.correct_answer": 0,
      "questions.feedback": 0,
  }
  ```
- [ ] Actualizar comentario godoc

#### 6.1.3 Handler RecordAttempt
- [ ] Localizar función `RecordAttempt` (POST assessment/attempts)
- [ ] Implementar validación en servidor:
  ```go
  // 1. Obtener quiz completo de MongoDB (CON correct_answer)
  // 2. Validar cada respuesta del estudiante
  // 3. Construir DetailedFeedback usando feedback.correct o feedback.incorrect
  // 4. Calcular score
  // 5. Guardar intento en PostgreSQL
  // 6. Retornar AttemptResultResponse con feedback personalizado
  ```
- [ ] CRITICAL: No confiar en cliente para puntaje
- [ ] Actualizar comentario godoc

### 6.2 API Administración - Nuevos Handlers

#### 6.2.1 Handler CreateGuardianRelation (POST-MVP)
- [ ] Crear archivo `/source/api-administracion/internal/handlers/guardians.go`
- [ ] Implementar función `CreateGuardianRelation`:
  ```go
  // @Summary Crear vínculo tutor-estudiante
  // @Tags Guardians
  // @Accept json
  // @Produce json
  // @Param body body request.CreateGuardianRelationRequest true "Datos de relación"
  // @Success 201 {object} response.SuccessResponse
  // @Security BearerAuth
  // @Router /guardian-relations [post]
  func CreateGuardianRelation(c *gin.Context) {
      // 1. Validar que guardian_id tenga rol 'guardian'
      // 2. Validar que student_id tenga rol 'student'
      // 3. Insertar en guardian_student_relation
      // 4. Retornar 201
  }
  ```
- [ ] Agregar validaciones:
  - [ ] Verificar que usuarios existan
  - [ ] Verificar roles correctos
  - [ ] Prevenir duplicados (UNIQUE constraint)
- [ ] Registrar ruta en router

#### 6.2.2 Handler UpdateSubject (POST-MVP)
- [ ] Abrir `/source/api-administracion/internal/handlers/subjects.go` (o crear)
- [ ] Implementar función `UpdateSubject`:
  ```go
  // @Summary Actualizar materia
  // @Tags Subjects
  // @Accept json
  // @Produce json
  // @Param id path string true "ID de materia"
  // @Param body body request.UpdateSubjectRequest true "Datos a actualizar"
  // @Success 200 {object} response.SuccessResponse
  // @Security BearerAuth
  // @Router /subjects/{id} [patch]
  func UpdateSubject(c *gin.Context) {
      // 1. Validar que materia exista
      // 2. Solo admin puede actualizar
      // 3. UPDATE subject SET ... WHERE id = $1
      // 4. Retornar 200
  }
  ```
- [ ] Registrar ruta en router

### 6.3 Actualizar Routers
- [ ] Abrir `/source/api-mobile/internal/router/router.go`
- [ ] Verificar que rutas de materials apunten a handlers actualizados
- [ ] Abrir `/source/api-administracion/internal/router/router.go`
- [ ] Agregar ruta `POST /v1/guardian-relations`
- [ ] Agregar ruta `PATCH /v1/subjects/:id`

**Salida esperada:** Handlers implementados con lógica real

---

## 📖 FASE 7: REGENERACIÓN DE SWAGGER

### 7.1 API Mobile - Regenerar Swagger
- [ ] Abrir terminal en `/source/api-mobile/`
- [ ] Verificar que swaggo esté instalado: `swag --version`
- [ ] Si no está instalado: `go install github.com/swaggo/swag/cmd/swag@latest`
- [ ] Ejecutar: `swag init -g cmd/main.go -o docs`
- [ ] Verificar que `docs/swagger.yaml` se haya actualizado
- [ ] Verificar que `docs/swagger.json` se haya actualizado
- [ ] Revisar que nuevos modelos aparezcan en `definitions:`
  - [ ] SummarySection
  - [ ] GlossaryTerm
  - [ ] ProcessingMetadata
  - [ ] QuestionOption
  - [ ] QuestionFeedback
- [ ] Verificar que `AssessmentResponse` tenga campos nuevos

### 7.2 API Administración - Regenerar Swagger
- [ ] Abrir terminal en `/source/api-administracion/`
- [ ] Ejecutar: `swag init -g cmd/main.go -o docs`
- [ ] Verificar que aparezcan nuevos endpoints:
  - [ ] `POST /v1/guardian-relations`
  - [ ] `PATCH /v1/subjects/{id}`
- [ ] Verificar que aparezcan nuevos modelos en `definitions:`
  - [ ] CreateGuardianRelationRequest
  - [ ] UpdateSubjectRequest

### 7.3 Validar Swagger UI
- [ ] Levantar API Mobile: `cd /source/api-mobile && go run cmd/main.go`
- [ ] Abrir navegador: `http://localhost:8080/swagger/index.html`
- [ ] Verificar que se vea correctamente
- [ ] Expandir modelo `MaterialSummaryResponse` y validar estructura
- [ ] Expandir modelo `AssessmentResponse` y validar estructura
- [ ] Cerrar servidor
- [ ] Levantar API Admin: `cd /source/api-administracion && go run cmd/main.go`
- [ ] Abrir navegador: `http://localhost:8081/swagger/index.html`
- [ ] Verificar nuevos endpoints
- [ ] Cerrar servidor

**Salida esperada:** Swagger autogenerado y funcional

---

## 🧪 FASE 8: TESTING Y VALIDACIÓN

### 8.1 Tests Unitarios

#### 8.1.1 Tests de Modelos
- [ ] Crear `/source/api-mobile/internal/models/response/material_test.go`
- [ ] Test: Serialización JSON de `MaterialSummaryResponse`
- [ ] Test: Serialización JSON de `AssessmentResponse`
- [ ] Test: Validación de tags de `QuestionFeedback`
- [ ] Ejecutar: `cd /source/api-mobile && go test ./internal/models/...`

#### 8.1.2 Tests de Handlers (básicos)
- [ ] Crear `/source/api-mobile/internal/handlers/materials_test.go`
- [ ] Test: `GetSummary` retorna 404 si no existe
- [ ] Test: `GetAssessment` NO incluye `correct_answer`
- [ ] Test: `RecordAttempt` calcula score correctamente
- [ ] Ejecutar: `cd /source/api-mobile && go test ./internal/handlers/...`

### 8.2 Tests de Integración (Manual con curl)

#### 8.2.1 API Mobile
- [ ] Levantar base de datos PostgreSQL
- [ ] Levantar MongoDB
- [ ] Ejecutar scripts: `psql < source/scripts/postgresql/01_schema.sql`
- [ ] Ejecutar scripts: `mongosh < source/scripts/mongodb/01_collections.js`
- [ ] Ejecutar scripts: `mongosh < source/scripts/mongodb/02_indexes.js`
- [ ] Ejecutar scripts: `mongosh < source/scripts/mongodb/03_mock_data.js`
- [ ] Levantar API: `cd /source/api-mobile && go run cmd/main.go`
- [ ] Test manual:
  - [ ] `POST /v1/auth/login` (obtener token)
  - [ ] `GET /v1/materials` (listar materiales)
  - [ ] `GET /v1/materials/{id}` (detalle)
  - [ ] `GET /v1/materials/{id}/summary` (verificar estructura completa)
  - [ ] `GET /v1/materials/{id}/assessment` (verificar que NO tenga correct_answer)
  - [ ] `POST /v1/materials/{id}/assessment/attempts` (verificar feedback personalizado)
- [ ] Documentar resultados en archivo temporal

#### 8.2.2 API Administración
- [ ] Levantar API: `cd /source/api-administracion && go run cmd/main.go`
- [ ] Test manual:
  - [ ] `POST /v1/users` (crear usuario)
  - [ ] `POST /v1/guardian-relations` (nuevo endpoint)
  - [ ] `PATCH /v1/subjects/{id}` (nuevo endpoint)
  - [ ] `GET /v1/stats/global`
- [ ] Documentar resultados

### 8.3 Validación de Consistencia
- [ ] Comparar respuesta de `GET /v1/materials/{id}/summary` con schema MongoDB
- [ ] Verificar que todos los campos documentados en diagramas estén presentes
- [ ] Verificar que `ProcessingMetadata` esté presente (si existe en MongoDB)
- [ ] Verificar que `Glossary` y `ReflectionQuestions` estén presentes

**Salida esperada:** Sistema funcional y validado

---

## 📚 FASE 9: ACTUALIZACIÓN DE DIAGRAMAS

### 9.1 Revisar Diagramas de Arquitectura
- [ ] Abrir `/docs/diagramas/arquitectura/01_arquitectura_general.md`
- [ ] Verificar que refleje estructura actual de carpetas
- [ ] Actualizar si es necesario (paths, referencias)

### 9.2 Revisar Diagramas de Base de Datos
- [ ] Abrir `/docs/diagramas/base_datos/02_colecciones_mongodb.md`
- [ ] Confirmar que ya incluye todos los campos implementados
- [ ] NO requiere cambios (ya está actualizado)

### 9.3 Revisar Diagramas de Procesos
- [ ] Verificar `/docs/diagramas/procesos/02_consumo_material.md`
- [ ] Actualizar si menciona estructura simple de respuestas
- [ ] Agregar ejemplos de respuestas completas si es útil

### 9.4 Crear Diagrama de Flujo de Datos (opcional)
- [ ] Crear `/docs/diagramas/arquitectura/04_flujo_datos_completo.md`
- [ ] Documentar flujo de datos desde MongoDB hasta respuesta API
- [ ] Mostrar transformaciones: MongoDocument → Response Model

**Salida esperada:** Diagramas actualizados y consistentes

---

## 📄 FASE 10: DOCUMENTACIÓN FINAL

### 10.1 Actualizar README Principal
- [ ] Crear o actualizar `/README.md` en raíz
- [ ] Documentar estructura de carpetas final
- [ ] Agregar sección "Inicio Rápido":
  - [ ] Requisitos previos
  - [ ] Instalación de dependencias
  - [ ] Ejecución de scripts DB
  - [ ] Levantar APIs
- [ ] Agregar sección "Arquitectura":
  - [ ] Link a diagramas
  - [ ] Descripción breve de componentes
- [ ] Agregar sección "Endpoints":
  - [ ] Link a Swagger UIs
  - [ ] Puertos de cada API

### 10.2 Crear Changelog
- [ ] Crear `/CHANGELOG.md`
- [ ] Documentar cambios de esta refactorización:
  - [ ] Reestructuración de carpetas
  - [ ] Implementación de esquemas MongoDB completos
  - [ ] Nuevos endpoints agregados
  - [ ] Modelos actualizados
  - [ ] Breaking changes (si los hay)


### 10.3 Crear Guía de Desarrollo
- [ ] Crear `/docs/DEVELOPMENT.md`
- [ ] Documentar:
  - [ ] Cómo agregar nuevos endpoints
  - [ ] Cómo regenerar Swagger
  - [ ] Cómo ejecutar tests
  - [ ] Convenciones de código

**Salida esperada:** Documentación completa y profesional

---

## 🧹 FASE 11: LIMPIEZA Y VALIDACIÓN FINAL

### 11.1 Eliminar Archivos Obsoletos
- [ ] Buscar archivos `.DS_Store`: `find . -name ".DS_Store" -delete`
- [ ] Buscar carpetas vacías: `find . -type d -empty`
- [ ] Eliminar carpetas vacías si es seguro
- [ ] Verificar que no queden carpetas `AnalisisFinal/` nested

### 11.2 Validar Estructura Final
- [ ] Ejecutar `tree -L 3` y verificar estructura limpia
- [ ] Confirmar que `/docs/` esté en raíz
- [ ] Confirmar que `/source/` tenga solo 4 subcarpetas (api-mobile, api-administracion, worker, scripts)
- [ ] Verificar que no haya duplicados de scripts

### 11.3 Ejecutar Linters y Formatters
- [ ] Ejecutar `gofmt` en todo el proyecto:
  ```bash
  cd /source/api-mobile && gofmt -w .
  cd /source/api-administracion && gofmt -w .
  cd /source/worker && gofmt -w .
  ```
- [ ] Ejecutar `go vet`:
  ```bash
  cd /source/api-mobile && go vet ./...
  cd /source/api-administracion && go vet ./...
  ```
- [ ] (Opcional) Ejecutar `golangci-lint` si está instalado

### 11.4 Verificar Dependencias
- [ ] Ejecutar `go mod tidy` en cada proyecto:
  ```bash
  cd /source/api-mobile && go mod tidy
  cd /source/api-administracion && go mod tidy
  cd /source/worker && go mod tidy
  ```
- [ ] Verificar que `go.sum` esté actualizado

**Salida esperada:** Proyecto limpio y sin archivos basura

---

## 🎯 FASE 12: COMMIT FINAL

### 12.1 Preparar Commit
- [ ] Verificar estado: `git status`
- [ ] Revisar cambios: `git diff` (archivos modificados)
- [ ] Revisar archivos nuevos: `git status` (untracked)
- [ ] Crear lista mental de cambios a commitear

### 12.2 Staging de Archivos

#### 12.2.1 Documentación
- [ ] `git add docs/`
- [ ] `git add README.md`
- [ ] `git add CHANGELOG.md`

#### 12.2.2 Scripts
- [ ] `git add source/scripts/`

#### 12.2.3 API Mobile
- [ ] `git add source/api-mobile/internal/models/`
- [ ] `git add source/api-mobile/internal/handlers/`
- [ ] `git add source/api-mobile/internal/router/`
- [ ] `git add source/api-mobile/docs/` (swagger)
- [ ] `git add source/api-mobile/go.mod`
- [ ] `git add source/api-mobile/go.sum`

#### 12.2.4 API Administración
- [ ] `git add source/api-administracion/internal/models/`
- [ ] `git add source/api-administracion/internal/handlers/`
- [ ] `git add source/api-administracion/internal/router/`
- [ ] `git add source/api-administracion/docs/` (swagger)
- [ ] `git add source/api-administracion/go.mod`
- [ ] `git add source/api-administracion/go.sum`

#### 12.2.5 Worker (si hubo cambios)
- [ ] `git add source/worker/` (si se modificó)

### 12.3 Crear Commit
- [ ] Crear commit con mensaje descriptivo:
  ```bash
  git commit -m "$(cat <<'EOF'
  feat: implementar esquemas MongoDB completos y reestructurar proyecto

  BREAKING CHANGES:
  - Reestructurar carpetas: eliminar nested AnalisisFinal/
  - Actualizar respuesta de GET /materials/{id}/summary (objeto completo vs string)
  - Actualizar respuesta de GET /materials/{id}/assessment (campos adicionales)
  - Actualizar respuesta de POST /materials/{id}/assessment/attempts (feedback detallado)

  Nuevas funcionalidades:
  - Implementar glosario en resúmenes
  - Implementar preguntas reflexivas
  - Implementar feedback personalizado en quizzes
  - Implementar metadata de procesamiento
  - Agregar endpoint POST /v1/guardian-relations (Post-MVP)
  - Agregar endpoint PATCH /v1/subjects/:id (Post-MVP)

  Mejoras técnicas:
  - Modelos Go completos para MongoDB
  - Handlers con lógica real (eliminar mocks)
  - Swagger autogenerado con nuevos modelos
  - Scripts MongoDB con validación completa
  - Documentación completa en /docs/

  Documentación:
  - Marcar endpoints Post-MVP en DISTRIBUCION_PROCESOS.md
  - Agregar CHANGELOG.md
  - Actualizar README.md
  - Crear MIGRATION_FROM_SIMPLE.md
  - Crear DEVELOPMENT.md

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

### 12.4 Verificar Commit
- [ ] Verificar que commit se creó: `git log -1`
- [ ] Verificar archivos incluidos: `git show --name-only`
- [ ] Confirmar que mensaje es correcto: `git log -1 --pretty=format:"%B"`

### 12.5 Push (OPCIONAL - Solo si usuario lo aprueba)
- [ ] Preguntar al usuario si desea push
- [ ] Si aprobado: `git push origin main`
- [ ] Verificar en GitHub/GitLab que cambios estén presentes

**Salida esperada:** Commit completo y bien documentado

---

## ✅ FASE 13: VALIDACIÓN POST-REFACTORIZACIÓN

### 13.1 Checklist Final de Calidad
- [ ] ✅ Estructura de carpetas plana (sin nested AnalisisFinal/)
- [ ] ✅ Scripts MongoDB versión completa (341 líneas)
- [ ] ✅ Scripts PostgreSQL intactos
- [ ] ✅ Modelos Go con todos los campos documentados
- [ ] ✅ Swagger actualizado en ambas APIs
- [ ] ✅ Documentación en `/docs/` completa
- [ ] ✅ README.md actualizado
- [ ] ✅ CHANGELOG.md creado
- [ ] ✅ Tests básicos pasando
- [ ] ✅ Commit creado con mensaje descriptivo

### 13.2 Verificación de Endpoints
- [ ] API Mobile (8080):
  - [ ] ✅ POST /v1/auth/login
  - [ ] ✅ GET /v1/materials
  - [ ] ✅ GET /v1/materials/{id}
  - [ ] ✅ POST /v1/materials
  - [ ] ✅ GET /v1/materials/{id}/summary (respuesta completa)
  - [ ] ✅ GET /v1/materials/{id}/assessment (respuesta completa)
  - [ ] ✅ POST /v1/materials/{id}/assessment/attempts (feedback detallado)
  - [ ] ✅ PATCH /v1/materials/{id}/progress
  - [ ] ✅ GET /v1/materials/{id}/stats
- [ ] API Admin (8081):
  - [ ] ✅ POST /v1/users
  - [ ] ✅ PATCH /v1/users/{id}
  - [ ] ✅ DELETE /v1/users/{id}
  - [ ] ✅ POST /v1/schools
  - [ ] ✅ POST /v1/units
  - [ ] ✅ PATCH /v1/units/{id}
  - [ ] ✅ POST /v1/units/{id}/members
  - [ ] ✅ POST /v1/subjects
  - [ ] ✅ PATCH /v1/subjects/{id} (NUEVO)
  - [ ] ✅ POST /v1/guardian-relations (NUEVO)
  - [ ] ✅ DELETE /v1/materials/{id}
  - [ ] ✅ GET /v1/stats/global

### 13.3 Verificación de Consistencia
- [ ] ✅ Swagger refleja implementación real
- [ ] ✅ Diagramas consistentes con código
- [ ] ✅ Scripts DB ejecutables sin errores
- [ ] ✅ Documentación alineada con funcionalidad


**Salida esperada:** Proyecto completamente refactorizado y validado

---

## 📊 RESUMEN DE FASES

| Fase | Nombre | Tareas | Duración Estimada |
|------|--------|--------|-------------------|
| 1 | Preparación y Auditoría | 5 | 30 min |
| 2 | Reestructuración de Carpetas | 12 | 1-2 horas |
| 3 | Correcciones Documentales | 7 | 30 min |
| 4 | Actualización Scripts DB | 15 | 1 hora |
| 5 | Actualización Modelos Go | 25 | 3-4 horas |
| 6 | Implementación Handlers | 15 | 4-6 horas |
| 7 | Regeneración Swagger | 15 | 1 hora |
| 8 | Testing y Validación | 20 | 2-3 horas |
| 9 | Actualización Diagramas | 8 | 1 hora |
| 10 | Documentación Final | 12 | 2 horas |
| 11 | Limpieza y Validación | 12 | 1 hora |
| 12 | Commit Final | 15 | 30 min |
| 13 | Validación Post-Refactorización | 10 | 1 hora |
| **TOTAL** | **13 fases** | **171 tareas** | **18-24 horas** |

---

## 🚀 PRÓXIMOS PASOS DESPUÉS DE REFACTORIZACIÓN

1. **Implementar Worker Real** (actualmente es esqueleto)
   - Integrar con RabbitMQ
   - Implementar procesamiento con OpenAI
   - Agregar reintentos y manejo de errores

2. **Implementar Autenticación Real**
   - JWT con refresh tokens
   - Password hashing con bcrypt
   - Middleware de autorización por roles

3. **Agregar Tests Comprehensivos**
   - Tests de integración completos
   - Tests E2E
   - Coverage > 80%

4. **CI/CD**
   - GitHub Actions / GitLab CI
   - Linting automático
   - Tests automáticos
   - Deploy automático

5. **Monitoreo y Logging**
   - Integrar Prometheus
   - Grafana dashboards
   - Structured logging

---

**¡Este plan está listo para ejecutarse!** 🎉

Cada casilla representa un paso verificable. Marca cada checkbox a medida que avances. La estructura está diseñada para minimizar errores y asegurar que no se omita ningún paso crítico.
