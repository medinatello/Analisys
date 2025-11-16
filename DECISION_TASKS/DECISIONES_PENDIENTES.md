# 🎯 Decisiones Pendientes - EduGo

**Fecha:** 15 de Noviembre, 2025
**Estado:** ✅ edugo-shared v0.7.0 resuelto | ⬜ 4 decisiones críticas pendientes
**Objetivo:** Tomar decisiones para desbloquear desarrollo

---

## 📖 Cómo Usar Este Documento

1. **Lee cada sección** (son 4 decisiones críticas)
2. **Entiende el problema** y sus implicaciones
3. **Revisa las soluciones propuestas** con pros/contras
4. **Escribe tu decisión** en el espacio "TU DECISIÓN"
5. **Guarda el documento** y avísame cuando termines
6. **Yo generaré las tareas** basado en tus decisiones

**Tiempo estimado:** 30-45 minutos para leer y decidir todo

---

# SESIÓN 1: Ownership de Tablas Compartidas

## 🔴 PROBLEMA

**¿Qué pasa?**
- La tabla `users` es mencionada tanto en **api-admin** como en **api-mobile**
- La tabla `materials` es mencionada en **api-mobile** pero no queda claro si la crea o asume que existe
- Las tablas `schools`, `academic_units` también son ambiguas

**¿Por qué es un problema?**
- Si ambos proyectos intentan crear la misma tabla → Error "table already exists"
- Si ninguno la crea → Error "table does not exist"
- Las migraciones no tienen orden garantizado en CI/CD

**¿Dónde se genera?**
- En las migraciones de base de datos de cada proyecto:
  - `api-admin/migrations/001_create_users.sql`
  - `api-mobile/migrations/00X_create_materials.sql`

**¿Qué inconveniente trae?**
- ❌ Migraciones fallan de manera impredecible
- ❌ CI/CD no puede ejecutar migraciones automáticamente
- ❌ Desarrollo local inconsistente (cada dev con esquema diferente)
- ❌ Tests de integración rompen aleatoriamente
- ❌ Imposible hacer development desatendido por IA

---

## 💡 SOLUCIONES PROPUESTAS

### Opción 1: api-admin crea TODAS las tablas base, api-mobile solo features

**Cómo funciona:**
```
api-admin crea:
├─ users (todas las columnas necesarias)
├─ schools
├─ academic_units
├─ memberships
└─ [otras tablas de administración]

api-mobile crea:
├─ materials (con FK a users, schools)
├─ assessment (con FK a materials)
├─ assessment_attempt
└─ [tablas específicas de mobile]

Orden de ejecución:
1. api-admin ejecuta migraciones PRIMERO
2. api-mobile ejecuta migraciones DESPUÉS
```

**✅ Pros:**
- Separación clara de responsabilidades
- api-admin es "fundación", api-mobile es "features"
- Fácil de entender y documentar
- CI/CD tiene orden claro: admin → mobile

**❌ Contras:**
- Si api-mobile necesita agregar columna a `users`, debe coordinar con api-admin
- api-admin se vuelve "cuello de botella" para cambios de esquema

**⚙️ Implementación:**
```
1. Crear tabla en: docs/DATABASE_OWNERSHIP.md
2. Modificar Makefile de api-mobile para validar tablas base
3. CI/CD ejecuta: api-admin migrate → api-mobile migrate
4. Tiempo: 3-4 horas
```

**🎯 Impacto:**
- ✅ Cero conflictos de migraciones
- ✅ Orden claro y documentado
- ⚠️ Acoplamiento entre proyectos en cambios de esquema

---

### Opción 2: Cada proyecto crea SOLO sus tablas, usar migraciones condicionales

**Cómo funciona:**
```sql
-- api-admin/migrations/001_create_users.sql
CREATE TABLE IF NOT EXISTS users (...);

-- api-mobile/migrations/001_create_users_if_needed.sql
CREATE TABLE IF NOT EXISTS users (...);
CREATE TABLE materials (...);
```

**✅ Pros:**
- Cada proyecto es "autocontenido"
- No importa el orden de ejecución
- Más flexible para desarrollo independiente

**❌ Contras:**
- Riesgo de esquemas inconsistentes (¿qué columnas tiene `users`?)
- Difícil de mantener (cambios deben replicarse en múltiples lugares)
- Debugging complejo cuando algo falla
- No es una práctica estándar en la industria

**⚙️ Implementación:**
```
1. Duplicar definiciones de tablas compartidas
2. Usar CREATE TABLE IF NOT EXISTS
3. Validar esquemas con tests
4. Tiempo: 5-6 horas + mantenimiento continuo
```

