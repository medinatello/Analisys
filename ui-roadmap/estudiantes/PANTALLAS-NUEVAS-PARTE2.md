# Pantallas Nuevas - Parte 2: Evaluaciones y Contexto

**Fecha de Creación:** 1 de Diciembre, 2025  
**Ubicación del Código:** `/Users/jhoanmedina/source/EduGo/EduUI/apple-app`  
**Paquete Principal:** `Packages/EduGoFeatures/Sources/EduGoFeatures/`  
**Backend:** edugo-api-mobile (puerto 8080)

---

## 📋 Resumen Ejecutivo

Este documento especifica **4 pantallas nuevas** para el flujo de evaluaciones y gestión de contexto escolar en la app Apple de EduGo.

| Pantalla | Propósito | Prioridad | Estado |
|----------|-----------|-----------|--------|
| **QuizView** | Tomar evaluación/quiz de un material | 🔴 Alta | ⬜ Pendiente |
| **QuizResultView** | Ver resultados con feedback detallado | 🔴 Alta | ⬜ Pendiente |
| **AttemptHistoryView** | Historial completo de intentos | 🟡 Media | ⬜ Pendiente |
| **SchoolSelectorView** | Selector de escuela/contexto activo | 🟡 Media | ⬜ Pendiente |

### Contexto del Proyecto

**Sistema de Evaluaciones:** EduGo genera automáticamente quizzes a partir de materiales educativos usando IA (OpenAI). Los estudiantes pueden:
1. Ver el quiz generado (sin respuestas correctas)
2. Enviar sus respuestas
3. Ver resultados con feedback inmediato
4. Consultar historial de intentos previos

**Sistema Multi-Escuela:** Los usuarios pueden tener múltiples roles en diferentes escuelas (estudiante en escuela A, profesor en escuela B). Necesitan poder cambiar el contexto activo.

---

## 1️⃣ QuizView - Tomar Evaluación

### Descripción

Pantalla para tomar un quiz/evaluación de un material educativo. Muestra preguntas de opción múltiple generadas por IA con interfaz intuitiva y validación en tiempo real.

**Flujo de navegación:**
```
MaterialDetailView → [Tap "Tomar Quiz"] → QuizView
```

### Endpoint(s) a Consumir

#### GET /v1/materials/:id/assessment

**Request:**
```http
GET /v1/materials/{material_id}/assessment
Authorization: Bearer {token}
```

**Response exitoso (200):**
```json
{
  "assessment_id": "uuid",
  "material_id": "uuid",
  "material_title": "Introducción a Swift",
  "questions": [
    {
      "question_id": "uuid",
      "question_text": "¿Qué es un Optional en Swift?",
      "question_type": "multiple_choice",
      "options": [
        {
          "option_id": "uuid",
          "option_text": "Un tipo que puede contener un valor o nil"
        },
        {
          "option_id": "uuid",
          "option_text": "Una función opcional"
        },
        {
          "option_id": "uuid",
          "option_text": "Un protocolo especial"
        },
        {
          "option_id": "uuid",
          "option_text": "Un operador de Swift"
        }
      ]
    }
  ],
  "total_questions": 10,
  "time_limit_minutes": 30,
  "passing_score": 70.0,
  "generated_at": "2025-12-01T10:30:00Z"
}
```

**Response error (404):**
```json
{
  "error": "assessment_not_found",
  "message": "No existe evaluación para este material"
}
```

**Nota:** El endpoint NO devuelve las respuestas correctas. Solo las preguntas y opciones.

#### POST /v1/materials/:id/assessment/attempts

**Request:**
```http
POST /v1/materials/{material_id}/assessment/attempts
Authorization: Bearer {token}
Content-Type: application/json

{
  "assessment_id": "uuid",
  "answers": [
    {
      "question_id": "uuid",
      "selected_option_id": "uuid"
    },
    {
      "question_id": "uuid",
      "selected_option_id": "uuid"
    }
  ],
  "started_at": "2025-12-01T10:35:00Z",
  "completed_at": "2025-12-01T10:55:00Z"
}
```

**Response exitoso (201):**
```json
{
  "attempt_id": "uuid",
  "status": "completed",
  "score": 85.0,
  "passed": true,
  "total_questions": 10,
  "correct_answers": 8,
  "incorrect_answers": 2,
  "time_spent_minutes": 20,
  "created_at": "2025-12-01T10:55:00Z"
}
```

**Response error (400):**
```json
{
  "error": "invalid_answers",
  "message": "Faltan respuestas o IDs inválidos",
  "details": {
    "missing_questions": ["uuid1", "uuid2"]
  }
}
```

---

### Layout por Plataforma

#### iPhone (Compact Width)

```
┌─────────────────────────────────────┐
│ ← Quiz: Introducción a Swift        │ Navigation Bar
├─────────────────────────────────────┤
│ Progreso: 3/10 [======>   ] 30%     │ Progress Header
│ Tiempo: ⏱️ 15:30 restantes          │
├─────────────────────────────────────┤
│                                     │
│ ScrollView (Vertical):              │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Pregunta 3 de 10                │ │
│ │                                 │ │
│ │ ¿Qué es un Optional en Swift?   │ │ Question Card
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ○ Un tipo que puede contener... │ │ Option Button
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ○ Una función opcional          │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ● Un protocolo especial         │ │ Selected Option
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ○ Un operador de Swift          │ │
│ └─────────────────────────────────┘ │
│                                     │
│                                     │
│ [← Anterior]      [Siguiente →]    │ Navigation Buttons
│                                     │
│                   [Finalizar Quiz]  │ Submit Button
└─────────────────────────────────────┘
```

**Características:**
- Touch targets de 44pt mínimo en opciones
- Scroll suave entre preguntas
- Botón "Finalizar" solo visible en última pregunta
- Confirmación antes de enviar respuestas

#### iPad (Regular Width + Regular Height)

```
┌─────────────────────────────────────────────────────────────┐
│ ← Quiz: Introducción a Swift                     ⏱️ 15:30    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────┬─────────────────────────────────┐ │
│ │ Sidebar:            │ Main Content:                   │ │
│ │                     │                                 │ │
│ │ Preguntas:          │ ┌─────────────────────────────┐ │ │
│ │                     │ │ Pregunta 3 de 10            │ │ │
│ │ ✅ 1. Pregunta 1    │ │                             │ │ │
│ │ ✅ 2. Pregunta 2    │ │ ¿Qué es un Optional en...?  │ │ │
│ │ 📝 3. Pregunta 3    │ │                             │ │ │
│ │ ⚪ 4. Pregunta 4    │ │                             │ │ │
│ │ ⚪ 5. Pregunta 5    │ └─────────────────────────────┘ │ │
│ │ ⚪ 6. Pregunta 6    │                                 │ │
│ │ ⚪ 7. Pregunta 7    │ Opciones:                       │ │
│ │ ⚪ 8. Pregunta 8    │                                 │ │
│ │ ⚪ 9. Pregunta 9    │ Grid 2 columnas:                │ │
│ │ ⚪ 10. Pregunta 10  │ ┌──────────┐ ┌──────────┐      │ │
│ │                     │ │ ○ Opción │ │ ○ Opción │      │ │
│ │                     │ │   A      │ │   B      │      │ │
│ │                     │ └──────────┘ └──────────┘      │ │
│ │ Progreso: 30%       │ ┌──────────┐ ┌──────────┐      │ │
│ │ [======>   ]        │ │ ● Opción │ │ ○ Opción │      │ │
│ │                     │ │   C      │ │   D      │      │ │
│ │                     │ └──────────┘ └──────────┘      │ │
│ │                     │                                 │ │
│ │                     │ [← Anterior]     [Siguiente →]  │ │
│ │                     │                                 │ │
│ │ [Finalizar Quiz]    │                                 │ │
│ └─────────────────────┴─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Características:**
- Sidebar con mini-mapa de preguntas
- Tap en pregunta del sidebar → saltar a esa pregunta
- Grid 2x2 para opciones (mejor aprovechamiento)
- Indicadores visuales: ✅ respondida, 📝 actual, ⚪ pendiente
- Hover effects en opciones

#### Mac (macOS)

```
┌─────────────────────────────────────────────────────────────┐
│ File  Edit  View  Quiz                          ⏱️ 15:30    │ Menu Bar
├─────────────────────────────────────────────────────────────┤
│ ← Quiz: Introducción a Swift      [⌘K Shortcuts]           │ Toolbar
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ [Mismo layout que iPad]                                     │
│                                                             │
│ + Keyboard shortcuts:                                       │
│   - ⌘1-4: Seleccionar opción A-D                           │
│   - ⌘→: Siguiente pregunta                                 │
│   - ⌘←: Pregunta anterior                                  │
│   - ⌘↩︎: Finalizar quiz                                     │
│   - ⌘K: Mostrar shortcuts                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Características adicionales:**
- Menu bar con opciones de quiz
- Keyboard navigation completa
- Context menu en opciones (click derecho)
- Toolbar con acciones rápidas

---

### Componentes UI (Design System)

#### Componentes Existentes a Usar

```swift
// Navegación
NavigationBar con DSButton para back

// Cards
DSCard(.prominent) para pregunta
DSCard(.regular) para opciones

// Botones
DSButton(.primary) para "Finalizar"
DSButton(.secondary) para navegación
DSButton(.tertiary) para opciones no seleccionadas

// Tipografía y Colores
DSTypography.body para pregunta
DSTypography.headline para número de pregunta
DSColors.primary para opción seleccionada
DSColors.surface para opciones no seleccionadas

// Efectos
.dsGlassEffect() en cards
.dsShadow() en opciones seleccionadas
```

#### Componentes NUEVOS a Crear

**1. DSQuestionCard**

