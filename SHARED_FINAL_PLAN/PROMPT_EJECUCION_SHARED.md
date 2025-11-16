# 🚀 PROMPT: Ejecutar Plan de Trabajo de edugo-shared (Ejecución Desatendida)

Vas a ejecutar el **Plan de Trabajo Definitivo** para completar y congelar la librería edugo-shared siguiendo la documentación en la carpeta `plan/`.

## 📍 Contexto del Repositorio

**Repositorio:** `github.com/EduGoGroup/edugo-shared` (privado)
**Carpeta de documentación:** `plan/` (en la raíz del repositorio)

Este repositorio contiene una librería Go con arquitectura modular (múltiples módulos independientes con versionado propio).

## 🎯 Tu Misión

Ejecutar el plan de manera **100% desatendida** siguiendo las instrucciones exactas de la documentación en `plan/`. 

**IMPORTANTE:** La carpeta `plan/` es tu ÚNICA fuente de documentación. NO tienes acceso a otros repos o documentación externa. TODO lo que necesitas está en `plan/`.

**REGLAS:**
- ✅ Seguir el plan al pie de la letra
- ✅ NO improvises, NO asumas
- ✅ Si algo no está claro en `plan/`, DETENTE y pregunta

---

## 📚 FASE 1: LECTURA OBLIGATORIA (ANTES DE HACER NADA)

### Paso 1.1: Ubicarte en el Repositorio

```bash
# Deberías estar en la raíz del repo edugo-shared
# Verificar que estás en el lugar correcto:
ls -la

# Debes ver carpetas como: auth/, logger/, config/, plan/, etc.
# Y archivos como: README.md, Makefile, etc.

# Si no ves la carpeta plan/, DETENTE - estás en el lugar equivocado
```

### Paso 1.2: Leer Documentación en Orden

Lee estos archivos EN ESTE ORDEN (están en la carpeta `plan/`):

```bash
cd plan/

# 1. Punto de entrada
cat START_HERE.md

# 2. Vista panorámica
cat RESUMEN_EJECUTIVO.md

# 3. Guía completa
cat 00-README.md

# 4. Estado actual del código
cat 01-ESTADO_ACTUAL.md

# 5. Qué necesitan los consumidores
cat 02-NECESIDADES_CONSOLIDADAS.md

# 6. Módulos que hay que crear
cat 03-MODULOS_FALTANTES.md

# 7. Features que hay que agregar
cat 04-FEATURES_FALTANTES.md

# 8. Plan de sprints
cat 05-PLAN_SPRINTS.md

# 9. Versión objetivo
cat 06-VERSION_CONGELADA.md

# 10. TU GUÍA PRINCIPAL DE EJECUCIÓN
cat 07-CHECKLIST_EJECUCION.md
```

### Paso 1.3: Entender el Plan

Después de leer, debes saber:

- ✅ Qué módulos existen actualmente
- ✅ Qué módulos hay que crear (y por qué)
- ✅ Qué features hay que agregar (y dónde)
- ✅ Cuál es la versión objetivo (probablemente v0.7.0)
- ✅ Cuál es el orden de ejecución (Sprint 0 → 1 → 2 → 3)

**REGLA DE ORO:** Si después de leer NO está 100% claro qué hacer, DETENTE y pregunta. NO adivines.

---

## 🚦 FASE 2: EJECUCIÓN POR SPRINTS

### ⚡ Sprint 0: Auditoría (EJECUTAR PRIMERO)

**Guía:** Seguir `plan/07-CHECKLIST_EJECUCION.md` sección "Sprint 0"

**Objetivo:** Documentar estado REAL del código actual

#### Tareas:

1. **Volver a la raíz del repositorio**
   ```bash
   # Desde plan/, volver a raíz
   cd ..
   
   # Verificar que estás en la raíz
   pwd
   # Debe mostrar algo como: /path/to/edugo-shared
   ```

2. **Verificar ramas**
   ```bash
   # Ver rama actual
   git branch
   
   # Ver estado
   git status
   
   # Actualizar desde remoto
   git checkout main
   git pull origin main
   
   git checkout dev
   git pull origin dev
   
   # Ver diferencias entre ramas
   git diff main dev --stat
   ```
   
   **Acción:** Documentar si hay diferencias y cuáles son.

