# Informes de Separación y Despliegue Cloud - EduGo

**Fecha:** 30 de Octubre, 2025
**Proyecto:** EduGo - Plataforma de Análisis de Evaluaciones
**Ubicación:** Santiago, Chile

---

## 📂 Contenido de este Directorio

Este directorio contiene tres informes completos para ayudarte a:
1. **Preparar** tu proyecto para la separación de repositorios
2. **Separar** correctamente los microservicios y manejar código compartido
3. **Desplegar** en la nube con la mejor estrategia costo-beneficio

---

## 📊 Resumen Ejecutivo

### Estado Actual
- ✅ 3 microservicios en monorepo: `api-mobile`, `api-administracion`, `worker`
- ✅ Carpeta `shared/` con código compartido (auth, database, messaging, etc.)
- ✅ Todos los sprints completados
- ⚠️ Necesita separación para desarrollo independiente
- ⚠️ GitHub Actions suspendido hasta noviembre

### Objetivo
Separar en repositorios independientes y desplegar en la nube manteniendo:
- Código compartido versionado y sincronizado
- CI/CD automatizado
- Costos optimizados
- Desarrollo ágil por equipo

---

## 📋 Los 3 Informes

### 1️⃣ Checklist Pre-Separación
📁 `1-Pre-Separacion/CHECKLIST-PRE-SEPARACION.md`

**Qué encontrarás:**
- Lista completa de tareas antes de separar proyectos
- Análisis de dependencias de `shared/`
- Plan de testing y validación
- Estrategia de versionamiento
- Preparación de infraestructura Docker
- Plan de rollback

**Tiempo estimado:** 12-17 días de trabajo

**⭐ Acción recomendada:**
- Completar al menos 80% de FASE 1 (Documentación) y FASE 3 (shared/)
- No separar hasta tener tests sólidos

---

### 2️⃣ Estrategia de Separación
📁 `2-Estrategia-Separacion/ESTRATEGIA-SEPARACION.md`

**Qué encontrarás:**
- 4 opciones para manejar código compartido (análisis completo)
- **Recomendación:** Módulo Go privado en GitHub
- Guía paso a paso para extraer `shared/` como módulo independiente
- Workflow de desarrollo futuro
- Manejo de breaking changes
- Setup de ambiente de desarrollo (VS Code workspace, docker-compose)
- Configuración de CI/CD para repos privados
- Troubleshooting común

**⭐ Decisión clave:**
```
Estrategia Recomendada:
github.com/edugo/edugo-shared (módulo Go privado versionado)

Ventajas:
✅ Versionamiento semántico explícito
✅ Control independiente de actualizaciones
✅ Funciona nativamente con Go modules
✅ Compatible con CI/CD

Estructura final:
├── edugo-shared/              (v0.1.0, v0.2.0, ...)
├── edugo-api-mobile/          (importa shared v0.1.0)
├── edugo-api-administracion/  (importa shared v0.1.0)
└── edugo-worker/              (importa shared v0.1.0)
```

---

### 3️⃣ Comparativa Cloud y CI/CD
📁 `3-Cloud-CICD/COMPARATIVA-CLOUD-CICD.md`

**Qué encontrarás:**

#### Parte A: Comparativa de Nubes
- Análisis completo: **AWS vs GCP vs Azure**
- Presencia en Chile y latencia
- Servicios necesarios (PostgreSQL, MongoDB, RabbitMQ, Storage)
- **Estimación de costos detallada** por proveedor
- Precios en USD y CLP (Santiago, Chile)
- Free tiers y descuentos

#### Parte B: CI/CD
- Comparativa: **GitHub Actions vs GitLab CI vs CircleCI vs Jenkins**
- Precios y límites de cada plataforma
- Configuración de pipelines completos
- Ejemplos de código (.gitlab-ci.yml, .circleci/config.yml)

**⭐ Recomendaciones:**

**Cloud Provider: AWS** ⭐
```
Costo: ~$540/mes USD (~$470,000 CLP/mes) en producción
       ~$290-340/mes primer año con free tier

Razones:
✅ AWS Local Zone en Santiago (latencia ~5-15ms)
✅ Amazon MQ con RabbitMQ nativo (sin refactorizar)
✅ Región completa en Chile para fin de 2026
✅ Ecosistema más completo
✅ Mejor documentación en español

Alternativa: GCP si presupuesto es crítico (~$60/mes más barato)
             pero requiere refactorizar RabbitMQ a Pub/Sub
```

**CI/CD: GitLab CI con Self-Hosted Runners** ⭐
```
Costo: $0 (gratis ilimitado con runners propios)

Razones:
✅ Minutos ilimitados gratis (vs 2,000 de GitHub Actions)
✅ Excelente UI de pipelines
✅ Container Registry incluido
✅ Puedes hacer mirror desde GitHub (no necesitas migrar)

Alternativa: CircleCI si no quieres gestionar runners
             (6,000 min gratis vs 2,000 de GitHub Actions)
```