**🎯 Impacto:**
- ✅ Proyectos independientes
- ❌ Riesgo alto de inconsistencias
- ❌ Mantenimiento complicado

---

### Opción 3: Crear proyecto separado "database-schema" que ejecuta primero

**Cómo funciona:**
```
Nuevo proyecto: edugo-database-schema/
├─ migrations/
│   ├─ 001_create_users.sql
│   ├─ 002_create_schools.sql
│   └─ 003_create_materials.sql  (¿o solo tablas compartidas?)

Orden en CI/CD:
1. edugo-database-schema migrate
2. api-admin migrate (solo cambios específicos)
3. api-mobile migrate (solo cambios específicos)
```

**✅ Pros:**
- Separación total de concerns
- Esquema centralizado y versionado
- Fácil de auditar cambios de BD

**❌ Contras:**
- Nuevo proyecto = más complejidad
- Overhead de mantenimiento de otro repo
- Requiere coordinación para cambios

**⚙️ Implementación:**
```
1. Crear nuevo repo edugo-database-schema
2. Mover migraciones compartidas
3. Actualizar CI/CD (3 pasos en lugar de 2)
4. Tiempo: 6-8 horas
```

**🎯 Impacto:**
- ✅ Máxima claridad de ownership
- ❌ Complejidad adicional de gestión
- ⚠️ Overkill para proyecto actual

---

## 📝 TU DECISIÓN

**Opción elegida:** ____Otra_____ (Escribe: Opción 1, Opción 2, Opción 3, u "Otra")

**Si eliges "Otra", describe tu solución:**
```
Esto no son microservicios, ya que las bases de datos son compartidas y los servidores como rabbit
El enfoque de tener 2 apis, se enfoca mas por mas consumo de llamadas, donde api-mobile, seran los endpoint mas usado, y api-admin, son endpoint menos consumido, desde ese punto de vista, ninguna de las dos tienen responsabilidad clara del ambiente, en teoria la responsabilidad debe ser /Users/jhoanmedina/source/EduGo/repos-separados/edugo-dev-environment, ya que alli hay dockerfile y compose para crear el ambiente trasversal, pero dar esa responsabilidad, no es viable, porque en el momento de hacer los test de integracion, necesito tener las tablas creadas con datos de prueba, y mismo tema cuando quiera correr solo una api, crear el ambiente local minimo

Siento que aca puede venir un nuevo proyecto o rehusar el proyecto shared para que tenga un modulo de migracion, y scripts varios, alli estaria la responsabilidad de crear las tablas, y los scripts para crear el ambiente local minimo, y los scripts para correr los test de integracion, y asi cada api solo se enfoca en su logica de negocio, apostar por un nuevo proyecto me suena mas logico, ya que rehusar shared, lo saca de su estado congelado, ademas se esta recargando de responsabilidades

Entonces prefiero crear un nuevo proyecto, de base de datos, y que alli esten las migraciones de todas las tablas, y los scripts para crear el ambiente local minimo, y los scripts para correr los test de integracion (no logica de tests, sino scripts necesarios para la migracion), es capaz que hasta a nive de diseño arquitectonico, podemamos importar shared para usar el area de base de datos, y asi no duplicar codigo, y tener un proyecto dedicado a la base de datos, y scripts necesarios para crear el ambiente local minimo, y correr los test de integracion, y shared funciones mas generica

```

**Razón de tu decisión:**
```
[¿Por qué elegiste esta opción? ¿Qué te convenció?]
En el punto anterior explico bien mi razonamiento
```

**Tablas que quieres que api-admin cree (si aplica):**
```
[ ] users
[ ] schools
[ ] academic_units
[ ] memberships
[ ] Otra: ___N/A_______
```

**Tablas que quieres que api-mobile cree (si aplica):**
```
[ ] materials
[ ] assessment
[ ] assessment_attempt
[ ] assessment_attempt_answer
[ ] Otra: _____N/A_____
```

---

# SESIÓN 2: Contratos de Eventos RabbitMQ

## 🔴 PROBLEMA

**¿Qué pasa?**
- **api-mobile** publica evento `material.uploaded` cuando un docente sube un PDF
- **worker** consume ese evento para generar resumen con OpenAI
- Pero NO está especificado el formato JSON exacto del evento

**¿Por qué es un problema?**
- api-mobile puede enviar: `{"material_id": "123", "file_path": "/uploads/file.pdf"}`
- worker puede esperar: `{"materialId": "123", "s3_url": "s3://..."}`
- ↑ Incompatibilidad = evento se pierde en el vacío, worker no procesa nada

