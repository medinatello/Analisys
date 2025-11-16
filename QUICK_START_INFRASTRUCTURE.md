# 🚀 Quick Start - edugo-infrastructure

**Para empezar a usar infrastructure en tus proyectos**

---

## ✅ Estado Actual

- **Versión:** v0.1.1
- **Repositorio:** https://github.com/EduGoGroup/edugo-infrastructure
- **Estado:** ✅ Funcional y publicado
- **CI/CD:** ✅ Funcionando

---

## 📦 Instalación en Proyectos

### api-admin

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-admin

# Agregar dependencia
go get github.com/EduGoGroup/edugo-infrastructure/database@v0.1.1
go mod tidy
```

### api-mobile

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Agregar dependencias
go get github.com/EduGoGroup/edugo-infrastructure/database@v0.1.1
go get github.com/EduGoGroup/edugo-infrastructure/schemas@v0.1.1
go mod tidy
```

### worker

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-worker

# Agregar dependencia
go get github.com/EduGoGroup/edugo-infrastructure/schemas@v0.1.1
go mod tidy
```

---

## 🛠️ Setup de Desarrollo

### 1. Levantar Infraestructura

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure

# Copiar .env
cp .env.example .env

# Setup completo (PostgreSQL + MongoDB + migraciones + seeds)
make dev-setup

# ✅ En 5 minutos todo listo
```

### 2. Desarrollar en api-admin

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-admin

# Crear Makefile con referencia a infrastructure
# Ver: edugo-infrastructure/INTEGRATION_GUIDE.md

make dev-setup  # Levanta lo necesario
make run        # Corre la API
```

---

## 📋 Comandos Útiles

```bash
# Ver servicios corriendo
make dev-ps

# Ver logs
make dev-logs

# Detener todo
make dev-teardown

# Reset completo
make dev-reset

# Ejecutar migraciones manualmente
make migrate-up

# Ver estado de migraciones
make migrate-status
```

---

## 🔄 Workflow de Desarrollo Validado

**Flujo completo probado:**

```
feature branch → PR a dev → CI pasa → Merge a dev
              ↓
dev → PR a main → CI pasa → Merge a main
              ↓
Tags (v0.1.1, database/v0.1.1, schemas/v0.1.1)
              ↓
Release automático (3 GitHub Releases creados)
              ↓
Sync main→dev automático
```

---

## 📚 Documentación

**En infrastructure:**
- README.md - Documentación principal
- INTEGRATION_GUIDE.md - Cómo integrar
- EVENT_CONTRACTS.md - Contratos de eventos
- CONTRIBUTING.md - Workflow de desarrollo
- database/TABLE_OWNERSHIP.md - Ownership

**En Analisys:**
- RESUMEN_SESION_15NOV2025.md - Resumen completo
- DECISION_TASKS/ - Proceso de decisiones
- INFORME_FINAL_SESION_15NOV2025.md - Informe final

---

## ✅ Validado

- ✅ CI/CD funcionando (5 checks pasando)
- ✅ Releases automáticos (3 releases creados)
- ✅ Tags publicados (7 tags totales)
- ✅ Migraciones SQL validadas
- ✅ Tests pasando (database, schemas)
- ✅ Docker Compose funcionando

---

**Fecha:** 16 de Noviembre, 2025  
**Estado:** ✅ LISTO PARA USAR