```swift
public struct DSQuestionCard: View {
    let questionNumber: Int
    let totalQuestions: Int
    let questionText: String
    let style: DSCard.Style = .prominent
    
    public var body: some View {
        DSCard(style: style) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Pregunta \(questionNumber) de \(totalQuestions)")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                
                Text(questionText)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DSSpacing.md)
        }
    }
}
```

**2. DSQuizOptionButton**

```swift
public struct DSQuizOptionButton: View {
    let optionLetter: String  // A, B, C, D
    let optionText: String
    let isSelected: Bool
    let onTap: () -> Void
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.sm) {
                // Radio button
                Image(systemName: isSelected ? "circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? DSColors.primary : DSColors.textSecondary)
                
                // Option letter badge
                Text(optionLetter)
                    .font(DSTypography.caption.bold())
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(isSelected ? DSColors.primary : DSColors.surface)
                    .clipShape(Circle())
                
                // Option text
                Text(optionText)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSCornerRadius.medium)
                    .fill(isSelected ? DSColors.primary.opacity(0.1) : DSColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSCornerRadius.medium)
                    .stroke(isSelected ? DSColors.primary : Color.clear, lineWidth: 2)
            )
            .dsShadow(isSelected ? .medium : .subtle)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(optionLetter). \(optionText)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
```

**3. DSQuizProgressHeader**

```swift
public struct DSQuizProgressHeader: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let timeRemaining: TimeInterval?  // nil = sin límite
    
    private var progress: Double {
        Double(currentQuestion) / Double(totalQuestions)
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.xs) {
            HStack {
                Text("Progreso: \(currentQuestion)/\(totalQuestions)")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                
                Spacer()
                
                if let remaining = timeRemaining {
                    Label(formatTime(remaining), systemImage: "timer")
                        .font(DSTypography.caption)
                        .foregroundColor(remaining < 300 ? .red : DSColors.textSecondary) // Rojo si < 5min
                }
            }
            
            ProgressView(value: progress)
                .tint(DSColors.primary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(DSColors.background)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
```

**4. DSQuestionNavigator (Sidebar para iPad)**

```swift
public struct DSQuestionNavigator: View {
    let questions: [QuestionStatus]
    let currentQuestionIndex: Int
    let onSelectQuestion: (Int) -> Void
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Preguntas")
                .font(DSTypography.headline)
                .padding(.bottom, DSSpacing.xs)
            
            ScrollView {
                VStack(spacing: DSSpacing.xs) {
                    ForEach(questions.indices, id: \.self) { index in
                        Button(action: { onSelectQuestion(index) }) {
                            HStack {
                                // Status icon
                                Image(systemName: questions[index].icon)
                                    .foregroundColor(questions[index].color)
                                
                                Text("\(index + 1). \(questions[index].shortText)")
                                    .font(DSTypography.body)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            .padding(.vertical, DSSpacing.xs)
                            .padding(.horizontal, DSSpacing.sm)
                            .background(
                                index == currentQuestionIndex
                                    ? DSColors.primary.opacity(0.1)
                                    : Color.clear
                            )
                            .cornerRadius(DSCornerRadius.small)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            Spacer()
            
            // Progress summary
            DSCard(.subtle) {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Progreso")
                        .font(DSTypography.caption.bold())
                    
                    let answered = questions.filter { $0.isAnswered }.count
                    ProgressView(value: Double(answered) / Double(questions.count))
                        .tint(DSColors.primary)
                    
                    Text("\(answered)/\(questions.count) respondidas")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
                .padding(DSSpacing.sm)
            }
        }
        .frame(width: 250)
        .padding(DSSpacing.md)
    }
}

public struct QuestionStatus {
    let shortText: String
    let isAnswered: Bool
    let isCurrent: Bool
    
    var icon: String {
        if isAnswered { return "checkmark.circle.fill" }
        if isCurrent { return "pencil.circle.fill" }
        return "circle"
    }
    
    var color: Color {
        if isAnswered { return .green }
        if isCurrent { return DSColors.primary }
        return DSColors.textSecondary
    }
}
```

---

### Estados

#### 1. Loading (Cargando Quiz)

```swift
struct QuizView: View {
    @State private var state: LoadingState = .loading
    
    var body: some View {
        switch state {
        case .loading:
            VStack(spacing: DSSpacing.md) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Cargando evaluación...")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColors.background)
        
        case .loaded(let quiz):
            quizContent(quiz)
        
        case .error(let message):
            errorView(message)
        }
    }
}
```

#### 2. Loaded (Quiz Cargado)

Estado principal con preguntas y opciones interactivas.

#### 3. Submitting (Enviando Respuestas)

```swift
.overlay {
    if isSubmitting {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: DSSpacing.md) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Enviando respuestas...")
                    .font(DSTypography.body)
                    .foregroundColor(.white)
            }
            .padding(DSSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DSCornerRadius.medium)
                    .fill(DSColors.surface)
                    .dsGlassEffect()
            )
        }
    }
}
```

#### 4. Error (Error al Cargar)

```swift
DSEmptyState(
    icon: "exclamationmark.triangle",
    title: "Error al cargar quiz",
    message: errorMessage,
    actionTitle: "Reintentar",
    action: { loadQuiz() },
    style: .error
)
```

#### 5. Time Warning (Advertencia de Tiempo)

Cuando quedan menos de 5 minutos, cambiar color del timer a rojo y mostrar alerta cada minuto.

```swift
.alert("⏱️ Tiempo limitado", isPresented: $showTimeWarning) {
    Button("Continuar", role: .cancel) { }
} message: {
    Text("Te quedan \(minutesRemaining) minutos para completar el quiz")
}
```

---

### Interacciones

#### Gestos Principales

**iPhone:**
- ✅ **Tap en opción:** Seleccionar respuesta
- ✅ **Swipe left:** Siguiente pregunta (si ya respondió)
- ✅ **Swipe right:** Pregunta anterior
- ✅ **Pull-to-refresh:** NO (podría borrar respuestas)
- ✅ **Tap en "Finalizar":** Mostrar confirmación

**iPad:**
- ✅ Todo lo de iPhone +
- ✅ **Tap en sidebar:** Navegar a pregunta específica
- ✅ **Hover en opción:** Highlight sutil
- ✅ **Keyboard 1-4:** Seleccionar opciones A-D

**macOS:**
- ✅ Todo lo de iPad +
- ✅ **⌘→ / ⌘←:** Navegación con teclado
- ✅ **⌘1-4:** Seleccionar opciones
- ✅ **⌘↩︎:** Finalizar quiz
- ✅ **⌘K:** Ver shortcuts disponibles

#### Navegación

```swift
// Navegación entre preguntas
func goToNextQuestion() {
    guard currentQuestionIndex < questions.count - 1 else { return }
    
    withAnimation(.spring(response: 0.3)) {
        currentQuestionIndex += 1
    }
    
    // Scroll to top
    scrollViewProxy?.scrollTo("question-top", anchor: .top)
}

func goToPreviousQuestion() {
    guard currentQuestionIndex > 0 else { return }
    
    withAnimation(.spring(response: 0.3)) {
        currentQuestionIndex -= 1
    }
}

// Finalizar quiz
func finishQuiz() {
    // Validar que todas las preguntas estén respondidas
    let unanswered = answers.filter { $0.value == nil }
    
    if !unanswered.isEmpty {
        showIncompleteAlert = true
        return
    }
    
    // Confirmar envío
    showSubmitConfirmation = true
}
```

#### Confirmación de Envío

```swift
.alert("¿Finalizar quiz?", isPresented: $showSubmitConfirmation) {
    Button("Cancelar", role: .cancel) { }
    Button("Enviar respuestas", role: .destructive) {
        submitAnswers()
    }
} message: {
    Text("Has respondido \(answers.count)/\(questions.count) preguntas. No podrás cambiar tus respuestas después de enviar.")
}
```

#### Advertencia de Preguntas Sin Responder

```swift
.alert("Preguntas sin responder", isPresented: $showIncompleteAlert) {
    Button("Revisar", role: .cancel) { }
    Button("Enviar de todas formas") {
        submitAnswers()
    }
} message: {
    let unanswered = answers.filter { $0.value == nil }.count
    Text("Hay \(unanswered) preguntas sin responder. ¿Deseas enviar el quiz de todas formas?")
}
```

---

### Validaciones

#### Validación de Carga

```swift
func loadQuiz() async {
    state = .loading
    
    do {
        let quiz = try await assessmentRepository.getAssessment(materialId: materialId)
        
        // Validar que tenga preguntas
        guard !quiz.questions.isEmpty else {
            state = .error("El quiz no contiene preguntas")
            return
        }
        
        // Validar que cada pregunta tenga opciones
        for question in quiz.questions {
            guard question.options.count >= 2 else {
                state = .error("Pregunta con opciones insuficientes")
                return
            }
        }
        
        state = .loaded(quiz)
        startTimer(timeLimit: quiz.timeLimitMinutes)
        
    } catch {
        state = .error(error.localizedDescription)
    }
}
```

#### Validación de Envío

```swift
func submitAnswers() async {
    isSubmitting = true
    
    // Preparar respuestas
    let attemptAnswers = answers.compactMap { questionId, optionId -> AttemptAnswer? in
        guard let optionId = optionId else { return nil }
        return AttemptAnswer(questionId: questionId, selectedOptionId: optionId)
    }
    
    // Validar IDs
    guard attemptAnswers.allSatisfy({ validateUUID($0.questionId) && validateUUID($0.selectedOptionId) }) else {
        showError("Respuestas inválidas")
        isSubmitting = false
        return
    }
    
    let request = CreateAttemptRequest(
        assessmentId: quiz.assessmentId,
        answers: attemptAnswers,
        startedAt: quizStartedAt,
        completedAt: Date()
    )
    
    do {
        let result = try await assessmentRepository.submitAttempt(
            materialId: materialId,
            request: request
        )
        
        isSubmitting = false
        
        // Navegar a resultados
        coordinator.navigate(to: .quizResult(attemptId: result.attemptId))
        
    } catch {
        isSubmitting = false
        showError("Error al enviar respuestas: \(error.localizedDescription)")
    }
}

private func validateUUID(_ string: String) -> Bool {
    UUID(uuidString: string) != nil
}
```