**¿Dónde se genera?**
- `api-mobile/internal/messaging/publisher.go` → Publica evento
- `worker/internal/messaging/consumer.go` → Consume evento
- Sin especificación compartida

**¿Qué inconveniente trae?**
- ❌ worker no procesa materiales (feature principal bloqueada)
- ❌ Breaking changes sin aviso (api-mobile actualiza formato, worker rompe)
- ❌ Debugging imposible (¿qué campo falta? ¿cuál sobra?)
- ❌ Desarrollo independiente bloqueado (necesitas coordinar manualmente)

---

## 💡 SOLUCIONES PROPUESTAS

### Opción 1: Documento de contratos JSON (enfoque lightweight)

**Cómo funciona:**
```markdown
# docs/EVENT_CONTRACTS.md

## material.uploaded (v1.0)

Publicado por: api-mobile
Consumido por: worker
Exchange: edugo.topic
Routing key: material.uploaded

{
  "event_id": "uuid-v7",              // ID único del evento
  "event_type": "material.uploaded",
  "event_version": "1.0",             // Importante para breaking changes
  "timestamp": "2025-11-15T10:30:00Z",
  "payload": {
    "material_id": "uuid",            // ID en PostgreSQL
    "school_id": "uuid",
    "teacher_id": "uuid",
    "file_url": "s3://bucket/key",
    "file_size_bytes": 2048000,
    "file_type": "application/pdf",
    "metadata": {
      "title": "Física Cuántica",
      "grade": "10th"
    }
  }
}
```

**✅ Pros:**
- Simple y rápido de implementar (1 hora)
- Fácil de leer y entender
- No requiere librerías adicionales
- Flexible para cambios rápidos

**❌ Contras:**
- No se valida automáticamente (confianza en devs)
- Requiere disciplina para mantenerlo actualizado
- Sin validación en tiempo de ejecución

**⚙️ Implementación:**
```
1. Crear docs/EVENT_CONTRACTS.md
2. Documentar 2-3 eventos principales
3. Referenciarlo en README de api-mobile y worker
4. Tiempo: 1-2 horas
```

**🎯 Impacto:**
- ✅ Claridad inmediata
- ✅ Fácil de iterar
- ⚠️ Requiere disciplina manual

---

### Opción 2: JSON Schema con validación automática

**Cómo funciona:**
```json
// shared/schemas/material-uploaded-v1.schema.json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["event_id", "event_type", "payload"],
  "properties": {
    "event_id": {"type": "string", "format": "uuid"},
    "event_type": {"const": "material.uploaded"},
    "event_version": {"const": "1.0"},
    "payload": {
      "type": "object",
      "required": ["material_id", "file_url"],
      "properties": {
        "material_id": {"type": "string", "format": "uuid"},
        "file_url": {"type": "string", "format": "uri"}
      }
    }
  }
}
```

**Uso en código:**
```go
// api-mobile: Validar antes de publicar
if err := validator.Validate(event, schema); err != nil {
    return fmt.Errorf("invalid event: %w", err)
}
publisher.Publish(event)

// worker: Validar al consumir
if err := validator.Validate(event, schema); err != nil {
    logger.Error("invalid event received", err)
    return // o enviar a DLQ
}
```

**✅ Pros:**
- Validación automática en runtime
- Errores detectados inmediatamente
- Documentación ejecutable (schema = contrato)
- Breaking changes detectados antes de producción

**❌ Contras:**
- Más complejo de implementar (librería de validación)
- Overhead de performance (validación en cada evento)
- Curva de aprendizaje de JSON Schema

**⚙️ Implementación:**
```
1. Crear schemas/ en shared/
2. Agregar librería de validación (xeipuuv/gojsonschema)
3. Implementar validación en publisher/consumer
4. Tiempo: 4-5 horas
```

**🎯 Impacto:**
- ✅ Máxima seguridad
- ✅ Errores detectados temprano
- ⚠️ Mayor complejidad técnica

---

### Opción 3: Protobuf (enfoque enterprise)

**Cómo funciona:**
```protobuf
// shared/protos/events.proto
syntax = "proto3";

message MaterialUploaded {
  string event_id = 1;
  string event_type = 2;
  string event_version = 3;
  google.protobuf.Timestamp timestamp = 4;

  message Payload {
    string material_id = 1;
    string school_id = 2;
    string teacher_id = 3;
    string file_url = 4;
    int64 file_size_bytes = 5;
  }

  Payload payload = 5;
}
```

