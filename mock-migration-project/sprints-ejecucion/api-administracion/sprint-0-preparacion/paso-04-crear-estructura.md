# Paso 4: Crear Estructura de Directorios

**Duracion estimada:** 5 minutos
**Prerequisitos:** Paso 3 completado

## Objetivo
Crear la estructura de directorios completa del proyecto.

## Archivos Involucrados
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/cmd/
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/parser/
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/generator/
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/pkg/types/
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/bin/

## Pasos de Ejecucion

### 1. Navegar al directorio
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
```

### 2. Crear todos los directorios
```bash
mkdir -p cmd
mkdir -p pkg/parser
mkdir -p pkg/generator
mkdir -p pkg/types
mkdir -p bin
```

### 3. Verificar estructura
```bash
tree -L 2 -d
```

## Validacion

### Criterio de Exito
- [ ] Directorio cmd existe
- [ ] Directorio pkg/parser existe
- [ ] Directorio pkg/generator existe
- [ ] Directorio pkg/types existe
- [ ] Directorio bin existe

### Comandos de Validacion
```bash
for dir in cmd pkg/parser pkg/generator pkg/types bin; do
  test -d $dir && echo "OK: $dir existe" || echo "ERROR: $dir no existe"
done
```

### Output Esperado
```
OK: cmd existe
OK: pkg/parser existe
OK: pkg/generator existe
OK: pkg/types existe
OK: bin existe
```

## Troubleshooting

**Problema:** Permission denied
**Solucion:** Verificar permisos del directorio padre

## Siguiente Paso
→ [paso-05-validar-acceso.md]
