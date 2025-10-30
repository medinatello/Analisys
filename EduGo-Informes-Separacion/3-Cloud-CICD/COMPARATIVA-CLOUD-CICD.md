# Comparativa de Nubes y Estrategia CI/CD para EduGo

**Fecha:** 30 de Octubre, 2025
**Proyecto:** EduGo - Plataforma de Análisis de Evaluaciones
**Ubicación:** Santiago, Chile

---

## 📋 Tabla de Contenidos

1. [Análisis de Necesidades del Proyecto](#1-análisis-de-necesidades-del-proyecto)
2. [Comparativa de Proveedores Cloud](#2-comparativa-de-proveedores-cloud)
3. [Estimación de Costos por Proveedor](#3-estimación-de-costos-por-proveedor)
4. [Servicios Específicos Requeridos](#4-servicios-específicos-requeridos)
5. [Comparativa de Plataformas CI/CD](#5-comparativa-de-plataformas-cicd)
6. [Recomendación Final](#6-recomendación-final)
7. [Plan de Implementación](#7-plan-de-implementación)

---

## 1. Análisis de Necesidades del Proyecto

### 1.1 Arquitectura de EduGo

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────┐
│  api-mobile     │────▶│   RabbitMQ (Queue)   │────▶│   Worker    │
│  (Puerto 8081)  │     └──────────────────────┘     │ (Processor) │
└─────────────────┘              │                   └─────────────┘
        │                        │                          │
        │                        │                          │
        ▼                        ▼                          ▼
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────┐
│  PostgreSQL     │     │    MongoDB Atlas     │     │ S3/Storage  │
│  (Usuarios, etc)│     │  (Summaries, etc)    │     │ (PDFs, etc) │
└─────────────────┘     └──────────────────────┘     └─────────────┘
                                    ▲
                                    │
                        ┌───────────────────────┐
                        │ api-administracion    │
                        │    (Puerto 8082)      │
                        └───────────────────────┘
```

### 1.2 Recursos Estimados por Servicio

| Servicio | CPU | RAM | Tráfico/mes | Storage |
|----------|-----|-----|-------------|---------|
| **api-mobile** | 1-2 vCPU | 2-4 GB | ~100GB | Mínimo |
| **api-administracion** | 1-2 vCPU | 2-4 GB | ~50GB | Mínimo |
| **worker** | 2-4 vCPU | 4-8 GB | ~10GB | ~50GB temporal |
| **PostgreSQL** | 2 vCPU | 4 GB | - | ~10GB inicial |
| **MongoDB** | 2 vCPU | 4 GB | - | ~20GB inicial |
| **RabbitMQ** | 1 vCPU | 2 GB | - | ~5GB |
| **Object Storage** | - | - | - | ~100GB inicial |

### 1.3 Cargas Esperadas (Fase Inicial)

- **Usuarios concurrentes:** 100-500
- **Requests/segundo:** ~10-50 RPS
- **Procesamiento PDFs:** 50-200 documentos/día
- **Crecimiento esperado:** 2x cada 6 meses

---

## 2. Comparativa de Proveedores Cloud

### 2.1 Presencia en Chile y Latam (2025)

| Proveedor | Región Chile | Latency desde Santiago | Status |
|-----------|--------------|------------------------|--------|
| **AWS** | 🟡 Local Zone (2025) + Región completa (fin 2026) | ~5-15ms (Local Zone) | Inversión $4B anunciada |
| **GCP** | ❌ No tiene región | ~150-200ms (São Paulo) | Sin planes anunciados |
| **Azure** | 🟢 Azure Stack Hub disponible | ~100-150ms (Brazil South) | Presencia establecida |

**Conclusión:** AWS tiene ventaja con AWS Local Zone actualmente operativa en Santiago y región completa en camino.

---

### 2.2 Servicios Necesarios - Matriz de Soporte

| Servicio | AWS | GCP | Azure |
|----------|-----|-----|-------|
| **Compute (Containers)** | ✅ ECS/EKS/Fargate | ✅ GKE/Cloud Run | ✅ AKS/Container Instances |
| **PostgreSQL Managed** | ✅ RDS PostgreSQL | ✅ Cloud SQL PostgreSQL | ✅ Azure Database PostgreSQL |
| **MongoDB Managed** | ✅ DocumentDB / Atlas | ✅ MongoDB Atlas | ✅ Cosmos DB / Atlas |
| **Message Queue** | ✅ Amazon MQ (RabbitMQ) | ❌ Pub/Sub (diferente) | ✅ Service Bus (similar) |
| **Object Storage** | ✅ S3 | ✅ Cloud Storage | ✅ Blob Storage |
| **Load Balancer** | ✅ ALB/NLB | ✅ Cloud Load Balancing | ✅ Azure Load Balancer |
| **CDN** | ✅ CloudFront | ✅ Cloud CDN | ✅ Azure CDN |
| **Container Registry** | ✅ ECR | ✅ Artifact Registry | ✅ Azure Container Registry |
| **Secrets Management** | ✅ Secrets Manager | ✅ Secret Manager | ✅ Key Vault |
| **Monitoring** | ✅ CloudWatch | ✅ Cloud Monitoring | ✅ Azure Monitor |

**Notas importantes:**
- **MongoDB:** Los tres proveedores soportan MongoDB Atlas (tercero) que es multiplataforma
- **RabbitMQ:** Solo AWS y Azure ofrecen RabbitMQ managed nativo
- **GCP:** Usa Pub/Sub que es diferente a RabbitMQ (requiere refactorización)

---

### 2.3 Facilidad de Uso y Experiencia de Desarrollo

| Criterio | AWS | GCP | Azure |
|----------|-----|-----|-------|
| **Curva de aprendizaje** | 🟡 Media-Alta | 🟢 Media | 🟡 Media-Alta |
| **Documentación** | 🟢 Excelente | 🟢 Excelente | 🟢 Excelente |
| **CLI/SDKs Go** | 🟢 Excelente | 🟢 Excelente | 🟢 Excelente |
| **Free Tier** | 🟢 12 meses + Always Free | 🟢 $300 crédito + Always Free | 🟢 $200 crédito + 12 meses |
| **Marketplace** | 🟢 Muy amplio | 🟡 Bueno | 🟢 Muy amplio |
| **Comunidad Latam** | 🟢 Grande | 🟡 Media | 🟡 Media |

---

### 2.4 Madurez y Cuota de Mercado

| Métrica | AWS | GCP | Azure |
|---------|-----|-----|-------|
| **Cuota mercado Q2 2025** | ~30% | ~13% | ~20% |
| **Años en el mercado** | 19 años (2006) | 15 años (2010) | 15 años (2010) |
| **# Servicios totales** | 200+ | 100+ | 200+ |
| **Startups usando** | 🟢 Mayoría | 🟡 Muchas | 🟡 Muchas |
| **Enterprise usando** | 🟢 Mayoría | 🟡 Muchos | 🟢 Mayoría (MS ecosystem) |

**Conclusión:** AWS lidera el mercado con mayor adopción y madurez.

---

## 3. Estimación de Costos por Proveedor

### 3.1 Escenario Base - Producción Inicial

**Supuestos:**
- 3 microservicios en contenedores (24/7)
- PostgreSQL: db.t4g.medium (2 vCPU, 4 GB RAM, 20 GB storage)
- MongoDB: Cluster M10 (2 vCPU, 4 GB RAM, 20 GB storage)
- RabbitMQ: 1 instancia pequeña
- Storage: 100 GB + 200 GB transferencia/mes
- Load Balancer
- Sin tráfico excesivo

---

### 3.2 AWS - Precios Detallados (Región São Paulo hasta que Chile esté disponible)

#### Compute - ECS con Fargate
```
3 tareas (servicios) ejecutando 24/7:
- vCPU: 1.5 vCPU cada uno = 4.5 vCPU total
- RAM: 3 GB cada uno = 9 GB total

Costo Fargate (sa-east-1):
- vCPU: 4.5 vCPU × 730 horas × $0.05696 = $187.22
- RAM: 9 GB × 730 horas × $0.00629 = $41.32
TOTAL COMPUTE: $228.54/mes
```

#### Base de Datos - RDS PostgreSQL
```
Instancia: db.t4g.medium (2 vCPU, 4 GB)
- Instancia: $0.098/hora × 730 horas = $71.54
- Storage: 20 GB × $0.138 = $2.76
- Backup: 20 GB incluidos gratis
TOTAL RDS: $74.30/mes
```

#### MongoDB Atlas (Multi-Cloud)
```
Cluster M10:
- Precio base: ~$57/mes (consistente en todas las nubes)
- Storage incluido: 20 GB
TOTAL MONGODB: $57/mes
```

#### Message Queue - Amazon MQ (RabbitMQ)
```
Instancia: mq.t3.micro (broker single-instance para dev/staging)
- Instancia: $0.045/hora × 730 horas = $32.85
- Storage: 20 GB × $0.10 = $2.00
TOTAL MQ: $34.85/mes

Nota: Para producción se recomienda cluster (3 nodos) = ~$105/mes
```

#### Object Storage - S3
```
- Storage: 100 GB × $0.115 = $11.50
- GET requests: 100,000 × $0.0005/1000 = $0.05
- PUT requests: 10,000 × $0.0072/1000 = $0.07
- Data transfer OUT: 100 GB × $0.15 = $15.00
TOTAL S3: $26.62/mes
```

#### Load Balancer - ALB
```
- ALB fijo: $0.027/hora × 730 horas = $19.71
- LCU (Load Balancer Capacity Units): ~$5/mes
TOTAL ALB: $24.71/mes
```

#### Extras
```
- Container Registry (ECR): ~$2/mes (5 GB imágenes)
- CloudWatch Logs: ~$5/mes (10 GB logs)
- Secrets Manager: 3 secrets × $0.40 = $1.20/mes
TOTAL EXTRAS: $8.20/mes
```

#### **TOTAL AWS (São Paulo):**
```
Compute:       $228.54
RDS:           $74.30
MongoDB:       $57.00
RabbitMQ:      $34.85
S3:            $26.62
Load Balancer: $24.71
Extras:        $8.20
────────────────────────
SUBTOTAL:      $454.22/mes
IVA (19%):     $86.30
────────────────────────
TOTAL:         $540.52/mes USD
               ~$470,000 CLP/mes (TC: 870 CLP/USD)
```

**Nota:** Cuando la región de Chile esté disponible (fin 2026), los precios podrían ser similares o ligeramente superiores (+5-10%).

---

### 3.3 Google Cloud Platform - Precios Detallados (Región São Paulo)

#### Compute - Cloud Run
```
3 servicios ejecutando:
- vCPU: 1 vCPU cada uno
- RAM: 2 GB cada uno
- Requests: ~500,000/mes total

Costo Cloud Run:
- vCPU: 3 × 730 horas × $0.00002400 × 3600 = $189.22
- RAM: 6 GB × 730 horas × $0.00000250 × 3600 = $39.42
TOTAL COMPUTE: $228.64/mes
```

#### Base de Datos - Cloud SQL PostgreSQL
```
Instancia: db-n1-standard-1 (1 vCPU, 3.75 GB) - similar a RDS t4g.medium
- Instancia: $0.0835/hora × 730 horas = $60.96
- Storage: 20 GB × $0.20 = $4.00
- Backup: 20 GB × $0.08 = $1.60
TOTAL CLOUD SQL: $66.56/mes
```

#### MongoDB Atlas (Multi-Cloud)
```
Cluster M10:
- Precio base: ~$57/mes
TOTAL MONGODB: $57/mes
```

#### Message Queue - Pub/Sub (NO es RabbitMQ)
```
⚠️ ADVERTENCIA: Pub/Sub NO es compatible con RabbitMQ
Requiere refactorización del código

Si decides usarlo:
- Mensajes: 1M mensajes/mes = ~$2/mes
- Data transfer: incluido
TOTAL PUB/SUB: $2/mes

Alternativa: Usar RabbitMQ en Compute Engine = ~$30-40/mes
```

#### Object Storage - Cloud Storage
```
- Storage: 100 GB × $0.023 = $2.30 (más barato que S3!)
- Operations: ~$0.10
- Data transfer OUT: 100 GB × $0.12 = $12.00
TOTAL STORAGE: $14.40/mes
```

#### Load Balancer - Cloud Load Balancing
```
- Load Balancer: $0.025/hora × 730 horas = $18.25
- Data processed: 200 GB × $0.008 = $1.60
TOTAL LB: $19.85/mes
```

#### Extras
```
- Container Registry: ~$2/mes
- Cloud Logging: ~$3/mes
- Secret Manager: 3 secrets × $0.06 = $0.18/mes
TOTAL EXTRAS: $5.18/mes
```

#### **TOTAL GCP (São Paulo):**
```
Compute:       $228.64
Cloud SQL:     $66.56
MongoDB:       $57.00
Pub/Sub:       $2.00 (pero necesitas RabbitMQ = +$35)
Storage:       $14.40
Load Balancer: $19.85
Extras:        $5.18
────────────────────────
SUBTOTAL:      $393.63/mes (sin RabbitMQ managed)
SUBTOTAL:      $428.63/mes (con RabbitMQ en VM)
IVA (19%):     $81.44
────────────────────────
TOTAL:         $510.07/mes USD
               ~$444,000 CLP/mes

⚠️ Pero requiere refactorización para Pub/Sub o self-hosting RabbitMQ
```

---

### 3.4 Microsoft Azure - Precios Detallados (Región Brazil South)

#### Compute - Azure Container Instances
```
3 contenedores ejecutando 24/7:
- vCPU: 1 vCPU cada uno = 3 vCPU
- RAM: 2 GB cada uno = 6 GB

Costo ACI (Brazil South):
- vCPU: 3 × 730 horas × $0.0000118 × 3600 = $93.16
- RAM: 6 GB × 730 horas × $0.0000014 × 3600 = $22.13
TOTAL COMPUTE: $115.29/mes

Nota: Azure Container Instances es más barato pero menos features que ECS/Cloud Run
Alternativa AKS (más comparable): ~$200-250/mes
```

#### Base de Datos - Azure Database for PostgreSQL
```
Instancia: General Purpose, 2 vCores, 4 GB
- Instancia: $0.119/hora × 730 horas = $86.87
- Storage: 32 GB (mínimo) × $0.125 = $4.00
- Backup: 32 GB incluidos
TOTAL POSTGRESQL: $90.87/mes
```

#### MongoDB Atlas (Multi-Cloud)
```
Cluster M10:
- Precio base: ~$57/mes
TOTAL MONGODB: $57/mes
```

#### Message Queue - Azure Service Bus
```
Premium tier (más similar a RabbitMQ):
- Base: ~$677/mes (CARO!)

Standard tier (limitado):
- Base: $10/mes + $0.05/millón ops = ~$12/mes

Alternativa: RabbitMQ en VM = ~$35-45/mes
TOTAL SERVICE BUS: $12/mes (Standard) o VM con RabbitMQ $40/mes
```

#### Object Storage - Blob Storage
```
- Storage: 100 GB × $0.0184 = $1.84 (más barato!)
- Operations: ~$0.10
- Data transfer OUT: 100 GB × $0.138 = $13.80
TOTAL BLOB: $15.74/mes
```

#### Load Balancer - Azure Load Balancer
```
- Load Balancer Standard: $0.025/hora × 730 = $18.25
- Rules: 5 × $0.01 × 730 = $36.50
- Data processed: incluido
TOTAL LB: $54.75/mes
```

#### Extras
```
- Container Registry: ~$5/mes
- Log Analytics: ~$3/mes
- Key Vault: 3 secrets × $0.03 = $0.09/mes
TOTAL EXTRAS: $8.09/mes
```

#### **TOTAL AZURE (Brazil South):**
```
Compute:       $115.29
PostgreSQL:    $90.87
MongoDB:       $57.00
Service Bus:   $12.00 (limitado) o RabbitMQ VM: $40
Blob Storage:  $15.74
Load Balancer: $54.75
Extras:        $8.09
────────────────────────
SUBTOTAL:      $353.74/mes (Service Bus básico)
SUBTOTAL:      $381.74/mes (RabbitMQ en VM)
IVA (19%):     $72.53
────────────────────────
TOTAL:         $454.27/mes USD
               ~$395,000 CLP/mes

⚠️ Compute es más barato pero PostgreSQL más caro
⚠️ Service Bus Standard es limitado vs RabbitMQ
```

---

### 3.5 Resumen Comparativo de Costos

| Proveedor | Costo Mensual USD | Costo Mensual CLP | Notas |
|-----------|------------------|-------------------|-------|
| **AWS** | $540.52 | ~$470,000 | ✅ Más completo, latencia menor desde Chile |
| **GCP** | $510.07 | ~$444,000 | ⚠️ Sin RabbitMQ managed, latencia mayor |
| **Azure** | $454.27 | ~$395,000 | ⚠️ Service Bus limitado, sin región Chile |

**Tipo de cambio usado:** 1 USD = 870 CLP (aproximado octubre 2025)

---

### 3.6 Costos con Free Tier (Primeros 12 Meses)

Todos los proveedores ofrecen free tiers generosos:

#### AWS Free Tier
- **EC2/Compute:** 750 horas/mes de t2.micro/t3.micro
- **RDS:** 750 horas/mes de db.t2.micro + 20 GB storage
- **S3:** 5 GB storage + 20,000 GET + 2,000 PUT
- **Load Balancer:** 750 horas + 15 GB data
- **Ahorro estimado:** ~$200-250/mes los primeros 12 meses

#### GCP Free Tier
- **$300 en créditos** para gastar en 90 días
- **Cloud Run:** 2M requests/mes + 360,000 GB-seconds
- **Cloud SQL:** No incluido en free tier
- **Cloud Storage:** 5 GB + 5,000 ops
- **Ahorro estimado:** $300 inicial + ~$100/mes en Cloud Run

#### Azure Free Tier
- **$200 en créditos** para gastar en 30 días
- **Container Instances:** No incluido en free tier always-free
- **PostgreSQL:** 750 horas de Flexible Server B1MS
- **Blob Storage:** 5 GB
- **Ahorro estimado:** $200 inicial + ~$80/mes

**Conclusión:** Durante el primer año, los costos reales serían:
- AWS: ~$290-340/mes (52% descuento)
- GCP: ~$410/mes después de créditos (20% descuento)
- Azure: ~$370/mes después de créditos (19% descuento)

---

## 4. Servicios Específicos Requeridos

### 4.1 Comparativa Detallada por Servicio

#### Compute (Contenedores)

| Feature | AWS ECS/Fargate | GCP Cloud Run | Azure Container Instances |
|---------|----------------|---------------|---------------------------|
| **Auto-scaling** | ✅ Completo | ✅ Excelente | 🟡 Básico |
| **Cold start** | ~5-10s | ~1-3s (mejor) | ~10-15s |
| **Max timeout** | Sin límite | 60 min | Sin límite |
| **VPC Integration** | ✅ Nativo | ✅ Nativo | ✅ Nativo |
| **Logging** | CloudWatch | Cloud Logging | Log Analytics |
| **Secrets** | Secrets Manager | Secret Manager | Key Vault |
| **Precio** | $$ Medio | $$ Medio | $ Bajo |
| **Madurez** | 🟢 Alta | 🟢 Alta | 🟡 Media |

**Recomendación:**
- **Mejor opción:** GCP Cloud Run (mejor cold start, excelente DX)
- **Más features:** AWS ECS Fargate (más control, mejor integración)
- **Más barato:** Azure ACI (pero menos features)

---

#### PostgreSQL Managed

| Feature | AWS RDS | GCP Cloud SQL | Azure Database |
|---------|---------|---------------|----------------|
| **Min instance** | db.t4g.micro (1GB) | db-f1-micro (0.6GB) | B1MS (1 vCore) |
| **Auto backup** | ✅ 7 días incluidos | ✅ 7 días incluidos | ✅ 7 días incluidos |
| **Point-in-time** | ✅ Hasta 35 días | ✅ Hasta 35 días | ✅ Hasta 35 días |
| **Read replicas** | ✅ Sí | ✅ Sí | ✅ Sí |
| **Encryption** | ✅ At rest + transit | ✅ At rest + transit | ✅ At rest + transit |
| **Monitoring** | CloudWatch | Cloud Monitoring | Azure Monitor |
| **Precio (4GB)** | ~$74/mes | ~$67/mes | ~$91/mes |

**Recomendación:** GCP Cloud SQL es ligeramente más económico, pero las tres opciones son sólidas.

---

#### MongoDB

Todos usan **MongoDB Atlas** (proveedor independiente):
- Precio consistente: $57/mes para cluster M10
- Multi-región disponible
- Backup automático incluido
- Funciona igual en AWS, GCP y Azure

**Recomendación:** No hay diferencia, usa el mismo proveedor que tu compute.

---

#### Message Queue (RabbitMQ)

| Feature | AWS Amazon MQ | GCP (No oficial) | Azure Service Bus |
|---------|---------------|------------------|-------------------|
| **RabbitMQ Nativo** | ✅ Sí | ❌ No (Pub/Sub) | 🟡 Similar (no idéntico) |
| **Compatibilidad** | 100% RabbitMQ | 0% (requiere refactor) | ~70% (protocolo diferente) |
| **Clustering** | ✅ Multi-AZ | N/A | ✅ Multi-zona |
| **Management UI** | ✅ Incluido | N/A | ✅ Portal Azure |
| **Precio básico** | ~$35/mes | ~$2 Pub/Sub o $40 VM | ~$12 Standard |
| **Precio cluster** | ~$105/mes | N/A | ~$677 Premium |

**Recomendación:**
- **Mejor opción:** AWS Amazon MQ (RabbitMQ nativo, sin cambios de código)
- **Alternativa:** Azure Service Bus Standard (requiere adaptación menor)
- **Evitar:** GCP Pub/Sub (requiere refactorización completa)

---

#### Object Storage

| Feature | AWS S3 | GCP Cloud Storage | Azure Blob |
|---------|--------|-------------------|------------|
| **Precio storage** | $0.115/GB | $0.023/GB (5x más barato!) | $0.0184/GB |
| **Transfer OUT** | $0.15/GB | $0.12/GB | $0.138/GB |
| **Durability** | 99.999999999% | 99.999999999% | 99.999999999% |
| **Lifecycle** | ✅ Sí | ✅ Sí | ✅ Sí |
| **Versioning** | ✅ Sí | ✅ Sí | ✅ Sí |
| **CDN integration** | CloudFront | Cloud CDN | Azure CDN |

**Recomendación:**
- **Más barato:** GCP Cloud Storage (storage) y Azure Blob
- **Más ecosistema:** AWS S3 (más herramientas y integraciones)

---

## 5. Comparativa de Plataformas CI/CD

### 5.1 Estado Actual: GitHub Actions

**Tu situación:**
- Suspendido hasta noviembre por límite
- Free tier: 2,000 minutos/mes para repos privados
- Minutos usados probablemente: ~2,000+/mes

---

### 5.2 GitHub Actions - Análisis Detallado

#### Pricing
```
Free Tier (repos privados):
- 2,000 minutos/mes (Linux)
- Storage: 500 MB

Paid Plans:
- Team: $4/usuario/mes + 3,000 minutos incluidos
- Enterprise: $21/usuario/mes + 50,000 minutos incluidos
- Minutos adicionales: $0.008/minuto (Linux)

Ejemplo (3 devs + 4,000 min/mes):
- Team: 3 × $4 = $12/mes + $16 (2,000 min extra) = $28/mes
- Enterprise: 3 × $21 = $63/mes (incluye 50k minutos)
```

#### Ventajas ✅
- Integración nativa con GitHub
- Amplio marketplace de actions
- Matrix builds fáciles
- Secrets management incluido
- Self-hosted runners gratis

#### Desventajas ❌
- Límites estrictos en free tier
- Minutos se agotan rápido con Docker builds
- No hay pipeline visual

---

### 5.3 GitLab CI/CD - Alternativa Principal

#### Pricing
```
Free Tier:
- 400 minutos/mes (Linux runners compartidos)
- Storage: 5 GB
- Unlimited pipelines en self-hosted runners

Premium: $29/usuario/mes
- 10,000 minutos/mes
- Advanced CI/CD features

Ultimate: $99/usuario/mes
- 50,000 minutos/mes
- Security scanning, etc.

Self-hosted: GRATIS (ilimitado)
```

#### Ventajas ✅
- **Self-hosted runners ilimitados y GRATIS**
- Pipeline visual muy bueno
- GitLab Pages incluido
- Container Registry incluido
- Built-in CI/CD (no necesita setup extra)
- Excelente documentación

#### Desventajas ❌
- Migrar repos de GitHub a GitLab
- UI menos familiar que GitHub
- Marketplace más pequeño

**Recomendación:** ⭐ **MEJOR OPCIÓN** si migras repos o usas self-hosted runners.

---

### 5.4 CircleCI - Cloud Especializado

#### Pricing
```
Free Tier:
- 6,000 minutos/mes (30,000 créditos)
- 1 concurrent job
- Storage: ilimitado

Performance: $15/mes
- 25,000 créditos (12,500 min)
- 5 concurrent jobs

Scale: $2,000/mes
- 200,000 créditos (100,000 min)
- 80 concurrent jobs

Créditos adicionales: $0.0006/crédito
```

#### Ventajas ✅
- Free tier generoso (3x GitHub Actions)
- Excelente performance
- Orbs (reusable configs) muy buenos
- Docker layer caching incluido
- Insights y analytics potentes

#### Desventajas ❌
- Más caro que GitHub Actions en paid tiers
- Requiere aprender nueva sintaxis
- No tan integrado con GitHub

**Recomendación:** Buena opción si necesitas más minutos que GitHub Actions gratis.

---

### 5.5 Jenkins - Self-Hosted Tradicional

#### Pricing
```
Costo directo: $0 (open source)

Costo indirecto:
- Servidor: ~$20-50/mes (VM pequeña)
- Mantenimiento: tiempo de dev
- Plugins: gratis
```

#### Ventajas ✅
- **Completamente gratis** (solo pagas hosting)
- Control total del entorno
- Miles de plugins disponibles
- Sin límites de builds
- Puede correr en tu máquina local

#### Desventajas ❌
- Requiere mantenimiento constante
- UI anticuada
- Setup inicial complejo
- Seguridad es tu responsabilidad
- No hay soporte oficial

**Recomendación:** Solo si tienes tiempo/experiencia para mantenerlo.

---

### 5.6 Otras Alternativas

#### Buildkite
- **Modelo:** Hybrid (UI cloud, runners tu infraestructura)
- **Precio:** $15/usuario/mes (runners ilimitados)
- **Ventaja:** Infinitos builds si usas tu hardware
- **Desventaja:** Requiere gestionar runners

#### Drone CI
- **Modelo:** Self-hosted open source
- **Precio:** Gratis (open source)
- **Ventaja:** Ligero, basado en Docker
- **Desventaja:** Menos features que GitLab

#### GitHub Actions Self-Hosted
- **Modelo:** Usa GitHub Actions pero con tus runners
- **Precio:** $0 (minutos ilimitados en self-hosted)
- **Ventaja:** Gratis si tienes hardware
- **Desventaja:** Gestión de runners

---

### 5.7 Comparativa CI/CD - Resumen

| Plataforma | Minutos Gratis/Mes | Costo Paid | Self-Hosted | Recomendación |
|------------|-------------------|------------|-------------|---------------|
| **GitHub Actions** | 2,000 | $0.008/min | ✅ Sí | 🟡 OK pero limitado |
| **GitLab CI** | 400 (shared) | $29/user | ✅ Sí (GRATIS ilimitado) | ⭐ **MEJOR** |
| **CircleCI** | 6,000 | $15/5k min | ❌ No | 🟢 Buena alternativa |
| **Jenkins** | ∞ | $0 + hosting | ✅ Sí | 🟡 Solo si tienes experiencia |
| **GitHub Self-Hosted** | ∞ | $0 | ✅ Sí | 🟢 Buena si mantienes GitHub |

---

### 5.8 Estimación de Uso Mensual (Tu Proyecto)

Supongamos:
- 3 microservicios
- 10 builds/día por servicio (30 total/día)
- Cada build: 5 minutos (test + build + push image)
- Total: 30 builds × 5 min = 150 min/día = **4,500 min/mes**

#### Costos por Plataforma:

| Plataforma | Costo Mensual | Notas |
|------------|---------------|-------|
| **GitHub Actions** | $20/mes | 2,000 free + 2,500 × $0.008 |
| **GitHub Self-Hosted** | $0 | Si usas tu propio runner |
| **GitLab CI (shared)** | ~$50/mes | Solo 400 free, necesitas Premium |
| **GitLab CI (self-hosted)** | $0 | **GRATIS ilimitado** ⭐ |
| **CircleCI** | $0 | 6,000 free cubre todo ✅ |
| **Jenkins** | $25/mes | Solo costo de VM |

---

## 6. Recomendación Final

### 6.1 Proveedor Cloud Recomendado: **AWS** ⭐

#### Razones:
1. **✅ Latencia óptima desde Chile**
   - AWS Local Zone en Santiago disponible AHORA
   - Latencia ~5-15ms vs ~150-200ms de GCP
   - Región completa en 2026

2. **✅ RabbitMQ Managed Nativo**
   - Amazon MQ con RabbitMQ
   - Sin necesidad de refactorizar código
   - GCP requiere cambiar a Pub/Sub

3. **✅ Ecosistema Completo**
   - Todos los servicios necesarios disponibles
   - Mejor marketplace de herramientas
   - Mayor comunidad en Latam

4. **✅ Mejor para Startups**
   - Free tier generoso (12 meses)
   - Amplia documentación en español
   - Más inversores esperan AWS

#### Desventajas:
- ❌ ~$70-90/mes más caro que GCP/Azure
- ❌ Curva de aprendizaje media-alta
- ❌ Facturación puede ser compleja

---

### 6.2 Alternativa si Presupuesto es Crítico: **GCP**

Si el presupuesto es muy ajustado y puedes refactorizar RabbitMQ a Pub/Sub:
- ~$60/mes más barato que AWS
- Excelente DX (Cloud Run es superior)
- Pero: latencia mayor y sin RabbitMQ nativo

---

### 6.3 CI/CD Recomendado: **GitLab CI con Self-Hosted Runners** ⭐

#### Razones:
1. **✅ Gratis ilimitado con self-hosted runners**
2. **✅ No necesitas cambiar de repositorio** (puedes mirror desde GitHub)
3. **✅ Mejor UI de pipelines**
4. **✅ Container Registry incluido**

#### Setup Recomendado:
```
GitHub (repos principales)
    ↓ (mirror automático)
GitLab (CI/CD)
    ↓ (deploy)
AWS (producción)
```

**Alternativa:** CircleCI si prefieres no gestionar runners (6,000 min gratis cubre tus necesidades).

---

## 7. Plan de Implementación

### 7.1 Fase 1: Setup Cloud (Semana 1-2)

#### AWS Setup
```bash
# Día 1-2: Crear cuenta y configurar IAM
- Crear cuenta AWS
- Configurar MFA
- Crear usuario IAM para CI/CD
- Configurar AWS CLI localmente

# Día 3-4: Networking
- Crear VPC
- Configurar subnets (públicas y privadas)
- Configurar NAT Gateway
- Configurar Security Groups

# Día 5-7: Bases de Datos
- Crear RDS PostgreSQL (db.t4g.medium)
- Crear MongoDB Atlas cluster (M10)
- Configurar backups automáticos
- Configurar point-in-time recovery

# Día 8-10: Servicios
- Crear bucket S3 para PDFs
- Configurar Amazon MQ (RabbitMQ)
- Configurar ECR (Container Registry)
- Configurar Secrets Manager

# Día 11-14: Compute
- Crear cluster ECS
- Configurar Fargate task definitions
- Configurar Application Load Balancer
- Configurar Auto Scaling
- Configurar CloudWatch alarms
```

---

### 7.2 Fase 2: Setup CI/CD (Semana 3)

#### Opción A: GitLab CI (Recomendada)

```bash
# Día 1-2: Setup GitLab
- Crear cuenta GitLab
- Configurar mirror desde GitHub (automático)
- Crear proyectos para cada servicio

# Día 3: Setup Self-Hosted Runner
# En tu máquina local o VM
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v gitlab-runner-config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest

gitlab-runner register \
  --url https://gitlab.com/ \
  --registration-token TU_TOKEN \
  --executor docker \
  --docker-image alpine:latest

# Día 4-5: Crear Pipelines
# Ver sección 7.4 para ejemplos de .gitlab-ci.yml
```

#### Opción B: CircleCI (Sin self-hosted)

```bash
# Día 1: Setup CircleCI
- Crear cuenta CircleCI
- Conectar con GitHub
- Autorizar repos

# Día 2-3: Crear Pipelines
# Ver sección 7.5 para ejemplos de .circleci/config.yml
```

---

### 7.3 Fase 3: Dockerización (Semana 4)

```dockerfile
# Ejemplo: Dockerfile para api-mobile
FROM golang:1.25.3-alpine AS builder

WORKDIR /app

# Dependencias
COPY go.mod go.sum ./
RUN go mod download

# Código
COPY . .

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/api-mobile

# Runtime
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/main .
COPY --from=builder /app/config ./config

EXPOSE 8080

CMD ["./main"]
```

---

### 7.4 Ejemplo Pipeline GitLab CI

```yaml
# .gitlab-ci.yml para api-mobile

stages:
  - test
  - build
  - deploy

variables:
  AWS_REGION: sa-east-1
  ECR_REGISTRY: 123456789.dkr.ecr.sa-east-1.amazonaws.com
  IMAGE_NAME: edugo-api-mobile

test:
  stage: test
  image: golang:1.25.3
  services:
    - postgres:16-alpine
  variables:
    POSTGRES_DB: edugo_test
    POSTGRES_USER: test
    POSTGRES_PASSWORD: test
    DB_HOST: postgres
  before_script:
    - go mod download
  script:
    - go test -v -race -coverprofile=coverage.txt ./...
    - go tool cover -html=coverage.txt -o coverage.html
  coverage: '/coverage: \d+.\d+% of statements/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
  only:
    - branches
    - merge_requests

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - apk add --no-cache aws-cli
    - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
  script:
    - docker build -t $IMAGE_NAME:$CI_COMMIT_SHA .
    - docker tag $IMAGE_NAME:$CI_COMMIT_SHA $ECR_REGISTRY/$IMAGE_NAME:$CI_COMMIT_SHA
    - docker tag $IMAGE_NAME:$CI_COMMIT_SHA $ECR_REGISTRY/$IMAGE_NAME:latest
    - docker push $ECR_REGISTRY/$IMAGE_NAME:$CI_COMMIT_SHA
    - docker push $ECR_REGISTRY/$IMAGE_NAME:latest
  only:
    - main
    - develop

deploy-staging:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache aws-cli
  script:
    - |
      aws ecs update-service \
        --cluster edugo-staging \
        --service api-mobile \
        --force-new-deployment \
        --region $AWS_REGION
  environment:
    name: staging
    url: https://staging.edugo.com
  only:
    - develop

deploy-production:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache aws-cli
  script:
    - |
      aws ecs update-service \
        --cluster edugo-production \
        --service api-mobile \
        --force-new-deployment \
        --region $AWS_REGION
  environment:
    name: production
    url: https://api.edugo.com
  when: manual
  only:
    - main
```

---

### 7.5 Ejemplo Pipeline CircleCI

```yaml
# .circleci/config.yml para api-mobile

version: 2.1

orbs:
  aws-ecr: circleci/aws-ecr@9.0.0
  aws-ecs: circleci/aws-ecs@5.0.0

jobs:
  test:
    docker:
      - image: cimg/go:1.25.3
      - image: cimg/postgres:16.0
        environment:
          POSTGRES_DB: edugo_test
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
    steps:
      - checkout
      - restore_cache:
          keys:
            - go-mod-v1-{{ checksum "go.sum" }}
      - run:
          name: Download dependencies
          command: go mod download
      - save_cache:
          key: go-mod-v1-{{ checksum "go.sum" }}
          paths:
            - /go/pkg/mod
      - run:
          name: Run tests
          command: |
            go test -v -race -coverprofile=coverage.txt ./...
            go tool cover -html=coverage.txt -o coverage.html
      - store_artifacts:
          path: coverage.html

workflows:
  build-deploy:
    jobs:
      - test

      - aws-ecr/build-and-push-image:
          name: build-and-push
          requires:
            - test
          filters:
            branches:
              only:
                - main
                - develop
          repo: edugo-api-mobile
          tag: ${CIRCLE_SHA1},latest
          region: sa-east-1

      - aws-ecs/deploy-service-update:
          name: deploy-staging
          requires:
            - build-and-push
          filters:
            branches:
              only: develop
          family: api-mobile-staging
          cluster: edugo-staging
          container-image-name-updates: "container=api-mobile,tag=${CIRCLE_SHA1}"
          region: sa-east-1

      - hold-production:
          type: approval
          requires:
            - build-and-push
          filters:
            branches:
              only: main

      - aws-ecs/deploy-service-update:
          name: deploy-production
          requires:
            - hold-production
          family: api-mobile-production
          cluster: edugo-production
          container-image-name-updates: "container=api-mobile,tag=${CIRCLE_SHA1}"
          region: sa-east-1
```

---

### 7.6 Costos Estimados Totales (Primer Año)

#### Año 1 con Free Tiers

| Concepto | Costo Mensual | Costo Anual |
|----------|---------------|-------------|
| **AWS (meses 1-12 con free tier)** | $290-340 | $3,600 |
| **MongoDB Atlas** | $57 | $684 |
| **CI/CD (GitLab self-hosted)** | $0 | $0 |
| **Dominio + SSL** | $5 | $60 |
| **Monitoreo (Sentry, etc)** | $0 (free tier) | $0 |
| **TOTAL** | **$352-402/mes** | **$4,344/año** |

**En pesos chilenos:** ~$306,000 - 350,000 CLP/mes (~$3.8M CLP/año)

---

#### Año 2+ (Sin Free Tier)

| Concepto | Costo Mensual | Costo Anual |
|----------|---------------|-------------|
| **AWS (precio completo)** | $540 | $6,480 |
| **MongoDB Atlas** | $57 | $684 |
| **CI/CD (GitLab self-hosted)** | $0 | $0 |
| **Dominio + SSL** | $5 | $60 |
| **Monitoreo** | $0-29 | $0-348 |
| **TOTAL** | **$602-631/mes** | **$7,224-7,572/año** |

**En pesos chilenos:** ~$524,000 - 549,000 CLP/mes (~$6.3M - 6.6M CLP/año)

---

## 8. Checklist Final

### Pre-Deploy ✓
- [ ] Cuenta AWS creada y configurada
- [ ] IAM users y políticas configuradas
- [ ] VPC y networking configurado
- [ ] Bases de datos creadas (RDS + MongoDB Atlas)
- [ ] S3 buckets creados
- [ ] Amazon MQ (RabbitMQ) configurado
- [ ] Secrets Manager configurado
- [ ] ECR (Container Registry) creado

### CI/CD ✓
- [ ] GitLab/CircleCI account creado
- [ ] Repositorios conectados
- [ ] Runners configurados (si GitLab)
- [ ] Pipelines creados para cada servicio
- [ ] Secrets configurados en CI/CD
- [ ] Notificaciones configuradas

### Aplicaciones ✓
- [ ] Dockerfiles creados y optimizados
- [ ] Variables de entorno documentadas
- [ ] Health checks implementados
- [ ] Logging configurado
- [ ] Tests pasando en CI/CD

### Seguridad ✓
- [ ] SSL/TLS configurado
- [ ] Security Groups restrictivos
- [ ] Secrets rotados regularmente
- [ ] Backups automáticos configurados
- [ ] Disaster recovery plan documentado

---

## 9. Próximos Pasos

1. **Revisar Informe 1:** Completar checklist pre-separación
2. **Revisar Informe 2:** Entender estrategia de separación de shared/
3. **Decidir proveedor cloud:** AWS recomendado
4. **Decidir CI/CD:** GitLab CI con self-hosted runners recomendado
5. **Crear plan de implementación detallado**
6. **Comenzar con setup de infraestructura en ambiente de staging**

---

## 10. Recursos Útiles

### AWS
- Calculadora de precios: https://calculator.aws/
- Free Tier: https://aws.amazon.com/free/
- Documentación Go SDK: https://aws.github.io/aws-sdk-go-v2/
- AWS en Español: https://aws.amazon.com/es/

### GitLab CI
- Documentación: https://docs.gitlab.com/ee/ci/
- Self-hosted runners: https://docs.gitlab.com/runner/
- Ejemplos Go: https://docs.gitlab.com/ee/ci/examples/

### Alternativas
- CircleCI: https://circleci.com/pricing/
- GCP Calculator: https://cloud.google.com/products/calculator
- Azure Calculator: https://azure.microsoft.com/es-es/pricing/calculator/

---

**Última actualización:** 30 de Octubre, 2025
**Versión:** 1.0
**Autor:** Claude Code - Análisis para EduGo