**✅ Pros:**
- Tipado fuerte (compilador detecta errores)
- Más eficiente en tamaño (binary vs JSON)
- Versionamiento built-in
- Usado en producción por Google, Uber, Netflix

**❌ Contras:**
- Complejidad alta (protoc, generación de código)
- Curva de aprendizaje
- Overkill para proyecto actual
- Requiere cambio de paradigma (no es JSON)

**⚙️ Implementación:**
```
1. Setup protoc compiler
2. Definir .proto files
3. Generar código Go
4. Actualizar publisher/consumer
5. Tiempo: 8-10 horas + aprendizaje
```

**🎯 Impacto:**
- ✅ Máxima robustez
- ❌ Complejidad excesiva para MVP
- ⚠️ Recomendado solo post-MVP

---

## 📝 TU DECISIÓN

**Opción elegida:** ____2_____ (Escribe: Opción 1, Opción 2, Opción 3, u "Otra")

**Si eliges "Otra", describe tu solución:**
```
[Tu solución aquí]
```

**Razón de tu decisión:**
```
[¿Por qué elegiste esta opción?]
Quiero que aunque sea un poco mas complejo al inicio, es mas estaticos y estandarizado
```

**Eventos que necesitas documentar (marca los que aplican):**
```
[X] material.uploaded (api-mobile → worker)
[X] assessment.generated (worker → api-mobile)
[X] material.deleted (api-mobile → worker)
[X] student.enrolled (api-admin → api-mobile)
[ ] Otro: __________
```

**Estrategia de versionamiento que prefieres:**
```
[X] event_version en JSON (ej: "1.0", "1.1", "2.0")
[ ] Routing keys separados (ej: material.uploaded.v1, material.uploaded.v2)
[ ] Sin versionamiento por ahora (agregar después si es necesario)
[ ] Otra: __________
```

---

# SESIÓN 3: docker-compose.yml para Desarrollo Local

## 🔴 PROBLEMA

**¿Qué pasa?**
- El archivo `dev-environment/docker-compose.yml` **NO EXISTE**
- Los scripts `setup.sh`, `seed-data.sh` **NO EXISTEN**
- Seeds de datos de prueba **NO EXISTEN**

**¿Por qué es un problema?**
- Un desarrollador nuevo clona el repo y... ¿cómo levanta PostgreSQL? ¿MongoDB? ¿RabbitMQ?
- Cada dev configura a su manera → inconsistencias
- Tests de integración no se pueden ejecutar sin infraestructura

**¿Dónde se genera?**
- Proyecto `dev-environment` existe pero está vacío (solo documentación)

**¿Qué inconveniente trae?**
- ❌ Onboarding de nuevos devs es manual y lento (1-2 horas)
- ❌ Tests de integración no se pueden ejecutar en local
- ❌ CI/CD no puede ejecutar tests de integración
- ❌ Desarrollo desatendido por IA bloqueado (no puede levantar infra)
- ❌ Cada dev con versiones diferentes de PostgreSQL/MongoDB

---

## 💡 SOLUCIONES PROPUESTAS

### Opción 1: docker-compose.yml completo con todos los servicios

**Cómo funciona:**
```yaml
# dev-environment/docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    ports: ["5432:5432"]
    environment:
      POSTGRES_DB: edugo_dev
      POSTGRES_USER: edugo
      POSTGRES_PASSWORD: changeme
    volumes:
      - postgres_data:/var/lib/postgresql/data

  mongodb:
    image: mongo:7.0
    ports: ["27017:27017"]
    volumes:
      - mongo_data:/data/db

  rabbitmq:
    image: rabbitmq:3.12-management-alpine
    ports:
      - "5672:5672"    # AMQP
      - "15672:15672"  # Management UI

  # Herramientas opcionales
  mongo-express:
    image: mongo-express
    ports: ["8082:8081"]
    profiles: ["tools"]

  pgadmin:
    image: dpage/pgadmin4
    ports: ["5050:80"]
    profiles: ["tools"]

volumes:
  postgres_data:
  mongo_data:
```

**Scripts incluidos:**
```bash
# scripts/setup.sh
#!/bin/bash
docker-compose up -d
sleep 5
./scripts/seed-data.sh

# scripts/seed-data.sh
#!/bin/bash
psql -h localhost -U edugo -d edugo_dev < seeds/postgres/users.sql
mongosh localhost:27017/edugo < seeds/mongodb/materials.js
```

