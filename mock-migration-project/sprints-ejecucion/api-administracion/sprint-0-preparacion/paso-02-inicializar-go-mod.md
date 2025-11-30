# Paso 2: Inicializar Modulo Go

**Duracion estimada:** 5 minutos
**Prerequisitos:** Paso 1 completado

## Objetivo
Inicializar el proyecto Go con go.mod y definir las dependencias basicas.

## Archivos Involucrados
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/go.mod

## Pasos de Ejecucion

### 1. Navegar al directorio del generador
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
```

### 2. Crear go.mod
```bash
cat > go.mod << 'GOMOD'
module github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator

go 1.21

require (
    github.com/pingcap/tidb/parser v0.0.0-20231130042310-925c364b3cf3
    github.com/spf13/cobra v1.8.0
    github.com/google/uuid v1.3.0
)
GOMOD
```

### 3. Verificar contenido
```bash
cat go.mod
```

## Codigo a Implementar

**Archivo:** `/Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/go.mod`
```go
module github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator

go 1.21

require (
    github.com/pingcap/tidb/parser v0.0.0-20231130042310-925c364b3cf3
    github.com/spf13/cobra v1.8.0
    github.com/google/uuid v1.3.0
)
```

## Validacion

### Criterio de Exito
- [ ] Archivo go.mod existe
- [ ] Archivo contiene module path correcto
- [ ] Archivo especifica Go 1.21

### Comandos de Validacion
```bash
test -f go.mod && echo "OK: go.mod existe" || echo "ERROR: go.mod no existe"
grep "module github.com/EduGoGroup/edugo-infrastructure/tools/mock-generator" go.mod && echo "OK: module path correcto"
```

## Troubleshooting

**Problema:** Sintaxis incorrecta en go.mod
**Solucion:** Copiar exactamente el contenido del codigo arriba

## Siguiente Paso
→ [paso-03-instalar-dependencias.md]