3. **Listar módulos existentes**
   ```bash
   # En la raíz del repo
   ls -la
   ```
   
   **Acción:** Para cada carpeta que parezca un módulo (tiene go.mod):
   ```bash
   # Ejemplo para auth/
   cd auth/
   cat go.mod
   ls -la
   cd ..
   
   # Repetir para: logger/, config/, database/, messaging/, etc.
   ```

4. **Ver versiones actuales (tags)**
   ```bash
   git tag -l
   ```
   
   **Acción:** Documentar qué tags existen (ej: auth/v0.5.0, logger/v0.5.0, etc.)

5. **Ejecutar tests**
   ```bash
   # Verificar si hay Makefile
   cat Makefile
   
   # Opción 1: Si hay make test
   make test
   
   # Opción 2: Si no hay Makefile
   go test ./... -v
   ```
   
   **Acción:** Documentar resultado por módulo:
   - ✅ PASS - módulo funciona
   - ❌ FAIL - anotar error exacto

6. **Verificar coverage**
   ```bash
   # Si hay comando en Makefile
   make coverage
   
   # Si no
   go test ./... -cover
   ```
   
   **Acción:** Documentar % de coverage por módulo

7. **Actualizar documentación del plan**
   
   ```bash
   # Abrir archivo de estado
   cd plan/
   # Editar 01-ESTADO_ACTUAL.md con los datos REALES que encontraste
   ```
   
   **Completar secciones con formato:**
   ```markdown
   ## Módulos Existentes
   
   ### auth/ (v0.5.0)
   - Última actualización: [fecha del git log]
   - Go version: [del go.mod]
   - Features implementadas:
     - [Feature 1] ✅ (verificado en [archivo]:[línea])
     - [Feature 2] ✅
   - Tests: [N] tests, [X]% coverage
   - Estado: ✅ Estable / ⚠️ En desarrollo / 🔴 Incompleto
   ```

8. **Commit de auditoría**
   ```bash
   cd ..  # volver a raíz
   git add plan/01-ESTADO_ACTUAL.md
   git commit -m "docs(plan): completar estado actual tras auditoría Sprint 0"
   ```

**Criterio de éxito Sprint 0:**
- ✅ `plan/01-ESTADO_ACTUAL.md` completo con datos REALES del código
- ✅ Sabes qué tests pasan/fallan
- ✅ Sabes qué módulos existen y sus versiones
- ✅ Commit creado

**🛑 DETENTE AQUÍ y reporta resultado de Sprint 0 antes de continuar a Sprint 1.**

---

### 🚀 Sprint 1: Crear Módulos Faltantes

**Guía:** Seguir `plan/07-CHECKLIST_EJECUCION.md` sección "Sprint 1"

**Prerequisitos:**
- ✅ Sprint 0 completado
- ✅ Has leído `plan/03-MODULOS_FALTANTES.md` completamente

#### ¿Qué módulos crear?

1. **Leer el plan**
   ```bash
   cat plan/03-MODULOS_FALTANTES.md
   ```

2. **Buscar módulos con Prioridad P0**
   
   El documento debe listar módulos como:
   ```markdown
   ## evaluation/ (Prioridad: P0)
   ## otro-modulo/ (Prioridad: P0)
   ```

Para CADA módulo P0 encontrado, ejecutar estos pasos:

#### Paso 1.1: Crear estructura del módulo

```bash
# En la raíz del repo
cd /ruta/donde/clonaste/edugo-shared

# Crear carpeta del módulo (usar nombre exacto del plan)
mkdir [nombre-modulo]
cd [nombre-modulo]/
```

#### Paso 1.2: Crear go.mod

El plan debe especificar el contenido exacto del `go.mod`.

```bash
# Crear go.mod con contenido del plan
# Copiar EXACTAMENTE lo que dice plan/03-MODULOS_FALTANTES.md
```

#### Paso 1.3: Crear archivos Go

El plan debe listar archivos a crear y su código completo.

```bash
# Ejemplo: Si el plan dice crear "assessment.go"
# Copiar código EXACTO del plan al archivo
```