---

## 💰 Resumen de Costos Estimados

### Primer Año (con Free Tiers)
```
Cloud (AWS):        $290-340/mes  (~$250,000-295,000 CLP)
MongoDB Atlas:      $57/mes       (~$50,000 CLP)
CI/CD (GitLab):     $0            (self-hosted gratis)
Dominio:            $5/mes        (~$4,500 CLP)
────────────────────────────────────────────────────────
TOTAL:              $352-402/mes  (~$306,000-350,000 CLP/mes)
TOTAL ANUAL:        $4,344/año    (~$3.8M CLP/año)
```

### Años Siguientes (sin Free Tier)
```
Cloud (AWS):        $540/mes      (~$470,000 CLP)
MongoDB Atlas:      $57/mes       (~$50,000 CLP)
CI/CD (GitLab):     $0            (self-hosted gratis)
Dominio:            $5/mes        (~$4,500 CLP)
────────────────────────────────────────────────────────
TOTAL:              $602/mes      (~$524,000 CLP/mes)
TOTAL ANUAL:        $7,224/año    (~$6.3M CLP/año)
```

*Tipo de cambio: 1 USD = 870 CLP (aproximado)*

---

## 🚀 Plan de Acción Recomendado

### ✅ FASE 1: Pre-Separación (2-3 semanas)
1. Lee y completa el checklist del **Informe 1**
2. Foco en:
   - Documentar dependencias de `shared/`
   - Crear tests de integración
   - Dockerizar aplicaciones
   - Crear `docker-compose` para desarrollo local

### ✅ FASE 2: Separación (1-2 semanas)
1. Lee el **Informe 2** completamente
2. Extrae `shared/` como módulo independiente
3. Crea repositorios separados:
   - `github.com/edugo/edugo-shared`
   - `github.com/edugo/edugo-api-mobile`
   - `github.com/edugo/edugo-api-administracion`
   - `github.com/edugo/edugo-worker`
4. Actualiza imports y `go.mod` en cada proyecto

### ✅ FASE 3: Setup Cloud (1-2 semanas)
1. Lee el **Informe 3** completamente
2. Crear cuenta AWS y configurar:
   - VPC y networking
   - RDS PostgreSQL
   - MongoDB Atlas
   - Amazon MQ (RabbitMQ)
   - S3 buckets
   - ECS/Fargate

### ✅ FASE 4: CI/CD (1 semana)
1. Configurar GitLab CI:
   - Crear cuenta GitLab
   - Setup self-hosted runner
   - Crear pipelines para cada servicio
2. Alternativa: CircleCI (más simple, sin gestión de runners)

### ✅ FASE 5: Deploy y Pruebas (1 semana)
1. Deploy a staging
2. Pruebas de integración
3. Deploy a producción (manual)
4. Monitoreo y ajustes

**TIEMPO TOTAL ESTIMADO:** 6-9 semanas

---

## ⚠️ Advertencias Importantes

### 1. No Separar Antes de Tiempo
- ❌ No crear repos en GitHub hasta completar FASE 1
- ❌ No hacer cambios grandes en `shared/` antes de separar
- ❌ No separar sin tener tests de integración

### 2. Manejo de `shared/`
- ⚠️ Usar **versionamiento semántico estricto** (v0.1.0, v0.2.0, v1.0.0)
- ⚠️ Breaking changes = MAJOR version bump
- ⚠️ Documentar CHANGELOG en cada release
- ⚠️ Nunca hacer `replace` en producción (solo en desarrollo local)

### 3. GitHub Actions
- ⚠️ Actualmente suspendido hasta noviembre
- ⚠️ 2,000 minutos/mes no serán suficientes (necesitas ~4,500)
- ⚠️ Self-hosted runners son gratis pero requieren gestión
- ✅ **Solución:** Migrar a GitLab CI (gratis ilimitado) o CircleCI (6,000 min)

### 4. Costos Cloud
- ⚠️ Los costos estimados son para carga inicial (100-500 usuarios)
- ⚠️ Con crecimiento 2x cada 6 meses, necesitarás escalar recursos
- ⚠️ Free tier de AWS dura solo 12 meses
- ✅ **Solución:** Implementar auto-scaling y monitoreo de costos

---

## 🔗 Enlaces Rápidos

### AWS
- Calculadora de precios: https://calculator.aws/
- Free Tier: https://aws.amazon.com/free/
- Documentación en español: https://aws.amazon.com/es/

