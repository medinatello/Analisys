# Paso 7: Validar Entorno

**Duración estimada:** 5 minutos
**Prerequisitos:** ✅ Paso 6 completado

## Objetivo
Validar Go, paths y permisos antes de comenzar Sprint 1.

## Ejecución

```bash
# Validar Go version
go version

# Validar paths existen
ls -la /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/
ls -la /Users/jhoanmedina/source/EduGo/repos-separados/edugo-infrastructure/tools/mock-generator/

# Validar permisos de escritura
touch /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/test-write && rm /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile/test-write

# Validar make
cd /Users/jhoanmedina/source/EduGo/repos-separados/edugo-api-mobile
make help
```

**Output esperado:**
```
go version go1.21.x darwin/arm64
drwxr-xr-x  api-mobile/
drwxr-xr-x  mock-generator/
Available targets:
  build    Build the application
  ...
```

## Validación
- [ ] Go 1.21+ instalado
- [ ] Todos los paths accesibles
- [ ] Permisos de escritura OK
- [ ] Makefile funciona

## Sprint 0 Completado ✅

**Resultado:**
- ✅ Api-admin validado funcionando
- ✅ Generador validado y funcional
- ✅ 10 repositorios identificados
- ✅ Plan MongoDB creado
- ✅ Entorno listo

## Siguiente Sprint
→ [../sprint-1-reutilizar-generador/README.md]
