# UI Roadmap - EduGo Apple App

> **Documento Pivote**: Guía completa de UI para la aplicación Apple de EduGo

**Fecha de creación**: 1 de Diciembre, 2025  
**Estado**: ✅ Análisis Completo  
**Plataformas objetivo**: iOS 18+, iPadOS 18+, macOS 15+, visionOS 2+  
**Versiones futuras**: iOS 26, macOS 26 (Liquid Glass preparado)

---

## Resumen del Análisis

Este roadmap fue generado mediante análisis exhaustivo de:
- **Base de datos**: 13 tablas PostgreSQL, 9 colecciones MongoDB
- **API Mobile**: 15 endpoints (estudiantes, materiales, quizzes)
- **API Admin**: 35+ endpoints + 12 funcionalidades faltantes documentadas
- **Apple App actual**: 72% completado, 10 pantallas existentes
- **GuideDesign**: Tokens de diseño para 9 plataformas

---

## Índice de Contenidos

### 0. Plan de Trabajo y Backend
| Documento | Estado | Descripción |
|-----------|--------|-------------|
| [PLAN-TRABAJO-ORDENADO.md](./PLAN-TRABAJO-ORDENADO.md) | ✅ | **FLUJO COMPLETO**: BD → APIs → Cross → App Estudiantes → App Admin |
| [MIGRACIONES-ADMIN.md](./MIGRACIONES-ADMIN.md) | ✅ | **SQL COMPLETO**: 16 tablas con definiciones detalladas para fase admin |
| [ENDPOINTS-BACKEND-REQUERIDOS.md](./ENDPOINTS-BACKEND-REQUERIDOS.md) | ✅ | **CONSOLIDADO**: Todos los endpoints nuevos/modificaciones necesarias |

### 1. Arquitectura de Apps
| Documento | Estado | Descripción |
|-----------|--------|-------------|
| [ANALISIS-APPS.md](./arquitectura/ANALISIS-APPS.md) | ✅ | Análisis 1 vs 2 apps - **Recomendación: 2 apps separadas** |

### 2. App Principal (Estudiantes)
| Documento | Estado | Descripción |
|-----------|--------|-------------|
| [PANTALLAS-EXISTENTES.md](./estudiantes/PANTALLAS-EXISTENTES.md) | ✅ | 8 pantallas a mejorar (Splash, Login, Home, Settings, Progress, Courses, Calendar, Community) |
| [PANTALLAS-NUEVAS-PARTE1.md](./estudiantes/PANTALLAS-NUEVAS-PARTE1.md) | ✅ | MaterialsListView, MaterialDetailView, PDFReaderView, SummaryView |
| [PANTALLAS-NUEVAS-PARTE2.md](./estudiantes/PANTALLAS-NUEVAS-PARTE2.md) | ✅ | QuizView, QuizResultView, AttemptHistoryView, SchoolSelectorView |

### 3. App de Administración
| Documento | Estado | Descripción |
|-----------|--------|-------------|
| [README.md](./administracion/README.md) | ✅ | Overview, arquitectura, usuarios, permisos, roadmap |
| [PANTALLAS.md](./administracion/PANTALLAS.md) | ✅ | 18 pantallas (10 con endpoints, 8 futuras) |
| [ENDPOINTS-FALTANTES.md](./administracion/ENDPOINTS-FALTANTES.md) | ✅ | 12 grupos de endpoints pendientes (~60 endpoints) |

### 4. Flujos de Navegación
| Documento | Estado | Descripción |
|-----------|--------|-------------|
| [README.md](./flujos/README.md) | ✅ | Índice de flujos |
| [FLUJO-ESTUDIANTE.md](./flujos/FLUJO-ESTUDIANTE.md) | ✅ | Flujo completo del rol estudiante |
| [FLUJO-DOCENTE.md](./flujos/FLUJO-DOCENTE.md) | ✅ | Flujo del rol docente |
| [FLUJO-ADMIN.md](./flujos/FLUJO-ADMIN.md) | ✅ | Flujo del rol administrador |
| [NAVEGACION-PLATAFORMA.md](./flujos/NAVEGACION-PLATAFORMA.md) | ✅ | iPhone, iPad, macOS, visionOS |

