# Checklist Pre-Separación de Proyectos EduGo

**Fecha:** 30 de Octubre, 2025
**Proyecto:** EduGo - Análisis de Evaluaciones
**Estado Actual:** Monorepo en desarrollo

---

## 1. Análisis del Estado Actual

### 1.1 Estructura Actual
```
Analisys/
├── source/
│   ├── api-administracion/
│   ├── api-mobile/
│   ├── worker/
│   └── scripts/
└── shared/
    └── pkg/
        ├── auth/          # JWT y autenticación
        ├── config/        # Configuración de entorno
        ├── database/      # Conexiones MongoDB y PostgreSQL
        ├── errors/        # Manejo de errores
        ├── logger/        # Sistema de logs (Zap)
        ├── messaging/     # RabbitMQ (Publisher/Consumer)
        ├── types/         # Tipos compartidos y enums
        └── validator/     # Validación
```

### 1.2 Dependencias Identificadas
Todos los proyectos dependen de `shared/` mediante:
```go
replace github.com/edugo/shared => ../../shared
```

**Módulos compartidos actualmente en uso:**
- ✅ Conexiones a bases de datos (MongoDB y PostgreSQL)
- ✅ Sistema de autenticación JWT
- ✅ Configuración de variables de entorno
- ✅ Sistema de logging centralizado
- ✅ Cliente RabbitMQ (Publisher/Consumer)
- ✅ Tipos y enums compartidos
- ✅ Manejo de errores centralizado
- ✅ Validadores compartidos

---

## 2. Checklist Pre-Separación

### ✅ FASE 1: Documentación y Análisis (COMPLETAR ANTES DE SEPARAR)

#### 2.1 Documentación de Arquitectura
- [ ] **Crear diagrama de arquitectura completo**
  - Incluir todos los servicios (api-administracion, api-mobile, worker)
  - Mostrar dependencias entre servicios
  - Documentar flujos de comunicación (HTTP, RabbitMQ)
  - Identificar bases de datos y sus esquemas

- [ ] **Documentar contratos de API**
  - Verificar que todas las APIs tengan Swagger actualizado
  - Documentar endpoints y sus responsabilidades
  - Documentar payloads de mensajes RabbitMQ
  - Crear catálogo de eventos del sistema

- [ ] **Documentar variables de entorno**
  - Crear archivo `.env.example` para cada proyecto
  - Documentar todas las variables requeridas
  - Identificar secretos y credenciales
  - Crear matriz de configuración por ambiente

#### 2.2 Análisis de Dependencias de `shared/`
- [ ] **Auditar uso de shared en cada proyecto**
  ```bash
  # Ejecutar para cada proyecto
  cd source/api-mobile && grep -r "github.com/edugo/shared" .
  cd source/api-administracion && grep -r "github.com/edugo/shared" .
  cd source/worker && grep -r "github.com/edugo/shared" .
  ```

- [ ] **Identificar dependencias circulares**
  - Verificar que shared/ no importe nada de los proyectos
  - Documentar acoplamiento entre proyectos

