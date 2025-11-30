# Paso 5: Identificar 10 Repositorios a Migrar

**Duración estimada:** 5 minutos
**Prerequisitos:** ✅ Paso 4 completado

## Objetivo
Crear lista completa de repositorios a migrar de stubs a implementación.

## Ejecución

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Extraer todos los mocks de stubs
grep "^type mock" internal/infrastructure/persistence/mock/postgres/stubs.go
grep "^type mock" internal/infrastructure/persistence/mock/mongodb/stubs.go
```

## Lista de Repositorios

### PostgreSQL (8 repositorios)
1. ✅ UserRepository - YA IMPLEMENTADO (referencia)
2. ❌ MaterialRepository - stub → dataset
3. ❌ ProgressRepository - stub → dataset
4. ❌ RefreshTokenRepository - stub → dataset
5. ❌ LoginAttemptRepository - stub → dataset
6. ❌ AssessmentRepository - stub → dataset
7. ❌ AttemptRepository - stub → dataset
8. ❌ AnswerRepository - stub → dataset

### MongoDB (3 repositorios)
9. ❌ SummaryRepository - stub → fixtures MongoDB
10. ❌ LegacyAssessmentRepository - stub → fixtures MongoDB
11. ❌ AssessmentDocumentRepository - stub → fixtures MongoDB

**Total:** 11 repositorios (1 hecho, 10 pendientes)

## Validación
- [ ] Lista completa de 11 repositorios
- [ ] 8 PostgreSQL + 3 MongoDB identificados
- [ ] UserRepository marcado como referencia

## Siguiente Paso
→ [paso-06-planificar-fixtures-mongodb.md]