#### Validación de Tiempo

```swift
func startTimer(timeLimit: Int?) {
    guard let limit = timeLimit else { return }
    
    timeRemaining = TimeInterval(limit * 60)
    
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        guard timeRemaining > 0 else {
            timer.invalidate()
            autoSubmitDueToTimeout()
            return
        }
        
        timeRemaining -= 1
        
        // Alertas de tiempo
        if timeRemaining == 300 { // 5 minutos
            showTimeWarning = true
        }
        if timeRemaining == 60 { // 1 minuto
            showTimeWarning = true
        }
    }
}

func autoSubmitDueToTimeout() {
    showAlert(
        title: "Tiempo agotado",
        message: "El tiempo del quiz ha terminado. Tus respuestas se enviarán automáticamente."
    )
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        submitAnswers()
    }
}
```

---

### Lógica Semi-Dummy (si aplica)

**NO APLICA** - Esta pantalla debe ser completamente funcional ya que:
1. Los endpoints están disponibles
2. Es funcionalidad core del MVP
3. No tiene dependencias externas complejas

---

## 2️⃣ QuizResultView - Ver Resultados con Feedback

### Descripción

Pantalla que muestra los resultados de un intento de quiz con feedback detallado, puntaje, respuestas correctas/incorrectas y retroalimentación por pregunta.

**Flujo de navegación:**
```
QuizView → [Submit Answers] → QuizResultView
MaterialDetailView → [Ver último resultado] → QuizResultView
AttemptHistoryView → [Tap en intento] → QuizResultView
```

### Endpoint(s) a Consumir

#### GET /v1/attempts/:id/results

**Request:**
```http
GET /v1/attempts/{attempt_id}/results
Authorization: Bearer {token}
```

**Response exitoso (200):**
```json
{
  "attempt_id": "uuid",
  "material_id": "uuid",
  "material_title": "Introducción a Swift",
  "user_id": "uuid",
  "score": 85.0,
  "passed": true,
  "total_questions": 10,
  "correct_answers": 8,
  "incorrect_answers": 2,
  "skipped_answers": 0,
  "time_spent_minutes": 20,
  "passing_score": 70.0,
  "created_at": "2025-12-01T10:55:00Z",
  "detailed_results": [
    {
      "question_id": "uuid",
      "question_text": "¿Qué es un Optional en Swift?",
      "selected_option_id": "uuid",
      "selected_option_text": "Un tipo que puede contener un valor o nil",
      "correct_option_id": "uuid",
      "correct_option_text": "Un tipo que puede contener un valor o nil",
      "is_correct": true,
      "feedback": "¡Correcto! Los Optionals son un feature fundamental de Swift que permite manejar la ausencia de valores de forma segura."
    },
    {
      "question_id": "uuid",
      "question_text": "¿Cuál es la diferencia entre let y var?",
      "selected_option_id": "uuid",
      "selected_option_text": "No hay diferencia",
      "correct_option_id": "uuid",
      "correct_option_text": "let es para constantes, var para variables",
      "is_correct": false,
      "feedback": "Incorrecto. 'let' se usa para declarar constantes (valores inmutables) mientras que 'var' se usa para variables (valores mutables)."
    }
  ]
}
```

**Response error (404):**
```json
{
  "error": "attempt_not_found",
  "message": "El intento no existe o no pertenece al usuario"
}
```

---

### Layout por Plataforma

#### iPhone (Compact Width)

```
┌─────────────────────────────────────┐
│ ✕ Resultados del Quiz               │ Navigation Bar
├─────────────────────────────────────┤
│                                     │
│ ScrollView (Vertical):              │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │        🎉 ¡Aprobado!            │ │ Result Header
│ │                                 │ │
│ │         85%                     │ │ Big Score
│ │                                 │ │
│ │    ━━━━━━━━━━━━━━━━━━━━        │ │ Score Bar
│ │                                 │ │
│ │  Nota de aprobación: 70%        │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Estadísticas                    │ │
│ │                                 │ │
│ │ ✅ Correctas: 8                 │ │ Stats Card
│ │ ❌ Incorrectas: 2               │ │
│ │ ⏱️ Tiempo: 20 min               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Revisión Detallada:                 │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ✅ Pregunta 1                   │ │
│ │ ¿Qué es un Optional...?         │ │ Correct Answer
│ │                                 │ │
│ │ Tu respuesta: ✓                 │ │
│ │ Un tipo que puede contener...   │ │
│ │                                 │ │
│ │ 💡 ¡Correcto! Los Optionals...  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ❌ Pregunta 2                   │ │
│ │ ¿Cuál es la diferencia...?      │ │ Wrong Answer
│ │                                 │ │
│ │ Tu respuesta: ✗                 │ │
│ │ No hay diferencia               │ │
│ │                                 │ │
│ │ Respuesta correcta:             │ │
│ │ let es para constantes...       │ │
│ │                                 │ │
│ │ 💡 Incorrecto. 'let' se usa...  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ... (más preguntas)                 │
│                                     │
│ [Reintentar Quiz]                   │ Action Buttons
│ [Volver al Material]                │
│                                     │
└─────────────────────────────────────┘
```

**Características:**
- Header grande con score prominente
- Color verde para aprobado, rojo para reprobado
- Cards por pregunta con feedback expandible
- Scroll suave con animaciones

#### iPad (Regular Width + Regular Height)

```
┌─────────────────────────────────────────────────────────────┐
│ ✕ Resultados: Introducción a Swift                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────┬─────────────────────────────────┐ │
│ │ Summary (Left):     │ Details (Right):                │ │
│ │                     │                                 │ │
│ │  🎉 ¡Aprobado!      │ Revisión Detallada:             │ │
│ │                     │                                 │ │
│ │      85%            │ ┌─────────────────────────────┐ │ │
│ │  ━━━━━━━━━━━━━━    │ │ ✅ Pregunta 1               │ │ │
│ │                     │ │ ¿Qué es un Optional...?     │ │ │
│ │  Puntaje: 70%       │ │                             │ │ │
│ │                     │ │ Tu respuesta: ✓             │ │ │
│ │ ┌─────────────────┐ │ │ Un tipo que puede...        │ │ │
│ │ │ Estadísticas:   │ │ │                             │ │ │
│ │ │                 │ │ │ 💡 Feedback...              │ │ │
│ │ │ ✅ Correctas: 8 │ │ └─────────────────────────────┘ │ │
│ │ │ ❌ Incorrectas:2│ │                                 │ │
│ │ │ ⏱️ Tiempo: 20min│ │ ┌─────────────────────────────┐ │ │
│ │ │ 📅 Fecha:       │ │ │ ❌ Pregunta 2               │ │ │
│ │ │ 01/12/2025      │ │ │ ...                         │ │ │
│ │ └─────────────────┘ │ └─────────────────────────────┘ │ │
│ │                     │                                 │ │
│ │ Distribución:       │ ... (scroll para más)           │ │
│ │ [Gráfica Pie]       │                                 │ │
│ │ 80% ✅              │                                 │ │
│ │ 20% ❌              │                                 │ │
│ │                     │                                 │ │
│ │ [Reintentar]        │                                 │ │
│ │ [Volver]            │                                 │ │
│ └─────────────────────┴─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Características:**
- Sidebar fijo con resumen y stats
- Gráfica de distribución de respuestas
- Scroll independiente en panel de detalles
- Hover en pregunta → highlight

#### Mac (macOS)

```
┌─────────────────────────────────────────────────────────────┐
│ File  Edit  View  Results                                   │ Menu Bar
├─────────────────────────────────────────────────────────────┤
│ ✕ Resultados: Introducción a Swift       [⌘P Print]        │ Toolbar
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ [Mismo layout que iPad]                                     │
│                                                             │
│ + Opciones adicionales:                                     │
│   - ⌘P: Imprimir resultados                                │
│   - ⌘S: Guardar PDF                                        │
│   - ⌘R: Reintentar quiz                                    │
│   - Menu: Export → PDF/CSV                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Características adicionales:**
- Menu bar con opciones de exportación
- Toolbar con acciones rápidas
- Keyboard shortcuts
- Print dialog nativo

---

### Componentes UI (Design System)

#### Componentes Existentes a Usar

```swift
DSCard(.prominent) para header de resultado
DSCard(.regular) para stats y preguntas
DSButton(.primary) para "Reintentar"
DSButton(.secondary) para "Volver"
DSColors, DSTypography, DSSpacing
.dsGlassEffect()
```

#### Componentes NUEVOS a Crear

**1. DSResultHeader**

```swift
public struct DSResultHeader: View {
    let score: Double
    let passed: Bool
    let passingScore: Double
    
    private var emoji: String {
        if score >= 90 { return "🎉" }
        if score >= 80 { return "😊" }
        if score >= passingScore { return "✅" }
        return "😞"
    }
    
    private var statusText: String {
        passed ? "¡Aprobado!" : "No aprobado"
    }
    
    private var statusColor: Color {
        passed ? .green : .red
    }
    
    public var body: some View {
        DSCard(.prominent) {
            VStack(spacing: DSSpacing.md) {
                // Emoji
                Text(emoji)
                    .font(.system(size: 60))
                
                // Status
                Text(statusText)
                    .font(DSTypography.title.bold())
                    .foregroundColor(statusColor)
                
                // Score
                Text("\(Int(score))%")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(DSColors.textPrimary)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DSColors.surface)
                            .frame(height: 8)
                        
                        // Filled portion
                        RoundedRectangle(cornerRadius: 4)
                            .fill(statusColor)
                            .frame(width: geometry.size.width * (score / 100), height: 8)
                        
                        // Passing threshold marker
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.orange)
                            .frame(width: 4, height: 16)
                            .offset(x: geometry.size.width * (passingScore / 100) - 2)
                    }
                }
                .frame(height: 16)
                .padding(.horizontal, DSSpacing.lg)
                
                // Passing score label
                Text("Nota de aprobación: \(Int(passingScore))%")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
            }
            .padding(DSSpacing.lg)
        }
    }
}
```

