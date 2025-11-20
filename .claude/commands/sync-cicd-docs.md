---
description: Sincroniza documentación CI/CD desde Analisys a los 6 proyectos usando subagentes paralelos
---

# Sincronizar Documentación CI/CD a Proyectos

Ejecuta sincronización automática de documentación CI/CD desde el análisis centralizado hacia los 6 proyectos del ecosistema EduGo.

## 🎯 Objetivo

Distribuir la documentación de CI/CD desde:
- **Origen:** `/Users/jhoanmedina/source/EduGo/Analisys/00-Projects-Isolated/cicd-analysis/implementation-plans/`
- **Destino:** `docs/cicd/` en cada uno de los 6 proyectos

## 📋 Proceso Automatizado

El comando ejecuta **6 subagentes en paralelo**, cada uno responsable de:

1. ✅ Cambiar a rama `dev` (o crearla si no existe)
2. ✅ Sincronizar con remoto: `git pull origin dev`
3. ✅ Actualizar desde main: `git merge origin/main --no-edit`
4. ✅ **ELIMINAR** carpeta `docs/cicd/` existente (limpieza completa)
5. ✅ **COPIAR** contenido nuevo desde carpeta fuente
6. ✅ Crear commit: `docs: actualizar documentación CI/CD desde análisis centralizado`
7. ✅ Push a GitHub: `git push origin dev`

## 🔧 Mapeo de Proyectos

| # | Carpeta Fuente | Proyecto Destino | Ruta Destino |
|---|----------------|------------------|--------------|
| 1 | `01-shared/` | edugo-shared | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-shared/docs/cicd/` |
| 2 | `02-infrastructure/` | edugo-infrastructure | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/docs/cicd/` |
| 3 | `03-api-mobile/` | edugo-api-mobile | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/docs/cicd/` |
| 4 | `04-api-administracion/` | edugo-api-administracion | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion/docs/cicd/` |
| 5 | `05-worker/` | edugo-worker | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-worker/docs/cicd/` |
| 6 | `06-dev-environment/` | edugo-dev-environment | `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-dev-environment/docs/cicd/` |

## ⚡ Ejecución

### Paso 1: Verificar Estado Inicial
Antes de ejecutar, mostrar:
- Estado de rama `dev` en cada proyecto (existe/no existe, sincronizado/desincronizado)
- Confirmación del usuario antes de proceder

### Paso 2: Lanzar 6 Subagentes en Paralelo
Cada subagente ejecuta el proceso completo para su proyecto asignado.

### Paso 3: Generar Informe Consolidado
Al finalizar, mostrar:
- ✅/❌ Estado por proyecto
- 📊 Archivos copiados por proyecto
- 🔗 Hash de commits generados
- ⚠️ Errores o warnings
- 📈 Métricas globales (total archivos, líneas, proyectos exitosos)

## 🚨 Reglas Importantes

1. **SIEMPRE eliminar `docs/cicd/` antes de copiar** (sobrescritura completa)
2. **NO hacer commit si hay errores** en pasos previos
3. **NO hacer push si el commit falla**
4. **Reportar TODOS los errores** al usuario
5. **Caso especial:** Si un proyecto no tiene rama `dev`, crearla desde `main`

## 📊 Output Esperado

```
📋 INFORME DE SINCRONIZACIÓN CI/CD
=====================================

✅ edugo-shared
   • Archivos: 7 copiados
   • Commit: a1b2c3d
   • Estado: Sincronizado

✅ edugo-infrastructure
   • Archivos: 6 copiados
   • Commit: e4f5g6h
   • Estado: Sincronizado

... (resto de proyectos)

📈 RESUMEN GLOBAL
• Proyectos exitosos: 6/6
• Total archivos: 35
• Total líneas: ~27,520
• Tiempo: ~45 segundos
```

## 🛠️ Implementación

Usa la herramienta `Task` con `subagent_type: general-purpose` para lanzar los 6 subagentes en paralelo.

Cada subagente recibe:
- Proyecto específico
- Ruta fuente específica
- Ruta destino específica
- Instrucciones detalladas de ejecución

## ⚠️ Pre-requisitos

- Estar en el directorio correcto: `/Users/jhoanmedina/source/EduGo/Analisys`
- Tener acceso a `/Users/jhoanmedina/source/EduGo/repos-separados/`
- Carpeta fuente debe existir: `00-Projects-Isolated/cicd-analysis/implementation-plans/`

---

**Comando:** `/sync-cicd-docs`
**Fecha creación:** 20 de Noviembre, 2025
**Generado por:** Claude Code