**⚠️ IMPORTANTE:** 
- Si el código NO está completo en el plan, DETENTE y reporta: "Plan incompleto - falta código de [módulo]/[archivo]"
- NO inventes código que no esté en el plan

#### Paso 1.4: Crear tests

```bash
# El plan debe especificar tests
# Crear archivos _test.go con código del plan
```

#### Paso 1.5: Ejecutar tests del módulo

```bash
# Dentro de la carpeta del módulo
go test -v -cover

# Debe mostrar PASS
# Verificar coverage >80% (o el % que diga el plan)
```

**Si falla:**
1. Leer mensaje de error completo
2. Verificar que copiaste código exacto del plan
3. Si código es exacto y falla, DETENTE y reporta error

#### Paso 1.6: Commit del módulo

```bash
# Volver a raíz
cd ..

# Agregar módulo nuevo
git add [nombre-modulo]/

# Commit con formato descriptivo
git commit -m "feat([nombre-modulo]): crear módulo [nombre] para [caso-uso]

- Implementar estructuras principales
- Agregar funciones core
- Tests con [X]% coverage

Requerido por: [proyectos que lo necesitan según plan]"
```

#### Paso 1.7: Publicar tag del módulo

```bash
# Tag con versión inicial (generalmente v0.1.0)
git tag [nombre-modulo]/v0.1.0

# Push a dev
git push origin dev

# Push del tag
git push origin [nombre-modulo]/v0.1.0
```

**Repetir pasos 1.1 a 1.7 para CADA módulo P0 listado en el plan.**

**Criterio de éxito Sprint 1:**
- ✅ Todos los módulos P0 del plan están creados
- ✅ Tests de cada módulo pasan (PASS)
- ✅ Coverage >80% por módulo
- ✅ Tags publicados
- ✅ Commits con mensajes descriptivos

**🛑 DETENTE AQUÍ y reporta resultado de Sprint 1 antes de continuar a Sprint 2.**

---

### 📦 Sprint 2: Agregar Features Faltantes

**Guía:** Seguir `plan/07-CHECKLIST_EJECUCION.md` sección "Sprint 2"

**Prerequisitos:**
- ✅ Sprint 1 completado
- ✅ Has leído `plan/04-FEATURES_FALTANTES.md` completamente

#### ¿Qué features agregar?

1. **Leer el plan**
   ```bash
   cat plan/04-FEATURES_FALTANTES.md
   ```

2. **Buscar features con Prioridad P0 o P1**
   
   El documento debe listar features como:
   ```markdown
   ## messaging/rabbit/ (v0.5.0 → v0.6.0)
   ### Feature: Dead Letter Queue Support (P0)
   ```

Para CADA feature P0/P1 encontrada:

#### Paso 2.1: Ir al módulo existente

```bash
# Desde la raíz del repo
cd [modulo-existente]/

# Ejemplo:
cd messaging/rabbit/
```

#### Paso 2.2: Modificar archivos según plan

El plan debe especificar:
- ✅ Qué archivos modificar
- ✅ Qué código agregar (código completo)
- ✅ Dónde agregarlo (al final, en sección X, etc.)

**Ejemplo del plan:**
```markdown
**Archivos a modificar:**
- `consumer.go` - Agregar función ConsumerWithRetry al final del archivo

**Código a agregar:**
```go
// consumer.go - AGREGAR AL FINAL
func (c *Consumer) ConsumeWithRetry(cfg RetryConfig) error {
    // [código completo aquí]
}
```
```

**Tu acción:**
- Abrir el archivo especificado
- Agregar código EXACTAMENTE donde dice el plan
- Guardar

#### Paso 2.3: Agregar/actualizar tests

```bash
# El plan debe especificar qué tests agregar
# Editar archivo _test.go correspondiente
```

#### Paso 2.4: Ejecutar tests

```bash
# Dentro del módulo
go test -v -cover

# Debe PASS
```

**Si falla:** Verificar código contra plan, reportar si sigue fallando.

#### Paso 2.5: Commit de la feature

```bash
# Volver a raíz
cd ..

# Add cambios
git add [modulo]/

# Commit descriptivo
git commit -m "feat([modulo]): agregar soporte para [feature]

- Implementar [feature específica]
- Agregar tests
- Coverage: [X]%

Requerido por: [proyecto según plan]"
```

