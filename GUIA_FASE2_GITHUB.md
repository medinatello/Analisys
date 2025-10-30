# Guía FASE 2: Configuración de GitHub

**Proyecto:** EduGo - Separación de Monorepo
**Fase:** FASE 2 - Setup GitHub + GitLab + Container Registry
**Sección:** 2.1 - Configuración de GitHub
**Tiempo estimado:** 1 hora

---

## 📋 Prerequisitos

- [ ] Cuenta de GitHub existente
- [ ] Acceso a internet
- [ ] Docker Desktop instalado y corriendo
- [ ] Navegador web

---

## 🎯 Objetivos de esta Guía

1. Crear organización `edugo` en GitHub
2. Generar Personal Access Token con permisos correctos
3. Configurar acceso a GitHub Container Registry (ghcr.io)
4. Crear 5 repositorios placeholder (privados)
5. Verificar que todo funciona

---

## PASO 1: Crear Organización en GitHub

### 1.1 Navegar a creación de organización

```
URL: https://github.com/organizations/new
```

### 1.2 Llenar formulario

| Campo | Valor |
|-------|-------|
| **Organization account name** | `edugo` (o el que prefieras) |
| **Contact email** | Tu email |
| **This organization belongs to** | My personal account |
| **Plan** | Free (seleccionar opción gratuita) |

### 1.3 Crear organización

- Click en **"Create organization"**
- Omitir invitaciones a miembros (por ahora)
- Click en **"Complete setup"**

### 1.4 Verificar creación

- Deberías estar en: `https://github.com/edugo`
- URL de la organización: `https://github.com/edugo`

✅ **Checkpoint:** Organización `edugo` creada

---

## PASO 2: Generar GitHub Personal Access Token

### 2.1 Navegar a configuración de tokens

```
Ruta: GitHub > Settings (tu perfil) > Developer settings > Personal access tokens > Tokens (classic)

URL directa: https://github.com/settings/tokens
```

### 2.2 Generar nuevo token

- Click en **"Generate new token"** → **"Generate new token (classic)"**
- Puede que te pida autenticación 2FA

### 2.3 Configurar token

| Campo | Valor |
|-------|-------|
| **Note** | `EduGo - CI/CD Token` |
| **Expiration** | `90 days` (o sin expiración si prefieres) |
| **Select scopes** | Marcar las siguientes: |

**Scopes necesarios:**

- ✅ `repo` (Full control of private repositories)
  - ✅ repo:status
  - ✅ repo_deployment
  - ✅ public_repo
  - ✅ repo:invite
  - ✅ security_events

- ✅ `write:packages` (Upload packages to GitHub Package Registry)
  - ✅ read:packages
  - ✅ delete:packages (opcional, para limpieza)

### 2.4 Generar y copiar token

- Scroll down, click en **"Generate token"**
- **⚠️ IMPORTANTE:** Copia el token inmediatamente
- Formato: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### 2.5 Guardar token de forma segura

**Opción A: En archivo local (temporal)**
```bash
echo "GITHUB_TOKEN=ghp_tu_token_aqui" >> ~/.edugo_credentials
chmod 600 ~/.edugo_credentials
```

**Opción B: En gestor de contraseñas**
- 1Password, LastPass, Bitwarden, etc.
- Nombre: "EduGo GitHub Token"

✅ **Checkpoint:** Token generado y guardado

---

## PASO 3: Configurar GitHub Container Registry (ghcr.io)

### 3.1 Exportar token en terminal

```bash
# Reemplaza con tu token real
export GITHUB_TOKEN="ghp_tu_token_aqui"

# Verificar que se exportó
echo $GITHUB_TOKEN
# Debe mostrar: ghp_...
```

### 3.2 Hacer login en ghcr.io

```bash
# Reemplaza TU_USUARIO con tu username de GitHub
echo $GITHUB_TOKEN | docker login ghcr.io -u TU_USUARIO --password-stdin
```

**Salida esperada:**
```
Login Succeeded
```

### 3.3 Verificar login

```bash
docker info | grep -A 5 "Registry"
```

**Salida esperada (debería incluir):**
```
Registry: https://index.docker.io/v1/
...
ghcr.io
```

### 3.4 Probar que funciona

```bash
# Intentar pull de una imagen pública
docker pull ghcr.io/linuxserver/code-server:latest
```

Si descarga sin errores, el login fue exitoso ✅

✅ **Checkpoint:** Acceso a ghcr.io configurado

---

## PASO 4: Crear Repositorios Placeholder

**⚠️ IMPORTANTE:** Estos son repositorios temporales para probar. Los borrarás y recrearás en FASE 3.

### 4.1 Crear repositorio 1: edugo-shared

```
URL: https://github.com/organizations/edugo/repositories/new
```

| Campo | Valor |
|-------|-------|
| **Owner** | `edugo` |
| **Repository name** | `edugo-shared` |
| **Description** | `[TEMP] Módulo Go compartido - placeholder para testing` |
| **Visibility** | ⚠️ **Private** (muy importante) |
| **Initialize repository** | ☐ NO marcar ninguna opción |

Click **"Create repository"**

### 4.2 Crear repositorio 2: edugo-api-mobile

```
URL: https://github.com/organizations/edugo/repositories/new
```

