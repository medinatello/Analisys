# Checklist FASE 2: Setup GitHub + GitLab + CI/CD

**Proyecto:** EduGo - Separación de Monorepo
**Fase:** FASE 2 - Configuración de Infraestructura CI/CD
**Tiempo estimado:** 2-3 días
**Fecha:** 30 de Octubre, 2025

---

## 📚 Guías de Referencia

Antes de comenzar, lee estas guías:

- 📖 [GUIA_FASE2_GITHUB.md](GUIA_FASE2_GITHUB.md) - Configuración de GitHub
- 📖 [GUIA_FASE2_GITLAB.md](GUIA_FASE2_GITLAB.md) - Configuración de GitLab y Runner
- 📂 [templates/](templates/) - Templates de .gitlab-ci.yml

---

## ✅ SECCIÓN 2.1: Configuración de GitHub (Día 1)

### Crear Organización

- [ ] Ir a https://github.com/organizations/new
- [ ] Crear organización `edugo` (o nombre preferido)
- [ ] Seleccionar plan Free
- [ ] Verificar URL: https://github.com/edugo

### Generar Personal Access Token

- [ ] Ir a https://github.com/settings/tokens
- [ ] Click "Generate new token (classic)"
- [ ] Nombre: `EduGo - CI/CD Token`
- [ ] Scopes seleccionados:
  - [ ] ✅ `repo` (Full control)
  - [ ] ✅ `write:packages`
  - [ ] ✅ `read:packages`
  - [ ] ✅ `delete:packages` (opcional)
- [ ] Generar token
- [ ] Copiar token: `ghp_...`
- [ ] Guardar token en lugar seguro (gestor de contraseñas)

### Configurar GitHub Container Registry

- [ ] Exportar token en terminal:
  ```bash
  export GITHUB_TOKEN="ghp_tu_token_aqui"
  ```
- [ ] Login en ghcr.io:
  ```bash
  echo $GITHUB_TOKEN | docker login ghcr.io -u TU_USUARIO --password-stdin
  ```
- [ ] Verificar login exitoso: `Login Succeeded`
- [ ] Probar pull de imagen pública:
  ```bash
  docker pull ghcr.io/linuxserver/code-server:latest
  ```

### Crear Repositorios Placeholder (Temporales)

**⚠️ IMPORTANTE:** Estos son repositorios temporales para testing. Los borrarás y recrearás en FASE 3.

- [ ] Crear repo `edugo/edugo-shared`
  - Visibility: **Private** ✅
  - Initialize: NO
- [ ] Crear repo `edugo/edugo-api-mobile`
  - Visibility: **Private** ✅
  - Initialize: NO
- [ ] Crear repo `edugo/edugo-api-administracion`
  - Visibility: **Private** ✅
  - Initialize: NO
- [ ] Crear repo `edugo/edugo-worker`
  - Visibility: **Private** ✅
  - Initialize: NO
- [ ] Crear repo `edugo/edugo-dev-environment`
  - Visibility: **Private** ✅
  - Initialize: NO

### Verificar Setup de GitHub

- [ ] Ejecutar:
  ```bash
  curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/edugo
  ```
- [ ] Respuesta exitosa (JSON con info de org)
- [ ] Listar repos:
  ```bash
  curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/edugo/repos | grep '"name"'
  ```
- [ ] Ver 5 repositorios
- [ ] Todos son privados: `"private": true`

**✅ Checkpoint 1:** GitHub configurado correctamente

---

## ✅ SECCIÓN 2.2: Configuración de GitLab (Día 1-2)

### Crear Cuenta y Grupo

- [ ] Cuenta de GitLab creada (o login si ya tienes)
- [ ] Ir a https://gitlab.com/groups/new
- [ ] Crear grupo `edugo`
  - Visibility: Private
- [ ] Verificar URL: https://gitlab.com/edugo

### Instalar GitLab Runner (macOS)

- [ ] Ejecutar:
  ```bash
  brew update
  brew install gitlab-runner
  ```
- [ ] Verificar instalación:
  ```bash
  gitlab-runner --version
  ```
- [ ] Versión debe ser 17.x.x o superior

### Obtener Registration Token

- [ ] Ir a https://gitlab.com/groups/edugo/-/settings/ci_cd
- [ ] Expandir sección "Runners"
- [ ] Copiar "Registration token" (formato: `GR1348941...`)
- [ ] Guardar token (lo necesitarás ahora)

### Registrar Runner

- [ ] Ejecutar:
  ```bash
  gitlab-runner register
  ```
- [ ] Responder preguntas:
  - [ ] GitLab URL: `https://gitlab.com/`
  - [ ] Token: `[pegar token]`
  - [ ] Description: `mac-local-runner`
  - [ ] Tags: `macos,docker,go,local`
  - [ ] Executor: `docker`
  - [ ] Default image: `golang:1.23-alpine`
