# 🔄 Orden de Ejecución - Ecosistema EduGo

**Fecha:** 16 de Noviembre, 2025  
**Versión:** 2.0.0

---

## 🎯 Propósito

Este documento define el orden OBLIGATORIO de ejecución para desarrollo, setup y deployment del ecosistema EduGo. Seguir este orden garantiza que no haya errores de dependencias.

---

## 📋 Orden de Desarrollo (Specs)

### ✅ COMPLETADOS

```
1. shared v0.7.0 (FROZEN)
   └─ Prerequisito: Ninguno
   └─ Duración: 2-3 semanas
   └─ Estado: ✅ COMPLETADO
   └─ Resultado: 12 módulos publicados

2. infrastructure v0.1.1
   └─ Prerequisito: Ninguno
   └─ Duración: 1 semana
   └─ Estado: ✅ 96% COMPLETADO
   └─ Resultado: Migraciones, schemas, docker

3. shared-testcontainers v0.6.2
   └─ Prerequisito: shared v0.5.0+
   └─ Duración: 3 días
   └─ Estado: ✅ COMPLETADO
   └─ Resultado: Módulo testing reutilizable

4. api-administracion v0.2.0 (jerarquía)
   └─ Prerequisito: shared v0.7.0, infrastructure v0.1.1
   └─ Duración: 1 semana
   └─ Estado: ✅ COMPLETADO
   └─ Resultado: Sistema de jerarquía completo

5. dev-environment
   └─ Prerequisito: infrastructure v0.1.1
   └─ Duración: 3 días
   └─ Estado: ✅ COMPLETADO
   └─ Resultado: Profiles y seeds
```

### 🔄 EN PROGRESO

```
6. api-mobile (evaluaciones)
   └─ Prerequisito: shared v0.7.0, infrastructure v0.1.1, api-admin v0.2.0
   └─ Duración estimada: 2-3 semanas
   └─ Estado: 🔄 40% COMPLETADO
   └─ Próximos pasos:
      1. Actualizar a shared v0.7.0
      2. Integrar infrastructure/schemas
      3. Completar endpoints de evaluaciones
```

### ⬜ PENDIENTES

```
7. worker (procesamiento IA)
   └─ Prerequisito: shared v0.7.0, infrastructure v0.1.1, api-mobile (evaluaciones)
   └─ Duración estimada: 3-4 semanas
   └─ Estado: ⬜ PENDIENTE
   └─ Requisitos adicionales:
      - Documentar costos de OpenAI
      - Documentar SLA de OpenAI
```

---

## 🗄️ Orden de Migraciones de Base de Datos

### PostgreSQL

**CRÍTICO:** Las migraciones deben ejecutarse en este orden EXACTO.

```
1. infrastructure/database/migrations/
   └─ Ejecutar PRIMERO (crea todas las tablas en orden)

   001_create_users.up.sql          # api-admin (owner)
   002_create_schools.up.sql         # api-admin (owner)
   003_create_academic_units.up.sql # api-admin (owner)
   004_create_memberships.up.sql    # api-admin (owner)
   005_create_materials.up.sql      # api-mobile (owner)
   006_create_assessments.up.sql    # api-mobile (owner)
   007_create_assessment_attempts.up.sql   # api-mobile (owner)
   008_create_assessment_answers.up.sql    # api-mobile (owner)
```

**Razón del orden:**
- 001-004: Tablas base de api-admin (sin foreign keys)
- 005-008: Tablas de api-mobile (con foreign keys a api-admin)

**Comando (cuando migrate.go esté listo):**
```bash
cd infrastructure/database
go run migrate.go up
```

**Comando manual (actual):**
```bash
cd infrastructure/database/migrations
psql -h localhost -U edugo -d edugo_dev -f 001_create_users.up.sql
psql -h localhost -U edugo -d edugo_dev -f 002_create_schools.up.sql
# ... etc
```

### MongoDB

**No requiere orden específico** (sin foreign keys)

Colecciones creadas automáticamente por worker al insertar:
- material_summary
- material_assessment
- material_event

---

## 🐳 Orden de Setup Local (Docker)

### Opción 1: Setup Completo (Recomendado)

```bash
# Paso 1: Levantar infrastructure
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
make dev-setup

# Esto hace automáticamente:
# - Levanta PostgreSQL, MongoDB, RabbitMQ
# - Ejecuta migraciones (cuando migrate.go esté listo)
# - Carga seeds de datos

# Paso 2: Levantar APIs (en orden)
# Terminal 1: api-admin
cd ../edugo-api-administracion
go run cmd/api/main.go

# Terminal 2: api-mobile
cd ../edugo-api-mobile
go run cmd/api/main.go

# Terminal 3: worker
cd ../edugo-worker
go run cmd/worker/main.go
```