**✅ Pros:**
- Setup en 1 comando: `./scripts/setup.sh`
- Todos los devs con misma configuración
- CI/CD puede usar los mismos servicios
- Herramientas de debugging opcionales (PgAdmin, Mongo Express)

**❌ Contras:**
- Requiere Docker instalado (dependency)
- Seeds de datos hay que crearlos manualmente

**⚙️ Implementación:**
```
1. Crear docker-compose.yml
2. Crear scripts/setup.sh
3. Crear scripts/seed-data.sh
4. Crear seeds básicos (5-10 registros por tabla)
5. Crear .env.example
6. Tiempo: 4-5 horas
```

**🎯 Impacto:**
- ✅ Onboarding de 2 horas → 5 minutos
- ✅ Tests de integración habilitados
- ✅ Desarrollo consistente entre devs

---

### Opción 2: docker-compose.yml mínimo + instrucciones manuales

**Cómo funciona:**
```yaml
# Solo servicios básicos, sin herramientas
services:
  postgres:
    image: postgres:15-alpine
    ports: ["5432:5432"]

  mongodb:
    image: mongo:7.0
    ports: ["27017:27017"]

  rabbitmq:
    image: rabbitmq:3.12-alpine
    ports: ["5672:5672"]
```

**Sin scripts automatizados:**
```markdown
# README.md
## Setup Manual

1. docker-compose up -d
2. Ejecutar migraciones: cd api-admin && make migrate
3. Cargar datos: psql < seeds/users.sql (crear manualmente)
```

**✅ Pros:**
- Más simple (menos código)
- Flexibilidad para cada dev

**❌ Contras:**
- Setup sigue siendo manual (10-15 min)
- Propenso a errores (¿qué si olvido un paso?)
- Sin seeds = cada dev crea sus datos

**⚙️ Implementación:**
```
1. Crear docker-compose.yml mínimo
2. Documentar pasos en README
3. Tiempo: 1-2 horas
```

**🎯 Impacto:**
- ✅ Básico funcionando
- ⚠️ Requiere seguir pasos manuales
- ❌ No ideal para IA desatendida

---

### Opción 3: Makefile con comandos unificados

**Cómo funciona:**
```makefile
# dev-environment/Makefile

.PHONY: setup
setup: ## Levantar todo y sembrar datos
	@docker-compose up -d
	@echo "Esperando que servicios estén listos..."
	@sleep 10
	@$(MAKE) seed

.PHONY: seed
seed: ## Sembrar datos de prueba
	@echo "Sembrando PostgreSQL..."
	@psql -h localhost -U edugo -f seeds/postgres/all.sql
	@echo "Sembrando MongoDB..."
	@mongosh localhost:27017/edugo < seeds/mongodb/all.js

.PHONY: teardown
teardown: ## Limpiar todo
	@docker-compose down -v

.PHONY: reset
reset: teardown setup ## Reset completo (teardown + setup)
```

**Uso:**
```bash
make setup      # Primera vez o después de cambios
make reset      # Limpiar y empezar de cero
make teardown   # Limpiar al terminar
```

**✅ Pros:**
- Comandos simples y memorizables
- Makefile es estándar en proyectos Go
- Fácil agregar comandos nuevos

**❌ Contras:**
- Requiere make instalado (pero Go devs lo tienen)
- Un poco más de código que scripts bash

**⚙️ Implementación:**
```
1. Crear Makefile con targets
2. Crear docker-compose.yml
3. Crear seeds/
4. Documentar en README: "make setup"
5. Tiempo: 4-5 horas
```

**🎯 Impacto:**
- ✅ Setup en 1 comando memorable
- ✅ Fácil de extender
- ✅ Convención estándar

---

## 📝 TU DECISIÓN

**Opción elegida:** ____Otra_____ (Escribe: Opción 1, Opción 2, Opción 3, u "Otra")

