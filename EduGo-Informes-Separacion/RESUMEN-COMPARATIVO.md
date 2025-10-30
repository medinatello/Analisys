# Resumen Comparativo - Decisiones Rápidas

**Fecha:** 30 de Octubre, 2025

---

## 🏆 Recomendaciones Finales

### ⭐ CLOUD PROVIDER: AWS

```
✅ VENTAJAS                        ❌ DESVENTAJAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Latencia 5-15ms desde Chile     ✗ ~$70-90/mes más caro
✓ Amazon MQ (RabbitMQ nativo)     ✗ Curva aprendizaje media
✓ Región completa en 2026         ✗ Facturación compleja
✓ Ecosistema más completo
✓ Free tier 12 meses
✓ Mejor documentación español
```

**Costo:** $540/mes (~$470k CLP) | Primer año: $290-340/mes con free tier

---

### ⭐ CI/CD: GitLab CI (Self-Hosted)

```
✅ VENTAJAS                        ❌ DESVENTAJAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ GRATIS ILIMITADO                ✗ Requiere gestionar runner
✓ Mejor UI de pipelines           ✗ Configuración inicial
✓ Container Registry incluido
✓ Mirror desde GitHub fácil
✓ Excelente documentación
```

**Costo:** $0 (gratis)

---

## 📊 Tabla Comparativa Cloud Providers

| Criterio | AWS ⭐ | GCP | Azure |
|----------|--------|-----|-------|
| **Costo/mes** | $540 | $510 | $454 |
| **Costo/mes CLP** | ~$470k | ~$444k | ~$395k |
| **Latencia desde Chile** | 🟢 5-15ms | 🔴 150-200ms | 🟡 100-150ms |
| **RabbitMQ Managed** | ✅ Sí (Amazon MQ) | ❌ No (Pub/Sub) | 🟡 Service Bus |
| **Presencia Chile** | ✅ Local Zone + Región 2026 | ❌ No | 🟡 Azure Stack |
| **PostgreSQL** | ✅ RDS | ✅ Cloud SQL | ✅ Azure DB |
| **MongoDB** | ✅ Atlas | ✅ Atlas | ✅ Atlas |
| **Object Storage** | ✅ S3 | ✅ Cloud Storage | ✅ Blob Storage |
| **Free Tier** | 🟢 12 meses | 🟢 $300 + always | 🟢 $200 + 12 meses |
| **Cuota mercado** | 🟢 30% | 🟡 13% | 🟢 20% |
| **Documentación ES** | 🟢 Excelente | 🟡 Buena | 🟡 Buena |
| **Startup friendly** | 🟢 Sí | 🟢 Sí | 🟡 Más enterprise |

### Veredicto por Necesidad:

- **Latencia crítica:** ➡️ **AWS** (única con Local Zone en Chile)
- **Presupuesto ajustado:** ➡️ **GCP** o **Azure** (pero requieren cambios)
- **RabbitMQ nativo:** ➡️ **AWS** o **Azure** (GCP NO tiene)
- **Mejor DX:** ➡️ **GCP** (Cloud Run es superior)
- **Más maduro:** ➡️ **AWS** (líder de mercado)

---

## 📊 Tabla Comparativa CI/CD

| Criterio | GitLab CI ⭐ | CircleCI | GitHub Actions | Jenkins |
|----------|--------------|----------|----------------|---------|
| **Minutos gratis** | ∞ (self-hosted) | 6,000 | 2,000 | ∞ (self-hosted) |
| **Costo extra min** | $0 | $0.0006 | $0.008 | $0 + hosting |
| **Self-hosted** | ✅ Gratis | ❌ No | ✅ Gratis | ✅ Gratis |
| **UI Pipeline** | 🟢 Excelente | 🟡 Bueno | 🟡 Básico | 🔴 Antiguo |
| **Container Registry** | ✅ Incluido | ❌ No | ✅ Incluido (GHCR) | ❌ No |
| **Curva aprendizaje** | 🟡 Media | 🟡 Media | 🟢 Fácil | 🔴 Alta |
| **Mantenimiento** | 🟡 Runner setup | 🟢 Ninguno | 🟡 Runner setup | 🔴 Alto |
| **Para tu uso (4,500 min)** | $0 | $0 | $20/mes | $25/mes |

### Veredicto por Necesidad:

- **Gratis ilimitado:** ➡️ **GitLab CI** (con self-hosted) o **Jenkins**
- **Fácil y sin gestión:** ➡️ **CircleCI** (6k min gratis cubre todo)
- **Mínimo cambio:** ➡️ **GitHub Actions** (self-hosted o pagar)
- **Más features:** ➡️ **GitLab CI** (UI, Registry, etc.)
- **Evitar:** ➡️ **Jenkins** (a menos que tengas experiencia)