### Opción 2: Setup por Perfil

```bash
# Paso 1: Solo bases de datos
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-dev-environment
./scripts/setup.sh --profile db-only --seed

# Paso 2: Ejecutar migraciones manualmente
cd ../edugo-infrastructure/database/migrations
# Ejecutar SQLs en orden (001 → 008)

# Paso 3: Levantar APIs en orden (igual que Opción 1)
```

### Opción 3: Manual (para debugging)

```bash
# Paso 1: Levantar servicios base
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/docker
docker-compose up -d postgres mongodb rabbitmq

# Paso 2: Esperar que servicios estén listos
docker-compose ps

# Paso 3: Ejecutar migraciones (ver sección de Migraciones)

# Paso 4: Cargar seeds
cd ../scripts
./seed-data.sh

# Paso 5: Levantar APIs en orden (igual que Opción 1)
```

---

## 🚀 Orden de Deployment a Producción

### Paso 1: Infraestructura Base

```
1.1 PostgreSQL 15
    └─ Servidor de BD configurado
    └─ Database: edugo_prod
    └─ User: edugo_prod

1.2 MongoDB 7.0
    └─ Servidor de BD configurado
    └─ Database: edugo

1.3 RabbitMQ 3.12
    └─ Servidor de mensajería configurado
    └─ Exchange: edugo.topic
    └─ DLQ configurado
```

### Paso 2: Ejecutar Migraciones

```
2.1 infrastructure/database (v0.1.1)
    └─ Ejecutar migraciones en orden (001 → 008)
    └─ Validar que todas las tablas existen
    └─ Ejecutar seeds de datos (si aplica)
```

### Paso 3: Deployar Aplicaciones (EN ORDEN)

```
3.1 api-administracion (v0.2.0)
    └─ Variables de entorno configuradas
    └─ Conectado a PostgreSQL
    └─ Healthcheck pasando
    └─ Puerto 8081 expuesto

    Validación:
    curl http://localhost:8081/health
    → {"status": "ok"}

3.2 api-mobile (cuando esté listo)
    └─ Prerequisito: api-admin debe estar UP
    └─ Variables de entorno configuradas
    └─ Conectado a PostgreSQL + MongoDB
    └─ Conectado a RabbitMQ
    └─ Healthcheck pasando
    └─ Puerto 8080 expuesto

    Validación:
    curl http://localhost:8080/health
    → {"status": "ok"}

3.3 worker (cuando esté listo)
    └─ Prerequisito: api-mobile debe estar UP
    └─ Variables de entorno configuradas
    └─ Conectado a MongoDB
    └─ Conectado a RabbitMQ
    └─ Consumiendo eventos

    Validación:
    # Verificar que worker está consumiendo
    rabbitmqctl list_queues
    → material.processing: 0 mensajes en cola
```

---

## 🔄 Orden de Pruebas (Testing)

### Tests Unitarios (en paralelo)

```
Pueden ejecutarse en cualquier orden:
- shared: make test
- api-administracion: make test
- api-mobile: make test
- worker: make test
```

### Tests de Integración (en orden)

```
1. infrastructure/database
   └─ Validar migraciones UP/DOWN
   └─ Validar constraints y indexes

2. shared/testing
   └─ Validar Testcontainers funcionan

3. api-administracion
   └─ Prerequisito: infrastructure migraciones
   └─ Tests con Testcontainers (PostgreSQL)

4. api-mobile
   └─ Prerequisito: infrastructure migraciones
   └─ Tests con Testcontainers (PostgreSQL + MongoDB + RabbitMQ)

5. worker
   └─ Prerequisito: infrastructure migraciones
   └─ Tests con Testcontainers (MongoDB + RabbitMQ)
```

### Tests End-to-End

```
1. Setup completo del ecosistema
   └─ infrastructure/docker: docker-compose up

2. Ejecutar migraciones
   └─ infrastructure/database

3. Levantar todas las APIs
   └─ api-admin
   └─ api-mobile
   └─ worker

4. Ejecutar escenarios E2E
   └─ Subir material → Procesar → Tomar quiz
   └─ Crear escuela → Asignar usuarios → Matricular
```

---

## 📊 Orden de Validación

### Validación de Dependencias