#### Paso 2.6: Actualizar versión del módulo

```bash
# Tag con nueva versión (incrementar minor: v0.5.0 → v0.6.0)
git tag [modulo]/v0.6.0

# Push
git push origin dev
git push origin [modulo]/v0.6.0
```

**Repetir pasos 2.1 a 2.6 para CADA feature P0/P1.**

**Criterio de éxito Sprint 2:**
- ✅ Todas las features P0/P1 implementadas
- ✅ Tests passing
- ✅ Versiones actualizadas
- ✅ Commits descriptivos

**🛑 DETENTE AQUÍ y reporta resultado de Sprint 2 antes de continuar a Sprint 3.**

---

### 🎯 Sprint 3: Consolidación y Congelamiento

**Guía:** Seguir `plan/07-CHECKLIST_EJECUCION.md` sección "Sprint 3"

**Prerequisitos:**
- ✅ Sprints 1 y 2 completados
- ✅ Has leído `plan/06-VERSION_CONGELADA.md`

#### Objetivo

Publicar versión coordinada de todos los módulos y declarar shared como CONGELADO.

#### Paso 3.1: Suite completa de tests

```bash
# En la raíz del repo
pwd  # verificar que estás en raíz

# Ejecutar TODOS los tests
make test
# O si no hay Makefile:
go test ./... -v -cover
```

**DEBE CUMPLIR:**
- ✅ 0 tests failing (todos PASS)
- ✅ Coverage global >85% (o % especificado en plan)

**Si hay failures:** ARREGLAR antes de continuar. NO proceder con tests failing.

#### Paso 3.2: Actualizar README.md

```bash
# Editar README.md principal
# Agregar al inicio (según especifica plan/06-VERSION_CONGELADA.md):

## ⚠️ SHARED IS FROZEN AT v0.7.0

**Version v0.7.0 is frozen.** No new features until post-MVP.

Only critical bug fixes allowed (v0.7.x patches).

See CHANGELOG.md for details.
```

#### Paso 3.3: Crear CHANGELOG.md

```bash
# El plan debe tener contenido completo del CHANGELOG
# Crear archivo con contenido de plan/06-VERSION_CONGELADA.md sección CHANGELOG
```

#### Paso 3.4: Merge a main

```bash
# Asegurar que dev está actualizado
git checkout dev
git pull origin dev

# Cambiar a main
git checkout main
git pull origin main

# Mergear dev en main
git merge dev

# Si hay conflictos:
# - Leer git status
# - DETENTE y reporta "Conflicto en merge. Archivos: [lista]"
# - Espera instrucciones (NO resolver solo)

# Si NO hay conflictos:
git push origin main
```

#### Paso 3.5: Publicar tags coordinados (versión congelada)

El plan debe especificar la versión final (ej: v0.7.0).

```bash
# En main branch
git checkout main

# Tag para CADA módulo existente con versión coordinada
# Ejemplo (ajustar según módulos reales):
git tag auth/v0.7.0
git tag logger/v0.7.0
git tag config/v0.7.0
git tag database/postgres/v0.7.0
git tag database/mongodb/v0.7.0
git tag messaging/rabbit/v0.7.0
git tag middleware/gin/v0.7.0
git tag bootstrap/v0.7.0
git tag lifecycle/v0.7.0
git tag common/v0.7.0
git tag evaluation/v0.7.0  # Si se creó en Sprint 1
git tag testing/v0.7.0

# Push TODOS los tags
git push origin --tags
```

#### Paso 3.6: Crear GitHub Release

```bash
# Si está disponible gh CLI:
gh release create v0.7.0 \
  --title "edugo-shared v0.7.0 - Frozen Release" \
  --notes "Version congelada. Ver CHANGELOG.md para detalles."

# Si no está disponible gh CLI:
# DETENTE y reporta: "GitHub Release necesita crearse manualmente"
```

#### Paso 3.7: Commit final de documentación