---

## 💰 Comparativa de Costos Detallada

### Primer Año (con Free Tiers)

| Componente | AWS | GCP | Azure |
|------------|-----|-----|-------|
| Compute | $115 | $115 | $58 |
| PostgreSQL | $37 | $33 | $45 |
| MongoDB | $57 | $57 | $57 |
| RabbitMQ | $17 | $35* | $20* |
| Storage | $13 | $7 | $8 |
| Load Balancer | $12 | $10 | $27 |
| Extras | $4 | $3 | $4 |
| **SUBTOTAL** | **$255** | **$260** | **$219** |
| MongoDB Atlas | $57 | $57 | $57 |
| **TOTAL/MES** | **$312** | **$317** | **$276** |
| **TOTAL/AÑO** | **$3,744** | **$3,804** | **$3,312** |

*Con refactorización o VM no managed

---

### Años Siguientes (sin Free Tier)

| Componente | AWS | GCP | Azure |
|------------|-----|-----|-------|
| Compute | $229 | $229 | $115 |
| PostgreSQL | $74 | $67 | $91 |
| MongoDB | $57 | $57 | $57 |
| RabbitMQ | $35 | $35* | $40* |
| Storage | $27 | $14 | $16 |
| Load Balancer | $25 | $20 | $55 |
| Extras | $8 | $5 | $8 |
| **SUBTOTAL** | **$455** | **$427** | **$382** |
| MongoDB Atlas | $57 | $57 | $57 |
| **TOTAL/MES** | **$512** | **$484** | **$439** |
| **TOTAL/AÑO** | **$6,144** | **$5,808** | **$5,268** |

### En Pesos Chilenos (TC: 1 USD = 870 CLP)

| Periodo | AWS | GCP | Azure |
|---------|-----|-----|-------|
| **Año 1** | $3.7M CLP | $3.8M CLP | $3.3M CLP |
| **Año 2+** | $6.1M CLP | $5.8M CLP | $5.3M CLP |
| **Diferencia** | +$2.4M | +$2.0M | +$2.0M |

**Nota:** Precios referenciales, pueden variar según uso real.

---

## 🎯 Matriz de Decisión

### Si tu prioridad es...

#### 💰 **COSTO MÍNIMO**
```
1º Azure:    $439/mes ($382k CLP)
2º GCP:      $484/mes ($421k CLP)
3º AWS:      $512/mes ($445k CLP)

⚠️ Pero considera:
- GCP: Sin RabbitMQ nativo (requiere refactorización)
- Azure: Sin presencia en Chile (latencia alta)
```

#### ⚡ **LATENCIA ÓPTIMA**
```
1º AWS:      5-15ms (Local Zone Santiago)
2º Azure:    100-150ms (Brazil South)
3º GCP:      150-200ms (São Paulo)

✅ AWS es la ÚNICA opción si latencia es crítica
```

#### 🔧 **COMPATIBILIDAD (sin refactorizar)**
```
1º AWS:      100% compatible (RabbitMQ nativo)
2º Azure:    ~70% compatible (Service Bus)
3º GCP:      0% compatible (requiere cambiar a Pub/Sub)

✅ AWS es la ÚNICA opción para RabbitMQ nativo
```

#### 🚀 **EXPERIENCIA DE DESARROLLO**
```
1º GCP:      Cloud Run (mejor cold start, mejor DX)
2º AWS:      ECS/Fargate (más features, más control)
3º Azure:    ACI (más básico)

✅ GCP Cloud Run es superior en DX
```

#### 📈 **MADUREZ Y ECOSISTEMA**
```
1º AWS:      30% mercado, 200+ servicios, 19 años
2º Azure:    20% mercado, 200+ servicios, 15 años
3º GCP:      13% mercado, 100+ servicios, 15 años

✅ AWS tiene el ecosistema más maduro
```

---

## 🔍 Escenarios Comunes

### Escenario 1: Startup con presupuesto muy limitado
```
Recomendación: GCP + CircleCI

Cloud: GCP ($484/mes)
- Más económico
- Excelente DX con Cloud Run
- Pero: Requiere refactorizar RabbitMQ a Pub/Sub

CI/CD: CircleCI ($0)
- 6,000 minutos gratis cubre tus necesidades
- Sin gestión de runners
- Fácil de usar

Total: $484/mes (~$421k CLP)

⚠️ Consideración: Tiempo de refactorización (1-2 semanas)
```