**Si eliges "Otra", describe tu solución:***
```
Bueno esto esta muy relacionado con el punto 1, ya en ese punto se mando hacer un proyecto para manejar el tema de la migracion, entonces en este punto, ese proyecto nuevo, puede tener el docker-compose.yml, los scripts de setup y seed, y los seeds de datos, asi todo lo relacionado con la base de datos y el ambiente local minimo, queda en un solo proyecto, y cada api solo se enfoca en su logica de negocio, ademas de que ese proyecto nuevo, puede rehusar shared para no duplicar codigo, y asi shared sigue congelado en su estado actual, a lo cual el nombre de proyecto deberia cambiar, ya que si es cierto que su funcion principal era migracion de base de datos, pero aca se va agregar otros contenedores, por eso, dime como deberiamos cambiarlo.
Este proyecto unificado debe tener la responsabilidad de
* Scritps de estructura de las bases de datos y contraints varios
* Scritps con datos de inicios si los hay
* Scritps con datos de prueba (seeds)
* Aunque no lo veo a nivel de implementacion, te coloco lo que se debe tener, y luego le damos la vuelta de como lo va a invocar cada proyecto
    * Docker file y Docker compose:
      * N Docker File por cada proyecto
      * Docker compose unificado
      * Docker compose de cada proyecto, es decir, si api admin no necesita rabbit no deberia levantarlo
      * El punto anterior es que no se como diagramarlo pero la idea que si quiero prgramar en api-admin, y no tengo el ambiente ejecutar lo que necesito como minimo, sabemos que la base de datos es todo.
      * No se si los testcontainer en go necesita docker compose para ellos, entonces pensar que no todos los proyectos prueba lo mismo
      * El proyecto /Users/jhoanmedina/source/EduGo/repos-separados/edugo-dev-environment deberia de tener acceso al docker compose unificado, (como dije no se como hacerlo pero la idea es que se modifique en un solo lugar)
```

**Razón de tu decisión:**
```
[¿Por qué elegiste esta opción?]
```

**Servicios que necesitas en docker-compose:**
```
[X] PostgreSQL 15
[X] MongoDB 7.0
[X] RabbitMQ 3.12
[X] Mongo Express (herramienta visual para MongoDB)
[X] PgAdmin (herramienta visual para PostgreSQL)
[X] Redis (si lo necesitas para caché)
[ ] Otro: __________
```

**Seeds de datos que necesitas:**
```
[X] 2-3 usuarios de prueba (admin, teacher, student)
[X] 1-2 escuelas de prueba
[X] 3-5 materiales de prueba
[X] 1-2 assessments de prueba
[ ] Otro: __________
```

**Herramienta de ejecución preferida:**
```
[ ] Scripts bash (setup.sh, seed-data.sh)
[X] Makefile (make setup, make seed)
[X] Docker compose commands directos (docker-compose up)
[ ] Otra: __________
Creo que Makefile puede ayudar para cuando se quiera solo instalar lo que necesita la api, o si debe actualizar algo referente a este punto
Docker compose, cuando quieras levantar todo el ambiente, es decir cada proyecto tendra las 2 opciones pero el compose es para todo, makefile es para lo necesario del proyecto, y la solucion para los testcontainer alli si hay que saber como se puede centralizar
```

---

# SESIÓN 4: Sincronización PostgreSQL ↔ MongoDB

## 🔴 PROBLEMA

**¿Qué pasa?**
- La tabla `assessment` en **PostgreSQL** tiene columna `mongo_document_id VARCHAR(24)`
- Los quizzes/preguntas están en **MongoDB** colección `material_assessment`
- Pero NO está claro:
  - ¿Se crea primero el documento en MongoDB o el registro en PostgreSQL?
  - ¿Qué pasa si MongoDB falla después de crear en PostgreSQL?
  - ¿Qué pasa si PostgreSQL falla después de crear en MongoDB?

**¿Por qué es un problema?**
- Sin patrón definido → cada dev implementa diferente
- Riesgo de **orphan records**: registro en PostgreSQL sin documento en MongoDB (o viceversa)
- Riesgo de **race conditions**: dos sistemas se actualizan en orden impredecible

**¿Dónde se genera?**
- `worker/internal/services/assessment_service.go` → Genera assessment en MongoDB
- `api-mobile/internal/services/assessment_service.go` → Lee/actualiza assessment

**¿Qué inconveniente trae?**
- ❌ Datos inconsistentes (assessment exists en PG pero no en Mongo)
- ❌ 500 errors al intentar leer (app busca en Mongo pero no existe)
- ❌ Debugging complejo (¿dónde está el problema?)
- ❌ Rollbacks imposibles (¿cómo deshacer cambio en 2 BDs?)

---

## 💡 SOLUCIONES PROPUESTAS

### Opción 1: MongoDB primero + Evento (Eventual Consistency)