**2. DSStatsCard**

```swift
public struct DSStatsCard: View {
    let correctCount: Int
    let incorrectCount: Int
    let skippedCount: Int
    let timeSpent: Int  // minutos
    let createdAt: Date
    
    public var body: some View {
        DSCard(.regular) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Estadísticas")
                    .font(DSTypography.headline)
                    .padding(.bottom, DSSpacing.xs)
                
                statRow(icon: "checkmark.circle.fill", color: .green, label: "Correctas", value: "\(correctCount)")
                statRow(icon: "xmark.circle.fill", color: .red, label: "Incorrectas", value: "\(incorrectCount)")
                
                if skippedCount > 0 {
                    statRow(icon: "minus.circle.fill", color: .orange, label: "Omitidas", value: "\(skippedCount)")
                }
                
                Divider()
                    .padding(.vertical, DSSpacing.xs)
                
                statRow(icon: "clock.fill", color: .blue, label: "Tiempo", value: "\(timeSpent) min")
                statRow(icon: "calendar", color: .purple, label: "Fecha", value: formatDate(createdAt))
            }
            .padding(DSSpacing.md)
        }
    }
    
    private func statRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(DSTypography.body.bold())
                .foregroundColor(DSColors.textPrimary)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
```

**3. DSQuestionResultCard**

```swift
public struct DSQuestionResultCard: View {
    let questionNumber: Int
    let questionText: String
    let selectedOptionText: String
    let correctOptionText: String
    let isCorrect: Bool
    let feedback: String
    @State private var isExpanded: Bool = false
    
    public var body: some View {
        DSCard(.regular) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                // Header
                HStack {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                        .font(.title2)
                    
                    Text("Pregunta \(questionNumber)")
                        .font(DSTypography.headline)
                        .foregroundColor(isCorrect ? .green : .red)
                    
                    Spacer()
                    
                    Button(action: { withAnimation { isExpanded.toggle() } }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
                
                // Question text
                Text(questionText)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                
                if isExpanded {
                    Divider()
                        .padding(.vertical, DSSpacing.xs)
                    
                    // Your answer
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        HStack {
                            Text("Tu respuesta:")
                                .font(DSTypography.caption.bold())
                                .foregroundColor(DSColors.textSecondary)
                            
                            Image(systemName: isCorrect ? "checkmark" : "xmark")
                                .foregroundColor(isCorrect ? .green : .red)
                        }
                        
                        Text(selectedOptionText)
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textPrimary)
                            .padding(DSSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: DSCornerRadius.small)
                                    .fill(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            )
                    }
                    
                    // Correct answer (if wrong)
                    if !isCorrect {
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("Respuesta correcta:")
                                .font(DSTypography.caption.bold())
                                .foregroundColor(DSColors.textSecondary)
                            
                            Text(correctOptionText)
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textPrimary)
                                .padding(DSSpacing.sm)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: DSCornerRadius.small)
                                        .fill(Color.green.opacity(0.1))
                                )
                        }
                    }
                    
                    // Feedback
                    HStack(alignment: .top, spacing: DSSpacing.xs) {
                        Text("💡")
                        Text(feedback)
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(DSSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: DSCornerRadius.small)
                            .fill(DSColors.surface)
                    )
                }
            }
            .padding(DSSpacing.md)
        }
    }
}
```

**4. DSScoreDistributionChart (usando Swift Charts)**

```swift
import Charts

public struct DSScoreDistributionChart: View {
    let correctCount: Int
    let incorrectCount: Int
    let skippedCount: Int
    
    private var chartData: [ScoreData] {
        [
            ScoreData(category: "Correctas", count: correctCount, color: .green),
            ScoreData(category: "Incorrectas", count: incorrectCount, color: .red),
            ScoreData(category: "Omitidas", count: skippedCount, color: .orange)
        ].filter { $0.count > 0 }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Distribución")
                .font(DSTypography.headline)
            
            Chart(chartData) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .annotation(position: .overlay) {
                    Text("\(item.count)")
                        .font(DSTypography.body.bold())
                        .foregroundColor(.white)
                }
            }
            .frame(height: 200)
            
            // Legend
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                ForEach(chartData) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)
                        
                        Text("\(item.category): \(item.count)")
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
            }
        }
        .padding(DSSpacing.md)
    }
}

private struct ScoreData: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
    let color: Color
}
```

---

### Estados

#### 1. Loading

```swift
ProgressView()
    .scaleEffect(1.5)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
```

#### 2. Loaded

Estado principal con todos los resultados visibles.

#### 3. Error

```swift
DSEmptyState(
    icon: "exclamationmark.triangle",
    title: "Error al cargar resultados",
    message: errorMessage,
    actionTitle: "Reintentar",
    action: { loadResults() },
    style: .error
)
```

---

### Interacciones

#### Gestos

**iPhone:**
- ✅ **Tap en pregunta:** Expandir/colapsar feedback
- ✅ **Swipe en pregunta:** NO (evitar acciones accidentales)
- ✅ **Tap en "Reintentar":** Navegar a nuevo quiz
- ✅ **Tap en "Volver":** Navegar a material

**iPad/macOS:**
- ✅ Todo lo de iPhone +
- ✅ **Hover en pregunta:** Highlight sutil
- ✅ **Cmd+P (macOS):** Imprimir resultados
- ✅ **Cmd+S (macOS):** Guardar como PDF

#### Navegación

```swift
// Reintentar quiz
func retryQuiz() {
    coordinator.navigate(to: .quiz(materialId: materialId))
}

// Volver al material
func backToMaterial() {
    coordinator.navigate(to: .materialDetail(id: materialId))
}

// Compartir resultados (iOS)
func shareResults() {
    let text = "Obtuve \(score)% en el quiz '\(materialTitle)'"
    let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    // Present activity VC
}
```

#### Animaciones

```swift
// Entrada animada del header
.onAppear {
    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
        showHeader = true
    }
}

// Expansión de preguntas
withAnimation(.easeInOut(duration: 0.3)) {
    isExpanded.toggle()
}

// Confetti si puntaje > 90%
if score >= 90 {
    ConfettiView()
        .onAppear { playConfetti() }
}
```

---

### Validaciones

```swift
func loadResults(attemptId: String) async {
    state = .loading
    
    do {
        let results = try await assessmentRepository.getAttemptResults(attemptId: attemptId)
        
        // Validar datos
        guard results.score >= 0 && results.score <= 100 else {
            state = .error("Puntaje inválido")
            return
        }
        
        guard !results.detailedResults.isEmpty else {
            state = .error("No hay detalles de resultados")
            return
        }
        
        state = .loaded(results)
        
    } catch {
        state = .error(error.localizedDescription)
    }
}
```

---

### Lógica Semi-Dummy (si aplica)

**NO APLICA** - Esta pantalla debe ser completamente funcional.

---

## 3️⃣ AttemptHistoryView - Historial de Intentos

### Descripción

Pantalla que muestra el historial completo de todos los intentos de quizzes del estudiante, con filtros, búsqueda y estadísticas agregadas.

**Flujo de navegación:**
```
HomeView → [Tab "Historial"] → AttemptHistoryView
ProfileView → [Ver intentos] → AttemptHistoryView
```

### Endpoint(s) a Consumir

#### GET /v1/users/me/attempts

**Request:**
```http
GET /v1/users/me/attempts?page=1&limit=20&material_id={optional}
Authorization: Bearer {token}
```

**Query params:**
- `page` (opcional): Número de página (default: 1)
- `limit` (opcional): Items por página (default: 20, max: 100)
- `material_id` (opcional): Filtrar por material específico

**Response exitoso (200):**
```json
{
  "attempts": [
    {
      "attempt_id": "uuid",
      "material_id": "uuid",
      "material_title": "Introducción a Swift",
      "score": 85.0,
      "passed": true,
      "total_questions": 10,
      "correct_answers": 8,
      "time_spent_minutes": 20,
      "created_at": "2025-12-01T10:55:00Z"
    },
    {
      "attempt_id": "uuid",
      "material_id": "uuid",
      "material_title": "SwiftUI Basics",
      "score": 60.0,
      "passed": false,
      "total_questions": 8,
      "correct_answers": 5,
      "time_spent_minutes": 15,
      "created_at": "2025-11-28T14:30:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 3,
    "total_items": 45,
    "items_per_page": 20,
    "has_next": true,
    "has_previous": false
  },
  "summary": {
    "total_attempts": 45,
    "average_score": 78.5,
    "passed_count": 35,
    "failed_count": 10,
    "total_time_minutes": 900
  }
}
```

**Response empty (200):**
```json
{
  "attempts": [],
  "pagination": {
    "current_page": 1,
    "total_pages": 0,
    "total_items": 0,
    "items_per_page": 20,
    "has_next": false,
    "has_previous": false
  },
  "summary": {
    "total_attempts": 0,
    "average_score": 0,
    "passed_count": 0,
    "failed_count": 0,
    "total_time_minutes": 0
  }
}
```

---

### Layout por Plataforma

#### iPhone (Compact Width)