```
1. Validar shared v0.7.0 disponible
   └─ go list -m github.com/EduGoGroup/edugo-shared/auth@v0.7.0

2. Validar infrastructure clonado
   └─ cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
   └─ git status

3. Validar Docker instalado
   └─ docker --version
   └─ docker-compose --version

4. Validar PostgreSQL accesible
   └─ psql -h localhost -U edugo -d edugo_dev -c "SELECT 1"

5. Validar MongoDB accesible
   └─ mongosh localhost:27017/edugo --eval "db.version()"

6. Validar RabbitMQ accesible
   └─ curl http://localhost:15672 (Management UI)
```

### Validación de Migraciones

```
1. Conectar a PostgreSQL
   └─ psql -h localhost -U edugo -d edugo_dev

2. Validar tablas existen (en orden)
   └─ \dt
   └─ Debe mostrar: users, schools, academic_units, memberships,
                     materials, assessment, assessment_attempt, assessment_answer

3. Validar constraints
   └─ \d+ users
   └─ Verificar foreign keys, unique constraints, indexes

4. Validar seeds cargados
   └─ SELECT COUNT(*) FROM users;
   └─ Debe retornar > 0
```

### Validación de Eventos

```
1. Validar exchange existe
   └─ rabbitmqctl list_exchanges
   └─ Debe mostrar: edugo.topic

2. Validar queues existen
   └─ rabbitmqctl list_queues
   └─ Debe mostrar: material.processing, etc.

3. Validar schemas disponibles
   └─ ls infrastructure/schemas/events/
   └─ Debe mostrar: material-uploaded-v1.schema.json, etc.
```

---

## ⚠️ Errores Comunes y Soluciones

### Error: "table already exists"

**Causa:** Intentar ejecutar migraciones fuera de orden

**Solución:**
```bash
# Eliminar BD y volver a crear
psql -h localhost -U edugo -d postgres
DROP DATABASE edugo_dev;
CREATE DATABASE edugo_dev;

# Ejecutar migraciones en orden correcto (001 → 008)
```

### Error: "foreign key constraint violation"

**Causa:** Intentar insertar en tabla de api-mobile sin datos en api-admin

**Solución:**
```bash
# Ejecutar seeds de api-admin primero
psql -h localhost -U edugo -d edugo_dev -f infrastructure/seeds/postgres/users.sql
psql -h localhost -U edugo -d edugo_dev -f infrastructure/seeds/postgres/schools.sql

# Luego seeds de api-mobile
psql -h localhost -U edugo -d edugo_dev -f infrastructure/seeds/postgres/materials.sql
```

### Error: "api-mobile no puede conectarse a api-admin"

**Causa:** api-admin no está corriendo o healthcheck falló

**Solución:**
```bash
# Verificar que api-admin está UP
curl http://localhost:8081/health

# Si no responde, revisar logs
cd edugo-api-administracion
go run cmd/api/main.go
# Ver errores en consola
```

### Error: "worker no procesa eventos"

**Causa:** RabbitMQ no configurado o api-mobile no publicó evento

**Solución:**
```bash
# Verificar que RabbitMQ está UP
curl http://localhost:15672

# Verificar que exchange existe
rabbitmqctl list_exchanges | grep edugo.topic

# Verificar que worker está consumiendo
rabbitmqctl list_consumers
```

---

## 📝 Checklist de Ejecución

### Setup Inicial (una vez)

- [ ] Clonar todos los repositorios
- [ ] Instalar Go 1.24+
- [ ] Instalar Docker + Docker Compose
- [ ] Clonar infrastructure
- [ ] Ejecutar make dev-setup en infrastructure
- [ ] Validar que todos los servicios están UP

### Desarrollo Diario

- [ ] Levantar infrastructure (si no está UP)
- [ ] Ejecutar migraciones (si hay cambios)
- [ ] Levantar api-admin primero
- [ ] Levantar api-mobile después
- [ ] Levantar worker al final
- [ ] Ejecutar tests en orden

### Deployment a Producción

- [ ] Validar infraestructura base (PostgreSQL, MongoDB, RabbitMQ)
- [ ] Ejecutar migraciones en orden
- [ ] Deployar api-admin y validar healthcheck
- [ ] Deployar api-mobile y validar healthcheck
- [ ] Deployar worker y validar consumo de eventos
- [ ] Ejecutar smoke tests
- [ ] Monitorear logs por 1 hora

---

## 🎯 Resumen

**ORDEN CRÍTICO:**
1. infrastructure (setup base)
2. migraciones (001 → 008)
3. api-administracion (owner de tablas base)
4. api-mobile (consumer de tablas base)
5. worker (consumer de eventos)

**NO SEGUIR ESTE ORDEN CAUSARÁ ERRORES.**

---

**Generado:** 16 de Noviembre, 2025  
**Por:** Claude Code  
**Versión:** 2.0.0
