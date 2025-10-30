# 🐳 Infraestructura Docker - EduGo

## 🏗️ Estructura Docker

EduGo usa una **arquitectura Docker modular**:

- **Cada proyecto** tiene su propio `Dockerfile` y `docker-compose.yml`
- **Raíz**: `docker-compose.yml` orquestador con infraestructura compartida
- **Red compartida**: `edugo-network` para comunicación entre servicios

```
/
├── docker-compose.yml                   # Orquestador (infraestructura + apps)
└── source/
    ├── api-mobile/
    │   ├── Dockerfile                   # Build standalone
    │   └── docker-compose.yml           # Run standalone
    ├── api-administracion/
    │   ├── Dockerfile
    │   └── docker-compose.yml
    └── worker/
        ├── Dockerfile
        └── docker-compose.yml
```

**Ventajas**:
✓ Ejecutar proyecto individual: `cd source/api-mobile && docker-compose up`
✓ Ejecutar stack completo: `make up` (desde raíz)
✓ Desarrollo modular y fácil mantenimiento

---

## 📦 Servicios Incluidos

Este stack incluye todos los servicios necesarios:

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| **PostgreSQL** | 5432 | Base de datos relacional principal |
| **MongoDB** | 27017 | Base de datos NoSQL para materiales procesados |
| **RabbitMQ** | 5672, 15672 | Cola de mensajes + Management UI |
| **API Mobile** | 8080 | API para aplicación móvil |
| **API Administración** | 8081 | API para panel administrativo |
| **Worker** | - | Procesador de materiales en background |

---

## 🚀 Inicio Rápido

### Prerrequisitos

- Docker instalado (versión 20.10+)
- Docker Compose instalado (versión 2.0+)
- (Opcional) Make instalado para usar comandos simplificados

### 1. Configuración Inicial

Copia el archivo de ejemplo de variables de entorno:

```bash
cp .env.example .env
```

Edita `.env` y configura tu API Key de OpenAI:

```env
OPENAI_API_KEY=sk-tu-api-key-real
```

### 2. Levantar los Servicios

**Opción A: Usando Make (recomendado)**

```bash
make build  # Construir imágenes
make up     # Levantar servicios
```

**Opción B: Usando Docker Compose directamente**

```bash
docker-compose build
docker-compose up -d
```

### 3. Verificar que Todo Funciona

```bash
make status
# o
docker-compose ps
```

Deberías ver todos los servicios con estado `Up (healthy)`.

---

## 🔗 Acceso a los Servicios

Una vez levantados los servicios, puedes acceder a:

### APIs

- **API Mobile Swagger**: http://localhost:8080/swagger/index.html
- **API Admin Swagger**: http://localhost:8081/swagger/index.html

### Bases de Datos

**PostgreSQL**:
```bash
# Desde tu máquina local
psql -h localhost -p 5432 -U edugo_user -d edugo

# Desde dentro del contenedor
docker exec -it edugo-postgres psql -U edugo_user -d edugo
```

**MongoDB**:
```bash
# Desde tu máquina local
mongosh mongodb://edugo_admin:edugo_pass@localhost:27017/edugo?authSource=admin

# Desde dentro del contenedor
docker exec -it edugo-mongodb mongosh -u edugo_admin -p edugo_pass --authenticationDatabase admin edugo
```

### RabbitMQ Management UI

- **URL**: http://localhost:15672
- **Usuario**: `edugo_user`
- **Contraseña**: `edugo_pass`

---

## 📋 Comandos Útiles (Make)

```bash
make help               # Ver todos los comandos disponibles
make build              # Construir imágenes
make up                 # Levantar servicios
make down               # Detener servicios
make logs               # Ver logs de todos los servicios
make logs-api-mobile    # Ver logs de API Mobile
make logs-api-admin     # Ver logs de API Admin
make logs-worker        # Ver logs del Worker
make restart            # Reiniciar todos los servicios
make clean              # Limpiar todo (contenedores, volúmenes, imágenes)
make status             # Ver estado de los servicios
make swagger            # Regenerar documentación Swagger
make test               # Ejecutar tests
```