```
┌─────────────────────────────────────┐
│ ← Historial de Intentos             │ Navigation Bar
├─────────────────────────────────────┤
│ [🔍 Buscar material...]             │ Search Bar
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Resumen                         │ │
│ │                                 │ │ Summary Card
│ │ 📊 Promedio: 78.5%              │ │
│ │ ✅ Aprobados: 35/45             │ │
│ │ ⏱️ Tiempo total: 900 min         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Filtros:                            │
│ [Todos] [Aprobados] [Reprobados]    │ Filter Chips
│                                     │
│ ScrollView (Vertical):              │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ✅ Introducción a Swift         │ │
│ │ 85% • 8/10                      │ │ Attempt Row
│ │ 01 Dic 2025 • 20 min            │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ❌ SwiftUI Basics               │ │
│ │ 60% • 5/8                       │ │ Failed Attempt
│ │ 28 Nov 2025 • 15 min            │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ✅ iOS Architecture             │ │
│ │ 92% • 10/11                     │ │
│ │ 25 Nov 2025 • 25 min            │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ... (infinite scroll)               │
│                                     │
│ [Cargar más]                        │ Load More Button
└─────────────────────────────────────┘
```

**Características:**
- Pull-to-refresh
- Infinite scroll con paginación
- Filtros rápidos con chips
- Búsqueda en tiempo real
- Touch targets 44pt

#### iPad (Regular Width + Regular Height)

```
┌─────────────────────────────────────────────────────────────┐
│ ← Historial de Intentos                          [Filter ▼] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────┬─────────────────────────────────┐ │
│ │ Sidebar:            │ Main List:                      │ │
│ │                     │                                 │ │
│ │ Resumen             │ [🔍 Buscar...]                  │ │
│ │ ┌─────────────────┐ │                                 │ │
│ │ │ 📊 Promedio     │ │ Table (3 columnas):             │ │
│ │ │    78.5%        │ │                                 │ │
│ │ │                 │ │ Material | Score | Fecha        │ │
│ │ │ ✅ Aprobados    │ │ ────────────────────────────    │ │
│ │ │    35/45 (78%) │ │ ✅ Swift      85%  01/12/25     │ │
│ │ │                 │ │ ❌ SwiftUI    60%  28/11/25     │ │
│ │ │ ⏱️ Total        │ │ ✅ iOS Arch   92%  25/11/25     │ │
│ │ │    900 min      │ │ ✅ Combine    88%  20/11/25     │ │
│ │ └─────────────────┘ │ ❌ Testing    55%  15/11/25     │ │
│ │                     │ ...                             │ │
│ │ Gráfica             │                                 │ │
│ │ [Line Chart]        │ [Pagination: 1 2 3 ... 10 →]    │ │
│ │ Progreso últimos    │                                 │ │
│ │ 30 días             │                                 │ │
│ │                     │                                 │ │
│ │ Filtros:            │                                 │ │
│ │ ○ Todos             │                                 │ │
│ │ ● Aprobados         │                                 │ │
│ │ ○ Reprobados        │                                 │ │
│ │                     │                                 │ │
│ │ Rango de fechas:    │                                 │ │
│ │ [Último mes ▼]      │                                 │ │
│ └─────────────────────┴─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Características:**
- Sidebar con resumen y filtros avanzados
- Vista de tabla con múltiples columnas
- Gráfica de progreso en el tiempo
- Paginación estándar
- Hover effects en filas

#### Mac (macOS)

```
┌─────────────────────────────────────────────────────────────┐
│ File  Edit  View  History                                   │ Menu Bar
├─────────────────────────────────────────────────────────────┤
│ ← Historial       [🔍]  [Filter]  [Export ▼]               │ Toolbar
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ [Mismo layout que iPad]                                     │
│                                                             │
│ + Opciones adicionales:                                     │
│   - ⌘F: Focus en búsqueda                                  │
│   - ⌘E: Export to CSV                                      │
│   - ⌘1/2/3: Cambiar filtro                                 │
│   - Menu: Export → CSV/PDF                                 │
│   - Click en columna → Ordenar                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Características adicionales:**
- Menu bar con opciones de exportación
- Toolbar con acciones rápidas
- Keyboard shortcuts completos
- Sort por columna (click en header)

---

### Componentes UI (Design System)

#### Componentes Existentes

```swift
DSCard, DSButton, DSEmptyState
DSSearchBar (a crear)
DSColors, DSTypography, DSSpacing
```

#### Componentes NUEVOS a Crear

**1. DSAttemptRow**

```swift
public struct DSAttemptRow: View {
    let attempt: AttemptSummary
    let onTap: () -> Void
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.md) {
                // Status icon
                Image(systemName: attempt.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(attempt.passed ? .green : .red)
                
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    // Material title
                    Text(attempt.materialTitle)
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textPrimary)
                        .lineLimit(1)
                    
                    // Score and stats
                    Text("\(Int(attempt.score))% • \(attempt.correctAnswers)/\(attempt.totalQuestions)")
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                    
                    // Date and time
                    HStack(spacing: DSSpacing.xs) {
                        Text(formatDate(attempt.createdAt))
                        Text("•")
                        Text("\(attempt.timeSpentMinutes) min")
                    }
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textTertiary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(DSColors.textTertiary)
            }
            .padding(DSSpacing.md)
            .background(DSColors.surface)
            .cornerRadius(DSCornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
```

**2. DSHistorySummaryCard**

```swift
public struct DSHistorySummaryCard: View {
    let summary: AttemptsSummary
    
    public var body: some View {
        DSCard(.prominent) {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("Resumen")
                    .font(DSTypography.headline)
                
                // Average score
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                    Text("Promedio:")
                        .foregroundColor(DSColors.textSecondary)
                    Spacer()
                    Text("\(String(format: "%.1f", summary.averageScore))%")
                        .font(DSTypography.body.bold())
                }
                
                // Pass rate
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Aprobados:")
                        .foregroundColor(DSColors.textSecondary)
                    Spacer()
                    Text("\(summary.passedCount)/\(summary.totalAttempts)")
                        .font(DSTypography.body.bold())
                    Text("(\(passRate)%)")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
                
                // Total time
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                    Text("Tiempo total:")
                        .foregroundColor(DSColors.textSecondary)
                    Spacer()
                    Text("\(summary.totalTimeMinutes) min")
                        .font(DSTypography.body.bold())
                }
            }
            .padding(DSSpacing.md)
        }
    }
    
    private var passRate: Int {
        guard summary.totalAttempts > 0 else { return 0 }
        return Int((Double(summary.passedCount) / Double(summary.totalAttempts)) * 100)
    }
}
```

**3. DSFilterChip (Reutilizable)**

```swift
public struct DSFilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int?
    let onTap: () -> Void
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.xs) {
                Text(title)
                    .font(DSTypography.caption.bold())
                
                if let count = count {
                    Text("(\(count))")
                        .font(DSTypography.caption)
                }
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(
                Capsule()
                    .fill(isSelected ? DSColors.primary : DSColors.surface)
            )
            .foregroundColor(isSelected ? .white : DSColors.textPrimary)
            .overlay(
                Capsule()
                    .stroke(DSColors.primary, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

**4. DSProgressChart (usando Swift Charts)**

```swift
import Charts

public struct DSProgressChart: View {
    let dataPoints: [ProgressDataPoint]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Progreso últimos 30 días")
                .font(DSTypography.headline)
            
            Chart(dataPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .foregroundStyle(DSColors.primary)
                .symbol(Circle())
                
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [DSColors.primary.opacity(0.3), DSColors.primary.opacity(0.0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 25, 50, 75, 100])
            }
        }
        .padding(DSSpacing.md)
    }
}

public struct ProgressDataPoint: Identifiable {
    public let id = UUID()
    public let date: Date
    public let score: Double
}
```

---

### Estados

#### 1. Loading

```swift
ProgressView("Cargando historial...")
```

#### 2. Loaded (Con datos)

Estado principal con lista de intentos.

#### 3. Empty (Sin intentos)

```swift
DSEmptyState(
    icon: "doc.text.magnifyingglass",
    title: "Sin intentos",
    message: "Aún no has realizado ningún quiz. ¡Comienza explorando materiales!",
    actionTitle: "Explorar materiales",
    action: { navigateToMaterials() },
    style: .informational
)
```

#### 4. Error

```swift
DSEmptyState(
    icon: "exclamationmark.triangle",
    title: "Error al cargar historial",
    message: errorMessage,
    actionTitle: "Reintentar",
    action: { loadHistory() },
    style: .error
)
```

#### 5. Loading More (Paginación)

```swift
if isLoadingMore {
    HStack {
        Spacer()
        ProgressView()
        Spacer()
    }
    .padding()
}
```

---

### Interacciones

#### Gestos

**iPhone:**
- ✅ **Pull-to-refresh:** Recargar historial
- ✅ **Infinite scroll:** Cargar más al llegar al final
- ✅ **Tap en intento:** Navegar a resultados detallados
- ✅ **Swipe en intento:** Opciones (compartir, eliminar)
- ✅ **Tap en filtro:** Aplicar filtro

**iPad/macOS:**
- ✅ Todo lo de iPhone +
- ✅ **Hover en fila:** Highlight
- ✅ **Click en columna header:** Ordenar
- ✅ **Cmd+F (macOS):** Focus en búsqueda
- ✅ **Cmd+E (macOS):** Exportar

#### Búsqueda y Filtros

```swift
// Búsqueda con debounce
.searchable(text: $searchText, prompt: "Buscar material...")
.onChange(of: searchText) { newValue in
    searchDebounceTask?.cancel()
    searchDebounceTask = Task {
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
        await filterAttempts(query: newValue)
    }
}

// Filtros
enum AttemptsFilter {
    case all
    case passed
    case failed
}