- [ ] Mensaje "Runner registered successfully"

### Iniciar Runner

- [ ] Instalar como servicio:
  ```bash
  gitlab-runner install
  gitlab-runner start
  ```
- [ ] Verificar status:
  ```bash
  gitlab-runner status
  ```
- [ ] Output esperado: `gitlab-runner: Service is running`

### Verificar Runner en GitLab UI

- [ ] Ir a https://gitlab.com/groups/edugo/-/settings/ci_cd
- [ ] Expandir "Runners"
- [ ] Ver runner "mac-local-runner"
- [ ] Status: 🟢 Online (punto verde)
- [ ] Tags: macos, docker, go, local

**✅ Checkpoint 2:** GitLab Runner configurado y online

---

## ✅ SECCIÓN 2.3: Configurar Mirroring y Variables

### Configurar Variables de Grupo en GitLab

- [ ] Ir a https://gitlab.com/groups/edugo/-/settings/ci_cd
- [ ] Expandir "Variables"
- [ ] Agregar variable `GITHUB_TOKEN`:
  - [ ] Key: `GITHUB_TOKEN`
  - [ ] Value: `[tu GitHub token]`
  - [ ] Protected: ✅ Sí
  - [ ] Masked: ✅ Sí
- [ ] Agregar variable `GITHUB_USERNAME`:
  - [ ] Key: `GITHUB_USERNAME`
  - [ ] Value: `[tu username GitHub]`
  - [ ] Protected: ☐ No
  - [ ] Masked: ☐ No
- [ ] Verificar que ambas variables aparecen en la lista

### Crear Proyectos en GitLab (Import desde GitHub)

Para cada repositorio, realizar:

#### edugo-shared
- [ ] GitLab: New project > Import project > Repository by URL
  - Git URL: `https://github.com/edugo/edugo-shared.git`
  - Name: `edugo-shared`
  - Visibility: Private
  - Group: edugo
- [ ] Click "Create project"
- [ ] Proyecto creado: https://gitlab.com/edugo/edugo-shared

#### edugo-api-mobile
- [ ] Import desde `https://github.com/edugo/edugo-api-mobile.git`
- [ ] Name: `edugo-api-mobile`
- [ ] Visibility: Private
- [ ] Proyecto creado: https://gitlab.com/edugo/edugo-api-mobile

#### edugo-api-administracion
- [ ] Import desde `https://github.com/edugo/edugo-api-administracion.git`
- [ ] Name: `edugo-api-administracion`
- [ ] Visibility: Private
- [ ] Proyecto creado: https://gitlab.com/edugo/edugo-api-administracion

#### edugo-worker
- [ ] Import desde `https://github.com/edugo/edugo-worker.git`
- [ ] Name: `edugo-worker`
- [ ] Visibility: Private
- [ ] Proyecto creado: https://gitlab.com/edugo/edugo-worker

#### edugo-dev-environment
- [ ] Import desde `https://github.com/edugo/edugo-dev-environment.git`
- [ ] Name: `edugo-dev-environment`
- [ ] Visibility: Private
- [ ] Proyecto creado: https://gitlab.com/edugo/edugo-dev-environment

### Configurar Pull Mirrors

Para **CADA** proyecto en GitLab:

#### edugo-shared mirror
- [ ] Settings > Repository > Mirroring repositories > Expand
- [ ] Git URL: `https://github.com/edugo/edugo-shared.git`
- [ ] Direction: Pull
- [ ] Auth: Password
- [ ] Password: `[tu GitHub token]`
- [ ] Only protected branches: ☐ No
- [ ] Keep divergent refs: ☑ Sí
- [ ] Click "Mirror repository"
- [ ] Probar "Update now" → "Successfully updated"

#### edugo-api-mobile mirror
- [ ] Settings > Repository > Mirroring
- [ ] URL: `https://github.com/edugo/edugo-api-mobile.git`
- [ ] Configurar igual que shared
- [ ] Probar "Update now"

#### edugo-api-administracion mirror
- [ ] Settings > Repository > Mirroring
- [ ] URL: `https://github.com/edugo/edugo-api-administracion.git`
- [ ] Configurar igual que shared
- [ ] Probar "Update now"

#### edugo-worker mirror
- [ ] Settings > Repository > Mirroring
- [ ] URL: `https://github.com/edugo/edugo-worker.git`
- [ ] Configurar igual que shared
- [ ] Probar "Update now"

#### edugo-dev-environment mirror
- [ ] Settings > Repository > Mirroring
- [ ] URL: `https://github.com/edugo/edugo-dev-environment.git`
- [ ] Configurar igual que shared
- [ ] Probar "Update now"

**✅ Checkpoint 3:** 5 proyectos con mirroring configurado

---

## ✅ SECCIÓN 2.4: Probar Pipelines (Día 2-3)

### Probar Pipeline Básico