### 5. Specs Técnicos Nuevos
| Documento | Estado | Descripción |
|-----------|--------|-------------|
| [SPEC-OFFLINE.md](./specs-nuevos/SPEC-OFFLINE.md) | ✅ | Persistencia local y descarga de PDFs (~275h) |
| [SPEC-SYNC.md](./specs-nuevos/SPEC-SYNC.md) | ✅ | Sincronización bidireccional (~287h) |

---

## Estructura de Carpetas

```
ui-roadmap/
├── README.md                          # Este archivo (índice principal)
├── PLAN-TRABAJO-ORDENADO.md           # ⭐ Flujo de trabajo ordenado
├── MIGRACIONES-ADMIN.md               # ⭐ SQL completo para 16 tablas admin
├── ENDPOINTS-BACKEND-REQUERIDOS.md    # ⭐ CONSOLIDADO para backend
├── arquitectura/
│   └── ANALISIS-APPS.md               # 1 vs 2 apps (recomendación final)
├── estudiantes/
│   ├── PANTALLAS-EXISTENTES.md        # 8 pantallas a mejorar
│   ├── PANTALLAS-NUEVAS-PARTE1.md     # Materials, PDF, Summary
│   └── PANTALLAS-NUEVAS-PARTE2.md     # Quiz, Results, History, SchoolSelector
├── administracion/
│   ├── README.md                      # Overview app admin
│   ├── PANTALLAS.md                   # 18 pantallas detalladas
│   └── ENDPOINTS-FALTANTES.md         # 12 grupos de endpoints
├── flujos/
│   ├── README.md                      # Índice de flujos
│   ├── FLUJO-ESTUDIANTE.md            # Diagrama + detalle
│   ├── FLUJO-DOCENTE.md               # Diagrama + detalle
│   ├── FLUJO-ADMIN.md                 # Diagrama + detalle
│   └── NAVEGACION-PLATAFORMA.md       # Por dispositivo
└── specs-nuevos/
    ├── SPEC-OFFLINE.md                # Persistencia local
    └── SPEC-SYNC.md                   # Sincronización
```

---

## Decisiones Clave

### Arquitectura: 2 Apps Separadas (Recomendado)

| Criterio | 1 App Unificada | 2 Apps Separadas |
|----------|-----------------|------------------|
| Tamaño bundle | 60 MB | 40 MB (estudiante) |
| Seguridad | Código admin en dispositivos estudiantes | Separación total |
| App Store | Una categoría | Educación + Empresa |
| Desarrollo | Conflictos de merge | Equipos paralelos |
| **Puntuación** | 38% | **77%** ✅ |

Ver [ANALISIS-APPS.md](./arquitectura/ANALISIS-APPS.md) para justificación completa.

### Pantallas Prioritarias (MVP Estudiantes)

| Prioridad | Pantalla | Endpoint | Esfuerzo |
|-----------|----------|----------|----------|
| 🔴 Alta | MaterialsListView | GET /v1/materials | 3-4 días |
| 🔴 Alta | MaterialDetailView | GET /v1/materials/:id | 2-3 días |
| 🔴 Alta | PDFReaderView | GET .../download-url | 5-7 días |
| 🔴 Alta | QuizView | GET/POST .../assessment | 4-5 días |
| 🔴 Alta | QuizResultView | GET /v1/attempts/:id/results | 2-3 días |
| 🟡 Media | SummaryView | GET .../summary | 2-3 días |
| 🟡 Media | AttemptHistoryView | GET /v1/users/me/attempts | 2-3 días |
| 🟡 Media | SchoolSelectorView | Requiere nuevos endpoints | 3-4 días |

### Endpoints Faltantes Críticos

**Para App Estudiante:**
```
GET  /v1/users/me/schools        # Lista escuelas del usuario
POST /v1/users/me/active-school  # Cambiar contexto activo
GET  /v1/users/me/active-school  # Obtener contexto actual
```

