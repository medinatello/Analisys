# Tracking: Migracion Mock Repositories - API Administracion

**Fecha de Inicio:** 30 Noviembre 2025
**Proyecto:** Migracion de mock repositories a dataset generado automaticamente
**API:** edugo-api-administracion

---

## Resumen Ejecutivo

Este documento rastrea el progreso de la migracion de mock repositories hardcodeados a un sistema de dataset generado automaticamente desde archivos SQL de testing.

### Objetivos del Proyecto

1. Eliminar codigo hardcodeado duplicado en mock repositories
2. Generar dataset automaticamente desde SQL de testing
3. Estandarizar configuracion de mocks en todas las APIs
4. Simplificar mantenimiento de datos mock

### Arquitectura Objetivo

```
edugo-infrastructure/
├── tools/mock-generator/          # Generador automatico
│   ├── cmd/main.go                # CLI
│   ├── pkg/parser/                # Parser SQL
│   └── pkg/generator/             # Generador de codigo Go
│
└── postgres/migrations/testing/   # Fuente unica de verdad
    ├── 001_demo_users.sql
    ├── 002_demo_schools.sql
    └── ...

edugo-api-administracion/
└── internal/infrastructure/persistence/mock/
    ├── dataset/                   # AUTO-GENERADO
    │   ├── database.go
    │   ├── users_table.go
    │   └── load_data.go
    └── repository/                # SIMPLE (solo proxy)
        └── user_repository_mock.go
```

---

## Tabla de Progreso General

| Sprint | Descripcion | Pasos Totales | Completados | % | Estado | Tiempo Est. |
|--------|-------------|---------------|-------------|---|--------|-------------|
| Sprint 0 | Preparacion | 6 | 0 | 0% | ⏳ Pendiente | 33 min |
| Sprint 1 | Parser SQL | 10 | 0 | 0% | 🔒 Bloqueado | 2h 40min |
| Sprint 2 | Generador Dataset | 12 | 0 | 0% | 🔒 Bloqueado | 3h 25min |
| Sprint 3 | Integracion API | 15 | 0 | 0% | 🔒 Bloqueado | 2h 55min |
| **TOTAL** | **4 sprints** | **43** | **0** | **0%** | **⏳ No Iniciado** | **9h 33min** |

---

## Detalles por Sprint

### Sprint 0: Preparacion del Ambiente

**Ubicacion:** `api-administracion/sprint-0-preparacion/`
**Estado:** ⏳ Pendiente
**Tiempo Estimado:** 33 minutos

#### Pasos

| # | Descripcion | Estado | Tiempo |
|---|-------------|--------|--------|
| 1 | Crear directorio del proyecto | ⬜ | 5 min |
| 2 | Inicializar modulo Go | ⬜ | 5 min |
| 3 | Instalar dependencias | ⬜ | 10 min |
| 4 | Crear estructura de directorios | ⬜ | 5 min |
| 5 | Validar acceso a migraciones SQL | ⬜ | 5 min |
| 6 | Configurar .gitignore | ⬜ | 3 min |

#### Resultado Esperado
- Directorio `tools/mock-generator` creado
- Dependencias instaladas (pingcap/tidb/parser, cobra)
- Estructura de proyecto lista

**Primer Paso a Ejecutar:**
```
/Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/sprint-0-preparacion/paso-01-crear-directorio.md
```

---

### Sprint 1: Parser SQL Basico

**Ubicacion:** `api-administracion/sprint-1-parser-sql/`
**Estado:** 🔒 Bloqueado (requiere Sprint 0)
**Tiempo Estimado:** 2 horas 40 minutos

#### Pasos

| # | Descripcion | Estado | Tiempo |
|---|-------------|--------|--------|
| 1 | Crear CLI principal con Cobra | ⬜ | 15 min |
| 2 | Crear estructura del parser | ⬜ | 20 min |
| 3 | Implementar ParseDirectory | ⬜ | 20 min |
| 4 | Extraer datos de INSERT | ⬜ | 25 min |
| 5 | Evaluar expresiones SQL | ⬜ | 20 min |
| 6 | Crear mapeos de tipos | ⬜ | 15 min |
| 7 | Integrar parser con main | ⬜ | 15 min |
| 8 | Compilar binario | ⬜ | 5 min |
| 9 | Ejecutar y probar parser | ⬜ | 10 min |
| 10 | Validar datos extraidos | ⬜ | 15 min |

#### Resultado Esperado
- Binario `bin/mock-generator` funcional
- Parser extrae datos de 5 archivos SQL
- Estadisticas: users (8), schools (3), memberships (12), etc.

---

### Sprint 2: Generador de Dataset

**Ubicacion:** `api-administracion/sprint-2-generador-dataset/`
**Estado:** 🔒 Bloqueado (requiere Sprint 1)
**Tiempo Estimado:** 3 horas 25 minutos

#### Pasos

| # | Descripcion | Estado | Tiempo |
|---|-------------|--------|--------|
| 1 | Crear estructura base del generador | ⬜ | 15 min |
| 2 | Template para database.go | ⬜ | 20 min |
| 3 | Template para tablas | ⬜ | 25 min |
| 4 | Template para loader | ⬜ | 20 min |
| 5 | Implementar generacion database.go | ⬜ | 15 min |
| 6 | Implementar generacion de tablas | ⬜ | 25 min |
| 7 | Implementar generacion loader | ⬜ | 20 min |
| 8 | Formatear codigo generado | ⬜ | 10 min |
| 9 | Integrar generador con main | ⬜ | 15 min |
| 10 | Compilar y ejecutar | ⬜ | 10 min |
| 11 | Validar archivos generados | ⬜ | 15 min |
| 12 | Probar compilacion | ⬜ | 15 min |

