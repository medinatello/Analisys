# Guía FASE 2: Configuración de GitLab + Runner

**Proyecto:** EduGo - Separación de Monorepo
**Fase:** FASE 2 - Setup GitHub + GitLab + Container Registry
**Sección:** 2.2 - Configuración de GitLab
**Tiempo estimado:** 2-3 horas

---

## 📋 Prerequisitos

- [ ] Cuenta de GitHub configurada (ver GUIA_FASE2_GITHUB.md)
- [ ] Organizació `edugo` creada en GitHub
- [ ] GitHub Personal Access Token generado
- [ ] macOS con Homebrew instalado
- [ ] Docker Desktop instalado y corriendo

---

## 🎯 Objetivos de esta Guía

1. Crear cuenta/grupo en GitLab
2. Instalar GitLab Runner en tu Mac
3. Registrar runner con GitLab
4. Configurar mirroring GitHub → GitLab
5. Probar pipeline básico

---

## PASO 1: Crear Cuenta y Grupo en GitLab

### 1.1 Crear cuenta (si no tienes)

```
URL: https://gitlab.com/users/sign_up
```

- Llenar formulario
- Verificar email
- Login en GitLab

### 1.2 Crear Grupo

```
URL: https://gitlab.com/groups/new
```

| Campo | Valor |
|-------|-------|
| **Group name** | `EduGo` |
| **Group URL** | `edugo` (resultará en https://gitlab.com/edugo) |
| **Visibility level** | **Private** (muy importante) |
| **Role** | `Software Developer` |

Click **"Create group"**

### 1.3 Verificar grupo creado

- Deberías estar en: `https://gitlab.com/edugo`
- Sidebar izquierdo debe mostrar "edugo" como grupo actual

✅ **Checkpoint:** Grupo `edugo` creado en GitLab

---

## PASO 2: Instalar GitLab Runner en macOS

### 2.1 Instalar con Homebrew

```bash
# Actualizar Homebrew
brew update

# Instalar GitLab Runner
brew install gitlab-runner

# Verificar instalación
gitlab-runner --version
```

**Salida esperada:**
```
Version:      17.x.x
Git revision: ...
Git branch:   ...
GO version:   go1.21.x
Built:        ...
OS/Arch:      darwin/amd64
```

### 2.2 Verificar que Docker está disponible

```bash
# Verificar Docker
docker --version

# Verificar que Docker está corriendo
docker ps
```

Si Docker no está corriendo:
```bash
open -a Docker
# Esperar a que inicie (ícono en la barra de menú)
```

✅ **Checkpoint:** GitLab Runner instalado

---

## PASO 3: Obtener Registration Token de GitLab

### 3.1 Navegar a configuración de Runners

```
Ruta: GitLab > Grupo edugo > Settings > CI/CD > Runners

URL directa: https://gitlab.com/groups/edugo/-/settings/ci_cd
```

### 3.2 Expandir sección Runners

- Scroll hasta sección **"Runners"**
- Click en **"Expand"**

### 3.3 Copiar Registration Token

- En la sección **"Set up a group runner manually"**
- Encontrar **"Registration token"**
- Click en botón de copiar (📋)
- Formato: `GR1348941...` (empieza con GR)

**⚠️ IMPORTANTE:** Guarda este token, lo necesitarás en el siguiente paso

✅ **Checkpoint:** Registration token copiado

---

## PASO 4: Registrar Runner con GitLab

### 4.1 Ejecutar comando de registro

```bash
gitlab-runner register
```

### 4.2 Responder preguntas interactivas

El comando te hará varias preguntas. Responde según la tabla:

| Pregunta | Respuesta |
|----------|-----------|
| **Enter the GitLab instance URL** | `https://gitlab.com/` |
| **Enter the registration token** | `[Pegar token de PASO 3.3]` |
| **Enter a description** | `mac-local-runner` |
| **Enter tags** | `macos,docker,go,local` |
| **Enter optional maintenance note** | `[Enter - dejar vacío]` |
| **Enter an executor** | `docker` |
| **Enter the default Docker image** | `golang:1.23-alpine` |

### 4.3 Ejemplo de sesión completa

```
Runtime platform: arch=amd64 os=darwin
Running in system-mode.

Enter the GitLab instance URL (for example, https://gitlab.com/):
https://gitlab.com/

Enter the registration token:
GR1348941... [tu token aquí]

Enter a description for the runner:
mac-local-runner

Enter tags for the runner (comma-separated):
macos,docker,go,local

Enter optional maintenance note for the runner:
[presiona Enter]

Registering runner... succeeded                     runner=GR1348941

Enter an executor: custom, shell, ssh, docker, docker-ssh, parallels, virtualbox, docker+machine, docker-ssh+machine, kubernetes:
docker

Enter the default Docker image (for example, ruby:2.7):
golang:1.23-alpine

Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

✅ **Checkpoint:** Runner registrado

---

## PASO 5: Iniciar GitLab Runner

### 5.1 Instalar como servicio

```bash
# Instalar runner como servicio de macOS
gitlab-runner install

# Iniciar servicio
gitlab-runner start
```

**Salida esperada:**
```
Runtime platform: arch=amd64 os=darwin
Runner installed and started successfully
```

### 5.2 Verificar que está corriendo

```bash
gitlab-runner status
```

**Salida esperada:**
```
Runtime platform: arch=amd64 os=darwin
gitlab-runner: Service is running
```

### 5.3 Ver configuración

```bash
cat ~/.gitlab-runner/config.toml
```

**Salida esperada:**
```toml
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "mac-local-runner"
  url = "https://gitlab.com/"
  token = "..."
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "golang:1.23-alpine"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
```

✅ **Checkpoint:** Runner corriendo como servicio

---

## PASO 6: Verificar Runner en GitLab UI

### 6.1 Navegar a Runners

```
URL: https://gitlab.com/groups/edugo/-/settings/ci_cd
```

- Expandir sección **"Runners"**
- Scroll hasta **"Group runners"**

### 6.2 Verificar estado

Deberías ver tu runner:

| Campo | Valor Esperado |
|-------|----------------|
| **Status** | 🟢 Online (punto verde) |
| **Description** | `mac-local-runner` |
| **Tags** | `macos`, `docker`, `go`, `local` |
| **Executor** | `docker` |

### 6.3 Si el runner aparece offline (🔴)

**Soluciones:**

```bash
# Opción 1: Reiniciar runner
gitlab-runner restart

# Opción 2: Ver logs
gitlab-runner --debug run

# Opción 3: Verificar que Docker está corriendo
docker ps
```

✅ **Checkpoint:** Runner online en GitLab UI

---

## PASO 7: Configurar Mirroring de GitHub a GitLab

### 7.1 Crear proyecto en GitLab (ejemplo con edugo-shared)

```
URL: https://gitlab.com/projects/new
```

| Campo | Valor |
|-------|-------|
| **Create from** | `Import project` |
| **Import project from** | `Repository by URL` |
| **Git repository URL** | `https://github.com/edugo/edugo-shared.git` |
| **Project name** | `edugo-shared` |
| **Project slug** | `edugo-shared` |
| **Visibility level** | **Private** |
| **Group** | `edugo` |

Click **"Create project"**

### 7.2 Configurar Pull Mirror (sincronización automática)

Una vez creado el proyecto:

```
URL: https://gitlab.com/edugo/edugo-shared/-/settings/repository
```

- Scroll hasta **"Mirroring repositories"**
- Click **"Expand"**

| Campo | Valor |
|-------|-------|
| **Git repository URL** | `https://github.com/edugo/edugo-shared.git` |
| **Mirror direction** | **Pull** |
| **Authentication method** | **Password** |
| **Password** | `[Pegar tu GitHub token]` |
| **Only mirror protected branches** | ☐ Desmarcar |
| **Keep divergent refs** | ☑ Marcar |

Click **"Mirror repository"**

### 7.3 Probar mirroring manual

- En la misma página, encontrar el mirror recién creado
- Click en botón de **"Update now"** (ícono de refresh 🔄)
- Debería mostrar "Successfully updated"

### 7.4 Configurar webhook automático (opcional pero recomendado)

Para sincronización inmediata en lugar de esperar 5 minutos:

**En GitHub:**
```
URL: https://github.com/edugo/edugo-shared/settings/hooks/new
```

| Campo | Valor |
|-------|-------|
| **Payload URL** | `https://gitlab.com/api/v4/projects/XXXXXX/mirror/pull` |
| **Content type** | `application/json` |
| **Secret** | `[Dejar vacío o generar uno]` |
| **Events** | ☑ Just the push event |
| **Active** | ☑ |

**Nota:** Necesitas el Project ID de GitLab (encontrarlo en Settings > General)

✅ **Checkpoint:** Mirror configurado

---

## PASO 8: Probar Pipeline Básico

### 8.1 Crear archivo .gitlab-ci.yml básico

Crea un archivo temporal para probar:

```bash
cd /tmp
mkdir test-gitlab-ci
cd test-gitlab-ci
```

Crear archivo `.gitlab-ci.yml`:

```yaml
# .gitlab-ci.yml - Test básico

stages:
  - test

test-job:
  stage: test
  image: golang:1.23-alpine
  tags:
    - docker
  script:
    - echo "Probando GitLab Runner..."
    - go version
    - echo "✅ Pipeline funcionando correctamente"
```

### 8.2 Push a repo GitHub placeholder

```bash
# Inicializar git
git init
git add .gitlab-ci.yml
git commit -m "test: pipeline básico"

# Conectar con GitHub (usa uno de los repos placeholder)
git remote add origin https://github.com/edugo/edugo-shared.git
git branch -M main
git push -u origin main
```

**Nota:** Si el repo ya tiene contenido, usa `git push --force` solo para testing.

### 8.3 Esperar mirroring a GitLab

- Opción A: Esperar ~5 minutos (auto-sync)
- Opción B: Trigger manual en GitLab > Settings > Repository > Mirroring > Update now

### 8.4 Verificar pipeline en GitLab

```
URL: https://gitlab.com/edugo/edugo-shared/-/pipelines
```

Deberías ver:
- **Pipeline #1** con estado **"passed"** (✅ verde)
- Duration: ~30 segundos
- Jobs: `test-job` passed

### 8.5 Ver logs del pipeline

- Click en el pipeline
- Click en job `test-job`
- Deberías ver:

```
Running with gitlab-runner X.X.X (...)
  on mac-local-runner ...
Preparing environment
...
$ echo "Probando GitLab Runner..."
Probando GitLab Runner...
$ go version
go version go1.23.x linux/amd64
$ echo "✅ Pipeline funcionando correctamente"
✅ Pipeline funcionando correctamente
Job succeeded
```

✅ **Checkpoint:** Pipeline ejecutado exitosamente en tu runner local

---

## PASO 9: Configurar Variables de Entorno en GitLab

Para que los pipelines puedan acceder a GitHub Container Registry y otros servicios.

### 9.1 Navegar a variables

```
URL: https://gitlab.com/groups/edugo/-/settings/ci_cd
```

- Expandir **"Variables"**
- Click **"Add variable"**

### 9.2 Agregar GITHUB_TOKEN

| Campo | Valor |
|-------|-------|
| **Key** | `GITHUB_TOKEN` |
| **Value** | `[Tu GitHub token]` |
| **Type** | Variable |
| **Environment scope** | All (default) |
| **Protect variable** | ☑ Sí |
| **Mask variable** | ☑ Sí |
| **Expand variable reference** | ☐ No |

Click **"Add variable"**

### 9.3 Agregar GITHUB_USERNAME

| Campo | Valor |
|-------|-------|
| **Key** | `GITHUB_USERNAME` |
| **Value** | `[Tu username de GitHub]` |
| **Type** | Variable |
| **Protect variable** | ☐ No |
| **Mask variable** | ☐ No |

Click **"Add variable"**

### 9.4 Verificar variables

En la lista deberías ver:
- `GITHUB_TOKEN` (masked: *****)
- `GITHUB_USERNAME` (visible)

✅ **Checkpoint:** Variables configuradas

---

## PASO 10: Probar Pipeline con Docker Build

### 10.1 Actualizar .gitlab-ci.yml para probar Docker

Crea este archivo más completo:

```yaml
# .gitlab-ci.yml - Test completo con Docker

stages:
  - test
  - build

variables:
  DOCKER_IMAGE: ghcr.io/edugo/test-image
  DOCKER_TLS_CERTDIR: "/certs"

test:
  stage: test
  image: golang:1.23-alpine
  tags:
    - docker
  script:
    - echo "Testing Go environment..."
    - go version
    - apk add --no-cache git
    - echo "✅ Test stage passed"

build-docker:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  tags:
    - docker
  before_script:
    - echo "Logging into GitHub Container Registry..."
    - echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
  script:
    - echo "Creating test Dockerfile..."
    - |
      cat > Dockerfile <<EOF
      FROM alpine:latest
      CMD ["echo", "Hello from EduGo test image"]
      EOF
    - echo "Building Docker image..."
    - docker build -t $DOCKER_IMAGE:test .
    - echo "✅ Build stage passed"
  only:
    - main
```

### 10.2 Push a GitHub

```bash
git add .gitlab-ci.yml
git commit -m "test: pipeline con Docker build"
git push origin main
```

### 10.3 Verificar en GitLab

- Ir a: https://gitlab.com/edugo/edugo-shared/-/pipelines
- Esperar que aparezca nuevo pipeline
- Verificar que ambos jobs pasan:
  - ✅ `test` - passed
  - ✅ `build-docker` - passed

### 10.4 Revisar logs de build-docker

Deberías ver:
```
$ echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
Login Succeeded
...
$ docker build -t $DOCKER_IMAGE:test .
...
Successfully built ...
Successfully tagged ghcr.io/edugo/test-image:test
✅ Build stage passed
```

✅ **Checkpoint:** Pipeline con Docker funcionando

---

## PASO 11: Configurar Mirroring para Resto de Repos

Repite los pasos 7.1 y 7.2 para cada repositorio:

### 11.1 Crear proyectos en GitLab

Para cada repo de GitHub, crear proyecto en GitLab:

1. **edugo-api-mobile**
   - URL GitHub: `https://github.com/edugo/edugo-api-mobile.git`
   - URL GitLab: `https://gitlab.com/edugo/edugo-api-mobile`

2. **edugo-api-administracion**
   - URL GitHub: `https://github.com/edugo/edugo-api-administracion.git`
   - URL GitLab: `https://gitlab.com/edugo/edugo-api-administracion`

3. **edugo-worker**
   - URL GitHub: `https://github.com/edugo/edugo-worker.git`
   - URL GitLab: `https://gitlab.com/edugo/edugo-worker`

4. **edugo-dev-environment**
   - URL GitHub: `https://github.com/edugo/edugo-dev-environment.git`
   - URL GitLab: `https://gitlab.com/edugo/edugo-dev-environment`

### 11.2 Configurar pull mirror para cada uno

En cada proyecto GitLab:
- Settings > Repository > Mirroring repositories
- Add mirror con GitHub URL y tu token

✅ **Checkpoint:** 5 proyectos con mirroring configurado

---

## 📝 Checklist de Verificación FASE 2

Marca cada item cuando lo completes:

### GitHub
- [ ] Organización `edugo` creada
- [ ] GitHub Personal Access Token generado
- [ ] Token guardado de forma segura
- [ ] Login en ghcr.io exitoso
- [ ] 5 repositorios placeholder creados (todos privados)

### GitLab
- [ ] Cuenta de GitLab creada/existente
- [ ] Grupo `edugo` creado (privado)
- [ ] GitLab Runner instalado (`brew install gitlab-runner`)
- [ ] Runner registrado con token de GitLab
- [ ] Runner iniciado como servicio
- [ ] Runner aparece online en GitLab UI (🟢)
- [ ] Variables `GITHUB_TOKEN` y `GITHUB_USERNAME` configuradas

### Mirroring
- [ ] Proyecto `edugo-shared` creado en GitLab
- [ ] Pull mirror configurado para `edugo-shared`
- [ ] Proyecto `edugo-api-mobile` creado en GitLab
- [ ] Pull mirror configurado para `edugo-api-mobile`
- [ ] Proyecto `edugo-api-administracion` creado en GitLab
- [ ] Pull mirror configurado para `edugo-api-administracion`
- [ ] Proyecto `edugo-worker` creado en GitLab
- [ ] Pull mirror configurado para `edugo-worker`
- [ ] Proyecto `edugo-dev-environment` creado en GitLab
- [ ] Pull mirror configurado para `edugo-dev-environment`

### Pipelines
- [ ] Pipeline básico probado (test stage)
- [ ] Pipeline con Docker probado (build stage)
- [ ] Runner ejecuta jobs correctamente
- [ ] Login a ghcr.io desde pipeline funciona

---

## 🔧 Comandos Útiles

### Ver status del runner

```bash
gitlab-runner status
```

### Detener runner

```bash
gitlab-runner stop
```

### Reiniciar runner

```bash
gitlab-runner restart
```

### Ver logs del runner en tiempo real

```bash
gitlab-runner --debug run
```

### Desregistrar runner (si necesitas empezar de nuevo)

```bash
gitlab-runner unregister --all-runners
```

### Ver runners registrados

```bash
gitlab-runner list
```

---

## ⚠️ Troubleshooting

### Problema: Runner aparece offline en GitLab

**Solución:**
```bash
# Verificar status
gitlab-runner status

# Si no está corriendo, iniciar
gitlab-runner start

# Ver logs para debugging
gitlab-runner --debug run
```

### Problema: "ERROR: Failed to remove network" en pipeline Docker

**Solución:** Otorgar privileged mode al runner

Editar `~/.gitlab-runner/config.toml`:
```toml
[[runners]]
  ...
  [runners.docker]
    ...
    privileged = true  # Cambiar a true
    volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]
```

Reiniciar runner:
```bash
gitlab-runner restart
```

### Problema: "docker: command not found" en pipeline

**Solución:** Verificar que Docker Desktop está corriendo en tu Mac

```bash
docker ps
# Si falla, abrir Docker Desktop
open -a Docker
```

### Problema: Pipeline no se dispara después de push a GitHub

**Solución:**
1. Trigger manual del mirror: GitLab > Settings > Repository > Mirroring > Update now
2. Configurar webhook en GitHub (opcional, ver PASO 7.4 arriba)
3. Verificar que el mirror tiene permisos correctos

### Problema: "Login to ghcr.io failed" en pipeline

**Solución:** Verificar que las variables están configuradas:

```bash
# En GitLab: Settings > CI/CD > Variables
# Verificar que GITHUB_TOKEN y GITHUB_USERNAME existen
```

---

## 📊 Resultado Esperado

Al completar esta guía, tendrás:

```
GitHub (edugo org)
├── edugo-shared ──────────┐
├── edugo-api-mobile ──────┤
├── edugo-api-admin ───────┼─── Pull Mirror ───> GitLab (edugo group)
├── edugo-worker ──────────┤                     ├── edugo-shared
└── edugo-dev-environment ─┘                     ├── edugo-api-mobile
                                                 ├── edugo-api-admin
                                                 ├── edugo-worker
                                                 └── edugo-dev-env
                                                      │
                                                      │ Ejecuta CI/CD
                                                      ↓
                                                  GitLab Runner
                                                  (tu Mac local)
                                                      │
                                                      │ Build & Push
                                                      ↓
                                                GitHub Container Registry
                                                (ghcr.io/edugo/*)
```

---

## ⏭️ Próximos Pasos

Una vez completada esta guía:

1. **Verificar** que todos los checkpoints están marcados ✅
2. **Probar** que el pipeline completo funciona
3. **Documentar** cualquier problema encontrado
4. **Continuar** con la siguiente fase del proyecto

---

**Última actualización:** 30 de Octubre, 2025
**Autor:** Claude Code
**Versión:** 1.0