```bash
git add README.md CHANGELOG.md plan/
git commit -m "docs: declare shared v0.7.0 as frozen

- Add frozen notice to README
- Create CHANGELOG with v0.7.0 changes
- All modules coordinated at v0.7.0
- No new features until post-MVP"

git push origin main
```

**Criterio de éxito Sprint 3:**
- ✅ 0 tests failing
- ✅ Coverage >85%
- ✅ README con "FROZEN" notice
- ✅ CHANGELOG.md creado
- ✅ Todos los módulos en v0.7.0
- ✅ GitHub Release publicado
- ✅ Merged a main
- ✅ Trabajo completado

---

## 📋 REGLAS DE EJECUCIÓN DESATENDIDA

### ✅ HACER:

1. **Seguir el plan literalmente**
   - Si dice "crear archivo X", crear exactamente eso
   - Si da código, copiar exactamente
   - Si da comando, ejecutar exactamente

2. **Ejecutar tests SIEMPRE**
   - Después de crear módulo
   - Después de modificar código
   - Antes de commit
   - Antes de publicar tag

3. **Commits frecuentes y descriptivos**
   - Después de cada tarea completada
   - Mensajes según formato del plan
   - Push regularmente a origin/dev

4. **DETENERTE cuando no esté claro**
   - Si plan dice "implementar X" sin código completo
   - Si test falla sin razón clara
   - Si encuentras error inesperado
   - Si hay conflicto de merge

### ❌ NO HACER:

1. **NO improvisar**
   - NO agregar features no especificadas
   - NO cambiar estructura no documentada
   - NO "mejorar" código por tu cuenta

2. **NO asumir**
   - NO asumir que módulo existe - verificar
   - NO asumir que test pasa - ejecutar
   - NO asumir versiones - verificar tags

3. **NO saltarse pasos**
   - Sprint 0 ANTES de Sprint 1 (siempre)
   - NO tags sin tests passing
   - NO push sin commit previo