#### Resultado Esperado
- Generador crea 7+ archivos Go
- Codigo generado compila sin errores
- Templates funcionando correctamente

---

### Sprint 3: Integracion con API Administracion

**Ubicacion:** `api-administracion/sprint-3-integracion-api/`
**Estado:** 🔒 Bloqueado (requiere Sprint 2)
**Tiempo Estimado:** 2 horas 55 minutos

#### Pasos

| # | Descripcion | Estado | Tiempo |
|---|-------------|--------|--------|
| 1 | Generar dataset para api-admin | ⬜ | 5 min |
| 2 | Verificar dataset copiado | ⬜ | 5 min |
| 3 | Actualizar UserRepository | ⬜ | 20 min |
| 4 | Actualizar SchoolRepository | ⬜ | 15 min |
| 5 | Actualizar AcademicUnitRepository | ⬜ | 15 min |
| 6 | Actualizar MembershipRepository | ⬜ | 15 min |
| 7 | Verificar Factory | ⬜ | 5 min |
| 8 | Estandarizar configuracion | ⬜ | 10 min |
| 9 | Actualizar debug.json | ⬜ | 5 min |
| 10 | Borrar archivos antiguos | ⬜ | 5 min |
| 11 | Compilar API | ⬜ | 10 min |
| 12 | Test health check | ⬜ | 10 min |
| 13 | Test login | ⬜ | 15 min |
| 14 | Test endpoints | ⬜ | 20 min |
| 15 | Validacion final | ⬜ | 20 min |

#### Resultado Esperado
- API compila y ejecuta con mocks
- Login funciona con datos del dataset
- Todos los endpoints retornan datos correctos
- Tests end-to-end pasan

---

## Criterios de Aceptacion Global

### Funcionales
- [ ] Parser SQL extrae datos de migraciones de testing
- [ ] Generador crea archivos Go validos
- [ ] API levanta correctamente con mocks
- [ ] Login funciona con usuario admin@edugo.test
- [ ] Endpoints retornan datos del dataset

### Tecnicos
- [ ] Todo el codigo compila sin errores
- [ ] Sin warnings de Go
- [ ] Codigo formateado con gofmt
- [ ] Binarios ejecutables generados

### Configuracion
- [ ] Variable USE_MOCK_REPOSITORIES estandarizada
- [ ] .zed/debug.json actualizado
- [ ] Sin archivos hardcodeados antiguos

### Calidad
- [ ] Tests de integracion pasan
- [ ] Health check retorna 200
- [ ] Login retorna token valido
- [ ] Lista de escuelas retorna 3 elementos
- [ ] Lista de usuarios retorna 8 elementos

---

## Datos Mock Disponibles

### Usuarios (8 total)
- admin@edugo.test (admin)
- teacher.math@edugo.test (teacher)
- teacher.science@edugo.test (teacher)
- student1@edugo.test (student)
- student2@edugo.test (student)
- student3@edugo.test (student)
- guardian1@edugo.test (guardian)
- guardian2@edugo.test (guardian)

**Password para todos:** `edugo2024`

### Escuelas (3 total)
- Escuela Primaria Demo
- Colegio Secundario Demo
- Instituto Tecnico Demo

### Otras Entidades
- Academic Units: 5
- Memberships: 12
- Materials: 3

---

## Comandos Rapidos

### Generar Dataset
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator

./bin/mock-generator \
  --testing=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing \
  --output=/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/internal/infrastructure/persistence/mock/dataset
```

### Compilar API
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
make build
```

### Ejecutar con Mocks
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion
USE_MOCK_REPOSITORIES=true APP_ENV=local ./bin/api-administracion
```

### Test Rapido
```bash
# Health
curl http://localhost:8081/health

# Login
curl -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@edugo.test","password":"edugo2024"}'
```

---

## Problemas Conocidos y Soluciones

### Problema: Dataset no generado
**Sintoma:** Error "package dataset not found"
**Solucion:** Ejecutar generador de dataset

### Problema: API no levanta
**Sintoma:** Error "failed to connect to postgres"
**Solucion:** Verificar USE_MOCK_REPOSITORIES=true

### Problema: Login falla
**Sintoma:** Error "invalid credentials"
**Solucion:** Verificar password es "edugo2024"

---

## Proximos Pasos (Post-Sprint 3)

1. Aplicar mismo proceso a api-mobile
2. Implementar carga real de datos en load_data.go
3. Agregar mas tablas al generador
4. Crear tests automatizados del generador
5. Documentar proceso completo

---

## Actualizaciones

### 2025-11-30
- Estructura de sprints creada
- Documentacion inicial completada
- 43 pasos atomicos definidos
- Tiempo total estimado: 9h 33min

---

## Recursos

- **Arquitectura:** `/Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/plan-arquitectura/plan-final/`
- **Sprints:** `/Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/`
- **SQL Testing:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/postgres/migrations/testing/`

---

**Estado del Proyecto:** ⏳ LISTO PARA COMENZAR

**Primer Paso:**
→ `/Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/sprint-0-preparacion/paso-01-crear-directorio.md`
