# Docker Local - Infraestructura Compartida

Infraestructura persistente para desarrollo local (3 proyectos).

## Servicios

- PostgreSQL (puerto 5432)
- MongoDB (puerto 27017)
- RabbitMQ (puertos 5672, 15672)

## Red Virtual

- **edugo-local-network**: Los 3 proyectos comparten esta red

## Volúmenes Persistentes

- edugo-postgres-local-data
- edugo-mongodb-local-data
- edugo-rabbitmq-local-data

**Datos NO se eliminan** al hacer down.

## Uso

```bash
# Iniciar infraestructura
docker-compose -f docker/docker-compose.local.yml up -d

# Ver estado
docker-compose -f docker/docker-compose.local.yml ps

# Detener (mantiene datos)
docker-compose -f docker/docker-compose.local.yml stop

# Iniciar de nuevo (reutiliza datos)
docker-compose -f docker/docker-compose.local.yml start

# Destruir TODO (incluye datos)
docker-compose -f docker/docker-compose.local.yml down -v
```

## Secretos

Lee desde `docker/.env.local` (valores de desarrollo OK).
