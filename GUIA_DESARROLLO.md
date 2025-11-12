# 🚀 Guía de Desarrollo - EduGo (Repos Separados)

**Fecha:** 30 de Octubre, 2025
**Organización:** EduGoGroup
**Estado:** ✅ Repos separados y funcionando

---

## 📂 Nueva Estructura de Trabajo

### ❌ NO USAR MÁS (Monorepo viejo - Solo referencia)
```
/Users/jhoanmedina/source/EduGo/Analisys/
└── [monorepo completo] ← BACKUP/HISTÓRICO - NO desarrollar aquí
```

### ✅ USAR AHORA (Repos separados - Conectados a GitHub)
```
/Users/jhoanmedina/source/EduGo/repos-separados/
├── edugo-shared/              ← github.com/EduGoGroup/edugo-shared
├── edugo-api-mobile/          ← github.com/EduGoGroup/edugo-api-mobile
├── edugo-api-administracion/  ← github.com/EduGoGroup/edugo-api-administracion
├── edugo-worker/              ← github.com/EduGoGroup/edugo-worker
└── edugo-dev-environment/     ← github.com/EduGoGroup/edugo-dev-environment
```

**Cada directorio es un repo git independiente conectado a GitHub.**

---

## ⚙️ Configuración Inicial (Una sola vez)

### 1. Configurar Git para Repos Privados

```bash
# Configurar Git para usar SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

### 2. Configurar Go para Módulos Privados

```bash
# Agregar a ~/.zshrc o ~/.bashrc
echo 'export GOPRIVATE="github.com/EduGoGroup/*"' >> ~/.zshrc

# Recargar configuración
source ~/.zshrc
```

### 3. Verificar Configuración

```bash
# Verificar GOPRIVATE
echo $GOPRIVATE
# Debería mostrar: github.com/EduGoGroup/*

# Probar acceso a GitHub
ssh -T git@github.com
# Debería mostrar: Hi medinatello! You've successfully authenticated...
```

---

## 💻 Flujo de Trabajo para Backend

### Escenario 1: Modificar edugo-shared (Módulo Compartido)

```bash
# 1. Ir al repo
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared

# 2. Crear branch para tu feature
git checkout -b feature/nueva-funcionalidad

# 3. Hacer cambios
# ... editar archivos ...

# 4. Ejecutar tests
go test -v ./...

# 5. Commit y push
git add .
git commit -m "feat: descripción de cambios"
git push origin feature/nueva-funcionalidad

# 6. Crear PR en GitHub
# https://github.com/EduGoGroup/edugo-shared/compare

# 7. Cuando se apruebe el PR y se haga merge a main:
#    → Crear nueva versión (tag)
git checkout main
git pull
git tag -a v0.2.0 -m "Release v0.2.0: descripción"
git push origin v0.2.0

# 8. Actualizar APIs que usen shared
cd ../edugo-api-mobile
go get github.com/EduGoGroup/edugo-shared@v0.2.0
go mod tidy
```

### Escenario 2: Modificar edugo-api-mobile

```bash
# 1. Ir al repo
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# 2. Crear branch
git checkout -b feature/nuevo-endpoint

# 3. Hacer cambios
# ... editar archivos ...

# 4. Ejecutar tests localmente
go test -v ./...

# 5. Compilar para verificar
go build -v -o api-mobile ./cmd/main.go

# 6. Commit y push
git add .
git commit -m "feat: agregar nuevo endpoint"
git push origin feature/nuevo-endpoint

# 7. Crear PR en GitHub
# → GitHub Actions ejecutará tests automáticamente

# 8. Cuando se apruebe y haga merge a main:
#    → GitHub Actions construirá imagen Docker automáticamente
#    → La imagen se sube a ghcr.io/edugogroup/edugo-api-mobile:latest
```

---

## 🤖 Usar GitHub Actions (CI/CD On-Demand)

### Opción 1: Trigger Manual (On-Demand)

```bash
# Ve a GitHub:
https://github.com/EduGoGroup/edugo-api-mobile/actions

# 1. Click en "Actions"
# 2. Selecciona "Build and Push Docker Image"
# 3. Click "Run workflow"
# 4. Selecciona:
#    - Branch: main (o el que quieras)
#    - Environment: development/staging/production
# 5. Click "Run workflow"
# 6. Espera ~2-3 minutos
# 7. ✅ Imagen disponible en ghcr.io
```

### Opción 2: Trigger Automático en PR

```bash
# Simplemente crea un PR:
git push origin feature/mi-feature

