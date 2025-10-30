# 🚀 Scripts de Gestión de Servicios

Scripts bash para facilitar el desarrollo local sin Docker.

---

## 📋 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `./start-all.sh` | Inicia los 3 servicios en background |
| `./stop-all.sh` | Detiene todos los servicios |
| `./logs-all.sh` | Ver logs de todos los servicios en tiempo real |
| `./status.sh` | Ver estado de los servicios |

---

## 🚀 Uso

### 1. Iniciar Todos los Servicios

```bash
./start-all.sh
```

**Salida**:
```
╔════════════════════════════════════════╗
║     🚀 Iniciando Servicios EduGo      ║
╔════════════════════════════════════════╗

Ambiente: local

[1/3] Iniciando API Mobile...
✓ API Mobile corriendo (PID: 12345)
  → http://localhost:8080/swagger/index.html

[2/3] Iniciando API Administración...
✓ API Admin corriendo (PID: 12346)
  → http://localhost:8081/swagger/index.html

[3/3] Iniciando Worker...
✓ Worker corriendo (PID: 12347)

╔════════════════════════════════════════╗
║      ✅ Todos los Servicios OK        ║
╔════════════════════════════════════════╗
```

**Los servicios corren en background y guardan logs en `logs/`**

### 2. Ver Estado

```bash
./status.sh
```

Muestra qué servicios están corriendo y sus PIDs.

### 3. Ver Logs

```bash
# Todos los logs en tiempo real
./logs-all.sh

# Log individual
tail -f logs/api-mobile.log
tail -f logs/api-admin.log
tail -f logs/worker.log
```

### 4. Detener Todos los Servicios

```bash
./stop-all.sh
```

**Salida**:
```
╔════════════════════════════════════════╗
║     ⏹️  Deteniendo Servicios EduGo    ║
╔════════════════════════════════════════╗

Deteniendo api-mobile (PID: 12345)...
✓ api-mobile detenido

Deteniendo api-admin (PID: 12346)...
✓ api-admin detenido

Deteniendo worker (PID: 12347)...
✓ worker detenido

╔════════════════════════════════════════╗
║     ✅ Todos los Servicios Detenidos  ║
╔════════════════════════════════════════╗
```

---

## ⚙️ Variables de Ambiente

Los scripts usan variables de ambiente con valores por defecto:

```bash
export APP_ENV=local
export POSTGRES_PASSWORD=edugo_pass
export MONGODB_URI=mongodb://edugo_admin:edugo_pass@localhost:27017/edugo?authSource=admin
export RABBITMQ_URL=amqp://edugo_user:edugo_pass@localhost:5672/
export OPENAI_API_KEY=sk-test-key
```

**Sobrescribir**:

```bash
APP_ENV=dev OPENAI_API_KEY=sk-real-key ./start-all.sh
```

---

## 📂 Archivos Generados

- `logs/api-mobile.log` - Log de API Mobile
- `logs/api-admin.log` - Log de API Admin
- `logs/worker.log` - Log de Worker
- `.running_services.pid` - PIDs de servicios corriendo (auto-eliminado al detener)

**Estos archivos están en `.gitignore`**

---

## 🔧 Troubleshooting

### Los servicios no inician

```bash
# Ver logs
cat logs/api-mobile.log
cat logs/api-admin.log
cat logs/worker.log

# Verificar dependencias
cd source/api-mobile && go mod download
```

### Puerto ya en uso

```bash
# Ver qué está usando el puerto
lsof -i :8080
lsof -i :8081

# Matar proceso
kill -9 <PID>
```

### Servicios quedaron huérfanos

```bash
# Buscar procesos Go
ps aux | grep "go run"

# Matar todos
pkill -f "go run cmd/main.go"
```

---

## 🆚 Scripts vs Make vs Docker

| Método | Cuándo Usar |
|--------|-------------|
| **Scripts** (`./start-all.sh`) | Desarrollo rápido, sin Docker, debugging directo |
| **Make** (`make run`) | Desarrollo por proyecto, más control |
| **Docker** (`make up`) | Producción-like, testing completo, CI/CD |

---

## 💡 Recomendaciones

**Desarrollo activo**:
```bash
# Usa los scripts para iteración rápida
./start-all.sh
# Haz cambios en código
./stop-all.sh
./start-all.sh
```

**Testing completo**:
```bash
# Usa Docker para ambiente production-like
make up
make test-all
make down
```

**Debugging**:
```bash
# Usa VSCode debugging (F5)
# O ejecuta proyecto individual: cd source/api-mobile && make run
```

---

**Creado**: 2025-10-29
