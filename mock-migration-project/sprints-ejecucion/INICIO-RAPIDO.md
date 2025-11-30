# Guia de Inicio Rapido

Esta guia te ayudara a comenzar con los sprints de migracion en menos de 5 minutos.

---

## Paso 1: Leer Tracking General (2 minutos)

```bash
cat /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/tracking-api-admin.md
```

Este archivo contiene:
- Resumen ejecutivo del proyecto
- Tabla de progreso general
- Objetivos y arquitectura
- Datos mock disponibles

---

## Paso 2: Ver Primer Sprint (1 minuto)

```bash
cat /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/sprint-0-preparacion/README.md
```

Sprint 0 tiene 6 pasos que toman 33 minutos en total.

---

## Paso 3: Ejecutar Primer Paso (5 minutos)

```bash
# Ver el paso
cat /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/sprint-0-preparacion/paso-01-crear-directorio.md

# Ejecutar comandos
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
mkdir -p tools/mock-generator
cd tools/mock-generator
pwd
```

**Output esperado:**
```
/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
```

✅ Si ves esta ruta, el paso 1 esta completo!

---

## Paso 4: Marcar Progreso (1 minuto)

```bash
# Editar CHECKLIST del sprint
vim /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/sprint-0-preparacion/CHECKLIST.md
```

Cambiar:
```markdown
- [ ] Paso 1 completado
```

Por:
```markdown
- [x] Paso 1 completado
```

---

## Paso 5: Continuar con Siguiente Paso

```bash
cat /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/sprint-0-preparacion/paso-02-inicializar-go-mod.md
```

---

## Estructura de Navegacion

### Archivos Principales
```
/Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/

├── INICIO-RAPIDO.md           ← ESTAS AQUI
├── README.md                  ← Guia general
├── tracking-api-admin.md      ← Tracking completo
└── RESUMEN-FINAL.md           ← Estadisticas
```

### Sprints
```
api-administracion/
├── sprint-0-preparacion/      ← COMENZAR AQUI
├── sprint-1-parser-sql/
├── sprint-2-generador-dataset/
└── sprint-3-integracion-api/
```

### Cada Sprint tiene:
```
sprint-X-nombre/
├── README.md                  ← Leer primero
├── paso-01-xxx.md            ← Ejecutar en orden
├── paso-02-xxx.md
├── ...
└── CHECKLIST.md              ← Marcar progreso
```

---

## Comandos Utiles

### Ver todos los sprints
```bash
ls -l /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/
```

### Ver pasos de un sprint
```bash
ls -1 /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/sprint-0-preparacion/paso-*.md
```

### Buscar un paso especifico
```bash
find /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion -name "*login*"
```

---

## Tips para Ejecucion Exitosa

1. **Lee el paso completo antes de ejecutar** - Entiende que haras
2. **Copia y pega comandos exactamente** - Usan rutas absolutas
3. **Valida cada paso** - Usa los comandos de validacion incluidos
4. **Marca tu progreso** - Actualiza CHECKLIST.md
5. **No saltes pasos** - Cada paso depende del anterior

---

## Progreso Esperado

### Dia 1 (2-3 horas)
- Sprint 0 completo (33 min)
- Sprint 1 completo (2h 40min)

### Dia 2 (3-4 horas)
- Sprint 2 completo (3h 25min)

### Dia 3 (3 horas)
- Sprint 3 completo (2h 55min)
- Validacion final

**Total: ~9 horas distribuidas en 3 dias**

---

## Ayuda Rapida

### Ver tabla de progreso completa
```bash
grep -A 10 "Tabla de Progreso" /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/tracking-api-admin.md
```

### Ver estadisticas finales
```bash
cat /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/RESUMEN-FINAL.md
```

### Ver arquitectura de referencia
```bash
ls /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/plan-arquitectura/plan-final/
```

---

## Siguiente Accion

**AHORA:** Lee el tracking general para entender el proyecto completo

```bash
cat /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/tracking-api-admin.md
```

**DESPUES:** Comienza con el Sprint 0

```bash
cat /Users/jhoanmedina/source/EduGo/Analisys/mock-migration-project/sprints-ejecucion/api-administracion/sprint-0-preparacion/README.md
```

---

¡Exito con la migracion!