# Ve a GitHub y crea PR:
# → GitHub Actions ejecutará tests automáticamente
# → Verás el estado en el PR (✅ checks passed)
```

### Opción 3: Trigger Automático en Main

```bash
# Cuando hagas merge a main:
# → GitHub Actions automáticamente:
#   1. Ejecuta tests
#   2. Build imagen Docker
#   3. Push a ghcr.io/edugogroup/[repo]:latest
```

---

## 🐳 Trabajar con Imágenes Docker

### Construir Imagen Localmente

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Build con soporte para repos privados
docker build \
  --build-arg GITHUB_TOKEN=$GITHUB_TOKEN \
  -t edugo-api-mobile:local \
  .

# Ejecutar localmente
docker run -p 8081:8080 edugo-api-mobile:local
```

### Descargar Imagen de ghcr.io

```bash
# 1. Login (una sola vez)
echo $GITHUB_TOKEN | docker login ghcr.io -u medinatello --password-stdin

# 2. Descargar última versión
docker pull ghcr.io/edugogroup/edugo-api-mobile:latest

# 3. Ejecutar
docker run -p 8081:8080 ghcr.io/edugogroup/edugo-api-mobile:latest
```

---

## 📦 Dependencias entre Repos

```
edugo-shared (v0.1.0)
    ↓ (dependen de)
┌───┴────┬────────────┐
│        │            │
api-    api-        worker
mobile  admin
```

### Actualizar edugo-shared en una API

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Ver versión actual
go list -m github.com/EduGoGroup/edugo-shared

# Actualizar a nueva versión
go get github.com/EduGoGroup/edugo-shared@v0.2.0
go mod tidy

# Commit y push
git add go.mod go.sum
git commit -m "chore: actualizar edugo-shared a v0.2.0"
git push
```

---

## 🧪 Ejecutar Tests

### Tests en edugo-shared

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared

# Ejecutar todos los tests
go test -v ./...

# Con cobertura
go test -v -race -coverprofile=coverage.txt ./...
go tool cover -html=coverage.txt -o coverage.html
open coverage.html
```

### Tests en APIs

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Tests unitarios
go test -v ./...

# Tests de integración (requiere Docker)
# Ver: test/integration/README.md
```

---

## 🔄 Workflow Típico de Desarrollo

### Para Features Nuevas

```bash
# 1. Asegúrate de estar en main actualizado
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
git checkout main
git pull

# 2. Crear branch de feature
git checkout -b feature/nombre-descriptivo

# 3. Desarrollar
# ... hacer cambios ...

# 4. Tests locales
go test ./...
go build -v -o api-mobile ./cmd/main.go

# 5. Commit (puedes hacer varios commits)
git add .
git commit -m "feat: descripción del cambio"

# 6. Push a GitHub
git push origin feature/nombre-descriptivo

# 7. Crear PR en GitHub
# https://github.com/EduGoGroup/edugo-api-mobile/compare

# 8. GitHub Actions ejecutará tests automáticamente
# 9. Esperar review y aprobación
# 10. Merge a main
# 11. GitHub Actions construirá imagen automáticamente
```

### Para Hotfixes

```bash
# 1. Branch desde main
git checkout main
git pull
git checkout -b hotfix/descripcion

# 2. Fix rápido
# ... arreglar ...

# 3. Tests
go test ./...

# 4. Commit y push
git add .
git commit -m "fix: descripción del bug arreglado"
git push origin hotfix/descripcion

# 5. PR directo a main
# 6. Merge rápido
# 7. GitHub Actions desplegará automáticamente
```

---

## 📊 Estado de los Repositorios

### Verificar Estado de un Repo

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Ver branch actual
git branch

# Ver remotes
git remote -v
# Debería mostrar: git@github.com:EduGoGroup/edugo-api-mobile.git

# Ver status
git status

# Ver últimos commits
git log --oneline -5
```

### Sincronizar con GitHub

```bash
# Traer últimos cambios
git pull origin main

# Ver qué cambió
git log --oneline -10
```

---

## 🐳 Docker Compose para Desarrollo Local

### Usar edugo-dev-environment

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-dev-environment

# 1. Login en ghcr.io (si no lo has hecho)
echo $GITHUB_TOKEN | docker login ghcr.io -u medinatello --password-stdin

# 2. Copiar .env
cp .env.example .env

# 3. Levantar servicios
docker-compose up -d

# 4. Ver logs
docker-compose logs -f

# 5. Detener
docker-compose down
```

**Esto levanta TODAS las APIs + bases de datos + RabbitMQ**

---

## 🔍 Troubleshooting

### Problema: "package github.com/EduGoGroup/edugo-shared: not found"

**Solución:**
```bash
# Verificar GOPRIVATE
echo $GOPRIVATE
# Debe mostrar: github.com/EduGoGroup/*

# Si no está configurado:
export GOPRIVATE="github.com/EduGoGroup/*"