- [ ] Crear directorio temporal:
  ```bash
  cd /tmp && mkdir test-pipeline && cd test-pipeline
  ```
- [ ] Copiar template:
  ```bash
  cp /Users/jhoanmedina/source/EduGo/Analisys/templates/.gitlab-ci.yml.shared .gitlab-ci.yml
  ```
- [ ] Editar y simplificar para testing (solo stage test)
- [ ] Init git:
  ```bash
  git init
  git add .gitlab-ci.yml
  git commit -m "test: pipeline básico"
  ```
- [ ] Push a GitHub placeholder (ej: edugo-shared):
  ```bash
  git remote add origin https://github.com/edugo/edugo-shared.git
  git branch -M main
  git push -u origin main --force
  ```

### Verificar Mirroring Automático

- [ ] Esperar 5 minutos (o trigger manual en GitLab)
- [ ] GitLab > edugo-shared > Repository
- [ ] Archivo .gitlab-ci.yml debe aparecer

### Verificar Pipeline Ejecutado

- [ ] GitLab > edugo-shared > CI/CD > Pipelines
- [ ] Debe aparecer pipeline #1
- [ ] Status: ✅ Passed (verde)
- [ ] Duration: ~30-60 segundos

### Ver Logs del Pipeline

- [ ] Click en pipeline
- [ ] Click en job (ej: `test-job`)
- [ ] Ver logs completos
- [ ] Verificar que muestra "Running on mac-local-runner"
- [ ] Job debe completar exitosamente

### Probar Pipeline con Docker Build

- [ ] Actualizar .gitlab-ci.yml para incluir stage build
- [ ] Agregar Dockerfile simple para testing
- [ ] Push a GitHub
- [ ] Esperar mirroring
- [ ] Verificar que pipeline ejecuta:
  - [ ] Stage test: ✅ passed
  - [ ] Stage build: ✅ passed
- [ ] Ver logs de stage build
- [ ] Verificar "Login Succeeded" a ghcr.io
- [ ] Verificar "Successfully built ..."

**✅ Checkpoint 4:** Pipeline completo funcionando

---

## 📊 Resumen de Estado

Al completar esta checklist, deberás tener:

### GitHub
- ✅ Organización `edugo` creada
- ✅ 5 repositorios privados creados
- ✅ Token con permisos correctos
- ✅ Acceso a ghcr.io configurado

### GitLab
- ✅ Grupo `edugo` creado
- ✅ 5 proyectos creados (mirrors de GitHub)
- ✅ Runner instalado y corriendo
- ✅ Variables configuradas (GITHUB_TOKEN, GITHUB_USERNAME)
- ✅ Mirroring automático funcionando

### CI/CD
- ✅ Pipeline básico probado
- ✅ Pipeline con Docker build probado
- ✅ Runner ejecuta jobs correctamente
- ✅ Login a ghcr.io desde pipeline funciona

---

## 🔄 Flujo Completo Esperado

```
Developer                GitHub                GitLab              Runner Local
    │                      │                     │                      │
    │  1. git push         │                     │                      │
    ├─────────────────────>│                     │                      │
    │                      │                     │                      │
    │                      │  2. Webhook/Mirror  │                      │
    │                      ├────────────────────>│                      │
    │                      │                     │                      │
    │                      │                     │  3. Trigger pipeline │
    │                      │                     ├─────────────────────>│
    │                      │                     │                      │
    │                      │                     │  4. Run jobs         │
    │                      │                     │<─────────────────────┤
    │                      │                     │  (test, build, push) │
    │                      │                     │                      │
    │                      │  5. Push image      │                      │
    │                      │<─────────────────────────────────────────────┤
    │                      │  to ghcr.io         │                      │
    │                      │                     │                      │
    │  6. Notification     │                     │  7. Pipeline status  │
    │  (email/UI)          │                     │  ✅ Success          │
    │<─────────────────────────────────────────────────────────────────────┤
```

---

## ⏭️ Siguiente Fase

Una vez completada FASE 2:

**FASE 3: Separación de Repositorios** (3-4 días)
- Extraer código de cada servicio
- Actualizar imports de shared
- Push a repos definitivos (no placeholders)
- Configurar pipelines reales

---

## 🔐 Información a Guardar

```bash
# Exportar estas variables en tu terminal para FASE 3
export GITHUB_ORG="edugo"
export GITHUB_TOKEN="ghp_..."
export GITHUB_USERNAME="tu-usuario"

# Verificar
echo "Org: $GITHUB_ORG"
echo "User: $GITHUB_USERNAME"
echo "Token: ${GITHUB_TOKEN:0:10}..." # Solo muestra inicio
```

---

## 📝 Notas

- **Tiempo real dedicado:** _____ horas
- **Problemas encontrados:** _____________________
- **Fecha de completitud:** _____________________

---

**Última actualización:** 30 de Octubre, 2025
**Autor:** Claude Code
**Versión:** 1.0