func applyFilter(_ filter: AttemptsFilter) {
    selectedFilter = filter
    
    switch filter {
    case .all:
        filteredAttempts = allAttempts
    case .passed:
        filteredAttempts = allAttempts.filter { $0.passed }
    case .failed:
        filteredAttempts = allAttempts.filter { !$0.passed }
    }
}
```

#### Paginación

```swift
func loadMore() async {
    guard !isLoadingMore, hasNextPage else { return }
    
    isLoadingMore = true
    currentPage += 1
    
    do {
        let response = try await assessmentRepository.getUserAttemptHistory(
            page: currentPage,
            limit: 20
        )
        
        attempts.append(contentsOf: response.attempts)
        hasNextPage = response.pagination.hasNext
        
    } catch {
        currentPage -= 1  // Revertir
        showError(error.localizedDescription)
    }
    
    isLoadingMore = false
}

// Detectar scroll al final
ScrollView {
    LazyVStack {
        ForEach(attempts) { attempt in
            DSAttemptRow(attempt: attempt) {
                navigateToResults(attempt.attemptId)
            }
            .onAppear {
                // Si es el penúltimo elemento, cargar más
                if attempt.id == attempts[attempts.count - 2].id {
                    Task { await loadMore() }
                }
            }
        }
    }
}
```

---

### Validaciones

```swift
func loadHistory() async {
    state = .loading
    
    do {
        let response = try await assessmentRepository.getUserAttemptHistory(page: 1, limit: 20)
        
        // Validar paginación
        guard response.pagination.currentPage > 0 else {
            state = .error("Paginación inválida")
            return
        }
        
        // Si está vacío, mostrar empty state
        if response.attempts.isEmpty {
            state = .empty
            return
        }
        
        state = .loaded(response)
        
    } catch {
        state = .error(error.localizedDescription)
    }
}
```

---

### Lógica Semi-Dummy (si aplica)

**NO APLICA** - Esta pantalla debe ser completamente funcional.

---

## 4️⃣ SchoolSelectorView - Selector de Escuela/Contexto Activo

### Descripción

Pantalla o modal que permite al usuario cambiar su contexto escolar activo cuando tiene múltiples roles en diferentes escuelas. Es crítica para sistemas multi-tenant donde un usuario puede ser estudiante en una escuela y profesor en otra.

**Flujo de navegación:**
```
HomeView → [Tap en nombre de escuela] → SchoolSelectorView
SettingsView → [Cambiar escuela] → SchoolSelectorView
App Launch → [Si tiene múltiples escuelas] → SchoolSelectorView (obligatorio)
```

### Endpoint(s) a Consumir

#### ⚠️ ENDPOINTS PENDIENTES DE IMPLEMENTACIÓN

Los siguientes endpoints **NO EXISTEN** actualmente en edugo-api-mobile y necesitan ser implementados:

**REQUERIDO:**
```
GET  /v1/users/me/schools         # Listar escuelas del usuario con roles
POST /v1/users/me/active-school   # Cambiar escuela activa
GET  /v1/users/me/active-school   # Obtener escuela activa actual
```

#### Especificación Propuesta de Endpoints

**GET /v1/users/me/schools**

**Request:**
```http
GET /v1/users/me/schools
Authorization: Bearer {token}
```

**Response esperado (200):**
```json
{
  "schools": [
    {
      "school_id": "uuid",
      "school_name": "Colegio San José",
      "school_logo_url": "https://...",
      "roles": [
        {
          "role": "student",
          "academic_unit_id": "uuid",
          "academic_unit_name": "3ro de Secundaria",
          "is_active": true
        }
      ]
    },
    {
      "school_id": "uuid",
      "school_name": "Instituto Tecnológico",
      "school_logo_url": "https://...",
      "roles": [
        {
          "role": "teacher",
          "academic_unit_id": "uuid",
          "academic_unit_name": "Departamento de Matemáticas",
          "is_active": false
        },
        {
          "role": "coordinator",
          "academic_unit_id": null,
          "academic_unit_name": null,
          "is_active": false
        }
      ]
    }
  ],
  "active_school_id": "uuid",
  "active_role": "student"
}
```

**POST /v1/users/me/active-school**

**Request:**
```http
POST /v1/users/me/active-school
Authorization: Bearer {token}
Content-Type: application/json

{
  "school_id": "uuid",
  "role": "teacher",  // Opcional si solo tiene un rol en esa escuela
  "academic_unit_id": "uuid"  // Opcional
}
```

**Response (200):**
```json
{
  "active_school_id": "uuid",
  "active_school_name": "Instituto Tecnológico",
  "active_role": "teacher",
  "active_academic_unit_id": "uuid",
  "active_academic_unit_name": "Departamento de Matemáticas",
  "changed_at": "2025-12-01T11:00:00Z"
}
```

**GET /v1/users/me/active-school**

**Request:**
```http
GET /v1/users/me/active-school
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "active_school_id": "uuid",
  "active_school_name": "Colegio San José",
  "active_role": "student",
  "active_academic_unit_id": "uuid",
  "active_academic_unit_name": "3ro de Secundaria"
}
```

#### Implementación Backend Necesaria

**Tabla de Contexto (a crear):**

```sql
-- migrations/xxx_create_user_context.up.sql
CREATE TABLE IF NOT EXISTS user_active_context (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    active_school_id UUID NOT NULL REFERENCES schools(id),
    active_role VARCHAR(50) NOT NULL,
    active_academic_unit_id UUID REFERENCES academic_units(id),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_context_school ON user_active_context(active_school_id);
```

**Handlers Go (a crear):**

```go
// internal/infrastructure/http/handler/context_handler.go
type ContextHandler struct {
    getUserSchoolsUseCase domain.GetUserSchoolsUseCase
    setActiveSchoolUseCase domain.SetActiveSchoolUseCase
    logger logging.Logger
}

func (h *ContextHandler) GetUserSchools(c *gin.Context) {
    userID := c.GetString("user_id")
    
    schools, err := h.getUserSchoolsUseCase.Execute(userID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusOK, schools)
}

func (h *ContextHandler) SetActiveSchool(c *gin.Context) {
    userID := c.GetString("user_id")
    
    var req SetActiveSchoolRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
        return
    }
    
    result, err := h.setActiveSchoolUseCase.Execute(userID, req.SchoolID, req.Role)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    
    c.JSON(http.StatusOK, result)
}
```

**Rutas (a agregar en router.go):**

```go
// Rutas de contexto de usuario
users.GET("/me/schools", c.Handlers.ContextHandler.GetUserSchools)
users.GET("/me/active-school", c.Handlers.ContextHandler.GetActiveSchool)
users.POST("/me/active-school", c.Handlers.ContextHandler.SetActiveSchool)
```

---

### Layout por Plataforma

#### iPhone (Compact Width)

**Presentación:** Sheet modal (`.presentationDetents([.medium, .large])`)

```
┌─────────────────────────────────────┐
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │ Drag indicator
│                                     │
│ Cambiar Escuela                     │ Title
│                                     │
│ Selecciona tu escuela y rol activo: │ Subtitle
│                                     │
│ ScrollView (Vertical):              │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🏫 Colegio San José             │ │
│ │                                 │ │ School Card
│ │ ✓ Estudiante                    │ │ (Active)
│ │   3ro de Secundaria             │ │
│ │                                 │ │
│ │ Activo actualmente              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🏫 Instituto Tecnológico        │ │
│ │                                 │ │ School Card
│ │ ○ Profesor                      │ │ (Inactive)
│ │   Depto. de Matemáticas         │ │
│ │                                 │ │
│ │ ○ Coordinador                   │ │
│ │   (Toda la escuela)             │ │
│ │                                 │ │
│ │ [Cambiar a esta escuela]        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🏫 Escuela Primaria ABC         │ │
│ │                                 │ │
│ │ ○ Tutor/Guardian                │ │
│ │   Hijo: Juan Pérez (2do grado) │ │
│ │                                 │ │
│ │ [Cambiar a esta escuela]        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Cancelar]                          │ Cancel Button
└─────────────────────────────────────┘
```

**Características:**
- Sheet modal con drag to dismiss
- Scroll si hay muchas escuelas
- Indicador visual de escuela activa
- Botón de cambio solo en inactivas
- Confirmación si cambia contexto

#### iPad (Regular Width + Regular Height)

**Presentación:** Popover desde el botón de escuela actual

```
┌─────────────────────────────────────┐
│ Cambiar Escuela                     │ Popover Title
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ✓ 🏫 Colegio San José           │ │
│ │   Estudiante • 3ro Secundaria   │ │ Active (checkmark)
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │   🏫 Instituto Tecnológico      │ │
│ │   Profesor • Matemáticas        │ │ Inactive
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │   🏫 Instituto Tecnológico      │ │
│ │   Coordinador                   │ │ Same school, different role
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │   🏫 Escuela ABC                │ │
│ │   Guardian • Hijo: Juan         │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

**Características:**
- Popover compacto (300x400pt aprox)
- Lista simple con checkmark en activo
- Tap en cualquier fila → cambiar contexto
- Auto-dismiss después de cambio
- Hover effects

#### Mac (macOS)

**Presentación:** Popover desde menu bar o botón de escuela

```
┌─────────────────────────────────────┐
│ Escuelas                        ✕   │ Popover with close
├─────────────────────────────────────┤
│                                     │
│ Activo:                             │
│ ┌─────────────────────────────────┐ │
│ │ ✓ 🏫 Colegio San José           │ │
│ │   Estudiante • 3ro Secundaria   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Otras escuelas:                     │
│ ┌─────────────────────────────────┐ │
│ │   🏫 Instituto Tecnológico      │ │
│ │   Profesor • Matemáticas        │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │   🏫 Instituto Tecnológico      │ │
│ │   Coordinador                   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Keyboard: ⌘1-9 para cambiar        │ Hint
└─────────────────────────────────────┘
```

