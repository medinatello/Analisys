# Paso 11: Compilar API Administracion

**Duracion estimada:** 10 minutos

## Objetivo
Compilar api-administracion con dataset integrado.

## Pasos de Ejecucion

```bash
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-administracion

# Limpiar builds anteriores
make clean

# Compilar
make build
```

## Validacion

### Criterio de Exito
- [ ] Compilacion exitosa sin errores
- [ ] Binario bin/api-administracion existe
- [ ] Sin warnings

### Comandos de Validacion
```bash
test -f bin/api-administracion && echo "OK: Binario existe"
file bin/api-administracion
```

## Siguiente Paso
→ [paso-12-probar-health.md]
