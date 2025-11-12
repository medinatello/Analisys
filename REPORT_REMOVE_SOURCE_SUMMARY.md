Resumen de la eliminación planificada de la carpeta `source/`

Fecha: 11 de noviembre de 2025
Ramas relevantes: `main` (local), `origin/main` (remoto), `feature/fase1-pre-separacion` (actual)
Prioridad: Alta — la carpeta `source/` será eliminada permanentemente del repositorio como parte de la separación de proyectos. Todo el análisis y las decisiones posteriores deben tratar cualquier contenido dentro de `source/` como deprecado; NO analizar ni migrar código desde `source/` en este documento.

Objetivo del documento

- Dejar constancia clara y detallada de las diferencias entre la rama local `main`, la rama `origin/main` y la rama de trabajo `feature/fase1-pre-separacion`, excluyendo cualquier contenido bajo `source/`.
- Proveer una guía y checklist accionable para proceder con la eliminación segura de `source/` y el cierre de la fase de separación.

1) Estado actual (resumen numérico)

- Comparación `main` (local) vs `origin/main` (remoto), excluyendo `source/`:
  - Commits en `main` que no están en `origin/main` (y que afectan archivos fuera de `source/`): 33
  - Archivos diferentes entre `main` y `origin/main` (excluyendo `source/`): 101

- Comparación `feature/fase1-pre-separacion` vs `origin/main`, excluyendo `source/`:
  - Commits en `feature/fase1-pre-separacion` que no están en `origin/main` (excluyendo `source/`): 45
  - Archivos diferentes entre `feature/fase1-pre-separacion` y `origin/main` (excluyendo `source/`): 133

Notas sobre estas cifras:
- Los `rev-list` mostraron que localmente hay más commits que en `origin/main` (48 en `main` vs 0 en el remoto; 61 en `feature` vs 0 en remoto). Al excluir `source/`, los conteos de commits que tocan archivos fuera de `source/` son los indicados arriba (33 y 45).
- No se encontraron commits en `origin/main` que no estén en tu `main` o en tu `feature` (es decir, el remoto no tiene commits que falten en tu local según `git fetch`). Esto sugiere que tus cambios locales aún no fueron empujados.

2) Áreas y archivos importantes afectados (excluyendo `source/`)

Principales áreas con cambios detectados (lista representativa):
- `shared/`: go.mod, go.sum, varios paquetes (`pkg/auth/jwt.go`, `pkg/database/*`, `pkg/logger/*`, `pkg/messaging/*`, `pkg/types/*`, `pkg/validator/*`) y tests añadidos.
- Documentación y planes: `PLAN-SEPARACION-COMPLETO.md`, `README.md`, `INFORME_ARQUITECTURA.md`, `EJEMPLO_IMPLEMENTACION_COMPLETO.md`, diversas guías (`GUIA_*`), `RESUMEN_*` y `EduGo-Informes-Separacion/*`.
- Scripts y helpers: `scripts/*`, `scripts/local/*`, `scripts/secrets/*`, `scripts/gitlab-runner-*`.
- Docker y CI: `docker-compose*.yml`, `Dockerfile.*`, `docker/` y templates `.gitlab-ci.yml.*`, `docker-compose.dev.yml`.
- Root config and env examples: `.editorconfig`, `.gitignore`, `.golangci.yml`, `.sops.yaml`, `.vscode/launch.json`, `.env.*` templates.
- Top-level helper scripts: `start-all.sh`, `stop-all.sh`, `status.sh`, `logs-all.sh`, `Makefile`.
- Plantillas y despliegue env: `edugo-dev-environment/` carpeta con su `README` y `docker`.

Si deseas, puedo volcar la lista completa de los 101/133 archivos en un archivo `reports/diff_files_excl_source_main_vs_origin.txt` y `reports/diff_files_excl_source_feature_vs_origin.txt`.

3) Observaciones y riesgos

- Riesgos al eliminar `source/`:
  - Si otras ramas remotas aún contienen `source/` (u otros colaboradores lo usan), la eliminación puede causar conflictos o perder trazabilidad. Recomiendo coordinar la eliminación mediante un PR y un anuncio en el equipo.
  - Si la eliminación se hace sin limpiar referencias en CI/CD (por ejemplo plantillas o Dockerfiles que aún referencien paths dentro de `source/`), pipelines pueden fallar. Hay que revisar `Dockerfile.*`, `docker-compose*` y plantillas de CI para referencias a `source/`.
  - Si hay tags o releases que referencian archivos dentro de `source/`, conviene documentarlo en el PR de eliminación para históricos.