**Características adicionales:**
- Keyboard shortcuts ⌘1-9
- Menú contextual (click derecho)
- Animación de transición
- Status bar icon indica escuela activa

---

### Componentes UI (Design System)

#### Componentes Existentes

```swift
DSCard, DSButton, DSEmptyState
DSColors, DSTypography, DSSpacing
```

#### Componentes NUEVOS a Crear

**1. DSSchoolCard**

```swift
public struct DSSchoolCard: View {
    let school: SchoolContext
    let isActive: Bool
    let onSelect: () -> Void
    
    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack {
                    // School logo or icon
                    if let logoURL = school.logoURL {
                        AsyncImage(url: logoURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "building.2.fill")
                                .font(.title)
                        }
                        .frame(width: 40, height: 40)
                        .cornerRadius(DSCornerRadius.small)
                    } else {
                        Image(systemName: "building.2.fill")
                            .font(.title)
                            .foregroundColor(DSColors.primary)
                            .frame(width: 40, height: 40)
                    }
                    
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(school.schoolName)
                            .font(DSTypography.headline)
                            .foregroundColor(DSColors.textPrimary)
                        
                        if isActive {
                            Text("Activo actualmente")
                                .font(DSTypography.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    if isActive {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
                
                Divider()
                
                // Roles in this school
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    ForEach(school.roles, id: \.role) { roleInfo in
                        HStack {
                            Image(systemName: roleInfo.isActive ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(roleInfo.isActive ? .green : DSColors.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(roleInfo.role.displayName)
                                    .font(DSTypography.body)
                                    .foregroundColor(DSColors.textPrimary)
                                
                                if let unitName = roleInfo.academicUnitName {
                                    Text(unitName)
                                        .font(DSTypography.caption)
                                        .foregroundColor(DSColors.textSecondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                if !isActive {
                    DSButton("Cambiar a esta escuela", style: .secondary) {
                        onSelect()
                    }
                    .padding(.top, DSSpacing.xs)
                }
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSCornerRadius.medium)
                    .fill(isActive ? DSColors.primary.opacity(0.1) : DSColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSCornerRadius.medium)
                    .stroke(isActive ? DSColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension UserRole {
    var displayName: String {
        switch self {
        case .student: return "Estudiante"
        case .teacher: return "Profesor"
        case .guardian: return "Tutor/Guardian"
        case .coordinator: return "Coordinador"
        case .admin: return "Administrador"
        case .assistant: return "Asistente"
        }
    }
}
```

**2. DSSchoolSelectorRow (versión compacta para iPad/Mac)**

```swift
public struct DSSchoolSelectorRow: View {
    let school: SchoolContext
    let role: RoleInfo
    let isActive: Bool
    let onSelect: () -> Void
    
    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: DSSpacing.sm) {
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(DSColors.textSecondary)
                }
                
                Image(systemName: "building.2.fill")
                    .foregroundColor(DSColors.textSecondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(school.schoolName)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text(role.role.displayName)
                            .font(DSTypography.caption)
                        
                        if let unitName = role.academicUnitName {
                            Text("•")
                            Text(unitName)
                                .font(DSTypography.caption)
                        }
                    }
                    .foregroundColor(DSColors.textSecondary)
                }
                
                Spacer()
            }
            .padding(.vertical, DSSpacing.xs)
            .padding(.horizontal, DSSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(isActive ? DSColors.primary.opacity(0.1) : Color.clear)
    }
}
```

---

### Estados

#### 1. Loading

```swift
ProgressView("Cargando escuelas...")
```

#### 2. Loaded (Con escuelas)

Estado principal con lista de escuelas.

#### 3. Single School (Solo una escuela)

Si el usuario solo tiene una escuela, NO mostrar selector. Auto-seleccionar.

```swift
// En App launch
if schools.count == 1 {
    setActiveSchool(schools[0].schoolID, role: schools[0].roles[0].role)
    // No mostrar selector
}
```

#### 4. Empty (Sin escuelas)

```swift
DSEmptyState(
    icon: "building.2",
    title: "Sin escuelas asignadas",
    message: "Contacta al administrador para que te asigne a una escuela",
    style: .warning
)
```

#### 5. Switching (Cambiando contexto)

```swift
.overlay {
    if isSwitching {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: DSSpacing.md) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Cambiando contexto...")
                    .font(DSTypography.body)
                    .foregroundColor(.white)
            }
            .padding(DSSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DSCornerRadius.medium)
                    .fill(DSColors.surface)
                    .dsGlassEffect()
            )
        }
    }
}
```

#### 6. Error

```swift
.alert("Error", isPresented: $showError) {
    Button("OK", role: .cancel) { }
} message: {
    Text(errorMessage)
}
```

---

### Interacciones

#### Presentación

**iPhone:**
```swift
.sheet(isPresented: $showSchoolSelector) {
    SchoolSelectorView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
```

**iPad:**
```swift
.popover(isPresented: $showSchoolSelector, arrowEdge: .bottom) {
    SchoolSelectorView()
        .frame(width: 300, height: 400)
}
```

**macOS:**
```swift
.popover(isPresented: $showSchoolSelector) {
    SchoolSelectorView()
        .frame(width: 320, height: 450)
}
```

#### Cambio de Contexto

```swift
func switchSchool(to schoolID: String, role: UserRole, unitID: String?) async {
    isSwitching = true
    
    do {
        let result = try await contextRepository.setActiveSchool(
            schoolID: schoolID,
            role: role,
            academicUnitID: unitID
        )
        
        // Actualizar estado global
        await AppState.shared.updateActiveSchool(result)
        
        // Recargar datos de la app
        await reloadAppData()
        
        // Cerrar selector
        showSchoolSelector = false
        
        // Mostrar confirmación
        showToast("Contexto cambiado a \(result.activeSchoolName)")
        
    } catch {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    isSwitching = false
}

func reloadAppData() async {
    // Recargar:
    // - Cursos/materiales
    // - Progreso
    // - Estadísticas
    // - etc.
    
    await homeViewModel.loadData()
    await progressViewModel.loadData()
    // ...
}
```

#### Confirmación de Cambio

```swift
.alert("¿Cambiar de escuela?", isPresented: $showSwitchConfirmation) {
    Button("Cancelar", role: .cancel) { }
    Button("Cambiar") {
        Task {
            await switchSchool(
                to: selectedSchool.schoolID,
                role: selectedRole,
                unitID: selectedUnitID
            )
        }
    }
} message: {
    Text("Cambiarás tu contexto a '\(selectedSchool.schoolName)' como '\(selectedRole.displayName)'. Tus datos actuales se guardarán.")
}
```

---

### Validaciones

```swift
func loadSchools() async {
    state = .loading
    
    do {
        let response = try await contextRepository.getUserSchools()
        
        // Validar que tenga al menos una escuela
        guard !response.schools.isEmpty else {
            state = .empty
            return
        }
        
        // Si solo tiene una escuela con un rol, auto-seleccionar
        if response.schools.count == 1 && response.schools[0].roles.count == 1 {
            let school = response.schools[0]
            let role = school.roles[0]
            
            await switchSchool(
                to: school.schoolID,
                role: role.role,
                unitID: role.academicUnitID
            )
            
            // No mostrar selector
            return
        }
        
        state = .loaded(response)
        
    } catch {
        state = .error(error.localizedDescription)
    }
}

func validateSchoolSelection(schoolID: String, role: UserRole) -> Bool {
    // Validar que la escuela existe
    guard let school = schools.first(where: { $0.schoolID == schoolID }) else {
        return false
    }
    
    // Validar que el usuario tiene ese rol en esa escuela
    guard school.roles.contains(where: { $0.role == role }) else {
        return false
    }
    
    return true
}
```

---

### Lógica Semi-Dummy (si aplica)

#### ⚠️ IMPLEMENTACIÓN TEMPORAL

Dado que los endpoints **NO EXISTEN** actualmente, se puede implementar una versión semi-dummy con datos locales:

**1. Mock Repository (temporal):**

```swift
public final class MockContextRepository: ContextRepositoryProtocol {
    public func getUserSchools() async -> Result<UserSchoolsResponse, DomainError> {
        // Simular delay de red
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Datos hardcodeados desde UserDefaults o keychain
        let mockSchools = UserSchoolsResponse(
            schools: [
                SchoolContext(
                    schoolID: "school-1",
                    schoolName: "Colegio San José",
                    logoURL: nil,
                    roles: [
                        RoleInfo(
                            role: .student,
                            academicUnitID: "unit-1",
                            academicUnitName: "3ro de Secundaria",
                            isActive: true
                        )
                    ]
                )
            ],
            activeSchoolID: "school-1",
            activeRole: .student
        )
        
        return .success(mockSchools)
    }
    
    public func setActiveSchool(schoolID: String, role: UserRole, academicUnitID: String?) async -> Result<ActiveSchoolResult, DomainError> {
        // Guardar en UserDefaults (temporal)
        UserDefaults.standard.set(schoolID, forKey: "active_school_id")
        UserDefaults.standard.set(role.rawValue, forKey: "active_role")
        
        let result = ActiveSchoolResult(
            activeSchoolID: schoolID,
            activeSchoolName: "Mock School",
            activeRole: role,
            activeAcademicUnitID: academicUnitID,
            activeAcademicUnitName: "Mock Unit",
            changedAt: Date()
        )
        
        return .success(result)
    }
}
```

**2. Feature Flag:**

```swift
// AppConfig.swift
struct AppConfig {
    static let useRealSchoolContext = false  // Cambiar a true cuando backend esté listo
    
    static func contextRepository() -> ContextRepositoryProtocol {
        if useRealSchoolContext {
            return RealContextRepository()
        } else {
            return MockContextRepository()
        }
    }
}
```