**Para App Admin (12 grupos):**
1. Ciclos académicos (6 endpoints)
2. Horarios/programación (7 endpoints)
3. Importación masiva (4 endpoints)
4. Aulas/recursos (6 endpoints)
5. Eventos escolares (6 endpoints)
6. Reportes (5 endpoints)
7. Auditoría (3 endpoints)
8. Escalas calificación (2 endpoints)
9. Roles/permisos (4 endpoints)
10. Certificados (4 endpoints)
11. Notificaciones (4 endpoints)
12. Pagos/finanzas (6 endpoints)

Ver [ENDPOINTS-FALTANTES.md](./administracion/ENDPOINTS-FALTANTES.md) para especificaciones completas.

---

## Métricas del Análisis

| Métrica | Cantidad |
|---------|----------|
| Documentos generados | 14 |
| Líneas de documentación | ~15,000+ |
| Pantallas documentadas (estudiantes) | 16 (8 existentes + 8 nuevas) |
| Pantallas documentadas (admin) | 18 |
| Endpoints documentados | 95+ |
| Componentes UI especificados | 40+ |
| Flujos de navegación | 4 completos |
| Specs técnicos | 2 (OFFLINE + SYNC) |

---

## Plan de Implementación Sugerido

### Fase 1: MVP Estudiantes (6-8 semanas)
1. **Semana 1-2**: Unificar pantallas existentes (Home, Settings)
2. **Semana 3-4**: MaterialsListView + MaterialDetailView
3. **Semana 5-6**: PDFReaderView + SummaryView
4. **Semana 7-8**: QuizView + QuizResultView

### Fase 2: Completar Estudiantes (4-6 semanas)
1. AttemptHistoryView
2. SchoolSelectorView (requiere endpoints nuevos)
3. Sistema de notificaciones UI
4. SPEC-OFFLINE básico

### Fase 3: App Administración (8-12 semanas)
1. Setup proyecto nuevo (reutilizar módulos SPM)
2. Dashboard + CRUD Escuelas
3. Árbol académico + Membresías
4. CRUD Usuarios + Tutores

### Fase 4: Features Avanzados (ongoing)
1. SPEC-OFFLINE completo
2. SPEC-SYNC
3. Endpoints admin faltantes
4. Reportes y auditoría

---

## Cómo Usar Esta Documentación

### Para Desarrolladores iOS
1. Leer arquitectura primero → [ANALISIS-APPS.md](./arquitectura/ANALISIS-APPS.md)
2. Revisar pantallas existentes → [PANTALLAS-EXISTENTES.md](./estudiantes/PANTALLAS-EXISTENTES.md)
3. Implementar nuevas → [PANTALLAS-NUEVAS-*.md](./estudiantes/)
4. Seguir flujos → [flujos/](./flujos/)

### Para Backend
1. Ver endpoints faltantes → [ENDPOINTS-FALTANTES.md](./administracion/ENDPOINTS-FALTANTES.md)
2. Revisar specs técnicos → [specs-nuevos/](./specs-nuevos/)

### Para Product/Diseño
1. Revisar flujos completos → [flujos/](./flujos/)
2. Ver prioridades en cada documento
3. Cada pantalla indica qué es MVP vs fase posterior

---

## Notas Importantes

### Sobre "Semi-Dummy"
Algunas funcionalidades se marcan como **semi-dummy**, significa:
- ✅ Se conecta al endpoint real
- ✅ Muestra datos reales
- ❌ NO implementa validaciones complejas de negocio
- ❌ NO implementa casos edge
- 📝 Documenta qué falta para ser completo

### Sobre Persistencia Offline
- La app ya tiene infraestructura base (NetworkSyncCoordinator, OfflineQueue)
- SPEC-OFFLINE extiende esto para PDFs y progreso
- SPEC-SYNC agrega sincronización bidireccional

### Sobre DummyJSON
- **YA NO SE USA** - eliminar referencias en el código
- La app conecta directamente a api-mobile y api-admin

---

**Generado por**: Claude Code con UltraThink  
**Análisis completado**: 1 de Diciembre, 2025  
**Total tiempo de análisis**: ~2 horas con agentes paralelos