- Riesgos operativos inmediatos:
  - Estás adelantado localmente (commits no empujados). Empujar sin revisar puede exponer trabajo parcial, o crear una mezcla donde la eliminación de `source/` se mezcla con otros cambios. Recomiendo separar las preocupaciones: primero empujar y/o crear ramas limpias para la eliminación.

4) Checklist sugerida (ordenada, accionable)

Preparación
- [ ] Hacer backup local (por si acaso): crear rama `backup/pre-separacion-YYYYMMDD` desde tu `feature/fase1-pre-separacion`.
- [ ] Empujar ramas de trabajo actuales (`main` y `feature/fase1-pre-separacion`) a `origin` para centralizar el estado y para que `origin/main` refleje el historial (si eso es deseado).

Aislamiento de la eliminación
- [ ] Crear una rama nueva desde `main` (por ejemplo `chore/remove-source`) o desde la rama que prefieras para el PR de limpieza.
- [ ] En esa rama ejecutar `git rm -r source` y `git commit -m "chore: remove deprecated source/ folder after project separation"`.
- [ ] Corregir cualquier referencia a `source/` en configs, Dockerfiles y CI templates (buscar `source/` en repo y actualizar o eliminar referencias).

Verificación y pruebas
- [ ] Correr tests unitarios en `shared/` y en la raíz (p. ej. `go test ./shared/...` y cualquier test adicional) y arreglar si algo falla.
- [ ] Ejecutar pipelines locales o un pipeline en una rama temporal (por ejemplo, abrir un MR/PR en GitHub/GitLab activando CI) para confirmar que no hay referencias rotas.

Revisión y comunicación
- [ ] Abrir PR desde `chore/remove-source` hacia `main` con descripción clara: por qué `source/` se elimina, enlace a los repositorios nuevos donde está el código (si aplica), pasos de rollback y archivos importantes afectados.
- [ ] Etiquetar a reviewers relevantes y explicar que TODO lo dentro de `source/` está deprecado y no debe revisarse en profundidad.
- [ ] Esperar aprobación y merge. Mantener la rama de respaldo por si necesitas recuperar algo.

Post-merge
- [ ] Eliminar ramas locales y remotas relacionadas con `source/` si procede.
- [ ] Actualizar documentación sobre dónde vive ahora cada módulo/proyecto y cerrar issues relacionados.

5) Comandos útiles (copiables)

- Backup de la rama actual:
```bash
git checkout feature/fase1-pre-separacion
git checkout -b backup/pre-separacion-$(date +%Y%m%d)
git push -u origin backup/pre-separacion-$(date +%Y%m%d)
```

- Crear rama para eliminar `source/` desde `main` y preparar commit (no hago push sin confirmación):
```bash
git checkout main
git pull origin main
git checkout -b chore/remove-source
git rm -r source
git commit -m "chore: remove deprecated source/ folder after project separation"
# revisar cambios y tests antes de push
git push -u origin chore/remove-source
```

- Buscar referencias a `source/` en el repo (revisar archivos que podrían necesitar cambios):
```bash
grep -RIn "source/" --exclude-dir=.git || true
```

- Generar listados de archivos distintos (excluyendo source) y guardarlos en `reports/` (ejemplo):
```bash
mkdir -p reports
git diff --name-only main origin/main | grep -vE '^source/' > reports/diff_files_excl_source_main_vs_origin.txt
git diff --name-only feature/fase1-pre-separacion origin/main | grep -vE '^source/' > reports/diff_files_excl_source_feature_vs_origin.txt
```

- Ejecutar tests en `shared`:
```bash
cd shared
go test ./...
cd -
```

6) Documentación y next steps propuestos

- Puedo generar ahora los archivos en `reports/` con los listados completos y un log detallado de commits (hash, autor, mensaje y archivos) que impactan fuera de `source/`. Dime si quieres que los incluya en el repo como commits.
- Si prefieres que prepare la rama `chore/remove-source` y haga `git rm -r source` pero no haga push, puedo hacerlo y te dejo listo para revisar antes de empujar.
- Puedo también preparar el texto del PR (descripción) listo para pegar en GitHub/GitLab, con links, riesgos y plan de rollback.

Estado de la tarea

- Archivo `REPORT_REMOVE_SOURCE_SUMMARY.md` creado en la raíz con este contenido.
- Checklist del proceso y comandos listados arriba.

Resumen final

Tienes cambios significativos fuera de `source/` que deben ser revisados (documentación, `shared/`, infra y scripts). `source/` debe ser eliminado, y este documento prioriza esa decisión: NO analizar nada dentro de `source/` ni intentar migrar código desde allí. Confírmame lo que prefieres que haga ahora: generar reportes detallados, preparar la rama y commit de eliminación, o preparar el PR y su descripción. Puedo ejecutar cualquiera de esas acciones inmediatamente.