| Campo | Valor |
|-------|-------|
| **Repository name** | `edugo-api-mobile` |
| **Description** | `[TEMP] Backend API Mobile - placeholder para testing` |
| **Visibility** | ⚠️ **Private** |
| **Initialize** | ☐ NO marcar |

Click **"Create repository"**

### 4.3 Crear repositorio 3: edugo-api-administracion

| Campo | Valor |
|-------|-------|
| **Repository name** | `edugo-api-administracion` |
| **Description** | `[TEMP] Backend API Admin - placeholder para testing` |
| **Visibility** | ⚠️ **Private** |
| **Initialize** | ☐ NO marcar |

Click **"Create repository"**

### 4.4 Crear repositorio 4: edugo-worker

| Campo | Valor |
|-------|-------|
| **Repository name** | `edugo-worker` |
| **Description** | `[TEMP] Worker procesador - placeholder para testing` |
| **Visibility** | ⚠️ **Private** |
| **Initialize** | ☐ NO marcar |

Click **"Create repository"**

### 4.5 Crear repositorio 5: edugo-dev-environment

| Campo | Valor |
|-------|-------|
| **Repository name** | `edugo-dev-environment` |
| **Description** | `[TEMP] Docker Compose dev environment - placeholder` |
| **Visibility** | ⚠️ **Private** |
| **Initialize** | ☐ NO marcar |

Click **"Create repository"**

### 4.6 Verificar creación

```
URL: https://github.com/orgs/edugo/repositories
```

Deberías ver **5 repositorios privados**:
- edugo-shared
- edugo-api-mobile
- edugo-api-administracion
- edugo-worker
- edugo-dev-environment

✅ **Checkpoint:** 5 repositorios placeholder creados (todos privados)

---

## PASO 5: Verificación Final

### 5.1 Verificar organización

```bash
# Desde terminal, verificar que la org existe
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/edugo
```

**Salida esperada:** JSON con información de la org (nombre, descripción, etc.)

### 5.2 Verificar repositorios

```bash
# Listar repos de la organización
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/edugo/repos | grep '"name"'
```

**Salida esperada:**
```json
"name": "edugo-shared",
"name": "edugo-api-mobile",
"name": "edugo-api-administracion",
"name": "edugo-worker",
"name": "edugo-dev-environment",
```

### 5.3 Verificar que son privados

```bash
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/edugo/repos | grep '"private"'
```

**Salida esperada:** Todos deben mostrar `"private": true`

### 5.4 Verificar acceso a Container Registry

```bash
# Verificar que puedes listar packages (debería estar vacío por ahora)
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/edugo/packages
```

**Salida esperada:** `[]` (array vacío)

✅ **Checkpoint:** Todo configurado correctamente

---

## 📝 Checklist Final

Marca cada item al completarlo:

- [ ] Organización `edugo` creada en GitHub
- [ ] GitHub Personal Access Token generado
- [ ] Token guardado en lugar seguro
- [ ] Token exportado en variable de entorno `GITHUB_TOKEN`
- [ ] Login en ghcr.io exitoso
- [ ] Repositorio `edugo-shared` creado (privado)
- [ ] Repositorio `edugo-api-mobile` creado (privado)
- [ ] Repositorio `edugo-api-administracion` creado (privado)
- [ ] Repositorio `edugo-worker` creado (privado)
- [ ] Repositorio `edugo-dev-environment` creado (privado)
- [ ] Verificación con API de GitHub exitosa
- [ ] Todos los repos son privados

---

## 🔐 Información Guardada

Guarda esta información para los siguientes pasos:

```bash
# GitHub Token (reemplaza con tu token real)
GITHUB_TOKEN="ghp_..."

# Tu usuario de GitHub
GITHUB_USERNAME="tu-usuario"

# Organización
GITHUB_ORG="edugo"

# URLs de los repositorios
https://github.com/edugo/edugo-shared
https://github.com/edugo/edugo-api-mobile
https://github.com/edugo/edugo-api-administracion
https://github.com/edugo/edugo-worker
https://github.com/edugo/edugo-dev-environment
```

---

## ⚠️ Troubleshooting

### Problema: "Organization name already taken"

**Solución:** Elige otro nombre (ej: `edugo-dev`, `edugo-platform`, etc.)

### Problema: "Invalid token" al hacer docker login

**Solución:**
```bash
# Verificar que el token está correcto
echo $GITHUB_TOKEN

# Si no aparece nada, exportarlo nuevamente
export GITHUB_TOKEN="ghp_tu_token_aqui"

# Reintentar login
echo $GITHUB_TOKEN | docker login ghcr.io -u TU_USUARIO --password-stdin
```

### Problema: No puedo crear repositorios privados

**Solución:** Verifica que tu cuenta de GitHub permite repos privados (la mayoría sí lo permite gratis)

### Problema: "403 Forbidden" al verificar con API

**Solución:** El token no tiene los scopes correctos. Regenera el token con todos los scopes mencionados.

---

## ⏭️ Próximos Pasos

Una vez completada esta guía, continúa con:

**📄 GUIA_FASE2_GITLAB.md** - Configuración de GitLab y GitLab Runner

---

**Última actualización:** 30 de Octubre, 2025
**Autor:** Claude Code
**Versión:** 1.0
