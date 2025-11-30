# Paso 3: Crear Directorio Mock en API Mobile

**Duración estimada:** 5 minutos
**Prerequisitos:** ✅ Paso 2 completado

## Objetivo
Crear estructura de directorios para dataset en api-mobile.

## Ejecución

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile

# Crear directorio si no existe
mkdir -p internal/infrastructure/persistence/mock/dataset

# Verificar estructura
tree internal/infrastructure/persistence/mock/
```

**Output esperado:**
```
mock/
├── README.md
├── fixtures/
├── postgres/
│   ├── stubs.go
│   └── user_repository_mock.go
├── mongodb/
│   └── stubs.go
└── dataset/          # NUEVO
```

## Validación
- [ ] Directorio dataset/ creado
- [ ] No sobrescribe archivos existentes

## Siguiente Paso
→ [paso-04-copiar-dataset.md]