4. **NO modificar plan/**
   - La carpeta `plan/` es READONLY
   - Si hay error en plan, REPORTAR no corregir

---

## 📊 FORMATO DE REPORTE DE PROGRESO

**Después de CADA sprint, reportar usando este formato:**

```markdown
## Reporte Sprint [N]

**Sprint:** [0/1/2/3]
**Estado:** ✅ COMPLETADO / ⚠️ BLOQUEADO / ❌ FALLIDO
**Tiempo:** [horas tomadas]

### Tareas Completadas
- [X] Tarea 1 - descripción
- [X] Tarea 2 - descripción

### Tareas Pendientes/Bloqueadas
- [ ] Tarea 3 - Bloqueada por: [razón]

### Tests
- Módulos testeados: [N]
- Tests passing: [N]
- Tests failing: [N] → Detalles: [cuáles y por qué]
- Coverage promedio: [X%]

### Commits Creados
- Total commits: [N]
- Branch actual: [dev/main]
- Último commit hash: [hash corto]
- Último commit mensaje: [mensaje]

### Tags Publicados
- [modulo]/v[X.Y.Z]
- [modulo]/v[X.Y.Z]
- Total tags: [N]

### Bloqueantes (si existen)
- [Descripción detallada del bloqueante]
- [Qué información/acción necesitas para continuar]

### Próximo Paso
- [ ] Leer documentación Sprint [N+1]
- [ ] Ejecutar Sprint [N+1]
```

---

## 🎯 CHECKLIST DE VALIDACIÓN FINAL

Antes de declarar "trabajo completado", verificar:

- [ ] Leí TODA la documentación en `plan/`
- [ ] Ejecuté Sprint 0 (auditoría) ✅
- [ ] Reporté Sprint 0 ✅
- [ ] Ejecuté Sprint 1 (módulos nuevos) ✅
- [ ] Reporté Sprint 1 ✅
- [ ] Ejecuté Sprint 2 (features) ✅
- [ ] Reporté Sprint 2 ✅
- [ ] Ejecuté Sprint 3 (consolidación) ✅
- [ ] Reporté Sprint 3 ✅
- [ ] TODOS los tests pasan (0 failures)
- [ ] Coverage >85% global
- [ ] Versión v0.7.0 publicada (todos los módulos)
- [ ] README.md contiene "FROZEN" notice
- [ ] CHANGELOG.md existe y está completo
- [ ] Merged a main exitosamente
- [ ] GitHub Release creado (si fue posible)

---

## 🚨 MANEJO DE CASOS ESPECIALES

### Caso 1: Plan incompleto o ambiguo

**Síntoma:** El plan dice hacer algo pero no da código/detalles completos

**Acción:**
```
🛑 DETENTE INMEDIATAMENTE

Reportar:
"Plan incompleto detectado
Archivo: plan/[nombre-archivo].md
Sección: [nombre de sección]
Problema: [qué falta - código/comando/especificación]
No puedo continuar sin esta información."

ESPERAR instrucciones.
```

### Caso 2: Tests fallan inesperadamente

**Síntoma:** Seguiste el plan exactamente pero tests fallan

**Acción:**
```
🛑 DETENTE

Reportar:
"Test failing inesperado
Módulo: [nombre]
Test: [nombre del test]
Error completo: [copiar mensaje de error]
Comando ejecutado: [comando exacto]
Código usado: Exacto del plan (verificado)
¿Posible causa?: [tu análisis si tienes uno]"

ESPERAR instrucciones.
```

### Caso 3: Conflicto en merge

**Síntoma:** `git merge` muestra conflictos

**Acción:**
```
🛑 DETENTE

git status  # ver archivos en conflicto

Reportar:
"Conflicto en merge detectado
Merge: [branch origen] → [branch destino]
Archivos en conflicto: [lista completa]
Contenido conflicto: [mostrar para cada archivo]

NO resolveré por mi cuenta. Esperando instrucciones."

ESPERAR instrucciones.
```

### Caso 4: Comando falla por permisos/entorno

**Síntoma:** Comando del plan falla por razones de entorno

**Acción:**
```
🛑 DETENTE

Reportar:
"Comando falló por entorno
Comando: [comando exacto]
Error: [mensaje completo]
Posible causa: [permisos/path/dependencia faltante]
Necesito: [qué necesitas para continuar]"

ESPERAR instrucciones.
```

---

## ✅ CRITERIO DE ÉXITO ABSOLUTO

**Has completado el trabajo exitosamente SI Y SOLO SI:**

1. ✅ Ejecutaste 4 sprints completos (0, 1, 2, 3)
2. ✅ Todos los módulos P0 del plan existen
3. ✅ Todas las features P0/P1 implementadas
4. ✅ `go test ./... -v` muestra 0 failures
5. ✅ Coverage reportado >85%
6. ✅ Todos los módulos tienen tag v0.7.0
7. ✅ README.md contiene aviso "FROZEN"
8. ✅ CHANGELOG.md existe
9. ✅ Branch main contiene todo el trabajo
10. ✅ GitHub Release v0.7.0 publicado (o reportaste que necesita hacerse manual)

**Mensaje de éxito:**
```
✅ TRABAJO COMPLETADO EXITOSAMENTE

edugo-shared v0.7.0 está:
- ✅ Congelado
- ✅ Testeado (0 failures, >85% coverage)
- ✅ Publicado (todos los módulos en v0.7.0)
- ✅ Documentado (README + CHANGELOG)
- ✅ Listo para ser consumido por api-mobile, api-admin y worker

Próximos pasos (fuera de este plan):
- Actualizar consumidores con go.mod apuntando a v0.7.0
- Validar integración en cada proyecto
```

---

## 🚀 INICIAR AHORA

**Tu primera acción al recibir este prompt:**

```bash
# 1. Verificar ubicación
pwd
ls -la

# 2. Ir a carpeta plan/
cd plan/

# 3. Leer documentos en orden
cat START_HERE.md
cat RESUMEN_EJECUTIVO.md
cat 00-README.md

# 4. Entender qué hay que hacer
cat 07-CHECKLIST_EJECUCION.md

# 5. Volver a raíz y empezar Sprint 0
cd ..
# ... ejecutar Sprint 0 según checklist
```

**Después de completar Sprint 0:** Reportar resultado y ESPERAR antes de continuar a Sprint 1.

---

**¡ADELANTE! La carpeta `plan/` tiene TODO lo que necesitas. Confía en el plan y síguelo paso a paso.** 🎉