---

### Escenario 2: Startup enfocada en velocidad/latencia
```
Recomendación: AWS + GitLab CI ⭐⭐⭐

Cloud: AWS ($512/mes)
- Latencia óptima (5-15ms)
- RabbitMQ nativo (sin refactorización)
- Región completa en 2026
- Sin cambios de código

CI/CD: GitLab CI Self-Hosted ($0)
- Gratis ilimitado
- Mejor UI de pipelines
- Container Registry incluido

Total: $512/mes (~$445k CLP)

✅ RECOMENDACIÓN PRINCIPAL
```

---

### Escenario 3: Presupuesto medio, quiero simplicidad
```
Recomendación: Azure + CircleCI

Cloud: Azure ($439/mes)
- Balance precio-features
- Service Bus similar a RabbitMQ (cambios menores)
- PostgreSQL y Storage buenos

CI/CD: CircleCI ($0)
- 6,000 minutos gratis
- Sin gestión de runners
- Fácil setup

Total: $439/mes (~$382k CLP)

⚠️ Consideración: Latencia mayor (100-150ms)
```

---

### Escenario 4: Quiero lo mejor sin importar costo
```
Recomendación: AWS + CircleCI Premium

Cloud: AWS ($512/mes)
- Mejor latencia
- Más servicios
- Ecosistema más maduro

CI/CD: CircleCI Performance ($15/mes)
- 12,500 minutos
- 5 concurrent jobs
- Docker layer caching

Total: $527/mes (~$458k CLP)

✅ Setup más robusto y profesional
```

---

## 📋 Checklist de Decisión

### Antes de decidir, responde:

#### Sobre tu proyecto:
- [ ] ¿Cuántos usuarios esperamos en los primeros 6 meses?
- [ ] ¿Latencia es crítica para la experiencia del usuario?
- [ ] ¿Tenemos presupuesto para $400-500/mes (~$350-435k CLP)?
- [ ] ¿Tenemos tiempo para refactorizar RabbitMQ? (1-2 semanas)
- [ ] ¿Esperamos crecer 2x cada 6 meses?

#### Sobre tu equipo:
- [ ] ¿Alguien tiene experiencia con cloud providers específicos?
- [ ] ¿Tenemos tiempo para aprender nueva plataforma CI/CD?
- [ ] ¿Tenemos capacidad para gestionar self-hosted runners?
- [ ] ¿Preferimos pagar más por simplicidad o gestionar para ahorrar?

#### Sobre el negocio:
- [ ] ¿Inversores esperan ver AWS? (más común en startups)
- [ ] ¿Es un MVP o producto a largo plazo?
- [ ] ¿Tenemos runway para 6-12 meses de operación?
- [ ] ¿Podemos justificar gastos de cloud ante stakeholders?

---

## 🎬 Siguiente Paso

### ¿Ya decidiste? Sigue este orden:

1. **Lee el README.md** (5 minutos)
   - Contexto general
   - Decisiones clave

2. **Lee el Informe que corresponda según tu decisión:**

   - **Si elegiste AWS:** ➡️ Lee Informe 3 sección AWS (20 min)
   - **Si elegiste GCP:** ➡️ Lee Informe 3 sección GCP (20 min)
   - **Si elegiste Azure:** ➡️ Lee Informe 3 sección Azure (20 min)

3. **Lee Informe 1** (1 hora)
   - Completar checklist
   - Preparar proyecto para separación

4. **Lee Informe 2** (1 hora)
   - Entender estrategia de shared/
   - Preparar extracción de módulos

5. **Ejecuta el plan** (6-9 semanas)
   - Seguir cronograma
   - Documentar progreso
   - Ajustar según necesidades

---

## 📞 Recursos Adicionales

### Calculadoras de Precio:
- AWS: https://calculator.aws/
- GCP: https://cloud.google.com/products/calculator
- Azure: https://azure.microsoft.com/pricing/calculator/

### Documentación Oficial:
- AWS Go SDK: https://aws.github.io/aws-sdk-go-v2/
- GCP Go SDK: https://cloud.google.com/go/docs
- Azure Go SDK: https://learn.microsoft.com/azure/developer/go/

### CI/CD:
- GitLab CI: https://docs.gitlab.com/ee/ci/
- CircleCI: https://circleci.com/docs/
- GitHub Actions: https://docs.github.com/actions

---

**Última actualización:** 30 de Octubre, 2025
**Generado por:** Claude Code - Análisis para EduGo