- [ ] **Evaluar estabilidad de shared/**
  - ¿Qué tan frecuente cambian los módulos?
  - ¿Qué módulos son más estables?
  - ¿Qué módulos requieren más cambios?

#### 2.3 Testing y Calidad
- [ ] **Ejecutar tests de cada proyecto**
  ```bash
  cd source/api-administracion && make test
  cd source/api-mobile && make test
  cd source/worker && make test
  ```

- [ ] **Verificar cobertura de tests**
  - Objetivo mínimo: 60% de cobertura
  - Priorizar tests de integración con shared/

- [ ] **Tests end-to-end**
  - Crear tests que validen flujos completos
  - Validar comunicación entre servicios
  - Validar procesamiento de mensajes RabbitMQ

#### 2.4 Versionamiento
- [ ] **Definir estrategia de versionamiento semántico**
  - Establecer versión inicial de cada servicio (ej: v1.0.0)
  - Establecer versión inicial de shared (ej: v0.1.0)
  - Documentar política de breaking changes

- [ ] **Crear CHANGELOG.md para cada proyecto**
  - Documentar cambios realizados hasta ahora
  - Establecer formato de changelog

- [ ] **Definir política de releases**
  - ¿Cuándo se hace un release?
  - ¿Cómo se coordinan releases entre servicios?

---

### ✅ FASE 2: Preparación de Infraestructura (COMPLETAR ANTES DE SEPARAR)

#### 2.5 Docker y Contenedores
- [ ] **Crear Dockerfile optimizado para cada servicio**
  - Usar multi-stage builds
  - Minimizar tamaño de imagen
  - Incluir health checks

- [ ] **Crear docker-compose para desarrollo local**
  - Incluir todos los servicios
  - Incluir bases de datos (PostgreSQL, MongoDB)
  - Incluir RabbitMQ
  - Configurar networking entre servicios

- [ ] **Validar builds en local**
  ```bash
  docker build -t edugo-api-mobile:local ./source/api-mobile
  docker build -t edugo-api-admin:local ./source/api-administracion
  docker build -t edugo-worker:local ./source/worker
  ```

#### 2.6 Scripts de Migración
- [ ] **Crear scripts de migración de base de datos**
  - PostgreSQL: Usar herramienta como golang-migrate
  - MongoDB: Crear scripts de inicialización
  - Documentar orden de ejecución

- [ ] **Crear scripts de seed data**
  - Datos de prueba para desarrollo
  - Datos de prueba para testing

#### 2.7 Configuración de Monitoreo
- [ ] **Implementar health checks en cada servicio**
  - Endpoint `/health` o `/healthz`
  - Verificar conexiones a bases de datos
  - Verificar conexión a RabbitMQ

- [ ] **Implementar métricas básicas**
  - Usar Prometheus o similar
  - Métricas de performance
  - Métricas de errores

---

### ✅ FASE 3: Preparación de shared/ (CRÍTICO)

#### 2.8 Estabilización de shared/
- [ ] **Revisar y refactorizar shared/**
  - Eliminar código no utilizado
  - Consolidar funcionalidades similares
  - Mejorar naming y organización

- [ ] **Crear tests para shared/**
  - Tests unitarios para cada paquete
  - Objetivo: 80% de cobertura mínimo
  - Tests de integración para database y messaging

- [ ] **Documentar shared/**
  - Crear README.md en cada paquete
  - Documentar ejemplos de uso
  - Documentar breaking changes potenciales

- [ ] **Versionar shared/ adecuadamente**
  - Crear tags semánticos (v0.1.0, v0.2.0, etc.)
  - Documentar API pública vs privada
  - Establecer política de compatibilidad

#### 2.9 Freezing de shared/ (Opcional pero Recomendado)
- [ ] **Periodo de congelación de cambios**
  - 2 semanas sin cambios en shared/
  - Solo bugfixes críticos
  - Validar estabilidad

---

### ✅ FASE 4: Preparación de Repositorios Git

#### 2.10 Planificación de Repositorios
- [ ] **Definir estructura de repositorios**
  ```
  Opción recomendada:
  - github.com/edugo/edugo-shared
  - github.com/edugo/edugo-api-mobile
  - github.com/edugo/edugo-api-administracion
  - github.com/edugo/edugo-worker
  ```

- [ ] **Crear repositorios en GitHub** (NO CREAR AÚN)
  - Definir si serán privados o públicos
  - Configurar equipos y permisos
  - Preparar templates de Issues y PRs

- [ ] **Definir estrategia de branching**
  - ¿Git Flow? ¿GitHub Flow? ¿Trunk-Based?
  - Definir branch principal (main/master)
  - Definir branches de desarrollo
  - Definir política de pull requests

#### 2.11 Migración de Historial Git
- [ ] **Decidir estrategia de historial**
  - **Opción A:** Empezar de cero (limpio pero pierdes historial)
  - **Opción B:** Usar `git filter-branch` o `git subtree` (mantiene historial)
  - **Recomendación:** Opción A para simplificar

---

### ✅ FASE 5: Plan de Rollback

#### 2.12 Estrategia de Contingencia
- [ ] **Crear backup completo del monorepo**
  - Backup del código completo
  - Backup de bases de datos de desarrollo
  - Documentar estado actual

- [ ] **Documentar proceso de rollback**
  - Cómo volver al monorepo si algo falla
  - Tiempo estimado de rollback
  - Responsables del rollback

- [ ] **Definir criterios de éxito/fracaso**
  - ¿Qué indica que la separación fue exitosa?
  - ¿Cuándo se considera un fracaso y se hace rollback?

---

## 3. Estimación de Tiempo

### Por Fase:
- **FASE 1 (Documentación):** 3-5 días
- **FASE 2 (Infraestructura):** 3-4 días
- **FASE 3 (shared/):** 4-5 días
- **FASE 4 (Git):** 1-2 días
- **FASE 5 (Rollback):** 1 día

**TOTAL ESTIMADO:** 12-17 días de trabajo

---

## 4. Riesgos Identificados

### Alto Riesgo 🔴
1. **Dependencia de shared/ no documentada**
   - Mitigation: Auditoría completa de imports

2. **Breaking changes en shared/ después de separación**
   - Mitigation: Versionamiento semántico estricto

3. **Pérdida de sincronización entre repositorios**
   - Mitigation: CI/CD automatizado y tests de integración

### Medio Riesgo 🟡
1. **Complejidad de CI/CD con múltiples repos**
   - Mitigation: Usar herramientas como GitHub Actions con workflows compartidos

2. **Dificultad para hacer cambios cross-cutting**
   - Mitigation: Documentar proceso de cambios que afecten múltiples servicios

### Bajo Riesgo 🟢
1. **Curva de aprendizaje del equipo**
   - Mitigation: Documentación clara y capacitación

---

## 5. Recomendaciones Finales

### ✅ HACER ANTES DE SEPARAR:
1. **Completar al menos 80% de las tareas de FASE 1 y FASE 3**
2. **Tener un conjunto sólido de tests de integración**
3. **Documentar exhaustivamente shared/**
4. **Crear un docker-compose funcional para desarrollo local**
5. **Definir claramente la estrategia de versionamiento de shared/**

### ❌ NO HACER TODAVÍA:
1. No crear los repositorios en GitHub aún
2. No hacer cambios grandes en shared/
3. No hacer refactorings masivos antes de separar
4. No separar sin tener un plan de CI/CD definido

### 📋 SIGUIENTE PASO:
Revisar el **Informe 2: Estrategia de Separación** para entender cómo manejar shared/ en un entorno multi-repo.

---

**Nota:** Este checklist es una guía. Adapta según las necesidades específicas de tu proyecto y equipo.