# Verificar git config
git config --global --get url."git@github.com:".insteadOf
# Debe mostrar: https://github.com/

# Descargar dependencias nuevamente
go clean -modcache
go mod download
```

### Problema: "Authentication failed" al hacer push

**Solución:**
```bash
# Verificar SSH
ssh -T git@github.com

# Ver remote
git remote -v

# Debería usar git@github.com, no https://
```

### Problema: Cambios del monorepo no están en repos separados

**Respuesta:** Es correcto. Los repos separados están SOLO en GitHub.

```bash
# El monorepo viejo:
/Users/jhoanmedina/source/EduGo/Analisys/
└── Solo para referencia, NO desarrollar aquí

# Los repos reales:
/Users/jhoanmedina/source/EduGo/repos-separados/
└── Desarrollar AQUÍ
```

---

## 📚 Recursos Útiles

### Repositorios en GitHub

- **Organización:** https://github.com/EduGoGroup
- **edugo-shared:** https://github.com/EduGoGroup/edugo-shared
- **edugo-api-mobile:** https://github.com/EduGoGroup/edugo-api-mobile
- **edugo-api-administracion:** https://github.com/EduGoGroup/edugo-api-administracion
- **edugo-worker:** https://github.com/EduGoGroup/edugo-worker
- **edugo-dev-environment:** https://github.com/EduGoGroup/edugo-dev-environment

### Imágenes Docker

- **Container Registry:** https://github.com/orgs/EduGoGroup/packages
- **Pull:** `docker pull ghcr.io/edugogroup/[repo]:latest`

### GitHub Actions

- **Workflows:** En cada repo → Actions tab
- **Manual trigger:** Actions → Select workflow → Run workflow

---

## 🎯 Comandos Rápidos de Referencia

### Desarrollo Diario

```bash
# Ir a un repo
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Actualizar desde GitHub
git pull

# Crear feature branch
git checkout -b feature/mi-feature

# Hacer cambios...

# Tests
go test ./...

# Commit y push
git add .
git commit -m "feat: mi cambio"
git push origin feature/mi-feature

# Crear PR en GitHub
```

### Build de Imagen Docker

```bash
# Opción 1: Manual en GitHub Actions
# → Ve a GitHub Actions → Run workflow

# Opción 2: Local
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
docker build --build-arg GITHUB_TOKEN=$GITHUB_TOKEN -t test:local .
```

### Actualizar edugo-shared

```bash
# 1. Ir a shared
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared

# 2. Hacer cambios y crear nueva versión
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin v0.2.0

# 3. Actualizar en APIs
cd ../edugo-api-mobile
go get github.com/EduGoGroup/edugo-shared@v0.2.0
go mod tidy
git add go.mod go.sum
git commit -m "chore: actualizar edugo-shared a v0.2.0"
git push
```

---

## 🔐 Seguridad

### GitHub Token para CI/CD

El token está configurado como secreto en GitHub. **NO lo pongas en el código.**

### GitHub Token para Docker

```bash
# Generar token en: https://github.com/settings/tokens
# Scopes necesarios:
# - read:packages (para descargar imágenes)
# - write:packages (si vas a pushear manualmente)

# Guardar en variable de entorno
export GITHUB_TOKEN="ghp_tu_token_aqui"

# Agregar a ~/.zshrc para que persista
echo 'export GITHUB_TOKEN="ghp_tu_token_aqui"' >> ~/.zshrc
```

---

## 📝 Convenciones de Commits

```bash
# Tipos de commits:
feat:     Nueva funcionalidad
fix:      Bug fix
chore:    Cambios de mantenimiento
docs:     Documentación
test:     Tests
refactor: Refactorización
perf:     Mejoras de performance

# Ejemplos:
git commit -m "feat: agregar endpoint de búsqueda de materiales"
git commit -m "fix: corregir validación de email en registro"
git commit -m "chore: actualizar edugo-shared a v0.2.0"
```

---

## 🎉 ¡Todo Listo!

Ahora puedes:

✅ Desarrollar en repos separados conectados a GitHub
✅ Hacer PR y que se ejecuten tests automáticamente
✅ Disparar builds on-demand cuando necesites
✅ Distribuir imágenes Docker privadas a tu equipo
✅ Versionar cada servicio independientemente

---

**Siguiente paso:** ¡Comenzar a desarrollar! 🚀

**Documentación adicional:**
- `SEPARACION_COMPLETADA.md` - Resumen de la separación
- `edugo-dev-environment/README.md` - Guía para frontend devs
- `PLAN-SEPARACION-COMPLETO.md` - Plan original

---

**Última actualización:** 30 de Octubre, 2025
**Autor:** Claude Code
**Versión:** 1.0
