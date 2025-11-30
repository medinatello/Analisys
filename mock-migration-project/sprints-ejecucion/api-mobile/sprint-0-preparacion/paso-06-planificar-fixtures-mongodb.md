# Paso 6: Planificar Fixtures MongoDB

**Duración estimada:** 5 minutos
**Prerequisitos:** ✅ Paso 5 completado

## Objetivo
Crear plan de fixtures para entidades MongoDB que api-admin no tiene.

## Plan de Fixtures MongoDB

### 1. Summary (MaterialSummary)
```
- Material ID: uuid (relacionar con dataset PostgreSQL)
- Summary: string (resumen generado por IA)
- Key Points: []string
- Created At: timestamp
```

**Datos de prueba:** 10 summaries (uno por material)

### 2. LegacyAssessment (MaterialAssessment)
```
- Material ID: uuid
- Questions: []Question
- Passing Score: int
- Time Limit: duration
```

**Datos de prueba:** 5 assessments con 8-12 preguntas c/u

### 3. AssessmentDocument (MongoDB Schema)
```
- _id: ObjectID
- Material ID: string
- Questions: []QuestionDocument
- Config: AssessmentConfig
```

**Datos de prueba:** 5 documents (mismo contenido que LegacyAssessment)

## Coherencia con Dataset PostgreSQL

**IMPORTANTE:** Los Material IDs de MongoDB DEBEN coincidir con materials_table.go

```
materials_table.go:
  - Material 1: uuid-xxx-1
  - Material 2: uuid-xxx-2
  
summary_fixtures.go:
  - Summary para uuid-xxx-1
  - Summary para uuid-xxx-2
```

## Validación
- [ ] Plan de 3 tipos de fixtures MongoDB
- [ ] Relación con dataset PostgreSQL clara
- [ ] Cantidad de datos definida

## Siguiente Paso
→ [paso-07-validar-entorno.md]
