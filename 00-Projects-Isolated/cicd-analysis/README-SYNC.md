# Sincronización de Documentación CI/CD

**Fecha:** 20 de Noviembre, 2025  
**Propósito:** Automatizar la distribución de documentación CI/CD a los 6 proyectos

---

## 🎯 Comando Slash Disponible

### `/sync-cicd-docs`

Sincroniza automáticamente la documentación desde este directorio hacia todos los proyectos usando 6 subagentes en paralelo.

**Ubicación del comando:** `~/.claude/commands/sync-cicd-docs.md`

---

## 📋 Qué Hace el Comando

### Proceso Automatizado por Proyecto:

1. ✅ Cambiar a rama `dev` (o crearla desde `main` si no existe)
2. ✅ Sincronizar con remoto: `git pull origin dev`
3. ✅ Traer cambios de main: `git merge origin/main --no-edit`
4. ✅ **ELIMINAR** carpeta `docs/cicd/` existente (limpieza total)
5. ✅ **COPIAR** contenido actualizado desde carpeta fuente
6. ✅ Crear commit: `docs: actualizar documentación CI/CD desde análisis centralizado`
7. ✅ Push a GitHub: `git push origin dev`

### Características:

- ⚡ **Paralelización:** 6 proyectos simultáneamente
- 🔄 **Sobrescritura completa:** Elimina carpeta antigua y copia nueva
- ✅ **Validación:** Verifica estado antes de proceder
- 📊 **Informe detallado:** Reporta éxito/errores por proyecto

---

## 🗺️ Mapeo de Carpetas

| Carpeta Fuente | → | Proyecto Destino |
|----------------|---|------------------|
| `01-shared/` | → | `edugo-shared/docs/cicd/` |
| `02-infrastructure/` | → | `edugo-infrastructure/docs/cicd/` |
| `03-api-mobile/` | → | `edugo-api-mobile/docs/cicd/` |
| `04-api-administracion/` | → | `edugo-api-administracion/docs/cicd/` |
| `05-worker/` | → | `edugo-worker/docs/cicd/` |
| `06-dev-environment/` | → | `edugo-dev-environment/docs/cicd/` |

**Ruta base proyectos:** `/Users/jhoanmedina/source/EduGo/repos-separados/`

---

## 🚀 Cómo Usar

### Paso 1: Asegúrate de estar en el directorio correcto

```bash
cd /Users/jhoanmedina/source/EduGo/Analisys
```

### Paso 2: Ejecuta el comando slash

```bash
/sync-cicd-docs
```

### Paso 3: Revisa el informe

El comando mostrará:
- Estado de cada proyecto
- Archivos copiados
- Commits creados
- Errores (si los hay)

---

## 📊 Ejemplo de Output

```
📋 INFORME DE SINCRONIZACIÓN CI/CD
=====================================

✅ edugo-shared
   • Archivos: 7 copiados
   • Commit: a1b2c3d
   • Estado: Sincronizado con origin/dev

✅ edugo-infrastructure
   • Archivos: 6 copiados
   • Commit: e4f5g6h
   • Estado: Sincronizado con origin/dev

✅ edugo-api-mobile
   • Archivos: 7 copiados
   • Commit: i9j0k1l
   • Estado: Sincronizado con origin/dev

✅ edugo-api-administracion
   • Archivos: 5 copiados
   • Commit: m2n3o4p
   • Estado: Sincronizado con origin/dev

✅ edugo-worker
   • Archivos: 5 copiados
   • Commit: q5r6s7t
   • Estado: Sincronizado con origin/dev

✅ edugo-dev-environment
   • Archivos: 5 copiados
   • Commit: u8v9w0x
   • Estado: Sincronizado con origin/dev

📈 RESUMEN GLOBAL
=====================================
• Proyectos procesados: 6/6
• Proyectos exitosos: 6/6
• Total archivos distribuidos: 35
• Total líneas de documentación: ~27,520
• Tiempo de ejecución: ~45 segundos
```

---

## ⚠️ Importante

### Reglas del Comando:

1. **SIEMPRE elimina `docs/cicd/` antes de copiar** (no merge, sobrescritura total)
2. **NO hace commit si hay errores** en pasos previos
3. **NO hace push si el commit falla**
4. **Reporta TODOS los errores** inmediatamente

### Casos Especiales:

- Si un proyecto **no tiene rama `dev`**, la crea automáticamente desde `main`
- Si hay **conflictos en merge**, aborta y reporta error
- Si la **carpeta fuente no existe**, reporta error y continúa con otros

---

## 🔧 Cuándo Usar Este Comando

### Usar cuando:

- ✅ Actualizaste documentación en `implementation-plans/`
- ✅ Modificaste algún `README.md`, `SPRINT-*.md`, etc.
- ✅ Agregaste nuevos archivos a las carpetas de proyectos
- ✅ Quieres sincronizar cambios a todos los proyectos de una vez

### NO usar cuando:

- ❌ Solo quieres actualizar UN proyecto (hazlo manualmente)
- ❌ Estás probando cambios (prueba en un proyecto primero)
- ❌ Hay trabajo sin commitear en algún proyecto

---

## 🛠️ Mantenimiento del Comando

### Ubicación del archivo:

```
~/.claude/commands/sync-cicd-docs.md
```

### Para modificar el comando:

```bash
# Editar
nano ~/.claude/commands/sync-cicd-docs.md

# O con VS Code
code ~/.claude/commands/sync-cicd-docs.md
```

### Para ver todos los comandos disponibles:

```bash
ls -la ~/.claude/commands/
```

---

## 📝 Historial de Uso

### Primera ejecución: 19 de Noviembre, 2025
- ✅ Distribuyó documentación inicial a los 6 proyectos
- ✅ Creó rama `dev` en `edugo-dev-environment`
- ✅ 35 archivos distribuidos, ~27,520 líneas

### Segunda ejecución: (Pendiente)
- Actualización de documentación con correcciones de dependencias

---

## 🔗 Referencias

- **Análisis original:** `PLAN-ULTRATHINK.md`
- **Carpetas fuente:** `implementation-plans/01-shared/` hasta `06-dev-environment/`
- **Documento de dependencias:** `../PLAN-ULTRATHINK.md`

---

**Última actualización:** 20 de Noviembre, 2025  
**Generado por:** Claude Code
