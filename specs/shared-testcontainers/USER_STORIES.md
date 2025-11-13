# User Stories: Módulo Testing

---

## 👨‍💻 Como Developer Backend de api-mobile

### US-1: Ejecutar Tests de Integración con Setup Mínimo
**Como** developer de api-mobile  
**Quiero** ejecutar tests de integración con una configuración simple  
**Para** no perder tiempo configurando Docker manualmente

**Criterios de Aceptación:**
- ✅ Setup en <10 líneas de código
- ✅ Containers se crean automáticamente
- ✅ Cleanup automático al finalizar
- ✅ Reutilización entre tests

**Ejemplo:**
```go
func TestMain(m *testing.M) {
    config := containers.NewConfig().
        WithPostgreSQL(nil).
        WithMongoDB(nil).
        WithRabbitMQ(nil).
        Build()
    
    mgr, _ := containers.GetManager(nil, config)
    defer mgr.Cleanup(context.Background())
    
    os.Exit(m.Run())
}
```

---

### US-2: Limpiar Datos Entre Tests
**Como** developer  
**Quiero** que los datos se limpien automáticamente entre tests  
**Para** tener aislamiento sin recrear containers

**Criterios de Aceptación:**
- ✅ Helper `CleanPostgreSQL(tables)` disponible
- ✅ Helper `CleanMongoDB(collections)` disponible
- ✅ Cleanup en <2 segundos
- ✅ Mantiene schema intacto

---

## 👨‍💻 Como Developer Backend de api-administracion

### US-3: Tests Solo con PostgreSQL
**Como** developer de api-admin  
**Quiero** tests con solo PostgreSQL (sin MongoDB/RabbitMQ)  
**Para** que sean más rápidos y no levantar servicios innecesarios

**Criterios de Aceptación:**
- ✅ Config permite seleccionar solo PostgreSQL
- ✅ Tiempo de setup <30s (vs 60s con todos)
- ✅ Mismo API que otros proyectos

**Ejemplo:**
```go
config := containers.NewConfig().
    WithPostgreSQL(&containers.PostgresConfig{
        InitScripts: []string{"migrations.sql"},
    }).
    Build()
```

---

### US-4: Ejecutar Migraciones SQL Automáticamente
**Como** developer  
**Quiero** que las migraciones SQL se ejecuten al crear el container  
**Para** no tener que aplicarlas manualmente

**Criterios de Aceptación:**
- ✅ `InitScripts` en PostgresConfig
- ✅ Scripts se ejecutan en orden
- ✅ Errores reportados claramente

---

## 👨‍💻 Como Developer Backend de worker

### US-5: Crear Primer Test de Integración
**Como** developer de worker (sin tests actuales)  
**Quiero** una guía simple para crear mi primer test  
**Para** empezar a testear el procesamiento de eventos

**Criterios de Aceptación:**
- ✅ Documentación clara con ejemplo
- ✅ Setup copy-paste funciona
- ✅ PostgreSQL + MongoDB + RabbitMQ disponibles
- ✅ Test ejecuta en <90s

---

## 👨‍💻 Como QA Engineer

### US-6: Ejecutar Tests de Todos los Proyectos
**Como** QA  
**Quiero** ejecutar tests con el mismo comando en todos los proyectos  
**Para** validar integraciones sin aprender setups diferentes

**Criterios de Aceptación:**
- ✅ Comando uniforme: `go test -tags=integration ./test/integration/`
- ✅ Mismo patrón de output
- ✅ Mismos containers en todos los proyectos

---

## 👨‍💻 Como Developer Frontend

### US-7: Levantar Ambiente Completo con un Comando
**Como** developer frontend  
**Quiero** levantar todo el stack (DBs + APIs) con un comando  
**Para** probar mi UI contra APIs reales

**Criterios de Aceptación:**
- ✅ `./scripts/setup.sh --profile full`
- ✅ Levanta: PostgreSQL, MongoDB, RabbitMQ, 3 APIs
- ✅ Datos de prueba cargados
- ✅ APIs disponibles en :8080, :8081
- ✅ Tiempo total: <3 minutos

---

### US-8: Levantar Solo Bases de Datos
**Como** developer frontend que corre APIs localmente  
**Quiero** levantar solo las bases de datos  
**Para** desarrollar más rápido sin las APIs en Docker

**Criterios de Aceptación:**
- ✅ `./scripts/setup.sh --profile db-only`
- ✅ Solo PostgreSQL + MongoDB + RabbitMQ
- ✅ Con seeds de datos
- ✅ Ports expuestos para conectar desde host

---

### US-9: Levantar Solo api-mobile
**Como** developer frontend que trabaja solo en mobile  
**Quiero** levantar solo api-mobile con sus dependencias  
**Para** no desperdiciar recursos en APIs que no uso

**Criterios de Aceptación:**
- ✅ `./scripts/setup.sh --profile mobile-only`
- ✅ Levanta: PostgreSQL + RabbitMQ + api-mobile
- ✅ No levanta: MongoDB, api-admin, worker

---

## 🛠️ Como DevOps/Infra

### US-10: Actualizar Versión de PostgreSQL
**Como** DevOps  
**Quiero** actualizar PostgreSQL de 15 a 16 en un solo lugar  
**Para** que todos los proyectos usen la nueva versión

**Criterios de Aceptación:**
- ✅ Cambio en shared/testing default config
- ✅ Todos los proyectos heredan el cambio
- ✅ Posibilidad de override si es necesario

---

### US-11: Configurar Seeds Centralizados
**Como** DevOps  
**Quiero** seeds de datos en dev-environment  
**Para** que frontend devs tengan datos consistentes

**Criterios de Aceptación:**
- ✅ Seeds en `dev-environment/seeds/`
- ✅ Script de carga automática
- ✅ Opción `--seed` en setup.sh
- ✅ Seeds incluyen: escuelas, usuarios, materiales

---

## 📊 Priorización (MoSCoW)

### Must Have (MVP)
- ✅ Manager con singleton
- ✅ PostgreSQL container
- ✅ MongoDB container
- ✅ RabbitMQ container
- ✅ Builder pattern
- ✅ Cleanup helpers

### Should Have (v0.6.0)
- ✅ Migración de api-mobile
- ✅ Migración de api-administracion
- ✅ Tests del módulo

### Could Have (v0.7.0)
- ⏳ S3/MinIO container
- ⏳ Seeds fixtures en shared
- ⏳ Parallel startup
- ⏳ Health checks

### Won't Have (Futuro)
- ❌ Redis (no usado aún)
- ❌ Elasticsearch (no usado aún)
- ❌ Kafka (no usado aún)

---

## 🎯 Definición de Done

### Para el Módulo
- ✅ Código implementado y testeado
- ✅ Coverage >70%
- ✅ Documentación completa
- ✅ Ejemplos de uso
- ✅ Release v0.6.0 publicado

### Para Migraciones
- ✅ Proyecto actualizado a usar shared/testing
- ✅ Tests pasando
- ✅ LOC reducido >80%
- ✅ PR mergeado

### Para dev-environment
- ✅ 6 perfiles docker-compose
- ✅ Scripts mejorados
- ✅ Seeds de datos
- ✅ README actualizado

---

**User Stories Definidas** ✅  
**Total:** 11 user stories