### GitLab CI
- Documentación: https://docs.gitlab.com/ee/ci/
- Self-hosted runners: https://docs.gitlab.com/runner/
- Pricing: https://about.gitlab.com/pricing/

### MongoDB Atlas
- Pricing: https://www.mongodb.com/pricing
- AWS integration: https://www.mongodb.com/cloud/atlas/aws

### CircleCI (alternativa)
- Pricing: https://circleci.com/pricing/
- Documentación: https://circleci.com/docs/

---

## 📞 Preguntas Frecuentes

### ¿Debo separar ahora o esperar?
**R:** Espera hasta completar al menos 80% del Informe 1. Tener tests sólidos y documentación es crítico.

### ¿Puedo usar otro proveedor que no sea AWS?
**R:** Sí, pero considera:
- **GCP:** $60/mes más barato pero sin RabbitMQ nativo (requiere refactorización)
- **Azure:** $85/mes más barato pero sin presencia en Chile

### ¿Y si no quiero usar GitLab?
**R:** Alternativas:
1. **CircleCI:** 6,000 min gratis (3x GitHub Actions), fácil de usar
2. **GitHub Actions Self-Hosted:** Gratis ilimitado pero requieres gestionar runner
3. **Jenkins:** Gratis total pero requiere mantenimiento constante

### ¿Cuándo estará disponible la región de AWS en Chile?
**R:** Fin de 2026. Actualmente hay AWS Local Zone en Santiago con latencia ~5-15ms.

### ¿Puedo empezar con menos recursos y escalar?
**R:** Sí, puedes empezar con instancias más pequeñas:
- RDS: db.t4g.micro (1 GB) = $25/mes
- MongoDB: M0 free tier = $0
- Fargate: Reducir a 0.5 vCPU + 1 GB = ~$100/mes
- **Total mínimo:** ~$200/mes

---

## 📝 Notas Finales

### Estado de los Informes
- ✅ Informe 1: Completo y listo para usar
- ✅ Informe 2: Completo con ejemplos de código
- ✅ Informe 3: Completo con costos actualizados octubre 2025

### Próxima Actualización
Se recomienda revisar estos informes cada 3-6 meses para:
- Actualizar precios de cloud providers
- Revisar nuevos servicios disponibles
- Actualizar estrategias de CI/CD
- Verificar si la región AWS Chile ya está disponible

### Feedback
Si encuentras errores o tienes sugerencias, por favor documéntalos para futuras revisiones.

---

## 🎯 Decisiones Clave a Tomar

Antes de proceder, debes decidir:

1. **¿Cuándo separar?**
   - [ ] Ahora (riesgoso si no completas Informe 1)
   - [ ] En 2-3 semanas (recomendado, completa Informe 1)
   - [ ] En 1-2 meses (conservador, más preparación)

2. **¿Qué estrategia para shared/?**
   - [ ] Módulo Go privado en GitHub (⭐ recomendado)
   - [ ] Git submodules (no recomendado)
   - [ ] Otra opción (revisar Informe 2)

3. **¿Qué cloud provider?**
   - [ ] AWS (⭐ recomendado: latencia, RabbitMQ nativo)
   - [ ] GCP (más barato pero sin RabbitMQ)
   - [ ] Azure (intermedio)

4. **¿Qué CI/CD?**
   - [ ] GitLab CI self-hosted (⭐ recomendado: gratis ilimitado)
   - [ ] CircleCI (fácil, 6,000 min gratis)
   - [ ] GitHub Actions self-hosted (gratis pero gestión)
   - [ ] Jenkins (solo si tienes experiencia)

5. **¿Presupuesto aprobado?**
   - [ ] $352-402/mes primer año (~$306k-350k CLP)
   - [ ] $602/mes años siguientes (~$524k CLP)
   - [ ] Necesito presupuesto menor (revisar opciones en Informe 3)

---

## ✅ Checklist Rápido

Antes de empezar la separación:
- [ ] Leí los 3 informes completos
- [ ] Entiendo la estrategia de módulo Go privado
- [ ] Decidí qué cloud provider usar
- [ ] Decidí qué plataforma de CI/CD usar
- [ ] Tengo presupuesto aprobado
- [ ] Tengo cuenta en el cloud provider elegido
- [ ] Tengo tiempo asignado (6-9 semanas)
- [ ] Respaldé el monorepo actual
- [ ] Creé plan de rollback

---

**¿Listo para empezar?** 🚀

1. Abre `1-Pre-Separacion/CHECKLIST-PRE-SEPARACION.md`
2. Comienza con FASE 1
3. No te saltes pasos
4. Documenta todo

**¡Éxito en tu migración!** 💪

---

**Generado:** 30 de Octubre, 2025
**Herramienta:** Claude Code
**Versión:** 1.0
