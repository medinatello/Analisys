# Plan de Rollback - EduGo

**Fecha:** 30 de Octubre, 2025
**Proyecto:** EduGo - Separación de Monorepo a Multi-Repo
**Estado:** Pre-Separación Completada (FASE 1)

---

## 📋 Información del Backup

### Backup Creado
- **Archivo:** `~/Backups/edugo-monorepo-backup-20251030.tar.gz`
- **Tamaño:** ~2.5 MB
- **Contenido:** Monorepo completo antes de separación
- **Fecha:** 30 de Octubre, 2025

### Tag Git Creado
- **Tag:** `monorepo-final`
- **Commit:** Último commit de FASE 1
- **Estado:** NO pusheado a remoto (solo local)
- **Mensaje:** "Último commit antes de separación a multi-repo"

---

## 🔄 OPCIÓN 1: Volver a Commit Anterior (Rápido)

**Cuándo usar:** Si acabas de completar FASE 1 y quieres revertir cambios recientes.

**Ventaja:** ⚡ Rápido (< 1 minuto)

**Desventaja:** ⚠️ Solo funciona si no has pusheado cambios

### Pasos

```bash
# 1. Verificar que estás en la rama correcta
git branch
# Deberías estar en: feature/fase1-pre-separacion

# 2. Ver el tag creado
git show monorepo-final

# 3. Volver al tag (reset HARD - borra cambios no commiteados)
git reset --hard monorepo-final

# 4. Verificar que volviste
git log --oneline -5

# 5. Si habías pusheado a remoto, forzar push (¡CUIDADO!)
# git push origin feature/fase1-pre-separacion --force
```

### ⚠️ Advertencias

- **`git reset --hard`** elimina todos los cambios no commiteados
- Si ya pusheaste a remoto, necesitarás `--force` (puede afectar a otros developers)
- Guarda cualquier cambio importante antes de hacer reset

---

## 🗄️ OPCIÓN 2: Restaurar desde Backup (Seguro)

**Cuándo usar:** Si algo salió muy mal y quieres empezar desde cero.

**Ventaja:** ✅ Completamente seguro, no depende de Git

**Desventaja:** 🐌 Más lento (~5 minutos)

### Pasos

```bash
# 1. Ir al directorio padre
cd /Users/jhoanmedina/source/EduGo

# 2. Renombrar directorio actual (por seguridad)
mv Analisys Analisys.backup-$(date +%Y%m%d-%H%M%S)

# 3. Extraer backup
cd ~/Backups
tar -xzf edugo-monorepo-backup-20251030.tar.gz -C /Users/jhoanmedina/source/EduGo

# 4. Verificar que se restauró correctamente
cd /Users/jhoanmedina/source/EduGo/Analisys
ls -la

# 5. Verificar estado de Git
git status
git log --oneline -5

# 6. Si todo está bien, eliminar backup antiguo
# rm -rf /Users/jhoanmedina/source/EduGo/Analisys.backup-*
```

### Verificación Post-Restauración

```bash
# Verificar estructura de directorios
ls -la shared/ source/

# Verificar que los servicios compilan
cd source/api-mobile && go build ./...
cd ../api-administracion && go build ./...
cd ../worker && go build ./...

# Verificar tests
cd ../../shared && go test ./...
```

---

## 🔙 OPCIÓN 3: Revertir Repos Separados (Post-FASE 2+)

**Cuándo usar:** Si ya separaste en múltiples repos y quieres volver al monorepo.

**Ventaja:** ✅ Funciona incluso después de separación

**Desventaja:** ⚠️ Complejo, requiere eliminar repos remotos

### Escenario: Ya creaste repos en GitHub

#### Paso 1: Eliminar Repos Remotos

```bash
# Opción A: Desde GitHub UI
# - Ir a github.com/edugo/<repo-name>
# - Settings > Danger Zone > Delete this repository
# - Confirmar escribiendo el nombre del repo

# Opción B: Con GitHub CLI
gh repo delete edugo/edugo-shared --yes
gh repo delete edugo/edugo-api-mobile --yes
gh repo delete edugo/edugo-api-administracion --yes
gh repo delete edugo/edugo-worker --yes
gh repo delete edugo/edugo-dev-environment --yes
```

#### Paso 2: Eliminar Directorios Locales (si existen)

```bash
cd /Users/jhoanmedina/source/EduGo

# Eliminar directorios de repos separados
rm -rf edugo-shared
rm -rf edugo-api-mobile
rm -rf edugo-api-administracion
rm -rf edugo-worker
rm -rf edugo-dev-environment
```

#### Paso 3: Restaurar Monorepo

```bash
# Usar OPCIÓN 2 (Restaurar desde backup)
cd ~/Backups
tar -xzf edugo-monorepo-backup-20251030.tar.gz -C /Users/jhoanmedina/source/EduGo

# Verificar
cd /Users/jhoanmedina/source/EduGo/Analisys
git status
```

#### Paso 4: Eliminar Mirrors en GitLab (si creaste)

```bash
# Desde GitLab UI:
# - Ir a gitlab.com/edugo/<project>
# - Settings > General > Advanced > Remove project
# - Confirmar
```

---

## 🚨 Plan de Contingencia por Problema

