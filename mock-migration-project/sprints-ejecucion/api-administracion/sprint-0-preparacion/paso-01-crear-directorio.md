# Paso 1: Crear Directorio del Proyecto

**Duracion estimada:** 5 minutos
**Prerequisitos:** Ninguno

## Objetivo
Crear el directorio base donde vivira el generador de dataset mock.

## Archivos Involucrados
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/

## Pasos de Ejecucion

### 1. Navegar al repositorio infrastructure
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure
```

### 2. Crear directorio del generador
```bash
mkdir -p tools/mock-generator
cd tools/mock-generator
```

### 3. Verificar creacion
```bash
pwd
```

## Validacion

### Criterio de Exito
- [ ] El comando pwd muestra: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
- [ ] El directorio existe y esta vacio

### Comandos de Validacion
```bash
ls -la
# Output esperado:
# total 0
# drwxr-xr-x  2 user  staff   64 Nov 30 XX:XX .
# drwxr-xr-x  3 user  staff   96 Nov 30 XX:XX ..
```

## Troubleshooting

**Problema:** Permission denied
**Solucion:** Verificar que tienes permisos de escritura en el directorio edugo-infrastructure

**Problema:** Directory not found
**Solucion:** Verificar que la ruta base del repositorio es correcta

## Siguiente Paso
→ [paso-02-inicializar-go-mod.md]
