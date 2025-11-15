# 📋 Product Requirements Document: Sistema de Evaluaciones

**Versión:** 1.0  
**Fecha:** 14 de Noviembre, 2025  
**Estado:** Aprobado para implementación

---

## 1. RESUMEN EJECUTIVO

### 1.1 Objetivo
Implementar un sistema completo de evaluaciones educativas que permita a los estudiantes tomar quizzes generados por IA, recibir calificación automática y feedback personalizado, mientras que los administradores pueden monitorear el progreso y rendimiento.

### 1.2 Alcance
- **Incluido:** Quizzes, calificación automática, historial, reportes
- **Excluido:** Evaluaciones manuales, exámenes programados, certificaciones

### 1.3 Stakeholders
- **Estudiantes:** Usuarios finales tomando evaluaciones
- **Profesores:** Monitoreo de progreso (futuro)
- **Administradores:** Reportes y analytics
- **Sistema IA:** Generador de quizzes (existente en worker)

---

## 2. CONTEXTO Y PROBLEMA

### 2.1 Situación Actual
- ✅ Worker genera quizzes con IA y los guarda en MongoDB
- ❌ No hay forma de que estudiantes tomen estos quizzes
- ❌ No existe sistema de calificación
- ❌ No hay tracking de progreso en evaluaciones
- ❌ Sin reportes para administradores

### 2.2 Oportunidad
Completar el ciclo de aprendizaje permitiendo que el contenido generado por IA sea evaluable, creando un loop de feedback que mejore el engagement y permita medir efectividad del aprendizaje.

---

## 3. REQUISITOS FUNCIONALES

### 3.1 Gestión de Evaluaciones

#### RF-001: Obtener Evaluación
**Como** estudiante  
**Quiero** obtener el quiz de un material  
**Para** evaluar mi comprensión

**Criterios de Aceptación:**
- Quiz viene de MongoDB (generado previamente)
- Incluye preguntas, opciones, metadatos
- Solo si el material tiene quiz disponible

#### RF-002: Iniciar Intento
**Como** estudiante  
**Quiero** iniciar un intento de evaluación  
**Para** registrar mi sesión

**Criterios:**
- Crear registro en PostgreSQL
- Asignar ID único de intento
- Registrar timestamp de inicio
- Validar que no hay intento activo

#### RF-003: Enviar Respuestas
**Como** estudiante  
**Quiero** enviar mis respuestas  
**Para** ser evaluado

**Criterios:**
- Validar formato de respuestas
- Guardar en PostgreSQL
- Permitir envío parcial (guardar progreso)
- Timeout configurable (default 30 min)

#### RF-004: Calificación Automática
**Como** sistema  
**Debo** calificar automáticamente  
**Para** dar feedback inmediato

**Criterios:**
- Comparar con respuestas correctas de MongoDB
- Calcular score (porcentaje)
- Determinar aprobado/reprobado (70% default)
- Generar feedback por pregunta

#### RF-005: Ver Resultados
**Como** estudiante  
**Quiero** ver mis resultados  
**Para** entender mi desempeño

**Criterios:**
- Score total y por pregunta
- Respuestas correctas vs incorrectas
- Feedback explicativo
- Tiempo tomado

#### RF-006: Historial de Intentos
**Como** estudiante  
**Quiero** ver mi historial  
**Para** trackear mi progreso

**Criterios:**
- Lista de todos los intentos
- Filtrar por material, fecha, score
- Ver tendencia de mejora
- Exportar a PDF (futuro)

### 3.2 Reportes Administrativos

#### RF-007: Estadísticas de Evaluación
**Como** administrador  
**Quiero** ver estadísticas por evaluación  
**Para** medir efectividad

**Criterios:**
- Intentos totales
- Score promedio
- Tasa de aprobación
- Preguntas más falladas

#### RF-008: Rendimiento de Estudiantes
**Como** administrador  
**Quiero** ver rendimiento por estudiante  
**Para** identificar necesidades

**Criterios:**
- Evaluaciones tomadas
- Score promedio general
- Progreso en el tiempo
- Áreas de fortaleza/debilidad

---

## 4. REQUISITOS NO FUNCIONALES

### 4.1 Performance
- **RNF-001:** Calificación <200ms para 20 preguntas
- **RNF-002:** Obtener quiz <500ms (con cache)
- **RNF-003:** Soportar 100 intentos concurrentes

### 4.2 Confiabilidad
- **RNF-004:** 99.9% uptime para evaluaciones
- **RNF-005:** No perder respuestas (transacciones ACID)
- **RNF-006:** Backup automático de intentos

### 4.3 Seguridad
- **RNF-007:** Respuestas encriptadas en tránsito
- **RNF-008:** Anti-cheating: un intento activo por vez
- **RNF-009:** Audit log de todas las acciones

### 4.4 Escalabilidad
- **RNF-010:** Horizontal scaling para api-mobile
- **RNF-011:** Cache distribuido para quizzes
- **RNF-012:** Particionamiento de tablas por fecha

### 4.5 Usabilidad
- **RNF-013:** Interfaz intuitiva sin training
- **RNF-014:** Responsive para móviles
- **RNF-015:** Accesibilidad WCAG 2.1 AA

---

## 5. REGLAS DE NEGOCIO

### 5.1 Evaluaciones
- **RN-001:** Un material puede tener máximo 1 evaluación activa
- **RN-002:** Score mínimo de aprobación: 70% (configurable)
- **RN-003:** Máximo 3 intentos por evaluación por día
- **RN-004:** Timeout de intento: 30 minutos (configurable)