### Problema 1: "No puedo volver a compilar el proyecto"

```bash
# Solución: Restaurar desde backup
cd ~/Backups
tar -xzf edugo-monorepo-backup-20251030.tar.gz -C /tmp
cd /tmp/Analisys

# Compilar desde backup para verificar
go build ./source/api-mobile/...
go build ./source/api-administracion/...
go build ./source/worker/...

# Si compila OK, reemplazar proyecto actual
```

### Problema 2: "Perdí el backup"

```bash
# Solución: Buscar en repositorio Git
git log --all --oneline | grep "monorepo-final"
git checkout <commit-hash>

# Crear nuevo backup
cd /Users/jhoanmedina/source/EduGo
tar -czf ~/Backups/edugo-monorepo-recovery-$(date +%Y%m%d).tar.gz Analisys/
```

### Problema 3: "Repos separados no funcionan"

```bash
# Solución rápida: Volver al monorepo temporalmente
cd /Users/jhoanmedina/source/EduGo/Analisys
git checkout monorepo-final

# Trabajar desde monorepo mientras arreglas repos separados
# No eliminar repos separados hasta confirmar rollback completo
```

### Problema 4: "Tag 'monorepo-final' no existe"

```bash
# Solución: Buscar commits recientes
git log --all --oneline -20

# Encontrar commit antes de separación (busca "FASE 1" o "Pre-Separación")
git checkout <commit-hash>

# Crear tag manualmente
git tag -a monorepo-final-recovery -m "Recovery tag"
```

---

## ✅ Checklist Pre-Rollback

Antes de ejecutar cualquier opción de rollback, verifica:

- [ ] **¿Hay código sin commitear que quiero conservar?**
  - Si sí: `git stash save "backup-before-rollback"`
  - Si no: Continuar

- [ ] **¿He pusheado cambios a remoto?**
  - Si sí: Usar OPCIÓN 2 (backup) es más seguro
  - Si no: OPCIÓN 1 (git reset) es más rápida

- [ ] **¿Otros developers tienen cambios basados en mi trabajo?**
  - Si sí: ⚠️ **COORDINAR con el equipo antes de rollback**
  - Si no: Continuar

- [ ] **¿Existe el backup en ~/Backups/?**
  ```bash
  ls -lh ~/Backups/edugo-monorepo-backup-*.tar.gz
  ```
  - Si sí: ✅ Continuar
  - Si no: ⚠️ **CREAR BACKUP AHORA** antes de rollback

- [ ] **¿He documentado qué salió mal?**
  - Crear archivo: `ROLLBACK_REASON_$(date +%Y%m%d).md`
  - Documentar: ¿Qué falló? ¿Por qué rollback? ¿Qué hacer diferente?

---

## 📊 Matriz de Decisión

| Situación | Opción Recomendada | Tiempo | Riesgo |
|-----------|-------------------|--------|--------|
| Acabé FASE 1, quiero deshacer | OPCIÓN 1 | 1 min | Bajo |
| Proyecto no compila | OPCIÓN 2 | 5 min | Muy Bajo |
| Ya separé repos, quiero volver | OPCIÓN 3 | 15 min | Medio |
| Perdí acceso a Git | OPCIÓN 2 | 5 min | Muy Bajo |
| Otros developers afectados | OPCIÓN 2 + Comunicación | 10 min | Bajo |

---

## 🔍 Verificación Post-Rollback

Después de ejecutar cualquier opción, verifica:

```bash
# 1. Estructura de directorios correcta
ls -la shared/ source/
# Debe mostrar: shared/, source/api-mobile, source/api-administracion, source/worker

# 2. Git en estado correcto
git status
# Debe mostrar: "On branch feature/fase1-pre-separacion" o "main"

# 3. Dependencias de shared funcionan
cd shared && go mod tidy && go test ./...
# Todos los tests deben pasar

# 4. Servicios compilan
cd ../source/api-mobile && go build ./cmd/api-mobile
cd ../api-administracion && go build ./cmd/api-administracion
cd ../worker && go build ./cmd/worker
# Todos deben compilar sin errores

# 5. Docker Compose funciona
cd ../../
docker-compose -f docker-compose.dev.yml config
# No debe mostrar errores

# 6. Archivos de documentación existen
ls -la *.md shared/*.md
# Debe mostrar: README.md, PLAN-SEPARACION-COMPLETO.md, etc.
```

---

## 📞 Contactos de Emergencia

Si el rollback falla, contactar:

1. **Equipo de desarrollo:** Revisar documentación en `/docs`
2. **Backup secondary:** Verificar si existe copia en otro lugar
3. **Git remoto:** Verificar si existe el tag `monorepo-final` en GitHub/GitLab

---

## 📝 Log de Rollbacks

Cada vez que ejecutes un rollback, documenta aquí:

```
| Fecha | Opción Usada | Razón | Resultado | Notas |
|-------|-------------|-------|-----------|-------|
| YYYY-MM-DD | OPCIÓN X | [Razón] | [OK/FAIL] | [Observaciones] |
```

---

**Última actualización:** 30 de Octubre, 2025
**Mantenedor:** Equipo EduGo
**Versión del plan:** 1.0