**Cómo funciona:**
```
Flujo de creación:
1. Worker genera assessment en MongoDB
   ├─ Colección: material_assessment
   ├─ _id: ObjectId("507f1f77bcf86cd799439011")
   └─ Contiene: {questions: [...], metadata: {...}}

2. Worker publica evento: assessment.generated
   ├─ Exchange: edugo.topic
   ├─ Routing key: assessment.generated
   └─ Payload: {material_id: "uuid", mongo_id: "507f..."}

3. api-mobile consume evento
   ├─ Crea registro en PostgreSQL.assessment
   ├─ Guarda: mongo_document_id = "507f..."
   └─ material_id = "uuid"

4. Si PostgreSQL falla:
   ├─ Retry automático (3 intentos con backoff)
   ├─ Si sigue fallando → Dead Letter Queue
   └─ Operaciones puede reintentar manualmente
```

**Manejo de inconsistencias:**
```go
// api-mobile: GET /assessment/:id
func (s *Service) GetAssessment(ctx, id) (*Assessment, error) {
    // 1. Buscar en PostgreSQL
    pgRecord, err := s.pgRepo.Get(id)
    if err != nil {
        return nil, err
    }

    // 2. Validar que MongoDB existe
    mongoDoc, err := s.mongoRepo.Get(pgRecord.MongoDocumentID)
    if err != nil {
        // MongoDB doc no existe → marcar como inválido
        return nil, ErrAssessmentIncomplete
    }

    // 3. Combinar datos
    return merge(pgRecord, mongoDoc), nil
}
```

**Validación diaria (cronjob):**
```sql
-- Encuentra orphan records en PostgreSQL
SELECT a.id, a.mongo_document_id
FROM assessment a
WHERE NOT EXISTS (
  SELECT 1 FROM mongodb.material_assessment
  WHERE _id::text = a.mongo_document_id
);
```

**✅ Pros:**
- MongoDB es "fuente de verdad" para contenido (quizzes generados por IA)
- PostgreSQL es "índice" para búsquedas relacionales
- Patrón estándar en microservicios (eventual consistency)
- Fácil de implementar

**❌ Contras:**
- Hay un pequeño período donde MongoDB tiene dato pero PostgreSQL no
- Requiere manejo de eventos (pero ya lo tienes con RabbitMQ)

**⚙️ Implementación:**
```
1. worker: Publicar evento assessment.generated después de Mongo
2. api-mobile: Consumer de evento para crear en PostgreSQL
3. Implementar retry logic (3 intentos)
4. Cronjob de validación (opcional)
5. Tiempo: 3-4 horas
```

**🎯 Impacto:**
- ✅ Patrón probado en producción
- ✅ MongoDB es source of truth correcto
- ⚠️ Requiere manejo de eventual consistency en UI

---

### Opción 2: PostgreSQL primero + MongoDB después (Synchronous)

**Cómo funciona:**
```
Flujo de creación:
1. Worker crea registro en PostgreSQL.assessment
   ├─ material_id: "uuid"
   ├─ mongo_document_id: NULL (por ahora)
   ├─ status: "processing"

2. Worker genera assessment en MongoDB
   ├─ _id: ObjectId("507f...")
   ├─ Contiene: {questions: [...]}

3. Worker actualiza PostgreSQL
   ├─ SET mongo_document_id = "507f..."
   ├─ SET status = "completed"

4. Si MongoDB falla:
   ├─ PostgreSQL queda con status = "processing"
   ├─ Retry automático
   └─ UI muestra "Generando assessment..."
```

**Manejo de fallos:**
```go
func (w *Worker) ProcessMaterial(material) error {
    // 1. Crear placeholder en PostgreSQL
    assessment, _ := w.pgRepo.Create(&Assessment{
        MaterialID: material.ID,
        Status:     "processing",
    })

    // 2. Generar en MongoDB
    mongoDoc, err := w.aiService.GenerateQuiz(material)
    if err != nil {
        // MongoDB falló → marcar como failed
        w.pgRepo.Update(assessment.ID, "failed", "")
        return err
    }

    // 3. Actualizar PostgreSQL con referencia
    w.pgRepo.Update(assessment.ID, "completed", mongoDoc.ID)
    return nil
}
```

**✅ Pros:**
- Estado siempre visible en PostgreSQL (processing/completed/failed)
- UI puede mostrar progreso en tiempo real
- Fácil de entender (flujo secuencial)

**❌ Contras:**
- PostgreSQL tiene "basura" temporal (registros con status=processing)
- Más transacciones (create + update en lugar de solo create)
- PostgreSQL no es source of truth de contenido

**⚙️ Implementación:**
```
1. worker: Crear en PostgreSQL primero
2. worker: Generar en MongoDB
3. worker: Update PostgreSQL con referencia
4. Agregar columna "status" a assessment
5. Tiempo: 3-4 horas
```