### 5.2 Calificación
- **RN-005:** Todas las preguntas valen igual
- **RN-006:** No hay puntos parciales
- **RN-007:** Score final se redondea al entero más cercano

### 5.3 Acceso
- **RN-008:** Solo usuarios autenticados pueden tomar evaluaciones
- **RN-009:** Solo puede ver sus propios intentos
- **RN-010:** Administradores ven todos los intentos

---

## 6. CASOS DE USO

### 6.1 Flujo Principal: Tomar Evaluación

```
1. Estudiante navega a material
2. Sistema muestra botón "Tomar Evaluación" si hay quiz
3. Estudiante inicia evaluación
4. Sistema crea intento y muestra preguntas
5. Estudiante responde y envía
6. Sistema califica automáticamente
7. Sistema muestra resultados y feedback
8. Estudiante puede ver en historial
```

### 6.2 Flujos Alternativos

#### Alt-1: Sin Quiz Disponible
```
3a. Material no tiene quiz en MongoDB
4a. Sistema muestra "Evaluación no disponible"
5a. Fin del flujo
```

#### Alt-2: Timeout de Intento
```
5a. Estudiante excede 30 minutos
6a. Sistema auto-envía respuestas actuales
7a. Continúa desde paso 6 principal
```

#### Alt-3: Límite de Intentos
```
3a. Estudiante ya tiene 3 intentos hoy
4a. Sistema muestra "Límite diario alcanzado"
5a. Fin del flujo
```

---

## 7. MOCKUPS Y WIREFRAMES

### 7.1 Pantalla de Quiz
```
┌─────────────────────────────────┐
│ Evaluación: Matemáticas Básicas │
│ Pregunta 3 de 10      ⏱️ 15:23  │
├─────────────────────────────────┤
│                                 │
│ ¿Cuál es el resultado de 5+3?  │
│                                 │
│ ○ 7                            │
│ ● 8                            │
│ ○ 9                            │
│ ○ 10                           │
│                                 │
│ [Anterior] [Siguiente]          │
│         [Enviar Evaluación]     │
└─────────────────────────────────┘
```

### 7.2 Pantalla de Resultados
```
┌─────────────────────────────────┐
│ Resultados de Evaluación        │
├─────────────────────────────────┤
│ Score: 85% ✅ APROBADO          │
│                                 │
│ Correctas: 17/20                │
│ Tiempo: 12:45                   │
│                                 │
│ Detalle por Pregunta:           │
│ 1. ✅ Correcta                  │
│ 2. ✅ Correcta                  │
│ 3. ❌ Incorrecta - Ver feedback │
│ ...                             │
│                                 │
│ [Ver Respuestas] [Nuevo Intento]│
└─────────────────────────────────┘
```

---

## 8. MÉTRICAS DE ÉXITO

### 8.1 KPIs Principales
- **Adoption Rate:** 60% de estudiantes toman al menos 1 quiz/semana
- **Completion Rate:** 80% de quizzes iniciados se completan
- **Pass Rate:** 70% de intentos aprueban
- **Improvement Rate:** 30% mejora en segundo intento

### 8.2 Métricas Técnicas
- **Latency p99:** <500ms en todos los endpoints
- **Error Rate:** <0.1% en calificación
- **Availability:** 99.9% uptime mensual

---

## 9. DEPENDENCIAS Y RIESGOS

### 9.1 Dependencias
- ✅ Worker generando quizzes (completado)
- ✅ MongoDB con material_assessment (existe)
- ⚠️ edugo-shared v0.7.0 (por crear)
- ⚠️ Schema PostgreSQL (por crear)

### 9.2 Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Integración MongoDB-PostgreSQL compleja | Alta | Alto | PoC temprano, interfaces claras |
| Performance de calificación | Media | Medio | Cache, optimización queries |
| Adopción baja | Media | Alto | UX intuitiva, gamification |
| Data inconsistency | Baja | Alto | Transacciones, validaciones |

---

## 10. PHASES Y MILESTONES

### Phase 1: Foundation (Week 1)
- Milestone 1: shared v0.7.0 released
- Milestone 2: Database schema deployed

### Phase 2: Core Implementation (Week 2-3)
- Milestone 3: API endpoints functional
- Milestone 4: Auto-grading working

### Phase 3: Integration (Week 4)
- Milestone 5: MongoDB integration complete
- Milestone 6: Admin reports available

### Phase 4: Polish (Week 4+)
- Milestone 7: Performance optimization
- Milestone 8: Full test coverage

---

## 11. DEFINICIÓN DE HECHO (DoD)

Una feature se considera COMPLETA cuando:

- [ ] Código implementado según diseño
- [ ] Tests unitarios >85% coverage
- [ ] Tests de integración pasando
- [ ] Code review aprobado
- [ ] Documentación actualizada
- [ ] Swagger regenerado
- [ ] Sin bugs críticos
- [ ] Performance dentro de SLAs
- [ ] Merged a dev branch
- [ ] Demo al stakeholder

---

## 12. FUTURAS MEJORAS (OUT OF SCOPE)

Para versiones posteriores:
- Evaluaciones programadas
- Preguntas de desarrollo (texto libre)
- Evaluaciones colaborativas
- Certificados de completion
- Analytics avanzados con ML
- Proctoring anti-cheating
- Question bank management
- Adaptive testing (dificultad dinámica)

---

**Aprobado por:** Product Owner  
**Fecha aprobación:** 14 de Noviembre, 2025  
**Válido hasta:** v1.0 Release