# Paso 3: Instalar Dependencias

**Duracion estimada:** 10 minutos
**Prerequisitos:** Paso 2 completado

## Objetivo
Descargar e instalar todas las dependencias necesarias para el proyecto.

## Archivos Involucrados
- Modificar: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/go.mod
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/go.sum

## Pasos de Ejecucion

### 1. Navegar al directorio
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
```

### 2. Descargar dependencias
```bash
go mod tidy
```

### 3. Verificar descarga
```bash
go mod verify
```

## Validacion

### Criterio de Exito
- [ ] Archivo go.sum existe
- [ ] Comando go mod verify retorna "all modules verified"
- [ ] No hay errores en la descarga

### Comandos de Validacion
```bash
test -f go.sum && echo "OK: go.sum existe" || echo "ERROR: go.sum no existe"
go mod verify
# Output esperado:
# all modules verified
```

### Output Esperado
```
go: downloading github.com/pingcap/tidb/parser v0.0.0-20231130042310-925c364b3cf3
go: downloading github.com/spf13/cobra v1.8.0
go: downloading github.com/google/uuid v1.3.0
...
all modules verified
```

## Troubleshooting

**Problema:** Cannot download modules
**Solucion:** Verificar conexion a internet y acceso a github.com

**Problema:** Version conflict
**Solucion:** Ejecutar `go mod tidy -v` para ver detalles

## Siguiente Paso
→ [paso-04-crear-estructura.md]