**🎯 Impacto:**
- ✅ UX más claro (progreso visible)
- ✅ Rollback más simple
- ⚠️ Registros temporales en PostgreSQL

---

### Opción 3: Transacción distribuida (Saga Pattern)

**Cómo funciona:**
```
Saga de creación de assessment:
1. Paso 1: Crear en MongoDB
   └─ Compensación: Borrar de MongoDB

2. Paso 2: Crear en PostgreSQL
   └─ Compensación: Borrar de PostgreSQL

Si Paso 2 falla:
├─ Ejecutar compensación de Paso 1
└─ Rollback completo (como si nunca pasó)
```

**Implementación con Saga library:**
```go
saga := saga.New()

saga.AddStep(
    // Forward
    func() error {
        mongoDoc, err := w.mongoRepo.Create(assessment)
        w.saga.Set("mongo_id", mongoDoc.ID)
        return err
    },
    // Compensate
    func() error {
        return w.mongoRepo.Delete(w.saga.Get("mongo_id"))
    },
)

saga.AddStep(
    // Forward
    func() error {
        return w.pgRepo.Create(&Assessment{
            MongoDocumentID: w.saga.Get("mongo_id"),
        })
    },
    // Compensate
    func() error {
        return w.pgRepo.Delete(assessment.ID)
    },
)

saga.Execute()
```

**✅ Pros:**
- Consistencia fuerte (todo o nada)
- No hay datos inconsistentes
- Patrón enterprise-grade

**❌ Contras:**
- Complejidad alta (Saga library o custom)
- Overhead de performance (compensaciones)
- Overkill para MVP

**⚙️ Implementación:**
```
1. Instalar saga library o implementar custom
2. Definir steps + compensations
3. Tests exhaustivos
4. Tiempo: 8-10 horas
```

**🎯 Impacto:**
- ✅ Máxima consistencia
- ❌ Complejidad excesiva para caso actual
- ⚠️ Recomendado solo si es crítico de negocio

---

## 📝 TU DECISIÓN

**Opción elegida:** ____A_____ (Escribe: Opción 1, Opción 2, Opción 3, u "Otra")

**Si eliges "Otra", describe tu solución:**
```
[Tu solución aquí]
```

**Razón de tu decisión:**
```
[¿Por qué elegiste esta opción?]
Sin tanto rollo, no sera la primera y ultima que queda datos basura, y prefiero mas mongo con esos datos huerfanos que pg, ya que pg es mas critico y es indice
```

**Estrategia de manejo de inconsistencias:**
```
[X] Eventual consistency (está OK si hay delay de segundos)
[ ] Strong consistency (DEBE ser consistente siempre)
[ ] Cronjob de reconciliación diario
[ ] Alertas cuando hay inconsistencias
[ ] Otra: __________
```

**¿Qué base de datos es "fuente de verdad" del contenido?**
```
[X] MongoDB (tiene las preguntas/quizzes completos)
[ ] PostgreSQL (tiene metadata y relaciones)
[ ] Ambas son source of truth de su dominio
```

---

# 📋 RESUMEN DE TUS DECISIONES

Una vez que completes las 4 sesiones, copia este resumen y envíamelo:

```
DECISIONES TOMADAS:

1. Ownership de Tablas: [Opción elegida]
   - api-admin crea: [tablas]
   - api-mobile crea: [tablas]

2. Contratos de Eventos: [Opción elegida]
   - Eventos a documentar: [lista]
   - Versionamiento: [estrategia]

3. docker-compose.yml: [Opción elegida]
   - Servicios incluidos: [lista]
   - Seeds necesarios: [lista]
   - Herramienta: [bash/make/otra]

4. Sincronización PG ↔ Mongo: [Opción elegida]
   - Patrón: [eventual/strong consistency]
   - Source of truth: [MongoDB/PostgreSQL/ambas]
```

---

# 🚀 PRÓXIMOS PASOS

Después de que completes tus decisiones:

1. **Guarda este archivo** con tus respuestas
2. **Avísame** que terminaste
3. **Yo generaré:**
   - ✅ Tareas específicas basadas en tus decisiones
   - ✅ Archivos a crear con contenido exacto
   - ✅ Orden de ejecución optimizado
   - ✅ Tiempo estimado por tarea

**Tiempo total estimado para leer y decidir:** 30-45 minutos
**Tiempo total de implementación (después):** 10-18 horas (dependiendo de tus decisiones)

---

¡Tómate tu tiempo para decidir! No hay respuestas incorrectas, solo trade-offs diferentes según tus prioridades (velocidad vs robustez, simplicidad vs escalabilidad, etc).
