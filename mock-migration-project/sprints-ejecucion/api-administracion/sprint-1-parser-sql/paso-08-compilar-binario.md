# Paso 8: Compilar Binario Final

**Duracion estimada:** 5 minutos
**Prerequisitos:** Paso 7 completado

## Objetivo
Compilar el binario ejecutable del generador.

## Archivos Involucrados
- Crear: /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/bin/mock-generator

## Pasos de Ejecucion

### 1. Navegar al directorio
```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator
```

### 2. Compilar
```bash
go build -o bin/mock-generator cmd/main.go
```

### 3. Verificar binario
```bash
ls -lh bin/mock-generator
```

### 4. Probar help
```bash
./bin/mock-generator --help
```

## Validacion

### Criterio de Exito
- [ ] Binario bin/mock-generator existe
- [ ] Binario es ejecutable
- [ ] Help muestra uso correcto

### Comandos de Validacion
```bash
test -x bin/mock-generator && echo "OK: Binario ejecutable"
./bin/mock-generator --help | grep -q "mock-generator" && echo "OK: Help funciona"
```

### Output Esperado
```
Genera codigo Go desde scripts SQL de testing

Usage:
  mock-generator [flags]

Flags:
  -h, --help              help for mock-generator
      --output string     Directorio de salida (default "../../mock/dataset")
      --testing string    Directorio con SQL de testing (default "../../postgres/migrations/testing")
```

## Troubleshooting

**Problema:** Compilation errors
**Solucion:** Ejecutar `go mod tidy` y recompilar

## Siguiente Paso
→ [paso-09-probar-parser.md]