---

## 🛠️ Desarrollo Local (Sin Docker)

Si prefieres ejecutar las APIs localmente (sin Docker):

### 1. Levantar Solo las Bases de Datos

```bash
docker-compose up -d postgres mongodb rabbitmq
```

### 2. Ejecutar las APIs Localmente

```bash
# Terminal 1 - API Mobile
make dev-api-mobile
# o
cd source/api-mobile && go run cmd/main.go

# Terminal 2 - API Admin
make dev-api-admin
# o
cd source/api-administracion && go run cmd/main.go

# Terminal 3 - Worker
make dev-worker
# o
cd source/worker && go run cmd/main.go
```

---

## 🗄️ Inicialización de Bases de Datos

Las bases de datos se inicializan automáticamente al levantar los contenedores por primera vez:

### PostgreSQL

Los scripts en `source/scripts/postgresql/` se ejecutan automáticamente:
- `01_schema.sql` - Crea las 17 tablas
- `02_indexes.sql` - Crea índices
- `03_mock_data.sql` - Carga datos de prueba

### MongoDB

Los scripts en `source/scripts/mongodb/` se ejecutan automáticamente:
- `01_collections.js` - Crea colecciones con validación
- `02_indexes.js` - Crea índices
- `03_mock_data.js` - Carga datos de prueba

**Nota**: Los scripts de MongoDB deben tener extensión `.js` y estar en el directorio de inicialización.

---

## 🔧 Troubleshooting

### Los servicios no inician

```bash
# Ver logs de todos los servicios
make logs

# Ver logs de un servicio específico
docker-compose logs postgres
docker-compose logs mongodb
docker-compose logs api-mobile
```

### Las bases de datos no se inicializan

```bash
# Eliminar volúmenes y reiniciar (¡CUIDADO! Esto borra todos los datos)
make clean
make build
make up
```

### Puerto ya en uso

Si algún puerto está ocupado, puedes cambiarlos en `docker-compose.yml`:

```yaml
ports:
  - "8080:8080"  # Cambiar primer número (puerto host)
```

### Reconstruir una imagen específica

```bash
docker-compose build api-mobile
docker-compose up -d api-mobile
```

---

## 📊 Health Checks

Todos los servicios tienen health checks configurados:

- **PostgreSQL**: Se verifica con `pg_isready`
- **MongoDB**: Se verifica con `mongosh ping`
- **RabbitMQ**: Se verifica con `rabbitmq-diagnostics ping`

Las APIs esperan a que las bases de datos estén `healthy` antes de iniciar (gracias a `depends_on: condition: service_healthy`).

---

## 🧹 Limpieza

### Detener servicios (mantener volúmenes)
```bash
make down
```

### Limpieza completa (eliminar todo)
```bash
make clean
```

### Eliminar solo volúmenes
```bash
docker-compose down -v
```

---

## 📝 Notas Importantes

1. **Volúmenes persistentes**: Los datos de PostgreSQL, MongoDB y RabbitMQ se persisten en volúmenes Docker. Sobreviven a `docker-compose down` pero se eliminan con `make clean`.

2. **Orden de inicio**: Docker Compose espera a que PostgreSQL y MongoDB estén `healthy` antes de iniciar las APIs y el Worker.

3. **Variables de entorno**: Las credenciales están configuradas en `docker-compose.yml`. Para producción, usa archivos `.env` y no las commitees.

4. **API Key de OpenAI**: El Worker necesita `OPENAI_API_KEY` configurada. Si no la tienes, el Worker iniciará pero fallará al procesar materiales.

5. **Estructura de carpetas**: Los Dockerfiles asumen la estructura POST-reestructuración (Fase 2). No funcionarán hasta completar la Fase 2 del plan de refactorización.

---

## 🔄 Próximos Pasos

Después de la **Fase 2 (Reestructuración)**, podrás:

1. Construir las imágenes: `make build`
2. Levantar el stack completo: `make up`
3. Acceder a Swagger UIs
4. Probar los endpoints

---

**Documentación actualizada**: 2025-10-29
