# Análisis carpeta `00-Projects-Isolated`

## Contexto
El README (`00-Projects-Isolated/README.md:80-174`) afirma que cada carpeta es 100% autónoma, con la misma estructura (contexto, requisitos, diseño, sprints, testing, deployment y `PROGRESS.json`). También indica que esta documentación replica las specs cross pero aisladas.

## Hallazgos globales

1. **Faltan los `PROGRESS.json` prometidos**  
   - Según el README cada proyecto debe incluir uno (`líneas 80-112`), pero `find 00-Projects-Isolated -name PROGRESS.json` solo devuelve `api-mobile/PROGRESS.json`.  
   - **Duda:** ¿Dónde se registra el avance para shared, worker, api-admin y dev-environment cuando se trabaja de forma aislada?

2. **Desalineación entre estructura descrita y archivos reales en varios proyectos**  
   - Ejemplo: `dev-environment/START_HERE.md:1-70` describe archivos (`docker-compose.yml`, `.env.example`, `scripts/`, `06-Operations/…`) que no existen en la carpeta real: solo hay `01-Context`…`06-Deployment`, `EXECUTION_PLAN.md` y `START_HERE.md`.  
   - **Duda:** ¿Debemos traer esos archivos desde otro repositorio o todavía no fueron copiados a la versión aislada?

## Evaluación por proyecto

### `shared/`
- **Tareas sin pasos ejecutables:** Los sprints en `04-Implementation` son meros stubs, por ejemplo `Sprint-01-Logger/TASKS.md:1-19` solo muestra la firma del logger sin secuencia de comandos, validaciones o paths. Igual ocurre en `Sprint-02-Database/TASKS.md` y `Sprint-03-Auth/TASKS.md`.  
  → *Duda:* ¿Dónde está el detalle paso a paso (comandos, rutas, criterios de aceptación) que sí existe en la versión cross (`AnalisisEstandarizado/03-Specifications/Spec-01.../01-shared/TASKS.md`)?
- **Diseño y testing insuficientes:** `03-Design/ARCHITECTURE.md:1-12` y `05-Testing/TEST_STRATEGY.md:1-6` son resúmenes de una sola pantalla, sin diagramas, matrices ni criterios de cobertura.  
  → *Duda:* ¿Debemos seguir consultando la spec cross para obtener diseño/testing detallado? Si sí, la carpeta deja de ser autónoma.
- **Ejecución planificada vs sprints reales:** `EXECUTION_PLAN.md` describe 4 fases (Logger+DB, Auth+Messaging, Models+Errors, Health), pero los directorios son `Sprint-01-Logger`, `Sprint-02-Database`, `Sprint-03-Auth`, `Sprint-04-Testing`. Falta la parte de messaging, models, context, errors y health checks.  
  → *Duda:* ¿Dónde están las tareas para messaging/models/context/errors? ¿Se quedaron en otra carpeta?

### `dev-environment/`
- **Archivos críticos ausentes:** El START_HERE menciona `docker-compose.yml`, `.env.example`, `scripts/`, `seeds/`, `06-Operations/`, etc., pero la carpeta solo contiene `01-Context` a `06-Deployment`, `EXECUTION_PLAN.md` y `START_HERE.md`. No hay `scripts` ni `docker-compose` que permitan ejecutar el entorno.  
  → *Duda:* ¿De dónde obtenemos los archivos reales para levantar los servicios? Sin ellos la carpeta aislada no sirve para operar.
- **Tareas referencian archivos inexistentes:** `04-Implementation/Sprint-02-Scripts/TASKS.md` y `06-Deployment/DEPLOYMENT_GUIDE.md` ordenan ejecutar `./scripts/setup.sh`, `seed-data.sh`, etc., pero esos scripts no existen en `dev-environment/`.  
  → *Duda:* ¿Se esperan scripts compartidos con otra carpeta? ¿O deben generarse desde cero?

### `api-mobile/`, `api-admin/`, `worker/`
- Estos tres proyectos sí contienen documentación detallada: sprints con pasos específicos (por ejemplo `api-mobile/04-Implementation/Sprint-01-Schema-BD/TASKS.md` o `worker/04-Implementation/Sprint-01-Auditoria/TASKS.md`), estrategias de testing completas y contexto alineado con las specs originales. No identifiqué bloqueos inmediatos en ellos.

## Riesgo
Los huecos anteriores rompen la promesa de autonomía de la carpeta aislada. En especial, `shared/` y `dev-environment/` no pueden ejecutarse sin volver a la documentación cross u otras fuentes, y el tracking por proyecto queda inconsistente al no tener `PROGRESS.json`.
