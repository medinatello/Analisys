# GitLab Runner - Uso On-Demand (Bajo Demanda)

**Proyecto:** EduGo
**Estrategia:** Runner manual (no como servicio permanente)
**Razón:** Deploys ocasionales (~1 vez cada 3 días)

---

## 🎯 Filosofía: Runner On-Demand

**NO necesitas** tener GitLab Runner corriendo 24/7 como un servicio si solo:
- Haces deploys ocasionalmente
- Desarrollas en tu Mac personal
- No tienes pipelines corriendo constantemente

**Estrategia recomendada:**
- Iniciar runner manualmente cuando necesites hacer push/deploy
- Detenerlo cuando termines
- Ahorra recursos de tu Mac

---

## 🚀 Cómo Usar el Runner

### Opción 1: Scripts Automáticos (Recomendado)

#### Iniciar Runner

```bash
# Desde la raíz del proyecto
./scripts/gitlab-runner-start.sh
```

**Qué hace:**
- ✅ Verifica que gitlab-runner está instalado
- ✅ Verifica que Docker está corriendo
- ✅ Muestra la configuración del runner
- ✅ Inicia el runner en modo foreground
- ⚠️ **Mantén esta terminal abierta mientras lo usas**

#### Verificar Estado

```bash
# En otra terminal
./scripts/gitlab-runner-status.sh
```

**Qué hace:**
- Muestra si el runner está corriendo
- Lista los runners registrados
- Muestra la configuración

#### Detener Runner

**Simplemente presiona `Ctrl+C`** en la terminal donde corre `gitlab-runner-start.sh`

---

### Opción 2: Comandos Manuales

#### Iniciar
```bash
gitlab-runner run
```

**⚠️ Mantén la terminal abierta**

#### Verificar
```bash
# En otra terminal
gitlab-runner status
```

#### Detener
**Presiona `Ctrl+C`** en la terminal del runner

---

## 📊 Flujo de Trabajo Típico

### Cuando Necesitas Hacer Deploy

```bash
# 1. Inicia runner (terminal 1)
./scripts/gitlab-runner-start.sh

# 2. Haz tus cambios y push (terminal 2)
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main

# 3. Ve a GitLab y monitorea el pipeline
open https://gitlab.com/groups/edugogroup/-/pipelines

# 4. Espera a que termine el pipeline (1-5 minutos)

# 5. Detén el runner (terminal 1)
# Presiona Ctrl+C
```

### Cuando NO Estás Haciendo Deploy

**Simplemente NO corras el runner.** Tu Mac estará más ligero. 😊

---

## 🔄 Modo Servicio Permanente (Alternativa)

Si en el futuro decides que prefieres tener el runner **siempre activo** (por ejemplo, si empiezas a hacer deploys muy frecuentes), puedes instalarlo como servicio:

```bash
# Instalar como servicio de macOS
sudo gitlab-runner install --user jhoanmedina

# Iniciar servicio
sudo gitlab-runner start

# El runner iniciará automáticamente al encender tu Mac
```

**Desventajas:**
- Consume recursos constantemente
- Inicia automáticamente al encender el Mac

**Ventajas:**
- No tienes que acordarte de iniciarlo
- Pipelines se ejecutan inmediatamente al hacer push

---

## 📋 Verificación Rápida

### ¿El runner está corriendo ahora?

```bash
./scripts/gitlab-runner-status.sh
```

### Ver configuración del runner

```bash
cat ~/.gitlab-runner/config.toml
```

### Ver logs en tiempo real (cuando está corriendo)

En la terminal donde ejecutaste `gitlab-runner-start.sh`, verás logs como:

```
Starting multi-runner from /Users/jhoanmedina/.gitlab-runner/config.toml...
Checking for jobs... received
Executing job...
Job succeeded
```

---

## 🎯 Resumen - Tu Caso de Uso

| Situación | Acción |
|-----------|--------|
| **Voy a hacer push/deploy** | `./scripts/gitlab-runner-start.sh` (mantén abierta la terminal) |
| **Terminé el deploy** | Presiona `Ctrl+C` en la terminal del runner |
| **¿Está corriendo?** | `./scripts/gitlab-runner-status.sh` |
| **Deploy urgente** | Inicia runner, haz push, monitorea GitLab, detén runner |

---

## ⚙️ Configuración Actual

**Ubicación:** `~/.gitlab-runner/config.toml`

**Tu runner:**
- **ID:** `hycW5iu7o`
- **URL:** `https://gitlab.com`
- **Executor:** `docker`
- **Default image:** `golang:1.23-alpine`
- **Tags:** `macos`, `docker`, `go`, `local`

---

## 🔐 Seguridad

**Tu token de runner está guardado en:**
```
~/.gitlab-runner/config.toml
```

**⚠️ NO commitear** ese archivo a Git (ya está en .gitignore)

---

## 💡 Recomendación Final

**Para tu caso (deploys cada 3 días):**

1. **NO instales como servicio permanente**
2. **USA el script:** `./scripts/gitlab-runner-start.sh` solo cuando necesites
3. **Detén el runner** cuando termines (`Ctrl+C`)

Esto:
- ✅ Ahorra batería de tu Mac
- ✅ Ahorra recursos (CPU/RAM)
- ✅ Runner solo corre cuando lo necesitas
- ✅ Mismo resultado que servicio permanente

---

## 🎉 Estado Actual: LISTO PARA USAR

Tu runner está **registrado** ✅ y **configurado** ✅.

**Para probarlo ahora:**

```bash
# Terminal 1: Inicia el runner
./scripts/gitlab-runner-start.sh

# Déjalo corriendo y úsalo para testing
# Cuando termines: Ctrl+C
```

¿Quieres probar iniciarlo ahora para verificar que funciona? O prefieres continuar con la documentación de FASE 2 y probarlo después? 😊