**3. Documentación del Mock:**

Agregar comentario en código:

```swift
// TODO: Reemplazar MockContextRepository con implementación real
// cuando los endpoints estén disponibles en edugo-api-mobile:
// - GET /v1/users/me/schools
// - POST /v1/users/me/active-school
// - GET /v1/users/me/active-school
//
// Ver especificación en: docs/specs/ui-roadmap/estudiantes/PANTALLAS-NUEVAS-PARTE2.md
```

---

## 📋 Resumen de Endpoints Requeridos en Backend

### Endpoints Existentes (Listos para Usar) ✅

```go
GET  /v1/materials/:id/assessment           // QuizView
POST /v1/materials/:id/assessment/attempts  // QuizView
GET  /v1/attempts/:id/results               // QuizResultView
GET  /v1/users/me/attempts                  // AttemptHistoryView
PUT  /v1/progress                           // Progreso de lectura
```

### Endpoints Pendientes de Implementación ⚠️

```go
// Para SchoolSelectorView (CRÍTICO)
GET  /v1/users/me/schools         // Listar escuelas del usuario
POST /v1/users/me/active-school   // Cambiar escuela activa
GET  /v1/users/me/active-school   // Obtener escuela activa
```

**Prioridad:** 🟡 Media (SchoolSelector puede usar mock temporal)

---

## 🎨 Componentes del Design System a Crear

### Alta Prioridad (Para Quizzes)

1. ✅ **DSQuestionCard** - Card de pregunta
2. ✅ **DSQuizOptionButton** - Botón de opción de quiz
3. ✅ **DSQuizProgressHeader** - Header con progreso y timer
4. ✅ **DSQuestionNavigator** - Sidebar de navegación (iPad)
5. ✅ **DSResultHeader** - Header de resultados con score
6. ✅ **DSStatsCard** - Card de estadísticas
7. ✅ **DSQuestionResultCard** - Card de resultado por pregunta
8. ✅ **DSScoreDistributionChart** - Gráfica de distribución

### Media Prioridad (Para Historial)

9. ✅ **DSAttemptRow** - Fila de intento en lista
10. ✅ **DSHistorySummaryCard** - Card de resumen de historial
11. ✅ **DSFilterChip** - Chip de filtro (reutilizable)
12. ✅ **DSProgressChart** - Gráfica de progreso temporal

### Baja Prioridad (Para SchoolSelector)

13. ✅ **DSSchoolCard** - Card de escuela
14. ✅ **DSSchoolSelectorRow** - Fila compacta para selector

---

## 🔄 Flujo Completo: Estudiante Toma Quiz

### 1. Usuario en MaterialDetailView

```
MaterialDetailView
├── Ver resumen IA
├── Ver progreso de lectura
└── [Botón: Tomar Quiz]
```

**Tap en "Tomar Quiz"** → Navega a `QuizView`

### 2. QuizView - Tomar Evaluación

```
QuizView
├── GET /v1/materials/:id/assessment
├── Mostrar preguntas una por una
├── Usuario responde 10 preguntas
├── Timer countdown (si hay límite)
└── [Finalizar Quiz] → Confirmación
```

**Tap en "Finalizar"** → `POST /v1/materials/:id/assessment/attempts`

### 3. Transición a Resultados

```
POST response:
{
  "attempt_id": "uuid",
  "score": 85.0,
  "passed": true
}
```

**Auto-navigate** → `QuizResultView(attemptId: uuid)`

### 4. QuizResultView - Ver Resultados

```
QuizResultView
├── GET /v1/attempts/:id/results
├── Mostrar score con animación
├── Confetti si score >= 90%
├── Desglose por pregunta
└── Opciones:
    ├── [Reintentar] → Volver a QuizView
    ├── [Volver al Material]
    └── [Ver Historial] → AttemptHistoryView
```

### 5. AttemptHistoryView - Historial Completo

```
AttemptHistoryView
├── GET /v1/users/me/attempts
├── Mostrar lista de intentos
├── Filtros y búsqueda
├── Tap en intento → QuizResultView(attemptId)
└── Infinite scroll con paginación
```

---

## 🚀 Plan de Implementación Sugerido

### Fase 1: Quizzes (2 semanas) - CRÍTICO

**Semana 1:**
- ✅ Crear componentes DS (DSQuestionCard, DSQuizOptionButton, etc.)
- ✅ Implementar QuizView completa
- ✅ Tests de QuizView

**Semana 2:**
- ✅ Implementar QuizResultView completa
- ✅ Implementar AttemptHistoryView
- ✅ Tests de ambas pantallas
- ✅ Integración end-to-end

### Fase 2: SchoolSelector (1 semana) - MEDIA

**Opción A (sin backend):**
- ✅ Implementar con MockRepository
- ✅ Datos en UserDefaults
- ✅ Feature flag para activar cuando backend esté listo

**Opción B (con backend):**
- ✅ Implementar endpoints en edugo-api-mobile
- ✅ Migración de tabla `user_active_context`
- ✅ Implementar SchoolSelectorView con API real

### Fase 3: Refinamiento (1 semana)

- ✅ Animaciones y transiciones
- ✅ Accessibility (VoiceOver, Dynamic Type)
- ✅ Tests de UI (snapshot tests)
- ✅ Documentación de código

---

## 📝 Notas de Implementación

### Persistencia de Estado de Quiz

**Pregunta:** ¿Guardar progreso del quiz si el usuario cierra la app?

**Recomendación:** NO en MVP. Razones:
- Complejidad adicional
- Posible trampas (buscar respuestas)
- Timer se invalida

**Alternativa:** Mostrar alerta al salir:

```swift
.onDisappear {
    if !isSubmitted {
        // Guardar draft en UserDefaults (opcional)
        saveDraft(answers)
    }
}

.alert("¿Salir del quiz?", isPresented: $showExitConfirmation) {
    Button("Cancelar", role: .cancel) { }
    Button("Salir sin guardar", role: .destructive) {
        coordinator.pop()
    }
} message: {
    Text("Si sales ahora, perderás tus respuestas. El quiz no se guardará.")
}
```

### Manejo de Errores de Red

**Durante el quiz:**
- Si pierde conexión DURANTE el quiz → Permitir continuar
- Al enviar respuestas → Retry con exponential backoff
- Si falla después de 3 intentos → Guardar localmente y sincronizar después

```swift
func submitWithRetry(maxRetries: Int = 3) async {
    for attempt in 1...maxRetries {
        do {
            let result = try await submitAttempt()
            return  // Éxito
        } catch {
            if attempt == maxRetries {
                // Guardar localmente
                saveAnswersLocally()
                showError("No se pudo enviar. Se guardó localmente y se sincronizará después.")
            } else {
                // Esperar antes de reintentar
                let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                try? await Task.sleep(nanoseconds: delay)
            }
        }
    }
}
```

### Sincronización de Contexto Escolar

**Importante:** Al cambiar de escuela, sincronizar:

1. **Token JWT** (si tiene school_id en claims)
2. **Cursos/materiales** visibles
3. **Progreso** del estudiante
4. **Intentos** de quizzes
5. **Cache** de datos

```swift
func switchSchool(to schoolID: String) async {
    // 1. Cambiar contexto en backend
    await setActiveSchool(schoolID)
    
    // 2. Limpiar cache
    await clearCache()
    
    // 3. Recargar datos
    await reloadAllData()
    
    // 4. Actualizar UI
    await MainActor.run {
        coordinator.popToRoot()
        coordinator.navigate(to: .home)
    }
}
```

---

## ✅ Checklist de Completitud

### QuizView
- [ ] Endpoint GET /v1/materials/:id/assessment integrado
- [ ] Endpoint POST /v1/materials/:id/assessment/attempts integrado
- [ ] Navegación entre preguntas funcionando
- [ ] Timer countdown implementado
- [ ] Validación de respuestas completas
- [ ] Confirmación antes de enviar
- [ ] Manejo de timeout automático
- [ ] Estados: loading, loaded, submitting, error
- [ ] Componentes DS creados y usados
- [ ] Tests unitarios de ViewModel
- [ ] Tests de UI (snapshot)
- [ ] Accessibility completa

### QuizResultView
- [ ] Endpoint GET /v1/attempts/:id/results integrado
- [ ] Header animado con score
- [ ] Confetti si score >= 90%
- [ ] Desglose por pregunta con feedback
- [ ] Expand/collapse de preguntas
- [ ] Navegación a reintentar quiz
- [ ] Navegación a material
- [ ] Gráfica de distribución (iPad/Mac)
- [ ] Export to PDF (macOS)
- [ ] Tests completos

### AttemptHistoryView
- [ ] Endpoint GET /v1/users/me/attempts integrado
- [ ] Paginación funcionando
- [ ] Infinite scroll
- [ ] Pull-to-refresh
- [ ] Búsqueda en tiempo real (debounce)
- [ ] Filtros (todos/aprobados/reprobados)
- [ ] Navegación a QuizResultView
- [ ] Empty state
- [ ] Gráfica de progreso (iPad/Mac)
- [ ] Tests completos

### SchoolSelectorView
- [ ] Endpoints implementados en backend O mock funcional
- [ ] Lista de escuelas y roles
- [ ] Cambio de contexto funcionando
- [ ] Confirmación de cambio
- [ ] Sincronización de datos post-cambio
- [ ] Auto-selección si solo una escuela
- [ ] Presentación correcta (sheet/popover)
- [ ] Tests completos

---

**Generado con:** Claude Code  
**Fecha:** 1 de Diciembre, 2025  
**Versión:** 1.0  
**Autor:** Jhoan Medina (asistido por Claude)

---

_Este documento es parte del proyecto EduGo y debe mantenerse sincronizado con los cambios en el backend (edugo-api-mobile) y el frontend (apple-app)._
